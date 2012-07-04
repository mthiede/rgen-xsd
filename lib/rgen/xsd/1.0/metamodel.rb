require 'rgen/metamodel_builder'

module MM
   extend RGen::MetamodelBuilder::ModuleExtension
   include RGen::MetamodelBuilder::DataTypes


   module W3Org2001XMLSchema
      extend RGen::MetamodelBuilder::ModuleExtension
      include RGen::MetamodelBuilder::DataTypes

      UseEnum = Enum.new(:name => 'UseEnum', :literals =>[ :prohibited, :optional, :required ])
      FormChoiceEnum = Enum.new(:name => 'FormChoiceEnum', :literals =>[ :qualified, :unqualified ])
      ProcessContentsEnum = Enum.new(:name => 'ProcessContentsEnum', :literals =>[ :skip, :lax, :strict ])
   end

   module W3OrgXML1998Namespace
      extend RGen::MetamodelBuilder::ModuleExtension
      include RGen::MetamodelBuilder::DataTypes

   end
end

class MM::W3Org2001XMLSchema::AnyType < RGen::MetamodelBuilder::MMBase
   has_attr 'text', String do
      annotation :source => "xsd", :details => {'simpleContent' => 'true'}
   end
end

class MM::W3Org2001XMLSchema::OpenAttrs < MM::W3Org2001XMLSchema::AnyType
end

class MM::W3Org2001XMLSchema::Annotated < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'id', String 
end

class MM::W3Org2001XMLSchema::AnnotationTYPE < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'id', String 
end

class MM::W3Org2001XMLSchema::AppinfoTYPE < RGen::MetamodelBuilder::MMBase
   has_attr 'source', String 
   has_attr 'text', String do
      annotation :source => "xsd", :details => {'simpleContent' => 'true'}
   end
end

class MM::W3Org2001XMLSchema::DocumentationTYPE < RGen::MetamodelBuilder::MMBase
   has_attr 'source', String 
   has_attr 'lang', Object 
   has_attr 'text', String do
      annotation :source => "xsd", :details => {'simpleContent' => 'true'}
   end
end

class MM::W3Org2001XMLSchema::Attribute < MM::W3Org2001XMLSchema::Annotated
   has_attr 'use', MM::W3Org2001XMLSchema::UseEnum 
   has_attr 'default', String 
   has_attr 'fixed', String 
   has_attr 'form', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::Type < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::SimpleType < MM::W3Org2001XMLSchema::Type
   abstract
   has_attr 'final', Object 
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::LocalSimpleType < MM::W3Org2001XMLSchema::SimpleType
end

class MM::W3Org2001XMLSchema::RestrictionTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::ListTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::UnionTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::Facet < MM::W3Org2001XMLSchema::Annotated
   has_attr 'value', String 
   has_attr 'fixed', String 
end

class MM::W3Org2001XMLSchema::NumFacet < MM::W3Org2001XMLSchema::Facet
end

class MM::W3Org2001XMLSchema::TotalDigitsTYPE < MM::W3Org2001XMLSchema::NumFacet
end

class MM::W3Org2001XMLSchema::NoFixedFacet < MM::W3Org2001XMLSchema::Facet
end

class MM::W3Org2001XMLSchema::WhiteSpaceTYPE < MM::W3Org2001XMLSchema::Facet
end

class MM::W3Org2001XMLSchema::PatternTYPE < MM::W3Org2001XMLSchema::NoFixedFacet
end

class MM::W3Org2001XMLSchema::TopLevelAttribute < MM::W3Org2001XMLSchema::Attribute
end

class MM::W3Org2001XMLSchema::ComplexType < MM::W3Org2001XMLSchema::Type
   abstract
   has_attr 'name', String 
   has_attr 'mixed', String 
   has_attr 'abstract', String 
   has_attr 'final', Object 
   has_attr 'block', Object 
end

class MM::W3Org2001XMLSchema::Group < MM::W3Org2001XMLSchema::Annotated
   abstract
   has_attr 'name', String 
   has_attr 'minOccurs', String 
   has_attr 'maxOccurs', Object 
end

class MM::W3Org2001XMLSchema::RealGroup < MM::W3Org2001XMLSchema::Group
end

class MM::W3Org2001XMLSchema::GroupRef < MM::W3Org2001XMLSchema::RealGroup
end

class MM::W3Org2001XMLSchema::ExplicitGroup < MM::W3Org2001XMLSchema::Group
end

class MM::W3Org2001XMLSchema::All < MM::W3Org2001XMLSchema::ExplicitGroup
end

class MM::W3Org2001XMLSchema::AttributeGroup < MM::W3Org2001XMLSchema::Annotated
   abstract
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::AttributeGroupRef < MM::W3Org2001XMLSchema::AttributeGroup
end

class MM::W3Org2001XMLSchema::Wildcard < MM::W3Org2001XMLSchema::Annotated
   has_attr 'namespace', Object 
   has_attr 'processContents', MM::W3Org2001XMLSchema::ProcessContentsEnum 
