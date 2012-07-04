require "rgen/xsd/xsi_instantiator"
require "rgen/instantiator/reference_resolver"

module RGen
module XSD

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
      :root_class => XMLSchemaMetamodel::SchemaTYPE
    )
    urefs = inst.unresolved_refs
    urefs.each do |ur|
      ti = ur.proxy.targetIdentifier
      if ti =~ /:/
        prefix, name = ti.split(":")
      else
        prefix, name = nil, ti
      end
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
    @unresolved_refs = @resolver.resolve(unresolved_refs, :problems => [], :use_target_type => true)
    add_missing_builtin_types
    @unresolved_refs = @resolver.resolve(unresolved_refs, :problems => problems, :use_target_type => true)
  end

  def add_missing_builtin_types
    unresolved_refs.each do |ur|
      if ur.proxy.targetIdentifier =~ /^http:\/\/www\.w3\.org\/2001\/XMLSchema:(\w+)$/
        name = $1
        if [ "anyType", "anySimpleType", "string", "normalizedString", "token", "language", "Name", "NCName", 
           "ID", "IDREF", "ENTITY", "NMTOKEN", "base64Binary", "hexBinary", "anyURI", "QName", 
           "NOTATION", "duration", "dateTime", "time", "date", "gYearMonth", "gYear", "gMonthDay", 
           "gDay", "gMonth", "IDREFS", "ENTITIES", "NMTOKENS", "float", "double",
           "decimal", "integer", "nonPositiveInteger", "negativeInteger", "long", "int", "short",
           "byte", "nonNegativeInteger", "unsignedLong", "unsignedInt", "unsignedShort", 
           "unsignedByte", "positiveInteger", "boolean" ].include?(name)
            add_builtin_type(ur.proxy.targetIdentifier, name)
        end
      end
    end
  end

  def add_builtin_type(target_identifier, name)
    @builtin_type_added ||= {}
    return if @builtin_type_added[target_identifier]
    type = @env.new(XMLSchemaMetamodel::TopLevelSimpleType, :name => name)
    @resolver.add_identifier(target_identifier, type)
    @builtin_type_added[target_identifier] = true
  end
    
end

end
end
