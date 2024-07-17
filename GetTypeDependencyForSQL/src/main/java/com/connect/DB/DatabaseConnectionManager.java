package com.connect.DB;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Map;

public class DatabaseConnectionManager {
    private final Map<String, String[]> dbConfigs;
    private final String dbType;

    public DatabaseConnectionManager(Map<String, String[]> dbConfigs, String dbType) {
        this.dbConfigs = dbConfigs;
        this.dbType = dbType;
    }

    public Connection getConnection(String dbName) throws SQLException {
        String[] config = dbConfigs.get(dbName);
        String url = config[0];
        String username = config[1];
        String password = config[2];

        return switch (dbType) {
            case "pg", "sql" -> DriverManager.getConnection(url, username, password);
            default -> throw new IllegalArgumentException("Unsupported database type: " + dbType);
        };
    }
}
