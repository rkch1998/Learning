CREATE TYPE "common"."DocumentSummaryGroupv1Type" AS ("SummaryType" smallint, "IsAmendment" boolean, "IsMixMode" boolean);

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

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentItemType";

ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "TotalRateWiseTaxAmount" numeric(18,2);
ALTER TYPE "oregular"."InsertSaleDocumentType" ADD ATTRIBUTE "TotalRateWiseTaxableValue" numeric(18,2);

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentSignedDetailType";

ALTER TYPE "oregular"."AutoGeneratedPurchaseSummaryType" ALTER ATTRIBUTE "Description" TYPE character varying;

ALTER TYPE "oregular"."ReconciliationSettingType" ADD ATTRIBUTE "IsReconciliationSectionChange" boolean;

DROP TYPE IF EXISTS "oregular"."UpdatePurchaseDocumentType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentPaymentType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentContactType";

CREATE TYPE "oregular"."UpdatePurchaseDocumentByPreferenceType" AS ("AutoSyncPreference" smallint, "PurchaseDocumentId" bigint);

DROP TYPE IF EXISTS "oregular"."GenerateItcDashboardLiabilityComplianceReportParamsType";

DROP TYPE IF EXISTS "oregular"."DownloadedEInvoicePurchaseDocumentType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentSignedDetailType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentItemType";

DROP TYPE IF EXISTS "tds"."DownloadedEInvoiceDocumentContactType";


