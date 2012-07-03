module XMLSchemaMetamodel

module Element::ClassModule
  def effectiveElement
    ref || self
  end
  def effectiveType
    e = effectiveElement
    if e.getType && e.complexType
      puts "WARN: element has both, a type reference and a contained type"
    end
    e.getType || e.complexType
  end
end

module Attribute::ClassModule
  def effectiveAttribute
    ref || self
  end
  def effectiveType
    e = effectiveAttribute
    if e.getType && e.simpleType
      puts "WARN: attribute has both, a type reference and a contained type"
    end
    e.getType || e.simpleType
  end
end

module ComplexType::ClassModule
  def allAttributes
    attribute + (complexContent.andand.extension.andand.allAttributes || [])
  end
end

module ExtensionType::ClassModule
  def allAttributes
    attribute + attributeGroup.allAttributes
  end
end

module AttributeGroup::ClassModule
  def effectiveAttributeGroup
    ref || self
  end
  def allAttributes
    effectiveAttributeGroup.attribute
  end
end

end


