DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'DateWiseRateType' AND typnamespace = 'common'::regnamespace::oid)
THEN
    CREATE TYPE "common"."DateWiseRateType" AS ("Date" timestamp without time zone, "Rate" numeric);

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
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'GstinReturnsCustomizedDataType' AND typnamespace = 'gst'::regnamespace::oid)
THEN
    CREATE TYPE "gst"."GstinReturnsCustomizedDataType" AS ("Gstin" character varying(15), "Gstr1LastFiledTaxPeriod" integer, "Gstr1LastLastFilingDate" timestamp without time zone, "Gstr1SecondLastFiledTaxPeriod" integer, "Gstr1SecondLastFilingDate" timestamp without time zone, "Gstr3BLastFiledTaxPeriod" integer, "Gstr3BLastLastFilingDate" timestamp without time zone, "Gstr3BSecondLastFiledTaxPeriod" integer, "Gstr3BSecondLastFilingDate" timestamp without time zone, "Gstr1Periodicity" smallint, "Gstr3BPeriodicity" smallint, "SupplierGrcScore" smallint, "Remarks" smallint, "Errors" character varying);

END IF;
END
$do$;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ReconciliationTypeIdsType' AND typnamespace = 'isd'::regnamespace::oid)
THEN
    CREATE TYPE "isd"."ReconciliationTypeIdsType" AS ("MapperId" bigint, "IsManual" boolean);

END IF;
END
$do$;

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

ALTER TYPE "oregular"."ReconciliationSettingType" ALTER ATTRIBUTE "FilingExtendedDate" TYPE timestamp without time zone;

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

ALTER TYPE "oregular"."ReconciliationTypeIdsType" ALTER ATTRIBUTE "IsManual" TYPE boolean;

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Get3WayReconciliationSettingResponseType' AND typnamespace = 'report'::regnamespace::oid)
THEN
    CREATE TYPE "report"."Get3WayReconciliationSettingResponseType" AS ("FinancialYear" integer, "IsDiscardEinvRecordStatus" boolean, "IsEinvCancelledStatusEnabled" boolean, "IsEinvYetNotGeneratedStatusEnabled" boolean, "IsDiscardGstRecordStatus" boolean, "IsGstCancelledStatusEnabled" boolean, "IsGstUploadedButNotPushedStatusEnabled" boolean, "IsDiscardEwbRecordStatus" boolean, "IsEwbCancelledStatusEnabled" boolean, "IsEwbRejectedStatusEnabled" boolean, "IsEwbDiscardedStatusEnabled" boolean, "IsDiscardGstAutodraftedRecordStatus" boolean, "IsGstAutodraftedCancelledStatusEnabled" boolean, "IsGstAutodraftedAutoPopulationFailedEnabled" boolean, "IsGstAutodraftedCancellationFailedEnabled" boolean, "IsExcludeOtherChargesEnabled" boolean, "IsMatchByTolerance" boolean, "MatchByToleranceDocumentValueFrom" numeric(15,2), "MatchByToleranceDocumentValueTo" numeric(15,2), "MatchByToleranceTaxableValueFrom" numeric(15,2), "MatchByToleranceTaxableValueTo" numeric(15,2), "MatchByToleranceTaxAmountsFrom" numeric(15,2), "MatchByToleranceTaxAmountsTo" numeric(15,2), "IsDocValueThresholdForRecoAgainstEwb" boolean, "DocValueThresholdForRecoAgainstEwb" numeric(15,2), "IsReconciliationPreference" boolean, "IsFinancialYearReturnPeriod" boolean, "IsDocumentDateReturnPeriod" boolean);

END IF;
END
$do$;


