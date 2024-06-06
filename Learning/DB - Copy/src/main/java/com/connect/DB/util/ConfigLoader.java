package com.connect.DB.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {
    private final Properties properties = new Properties();

    public ConfigLoader(String configFilePath){
        try(InputStream input = getClass().getClassLoader().getResourceAsStream(configFilePath)){
            if(input == null){
                throw new IOException("Unable to find " + configFilePath);
            }
            properties.load(input);
        }catch (IOException e){
            throw new RuntimeException("Failed to load properties file: " + e.getMessage(), e);
        }
    }

    public String getProperty(String key){
        return properties.getProperty(key);
    }
}
