package com.connect.DB.data;

public interface DatabaseOperations {
    String executeQuery(String dbName, String schemaName, String functionName);
}
