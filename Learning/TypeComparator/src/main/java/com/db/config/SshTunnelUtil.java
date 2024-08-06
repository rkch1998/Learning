package com.db.config;

import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;

public class SshTunnelUtil {

    private Session session;

    public void setupSshTunnel(String sshHost, int sshPort, String sshUser, String sshPrivateKey, String remoteHost, int remotePort, int localPort) throws JSchException {
        JSch jsch = new JSch();
        jsch.addIdentity(sshPrivateKey);

        session = jsch.getSession(sshUser, sshHost, sshPort);
        session.setConfig("StrictHostKeyChecking", "no");

        session.connect();
        session.setPortForwardingL(localPort, remoteHost, remotePort);
    }

    public void closeSshTunnel() {
        if (session != null && session.isConnected()) {
            session.disconnect();
        }
    }
}
