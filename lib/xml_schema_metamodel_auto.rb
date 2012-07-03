require 'rgen/metamodel_builder'

module XMLSchemaMetamodel
   extend RGen::MetamodelBuilder::ModuleExtension
   include RGen::MetamodelBuilder::DataTypes

   class Type < RGen::MetamodelBuilder::MMBase
      abstract
   end

   class SimpleType < Type
      has_attr 'name', String 
      has_attr 'id', String 
   end

   class ComplexType < Type
      has_attr 'name', String 
      has_attr 'abstract', Boolean 
      has_attr 'mixed', String 
   end

   class Selector < RGen::MetamodelBuilder::MMBase
      has_attr 'xpath', String 
   end

   class ExplicitGroup < RGen::MetamodelBuilder::MMBase
      has_attr 'maxOccurs', String 
      has_attr 'minOccurs', String 
   end

   class Union < RGen::MetamodelBuilder::MMBase
      has_attr 'memberTypes', String   # reference?
   end

   class Pattern < RGen::MetamodelBuilder::MMBase
      has_attr 'value', String 
      has_attr 'id', String 
   end

   class Appinfo < RGen::MetamodelBuilder::MMBase
   end

   class Group < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
      has_one 'ref', Group 
      has_attr 'minOccurs', String 
      has_attr 'maxOccurs', String 
   end

   class Key < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
   end

   class FractionDigits < RGen::MetamodelBuilder::MMBase
      has_attr 'id', String 
      has_attr 'value', String 
      has_attr 'fixed', String 
   end

   class SchemaTYPE < RGen::MetamodelBuilder::MMBase
      has_attr 'blockDefault', String 
      has_attr 'elementFormDefault', String 
      has_attr 'lang', String 
      has_attr 'version', String 
      has_attr 'targetNamespace', String 
   end

   class ExtensionType < RGen::MetamodelBuilder::MMBase
      has_one 'base', Type 
   end

   class Attribute < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
      has_one 'type', SimpleType 
      has_attr 'default', String 
      has_attr 'fixed', String
      has_attr 'use', String 
      has_one 'ref', Attribute 
   end

   class NoFixedFacet < RGen::MetamodelBuilder::MMBase
      has_attr 'value', String 
   end

   class Field < RGen::MetamodelBuilder::MMBase
      has_attr 'xpath', String 
   end

   class Any < RGen::MetamodelBuilder::MMBase
      has_attr 'namespace', String 
      has_attr 'processContents', String 
      has_attr 'maxOccurs', String 
      has_attr 'minOccurs', String 
   end

   class MinInclusive < RGen::MetamodelBuilder::MMBase
      has_attr 'id', String 
      has_attr 'value', String 
   end

   class Annotation < RGen::MetamodelBuilder::MMBase
   end

   class Restriction < RGen::MetamodelBuilder::MMBase
      has_one 'base', Type 
   end

   class Notation < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
      has_attr 'public', String 
      has_attr 'system', String 
   end

   class AttributeGroup < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
      has_one 'ref', AttributeGroup
   end

   class HasProperty < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
      has_attr 'value', String 
   end

   class Documentation < RGen::MetamodelBuilder::MMBase
      has_attr "text", String do
        annotation :source => "xsd", :details => { 'simpleContent' => 'true' }
      end
      has_attr 'source', String 
   end

   class ComplexContent < RGen::MetamodelBuilder::MMBase
   end

   class MinLength < RGen::MetamodelBuilder::MMBase
      has_attr 'id', String 
      has_attr 'value', String 
   end

   class MaxLength < RGen::MetamodelBuilder::MMBase
      has_attr 'id', String 
      has_attr 'value', String 
   end

   class AnyAttribute < RGen::MetamodelBuilder::MMBase
      has_attr 'namespace', String 
      has_attr 'processContents', String 
   end

   class WhiteSpace < RGen::MetamodelBuilder::MMBase
      has_attr 'id', String 
      has_attr 'value', String 
      has_attr 'fixed', String 
   end

   class MaxInclusive < RGen::MetamodelBuilder::MMBase
      has_attr 'id', String 
      has_attr 'value', String 
   end

   class Import < RGen::MetamodelBuilder::MMBase
      has_attr 'schemaLocation', String 
      has_attr 'namespace', String 
   end

   class Include < RGen::MetamodelBuilder::MMBase
      has_attr 'schemaLocation', String 
   end

   class Element < RGen::MetamodelBuilder::MMBase
      has_attr 'abstract', Boolean 
      has_attr 'minOccurs', String 
      has_one 'ref', Element 
      many_to_one 'substitutionGroup', Element, 'substitutes'
      has_attr 'name', String 
      has_attr 'id', String 
      has_attr 'maxOccurs', String 
      has_one 'type', ComplexType 
   end

   class List < RGen::MetamodelBuilder::MMBase
      has_one 'itemType', SimpleType 
   end

   class HasFacet < RGen::MetamodelBuilder::MMBase
      has_attr 'name', String 
   end

end

