package com.db.type;

import com.db.config.DatabaseUtil;
import com.db.format.FormatFactory;
import com.db.util.FileWriter;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

@Service
public class CompositeTypeService {

    @Autowired
    private JsonNode config;

    @Autowired
    private FormatFactory formatFactory;

    @Autowired
    private FileWriter fileWriter;

    public Map<String, String> getCompositeTypes(JdbcTemplate jdbcTemplate, String schemaName) {
        Map<String, String> compositeTypes = new HashMap<>();
        String query = String.format("""
            SELECT
                n.nspname AS schema_name, 
                t.typname AS type_name,
                string_agg('"' || a.attname || '" ' || pg_catalog.format_type(a.atttypid, a.atttypmod), ', ') AS type_definition
            FROM pg_type t 
            LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace 
            JOIN pg_class c ON c.oid = t.typrelid
            JOIN pg_attribute a ON a.attrelid = c.oid
            WHERE 
                (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
                AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
                AND n.nspname NOT IN ('pg_catalog', 'information_schema')
                AND n.nspname = '%s'
            GROUP BY
                n.nspname, t.typname;
            """, schemaName);

        jdbcTemplate.query(query, rs -> {
            String typeName = rs.getString("type_name");
            String typeDefinition = rs.getString("type_definition");
            compositeTypes.put("\"" + schemaName + "\".\"" + typeName + "\"", typeDefinition);
        });

        return compositeTypes;
    }

    public void compareAndExport(String environment) {
        JsonNode envConfig = config.path(environment);

        if (envConfig.isMissingNode()) {
            throw new IllegalArgumentException("Environment " + environment + " not found in configuration.");
        }

        envConfig.fields().forEachRemaining(databaseEntry -> {
            String dbName = databaseEntry.getKey();
            JsonNode databaseConfig = databaseEntry.getValue();

            DataSource sourceDataSource = null;
            DataSource targetDataSource = null;

            try {
                // Configure data sources dynamically
                sourceDataSource = DatabaseUtil.createDataSource(databaseConfig.path("sourceClient"));
                targetDataSource = DatabaseUtil.createDataSource(databaseConfig.path("targetClient"));

                JdbcTemplate sourceJdbcTemplate = new JdbcTemplate(sourceDataSource);
                JdbcTemplate targetJdbcTemplate = new JdbcTemplate(targetDataSource);

                StringBuilder sqlCommands = new StringBuilder();

                // Fetch the schema names for the current database
                JsonNode namespaces = databaseConfig.path("schemaCompare").path("namespaces");

                for (JsonNode namespace : namespaces) {
                    String schemaName = namespace.asText();

                    // Fetch and compare types
                    Map<String, String> sourceCompositeTypes = getCompositeTypes(sourceJdbcTemplate, schemaName);
                    Map<String, String> targetCompositeTypes = getCompositeTypes(targetJdbcTemplate, schemaName);

                    for (Map.Entry<String, String> entry : sourceCompositeTypes.entrySet()) {
                        String typeName = entry.getKey();
                        // System.out.println(typeName);
                        String sourceTypeDef = entry.getValue();

                        if (!targetCompositeTypes.containsKey(typeName)) {
                            // Create new type
                            sqlCommands.append(formatFactory.getTypeFormat("create", schemaName, typeName, sourceTypeDef)).append("\n");
                        } else if (!sourceTypeDef.equals(targetCompositeTypes.get(typeName))) {
                            // Compare attributes
                            Map<String, String> sourceAttributes = extractAttributesWithTypes(sourceTypeDef);
                            Map<String, String> targetAttributes = extractAttributesWithTypes(targetCompositeTypes.get(typeName));

                            for (Map.Entry<String, String> attrEntry : sourceAttributes.entrySet()) {
                                String attrName = attrEntry.getKey();
                                String sourceDataType = attrEntry.getValue();

                                if (!targetAttributes.containsKey(attrName)) {
                                    sqlCommands.append(formatFactory.addAttributeFormat(schemaName, typeName, attrName, sourceDataType)).append("\n");
                                } else if (!sourceDataType.equals(targetAttributes.get(attrName))) {
                                    sqlCommands.append(formatFactory.alterAttributeFormat(schemaName, typeName, attrName, sourceDataType)).append("\n");
                                }
                            }

                            for (String attrName : targetAttributes.keySet()) {
                                if (!sourceAttributes.containsKey(attrName)) {
                                    sqlCommands.append(formatFactory.dropAttributeFormat(schemaName, typeName, attrName)).append("\n");
                                }
                            }
                        }
                    }

                    targetCompositeTypes.forEach((typeName, targetTypeDef) -> {
                        if (!sourceCompositeTypes.containsKey(typeName)) {
                            sqlCommands.append(formatFactory.getTypeFormat("drop", schemaName, typeName, targetTypeDef)).append("\n");
                        }
                    });
                }

                // Write all schema changes for this database to a single file
                if (!sqlCommands.toString().isEmpty()) {
                    fileWriter.writeToFile(sqlCommands.toString(), dbName);
                } else {
                    System.out.println("No Changes found in " + dbName);
                }
            } finally {
                if (sourceDataSource != null) {
                    DatabaseUtil.closeDataSource(sourceDataSource);
                }
                if (targetDataSource != null) {
                    DatabaseUtil.closeDataSource(targetDataSource);
                }
                // DatabaseUtil.closeSshTunnel();
            }
        });
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

    // private String formatAttributes(String typeDefinition) {
    //     StringBuilder sb = new StringBuilder();
    //     for (String attr : extractAttributesWithTypes(typeDefinition).keySet()) {
    //         if (sb.length() > 0) {
    //             sb.append(", ");
    //         }
    //         String attrType = extractAttributesWithTypes(typeDefinition).get(attr);
    //         sb.append("\"").append(attr).append("\" ").append(attrType);
    //     }
    //     return sb.toString();
    // }
}