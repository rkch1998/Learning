package org.connect.data;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class DatabaseExecutor {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public DatabaseExecutor(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public String executeQuery(String schema, String functionName) {
        String query = String.format("""
                SELECT F.full_text :: varchar
                FROM
                (
                SELECT oid, proname
                FROM pg_proc
                WHERE proname like '%s'
                    AND pronamespace IN (SELECT oid FROM pg_namespace WHERE nspname = '%s')
                ) AS P
                JOIN LATERAL
                (SELECT pg_get_functiondef(P.oid) AS full_text) AS F ON TRUE;""", functionName, schema);
        return jdbcTemplate.queryForObject(query, String.class);
    }
}
