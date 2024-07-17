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
DROP FUNCTION IF EXISTS report."Insert3WayReconciliation";

CREATE OR REPLACE FUNCTION report."Insert3WayReconciliation"("_SubscriberId" integer, "_ParentEntityId" integer, "_FinancialYear" integer, "_IsRegenerateNow" boolean, "_Settings" subscriber."Get3WayReconciliationSettingResponseType"[], "_EInvoicePushStatuses" integer[], "_EwayBillPushStatuses" integer[], "_GstPushStatuses" integer[], "_DocumentTypeINV" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeBOE" smallint, "_DocumentTypeCHL" smallint, "_DocumentTypeBIL" smallint, "_SupplyTypeSale" smallint, "_SupplyTypePurchase" smallint, "_SourceTypeTaxpayer" smallint, "_SourceTypeAutoDraft" smallint, "_SourceTypeEInvoice" smallint, "_TransactionTypeB2B" smallint, "_TransactionTypeB2C" smallint, "_TransactionTypeSEZWP" smallint, "_TransactionTypeSEZWOP" smallint, "_TransactionTypeEXPWP" smallint, "_TransactionTypeEXPWOP" smallint, "_TransactionTypeDE" smallint, "_TransactionTypeIMPG" smallint, "_TransactionTypeCBW" smallint, "_TransactionTypeKD" smallint, "_TransactionTypeJW" smallint, "_TransactionTypeJWR" smallint, "_TransactionTypeOTH" smallint, "_EInvoicePushStatusYetNotGenerated" smallint, "_EInvoicePushStatusInProgress" smallint, "_EInvoicePushStatusGenerated" smallint, "_EInvoicePushStatusCancelled" smallint, "_ReconciliationSectionTypeGstNotAvailable" smallint, "_ReconciliationSectionTypeGstMatched" smallint, "_ReconciliationSectionTypeGstMismatched" smallint, "_ReconciliationSectionTypeEwbNotAvailable" smallint, "_ReconciliationSectionTypeEwbMatched" smallint, "_ReconciliationSectionTypeEwbMismatched" smallint, "_ReconciliationSectionTypeEinvNotAvailable" smallint, "_ReconciliationSectionTypeEinvMatched" smallint, "_ReconciliationSectionTypeEinvMismatched" smallint, "_ReconciliationSectionTypeGstAutodraftedMatched" smallint, "_ReconciliationSectionTypeGstAutodraftedMismatched" smallint, "_ReconciliationSectionTypeGstAutodraftedNotAvailable" smallint, "_ReconciliationSectionTypeQrCodeMatched" smallint, "_ReconciliationSectionTypeQrCodeMismatched" smallint, "_ReconciliationSectionTypeQrCodeNotAvailable" smallint, "_ReconciliationSectionTypeEwbNotApplicable" smallint, "_ReconciliationReasonTypeTaxAmount" bigint, "_ReconciliationReasonTypeItems" bigint, "_ReconciliationReasonTypeSgstAmount" bigint, "_ReconciliationReasonTypeCgstAmount" bigint, "_ReconciliationReasonTypeIgstAmount" bigint, "_ReconciliationReasonTypeCessAmount" bigint, "_ReconciliationReasonTypeTaxableValue" bigint, "_ReconciliationReasonTypeTransactionType" bigint, "_ReconciliationReasonTypePOS" bigint, "_ReconciliationReasonTypeReverseCharge" bigint, "_ReconciliationReasonTypeDocumentValue" bigint, "_ReconciliationReasonTypeDocumentDate" bigint, "_ReconciliationReasonTypeDocumentNumber" bigint, "_ReconciliationReasonTypeIrn" bigint, "_ReconciliationReasonTypeRate" bigint, "_ReconciliationReasonTypeGstin" bigint, "_PurposeTypeEINV" smallint, "_PurposeTypeGST" smallint, "_PurposeTypeEWB" smallint, "_ContactTypeBillTo" smallint, "_ContactTypeBillFrom" smallint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: report."Insert3WayReconciliation"
*	Comments		: 05-10-2022 | Ravi Chauhan | This procedure is used to Insert3WayReconciliation.
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: 	
DROP TABLE IF EXISTS "TempFilterDocumentsParamsType";
CREATE TEMP TABLE "TempFilterDocumentsParamsType" of subscriber."Get3WayReconciliationSettingResponseType";
INSERT INTO "TempFilterDocumentsParamsType"
SELECT
	(PR ->> 'FinancialYear')::integer,
	(PR ->> 'IsDiscardEinvRecordStatus')::boolean,
	(PR ->> 'IsEinvCancelledStatusEnabled')::boolean,
	(PR ->> 'IsEinvYetNotGeneratedStatusEnabled')::boolean,
	(PR ->> 'IsDiscardGstRecordStatus')::boolean,
	(PR ->> 'IsGstCancelledStatusEnabled')::boolean,
	(PR ->> 'IsGstUploadedButNotPushedStatusEnabled')::boolean,
	(PR ->> 'IsDiscardEwbRecordStatus')::boolean,
	(PR ->> 'IsEwbCancelledStatusEnabled')::boolean,
	(PR ->> 'IsEwbRejectedStatusEnabled')::boolean,
	(PR ->> 'IsEwbDiscardedStatusEnabled')::boolean,
	(PR ->> 'IsDiscardGstAutodraftedRecordStatus')::boolean,
	(PR ->> 'IsGstAutodraftedCancelledStatusEnabled')::boolean,
	(PR ->> 'IsGstAutodraftedAutoPopulationFailedEnabled')::boolean,
	(PR ->> 'IsGstAutodraftedCancellationFailedEnabled')::boolean,
	(PR ->> 'IsExcludeOtherChargesEnabled')::boolean,
	(PR ->> 'IsMatchByTolerance')::boolean,
	(PR ->> 'MatchByToleranceDocumentValueFrom')::numeric(15,2),
	(PR ->> 'MatchByToleranceDocumentValueTo')::numeric(15,2),
	(PR ->> 'MatchByToleranceTaxableValueFrom')::numeric(15,2),
	(PR ->> 'MatchByToleranceTaxableValueTo')::numeric(15,2),
	(PR ->> 'MatchByToleranceTaxAmountsFrom')::numeric(15,2),
	(PR ->> 'MatchByToleranceTaxAmountsTo')::numeric(15,2),
	(PR ->> 'IsDocValueThresholdForRecoAgainstEwb')::boolean,
	(PR ->> 'DocValueThresholdForRecoAgainstEwb')::numeric(15,2),
	(PR ->> 'IsReconciliationPreference')::boolean,
	(PR ->> 'IsFinancialYearReturnPeriod')::boolean,
	(PR ->> 'IsDocumentDateReturnPeriod')::boolean
FROM 
	JSON_ARRAY_ELEMENTS('[{}]'::JSON) Pr;
	
SELECT * FROM report."Insert3WayReconciliation"(
	"_SubscriberId"=> 164 ::integer,
	"_ParentEntityId"=> 20081 ::integer,
	"_FinancialYear"=> 202122 ::integer,
	"_IsRegenerateNow"=> True ::boolean,
	"_Settings"=> ARRAY(SELECT ROW(s.*)::subscriber."Get3WayReconciliationSettingResponseType" FROM "TempFilterDocumentsParamsType" s) ::subscriber."Get3WayReconciliationSettingResponseType"[],
	"_EInvoicePushStatuses"=> ARRAY[1,2,3,4,5,6] ::integer[],
	"_EwayBillPushStatuses"=> ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14] ::integer[],
	"_GstPushStatuses"=> ARRAY[1,2,3,4,5,6,7] ::integer[],
	"_DocumentTypeINV"=> 1 ::smallint,
	"_DocumentTypeCRN"=> 2 ::smallint,
	"_DocumentTypeDBN"=> 3 ::smallint,
	"_DocumentTypeBOE"=> 4 ::smallint,
	"_DocumentTypeCHL"=> 7 ::smallint,
	"_DocumentTypeBIL"=> 8 ::smallint,
	"_SupplyTypeSale"=> 1 ::smallint,
	"_SupplyTypePurchase"=> 2 ::smallint,
	"_SourceTypeTaxpayer"=> 1 ::smallint,
	"_SourceTypeAutoDraft"=> 4 ::smallint,
	"_SourceTypeEInvoice" => 5::smallint,
	"_TransactionTypeB2B"=> 1 ::smallint,
	"_TransactionTypeB2C"=> 12 ::smallint,
	"_TransactionTypeSEZWP"=> 4 ::smallint,
	"_TransactionTypeSEZWOP"=> 5 ::smallint,
	"_TransactionTypeEXPWP"=> 2 ::smallint,
	"_TransactionTypeEXPWOP"=> 3 ::smallint,
	"_TransactionTypeDE"=> 6 ::smallint,
	"_TransactionTypeIMPG"=> 7 ::smallint,
	"_TransactionTypeCBW"=> 25 ::smallint,
	"_TransactionTypeKD"=> 15 ::smallint,
	"_TransactionTypeJW"=> 16 ::smallint,
	"_TransactionTypeJWR"=> 17 ::smallint,
	"_TransactionTypeOTH"=> 23 ::smallint,
	"_EInvoicePushStatusYetNotGenerated"=> 1 ::smallint,
	"_EInvoicePushStatusInProgress"=> 2 ::smallint,
	"_EInvoicePushStatusGenerated"=> 4 ::smallint,
	"_EInvoicePushStatusCancelled"=> 5 ::smallint,
	"_ReconciliationSectionTypeGstNotAvailable"=> 17 ::smallint,
	"_ReconciliationSectionTypeGstMatched"=> 15 ::smallint,
	"_ReconciliationSectionTypeGstMismatched"=> 16 ::smallint,
	"_ReconciliationSectionTypeEwbNotAvailable"=> 20 ::smallint,
	"_ReconciliationSectionTypeEwbMatched"=> 18 ::smallint,
	"_ReconciliationSectionTypeEwbMismatched"=> 19 ::smallint,
	"_ReconciliationSectionTypeEinvNotAvailable"=> 14 ::smallint,
	"_ReconciliationSectionTypeEinvMatched"=> 12 ::smallint,
	"_ReconciliationSectionTypeEinvMismatched"=> 13 ::smallint,
	"_ReconciliationSectionTypeGstAutodraftedMatched"=> 21 ::smallint,
	"_ReconciliationSectionTypeGstAutodraftedMismatched"=> 22 ::smallint,
	"_ReconciliationSectionTypeGstAutodraftedNotAvailable"=> 23 ::smallint,
	"_ReconciliationSectionTypeEwbNotApplicable"=> 24 ::smallint,
	"_ReconciliationSectionTypeQrCodeMatched"=>53 ::smallint,
	"_ReconciliationSectionTypeQrCodeMismatched"=>54 ::smallint,
	"_ReconciliationSectionTypeQrCodeNotAvailable"=>52 ::smallint,
	"_ReconciliationReasonTypeTaxAmount"=> 4 ::bigint,
	"_ReconciliationReasonTypeItems"=> 8 ::bigint,
	"_ReconciliationReasonTypeSgstAmount"=> 16 ::bigint,
	"_ReconciliationReasonTypeCgstAmount"=> 32 ::bigint,
	"_ReconciliationReasonTypeIgstAmount"=> 64 ::bigint,
	"_ReconciliationReasonTypeCessAmount"=> 128 ::bigint,
	"_ReconciliationReasonTypeTaxableValue"=> 256 ::bigint,
	"_ReconciliationReasonTypeTransactionType"=> 512 ::bigint,
	"_ReconciliationReasonTypePOS"=> 1024 ::bigint,
	"_ReconciliationReasonTypeReverseCharge"=> 2048 ::bigint,
	"_ReconciliationReasonTypeDocumentValue"=> 4096 ::bigint,
	"_ReconciliationReasonTypeDocumentDate"=> 8192 ::bigint,
	"_ReconciliationReasonTypeDocumentNumber"=> 16384 ::bigint,
	"_ReconciliationReasonTypeIrn"=> 1 ::BIGINT,
	"_ReconciliationReasonTypeRate"=> 2::bigint,
	"_ReconciliationReasonTypeGstin" => 1515::bigint,
	"_PurposeTypeEINV"=> 2 ::smallint,
	"_PurposeTypeGST"=> 1 ::smallint,
	"_PurposeTypeEWB"=> 8 ::smallint,
	"_ContactTypeBillTo"=> 1 ::smallint,
	"_ContactTypeBillFrom"=> 2 ::smallint
	);
--------------------------------------------------------------------------------------------------------------------------------------*/

DECLARE
	"_PurposeTypeBoth" SMALLINT = "_PurposeTypeEINV" + "_PurposeTypeEWB";
	"_IsEinvCancelledStatusEnabled" SMALLINT = 0;
	"_IsEinvYetNotGeneratedStatusEnabled" SMALLINT = 0;
	"_IsGstCancelledStatusEnabled" SMALLINT = 0;
	"_IsGstUploadedButNotPushedStatusEnabled" SMALLINT = 0;
	"_IsEwbCancelledStatusEnabled" SMALLINT = 0;
	"_IsEwbRejectedStatusEnabled" SMALLINT = 0;
	"_IsEwbDiscardedStatusEnabled" SMALLINT = 0;
	"_GstPushStatusUploadedButNotPushed" SMALLINT = 1;
	"_GstPushStatusCancelled" SMALLINT = 7;
	"_GstPushStatusRemovedButNotPushed" SMALLINT = 3;
	"_EwaybillPushStatusCancelled" SMALLINT = 4;
	"_EwaybillPushStatusRejected" SMALLINT = 8;
	"_EwaybillPushStatusDiscarded"  SMALLINT = 14;
	"_IsGstAutodraftedCancelledStatusEnabled" SMALLINT = 0 ; --7
	"_IsGstAutodraftedAutoPopulationFailedEnabled" SMALLINT = 0; --1
	"_IsGstAutodraftedCancellationFailedEnabled" SMALLINT = 0; --3		 
	"_SettingTypeExcludeOtherCharges" BOOLEAN = false;
	"_IsMatchByTolerance" BOOLEAN;
	"_MatchByToleranceDocumentValueFrom" DECIMAL(15, 2);
	"_MatchByToleranceDocumentValueTo" DECIMAL(15, 2);
	"_MatchByToleranceTaxableValueFrom" DECIMAL(15, 2);
	"_MatchByToleranceTaxableValueTo" DECIMAL(15, 2);
	"_MatchByToleranceTaxAmountsFrom" DECIMAL(15, 2);
	"_MatchByToleranceTaxAmountsTo" DECIMAL(15, 2);
	"_DocValueThresholdForRecoAgainstEwb" DECIMAL(15,2);
	"_IsDocumentDateReturnPeriod" BOOLEAN;
	"_IsExcludeMatchingCriteriaTransactionType" BOOLEAN;
	"_IsExcludeMatchingCriteriaGstin" BOOLEAN;
	"_IsExcludeMatchingCriteriaIrn" BOOLEAN;

BEGIN
	
	RAISE NOTICE 'Main1';	
	SELECT 
		CASE WHEN s."IsEinvCancelledStatusEnabled" = true THEN "_EInvoicePushStatusCancelled" ELSE 0 END,
		CASE WHEN s."IsEinvYetNotGeneratedStatusEnabled" = true THEN "_EInvoicePushStatusYetNotGenerated" ELSE 0 END,
		CASE WHEN s."IsGstCancelledStatusEnabled" = true THEN "_GstPushStatusCancelled" ELSE 0 END,
		CASE WHEN s."IsGstUploadedButNotPushedStatusEnabled" = true THEN "_GstPushStatusUploadedButNotPushed" ELSE 0 END,
		CASE WHEN s."IsEwbCancelledStatusEnabled" = true THEN "_EwaybillPushStatusCancelled" ELSE 0 END,
		CASE WHEN s."IsEwbRejectedStatusEnabled" = true THEN "_EwaybillPushStatusRejected" ELSE 0 END,
		CASE WHEN s."IsEwbDiscardedStatusEnabled" = true THEN "_EwaybillPushStatusDiscarded" ELSE 0 END,				
		CASE WHEN s."IsGstAutodraftedCancelledStatusEnabled" = true THEN "_GstPushStatusCancelled" ELSE 0 END,
		CASE WHEN s."IsGstAutodraftedAutoPopulationFailedEnabled" = true THEN "_GstPushStatusUploadedButNotPushed" ELSE 0 END,
		CASE WHEN s."IsGstAutodraftedCancellationFailedEnabled" = true THEN "_GstPushStatusRemovedButNotPushed" ELSE 0 END,
		s."IsExcludeOtherChargesEnabled",
		s."IsMatchByTolerance",
		s."MatchByToleranceDocumentValueFrom",
		s."MatchByToleranceDocumentValueTo",
		s."MatchByToleranceTaxableValueFrom",
		s."MatchByToleranceTaxableValueTo",
		s."MatchByToleranceTaxAmountsFrom",
		s."MatchByToleranceTaxAmountsTo",
		s."DocValueThresholdForRecoAgainstEwb",
		CASE WHEN s."IsFinancialYearReturnPeriod" = false THEN true ELSE false END,
		s."IsExcludeMatchingCriteriaTransactionType",
		s."IsExcludeMatchingCriteriaGstin",
		s."IsExcludeMatchingCriteriaIrn"
		INTO "_IsEinvCancelledStatusEnabled","_IsEinvYetNotGeneratedStatusEnabled","_IsGstCancelledStatusEnabled","_IsGstUploadedButNotPushedStatusEnabled","_IsEwbCancelledStatusEnabled",
			 "_IsEwbRejectedStatusEnabled","_IsEwbDiscardedStatusEnabled","_IsGstAutodraftedCancelledStatusEnabled","_IsGstAutodraftedAutoPopulationFailedEnabled","_IsGstAutodraftedCancellationFailedEnabled",
			 "_SettingTypeExcludeOtherCharges","_IsMatchByTolerance","_MatchByToleranceDocumentValueFrom","_MatchByToleranceDocumentValueTo",
			 "_MatchByToleranceTaxableValueFrom","_MatchByToleranceTaxableValueTo","_MatchByToleranceTaxAmountsFrom","_MatchByToleranceTaxAmountsTo",
			 "_DocValueThresholdForRecoAgainstEwb","_IsDocumentDateReturnPeriod","_IsExcludeMatchingCriteriaTransactionType","_IsExcludeMatchingCriteriaGstin", "_IsExcludeMatchingCriteriaIrn"
	FROM UNNEST("_Settings") s;

	CREATE TEMP TABLE "EInvoicePushStatuses"  AS
	SELECT 
		"Item"
	FROM 
		UNNEST("_EInvoicePushStatuses") "Item"
	WHERE 
		"Item" NOT IN ("_IsEinvCancelledStatusEnabled","_IsEinvYetNotGeneratedStatusEnabled");

	CREATE TEMP TABLE "EwaybillPushStatuses" AS
	SELECT 
		"Item"							
	FROM 
		UNNEST("_EwayBillPushStatuses") "Item"
	WHERE 
		"Item" NOT IN ("_IsEwbCancelledStatusEnabled","_IsEwbDiscardedStatusEnabled","_IsEwbRejectedStatusEnabled");

	CREATE TEMP TABLE "GstPushStatuses" AS 
	SELECT 
		"Item"				
	FROM 
		UNNEST("_GstPushStatuses") "Item"
	WHERE 
		"Item" NOT IN ("_IsGstCancelledStatusEnabled","_IsGstUploadedButNotPushedStatusEnabled");

	DROP TABLE IF EXISTS "AutoDraftPushStatuses";
	CREATE TEMP TABLE "AutoDraftPushStatuses" AS 		
	SELECT 
		"Item"
	FROM 
		UNNEST("_GstPushStatuses")"Item"
	WHERE 
		"Item" NOT IN ("_IsGstAutodraftedCancelledStatusEnabled","_IsGstAutodraftedAutoPopulationFailedEnabled","_IsGstAutodraftedCancellationFailedEnabled");

		RAISE NOTICE 'Main2';
	/* Making flag 3Wayreconciled false when regenerate flag is true */
	IF ("_IsRegenerateNow" = TRUE)
	THEN
		UPDATE Einvoice."DocumentDW" dw 
			Set "Is3WayReconciled" = false
		WHERE 
			dw."SubscriberId" = "_SubscriberId"
		  AND dw."ParentEntityId" = "_ParentEntityId"
		  AND "FinancialYear" = "_FinancialYear"
		  AND "Is3WayReconciled" = true ;		  			

		UPDATE oregular."SaleDocumentDW" dw 
			Set "Is3WayReconciled" = false
		WHERE 
			dw."SubscriberId" = "_SubscriberId"
		  AND dw."ParentEntityId" = "_ParentEntityId"
		  AND "FinancialYear" = "_FinancialYear"
		  AND "Is3WayReconciled" = true; 

		UPDATE oregular."PurchaseDocumentDW" dw
			Set "Is3WayReconciled" = false
		WHERE 
			dw."SubscriberId" = "_SubscriberId"
		  AND dw."ParentEntityId" = "_ParentEntityId"
		  AND "FinancialYear" = "_FinancialYear"
		  AND "Is3WayReconciled" = true 
		  AND dw."SourceType" IN("_SourceTypeTaxpayer", "_SourceTypeEInvoice");
		 
		UPDATE einvoice."QrCodeDetails" dw
			Set "Is3WayReconciled" = false
		WHERE 
			dw."SubscriberId" = "_SubscriberId"
		  AND dw."EntityId" = "_ParentEntityId"
		  AND dw."FinancialYear" = "_FinancialYear"
		  AND dw."Is3WayReconciled" = true;		  

	END IF;

