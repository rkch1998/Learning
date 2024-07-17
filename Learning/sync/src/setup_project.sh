#!/bin/bash

# Set up project structure
mkdir -p src/main/java/com/database/sync/config
mkdir -p src/main/java/com/database/sync/database
mkdir -p src/main/java/com/database/sync/model
mkdir -p src/main/java/com/database/sync/util
mkdir -p src/main/java/com/database/sync/service
mkdir -p src/main/resources
mkdir -p src/test/java/com/database/sync

# Create SyncApplication.java
cat <<EOL > src/main/java/com/database/sync/SyncApplication.java
package com.database.sync;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SyncApplication {
    public static void main(String[] args) {
        SpringApplication.run(SyncApplication.class, args);
    }
}
EOL

# Create DbConfig.java
cat <<EOL > src/main/java/com/database/sync/config/DbConfig.java
package com.database.sync.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "db")
public class DbConfig {
    private String type;

    // Getters and Setters
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
EOL

# Create DatabaseExporter.java
cat <<EOL > src/main/java/com/database/sync/database/DatabaseExporter.java
package com.database.sync.database;

import com.database.sync.model.UserDefinedType;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface DatabaseExporter {
    void exportProcedures(Connection connection, List<UserDefinedType> udtList) throws SQLException;
}
EOL

# Create SqlServerExporter.java
cat <<EOL > src/main/java/com/database/sync/database/SqlServerExporter.java
package com.database.sync.database;

import com.database.sync.model.UserDefinedType;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Component
public class SqlServerExporter implements DatabaseExporter {

    @Override
    public void exportProcedures(Connection connection, List<UserDefinedType> udtList) throws SQLException {
        String query = getQuery();

        for (UserDefinedType udt : udtList) {
            try (PreparedStatement statement = connection.prepareStatement(query)) {
                statement.setString(1, udt.getSchemaName());
                statement.setString(2, udt.getTypeName());

                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        String procSchemaName = resultSet.getString("schema_name");
                        String procedureName = resultSet.getString("procedure_name");
                        String procedureDefinition = resultSet.getString("complete_procedure_definition");

                        // Generate and handle the DROP and CREATE statements as required
                    }
                }
            }
        }
    }

    private String getQuery() {
        return "WITH UDT_Dependencies AS (" +
               "    SELECT obj.object_id AS procedure_id," +
               "           obj.name AS procedure_name," +
               "           sch.name AS schema_name" +
               "    FROM sys.sql_expression_dependencies AS dep" +
               "    JOIN sys.objects AS obj ON dep.referencing_id = obj.object_id" +
               "    JOIN sys.schemas AS sch ON obj.schema_id = sch.schema_id" +
               "    WHERE obj.type = 'P' " +
               "      AND dep.referenced_id = (" +
               "          SELECT user_type_id" +
               "          FROM sys.types AS t" +
               "          JOIN sys.schemas AS s ON t.schema_id = s.schema_id" +
               "          WHERE s.name = ? AND t.name = ?" +
               "      )" +
               ") " +
               "Procedure_Definitions AS (" +
               "    SELECT ud.procedure_name," +
               "           ud.schema_name," +
               "           OBJECT_DEFINITION(ud.procedure_id) AS procedure_definition" +
               "    FROM UDT_Dependencies AS ud" +
               ") " +
               "SELECT schema_name," +
               "       procedure_name," +
               "       'DROP PROCEDURE IF EXISTS [' + schema_name + '].[' + procedure_name + '];' + CHAR(13) + CHAR(10) +" +
               "       ISNULL(procedure_definition, '') + CHAR(13) + CHAR(10) + 'GO' AS complete_procedure_definition" +
               "FROM Procedure_Definitions;";
    }
}
EOL

# Create PostgresExporter.java
cat <<EOL > src/main/java/com/database/sync/database/PostgresExporter.java
package com.database.sync.database;

import com.database.sync.model.UserDefinedType;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Component
public class PostgresExporter implements DatabaseExporter {

    @Override
    public void exportProcedures(Connection connection, List<UserDefinedType> udtList) throws SQLException {
        String query = getQuery();

        for (UserDefinedType udt : udtList) {
            try (PreparedStatement statement = connection.prepareStatement(query)) {
                statement.setString(1, udt.getSchemaName());
                statement.setString(2, udt.getTypeName());

                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        String procSchemaName = resultSet.getString("schema_name");
                        String procedureName = resultSet.getString("procedure_name");
                        String procedureDefinition = resultSet.getString("complete_procedure_definition");

                        // Generate and handle the DROP and CREATE statements as required
                    }
                }
            }
        }
    }

    private String getQuery() {
        return "WITH UDT_Dependencies AS (" +
               "    SELECT p.oid::regprocedure::text AS procedure_name, " +
               "           n.nspname AS schema_name " +
               "    FROM pg_depend AS d " +
               "    JOIN pg_type AS t ON d.refobjid = t.oid " +
               "    JOIN pg_proc AS p ON d.objid = p.oid " +
               "    JOIN pg_namespace AS n ON p.pronamespace = n.oid " +
               "    WHERE t.typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = ?) " +
               "      AND t.typname = ? " +
               ") " +
               "SELECT schema_name, " +
               "       procedure_name, " +
               "       'DROP FUNCTION IF EXISTS ' || schema_name || '.' || procedure_name || ';' AS drop_statement, " +
               "       pg_get_functiondef(p.oid) AS procedure_definition " +
               "FROM pg_proc p " +
               "JOIN pg_namespace n ON p.pronamespace = n.oid " +
               "JOIN UDT_Dependencies ud ON ud.procedure_name = p.oid::regprocedure::text AND ud.schema_name = n.nspname;";
    }
}
EOL

# Create ExporterFactory.java
cat <<EOL > src/main/java/com/database/sync/database/ExporterFactory.java
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
EOL

# Create UserDefinedType.java
cat <<EOL > src/main/java/com/database/sync/model/UserDefinedType.java
package com.database.sync.model;

public class UserDefinedType {
    private String schemaName;
    private String typeName;

    // Getters and Setters
    public String getSchemaName() {
        return schemaName;
    }

    public void setSchemaName(String schemaName) {
        this.schemaName = schemaName;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
}
EOL

# Create FileUtils.java
cat <<EOL > src/main/java/com/database/sync/util/FileUtils.java
package com.database.sync.util;

import com.database.sync.model.UserDefinedType;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FileUtils {

    public static List<UserDefinedType> readSchemaAndTypeNames(String filePath) throws IOException {
        List<UserDefinedType> udtList = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split("\\.");
                if (parts.length == 2) {
                    udtList.add(new UserDefinedType(parts[0], parts[1].replace("\"", "")));
                }
            }
        }
        return udtList;
    }
}
EOL

# Create application.properties
cat <<EOL > src/main/resources/application.properties
db.type=sqlserver
db.url=jdbc:sqlserver://yourserver:1433;databaseName=yourdb
db.username=yourusername
db.password=yourpassword
EOL

# Create settings.gradle
cat <<EOL > settings.gradle
rootProject.name = 'DatabaseSync'
EOL

# Create build.gradle
cat <<EOL > build.gradle
plugins {
    id 'org.springframework.boot' version '2.7.4'
    id 'io.spring.dependency-management' version '1.0.13.RELEASE'
    id 'java'
}

group = 'com.database'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '11'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter'
    implementation 'org.springframework.boot:spring-boot-starter-jdbc'
    implementation 'com.microsoft.sqlserver:mssql-jdbc:9.4.1.jre11'
    implementation 'org.postgresql:postgresql:42.3.6'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
EOL

echo "Project structure created successfully."
