require 'rgen/metamodel_builder'

module MM
   extend RGen::MetamodelBuilder::ModuleExtension
   include RGen::MetamodelBuilder::DataTypes


   module W3Org2001XMLSchema
      extend RGen::MetamodelBuilder::ModuleExtension
      include RGen::MetamodelBuilder::DataTypes
      annotation :source => "xsd", :details => {'xmlName' => 'http://www.w3.org/2001/XMLSchema'}

      UseEnum = Enum.new(:name => 'UseEnum', :literals =>[ :prohibited, :optional, :required ])
      FormChoiceEnum = Enum.new(:name => 'FormChoiceEnum', :literals =>[ :qualified, :unqualified ])
      ModeEnum = Enum.new(:name => 'ModeEnum', :literals =>[ :none, :interleave, :suffix ])
      ProcessContentsEnum = Enum.new(:name => 'ProcessContentsEnum', :literals =>[ :skip, :lax, :strict ])
      ModeEnum2 = Enum.new(:name => 'ModeEnum2', :literals =>[ :interleave, :suffix ])
   end

   module W3OrgXML1998Namespace
      extend RGen::MetamodelBuilder::ModuleExtension
      include RGen::MetamodelBuilder::DataTypes
      annotation :source => "xsd", :details => {'xmlName' => 'http://www.w3.org/XML/1998/namespace'}

   end
end

class MM::W3Org2001XMLSchema::AnyType < RGen::MetamodelBuilder::MMBase
   annotation :source => "xsd", :details => {'xmlName' => 'anyType'}
   has_many_attr 'anyObject', Object 
   has_attr 'text', String do
      annotation :source => "xsd", :details => {'simpleContent' => 'true'}
   end
end

class MM::W3Org2001XMLSchema::OpenAttrs < MM::W3Org2001XMLSchema::AnyType
   annotation :source => "xsd", :details => {'xmlName' => 'openAttrs'}
end

class MM::W3Org2001XMLSchema::Annotated < MM::W3Org2001XMLSchema::OpenAttrs
   annotation :source => "xsd", :details => {'xmlName' => 'annotated'}
   has_attr 'id', String 
end

class MM::W3Org2001XMLSchema::AnnotationTYPE < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'id', String 
end

class MM::W3Org2001XMLSchema::AppinfoTYPE < RGen::MetamodelBuilder::MMBase
   has_many_attr 'anyObject', Object 
   has_attr 'source', String 
   has_attr 'text', String do
      annotation :source => "xsd", :details => {'simpleContent' => 'true'}
   end
end

class MM::W3Org2001XMLSchema::DocumentationTYPE < RGen::MetamodelBuilder::MMBase
   has_many_attr 'anyObject', Object 
   has_attr 'source', String 
   has_attr 'lang', Object 
   has_attr 'text', String do
      annotation :source => "xsd", :details => {'simpleContent' => 'true'}
   end
end

class MM::W3Org2001XMLSchema::Attribute < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'attribute'}
   has_attr 'use', MM::W3Org2001XMLSchema::UseEnum 
   has_attr 'default', String 
   has_attr 'fixed', String 
   has_attr 'form', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'targetNamespace', String 
   has_attr 'inheritable', Boolean 
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::Type < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::SimpleType < MM::W3Org2001XMLSchema::Type
   abstract
   annotation :source => "xsd", :details => {'xmlName' => 'simpleType'}
   has_attr 'final', Object 
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::LocalSimpleType < MM::W3Org2001XMLSchema::SimpleType
   annotation :source => "xsd", :details => {'xmlName' => 'localSimpleType'}
end

class MM::W3Org2001XMLSchema::RestrictionTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::ListTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::UnionTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::Facet < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'facet'}
   has_attr 'value', String 
   has_attr 'fixed', Boolean 
end

class MM::W3Org2001XMLSchema::NumFacet < MM::W3Org2001XMLSchema::Facet
   annotation :source => "xsd", :details => {'xmlName' => 'numFacet'}
end

class MM::W3Org2001XMLSchema::TotalDigitsTYPE < MM::W3Org2001XMLSchema::NumFacet
end

class MM::W3Org2001XMLSchema::NoFixedFacet < MM::W3Org2001XMLSchema::Facet
   annotation :source => "xsd", :details => {'xmlName' => 'noFixedFacet'}
