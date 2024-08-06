CREATE TYPE "common"."DocumentSummaryGroupv1Type" AS ("SummaryType" smallint, "IsAmendment" boolean, "IsMixMode" boolean);

DROP TYPE "einvoice"."GlibInvoiceStatusType";

DROP TYPE "gst"."InsertReturnDataType";

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property5" TYPE text;

DROP TYPE "isd"."DownloadedEInvoiceDocumentType";

DROP TYPE "isd"."DownloadedEInvoiceDocumentItemType";

DROP TYPE "isd"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE "isd"."DownloadedEInvoiceDocumentContactType";

DROP TYPE "oregular"."DownloadedEInvoicePurchaseDocumentItemType";

ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "TotalRateWiseTaxableValue" numeric(18,2);

DROP TYPE "oregular"."DownloadedEInvoicePurchaseDocumentSignedDetailType";

ALTER TYPE "oregular"."AutoGeneratedPurchaseSummaryType" ALTER ATTRIBUTE "Description" TYPE character varying;

CREATE TYPE "oregular"."UpdatePurchaseDocumentType" AS ("AutoSyncGstr1Filed" boolean, "AutoSyncGstr3bFiled" boolean, "PurchaseDocumentId" bigint, "ReturnPeriod" integer);

ALTER TYPE "oregular"."ReconciliationSettingType" ADD ATTRIBUTE "IsReconciliationSectionChange" boolean;

DROP TYPE "oregular"."DownloadedEInvoicePurchaseDocumentPaymentType";

DROP TYPE "oregular"."DownloadedEInvoicePurchaseDocumentContactType";

DROP TYPE "oregular"."GenerateItcDashboardLiabilityComplianceReportParamsType";

DROP TYPE "oregular"."DownloadedEInvoicePurchaseDocumentType";

DROP TYPE "tds"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE "tds"."DownloadedEInvoiceDocumentType";

DROP TYPE "tds"."DownloadedEInvoiceDocumentItemType";

DROP TYPE "tds"."DownloadedEInvoiceDocumentContactType";

