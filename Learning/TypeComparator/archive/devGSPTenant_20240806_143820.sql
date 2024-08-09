CREATE TYPE "common"."DocumentSummaryGroupv1Type" AS ("SummaryType" smallint, "IsAmendment" boolean, "IsMixMode" boolean);

DROP TYPE IF EXISTS "einvoice"."GlibInvoiceStatusType";

DROP TYPE IF EXISTS "gst"."InsertReturnDataType";

ALTER TYPE "import"."DocumentType" ALTER ATTRIBUTE "Property5" TYPE text;

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "isd"."DownloadedEInvoiceDocumentContactType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentItemType";

ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "TotalRateWiseTaxableValue" numeric(18,2);

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentSignedDetailType";

ALTER TYPE "oregular"."AutoGeneratedPurchaseSummaryType" ALTER ATTRIBUTE "Description" TYPE character varying;

ALTER TYPE "oregular"."ReconciliationSettingType" ADD ATTRIBUTE "IsReconciliationSectionChange" boolean;

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentPaymentType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentContactType";

DROP TYPE IF EXISTS "oregular"."GenerateItcDashboardLiabilityComplianceReportParamsType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentContactType";


