require 'rgen/instantiator/default_xml_instantiator'
require 'rgen/environment'
require 'rgen/util/name_helper'
require 'mmgen/metamodel_generator'

module XMLSchemaMetamodel
  extend RGen::MetamodelBuilder::ModuleExtension
end

class XsdInstantiator < RGen::Instantiator::DefaultXMLInstantiator
  include RGen::Util::NameHelper

  #map_tag_ns "http://www.w3.org/2001/XMLSchema", XMLSchemaMetamodel
  
  def class_name(str)
    firstToUpper(str.split(":").last)
  end

	def on_ascent(node)
		node.children.each { |c| assoc_p2c(node, c) }
    if node.chardata.join.strip.size > 0
      node.object.class.has_attr 'text', Object unless node.object.respond_to?(:text)
      set_attribute(node, "text", node.chardata)
    end
	end

	def assoc_p2c(parent, child)
    return unless parent.object && child.object
    method_name = method_name(className(child.object))
		build_on_error(NoMethodError, :build_p2c_assoc, parent, child, method_name) do
			parent.object.addGeneric(method_name, child.object)
		end
	end

	def build_p2c_assoc(parent, child, method_name)
		parent.object.class.contains_many_uni(method_name, child.object.class)
	end

#    resolve :type do
#      @env.find(:xmi_id => getType).first
#    end

# resolve_by_id :personalRoom, :id => :getId, :src => :room
  
end

env = RGen::Environment.new
inst = XsdInstantiator.new(env, XMLSchemaMetamodel, true)
inst.instantiate_file(ARGV[0])

RGen::ECore::ECoreInterface.clear_ecore_cache
include MMGen::MetamodelGenerator
generateMetamodel(XMLSchemaMetamodel.ecore, "xsd_metamodel_auto.rb")
