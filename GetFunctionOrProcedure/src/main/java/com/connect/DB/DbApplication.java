package com.connect.DB;

import java.io.*;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.*;

public class DbApplication {

    public static void main(String[] args) {

        if (args.length != 3) {
            System.out.println("Usage: java DbApplication <inputFilePath> <dbType> <dbName>" + args[0] +","+ args[1] +","+ args[2] +","+ args[3]);
            return;
        }

        String inputFilePath = args[0];
        String dbType = args[1].toLowerCase();
        String dbName = args[2];

        try {
            FunctionProcessor functionProcessor = getFunctionProcessor(dbType);

            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String outputFileName = String.format("%s_%s.sql", dbName, timestamp);
            Path outputFilePath = Path.of(outputFileName);
//            System.out.println("Path : " + outputFilePath);

            ArchiveManager.moveToArchive();

            functionProcessor.processFunctionsFromFile(inputFilePath, outputFilePath.toString(), dbName);
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private static FunctionProcessor getFunctionProcessor(String dbType) {
        ConfigLoader configLoader = new ConfigLoader("dbconfig.properties");
        Map<String, String[]> dbConfigs = configLoader.loadDbConfigs(dbType);

        DatabaseConnectionManager connectionManager = new DatabaseConnectionManager(dbConfigs, dbType);
        QueryExecutor queryExecutor = new QueryExecutor(connectionManager, dbType);
        FunctionWriter functionWriter = new FunctionWriter();

        FunctionProcessor functionProcessor;
        functionProcessor = new FunctionProcessor(queryExecutor, functionWriter);
        return functionProcessor;
    }
}
