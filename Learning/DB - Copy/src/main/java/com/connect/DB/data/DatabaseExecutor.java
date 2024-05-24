package com.connect.DB.data;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class DatabaseExecutor {

    private final Map<String, Connection> connections = new HashMap<>();
    public DatabaseExecutor(Map<String, String[]> dbConfigs) throws SQLException {
        for (Map.Entry<String, String[]> entry : dbConfigs.entrySet()) {
            String dbName = entry.getKey();
            String[] config = entry.getValue();
            String url = config[0];
            String username = config[1];
            String password = config[2];
            connections.put(dbName, DriverManager.getConnection(url, username, password));
        }
    }

    public Connection getConnection(String dbName) {
        return connections.get(dbName);
    }


    public String executeQuery(String dbName, String schemaName, String functionName) {
        String query = String.format("""
                SELECT pg_get_functiondef(oid)
                FROM pg_proc
                WHERE proname = '%s'
                AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = '%s')
                """, functionName, schemaName);

        try (PreparedStatement statement = getConnection(dbName).prepareStatement(query);
             ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                return resultSet.getString(1) + ";";
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
        }
        return null;
    }
}
