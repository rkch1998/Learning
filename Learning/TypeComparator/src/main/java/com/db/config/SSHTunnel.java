package com.db.config;

import com.fasterxml.jackson.databind.JsonNode;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;

public class SSHTunnel {
    private Session session;

    public void openSshTunnel(JsonNode sshConfig) throws JSchException {
        String sshHost = sshConfig.path("ssh_host").asText();
        int sshPort = sshConfig.path("ssh_port").asInt();
        String sshUser = sshConfig.path("ssh_username").asText();
        String privateKey = sshConfig.path("ssh_private_key").asText();

        JSch jsch = new JSch();
        jsch.addIdentity(privateKey);
        session = jsch.getSession(sshUser, sshHost, sshPort);
        session.setConfig("StrictHostKeyChecking", "no");
        session.connect();
    }

    public void closeSshTunnel() {
        if (session != null && session.isConnected()) {
            session.disconnect();
        }
    }
}