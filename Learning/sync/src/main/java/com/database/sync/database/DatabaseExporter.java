package com.database.sync.database;

import com.database.sync.model.UserDefinedType;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface DatabaseExporter {
    void exportProcedures(Connection connection, List<UserDefinedType> udtList) throws SQLException;
}
