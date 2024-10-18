package com.db.execution.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class LineCounter {
    
    public static int countLines(String filePath) throws IOException{
        int lineCount = 0;
        try(BufferedReader reader = new BufferedReader(new FileReader(filePath))){
            while (reader.readLine() != null){
                lineCount++;
            }
        }
        return lineCount;
    }
}