end

class MM::W3Org2001XMLSchema::WhiteSpaceTYPE < MM::W3Org2001XMLSchema::Facet
end

class MM::W3Org2001XMLSchema::PatternTYPE < MM::W3Org2001XMLSchema::NoFixedFacet
end

class MM::W3Org2001XMLSchema::Assertion < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'assertion'}
   has_attr 'test', String 
   has_attr 'xpathDefaultNamespace', Object 
end

class MM::W3Org2001XMLSchema::ExplicitTimezoneTYPE < MM::W3Org2001XMLSchema::Facet
end

class MM::W3Org2001XMLSchema::TopLevelAttribute < MM::W3Org2001XMLSchema::Attribute
   annotation :source => "xsd", :details => {'xmlName' => 'topLevelAttribute'}
end

class MM::W3Org2001XMLSchema::ComplexType < MM::W3Org2001XMLSchema::Type
   abstract
   annotation :source => "xsd", :details => {'xmlName' => 'complexType'}
   has_attr 'name', String 
   has_attr 'mixed', Boolean 
   has_attr 'abstract', Boolean 
   has_attr 'final', Object 
   has_attr 'block', Object 
   has_attr 'defaultAttributesApply', Boolean 
end

class MM::W3Org2001XMLSchema::Group < MM::W3Org2001XMLSchema::Annotated
   abstract
   annotation :source => "xsd", :details => {'xmlName' => 'group'}
   has_attr 'name', String 
   has_attr 'minOccurs', Integer 
   has_attr 'maxOccurs', Object 
end

class MM::W3Org2001XMLSchema::RealGroup < MM::W3Org2001XMLSchema::Group
   annotation :source => "xsd", :details => {'xmlName' => 'realGroup'}
end

class MM::W3Org2001XMLSchema::GroupRef < MM::W3Org2001XMLSchema::RealGroup
   annotation :source => "xsd", :details => {'xmlName' => 'groupRef'}
end

class MM::W3Org2001XMLSchema::ExplicitGroup < MM::W3Org2001XMLSchema::Group
   annotation :source => "xsd", :details => {'xmlName' => 'explicitGroup'}
end

class MM::W3Org2001XMLSchema::All < MM::W3Org2001XMLSchema::ExplicitGroup
   annotation :source => "xsd", :details => {'xmlName' => 'all'}
end

class MM::W3Org2001XMLSchema::AttributeGroup < MM::W3Org2001XMLSchema::Annotated
   abstract
   annotation :source => "xsd", :details => {'xmlName' => 'attributeGroup'}
   has_attr 'name', String 
end

class MM::W3Org2001XMLSchema::AttributeGroupRef < MM::W3Org2001XMLSchema::AttributeGroup
   annotation :source => "xsd", :details => {'xmlName' => 'attributeGroupRef'}
end

class MM::W3Org2001XMLSchema::Wildcard < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'wildcard'}
   has_attr 'namespace', Object 
   has_many_attr 'notNamespace', Object, :lowerBound => 1 
   has_attr 'processContents', MM::W3Org2001XMLSchema::ProcessContentsEnum 
end

class MM::W3Org2001XMLSchema::AnyAttributeTYPE < MM::W3Org2001XMLSchema::Wildcard
   has_many_attr 'notQName', Object 
end

class MM::W3Org2001XMLSchema::OpenContentTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'mode', MM::W3Org2001XMLSchema::ModeEnum 
end

class MM::W3Org2001XMLSchema::SimpleContentTYPE < MM::W3Org2001XMLSchema::Annotated
end

class MM::W3Org2001XMLSchema::ComplexContentTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'mixed', Boolean 
end

class MM::W3Org2001XMLSchema::Element < MM::W3Org2001XMLSchema::Annotated
   abstract
   annotation :source => "xsd", :details => {'xmlName' => 'element'}
   has_attr 'default', String 
   has_attr 'fixed', String 
   has_attr 'nillable', Boolean 
   has_attr 'abstract', Boolean 
   has_attr 'final', Object 
   has_attr 'block', Object 
   has_attr 'form', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'targetNamespace', String 
   has_attr 'name', String 
   has_attr 'minOccurs', Integer 
   has_attr 'maxOccurs', Object 
end

