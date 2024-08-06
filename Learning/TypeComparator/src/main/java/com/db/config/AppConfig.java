package com.db.config;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.File;
import java.io.IOException;

@Configuration
public class AppConfig {

    @Bean
    public JsonNode config() throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readTree(new File("database-config.json"));
    }
}
