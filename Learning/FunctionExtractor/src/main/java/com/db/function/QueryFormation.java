package com.db.function;

import java.sql.Connection;
import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import com.db.config.DatabaseExecutor;

@Component
public class QueryFormation {
    
    @Autowired
    private Environment env;    
 
    @Autowired
    private DatabaseExecutor databaseExecutor;

    public String executeQuery(String dbProfile, String schemaName, String functionName) {
        String[] dbName = dbProfile.split("_");
        String profile = env.getProperty("spring.profiles.active");
        String query = "";

        if ("pg".equals(profile)) {
            query = String.format("""
                SELECT pg_get_functiondef(oid)
                FROM pg_proc
                WHERE proname = '%s'
                AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = '%s')
                """, functionName.trim(), schemaName.trim());
        } else { // SQL Server Query
            query = String.format("SELECT OBJECT_DEFINITION (OBJECT_ID('%s.%s'))", schemaName.trim(), functionName.trim());
        }

        Connection connection = databaseExecutor.getConnection(dbName[1]);
        if (connection == null) {
            return null;
        }
        System.out.printf("Database Connection for %s is connected.\n", dbName[1]);
        try (var statement = connection.prepareStatement(query);
             var resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                return resultSet.getString(1) + ";";
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
        } finally {
            databaseExecutor.closeConnection(connection);
            System.out.printf("Database Connection for %s is closed.\n", dbName[1]);
        }
        return null;
    }
    
}
