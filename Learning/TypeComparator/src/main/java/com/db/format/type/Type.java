package com.db.format.type;

public interface Type {
    String createTypeFormat(String typeName, String typeDefinition);
    String alterTypeFormat(String typeName, String newDefinition);
    String addAttributeFormat(String typeName, String attrName, String dataType);
    String alterAttributeFormat(String typeName, String attrName, String dataType);
    String dropAttributeFormat(String schemaName, String typeName, String attrName);
}
