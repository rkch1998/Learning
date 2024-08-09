DROP TYPE "api"."ExportBillingTransactionsParamsType";

DROP TYPE "ewaybill"."DownloadedVehicleDetails";

DROP TYPE "gst"."InsertDownloadedGstin";

DROP TYPE "gst"."InsertGstinReturn";

DROP TYPE "gst"."GstinLastChangeDateType";

DROP TYPE "gst"."UpdateSubscriberGstinsLastChangeDateResponseType";

DROP TYPE "gst"."InsertDownloadedSubscriberGstin";

DROP TYPE "gst"."ReturnType";

DROP TYPE "gst"."InsertGstinPreference";

DROP TYPE "gst"."ReturnFilingDeadlineType";

DROP TYPE "gst"."InsertSubscriberGstin";

CREATE TYPE "gst"."GstinReturnsCustomizedDataType" AS ("Gstr3BSecondLastFiledTaxPeriod" integer, "Gstr3BLastFiledTaxPeriod" integer, "Gstr1SecondLastFiledTaxPeriod" integer, "Gstr1LastFiledTaxPeriod" integer, "Gstr1LastLastFilingDate" timestamp without time zone, "SupplierGrcScore" smallint, "Errors" character varying, "Gstin" character varying(15), "Gstr1SecondLastFilingDate" timestamp without time zone, "Gstr3BPeriodicity" smallint, "Remarks" smallint, "Gstr3BSecondLastFilingDate" timestamp without time zone, "Gstr3BLastLastFilingDate" timestamp without time zone, "Gstr1Periodicity" smallint);

CREATE TYPE "isd"."ReconciliationTypeIdsType" AS ("IsManual" boolean, "MapperId" bigint);

DROP TYPE "isd"."ReconciliationBulkActionType";

DROP TYPE "isd"."ReconciliationSettingType";

DROP TYPE "isd"."ReconciliationTypeIds";

DROP TYPE "notice"."NoticeType";

DROP TYPE "oregular"."GenerateSummaryReportParamsType";

ALTER TYPE "oregular"."ReconciliationSettingType" ALTER ATTRIBUTE "FilingExtendedDate" TYPE timestamp without time zone;

ALTER TYPE "oregular"."ReconciliationTypeIdsType" ALTER ATTRIBUTE "IsManual" TYPE boolean;

DROP TYPE "oregular"."UpdatePushActionForGstr2xType";

DROP TYPE "oregular"."PurchaseDocumentItcDetailType";

DROP TYPE "oregular"."ReconciliationTypeIds";

DROP TYPE "oregular"."GenerateOverviewSummaryComparisonReportParamsType";

DROP TYPE "oregular"."GenerateComparisonReportParamsType";

CREATE TYPE "report"."Get3WayReconciliationSettingResponseType" AS ("IsDiscardGstAutodraftedRecordStatus" boolean, "IsDiscardGstRecordStatus" boolean, "IsReconciliationPreference" boolean, "IsDiscardEinvRecordStatus" boolean, "MatchByToleranceTaxableValueTo" numeric(15,2), "MatchByToleranceTaxAmountsTo" numeric(15,2), "IsEwbRejectedStatusEnabled" boolean, "IsDocValueThresholdForRecoAgainstEwb" boolean, "FinancialYear" integer, "IsEwbDiscardedStatusEnabled" boolean, "MatchByToleranceDocumentValueFrom" numeric(15,2), "IsGstAutodraftedAutoPopulationFailedEnabled" boolean, "MatchByToleranceTaxAmountsFrom" numeric(15,2), "MatchByToleranceDocumentValueTo" numeric(15,2), "IsGstCancelledStatusEnabled" boolean, "DocValueThresholdForRecoAgainstEwb" numeric(15,2), "IsDiscardEwbRecordStatus" boolean, "IsFinancialYearReturnPeriod" boolean, "IsMatchByTolerance" boolean, "IsEinvYetNotGeneratedStatusEnabled" boolean, "IsGstAutodraftedCancelledStatusEnabled" boolean, "IsEwbCancelledStatusEnabled" boolean, "IsGstAutodraftedCancellationFailedEnabled" boolean, "MatchByToleranceTaxableValueFrom" numeric(15,2), "IsEinvCancelledStatusEnabled" boolean, "IsGstUploadedButNotPushedStatusEnabled" boolean, "IsExcludeOtherChargesEnabled" boolean, "IsDocumentDateReturnPeriod" boolean);

DROP TYPE "report"."TdsTcsAmendmentReportIdAndType";

DROP TYPE "subscriber"."HsnSacType";

DROP TYPE "subscriber"."UpdateDownloadResponseForVendor";

DROP TYPE "subscriber"."UpdateSubscriberGstinsLastChangeDateResponseType";

DROP TYPE "subscriber"."InsertGstinTurnoverType";


