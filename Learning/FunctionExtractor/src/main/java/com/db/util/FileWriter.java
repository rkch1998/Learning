package com.db.util;

import org.springframework.stereotype.Component;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.Date;

@Component
public class FileWriter {

    public void writeToFile(String content, String dbName) {
        String outputFileName = generateFileName(dbName);
        try (BufferedWriter writer = Files.newBufferedWriter(Path.of(outputFileName))) {
            writer.write(content);
            writer.newLine();
            System.out.println("Data written to file successfully!");
        } catch (IOException e) {
            System.out.println("Error writing to file: " + e.getMessage());
        }
    }

    public String generateFileName(String dbName) {
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String outputFileName = String.format("%s_%s.sql", dbName, timestamp);
        // Path outputFilePath = Path.of(outputFileName);
        System.out.println("Output file path: " + outputFileName);
        return outputFileName;
        
    }

}