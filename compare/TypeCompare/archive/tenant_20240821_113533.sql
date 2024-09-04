DROP TYPE IF EXISTS "api"."ExportBillingTransactionsParamsType";

DROP TYPE IF EXISTS "einvoice"."GlibInvoiceStatusType";

DROP TYPE IF EXISTS "ewaybill"."DownloadedVehicleDetails";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'GstinReturnsCustomizedDataType' AND typnamespace = 'gst'::regnamespace::oid)
THEN
    CREATE TYPE "gst"."GstinReturnsCustomizedDataType" AS ("Gstin" character varying(15), "Gstr1LastFiledTaxPeriod" integer, "Gstr1LastLastFilingDate" timestamp without time zone, "Gstr1SecondLastFiledTaxPeriod" integer, "Gstr1SecondLastFilingDate" timestamp without time zone, "Gstr3BLastFiledTaxPeriod" integer, "Gstr3BLastLastFilingDate" timestamp without time zone, "Gstr3BSecondLastFiledTaxPeriod" integer, "Gstr3BSecondLastFilingDate" timestamp without time zone, "Gstr1Periodicity" smallint, "Gstr3BPeriodicity" smallint, "SupplierGrcScore" smallint, "Remarks" smallint, "Errors" character varying);

END IF;
END
$do$;

DROP TYPE IF EXISTS "gst"."InsertDownloadedGstin";

DROP TYPE IF EXISTS "gst"."InsertGstinPreference";

DROP TYPE IF EXISTS "gst"."InsertDownloadedSubscriberGstin";

DROP TYPE IF EXISTS "gst"."ReturnType";

DROP TYPE IF EXISTS "gst"."ReturnFilingDeadlineType";

DROP TYPE IF EXISTS "gst"."UpdateSubscriberGstinsLastChangeDateResponseType";

DROP TYPE IF EXISTS "gst"."InsertSubscriberGstin";

DROP TYPE IF EXISTS "gst"."InsertGstinReturn";

DROP TYPE IF EXISTS "gst"."GstinLastChangeDateType";

DROP TYPE IF EXISTS "gst"."InsertReturnDataType";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ReconciliationTypeIdsType' AND typnamespace = 'isd'::regnamespace::oid)
THEN
    CREATE TYPE "isd"."ReconciliationTypeIdsType" AS ("MapperId" bigint, "IsManual" boolean);

END IF;
END
$do$;

DROP TYPE IF EXISTS "isd"."ReconciliationBulkActionType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "isd"."ReconciliationTypeIds";

DROP TYPE IF EXISTS "isd"."ReconciliationSettingType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentContactType";

DROP TYPE IF EXISTS "notice"."NoticeType";

ALTER TYPE "oregular"."ReconciliationSettingType" ALTER ATTRIBUTE "FilingExtendedDate" TYPE timestamp without time zone;

ALTER TYPE "oregular"."ReconciliationTypeIdsType" ALTER ATTRIBUTE "IsManual" TYPE boolean;

DROP TYPE IF EXISTS "oregular"."UpdatePurchaseDocumentType";

DROP TYPE IF EXISTS "oregular"."UpdatePushActionForGstr2xType";

DROP TYPE IF EXISTS "oregular"."ReconciliationTypeIds";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentType";

DROP TYPE IF EXISTS "oregular"."PurchaseDocumentItcDetailType";

DROP TYPE IF EXISTS "oregular"."GenerateComparisonReportParamsType";

DROP TYPE IF EXISTS "oregular"."GenerateItcDashboardLiabilityComplianceReportParamsType";

DROP TYPE IF EXISTS "oregular"."GenerateSummaryReportParamsType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentPaymentType";

DROP TYPE IF EXISTS "oregular"."GenerateOverviewSummaryComparisonReportParamsType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentItemType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentContactType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentSignedDetailType";

DO
$do$
BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Get3WayReconciliationSettingResponseType' AND typnamespace = 'report'::regnamespace::oid)
THEN
    CREATE TYPE "report"."Get3WayReconciliationSettingResponseType" AS ("FinancialYear" integer, "IsDiscardEinvRecordStatus" boolean, "IsEinvCancelledStatusEnabled" boolean, "IsEinvYetNotGeneratedStatusEnabled" boolean, "IsDiscardGstRecordStatus" boolean, "IsGstCancelledStatusEnabled" boolean, "IsGstUploadedButNotPushedStatusEnabled" boolean, "IsDiscardEwbRecordStatus" boolean, "IsEwbCancelledStatusEnabled" boolean, "IsEwbRejectedStatusEnabled" boolean, "IsEwbDiscardedStatusEnabled" boolean, "IsDiscardGstAutodraftedRecordStatus" boolean, "IsGstAutodraftedCancelledStatusEnabled" boolean, "IsGstAutodraftedAutoPopulationFailedEnabled" boolean, "IsGstAutodraftedCancellationFailedEnabled" boolean, "IsExcludeOtherChargesEnabled" boolean, "IsMatchByTolerance" boolean, "MatchByToleranceDocumentValueFrom" numeric(15,2), "MatchByToleranceDocumentValueTo" numeric(15,2), "MatchByToleranceTaxableValueFrom" numeric(15,2), "MatchByToleranceTaxableValueTo" numeric(15,2), "MatchByToleranceTaxAmountsFrom" numeric(15,2), "MatchByToleranceTaxAmountsTo" numeric(15,2), "IsDocValueThresholdForRecoAgainstEwb" boolean, "DocValueThresholdForRecoAgainstEwb" numeric(15,2), "IsReconciliationPreference" boolean, "IsFinancialYearReturnPeriod" boolean, "IsDocumentDateReturnPeriod" boolean);

END IF;
END
$do$;

DROP TYPE IF EXISTS "report"."TdsTcsAmendmentReportIdAndType";

DROP TYPE IF EXISTS "subscriber"."UpdateDownloadResponseForVendor";

DROP TYPE IF EXISTS "subscriber"."HsnSacType";

DROP TYPE IF EXISTS "subscriber"."UpdateSubscriberGstinsLastChangeDateResponseType";

DROP TYPE IF EXISTS "subscriber"."InsertGstinTurnoverType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentContactType";


