package com.connect.DB;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class ConfigLoader {
    private final Properties properties = new Properties();

    public ConfigLoader(String configFilePath) {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream(configFilePath)) {
            if (input == null) {
                throw new IOException("Unable to find " + configFilePath);
            }
            properties.load(input);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load properties file: " + e.getMessage(), e);
        }
    }

    public Map<String, String[]> loadDbConfigs(String dbType) {
        Map<String, String[]> dbConfigs = new HashMap<>();
        if (dbType.equals("sql")) {
            dbConfigs.put("master", new String[]{
                    properties.getProperty("sql.master.url"),
                    properties.getProperty("sql.master.username"),
                    properties.getProperty("sql.master.password")
            });
            dbConfigs.put("appdata", new String[]{
                    properties.getProperty("sql.appdata.url"),
                    properties.getProperty("sql.appdata.username"),
                    properties.getProperty("sql.appdata.password")
            });
            dbConfigs.put("tenant", new String[]{
                    properties.getProperty("sql.tenant.url"),
                    properties.getProperty("sql.tenant.username"),
                    properties.getProperty("sql.tenant.password")
            });
            dbConfigs.put("log", new String[]{
                    properties.getProperty("sql.log.url"),
                    properties.getProperty("sql.log.username"),
                    properties.getProperty("sql.log.password")
            });
            dbConfigs.put("admin", new String[]{
                    properties.getProperty("sql.admin.url"),
                    properties.getProperty("sql.admin.username"),
                    properties.getProperty("sql.admin.password")
            });
        } else if (dbType.equals("pg")) {
            dbConfigs.put("master", new String[]{
                    properties.getProperty("pg.master.url"),
                    properties.getProperty("pg.master.username"),
                    properties.getProperty("pg.master.password")
            });
            dbConfigs.put("appdata", new String[]{
                    properties.getProperty("pg.appdata.url"),
                    properties.getProperty("pg.appdata.username"),
                    properties.getProperty("pg.appdata.password")
            });
            dbConfigs.put("tenant", new String[]{
                    properties.getProperty("pg.tenant.url"),
                    properties.getProperty("pg.tenant.username"),
                    properties.getProperty("pg.tenant.password")
            });
            dbConfigs.put("log", new String[]{
                    properties.getProperty("pg.log.url"),
                    properties.getProperty("pg.log.username"),
                    properties.getProperty("pg.log.password")
            });
            dbConfigs.put("admin", new String[]{
                    properties.getProperty("pg.admin.url"),
                    properties.getProperty("pg.admin.username"),
                    properties.getProperty("pg.admin.password")
            });
    }
    else {
            System.out.println( "database type: " + dbType.equals("pg"));
//            System.out.println("Unsupported database type: " + dbType);
    }
        return dbConfigs;
    }
}
