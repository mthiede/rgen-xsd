require 'nokogiri'
require 'andand'
require 'rgen/ecore/ecore'
require 'rgen/instantiator/reference_resolver'

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
    @xml_name_provider = options[:xml_name_provider] || lambda {|o| raise "default xml name provider"}
    @unresolved_refs = []
    root = nil
    root_class = options[:root_class].andand.ecore || root_class(doc.root.name)
    File.open(file) do |f|
      doc = Nokogiri::XML(f)
      root =instantiate_node(doc.root, root_class)
      @namespaces = doc.root.namespace_definitions
    end
    root
  end

  private

  def instantiate_node(node, eclass)
    element = eclass.instanceClass.new
    @env << element
    set_attribute_values(element, node)
    simple_content = ""
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
            element.setOrAddGeneric(feats.first.name,
              instantiate_node(c, reference_target_type(feats.first, c.name)))
          rescue Exception => e
            puts "Line: #{node.line}: #{e}"
          end
        else
          problem "could not determine reference for tag #{c.name}, #{feats.size} options", node
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
      element.setGeneric(a.name, value)
    else
      raise "could not set simple content for element #{element.class.name}"
    end
  end

  def set_attribute_values(element, node)
    node.attribute_nodes.each do |attrnode|
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

  def reference_target_type(ref, tag)
    #TODO: xsi:type support
    if ref.eType.eSubTypes.size > 0
      p = annotation_value(ref, "xmlName").andand.split(",").andand.find{|p| p.split("=").first == tag}
      type_name = p && p.split("=")[1]
      if type_name
        eclass = @mm.ecore.eAllClasses.find{|c| c.name == type_name}
        if eclass
          eclass
        else
          raise "could not find class for type name #{type_name}"
        end
      else
        # is this correct? 
        ref.eType
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
      xml_names(c).each do |n|
        @classes_by_xml_name[n] ||= []
        @classes_by_xml_name[n] << c
      end
    end
    @classes_by_xml_name[name]
  end

  def features_by_xml_name(name)
    return @features_by_xml_name[name] || [] if @features_by_xml_name
    @features_by_xml_name = {}
    @mm.ecore.eAllClasses.eStructuralFeatures.each do |f|
      xml_names(f).each do |n|
        @features_by_xml_name[n] ||= []
        @features_by_xml_name[n] << f
      end
    end
    @features_by_xml_name[name]
  end

  def xml_names(o)
    xml_name = annotation_value(o, "xmlName")
    if xml_name
      xml_name.split(",").collect{|p| p.split("=").first}
    else
      [@xml_name_provider.call(o)]
    end
  end


  def annotation_value(o, key)
    anno = o.eAnnotations.find{|a| a.source == "xsd"}
    anno.andand.details.andand.find{|d| d.key == key}.andand.value
  end

end
