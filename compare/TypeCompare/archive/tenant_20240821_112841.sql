DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'DateWiseRateType' AND typnamespace = 'common'::regnamespace::oid)
THEN
    CREATE TYPE "common"."DateWiseRateType" AS ("Date" timestamp without time zone, "Rate" numeric);

END IF;
END
$do$;

DROP TYPE IF EXISTS "einvoice"."GlibInvoiceStatusType";

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

DROP TYPE IF EXISTS "gst"."InsertReturnDataType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentContactType";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'InsertSaleDocumentType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'IsGstr1A')
THEN
    ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "IsGstr1A" boolean;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'InsertSaleDocumentType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'TotalRateWiseTaxAmount')
THEN
    ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "TotalRateWiseTaxAmount" numeric(18,2);

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = 'InsertSaleDocumentType' AND ns.nspname = 'oregular' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'TotalRateWiseTaxableValue')
THEN
    ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "TotalRateWiseTaxableValue" numeric(18,2);

END IF;
END
$do$;

ALTER TYPE "oregular"."AutoGeneratedPurchaseSummaryType" ALTER ATTRIBUTE "Description" TYPE character varying;

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

DROP TYPE IF EXISTS "oregular"."UpdatePurchaseDocumentType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentType";

DROP TYPE IF EXISTS "oregular"."GenerateItcDashboardLiabilityComplianceReportParamsType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentPaymentType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentItemType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentContactType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentSignedDetailType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentContactType";


