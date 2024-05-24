package org.connect.data;

import org.connect.util.SqlFileWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

@Service
public class FunctionProcessor {

    private final DatabaseExecutor databaseExecutor;
    private final SqlFileWriter sqlFileWriter;

    @Autowired
    public FunctionProcessor(DatabaseExecutor databaseExecutor, SqlFileWriter sqlFileWriter) {
        this.databaseExecutor = databaseExecutor;
        this.sqlFileWriter = sqlFileWriter;
    }

    public void processFunctionsFromFile(String inputFilePath, String outputFilePath) {
        try (BufferedReader reader = new BufferedReader(new FileReader(inputFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] result = line.split("\\.");
                if (result.length == 2) {
                    String schema = result[0];
                    String functionName = result[1].replaceAll("\"", "");
                    String queryResult = databaseExecutor.executeQuery(schema, functionName);
                    if (queryResult != null) {
                        sqlFileWriter.writeToFile(queryResult, outputFilePath, schema, functionName);
                    } else {
                        System.out.println("Error executing query for " + line);
                    }
                } else {
                    System.out.println("Invalid function name format: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