RAISE NOTICE 'Main3';
	/* Creating Temp Table */
	CREATE TEMP TABLE  "TempEinvoiceReconciledInsertedIds"
	(		
		"EInvId" BIGINT NOT NULL
	);
	
	CREATE  INDEX "IDX_TempEinvoiceReconciledIds" ON "TempEinvoiceReconciledInsertedIds"("EInvId");
	
	DROP TABLE IF EXISTS "TempEwaybillReconciledInsertedIds";
	
	CREATE TEMP TABLE  "TempEwaybillReconciledInsertedIds"
	(		
		"EWBId" BIGINT NOT NULL,
		"SupplyType" SMALLINT NOT NULL
	);
	CREATE  INDEX "IDX_TempEwaybillReconciledIds" ON "TempEwaybillReconciledInsertedIds"("EWBId");

	DROP TABLE IF EXISTS "TempGstReconciledInsertedIds";
	CREATE TEMP TABLE  "TempGstReconciledInsertedIds"
	(		
		"GstId" BIGINT NOT NULL,
		"SupplyType" SMALLINT NOT NULL
	);
	CREATE  INDEX IDX_TempGstReconciledIds ON "TempGstReconciledInsertedIds"("GstId")	;

	DROP TABLE IF EXISTS "TempAutoDraftReconciledInsertedIds";
	CREATE TEMP TABLE  "TempAutoDraftReconciledInsertedIds"
	(		
		"AutoDraftId" BIGINT NOT NULL		
	);
	CREATE  INDEX "IDX_TempAutoDraftReconciledInsertedIds" ON "TempAutoDraftReconciledInsertedIds"("AutoDraftId");

	DROP TABLE IF EXISTS "TempPurchaseAutoDraftIds";
	CREATE TEMP TABLE "TempPurchaseAutoDraftIds"
	(		
		"PurchaseAutoDraftId" BIGINT NOT NULL		
	);
	CREATE INDEX "Idx_TempPurchaseAutoDraftIds_PurchaseAutoDraftId" ON "TempPurchaseAutoDraftIds"("PurchaseAutoDraftId");

	DROP TABLE IF EXISTS "TempEinvQrCodeIds";
	CREATE TEMP TABLE "TempEinvQrCodeIds"
	(		
		"EinvQrId" BIGINT NOT NULL		
	);
	CREATE INDEX "Idx_TempEinvQrCodeIds_EinvQrId" ON "TempEinvQrCodeIds"("EinvQrId");

	DROP TABLE IF EXISTS "TempEinvoiceDeletedIds";
	CREATE TEMP TABLE "TempEinvoiceDeletedIds"
	(		
		"EInvId" BIGINT NOT NULL
	);
	
	CREATE  INDEX "IDX_TempEinvoiceDeletedIds" ON "TempEinvoiceDeletedIds"("EInvId");

	DROP TABLE IF EXISTS "TempEwaybillDeletedIds";
	CREATE TEMP TABLE  "TempEwaybillDeletedIds"
	(		
		"EWBId" BIGINT NOT NULL		
	);
	CREATE  INDEX "IDX_TempEwaybillDeletedIds" ON "TempEwaybillDeletedIds"("EWBId");

	DROP TABLE IF EXISTS "TempGstDeletedIds";
	CREATE TEMP TABLE  "TempGstDeletedIds"
	(		
		"GstId" BIGINT NOT NULL,
		"SupplyType" SMALLINT NOT NULL
	);
	CREATE  INDEX "IDX_TempGstDeletedIds" ON "TempGstDeletedIds"("GstId");	

	DROP TABLE IF EXISTS "TempAutoDraftDeletedIds";
	CREATE TEMP TABLE  "TempAutoDraftDeletedIds"
	(		
		"AutoDraftId" BIGINT NOT NULL
	);
	CREATE  INDEX "IDX_TempAutoDraftDeletedIds" ON "TempAutoDraftDeletedIds"("AutoDraftId");	

	DROP TABLE IF EXISTS "TempEinvoiceUpdatedIds";
	CREATE TEMP TABLE  "TempEinvoiceUpdatedIds"
	(		
		"EInvId" BIGINT NOT NULL
	);
	
	CREATE  INDEX "IDX_TempEinvoiceUpdatedIds" ON "TempEinvoiceUpdatedIds"("EInvId");

	DROP TABLE IF EXISTS "TempEwaybillUpdatedIds";
	CREATE TEMP TABLE  "TempEwaybillUpdatedIds"
	(		
		"EWBId" BIGINT NOT NULL		
	);
	CREATE  INDEX "IDX_TempEwaybillUpdatedIds" ON "TempEwaybillUpdatedIds"("EWBId");

	DROP TABLE IF EXISTS "TempGstUpdatedIds";
	CREATE TEMP TABLE  "TempGstUpdatedIds"
	(		
		"GstId" BIGINT NOT NULL,
		"SupplyType" SMALLINT NOT NULL
	);
	CREATE  INDEX "IDX_TempGstUpdatedIds" ON "TempGstUpdatedIds"("GstId");	

	DROP TABLE IF EXISTS "TempAutoDraftUpdatedIds";
	CREATE TEMP TABLE  "TempAutoDraftUpdatedIds"
	(		
		"AutoDraftId" BIGINT NOT NULL		
	);
	
	CREATE  INDEX "IDX_TempAutoDraftUpdatedIds" ON "TempAutoDraftUpdatedIds"("AutoDraftId");	
	RAISE NOTICE 'Main1';
	/*Get Einvoice Deleted ids*/
	
	DROP TABLE IF EXISTS "TempPurchaseAutoDraftDeletedIds";
	CREATE TEMP TABLE  "TempPurchaseAutoDraftDeletedIds"
	(		
		"PurchaseAutoDraftId" BIGINT NOT NULL
	);
	CREATE  INDEX "IDX_TempPurchaseAutoDraftDeletedIds" ON "TempPurchaseAutoDraftDeletedIds"("PurchaseAutoDraftId");
	
	INSERT INTO "TempEinvoiceDeletedIds"
	SELECT 
		erm."EInvId"
	FROM 
	report."EinvoiceRecoMapper" erm
	WHERE
		NOT EXISTS (
					SELECT 
						dw."Id" 
					FROM 
						einvoice."DocumentDW" dw 
					WHERE 
						dw."Id" = erm."EInvId" 				
						AND dw."Purpose" IN ("_PurposeTypeEINV","_PurposeTypeBoth")
					);
	
	RAISE NOTICE 'Main5';
	/*Get Ewaybill Deleted ids*/
	INSERT INTO "TempEwaybillDeletedIds"
	SELECT 
		erm."EWBId"
	FROM 
		report."EwaybillRecoMapper" erm
	WHERE 
		NOT EXISTS 
			(SELECT 
				dw."Id" 
			 FROM 
				einvoice."DocumentDW" dw 
			 WHERE 
				dw."Id" = erm."EWBId" 
				AND dw."Purpose" IN ("_PurposeTypeEWB","_PurposeTypeBoth") 
			 );		
	
	RAISE NOTICE 'Main6';
	/*Get Ewaybill Duplicate Entries*/
	CREATE TEMP TABLE "TempEwaybillDuplicateEntries" AS
	WITH "CTE" 
	AS
	(
		SELECT 
			d."Id"
			,ROW_NUMBER() OVER (PARTITION BY d."DocumentNumber",d."DocumentFinancialYear",d."SupplyType",dc."Gstin",d."Type" ORDER BY COALESCE(ds."GeneratedDate",NOW()::timestamp(3)) DESC) "Rownum"					 
		FROM 
			einvoice."Documents" d 
			INNER JOIN einvoice."DocumentContacts" dc  ON dc."DocumentId" = d."Id" and dc."Type" = 1
			INNER JOIN ewaybill."DocumentStatus" ds  ON ds."DocumentId" = d."Id"			
		WHERE 
			d."SubscriberId" = "_SubscriberId"
			AND d."ParentEntityId" = "_ParentEntityId"
			AND "FinancialYear" = "_FinancialYear" 
			AND "Purpose" IN ("_PurposeTypeEWB","_PurposeTypeBoth") 
			AND ds."PushStatus" IN (SELECT * FROM "EwaybillPushStatuses" einv)
	)
	SELECT 
		"Id"  
	FROM 
		"CTE" 
	WHERE
		"Rownum" > 1;

	
	RAISE NOTICE 'Main7';
	/*Get Einvoice Duplicate Entries*/
	DROP TABLE IF EXISTS "TempEinvoiceDuplicateEntries";
	CREATE TEMP TABLE "TempEinvoiceDuplicateEntries" AS
	WITH CTE 
	AS
	(
		SELECT 
			d."Id"
			,ROW_NUMBER() OVER (PARTITION BY d."DocumentNumber",d."DocumentFinancialYear",d."SupplyType",dc."Gstin",d."Type" ORDER BY COALESCE(ds."GeneratedDate",ds."Stamp") DESC) "Rownum"					 
		FROM 
			einvoice."Documents" d 
			INNER JOIN einvoice."DocumentContacts" dc  ON dc."DocumentId" = d."Id" and dc."Type" = 1
			INNER JOIN einvoice."DocumentStatus" ds  ON ds."DocumentId" = d."Id"			
		WHERE 
			d."SubscriberId" = "_SubscriberId"
			AND d."ParentEntityId" = "_ParentEntityId"
			AND "FinancialYear" = "_FinancialYear" 
			AND d."Purpose" IN ("_PurposeTypeEINV","_PurposeTypeBoth")
			AND ds."PushStatus" IN (SELECT * FROM "EInvoicePushStatuses" einv)
	)
	SELECT 
		"Id" 		 
	FROM 
		CTE 
	WHERE
		"Rownum" > 1;
		
	RAISE NOTICE 'Main8';
	INSERT INTO "TempEwaybillDeletedIds"
	SELECT 
		"Id" 
	FROM 
		"TempEwaybillDuplicateEntries";

	RAISE NOTICE 'Main9';
	INSERT INTO "TempEinvoiceDeletedIds"
	SELECT 
		"Id"
	FROM
		"TempEinvoiceDuplicateEntries";
	
	RAISE NOTICE 'Main10';
	/*Get Gst Deleted ids for sale*/
	INSERT INTO "TempGstDeletedIds"
	SELECT 
		erm."GstId",
		"_SupplyTypeSale"
	FROM 
		report."GstRecoMapper" erm 
	WHERE 
		NOT EXISTS 
		(
			SELECT 
				dw."Id" 
			FROM 
				oregular."SaleDocumentDW" dw 
			WHERE dw."Id" = erm."GstId"
			) 
		AND erm."GstType" = "_SupplyTypeSale";
		
	INSERT INTO "TempGstDeletedIds"
	SELECT 
		d."Id",
		"_SupplyTypeSale"
	FROM 
		Oregular."SaleDocumentDW" d	
		INNER JOIN oregular."SaleDocumentStatus" ds ON ds."SaleDocumentId" = d."Id"
	WHERE
			d."SubscriberId" = "_SubscriberId"
		AND d."ParentEntityId" = "_ParentEntityId"
		AND d."FinancialYear" = "_FinancialYear" 
		AND ds."PushStatus" IN ("_IsGstCancelledStatusEnabled","_IsGstUploadedButNotPushedStatusEnabled");	
	
	RAISE NOTICE 'Main11';
	/*Get Gst Deleted ids for Purchase*/
	INSERT INTO "TempGstDeletedIds"
	SELECT 
		erm."GstId",
		"_SupplyTypePurchase"
	FROM 
		report."GstRecoMapper" erm 
	WHERE 
		NOT EXISTS 
			(SELECT 
				dw."Id" 
			 FROM 
				oregular."PurchaseDocumentDW" dw 
			 WHERE dw."Id" = erm."GstId"
			 )	
		AND erm."GstType" = "_SupplyTypePurchase";
	
	RAISE NOTICE 'Main12';
	/*Get Gst Deleted ids for sale*/
	INSERT INTO "TempAutoDraftDeletedIds"
	SELECT 
		erm."AutoDraftId"		
	FROM 
		report."GstAutoDraftRecoMapper" erm 
	WHERE 
		NOT EXISTS 
		(
			SELECT 
				dw."Id" 
			FROM 
				oregular."SaleDocumentDW" dw 
			WHERE 
				dw."Id" = erm."AutoDraftId"
				AND dw."SourceType"="_SourceTypeAutoDraft"
		) ;
		
	INSERT INTO "TempAutoDraftDeletedIds"
	SELECT 
		d."Id"
	FROM 
		Oregular."SaleDocumentDW" d			
	INNER JOIN oregular."SaleDocumentStatus" ss ON d."Id" = ss."SaleDocumentId"
	WHERE
			d."SubscriberId" = "_SubscriberId"
		AND d."ParentEntityId" = "_ParentEntityId"
		AND d."FinancialYear" = "_FinancialYear" 
		AND ss."PushStatus" IN ("_IsGstAutodraftedCancelledStatusEnabled","_IsGstAutodraftedAutoPopulationFailedEnabled","_IsGstAutodraftedCancellationFailedEnabled");
		
		
	/*Get Gst Deleted ids for sale*/
	INSERT INTO "TempPurchaseAutoDraftDeletedIds"("PurchaseAutoDraftId")
	SELECT 
		erm."AutoDraftId"		
	FROM 
		report."PurchaseAutoDraftRecoMapper" erm
	WHERE 
		NOT EXISTS 
		(
			SELECT 
				dw."Id" 
			FROM 
				oregular."PurchaseDocumentDW" dw
			WHERE dw."Id" = erm."AutoDraftId"
		);

	DROP TABLE IF EXISTS "TempQrCodeDeletedIds";
	CREATE TEMP TABLE "TempQrCodeDeletedIds" AS
	SELECT 
		erm."EinvQrId"		
	FROM 
		report."EinvoiceQrCodeRecoMapper" erm 
	WHERE 
		NOT EXISTS 
		(
			SELECT 
				dw."Id" 
			FROM 
				einvoice."QrCodeDetails" dw 
			WHERE 
				dw."Id" = erm."EinvQrId"				
		) ;

	/*Get Gst Deleted ids for sale*/
	INSERT INTO "TempPurchaseAutoDraftDeletedIds"("PurchaseAutoDraftId")
	SELECT 
		erm."PrId"		
	FROM 
		report."PurchaseAutoDraftRecoMapper" erm
	WHERE 
		NOT EXISTS 
		(
			SELECT 
				dw."Id" 
			FROM 
				oregular."PurchaseDocumentDW" dw
			WHERE dw."Id" = erm."PrId"
		)
		AND erm."PrId" IS NOT NULL;		
	
	RAISE NOTICE 'Main13';
	/* Deleting ids from Reco table and updating NotAvailbale Section for same in other reco table */
	IF EXISTS (SELECT 1 FROM "TempEinvoiceDeletedIds") OR EXISTS (SELECT 1 FROM "TempEinvoiceUpdatedIds")
	THEN				
		UPDATE 
			report."GstRecoMapper" grm	set "EInvSection" = "_ReconciliationSectionTypeEinvNotAvailable","EInvId" = NULL,
											"EInvReasonsType" = NULL,"EInvReason" = NULL
		FROM 
			"TempEinvoiceDeletedIds" erm 
		WHERE grm."EInvId" = erm."EInvId";

		UPDATE 
			report."EwaybillRecoMapper" grm	 
		SET "EInvSection" = "_ReconciliationSectionTypeEinvNotAvailable","EInvId" = NULL,
			"EInvReasonsType" = NULL,"EInvReason" = NULL
		FROM 			
			 "TempEinvoiceDeletedIds" erm
		WHERE grm."EInvId" = erm."EInvId";					

		DELETE
		FROM 
			report."EinvoiceRecoMapper" erm
		USING "TempEinvoiceDeletedIds" ids
		WHERE ids."EInvId" = erm."EInvId";					

	END IF;

	RAISE NOTICE 'Main14';
	IF EXISTS (SELECT 1 FROM "TempEwaybillDeletedIds") OR EXISTS (SELECT 1  FROM "TempEwaybillUpdatedIds")
	THEN
		UPDATE 
			report."GstRecoMapper" grm	 set 
				"EWBSection" = "_ReconciliationSectionTypeEwbNotAvailable", 
				"EWBId" = NULL,
				"EwbReasonsType" = NULL,
				"EwbReason" = NULL
		FROM 			
			"TempEwaybillDeletedIds" erm 
		WHERE grm."EWBId" = erm."EWBId";
		
		UPDATE 
			report."EinvoiceRecoMapper" grm set 
				"EwbSection" = "_ReconciliationSectionTypeEwbNotAvailable", 
				"EWBId" = NULL,
				"EwbReasonsType" = NULL,
				"Ewbeason" = NULL
		FROM 			
			"TempEwaybillDeletedIds" erm 
		WHERE COALESCE(grm."EWBId",0) = erm."EWBId";

		DELETE 
		FROM 
			report."EwaybillRecoMapper" erm
		USING "TempEwaybillDeletedIds" ids 
		WHERE ids."EWBId" = erm."EWBId";
		
	END IF;

	RAISE NOTICE 'Main15';
	IF EXISTS (SELECT  1 FROM "TempGstDeletedIds") OR EXISTS (SELECT  1 FROM "TempGstUpdatedIds")
	THEN	
		UPDATE 
			report."EwaybillRecoMapper" grm	 
				SET  "GstSection" = "_ReconciliationSectionTypeGstNotAvailable",
					 "GstId" = NULL,
					 "GstReasonsType" = NULL,
					 "GstReason" = NULL
		FROM 			
			 "TempGstDeletedIds" erm 
		WHERE 
			grm."GstId" = erm."GstId" 
			AND grm."GstType" = erm."SupplyType";

		UPDATE 
			report."EinvoiceRecoMapper" grm	
			SET 
				"GstSection" = "_ReconciliationSectionTypeGstNotAvailable", 
				"GstId" = NULL,
				"GstReasonsType" = NULL,
				"GstReason" = NULL
		FROM 			
			 "TempGstDeletedIds" erm 
		WHERE grm."GstId" = erm."GstId" AND erm."SupplyType" = "_SupplyTypeSale";

		UPDATE 	report."GstAutoDraftRecoMapper" grm	 
			SET "GstSection" = "_ReconciliationSectionTypeGstNotAvailable", 
				"GstId" = NULL,
				"GstReasonsType" = NULL,
				"GstReason" = NULL
		FROM 			
			"TempGstDeletedIds" erm 
		WHERE grm."GstId" = erm."GstId" AND erm."SupplyType" = "_SupplyTypeSale";
		
		DELETE 
		FROM 
			report."GstRecoMapper" erm
		USING "TempGstDeletedIds" ids 
		WHERE ids."GstId" = erm."GstId" AND erm."GstType" = ids."SupplyType";
		
	END IF;
	
	RAISE NOTICE 'Main16';
	IF EXISTS (SELECT 1 FROM "TempAutoDraftDeletedIds")OR EXISTS (SELECT 1 FROM "TempAutoDraftUpdatedIds")
	THEN
		UPDATE 
			report."GstRecoMapper" grm	 
			set "AutoDraftSection" = "_ReconciliationSectionTypeGstAutodraftedNotAvailable",
				"AutoDraftId" = NULL,
				"AutoDraftReasonsType" = NULL,
				"AutoDraftReason" = NULL
		FROM 
			"TempAutoDraftDeletedIds" erm 
		WHERE grm."AutoDraftId" = erm."AutoDraftId" AND grm."GstType" = "_SupplyTypeSale";
		
		DELETE
		FROM 
			report."GstAutoDraftRecoMapper" erm
		USING "TempAutoDraftDeletedIds" ids 
		WHERE ids."AutoDraftId" = erm."AutoDraftId" ;

	END IF;
	
	IF EXISTS (SELECT 1 FROM "TempPurchaseAutoDraftDeletedIds")
	THEN
		UPDATE report."PurchaseAutoDraftRecoMapper" grm 
			SET "PrId" = NULL,
				"GstSection" = "_ReconciliationSectionTypeGstNotAvailable",
				"GstReasonsType" = NULL,
				"GstReason" = NULL
		FROM 
			"TempPurchaseAutoDraftDeletedIds" ids
		WHERE grm."PrId" = ids."PurchaseAutoDraftId";

		UPDATE report."EinvoiceQrCodeRecoMapper" grm 
			SET "AutoDraftId" = NULL,
				"AutoDraftSection" = "_ReconciliationSectionTypeGstAutodraftedNotAvailable",
				"AutoDraftReasonsType" = NULL,
				"AutoDraftReason" = NULL
		FROM 
			"TempPurchaseAutoDraftDeletedIds" ids
		WHERE grm."AutoDraftId" = ids."PurchaseAutoDraftId";

		DELETE 
		FROM 
			report."PurchaseAutoDraftRecoMapper" erm
		USING "TempPurchaseAutoDraftDeletedIds" ids 
		WHERE
			ids."PurchaseAutoDraftId" = erm."AutoDraftId";
			
	END IF;
	
	IF EXISTS (SELECT 1 FROM "TempQrCodeDeletedIds")
	THEN
		UPDATE report."PurchaseAutoDraftRecoMapper" grm 
			SET "EinvQrId" = NULL,
				"EinvQrSection" = "_ReconciliationSectionTypeQrCodeNotAvailable",
				"EinvQrReasonsType" = NULL,
				"EinvQrReason" = NULL
		FROM 
			"TempQrCodeDeletedIds" ids
		WHERE grm."EinvQrId" = ids."EinvQrId";

		DELETE 
		FROM 
			report."EinvoiceQrCodeRecoMapper" erm
		USING "TempQrCodeDeletedIds" ids 
		WHERE
			ids."EinvQrId" = erm."EinvQrId";
			
	END IF;
	
	
	RAISE NOTICE 'Main17';
	/*Executing sp for Einvoice reconciliation */
	INSERT INTO"TempEinvoiceReconciledInsertedIds"
	SELECT * FROM  report."InsertEinvoice3WayReconciliation"
		("_SubscriberId"	:="_SubscriberId"
		,"_ParentEntityId" :="_ParentEntityId"
		,"_FinancialYear" :="_FinancialYear"
		,"_DocumentTypeINV" :="_DocumentTypeINV"
		,"_DocumentTypeCRN" :="_DocumentTypeCRN"
		,"_DocumentTypeDBN" :="_DocumentTypeDBN"
		,"_PurposeTypeEInv" :="_PurposeTypeEINV"
		,"_PurposeTypeEWB" :="_PurposeTypeEWB"
		,"_SupplyTypeSale" :="_SupplyTypeSale"
		,"_IsDocumentDateReturnPeriod" :="_IsDocumentDateReturnPeriod"
		,"_TransactionTypeB2B" :="_TransactionTypeB2B"
		,"_TransactionTypeB2C" :="_TransactionTypeB2C"
		,"_TransactionTypeSEZWP" :="_TransactionTypeSEZWP"
		,"_TransactionTypeSEZWOP" :="_TransactionTypeSEZWOP"
		,"_TransactionTypeEXPWP" :="_TransactionTypeEXPWP"
		,"_TransactionTypeEXPWOP" :="_TransactionTypeEXPWOP"
		,"_TransactionTypeDE" :="_TransactionTypeDE"
		,"_TransactionTypeIMPG" :="_TransactionTypeIMPG"
		,"_TransactionTypeKD" :="_TransactionTypeKD"
		,"_TransactionTypeJW" :="_TransactionTypeJW"
		,"_TransactionTypeJWR" :="_TransactionTypeJWR"
		,"_TransactionTypeOTH" :="_TransactionTypeOTH"
		,"_TransactionTypeCBW" :="_TransactionTypeCBW"
		,"_EInvoicePushStatusYetNotGenerated" :="_EInvoicePushStatusYetNotGenerated"
		,"_EInvoicePushStatusInProgress" :="_EInvoicePushStatusInProgress"
		,"_EInvoicePushStatusGenerated" :="_EInvoicePushStatusGenerated"
		,"_EInvoicePushStatusCancelled" :="_EInvoicePushStatusCancelled"
		,"_ReconciliationSectionTypeGstNotAvailable" :="_ReconciliationSectionTypeGstNotAvailable"
		,"_ReconciliationSectionTypeGstMatched" :="_ReconciliationSectionTypeGstMatched"
		,"_ReconciliationSectionTypeGstMismatched" :="_ReconciliationSectionTypeGstMismatched"
		,"_ReconciliationSectionTypeEwbNotAvailable" :="_ReconciliationSectionTypeEwbNotAvailable"
		,"_ReconciliationSectionTypeEwbMatched" :="_ReconciliationSectionTypeEwbMatched"
		,"_ReconciliationSectionTypeEwbMismatched" :="_ReconciliationSectionTypeEwbMismatched"
		,"_ReconciliationSectionTypeEinvNotAvailable" :="_ReconciliationSectionTypeEinvNotAvailable"
		,"_ReconciliationSectionTypeEinvMatched" :="_ReconciliationSectionTypeEinvMatched"
		,"_ReconciliationSectionTypeEinvMismatched" :="_ReconciliationSectionTypeEinvMismatched"
		,"_ReconciliationSectionTypeEwbNotApplicable" :="_ReconciliationSectionTypeEwbNotApplicable"
		,"_ContactTypeBillTo" :="_ContactTypeBillTo"
		,"_ContactTypeBillFrom" :="_ContactTypeBillFrom"
		,"_SourceTypeTaxpayer" :="_SourceTypeTaxpayer"
		,"_ReconciliationReasonTypeTaxAmount" :="_ReconciliationReasonTypeTaxAmount"
		,"_ReconciliationReasonTypeItems" :="_ReconciliationReasonTypeItems"
		,"_ReconciliationReasonTypeSgstAmount" :="_ReconciliationReasonTypeSgstAmount"
		,"_ReconciliationReasonTypeCgstAmount" :="_ReconciliationReasonTypeCgstAmount"
		,"_ReconciliationReasonTypeIgstAmount" :="_ReconciliationReasonTypeIgstAmount"
		,"_ReconciliationReasonTypeCessAmount" :="_ReconciliationReasonTypeCessAmount"
		,"_ReconciliationReasonTypeTaxableValue" :="_ReconciliationReasonTypeTaxableValue"
		,"_ReconciliationReasonTypeTransactionType" :="_ReconciliationReasonTypeTransactionType"
		,"_ReconciliationReasonTypePOS" :="_ReconciliationReasonTypePOS"
		,"_ReconciliationReasonTypeReverseCharge" :="_ReconciliationReasonTypeReverseCharge"
		,"_ReconciliationReasonTypeDocumentValue" :="_ReconciliationReasonTypeDocumentValue"
		,"_ReconciliationReasonTypeDocumentDate" :="_ReconciliationReasonTypeDocumentDate"
		,"_ReconciliationReasonTypeDocumentNumber" :="_ReconciliationReasonTypeDocumentNumber"
		,"_ReconciliationReasonTypeRate" := "_ReconciliationReasonTypeRate"
		,"_ReconciliationReasonTypeGstin" := "_ReconciliationReasonTypeGstin"
		,"_SettingTypeExcludeOtherCharges" :="_SettingTypeExcludeOtherCharges"
		,"_IsMatchByTolerance" :="_IsMatchByTolerance"
		,"_MatchByToleranceDocumentValueFrom" :="_MatchByToleranceDocumentValueFrom"
		,"_MatchByToleranceDocumentValueTo" :="_MatchByToleranceDocumentValueTo"
		,"_MatchByToleranceTaxableValueFrom" :="_MatchByToleranceTaxableValueFrom"
		,"_MatchByToleranceTaxableValueTo" :="_MatchByToleranceTaxableValueTo"
		,"_MatchByToleranceTaxAmountsFrom" :="_MatchByToleranceTaxAmountsFrom"
		,"_MatchByToleranceTaxAmountsTo" :="_MatchByToleranceTaxAmountsTo"
		,"_DocValueThresholdForRecoAgainstEwb" :="_DocValueThresholdForRecoAgainstEwb"
		,"_IsExcludeMatchingCriteriaTransactionType" := "_IsExcludeMatchingCriteriaTransactionType"
		,"_IsExcludeMatchingCriteriaGstin":="_IsExcludeMatchingCriteriaGstin" 		
        );
	RAISE NOTICE 'Main18';
	
	/*Executing sp for Ewaybill reconciliation */
	INSERT INTO "TempEwaybillReconciledInsertedIds"
	SELECT * FROM  report."InsertEwaybill3WayReconciliation"
		("_SubscriberId"	:="_SubscriberId"
		,"_ParentEntityId" :="_ParentEntityId"
		,"_FinancialYear" :="_FinancialYear"
		,"_DocumentTypeINV" :="_DocumentTypeINV"
		,"_DocumentTypeBOE" :="_DocumentTypeBOE"
		,"_DocumentTypeCHL" :="_DocumentTypeCHL"
		,"_DocumentTypeBIL" :="_DocumentTypeBIL"
		,"_PurposeTypeEInv" :="_PurposeTypeEINV"
		,"_PurposeTypeEWB" :="_PurposeTypeEWB"
		,"_SupplyTypeSale" :="_SupplyTypeSale"
		,"_IsDocumentDateReturnPeriod" :="_IsDocumentDateReturnPeriod"
		,"_SupplyTypePurchase" :="_SupplyTypePurchase" 
		,"_SourceTypeTaxpayer" :="_SourceTypeTaxpayer"
		,"_TransactionTypeB2B" :="_TransactionTypeB2B"
		,"_TransactionTypeB2C" :="_TransactionTypeB2C" 
		,"_TransactionTypeSEZWP" :="_TransactionTypeSEZWP"
		,"_TransactionTypeSEZWOP" :="_TransactionTypeSEZWOP"
		,"_TransactionTypeEXPWP" :="_TransactionTypeEXPWP"
		,"_TransactionTypeEXPWOP" :="_TransactionTypeEXPWOP"
		,"_TransactionTypeDE" :="_TransactionTypeDE"
		,"_TransactionTypeIMPG" :="_TransactionTypeIMPG" 
		,"_TransactionTypeKD" :="_TransactionTypeKD"
		,"_TransactionTypeJW" :="_TransactionTypeJW"
		,"_TransactionTypeJWR" :="_TransactionTypeJWR"
		,"_TransactionTypeOTH" :="_TransactionTypeOTH"
		,"_TransactionTypeCBW" :="_TransactionTypeCBW" 
		,"_ReconciliationSectionTypeGstNotAvailable" :="_ReconciliationSectionTypeGstNotAvailable"
		,"_ReconciliationSectionTypeGstMatched" :="_ReconciliationSectionTypeGstMatched"
		,"_ReconciliationSectionTypeGstMismatched" :="_ReconciliationSectionTypeGstMismatched"
		,"_ReconciliationSectionTypeEwbNotAvailable" :="_ReconciliationSectionTypeEwbNotAvailable"
		,"_ReconciliationSectionTypeEwbMatched" :="_ReconciliationSectionTypeEwbMatched"
		,"_ReconciliationSectionTypeEwbMismatched" :="_ReconciliationSectionTypeEwbMismatched"
		,"_ReconciliationSectionTypeEinvNotAvailable" :="_ReconciliationSectionTypeEinvNotAvailable"
		,"_ReconciliationSectionTypeEinvMatched" :="_ReconciliationSectionTypeEinvMatched"
		,"_ReconciliationSectionTypeEinvMismatched" :="_ReconciliationSectionTypeEinvMismatched"
		,"_ContactTypeBillFromGstin" :="_ContactTypeBillFrom"
		,"_ReconciliationReasonTypeTaxAmount" :="_ReconciliationReasonTypeTaxAmount"
		,"_ReconciliationReasonTypeItems" :="_ReconciliationReasonTypeItems"
		,"_ReconciliationReasonTypeSgstAmount" :="_ReconciliationReasonTypeSgstAmount"
		,"_ReconciliationReasonTypeCgstAmount" :="_ReconciliationReasonTypeCgstAmount"
		,"_ReconciliationReasonTypeIgstAmount" :="_ReconciliationReasonTypeIgstAmount"
		,"_ReconciliationReasonTypeCessAmount" :="_ReconciliationReasonTypeCessAmount"
		,"_ReconciliationReasonTypeTaxableValue" :="_ReconciliationReasonTypeTaxableValue"
		,"_ReconciliationReasonTypeTransactionType" :="_ReconciliationReasonTypeTransactionType"
		,"_ReconciliationReasonTypePOS" :="_ReconciliationReasonTypePOS"
		,"_ReconciliationReasonTypeReverseCharge" :="_ReconciliationReasonTypeReverseCharge"
		,"_ReconciliationReasonTypeDocumentValue" :="_ReconciliationReasonTypeDocumentValue"
		,"_ReconciliationReasonTypeDocumentDate" :="_ReconciliationReasonTypeDocumentDate"
		,"_ReconciliationReasonTypeDocumentNumber" :="_ReconciliationReasonTypeDocumentNumber"
		,"_ReconciliationReasonTypeRate" := "_ReconciliationReasonTypeRate"
		,"_SettingTypeExcludeOtherCharges" :="_SettingTypeExcludeOtherCharges"
		,"_IsMatchByTolerance" :="_IsMatchByTolerance" 
		,"_MatchByToleranceDocumentValueFrom" :="_MatchByToleranceDocumentValueFrom"
		,"_MatchByToleranceDocumentValueTo" :="_MatchByToleranceDocumentValueTo"
		,"_MatchByToleranceTaxableValueFrom" :="_MatchByToleranceTaxableValueFrom"
		,"_MatchByToleranceTaxableValueTo" :="_MatchByToleranceTaxableValueTo"
		,"_MatchByToleranceTaxAmountsFrom" :="_MatchByToleranceTaxAmountsFrom"
		,"_MatchByToleranceTaxAmountsTo" :="_MatchByToleranceTaxAmountsTo"
		,"_IsExcludeMatchingCriteriaTransactionType" := "_IsExcludeMatchingCriteriaTransactionType"
		,"_IsExcludeMatchingCriteriaGstin":="_IsExcludeMatchingCriteriaGstin"
-- 		,"_ReconciliationReasonTypeGstin" := "_ReconciliationReasonTypeGstin"
        );

	RAISE NOTICE 'Main19';
	/*Executing sp for Sales and Purchase reconciliation */
	INSERT INTO"TempGstReconciledInsertedIds"
	SELECT * FROM  report."InsertRegularReturns3WayReconciliation"
	(
		"_SubscriberId":="_SubscriberId"::integer, 
		"_ParentEntityId":="_ParentEntityId"::integer, 
		"_FinancialYear":="_FinancialYear"::integer, 
		"_DocumentTypEInv":="_DocumentTypeINV"::smallint, 
		"_DocumentTypeCRN":="_DocumentTypeCRN"::smallint, 
		"_DocumentTypeDBN":="_DocumentTypeDBN"::smallint, 
		"_DocumentTypeBOE":="_DocumentTypeBOE"::smallint, 
		"_DocumentTypeCHL":="_DocumentTypeCHL"::smallint, 
		"_DocumentTypeBIL":="_DocumentTypeBIL"::smallint, 
		"_PurposeTypeEInv":="_PurposeTypeEINV"::smallint, 
		"_PurposeTypeEWB":="_PurposeTypeEWB"::smallint, 
		"_SupplyTypeSale":="_SupplyTypeSale"::smallint, 
		"_SupplyTypePurchase":="_SupplyTypePurchase"::smallint, 
		"_SourceTypeTaxpayer":="_SourceTypeTaxpayer"::smallint, 
		"_SourceTypeAutoDraft":="_SourceTypeAutoDraft"::smallint, 
		"_TransactionTypeB2B":="_TransactionTypeB2B"::smallint, 
		"_TransactionTypeB2C":="_TransactionTypeB2C"::smallint, 
		"_TransactionTypeSEZWP":="_TransactionTypeSEZWP"::smallint, 
		"_TransactionTypeSEZWOP":="_TransactionTypeSEZWOP"::smallint, 
		"_TransactionTypeEXPWP":="_TransactionTypeEXPWP"::smallint, 
		"_TransactionTypeEXPWOP":="_TransactionTypeEXPWOP"::smallint, 
		"_TransactionTypeDE":="_TransactionTypeDE"::smallint, 
		"_TransactionTypeIMPG":="_TransactionTypeIMPG"::smallint, 
		"_TransactionTypeCBW":="_TransactionTypeCBW"::smallint, 
		"_TransactionTypeOTH":="_TransactionTypeOTH"::smallint, 
		"_TransactionTypeKD":="_TransactionTypeKD"::smallint, 
		"_TransactionTypeJW":="_TransactionTypeJW"::smallint, 
		"_TransactionTypeJWR":="_TransactionTypeJWR"::smallint, 
		"_IsDocumentDateReturnPeriod":="_IsDocumentDateReturnPeriod"::boolean, 
		"_ReconciliationSectionTypeGstNotAvailable":="_ReconciliationSectionTypeGstNotAvailable"::smallint, 
		"_ReconciliationSectionTypeGstMatched":="_ReconciliationSectionTypeGstMatched"::smallint, 
		"_ReconciliationSectionTypeGstMismatched":="_ReconciliationSectionTypeGstMismatched"::smallint, 
		"_ReconciliationSectionTypeEwbNotAvailable":="_ReconciliationSectionTypeEwbNotAvailable"::smallint, 
		"_ReconciliationSectionTypeEwbMatched":="_ReconciliationSectionTypeEwbMatched"::smallint, 
		"_ReconciliationSectionTypeEwbMismatched":="_ReconciliationSectionTypeEwbMismatched"::smallint, 
		"_ReconciliationSectionTypeEInvNotAvailable":="_ReconciliationSectionTypeEinvNotAvailable"::smallint, 
		"_ReconciliationSectionTypeEInvMatched":="_ReconciliationSectionTypeEinvMatched"::smallint, 
		"_ReconciliationSectionTypeEInvMismatched":="_ReconciliationSectionTypeEinvMismatched"::smallint, 
		"_ReconciliationSectionTypeGstAutodraftedMatched":="_ReconciliationSectionTypeGstAutodraftedMatched"::smallint, 
		"_ReconciliationSectionTypeGstAutodraftedMismatched":="_ReconciliationSectionTypeGstAutodraftedMismatched"::smallint, 
		"_ReconciliationSectionTypeGstAutodraftedNotAvailable":="_ReconciliationSectionTypeGstAutodraftedNotAvailable"::smallint, 
		"_ReconciliationSectionTypeEwbNotApplicable":="_ReconciliationSectionTypeEwbNotApplicable"::smallint, 
		"_ContactTypeBillFromGstin":="_ContactTypeBillFrom"::smallint, 
		"_ReconciliationReasonTypeTaxAmount":="_ReconciliationReasonTypeTaxAmount"::bigint, 
		"_ReconciliationReasonTypeItems":="_ReconciliationReasonTypeItems"::bigint, 
		"_ReconciliationReasonTypeSgstAmount":="_ReconciliationReasonTypeSgstAmount"::bigint, 
		"_ReconciliationReasonTypeCgstAmount":="_ReconciliationReasonTypeCgstAmount"::bigint, 
		"_ReconciliationReasonTypeIgstAmount":="_ReconciliationReasonTypeIgstAmount"::bigint, 
		"_ReconciliationReasonTypeCessAmount":="_ReconciliationReasonTypeCessAmount"::bigint, 
		"_ReconciliationReasonTypeTaxableValue":="_ReconciliationReasonTypeTaxableValue"::bigint, 
		"_ReconciliationReasonTypeTransactionType":="_ReconciliationReasonTypeTransactionType"::bigint, 
		"_ReconciliationReasonTypePOS":="_ReconciliationReasonTypePOS"::bigint, 
		"_ReconciliationReasonTypeReverseCharge":="_ReconciliationReasonTypeReverseCharge"::bigint, 
		"_ReconciliationReasonTypeDocumentValue":="_ReconciliationReasonTypeDocumentValue"::bigint, 
		"_ReconciliationReasonTypeDocumentDate":="_ReconciliationReasonTypeDocumentDate"::bigint, 
		"_ReconciliationReasonTypeDocumentNumber":="_ReconciliationReasonTypeDocumentNumber"::bigint, 
		"_ReconciliationReasonTypeRate" := "_ReconciliationReasonTypeRate"::bigint,
        "_ReconciliationReasonTypeGstin" := "_ReconciliationReasonTypeGstin"::bigint,
		"_SettingTypeExcludeOtherCharges":="_SettingTypeExcludeOtherCharges"::boolean, 
		"_IsMatchByTolerance":="_IsMatchByTolerance"::boolean, 
		"_MatchByToleranceDocumentValueFrom":="_MatchByToleranceDocumentValueFrom"::numeric, 
		"_MatchByToleranceDocumentValueTo":="_MatchByToleranceDocumentValueTo"::numeric, 
		"_MatchByToleranceTaxableValueFrom":="_MatchByToleranceTaxableValueFrom"::numeric, 
		"_MatchByToleranceTaxableValueTo":="_MatchByToleranceTaxableValueTo"::numeric, 
		"_MatchByToleranceTaxAmountsFrom":="_MatchByToleranceTaxAmountsFrom"::numeric, 
		"_MatchByToleranceTaxAmountsTo":="_MatchByToleranceTaxAmountsTo"::numeric, 
		"_DocValueThresholdForRecoAgainstEwb":="_DocValueThresholdForRecoAgainstEwb"::numeric,
		"_IsExcludeMatchingCriteriaTransactionType" := "_IsExcludeMatchingCriteriaTransactionType"
		,"_IsExcludeMatchingCriteriaGstin":="_IsExcludeMatchingCriteriaGstin"
-- 		,"_ReconciliationReasonTypeGstin" = "_ReconciliationReasonTypeGstin"
	);

	RAISE NOTICE 'Main20';

	/*Executing sp for Sales and Purchase reconciliation */
	INSERT INTO"TempAutoDraftReconciledInsertedIds"
	SELECT * FROM report."InsertAutoDraft3WayReconciliation"
		("_SubscriberId"	:="_SubscriberId"
		,"_ParentEntityId" :="_ParentEntityId"
		,"_FinancialYear" :="_FinancialYear"
		,"_IsDocumentDateReturnPeriod" :="_IsDocumentDateReturnPeriod"

		,"_DocumentTypeINV" :="_DocumentTypeINV"
		,"_DocumentTypeCRN" :="_DocumentTypeCRN"
		,"_DocumentTypeDBN" :="_DocumentTypeDBN"
		,"_DocumentTypeBOE" :="_DocumentTypeBOE"
		,"_DocumentTypeCHL" :="_DocumentTypeCHL"
		,"_DocumentTypeBIL" :="_DocumentTypeBIL"

		,"_SupplyTypeSale" :="_SupplyTypeSale"

		,"_SourceTypeTaxpayer" :="_SourceTypeTaxpayer"
		,"_SourceTypeAutoDraft" :="_SourceTypeAutoDraft"

		,"_TransactionTypeB2B" :="_TransactionTypeB2B"
		,"_TransactionTypeB2C" :="_TransactionTypeB2C"
		,"_TransactionTypeSEZWP" :="_TransactionTypeSEZWP"
		,"_TransactionTypeSEZWOP" :="_TransactionTypeSEZWOP"
		,"_TransactionTypeEXPWP" :="_TransactionTypeEXPWP"
		,"_TransactionTypeEXPWOP" :="_TransactionTypeEXPWOP"
		,"_TransactionTypeDE" :="_TransactionTypeDE"
		,"_TransactionTypeIMPG" :="_TransactionTypeIMPG"
		,"_TransactionTypeCBW" :="_TransactionTypeCBW"
		,"_TransactionTypeOTH" :="_TransactionTypeOTH"

		,"_ReconciliationSectionTypeGstNotAvailable" :="_ReconciliationSectionTypeGstNotAvailable"
		,"_ReconciliationSectionTypeGstMatched" :="_ReconciliationSectionTypeGstMatched"
		,"_ReconciliationSectionTypeGstMismatched" :="_ReconciliationSectionTypeGstMismatched"
		,"_ReconciliationSectionTypeGstAutodraftedNotAvailable" :="_ReconciliationSectionTypeGstAutodraftedNotAvailable"

		,"_ReconciliationReasonTypeTaxAmount" :="_ReconciliationReasonTypeTaxAmount"
		,"_ReconciliationReasonTypeItems" :="_ReconciliationReasonTypeItems"
		,"_ReconciliationReasonTypeSgstAmount" :="_ReconciliationReasonTypeSgstAmount"
		,"_ReconciliationReasonTypeCgstAmount" :="_ReconciliationReasonTypeCgstAmount"
		,"_ReconciliationReasonTypeIgstAmount" :="_ReconciliationReasonTypeIgstAmount"
		,"_ReconciliationReasonTypeCessAmount" :="_ReconciliationReasonTypeCessAmount"
		,"_ReconciliationReasonTypeTaxableValue" :="_ReconciliationReasonTypeTaxableValue"
		,"_ReconciliationReasonTypeTransactionType" :="_ReconciliationReasonTypeTransactionType"
		,"_ReconciliationReasonTypePOS" :="_ReconciliationReasonTypePOS"
		,"_ReconciliationReasonTypeReverseCharge" :="_ReconciliationReasonTypeReverseCharge"
		,"_ReconciliationReasonTypeDocumentValue" :="_ReconciliationReasonTypeDocumentValue"
		,"_ReconciliationReasonTypeDocumentDate" :="_ReconciliationReasonTypeDocumentDate"
		,"_ReconciliationReasonTypeDocumentNumber" :="_ReconciliationReasonTypeDocumentNumber"
		,"_ReconciliationReasonTypeRate" := "_ReconciliationReasonTypeRate"::bigint
		,"_ReconciliationReasonTypeGstin" := "_ReconciliationReasonTypeGstin"
		,"_IsMatchByTolerance" :="_IsMatchByTolerance"
		,"_MatchByToleranceDocumentValueFrom" :="_MatchByToleranceDocumentValueFrom"
		,"_MatchByToleranceDocumentValueTo" :="_MatchByToleranceDocumentValueTo"
		,"_MatchByToleranceTaxableValueFrom" :="_MatchByToleranceTaxableValueFrom"
		,"_MatchByToleranceTaxableValueTo" :="_MatchByToleranceTaxableValueTo"
		,"_MatchByToleranceTaxAmountsFrom" :="_MatchByToleranceTaxAmountsFrom"
		,"_MatchByToleranceTaxAmountsTo" :="_MatchByToleranceTaxAmountsTo"
		,"_IsExcludeMatchingCriteriaTransactionType" := "_IsExcludeMatchingCriteriaTransactionType"
		,"_IsExcludeMatchingCriteriaGstin":="_IsExcludeMatchingCriteriaGstin"
        );

	/*Executing sp for Purchase reconciliation of E-Invoice */
	INSERT INTO "TempPurchaseAutoDraftIds"("PurchaseAutoDraftId")
	SELECT * FROM report."InsertPurchaseAutoDraft3WayReconciliation"
	(
		 "_SubscriberId" => "_SubscriberId"::INT
		,"_ParentEntityId" => "_ParentEntityId"::INT
		,"_FinancialYear" => "_FinancialYear"::INT	
		/* Enums */
		,"_DocumentTypeINV"=> "_DocumentTypeINV" ::SMALLINT
		,"_DocumentTypeCRN"=> "_DocumentTypeCRN" ::SMALLINT
		,"_DocumentTypeDBN"=> "_DocumentTypeDBN" ::SMALLINT

		,"_SupplyTypePurchase"=> "_SupplyTypePurchase" ::SMALLINT 	

		,"_TransactionTypeB2B"=> "_TransactionTypeB2B" ::SMALLINT
		,"_TransactionTypeB2C"=> "_TransactionTypeB2C" ::SMALLINT
		,"_TransactionTypeSEZWP"=> "_TransactionTypeSEZWP" ::SMALLINT
		,"_TransactionTypeSEZWOP"=> "_TransactionTypeSEZWOP" ::SMALLINT
		,"_TransactionTypeEXPWP"=> "_TransactionTypeEXPWP" ::SMALLINT
		,"_TransactionTypeEXPWOP"=> "_TransactionTypeEXPWOP" ::SMALLINT
		,"_TransactionTypeDE"=> "_TransactionTypeDE" ::SMALLINT
		,"_TransactionTypeIMPG"=> "_TransactionTypeIMPG" ::SMALLINT
		,"_TransactionTypeCBW"=> "_TransactionTypeCBW" ::SMALLINT
		,"_TransactionTypeOTH"=> "_TransactionTypeOTH" ::SMALLINT
		,"_IsDocumentDateReturnPeriod"=> "_IsDocumentDateReturnPeriod" ::BOOLEAN

		,"_ReconciliationSectionTypeGstNotAvailable"=> "_ReconciliationSectionTypeGstNotAvailable" ::SMALLINT
		,"_ReconciliationSectionTypeGstMatched"=> "_ReconciliationSectionTypeGstMatched" ::SMALLINT
		,"_ReconciliationSectionTypeGstMismatched"=> "_ReconciliationSectionTypeGstMismatched" ::SMALLINT	
		,"_ReconciliationSectionTypeGstAutoDraftedMatched"=> "_ReconciliationSectionTypeGstAutodraftedMatched" ::SMALLINT
		,"_ReconciliationSectionTypeGstAutoDraftedMismatched"=> "_ReconciliationSectionTypeGstAutodraftedMismatched" ::SMALLINT	
		,"_ReconciliationSectionTypeQrCodeNotAvailable"=> "_ReconciliationSectionTypeQrCodeNotAvailable" ::SMALLINT

		,"_ReconciliationReasonTypeTaxAmount"=> "_ReconciliationReasonTypeTaxAmount" ::BIGINT
		,"_ReconciliationReasonTypeItems"=> "_ReconciliationReasonTypeItems" ::BIGINT
		,"_ReconciliationReasonTypeSgstAmount"=> "_ReconciliationReasonTypeSgstAmount" ::BIGINT
		,"_ReconciliationReasonTypeCgstAmount"=> "_ReconciliationReasonTypeCgstAmount" ::BIGINT
		,"_ReconciliationReasonTypeIgstAmount"=> "_ReconciliationReasonTypeIgstAmount" ::BIGINT
		,"_ReconciliationReasonTypeCessAmount"=> "_ReconciliationReasonTypeCessAmount" ::BIGINT
		,"_ReconciliationReasonTypeTaxableValue"=> "_ReconciliationReasonTypeTaxableValue" ::BIGINT
		,"_ReconciliationReasonTypeTransactionType"=> "_ReconciliationReasonTypeTransactionType" ::BIGINT
		,"_ReconciliationReasonTypePOS"=> "_ReconciliationReasonTypePOS" ::BIGINT
		,"_ReconciliationReasonTypeReverseCharge"=> "_ReconciliationReasonTypeReverseCharge" ::BIGINT
		,"_ReconciliationReasonTypeDocumentValue"=> "_ReconciliationReasonTypeDocumentValue" ::BIGINT
		,"_ReconciliationReasonTypeDocumentDate"=> "_ReconciliationReasonTypeDocumentDate" ::BIGINT
		,"_ReconciliationReasonTypeDocumentNumber"=> "_ReconciliationReasonTypeDocumentNumber" ::BIGINT
		,"_ReconciliationReasonTypeIrn"=> "_ReconciliationReasonTypeIrn" ::BIGINT
		,"_ReconciliationReasonTypeRate" := "_ReconciliationReasonTypeRate"::bigint
		,"_ReconciliationReasonTypeGstin" := "_ReconciliationReasonTypeGstin"::bigint
		
		,"_IsMatchByTolerance"=> "_IsMatchByTolerance" ::BOOLEAN
		,"_MatchByToleranceDocumentValueFrom"=> "_MatchByToleranceDocumentValueFrom" :: DECIMAL(15,2)
		,"_MatchByToleranceDocumentValueTo"=> "_MatchByToleranceDocumentValueTo" ::DECIMAL(15,2)
		,"_MatchByToleranceTaxableValueFrom"=> "_MatchByToleranceTaxableValueFrom" ::DECIMAL(15,2)
		,"_MatchByToleranceTaxableValueTo"=> "_MatchByToleranceTaxableValueTo" :: DECIMAL(15,2)
		,"_MatchByToleranceTaxAmountsFrom"=> "_MatchByToleranceTaxAmountsFrom" ::DECIMAL(15,2)
		,"_MatchByToleranceTaxAmountsTo"=> "_MatchByToleranceTaxAmountsTo" ::DECIMAL(15,2)
		
		,"_SourceTypeTaxpayer"=>"_SourceTypeTaxpayer"::smallint
		,"_SourceTypeEInvoice"=> "_SourceTypeEInvoice" ::SMALLINT	
		,"_IsExcludeMatchingCriteriaTransactionType" := "_IsExcludeMatchingCriteriaTransactionType"
		,"_IsExcludeMatchingCriteriaGstin" := "_IsExcludeMatchingCriteriaGstin"
		,"_IsExcludeMatchingCriteriaIrn" := "_IsExcludeMatchingCriteriaIrn"
	);
	
	RAISE NOTICE 'Step InsertEinvoiceQrCode3WayReconciliation';
	
	/*Executing sp for Einvoice Qr Code reconciliation*/
	INSERT INTO "TempEinvQrCodeIds"("EinvQrId")
	SELECT * FROM report."InsertEinvoiceQrCode3WayReconciliation"
	(
		 "_SubscriberId" => "_SubscriberId"::INT
		,"_ParentEntityId" => "_ParentEntityId"::INT
		,"_FinancialYear" => "_FinancialYear"::INT	
		/* Enums */
		,"_DocumentTypeINV"=> "_DocumentTypeINV" ::SMALLINT
		,"_DocumentTypeCRN"=> "_DocumentTypeCRN" ::SMALLINT
		,"_DocumentTypeDBN"=> "_DocumentTypeDBN" ::SMALLINT

		,"_SupplyTypePurchase"=> "_SupplyTypePurchase" ::SMALLINT 	

		,"_TransactionTypeB2B"=> "_TransactionTypeB2B" ::SMALLINT
		,"_TransactionTypeB2C"=> "_TransactionTypeB2C" ::SMALLINT
		,"_TransactionTypeSEZWP"=> "_TransactionTypeSEZWP" ::SMALLINT
		,"_TransactionTypeSEZWOP"=> "_TransactionTypeSEZWOP" ::SMALLINT
		,"_TransactionTypeEXPWP"=> "_TransactionTypeEXPWP" ::SMALLINT
		,"_TransactionTypeEXPWOP"=> "_TransactionTypeEXPWOP" ::SMALLINT
		,"_TransactionTypeDE"=> "_TransactionTypeDE" ::SMALLINT
		,"_TransactionTypeIMPG"=> "_TransactionTypeIMPG" ::SMALLINT
		,"_TransactionTypeCBW"=> "_TransactionTypeCBW" ::SMALLINT
		,"_TransactionTypeOTH"=> "_TransactionTypeOTH" ::SMALLINT
		,"_IsDocumentDateReturnPeriod"=> "_IsDocumentDateReturnPeriod" ::BOOLEAN

		,"_ReconciliationSectionTypeGstAutodraftedMatched"=> "_ReconciliationSectionTypeGstAutodraftedMatched" ::SMALLINT
		,"_ReconciliationSectionTypeGstAutodraftedMismatched"=> "_ReconciliationSectionTypeGstAutodraftedMismatched" ::SMALLINT	
		,"_ReconciliationSectionTypeGstAutodraftedNotAvailable"=> "_ReconciliationSectionTypeGstAutodraftedNotAvailable" ::SMALLINT

		,"_ReconciliationSectionTypeQrCodeMatched"=>"_ReconciliationSectionTypeQrCodeMatched"::SMALLINT
		,"_ReconciliationSectionTypeQrCodeMismatched"=>"_ReconciliationSectionTypeQrCodeMismatched"::SMALLINT

		,"_ReconciliationReasonTypeItems"=> "_ReconciliationReasonTypeItems" ::BIGINT
		,"_ReconciliationReasonTypeDocumentValue"=> "_ReconciliationReasonTypeDocumentValue" ::BIGINT
		,"_ReconciliationReasonTypeIrn"=> "_ReconciliationReasonTypeIrn" ::BIGINT

		,"_IsMatchByTolerance"=> "_IsMatchByTolerance" ::BOOLEAN
		,"_MatchByToleranceDocumentValueFrom"=> "_MatchByToleranceDocumentValueFrom" :: DECIMAL(15,2)
		,"_MatchByToleranceDocumentValueTo"=> "_MatchByToleranceDocumentValueTo" ::DECIMAL(15,2)

		,"_SourceTypeEInvoice"=> "_SourceTypeEInvoice" ::SMALLINT
-- 		,"" := "_IsExcludeMatchingCriteriaTransactionType"
-- 		,"_IsExcludeMatchingCriteriaGstin":="_IsExcludeMatchingCriteriaGstin"
-- 		,"_ReconciliationReasonTypeGstin" = "_ReconciliationReasonTypeGstin"
	);

	RAISE NOTICE 'Main21_IsExcludeMatchingCriteriaTransactionType';
	
	UPDATE einvoice."DocumentDW" dw  SET "Is3WayReconciled" = true
	FROM 
		"TempEinvoiceReconciledInsertedIds" ids 
	WHERE "Is3WayReconciled" <> true AND dw."Id" = ids."EInvId";

	UPDATE einvoice."DocumentDW" dw  SET "Is3WayReconciled" = true
	FROM 
		"TempEwaybillReconciledInsertedIds" ids 
	WHERE "Is3WayReconciled" <> true AND dw."Id" = ids."EWBId";

	UPDATE oregular."SaleDocumentDW" dw  SET "Is3WayReconciled" = true
	FROM 
		 "TempGstReconciledInsertedIds" ids 
	WHERE dw."Id" = ids."GstId" AND ids."SupplyType" = "_SupplyTypeSale"
		AND "Is3WayReconciled" <> true;

	UPDATE oregular."PurchaseDocumentDW" dw  SET "Is3WayReconciled" = true
	FROM 
		"TempGstReconciledInsertedIds" ids
	WHERE dw."Id" = ids."GstId" AND ids."SupplyType" = "_SupplyTypePurchase";

	UPDATE oregular."SaleDocumentDW" dw  SET "Is3WayReconciled" = true
	FROM 
		"TempAutoDraftReconciledInsertedIds" ids
	WHERE dw."Id" = ids."AutoDraftId"; 
	
	UPDATE oregular."PurchaseDocumentDW" pd
		SET "Is3WayReconciled" = True
	FROM
		"TempPurchaseAutoDraftIds" tep
	WHERE 
		tep."PurchaseAutoDraftId" = pd."Id";
		
	UPDATE einvoice."QrCodeDetails" pd
		SET "Is3WayReconciled" = True
	FROM
		"TempEinvQrCodeIds" tep
	WHERE 
		tep."EinvQrId" = pd."Id";

	DROP TABLE IF EXISTS "TempEinvoiceDeletedIds","TempEinvoiceReconciledInsertedIds","TempEinvoiceUpdatedIds","TempEwaybillDeletedIds","TempEwaybillDuplicateEntries","TempEwaybillReconciledInsertedIds","TempEwaybillUpdatedIds","TempGstDeletedIds","TempGstReconciledInsertedIds","TempGstUpdatedIds","EInvoicePushStatuses","EwaybillPushStatuses","GstPushStatuses", "TempEinvQrCodeIds";	

