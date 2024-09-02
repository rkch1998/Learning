package com.db.execution;

import java.util.Map;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.context.ApplicationContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.Banner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.env.Environment;

import com.db.execution.function.GetFunctionName;
import com.db.execution.util.FileArchive;
import com.db.execution.util.FileWriter;

@SpringBootApplication
public class App implements CommandLineRunner {

	@Autowired
	private GetFunctionName getFun;

	@Autowired
	private FileArchive fileArchive;

	@Autowired
	private FileWriter fileWriter;

	@Autowired
	private Environment env;

	@Autowired
    private ApplicationContext context;

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(App.class);
        app.setBannerMode(Banner.Mode.OFF);
        app.run(args);
	}

	@Override
	public void run(String... args){
		if (args.length != 2) {
			//java -jar build/libs/function-0.0.1-SNAPSHOT.jar --spring.profiles.active=pg tenant
            System.out.println("Usage: java -jar build/libs/function-0.0.1-SNAPSHOT.jar <profile> <dbName>");
            return;
        }
        String dbName = args[1].toLowerCase();
        String inputFilePath = "functions.txt";
        String jsonFilePath = "database-config.json";
        String profile =  env.getProperty("spring.profiles.active");

        System.setProperty("spring.profiles.active", profile);
        System.out.printf("Getting the DB credencials.\n");
        System.setProperty("db.credentials.file", jsonFilePath);
		
		Map<String, String> arguments = getFun.getFunctionArguments(inputFilePath, dbName);
		
		String content;
		try {
			content = new String(Files.readAllBytes(Paths.get(inputFilePath)));
			String transformedSql = transformSqlQuery(content, arguments);
			// System.out.println(transformedSql);
			fileArchive.moveToArchive();
			fileWriter.writeToFile(transformedSql, dbName);
		} catch (IOException e) {
			System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
		}
        // shutdown
        System.exit(SpringApplication.exit(context, () -> 0));
	}

	public String transformSqlQuery(String sql, Map<String, String> arguments) {
		for (Map.Entry<String, String> entry : arguments.entrySet()) {
			String argumentName = entry.getKey();
			String dataType = entry.getValue();
	
			// Regex to match the argument with or without array/JSON structure
			String regex = String.format("%s=>(\\{.*?\\}|\\[.*?\\]|'[^']*'|[^,\\)]+)", argumentName);
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(sql);
	
			while (matcher.find()) {
				String matchedValue = matcher.group(1);
				// System.out.println("machedValue: "+matchedValue);
				String replacement;
	
				// Check if the matched value is an array or JSON structure (starts with '[')
				if ((matchedValue.startsWith("[{") && matchedValue.endsWith("}]"))) {
					// Wrap the matched value with ARRAY and apply the data type casting
					String dtype = dataType.replaceAll("\\[\\]", "");
					// System.out.println("True");
					replacement = String.format("%s=>ARRAY(SELECT json_populate_recordset(null ::%s,'%s'))", argumentName, dtype, matchedValue);
				} else if((matchedValue.startsWith("{") && matchedValue.endsWith("}"))){
					replacement = String.format("%s=>(SELECT json_populate_recordset(null ::%s,'[%s]'))", argumentName, dataType, matchedValue);
				} 
				else if (matchedValue.startsWith("[") && matchedValue.endsWith("]")) {
					// Wrap the matched value with ARRAY and apply the data type casting
					replacement = String.format("%s=>ARRAY%s::%s", argumentName, matchedValue, dataType);
				} else if (matchedValue.startsWith("'") && matchedValue.endsWith("'")) {
					// Remove the surrounding single quotes for proper SQL syntax
					matchedValue = matchedValue.substring(1, matchedValue.length() - 1);
					// Apply the data type casting as VARCHAR
					replacement = String.format("%s=>'%s'::VARCHAR", argumentName, matchedValue);
				} else {
					// Apply the data type casting without ARRAY
					replacement = String.format("%s=>%s::%s", argumentName, matchedValue, dataType);
				}
	
				// Replace the original argument with the transformed value
				sql = sql.replace(matcher.group(0), replacement);
			}
		}
		return sql;
	}
	
}