end

class MM::W3Org2001XMLSchema::SimpleContentTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::ComplexContentTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'mixed', String 
end

class MM::W3Org2001XMLSchema::RestrictionType < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::SimpleRestrictionType < MM::W3Org2001XMLSchema::RestrictionType
end

class MM::W3Org2001XMLSchema::ExtensionType < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::SimpleExtensionType < MM::W3Org2001XMLSchema::ExtensionType
end

class MM::W3Org2001XMLSchema::ComplexRestrictionType < MM::W3Org2001XMLSchema::RestrictionType
end

class MM::W3Org2001XMLSchema::Element < MM::W3Org2001XMLSchema::Annotated
   abstract
   has_attr 'default', String 
   has_attr 'fixed', String 
   has_attr 'nillable', String 
   has_attr 'abstract', String 
   has_attr 'final', Object 
   has_attr 'block', Object 
   has_attr 'form', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'name', String 
   has_attr 'minOccurs', String 
   has_attr 'maxOccurs', Object 
end

class MM::W3Org2001XMLSchema::LocalElement < MM::W3Org2001XMLSchema::Element
end

class MM::W3Org2001XMLSchema::AnyTYPE < MM::W3Org2001XMLSchema::Wildcard
   has_attr 'minOccurs', String 
   has_attr 'maxOccurs', Object 
end

class MM::W3Org2001XMLSchema::LocalComplexType < MM::W3Org2001XMLSchema::ComplexType
end

class MM::W3Org2001XMLSchema::Keybase < MM::W3Org2001XMLSchema::Annotated
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::KeyrefTYPE < MM::W3Org2001XMLSchema::Keybase
   has_attr 'refer', String 
end

class MM::W3Org2001XMLSchema::SelectorTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'xpath', String 
end

class MM::W3Org2001XMLSchema::FieldTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'xpath', String 
end

class MM::W3Org2001XMLSchema::TopLevelComplexType < MM::W3Org2001XMLSchema::ComplexType
end

class MM::W3Org2001XMLSchema::TopLevelElement < MM::W3Org2001XMLSchema::Element
end

class MM::W3Org2001XMLSchema::NamedGroup < MM::W3Org2001XMLSchema::RealGroup
end

class MM::W3Org2001XMLSchema::SimpleExplicitGroup < MM::W3Org2001XMLSchema::ExplicitGroup
end

class MM::W3Org2001XMLSchema::NarrowMaxMin < MM::W3Org2001XMLSchema::LocalElement
end

class MM::W3Org2001XMLSchema::NamedAttributeGroup < MM::W3Org2001XMLSchema::AttributeGroup
end

class MM::W3Org2001XMLSchema::TopLevelSimpleType < MM::W3Org2001XMLSchema::SimpleType
end

class MM::W3Org2001XMLSchema::SchemaTYPE < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'targetNamespace', String 
   has_attr 'version', String 
   has_attr 'finalDefault', Object 
   has_attr 'blockDefault', Object 
   has_attr 'attributeFormDefault', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'elementFormDefault', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'id', String 
   has_attr 'lang', Object 
end

class MM::W3Org2001XMLSchema::IncludeTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'schemaLocation', String 
end

class MM::W3Org2001XMLSchema::ImportTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'namespace', String 
   has_attr 'schemaLocation', String 
end

class MM::W3Org2001XMLSchema::RedefineTYPE < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'schemaLocation', String 
   has_attr 'id', String 
end

class MM::W3Org2001XMLSchema::NotationTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'name', String 
   has_attr 'public', String 
   has_attr 'system', String 
end


