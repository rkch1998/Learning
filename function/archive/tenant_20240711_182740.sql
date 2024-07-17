DROP FUNCTION IF EXISTS report."GetAll3WayReconciliationReportByIds";

CREATE OR REPLACE FUNCTION report."GetAll3WayReconciliationReportByIds"("_SubscriberId" integer, "_Ids" report."ReconciliationHubTypeIdsType"[], "_MappingType" smallint, "_Purpose" smallint, "_IncludeAggregatedItems" boolean, "_SupplyTypes" character varying, "_SupplyTypeSale" smallint, "_SupplyTypePurchase" smallint, "_PurposeTypeGstVsEInvVsEwb" smallint, "_PurposeTypeGstVsSaleAutoDraftVsEInv" smallint, "_PurposeTypeGstVsPurchaseAutoDraft" smallint, "_PurposeTypeEInvQRCodeVsPurchaseAutoDraft" smallint, "_ContactBillFromType" smallint, "_ContactBillToType" smallint)
 RETURNS TABLE("EntityId" integer, "DocumentNumber" character varying, "DocumentType" smallint, "GstDocumentDate" timestamp without time zone, "EinvDocumentDate" timestamp without time zone, "EwbDocumentDate" timestamp without time zone, "GstDocumentValue" numeric, "EinvDocumentValue" numeric, "EwbDocumentValue" numeric, "GstDocumentTaxableValue" numeric, "EinvDocumentTaxableValue" numeric, "EwbDocumentTaxableValue" numeric, "GstDocumentTaxValue" numeric, "EinvDocumentTaxValue" numeric, "EwbDocumentTaxValue" numeric, "GstIrn" character varying, "EinvIrn" character varying, "EwbIrn" character varying, "EwbNumber" bigint, "PartBStatus" smallint, "GstTransactionType" smallint, "EinvTransactionType" smallint, "EwbTransactionType" smallint, "IsAmendment" boolean, "GstReverseCharge" boolean, "EInvReverseCharge" boolean, "EwbReverseCharge" boolean, "GstPos" smallint, "EinvPos" smallint, "EwbPos" smallint, "GstBillFromGstin" character varying, "EinvBillFromGstin" character varying, "EwbBillFromGstin" character varying, "GstBillFromTradeName" character varying, "EinvBillFromTradeName" character varying, "EwbBillFromTradeName" character varying, "GstBillFromLegalName" character varying, "EinvBillFromLegalName" character varying, "EwbBillFromLegalName" character varying, "GstBillToGstin" character varying, "EinvBillToGstin" character varying, "EwbBillToGstin" character varying, "GstBillToTradeName" character varying, "EinvBillToTradeName" character varying, "EwbBillToTradeName" character varying, "GstBillToLegalName" character varying, "EinvBillToLegalName" character varying, "EwbBillToLegalName" character varying, "GstVsEinvSection" smallint, "GstVsEinvReasonParameters" character varying, "GstVsEwbSection" smallint, "GstVsEwbReasonParameters" character varying, "EinvVsGstSection" smallint, "EinvVsGstReasonParameters" character varying, "EinvVsEwbSection" smallint, "EinvVsEwbReasonParameters" character varying, "EwbVsEinvSection" smallint, "EwbVsEinvReasonParameters" character varying, "EwbVsGstSection" smallint, "EwbVsGstReasonParameters" character varying, "GstinStatus" integer, "GstinTaxpayerType" smallint, "GstCustom1" character varying, "EinvCustom1" character varying, "EwbCustom1" character varying, "GstCustom2" character varying, "EinvCustom2" character varying, "EwbCustom2" character varying, "GstCustom3" character varying, "EinvCustom3" character varying, "EwbCustom3" character varying, "GstCustom4" character varying, "EinvCustom4" character varying, "EwbCustom4" character varying, "GstCustom5" character varying, "EinvCustom5" character varying, "EwbCustom5" character varying, "GstCustom6" character varying, "EinvCustom6" character varying, "EwbCustom6" character varying, "GstCustom7" character varying, "EinvCustom7" character varying, "EwbCustom7" character varying, "GstCustom8" character varying, "EinvCustom8" character varying, "EwbCustom8" character varying, "GstCustom9" character varying, "EinvCustom9" character varying, "EwbCustom9" character varying, "GstCustom10" character varying, "EinvCustom10" character varying, "EwbCustom10" character varying, "GstHsnOrSacCode" character varying, "EinvHsnOrSacCode" character varying, "EwbHsnOrSacCode" character varying, "GstDescription" character varying, "EinvDescription" character varying, "EwbDescription" character varying, "GstUqc" character varying, "EinvUqc" character varying, "EwbUqc" character varying, "GstQuantity" numeric, "EinvQuantity" numeric, "EwbQuantity" numeric, "GstPricePerQuantity" numeric, "EinvPricePerQuantity" numeric, "EwbPricePerQuantity" numeric, "GstRate" numeric, "EinvRate" numeric, "EwbRate" numeric, "GstCessRate" numeric, "EinvCessRate" numeric, "EwbCessRate" numeric, "GstStateCessRate" numeric, "EinvStateCessRate" numeric, "EwbStateCessRate" numeric, "GstCessNonAdvaloremRate" numeric, "EinvCessNonAdvaloremRate" numeric, "EwbCessNonAdvaloremRate" numeric, "GstOtherCharges" numeric, "EinvOtherCharges" numeric, "EwbOtherCharges" numeric, "GstTaxableValue" numeric, "EinvTaxableValue" numeric, "EwbTaxableValue" numeric, "GstIgstAmount" numeric, "EinvIgstAmount" numeric, "EwbIgstAmount" numeric, "GstCgstAmount" numeric, "EinvCgstAmount" numeric, "EwbCgstAmount" numeric, "GstSgstAmount" numeric, "EinvSgstAmount" numeric, "EwbSgstAmount" numeric, "GstCessAmount" numeric, "EinvCessAmount" numeric, "EwbCessAmount" numeric, "GstStateCessAmount" numeric, "EinvStateCessAmount" numeric, "EwbStateCessAmount" numeric, "GstCessNonAdvaloremAmount" numeric, "EinvCessNonAdvaloremAmount" numeric, "EwbCessNonAdvaloremAmount" numeric, "GstStateCessNonAdvaloremAmount" numeric, "EinvStateCessNonAdvaloremAmount" numeric, "EwbStateCessNonAdvaloremAmount" numeric, "GstItemTotal" integer, "EinvItemTotal" integer, "EwbItemTotal" integer, "Remarks" character varying, "GstBillFromStateCode" smallint, "GstBillToStateCode" smallint, "EinvBillFromStateCode" smallint, "EinvBillToStateCode" smallint, "EwbBillFromStateCode" smallint, "EwbBillToStateCode" smallint, "GstPushStatus" smallint, "EinvPushStatus" smallint, "EwbPushStatus" smallint)
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: temp."Get3WayReconciliationReportByIds"
*	Comments		: 2024-06-29 | Shambhu Das | This procedure is used to get reco hub report all column data by export.
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	:

DROP TABLE IF EXISTS "TempReconciliationHub";
CREATE TEMP TABLE "TempReconciliationHub" of report."ReconciliationHubTypeIdsType";
INSERT INTO "TempReconciliationHub"
SELECT 
    (Pr ->> 'MapperId')::bigint AS "MapperId",
	(Pr ->> 'EInvId')::bigint AS "EInvId",
	(Pr ->> 'EwbId')::bigint AS "EwbId",
	(Pr ->> 'SaleId')::bigint AS "SaleId",
	(Pr ->> 'PurchaseId')::bigint AS "PurchaseId",
	(Pr ->> 'SaleAutoDraftId')::bigint AS "SaleAutoDraftId",
	(Pr ->> 'PurchaseAutoDraftId')::bigint AS "PurchaseAutoDraftId",
	(Pr ->> 'Purpose')::smallint AS "Purpose",
	(Pr ->> 'EinvQrId')::bigint AS "EinvQrId" 
