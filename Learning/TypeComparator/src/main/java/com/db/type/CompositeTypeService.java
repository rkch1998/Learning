package com.db.type;

import com.db.config.DatabaseUtil;
import com.db.util.FileWriter;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

import javax.sql.DataSource;

@Service
public class CompositeTypeService {

    @Autowired
    private JsonNode config;

    @Autowired
    private ScriptGenerator scriptGenerator;

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

    public void compareAndExport() {
        config.fields().forEachRemaining(databaseEntry -> {
            String dbName = databaseEntry.getKey();
            JsonNode databaseConfig = databaseEntry.getValue();

            // Configure data sources dynamically
            DataSource sourceDataSource = DatabaseUtil.createDataSource(databaseConfig.path("sourceClient"));
            DataSource targetDataSource = DatabaseUtil.createDataSource(databaseConfig.path("targetClient"));

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

                // Compare types and generate SQL commands
                Map<String, String> commands = scriptGenerator.compareTypes(sourceCompositeTypes, targetCompositeTypes);

                // Append commands to the aggregated SQL
                for (String command : commands.values()) {
                    sqlCommands.append(command).append("\n");
                }
            }

            // Write all schema changes for this database to a single file
            if (!sqlCommands.toString().isEmpty()) {
                fileWriter.writeToFile(sqlCommands.toString(), dbName);
            } else {
                System.out.println("No Changes found in " + dbName);
            }
        });
    }
}