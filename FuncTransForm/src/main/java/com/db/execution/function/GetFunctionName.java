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
import com.db.execution.util.DateTimeFormat;

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
        // String query = "SELECT n.nspname, p.proname, " +
        //        "pg_catalog.pg_get_function_identity_arguments(p.oid) AS fun_args " +
        //        "FROM pg_catalog.pg_proc p " +
        //        "JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace " +
        //        "WHERE n.nspname = ? AND p.proname = ? " +
        //        "ORDER BY 1";
        // System.out.println("Query: "+query);
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

    public String transformSqlQuery(String sql, Map<String, String> arguments) {
		for (Map.Entry<String, String> entry : arguments.entrySet()) {
			String argumentName = entry.getKey();
			String dataType = entry.getValue();
	
			// Regex to match the argument with or without array/JSON structure
			String regex = String.format("%s=>(\\{.*?\\}|\\[.*?\\]|'''(.*?)'''|'[^']*'|[^,\\)]+)", argumentName);
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(sql);
	
			while (matcher.find()) {
				String matchedValue = matcher.group(1);
				// System.out.println("machedValue: "+matchedValue);
				String replacement;
	
				// Check if the matched value is an array or JSON structure (starts with '[')
				if ((matchedValue.startsWith("[{") && matchedValue.endsWith("}]"))) {
					// Wrap the matched value with ARRAY and apply the data type casting
					String dtype = dataType.replaceAll("\\[\\]", "");
					// System.out.println("True");
					replacement = String.format("%s=>ARRAY(SELECT json_populate_recordset(null ::%s,'%s'))", argumentName, dtype, matchedValue);
				} else if((matchedValue.startsWith("{") && matchedValue.endsWith("}"))){
					replacement = String.format("%s=>(SELECT json_populate_recordset(null ::%s,'[%s]'))", argumentName, dataType, matchedValue);
				} 
				else if (matchedValue.startsWith("[") && matchedValue.endsWith("]")) {
					// Wrap the matched value with ARRAY and apply the data type casting
					replacement = String.format("%s=>ARRAY%s::%s", argumentName, matchedValue, dataType);
				} else if (matchedValue.startsWith("'") && matchedValue.endsWith("'")) {
                    //checking for date possibility
                    if(matchedValue.contains("-")){
                        //converting date format from 'dd-MM-yyyy' to 'yyyy-MM-dd'
                        String formattedDate = DateTimeFormat.dateTimeFormat(matchedValue);

                        //If date convertion is successful, apply TIMESTAMP casting
                        if(formattedDate != null){
                            // Apply the data type casting as TIMESTAMP WITHOUT TIME ZONE
                            replacement = String.format("%s=>'%s'::TIMESTAMP WITHOUT TIME ZONE", argumentName, formattedDate);
                        } else {
                            // If date conversion fails, handle it as a normal VARCHAR type
                            matchedValue = matchedValue.substring(1, matchedValue.length() - 1);
                            replacement = String.format("%s=>'%s'::VARCHAR", argumentName, matchedValue);
                        }
                    }else{
                        // Remove the surrounding single quotes for proper SQL syntax
                        matchedValue = matchedValue.substring(1, matchedValue.length() - 1);
                        // Apply the data type casting as VARCHAR
                        replacement = String.format("%s=>'%s'::VARCHAR", argumentName, matchedValue);
                    }
				} else {
					// Apply the data type casting without ARRAY
					replacement = String.format("%s=>%s::%s", argumentName, matchedValue, dataType);
				}
	
				// Replace the original argument with the transformed value
				sql = sql.replace(matcher.group(0), replacement);
			}
		}
		return sql;
	}
	
}   

