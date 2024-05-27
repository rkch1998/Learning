package com.connect.DB;

import java.io.*;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.sql.*;
import java.util.*;

public class DbApplication {

	public static void main(String[] args) {

		if (args.length != 2) {
//			System.out.println("Usage: java DbApplication <inputFilePath> <outputFilePath> <dbName>");
			System.out.println("Usage: java DbApplication <inputFilePath> <dbName>");
			return;
		}

		String inputFilePath = args[0];
//		String outputFilePath = args[1];
		String dbName = args[1];

		try {
			// Load database configurations
			ConfigLoader configLoader = new ConfigLoader("dbconfig.properties");
			Map<String, String[]> dbConfigs = new HashMap<>();
			dbConfigs.put("master", new String[]{
					configLoader.getProperty("db.master.url"),
					configLoader.getProperty("db.master.username"),
					configLoader.getProperty("db.master.password")
			});
			dbConfigs.put("appdata", new String[]{
					configLoader.getProperty("db.appdata.url"),
					configLoader.getProperty("db.appdata.username"),
					configLoader.getProperty("db.appdata.password")
			});
			dbConfigs.put("tenant", new String[]{
					configLoader.getProperty("db.tenant.url"),
					configLoader.getProperty("db.tenant.username"),
					configLoader.getProperty("db.tenant.password")
			});
			dbConfigs.put("log", new String[]{
					configLoader.getProperty("db.log.url"),
					configLoader.getProperty("db.log.username"),
					configLoader.getProperty("db.log.password")
			});
			dbConfigs.put("admin", new String[]{
					configLoader.getProperty("db.admin.url"),
					configLoader.getProperty("db.admin.username"),
					configLoader.getProperty("db.admin.password")
			});

			// Initialize dependencies
			DatabaseExecutor databaseExecutor = new DatabaseExecutor(dbConfigs);
			FunctionWriter fileWriter = new FunctionWriter();
			FunctionProcessor functionProcessor = new FunctionProcessor(databaseExecutor, fileWriter);

			// Generate output file name
			String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
			String outputFileName = String.format("%s_%s.sql", dbName, timestamp);
			Path outputFilePath = Path.of(outputFileName);
			System.out.println("Path : " + outputFilePath);
			// Move existing file to archive if it exists
			moveToArchive();

			// Process functions from file
			functionProcessor.processFunctionsFromFile(inputFilePath, outputFilePath.toString(), dbName);
		} catch (SQLException e) {
			System.out.println("Error connecting to database: " + e.getMessage());
		}
	}

	private static void moveToArchive() {
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

	static class FunctionProcessor {
		private final DatabaseExecutor databaseOperations;
		private final FunctionWriter functionWriter;

		public FunctionProcessor(DatabaseExecutor databaseOperations, FunctionWriter functionWriter) {
			this.databaseOperations = databaseOperations;
			this.functionWriter = functionWriter;
		}

		public void processFunctionsFromFile(String inputFilePath, String outputFilePath, String dbName) {
			List<String> results = new ArrayList<>();
			try (BufferedReader reader = Files.newBufferedReader(Path.of(inputFilePath))) {
				String line;
				while ((line = reader.readLine()) != null) {
					String[] result = parseFunction(line);
					if (result.length == 2) {
						String schema = result[0];
						String functionName = result[1].replaceAll("\"", "");
						String queryResult = databaseOperations.executeQuery(dbName, schema, functionName);
						if (queryResult != null) {
							results.add(String.format("DROP FUNCTION IF EXISTS %s.\"%s\";\n", schema, functionName));
							results.add(queryResult);
						} else {
							System.out.println("Error executing query for function: " + line + " - " + dbName);
						}
					} else {
						System.out.println("Invalid function name format: " + line + dbName);
					}
				}

				functionWriter.writeToFile(String.join("\n", results), outputFilePath);
			} catch (IOException e) {
				System.out.println("Error reading input file: " + e.getMessage());
			}
		}

		private String[] parseFunction(String function) {
			function = function.replace("\"", "");
			return function.split("\\.");
		}
	}

	static class DatabaseExecutor {
		private final Map<String, Connection> connections = new HashMap<>();

		public DatabaseExecutor(Map<String, String[]> dbConfigs) throws SQLException {
			for (Map.Entry<String, String[]> entry : dbConfigs.entrySet()) {
				String dbName = entry.getKey();
				String[] config = entry.getValue();
				String url = config[0];
				String username = config[1];
				String password = config[2];
				connections.put(dbName, DriverManager.getConnection(url, username, password));
			}
		}

		public Connection getConnection(String dbName) {
			return connections.get(dbName);
		}

		public String executeQuery(String dbName, String schemaName, String functionName) {
			String query = String.format("""
                    SELECT pg_get_functiondef(oid)
                    FROM pg_proc
                    WHERE proname = '%s'
                    AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = '%s')
                    """, functionName, schemaName);

			try (PreparedStatement statement = getConnection(dbName).prepareStatement(query);
				 ResultSet resultSet = statement.executeQuery()) {
				if (resultSet.next()) {
					return resultSet.getString(1) + ";";
				}
			} catch (SQLException e) {
				System.out.println("Error executing query: " + e.getMessage());
			}
			return null;
		}
	}

	static class FunctionWriter {
		public void writeToFile(String content, String filePath) {
			try (BufferedWriter writer = Files.newBufferedWriter(Path.of(filePath))) {
				writer.write(content);
				writer.newLine();
				System.out.println("Data written to file successfully!");
			} catch (IOException e) {
				System.out.println("Error writing to file: " + e.getMessage());
			}
		}
	}

	static class ConfigLoader {
		private final Properties properties = new Properties();

		public ConfigLoader(String configFilePath) {
			try (InputStream input = getClass().getClassLoader().getResourceAsStream(configFilePath)) {
				if (input == null) {
					throw new IOException("Unable to find " + configFilePath);
				}
				properties.load(input);
			} catch (IOException e) {
				throw new RuntimeException("Failed to load properties file: " + e.getMessage(), e);
			}
		}

		public String getProperty(String key) {
			return properties.getProperty(key);
		}
	}
}
