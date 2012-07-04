module RGen
module XSD
module SimpleType

SimpleType = Struct.new(:type, :isList, :minOccurs, :maxOccurs)

def build_type_desc(type)
  builtin = builtin_type(type)
  if builtin
    builtin 
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
    puts "WARN: unknown node type: #{type.class}"
    SimpleType.new(:string, false, 0, 1)
  end
end

def builtin_type(type)
  if type.nil?
    # assumen anySimpleType
    return SimpleType.new(:string, false, 0, 1)
  end
  case type.name
  when "anyType"
    SimpleType.new(:object, false, 0, 1)
  when "anySimpleType", "string", "normalizedString", "token", "language", "Name", "NCName", 
       "ID", "IDREF", "ENTITY", "NMTOKEN", "base64Binary", "hexBinary", "anyURI", "QName", 
       "NOTATION", "duration", "dateTime", "time", "date", "gYearMonth", "gYear", "gMonthDay", 
       "gDay", "gMonth" 
    SimpleType.new(:string, false, 0, 1)
  when "IDREFS", "ENTITIES", "NMTOKENS"
    SimpleType.new(:string, true, 0, -1) 
  when "float", "double"
    SimpleType.new(:float, false, 0, 1)
  when "decimal", "integer", "nonPositiveInteger", "negativeInteger", "long", "int", "short",
       "byte", "nonNegativeInteger", "unsignedLong", "unsignedInt", "unsignedShort", 
       "unsignedByte", "positiveInteger"
    SimpleType.new(:int, false, 0, 1)
  when "boolean"
    SimpleType.new(:boolean, false, 0, 1)
  else
    nil
  end
end

end
end
end

