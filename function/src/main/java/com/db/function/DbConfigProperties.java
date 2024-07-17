package com.db.function;

import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class DbConfigProperties {

    @Value("${pg.master.url:}")
    private String pgMasterUrl;

    @Value("${pg.master.username:}")
    private String pgMasterUsername;

    @Value("${pg.master.password:}")
    private String pgMasterPassword;

    @Value("${pg.appdata.url:}")
    private String pgAppdataUrl;

    @Value("${pg.appdata.username:}")
    private String pgAppdataUsername;

    @Value("${pg.appdata.password:}")
    private String pgAppdataPassword;

    @Value("${pg.tenant.url:}")
    private String pgTenantUrl;

    @Value("${pg.tenant.username:}")
    private String pgTenantUsername;

    @Value("${pg.tenant.password:}")
    private String pgTenantPassword;

    @Value("${pg.log.url:}")
    private String pgLogUrl;

    @Value("${pg.log.username:}")
    private String pgLogUsername;

    @Value("${pg.log.password:}")
    private String pgLogPassword;

    @Value("${pg.admin.url:}")
    private String pgAdminUrl;

    @Value("${pg.admin.username:}")
    private String pgAdminUsername;

    @Value("${pg.admin.password:}")
    private String pgAdminPassword;

    @Value("${sql.master.url:}")
    private String sqlMasterUrl;

    @Value("${sql.master.username:}")
    private String sqlMasterUsername;

    @Value("${sql.master.password:}")
    private String sqlMasterPassword;

    @Value("${sql.appdata.url:}")
    private String sqlAppdataUrl;

    @Value("${sql.appdata.username:}")
    private String sqlAppdataUsername;

    @Value("${sql.appdata.password:}")
    private String sqlAppdataPassword;

    @Value("${sql.tenant.url:}")
    private String sqlTenantUrl;

    @Value("${sql.tenant.username:}")
    private String sqlTenantUsername;

    @Value("${sql.tenant.password:}")
    private String sqlTenantPassword;

    @Value("${sql.log.url:}")
    private String sqlLogUrl;

    @Value("${sql.log.username:}")
    private String sqlLogUsername;

    @Value("${sql.log.password:}")
    private String sqlLogPassword;

    @Value("${sql.admin.url:}")
    private String sqlAdminUrl;

    @Value("${sql.admin.username:}")
    private String sqlAdminUsername;

    @Value("${sql.admin.password:}")
    private String sqlAdminPassword;

    @Autowired
    private Environment env;

    public Map<String, String[]> getDbConfigs(String dbName) {
        Map<String, String[]> dbConfigs = new HashMap<>();
        String profile = env.getProperty("spring.profiles.active");
        System.out.println("Profile: " + profile);

        if ("pg".equals(profile)) {
            dbConfigs.put("master", new String[]{pgMasterUrl, pgMasterUsername, pgMasterPassword});
            dbConfigs.put("appdata", new String[]{pgAppdataUrl, pgAppdataUsername, pgAppdataPassword});
            dbConfigs.put("tenant", new String[]{pgTenantUrl, pgTenantUsername, pgTenantPassword});
            dbConfigs.put("log", new String[]{pgLogUrl, pgLogUsername, pgLogPassword});
            dbConfigs.put("admin", new String[]{pgAdminUrl, pgAdminUsername, pgAdminPassword});
        } else if ("sql".equals(profile)) {
            dbConfigs.put("master", new String[]{sqlMasterUrl, sqlMasterUsername, sqlMasterPassword});
            dbConfigs.put("appdata", new String[]{sqlAppdataUrl, sqlAppdataUsername, sqlAppdataPassword});
            dbConfigs.put("tenant", new String[]{sqlTenantUrl, sqlTenantUsername, sqlTenantPassword});
            dbConfigs.put("log", new String[]{sqlLogUrl, sqlLogUsername, sqlLogPassword});
            dbConfigs.put("admin", new String[]{sqlAdminUrl, sqlAdminUsername, sqlAdminPassword});
        } else {
            System.out.println("No valid profile provided.");
        }
        return dbConfigs;
    }
}