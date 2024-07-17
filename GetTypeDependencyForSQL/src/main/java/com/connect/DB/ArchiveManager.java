package com.connect.DB;

import java.io.IOException;
import java.nio.file.*;

public class ArchiveManager {
    public static void moveToArchive() {
        try {
            Path currentDir = Path.of(".");
            Path archiveDir = Path.of("archive");
            Files.createDirectories(archiveDir);

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
