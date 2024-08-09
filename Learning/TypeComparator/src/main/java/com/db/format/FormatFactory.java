package com.db.format;

import org.springframework.stereotype.Component;

import com.db.format.type.TypeFormat;

@Component
public class FormatFactory {

    private TypeFormat typeFormat = new TypeFormat();

    public String getTypeFormat(String operation, String schemaName, String typeName, String typeDefinition) {
        switch (operation.toLowerCase()) {
            case "create":
                return typeFormat.createTypeFormat(typeName, typeDefinition);
            case "alter":
                return typeFormat.alterTypeFormat(typeName, typeDefinition);
            case "drop":
                return String.format("DROP TYPE IF EXISTS %s;\n", typeName);
            default:
                throw new IllegalArgumentException("Unknown operation: " + operation);
        }
    }

    public String addAttributeFormat(String schemaName, String typeName, String attrName, String dataType) {
        return typeFormat.addAttributeFormat(typeName, attrName, dataType);
    }

    public String alterAttributeFormat(String schemaName, String typeName, String attrName, String dataType) {
        return typeFormat.alterAttributeFormat(typeName, attrName, dataType);
    }

    public String dropAttributeFormat(String schemaName, String typeName, String attrName) {
        return typeFormat.dropAttributeFormat(schemaName, typeName, attrName);
    }
}
