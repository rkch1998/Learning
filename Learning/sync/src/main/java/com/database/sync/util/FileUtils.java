package com.database.sync.util;

import com.database.sync.model.UserDefinedType;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FileUtils {

    public static List<UserDefinedType> readSchemaAndTypeNames(String filePath) throws IOException {
        List<UserDefinedType> udtList = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split("\\.");
                if (parts.length == 2) {
                    udtList.add(new UserDefinedType(parts[0], parts[1].replace("\"", "")));
                }
            }
        }
        return udtList;
    }
}
