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
