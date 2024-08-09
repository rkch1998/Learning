DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'test4' AND typnamespace = 'public'::regnamespace::oid)
THEN
    CREATE TYPE "public"."test4" AS ("email" character varying, "name" character varying, "id" integer);

END IF;
END
$do$;

ALTER TYPE "public"."test5" ALTER ATTRIBUTE "email" TYPE character varying(50);

ALTER TYPE "public"."test2" DROP ATTRIBUTE "name";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'test3' AND ns.nspname = 'public' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'email')
THEN
    ALTER TYPE "public"."test3" ADD ATTRIBUTE "email" character varying;

END IF;
END
$do$;

DROP TYPE IF EXISTS "public"."test1";


