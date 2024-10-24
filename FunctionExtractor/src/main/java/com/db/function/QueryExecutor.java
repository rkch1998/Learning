package com.db.function;

import java.sql.Connection;
import java.sql.SQLException;

import org.springframework.stereotype.Component;

@Component
public class QueryExecutor {


    public String executeQuery(Connection connection, String schemaName, String functionName, String profile) {

        //Selecting Query to get Function
        String query = "pg".equals(profile) ? Query.PG : Query.MS;
        
        if (connection == null) {
            return null;
        }
        
        try (var statement = connection.prepareStatement(String.format(query, schemaName, functionName));
             var resultSet = statement.executeQuery()) {
            if (resultSet.next()) {

                return "pg".equals(profile) ? resultSet.getString(1) + ";\n" : resultSet.getString(1);
                
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
        }
        return null;
    }
    
}
