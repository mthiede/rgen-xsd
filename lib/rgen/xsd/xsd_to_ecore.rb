require 'rgen/ecore/ecore'
require 'rgen/util/name_helper'
require 'rgen/transformer'
require 'rgen/xsd/particle'
require 'rgen/xsd/simple_type'

module RGen
module XSD

# Mapping Strategy:
# 
# 1. Complex Types are mapped to classes
#    
# * this is true even for Complex Types with simple content
#   (because they may contain attributes and the simple value)
# * the name of the class is the name of the Complex Type or 
#   a derived name (TODO) in case of an anonymous Complex Type
# * if the Complex Type is abstract, the class will be abstract
#
# 1.1 Extension is mapped to supertype relationship
#
# * the extending Complex Type contributes features according to its content
#   (simple or complex content, simple content for example contributes attribtes)
#
# 1.2 Restriction is mapped to supertype relationship
#
# * the restriction expresses a "is a" relationship
#   ("it is a <super type> but with restrictions")
#   in general, restrictions can not be expressed in ECore, so
#   we accept to have a superset of the original constraints
# * in some cases however, the restricting Complex Type many also contribute features
#   e.g. in case the base complex type has a 'any' wildcard, then the
#   restricting type may narrow this by specifying specific elements
# * the implementation idea is to add all features introduced by the restriction, just
#   in the same way as with the extension, but exclude any features which have
#   already been defined in a super class (i.e. new features may be added but
#   existing features can not be restricted)
#
# 1.3 Element Particles
#
# * element particles are collected recursively through the type's content model:
#   - Group references are replaced by the target group's child and min/max occurrence
#     from the Group reference are applied to that replacement
#   - Element references are replaced by the target element and min/max occurrence
#     from the Element reference are applied to that replacement
#   - recursion for model groups "all", "sequence", "choice"
# * multiplicities are calculated from the element particles' min/max occurrence
#   and the min/max occurrence of the group particles they are contained in:
#   - the min multiplicity of an element within a group is the element's min multiplicity
#     multiplied by the groups min multiplicity
#   - in case of a "choice" group, if an element occurrs in only one of several choices,
#     its min multiplicity is 0
#   - the max multiplicity of an element within a group is the element's max multiplicity
#     multiplied by the groups max multiplicity
#  * particles referencing elements which are substitution group heads are augmented
#    by one other particle for each substitutable element, min/max occurrences are the
#    same as for the heading element 
#
# 1.3.1 Element Particles with Complex Type are mapped to containment references
#
# 1.3.2  Element Particles with Simple Type are mapped to to attributes
#
# 1.4 Wildcards (any)
#
# * there can be one wildcard attribute for each class created from a complex type
#   by convention, the attribute is called "anyObject"; the attribute type is EObject
#
# * 'any' particles are collected recursively through the type's content model just
#   as with element particles; however, in the end all of them will be condensed into one
#   the multiplicity is calculated in the same way as for element particles
#
# * Note: depending on the value of the "processContents" attribute, XML instances may
#   be forced to use only existing types in the "any" section (value "strict"); this
#   means that all possible target types of the attribute would be known; so in theory
#   the target type could be a superclass of all possible complex types (using "strict",
#   XML instances may either make use of a toplevel element definition or any complex
#   type using the xsi:type attribute)
#
# 1.5 Attributes are mapped to attributes
#
# 2. Simples Types are mapped to datatypes
#
# 2.1 Simple Types with an enumeration restriction are mapped to enums
# 
# Mapping Variants:
# 
# * Use content of complex type restrictions to create the actual class
#   this means that superclasses can not also contain the same features
#   so either the superclasses must be abstract or the superclass must be split into an
#   abstract class and a concrete class derived from it
#   UseCase: Facets in XSD, e.g. a NumFacet has a value of type integer
#
# * Use substitution groups to derive a class hierarchy
#   In XSD, elements which are substitutes must have a derived type which is either a restriction
#   or extension of the group head element or the same type
#   Problem: substitution is defined on roles (elements), there can be substitutions which
#   only differ in the role/element name, not in the type. As a solution there could be
#   dedicated subclasses for this situation which hold the role information
#   UseCase: Facets in XSD
# 
class XSDToEcoreTransformer < RGen::Transformer
  include RGen::ECore
  include RGen::Util::NameHelper
  include Particle
  include SimpleType

  # Options:
  #  
  # :class_name_provider:
  #   a proc which receives a ComplexType and should return the EClass name
  #
  # :feature_name_provider:
  #   a proc which receives an Element or Attribute and should return the EStructuralFeature name
  # 
  # :enum_name_provider:
  #   a proc which receives a SimpleType and should return the EEnum name
  #
  def initialize(env_in, env_out, options={})
    super(env_in, env_out)
    @package_by_source_element = {}
    @class_name_provider = options[:class_name_provider] || proc do |type|
      firstToUpper(type.name || type.containingElement.name+"TYPE")
    end
    @feature_name_provider = options[:feature_name_provider] || proc do |ea|
      firstToLower(ea.name)
    end
    @enum_name_provider = options[:enum_name_provider] || proc do |type|
      uniq_classifier_name(@package_by_source_element[type], 
        type.name ? firstToUpper(type.name)+"Enum" : 
          type.containingAttribute ? firstToUpper(type.containingAttribute.effectiveAttribute.name)+"Enum" :
          "Unknown")
    end
  end

  def transform
    root = @env_out.new(RGen::ECore::EPackage, :name => "MM")
    schemas = @env_in.find(:class => XMLSchemaMetamodel::SchemaTYPE)
    schemas.each do |s|
      tns = s.targetNamespace || "Default"
      name = tns.sub(/http:\/\/(www\.)?/,"").split("/").
        collect{|p| p.split(/\W/).collect{|t| firstToUpper(t)}.join }.join
      puts "empty package name" if name.strip.empty?
      p = package_by_name(name, root, tns)
      child_elements(s).each{|e| @package_by_source_element[e] = p}
    end
    trans(schemas.complexType)
    trans(schemas.element.effectiveType.select do |t|
      t.is_a?(XMLSchemaMetamodel::ComplexType) ||
      build_type_desc(t).type.is_a?(Array)
    end)

    # remove duplicate features created by restrictions
    # TODO: find a way to do this while transformation or make sure unused elements will also be removed (EClasses, EAnnotation, ..)
    root.eAllClasses.each do |c|
      super_features = c.eAllStructuralFeatures - c.eStructuralFeatures
      c.eStructuralFeatures.each do |f|
        if super_features.any?{|sf| sf.name == f.name}
          f.eContainingClass = nil
          f.eType = nil
          f.eOpposite = nil if f.is_a?(RGen::ECore::EReference)
          @env_out.delete(f)
        end
      end
    end

    # unique classifier names
    # TODO: smarter way to modify names
    root.eAllSubpackages.each do |p|
      names = {}
      p.eClassifiers.each do |c|
        while names[c.name]
          c.name = c.name+"X"
        end
        names[c.name] = true
      end
    end

    root
  end

  def package_by_name(name, root, ns)
    @package_by_name ||= {}
    @package_by_name[name] ||= @env_out.new(RGen::ECore::EPackage, :name => name, :eSuperPackage => root,
      :eAnnotations => [create_annotation("xmlName", ns)])
  end

  transform XMLSchemaMetamodel::ComplexType, :to => EClass do
    _features = []
    if complexContent.andand.extension
      _particles = element_particles(complexContent.extension)
    elsif complexContent.andand.restriction
      _particles = element_particles(complexContent.restriction)
    else
      _particles = element_particles(@current_object)
    end 
    _particles = add_substitution_particles(_particles)
    _particles.each do |p|
      if p.kind == :element
        e = p.node
        if e.effectiveType.is_a?(XMLSchemaMetamodel::ComplexType)
          fn = @feature_name_provider.call(e)
          _features << @env_out.new(RGen::ECore::EReference, :name => fn, :containment => true, 
            :upperBound => p.maxOccurs == "unbounded" ? -1 : p.maxOccurs,
            :lowerBound => p.minOccurs,
            :eType => trans(e.effectiveType))
          if fn != e.name
            _features.last.eAnnotations = [create_annotation("xmlName", e.name)]
          end
        elsif e.effectiveType.is_a?(XMLSchemaMetamodel::SimpleType)
          _features << create_attribute(e)
        end
      else
        # any
        _features << @env_out.new(RGen::ECore::EAttribute, :name => "anyObject", 
          :lowerBound => p.minOccurs,
          :upperBound => p.maxOccurs == "unbounded" ? -1 : p.maxOccurs,
          :eType => RGen::ECore::ERubyObject)
      end
    end
    allAttributes.effectiveAttribute.each do |a|
      _features << create_attribute(a) 
    end
    if mixed
      _features << @env_out.new(RGen::ECore::EAttribute, :name => "text", 
        :eType => RGen::ECore::EString,
        :eAnnotations => [create_annotation("simpleContent", "true")])
    end
    if simpleContent.andand.extension.andand.base || simpleContent.andand.restriction.andand.base
      _features << @env_out.new(RGen::ECore::EAttribute, :name => "simpleValue", 
        :eType => get_datatype(simple_content_base_type(@current_object)),
        :eAnnotations => [create_annotation("simpleContent", "true")])
    end
    { :name => @class_name_provider.call(@current_object),
      :abstract => abstract,
      :eStructuralFeatures => _features,
      :eSuperTypes => trans([complexContent.andand.extension.andand.base || 
        complexContent.andand.restriction.andand.base].compact.select{|t| t.is_a?(XMLSchemaMetamodel::ComplexType)}),
      :ePackage => @package_by_source_element[@current_object],
      :eAnnotations => name ? [create_annotation("xmlName", name)] : []
    }
  end

  def simple_content_base_type(type)
    base = type.simpleContent.andand.extension.andand.base || type.simpleContent.andand.restriction.andand.base
    while base.is_a?(XMLSchemaMetamodel::ComplexType)
      base = base.simpleContent.andand.extension.andand.base || base.simpleContent.andand.restriction.andand.base
    end
    base
  end

  def create_annotation(key, value)
     @env_out.new(RGen::ECore::EAnnotation, :source => "xsd", :details => 
       [@env_out.new(RGen::ECore::EStringToStringMapEntry, :key => key, :value => value)])
  end

  def create_attribute(e)
    td = build_type_desc(e.effectiveType)
    fn = @feature_name_provider.call(e)
    result = @env_out.new(RGen::ECore::EAttribute, :name => fn, 
      :lowerBound => td.minOccurs,
      :upperBound => td.maxOccurs,
      :eType => get_datatype(e.effectiveType))
    if fn != e.name
      result.eAnnotations = [create_annotation("xmlName", e.name)]
    end
    result
  end

  def get_datatype(type)
    td = build_type_desc(type)
    case td.type
    when :string
      RGen::ECore::EString
    when :int
      RGen::ECore::EInt
    when :float
      RGen::ECore::EFloat
    when :boolean
      RGen::ECore::EBoolean
    when :object
      RGen::ECore::ERubyObject
    when Array
      trans(type)
    end
  end

  transform XMLSchemaMetamodel::SimpleType, :to => EEnum do
    _literals = build_type_desc(@current_object).type
    raise "not an enum: #{@current_object.class}" unless _literals.is_a?(Array)
    { :name => @enum_name_provider.call(@current_object),
      :eLiterals => _literals.collect{|l| @env_out.new(RGen::ECore::EEnumLiteral, :name => l)},
      :ePackage => @package_by_source_element[@current_object]
    }
  end

  def uniq_classifier_name(package, base)
    try = base
    index = 2
    while package.eClassifiers.any?{|c| c.name == try}
      try = base + index.to_s
      index += 1
    end
    try
  end

  def child_elements(element, opts={})
    result = []
    element.class.ecore.eAllReferences.each do |r|
      if r.containment 
        element.getGenericAsArray(r.name).each do |e|
          if !opts[:class] || e.is_a?(opts[:class])
            result << e
          end
          result += child_elements(e, opts)
        end
      end
    end
    result
  end

end

end
end

