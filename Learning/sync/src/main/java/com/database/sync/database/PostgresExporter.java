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
