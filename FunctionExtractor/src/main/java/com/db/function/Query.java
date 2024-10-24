package com.db.function;

public class Query {
    static final String PG = """
                SELECT pg_get_functiondef(oid)
                FROM pg_proc
                WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = '%s')
                 AND proname = '%s'
                """; 

    static final String MS = "SELECT OBJECT_DEFINITION (OBJECT_ID('%s.%s'))";
    
}
