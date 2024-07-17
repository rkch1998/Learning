package com.database.sync.database;

import com.database.sync.config.DbConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class ExporterFactory {

    private final SqlServerExporter sqlServerExporter;
    private final PostgresExporter postgresExporter;

    @Autowired
    public ExporterFactory(SqlServerExporter sqlServerExporter, PostgresExporter postgresExporter) {
        this.sqlServerExporter = sqlServerExporter;
        this.postgresExporter = postgresExporter;
    }

    public DatabaseExporter createExporter(DbConfig dbConfig) {
        switch (dbConfig.getType().toLowerCase()) {
            case "sqlserver":
                return sqlServerExporter;
            case "postgresql":
                return postgresExporter;
            default:
                throw new IllegalArgumentException("Unsupported database type: " + dbConfig.getType());
        }
    }
}
