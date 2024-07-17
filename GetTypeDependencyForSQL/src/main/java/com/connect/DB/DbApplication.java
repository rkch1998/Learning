package com.connect.DB;

import java.io.*;
import java.nio.file.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.*;

public class DbApplication {

    public static void main(String[] args) {
        if (args.length != 4) {
            System.out.println("Usage: java -jar DatabaseTypeSync.jar <dbType> <dbName> <schemaName> <typeName>");
            return;
        }

        String dbType = args[0];
        String dbName = args[1];
        String schemaName = args[2];
        String typeName = args[3];
        String outputFilePath = "procedures.sql";

        try {
            // Load database configurations
            ConfigLoader configLoader = new ConfigLoader("dbconfig.properties");
            Map<String, String[]> dbConfigs = configLoader.loadDbConfigs(dbType);

            DatabaseConnectionManager connectionManager = new DatabaseConnectionManager(dbConfigs, dbType);
            QueryExecutor queryExecutor = new QueryExecutor(connectionManager);

            try (FileWriter fileWriter = new FileWriter(outputFilePath)) {
                String query = getProcedureQuery(dbType);
                try (Connection connection = connectionManager.getConnection(dbName);
                     PreparedStatement statement = connection.prepareStatement(query)) {

                    statement.setString(1, schemaName);
                    statement.setString(2, typeName);

                    try (ResultSet resultSet = statement.executeQuery()) {
                        List<String> dropStatements = new ArrayList<>();
                        List<String> createStatements = new ArrayList<>();

                        while (resultSet.next()) {
                            String procSchemaName = resultSet.getString("schema_name");
                            String procedureName = resultSet.getString("procedure_name");
                            String procedureDefinition = resultSet.getString("complete_procedure_definition");

                            // Create the DROP statement
                            String dropStatement;
                            if (dbType.equals("pg")) {
                                dropStatement = String.format("DROP FUNCTION IF EXISTS %s.%s;", procSchemaName, procedureName);
                            } else {
                                dropStatement = String.format("DROP PROCEDURE IF EXISTS [%s].[%s];", procSchemaName, procedureName);
                            }
                            dropStatements.add(dropStatement);

                            // Add the formatted CREATE statement
                            createStatements.add(procedureDefinition);
                        }

                        // Write all DROP statements first
                        for (String dropStatement : dropStatements) {
                            fileWriter.write(dropStatement);
                            fileWriter.write(System.lineSeparator());
                        }

                        // Separate DROP and CREATE sections with a new line
                        fileWriter.write(System.lineSeparator());

                        // Write all CREATE statements
                        for (String createStatement : createStatements) {
                            fileWriter.write(createStatement);
                            fileWriter.write(System.lineSeparator());
                        }
                    }
                }

                System.out.println("Procedures have been successfully exported to " + outputFilePath);
            } catch (SQLException | IOException e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String getProcedureQuery(String dbType) {
        if (dbType.equals("pg")) {
            return "WITH RECURSIVE func_deps AS (" +
                    "    SELECT p.oid AS func_oid, n.nspname AS schema_name, p.proname AS function_name" +
                    "    FROM pg_proc p" +
                    "    JOIN pg_namespace n ON p.pronamespace = n.oid" +
                    "    WHERE n.nspname = ? AND p.proname = ?" +
                    "), proc_defs AS (" +
                    "    SELECT fd.schema_name, fd.function_name AS procedure_name, pg_get_functiondef(fd.func_oid) AS function_definition" +
                    "    FROM func_deps fd" +
                    ")" +
                    "SELECT schema_name, procedure_name, function_definition || ';' AS complete_procedure_definition" +
                    "FROM proc_defs;";
        } else if (dbType.equals("sql")) {
            return "WITH UDT_Dependencies AS (" +
                    "    SELECT obj.object_id AS procedure_id," +
                    "           obj.name AS procedure_name," +
                    "           sch.name AS schema_name" +
                    "    FROM sys.sql_expression_dependencies AS dep" +
                    "    JOIN sys.objects AS obj ON dep.referencing_id = obj.object_id" +
                    "    JOIN sys.schemas AS sch ON obj.schema_id = sch.schema_id" +
                    "    WHERE obj.type = 'P' " +
                    "      AND dep.referenced_id = (" +
                    "          SELECT user_type_id" +
                    "          FROM sys.types AS t" +
                    "          JOIN sys.schemas AS s ON t.schema_id = s.schema_id" +
                    "          WHERE s.name = ? AND t.name = ?" +
                    "      )" +
                    "), " + // Correct syntax: add a space before "Procedure_Definitions"
                    "Procedure_Definitions AS (" +
                    "    SELECT ud.procedure_name," +
                    "           ud.schema_name," +
                    "           OBJECT_DEFINITION(ud.procedure_id) AS procedure_definition" +
                    "    FROM UDT_Dependencies AS ud" +
                    ") " +
                    "SELECT schema_name," +
                    "       procedure_name," +
                    "       ISNULL(procedure_definition, '') + CHAR(13) + CHAR(10) + 'GO' AS complete_procedure_definition " +
                    "FROM Procedure_Definitions;";
        }
        throw new IllegalArgumentException("Unsupported database type: " + dbType);
    }
}
