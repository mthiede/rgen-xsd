require "xsi_instantiator"
require "rgen/instantiator/reference_resolver"

class XSDInstantiator
  attr_reader :unresolved_refs

  def initialize(env, mm)
    @env = env
    @mm = mm 
    @unresolved_refs = []
    @resolver = RGen::Instantiator::ReferenceResolver.new
  end

  def instantiate(file_name)
    inst = XSIInstantiator.new(@mm, @env)
    schema = inst.instantiate(file_name, 
      :root_class => XMLSchemaMetamodel::SchemaTYPE,
      :xml_name_provider => lambda do |o|
        firstToLower(o.name)
      end
    )
    urefs = inst.unresolved_refs
    urefs.each do |ur|
      ti = ur.proxy.targetIdentifier
      prefix, name = ti.split(":")
      href = inst.namespaces.find{|ns| ns.prefix == prefix}.andand.href
      # built in xml schema namespace
      if !href && prefix == "xml"
        href = "http://www.w3.org/XML/1998/namespace" 
      end
      if href
        ur.proxy.targetIdentifier = "#{href}:#{name}"
      else
        puts "WARN: could not resolve namespace prefix #{prefix} in file #{file_name}"
      end
    end
    @unresolved_refs += urefs 
    (schema.element + 
      schema.group + 
      schema.complexType + 
      schema.simpleType + 
      schema.attribute + 
      schema.attributeGroup).each do |e|
        @resolver.add_identifier("#{schema.targetNamespace}:#{e.name}", e) if e.name
    end
  end

  def resolve(problems=nil)
    @unresolved_refs = @resolver.resolve(unresolved_refs, :problems => problems, :use_target_type => true)
  end

end

