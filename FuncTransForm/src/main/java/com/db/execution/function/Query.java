package com.db.execution.function;

public class Query {
   static String  query = "SELECT n.nspname, p.proname, " +
               "pg_catalog.pg_get_function_identity_arguments(p.oid) AS fun_args " +
               "FROM pg_catalog.pg_proc p " +
               "JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace " +
               "WHERE n.nspname = ? AND p.proname = ? " +
               "ORDER BY 1";
    
}