FROM 
    JSON_ARRAY_ELEMENTS('[{"MapperId":0,"EInvId":141074,"EwbId":141074,"SaleId":507408,"PurchaseId":0,"SaleAutoDraftId":507257,"PurchaseAutoDraftId":0,"Purpose":16,"EinvQrId":0}]'::JSON) Pr;

SELECT * FROM report."GetAll3WayReconciliationReportByIds"
(
	"_Ids"=>ARRAY(SELECT ROW(s.*)::report."ReconciliationHubTypeIdsType" FROM "TempReconciliationHub" s)::report."ReconciliationHubTypeIdsType"[],
	"_SubscriberId"=>5187::INT,
	"_Purpose"=>1::SMALLINT,
	"_IncludeAggregatedItems"=>False::BOOLEAN,
	"_MappingType"=>2::SMALLINT,
	"_SupplyTypes" => '1'::Character varying,
	"_SupplyTypeSale"=>1::SMALLINT,
	"_SupplyTypePurchase"=>2::SMALLINT,
	"_PurposeTypeGstVsEInvVsEwb" => 1::smallint,
	"_PurposeTypeGstVsSaleAutoDraftVsEInv" => 2::smallint,
	"_PurposeTypeGstVsPurchaseAutoDraft" => 3::smallint,
	"_PurposeTypeEInvQRCodeVsPurchaseAutoDraft" => 4::smallint,
	"_ContactBillFromType" => 1 ::smallint,
    "_ContactBillToType" => 3::smallint
);
							
--------------------------------------------------------------------------------------------------------------------------------------*/
DECLARE

		"_SupplyType" smallint;

