DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'PushResponseType' AND ns.nspname = 'ewaybill' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'UpdatedByGstin')
THEN
    ALTER TYPE "ewaybill"."PushResponseType" ADD ATTRIBUTE "UpdatedByGstin" character varying(15);

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'PushResponseType' AND ns.nspname = 'ewaybill' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'Provider')
THEN
    ALTER TYPE "ewaybill"."PushResponseType" ADD ATTRIBUTE "Provider" smallint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'DownloadedDocumentType' AND ns.nspname = 'ewaybill' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'Provider')
THEN
    ALTER TYPE "ewaybill"."DownloadedDocumentType" ADD ATTRIBUTE "Provider" smallint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeAdvReca')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeAdvReca" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeAdvRec')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeAdvRec" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeNil')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeNil" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeSupEcom14ba')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeSupEcom14ba" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeAdvAdj')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeAdvAdj" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeB2csa')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeB2csa" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeEcomUnr')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeEcomUnr" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeSupEcom14aa')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeSupEcom14aa" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeAdvAdja')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeAdvAdja" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeEcomUnra')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeEcomUnra" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeDocIssued')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeDocIssued" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeSupEcom14b')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeSupEcom14b" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeSupEcom14a')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeSupEcom14a" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeB2cs')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeB2cs" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'GenerateGstr1DocumentSectionParamsType' AND ns.nspname = 'gst' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'DocumentSectionTypeHsn')
THEN
    ALTER TYPE "gst"."GenerateGstr1DocumentSectionParamsType" ADD ATTRIBUTE "DocumentSectionTypeHsn" bigint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'ValidateGstr1aSummaryType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'IsAmendment')
THEN
    ALTER TYPE "oregular"."ValidateGstr1aSummaryType" ADD ATTRIBUTE "IsAmendment" boolean;

END IF;
END
$do$;

ALTER TYPE "oregular"."ValidateGstr1aSummaryType" DROP ATTRIBUTE "IsAmendmment";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'ReconciliationSettingType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'IsReconciliationSectionChange')
THEN
    ALTER TYPE "oregular"."ReconciliationSettingType" ADD ATTRIBUTE "IsReconciliationSectionChange" boolean;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'InsertPurchaseDocumentType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'BillFromTradeName')
THEN
    ALTER TYPE "oregular"."InsertPurchaseDocumentType" ADD ATTRIBUTE "BillFromTradeName" character varying(200);

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'ValidatePurchaseDocumentType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'BillFromTradeName')
THEN
    ALTER TYPE "oregular"."ValidatePurchaseDocumentType" ADD ATTRIBUTE "BillFromTradeName" character varying(200);

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'SaleSummaryType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'ReturnType')
THEN
    ALTER TYPE "oregular"."SaleSummaryType" ADD ATTRIBUTE "ReturnType" smallint;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'SaleSummaryType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'IsGstr1a')
THEN
    ALTER TYPE "oregular"."SaleSummaryType" ADD ATTRIBUTE "IsGstr1a" boolean;

END IF;
END
$do$;


