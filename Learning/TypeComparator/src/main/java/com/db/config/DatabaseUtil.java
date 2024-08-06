package com.db.config;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;

public class DatabaseUtil {

    public static DataSource createDataSource(JsonNode clientConfig) {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setUrl(String.format("jdbc:postgresql://%s:%d/%s",
                clientConfig.path("host").asText(),
                clientConfig.path("port").asInt(),
                clientConfig.path("database").asText()));
        dataSource.setUsername(clientConfig.path("user").asText());
        dataSource.setPassword(clientConfig.path("password").asText());
        return dataSource;
    }

}