BEGIN
	
	SELECT
		"SupplyType"::SMALLINT
	INTO
		"_SupplyType"
	FROM
		UNNEST(STRING_TO_ARRAY("_SupplyTypes", ',')) AS "SupplyType";
	
	DROP TABLE IF EXISTS "TempRecoMapperIds";
	CREATE TEMP TABLE "TempRecoMapperIds"
	(
		"AutoId" SERIAL,
		"Id" BIGINT,
		"EInvId" BIGINT,
		"EwbId" BIGINT,
		"SaleId" BIGINT,
		"PurchaseId" BIGINT,
		"SaleAutoDraftId" BIGINT,
		"PurchaseAutoDraftId" BIGINT,
		"Purpose" SMALLINT,
		"EinvQrId" bigint
	);

	INSERT INTO "TempRecoMapperIds"
	(
		"Id",
		"EInvId",
		"EwbId",
		"SaleId",
		"PurchaseId",
		"SaleAutoDraftId",
		"PurchaseAutoDraftId",
		"Purpose",
		"EinvQrId"
	)
	SELECT
		a."MapperId" ,
		CASE WHEN a."EInvId" = 0 THEN NULL::BIGINT ELSE a."EInvId" END ,
		CASE WHEN a."EwbId" = 0 THEN NULL::BIGINT ELSE a."EwbId" END ,
		CASE WHEN a."SaleId" = 0 THEN NULL::BIGINT ELSE a."SaleId" END ,
		CASE WHEN a."PurchaseId" = 0 THEN NULL::BIGINT ELSE a."PurchaseId" END ,
		CASE WHEN a."SaleAutoDraftId" = 0 THEN NULL::BIGINT ELSE a."SaleAutoDraftId" END ,
		CASE WHEN a."PurchaseAutoDraftId" = 0 THEN NULL::BIGINT ELSE a."PurchaseAutoDraftId" END ,
		a."Purpose",
		CASE WHEN a."EinvQrId" = 0 THEN NULL::BIGINT ELSE a."EinvQrId" END
	FROM
		UNNEST("_Ids") AS "a";
		
	DROP TABLE IF EXISTS "TempEinvoiceDocumentItemIds";
	CREATE TEMP TABLE "TempEinvoiceDocumentItemIds"  AS
	SELECT
		di."Id" AS "DocumentItemId"
	FROM
		"TempRecoMapperIds" AS Ids	
		INNER JOIN einvoice."DocumentItems" AS di ON ids."EInvId" = di."DocumentId"
	WHERE
		ids."EInvId" IS NOT NULL;
	
	IF ("_IncludeAggregatedItems" = false)
	THEN
		DROP TABLE IF EXISTS "TempEinvoiceItemDetails";
		CREATE TEMP TABLE "TempEinvoiceItemDetails" AS
		SELECT 
			edi."DocumentId",
			edi."Hsn" AS "HsnOrSacCode",
			edi."Name",
			edi."Description",
			edi."Uqc",
			edi."Quantity",
			edi."PricePerQuantity",
			edi."Rate",
			edi."CessRate",
			edi."StateCessRate",
			edi."CessNonAdvaloremRate",
			NULL::numeric AS "TdsRate",
			edi."GrossAmount",
			edi."OtherCharges",
			edi."TaxableValue",
			edi."IgstAmount",
			edi."CgstAmount",
			edi."SgstAmount",
			edi."CessAmount",
			edi."StateCessAmount",
			edi."CessNonAdvaloremAmount",
			edi."StateCessNonAdvaloremAmount",
			NULL::numeric AS "TdsAmount",
			edi."ItemTotal"::int AS "ItemTotal"
		FROM
			"TempEinvoiceDocumentItemIds" AS Ids	
			INNER JOIN einvoice."DocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId";
			
	ELSE
		DROP TABLE IF EXISTS "TempEinvoiceItemDetails";
		CREATE TEMP TABLE "TempEinvoiceItemDetails" AS
		SELECT 
			edi."DocumentId" AS "DocumentId",
			NULL::character varying AS "HsnOrSacCode",
			NULL::character varying AS "Name",
			NULL::character varying AS "Description",
			NULL::character varying AS "Uqc",
			NULL::numeric AS "Quantity",
			NULL::numeric AS "PricePerQuantity",
			NULL::numeric AS "Rate",
			NULL::numeric AS "CessRate",
			NULL::numeric AS "StateCessRate",
			NULL::numeric AS "CessNonAdvaloremRate",
			NULL::numeric AS "TdsRate",
			SUM(edi."GrossAmount") AS "GrossAmount",
			SUM(edi."OtherCharges") AS "OtherCharges",
			SUM(edi."TaxableValue") AS "TaxableValue",
			SUM(edi."IgstAmount") AS "IgstAmount",
			SUM(edi."CgstAmount") AS "CgstAmount",
			SUM(edi."SgstAmount") AS "SgstAmount",
			SUM(edi."CessAmount") AS "CessAmount",
			SUM(edi."StateCessAmount") AS "StateCessAmount",
			SUM(edi."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(edi."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			NULL::numeric AS "TdsAmount",
			SUM(edi."ItemTotal")::int AS "ItemTotal"
		FROM
			"TempEinvoiceDocumentItemIds" AS Ids	
			INNER JOIN einvoice."DocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId"
		GROUP BY
			edi."DocumentId";		
	END IF;

	DROP TABLE IF EXISTS "TempEinvoiceBillFromContacts";
	CREATE TEMP TABLE "TempEinvoiceBillFromContacts" AS
	SELECT 
		dc."DocumentId",
		dc."Gstin" AS "BillFromGstin",
		dc."TradeName" AS "BillFromTradeName",
		dc."LegalName" AS "BillFromLegalName",
		dc."AddressLine1" AS "BillFromAddress1",
		dc."AddressLine2" AS "BillFromAddress2",
		dc."City" AS "BillFromCity",
		dc."StateCode" AS "BillFromStateCode",
		dc."Pincode" AS "BillFromPin"
	FROM 
		"TempRecoMapperIds" AS Ids
		INNER JOIN einvoice."DocumentContacts" dc on Ids."EInvId" = dc."DocumentId"
	WHERE
		Ids."EInvId" IS NOT NULL
		AND dc."Type" = "_ContactBillFromType";

	DROP TABLE IF EXISTS "TempEinvoiceBillToContacts";
	CREATE TEMP TABLE "TempEinvoiceBillToContacts" AS
	SELECT 
		dc."DocumentId",
		dc."Gstin" AS "BillToGstin",
		dc."TradeName" AS "BillToTradeName",
		dc."LegalName" AS "BillToLegalName",
		dc."AddressLine1" AS "BillToAddress1",
		dc."AddressLine2" AS "BillToAddress2",
		dc."City" AS "BillToCity",
		dc."StateCode" AS "BillToStateCode",
		dc."Pincode" AS "BillToPin"
	FROM 
		"TempRecoMapperIds" AS Ids
		INNER JOIN einvoice."DocumentContacts" dc on Ids."EInvId" = dc."DocumentId"
	WHERE
		Ids."EInvId" IS NOT NULL
		AND dc."Type" = "_ContactBillToType";
		
	DROP TABLE IF EXISTS "TempEwaybillDocumentItemIds";
	CREATE TEMP TABLE "TempEwaybillDocumentItemIds"  AS
	SELECT
		di."Id" AS "DocumentItemId"
	FROM
		"TempRecoMapperIds" AS Ids	
		INNER JOIN einvoice."DocumentItems" AS di ON ids."EwbId" = di."DocumentId"
	WHERE
		ids."EwbId" IS NOT NULL;
	
	IF ("_IncludeAggregatedItems" = false)
	THEN
		DROP TABLE IF EXISTS "TempEwaybillItemDetails";
		CREATE TEMP TABLE "TempEwaybillItemDetails" AS
		SELECT 
			edi."DocumentId",
			edi."Hsn" AS "HsnOrSacCode",
			edi."Name",
			edi."Description",
			edi."Uqc",
			edi."Quantity",
			edi."PricePerQuantity",
			edi."Rate",
			edi."CessRate",
			edi."StateCessRate",
			edi."CessNonAdvaloremRate",
			NULL::numeric AS "TdsRate",
			edi."GrossAmount",
			edi."OtherCharges",
			edi."TaxableValue",
			edi."IgstAmount",
			edi."CgstAmount",
			edi."SgstAmount",
			edi."CessAmount",
			edi."StateCessAmount",
			edi."CessNonAdvaloremAmount",
			edi."StateCessNonAdvaloremAmount",
			NULL::numeric AS "TdsAmount",
			edi."ItemTotal"::int AS "ItemTotal"
		FROM
			"TempEwaybillDocumentItemIds" AS Ids	
			INNER JOIN einvoice."DocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId";
	ELSE
		DROP TABLE IF EXISTS "TempEwaybillItemDetails";
		CREATE TEMP TABLE "TempEwaybillItemDetails" AS
		SELECT 
			edi."DocumentId" AS "DocumentId",
			NULL::character varying AS "HsnOrSacCode",
			NULL::character varying AS "Name",
			NULL::character varying AS "Description",
			NULL::character varying AS "Uqc",
			NULL::numeric AS "Quantity",
			NULL::numeric AS "PricePerQuantity",
			NULL::numeric AS "Rate",
			NULL::numeric AS "CessRate",
			NULL::numeric AS "StateCessRate",
			NULL::numeric AS "CessNonAdvaloremRate",
			NULL::numeric AS "TdsRate",
			SUM(edi."GrossAmount") AS "GrossAmount",
			SUM(edi."OtherCharges") AS "OtherCharges",
			SUM(edi."TaxableValue") AS "TaxableValue",
			SUM(edi."IgstAmount") AS "IgstAmount",
			SUM(edi."CgstAmount") AS "CgstAmount",
			SUM(edi."SgstAmount") AS "SgstAmount",
			SUM(edi."CessAmount") AS "CessAmount",
			SUM(edi."StateCessAmount") AS "StateCessAmount",
			SUM(edi."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(edi."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			NULL::numeric AS "TdsAmount",
			SUM(edi."ItemTotal")::int AS "ItemTotal"
		FROM
			"TempEwaybillDocumentItemIds" AS Ids	
			INNER JOIN einvoice."DocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId"
		GROUP BY
			edi."DocumentId";		
	END IF;

	DROP TABLE IF EXISTS "TempEwaybillBillFromContacts";
	CREATE TEMP TABLE "TempEwaybillBillFromContacts" AS
	SELECT 
		dc."DocumentId",
		dc."Gstin" AS "BillFromGstin",
		dc."TradeName" AS "BillFromTradeName",
		dc."LegalName" AS "BillFromLegalName",
		dc."AddressLine1" AS "BillFromAddress1",
		dc."AddressLine2" AS "BillFromAddress2",
		dc."City" AS "BillFromCity",
		dc."StateCode" AS "BillFromStateCode",
		dc."Pincode" AS "BillFromPin"
	FROM 
		"TempRecoMapperIds" AS Ids
		INNER JOIN einvoice."DocumentContacts" dc on Ids."EwbId" = dc."DocumentId"
	WHERE
		Ids."EwbId" IS NOT NULL
		AND dc."Type" = "_ContactBillFromType";

	DROP TABLE IF EXISTS "TempEwaybillBillToContacts";
	CREATE TEMP TABLE "TempEwaybillBillToContacts" AS
	SELECT 
		dc."DocumentId",
		dc."Gstin" AS "BillToGstin",
		dc."TradeName" AS "BillToTradeName",
		dc."LegalName" AS "BillToLegalName",
		dc."AddressLine1" AS "BillToAddress1",
		dc."AddressLine2" AS "BillToAddress2",
		dc."City" AS "BillToCity",
		dc."StateCode" AS "BillToStateCode",
		dc."Pincode" AS "BillToPin"
	FROM 
		"TempRecoMapperIds" AS Ids
		INNER JOIN einvoice."DocumentContacts" dc on Ids."EwbId" = dc."DocumentId"
	WHERE
		Ids."EwbId" IS NOT NULL
		AND dc."Type" = "_ContactBillToType";
		
	IF "_SupplyType" = "_SupplyTypeSale"
	THEN
		DROP TABLE IF EXISTS "TempSaleDocumentItemIds";
		CREATE TEMP TABLE "TempSaleDocumentItemIds"  AS
		SELECT
			di."Id" AS "DocumentItemId"
		FROM
			"TempRecoMapperIds" AS Ids	
			INNER JOIN oregular."SaleDocumentItems" AS di ON ids."SaleId" = di."SaleDocumentId"
		WHERE
			ids."SaleId" IS NOT NULL;
			
		IF ("_IncludeAggregatedItems" = false)
		THEN
			DROP TABLE IF EXISTS "TempSaleItemDetails";
			CREATE TEMP TABLE "TempSaleItemDetails" AS
			SELECT 
				edi."SaleDocumentId" AS "DocumentId",
				edi."Hsn" AS "HsnOrSacCode",
				edi."Name",
				edi."Description",
				edi."Uqc",
				edi."Quantity",
				edi."PricePerQuantity",
				edi."Rate",
				edi."CessRate",
				edi."StateCessRate",
				edi."CessNonAdvaloremRate",
				NULL::numeric AS "TdsRate",
				edi."GrossAmount",
				edi."OtherCharges",
				edi."TaxableValue",
				edi."IgstAmount",
				edi."CgstAmount",
				edi."SgstAmount",
				edi."CessAmount",
				edi."StateCessAmount",
				edi."CessNonAdvaloremAmount",
				edi."StateCessNonAdvaloremAmount",
				NULL::numeric AS "TdsAmount",
				NULL::int AS "ItemTotal"
			FROM
				"TempSaleDocumentItemIds" AS Ids	
				INNER JOIN oregular."SaleDocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId";
		ELSE
			DROP TABLE IF EXISTS "TempSaleItemDetails";
			CREATE TEMP TABLE "TempSaleItemDetails" AS
			SELECT 
				edi."SaleDocumentId" AS "DocumentId",
				NULL::character varying AS "HsnOrSacCode",
				NULL::character varying AS "Name",
				NULL::character varying AS "Description",
				NULL::character varying AS "Uqc",
				NULL::numeric AS "Quantity",
				NULL::numeric AS "PricePerQuantity",
				NULL::numeric AS "Rate",
				NULL::numeric AS "CessRate",
				NULL::numeric AS "StateCessRate",
				NULL::numeric AS "CessNonAdvaloremRate",
				NULL::numeric AS "TdsRate",
				SUM(edi."GrossAmount") AS "GrossAmount",
				SUM(edi."OtherCharges") AS "OtherCharges",
				SUM(edi."TaxableValue") AS "TaxableValue",
				SUM(edi."IgstAmount") AS "IgstAmount",
				SUM(edi."CgstAmount") AS "CgstAmount",
				SUM(edi."SgstAmount") AS "SgstAmount",
				SUM(edi."CessAmount") AS "CessAmount",
				SUM(edi."StateCessAmount") AS "StateCessAmount",
				SUM(edi."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
				SUM(edi."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
				NULL::numeric AS "TdsAmount",
				COUNT(*)::int AS "ItemTotal"
			FROM
				"TempSaleDocumentItemIds" AS Ids	
				INNER JOIN oregular."SaleDocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId"
			GROUP BY
				edi."SaleDocumentId";		
		END IF;

		DROP TABLE IF EXISTS "TempSaleBillFromContacts";
		CREATE TEMP TABLE "TempSaleBillFromContacts" AS
		SELECT 
			dc."SaleDocumentId" AS "DocumentId",
			dc."Gstin" AS "BillFromGstin",
			dc."TradeName" AS "BillFromTradeName",
			dc."LegalName" AS "BillFromLegalName",
			dc."AddressLine1" AS "BillFromAddress1",
			dc."AddressLine2" AS "BillFromAddress2",
			dc."City" AS "BillFromCity",
			dc."StateCode" AS "BillFromStateCode",
			dc."Pincode" AS "BillFromPin"
		FROM 
			"TempRecoMapperIds" AS Ids
			INNER JOIN oregular."SaleDocumentContacts" dc on Ids."SaleId" = dc."SaleDocumentId"
		WHERE
			Ids."SaleId" IS NOT NULL
			AND dc."Type" = "_ContactBillFromType";

		DROP TABLE IF EXISTS "TempSaleBillToContacts";
		CREATE TEMP TABLE "TempSaleBillToContacts" AS
		SELECT 
			dc."SaleDocumentId" AS "DocumentId",
			dc."Gstin" AS "BillToGstin",
			dc."TradeName" AS "BillToTradeName",
			dc."LegalName" AS "BillToLegalName",
			dc."AddressLine1" AS "BillToAddress1",
			dc."AddressLine2" AS "BillToAddress2",
			dc."City" AS "BillToCity",
			dc."StateCode" AS "BillToStateCode",
			dc."Pincode" AS "BillToPin"
		FROM 
			"TempRecoMapperIds" AS Ids
			INNER JOIN oregular."SaleDocumentContacts" dc on Ids."SaleId" = dc."SaleDocumentId"
		WHERE
			Ids."SaleId" IS NOT NULL
			AND dc."Type" = "_ContactBillToType";
	END IF;
		
	IF "_SupplyType" = "_SupplyTypePurchase"
	THEN
		DROP TABLE IF EXISTS "TempPurchaseDocumentItemIds";
		CREATE TEMP TABLE "TempPurchaseDocumentItemIds"  AS
		SELECT
			di."Id" AS "DocumentItemId"
		FROM
			"TempRecoMapperIds" AS Ids	
			INNER JOIN oregular."PurchaseDocumentItems" AS di ON ids."PurchaseId" = di."PurchaseDocumentId"
		WHERE
			ids."PurchaseId" IS NOT NULL;
			
		IF ("_IncludeAggregatedItems" = false)
		THEN
			DROP TABLE IF EXISTS "TempPurchaseItemDetails";
			CREATE TEMP TABLE "TempPurchaseItemDetails" AS
			SELECT 
				edi."PurchaseDocumentId" AS "DocumentId",
				edi."Hsn" AS "HsnOrSacCode",
				edi."Name",
				edi."Description",
				edi."Uqc",
				edi."Quantity",
				edi."PricePerQuantity",
				edi."Rate",
				edi."CessRate",
				edi."StateCessRate",
				edi."CessNonAdvaloremRate",
				NULL::numeric AS "TdsRate",
				edi."GrossAmount",
				edi."OtherCharges",
				edi."TaxableValue",
				edi."IgstAmount",
				edi."CgstAmount",
				edi."SgstAmount",
				edi."CessAmount",
				edi."StateCessAmount",
				edi."CessNonAdvaloremAmount",
				edi."StateCessNonAdvaloremAmount",
				NULL::numeric AS "TdsAmount",
				NULL::int AS "ItemTotal"
			FROM
				"TempPurchaseDocumentItemIds" AS Ids	
				INNER JOIN oregular."PurchaseDocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId";
		ELSE
			DROP TABLE IF EXISTS "TempPurchaseItemDetails";
			CREATE TEMP TABLE "TempPurchaseItemDetails" AS
			SELECT 
				edi."PurchaseDocumentId" AS "DocumentId",
				NULL::character varying AS "HsnOrSacCode",
				NULL::character varying AS "Name",
				NULL::character varying AS "Description",
				NULL::character varying AS "Uqc",
				NULL::numeric AS "Quantity",
				NULL::numeric AS "PricePerQuantity",
				NULL::numeric AS "Rate",
				NULL::numeric AS "CessRate",
				NULL::numeric AS "StateCessRate",
				NULL::numeric AS "CessNonAdvaloremRate",
				NULL::numeric AS "TdsRate",
				SUM(edi."GrossAmount") AS "GrossAmount",
				SUM(edi."OtherCharges") AS "OtherCharges",
				SUM(edi."TaxableValue") AS "TaxableValue",
				SUM(edi."IgstAmount") AS "IgstAmount",
				SUM(edi."CgstAmount") AS "CgstAmount",
				SUM(edi."SgstAmount") AS "SgstAmount",
				SUM(edi."CessAmount") AS "CessAmount",
				SUM(edi."StateCessAmount") AS "StateCessAmount",
				SUM(edi."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
				SUM(edi."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
				NULL::numeric AS "TdsAmount",
				COUNT(*)::int AS "ItemTotal"
			FROM
				"TempPurchaseDocumentItemIds" AS Ids	
				INNER JOIN oregular."PurchaseDocumentItems" AS edi ON edi."Id" = Ids."DocumentItemId"
			GROUP BY
				edi."PurchaseDocumentId";		
		END IF;

		DROP TABLE IF EXISTS "TempPurchaseBillFromContacts";
		CREATE TEMP TABLE "TempPurchaseBillFromContacts" AS
		SELECT 
			dc."PurchaseDocumentId" AS "DocumentId",
			dc."Gstin" AS "BillFromGstin",
			dc."TradeName" AS "BillFromTradeName",
			dc."LegalName" AS "BillFromLegalName",
			dc."AddressLine1" AS "BillFromAddress1",
			dc."AddressLine2" AS "BillFromAddress2",
			dc."City" AS "BillFromCity",
			dc."StateCode" AS "BillFromStateCode",
			dc."Pincode" AS "BillFromPin"
		FROM 
			"TempRecoMapperIds" AS Ids
			INNER JOIN oregular."PurchaseDocumentContacts" dc on Ids."PurchaseId" = dc."PurchaseDocumentId"
		WHERE
			Ids."PurchaseId" IS NOT NULL
			AND dc."Type" = "_ContactBillFromType";

		DROP TABLE IF EXISTS "TempPurchaseBillToContacts";
		CREATE TEMP TABLE "TempPurchaseBillToContacts" AS
		SELECT 
			dc."PurchaseDocumentId" AS "DocumentId",
			dc."Gstin" AS "BillToGstin",
			dc."TradeName" AS "BillToTradeName",
			dc."LegalName" AS "BillToLegalName",
			dc."AddressLine1" AS "BillToAddress1",
			dc."AddressLine2" AS "BillToAddress2",
			dc."City" AS "BillToCity",
			dc."StateCode" AS "BillToStateCode",
			dc."Pincode" AS "BillToPin"
		FROM 
			"TempRecoMapperIds" AS Ids
			INNER JOIN oregular."PurchaseDocumentContacts" dc on Ids."PurchaseId" = dc."PurchaseDocumentId"
		WHERE
			Ids."PurchaseId" IS NOT NULL
			AND dc."Type" = "_ContactBillToType";
	END IF;
	
	DROP TABLE IF EXISTS "TempEInvoiceRecoHubData";
	CREATE TEMP TABLE "TempEInvoiceRecoHubData" AS
	SELECT
		ROW_NUMBER() OVER(PARTITION BY ed."Id" ORDER BY ed."Id", teid."Rate") AS "RowNum",
		rm."Id" AS "MapperId",
		rm."EInvId",
		rm."GstId",
		rm."GstSection" AS "EinvVsGstSection",		
		rm."GstReason" AS "EinvVsGstReasonParameters",
		rm."EWBId",		
		rm."EwbSection" AS "EinvVsEwbSection",
		rm."Ewbeason" AS "EinvVsEwbReasonParameters",
		
		ed."EntityId",
		ed."DocumentNumber",
		ed."Type" AS "DocumentType",
		ed."DocumentDate" AS "EinvDocumentDate",
		ed."DocumentValue" AS "EinvDocumentValue",
		ed."TotalTaxableValue" AS "EinvDocumentTaxableValue",
		ed."TotalTaxAmount" AS "EinvDocumentTaxValue",
		ed."TransactionType" AS "EinvTransactionType",
		ed."ReverseCharge" AS "EinvReverseCharge",
		ed."Pos" AS "EinvPos",
		
		eds."Irn" AS "EinvIrn",	
		eds."PushStatus" AS "EinvPushStatus",
		eds."RecoHubRemarks" AS "Remarks",
		
		tebfc."BillFromGstin" AS "EinvBillFromGstin",
		tebfc."BillFromTradeName" AS "EinvBillFromTradeName",
		tebfc."BillFromLegalName" AS "EinvBillFromLegalName",
		tebfc."BillFromStateCode" AS "EinvBillFromStateCode",
		
		tebtc."BillToGstin" AS "EinvBillToGstin",
		tebtc."BillToTradeName" AS "EinvBillToTradeName",
		tebtc."BillToLegalName" AS "EinvBillToLegalName",
		tebtc."BillToStateCode" AS "EinvBillToStateCode",
		
		edc."Custom1" AS "EinvCustom1",
		edc."Custom2" AS "EinvCustom2",
		edc."Custom3" AS "EinvCustom3",
		edc."Custom4" AS "EinvCustom4",
		edc."Custom5" AS "EinvCustom5",
		edc."Custom6" AS "EinvCustom6",
		edc."Custom7" AS "EinvCustom7",
		edc."Custom8" AS "EinvCustom8",
		edc."Custom9" AS "EinvCustom9",
		edc."Custom10" AS "EinvCustom10",		
		
		teid."HsnOrSacCode"::character varying AS "EinvHsnOrSacCode",
		teid."Description"::character varying AS "EinvDescription",
		teid."Uqc"::character varying AS "EinvUqc",
		teid."Quantity"::numeric AS "EinvQuantity",
		teid."PricePerQuantity"::numeric AS "EinvPricePerQuantity",
		teid."Rate"::numeric AS "EinvRate",
		teid."CessRate"::numeric AS "EinvCessRate",
		teid."StateCessRate"::numeric AS "EinvStateCessRate",
		teid."CessNonAdvaloremRate"::numeric AS "EinvCessNonAdvaloremRate",
		teid."OtherCharges"::numeric AS "EinvOtherCharges",
		teid."TaxableValue"::numeric AS "EinvTaxableValue",
		teid."IgstAmount"::numeric AS "EinvIgstAmount",
		teid."CgstAmount"::numeric AS "EinvCgstAmount",
		teid."SgstAmount"::numeric AS "EinvSgstAmount",
		teid."CessAmount"::numeric AS "EinvCessAmount",
		teid."StateCessAmount"::numeric AS "EinvStateCessAmount",
		teid."CessNonAdvaloremAmount"::numeric AS "EinvCessNonAdvaloremAmount",
		teid."StateCessNonAdvaloremAmount"::numeric AS "EinvStateCessNonAdvaloremAmount",
		teid."ItemTotal" AS "EinvItemTotal"
	FROM
		"TempRecoMapperIds" AS Ids
		INNER JOIN report."EinvoiceRecoMapper" AS rm ON rm."EInvId" = Ids."EInvId" AND rm."MappingType" = "_MappingType"
		INNER JOIN einvoice."Documents" AS ed ON ed."Id" = Ids."EInvId"
		INNER JOIN einvoice."DocumentStatus" AS eds ON eds."DocumentId" = ed."Id"
		LEFT JOIN einvoice."DocumentCustoms" AS edc ON ed."Id" = edc."DocumentId"
		LEFT JOIN "TempEinvoiceItemDetails" AS teid ON teid."DocumentId" = ed."Id"
		LEFT JOIN "TempEinvoiceBillFromContacts" AS tebfc ON tebfc."DocumentId" = ed."Id"
		LEFT JOIN "TempEinvoiceBillToContacts" AS tebtc ON tebtc."DocumentId" = ed."Id"
	WHERE
		Ids."EInvId" IS NOT NULL;
	
	DROP TABLE IF EXISTS "TempEwaybillRecoHubData";
	CREATE TEMP TABLE "TempEwaybillRecoHubData" AS
	SELECT
		ROW_NUMBER() OVER(PARTITION BY ed."Id" ORDER BY ed."Id", teid."Rate") AS "RowNum",
		rm."Id" AS "MapperId",
		rm."EWBId" AS "EwbId",
		rm."GstType",		
		rm."EInvId",
		rm."EInvSection" AS "EwbVsEinvSection",		
		rm."EInvReason" AS "EwbVsEinvReasonParameters",
		rm."GstId",
		rm."GstSection" AS "EwbVsGstSection",
		rm."GstReason" AS "EwbVsGstReasonParameters",
		
		ed."EntityId",
		ed."DocumentNumber",
		ed."Type" AS "DocumentType",
		ed."DocumentDate" AS "EwbDocumentDate",
		ed."DocumentValue" AS "EwbDocumentValue",
		ed."TotalTaxableValue" AS "EwbDocumentTaxableValue",
		ed."TotalTaxAmount" AS "EwbDocumentTaxValue",
		ed."TransactionType" AS "EwbTransactionType",
		ed."ReverseCharge" AS "EwbReverseCharge",
		ed."Pos" AS "EwbPos",
		
		eds."Irn" AS "EwbIrn",	
		eds."PushStatus" AS "EwbPushStatus",
		eds."RecoHubRemarks" AS "Remarks",
		eds."EwayBillNumber" AS	"EwbNumber",
		CASE WHEN eds."ValidUpto" IS NULL AND eds."EwayBillNumber" IS NOT NULL THEN 0  WHEN eds."ValidUpto" IS NOT NULL AND eds."EwayBillNumber" IS NOT NULL THEN 1  END::SMALLINT AS "PartBStatus",
		
		tebfc."BillFromGstin" AS "EwbBillFromGstin",
		tebfc."BillFromTradeName" AS "EwbBillFromTradeName",
		tebfc."BillFromLegalName" AS "EwbBillFromLegalName",
		tebfc."BillFromStateCode" AS "EwbBillFromStateCode",
		
		tebtc."BillToGstin" AS "EwbBillToGstin",
		tebtc."BillToTradeName" AS "EwbBillToTradeName",
		tebtc."BillToLegalName" AS "EwbBillToLegalName",
		tebtc."BillToStateCode" AS "EwbBillToStateCode",
		
		edc."Custom1" AS "EwbCustom1",
		edc."Custom2" AS "EwbCustom2",
		edc."Custom3" AS "EwbCustom3",
		edc."Custom4" AS "EwbCustom4",
		edc."Custom5" AS "EwbCustom5",
		edc."Custom6" AS "EwbCustom6",
		edc."Custom7" AS "EwbCustom7",
		edc."Custom8" AS "EwbCustom8",
		edc."Custom9" AS "EwbCustom9",
		edc."Custom10" AS "EwbCustom10",		
		
		teid."HsnOrSacCode"::character varying AS "EwbHsnOrSacCode",
		teid."Description"::character varying AS "EwbDescription",
		teid."Uqc"::character varying AS "EwbUqc",
		teid."Quantity"::numeric AS "EwbQuantity",
		teid."PricePerQuantity"::numeric AS "EwbPricePerQuantity",
		teid."Rate"::numeric AS "EwbRate",
		teid."CessRate"::numeric AS "EwbCessRate",
		teid."StateCessRate"::numeric AS "EwbStateCessRate",
		teid."CessNonAdvaloremRate"::numeric AS "EwbCessNonAdvaloremRate",
		teid."OtherCharges"::numeric AS "EwbOtherCharges",
		teid."TaxableValue"::numeric AS "EwbTaxableValue",
		teid."IgstAmount"::numeric AS "EwbIgstAmount",
		teid."CgstAmount"::numeric AS "EwbCgstAmount",
		teid."SgstAmount"::numeric AS "EwbSgstAmount",
		teid."CessAmount"::numeric AS "EwbCessAmount",
		teid."StateCessAmount"::numeric AS "EwbStateCessAmount",
		teid."CessNonAdvaloremAmount"::numeric AS "EwbCessNonAdvaloremAmount",
		teid."StateCessNonAdvaloremAmount"::numeric AS "EwbStateCessNonAdvaloremAmount",
		teid."ItemTotal" AS "EwbItemTotal"
	FROM
		"TempRecoMapperIds" AS Ids
		INNER JOIN report."EwaybillRecoMapper" AS rm ON rm."EWBId" = Ids."EwbId" AND rm."MappingType" = "_MappingType"
		LEFT JOIN einvoice."Documents" AS ed ON ed."Id" = Ids."EwbId"
		LEFT JOIN ewaybill."DocumentStatus" AS eds ON eds."DocumentId" = ed."Id"
		LEFT JOIN einvoice."DocumentCustoms" AS edc ON ed."Id" = edc."DocumentId"
		LEFT JOIN "TempEwaybillItemDetails" AS teid ON teid."DocumentId" = ed."Id"
		LEFT JOIN "TempEwaybillBillFromContacts" AS tebfc ON tebfc."DocumentId" = ed."Id"
		LEFT JOIN "TempEwaybillBillToContacts" AS tebtc ON tebtc."DocumentId" = ed."Id"		
	WHERE
		ids."EwbId" IS NOT NULL;
	
	IF "_SupplyType" = "_SupplyTypeSale"
	THEN
		DROP TABLE IF EXISTS "TempGstRecoHubData";
		CREATE TEMP TABLE "TempGstRecoHubData" AS
		SELECT
			ROW_NUMBER() OVER(PARTITION BY ed."Id" ORDER BY ed."Id", teid."Rate") AS "RowNum",
			rm."Id" AS "MapperId",
			rm."GstId",
			rm."GstType",
			rm."EInvId",
			rm."EInvSection" AS "GstVsEinvSection",
			rm."EInvReason" AS "GstVsEinvReasonParameters",
			rm."EWBId" AS "EwbId",
			rm."EWBSection" AS "GstVsEwbSection",
			rm."EwbReason" AS "GstVsEwbReasonParameters",
			rm."AutoDraftId" AS "SaleAutoDraftId",
			rm."AutoDraftSection" AS "GstVsDraftSection",
			rm."AutoDraftReason" AS "GstVsDraftReason",

			ed."EntityId",
			ed."DocumentNumber",
			ed."DocumentType" AS "DocumentType",
			ed."DocumentDate" AS "GstDocumentDate",
			ed."DocumentValue" AS "GstDocumentValue",
			ed."TotalTaxableValue" AS "GstDocumentTaxableValue",
			ed."TotalTaxAmount" AS "GstDocumentTaxValue",
			ed."TransactionType" AS "GstTransactionType",
			ed."ReverseCharge" AS "GstReverseCharge",
			ed."Pos" AS "GstPos",		
			ed."Irn" AS "GstIrn",
			ed."TaxpayerType" AS "GstinTaxpayerType",
			ed."IsAmendment",
			
			eds."PushStatus" AS "GstPushStatus",
			eds."RecoHubRemarks" AS "Remarks",

			tebfc."BillFromGstin" AS "GstBillFromGstin",
			tebfc."BillFromTradeName" AS "GstBillFromTradeName",
			tebfc."BillFromLegalName" AS "GstBillFromLegalName",
			tebfc."BillFromStateCode" AS "GstBillFromStateCode",

			tebtc."BillToGstin" AS "GstBillToGstin",
			tebtc."BillToTradeName" AS "GstBillToTradeName",
			tebtc."BillToLegalName" AS "GstBillToLegalName",
			tebtc."BillToStateCode" AS "GstBillToStateCode",

			edc."Custom1" AS "GstCustom1",
			edc."Custom2" AS "GstCustom2",
			edc."Custom3" AS "GstCustom3",
			edc."Custom4" AS "GstCustom4",
			edc."Custom5" AS "GstCustom5",
			edc."Custom6" AS "GstCustom6",
			edc."Custom7" AS "GstCustom7",
			edc."Custom8" AS "GstCustom8",
			edc."Custom9" AS "GstCustom9",
			edc."Custom10" AS "GstCustom10",		

			teid."HsnOrSacCode"::character varying AS "GstHsnOrSacCode",
			teid."Description"::character varying AS "GstDescription",
			teid."Uqc"::character varying AS "GstUqc",
			teid."Quantity"::numeric AS "GstQuantity",
			teid."PricePerQuantity"::numeric AS "GstPricePerQuantity",
			teid."Rate"::numeric AS "GstRate",
			teid."CessRate"::numeric AS "GstCessRate",
			teid."StateCessRate"::numeric AS "GstStateCessRate",
			teid."CessNonAdvaloremRate"::numeric AS "GstCessNonAdvaloremRate",
			teid."OtherCharges"::numeric AS "GstOtherCharges",
			teid."TaxableValue"::numeric AS "GstTaxableValue",
			teid."IgstAmount"::numeric AS "GstIgstAmount",
			teid."CgstAmount"::numeric AS "GstCgstAmount",
			teid."SgstAmount"::numeric AS "GstSgstAmount",
			teid."CessAmount"::numeric AS "GstCessAmount",
			teid."StateCessAmount"::numeric AS "GstStateCessAmount",
			teid."CessNonAdvaloremAmount"::numeric AS "GstCessNonAdvaloremAmount",
			teid."StateCessNonAdvaloremAmount"::numeric AS "GstStateCessNonAdvaloremAmount",
			teid."ItemTotal" AS "GstItemTotal"
		FROM 
			"TempRecoMapperIds" AS ids
			INNER JOIN report."GstRecoMapper" AS rm ON ids."SaleId" = rm."GstId" AND rm."GstType" = "_SupplyTypeSale" AND rm."MappingType" = "_MappingType"
			LEFT JOIN oregular."SaleDocuments" AS ed ON ed."Id" = Ids."SaleId"
			LEFT JOIN oregular."SaleDocumentStatus" AS eds ON eds."SaleDocumentId" = ed."Id"
			LEFT JOIN oregular."SaleDocumentCustoms" AS edc ON edc."SaleDocumentId" = ed."Id"
			LEFT JOIN "TempSaleItemDetails" AS teid ON teid."DocumentId" = ed."Id"
			LEFT JOIN "TempSaleBillFromContacts" AS tebfc ON tebfc."DocumentId" = ed."Id"
			LEFT JOIN "TempSaleBillToContacts" AS tebtc ON tebtc."DocumentId" = ed."Id"			
		WHERE
			ids."SaleId" IS NOT NULL;
	END IF;
		
	IF "_SupplyType" = "_SupplyTypePurchase"
	THEN
		DROP TABLE IF EXISTS "TempGstRecoHubData";
		CREATE TEMP TABLE "TempGstRecoHubData" AS
		SELECT		
			ROW_NUMBER() OVER(PARTITION BY ed."Id" ORDER BY ed."Id", teid."Rate") AS "RowNum",
            rm."Id" AS "MapperId",
			rm."GstId",
			rm."GstType",
			rm."EInvId",
			rm."EInvSection" AS "GstVsEinvSection",
			rm."EInvReason" AS "GstVsEinvReasonParameters",
			rm."EWBId" AS "EwbId",
			rm."EWBSection" AS "GstVsEwbSection",
			rm."EwbReason" AS "GstVsEwbReasonParameters",
			rm."AutoDraftId" AS "SaleAutoDraftId",
			rm."AutoDraftSection" AS "GstVsDraftSection",
			rm."AutoDraftReason" AS "GstVsDraftReason",

			ed."EntityId",
			ed."DocumentNumber",
			ed."DocumentType" AS "DocumentType",
			ed."DocumentDate" AS "GstDocumentDate",
			ed."DocumentValue" AS "GstDocumentValue",
			ed."TotalTaxableValue" AS "GstDocumentTaxableValue",
			ed."TotalTaxAmount" AS "GstDocumentTaxValue",
			ed."TransactionType" AS "GstTransactionType",
			ed."ReverseCharge" AS "GstReverseCharge",
			ed."Pos" AS "GstPos",		
			ed."Irn" AS "GstIrn",
			ed."TaxpayerType" AS "GstinTaxpayerType",
			ed."IsAmendment",

			eds."PushStatus" AS "GstPushStatus",
			eds."RecoHubRemarks" AS "Remarks",

			tebfc."BillFromGstin" AS "GstBillFromGstin",
			tebfc."BillFromTradeName" AS "GstBillFromTradeName",
			tebfc."BillFromLegalName" AS "GstBillFromLegalName",
			tebfc."BillFromStateCode" AS "GstBillFromStateCode",

			tebtc."BillToGstin" AS "GstBillToGstin",
			tebtc."BillToTradeName" AS "GstBillToTradeName",
			tebtc."BillToLegalName" AS "GstBillToLegalName",
			tebtc."BillToStateCode" AS "GstBillToStateCode",

			edc."Custom1" AS "GstCustom1",
			edc."Custom2" AS "GstCustom2",
			edc."Custom3" AS "GstCustom3",
			edc."Custom4" AS "GstCustom4",
			edc."Custom5" AS "GstCustom5",
			edc."Custom6" AS "GstCustom6",
			edc."Custom7" AS "GstCustom7",
			edc."Custom8" AS "GstCustom8",
			edc."Custom9" AS "GstCustom9",
			edc."Custom10" AS "GstCustom10",		

			teid."HsnOrSacCode"::character varying AS "GstHsnOrSacCode",
			teid."Description"::character varying AS "GstDescription",
			teid."Uqc"::character varying AS "GstUqc",
			teid."Quantity"::numeric AS "GstQuantity",
			teid."PricePerQuantity"::numeric AS "GstPricePerQuantity",
			teid."Rate"::numeric AS "GstRate",
			teid."CessRate"::numeric AS "GstCessRate",
			teid."StateCessRate"::numeric AS "GstStateCessRate",
			teid."CessNonAdvaloremRate"::numeric AS "GstCessNonAdvaloremRate",
			teid."OtherCharges"::numeric AS "GstOtherCharges",
			teid."TaxableValue"::numeric AS "GstTaxableValue",
			teid."IgstAmount"::numeric AS "GstIgstAmount",
			teid."CgstAmount"::numeric AS "GstCgstAmount",
			teid."SgstAmount"::numeric AS "GstSgstAmount",
			teid."CessAmount"::numeric AS "GstCessAmount",
			teid."StateCessAmount"::numeric AS "GstStateCessAmount",
			teid."CessNonAdvaloremAmount"::numeric AS "GstCessNonAdvaloremAmount",
			teid."StateCessNonAdvaloremAmount"::numeric AS "GstStateCessNonAdvaloremAmount",
			teid."ItemTotal" AS "GstItemTotal"
		FROM 
			"TempRecoMapperIds" AS ids
			INNER JOIN report."GstRecoMapper" AS rm ON ids."PurchaseId" = rm."GstId" AND rm."GstType" = "_SupplyTypePurchase" AND rm."MappingType" = "_MappingType"
			LEFT JOIN oregular."SaleDocuments" AS ed ON ed."Id" = Ids."PurchaseId"
			LEFT JOIN oregular."SaleDocumentStatus" AS eds ON eds."SaleDocumentId" = ed."Id"
			LEFT JOIN oregular."SaleDocumentCustoms" AS edc ON edc."SaleDocumentId" = ed."Id"
			LEFT JOIN "TempPurchaseItemDetails" AS teid ON teid."DocumentId" = ed."Id"
			LEFT JOIN "TempPurchaseBillFromContacts" AS tebfc ON tebfc."DocumentId" = ed."Id"
			LEFT JOIN "TempPurchaseBillToContacts" AS tebtc ON tebtc."DocumentId" = ed."Id"			
		WHERE
			ids."PurchaseId" IS NOT NULL;
	END IF;
			
	IF "_Purpose" = "_PurposeTypeGstVsEInvVsEwb"
	THEN
		RETURN QUERY
		SELECT
			COALESCE(einv."EntityId", ewb."EntityId", gst."EntityId")::integer AS "EntityId",
			COALESCE(einv."DocumentNumber", ewb."DocumentNumber", gst."DocumentNumber")::character varying AS "DocumentNumber",
			COALESCE(einv."DocumentType", ewb."DocumentType", gst."DocumentType")::smallint AS "DocumentType",
			gst."GstDocumentDate"::timestamp without time zone AS "GstDocumentDate",
			einv."EinvDocumentDate"::timestamp without time zone AS "EinvDocumentDate",
			ewb."EwbDocumentDate"::timestamp without time zone AS "EwbDocumentDate",
			gst."GstDocumentValue"::numeric,
			einv."EinvDocumentValue"::numeric,
			ewb."EwbDocumentValue"::numeric,
			gst."GstDocumentTaxableValue"::numeric,
			einv."EinvDocumentTaxableValue"::numeric,
			ewb."EwbDocumentTaxableValue"::numeric,
			gst."GstDocumentTaxValue"::numeric,
			einv."EinvDocumentTaxValue"::numeric,
			ewb."EwbDocumentTaxValue"::numeric,
			gst."GstIrn"::character varying,
			einv."EinvIrn"::character varying,
			ewb."EwbIrn"::character varying,
			ewb."EwbNumber"::bigint,
			ewb."PartBStatus"::smallint,
			gst."GstTransactionType"::smallint,
			einv."EinvTransactionType"::smallint,
			ewb."EwbTransactionType"::smallint,
			gst."IsAmendment"::boolean,
			gst."GstReverseCharge"::boolean,
			einv."EinvReverseCharge"::boolean,
			ewb."EwbReverseCharge"::boolean,
			gst."GstPos"::smallint,
			einv."EinvPos"::smallint,
			ewb."EwbPos"::smallint,
			gst."GstBillFromGstin"::character varying,
			einv."EinvBillFromGstin"::character varying,
			ewb."EwbBillFromGstin"::character varying,
			gst."GstBillFromTradeName"::character varying,
			einv."EinvBillFromTradeName"::character varying,
			ewb."EwbBillFromTradeName"::character varying,
			gst."GstBillFromLegalName"::character varying,
			einv."EinvBillFromLegalName"::character varying,
			ewb."EwbBillFromLegalName"::character varying,
			gst."GstBillToGstin"::character varying,
			einv."EinvBillToGstin"::character varying,
			ewb."EwbBillToGstin"::character varying,
			gst."GstBillToTradeName"::character varying,
			einv."EinvBillToTradeName"::character varying,
			ewb."EwbBillToTradeName"::character varying,
			gst."GstBillToLegalName"::character varying,
			einv."EinvBillToLegalName"::character varying,
			ewb."EwbBillToLegalName"::character varying,
			gst."GstVsEinvSection"::smallint,
			gst."GstVsEinvReasonParameters"::character varying,
			gst."GstVsEwbSection"::smallint,
			gst."GstVsEwbReasonParameters"::character varying,
			einv."EinvVsGstSection"::smallint,
			einv."EinvVsGstReasonParameters"::character varying,
			einv."EinvVsEwbSection"::smallint,
			einv."EinvVsEwbReasonParameters"::character varying,
			ewb."EwbVsEinvSection"::smallint,
			ewb."EwbVsEinvReasonParameters"::character varying,
			ewb."EwbVsGstSection"::smallint,
			ewb."EwbVsGstReasonParameters"::character varying,
			v."TaxpayerStatus"::integer AS "GstinStatus",
			gst."GstinTaxpayerType"::smallint,
			gst."GstCustom1"::character varying,
			einv."EinvCustom1"::character varying,
			ewb."EwbCustom1"::character varying,
			gst."GstCustom2"::character varying,
			einv."EinvCustom2"::character varying,
			ewb."EwbCustom2"::character varying,
			gst."GstCustom3"::character varying,
			einv."EinvCustom3"::character varying,
			ewb."EwbCustom3"::character varying,
			gst."GstCustom4"::character varying,
			einv."EinvCustom4"::character varying,
			ewb."EwbCustom4"::character varying,
			gst."GstCustom5"::character varying,
			einv."EinvCustom5"::character varying,
			ewb."EwbCustom5"::character varying,
			gst."GstCustom6"::character varying,
			einv."EinvCustom6"::character varying,
			ewb."EwbCustom6"::character varying,
			gst."GstCustom7"::character varying,
			einv."EinvCustom7"::character varying,
			ewb."EwbCustom7"::character varying,
			gst."GstCustom8"::character varying,
			einv."EinvCustom8"::character varying,
			ewb."EwbCustom8"::character varying,
			gst."GstCustom9"::character varying,
			einv."EinvCustom9"::character varying,
			ewb."EwbCustom9"::character varying,
			gst."GstCustom10"::character varying,
			einv."EinvCustom10"::character varying,
			ewb."EwbCustom10"::character varying,
			gst."GstHsnOrSacCode"::character varying,
			einv."EinvHsnOrSacCode"::character varying,
			ewb."EwbHsnOrSacCode"::character varying,
			gst."GstDescription"::character varying,
			einv."EinvDescription"::character varying,
			ewb."EwbDescription"::character varying,
			gst."GstUqc"::character varying,
			einv."EinvUqc"::character varying,
			ewb."EwbUqc"::character varying,
			gst."GstQuantity"::numeric,
			einv."EinvQuantity"::numeric,
			ewb."EwbQuantity"::numeric,
			gst."GstPricePerQuantity"::numeric,
			einv."EinvPricePerQuantity"::numeric,
			ewb."EwbPricePerQuantity"::numeric,
			gst."GstRate"::numeric,
			einv."EinvRate"::numeric,
			ewb."EwbRate"::numeric,
			gst."GstCessRate"::numeric,
			einv."EinvCessRate"::numeric,
			ewb."EwbCessRate"::numeric,
			gst."GstStateCessRate"::numeric, 
			einv."EinvStateCessRate"::numeric,
			ewb."EwbStateCessRate"::numeric,
			gst."GstCessNonAdvaloremRate"::numeric,
			einv."EinvCessNonAdvaloremRate"::numeric,
			ewb."EwbCessNonAdvaloremRate"::numeric,
			gst."GstOtherCharges"::numeric,
			einv."EinvOtherCharges"::numeric,
			ewb."EwbOtherCharges"::numeric,
			gst."GstTaxableValue"::numeric,
			einv."EinvTaxableValue"::numeric,
			ewb."EwbTaxableValue"::numeric,
			gst."GstIgstAmount"::numeric,
			einv."EinvIgstAmount"::numeric,
			ewb."EwbIgstAmount"::numeric,
			gst."GstCgstAmount"::numeric,
			einv."EinvCgstAmount"::numeric,
			ewb."EwbCgstAmount"::numeric,
			gst."GstSgstAmount"::numeric,
			einv."EinvSgstAmount"::numeric,
			ewb."EwbSgstAmount"::numeric,
			gst."GstCessAmount"::numeric,
			einv."EinvCessAmount"::numeric,
			ewb."EwbCessAmount"::numeric,
			gst."GstStateCessAmount"::numeric,
			einv."EinvStateCessAmount"::numeric,
			ewb."EwbStateCessAmount"::numeric,
			gst."GstCessNonAdvaloremAmount"::numeric,
			einv."EinvCessNonAdvaloremAmount"::numeric,
			ewb."EwbCessNonAdvaloremAmount"::numeric,
			gst."GstStateCessNonAdvaloremAmount"::numeric,
			einv."EinvStateCessNonAdvaloremAmount"::numeric,
			ewb."EwbStateCessNonAdvaloremAmount"::numeric,
			gst."GstItemTotal"::integer,
			einv."EinvItemTotal"::integer,
			ewb."EwbItemTotal"::integer,
			COALESCE(einv."Remarks", ewb."Remarks", gst."Remarks")::character varying,
			gst."GstBillFromStateCode"::smallint,
			gst."GstBillToStateCode"::smallint,
			einv."EinvBillFromStateCode"::smallint,
			einv."EinvBillToStateCode"::smallint,
			ewb."EwbBillFromStateCode"::smallint,
			ewb."EwbBillToStateCode"::smallint,
			gst."GstPushStatus"::smallint,
			einv."EinvPushStatus"::smallint,
			ewb."EwbPushStatus"::smallint
		FROM
			"TempEInvoiceRecoHubData" AS einv --ON ids."EInvId" = einv."EInvId"
			FULL JOIN "TempEwaybillRecoHubData" AS ewb ON einv."EWBId" = ewb."EwbId" AND einv."RowNum" = ewb."RowNum" 
			FULL JOIN "TempGstRecoHubData" AS gst ON COALESCE(einv."GstId", ewb."GstId") = gst."GstId" AND COALESCE(einv."RowNum", ewb."RowNum") = gst."RowNum"
			LEFT JOIN subscriber."VendorDetails" AS v ON COALESCE(gst."GstBillToGstin", gst."GstBillFromGstin") = v."Gstin" AND v."SubscriberId" = "_SubscriberId"
		ORDER BY
			COALESCE(einv."EntityId", ewb."EntityId", gst."EntityId"),
			COALESCE(einv."DocumentNumber", ewb."DocumentNumber", gst."DocumentNumber"),
			COALESCE(einv."EinvRate", ewb."EwbRate", gst."GstRate")
		;		
	ELSE
		RETURN;
	END IF;
		
END;
$function$
;