class MM::W3Org2001XMLSchema::LocalElement < MM::W3Org2001XMLSchema::Element
   annotation :source => "xsd", :details => {'xmlName' => 'localElement'}
end

class MM::W3Org2001XMLSchema::AnyTYPE < MM::W3Org2001XMLSchema::Wildcard
   has_many_attr 'notQName', Object 
   has_attr 'minOccurs', Integer 
   has_attr 'maxOccurs', Object 
end

class MM::W3Org2001XMLSchema::GroupTYPE < MM::W3Org2001XMLSchema::GroupRef
end

class MM::W3Org2001XMLSchema::RestrictionType < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'restrictionType'}
end

class MM::W3Org2001XMLSchema::SimpleRestrictionType < MM::W3Org2001XMLSchema::RestrictionType
   annotation :source => "xsd", :details => {'xmlName' => 'simpleRestrictionType'}
end

class MM::W3Org2001XMLSchema::ExtensionType < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'extensionType'}
end

class MM::W3Org2001XMLSchema::SimpleExtensionType < MM::W3Org2001XMLSchema::ExtensionType
   annotation :source => "xsd", :details => {'xmlName' => 'simpleExtensionType'}
end

class MM::W3Org2001XMLSchema::ComplexRestrictionType < MM::W3Org2001XMLSchema::RestrictionType
   annotation :source => "xsd", :details => {'xmlName' => 'complexRestrictionType'}
end

class MM::W3Org2001XMLSchema::LocalComplexType < MM::W3Org2001XMLSchema::ComplexType
   annotation :source => "xsd", :details => {'xmlName' => 'localComplexType'}
end

class MM::W3Org2001XMLSchema::Keybase < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'keybase'}
   has_attr 'name', String 
   has_attr 'ref', String 
end

class MM::W3Org2001XMLSchema::KeyrefTYPE < MM::W3Org2001XMLSchema::Keybase
   has_attr 'refer', String 
end

class MM::W3Org2001XMLSchema::AltType < MM::W3Org2001XMLSchema::Annotated
   annotation :source => "xsd", :details => {'xmlName' => 'altType'}
   has_attr 'test', String 
   has_attr 'type', String 
   has_attr 'xpathDefaultNamespace', Object 
end

class MM::W3Org2001XMLSchema::SelectorTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'xpath', String 
   has_attr 'xpathDefaultNamespace', Object 
end

class MM::W3Org2001XMLSchema::FieldTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'xpath', String 
   has_attr 'xpathDefaultNamespace', Object 
end

class MM::W3Org2001XMLSchema::TopLevelComplexType < MM::W3Org2001XMLSchema::ComplexType
   annotation :source => "xsd", :details => {'xmlName' => 'topLevelComplexType'}
end

class MM::W3Org2001XMLSchema::TopLevelElement < MM::W3Org2001XMLSchema::Element
   annotation :source => "xsd", :details => {'xmlName' => 'topLevelElement'}
end

class MM::W3Org2001XMLSchema::NamedGroup < MM::W3Org2001XMLSchema::RealGroup
   annotation :source => "xsd", :details => {'xmlName' => 'namedGroup'}
end

class MM::W3Org2001XMLSchema::AllTYPE < MM::W3Org2001XMLSchema::All
end

class MM::W3Org2001XMLSchema::SimpleExplicitGroup < MM::W3Org2001XMLSchema::ExplicitGroup
   annotation :source => "xsd", :details => {'xmlName' => 'simpleExplicitGroup'}
end

class MM::W3Org2001XMLSchema::NamedAttributeGroup < MM::W3Org2001XMLSchema::AttributeGroup
   annotation :source => "xsd", :details => {'xmlName' => 'namedAttributeGroup'}
end

class MM::W3Org2001XMLSchema::TopLevelSimpleType < MM::W3Org2001XMLSchema::SimpleType
   annotation :source => "xsd", :details => {'xmlName' => 'topLevelSimpleType'}
end

class MM::W3Org2001XMLSchema::IntFacet < MM::W3Org2001XMLSchema::Facet
   annotation :source => "xsd", :details => {'xmlName' => 'intFacet'}
end