XMLSchemaMetamodel::ComplexType.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::ComplexType.contains_one_uni 'complexContent', XMLSchemaMetamodel::ComplexContent 
XMLSchemaMetamodel::ComplexType.contains_many_uni 'sequence', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ComplexType.contains_many_uni 'choice', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ComplexType.contains_many_uni 'all', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ComplexType.contains_many_uni 'group', XMLSchemaMetamodel::Group 
XMLSchemaMetamodel::ComplexType.contains_many_uni 'attribute', XMLSchemaMetamodel::Attribute 
XMLSchemaMetamodel::ComplexType.contains_many_uni 'anyAttribute', XMLSchemaMetamodel::AnyAttribute 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'element', XMLSchemaMetamodel::Element 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'group', XMLSchemaMetamodel::Group 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'choice', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'sequence', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'all', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::ExplicitGroup.contains_many_uni 'any', XMLSchemaMetamodel::Any 
XMLSchemaMetamodel::Union.contains_many_uni 'simpleType', XMLSchemaMetamodel::SimpleType 
XMLSchemaMetamodel::Pattern.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::Appinfo.contains_many_uni 'hasFacet', XMLSchemaMetamodel::HasFacet 
XMLSchemaMetamodel::Appinfo.contains_many_uni 'hasProperty', XMLSchemaMetamodel::HasProperty 
XMLSchemaMetamodel::Group.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::Group.contains_many_uni 'choice', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::Group.contains_many_uni 'sequence', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::Group.contains_many_uni 'all', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::Key.contains_many_uni 'selector', XMLSchemaMetamodel::Selector 
XMLSchemaMetamodel::Key.contains_many_uni 'field', XMLSchemaMetamodel::Field 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'import', XMLSchemaMetamodel::Import 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'include', XMLSchemaMetamodel::Include 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'complexType', XMLSchemaMetamodel::ComplexType 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'group', XMLSchemaMetamodel::Group 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'simpleType', XMLSchemaMetamodel::SimpleType 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'element', XMLSchemaMetamodel::Element 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'attributeGroup', XMLSchemaMetamodel::AttributeGroup 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'notation', XMLSchemaMetamodel::Notation 
XMLSchemaMetamodel::SchemaTYPE.contains_many_uni 'attribute', XMLSchemaMetamodel::Attribute
XMLSchemaMetamodel::ExtensionType.contains_many_uni 'sequence', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ExtensionType.contains_many_uni 'all', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::ExtensionType.contains_many_uni 'attribute', XMLSchemaMetamodel::Attribute 
XMLSchemaMetamodel::ExtensionType.contains_many_uni 'attributeGroup', XMLSchemaMetamodel::AttributeGroup 
XMLSchemaMetamodel::ExtensionType.contains_many_uni 'group', XMLSchemaMetamodel::Group 
XMLSchemaMetamodel::ExtensionType.contains_many_uni 'choice', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::Attribute.contains_one 'simpleType', XMLSchemaMetamodel::SimpleType, "containingAttribute"
XMLSchemaMetamodel::Attribute.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::Annotation.contains_many_uni 'documentation', XMLSchemaMetamodel::Documentation 
XMLSchemaMetamodel::Annotation.contains_many_uni 'appinfo', XMLSchemaMetamodel::Appinfo 
XMLSchemaMetamodel::Restriction.contains_many_uni 'anyAttribute', XMLSchemaMetamodel::AnyAttribute 
XMLSchemaMetamodel::Restriction.contains_many_uni 'enumeration', XMLSchemaMetamodel::NoFixedFacet 
XMLSchemaMetamodel::Restriction.contains_many_uni 'sequence', XMLSchemaMetamodel::ExplicitGroup 
XMLSchemaMetamodel::Restriction.contains_many_uni 'attribute', XMLSchemaMetamodel::Attribute 
XMLSchemaMetamodel::Restriction.contains_many_uni 'group', XMLSchemaMetamodel::Group 
XMLSchemaMetamodel::Restriction.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::Restriction.contains_many_uni 'pattern', XMLSchemaMetamodel::Pattern 
XMLSchemaMetamodel::Restriction.contains_many_uni 'whiteSpace', XMLSchemaMetamodel::WhiteSpace 
XMLSchemaMetamodel::Restriction.contains_many_uni 'simpleType', XMLSchemaMetamodel::SimpleType 
XMLSchemaMetamodel::Restriction.contains_many_uni 'minLength', XMLSchemaMetamodel::MinLength 
XMLSchemaMetamodel::Restriction.contains_many_uni 'maxLength', XMLSchemaMetamodel::MaxLength 
XMLSchemaMetamodel::Restriction.contains_many_uni 'fractionDigits', XMLSchemaMetamodel::FractionDigits 
XMLSchemaMetamodel::Restriction.contains_many_uni 'maxInclusive', XMLSchemaMetamodel::MaxInclusive 
XMLSchemaMetamodel::Restriction.contains_many_uni 'minInclusive', XMLSchemaMetamodel::MinInclusive 
XMLSchemaMetamodel::SimpleType.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::SimpleType.contains_one_uni 'restriction', XMLSchemaMetamodel::Restriction 
XMLSchemaMetamodel::SimpleType.contains_one_uni 'list', XMLSchemaMetamodel::List 
XMLSchemaMetamodel::SimpleType.contains_one_uni 'union', XMLSchemaMetamodel::Union 
XMLSchemaMetamodel::AttributeGroup.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::AttributeGroup.contains_many_uni 'attribute', XMLSchemaMetamodel::Attribute 
XMLSchemaMetamodel::ComplexContent.contains_one_uni 'restriction', XMLSchemaMetamodel::Restriction 
XMLSchemaMetamodel::ComplexContent.contains_one_uni 'extension', XMLSchemaMetamodel::ExtensionType 
XMLSchemaMetamodel::Import.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::Element.contains_many_uni 'annotation', XMLSchemaMetamodel::Annotation 
XMLSchemaMetamodel::Element.contains_one 'complexType', XMLSchemaMetamodel::ComplexType, "containingElement"
XMLSchemaMetamodel::Element.contains_many_uni 'key', XMLSchemaMetamodel::Key 
XMLSchemaMetamodel::List.contains_one_uni 'simpleType', XMLSchemaMetamodel::SimpleType 
