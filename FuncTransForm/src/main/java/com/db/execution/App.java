package com.db.execution;

import java.util.Map;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

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
			String transformedSql = getFun.transformSqlQuery(content, arguments);
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
}