class MM::W3Org2001XMLSchema::SchemaTYPE < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'targetNamespace', String 
   has_attr 'version', String 
   has_attr 'finalDefault', Object 
   has_attr 'blockDefault', Object 
   has_attr 'attributeFormDefault', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'elementFormDefault', MM::W3Org2001XMLSchema::FormChoiceEnum 
   has_attr 'defaultAttributes', String 
   has_attr 'xpathDefaultNamespace', Object 
   has_attr 'id', String 
   has_attr 'lang', Object 
end

class MM::W3Org2001XMLSchema::DefaultOpenContentTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'appliesToEmpty', Boolean 
   has_attr 'mode', MM::W3Org2001XMLSchema::ModeEnum2 
end

class MM::W3Org2001XMLSchema::NotationTYPE < MM::W3Org2001XMLSchema::Annotated
   has_attr 'name', String 
   has_attr 'public', String 
   has_attr 'system', String 
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

class MM::W3Org2001XMLSchema::OverrideTYPE < MM::W3Org2001XMLSchema::OpenAttrs
   has_attr 'schemaLocation', String 
   has_attr 'id', String 
end


MM::W3Org2001XMLSchema::Annotated.contains_one_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
MM::W3Org2001XMLSchema::AnnotationTYPE.contains_many_uni 'appinfo', MM::W3Org2001XMLSchema::AppinfoTYPE 
MM::W3Org2001XMLSchema::AnnotationTYPE.contains_many_uni 'documentation', MM::W3Org2001XMLSchema::DocumentationTYPE 
MM::W3Org2001XMLSchema::Attribute.contains_one 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType, 'containingAttribute' 
MM::W3Org2001XMLSchema::Attribute.has_one 'ref', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::Attribute.has_one 'type', MM::W3Org2001XMLSchema::SimpleType 
MM::W3Org2001XMLSchema::Element.contains_one 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType, 'containingElement' 
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
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'assertion', MM::W3Org2001XMLSchema::Assertion 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_many_uni 'explicitTimezone', MM::W3Org2001XMLSchema::ExplicitTimezoneTYPE 
MM::W3Org2001XMLSchema::RestrictionTYPE.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::RestrictionTYPE.has_one 'base', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::ListTYPE.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::ListTYPE.has_one 'itemType', MM::W3Org2001XMLSchema::SimpleType 
MM::W3Org2001XMLSchema::UnionTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::UnionTYPE.has_many 'memberTypes', MM::W3Org2001XMLSchema::SimpleType 
MM::W3Org2001XMLSchema::SimpleType.contains_one_uni 'restriction', MM::W3Org2001XMLSchema::RestrictionTYPE 
MM::W3Org2001XMLSchema::SimpleType.contains_one_uni 'list', MM::W3Org2001XMLSchema::ListTYPE 
MM::W3Org2001XMLSchema::SimpleType.contains_one_uni 'union', MM::W3Org2001XMLSchema::UnionTYPE 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ComplexType.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::ComplexType.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::AnyAttributeTYPE 
MM::W3Org2001XMLSchema::ComplexType.contains_many_uni 'assert', MM::W3Org2001XMLSchema::Assertion 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'openContent', MM::W3Org2001XMLSchema::OpenContentTYPE 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'simpleContent', MM::W3Org2001XMLSchema::SimpleContentTYPE 
MM::W3Org2001XMLSchema::ComplexType.contains_one_uni 'complexContent', MM::W3Org2001XMLSchema::ComplexContentTYPE 
MM::W3Org2001XMLSchema::OpenContentTYPE.contains_one_uni 'any', MM::W3Org2001XMLSchema::Wildcard 
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
MM::W3Org2001XMLSchema::AttributeGroup.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::AnyAttributeTYPE 
MM::W3Org2001XMLSchema::AttributeGroup.has_one 'ref', MM::W3Org2001XMLSchema::AttributeGroup 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::ExtensionType.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::ExtensionType.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::AnyAttributeTYPE 
MM::W3Org2001XMLSchema::ExtensionType.contains_many_uni 'assert', MM::W3Org2001XMLSchema::Assertion 
MM::W3Org2001XMLSchema::ExtensionType.contains_one_uni 'openContent', MM::W3Org2001XMLSchema::OpenContentTYPE 
MM::W3Org2001XMLSchema::ExtensionType.has_one 'base', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::Element.contains_one 'complexType', MM::W3Org2001XMLSchema::LocalComplexType, 'containingElement' 
MM::W3Org2001XMLSchema::Keybase.contains_one_uni 'selector', MM::W3Org2001XMLSchema::SelectorTYPE 
MM::W3Org2001XMLSchema::Keybase.contains_many_uni 'field', MM::W3Org2001XMLSchema::FieldTYPE 
MM::W3Org2001XMLSchema::AltType.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::AltType.contains_one_uni 'complexType', MM::W3Org2001XMLSchema::LocalComplexType 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'unique', MM::W3Org2001XMLSchema::Keybase 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'key', MM::W3Org2001XMLSchema::Keybase 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'keyref', MM::W3Org2001XMLSchema::KeyrefTYPE 
MM::W3Org2001XMLSchema::Element.contains_many_uni 'alternative', MM::W3Org2001XMLSchema::AltType 
MM::W3Org2001XMLSchema::Element.has_one 'ref', MM::W3Org2001XMLSchema::Element 
MM::W3Org2001XMLSchema::Element.has_one 'type', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::Element.many_to_many 'substitutionGroup', MM::W3Org2001XMLSchema::Element, 'substitutes' 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'group', MM::W3Org2001XMLSchema::GroupRef 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'all', MM::W3Org2001XMLSchema::All 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'choice', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'sequence', MM::W3Org2001XMLSchema::ExplicitGroup 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'openContent', MM::W3Org2001XMLSchema::OpenContentTYPE 
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
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'assertion', MM::W3Org2001XMLSchema::Assertion 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'explicitTimezone', MM::W3Org2001XMLSchema::ExplicitTimezoneTYPE 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'simpleType', MM::W3Org2001XMLSchema::LocalSimpleType 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::Attribute 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::AttributeGroupRef 
MM::W3Org2001XMLSchema::RestrictionType.contains_one_uni 'anyAttribute', MM::W3Org2001XMLSchema::AnyAttributeTYPE 
MM::W3Org2001XMLSchema::RestrictionType.contains_many_uni 'assert', MM::W3Org2001XMLSchema::Assertion 
MM::W3Org2001XMLSchema::RestrictionType.has_one 'base', MM::W3Org2001XMLSchema::Type 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_one_uni 'defaultOpenContent', MM::W3Org2001XMLSchema::DefaultOpenContentTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::TopLevelSimpleType 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'complexType', MM::W3Org2001XMLSchema::TopLevelComplexType 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'group', MM::W3Org2001XMLSchema::NamedGroup 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::NamedAttributeGroup 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'element', MM::W3Org2001XMLSchema::TopLevelElement 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::TopLevelAttribute 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'notation', MM::W3Org2001XMLSchema::NotationTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'include', MM::W3Org2001XMLSchema::IncludeTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'import', MM::W3Org2001XMLSchema::ImportTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'redefine', MM::W3Org2001XMLSchema::RedefineTYPE 
MM::W3Org2001XMLSchema::SchemaTYPE.contains_many_uni 'override', MM::W3Org2001XMLSchema::OverrideTYPE 
MM::W3Org2001XMLSchema::DefaultOpenContentTYPE.contains_one_uni 'any', MM::W3Org2001XMLSchema::Wildcard, :lowerBound => 1 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::TopLevelSimpleType 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'complexType', MM::W3Org2001XMLSchema::TopLevelComplexType 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'group', MM::W3Org2001XMLSchema::NamedGroup 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::NamedAttributeGroup 
MM::W3Org2001XMLSchema::RedefineTYPE.contains_many_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'simpleType', MM::W3Org2001XMLSchema::TopLevelSimpleType 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'complexType', MM::W3Org2001XMLSchema::TopLevelComplexType 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'group', MM::W3Org2001XMLSchema::NamedGroup 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'attributeGroup', MM::W3Org2001XMLSchema::NamedAttributeGroup 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'element', MM::W3Org2001XMLSchema::TopLevelElement 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'attribute', MM::W3Org2001XMLSchema::TopLevelAttribute 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_many_uni 'notation', MM::W3Org2001XMLSchema::NotationTYPE 
MM::W3Org2001XMLSchema::OverrideTYPE.contains_one_uni 'annotation', MM::W3Org2001XMLSchema::AnnotationTYPE 
