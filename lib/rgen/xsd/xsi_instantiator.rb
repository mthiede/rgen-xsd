require 'nokogiri'
require 'andand'
require 'rgen/ecore/ecore'
require 'rgen/instantiator/reference_resolver'

module RGen
module XSD

class XSIInstantiator
  attr_reader :unresolved_refs
  attr_reader :namespaces

  def initialize(mm, env)
    @mm = mm
    @env = env
    @classes_by_xml_name = nil 
    @namespaces = []
  end

  def instantiate(file, options={})
    @unresolved_refs = []
    @target_identifier_provider = options[:target_identifier_provider] ||
      lambda do |node| node["id"] end
    root = nil
    root_class = options[:root_class].andand.ecore || root_class(doc.root.name)
    File.open(file) do |f|
      doc = Nokogiri::XML(f)
      @namespaces = doc.root.namespace_definitions
      root =instantiate_node(doc.root, root_class)
    end
    root
  end

  def resolve_namespace(str)
    if str =~ /:/
      prefix, name = str.split(":")
    else
      prefix, name = nil, str
    end
    # the default namespace has a prefix of nil
    href = namespaces.find{|ns| ns.prefix == prefix}.andand.href
    # built in xml schema namespace
    if !href 
      if prefix == "xml"
        href = "http://www.w3.org/XML/1998/namespace" 
      elsif prefix
        puts "WARN: Can not resolve namespace prefix #{prefix}"
      end
    end
    [href, name]
  end

  private

  def xsi_type_value(node)
    node.attribute_nodes.find{|n| is_xsi_type?(n)}.andand.text
  end

  def instantiate_node(node, eclass, element=nil, wrapper_features=nil)
    if !element
      element = eclass.instanceClass.new
      @env << element
    end
    set_attribute_values(element, node, wrapper_features)
    simple_content = ""
    node.children.each do |c|
      if c.text?
        simple_content << c.text
      elsif c.element?
        if wrapper_features
          feats = wrapper_features.select{|f| xml_name(f) == c.name}
        else
          feats = features_by_xml_name(element.class, c.name) || []
        end
        if feats.size == 1
          begin
            if feats.first.is_a?(RGen::ECore::EReference)
              if feats.first.containment
                element.setOrAddGeneric(feats.first.name,
                  instantiate_node(c, reference_target_type(feats.first, xsi_type_value(c))))
              else
                proxy = RGen::MetamodelBuilder::MMProxy.new(@target_identifier_provider.call(c))
                @unresolved_refs <<
                  RGen::Instantiator::ReferenceResolver::UnresolvedReference.new(element, feats.first.name, proxy)
                element.setOrAddGeneric(feats.first.name, proxy)
              end
            else
              element.setOrAddGeneric(feats.first.name, value_from_string(element, feats.first, c.text))
            end
          rescue Exception => e
            puts "Line: #{node.line}: #{e}\n#{e.backtrace.join("\n")}"
          end
        else
          if wrapper_features
            # already inside a wrapper
            wrapper_feats = []
          else
            wrapper_feats = features_by_xml_wrapper_name(element.class, c.name) || []
          end
          if wrapper_feats.size > 0
            instantiate_node(c, eclass, element, wrapper_feats)
          elsif can_take_any(eclass)
            begin
              # currently the XML node is added to the model
              element.setOrAddGeneric("anyObject", c)
            rescue Exception => e
              puts "Line: #{node.line}: #{e}\n#{e.backtrace.join("\n")}"
            end
          else
            problem "could not determine reference for tag #{c.name}, #{feats.size} options", node
          end
        end
      end
    end
    if simple_content.strip.size > 0
      set_simple_content(element, simple_content.strip)
    end
    element
  end

  def set_simple_content(element, value)
    a = element.class.ecore.eAllAttributes.find{|a| annotation_value(a, "simpleContent") == "true"} 
    if a
      element.setGeneric(a.name, value_from_string(element, a, value))
    else
      raise "could not set simple content for element #{element.class.name}"
    end
  end

  def is_xsi_type?(attr_node)
    attr_node.namespace.andand.href == "http://www.w3.org/2001/XMLSchema-instance" && attr_node.node_name == "type"
  end

  def set_attribute_values(element, node, wrapper_features)
    node.attribute_nodes.each do |attrnode|
      next if is_xsi_type?(attrnode)
      name = attrnode.node_name
      if wrapper_features
        feats = wrapper_features.select{|f| xml_name(f) == name}
      else
        feats = features_by_xml_name(element.class, name) || []
      end
      if feats.size == 1
        f = feats.first
        str = node.attr(name)
        if f.many
          # list datatype implies whitespace handling method "collapse", 
          # removing white space in the front and back and reducing multiple whitespaces to one
          # list items are separated by spaces
          str.strip.split(/\s+/).each do |s|
            element.addGeneric(f.name, value_from_string(element, f, s))
          end
        else
          element.setGeneric(f.name, value_from_string(element, f, str))
        end 
      elsif name == "schemaLocation" || name == "noNamespaceSchemaLocation"
        # ignore, this may occure with any XML element
      else
        problem "could not determine feature for attribute #{name}, #{feats.size} options", node
      end
    end
  end

  def value_from_string(element, f, str)
    if f.is_a?(RGen::ECore::EAttribute)
      if f.eType.is_a?(RGen::ECore::EEnum)
        str.to_sym
      else
        case f.eType.instanceClassName
        when "Integer"
          str.to_i
        when "Float"
          str.to_f
        when "Boolean"
          (str == "true")
        else
          str
        end 
      end
    else
      proxy = RGen::MetamodelBuilder::MMProxy.new(str)
      @unresolved_refs <<
        RGen::Instantiator::ReferenceResolver::UnresolvedReference.new(element, f.name, proxy)
      proxy
    end
  end

  def reference_target_type(ref, typename)
    if typename
      href, name = resolve_namespace(typename)
      href ||= "Default"
      types = (ref.eType.eAllSubTypes + [ref.eType]) & classes_by_xml_name(name).select{|c| xml_name(c.ePackage) == href}
      if types.size == 1
        types.first
      elsif types.size > 1
        raise "ambiguous type name #{typename}: #{types.collect{|t| t.name}.join(",")}"
      else
        raise "type name #{typename} not found"
      end
    else
      ref.eType
    end
  end

  def root_class(tag_name)
    classes = classes_by_xml_name(tag_name) || []
    if classes.size == 1
      classes.first
    else
      raise "could not determine root class, #{classes.size} options"
    end
  end

  def problem(desc, node)
    raise desc + " at [#{node.name}]"
  end

  def classes_by_xml_name(name)
    return @classes_by_xml_name[name] || [] if @classes_by_xml_name
    @classes_by_xml_name = {}
    @mm.ecore.eAllClasses.each do |c|
      n = xml_name(c)
      @classes_by_xml_name[n] ||= []
      @classes_by_xml_name[n] << c
    end
    @classes_by_xml_name[name]
  end

  def features_by_xml_name(clazz, name)
    @features_by_xml_name ||= {}
    return @features_by_xml_name[clazz][name] || [] if @features_by_xml_name[clazz]
    @features_by_xml_name[clazz] = {}
    clazz.ecore.eAllStructuralFeatures.each do |f|
      n = xml_name(f)
      @features_by_xml_name[clazz][n] ||= []
      @features_by_xml_name[clazz][n] << f
    end
    @features_by_xml_name[clazz][name]
  end

  def features_by_xml_wrapper_name(clazz, name)
    @features_by_xml_wrapper_name ||= {}
    return @features_by_xml_wrapper_name[clazz][name] || [] if @features_by_xml_wrapper_name[clazz]
    @features_by_xml_wrapper_name[clazz] = {}
    clazz.ecore.eAllStructuralFeatures.each do |f|
      n = xml_wrapper_name(f)
      if n
        @features_by_xml_wrapper_name[clazz][n] ||= []
        @features_by_xml_wrapper_name[clazz][n] << f
      end
    end
    @features_by_xml_wrapper_name[clazz][name]
  end

  def can_take_any(eclass)
    @can_take_any ||= {}
    @can_take_any[eclass] ||= eclass.eAllAttributes.any?{|a| a.name == "anyObject"}
  end

  def xml_name(o)
    annotation_value(o, "xmlName") || o.name
  end

  def xml_wrapper_name(o)
    annotation_value(o, "xmlWrapperName")
  end

  def annotation_value(o, key)
    anno = o.eAnnotations.find{|a| a.source == "xsd"}
    anno.andand.details.andand.find{|d| d.key == key}.andand.value
  end

end

end
end

