package com.db.function;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.db.config.Connect;
import com.db.util.FileWriter;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

@Component
public class FunctionExtractor {

    @Autowired
    private QueryExecutor queryFormation;

    @Autowired
    private FileWriter functionWriter;
 
    @Autowired
    private Connect databaseExecutor;

    public void processFunctionsFromFile(String inputFilePath, String dbName, String profile) {
        List<String> results = new ArrayList<>();

        if(!"pg".equals(profile)){
            results.add("SET ANSI_NULLS ON\r\n" + //
                                "GO\r\n" + //
                                "\r\n" + //
                                "SET QUOTED_IDENTIFIER ON\r\n" + //
                                "GO\r\n");
        }

        // String profile = env.getProperty("spring.profiles.active");

        Connection connection = databaseExecutor.getConnection(dbName);

        System.out.printf("%s Database Connected.\n", dbName);

        try (BufferedReader reader = Files.newBufferedReader(Path.of(inputFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] result = parseFunction(line);
                if (result.length == 2) {
                    String schema = result[0];
                    String functionName = result[1];
                    String queryResult = queryFormation.executeQuery(connection, schema, functionName, profile);
                    if (queryResult != null) {
                        concateDropAndBodyStatement(results, profile, schema, functionName, queryResult);
                    } else {
                        
                        System.out.println("Error executing query for function: " + line + " - " + dbName);
                    }
                } else {
                    System.out.println("Invalid function name format: " + line + " - " + dbName);
                }
            }

            functionWriter.writeToFile(String.join("\n", results), dbName);
        } catch (IOException e) {
            System.out.println("Error reading input file: " + e.getMessage());
        } finally {
            databaseExecutor.closeConnection(connection);
            System.out.printf("%s Database is Closed.\n", dbName);
        }
    }

    private void concateDropAndBodyStatement(List<String> results, String profile, String schema, String functionName,
            String queryResult) {
        if ("pg".equals(profile)) {
            results.add(String.format("DROP FUNCTION IF EXISTS %s.\"%s\";\n", schema.trim(), functionName.trim()));
            results.add(String.format("%s;\n", queryResult.trim()));
        } else {
            results.add(String.format("DROP PROCEDURE IF EXISTS [%s].[%s]\nGO\n", schema.trim(), functionName.trim()));
            results.add(String.format("%s\nGO\n", queryResult.trim()));
        }
    }

    private String[] parseFunction(String function) {
        function = function.replaceAll("\"", "");
        function = function.replaceAll("\\]", "");
        function = function.replaceAll("\\[", "");
        function = function.trim();
        return function.split("\\.");
    }
}