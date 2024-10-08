CREATE TYPE "common".""common"."DocumentSummaryGroupv1Type"" AS ("SummaryType" smallint, "IsAmendment" boolean, "IsMixMode" boolean);
DROP TYPE IF EXISTS "einvoice".""einvoice"."GlibInvoiceStatusType"";
DROP TYPE IF EXISTS "gst".""gst"."InsertReturnDataType"";
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property4" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property3" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property2" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property19" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property1" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property18" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property17" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property16" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property15" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property14" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property13" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property12" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property11" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property10" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property20" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property9" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property8" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property7" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property6" TYPE text;
ALTER TYPE "import".""import"."DocumentType"" ALTER ATTRIBUTE "Property5" TYPE text;
DROP TYPE IF EXISTS "isd".""isd"."DownloadedEInvoiceDocumentType"";
DROP TYPE IF EXISTS "isd".""isd"."DownloadedEInvoiceDocumentItemType"";
DROP TYPE IF EXISTS "isd".""isd"."DownloadedEInvoiceDocumentSignedDetailType"";
DROP TYPE IF EXISTS "isd".""isd"."DownloadedEInvoiceDocumentContactType"";
CREATE TYPE "oregular".""oregular"."UpdatePurchaseDocumentByReturnType"" AS ("PurchaseDocumentId" bigint, "AutoSyncGstr1Filed" boolean, "AutoSyncGstr3bFiled" boolean);
ALTER TYPE "oregular".""oregular"."InsertSaleDocumentType"" ADD ATTRIBUTE "TotalRateWiseTaxAmount" numeric(18,2);
ALTER TYPE "oregular".""oregular"."InsertSaleDocumentType"" ADD ATTRIBUTE "TotalRateWiseTaxableValue" numeric(18,2);
ALTER TYPE "oregular".""oregular"."AutoGeneratedPurchaseSummaryType"" ALTER ATTRIBUTE "Description" TYPE character varying;
ALTER TYPE "oregular".""oregular"."ReconciliationSettingType"" ADD ATTRIBUTE "IsReconciliationSectionChange" boolean;
DROP TYPE IF EXISTS "oregular".""oregular"."UpdatePurchaseDocumentType"";
DROP TYPE IF EXISTS "oregular".""oregular"."DownloadedEInvoicePurchaseDocumentType"";
DROP TYPE IF EXISTS "oregular".""oregular"."GenerateItcDashboardLiabilityComplianceReportParamsType"";
DROP TYPE IF EXISTS "oregular".""oregular"."DownloadedEInvoicePurchaseDocumentPaymentType"";
DROP TYPE IF EXISTS "oregular".""oregular"."DownloadedEInvoicePurchaseDocumentItemType"";
DROP TYPE IF EXISTS "oregular".""oregular"."DownloadedEInvoicePurchaseDocumentContactType"";
DROP TYPE IF EXISTS "oregular".""oregular"."DownloadedEInvoicePurchaseDocumentSignedDetailType"";
DROP TYPE IF EXISTS "tds".""tds"."DownloadedEInvoiceDocumentSignedDetailType"";
DROP TYPE IF EXISTS "tds".""tds"."DownloadedEInvoiceDocumentType"";
DROP TYPE IF EXISTS "tds".""tds"."DownloadedEInvoiceDocumentItemType"";
DROP TYPE IF EXISTS "tds".""tds"."DownloadedEInvoiceDocumentContactType"";

