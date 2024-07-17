package com.connect.DB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class QueryExecutor {
    private final DatabaseConnectionManager connectionManager;

    public QueryExecutor(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
    }

    public String executeQuery(String dbName, String schemaName, String functionName) {
        String query = getQuery(dbName, schemaName, functionName);

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

    private String getQuery(String dbType, String schemaName, String functionName) {
        if (dbType.equals("pg")) {
            return String.format("SELECT pg_get_functiondef('%s.%s'::regproc);", schemaName, functionName);
        } else if (dbType.equals("sql")) {
            return String.format("SELECT OBJECT_DEFINITION (OBJECT_ID('%s.%s'))", schemaName, functionName);
        }
        throw new IllegalArgumentException("Unsupported database type: " + dbType);
    }
}
