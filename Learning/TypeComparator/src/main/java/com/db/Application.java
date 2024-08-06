package com.db;


import org.springframework.beans.factory.annotation.Autowired;
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

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Override
    public void run(String... args) {
        fileArchive.moveToArchive();
        compositeTypeService.compareAndExport();
    }

}