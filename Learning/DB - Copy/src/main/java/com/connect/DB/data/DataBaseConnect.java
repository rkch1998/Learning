package com.connect.DB.data;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DataBaseConnect {
    private static HikariDataSource dataSource;

    static {
        initializeDataSource();
    }

    private static void initializeDataSource(){
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://103.158.108.17:5432/1_CygnetGSPTenant_1");
        config.setUsername("CygGSPDBA");
        config.setPassword("Admin#321");

        config.setMaximumPoolSize(10);

        dataSource = new HikariDataSource(config);
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public static void close(){
        if(dataSource != null){
            dataSource.close();
        }
    }
}