END;
$function$
;
DROP FUNCTION IF EXISTS report."InsertAutoDraft3WayReconciliation";

CREATE OR REPLACE FUNCTION report."InsertAutoDraft3WayReconciliation"("_SubscriberId" integer, "_ParentEntityId" integer, "_FinancialYear" integer, "_DocumentTypeINV" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeBOE" smallint, "_DocumentTypeCHL" smallint, "_DocumentTypeBIL" smallint, "_SupplyTypeSale" smallint, "_SourceTypeTaxpayer" smallint, "_SourceTypeAutoDraft" smallint, "_TransactionTypeB2B" smallint, "_TransactionTypeB2C" smallint, "_TransactionTypeSEZWP" smallint, "_TransactionTypeSEZWOP" smallint, "_TransactionTypeEXPWP" smallint, "_TransactionTypeEXPWOP" smallint, "_TransactionTypeDE" smallint, "_TransactionTypeIMPG" smallint, "_TransactionTypeCBW" smallint, "_TransactionTypeOTH" smallint, "_IsDocumentDateReturnPeriod" boolean, "_ReconciliationSectionTypeGstNotAvailable" smallint, "_ReconciliationSectionTypeGstMatched" smallint, "_ReconciliationSectionTypeGstMismatched" smallint, "_ReconciliationSectionTypeGstAutodraftedNotAvailable" smallint, "_ReconciliationReasonTypeTaxAmount" bigint, "_ReconciliationReasonTypeItems" bigint, "_ReconciliationReasonTypeSgstAmount" bigint, "_ReconciliationReasonTypeCgstAmount" bigint, "_ReconciliationReasonTypeIgstAmount" bigint, "_ReconciliationReasonTypeCessAmount" bigint, "_ReconciliationReasonTypeTaxableValue" bigint, "_ReconciliationReasonTypeTransactionType" bigint, "_ReconciliationReasonTypePOS" bigint, "_ReconciliationReasonTypeReverseCharge" bigint, "_ReconciliationReasonTypeDocumentValue" bigint, "_ReconciliationReasonTypeDocumentDate" bigint, "_ReconciliationReasonTypeDocumentNumber" bigint, "_ReconciliationReasonTypeRate" bigint, "_ReconciliationReasonTypeGstin" bigint, "_IsMatchByTolerance" boolean, "_MatchByToleranceDocumentValueFrom" numeric, "_MatchByToleranceDocumentValueTo" numeric, "_MatchByToleranceTaxableValueFrom" numeric, "_MatchByToleranceTaxableValueTo" numeric, "_MatchByToleranceTaxAmountsFrom" numeric, "_MatchByToleranceTaxAmountsTo" numeric, "_IsExcludeMatchingCriteriaTransactionType" boolean, "_IsExcludeMatchingCriteriaGstin" boolean)
 RETURNS TABLE("AutoDraftId" bigint)
 LANGUAGE plpgsql
AS $function$

	DECLARE "_MappingTypeMonthly" SMALLINT = 1;
			"_MappingTypeYearly" SMALLINT = 2;			

BEGIN
	
	DROP TABLE IF EXISTS "TempYearlyAutoDraftGstReco","TempAutoDraftDetailData","TempAutoDraftData","TempGstUnreconciledIdsAuto"
				,"TempRegularReturnData","TempRegularReturnDetailData","TempYearlyAutoDraftGstdetailComp","TempYearlyAutoDraftGstHeaderMatching","TempYearlyAutoDraftGstMatchedId"
				,"TempAutoDraftUnreconciledIds2";

	CREATE TEMP TABLE "TempGstUnreconciledIdsAuto"
	(		
		"GstId" BIGINT NOT NULL
	);

	CREATE INDEX "IDX_TempGstUnreconciledIdsAuto" ON "TempGstUnreconciledIdsAuto"("GstId");

	CREATE TEMP TABLE "TempAutoDraftUnreconciledIds2"
	(		
		"AutoDraftId" BIGINT NOT NULL
	);

	CREATE  INDEX "IDX_TempAutoDraftUnreconciledIds2" ON "TempAutoDraftUnreconciledIds2"("AutoDraftId");		

	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO	"TempAutoDraftUnreconciledIds2"
	SELECT 
		d."Id" 
	FROM 
		Oregular."SaleDocumentDW" d			
	INNER JOIN oregular."SaleDocumentStatus" ss ON d."Id" = ss."SaleDocumentId"		
	WHERE 
			d."SubscriberId" = "_SubscriberId"
		AND d."FinancialYear" = "_FinancialYear"
		AND d."ParentEntityId" =  "_ParentEntityId"
		AND d."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW") 
		AND d."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")			
		AND d."Is3WayReconciled" = false	
		AND (ss."PushStatus" IN (SELECT e."Item" FROM "AutoDraftPushStatuses" e))
		AND d."SourceType" = "_SourceTypeAutoDraft"
		--AND ss."Status = true
		
	UNION 					

	SELECT 
		SAD."Id"
	FROM 
		oregular."SaleDocumentDW" SD	
		INNER JOIN oregular."SaleDocumentStatus" SS ON SD."Id" = ss."SaleDocumentId"		
		INNER JOIN oregular."SaleDocumentDW" SAD ON SD."DocumentNumber" = SAD."DocumentNumber" AND SD."DocumentFinancialYear" = SAD."DocumentFinancialYear" and SD."DocumentType" =SAD."DocumentType" 				
		INNER JOIN oregular."SaleDocumentStatus" SADS ON SAD."Id" = SADS."SaleDocumentId"		
	WHERE 
		SD."SubscriberId" = "_SubscriberId"
		AND SD."FinancialYear" = "_FinancialYear"
		AND SAD."SubscriberId" = "_SubscriberId"
		AND SD."ParentEntityId" =  "_ParentEntityId"
		AND SAD."ParentEntityId" =  "_ParentEntityId"
		AND SD."Is3WayReconciled" = false		
		AND SAD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW") 
		AND SAD."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")						
		AND (SS."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		AND (SADS."PushStatus" IN (SELECT e."Item" FROM "AutoDraftPushStatuses" e))
		AND SD."SourceType" = "_SourceTypeTaxpayer"
		AND SAD."SourceType" = "_SourceTypeAutoDraft";								

	IF EXISTS (SELECT 1 FROM "TempAutoDraftUnreconciledIds2")
	THEN

	/*To Get Ids of GstAutoDraft For Reconciliation  */
	INSERT INTO "TempGstUnreconciledIdsAuto"
	SELECT 
		SD."Id"
	FROM 
		"TempAutoDraftUnreconciledIds2" tui
		INNER JOIN oregular."SaleDocuments" SAD ON tui."AutoDraftId" = SAD."Id"
		INNER JOIN Oregular."SaleDocumentDW" SD ON SD."DocumentNumber" = SAD."DocumentNumber" AND SD."DocumentFinancialYear" = SAD."DocumentFinancialYear" AND SD."DocumentType" =SAD."DocumentType" 
		INNER JOIN oregular."SaleDocumentStatus" SS ON SD."Id" = ss."SaleDocumentId"	
	WHERE 
		SD."SubscriberId" = "_SubscriberId"
		AND SD."ParentEntityId" =  "_ParentEntityId"
		AND sd."SourceType" = "_SourceTypeTaxpayer"
		--AND SS."Status = true		
		AND SD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND SD."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")				
		AND (SS."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e));	
	

	DELETE 
	FROM "TempGstUnreconciledIdsAuto" a 
	USING "TempGstUnreconciledIdsAuto" b 
	WHERE
		a."GstId"=b."GstId" 
		AND a.ctid < b.ctid;
	
	CREATE TEMP TABLE "OregularSaleDocumentItems1" AS
	SELECT
		SDI."Id" AS "SaleDocumentItemId"
	FROM 
		oregular."SaleDocumentItems" SDI
	WHERE EXISTS (SELECT 1 FROM "TempGstUnreconciledIdsAuto" TED WHERE SDI."SaleDocumentId" = TED."GstId");

	/* Get data for Reconcilation in Temp Table */	
	CREATE TEMP TABLE "TempRegularReturnDetailData" AS
	SELECT 
		SDI."SaleDocumentId" "GstId",		
		SDI."Rate",
		COALESCE(SUM(SDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(SDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(SDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(SDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(SDI."CessAmount"),0)+COALESCE(SUM(SDI."StateCessAmount"),0)+COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0)+COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0)  "CessAmount",
		COALESCE(SUM(SDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0) "CessNonAdvaloremAmount",
		COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0) "StateCessNonAdvaloremAmount",
		COUNT(DISTINCT "Rate") "ItemCount",
		"_SupplyTypeSale" "SupplyType"			
	FROM 
		oregular."SaleDocumentItems" SDI
	INNER JOIN "OregularSaleDocumentItems1" TED ON SDI."Id" = TED."SaleDocumentItemId"
	GROUP BY "SaleDocumentId",SDI."Rate";
	DROP TABLE "OregularSaleDocumentItems1";

	DROP TABLE IF EXISTS "TempRegularReturnDetailDataAgg";	
	CREATE TEMP TABLE "TempRegularReturnDetailDataAgg" AS
	SELECT 
		dd."GstId",
		dd."SupplyType",
		SUM(dd."TaxableValue") "TaxableValue",
						SUM(dd."IgstAmount") "IgstAmount",
						SUM(dd."CgstAmount") "CgstAmount",
						SUM(dd."SgstAmount") "SgstAmount",
						SUM(dd."CessAmount") "CessAmount",
						SUM(dd."StateCessAmount") "StateCessAmount",
						SUM(dd."CessNonAdvaloremAmount") "CessNonAdvaloremAmount",
						SUM(dd."StateCessNonAdvaloremAmount") "StateCessNonAdvaloremAmount",
						SUM("ItemCount") "ItemCount"
	FROM "TempRegularReturnDetailData" dd
	GROUP BY dd."GstId",dd."SupplyType";
				
	CREATE TEMP TABLE "TempRegularReturnData" AS			
	SELECT 
		SD."Id",
		SD."DocumentNumber",
		to_date(sd."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		SD."DocumentValue",
		SD."DocumentType",
		SD."TransactionType",
		SD."Pos",
		SD."ReverseCharge",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN sd."DocumentReturnPeriod" ELSE SD."ReturnPeriod" END "ReturnPeriod",        
		SD."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN SD."DocumentFinancialYear" ELSE SD."FinancialYear" END "FinancialYear",
		SD."ParentEntityId",
		COALESCE("BillToGstin",'URP') "Gstin",
		"_SupplyTypeSale" "SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		sd."UnderIgstAct"
	FROM 
		oregular."SaleDocumentDW" SD
	INNER JOIN "TempGstUnreconciledIdsAuto" TED ON SD."Id" = TED."GstId" 
	INNER JOIN "TempRegularReturnDetailDataAgg" dd ON SD."Id" = dd."GstId" 
	AND dd."SupplyType" = "_SupplyTypeSale";	

	CREATE TEMP TABLE  "OregularSaleDocumentItems2" AS				
	SELECT
		SDI."Id" AS "SaleDocumentItemId"
	FROM 
		oregular."SaleDocumentItems" SDI
	WHERE EXISTS (SELECT 1 FROM "TempAutoDraftUnreconciledIds2" TED WHERE SDI."SaleDocumentId" = TED."AutoDraftId");

	/*Get data of Gst AUTO Drafted */
	CREATE TEMP TABLE "TempAutoDraftDetailData" AS
	SELECT 
		SDI."SaleDocumentId" "AutoDraftId",		
		SDI."Rate",
		COALESCE(SUM(SDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(SDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(SDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(SDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(SDI."CessAmount"),0) "CessAmount",
		COALESCE(SUM(SDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0) "CessNonAdvaloremAmount",
		COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0) "StateCessNonAdvaloremAmount",
		COUNT(DISTINCT "Rate") "ItemCount",
		"_SupplyTypeSale" "SupplyType"	 
	FROM 
		oregular."SaleDocumentItems" SDI
	INNER JOIN "OregularSaleDocumentItems2" TED ON SDI."Id" = TED."SaleDocumentItemId"
	GROUP BY "SaleDocumentId",SDI."Rate";
	
	DROP TABLE "OregularSaleDocumentItems2";
	
	DROP TABLE IF EXISTS "TempAutoDraftDetailDataAgg";
	CREATE TEMP TABLE "TempAutoDraftDetailDataAgg" AS
	SELECT 
	dd."AutoDraftId",	
	SUM(dd."TaxableValue") "TaxableValue",
						SUM(dd."IgstAmount") "IgstAmount",
						SUM(dd."CgstAmount") "CgstAmount",
						SUM(dd."SgstAmount") "SgstAmount",
						SUM(dd."CessAmount") "CessAmount",
						SUM(dd."StateCessAmount") "StateCessAmount",
						SUM(dd."CessNonAdvaloremAmount") "CessNonAdvaloremAmount",
						SUM(dd."StateCessNonAdvaloremAmount") "StateCessNonAdvaloremAmount",
						SUM("ItemCount") "ItemCount"
				FROM "TempAutoDraftDetailData" dd 
		 GROUP BY dd."AutoDraftId";

	CREATE TEMP TABLE "TempAutoDraftData" AS		
	SELECT 
		SD."Id",
		SD."DocumentNumber",
		to_date(sd."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		SD."DocumentValue",
		SD."DocumentType",
		SD."TransactionType",
		SD."Pos",
		SD."ReverseCharge",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN sd."DocumentReturnPeriod" ELSE SD."ReturnPeriod" END "ReturnPeriod",        
		SD."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN SD."DocumentFinancialYear" ELSE SD."FinancialYear" END "FinancialYear",
		SD."ParentEntityId",
		COALESCE("BillToGstin",'URP') "Gstin",
		"_SupplyTypeSale" "SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		sd."UnderIgstAct"
	FROM 
		oregular."SaleDocumentDW" SD
	INNER JOIN "TempAutoDraftUnreconciledIds2" TED ON SD."Id" = TED."AutoDraftId" 
	INNER JOIN "TempAutoDraftDetailDataAgg" dd ON SD."Id" = dd."AutoDraftId" ;
						
	--*************************Monthly Comparison Begin**************************************
	
	/*Header Level Matching of Gst data with GstAutoDraft  */
	CREATE TEMP TABLE "TempAutoDraftGstHeaderMatching" AS
	SELECT
		sad."Id" "AutoDraftId",		
		gst."Id" "GstId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = false OR gst."TransactionType" = sad."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR sad."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		CASE WHEN  ("_IsExcludeMatchingCriteriaGstin" = false OR gst."Gstin" = sad."Gstin") THEN NULL ELSE gst."Gstin" END "Gstin",
		CASE WHEN (gst."Pos" = 96 and gst."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (sad."Pos" = 96 and sad."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (gst."Pos" = sad."Pos") THEN NULL ELSE gst."Pos" END "Pos",
		CASE WHEN  gst."DocumentDate" = sad."DocumentDate" THEN NULL ELSE ABS(extract ( day from gst."DocumentDate"::timestamp -sad."DocumentDate"::timestamp)) END "DocumentDate",
		CASE WHEN  gst."ReverseCharge" = sad."ReverseCharge" THEN NULL ELSE CASE WHEN gst."ReverseCharge" = true THEN 'Y' ELSE 'N' END END "ReverseCharge",
		CASE WHEN  gst."DocumentValue" = sad."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN sad."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND sad."DocumentValue"+"_MatchByToleranceDocumentValueTo" THEN NULL		 
			 ELSE ABS(gst."DocumentValue" - sad."DocumentValue") END "DocumentValue",
		CASE WHEN  gst."ItemCount" = sad."ItemCount" THEN NULL ELSE ABS(gst."ItemCount" - sad."ItemCount") END "ItemCount",		
		CASE WHEN  gst."IgstAmount" = sad."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN sad."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."IgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."IgstAmount" - sad."IgstAmount") END "IgstAmount",		
		CASE WHEN  gst."SgstAmount" = sad."SgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN sad."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."SgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."SgstAmount" - sad."SgstAmount") END "SgstAmount",		
		CASE WHEN  gst."CgstAmount" = sad."CgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN sad."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CgstAmount" - sad."CgstAmount") END "CgstAmount",		
		CASE WHEN  gst."CessAmount" = sad."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN sad."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CessAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CessAmount" - sad."CessAmount") END "CessAmount",		
		CASE WHEN  gst."TaxableValue" = sad."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN sad."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND sad."TaxableValue"+"_MatchByToleranceTaxableValueTo" THEN NULL		 
			 ELSE ABS(gst."TaxableValue" - sad."TaxableValue") END "TaxableValue",		
		CASE WHEN  gst."StateCessAmount" = sad."StateCessAmount" THEN NULL ELSE ABS(gst."StateCessAmount" - sad."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType"
	FROM 
		"TempAutoDraftData" sad		
	INNER JOIN "TempRegularReturnData" gst ON gst."DocumentNumber" = sad."DocumentNumber" AND gst."DocumentType" = sad."DocumentType" AND gst."DocumentFinancialYear" = sad."DocumentFinancialYear" 
	WHERE 
		gst."ParentEntityId" = sad."ParentEntityId"
		AND gst."ReturnPeriod" = sad."ReturnPeriod";
			
	/*Getting Matched ids to compare data at detail level*/	
	CREATE TEMP TABLE "TempAutoDraftGstMatchedId" AS
	SELECT 
		e."AutoDraftId",
		"GstId",		
		"SupplyType"	
	FROM "TempAutoDraftGstHeaderMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Gstin" IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN "Pos" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "ReverseCharge" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;				
	
	/*Comparing data at detail level*/	
	CREATE TEMP TABLE "TempAutoDraftGstDetailComp" AS
	SELECT 		
		Ids."AutoDraftId",		
		Ids."GstId",
		SUM(CASE WHEN COALESCE(ED."ItemCount",0) <> COALESCE(sad."ItemCount",0) THEN 3
			ELSE
				CASE WHEN "_IsMatchByTolerance" = true THEN
						CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(sad."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
						       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(sad."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(sad."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CessAmount",0) - COALESCE(sad."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(sad."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
				 	    ELSE 0 END 		
				ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(sad."IgstAmount",0) THEN 1 
				       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(sad."CgstAmount",0) THEN 1
					   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(sad."SgstAmount",0) THEN 1
					   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(sad."CessAmount",0) THEN 1
					   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(sad."TaxableValue",0) THEN 1
					   ELSE 0 END END
	   END) AS "DetailComparison",
	   ids."SupplyType"	
	FROM "TempAutoDraftGstMatchedId" Ids
	INNER JOIN "TempAutoDraftDetailData" sad ON Ids."AutoDraftId" = sad."AutoDraftId"
	LEFT JOIN "TempRegularReturnDetailData" ED ON Ids."GstId"= ED."GstId" AND ED."Rate" = sad."Rate" 
	GROUP BY Ids."AutoDraftId",Ids."GstId",ids."SupplyType"; 

	/*Finding sectiontype",Reason Type */		
	CREATE TEMP TABLE "TempAutoDraftGstReco" AS
	SELECT 
		Ids."AutoDraftId",
		ED."GstId",	
		"_SupplyTypeSale" "SupplyType",	
		CASE WHEN ED."AutoDraftId" IS NOT NULL
				THEN CASE WHEN "TransactionType" IS NULL AND "Gstin" IS NULL AND "Pos" IS NULL AND "DocumentValue" IS NULL AND "ReverseCharge" IS NULL AND "DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND "ItemCount" IS NULL
				AND "IgstAmount" IS NULL AND "SgstAmount" IS NULL AND "CgstAmount" IS NULL AND "CessAmount" IS NULL AND "TaxableValue" IS NULL
							THEN "_ReconciliationSectionTypeGstMatched"
							ELSE "_ReconciliationSectionTypeGstMismatched"
					 END	
			 ELSE "_ReconciliationSectionTypeGstNotAvailable" END "GstSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +
		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +
		CASE WHEN ED."Pos" IS NOT NULL Then "_ReconciliationReasonTypePOS" else 0 END +
		CASE WHEN ED."ReverseCharge" IS NOT NULL Then "_ReconciliationReasonTypeReverseCharge" else 0 END +
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "GstReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."Pos" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypePOS" , ',"Value":"', "Pos" ,'"},') ELSE '' END ||
				CASE WHEN ED."ReverseCharge" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeReverseCharge" , ',"Value":""},') ELSE '' END ||
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', "DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', "DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', "ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',"IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',"CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',"SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',"TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',"CessAmount",'"},') ELSE '' END
				) "GstReason" ,				
		"_MappingTypeMonthly" "MappingType"						
	FROM "TempAutoDraftUnreconciledIds2" Ids
	LEFT JOIN "TempAutoDraftGstHeaderMatching" ED ON Ids."AutoDraftId" = ED."AutoDraftId" 
	LEFT JOIN "TempAutoDraftGstDetailComp" EDI ON Ed."AutoDraftId" = EDI."AutoDraftId" AND ED."GstId" = EDI."GstId";
		
	/*Deleting data from RecoMapperTable*/			 	
	DELETE 		
	FROM
		 report."GstAutoDraftRecoMapper" rm 
	USING
		"TempAutoDraftUnreconciledIds2" Ids 
	WHERE Ids."AutoDraftId" = rm."AutoDraftId" ;

	/*Inserting data of MonthlyComparison into Mapping Table*/
	INSERT INTO report."GstAutoDraftRecoMapper"
	(		
		 "AutoDraftId"
		,"GstId"
		,"GstType"
		,"GstSection"
		,"GstReasonsType"
		,"GstReason"
		,"MappingType"
		,"Stamp"
		,"ModifiedStamp"
	)
	SELECT 		
		AD."AutoDraftId",
		AD."GstId",
		AD."SupplyType",
		AD."GstSection",
		CASE WHEN AD."GstReasonsType" = 0 THEN NULL ELSE AD."GstReasonsType" END,
		CASE WHEN AD."GstReason" = '' THEN NULL ELSE CONCAT('[',LEFT(AD."GstReason",LENGTH(AD."GstReason")-1) ,']') END,
		AD."MappingType",
		NOW()::timestamp without time zone,
		NULL
	From
		"TempAutoDraftGstReco" AD;
		
	 DROP TABLE IF EXISTS "TempAutoDraftGstHeaderMatching","TempAutoDraftGstReco","TempAutoDraftGstDetailComp","TempAutoDraftGstMatchedId";
					
	--*************************Monthly Comparison ENDS**************************************
	
	--*************************YEARLY Comparison Starts***************************************

	
	/*Header data comparison of Gst data with AutoDraft data*/
	CREATE TEMP TABLE "TempYearlyAutoDraftGstHeaderMatching" AS
	SELECT
		sad."Id" "AutoDraftId",		
		gst."Id" "GstId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = false OR gst."TransactionType" = sad."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR sad."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		CASE WHEN  ("_IsExcludeMatchingCriteriaGstin" = false OR gst."Gstin" = sad."Gstin") THEN NULL ELSE sad."Gstin" END "Gstin",
		CASE WHEN (gst."Pos" = 96 AND gst."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (sad."Pos" = 96 AND sad."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (gst."Pos" = sad."Pos") THEN NULL ELSE gst."Pos" END "Pos",
		CASE WHEN  gst."DocumentDate" = sad."DocumentDate" THEN NULL ELSE ABS(extract ( day from gst."DocumentDate"::timestamp - sad."DocumentDate"::timestamp)) END "DocumentDate",
		CASE WHEN  gst."ReverseCharge" = sad."ReverseCharge" THEN NULL ELSE  CASE WHEN gst."ReverseCharge" = true THEN 'Y' ELSE 'N' END END "ReverseCharge",
		CASE WHEN  gst."DocumentValue" = sad."DocumentValue" THEN NULL 
			  WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN sad."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND sad."DocumentValue"+"_MatchByToleranceDocumentValueTo" THEN NULL		 
			 ELSE ABS(gst."DocumentValue" - sad."DocumentValue") END "DocumentValue",
		CASE WHEN  gst."ItemCount" = sad."ItemCount" THEN NULL ELSE ABS(gst."ItemCount" - sad."ItemCount") END "ItemCount",		
		CASE WHEN  gst."IgstAmount" = sad."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN sad."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."IgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."IgstAmount" - sad."IgstAmount") END "IgstAmount",																									 
		CASE WHEN  gst."SgstAmount" = sad."SgstAmount" THEN NULL 																											 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN sad."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."SgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."SgstAmount" - sad."SgstAmount") END "SgstAmount",																									 
		CASE WHEN  gst."CgstAmount" = sad."CgstAmount" THEN NULL 																											 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN sad."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CgstAmount" - sad."CgstAmount") END "CgstAmount",																									 
		CASE WHEN  gst."CessAmount" = sad."CessAmount" THEN NULL 																											 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN sad."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CessAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CessAmount" - sad."CessAmount") END "CessAmount",		
		CASE WHEN  gst."TaxableValue" = sad."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN sad."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND sad."TaxableValue"+"_MatchByToleranceTaxableValueTo" THEN NULL		 
			 ELSE ABS(gst."TaxableValue" - sad."TaxableValue") END "TaxableValue",		
		CASE WHEN  gst."StateCessAmount" = sad."StateCessAmount" THEN NULL ELSE ABS(gst."StateCessAmount" - sad."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType"	
	FROM 
		"TempAutoDraftData" sad		
	INNER JOIN "TempRegularReturnData" gst ON gst."DocumentNumber" = sad."DocumentNumber" AND gst."DocumentType" = sad."DocumentType" and gst."DocumentFinancialYear" = sad."DocumentFinancialYear" 
	WHERE gst."ParentEntityId" = sad."ParentEntityId"				
	AND sad."FinancialYear" = gst."FinancialYear";
	
	/*Getting matched ids to compare data at detail level*/
	CREATE TEMP TABLE "TempYearlyAutoDraftGstMatchedId" AS
	SELECT 
		"GstId",
		e."AutoDraftId",
		"SupplyType"	
	FROM "TempYearlyAutoDraftGstHeaderMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Gstin" IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN "Pos" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "ReverseCharge" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;	
	
	/*comparing data at detail level*/
	CREATE TEMP TABLE "TempYearlyAutoDraftGstdetailComp" AS
	SELECT 
		Ids."AutoDraftId",		
		Ids."GstId",		
		SUM(CASE WHEN COALESCE(ED."ItemCount",0) <> COALESCE(sad."ItemCount",0) THEN 3
			ELSE
				CASE WHEN "_IsMatchByTolerance" = true THEN
					CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(sad."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
				       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(sad."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
					   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(sad."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
					   WHEN COALESCE(ED."CessAmount",0) - COALESCE(sad."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
					   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(sad."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
				    ELSE 0 END 		
				 ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(sad."IgstAmount",0) THEN 1 
					       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(sad."CgstAmount",0) THEN 1
						   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(sad."SgstAmount",0) THEN 1
						   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(sad."CessAmount",0) THEN 1
						   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(sad."TaxableValue",0) THEN 1
						   ELSE 0 END  END
	   END) AS "DetailComparison",
	   ids."SupplyType"	
	FROM "TempYearlyAutoDraftGstMatchedId" Ids
	INNER JOIN "TempAutoDraftDetailData" sad ON Ids."AutoDraftId" = sad."AutoDraftId" 
	LEFT JOIN "TempRegularReturnDetailData" ED ON IDS."GstId" = ED."GstId" AND ED."Rate" = sad."Rate"
	GROUP BY Ids."AutoDraftId",Ids."GstId",ids."SupplyType";
	raise notice 'Test';
	/*Finding final Section and reason of reconciled data*/		
	CREATE TEMP TABLE "TempYearlyAutoDraftGstReco" AS
	SELECT 
		Ids."AutoDraftId",
		ED."GstId",	
		"_SupplyTypeSale" AS "SupplyType",	
		CASE WHEN ED."AutoDraftId" IS NOT NULL
			 THEN CASE WHEN "TransactionType" IS NULL  AND "Pos" IS NULL AND "Gstin" IS NULL AND "DocumentValue" IS NULL AND "ReverseCharge" IS NULL AND "DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND "ItemCount" IS NULL
							AND "IgstAmount" IS NULL AND "SgstAmount" IS NULL AND "CgstAmount" IS NULL AND "CessAmount" IS NULL  AND "TaxableValue" IS NULL
					   THEN "_ReconciliationSectionTypeGstMatched"
					   ELSE "_ReconciliationSectionTypeGstMismatched"
				   END	
			 ELSE "_ReconciliationSectionTypeGstNotAvailable" 
		END "GstSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +
		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +
		CASE WHEN ED."Pos" IS NOT NULL Then "_ReconciliationReasonTypePOS" else 0 END +
		CASE WHEN ED."ReverseCharge" IS NOT NULL Then "_ReconciliationReasonTypeReverseCharge" else 0 END +
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "GstReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."Pos" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypePOS" , ',"Value":"', "Pos" ,'"},') ELSE '' END ||
				CASE WHEN ED."ReverseCharge" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeReverseCharge" , ',"Value":""},') ELSE '' END ||
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', "DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', "DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', "ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',"IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',"CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',"SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',"TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',"CessAmount",'"},') ELSE '' END
				) "GstReason" ,						
		"_MappingTypeYearly" "MappingType"						
	FROM "TempAutoDraftUnreconciledIds2" Ids
	LEFT JOIN "TempYearlyAutoDraftGstHeaderMatching" ED ON Ids."AutoDraftId" = ED."AutoDraftId" 
	LEFT JOIN "TempYearlyAutoDraftGstdetailComp" EDI ON Ed."AutoDraftId" = EDI."AutoDraftId" AND ED."GstId" = EDI."GstId";

	/*Inserting data of MonthlyComparison into Mapping Table*/
	INSERT INTO report."GstAutoDraftRecoMapper"
	(		
		 "AutoDraftId"
		,"GstId"
		,"GstType"
		,"GstSection"
		,"GstReasonsType"
		,"GstReason"
		,"MappingType"
		,"Stamp"
		,"ModifiedStamp"
	)
	SELECT 		
		 AD."AutoDraftId",
		 AD."GstId",
		 AD."SupplyType",
		 AD."GstSection",
		 CASE WHEN AD."GstReasonsType" = 0 THEN NULL ELSE AD."GstReasonsType" END,
		 CASE WHEN AD."GstReason" = '' THEN NULL ELSE CONCAT('[',LEFT(AD."GstReason",LENGTH(AD."GstReason")-1) ,']') END,
		 AD."MappingType",
		 NOW(),
		 NULL
	From
		"TempYearlyAutoDraftGstReco" AD;						

	RETURN QUERY
	SELECT * FROM "TempAutoDraftUnreconciledIds2";

	DROP TABLE IF EXISTS "TempYearlyAutoDraftGstReco","TempAutoDraftDetailData","TempAutoDraftData","TempGstUnreconciledIdsAuto"
				,"TempRegularReturnData","TempRegularReturnDetailData","TempYearlyAutoDraftGstdetailComp","TempYearlyAutoDraftGstHeaderMatching","TempYearlyAutoDraftGstMatchedId"
				,"TempAutoDraftUnreconciledIds2";

	END IF;

END;
$function$
;
DROP FUNCTION IF EXISTS report."InsertRegularReturns3WayReconciliation";

CREATE OR REPLACE FUNCTION report."InsertRegularReturns3WayReconciliation"("_SubscriberId" integer, "_ParentEntityId" integer, "_FinancialYear" integer, "_DocumentTypEInv" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeBOE" smallint, "_DocumentTypeCHL" smallint, "_DocumentTypeBIL" smallint, "_PurposeTypeEInv" smallint, "_PurposeTypeEWB" smallint, "_SupplyTypeSale" smallint, "_SupplyTypePurchase" smallint, "_SourceTypeTaxpayer" smallint, "_SourceTypeAutoDraft" smallint, "_TransactionTypeB2B" smallint, "_TransactionTypeB2C" smallint, "_TransactionTypeSEZWP" smallint, "_TransactionTypeSEZWOP" smallint, "_TransactionTypeEXPWP" smallint, "_TransactionTypeEXPWOP" smallint, "_TransactionTypeDE" smallint, "_TransactionTypeIMPG" smallint, "_TransactionTypeCBW" smallint, "_TransactionTypeOTH" smallint, "_TransactionTypeKD" smallint, "_TransactionTypeJW" smallint, "_TransactionTypeJWR" smallint, "_IsDocumentDateReturnPeriod" boolean, "_ReconciliationSectionTypeGstNotAvailable" smallint, "_ReconciliationSectionTypeGstMatched" smallint, "_ReconciliationSectionTypeGstMismatched" smallint, "_ReconciliationSectionTypeEwbNotAvailable" smallint, "_ReconciliationSectionTypeEwbMatched" smallint, "_ReconciliationSectionTypeEwbMismatched" smallint, "_ReconciliationSectionTypeEInvNotAvailable" smallint, "_ReconciliationSectionTypeEInvMatched" smallint, "_ReconciliationSectionTypeEInvMismatched" smallint, "_ReconciliationSectionTypeGstAutodraftedMatched" smallint, "_ReconciliationSectionTypeGstAutodraftedMismatched" smallint, "_ReconciliationSectionTypeGstAutodraftedNotAvailable" smallint, "_ReconciliationSectionTypeEwbNotApplicable" smallint, "_ContactTypeBillFromGstin" smallint, "_ReconciliationReasonTypeTaxAmount" bigint, "_ReconciliationReasonTypeItems" bigint, "_ReconciliationReasonTypeSgstAmount" bigint, "_ReconciliationReasonTypeCgstAmount" bigint, "_ReconciliationReasonTypeIgstAmount" bigint, "_ReconciliationReasonTypeCessAmount" bigint, "_ReconciliationReasonTypeTaxableValue" bigint, "_ReconciliationReasonTypeTransactionType" bigint, "_ReconciliationReasonTypePOS" bigint, "_ReconciliationReasonTypeReverseCharge" bigint, "_ReconciliationReasonTypeDocumentValue" bigint, "_ReconciliationReasonTypeDocumentDate" bigint, "_ReconciliationReasonTypeDocumentNumber" bigint, "_ReconciliationReasonTypeRate" bigint, "_ReconciliationReasonTypeGstin" bigint, "_SettingTypeExcludeOtherCharges" boolean, "_IsMatchByTolerance" boolean, "_MatchByToleranceDocumentValueFrom" numeric, "_MatchByToleranceDocumentValueTo" numeric, "_MatchByToleranceTaxableValueFrom" numeric, "_MatchByToleranceTaxableValueTo" numeric, "_MatchByToleranceTaxAmountsFrom" numeric, "_MatchByToleranceTaxAmountsTo" numeric, "_DocValueThresholdForRecoAgainstEwb" numeric, "_IsExcludeMatchingCriteriaTransactionType" boolean, "_IsExcludeMatchingCriteriaGstin" boolean)
 RETURNS TABLE("GstId" bigint, "SupplyType" smallint)
 LANGUAGE plpgsql
AS $function$
		
DECLARE
	"_PurposeTypeBoth" SMALLINT = "_PurposeTypeEInv" + "_PurposeTypeEWB";
	"_MappingTypeMonthly" SMALLINT = 1;
	"_MappingTypeYearly" SMALLINT = 2;

BEGIN
	
	DROP TABLE IF EXISTS "TempEInvoiceData","TempEInvoiceDetailData","TempEInvoiceUnreconciledIds","TempEwayBillData","TempEwaybillDetailData","TempEwaybillUnreconciledIds",
						 "TempGstUnreconciledIds","TempRegularReturnData","TempRegularReturnDetailData","TempYearlyGstEInvDetailComp",
						"TempYearlyGstEInvHeaderMatching","TempYearlyGstEInvMatchedId","TempYearlyGstEInvReco","TempYearlyGstEwbDetailComparison","TempYearlyGstEwbHeaderDataMatching",
						"TempYearlyGstEwbMatchedIds","TempYearlyGstEwbReco","TempAutoDraftData","TempAutoDraftDetailData","TempAutoDraftUnreconciledIds","TempYearlyGstAutoDraftDetailComp",
						"TempYearlyGstAutoDraftHeaderMatching","TempYearlyGstAutoDraftMatchedId","TempYearlyGstAutoDraftReco","TempGstEwbHeaderDataMatching";

	CREATE TEMP TABLE "TempEwaybillUnreconciledIds"
	(		
		"EwbId" BIGINT NOT NULL
	);

	CREATE  INDEX "IDX_TempEwaybillUnreconciledIds" ON "TempEwaybillUnreconciledIds"("EwbId");

	CREATE TEMP TABLE "TempEInvoiceUnreconciledIds"
	(		
		"EInvId" BIGINT NOT NULL
	);

	CREATE INDEX "IDX_TempEInvoiceUnreconciledIds" ON "TempEInvoiceUnreconciledIds"("EInvId");

	CREATE TEMP TABLE "TempGstUnreconciledIds"
	(		
		"GstId" BIGINT NOT NULL,
		"SupplyType" SMALLINT NOT NULL
	);
	
	CREATE INDEX "IDX_TempGstUnreconciledIds" ON "TempGstUnreconciledIds"("GstId");		

	CREATE TEMP TABLE "TempAutoDraftUnreconciledIds"
	(		
		"AutoDraftId" BIGINT NOT NULL
	);
	
	CREATE  INDEX "IDX_TempAutoDraftUnreconciledIds" ON "TempAutoDraftUnreconciledIds"("AutoDraftId");		
	RAISE NOTICE 'Step 1 %', clock_timestamp()::timestamp(3) without time zone;
	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO	"TempGstUnreconciledIds"
	SELECT 
		d."Id",1 "SupplyType" 
	FROM 
		Oregular."SaleDocumentDW" d	
		INNER JOIN oregular."SaleDocumentStatus"  ds  ON ds."SaleDocumentId" = d."Id"		
	WHERE 
			d."SubscriberId" = "_SubscriberId"
		AND d."FinancialYear" = "_FinancialYear"
		AND d."ParentEntityId" =  "_ParentEntityId"
		AND d."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND d."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")			
		AND d."Is3WayReconciled" = false	
		AND (ds."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		AND d."SourceType" = "_SourceTypeTaxpayer"
		--AND ds."Status = true 
	UNION 				
	
	SELECT 
		SD."Id",ED."SupplyType"
	FROM 
		oregular."SaleDocumentDW" SD		
		INNER JOIN oregular."SaleDocumentStatus"  ss  ON ss."SaleDocumentId" = sd."Id"
		INNER JOIN EInvoice."DocumentDW" ED ON SD."DocumentNumber" = ED."DocumentNumber" AND SD."DocumentFinancialYear" = ED."DocumentFinancialYear" and SD."DocumentType" =ED."Type" 	
		INNER JOIN EInvoice."DocumentStatus" ds ON ed."Id" = ds."DocumentId"
	WHERE	
		SD."SubscriberId" = "_SubscriberId"		
		AND ED."SubscriberId" = "_SubscriberId"
		AND ED."FinancialYear" = "_FinancialYear"
		AND SD."ParentEntityId" =  "_ParentEntityId"
		AND ED."ParentEntityId" =  "_ParentEntityId"
		AND ED."Is3WayReconciled" = false
		AND ed."SupplyType" IN("_SupplyTypeSale")
		AND SD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND Sd."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")		
		AND ed."Purpose" IN( "_PurposeTypeEInv","_PurposeTypeBoth")
		AND (ss."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		AND (ds."PushStatus" IN (SELECT e."Item" FROM "EInvoicePushStatuses" e))
		--AND SS."Status	 = true
		--AND DS."Status	 = true
		AND SD."SourceType" = "_SourceTypeTaxpayer"
		
	UNION 				
	
	SELECT 
		SD."Id",ED."SupplyType"
	FROM 
		oregular."SaleDocumentDW" SD	
		INNER JOIN oregular."SaleDocumentStatus"  ss  ON ss."SaleDocumentId" = sd."Id"
		INNER JOIN EInvoice."DocumentDW" ED ON SD."DocumentNumber" = ED."DocumentNumber" AND SD."DocumentFinancialYear" = ED."DocumentFinancialYear" and SD."DocumentType" =ED."Type" 		
		INNER JOIN ewaybill."DocumentStatus" DS ON ED."Id" = DS."DocumentId"
	WHERE 
		SD."SubscriberId" = "_SubscriberId"
		AND ED."SubscriberId" = "_SubscriberId"
		AND ED."FinancialYear" = "_FinancialYear"
		AND SD."ParentEntityId" =  "_ParentEntityId"
		AND ED."ParentEntityId" =  "_ParentEntityId"
		AND ED."Is3WayReconciled" = false
		AND ed."SupplyType" IN("_SupplyTypeSale")
		AND SD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND Sd."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")				
		AND ED."Purpose" IN ("_PurposeTypeEWB","_PurposeTypeBoth") 
		AND (ss."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		AND (DS."PushStatus" IN (SELECT e."Item" FROM "EwaybillPushStatuses" e))
		--AND SS."Status	 = true
		--AND DS."Status	 = true
		AND SD."SourceType" = "_SourceTypeTaxpayer"
	UNION 					
	SELECT 
		SD."Id","_SupplyTypeSale"
	FROM 
		oregular."SaleDocumentDW" SD	
		INNER JOIN oregular."SaleDocumentStatus"  ss  ON ss."SaleDocumentId" = sd."Id"
		INNER JOIN oregular."SaleDocumentDW" SAD ON SD."DocumentNumber" = SAD."DocumentNumber" AND SD."DocumentFinancialYear" = SAD."DocumentFinancialYear" and SD."DocumentType" =SAD."DocumentType" 				
		INNER JOIN oregular."SaleDocumentStatus" ssa  ON ssa."SaleDocumentId" = sad."Id"
	WHERE 
		SD."SubscriberId" = "_SubscriberId"		
		AND SAD."SubscriberId" = "_SubscriberId"
		AND SAD."FinancialYear" = "_FinancialYear"
		AND SD."ParentEntityId" =  "_ParentEntityId"
		AND SAD."ParentEntityId" =  "_ParentEntityId"
		AND SAD."Is3WayReconciled" = false		
		AND SD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND Sd."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")						
		AND (ss."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		AND (ssa."PushStatus" IN (SELECT e."Item" FROM "AutoDraftPushStatuses" e))
		--AND SS."Status	 = true
		--AND ssa."Status = true
		AND SD."SourceType" = "_SourceTypeTaxpayer"
		AND SAD."SourceType" = "_SourceTypeAutoDraft";
	
	RAISE NOTICE 'Step 2 %', clock_timestamp()::timestamp(3) without time zone;

	/*To Get Ids of Purchase For Reconciliation  */
	INSERT INTO	"TempGstUnreconciledIds"
	SELECT
		d."Id",2 "SupplyType" 
	FROM 
		Oregular."PurchaseDocumentDW" d	
		INNER JOIN oregular."PurchaseDocumentStatus" ss  ON ss."PurchaseDocumentId" = d."Id"
	WHERE 
		d."SubscriberId" = "_SubscriberId"
		AND d."FinancialYear" = "_FinancialYear"
		AND d."ParentEntityId" =  "_ParentEntityId"
		AND d."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND d."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")		
		AND d."Is3WayReconciled" = false		
		AND d."SourceType" = "_SourceTypeTaxpayer"
		AND (ss."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		--AND SS."Status = true
	
	UNION 				
				
	SELECT 
		SD."Id",ED."SupplyType"
	FROM 
		oregular."PurchaseDocumentDW" SD		
		INNER JOIN oregular."PurchaseDocumentStatus" ss  ON ss."PurchaseDocumentId" = sd."Id"
		INNER JOIN EInvoice."DocumentDW" ED ON SD."DocumentNumber" = ED."DocumentNumber" AND SD."DocumentFinancialYear" = ED."DocumentFinancialYear" and SD."DocumentType" =ED."Type" AND COALESCE(SD."BillFromGstin",'URP') = COALESCE(ED."BillFromGstin",'URP')				
		INNER JOIN ewaybill."DocumentStatus" DS ON ED."Id" = DS."DocumentId"
	WHERE 
		SD."SubscriberId" = "_SubscriberId"		
		AND ED."SubscriberId" = "_SubscriberId"
		AND ED."FinancialYear" = "_FinancialYear"
		AND SD."ParentEntityId" =  "_ParentEntityId"
		AND ED."ParentEntityId" =  "_ParentEntityId"	
		AND SD."SourceType" = "_SourceTypeTaxpayer"
		AND ED."Is3WayReconciled" = false
		AND ed."SupplyType" IN("_SupplyTypePurchase")
		AND SD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW","_TransactionTypeOTH") 
		AND Sd."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")			
		AND ED."Purpose" IN ("_PurposeTypeEWB","_PurposeTypeBoth") 
		AND (SS."PushStatus" IN (SELECT e."Item" FROM "GstPushStatuses" e))
		AND (DS."PushStatus" IN (SELECT e."Item" FROM "EwaybillPushStatuses" e));	
		--AND SS."Status	 = true
		--AND DS."Status	 = true				
	RAISE NOTICE 'Step 3 %', clock_timestamp()::timestamp(3) without time zone;
	IF EXISTS (SELECT  1 FROM "TempGstUnreconciledIds")
	THEN
	/*To Get Ids of EInvoice For Reconciliation  */
	INSERT INTO "TempEInvoiceUnreconciledIds"
	SELECT 
		ED."Id"
	FROM 
		"TempGstUnreconciledIds" tui
		INNER JOIN oregular."SaleDocumentDW" sd on tui."GstId" = sd."Id"  and tui."SupplyType" = "_SupplyTypeSale"
		INNER JOIN EInvoice."DocumentDW" ED ON SD."DocumentNumber" = ED."DocumentNumber" AND SD."DocumentFinancialYear" = ED."DocumentFinancialYear" and SD."DocumentType" =ED."Type" 	
		INNER JOIN EInvoice."DocumentStatus" DS ON ED."Id" = DS."DocumentId"
	WHERE 
		ED."SubscriberId" = "_SubscriberId"		
		AND ED."ParentEntityId" =  "_ParentEntityId"
		AND ED."Purpose" IN ("_PurposeTypeBoth","_PurposeTypeEInv")				
		AND ED."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE") 
		AND ED."Type" IN ("_DocumentTypEInv","_DocumentTypeDBN","_DocumentTypeCRN")
		AND (ds."PushStatus" IN (SELECT e."Item" FROM "EInvoicePushStatuses" e));
		--AND ds."Status = true
	RAISE NOTICE 'Step 4 %', clock_timestamp()::timestamp(3) without time zone;
	DELETE 
	FROM "TempEInvoiceUnreconciledIds" a 
	USING "TempEInvoiceUnreconciledIds" b 
	WHERE
		a."EInvId"=b."EInvId" 
		AND a.ctid < b.ctid;

	RAISE NOTICE 'Step 5 %', clock_timestamp()::timestamp(3) without time zone;
	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO "TempEwaybillUnreconciledIds"
	SELECT 
		EWB."Id"
	FROM 
		"TempGstUnreconciledIds" tui
		INNER JOIN oregular."SaleDocumentDW" sd on tui."GstId" = sd."Id"  
		INNER JOIN EInvoice."DocumentDW" EWB 
			ON EWB."ParentEntityId" =  "_ParentEntityId"
			AND EWB."SupplyType" = "_SupplyTypeSale"
			AND EWB."DocumentFinancialYear" = SD."DocumentFinancialYear"
			AND SD."DocumentType" =EWB."Type"
			AND LOWER(SD."DocumentNumber") = LOWER(EWB."DocumentNumber")
		INNER JOIN ewaybill."DocumentStatus" DS ON EWB."Id" = DS."DocumentId"
	WHERE 
		EWB."SubscriberId" = "_SubscriberId"		
		AND EWB."Purpose" IN ("_PurposeTypeEWB","_PurposeTypeBoth") 		
		AND EWB."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeKD","_TransactionTypeJW","_TransactionTypeJWR","_TransactionTypeOTH") 
		AND EWB."Type" IN ("_DocumentTypEInv","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")		
		AND (DS."PushStatus" IN (SELECT e."Item" FROM "EwaybillPushStatuses" e))	
		AND tui."SupplyType" = "_SupplyTypeSale";
		
	RAISE NOTICE 'Step 6 %', clock_timestamp()::timestamp(3) without time zone;
	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO "TempEwaybillUnreconciledIds"
	SELECT 
		EWB."Id"
	FROM 
		"TempGstUnreconciledIds" tui
		INNER JOIN oregular."PurchaseDocumentDW" sd on tui."GstId" = sd."Id"  
		INNER JOIN EInvoice."DocumentDW" EWB 
			ON SD."DocumentNumber" = EWB."DocumentNumber" 
			AND SD."DocumentFinancialYear" = EWB."DocumentFinancialYear" 
			AND SD."DocumentType" =EWB."Type" 
			AND COALESCE(SD."BillFromGstin",'URP') = COALESCE(EWB."BillFromGstin",'URP')				
		INNER JOIN ewaybill."DocumentStatus" DS ON EWB."Id" = DS."DocumentId"
	WHERE 
		EWB."SubscriberId" = "_SubscriberId"
		AND EWB."ParentEntityId" =  "_ParentEntityId"
		AND EWB."Purpose" IN ("_PurposeTypeEWB","_PurposeTypeBoth") 		
		AND EWB."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeKD","_TransactionTypeJW","_TransactionTypeJWR","_TransactionTypeOTH") 
		AND EWB."Type" IN ("_DocumentTypEInv","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")		
		AND (DS."PushStatus" IN (SELECT e."Item" FROM "EwaybillPushStatuses" e))	
		AND tui."SupplyType" = "_SupplyTypePurchase"
		AND EWB."SupplyType" = "_SupplyTypePurchase"		;

	RAISE NOTICE 'Step 7 %', clock_timestamp()::timestamp(3) without time zone;
	/* Get data for Reconcilation in Temp Table */
	DELETE 
	FROM "TempEwaybillUnreconciledIds" a 
	USING "TempEwaybillUnreconciledIds" b 
	WHERE
		a."EwbId"=b."EwbId" 
		AND a.ctid < b.ctid;

	/*Delete Duplicate Ewaybill entries*/
	DELETE
	FROM  
		"TempEwaybillUnreconciledIds" tdu
	WHERE EXISTS (SELECT "Id" FROM "TempEwaybillDuplicateEntries" tede WHERE tede."Id" = tdu."EwbId");
	
	DELETE  
	FROM  
		"TempEInvoiceUnreconciledIds" tdu
	WHERE EXISTS (SELECT "Id" FROM "TempEinvoiceDuplicateEntries" tede WHERE tede."Id" = tdu."EInvId");
	RAISE NOTICE 'Step 8 %', clock_timestamp()::timestamp(3) without time zone;
	/*To Get Ids of GstAutoDraft For Reconciliation  */
	INSERT INTO "TempAutoDraftUnreconciledIds"
	SELECT 
		SAD."Id"
	FROM 
		"TempGstUnreconciledIds" tui
		INNER JOIN oregular."SaleDocumentDW" sd on tui."GstId" = sd."Id"  
		INNER JOIN oregular."SaleDocumentDW" SAD ON SD."DocumentNumber" = SAD."DocumentNumber" AND SD."DocumentFinancialYear" = SAD."DocumentFinancialYear" and SD."DocumentType" =SAD."DocumentType" 				
		INNER JOIN oregular."SaleDocumentStatus" SS ON ss."SaleDocumentId" = SAD."Id"
	WHERE 
		SAD."SubscriberId" = "_SubscriberId"
		AND SAD."ParentEntityId" =  "_ParentEntityId"		
		AND SAD."TransactionType" IN("_TransactionTypeB2B","_TransactionTypeB2C","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeEXPWP","_TransactionTypeEXPWOP","_TransactionTypeDE","_TransactionTypeIMPG","_TransactionTypeCBW") 
		AND SAD."DocumentType" IN ("_DocumentTypEInv","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE","_DocumentTypeCHL","_DocumentTypeBIL")			
		AND SAD."SourceType" = "_SourceTypeAutoDraft"
		AND tui."SupplyType" = "_SupplyTypeSale"
		AND (SS."PushStatus" IN (SELECT e."Item" FROM "AutoDraftPushStatuses" e));
	RAISE NOTICE 'Step 9 %', clock_timestamp()::timestamp(3) without time zone;
		/* Get data for Reconcilation in Temp Table */
	DELETE 
	FROM "TempAutoDraftUnreconciledIds" a 
	USING "TempAutoDraftUnreconciledIds" b 
	WHERE
		a."AutoDraftId"=b."AutoDraftId" 
		AND a.ctid < b.ctid;
	RAISE NOTICE 'Step 10 %', clock_timestamp()::timestamp(3) without time zone;
	
	CREATE TEMP TABLE  "TempOregularDocumentItems" AS
	SELECT
		"_SupplyTypeSale" "SupplyType",
		SDI."Id" AS "DocumentItemId"
	FROM 
		oregular."SaleDocumentItems" SDI
	WHERE EXISTS(SELECT 1 FROM "TempGstUnreconciledIds" TED WHERE SDI."SaleDocumentId" = TED."GstId" AND TED."SupplyType" = "_SupplyTypeSale");
	
	RAISE NOTICE 'Step 11 %', clock_timestamp()::timestamp(3) without time zone;
	INSERT INTO "TempOregularDocumentItems"
	SELECT
		"_SupplyTypePurchase" "SupplyType",
		SDI."Id" AS "DocumentItemId"
	FROM 
		oregular."PurchaseDocumentItems" SDI
	WHERE EXISTS(SELECT 1 FROM "TempGstUnreconciledIds" TED WHERE SDI."PurchaseDocumentId" = TED."GstId" AND TED."SupplyType" = "_SupplyTypePurchase");

	RAISE NOTICE 'Step 12 %', clock_timestamp()::timestamp(3) without time zone;
	/* Get data for Reconcilation in Temp Table */	
	CREATE TEMP TABLE "TempRegularReturnDetailData" AS
	SELECT 
		SDI."SaleDocumentId" "GstId",		
		SDI."Rate",
		COALESCE(SUM(SDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(SDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(SDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(SDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(SDI."CessAmount"),0)+COALESCE(SUM(SDI."StateCessAmount"),0)+COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0)+COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0) AS "CessAmount",
		COALESCE(SUM(SDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0) "CessNonAdvaloremAmount",
		COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0) "StateCessNonAdvaloremAmount",
		COUNT(DISTINCT "Rate") "ItemCount",
		"_SupplyTypeSale" "SupplyType"			
	FROM 
		oregular."SaleDocumentItems" SDI
	INNER JOIN "TempOregularDocumentItems" TED ON SDI."Id" = TED."DocumentItemId" AND TED."SupplyType" = "_SupplyTypeSale"
	GROUP BY "SaleDocumentId",SDI."Rate"
		
	UNION ALL

	SELECT 
		SDI."PurchaseDocumentId",		
		SDI."Rate",
		COALESCE(SUM(SDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(SDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(SDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(SDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(SDI."CessAmount"),0) "CessAmount",
		COALESCE(SUM(SDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0) "CessNonAdvaloremAmount",
		COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0) "StateCessNonAdvaloremAmount",
		COUNT(DISTINCT "Rate") "ItemCount",
		"_SupplyTypePurchase" "SupplyType"	
	FROM 
		oregular."PurchaseDocumentItems" SDI
	INNER JOIN "TempOregularDocumentItems" TED ON SDI."Id" = TED."DocumentItemId" AND TED."SupplyType" = "_SupplyTypePurchase"
	GROUP BY "PurchaseDocumentId",SDI."Rate";
	
	RAISE NOTICE 'Step 13 %', clock_timestamp()::timestamp(3) without time zone;
	DROP TABLE "TempOregularDocumentItems";
	
	DROP TABLE IF EXISTS "TempRegularReturnDetailDataAgg";
	CREATE TEMP TABLE "TempRegularReturnDetailDataAgg" AS
	SELECT 
		dd."GstId",
		dd."SupplyType",
		SUM(dd."TaxableValue") "TaxableValue",
						SUM(dd."IgstAmount") "IgstAmount",
						SUM(dd."CgstAmount") "CgstAmount",
						SUM(dd."SgstAmount") "SgstAmount",
						SUM(dd."CessAmount") "CessAmount",
						SUM(dd."StateCessAmount") "StateCessAmount",
						SUM(dd."CessNonAdvaloremAmount") "CessNonAdvaloremAmount",
						SUM(dd."StateCessNonAdvaloremAmount") "StateCessNonAdvaloremAmount",
						SUM("ItemCount") "ItemCount"
	FROM 
		"TempRegularReturnDetailData" dd 
	GROUP BY dd."GstId",dd."SupplyType";
	
	RAISE NOTICE 'Step 14 %', clock_timestamp()::timestamp(3) without time zone;
	
	CREATE TEMP TABLE "TempRegularReturnData" AS
	SELECT 
		SD."Id",
		SD."DocumentNumber",
		to_date(sd."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		SD."DocumentValue",
		SD."DocumentType",
		SD."TransactionType",
		SD."Pos",
		SD."ReverseCharge",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN sd."DocumentReturnPeriod" ELSE SD."ReturnPeriod" END "ReturnPeriod",        
		SD."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN SD."DocumentFinancialYear" ELSE SD."FinancialYear" END "FinancialYear",
		SD."ParentEntityId",
		SD."BillToGstin" AS "Gstin",
		"_SupplyTypeSale" "SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		sd."UnderIgstAct"
	FROM 
		oregular."SaleDocumentDW" SD
	INNER JOIN "TempGstUnreconciledIds" TED ON SD."Id" = TED."GstId" AND TED."SupplyType" = "_SupplyTypeSale"
	INNER JOIN "TempRegularReturnDetailDataAgg" dd ON SD."Id" = dd."GstId" AND dd."SupplyType" = "_SupplyTypeSale"

	UNION ALL

	SELECT 
		SD."Id",
		SD."DocumentNumber",
		to_date(sd."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		SD."DocumentValue",
		SD."DocumentType",
		SD."TransactionType",
		SD."Pos",
		SD."ReverseCharge",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN sd."DocumentReturnPeriod" ELSE SD."ReturnPeriod" END "ReturnPeriod",        
		SD."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN SD."DocumentFinancialYear" ELSE SD."FinancialYear" END "FinancialYear",
		SD."ParentEntityId",
		COALESCE("BillFromGstin",'URP') "Gstin",
		"_SupplyTypePurchase" "SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		sd."UnderIgstAct"
	FROM 
		oregular."PurchaseDocumentDW" SD
	INNER JOIN "TempGstUnreconciledIds" TED ON SD."Id" = TED."GstId" AND TED."SupplyType" = "_SupplyTypePurchase"
	INNER JOIN "TempRegularReturnDetailDataAgg" dd ON SD."Id" = dd."GstId" AND dd."SupplyType" = "_SupplyTypePurchase";		
	
	RAISE NOTICE 'Step 15 %', clock_timestamp()::timestamp(3) without time zone;
	
	DROP TABLE IF EXISTS "TempAutoDraftDocumentItems";
	CREATE TEMP TABLE "TempAutoDraftDocumentItems" AS
	SELECT
		SDI."Id" AS "DocumentItemId"
	FROM 
		oregular."SaleDocumentItems" SDI
	WHERE EXISTS(SELECT 1 FROM "TempAutoDraftUnreconciledIds" TED WHERE SDI."SaleDocumentId" = TED."AutoDraftId");

	/*Get data of Gst AUTO Drafted */
	CREATE TEMP TABLE "TempAutoDraftDetailData" AS
	SELECT 
		SDI."SaleDocumentId" "AutoDraftId",		
		SDI."Rate",
		COALESCE(SUM(SDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(SDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(SDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(SDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(SDI."CessAmount"),0) "CessAmount",
		COALESCE(SUM(SDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(SDI."CessNonAdvaloremAmount"),0) "CessNonAdvaloremAmount",
		COALESCE(SUM(SDI."StateCessNonAdvaloremAmount"),0) "StateCessNonAdvaloremAmount",
		COUNT(DISTINCT "Rate") "ItemCount",
		"_SupplyTypeSale" "SupplyType"	 
	FROM 
		oregular."SaleDocumentItems" SDI
	INNER JOIN "TempAutoDraftDocumentItems" TED ON SDI."Id" = TED."DocumentItemId"
	GROUP BY "SaleDocumentId",SDI."Rate";
	
	RAISE NOTICE 'Step 16 %', clock_timestamp()::timestamp(3) without time zone;
	DROP TABLE IF EXISTS "TempAutoDraftDetailDataAgg";
	CREATE TEMP TABLE "TempAutoDraftDetailDataAgg" AS
	SELECT 
		dd."AutoDraftId",
		SUM(dd."TaxableValue") "TaxableValue",
						SUM(dd."IgstAmount") "IgstAmount",
						SUM(dd."CgstAmount") "CgstAmount",
						SUM(dd."SgstAmount") "SgstAmount",
						SUM(dd."CessAmount") "CessAmount",
						SUM(dd."StateCessAmount") "StateCessAmount",
						SUM(dd."CessNonAdvaloremAmount") "CessNonAdvaloremAmount",
						SUM(dd."StateCessNonAdvaloremAmount") "StateCessNonAdvaloremAmount",
						SUM("ItemCount") "ItemCount"
	FROM "TempAutoDraftDetailData" dd 
	GROUP BY dd."AutoDraftId";

	CREATE TEMP TABLE "TempAutoDraftData" AS
	SELECT 
		SD."Id",
		SD."DocumentNumber",
		to_date(sd."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		SD."DocumentValue",
		SD."DocumentType",
		SD."TransactionType",
		SD."Pos",
		SD."ReverseCharge",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN sd."DocumentReturnPeriod" ELSE SD."ReturnPeriod" END "ReturnPeriod",        
		SD."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN SD."DocumentFinancialYear" ELSE SD."FinancialYear" END "FinancialYear",
		SD."ParentEntityId",
		SD."BillToGstin" AS "Gstin",
		"_SupplyTypeSale" "SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		SD."UnderIgstAct"
	FROM 
		oregular."SaleDocumentDW" SD
	INNER JOIN "TempAutoDraftUnreconciledIds" TED ON SD."Id" = TED."AutoDraftId" 
	INNER JOIN "TempAutoDraftDetailDataAgg" dd ON SD."Id" = dd."AutoDraftId" ;		
	RAISE NOTICE 'Step 17 %', clock_timestamp()::timestamp(3) without time zone;
	/*Get dAta of EInvoice for Reconciliation */

	DROP TABLE IF EXISTS "TempEwaybillDocumentItems";
	CREATE TEMP TABLE "TempEwaybillDocumentItems" AS
	SELECT
		SDI."Id" AS "DocumentItemId"
	FROM 
		einvoice."DocumentItems" SDI
	WHERE EXISTS(SELECT 1 FROM "TempEwaybillUnreconciledIds" TED WHERE SDI."DocumentId" = TED."EwbId");

	CREATE TEMP TABLE "TempEwaybillDetailData" AS
	SELECT 
		EDI."DocumentId",		
		EDI."Rate",
		COALESCE(SUM(EDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(EDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(EDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(EDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(EDI."CessAmount"),0) "CessAmount",		
		COALESCE(SUM(EDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(EDI."OtherCharges"),0) "OtherCharges",
		COALESCE(SUM(EDI."CessNonAdvaloremAmount"),0) AS "CessNonAdvaloremAmount",
		COALESCE(SUM(EDI."StateCessNonAdvaloremAmount"),0) AS "StateCessNonAdvaloremAmount",
		Count(DISTINCT "Rate") AS "ItemCount"
	FROM 
		EInvoice."DocumentItems" EDI
	INNER JOIN "TempEwaybillDocumentItems" TED ON EDI."Id" = TED."DocumentItemId"
	GROUP BY "DocumentId","Rate";
	
	RAISE NOTICE 'Step 18 %', clock_timestamp()::timestamp(3) without time zone;
	
	DROP TABLE IF EXISTS "TempEwaybillDetailDataAgg";
	CREATE TEMP TABLE "TempEwaybillDetailDataAgg" AS
	SELECT 
		dd."DocumentId",
		SUM(dd."TaxableValue") "TaxableValue",
						SUM(dd."IgstAmount") "IgstAmount",
						SUM(dd."CgstAmount") "CgstAmount",
						SUM(dd."SgstAmount") "SgstAmount",
						SUM(dd."CessAmount") "CessAmount",
						SUM(dd."OtherCharges") "OtherCharges",
						SUM(dd."StateCessAmount") "StateCessAmount",
						SUM(dd."CessNonAdvaloremAmount") "CessNonAdvaloremAmount",
						SUM(dd."StateCessNonAdvaloremAmount") "StateCessNonAdvaloremAmount",
						SUM("ItemCount") "ItemCount"
	  FROM  
	  	"TempEwaybillDetailData" dd
	  GROUP BY dd."DocumentId";
	
	RAISE NOTICE 'Step 19 %', clock_timestamp()::timestamp(3) without time zone;		
		
	CREATE TEMP TABLE "TempEwayBillData" AS
	SELECT 
		ED."Id",
		ED."DocumentNumber",
		to_date(ED."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		CASE WHEN "_SettingTypeExcludeOtherCharges" = true THEN COALESCE(ED."DocumentValue",0) - COALESCE(ds."DocumentOtherCharges",0) - COALESCE(dd."OtherCharges",0) ELSE ED."DocumentValue" END AS "DocumentValue",
		ED."Type",
		ED."TransactionType",
		ED."Pos",
		ED."ReverseCharge",
		CASE WHEN Ed."SupplyType" = "_SupplyTypeSale" THEN '' ELSE COALESCE(Ed."BillFromGstin",'URP') END "Gstin",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN ed."DocumentReturnPeriod" ELSE ED."ReturnPeriod" END "ReturnPeriod",        
		ED."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN Ed."DocumentFinancialYear" ELSE ED."FinancialYear" END "FinancialYear",
		ED."ParentEntityId",
		ED."SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		DS."UnderIgstAct" AS "UnderIgstAct"
	FROM 
		EInvoice."DocumentDW" ED
	INNER JOIN EInvoice."Documents" DS ON ED."Id" = DS."Id"
	INNER JOIN "TempEwaybillUnreconciledIds" TED ON ED."Id" = TED."EwbId"
	INNER JOIN "TempEwaybillDetailDataAgg" dd ON Ed."Id" = dd."DocumentId";		
	RAISE NOTICE 'Step 20 %', clock_timestamp()::timestamp(3) without time zone;
	/*Get dAta of EInvoice for Reconciliation */
	
	DROP TABLE IF EXISTS "TempEinvoiceDocumentItems";
	CREATE TEMP TABLE "TempEinvoiceDocumentItems" AS
	SELECT
		SDI."Id" AS "DocumentItemId"
	FROM 
		einvoice."DocumentItems" SDI
	WHERE EXISTS(SELECT 1 FROM "TempEInvoiceUnreconciledIds" TED WHERE SDI."DocumentId" = TED."EInvId");

	CREATE TEMP TABLE "TempEInvoiceDetailData" AS
	SELECT 
		EDI."DocumentId",		
		EDI."Rate",
		COALESCE(SUM(EDI."TaxableValue"),0) "TaxableValue",
		COALESCE(SUM(EDI."IgstAmount"),0) "IgstAmount",
		COALESCE(SUM(EDI."CgstAmount"),0) "CgstAmount",
		COALESCE(SUM(EDI."SgstAmount"),0) "SgstAmount",
		COALESCE(SUM(EDI."CessAmount"),0) "CessAmount",
		COALESCE(SUM(EDI."StateCessAmount"),0) "StateCessAmount",
		COALESCE(SUM(EDI."OtherCharges"),0) "OtherCharges",
		COALESCE(SUM(EDI."CessNonAdvaloremAmount"),0) "CessNonAdvaloremAmount",
		COALESCE(SUM(EDI."StateCessNonAdvaloremAmount"),0) "StateCessNonAdvaloremAmount",
		COUNT(DISTINCT "Rate") "ItemCount"			
	FROM 
		EInvoice."DocumentItems" EDI
	INNER JOIN "TempEinvoiceDocumentItems" TED ON EDI."Id" = TED."DocumentItemId"
	GROUP BY "DocumentId","Rate";
	RAISE NOTICE 'Step 21 %', clock_timestamp()::timestamp(3) without time zone;
	DROP TABLE IF EXISTS "TempEInvoiceDetailDataAgg";
	CREATE TEMP TABLE "TempEInvoiceDetailDataAgg" AS
	SELECT 
		dd."DocumentId", 
		SUM(dd."TaxableValue") "TaxableValue",
						SUM(dd."IgstAmount") "IgstAmount",
						SUM(dd."CgstAmount") "CgstAmount",
						SUM(dd."SgstAmount") "SgstAmount",
						SUM(dd."CessAmount") "CessAmount",
						SUM(dd."OtherCharges") "OtherCharges",
						SUM(dd."StateCessAmount") "StateCessAmount",
						SUM(dd."CessNonAdvaloremAmount") "CessNonAdvaloremAmount",
						SUM(dd."StateCessNonAdvaloremAmount") "StateCessNonAdvaloremAmount",
						SUM("ItemCount") "ItemCount"
	FROM  
		"TempEInvoiceDetailData" dd 
	GROUP BY dd."DocumentId";

	CREATE TEMP TABLE "TempEInvoiceData" AS
	SELECT 
		ED."Id",
		ED."DocumentNumber",
		to_date(ed."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		CASE WHEN "_SettingTypeExcludeOtherCharges" = true THEN COALESCE(ED."DocumentValue",0) - COALESCE(DS."DocumentOtherCharges",0) - COALESCE(dd."OtherCharges",0) ELSE ED."DocumentValue" END AS "DocumentValue",
		ED."Type",
		ED."TransactionType",
		ED."Pos",
		ED."ReverseCharge",
        CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN ed."DocumentReturnPeriod" ELSE ED."ReturnPeriod" END "ReturnPeriod",        
		ED."DocumentFinancialYear",
	    CASE WHEN "_IsDocumentDateReturnPeriod" = true THEN Ed."DocumentFinancialYear" ELSE ED."FinancialYear" END "FinancialYear",
		ED."ParentEntityId",
		COALESCE(ED."BillFromGstin",'URP') "Gstin",
		ED."SupplyType",
		dd."TaxableValue",
		dd."IgstAmount",
		dd."CgstAmount",
		dd."SgstAmount",
		dd."CessAmount",
		dd."StateCessAmount",
		dd."StateCessNonAdvaloremAmount",
		dd."CessNonAdvaloremAmount",
		"ItemCount",
		DS."UnderIgstAct"
	FROM 
		EInvoice."DocumentDW" ED
	INNER JOIN EInvoice."Documents" DS ON ED."Id" = DS."Id"
	INNER JOIN "TempEInvoiceUnreconciledIds" TED ON ED."Id" = TED."EInvId"	
	INNER JOIN "TempEInvoiceDetailDataAgg" dd ON Ed."Id" = dd."DocumentId";		
						
	--*************************Monthly Comparison Begin**************************************
	/*Header Level Matching of Gst data with Ewaybill  */
	CREATE TEMP TABLE "TempGstEwbHeaderDataMatching" AS
	SELECT
		gst."Id" "GstId",
		ewb."Id" "EwbId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = false OR ewb."TransactionType" = gst."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR ewb."UnderIgstAct" = TRUE)) THEN NULL ELSE ewb."TransactionType" END "TransactionType",		
		CASE WHEN  (("_IsExcludeMatchingCriteriaGstin" = false OR gst."Gstin" = ewb."Gstin") AND ewb."SupplyType"="_SupplyTypeSale") OR ewb."SupplyType"="_SupplyTypePurchase" THEN NULL ELSE ewb."Gstin" END "Gstin",
		CASE WHEN  EWB."DocumentDate" = gst."DocumentDate" THEN NULL ELSE ABS(EXTRACT (day from EWB."DocumentDate"::timestamp - gst."DocumentDate"::timestamp)) END "DocumentDate",		
		CASE WHEN  EWB."DocumentValue" = gst."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN ewb."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND ewb."DocumentValue"+"_MatchByToleranceDocumentValueTo"	THEN NULL		 
			 ELSE ABS(EWB."DocumentValue" - gst."DocumentValue") END "DocumentValue",
		CASE WHEN  EWb."ItemCount" = gst."ItemCount" THEN NULL ELSE ABS(EWB."ItemCount" - gst."ItemCount") END "ItemCount",		
		CASE WHEN  EWb."IgstAmount" = gst."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN ewb."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."IgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(EWB."IgstAmount" - gst."IgstAmount") END "IgstAmount",																									 
		CASE WHEN  EWb."SgstAmount" = gst."SgstAmount" THEN NULL 																											 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN ewb."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."SgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(EWB."SgstAmount" - gst."SgstAmount") END "SgstAmount",																									 
		CASE WHEN  EWb."CgstAmount" = gst."CgstAmount" THEN NULL 																											 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN ewb."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."CgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(EWB."CgstAmount" - gst."CgstAmount") END "CgstAmount",		
		CASE WHEN  EWb."TaxableValue" = gst."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN ewb."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND ewb."TaxableValue"+"_MatchByToleranceTaxableValueTo" THEN NULL		 
			 ELSE ABS(EWB."TaxableValue" - gst."TaxableValue") END "TaxableValue",		
		CASE WHEN  EWb."CessAmount" = gst."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN ewb."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."CessAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(EWB."CessAmount" - gst."CessAmount") END "CessAmount",		
		CASE WHEN  EWb."StateCessAmount" = gst."StateCessAmount" THEN NULL ELSE ABS(EWB."StateCessAmount" - gst."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType",
		CASE WHEN EWB."DocumentValue" < "_DocValueThresholdForRecoAgainstEwb" THEN true ELSE false END "IsEwbNotApplicable"			
	FROM 
		"TempRegularReturnData" gst	
	INNER JOIN "TempEwayBillData" ewb on EWB."DocumentNumber" = gst."DocumentNumber" AND EWB."Type" = gst."DocumentType" and EWB."DocumentFinancialYear" = gst."DocumentFinancialYear" AND (EWB."Gstin" = gst."Gstin" OR ewb."SupplyType"= "_SupplyTypeSale") AND ewb."SupplyType" = gst."SupplyType"
	WHERE
	    EWB."ParentEntityId" = gst."ParentEntityId"
		AND EWB."ReturnPeriod" = gst."ReturnPeriod";

	/*Getting Matched ids to compare data at detail level*/		
	CREATE TEMP TABLE "TempGstEwbMatchedIds" AS
	SELECT 
		e."GstId",
		"EwbId",
		e."SupplyType"	
	FROM "TempGstEwbHeaderDataMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN "Gstin" IS NOT NULL THEN 1 ELSE 0 END  +
			+ CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;
	
	/*Comparing data at detail level*/	
	CREATE TEMP TABLE "TempGstEwbDetailComparison" AS
	SELECT 
		Ids."GstId",
		"EwbId",
		SUM(CASE WHEN COALESCE(SD."ItemCount",0) <> COALESCE(ED."ItemCount",0) THEN 3
			  ELSE
			  CASE WHEN "_IsMatchByTolerance" = true THEN
			  CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(SD."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
					       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(SD."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
						   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(SD."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
						   WHEN COALESCE(ED."CessAmount",0) - COALESCE(SD."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
						   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(SD."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
			  	    ELSE 0 END 
			  ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(SD."IgstAmount",0) THEN 1 
						WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(SD."CgstAmount",0) THEN 1
			  			WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(SD."SgstAmount",0) THEN 1
			  			WHEN COALESCE(ED."CessAmount",0) <> COALESCE(SD."CessAmount",0) THEN 1
			  			WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(SD."TaxableValue",0) THEN 1
			  	   ELSE 0 END END
			 END) AS "DetailComparison",
			Ids."SupplyType"
	FROM 
		"TempGstEwbMatchedIds" Ids
	INNER JOIN "TempRegularReturnDetailData" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempEwaybillDetailData" SD ON  IDS."EwbId" = SD."DocumentId" AND ED."Rate" = SD."Rate" 
	GROUP BY "EwbId",Ids."GstId",Ids."SupplyType";
	
	/*Finding sectiontype",Reason Type */	
	CREATE TEMP TABLE "TempGstEwbReco" AS
	SELECT 
		Ids."GstId",
		Ed."EwbId",
		Ids."SupplyType",
		CASE WHEN ED."GstId" IS NOT NULL AND  ED."IsEwbNotApplicable" = false
				THEN CASE WHEN ED."TransactionType" IS NULL
				AND ED."DocumentValue" IS NULL AND ED."DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND ED."ItemCount" IS NULL
				AND ED."IgstAmount" IS NULL AND ED."SgstAmount" IS NULL AND ED."CgstAmount" IS NULL AND ED."CessAmount" IS NULL AND ED."TaxableValue" IS NULL
							THEN "_ReconciliationSectionTypeEwbMatched"	
							ELSE "_ReconciliationSectionTypeEwbMismatched"	
					 END	
		    ELSE CASE WHEN trd."DocumentType" IN ("_DocumentTypeCRN","_DocumentTypeDBN") OR "IsEwbNotApplicable" = True THEN "_ReconciliationSectionTypeEwbNotApplicable"  ELSE "_ReconciliationSectionTypeEwbNotAvailable" END
		END "EwbSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +				
-- 		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +				
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "EwbReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 			
-- 		 		CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin"  , ',"Value":""},') ELSE '' END || 								
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', ED."DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', ED."DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', ED."ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',ED."IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',ED."CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',ED."SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',ED."TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',ED."CessAmount",'"},') ELSE '' END
				) "EwbReason",	
		"_MappingTypeMonthly" "MappingType"					
	FROM 
		"TempGstUnreconciledIds" Ids
	INNER JOIN "TempRegularReturnData" trd On Ids."GstId" = trd."Id" and Ids."SupplyType" = trd."SupplyType"
	LEFT JOIN "TempGstEwbHeaderDataMatching" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempGstEwbDetailComparison" EDI ON IDS."GstId" = EDI."GstId"	AND Ids."SupplyType" = EDI."SupplyType"	AND ED."EwbId" = EDI."EwbId";		

	/*Header Level Matching of Gst data with GstAutoDraft  */
	CREATE TEMP TABLE "TempGstAutoDraftHeaderMatching" AS
	SELECT
		sad."Id" "AutoDraftId",
		gst."Id" "GstId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = false OR gst."TransactionType" = sad."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR sad."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		CASE WHEN  ("_IsExcludeMatchingCriteriaGstin" = false OR gst."Gstin" = sad."Gstin") THEN NULL ELSE gst."Gstin" END "Gstin",
		CASE WHEN  (gst."Pos" = 96 and gst."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (sad."Pos" = 96 and sad."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (gst."Pos" = sad."Pos") THEN NULL ELSE gst."Pos" END "Pos",
		CASE WHEN  gst."DocumentDate" = sad."DocumentDate" THEN NULL ELSE ABS(EXTRACT (day from gst."DocumentDate"::timestamp-sad."DocumentDate"::timestamp)) END "DocumentDate",
		CASE WHEN  gst."ReverseCharge" = sad."ReverseCharge" THEN NULL ELSE CASE WHEN gst."ReverseCharge" = true THEN 'Y' ELSE 'N' END END "ReverseCharge",
		CASE WHEN  gst."DocumentValue" = sad."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN sad."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND sad."DocumentValue"+"_MatchByToleranceDocumentValueTo" THEN NULL		 
			 ELSE ABS(gst."DocumentValue" - sad."DocumentValue") END "DocumentValue",
		CASE WHEN  gst."ItemCount" = sad."ItemCount" THEN NULL ELSE ABS(gst."ItemCount" - sad."ItemCount") END "ItemCount",		
		CASE WHEN  gst."IgstAmount" = sad."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN sad."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."IgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."IgstAmount" - sad."IgstAmount") END "IgstAmount",		
		CASE WHEN  gst."SgstAmount" = sad."SgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN sad."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."SgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."SgstAmount" - sad."SgstAmount") END "SgstAmount",		
		CASE WHEN  gst."CgstAmount" = sad."CgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN sad."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CgstAmount" - sad."CgstAmount") END "CgstAmount",		
		CASE WHEN  gst."CessAmount" = sad."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN sad."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CessAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CessAmount" - sad."CessAmount") END "CessAmount",		
		CASE WHEN  gst."TaxableValue" = sad."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN sad."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND sad."TaxableValue"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."TaxableValue" - sad."TaxableValue") END "TaxableValue",		
		CASE WHEN  gst."StateCessAmount" = sad."StateCessAmount" THEN NULL ELSE ABS(gst."StateCessAmount" - sad."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType"	
	FROM 
		"TempRegularReturnData" gst
	INNER JOIN "TempAutoDraftData" sad  ON gst."DocumentNumber" = sad."DocumentNumber" AND gst."DocumentType" = sad."DocumentType" AND gst."DocumentFinancialYear" = sad."DocumentFinancialYear" 
	WHERE gst."SupplyType" = "_SupplyTypeSale"
		AND gst."ParentEntityId" = sad."ParentEntityId"
		AND gst."ReturnPeriod" = sad."ReturnPeriod";
		
	
	/*Getting Matched ids to compare data at detail level*/	
	CREATE TEMP TABLE "TempGstAutoDraftMatchedId" AS
	SELECT 
		e."GstId",
		"AutoDraftId",
		e."SupplyType"
	FROM "TempGstAutoDraftHeaderMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Gstin" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Pos" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "ReverseCharge" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;				
	
	/*Comparing data at detail level*/	
	CREATE TEMP TABLE "TempGstAutoDraftDetailComp" AS
	SELECT 
		Ids."GstId",
		Ids."AutoDraftId",		
		SUM(CASE WHEN COALESCE(ED."ItemCount",0) <> COALESCE(sad."ItemCount",0) THEN 3
			 ELSE
				CASE WHEN "_IsMatchByTolerance" = true THEN
						CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(sad."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
						       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(sad."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(sad."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CessAmount",0) - COALESCE(sad."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(sad."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
				 	    ELSE 0 END 
				 ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(sad."IgstAmount",0) THEN 1 
				       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(sad."CgstAmount",0) THEN 1
					   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(sad."SgstAmount",0) THEN 1
					   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(sad."CessAmount",0) THEN 1
					   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(sad."TaxableValue",0) THEN 1
					   ELSE 0 END END
	   END) AS "DetailComparison",
	   ids."SupplyType"	
	FROM "TempGstAutoDraftMatchedId" Ids
	INNER JOIN "TempRegularReturnDetailData" ED ON Ids."GstId"= ED."GstId" AND ids."SupplyType" = Ed."SupplyType"
	LEFT JOIN "TempAutoDraftDetailData" sad ON IDS."AutoDraftId" = sad."AutoDraftId" AND ED."Rate" = sad."Rate" 
	GROUP BY Ids."AutoDraftId",Ids."GstId",ids."SupplyType" ;

	/*Finding sectiontype",Reason Type */		
	CREATE TEMP TABLE "TempGstAutoDraftReco" AS
	SELECT 
		Ids."GstId",
		ED."AutoDraftId",	
		Ids."SupplyType",	
		CASE WHEN ED."GstId" IS NOT NULL
				THEN CASE WHEN "TransactionType" IS NULL AND "Pos" IS NULL AND "Gstin" IS NULL AND "DocumentValue" IS NULL AND "ReverseCharge" IS NULL AND "DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND "ItemCount" IS NULL
				AND "IgstAmount" IS NULL AND "SgstAmount" IS NULL AND "CgstAmount" IS NULL AND "CessAmount" IS NULL AND "TaxableValue" IS NULL
							THEN "_ReconciliationSectionTypeGstAutodraftedMatched"
							ELSE "_ReconciliationSectionTypeGstAutodraftedMismatched"
					 END	
			 ELSE "_ReconciliationSectionTypeGstAutodraftedNotAvailable" END "AutoDraftSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +
 		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +
		CASE WHEN ED."Pos" IS NOT NULL Then "_ReconciliationReasonTypePOS" else 0 END +
		CASE WHEN ED."ReverseCharge" IS NOT NULL Then "_ReconciliationReasonTypeReverseCharge" else 0 END +
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "AutoDraftReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 
 				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."Pos" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypePOS" , ',"Value":"', "Pos" ,'"},') ELSE '' END ||
				CASE WHEN ED."ReverseCharge" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeReverseCharge" , ',"Value":""},') ELSE '' END ||
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', "DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', "DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', "ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',"IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',"CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',"SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',"TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',"CessAmount",'"},') ELSE '' END
				) "AutoDraftReason",				
		"_MappingTypeMonthly" "MappingType"						
	FROM "TempGstUnreconciledIds" Ids
	LEFT JOIN "TempGstAutoDraftHeaderMatching" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempGstAutoDraftDetailComp" EDI ON Ed."GstId" = EDI."GstId" AND Ids."SupplyType" = EDI."SupplyType" AND ED."AutoDraftId" = EDI."AutoDraftId";		

	/*Header Level Matching of Gst data with EInvoice  */
	CREATE TEMP TABLE "TempGstEInvHeaderMatching" AS
	SELECT
		EInv."Id" "EInvId",		
		gst."Id" "GstId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = TRUE OR gst."TransactionType" = EInv."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR EInv."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		--CASE WHEN  ("_IsExcludeMatchingCriteriaGstin" = TRUE OR einv."Gstin" = gst."Gstin") THEN NULL ELSE gst."Gstin" END "Gstin",
		CASE WHEN  (gst."Pos" = 96 and gst."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (EInv."Pos" = 96 and EInv."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (gst."Pos" = EInv."Pos") THEN NULL ELSE gst."Pos" END "Pos",
		CASE WHEN  gst."DocumentDate" = EInv."DocumentDate" THEN NULL ELSE ABS(EXTRACT (day from gst."DocumentDate"::timestamp - EInv."DocumentDate"::timestamp)) END "DocumentDate",
		CASE WHEN  gst."ReverseCharge" = EInv."ReverseCharge" THEN NULL ELSE CASE WHEN gst."ReverseCharge" = true THEN 'Y' ELSE 'N' END END "ReverseCharge",
		CASE WHEN  gst."DocumentValue" = EInv."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN EInv."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND EInv."DocumentValue"+"_MatchByToleranceDocumentValueTo" THEN NULL		 
			 ELSE ABS(gst."DocumentValue" - EInv."DocumentValue") END "DocumentValue",
		CASE WHEN  gst."ItemCount" = EInv."ItemCount" THEN NULL ELSE ABS(gst."ItemCount" - EInv."ItemCount") END "ItemCount",		
		CASE WHEN  gst."IgstAmount" = EInv."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN EInv."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."IgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."IgstAmount" - EInv."IgstAmount") END "IgstAmount",		
		CASE WHEN  gst."SgstAmount" = EInv."SgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN EInv."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."SgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."SgstAmount" - EInv."SgstAmount") END "SgstAmount",		
		CASE WHEN  gst."CgstAmount" = EInv."CgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN EInv."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."CgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CgstAmount" - EInv."CgstAmount") END "CgstAmount",		
		CASE WHEN  gst."CessAmount" = EInv."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN EInv."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."CessAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CessAmount" - EInv."CessAmount") END "CessAmount",		
		CASE WHEN  gst."TaxableValue" = EInv."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN EInv."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND EInv."TaxableValue"+"_MatchByToleranceTaxableValueTo" THEN NULL		 
			 ELSE ABS(gst."TaxableValue" - EInv."TaxableValue") END "TaxableValue",		
		CASE WHEN  gst."StateCessAmount" = EInv."StateCessAmount" THEN NULL ELSE ABS(gst."StateCessAmount" - EInv."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType"
	FROM 
		"TempRegularReturnData" gst
	INNER JOIN "TempEInvoiceData" EInv on gst."DocumentNumber" = EInv."DocumentNumber" AND gst."DocumentType" = EInv."Type" and gst."DocumentFinancialYear" = EInv."DocumentFinancialYear" AND gst."SupplyType" = "_SupplyTypeSale"
	WHERE gst."ParentEntityId" = EInv."ParentEntityId"
		AND gst."ReturnPeriod" = EInv."ReturnPeriod";
	
	/*Getting Matched ids to compare data at detail level*/	
	CREATE TEMP TABLE "TempGstEInvMatchedId" AS
	SELECT 
		e."GstId",
		"EInvId",
		e."SupplyType"
	FROM "TempGstEInvHeaderMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN "Pos" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "ReverseCharge" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;				
	
	/*Comparing data at detail level*/		
	CREATE TEMP TABLE "TempGstEInvDetailComp" AS 
	SELECT 
		Ids."GstId",
		"EInvId",		
		SUM(CASE WHEN COALESCE(ED."ItemCount",0) <> COALESCE(EInv."ItemCount",0) THEN 3
			ELSE
				CASE WHEN "_IsMatchByTolerance" = true THEN
						CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(EInv."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
						       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(EInv."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(EInv."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CessAmount",0) - COALESCE(EInv."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(EInv."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
				 	    ELSE 0 END 	
				 ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(EInv."IgstAmount",0) THEN 1 
					       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(EInv."CgstAmount",0) THEN 1
						   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(EInv."SgstAmount",0) THEN 1
						   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(EInv."CessAmount",0) THEN 1
						   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(EInv."TaxableValue",0) THEN 1
						   ELSE 0 END END
	   END) AS "DetailComparison",
	   ids."SupplyType"	
	FROM "TempGstEInvMatchedId" Ids
	INNER JOIN "TempRegularReturnDetailData" ED ON Ids."GstId"= ED."GstId" AND ids."SupplyType" = Ed."SupplyType"
	LEFT JOIN "TempEInvoiceDetailData" EInv ON IDS."EInvId" = EInv."DocumentId" AND ED."Rate" = EInv."Rate" 
	GROUP BY "EInvId",Ids."GstId",ids."SupplyType";

	/*Finding sectiontype",Reason Type */			
	CREATE TEMP TABLE "TempGstEInvReco" AS
	SELECT 
		Ids."GstId",
		ED."EInvId",	
		Ids."SupplyType",	
		CASE WHEN ED."GstId" IS NOT NULL
				THEN CASE WHEN "TransactionType" IS NULL AND "Pos" IS NULL AND "DocumentValue" IS NULL AND "ReverseCharge" IS NULL AND "DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND "ItemCount" IS NULL
				AND "IgstAmount" IS NULL AND "SgstAmount" IS NULL AND "CgstAmount" IS NULL AND "CessAmount" IS NULL  AND "TaxableValue" IS NULL
							THEN "_ReconciliationSectionTypeEInvMatched"
							ELSE "_ReconciliationSectionTypeEInvMismatched"
					 END	
			 ELSE "_ReconciliationSectionTypeEInvNotAvailable" END "EInvSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +
-- 		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +
		CASE WHEN ED."Pos" IS NOT NULL Then "_ReconciliationReasonTypePOS" else 0 END +
		CASE WHEN ED."ReverseCharge" IS NOT NULL Then "_ReconciliationReasonTypeReverseCharge" else 0 END +
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "EInvReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 
-- 				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."Pos" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypePOS" , ',"Value":"', "Pos" ,'"},') ELSE '' END ||
				CASE WHEN ED."ReverseCharge" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeReverseCharge" , ',"Value":""},') ELSE '' END ||
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', "DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', "DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', "ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',"IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',"CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',"SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',"TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',"CessAmount",'"},') ELSE '' END
				) "EInvReason",				
		"_MappingTypeMonthly" "MappingType"						
	FROM "TempGstUnreconciledIds" Ids
	LEFT JOIN "TempGstEInvHeaderMatching" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempGstEInvDetailComp" EDI ON Ed."GstId" = EDI."GstId" AND ED."SupplyType" = EDI."SupplyType"  AND ED."EInvId" = EDI."EInvId"	;	

	/*Deleting data from RecoMapperTable*/			 	
	DELETE 		 
	FROM
		 report."GstRecoMapper" rm 
	USING
		"TempGstUnreconciledIds" Ids 
	WHERE Ids."GstId" = rm."GstId" AND Ids."SupplyType" = rm."GstType";	

	/*Inserting data of MonthlyComparison into Mapping Table*/
	INSERT INTO report."GstRecoMapper"
	(
		 "GstId"
		,"EInvId"
		,"EWBId"
		,"AutoDraftId"
		,"GstType"
		,"EInvSection"
		,"EWBSection"
		,"AutoDraftSection"
		,"EInvReasonsType"
		,"EwbReasonsType"
		,"AutoDraftReasonsType"
		,"EInvReason"
		,"EwbReason"
		,"AutoDraftReason"
		,"MappingType"
		,"Stamp"
		,"ModifiedStamp"
	)
	SELECT 
		ES."GstId",
		EE."EInvId",
		CASE WHEN Es."EwbSection" = "_ReconciliationSectionTypeEwbNotApplicable" THEN NULL ELSE ES."EwbId" END,
		AD."AutoDraftId",
		ES."SupplyType",
		EE."EInvSection",
		ES."EwbSection",
		CASE WHEN ES."SupplyType" =  "_SupplyTypePurchase" THEN "_ReconciliationSectionTypeGstAutodraftedNotAvailable" ELSE AD."AutoDraftSection" END,
		CASE WHEN EE."EInvReasonsType" = 0 THEN NULL ELSE EE."EInvReasonsType" END,
		CASE WHEN ES."EwbReasonsType" = 0 OR ES."EwbSection" = "_ReconciliationSectionTypeEwbNotApplicable" THEN NULL ELSE ES."EwbReasonsType" END,
		CASE WHEN AD."AutoDraftReasonsType" = 0 THEN NULL ELSE Ad."AutoDraftReasonsType" END,
		CASE WHEN EE."EInvReason" = '' THEN NULL ELSE CONCAT('[',LEFT(EE."EInvReason",LENGTH(EE."EInvReason")-1) ,']') END,
		CASE WHEN ES."EwbReason" = '' OR Es."EwbSection" = "_ReconciliationSectionTypeEwbNotApplicable" THEN NULL ELSE CONCAT('[',LEFT(ES."EwbReason",LENGTH(ES."EwbReason")-1),']') END,
		CASE WHEN AD."AutoDraftReason" = '' THEN NULL ELSE CONCAT('[',LEFT(AD."AutoDraftReason",LENGTH(AD."AutoDraftReason")-1),']') END,
		"_MappingTypeMonthly",
		NOW()::timestamp without time zone,
		NULL
	FROM
		"TempGstEwbReco" ES
	LEFT JOIN "TempGstEInvReco" EE ON ES."GstId" = EE."GstId" ANd ES."SupplyType" = EE."SupplyType"
	LEFT JOIN "TempGstAutoDraftReco" AD ON ES."GstId" = AD."GstId" ANd ES."SupplyType" = AD."SupplyType";
	
	DROP TABLE IF EXISTS "TempGstEInvDetailComp","TempGstEInvHeaderMatching","TempGstEInvMatchedId","TempGstEInvReco","TempGstEwbDetailComparison","TempGstEwbHeaderDataMatching",
						"TempGstEwbMatchedIds","TempGstEwbReco","TempYearlyGstEInvDetailComp","TempGstEInvDetailComp","TempGstAutoDraftDetailComp","TempGstAutoDraftHeaderMatching","TempGstAutoDraftMatchedId","TempGstAutoDraftReco";

	--*************************Monthly Comparison ENDS**************************************
	
	--*************************YEARLY Comparison Starts***************************************

	/*Header data comparsion of Regulardata With Ewaybill data */
	CREATE TEMP TABLE "TempYearlyGstEwbHeaderDataMatching" AS
	SELECT
		gst."Id" "GstId",
		ewb."Id" "EwbId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = TRUE OR GST."TransactionType" = EWB."TransactionType" OR (GST."TransactionType" = "_TransactionTypeCBW" OR EWB."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		--CASE WHEN  (("_IsExcludeMatchingCriteriaGstin" = TRUE OR gst."Gstin" = ewb."Gstin") AND ewb."SupplyType"="_SupplyTypeSale") OR ewb."SupplyType"="_SupplyTypePurchase" THEN NULL ELSE gst."Gstin" END "Gstin",
		CASE WHEN  EWB."DocumentDate" = gst."DocumentDate" THEN NULL ELSE ABS(EXTRACT (day from EWB."DocumentDate"::timestamp - gst."DocumentDate"::timestamp)) END "DocumentDate",		
		CASE WHEN  EWB."DocumentValue" = gst."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN ewb."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND ewb."DocumentValue"+"_MatchByToleranceDocumentValueTo"	THEN NULL		 			 
			 ELSE ABS(EWB."DocumentValue" - gst."DocumentValue") END "DocumentValue",
		CASE WHEN  EWb."ItemCount" = gst."ItemCount" THEN NULL ELSE ABS(EWB."ItemCount" - gst."ItemCount") END "ItemCount",		
		CASE WHEN  EWb."IgstAmount" = gst."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN ewb."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."IgstAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(EWB."IgstAmount" - gst."IgstAmount") END "IgstAmount",		
		CASE WHEN  EWb."SgstAmount" = gst."SgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN ewb."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."SgstAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(EWB."SgstAmount" - gst."SgstAmount") END "SgstAmount",		
		CASE WHEN  EWb."CgstAmount" = gst."CgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN ewb."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."CgstAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(EWB."CgstAmount" - gst."CgstAmount") END "CgstAmount",		
		CASE WHEN  EWb."CessAmount" = gst."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN ewb."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND ewb."CessAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(EWB."CessAmount" - gst."CessAmount") END "CessAmount",		
		CASE WHEN  EWb."TaxableValue" = gst."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN ewb."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND ewb."TaxableValue"+"_MatchByToleranceTaxableValueTo"	THEN NULL		 
			 ELSE ABS(EWB."TaxableValue" - gst."TaxableValue") END "TaxableValue",		
		CASE WHEN  EWb."StateCessAmount" = gst."StateCessAmount" THEN NULL ELSE ABS(EWB."StateCessAmount" - gst."StateCessAmount") END "StateCessAmount",
		gst."SupplyType",
		CASE WHEN EWB."DocumentValue" < "_DocValueThresholdForRecoAgainstEwb" THEN TRUE ELSE FALSE END "IsEwbNotApplicable"
	FROM 
		"TempRegularReturnData" gst	
	INNER JOIN "TempEwayBillData" ewb ON EWB."DocumentNumber" = gst."DocumentNumber" AND EWB."Type" = gst."DocumentType" and EWB."DocumentFinancialYear" = gst."DocumentFinancialYear" AND EWB."Gstin" = gst."Gstin" AND ewb."SupplyType" = gst."SupplyType"
	WHERE
	    EWB."ParentEntityId" = gst."ParentEntityId"		
		AND EWB."FinancialYear" = gst."FinancialYear";	
	
	/*Getting Matched ids to compare data at detail level*/
	CREATE TEMP TABLE "TempYearlyGstEwbMatchedIds" AS
	SELECT 
		e."GstId",
		"EwbId",
		e."SupplyType"
	FROM "TempYearlyGstEwbHeaderDataMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END   
			+ CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;	

	/*comparing data at detail level*/		
	CREATE TEMP TABLE "TempYearlyGstEwbDetailComparison" AS
	SELECT 
		Ids."GstId",
		"EwbId",
		SUM(CASE WHEN COALESCE(SD."ItemCount",0) <> COALESCE(ED."ItemCount",0) THEN 3
			ELSE	
				CASE WHEN "_IsMatchByTolerance" = true THEN
					CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(SD."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
				       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(SD."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
					   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(SD."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
					   WHEN COALESCE(ED."CessAmount",0) - COALESCE(SD."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
					   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(SD."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
	  				 ELSE 0 END 
				 ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(SD."IgstAmount",0) THEN 1 
					       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(SD."CgstAmount",0) THEN 1
						   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(SD."SgstAmount",0) THEN 1
						   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(SD."CessAmount",0) THEN 1
						   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(SD."TaxableValue",0) THEN 1
						   ELSE 0 END END
			 END) AS "DetailComparison",
			Ids."SupplyType"
	FROM "TempYearlyGstEwbMatchedIds" Ids
	INNER JOIN "TempRegularReturnDetailData" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempEwaybillDetailData" SD ON  IDS."EwbId" = SD."DocumentId" AND ED."Rate" = SD."Rate" 
	GROUP BY "EwbId",Ids."GstId",Ids."SupplyType";

	/*Finding final Section and reason of reconciled data*/		
	CREATE TEMP TABLE "TempYearlyGstEwbReco" AS				
	SELECT 
		Ids."GstId",
		Ed."EwbId",
		Ids."SupplyType",
		CASE WHEN ED."GstId" IS NOT NULL AND Ed."IsEwbNotApplicable" = false
				THEN CASE WHEN ED."TransactionType" IS NULL
				AND ED."DocumentValue" IS NULL AND ED."DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND ED."ItemCount" IS NULL
				AND ED."IgstAmount" IS NULL AND ED."SgstAmount" IS NULL AND ED."CgstAmount" IS NULL AND ED."CessAmount" IS NULL AND ED."TaxableValue" IS NULL
							THEN "_ReconciliationSectionTypeEwbMatched"	
							ELSE "_ReconciliationSectionTypeEwbMismatched"
					 END	
            ELSE CASE WHEN trd."DocumentType" IN ("_DocumentTypeCRN","_DocumentTypeDBN") OR "IsEwbNotApplicable" = True THEN "_ReconciliationSectionTypeEwbNotApplicable"  ELSE "_ReconciliationSectionTypeEwbNotAvailable" END
		END "EwbSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +				
-- 		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +				
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "EwbReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 								
-- 				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', ED."DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', ED."DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', ED."ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',ED."IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',ED."CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',ED."SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',ED."TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',ED."CessAmount",'"},') ELSE '' END
				) "EwbReason" ,						
		"_MappingTypeYearly" "MappingType"	
	FROM 
		"TempGstUnreconciledIds" Ids
	INNER JOIN "TempRegularReturnData" trd ON Ids."GstId" = trd."Id" AND Ids."SupplyType" = trd."SupplyType"
	LEFT JOIN "TempYearlyGstEwbHeaderDataMatching" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempYearlyGstEwbDetailComparison" EDI ON IDS."GstId" = EDI."GstId" AND Ids."SupplyType" = EDI."SupplyType" AND ED."EwbId" = EDI."EwbId";						

	/*Header data comparison of Gst data with EInvoice data*/
	CREATE TEMP TABLE "TempYearlyGstEInvHeaderMatching" AS
	SELECT
		EInv."Id" "EInvId",		
		gst."Id" "GstId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = TRUE OR einv."TransactionType" = gst."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR einv."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		--CASE WHEN  ("_IsExcludeMatchingCriteriaGstin" = TRUE OR einv."Gstin" = gst."Gstin") THEN NULL ELSE gst."Gstin" END "Gstin",
		CASE WHEN  (gst."Pos" = 96 and gst."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (EInv."Pos" = 96 and EInv."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (gst."Pos" = EInv."Pos") THEN NULL ELSE gst."Pos" END "Pos",
		CASE WHEN  gst."DocumentDate" = EInv."DocumentDate" THEN NULL ELSE ABS(EXTRACT (day from gst."DocumentDate"::timestamp  -EInv."DocumentDate" ::timestamp)) END "DocumentDate",
		CASE WHEN  gst."ReverseCharge" = EInv."ReverseCharge" THEN NULL ELSE  CASE WHEN gst."ReverseCharge" = true THEN 'Y' ELSE 'N' END  END "ReverseCharge",
		CASE WHEN  gst."DocumentValue" = EInv."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN EInv."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND EInv."DocumentValue"+"_MatchByToleranceDocumentValueTo" THEN NULL		 
			 ELSE ABS(gst."DocumentValue" - EInv."DocumentValue") END "DocumentValue",
		CASE WHEN  gst."ItemCount" = EInv."ItemCount" THEN NULL ELSE ABS(gst."ItemCount" - EInv."ItemCount") END "ItemCount",		
		CASE WHEN  gst."IgstAmount" = EInv."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN EInv."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."IgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."IgstAmount" - EInv."IgstAmount") END "IgstAmount",		
		CASE WHEN  gst."SgstAmount" = EInv."SgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN EInv."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."SgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."SgstAmount" - EInv."SgstAmount") END "SgstAmount",		
		CASE WHEN  gst."CgstAmount" = EInv."CgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN EInv."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."CgstAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CgstAmount" - EInv."CgstAmount") END "CgstAmount",		
		CASE WHEN  gst."CessAmount" = EInv."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN EInv."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND EInv."CessAmount"+"_MatchByToleranceTaxAmountsTo" THEN NULL		 
			 ELSE ABS(gst."CessAmount" - EInv."CessAmount") END "CessAmount",		
		CASE WHEN  gst."TaxableValue" = EInv."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN EInv."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND EInv."TaxableValue"+"_MatchByToleranceTaxableValueTo" THEN NULL		 
			 ELSE ABS(gst."TaxableValue" - EInv."TaxableValue") END "TaxableValue",		
		CASE WHEN  gst."StateCessAmount" = EInv."StateCessAmount" THEN NULL ELSE ABS(gst."StateCessAmount" - EInv."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType"
	FROM 
		"TempRegularReturnData" gst
	INNER JOIN "TempEInvoiceData" EInv on gst."DocumentNumber" = EInv."DocumentNumber" AND gst."DocumentType" = EInv."Type" and gst."DocumentFinancialYear" = EInv."DocumentFinancialYear" AND gst."SupplyType" = "_SupplyTypeSale"
	WHERE gst."ParentEntityId" = EInv."ParentEntityId"		
		  AND EInv."FinancialYear" = gst."FinancialYear";

	/*Getting matched ids to compare data at detail level*/
	CREATE TEMP TABLE "TempYearlyGstEInvMatchedId" AS
	SELECT 
		e."GstId",
		"EInvId",
		e."SupplyType"
	FROM "TempYearlyGstEInvHeaderMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Pos" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "ReverseCharge" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;	
	
	/*comparing data at detail level*/
	CREATE TEMP TABLE "TempYearlyGstEInvDetailComp" AS
	SELECT 
		Ids."GstId",
		"EInvId",		
		SUM(CASE WHEN COALESCE(ED."ItemCount",0) <> COALESCE(EInv."ItemCount",0) THEN 3
			ELSE
				CASE WHEN "_IsMatchByTolerance" = true THEN
						CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(EInv."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
						       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(EInv."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(EInv."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CessAmount",0) - COALESCE(EInv."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(EInv."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
				 	    ELSE 0 END 		
			 ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(EInv."IgstAmount",0) THEN 1 
				       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(EInv."CgstAmount",0) THEN 1
					   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(EInv."SgstAmount",0) THEN 1
					   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(EInv."CessAmount",0) THEN 1
					   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(EInv."TaxableValue",0) THEN 1
					   ELSE 0 END END
	   END) AS "DetailComparison",
	   ids."SupplyType"	
	FROM "TempYearlyGstEInvMatchedId" Ids
	INNER JOIN "TempRegularReturnDetailData" ED ON Ids."GstId"= ED."GstId" AND ids."SupplyType" = Ed."SupplyType"
	LEFT JOIN "TempEInvoiceDetailData" EInv ON IDS."EInvId" = EInv."DocumentId" AND ED."Rate" = EInv."Rate" 
	GROUP BY "EInvId",Ids."GstId",ids."SupplyType" ;
	
	/*Finding final Section and reason of reconciled data*/		
	CREATE TEMP TABLE "TempYearlyGstEInvReco" AS
	SELECT 
		Ids."GstId",
		ED."EInvId",	
		Ids."SupplyType",	
		CASE WHEN ED."GstId" IS NOT NULL
			 THEN CASE WHEN "TransactionType" IS NULL AND "Pos" IS NULL AND "DocumentValue" IS NULL AND "ReverseCharge" IS NULL AND "DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND "ItemCount" IS NULL
							AND "IgstAmount" IS NULL AND "SgstAmount" IS NULL AND "CgstAmount" IS NULL AND "CessAmount" IS NULL AND "TaxableValue" IS NULL
					   THEN "_ReconciliationSectionTypeEInvMatched"
					   ELSE "_ReconciliationSectionTypeEInvMismatched"
				   END	
			 ELSE "_ReconciliationSectionTypeEInvNotAvailable" 
		END "EInvSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +
-- 		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +
		CASE WHEN ED."Pos" IS NOT NULL Then "_ReconciliationReasonTypePOS" else 0 END +
		CASE WHEN ED."ReverseCharge" IS NOT NULL Then "_ReconciliationReasonTypeReverseCharge" else 0 END +
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "EInvReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 
-- 				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."Pos" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypePOS" , ',"Value":"', "Pos" ,'"},') ELSE '' END ||
				CASE WHEN ED."ReverseCharge" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeReverseCharge" , ',"Value":""},') ELSE '' END ||
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', "DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', "DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', "ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',"IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',"CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',"SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',"TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',"CessAmount",'"},') ELSE '' END
				) "EInvReason",						
		"_MappingTypeYearly" "MappingType"						
	FROM "TempGstUnreconciledIds" Ids
	LEFT JOIN "TempYearlyGstEInvHeaderMatching" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempYearlyGstEInvDetailComp" EDI ON Ed."GstId" = EDI."GstId" AND ED."SupplyType" = EDI."SupplyType" AND ED."EInvId" = EDI."EInvId";			
	
	/*Header data comparison of Gst data with AutoDraft data*/
	CREATE TEMP TABLE "TempYearlyGstAutoDraftHeaderMatching" AS
	SELECT
		sad."Id" "AutoDraftId",		
		gst."Id" "GstId",		
		CASE WHEN  ("_IsExcludeMatchingCriteriaTransactionType" = false OR gst."TransactionType" = sad."TransactionType" OR (gst."TransactionType" = "_TransactionTypeCBW" OR sad."UnderIgstAct" = TRUE)) THEN NULL ELSE gst."TransactionType" END "TransactionType",
		CASE WHEN  ("_IsExcludeMatchingCriteriaGstin" = false OR gst."Gstin" = sad."Gstin") THEN NULL ELSE gst."Gstin" END "Gstin",
		CASE WHEN  (gst."Pos" = 96 and gst."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (sad."Pos" = 96 and sad."TransactionType" IN ("_TransactionTypeEXPWP","_TransactionTypeEXPWOP")) OR (gst."Pos" = sad."Pos") THEN NULL ELSE gst."Pos" END "Pos",
		CASE WHEN  gst."DocumentDate" = sad."DocumentDate" THEN NULL ELSE ABS(EXTRACT (day from gst."DocumentDate"::timestamp-sad."DocumentDate"::timestamp)) END "DocumentDate",
		CASE WHEN  gst."ReverseCharge" = sad."ReverseCharge" THEN NULL ELSE  CASE WHEN gst."ReverseCharge" = true THEN 'Y' ELSE 'N' END END "ReverseCharge",
		CASE WHEN  gst."DocumentValue" = sad."DocumentValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."DocumentValue" BETWEEN sad."DocumentValue"+"_MatchByToleranceDocumentValueFrom" AND sad."DocumentValue"+"_MatchByToleranceDocumentValueTo"	THEN NULL		 
			 ELSE ABS(gst."DocumentValue" - sad."DocumentValue") END "DocumentValue",
		CASE WHEN  gst."ItemCount" = sad."ItemCount" THEN NULL ELSE ABS(gst."ItemCount" - sad."ItemCount") END "ItemCount",		
		CASE WHEN  gst."IgstAmount" = sad."IgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."IgstAmount" BETWEEN sad."IgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."IgstAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(gst."IgstAmount" - sad."IgstAmount") END "IgstAmount",		
		CASE WHEN  gst."SgstAmount" = sad."SgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."SgstAmount" BETWEEN sad."SgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."SgstAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(gst."SgstAmount" - sad."SgstAmount") END "SgstAmount",		
		CASE WHEN  gst."CgstAmount" = sad."CgstAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CgstAmount" BETWEEN sad."CgstAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CgstAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(gst."CgstAmount" - sad."CgstAmount") END "CgstAmount",		
		CASE WHEN  gst."CessAmount" = sad."CessAmount" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."CessAmount" BETWEEN sad."CessAmount"+"_MatchByToleranceTaxAmountsFrom" AND sad."CessAmount"+"_MatchByToleranceTaxAmountsTo"	THEN NULL		 
			 ELSE ABS(gst."CessAmount" - sad."CessAmount") END "CessAmount",		
		CASE WHEN  gst."TaxableValue" = sad."TaxableValue" THEN NULL 
			 WHEN "_IsMatchByTolerance" = true AND gst."TaxableValue" BETWEEN sad."TaxableValue"+"_MatchByToleranceTaxableValueFrom" AND sad."TaxableValue"+"_MatchByToleranceTaxableValueTo"	THEN NULL		 
			 ELSE ABS(gst."TaxableValue" - sad."TaxableValue") END "TaxableValue",
		CASE WHEN  gst."StateCessAmount" = sad."StateCessAmount" THEN NULL ELSE ABS(gst."StateCessAmount" - sad."StateCessAmount") END "StateCessAmount",		
		gst."SupplyType"
	FROM 
		"TempRegularReturnData" gst
	INNER JOIN "TempAutoDraftData" sad on gst."DocumentNumber" = sad."DocumentNumber" AND gst."DocumentType" = sad."DocumentType" and gst."DocumentFinancialYear" = sad."DocumentFinancialYear" 
	WHERE gst."ParentEntityId" = sad."ParentEntityId"		
		AND gst."SupplyType" = "_SupplyTypeSale"
		AND sad."FinancialYear" = gst."FinancialYear";

	/*Getting matched ids to compare data at detail level*/
	CREATE TEMP TABLE  "TempYearlyGstAutoDraftMatchedId" AS
	SELECT 
		e."GstId",
		"AutoDraftId",
		e."SupplyType"
	FROM "TempYearlyGstAutoDraftHeaderMatching" e
	WHERE (CASE WHEN "TransactionType" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Gstin" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "Pos" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "ReverseCharge" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN "DocumentDate" IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN COALESCE("DocumentValue",0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN COALESCE("ItemCount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("IgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("SgstAmount",0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN COALESCE("CgstAmount",0) <>0  THEN 1 ELSE  0 END + CASE WHEN COALESCE("TaxableValue",0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN COALESCE("CessAmount",0) <>0  THEN 1 ELSE  0 END) = 0;
	
	/*comparing data at detail level*/
	CREATE TEMP TABLE "TempYearlyGstAutoDraftDetailComp" AS
	SELECT 
		Ids."GstId",
		Ids."AutoDraftId",		
		SUM(CASE WHEN COALESCE(ED."ItemCount",0) <> COALESCE(sad."ItemCount",0) THEN 3
			ELSE
				CASE WHEN "_IsMatchByTolerance" = true THEN
						CASE WHEN COALESCE(ED."IgstAmount",0) - COALESCE(sad."IgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1 
						       WHEN COALESCE(ED."SgstAmount",0) - COALESCE(sad."SgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CgstAmount",0) - COALESCE(sad."CgstAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."CessAmount",0) - COALESCE(sad."CessAmount",0) NOT BETWEEN "_MatchByToleranceTaxAmountsFrom" AND "_MatchByToleranceTaxAmountsTo" THEN 1
							   WHEN COALESCE(ED."TaxableValue",0) - COALESCE(sad."TaxableValue",0) NOT BETWEEN "_MatchByToleranceTaxableValueFrom" AND "_MatchByToleranceTaxableValueTo" THEN 1
				 	    ELSE 0 END 		
			 ELSE CASE WHEN COALESCE(ED."IgstAmount",0) <> COALESCE(sad."IgstAmount",0) THEN 1 
				       WHEN COALESCE(ED."CgstAmount",0) <> COALESCE(sad."CgstAmount",0) THEN 1
					   WHEN COALESCE(ED."SgstAmount",0) <> COALESCE(sad."SgstAmount",0) THEN 1
					   WHEN COALESCE(ED."CessAmount",0) <> COALESCE(sad."CessAmount",0) THEN 1
					   WHEN COALESCE(ED."TaxableValue",0) <> COALESCE(sad."TaxableValue",0) THEN 1
					   ELSE 0 END END
	   END) AS "DetailComparison",
	   ids."SupplyType"	
	FROM "TempYearlyGstAutoDraftMatchedId" Ids
	INNER JOIN "TempRegularReturnDetailData" ED ON Ids."GstId"= ED."GstId" 
	LEFT JOIN "TempAutoDraftDetailData" sad ON IDS."AutoDraftId" = sad."AutoDraftId" AND ED."Rate" = sad."Rate"
	GROUP BY Ids."AutoDraftId",Ids."GstId",ids."SupplyType"; 
	
	/*Finding final Section and reason of reconciled data*/		
	CREATE TEMP TABLE "TempYearlyGstAutoDraftReco" AS
	SELECT 
		Ids."GstId",
		ED."AutoDraftId",	
		Ids."SupplyType",	
		CASE WHEN ED."GstId" IS NOT NULL
			 THEN CASE WHEN "TransactionType" IS NULL AND "Pos" IS NULL AND "Gstin" IS NULL AND "DocumentValue" IS NULL AND "ReverseCharge" IS NULL AND "DocumentDate" IS NULL AND COALESCE("DetailComparison",0) = 0 AND "ItemCount" IS NULL
							AND "IgstAmount" IS NULL AND "SgstAmount" IS NULL AND "CgstAmount" IS NULL AND "CessAmount" IS NULL AND "TaxableValue" IS NULL
					   THEN "_ReconciliationSectionTypeGstAutodraftedMatched"
					   ELSE "_ReconciliationSectionTypeGstAutodraftedMismatched"
				   END	
			 ELSE "_ReconciliationSectionTypeGstAutodraftedNotAvailable" 
		END "AutoDraftSection",		
		CASE WHEN ED."TransactionType" IS NOT NULL Then "_ReconciliationReasonTypeTransactionType" else 0 END +
 		CASE WHEN ED."Gstin" IS NOT NULL Then "_ReconciliationReasonTypeGstin" else 0 END +
		CASE WHEN ED."Pos" IS NOT NULL Then "_ReconciliationReasonTypePOS" else 0 END +
		CASE WHEN ED."ReverseCharge" IS NOT NULL Then "_ReconciliationReasonTypeReverseCharge" else 0 END +
		CASE WHEN ED."DocumentDate" IS NOT NULL Then "_ReconciliationReasonTypeDocumentDate" else 0 END +
		CASE WHEN ED."DocumentValue" IS NOT NULL Then "_ReconciliationReasonTypeDocumentValue" else 0 END  + 
		CASE WHEN ED."ItemCount" IS NOT NULL Then "_ReconciliationReasonTypeItems" else 0 END  + 
		CASE WHEN ED."IgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeIgstAmount" else 0 END  + 
		CASE WHEN ED."CgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeCgstAmount" else 0 END  + 
		CASE WHEN ED."SgstAmount" IS NOT NULL Then "_ReconciliationReasonTypeSgstAmount" else 0 END  + 
		CASE WHEN ED."TaxableValue" IS NOT NULL Then "_ReconciliationReasonTypeTaxableValue" else 0 END  + 
		CASE WHEN COALESCE("DetailComparison",0) >= 3 Then "_ReconciliationReasonTypeRate" else 0 END  + 
		CASE WHEN ED."CessAmount" IS NOT NULL Then "_ReconciliationReasonTypeCessAmount" else 0 END  AS "AutoDraftReasonsType",
		(SELECT CASE WHEN ED."TransactionType" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTransactionType"  , ',"Value":""},') ELSE '' END || 
 				CASE WHEN ED."Gstin" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeGstin" , ',"Value":""},') ELSE '' END ||
		 		CASE WHEN ED."Pos" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypePOS" , ',"Value":"', "Pos" ,'"},') ELSE '' END ||
				CASE WHEN ED."ReverseCharge" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeReverseCharge" , ',"Value":""},') ELSE '' END ||
				CASE WHEN ED."DocumentDate" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentDate" , ',"Value":"', "DocumentDate" ,'"},') ELSE '' END ||
				CASE WHEN ED."DocumentValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeDocumentValue" , ',"Value":"', "DocumentValue" ,'"},') ELSE '' END ||
				CASE WHEN ED."ItemCount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeItems" , ',"Value":"', "ItemCount" ,'"},') ELSE '' END ||
				CASE WHEN ED."IgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeIgstAmount" , ',"Value":"',"IgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."CgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCgstAmount" , ',"Value":"',"CgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."SgstAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeSgstAmount" , ',"Value":"',"SgstAmount",'"},') ELSE '' END ||
				CASE WHEN ED."TaxableValue" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeTaxableValue" , ',"Value":"',"TaxableValue",'"},') ELSE '' END ||
				CASE WHEN COALESCE("DetailComparison",0) >= 3 Then CONCAT('{"Reason":', "_ReconciliationReasonTypeRate"  , ',"Value":""},') ELSE '' END || 
				CASE WHEN ED."CessAmount" IS NOT NULL Then CONCAT('{"Reason":', "_ReconciliationReasonTypeCessAmount" , ',"Value":"',"CessAmount",'"},') ELSE '' END
				) "AutoDraftReason" ,						
		"_MappingTypeYearly" "MappingType"						
	FROM "TempGstUnreconciledIds" Ids
	LEFT JOIN "TempYearlyGstAutoDraftHeaderMatching" ED ON Ids."GstId" = ED."GstId" AND Ids."SupplyType" = ED."SupplyType"
	LEFT JOIN "TempYearlyGstAutoDraftDetailComp" EDI ON Ed."GstId" = EDI."GstId" AND ED."SupplyType" = EDI."SupplyType" AND ED."AutoDraftId" = EDI."AutoDraftId";	

	/*Inserting data of MonthlyComparison into Mapping Table*/
	INSERT INTO report."GstRecoMapper"
	(
		 "GstId"
		 ,"EInvId"
		 ,"EWBId"
		 ,"AutoDraftId"
		 ,"GstType"
		 ,"EInvSection"
		 ,"EWBSection"
		 ,"AutoDraftSection"
		 ,"EInvReasonsType"
		 ,"EwbReasonsType"
		 ,"AutoDraftReasonsType"
		 ,"EInvReason"
		 ,"EwbReason"
		 ,"AutoDraftReason"
		 ,"MappingType"
		 ,"Stamp"
		 ,"ModifiedStamp"
	)
	SELECT 
		ES."GstId",
		EE."EInvId",
		CASE WHEN Es."EwbSection" = "_ReconciliationSectionTypeEwbNotApplicable" THEN NULL ELSE ES."EwbId" END,
		AD."AutoDraftId",
		EE."SupplyType",
		EE."EInvSection",
		ES."EwbSection",
		CASE WHEN ES."SupplyType" =  "_SupplyTypePurchase" THEN "_ReconciliationSectionTypeGstAutodraftedNotAvailable" ELSE AD."AutoDraftSection" END,
		CASE WHEN EE."EInvReasonsType" = 0 THEN NULL ELSE EE."EInvReasonsType" END,
		CASE WHEN ES."EwbReasonsType" = 0 OR Es."EwbSection" = "_ReconciliationSectionTypeEwbNotApplicable" THEN NULL ELSE ES."EwbReasonsType" END,
		CASE WHEN AD."AutoDraftReasonsType" = 0 THEN NULL ELSE AD."AutoDraftReasonsType" END,
		CASE WHEN EE."EInvReason" = '' THEN NULL ELSE CONCAT('[',LEFT(EE."EInvReason",LENGTH(EE."EInvReason")-1) ,']') END,
		CASE WHEN ES."EwbReason" = '' OR Es."EwbSection" = "_ReconciliationSectionTypeEwbNotApplicable" THEN NULL ELSE CONCAT('[',LEFT(ES."EwbReason",LENGTH(ES."EwbReason")-1) ,']') END,
		CASE WHEN AD."AutoDraftReason" = '' THEN NULL ELSE CONCAT('[',LEFT(AD."AutoDraftReason",LENGTH(AD."AutoDraftReason")-1) ,']') END,
		EE."MappingType",
		NOW()::timestamp without time zone,
		NULL		
	FROM
		"TempYearlyGstEwbReco" ES
	INNER JOIN "TempYearlyGstEInvReco" EE ON ES."GstId" = EE."GstId" ANd ES."SupplyType" = EE."SupplyType"
	INNER JOIN "TempYearlyGstAutoDraftReco" AD ON ES."GstId" = AD."GstId" ANd ES."SupplyType" = AD."SupplyType";

	RAISE NOTICE 'Step 22 %', clock_timestamp()::timestamp(3) without time zone;
	RETURN QUERY
	SELECT * FROM "TempGstUnreconciledIds";
	
	END IF;

END;
$function$
;
