package com.connect.DB;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class FunctionWriter {
    public void writeToFile(String content, String filePath) {
        try (BufferedWriter writer = Files.newBufferedWriter(Path.of(filePath))) {
            writer.write(content);
            writer.newLine();
        } catch (IOException e) {
            System.out.println("Error writing to file: " + e.getMessage());
        }
    }
}
