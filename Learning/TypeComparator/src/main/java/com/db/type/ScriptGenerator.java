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
            
            StringBuilder typeCommands = new StringBuilder();
            
            if (!targetCompositeTypes.containsKey(typeName)) {
                typeCommands.append("CREATE TYPE ").append(typeName).append(" AS (").append(formatAttributes(sourceDefinition)).append(");\n");
            } else {
                String targetDefinition = targetCompositeTypes.get(typeName);

                // Handle attribute changes
                handleAttributeChanges(typeName, sourceDefinition, targetDefinition, typeCommands);
            }
            
            if (typeCommands.length() > 0) {
                sqlCommands.put(typeName, typeCommands.toString());
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

    private void handleAttributeChanges(String typeName, String sourceDefinition, String targetDefinition, StringBuilder typeCommands) {
        Map<String, String> sourceAttributes = extractAttributesWithTypes(sourceDefinition);
        Map<String, String> targetAttributes = extractAttributesWithTypes(targetDefinition);

        for (Map.Entry<String, String> entry : sourceAttributes.entrySet()) {
            String attrName = entry.getKey();
            String sourceDataType = entry.getValue();

            if (!targetAttributes.containsKey(attrName)) {
                typeCommands.append("ALTER TYPE ").append(typeName).append(" ADD ATTRIBUTE \"").append(attrName).append("\" ").append(sourceDataType).append(";\n");
            } else {
                String targetDataType = targetAttributes.get(attrName);

                if (!sourceDataType.equals(targetDataType)) {
                    typeCommands.append("ALTER TYPE ").append(typeName).append(" ALTER ATTRIBUTE \"").append(attrName).append("\" TYPE ").append(sourceDataType).append(";\n");
                }
            }
        }

        for (String attrName : targetAttributes.keySet()) {
            if (!sourceAttributes.containsKey(attrName)) {
                typeCommands.append("ALTER TYPE ").append(typeName).append(" DROP ATTRIBUTE \"").append(attrName).append("\";\n");
            }
        }
    }

    private Map<String, String> extractAttributesWithTypes(String typeDefinition) {
        Map<String, String> attributes = new HashMap<>();
        String[] parts = typeDefinition.split(", ");
        for (String part : parts) {
            if (!part.contains("pg.dropped.")) {
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
