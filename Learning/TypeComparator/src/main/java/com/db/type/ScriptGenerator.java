package com.db.type;

import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class ScriptGenerator {

    public Map<String, String> compareTypes(Map<String, String> sourceCompositeTypes, Map<String, String> targetCompositeTypes) {
        Map<String, String> sqlCommands = new HashMap<>();

        // Check for missing types in the target
        for (Map.Entry<String, String> entry : sourceCompositeTypes.entrySet()) {
            String typeName = entry.getKey();
            String sourceDefinition = entry.getValue();

            if (!targetCompositeTypes.containsKey(typeName)) {
                sqlCommands.put(typeName, "CREATE TYPE " + typeName + " AS (" + formatAttributes(sourceDefinition) + ");\n");
            } else {
                String targetDefinition = targetCompositeTypes.get(typeName);

                // Handle attribute changes
                handleAttributeChanges(typeName, sourceDefinition, targetDefinition, sqlCommands);
            }
        }

        // Check for dropped types in the source
        for (String typeName : targetCompositeTypes.keySet()) {
            if (!sourceCompositeTypes.containsKey(typeName)) {
                sqlCommands.put(typeName, "DROP TYPE IF EXISTS " + typeName + ";\n");
            }
        }

        return sqlCommands;
    }

    private void handleAttributeChanges(String typeName, String sourceDefinition, String targetDefinition, Map<String, String> sqlCommands) {
        Map<String, String> sourceAttributes = extractAttributesWithTypes(sourceDefinition);
        Map<String, String> targetAttributes = extractAttributesWithTypes(targetDefinition);

        for (Map.Entry<String, String> entry : sourceAttributes.entrySet()) {
            String attrName = entry.getKey();
            String sourceDataType = entry.getValue();

            // Check for dropped types in the source
            if (!targetAttributes.containsKey(attrName)) {
                sqlCommands.put(typeName, "ALTER TYPE " + typeName + " ADD ATTRIBUTE \"" + attrName + "\" " + sourceDataType + ";\n");
            } else {
                String targetDataType = targetAttributes.get(attrName);

                // Check for dropped types in the source
                if (!sourceDataType.equals(targetDataType)) {
                    sqlCommands.put(typeName, "ALTER TYPE " + typeName + " ALTER ATTRIBUTE \"" + attrName + "\" TYPE " + sourceDataType + ";\n");
                }
            }
        }

        // Check for dropped ATTRIBUTE in the source
        for (String attrName : targetAttributes.keySet()) {
            if (!sourceAttributes.containsKey(attrName)) {
                sqlCommands.put(typeName, "ALTER TYPE " + typeName + " DROP ATTRIBUTE \"" + attrName + "\";\n");
            }
        }
    }

    private Map<String, String> extractAttributesWithTypes(String typeDefinition) {
        Map<String, String> attributes = new HashMap<>();
        String[] parts = typeDefinition.split(", ");
        for (String part : parts) {
            // Filter out the placeholder attributes like "pg.dropped.*"
            if (!part.contains("pg.dropped.")) {
                // Extract attribute name and type
                String[] attrParts = part.split(" ", 2);
                if (attrParts.length == 2) {
                    attributes.put(attrParts[0].replace("\"", ""), attrParts[1]);
                }
            }
        }
        return attributes;
    }

    private String formatAttributes(String typeDefinition) {
        StringBuilder sb = new StringBuilder();
        for (String attr : extractAttributesWithTypes(typeDefinition).keySet()) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            String attrType = extractAttributesWithTypes(typeDefinition).get(attr);
            sb.append("\"").append(attr).append("\" ").append(attrType);
        }
        return sb.toString();
    }
}
