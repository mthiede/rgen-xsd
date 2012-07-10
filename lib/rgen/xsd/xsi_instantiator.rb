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

  def instantiate_node(node, eclass)
    element = eclass.instanceClass.new
    @env << element
    set_attribute_values(element, node)
    simple_content = ""
    can_take_any = eclass.eAllAttributes.any?{|a| a.name == "anyObject"}
    node.children.each do |c|
      if c.text?
        simple_content << c.text
      elsif c.element?
        feats = features_by_xml_name(c.name).select{|f| 
          f.eContainingClass == element.class.ecore ||
          f.eContainingClass.eAllSubTypes.include?(element.class.ecore)
        }
        if feats.size == 1
          begin
            if feats.first.is_a?(RGen::ECore::EReference)
              element.setOrAddGeneric(feats.first.name,
                instantiate_node(c, reference_target_type(feats.first, xsi_type_value(c))))
            else
              element.setOrAddGeneric(feats.first.name, value_from_string(element, feats.first, c.text))
            end
          rescue Exception => e
            puts "Line: #{node.line}: #{e}"
          end
        else
          if can_take_any
            begin
              # currently the XML node is added to the model
              element.setOrAddGeneric("anyObject", c)
            rescue Exception => e
              puts "Line: #{node.line}: #{e}"
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

  def set_attribute_values(element, node)
    node.attribute_nodes.each do |attrnode|
      next if is_xsi_type?(attrnode)
      name = attrnode.node_name
      feats = (features_by_xml_name(name) || []).select{|f| 
        f.eContainingClass == element.class.ecore ||
        f.eContainingClass.eAllSubTypes.include?(element.class.ecore)}
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
      case f.eType
      when RGen::ECore::EInt
        str.to_i
      when RGen::ECore::EFloat
        str.to_f
      when RGen::ECore::EEnum
        str.to_sym
      when RGen::ECore::EBoolean
        (str == "true")
      else
        str
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
      if !href
        raise "could not resolve namespace in #{typename}"
      end
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

  def features_by_xml_name(name)
    return @features_by_xml_name[name] || [] if @features_by_xml_name
    @features_by_xml_name = {}
    @mm.ecore.eAllClasses.eStructuralFeatures.each do |f|
      n = xml_name(f)
      @features_by_xml_name[n] ||= []
      @features_by_xml_name[n] << f
    end
    @features_by_xml_name[name]
  end

  def xml_name(o)
    annotation_value(o, "xmlName") || o.name
  end

  def annotation_value(o, key)
    anno = o.eAnnotations.find{|a| a.source == "xsd"}
    anno.andand.details.andand.find{|d| d.key == key}.andand.value
  end

end

end
end

