package com.db.util;

import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

import org.springframework.stereotype.Component;

@Component
public class FileArchive {

    public void moveToArchive() {
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
