package com.db.execution.function;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Autowired;

import com.db.execution.config.AppConfig;

@Component
public class GetFunctionName {
    @Autowired
    private AppConfig appConfig;

    public Map<String, String> getFunctionArguments(String filePath, String dbName){
        String functionName ="";
        try {
            // Read the file content into a String
            String content = new String(Files.readAllBytes(Paths.get(filePath)));
            
            // Use getFunctionName method
            functionName = getFunctionName(content);
            // System.out.println("Function name: " + functionName);
            
        } catch (IOException e) {
            System.err.println("Error reading the file: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            System.err.println("Error extracting function name: " + e.getMessage());
        }

        Map<String, String> argsMap = new HashMap<>();
        String[] strArray = functionName.split("\\.");
        String query = "SELECT n.nspname, p.proname, " +
               "pg_catalog.pg_get_function_identity_arguments(p.oid) AS fun_args " +
               "FROM pg_catalog.pg_proc p " +
               "JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace " +
               "WHERE n.nspname = ? AND p.proname = ? " +
               "ORDER BY 1";
        // System.out.println("Query: "+query);
        Connection connection = appConfig.getConnection(dbName);
        if (connection == null) {
            return null;
        }
        
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, strArray[0]);
            statement.setString(2, strArray[1]);
        
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String[] splitArgs = resultSet.getString("fun_args").split(",");
                    for (String arg : splitArgs) {
                        String[] argPair = arg.trim().split(" ");
                        argsMap.put(argPair[0], argPair[1]);
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
        }
        finally {
            appConfig.closeConnection(connection);
            // System.out.printf("Database Connection for %s is closed.\n", dbName[1]);
        }

        return argsMap;
    }

    public String getFunctionName(String str){
		Pattern pattern = Pattern.compile("\"(.*?)\"\\.\"(.*?)\"");
        Matcher matcher = pattern.matcher(str);

        if (matcher.find()) {
            String schemaName = matcher.group(1);
            String functionName = matcher.group(2);
            return schemaName + "." + functionName;
        } else {
            throw new IllegalArgumentException("Function name not found in the provided SQL string.");
        }
	}
    
    public Map<String, String> parseArguments(ResultSet resultSet) throws SQLException {
        Map<String, String> argsMap = new HashMap<>();
        Pattern pattern = Pattern.compile("(\\w+)=>([^,]+?)::(\\w+|character varying|character|smallint|integer|boolean|numeric|text|timestamp|date|json|jsonb|ARRAY\\w+|ARRAY\\w+\\[])");

        while (resultSet.next()) {
            String funArgs = resultSet.getString("fun_args");

            // Use a Matcher to find all matches for the pattern
            Matcher matcher = pattern.matcher(funArgs);

            while (matcher.find()) {
                String argName = matcher.group(1).trim();
                String argValue = matcher.group(2).trim();
                String dataType = matcher.group(3).trim();

                // Remove any leading or trailing quotes from the value if it's a string
                if (dataType.equals("character varying") || dataType.equals("character")) {
                    argValue = argValue.replaceAll("^'(.*)'$", "$1"); // Remove single quotes
                }

                // Store the argument and its type in the map
                argsMap.put(argName, dataType);
            }
        }

        return argsMap;
    }
}   

