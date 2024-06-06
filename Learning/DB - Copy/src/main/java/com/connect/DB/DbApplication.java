package com.connect.DB;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import com.connect.DB.data.DatabaseExecutor;
import com.connect.DB.service.FunctionProcessor;
import com.connect.DB.util.ConfigLoader;
import com.connect.DB.util.FunctionWriter;

public class DbApplication {

	public static void main(String[] args) {

		if (args.length != 3) {
			System.out.println("Usage: java DbApplication <inputFilePath> <outputFilePath> <dbName>");
			return;
		}

		String inputFilePath = args[0];
		String outputFilePath = args[1];
		String dbName = args[2];

		try {
			// Load database configurations
			ConfigLoader configLoader = new ConfigLoader("dbconfig.properties");
			Map<String, String[]> dbConfigs = new HashMap<>();
			dbConfigs.put("master", new String[] {
					configLoader.getProperty("db.master.url"),
					configLoader.getProperty("db.master.username"),
					configLoader.getProperty("db.master.password")
			});
			dbConfigs.put("appdata", new String[] {
					configLoader.getProperty("db.appdata.url"),
					configLoader.getProperty("db.appdata.username"),
					configLoader.getProperty("db.appdata.password")
			});
			dbConfigs.put("tenant", new String[] {
					configLoader.getProperty("db.tenant.url"),
					configLoader.getProperty("db.tenant.username"),
					configLoader.getProperty("db.tenant.password")
			});

			// Initialize dependencies
			DatabaseExecutor databaseExecutor = new DatabaseExecutor(dbConfigs);
			FunctionWriter fileWriter = new FunctionWriter();
			FunctionProcessor functionProcessor = new FunctionProcessor(databaseExecutor, fileWriter);

			// Example function to process
//			String inputFilePath = "function.txt";
//			String outputFilePath = "result.txt";
//			String dbName = "master";  // Specify the database name to use
			functionProcessor.processFunctionsFromFile(inputFilePath, outputFilePath, dbName);
		} catch (SQLException e) {
			System.out.println("Error connecting to database: " + e.getMessage());
		}
	}


}
