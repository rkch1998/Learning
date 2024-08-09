DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'DocumentSummaryGroupv1Type' AND typnamespace = 'common'::regnamespace::oid)
THEN
    CREATE TYPE "common"."DocumentSummaryGroupv1Type" AS ("SummaryType" smallint, "IsAmendment" boolean, "IsMixMode" boolean);

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = '$s' AND ns.nspname = 'DocumentSummaryGroupType' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'common';)
THEN
    ALTER TYPE IsMixMode ADD ATTRIBUTE ""common"."DocumentSummaryGroupType"" IsMixMode;

END IF;
END
$do$;

DROP TYPE IF EXISTS "einvoice"."GlibInvoiceStatusType";

DROP TYPE IF EXISTS "gst"."InsertReturnDataType";

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property4" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property3" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property2" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property19" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property1" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property18" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property17" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property16" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property15" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property14" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property13" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property12" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property11" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property10" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property20" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property9" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property8" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property7" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property6" TYPE text;

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property5" TYPE text;

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentContactType";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = '$s' AND ns.nspname = 'InsertSaleDocumentType' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'oregular';)
THEN
    ALTER TYPE TotalRateWiseTaxAmount ADD ATTRIBUTE ""oregular"."InsertSaleDocumentType"" TotalRateWiseTaxAmount;

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = '$s' AND ns.nspname = 'InsertSaleDocumentType' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'oregular';)
THEN
    ALTER TYPE TotalRateWiseTaxableValue ADD ATTRIBUTE ""oregular"."InsertSaleDocumentType"" TotalRateWiseTaxableValue;

END IF;
END
$do$;

ALTER TYPE "oregular"."AutoGeneratedPurchaseSummaryType" ALTER ATTRIBUTE "Description" TYPE character varying;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_attribute a ON a.attrelid = t.typrelid JOIN pg_namespace ns ON ns.oid = t.typnamespace
                WHERE t.typname = '$s' AND ns.nspname = 'ReconciliationSettingType' AND a.attnum > 0 AND NOT a.attisdropped AND a.attname = 'oregular';)
THEN
    ALTER TYPE IsReconciliationSectionChange ADD ATTRIBUTE ""oregular"."ReconciliationSettingType"" IsReconciliationSectionChange;

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

