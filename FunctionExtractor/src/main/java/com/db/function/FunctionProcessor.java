package com.db.function;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Component
public class FunctionProcessor {


    @Autowired
    private Environment env;

    @Autowired
    private QueryFormation queryFormation;

    @Autowired
    private final FunctionWriter functionWriter;

    public FunctionProcessor(FunctionWriter functionWriter) {
        this.functionWriter = functionWriter;
    }

    public void processFunctionsFromFile(String inputFilePath, String dbName) {
        List<String> results = new ArrayList<>();
        String profile = env.getProperty("spring.profiles.active");

        try (BufferedReader reader = Files.newBufferedReader(Path.of(inputFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] result = parseFunction(line);
                if (result.length == 2) {
                    String schema = result[0];
                    String functionName = result[1].replaceAll("\"", "");
                    String queryResult = queryFormation.executeQuery(dbName, schema, functionName);
                    if (queryResult != null) {
                        if ("pg".equals(profile)) {
                            results.add(String.format("DROP FUNCTION IF EXISTS %s.\"%s\";\n", schema, functionName));
                            results.add(queryResult);
                        } else {
                            results.add(String.format("DROP PROCEDURE IF EXISTS [%s].[%s];\nGO\n\n", schema, functionName));
                            results.add(String.format("%s\nGO\n\n", queryResult));
                        }
                    } else {
                        // System.out.println("Error executing query for function: " + line + " - " + queryResult);

                        System.out.println("Error executing query for function: " + line + " - " + dbName);
                    }
                } else {
                    System.out.println("Invalid function name format: " + line + " - " + dbName);
                }
            }

            functionWriter.writeToFile(String.join("\n", results), dbName);
        } catch (IOException e) {
            System.out.println("Error reading input file: " + e.getMessage());
        }
    }

    private String[] parseFunction(String function) {
        function = function.replace("\"\\[\\]", "");
        return function.split("\\.");
    }
}