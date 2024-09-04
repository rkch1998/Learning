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

ALTER TYPE "oregular"."ReconciliationSettingType" ALTER ATTRIBUTE "FilingExtendedDate" TYPE timestamp without time zone;

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


