package com.db.function;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.Banner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import java.sql.SQLException;

@SpringBootApplication
public class FunctionApp implements CommandLineRunner {

    @Autowired
    private FunctionProcessor functionProcessor;

    @Autowired
    private FileArchive archive;
    
    @Autowired
    private Environment env;

    @Autowired
    private ApplicationContext appContext;
    
    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(FunctionApp.class);
        app.setBannerMode(Banner.Mode.OFF);
        app.run(args);
    }

    @Override
    public void run(String... args) throws SQLException {

        if (args.length != 2) {
            System.out.println("Usage: java FunctionApp <inputFilePath> <dbName> <profile>");
            return;
        }

        
        String dbName = args[1].toLowerCase();
        String inputFilePath = "functions.txt";
        String jsonFilePath = "db_config.json";
        String profile =  env.getProperty("spring.profiles.active");

        @SuppressWarnings("null")
        String dbProfile = profile.concat("_").concat(dbName);

        System.setProperty("spring.profiles.active", profile);
        System.out.printf("Getting the DB credencials.\n");
        System.setProperty("db.credentials.file", jsonFilePath);
          
        archive.moveToArchive();

        functionProcessor.processFunctionsFromFile(inputFilePath, dbProfile);

         // Shut down the application context (stopping the server)
         SpringApplication.exit(appContext, () -> 0);
    }

}