MM::W3Org2001XMLSchema::Annotated.contains_one_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
MM::W3Org2001XMLSchema::AnnotationTYPE.contains_many_uni 'appinfo', MM::W3Org2001XMLSchema::AppinfoTYPE 
MM::W3Org2001XMLSchema::AnnotationTYPE.contains_many_uni 'documentation', MM::W3Org2001XMLSchema::DocumentationTYPE 
MM::W3Org2001XMLSchema::Attribute.contains_one 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType, 'containingAttribute' 
MM::W3Org2001XMLSchema::Attribute.has_one 'ref', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::Attribute.has_one 'type', MM::W3Org2001XMLSchema::SimpleType 
MM::W3Org2001XMLSchema::SimpleType.contains_one_uni 'restriction', MM::W3Org2001XMLSchema::RestrictionTYPE 
MM::W3Org2001XMLSchema::SimpleType.contains_one_uni 'list', MM::W3Org2001XMLSchema::ListTYPE 
MM::W3Org2001XMLSchema::SimpleType.contains_one_uni 'union', MM::W3Org2001XMLSchema::UnionTYPE 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'minExclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'minInclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'maxExclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'maxInclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'totalDigits', MM::W3Org2001XMLSchema::TotalDigitsTYPE 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'fractionDigits', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'length', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'minLength', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'maxLength', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'enumeration', MM::W3Org2001XMLSchema::NoFixedFacet 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'whiteSpace', MM::W3Org2001XMLSchema::WhiteSpaceTYPE 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'pattern', MM::W3Org2001XMLSchema::PatternTYPE 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::RestrictionTYPE.has_one 'base', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::ListTYPE.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::ListTYPE.has_one 'itemType', MM::W3Org2001XMLSchema::SimpleType 
MM::W3Org2001XMLSchema::UnionTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::UnionTYPE.has_many 'memberTypes', MM::W3Org2001XMLSchema::SimpleType 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ComplexType.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::ComplexType.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::Wildcard 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'simpleContent', MM::W3Org2001XMLSchema::SimpleContentTYPE 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'complexContent', MM::W3Org2001XMLSchema::ComplexContentTYPE 
MM::W3Org2001XMLSchema::SimpleContentTYPE.contains_one_uni 'restriction', MM::W3Org2001XMLSchema::SimpleRestrictionType 
MM::W3Org2001XMLSchema::SimpleContentTYPE.contains_one_uni 'extension', MM::W3Org2001XMLSchema::SimpleExtensionType 
MM::W3Org2001XMLSchema::ComplexContentTYPE.contains_one_uni 'restriction', MM::W3Org2001XMLSchema::ComplexRestrictionType 
MM::W3Org2001XMLSchema::ComplexContentTYPE.contains_one_uni 'extension', MM::W3Org2001XMLSchema::ExtensionType 
MM::W3Org2001XMLSchema::Group.contains_many_uni 'element', MM::W3Org2001XMLSchema::LocalElement 
MM::W3Org2001XMLSchema::Group.contains_many_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::Group.contains_many_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::Group.contains_many_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::Group.contains_many_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::Group.contains_many_uni 'any', MM::W3Org2001XMLSchema::AnyTYPE 
MM::W3Org2001XMLSchema::Group.has_one 'ref', MM::W3Org2001XMLSchema::Group 
MM::W3Org2001XMLSchema::AttributeGroup.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::AttributeGroup.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::AttributeGroup.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::Wildcard 
MM::W3Org2001XMLSchema::AttributeGroup.has_one 'ref', MM::W3Org2001XMLSchema::AttributeGroup 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ExtensionType.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::ExtensionType.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::Wildcard 
MM::W3Org2001XMLSchema::ExtensionType.has_one 'base', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'minExclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'minInclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'maxExclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'maxInclusive', MM::W3Org2001XMLSchema::Facet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'totalDigits', MM::W3Org2001XMLSchema::TotalDigitsTYPE 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'fractionDigits', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'length', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'minLength', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'maxLength', MM::W3Org2001XMLSchema::NumFacet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'enumeration', MM::W3Org2001XMLSchema::NoFixedFacet 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'whiteSpace', MM::W3Org2001XMLSchema::WhiteSpaceTYPE 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'pattern', MM::W3Org2001XMLSchema::PatternTYPE 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::Wildcard 
MM::W3Org2001XMLSchema::RestrictionType.has_one 'base', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::Element.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::Element.contains_one 'complexType', MM::W3Org2001XMLSchema::LocalComplexType, 'containingElement' 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'unique', MM::W3Org2001XMLSchema::Keybase 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'key', MM::W3Org2001XMLSchema::Keybase 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'keyref', MM::W3Org2001XMLSchema::KeyrefTYPE 
MM::W3Org2001XMLSchema::Element.has_one 'ref', MM::W3Org2001XMLSchema::Element 
MM::W3Org2001XMLSchema::Element.has_one 'type', MM::W3Org2001XMLSchema::ComplexType 
MM::W3Org2001XMLSchema::Element.many_to_one 'substitutionGroup', MM::W3Org2001XMLSchema::Element, 'substitutes' 
MM::W3Org2001XMLSchema::Keybase.contains_one_uni 'selector', MM::W3Org2001XMLSchema::SelectorTYPE, :lowerBound => 1 
MM::W3Org2001XMLSchema::Keybase.contains_many_uni 'field', MM::W3Org2001XMLSchema::FieldTYPE, :lowerBound => 1 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'include', MM::W3Org2001XMLSchema::IncludeTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'import', MM::W3Org2001XMLSchema::ImportTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'redefine', MM::W3Org2001XMLSchema::RedefineTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::TopLevelSimpleType 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'complexType', MM::W3Org2001XMLSchema::TopLevelComplexType 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'group', MM::W3Org2001XMLSchema::NamedGroup 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::NamedAttributeGroup 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'element', MM::W3Org2001XMLSchema::TopLevelElement 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::TopLevelAttribute 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'notation', MM::W3Org2001XMLSchema::NotationTYPE 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::TopLevelSimpleType 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'complexType', MM::W3Org2001XMLSchema::TopLevelComplexType 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'group', MM::W3Org2001XMLSchema::NamedGroup 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::NamedAttributeGroup 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
