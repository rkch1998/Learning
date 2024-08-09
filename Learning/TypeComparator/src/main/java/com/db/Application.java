package com.db;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.Banner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.db.type.CompositeTypeService;
import com.db.util.FileArchive;

@SpringBootApplication
public class Application implements CommandLineRunner {

    @Autowired
    private CompositeTypeService compositeTypeService;

    @Autowired
    private FileArchive fileArchive;

    @Autowired
    private ApplicationArguments args;

    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(Application.class);
        app.setBannerMode(Banner.Mode.OFF);
        app.run(args);
        // SpringApplication.run(Application.class, args);
    }

    @Override
    public void run(String... args) {
        String environment = this.args.getOptionValues("env").get(0);
        if (environment == null || environment.isEmpty()) {
            throw new IllegalArgumentException("Environment must be specified with --env option.");
        }

        fileArchive.moveToArchive();
        compositeTypeService.compareAndExport(environment);
    }
}