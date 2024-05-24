package org.connect.util;

import org.springframework.stereotype.Component;

import java.io.BufferedWriter;
import java.io.IOException;

@Component
public class SqlFileWriter {

    public void writeToFile(String content, String filePath, String schema, String functionName) {
        try (BufferedWriter writer = new BufferedWriter(new java.io.FileWriter(filePath, true))) {
            String dropFunction = String.format("DROP FUNCTION IF EXISTS %s.\"%s\";", schema, functionName);
            writer.write(dropFunction);
            writer.newLine();
            writer.write(content);
            writer.newLine();
            System.out.println("Written Successfully");
        } catch (IOException e) {
            System.out.println("Error occurred while writing the file: " + e.getMessage());
        }
    }
}
