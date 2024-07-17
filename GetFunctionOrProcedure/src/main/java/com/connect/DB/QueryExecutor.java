package com.connect.DB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class QueryExecutor {
    private final DatabaseConnectionManager connectionManager;
    private final String dbType;

    public QueryExecutor(DatabaseConnectionManager connectionManager, String dbType) {
        this.connectionManager = connectionManager;
        this.dbType = dbType;
    }

    public String executeQuery(String dbName, String schemaName, String functionName) {
        String query = getQuery(schemaName, functionName);

        try (Connection connection = connectionManager.getConnection(dbName);
             PreparedStatement statement = connection.prepareStatement(query);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                return resultSet.getString(1) + ";";
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
        }
        return null;
    }

    private String getQuery(String schemaName, String functionName) {
        return switch (dbType) {
            case "sql" -> String.format("SELECT OBJECT_DEFINITION (OBJECT_ID('%s.%s'))", schemaName, functionName);
            case "pg" -> String.format(
                    "SELECT pg_get_functiondef(p.oid) " +
                            "FROM pg_proc p " +
                            "JOIN pg_namespace n ON p.pronamespace = n.oid " +
                            "WHERE n.nspname = '%s' AND p.proname = '%s'",
                    schemaName, functionName);
            default -> throw new IllegalArgumentException("Unsupported database type: " + dbType);
        };
    }
}
