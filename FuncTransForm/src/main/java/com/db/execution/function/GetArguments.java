package com.db.execution.function;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
// import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;

import com.db.execution.config.AppConfig;
import org.springframework.stereotype.Component;

@Component
public class GetArguments {
    @Autowired
    private AppConfig appConfig;

    @Autowired
    private GetName getName;

    public LinkedHashMap<String, String> getFunctionArguments(String filePath, String dbName){
        String functionName ="";
        try {
            // Read the file content into a String
            String content = new String(Files.readAllBytes(Paths.get(filePath)));
            
            // Use getFunctionName method
            functionName = getName.getFunctionName(content);
            // System.out.println("Function name: " + functionName);
            
        } catch (IOException e) {
            System.err.println("Error reading the file: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            System.err.println("Error extracting function name: " + e.getMessage());
        }

        LinkedHashMap<String, String> argsMap = new LinkedHashMap<>();
        String[] strArray = functionName.split("\\.");
        
        Connection connection = appConfig.getConnection(dbName);
        if (connection == null) {
            return null;
        }
        
        try (PreparedStatement statement = connection.prepareStatement(Query.query)) {
            
            statement.setString(1, strArray[0]);
            statement.setString(2, strArray[1]);
        
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String[] splitArgs = resultSet.getString("fun_args").split(",");
                    // System.out.println(Arrays.toString(splitArgs));
                    for (String arg : splitArgs) {
                        String[] argPair = arg.trim().split(" ", 2);
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

}
