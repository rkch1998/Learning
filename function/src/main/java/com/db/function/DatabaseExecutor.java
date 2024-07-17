package com.db.function;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import jakarta.annotation.PostConstruct;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@Component
public class DatabaseExecutor {
    private final Map<String, Connection> connections = new HashMap<>();
    
    @Autowired
    private Environment env;

    @Autowired
    private DbConfigProperties dbConfigProperties;

    @PostConstruct
    public void init() {
        initializeConnections();
    }

    private void initializeConnections() {
        try {
            Map<String, String[]> dbConfigs = dbConfigProperties.getDbConfigs(null);
            for (Map.Entry<String, String[]> entry : dbConfigs.entrySet()) {
                String dbName = entry.getKey();
                String[] config = entry.getValue();
                String url = config[0];
                String username = config[1];
                String password = config[2];
                System.out.printf("Initializing connection for: %s with URL: %s, Username: %s%n", dbName, url, username);
                connections.put(dbName, DriverManager.getConnection(url, username, password));
            }
        } catch (SQLException e) {
            System.out.println("Error initializing database connections: " + e.getMessage());
        }
    }

    public Connection getConnection(String dbName) {
        Connection conn = connections.get(dbName);
        if (conn == null || isConnectionClosed(conn)) {
            System.out.println("Re-establishing connection for database: " + dbName);
            reinitializeConnection(dbName);
            conn = connections.get(dbName); // Get the new connection
        }
        System.out.println("Establishing connection for database: " + dbName);
        return conn;
    }

    private boolean isConnectionClosed(Connection conn) {
        try {
            return conn.isClosed();
        } catch (SQLException e) {
            return true; // Assume closed if there's an error
        }
    }

    private void reinitializeConnection(String dbName) {
        try {
            Map<String, String[]> dbConfigs = dbConfigProperties.getDbConfigs(dbName);
            String[] config = dbConfigs.get(dbName);
            String url = config[0];
            String username = config[1];
            String password = config[2];
            connections.put(dbName, DriverManager.getConnection(url, username, password));
            System.out.printf("Reinitialized connection for: %s%n", dbName);
        } catch (SQLException e) {
            System.out.println("Error re-establishing database connection: " + e.getMessage());
        }
    }

    public String executeQuery(String dbName, String schemaName, String functionName) {
        String profile = env.getProperty("spring.profiles.active");
        String query = "";

        if ("pg".equals(profile)) {
            query = String.format("""
                SELECT pg_get_functiondef(oid)
                FROM pg_proc
                WHERE proname = '%s'
                AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = '%s')
                """, functionName, schemaName);
        } else { // SQL Server Query
            query = String.format("SELECT OBJECT_DEFINITION (OBJECT_ID('%s.%s'))", schemaName, functionName);
        }

        try (var statement = getConnection(dbName).prepareStatement(query);
             var resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                return resultSet.getString(1) + ";";
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
        }
        return null;
    }
}