package com.db.config;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class DatabaseUtil {

    private static final int LOCAL_PORT = 5433; 
    private static SshTunnelUtil sshTunnelUtil = new SshTunnelUtil();

    public static DataSource createDataSource(JsonNode clientConfig) {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");

        String host = clientConfig.path("host").asText();
        int port = clientConfig.path("port").asInt();
        String database = clientConfig.path("database").asText();
        String user = clientConfig.path("user").asText();
        String password = clientConfig.path("password").asText();

        if (clientConfig.path("is_ssh_required").asBoolean(false)) {
            String sshHost = clientConfig.path("ssh_host").asText();
            int sshPort = clientConfig.path("ssh_port").asInt();
            String sshUser = clientConfig.path("ssh_username").asText();
            String sshPrivateKey = clientConfig.path("ssh_private_key").asText();

            try {
                sshTunnelUtil.setupSshTunnel(sshHost, sshPort, sshUser, sshPrivateKey, host, port, LOCAL_PORT);
                host = "localhost";
                port = LOCAL_PORT;
            } catch (Exception e) {
                e.printStackTrace();
                throw new RuntimeException("Failed to setup SSH tunnel", e);
            }
        }

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

    public static void closeSshTunnel() {
        sshTunnelUtil.closeSshTunnel();
    }

}
