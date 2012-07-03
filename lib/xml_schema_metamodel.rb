require 'rgen/metamodel_builder'

module XMLSchemaMetamodel
  extend RGen::MetamodelBuilder::ModuleExtension

  class Annotatable < RGen::MetamodelBuilder::MMBase
    abstract
  end
   
  class Schema < Annotatable 
    has_attr "targetNamespace", String
    has_attr "attributeFormDefault", String
    has_attr "elementFormDefault", String
    has_attr "version", String
    has_attr "blockDefault", String
    has_attr "lang", String
  end

  class Import < Annotatable
    has_attr "namespace", String
    has_attr "schemaLocation", String
  end
  Schema.contains_many_uni "import", Import

  class Include < RGen::MetamodelBuilder::MMBase
    has_attr "schemaLocation", String
  end
  Schema.contains_many_uni "include", Include

  class Enumeration < RGen::MetamodelBuilder::MMBase
    has_attr "value", String
  end

  class MaxInclusive < RGen::MetamodelBuilder::MMBase
    has_attr "value", String
  end

  class MinInclusive < RGen::MetamodelBuilder::MMBase
    has_attr "value", String
  end

  class Type < Annotatable
    abstract
    has_attr "name", String
  end

  class Extension < RGen::MetamodelBuilder::MMBase
    has_one "base", Type
  end

  class AnyAttribute < RGen::MetamodelBuilder::MMBase
    has_attr "namespace", String
    has_attr "processContents", String
  end

  class Restriction < RGen::MetamodelBuilder::MMBase
    has_one "base", Type
    contains_many_uni "enumeration", Enumeration
    contains_one_uni "minInclusive", MinInclusive
    contains_one_uni "maxInclusive", MaxInclusive
    contains_one_uni "anyAttribute", AnyAttribute
  end

  class Union < Annotatable
  end

  class SimpleType < Type 
    contains_one_uni "restriction", Restriction
    contains_one_uni "union", Union
  end

  class List < Annotatable
    has_one "itemType", SimpleType
  end
  SimpleType.contains_one_uni "list", List

  Union.contains_many_uni "simpleType", SimpleType
  List.contains_one_uni "simpleType", SimpleType

  class ComplexType < Type
    has_attr "abstract", Boolean
    has_attr "final", String
  end

  class ComplexTypeContent < RGen::MetamodelBuilder::MMBase
  end

  class Sequence < ComplexTypeContent
    has_attr "minOccurs", String
    has_attr "maxOccurs", String
  end
  Sequence.contains_many_uni "contents", ComplexTypeContent do
    annotation :source => "xsd", :details => { 'xmlName' => 'element=Element,sequence=Sequence,choice=Choice,group=Group' }
  end

  class Choice < ComplexTypeContent
    has_attr "minOccurs", String
    has_attr "maxOccurs", String
  end
  Choice.contains_many_uni "contents", ComplexTypeContent do
    annotation :source => "xsd", :details => { 'xmlName' => 'element=Element,sequence=Sequence,choice=Choice,group=Group' }
  end

  ComplexType.contains_many_uni "contents", ComplexTypeContent do
    annotation :source => "xsd", :details => { 'xmlName' => 'element=Element,sequence=Sequence,choice=Choice,group=Group' }
  end

  Extension.contains_many_uni "contents", ComplexTypeContent do
    annotation :source => "xsd", :details => { 'xmlName' => 'element=Element,sequence=Sequence,choice=Choice,group=Group' }
  end

  class Group < RGen::MetamodelBuilder::MMMultiple(Annotatable, ComplexTypeContent)
    has_attr "name", String
    has_one "ref", Group
  end
  Group.contains_many_uni "contents", ComplexTypeContent do
    annotation :source => "xsd", :details => { 'xmlName' => 'element=Element,sequence=Sequence,choice=Choice,group=Group' }
  end
  
  class Documentation < RGen::MetamodelBuilder::MMBase
    has_attr "source", String
    has_attr "text", String do
      annotation :source => "xsd", :details => { 'simpleContent' => 'true' }
    end
  end

  class Annotation < RGen::MetamodelBuilder::MMBase
    contains_one_uni "documentation", Documentation
  end
  Annotatable.contains_many_uni "annotation", Annotation

  class ComplexContent < RGen::MetamodelBuilder::MMBase
  end

  class SimpleContent < RGen::MetamodelBuilder::MMBase
  end

  ComplexType.contains_one_uni "complexContent", ComplexContent
  ComplexType.contains_one_uni "simpleContent", SimpleContent
  ComplexContent.contains_one_uni "extension", Extension
  ComplexContent.contains_one_uni "restriction", Restriction
  SimpleContent.contains_one_uni "extension", Extension

  class Element < RGen::MetamodelBuilder::MMMultiple(Annotatable, ComplexTypeContent)
    has_attr "id", String
    has_attr "name", String
    has_attr "default", String
    has_attr "minOccurs", String
    has_attr "maxOccurs", String
    has_one "ref", Element
    has_one "typeViaRef", Type do
      annotation :source => "xsd", :details => { 'xmlName' => 'type'}
    end
    contains_one_uni "typeViaCont", Type do
      annotation :source => "xsd", :details => { 'xmlName' => 'simpleType=SimpleType,complexType=ComplexType'}
    end
  end

  class Attribute < Annotatable
    has_attr "name", String
    has_attr "use", String
    has_attr "fixed", String
    has_attr "default", String
    has_one "ref", Attribute
    has_one "typeViaRef", SimpleType do
      annotation :source => "xsd", :details => { 'xmlName' => 'type'}
    end
    contains_one_uni "typeViaCont", SimpleType do
      annotation :source => "xsd", :details => { 'xmlName' => 'simpleType'}
    end
  end
  Extension.contains_many_uni "attribute", Attribute
  ComplexType.contains_many_uni "attribute", Attribute
  Schema.contains_many_uni "type", Type do
    annotation :source => "xsd", :details => { 'xmlName' => 'simpleType=SimpleType,complexType=ComplexType'}
  end
  Schema.contains_many_uni "type", Type do
    annotation :source => "xsd", :details => { 'xmlName' => 'simpleType=SimpleType,complexType=ComplexType'}
  end
  Schema.contains_many_uni "element", Element
  Schema.contains_many_uni "group", Group

end
