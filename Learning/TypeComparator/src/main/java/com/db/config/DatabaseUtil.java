package com.db.config;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class DatabaseUtil {

    // private static SshTunnel sshTunnelUtil = new SshTunnel();

    public static DataSource createDataSource(JsonNode clientConfig) {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");

        String host = clientConfig.path("host").asText();
        int port = clientConfig.path("port").asInt();
        String database = clientConfig.path("database").asText();
        String user = clientConfig.path("user").asText();
        String password = clientConfig.path("password").asText();

        // if (clientConfig.path("is_ssh_required").asBoolean(false)) {
            
        //     try {
        //         SshTunnelUtil.setupSshTunnel(clientConfig);
        //     } catch (Exception e) {
        //         e.printStackTrace();
        //         throw new RuntimeException("Failed to setup SSH tunnel again", e);
        //     }
        // }

        dataSource.setUrl(String.format("jdbc:postgresql://%s:%d/%s", host, port, database));
        dataSource.setUsername(user);
        dataSource.setPassword(password);

        return dataSource;
    }

    public static void closeDataSource(DataSource dataSource) {
        if (dataSource instanceof DriverManagerDataSource) {
            try {
                Connection conn = dataSource.getConnection();
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // public static void closeSshTunnel() {
    //     sshTunnelUtil.closeSshTunnel();
    // }

}
