$:.unshift(File.dirname(__FILE__)+"/lib")

require "xsd_instantiator"
require "rgen/environment"
require "rgen/util/name_helper"
require "rtext/language"
require "rtext/serializer"
require 'mmgen/metamodel_generator'

require "xml_schema_metamodel_generated"
XMLSchemaMetamodel = MM::W3Org2001XMLSchema

include RGen::Util::NameHelper

env = RGen::Environment.new
mm = XMLSchemaMetamodel
inst = XSDInstantiator.new(env, mm)

ARGV.each do |fn|
  inst.instantiate(fn)
end

inst.resolve

urefs = inst.unresolved_refs
 urefs.each do |r|
   puts r.proxy.targetIdentifier
end
puts urefs.size

require "xml_schema_metamodel_ext"
require "xsd_to_ecore"

sch = env.find(:class => XMLSchemaMetamodel::Element, :name => "schema").first
#puts sch.complexType.allElements.collect{|e| e.effectiveElement.name+" "+e.effectiveType.name.to_s}.join("\n")
#exit

env_ecore = RGen::Environment.new
trans = XSDToEcoreTransformer.new(env, env_ecore)
root = trans.transform

def find_feature(env, desc)
  env.find(:class => RGen::ECore::EStructuralFeature, :name => desc.split("#").last).
    find{|f| f.eContainingClass.name == desc.split("#").first}
end

def attribute_to_reference(env, desc, target)
  a = find_feature(env, desc)
  r = env.new(RGen::ECore::EReference, Hash[
    RGen::ECore::EStructuralFeature.ecore.eAllStructuralFeatures.collect do |f| 
      next if f.derived
      p = [f.name, a.getGeneric(f.name)]
      if f.many
        a.setGeneric(f.name, [])
      else
        a.setGeneric(f.name, nil)
      end
      p
    end])
  r.eType = target
  r
end

def create_opposite(env, desc, name, upper_bound)
  r = find_feature(env, desc)
  r.eOpposite = 
    env.new(RGen::ECore::EReference, :name => name, :eType => r.eContainingClass, 
      :eContainingClass => r.eType, :upperBound => upper_bound, :eOpposite => r)
end

class_complexType = env_ecore.find(:class => RGen::ECore::EClass, :name => "ComplexType").first
class_simpleType = env_ecore.find(:class => RGen::ECore::EClass, :name => "SimpleType").first
class_element = env_ecore.find(:class => RGen::ECore::EClass, :name => "Element").first
class_group = env_ecore.find(:class => RGen::ECore::EClass, :name => "Group").first
class_attribute = env_ecore.find(:class => RGen::ECore::EClass, :name => "Attribute").first
class_attributeGroup = env_ecore.find(:class => RGen::ECore::EClass, :name => "AttributeGroup").first

# insert Type class as supertype of ComplexType and SimpleType
class_type = env_ecore.new(RGen::ECore::EClass, :name => "Type", :ePackage => class_complexType.ePackage,
  :eSuperTypes => class_complexType.eSuperTypes)
class_complexType.eSuperTypes = [class_type]
class_simpleType.eSuperTypes = [class_type]

# explicit references
attribute_to_reference(env_ecore, "RestrictionType#base", class_type)
attribute_to_reference(env_ecore, "RestrictionTYPE#base", class_type)
attribute_to_reference(env_ecore, "ExtensionType#base", class_type)
attribute_to_reference(env_ecore, "Element#ref", class_element)
attribute_to_reference(env_ecore, "Element#type", class_complexType)
attribute_to_reference(env_ecore, "Group#ref", class_group)
attribute_to_reference(env_ecore, "AttributeGroup#ref", class_attributeGroup)
attribute_to_reference(env_ecore, "Attribute#ref", class_attribute)
attribute_to_reference(env_ecore, "Attribute#type", class_simpleType)
attribute_to_reference(env_ecore, "Element#substitutionGroup", class_element)
attribute_to_reference(env_ecore, "ListTYPE#itemType", class_simpleType)
attribute_to_reference(env_ecore, "UnionTYPE#memberTypes", class_simpleType)

# bidirectional references
create_opposite(env_ecore, "Element#substitutionGroup", "substitutes", -1)
create_opposite(env_ecore, "Element#complexType", "containingElement", 1)
create_opposite(env_ecore, "Attribute#simpleType", "containingAttribute", 1)

#puts problems.collect{|p| p.to_s}.join("\n")

#env.find(:class => mm::Annotatable).each do |a|
  #a.annotation = []
#end

include MMGen::MetamodelGenerator
generateMetamodel(root, "lib/xml_schema_metamodel_generated.rb")

# lang = RText::Language.new(XMLSchemaMetamodel.ecore, {
#   :feature_provider => proc {|c| c.eAllStructuralFeatures.reject{|f| f.derived}}
# })
# ser = RText::Serializer.new(lang)
# File.open("temp.txt", "w") do |f|
#   ser.serialize(env.find(:class => XMLSchemaMetamodel::Schema), f)
# end
# 