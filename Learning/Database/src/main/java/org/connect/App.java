package org.connect;

import org.connect.data.FunctionProcessor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class App implements CommandLineRunner {

    @Autowired
    private FunctionProcessor functionProcessor;

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    public void run(String... args) {
        if (args.length != 2) {
            System.out.println("Usage: java -jar <jar-file> <input-file> <output-file>");
            System.exit(1);
        }

        String inputFilePath = args[0];
        String outputFilePath = args[1];
        functionProcessor.processFunctionsFromFile(inputFilePath, outputFilePath);
    }
}