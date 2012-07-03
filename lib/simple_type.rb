module SimpleType

SimpleType = Struct.new(:type, :isList, :minOccurs, :maxOccurs)

def build_type_desc(type)
  if type.nil?
    # no type implies AnyType
    SimpleType.new(:string, false, 0, 1)
  elsif type.is_a?(RGen::MetamodelBuilder::MMProxy)
    SimpleType.new(builtin_type(type) || :string, false, 0, 1)
  elsif type.respond_to?(:list) && type.list 
    if type.list.itemType || type.list.simpleType
      td = build_type_desc(type.list.itemType || type.list.simpleType)
      td.isList = true
      td.minOccurs = 0
      td.maxOccurs = -1
      td
    else
      puts "WARN: list type without an item type"
      SimpleType.new(:string, false, 0, 1)
    end
  elsif type.respond_to?(:union) && type.union
    # TODO
    # (type.union.memberTypes + type.union.simpleType).each do |t|
    #   build_type_desc(t)
    # end
    SimpleType.new(:object, false, 0, 1)
  elsif type.respond_to?(:restriction) && type.restriction
    if type.restriction.base
      td = build_type_desc(type.restriction.base)
      if td.type == :string && type.restriction.enumeration.size > 0
        SimpleType.new(
          type.restriction.enumeration.collect { |e| e.value },
          false, 0, 1)
      elsif td.isList
        # assumption: restrictions are properly nested
        # note: this doesn't work correctly in case of lists of lists
        td.minOccurs = type.restriction.minLength.first.value.to_i if type.restriction.minLength.first
        td.maxOccurs = type.restriction.maxLength.first.value.to_i if type.restriction.maxLength.first
        td
      else
        # unhandled restriction, pass the original
        td
      end
    else
      puts "WARN: restriction type without a base type"
      SimpleType.new(:string, false, 0, 1)
    end  
  else
    puts "WARN: unknown node type: #{type.collect{|t| t.class}.inspect}"
    SimpleType.new(:string, false, 0, 1)
  end
end

def builtin_type(type)
  case type.targetIdentifier.split(":").last
  when "string", "QName", "NCName", "anyURI", "NMTOKEN", "ID", "token"
    :string
  when "decimal", "integer", "nonNegativeInteger"
    :int
  when "boolean"
    :boolean
  else
    puts "Unsupported simple type: #{t.targetIdentifier}"
    nil
  end
end

end

