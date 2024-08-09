package com.db.format.type;

public class TypeFormat implements Type {

    @Override
    public String createTypeFormat(String typeName, String typeDefinition) {
        String typeArray[] = typeName.replaceAll("\"", "").split("\\.");
        return String.format("""
        DO
        $do$
        BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = '%s' AND typnamespace = '%s'::regnamespace::oid) 
        THEN
            CREATE TYPE %s AS (%s);\n
        END IF;
        END
        $do$;\n""", typeArray[1], typeArray[0], typeName, typeDefinition);
    }

    @Override
    public String alterTypeFormat(String typeName, String newDefinition) {
        return String.format("ALTER TYPE %s AS (%s);\n", typeName, newDefinition);
    }

    @Override
    public String addAttributeFormat(String typeName, String attrName, String dataType) {
        String typeArray[] = typeName.replaceAll("\"", "").split("\\.");
        return String.format("""
        DO
        $do$
        BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                        WHERE t.typname = '%s' AND ns.nspname = '%s' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = '%s') 
        THEN    
            ALTER TYPE %s ADD ATTRIBUTE \"%s\" %s;\n
        END IF;
        END
        $do$;\n""", typeArray[1], typeArray[0], attrName, typeName, attrName, dataType);

    }

    @Override
    public String alterAttributeFormat(String typeName, String attrName, String dataType) {
        return String.format("ALTER TYPE %s ALTER ATTRIBUTE \"%s\" TYPE %s;\n",typeName, attrName, dataType);
    }

    @Override
    public String dropAttributeFormat(String schemaName, String typeName, String attrName) {
        return String.format("ALTER TYPE %s DROP ATTRIBUTE \"%s\";\n",typeName, attrName);
    }
}
