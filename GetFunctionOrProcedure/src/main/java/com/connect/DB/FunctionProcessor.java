package com.connect.DB;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class FunctionProcessor {
    private final QueryExecutor queryExecutor;
    private final FunctionWriter functionWriter;

    public FunctionProcessor(QueryExecutor queryExecutor, FunctionWriter functionWriter) {
        this.queryExecutor = queryExecutor;
        this.functionWriter = functionWriter;
    }

    public void processFunctionsFromFile(String inputFilePath, String outputFilePath, String dbName) {
        List<String> results = new ArrayList<>();
        try (BufferedReader reader = Files.newBufferedReader(Path.of(inputFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] result = parseFunction(line);
                if (result.length == 2) {
                    String schema = result[0];
                    String functionName = result[1].replaceAll("[\"\\[\\]]", "");
                    String queryResult = queryExecutor.executeQuery(dbName, schema, functionName);
                    if (queryResult != null) {
                        results.add(String.format("DROP FUNCTION IF EXISTS %s.\"%s\";\n", schema, functionName));
                        results.add(queryResult);
                    } else {
                        System.out.println("Error executing query for function: " + line + " - " + dbName);
                    }
                } else {
                    System.out.println("Invalid function name format: " + line + dbName);
                }
            }

            functionWriter.writeToFile(String.join("\n", results), outputFilePath);
        } catch (IOException e) {
            System.out.println("Error reading input file: " + e.getMessage());
        }
    }

    private String[] parseFunction(String function) {
        function = function.replace("\"", "");
        return function.split("\\.");
    }
}
