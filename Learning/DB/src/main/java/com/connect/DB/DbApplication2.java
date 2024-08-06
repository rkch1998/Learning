package com.connect.DB;


import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class DbApplication2 {

    public static void main(String[] args) {
        // Database URLs and credentials
        String urlOld = "jdbc:postgresql://103.158.108.18:5432/1_CygnetGSPTenant_1";
        String urlNew = "jdbc:postgresql://103.158.108.17:5432/1_CygnetGSPTenant_1";
        String user = "CygGSPDBA";
        String passwordOld = "Admin#321";
        String passwordNew = "th3dB@1sh3r3";
        String schemaName = "temp";
        String outputFile = "newType.sql";

        try {
            // Load PostgreSQL JDBC driver
            Class.forName("org.postgresql.Driver");

            // Fetch composite types from both old and new databases
            Map<String, String> oldCompositeTypes = getCompositeTypes(urlOld, user, passwordOld, schemaName);
            Map<String, String> newCompositeTypes = getCompositeTypes(urlNew, user, passwordNew, schemaName);

            // Identify changed types
            Map<String, String> changedTypes = new HashMap<>();
            for (String typeName : newCompositeTypes.keySet()) {
                if (!oldCompositeTypes.containsKey(typeName) ||
                    !oldCompositeTypes.get(typeName).equals(newCompositeTypes.get(typeName))) {
                    changedTypes.put(typeName, newCompositeTypes.get(typeName));
                }
            }

            // Write changed types to output file
            writeChangedTypesToFile(outputFile, changedTypes);

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Fetches composite types from the specified database and schema.
     */
    private static Map<String, String> getCompositeTypes(String url, String user, String password, String schemaName) {
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

        //System.out.println("Query: " + query);

        try (Connection con = DriverManager.getConnection(url, user, password);
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(query)) {

            while (rs.next()) {
                String typeName = rs.getString("type_name");
                String typeDefinition = rs.getString("type_definition");
                compositeTypes.put(schemaName + "." + typeName, typeDefinition);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return compositeTypes;
    }

    /**
     * Writes the changed custom types to the specified file.
     */
    private static void writeChangedTypesToFile(String fileName, Map<String, String> changedTypes) {
        try (FileWriter writer = new FileWriter(fileName)) {
            for (Map.Entry<String, String> entry : changedTypes.entrySet()) {
                writer.write("CREATE TYPE " + entry.getKey() + " AS (\n");
                writer.write("    " + entry.getValue() + "\n");
                writer.write(");\n\n");
            }
            System.out.println("Changed custom types written to file: " + fileName);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
