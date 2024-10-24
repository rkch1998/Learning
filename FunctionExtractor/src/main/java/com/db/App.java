package com.db;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.Banner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;

import com.db.function.FunctionExtractor;
import com.db.util.Archiver;

import java.sql.SQLException;

@SpringBootApplication
public class App implements CommandLineRunner {

    @Autowired
    private FunctionExtractor functionProcessor;

    @Autowired
    private Archiver archive;
    
    @Autowired
    private Environment env;

    @Autowired
    private ApplicationContext appContext;
    
    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(App.class);
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

        System.setProperty("spring.profiles.active", profile);
        System.setProperty("db.credentials.file", jsonFilePath);
          
        archive.moveToArchive();

        functionProcessor.processFunctionsFromFile(inputFilePath, dbName, profile);

         // Shut down the application context (stopping the server)
         SpringApplication.exit(appContext, () -> 0);
    }

}