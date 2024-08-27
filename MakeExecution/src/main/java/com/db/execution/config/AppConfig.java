package com.db.execution.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Map;

@Component
public class AppConfig {

    @Autowired
    private DatabaseUtil databaseUtil;

    @Autowired
    private Environment env;

    public Connection getConnection(String dbName) {
        String profile = env.getProperty("spring.profiles.active");
        // System.out.println("Profile: " + profile);
        
        Map<String, String[]> dbConfig = databaseUtil.getDbConfigs(profile, dbName);
        // System.out.println("Connection: "+dbConfig.get(dbName));
        if (dbConfig.isEmpty()) {
            System.out.println("No configuration found for database: " + dbName);
            return null;
        }

        String[] config = dbConfig.get(dbName);
        String url = config[0];
        String username = config[1];
        String password = config[2];

        try {
            return DriverManager.getConnection(url, username, password);
        } catch (SQLException e) {
            System.out.println("Error connecting to database: " + e.getMessage());
            return null;
        }
    }

    public void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.out.println("Error closing connection: " + e.getMessage());
            }
        }
    }

}