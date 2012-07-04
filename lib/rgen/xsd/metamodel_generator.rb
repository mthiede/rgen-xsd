$:.unshift(File.dirname(__FILE__)+"/../../")

require "rgen/environment"
require "rgen/util/name_helper"
require 'mmgen/metamodel_generator'

require "rgen/xsd/xsd_instantiator"
require 'optparse'
 
include RGen::Util::NameHelper

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: metamodel_generator.rb [options] <schema file>+"

  opts.on( '--mm VERSION', 'XML schema version: 1.0 or 1.1' ) do |v|
    options[:mm] = v
  end

  opts.on('-o FILE', "Output metamodel file") do |f|
    options[:outfile] = f
  end
end
optparse.parse!
if !options[:mm]
  puts "Schema version not specified" 
  exit
end
if !options[:outfile]
  puts "Output file not specified" 
  exit
end

case options[:mm]
when "1.0"
  require "rgen/xsd/1.0/metamodel"
when "1.1"
  require "rgen/xsd/1.1/metamodel"
else
  puts "Unknown schema version: #{options[:mm]}"
  exit
end
XMLSchemaMetamodel = MM::W3Org2001XMLSchema

env = RGen::Environment.new
mm = XMLSchemaMetamodel
inst = XSDInstantiator.new(env, mm)

ARGV.each do |fn|
  inst.instantiate(fn)
end

problems = []
inst.resolve(problems)

if problems.size > 0
  problems.each do |p|
    puts p
  end
  exit
end

require "rgen/xsd/xml_schema_metamodel_ext"
require "rgen/xsd/xsd_to_ecore"

sch = env.find(:class => XMLSchemaMetamodel::Element, :name => "schema").first

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

include MMGen::MetamodelGenerator
generateMetamodel(root, options[:outfile])

