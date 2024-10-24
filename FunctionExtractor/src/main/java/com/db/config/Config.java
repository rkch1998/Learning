package com.db.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Configuration;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class Config {

    private Map<String, Map<String, Map<String, String>>> dbConfigs;

    @SuppressWarnings("unchecked")
    public Config() {
        String jsonFilePath = System.getProperty("db.credentials.file", "db_config.json");
        System.out.printf("Connecting with database.....\n");
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            dbConfigs = objectMapper.readValue(new File(jsonFilePath), HashMap.class);
        } catch (IOException e) {
            e.printStackTrace();
            dbConfigs = new HashMap<>();
        }
    }

    public Map<String, String[]> getDbConfigs(String profile, String dbName) {
        Map<String, String[]> config = new HashMap<>();
        if (dbConfigs.containsKey(profile) && dbConfigs.get(profile).containsKey(dbName)) {
            Map<String, String> dbConfig = dbConfigs.get(profile).get(dbName);
            config.put(dbName, new String[]{dbConfig.get("url"), dbConfig.get("username"), dbConfig.get("password")});
        }
        return config;
    }

}