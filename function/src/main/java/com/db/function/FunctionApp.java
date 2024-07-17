package com.db.function;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.env.Environment;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;

@SpringBootApplication
public class FunctionApp implements CommandLineRunner {

    @Autowired
    private Environment env;

    @Autowired
    private FunctionProcessor functionProcessor;


    
    public static void main(String[] args) {
        SpringApplication.run(FunctionApp.class, args);
    }

    

    @Override
    public void run(String... args) throws SQLException {
        String activeProfile = env.getProperty("spring.profiles.active");
        System.out.println("Active profile: " + activeProfile);
        
        if (args.length != 3) {
            System.out.println("Usage: java FunctionApp <inputFilePath> <dbName> <profile>");
            return;
        }

        String inputFilePath = args[1];
        String dbName = args[2];
        String profile = args[0];

        // String inputFilePath = "D:\\Learn\\function\\functions.txt";
        // String dbName = "tenant";
        // String profile = "sql";

        System.out.printf("Arguments received: inputFilePath=%s, dbName=%s, profile=%s%n", inputFilePath, dbName, profile);
        System.setProperty("spring.profiles.active", profile);
        System.out.println("Active profile: " + activeProfile);
        
        
        moveToArchive();

        functionProcessor.processFunctionsFromFile(inputFilePath, dbName);
    }

    private void moveToArchive() {
        try {
            Path currentDir = Path.of(".");
            Path archiveDir = Path.of("archive");
            if (!Files.exists(archiveDir)) {
                Files.createDirectories(archiveDir);
            }

            DirectoryStream.Filter<Path> filter = entry -> entry.toString().endsWith(".sql");
            try (DirectoryStream<Path> stream = Files.newDirectoryStream(currentDir, filter)) {
                for (Path entry : stream) {
                    Path archiveFilePath = archiveDir.resolve(entry.getFileName());
                    Files.move(entry, archiveFilePath, StandardCopyOption.REPLACE_EXISTING);
                    System.out.println("Moved file to archive: " + archiveFilePath);
                }
            }
        } catch (IOException e) {
            System.out.println("Error moving files to archive: " + e.getMessage());
        }
    }
}