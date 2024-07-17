package com.database.sync.model;

public class UserDefinedType {
    private String schemaName;
    private String typeName;

    public UserDefinedType(String schemaName, String typeName) {
        this.schemaName = schemaName;
        this.typeName = typeName;
    }

    // Getters and Setters
    public String getSchemaName() {
        return schemaName;
    }

    public void setSchemaName(String schemaName) {
        this.schemaName = schemaName;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
}
