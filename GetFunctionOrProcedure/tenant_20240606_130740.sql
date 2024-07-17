DROP FUNCTION IF EXISTS report."Get3WayReconciliationReportByIds";

CREATE OR REPLACE FUNCTION report."Get3WayReconciliationReportByIds"("_SubscriberId" integer, "_Ids" report."ReconciliationHubTypeIdsType"[], "_Purpose" smallint, "_BaseSource" smallint, "_IncludeAggregatedItems" boolean, "_SupplyTypeSale" smallint, "_SupplyTypePurchase" smallint, "_ReconciliationSectionTypeGstNotAvailable" smallint, "_ReconciliationSectionTypeGstMatched" smallint, "_ReconciliationSectionTypeGstMismatched" smallint, "_ReconciliationSectionTypeEwbNotAvailable" smallint, "_ReconciliationSectionTypeEwbMatched" smallint, "_ReconciliationSectionTypeEwbMismatched" smallint, "_ReconciliationSectionTypeEinvNotAvailable" smallint, "_ReconciliationSectionTypeEinvMatched" smallint, "_ReconciliationSectionTypeEinvMismatched" smallint, "_MappingType" smallint, "_ReconciliationHubBaseSourceTypeEINV" smallint, "_ReconciliationHubBaseSourceTypeGST" smallint, "_ReconciliationHubBaseSourceTypeEWB" smallint, "_ReconciliationHubBaseSourceTypeGstAutodrafted" smallint, "_ReconciliationHubBaseSourceTypePurchaseAutoDraft" smallint, "_ReconciliationHubBaseSourceTypeEInvQRCode" smallint)
 RETURNS TABLE("EntityId" integer, "EinvMapperId" bigint, "EwbMapperId" bigint, "GstMapperId" bigint, "SaleAutoDraftMapperId" bigint, "PurchaseAutoDraftMapperId" bigint, "EinvQrCodeMapperId" bigint, "DocumentNumber" character varying, "DocumentDate" timestamp without time zone, "DocFinancialYear" integer, "DocumentType" smallint, "PurchaseAutodraftTransactionType" smallint, "PurchaseAutodraftPushStatus" smallint, "GstTransactionType" smallint, "GstPushStatus" smallint, "SalesAutodraftTransactionType" smallint, "SalesAutodraftPushStatus" smallint, "EinvTransactionType" smallint, "EinvPushStatus" smallint, "EwbTransactionType" smallint, "EwbPushStatus" smallint, "DocumentValue" numeric, "DocumentTaxableValue" numeric, "DocumentTaxValue" numeric, "Irn" character varying, "EwbNumber" bigint, "PartBStatus" smallint, "TransactionType" smallint, "IsAmendment" boolean, "ReverseCharge" boolean, "Pos" smallint, "BillFromGstin" character varying, "BillFromTradeName" character varying, "BillFromLegalName" character varying, "BillFromAddress1" character varying, "BillFromAddress2" character varying, "BillFromCity" character varying, "BillFromStateCode" smallint, "BillFromPin" integer, "BillToGstin" character varying, "BillToTradeName" character varying, "BillToLegalName" character varying, "BillToAddress1" character varying, "BillToAddress2" character varying, "BillToCity" character varying, "BillToStateCode" smallint, "BillToPin" integer, "GstVsEinvSection" smallint, "GstVsEwbSection" smallint, "EinvVsGstSection" smallint, "EinvVsEwbSection" smallint, "EwbVsEinvSection" smallint, "EwbVsGstSection" smallint, "GstVsSalesAutodraftSection" smallint, "SalesAutodraftVsGstSection" smallint, "GstPurchaseVsGstPurchaseAutoDraftedSection" smallint, "EinvQrCodeVsGstPurchaseAutoDraftedSection" smallint, "GSTINStatus" integer, "GSTINTaxpayerType" smallint, "Custom1" character varying, "Custom2" character varying, "Custom3" character varying, "Custom4" character varying, "Custom5" character varying, "Custom6" character varying, "Custom7" character varying, "Custom8" character varying, "Custom9" character varying, "Custom10" character varying, "HsnOrSacCode" character varying, "Name" character varying, "Description" character varying, "Uqc" character varying, "Quantity" numeric, "PricePerQuantity" numeric, "Rate" numeric, "CessRate" numeric, "StateCessRate" numeric, "CessNonAdvaloremRate" numeric, "TdsRate" numeric, "GrossAmount" numeric, "OtherCharges" numeric, "TaxableValue" numeric, "IgstAmount" numeric, "CgstAmount" numeric, "SgstAmount" numeric, "CessAmount" numeric, "StateCessAmount" numeric, "CessNonAdvaloremAmount" numeric, "StateCessNonAdvaloremAmount" numeric, "TdsAmount" numeric, "ItemTotal" smallint, "Remarks" character varying, "GstVsEinvReasonParameters" character varying, "GstVsEwbReasonParameters" character varying, "EinvVsGstReasonParameters" character varying, "EinvVsEwbReasonParameters" character varying, "EwbVsEinvReasonParameters" character varying, "EwbVsGstReasonParameters" character varying, "GstVsSalesAutodraftReasonParameters" character varying, "SalesAutodraftVsGstReasonParameters" character varying, "GstPurchaseVsGstPurchaseAutoDraftedReasonParameters" character varying, "EinvQrCodeVsGstPurchaseAutoDraftedReasonParameters" character varying)
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: temp."Get3WayReconciliationReportByIds"
*	Comments		: 25-11-2022 | CHETAN SAINI | This procedure is used to Get 3 Way Vendor Reconciliation Report By Ids.
					: 26-07-2023 | Anup Yadav | Added MapperId in Response for Enriched.
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: 	SELECT * FROM  report."Get3WayReconciliationReportByIds"(
						"_SubscriberId" := 23::integer,
						"_Ids" := ARRAY[23]:: bigint[],
						"_Purpose" := 64:: smallint,
						"_IncludeAggregatedItems" := TRUE:: BOOLEAN,
						"_PurposeTypeEINV" := 2:: smallint,
						"_PurposeTypeEWB" := 4:: smallint,
						"_PurposeTypeOGST" := 8:: smallint,
						"_PurposeTypeSaleAutoDrafted" =>  32 ::smallint,
						"_PurposeTypePurchaseAutoDraft" =>  64::smallint,
						"_SupplyTypeSale" := 2:: smallint,
						"_SupplyTypePurchase" := 1:: smallint,
						"_ReconciliationSectionTypeGstNotAvailable" := 2:: smallint,
						"_ReconciliationSectionTypeGstMatched" := 1:: smallint,
						"_ReconciliationSectionTypeGstMismatched" := 2:: smallint,
						"_ReconciliationSectionTypeEwbNotAvailable" := 2:: smallint,
						"_ReconciliationSectionTypeEwbMatched" := 1:: smallint,
						"_ReconciliationSectionTypeEwbMismatched" := 1:: smallint,
						"_ReconciliationSectionTypeEinvNotAvailable" := 2:: smallint,
						"_ReconciliationSectionTypeEinvMatched" := 1:: smallint,
						"_ReconciliationSectionTypeEinvMismatched" := 2:: smallint)
							
--------------------------------------------------------------------------------------------------------------------------------------*/
DECLARE
		"_ContactBillFromType" SMALLINT = 1;
        "_ContactBillToType" SMALLINT = 3;
		"_SqlQuery" TEXT;
		"_basetablename" text;

BEGIN

	DROP TABLE IF EXISTS "TempRecoMapperIds","TempEinvoiceId","TempEwaybillId", "TempGstId","TempAutoDraftId";
	
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
		"Id" ,
		"EInvId" ,
		"EwbId" ,
		"SaleId" ,
		"PurchaseId" ,
		"SaleAutoDraftId" ,
		"PurchaseAutoDraftId" ,
		"Purpose",
		"EinvQrId"
	)
	SELECT
		a."MapperId" ,
		a."EInvId" ,
		a."EwbId" ,
		a."SaleId" ,
		a."PurchaseId" ,
		a."SaleAutoDraftId" ,
		a."PurchaseAutoDraftId" ,
		a."Purpose",
		a."EinvQrId"
	FROM
		UNNEST("_Ids") AS "a";

	CREATE TEMP TABLE "TempEinvoiceId"		
	(	
		"EInvId" BIGINT ,
		"MapperId" BIGINT NOT NULL,
		"EwbSection" SMALLINT,
		"GstSection" SMALLINT,
		"EinvSection" SMALLINT,
		"EwbReason" VARCHAR(500),
		"GstReason" VARCHAR(500),
		"EinvReason" VARCHAR(500)
	);

	CREATE TEMP TABLE "TempEwaybillId"
	(	
		"EwbId" BIGINT,
		"EInvId" BIGINT,
		"GstType" SMALLINT,
		"MapperId" BIGINT NOT NULL,
		"EinvSection" SMALLINT,
		"GstSection" SMALLINT,
		"EwbSection" SMALLINT,
		"SupplyType" SMALLINT,
		"EwbReason" VARCHAR(500),
		"GstReason" VARCHAR(500),
		"EinvReason" VARCHAR(500)
	);

	CREATE TEMP TABLE "TempAutoDraftId"
	(	
		"AutoDraftId" BIGINT,
		"MapperId" BIGINT NOT NULL,			
		"AutoDraftSection" SMALLINT,
		"GstSection" SMALLINT,
		"SupplyType" SMALLINT,
		"GstReason" VARCHAR(500),			
		"AutoDraftReason" VARCHAR(500)	,
		"GstType" smallint
	);

	DROP TABLE IF EXISTS "TempPrIds", "TempPurchaseAutoDraftIds";
	CREATE TEMP TABLE "TempPrIds"
	(	
		"PrId" BIGINT,
		"MapperId" BIGINT NOT NULL,
		"EinvSection" SMALLINT,
		"EwbSection" SMALLINT,
		"GstSection" SMALLINT,
		"AutoDraftSection" SMALLINT,
		"SupplyType" SMALLINT,
		"EinvReason" VARCHAR(500),
		"EwbReason" VARCHAR(500),
		"GstReason" VARCHAR(500),
		"AutoDraftReason" VARCHAR(500),
		"GstType" smallint
	);

	CREATE TEMP TABLE "TempPurchaseAutoDraftIds"
	(	
		"AutoDraftId" BIGINT,
		"MapperId" BIGINT NOT NULL,			
		"AutoDraftSection" SMALLINT,
		"GstSection" SMALLINT,
		"SupplyType" SMALLINT,
		"GstReason" VARCHAR(500),			
		"AutoDraftReason" VARCHAR(500),
		"EinvQrId" bigint
	);

	INSERT INTO "TempEinvoiceId"("EInvId","MapperId","EwbSection","GstSection","EwbReason","GstReason")
	SELECT 
		e."EInvId",
		e."Id",
		e."EwbSection",
		e."GstSection",
		e."Ewbeason",
		e."GstReason"
	FROM report."EinvoiceRecoMapper" e
	INNER JOIN "TempRecoMapperIds" Ids  ON e."EInvId" = Ids."EInvId" AND e."MappingType" = "_MappingType"
	WHERE Ids."EInvId" IS NOT NULL;
	
	INSERT INTO "TempEwaybillId" ("EwbId","EInvId","GstType","MapperId","EinvSection","GstSection",
								 "SupplyType","GstReason","EinvReason")
	SELECT 
		e."EWBId",
		e."EInvId",
		e."GstType",
		e."Id",			
		e."EInvSection",
		e."GstSection",
		e."GstType",
		e."GstReason",		
		e."EInvReason"
	FROM report."EwaybillRecoMapper" e		
	INNER JOIN "TempRecoMapperIds" Ids  ON e."EWBId" = Ids."EwbId" AND e."MappingType" = "_MappingType"														 
	WHERE ids."EwbId" IS NOT NULL ;
	
	DROP TABLE IF EXISTS "TempEinvoiceQrCodeMapper";
	CREATE TEMP TABLE "TempEinvoiceQrCodeMapper" AS
	SELECT
		e."Id" AS "MapperId",
		e."EinvQrId",
		e."AutoDraftId",
		e."AutoDraftSection",
		e."AutoDraftReason"
	FROM
		report."EinvoiceQrCodeRecoMapper" AS e
		INNER JOIN "TempRecoMapperIds" AS Ids  ON e."EinvQrId" = Ids."EinvQrId" AND e."MappingType" = "_MappingType"														 
	WHERE
		ids."EinvQrId" IS NOT NULL;
	

	CREATE TEMP TABLE "TempGstId" AS
	SELECT		
		erm."Id"::bigint "MapperId"	
		,erm."GstId"::bigint
		,erm."GstType"::smallint
		,erm."EwbReason" 
		,erm."EInvReason"  
		,erm."AutoDraftReason"  
		,erm."EWBSection"::smallint 
		,erm."EInvSection"::smallint
		,erm."AutoDraftSection"::smallint
		,erm."EInvId"::bigint
		,erm."EWBId"::bigint
		,erm."AutoDraftId"::bigint "SaleAutoDraftId"
	FROM 
		"TempRecoMapperIds" ids
		INNER JOIN report."GstRecoMapper" erm ON ids."SaleId" = erm."GstId" AND "GstType" = "_SupplyTypeSale" AND erm."MappingType" = "_MappingType"
		WHERE ids."SaleId" IS NOT NULL;

	INSERT INTO "TempGstId"
	SELECT
		 erm."Id" "MapperId"	
		,erm."GstId"
		,erm."GstType"
		,erm."EwbReason" 
		,erm."EInvReason"  
		,erm."AutoDraftReason"  
		,erm."EWBSection" 
		,erm."EInvSection"
		,erm."AutoDraftSection"
		,erm."EInvId"
		,erm."EWBId"
		,erm."AutoDraftId" "SaleAutoDraftId"
	FROM 
		"TempRecoMapperIds" ids
		INNER JOIN report."GstRecoMapper" erm ON ids."PurchaseId" = erm."GstId" AND "GstType" = "_SupplyTypePurchase" AND erm."MappingType" = "_MappingType"
		WHERE ids."PurchaseId" IS NOT NULL;

	DROP TABLE IF EXISTS "TempEinvoiceDocumentItems";
	CREATE TEMP TABLE "TempEinvoiceDocumentItems"  AS
	SELECT
		di."Id" AS "DocumentItemId",
		Ids."MapperId"
	FROM "TempEinvoiceId" Ids	
	INNER JOIN  einvoice."DocumentItems" di ON di."DocumentId" = ids."EInvId"; 

	DROP TABLE IF EXISTS "TempEinvDetail";
	CREATE TEMP TABLE "TempEinvDetail" AS
	SELECT 
		edi."DocumentId",
		Ids."MapperId" AS "MapperId",
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
		NULL::smallint AS "ItemTotal"
	FROM
		"TempEinvoiceDocumentItems" Ids	
		INNER JOIN  einvoice."DocumentItems" edi ON edi."Id" = Ids."DocumentItemId"	
	;

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
		"TempEinvoiceId" ei
	INNER JOIN einvoice."DocumentContacts" dc on ei."EInvId" = dc."DocumentId"
	WHERE dc."Type" = "_ContactBillFromType";

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
		"TempEinvoiceId" ei
	INNER JOIN einvoice."DocumentContacts" dc on ei."EInvId" = dc."DocumentId"
	WHERE dc."Type" = "_ContactBillToType";

	DROP TABLE IF EXISTS "TempEinvData";
	CREATE TEMP TABLE "TempEinvData" AS
	SELECT 
		ed."EntityId",
		ed."Id",
		Ids."EInvId",
		Ids."MapperId",		
		ed."DocumentNumber",
		ed."DocumentDate",
		ed."DocumentFinancialYear" AS "DocFinancialYear",
		ed."DocumentValue",
		ed."Pos",
		ed."Type" AS "DocumentType",
		ed."TransactionType",
		ds."PushStatus",
		Ids."EwbSection",
		Ids."GstSection",
		Ids."EinvSection",
		Ids."EinvReason",
		Ids."EwbReason",
		Ids."GstReason",
		NULL::boolean "IsAmendment",
		
		eds."BillFromGstin",
		eds."BillFromTradeName",
		eds."BillFromLegalName",
		eds."BillFromAddress1",
		eds."BillFromAddress2",
		eds."BillFromCity",
		eds."BillFromStateCode",
		eds."BillFromPin",
		edct."BillToGstin",
		edct."BillToTradeName",
		edct."BillToLegalName",
		edct."BillToAddress1",
		edct."BillToAddress2",
		edct."BillToCity",
		edct."BillToStateCode",
		edct."BillToPin",
		
		dc."Custom1",
		dc."Custom2",
		dc."Custom3",
		dc."Custom4",
		dc."Custom5",
		dc."Custom6",
		dc."Custom7",
		dc."Custom8",
		dc."Custom9",
		dc."Custom10",
		
		edi."HsnOrSacCode",
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
		NULL::smallint AS "ItemTotal",
		
		ed."TotalTaxableValue",
		ed."TotalTaxAmount",
		ed."ReverseCharge",
		ds."RecoHubRemarks",		
		ds."Irn"
	FROM 
		"TempEinvoiceId" Ids	
		INNER JOIN einvoice."Documents" ed ON ed."Id" = Ids."EInvId"
		INNER JOIN einvoice."DocumentStatus" ds  ON ed."Id" = ds."DocumentId"
		LEFT JOIN einvoice."DocumentCustoms" AS dc ON ed."Id" = dc."DocumentId"
		LEFT JOIN "TempEinvoiceBillFromContacts" eds ON ed."Id" = eds."DocumentId" 
		LEFT JOIN "TempEinvoiceBillToContacts" edct ON ed."Id" = edct."DocumentId"
		LEFT JOIN "TempEinvDetail" AS edi ON edi."DocumentId" = Ids."EInvId"
	;

	DROP TABLE IF EXISTS "TempEWayBillDocumentItems";
	CREATE TEMP TABLE "TempEWayBillDocumentItems" AS
	SELECT
		di."Id" AS "DocumentItemId",
		Ids."MapperId"
	FROM
		"TempEwaybillId" Ids	
	INNER JOIN  einvoice."DocumentItems" di  ON di."DocumentId" = Ids."EwbId";	

	DROP TABLE IF EXISTS "TempEwbDetail";
	CREATE TEMP TABLE "TempEwbDetail" AS
	SELECT 
		edi."DocumentId",
		Ids."MapperId" AS "MapperId",
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
		NULL::smallint AS "ItemTotal"
	FROM
		"TempEWayBillDocumentItems" Ids	
	INNER JOIN  einvoice."DocumentItems" edi ON edi."Id" = Ids."DocumentItemId";

	DROP TABLE IF EXISTS "TempEwaybillBillFrom";
	CREATE TEMP TABLE "TempEwaybillBillFrom" AS
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
		"TempEwaybillId" AS ed
		INNER JOIN einvoice."DocumentContacts" dc on ed."EwbId" = dc."DocumentId"
	WHERE dc."Type" = "_ContactBillFromType";
	CREATE INDEX "Idx_TempEwaybillBillFrom_DocumentId" ON "TempEwaybillBillFrom"("DocumentId");

	DROP TABLE IF EXISTS "TempEwaybillBillTo";
	CREATE TEMP TABLE "TempEwaybillBillTo" AS
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
		"TempEwaybillId" AS ed
		INNER JOIN einvoice."DocumentContacts" dc on ed."EwbId" = dc."DocumentId"
	WHERE
		dc."Type" = "_ContactBillToType";
	CREATE INDEX "Idx_TempEwaybillBillTo_DocumentId" ON "TempEwaybillBillTo"("DocumentId");

	DROP TABLE IF EXISTS "TempEwaybillData";
	CREATE TEMP TABLE "TempEwaybillData" AS
	SELECT 
		ed."EntityId",
		ed."Id",
		Ids."MapperId",
		Ids."GstType" AS "SupplyType",		
		ed."DocumentNumber",
		ed."DocumentDate",
		ed."DocumentFinancialYear" AS "DocFinancialYear",
		ed."Type" AS "DocumentType",
		ed."TransactionType",
		--CASE WHEN ed."SupplyType" = "_SupplyTypeSale" THEN edct."Gstin" ELSE eds."Gstin" END "Gstin",
		ed."DocumentValue",
		ed."Pos",
		ds."PushStatus",
		Ids."EinvSection",
		Ids."GstSection",
		Ids."EwbSection",
		Ids."EwbReason",
		Ids."EinvReason",
		Ids."GstReason",
		ds."EwayBillNumber" "EwbNumber",
		ds."ValidUpto",
		CAST(CASE WHEN ds."ValidUpto" IS NULL AND ds."EwayBillNumber" IS NOT NULL THEN 0  WHEN ds."ValidUpto" IS NOT NULL AND ds."EwayBillNumber" IS NOT NULL THEN 1  END AS SMALLINT) AS "PartBStatus",		
		NULL::boolean "IsAmendment",
		Ids."EwbId" AS "EWBId",
		Ids."EInvId",
		
		eds."BillFromGstin",
		eds."BillFromTradeName",
		eds."BillFromLegalName",
		eds."BillFromAddress1",
		eds."BillFromAddress2",
		eds."BillFromCity",
		eds."BillFromStateCode",
		eds."BillFromPin",
		edct."BillToGstin",
		edct."BillToTradeName",
		edct."BillToLegalName",
		edct."BillToAddress1",
		edct."BillToAddress2",
		edct."BillToCity",
		edct."BillToStateCode",
		edct."BillToPin",
		
		dc."Custom1",
		dc."Custom2",
		dc."Custom3",
		dc."Custom4",
		dc."Custom5",
		dc."Custom6",
		dc."Custom7",
		dc."Custom8",
		dc."Custom9",
		dc."Custom10",
		
		edi."HsnOrSacCode",
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
		NULL::smallint AS "ItemTotal",
		
		ed."TotalTaxableValue",
		ed."TotalTaxAmount",	
		ed."ReverseCharge",
		ds."RecoHubRemarks",
		ds."Irn"
	FROM
		"TempEwaybillId" Ids	
		INNER JOIN einvoice."Documents" ed ON ed."Id" = Ids."EwbId"
		INNER JOIN ewaybill."DocumentStatus" ds ON ed."Id" = ds."DocumentId"		
		LEFT JOIN einvoice."DocumentCustoms" AS dc ON ed."Id" = dc."DocumentId"
		LEFT JOIN "TempEwaybillBillFrom" eds ON ed."Id" = eds."DocumentId" 
		LEFT JOIN "TempEwaybillBillTo" edct ON ed."Id" = edct."DocumentId"
		LEFT JOIN "TempEwbDetail" AS edi ON edi."DocumentId" = Ids."EInvId"
	;

	DROP TABLE IF EXISTS "TempOregularDocumentItems";
	CREATE TEMP TABLE "TempOregularDocumentItems" AS
	SELECT
		Ids."GstType",
		Ids."GstId",
		Ids."MapperId",
		sd."Id" AS "DocumentItemId"
	FROM
		"TempGstId" Ids	
	INNER JOIN oregular."SaleDocumentItems" sd ON Ids."GstId" = sd."SaleDocumentId" 
	WHERE Ids."GstType" = "_SupplyTypeSale";

	INSERT INTO "TempOregularDocumentItems"
	SELECT
		Ids."GstType",
		Ids."GstId",
		Ids."MapperId",
		pd."Id" AS "DocumentItemId"	
	FROM
		"TempGstId" Ids	
	INNER JOIN oregular."PurchaseDocumentItems" pd ON Ids."GstId" = pd."PurchaseDocumentId" 
	WHERE Ids."GstType" = "_SupplyTypePurchase";

	DROP TABLE IF EXISTS "TempGstDetail";
	CREATE TEMP TABLE "TempGstDetail" AS
	SELECT
		ids."MapperId" AS "MapperId",
		COALESCE(sd."SaleDocumentId",pd."PurchaseDocumentId") AS "DocumentId",
		COALESCE(sd."Hsn", pd."Hsn") AS "HsnOrSacCode",
		COALESCE(sd."Name", pd."Name") AS "Name",
		COALESCE(sd."Description", pd."Description") AS "Description",
		COALESCE(sd."Uqc", pd."Uqc") AS "Uqc",
		COALESCE(sd."Quantity", pd."Quantity") AS "Quantity",
		COALESCE(sd."PricePerQuantity", pd."PricePerQuantity") AS "PricePerQuantity",
		COALESCE(sd."Rate", pd."Rate") AS "Rate",
		COALESCE(sd."CessRate", pd."CessRate") AS "CessRate",
		COALESCE(sd."StateCessRate", pd."StateCessRate") AS "StateCessRate",
		COALESCE(sd."CessNonAdvaloremRate", pd."CessNonAdvaloremRate") AS "CessNonAdvaloremRate",
		pd."TdsRate" AS "TdsRate",
		COALESCE(sd."GrossAmount", pd."GrossAmount") AS "GrossAmount",
		COALESCE(sd."OtherCharges", pd."OtherCharges") AS "OtherCharges",
		COALESCE(sd."TaxableValue", pd."TaxableValue") AS "TaxableValue",
		COALESCE(sd."IgstAmount", pd."IgstAmount") AS "IgstAmount",
		COALESCE(sd."CgstAmount", pd."CgstAmount") AS "CgstAmount",
		COALESCE(sd."SgstAmount", pd."SgstAmount") AS "SgstAmount",
		COALESCE(sd."CessAmount", pd."CessAmount") AS "CessAmount",
		COALESCE(sd."StateCessAmount", pd."StateCessAmount") AS "StateCessAmount",
		COALESCE(sd."CessNonAdvaloremAmount", pd."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
		COALESCE(sd."StateCessNonAdvaloremAmount", pd."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
		pd."TdsAmount" AS "TdsAmount",
		NULL::smallint AS "ItemTotal"
	FROM
		"TempOregularDocumentItems" ids	
		LEFT JOIN oregular."SaleDocumentItems" sd ON sd."Id" = ids."DocumentItemId" AND ids."GstType" = "_SupplyTypeSale"	
		LEFT JOIN oregular."PurchaseDocumentItems" pd ON pd."Id" = ids."DocumentItemId" AND ids."GstType" = "_SupplyTypePurchase"
	;

	DROP TABLE IF EXISTS "TempGstData";
	CREATE TEMP TABLE "TempGstData" AS
	SELECT
		COALESCE(sdh."Id", pdh."Id") AS "Id",
		COALESCE(sdh."EntityId",pdh."EntityId") AS "EntityId",
		ids."MapperId",		
		ids."GstType" "SupplyType",		
		COALESCE(sdh."DocumentNumber",pdh."DocumentNumber") "DocumentNumber",
		TO_CHAR(COALESCE(sdh."DocumentDate"::CHARACTER VARYING ,pdh."DocumentDate"::CHARACTER VARYING)::TIMESTAMP WITHOUT TIME ZONE, 'YYYY-MM-DD')::TIMESTAMP WITHOUT TIME ZONE AS "DocumentDate",
		COALESCE(sdh."DocumentFinancialYear",sdh."DocumentFinancialYear") AS "DocFinancialYear", 		
		COALESCE(sdc."Gstin" ,pdc."Gstin") "Gstin",
		COALESCE(sdh."DocumentValue",pdh."DocumentValue") "DocumentValue",
		COALESCE(sdh."Pos",pdh."Pos") "Pos",
		COALESCE(sds."PushStatus",pds."PushStatus") "PushStatus",
		COALESCE(sdh."IsAmendment",pdh."IsAmendment") "IsAmendment",
		COALESCE(sdh."DocumentType",pdh."DocumentType") "DocumentType",
		COALESCE(sdh."TransactionType",pdh."TransactionType") "TransactionType",
		ids."EWBSection" "EwbSection",
		ids."EInvSection" "EinvSection",
		ids."AutoDraftSection",
		ids."EwbReason"::character varying,
		ids."EInvReason"::character varying "EinvReason", 
		ids."AutoDraftReason"::character varying,
		COALESCE(sdh."Irn",pdh."Irn") "Irn",
		COALESCE(sdc."TradeName",pdc."TradeName") "GstTradeName",
		COALESCE(sdc."LegalName",pdc."LegalName") "GstLegalName",
		COALESCE(sdh."TaxpayerType",pdh."TaxpayerType") "GstinTaxpayerType",
		COALESCE(sdct."Custom1",pdct."Custom1") "Custom1",
		COALESCE(sdct."Custom2",pdct."Custom2") "Custom2",
		COALESCE(sdct."Custom3",pdct."Custom3") "Custom3",
		COALESCE(sdct."Custom4",pdct."Custom4") "Custom4",
		COALESCE(sdct."Custom5",pdct."Custom5") "Custom5",
		COALESCE(sdct."Custom6",pdct."Custom6") "Custom6",
		COALESCE(sdct."Custom7",pdct."Custom7") "Custom7",
		COALESCE(sdct."Custom8",pdct."Custom8") "Custom8",
		COALESCE(sdct."Custom9",pdct."Custom9") "Custom9",
		COALESCE(sdct."Custom10",pdct."Custom10") "Custom10",
		ids."EInvId",
		ids."EWBId",
		ids."SaleAutoDraftId" "AutoDraftId",
		NULL "PurchaseAutoDraftId",
		
		sdc."Gstin" AS "BillToGstin",
		sdc."TradeName" AS "BillToTradeName",
		sdc."LegalName" AS "BillToLegalName",
		sdc."AddressLine1" AS "BillToAddress1",
		sdc."AddressLine2" AS "BillToAddress2",
		sdc."City" AS "BillToCity",
		sdc."StateCode" AS "BillToStateCode",
		sdc."Pincode" AS "BillToPin",
		
		pdc."Gstin" AS "BillFromGstin",
		pdc."TradeName" AS "BillFromTradeName",
		pdc."LegalName" AS "BillFromLegalName",
		pdc."AddressLine1" AS "BillFromAddress1",
		pdc."AddressLine2" AS "BillFromAddress2",
		pdc."City" AS "BillFromCity",
		pdc."StateCode" AS "BillFromStateCode",
		pdc."Pincode" AS "BillFromPin",
		
		tgd."HsnOrSacCode",
		tgd."Name",
		tgd."Description",
		tgd."Uqc",
		tgd."Quantity",
		tgd."PricePerQuantity",
		tgd."Rate",
		tgd."CessRate",
		tgd."StateCessRate",
		tgd."CessNonAdvaloremRate",
		tgd."TdsRate",
		tgd."GrossAmount",
		tgd."OtherCharges",
		tgd."TaxableValue",
		tgd."IgstAmount",
		tgd."CgstAmount",
		tgd."SgstAmount",
		tgd."CessAmount",
		tgd."StateCessAmount",
		tgd."CessNonAdvaloremAmount",
		tgd."StateCessNonAdvaloremAmount",
		tgd."TdsAmount",
		tgd."ItemTotal",
		
		COALESCE(sdh."TotalTaxableValue", pdh."TotalTaxableValue") AS "TotalTaxableValue",
		COALESCE(sdh."TotalTaxAmount", pdh."TotalTaxAmount") AS "TotalTaxAmount",
		COALESCE(sdh."ReverseCharge", pdh."ReverseCharge") AS "ReverseCharge",
		COALESCE(sds."RecoHubRemarks", pds."RecoHubRemarks") AS "RecoHubRemarks"
	FROM
		"TempGstId" ids	
		LEFT JOIN oregular."SaleDocuments" sdh ON sdh."Id" = ids."GstId" AND ids."GstType" = "_SupplyTypeSale"		
		LEFT JOIN oregular."SaleDocumentStatus" sds ON sdh."Id" = sds."SaleDocumentId" 	
		LEFT JOIN oregular."SaleDocumentContacts" sdc ON sdc."SaleDocumentId" = sdh."Id" and sdc."Type" = "_ContactBillToType"
		LEFT JOIN oregular."PurchaseDocuments" pdh ON pdh."Id" = ids."GstId" AND ids."GstType" = "_SupplyTypePurchase"			
		LEFT JOIN oregular."PurchaseDocumentStatus" pds ON pdh."Id" = pds."PurchaseDocumentId" 
		LEFT JOIN oregular."PurchaseDocumentContacts" pdc ON pdc."PurchaseDocumentId" = pdh."Id" and pdc."Type" = "_ContactBillFromType"	
		LEFT JOIN oregular."SaleDocumentCustoms" sdct ON sdct."SaleDocumentId" = sdh."Id" AND ids."GstType" = "_SupplyTypeSale"
		LEFT JOIN oregular."PurchaseDocumentCustoms" pdct ON Pdct."PurchaseDocumentId" = pdh."Id" AND ids."GstType" = "_SupplyTypePurchase"
		LEFT JOIN "TempGstDetail" AS tgd ON ids."MapperId" = tgd."MapperId";

	DROP TABLE IF EXISTS "TempOregularSaleDocumentItems";
	CREATE TEMP TABLE "TempOregularSaleDocumentItems" AS
	SELECT
		di."Id" AS "SaleDocumentItemId",
		ids."MapperId"
		FROM
		"TempAutoDraftId" ids	
	INNER JOIN oregular."SaleDocumentItems" di ON di."SaleDocumentId" = ids."AutoDraftId";

	DROP TABLE IF EXISTS "TempAutoDraftDetail";
	CREATE TEMP TABLE "TempAutoDraftDetail" AS
	SELECT 
		sdi."SaleDocumentId" AS "DocumentId",
		ids."MapperId" AS "MapperId",
		sdi."Hsn" AS "HsnOrSacCode",
		sdi."Name",
		sdi."Description",
		sdi."Uqc",
		sdi."Quantity",
		sdi."PricePerQuantity",
		sdi."Rate",
		sdi."CessRate",
		sdi."StateCessRate",
		sdi."CessNonAdvaloremRate",
		NULL::numeric AS "TdsRate",
		sdi."GrossAmount",
		sdi."OtherCharges",
		sdi."TaxableValue",
		sdi."IgstAmount",
		sdi."CgstAmount",
		sdi."SgstAmount",
		sdi."CessAmount",
		sdi."StateCessAmount",
		sdi."CessNonAdvaloremAmount",
		sdi."StateCessNonAdvaloremAmount",
		NULL::numeric AS "TdsAmount",
		NULL::smallint AS "ItemTotal"
	FROM
		"TempOregularSaleDocumentItems" ids	
		INNER JOIN oregular."SaleDocumentItems" AS sdi ON sdi."Id" = ids."SaleDocumentItemId"
	;

	DROP TABLE IF EXISTS "TempAutoDraftData";
	CREATE TEMP TABLE "TempAutoDraftData" AS
	SELECT 
		ed."EntityId",
		ed."Id",
		ids."AutoDraftId",
		ids."MapperId",
		ids."GstType",		
		ed."DocumentNumber",
		ed."DocumentDate",
		ed."DocumentFinancialYear" AS "DocFinancialYear",
		sdc."Gstin" AS "Gstin",
		ed."DocumentValue",
		ed."Pos",
		ds."PushStatus",
		ed."DocumentType" AS "DocumentType",
		ids."GstSection",
		ids."AutoDraftSection",
		ed."TransactionType",
		ed."IsAmendment" ,
		ids."GstReason",
		ids."AutoDraftReason",
		sdc."TradeName" "AutoDraftTradeName",
		sdc."LegalName" "AutoDraftLegalName",
		
		sdc."Gstin" AS "BillToGstin",
		sdc."TradeName" AS "BillToTradeName",
		sdc."LegalName" AS "BillToLegalName",
		sdc."AddressLine1" AS "BillToAddress1",
		sdc."AddressLine2" AS "BillToAddress2",
		sdc."City" AS "BillToCity",
		sdc."StateCode" AS "BillToStateCode",
		sdc."Pincode" AS "BillToPin",
		
		NULL AS "BillFromGstin",
		NULL AS "BillFromTradeName",
		NULL AS "BillFromLegalName",
		NULL AS "BillFromAddress1",
		NULL AS "BillFromAddress2",
		NULL AS "BillFromCity",
		NULL AS "BillFromStateCode",
		NULL AS "BillFromPin",
		
		sdct."Custom1",
		sdct."Custom2",
		sdct."Custom3",
		sdct."Custom4",
		sdct."Custom5",
		sdct."Custom6",
		sdct."Custom7",
		sdct."Custom8",
		sdct."Custom9",
		sdct."Custom10",
		
		sdi."HsnOrSacCode",
		sdi."Name",
		sdi."Description",
		sdi."Uqc",
		sdi."Quantity",
		sdi."PricePerQuantity",
		sdi."Rate",
		sdi."CessRate",
		sdi."StateCessRate",
		sdi."CessNonAdvaloremRate",
		NULL::numeric AS "TdsRate",
		sdi."GrossAmount",
		sdi."OtherCharges",
		sdi."TaxableValue",
		sdi."IgstAmount",
		sdi."CgstAmount",
		sdi."SgstAmount",
		sdi."CessAmount",
		sdi."StateCessAmount",
		sdi."CessNonAdvaloremAmount",
		sdi."StateCessNonAdvaloremAmount",
		NULL::numeric AS "TdsAmount",
		NULL::smallint AS "ItemTotal",
		
		ed."TotalTaxableValue",
		ed."TotalTaxAmount",
		ed."ReverseCharge",
		ds."RecoHubRemarks",
		ed."Irn"
	FROM 
		"TempAutoDraftId" ids	
		INNER JOIN oregular."SaleDocuments" ed ON ed."Id" = ids."AutoDraftId"
		INNER JOIN oregular."SaleDocumentStatus" ds ON ed."Id" = ds."SaleDocumentId"
		LEFT JOIN "TempAutoDraftDetail" AS sdi ON sdi."DocumentId" = ids."AutoDraftId"
		LEFT JOIN oregular."SaleDocumentContacts" sdc ON sdc."SaleDocumentId" = ed."Id" AND sdc."Type" = "_ContactBillToType"
		LEFT JOIN oregular."SaleDocumentCustoms" sdct ON sdct."SaleDocumentId" = ed."Id"
	;		
		
	DROP TABLE IF EXISTS "TempPurchaseDocumentItemIds";
	CREATE TEMP TABLE "TempPurchaseDocumentItemIds" AS
	SELECT
		pdi."Id" AS "PurchaseDocumentItemId"						  
	FROM
		"TempPrIds" ids	
	INNER JOIN oregular."PurchaseDocumentItems" pdi ON pdi."PurchaseDocumentId" = ids."PrId";
											

	DROP TABLE IF EXISTS "TempPurchaseDocumentItemDetails";
	CREATE TEMP TABLE "TempPurchaseDocumentItemDetails" AS
	SELECT 
		pdi."PurchaseDocumentId",
		pdi."Hsn" AS "HsnOrSacCode",
		pdi."Name",
		pdi."Description",
		pdi."Uqc",
		pdi."Quantity",
		pdi."PricePerQuantity",
		pdi."Rate",
		pdi."CessRate",
		pdi."StateCessRate",
		pdi."CessNonAdvaloremRate",
		pdi."TdsRate",
		pdi."GrossAmount",
		pdi."OtherCharges",
		pdi."TaxableValue",
		pdi."IgstAmount",
		pdi."CgstAmount",
		pdi."SgstAmount",
		pdi."CessAmount",
		pdi."StateCessAmount",
		pdi."CessNonAdvaloremAmount",
		pdi."StateCessNonAdvaloremAmount",
		pdi."TdsAmount",
		NULL::smallint AS "ItemTotal"
	FROM
		oregular."PurchaseDocumentItems" AS pdi
	WHERE
		pdi."Id" IN(SELECT "PurchaseDocumentItemId" FROM "TempPurchaseDocumentItemIds")
	;
	
	DROP TABLE IF EXISTS "TempPurchaseGstData";
	CREATE TEMP TABLE "TempPurchaseGstData" AS
	SELECT 
		sdh."EntityId" AS "EntityId",
		pdi."PurchaseDocumentId" AS "Id",
		ids."MapperId",
		ids."GstType",		
		sdh."DocumentNumber" AS "DocumentNumber",
		CAST(sdh."DocumentDate"::VARCHAR AS DATE) AS "DocumentDate",
		sdh."BillFromGstin" AS "Gstin",
		sdh."DocumentValue" AS "DocumentValue",
		sdh."Pos" AS "Pos",
		sds."PushStatus" AS "PushStatus",
		sdh."IsAmendment" AS "IsAmendment",
		sdh."DocumentType" AS "DocumentType",
		sdh."TransactionType" AS "TransactionType",
		ids."EwbSection",
		ids."EinvSection",
		ids."GstSection",
		ids."AutoDraftSection",
		ids."GstReason",
		ids."EwbReason",
		ids."EinvReason",
		ids."AutoDraftReason",
		sdh."BillFromTradeName" AS "GstTradeName",
		sdc."LegalName" AS "GstLegalName",
		
		NULL AS "BillToGstin",
		NULL AS "BillToTradeName",
		NULL AS "BillToLegalName",
		NULL AS "BillToAddress1",
		NULL AS "BillToAddress2",
		NULL AS "BillToCity",
		NULL AS "BillToStateCode",
		NULL AS "BillToPin",
		
		sdc."Gstin" AS "BillFromGstin",
		sdc."TradeName" AS "BillFromTradeName",
		sdc."LegalName" AS "BillFromLegalName",
		sdc."AddressLine1" AS "BillFromAddress1",
		sdc."AddressLine2" AS "BillFromAddress2",
		sdc."City" AS "BillFromCity",
		sdc."StateCode" AS "BillFromStateCode",
		sdc."Pincode" AS "BillFromPin",
		
		sdct."Custom1",
		sdct."Custom2",
		sdct."Custom3",
		sdct."Custom4",
		sdct."Custom5",
		sdct."Custom6",
		sdct."Custom7",
		sdct."Custom8",
		sdct."Custom9",
		sdct."Custom10",
		
		pdi."HsnOrSacCode",
		pdi."Name",
		pdi."Description",
		pdi."Uqc",
		pdi."Quantity",
		pdi."PricePerQuantity",
		pdi."Rate",
		pdi."CessRate",
		pdi."StateCessRate",
		pdi."CessNonAdvaloremRate",
		pdi."TdsRate",
		pdi."GrossAmount",
		pdi."OtherCharges",
		pdi."TaxableValue",
		pdi."IgstAmount",
		pdi."CgstAmount",
		pdi."SgstAmount",
		pdi."CessAmount",
		pdi."StateCessAmount",
		pdi."CessNonAdvaloremAmount",
		pdi."StateCessNonAdvaloremAmount",
		pdi."TdsAmount",
		NULL::smallint AS "ItemTotal",
		
		sdh."TotalTaxableValue",
		sdh."TotalTaxAmount",
		sdh."ReverseCharge",
		sds."RecoHubRemarks",
		pd."Irn"
	FROM
		"TempPrIds" ids
		LEFT JOIN oregular."PurchaseDocumentDW" sdh ON sdh."Id" = ids."PrId"
		LEFT JOIN oregular."PurchaseDocuments" pd ON pd."Id" = ids."PrId"
		LEFT JOIN oregular."PurchaseDocumentStatus" sds ON sdh."Id" = sds."PurchaseDocumentId" 	
		LEFT JOIN oregular."PurchaseDocumentContacts" sdc ON sdc."PurchaseDocumentId" = sdh."Id" and sdc."Type" = "_ContactBillFromType"
		LEFT JOIN "TempPurchaseDocumentItemDetails" pdi ON ids."PrId" = pdi."PurchaseDocumentId"
		LEFT JOIN oregular."PurchaseDocumentCustoms" sdct ON sdct."PurchaseDocumentId" = sdh."Id";
	
	DROP TABLE IF EXISTS "TempOregularPurchaseDocumentItems";

	CREATE TEMP TABLE "TempOregularPurchaseDocumentItems" AS
	SELECT
		di."Id" AS "PurchaseDocumentItemId",
		ids."MapperId"
	FROM
		"TempPurchaseAutoDraftIds" ids	
	INNER JOIN oregular."PurchaseDocumentItems" di ON di."PurchaseDocumentId" = ids."AutoDraftId";
	
	DROP TABLE IF EXISTS "TempPurchaseAutoDraftDetail";
	CREATE TEMP TABLE "TempPurchaseAutoDraftDetail" AS
	SELECT 
		pdi."PurchaseDocumentId",
		pdi."Hsn" AS "HsnOrSacCode",
		pdi."Name",
		pdi."Description",
		pdi."Uqc",
		pdi."Quantity",
		pdi."PricePerQuantity",
		pdi."Rate",
		pdi."CessRate",
		pdi."StateCessRate",
		pdi."CessNonAdvaloremRate",
		pdi."TdsRate",
		pdi."GrossAmount",
		pdi."OtherCharges",
		pdi."TaxableValue",
		pdi."IgstAmount",
		pdi."CgstAmount",
		pdi."SgstAmount",
		pdi."CessAmount",
		pdi."StateCessAmount",
		pdi."CessNonAdvaloremAmount",
		pdi."StateCessNonAdvaloremAmount",
		pdi."TdsAmount",
		NULL::smallint AS "ItemTotal"
	FROM
		"TempOregularPurchaseDocumentItems" ids	
		INNER JOIN oregular."PurchaseDocumentItems" pdi ON pdi."Id" = ids."PurchaseDocumentItemId"
	;

	DROP TABLE IF EXISTS "TempPurchaseAutoDraftData";
	CREATE TEMP TABLE "TempPurchaseAutoDraftData" AS
	SELECT 
		ed."EntityId",
		ed."Id" "AutoDraftId",
		ids."MapperId",
		ids."SupplyType",		
		ed."DocumentNumber",
		ed."DocumentDate",
		ed."DocumentFinancialYear" AS "DocFinancialYear",
		sdc."Gstin",
		ed."DocumentValue",
		ed."Pos",
		ds."PushStatus",
		ed."DocumentType" AS "DocumentType",
		NULL "EinvSection",
		ids."GstSection",
		NULL "EwbSection",
		ids."AutoDraftSection",
		ed."TransactionType",
		ed."IsAmendment",
		ids."GstReason",
		ids."AutoDraftReason",
		sdc."TradeName" "AutoDraftTradeName",
		sdc."LegalName" "AutoDraftLegalName",
		ed."Irn",

		NULL AS "BillToGstin",
		NULL AS "BillToTradeName",
		NULL AS "BillToLegalName",
		NULL AS "BillToAddress1",
		NULL AS "BillToAddress2",
		NULL AS "BillToCity",
		NULL AS "BillToStateCode",
		NULL AS "BillToPin",
		
		sdc."Gstin" AS "BillFromGstin",
		sdc."TradeName" AS "BillFromTradeName",
		sdc."LegalName" AS "BillFromLegalName",
		sdc."AddressLine1" AS "BillFromAddress1",
		sdc."AddressLine2" AS "BillFromAddress2",
		sdc."City" AS "BillFromCity",
		sdc."StateCode" AS "BillFromStateCode",
		sdc."Pincode" AS "BillFromPin",
		
		sdct."Custom1",
		sdct."Custom2",
		sdct."Custom3",
		sdct."Custom4",
		sdct."Custom5",
		sdct."Custom6",
		sdct."Custom7",
		sdct."Custom8",
		sdct."Custom9",
		sdct."Custom10",
		
		pdi."HsnOrSacCode",
		pdi."Name",
		pdi."Description",
		pdi."Uqc",
		pdi."Quantity",
		pdi."PricePerQuantity",
		pdi."Rate",
		pdi."CessRate",
		pdi."StateCessRate",
		pdi."CessNonAdvaloremRate",
		pdi."TdsRate",
		pdi."GrossAmount",
		pdi."OtherCharges",
		pdi."TaxableValue",
		pdi."IgstAmount",
		pdi."CgstAmount",
		pdi."SgstAmount",
		pdi."CessAmount",
		pdi."StateCessAmount",
		pdi."CessNonAdvaloremAmount",
		pdi."StateCessNonAdvaloremAmount",
		pdi."TdsAmount",
		NULL::smallint AS "ItemTotal",
		ed."TotalTaxableValue",
		ed."TotalTaxAmount",
		ed."ReverseCharge",
		ds."RecoHubRemarks",
		ids."EinvQrId"
	FROM
		"TempPurchaseAutoDraftIds" ids	
		INNER JOIN oregular."PurchaseDocuments" ed ON ed."Id" = ids."AutoDraftId"
		INNER JOIN oregular."PurchaseDocumentStatus" ds ON ed."Id" = ds."PurchaseDocumentId"
		LEFT JOIN oregular."PurchaseDocumentContacts" sdc ON sdc."PurchaseDocumentId" = ed."Id" AND sdc."Type" = "_ContactBillFromType"
		INNER JOIN "TempPurchaseAutoDraftDetail" AS pdi ON pdi."PurchaseDocumentId" = ids."AutoDraftId"
		LEFT JOIN oregular."PurchaseDocumentCustoms" sdct ON sdct."PurchaseDocumentId" = ed."Id";

	DROP TABLE IF EXISTS "TempEinvoiceQrCodeData";
	CREATE TEMP TABLE "TempEinvoiceQrCodeData" AS
	SELECT 
		ed."EntityId",
		ids."AutoDraftId",
		ids."EinvQrId",
		ids."MapperId",
		NULL::smallint AS "SupplyType",		
		ed."DocumentNumber",
		ed."DocumentDate",
		ed."FinancialYear" AS "DocFinancialYear",
		ed."Gstin",
		ed."DocumentValue",
		NULL::smallint AS "Pos",
		NULL::smallint AS "PushStatus",
		ed."DocumentType" AS "DocumentType",
		NULL::smallint AS "EinvSection",
		NULL::smallint AS "GstSection",
		NULL::smallint "EwbSection",
		ids."AutoDraftSection",
		NULL::smallint AS "TransactionType",
		NULL::boolean AS "IsAmendment",
		NULL::Character Varying AS "GstReason",
		ids."AutoDraftReason",
		NULL::Character Varying "AutoDraftTradeName",
		NULL::Character Varying "AutoDraftLegalName",
		ed."Irn",

		NULL AS "BillToGstin",
		NULL AS "BillToTradeName",
		NULL AS "BillToLegalName",
		NULL AS "BillToAddress1",
		NULL AS "BillToAddress2",
		NULL AS "BillToCity",
		NULL AS "BillToStateCode",
		NULL AS "BillToPin",
		
		ed."Gstin" AS "BillFromGstin",
		ed."TradeName" AS "BillFromTradeName",
		NULL AS "BillFromLegalName",
		NULL AS "BillFromAddress1",
		NULL AS "BillFromAddress2",
		NULL AS "BillFromCity",
		NULL AS "BillFromStateCode",
		NULL AS "BillFromPin",
		
		NULL AS "Custom1",
		NULL AS "Custom2",
		NULL AS "Custom3",
		NULL AS "Custom4",
		NULL AS "Custom5",
		NULL AS "Custom6",
		NULL AS "Custom7",
		NULL AS "Custom8",
		NULL AS "Custom9",
		NULL AS "Custom10",
		
		NULL AS "HsnOrSacCode",
		NULL AS "Name",
		NULL AS "Description",
		NULL AS "Uqc",
		NULL AS "Quantity",
		NULL AS "PricePerQuantity",
		NULL AS "Rate",
		NULL AS "CessRate",
		NULL AS "StateCessRate",
		NULL AS "CessNonAdvaloremRate",
		NULL AS "TdsRate",
		NULL AS "GrossAmount",
		NULL AS "OtherCharges",
		NULL AS "TaxableValue",
		NULL AS "IgstAmount",
		NULL AS "CgstAmount",
		NULL AS "SgstAmount",
		NULL AS "CessAmount",
		NULL AS "StateCessAmount",
		NULL AS "CessNonAdvaloremAmount",
		NULL AS "StateCessNonAdvaloremAmount",
		NULL AS "TdsAmount",
		ed."NoOfItems"::smallint AS "ItemTotal",
		NULL AS "TotalTaxableValue",
		NULL AS "TotalTaxAmount",
		NULL AS "ReverseCharge",
		ed."RecoHubRemarks"
	FROM
		"TempEinvoiceQrCodeMapper" ids	
		INNER JOIN einvoice."QrCodeDetails" ed ON ed."Id" = ids."EinvQrId"
	;
		
	/*To Aggegrate data at header level */
	IF ("_IncludeAggregatedItems" = True)
	THEN
		DROP TABLE IF EXISTS "TempEinvDataHeader";
		CREATE TEMP TABLE "TempEinvDataHeader" AS			
		SELECT			
			ed."Id",			
			ed."MapperId",
			MAX(ed."DocFinancialYear")  AS "DocFinancialYear",
			MAX(ed."EntityId") AS "EntityId",
			MAX(ed."EInvId") AS "EInvId",
			MAX(ed."DocumentNumber") AS "DocumentNumber",
			MAX(ed."DocumentDate") AS "DocumentDate",
			MAX(ed."DocumentValue") AS "DocumentValue",
			MAX(ed."Pos") AS "Pos",
			MAX(ed."DocumentType") AS "DocumentType",
			MAX(ed."TransactionType") AS "TransactionType",
			MAX(ed."PushStatus") AS "PushStatus",
			MAX(ed."EwbSection") AS "EwbSection",
			MAX(ed."GstSection") AS "GstSection",
			MAX(ed."EinvSection") AS "EinvSection",
			MAX(ed."EinvReason") AS "EinvReason",
			MAX(ed."EwbReason") AS "EwbReason",
			MAX(ed."GstReason") AS "GstReason",
			MAX(ed."IsAmendment"::int)::boolean AS "IsAmendment",

			MAX(ed."BillFromGstin") AS "BillFromGstin",
			MAX(ed."BillFromTradeName") AS "BillFromTradeName",
			MAX(ed."BillFromLegalName") AS "BillFromLegalName",
			MAX(ed."BillFromAddress1") AS "BillFromAddress1",
			MAX(ed."BillFromAddress2") AS "BillFromAddress2",
			MAX(ed."BillFromCity") AS "BillFromCity",
			MAX(ed."BillFromStateCode") AS "BillFromStateCode",
			MAX(ed."BillFromPin") AS "BillFromPin",
			MAX(ed."BillToGstin") AS "BillToGstin",
			MAX(ed."BillToTradeName") AS "BillToTradeName",
			MAX(ed."BillToLegalName") AS "BillToLegalName",
			MAX(ed."BillToAddress1") AS "BillToAddress1",
			MAX(ed."BillToAddress2") AS "BillToAddress2",
			MAX(ed."BillToCity") AS "BillToCity",
			MAX(ed."BillToStateCode") AS "BillToStateCode",
			MAX(ed."BillToPin") AS "BillToPin",

			MAX(ed."Custom1") AS "Custom1",
			MAX(ed."Custom2") AS "Custom2",
			MAX(ed."Custom3") AS "Custom3",
			MAX(ed."Custom4") AS "Custom4",
			MAX(ed."Custom5") AS "Custom5",
			MAX(ed."Custom6") AS "Custom6",
			MAX(ed."Custom7") AS "Custom7",
			MAX(ed."Custom8") AS "Custom8",
			MAX(ed."Custom9") AS "Custom9",
			MAX(ed."Custom10") AS "Custom10",
			
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
			SUM(ed."GrossAmount") AS "GrossAmount",
			SUM(ed."OtherCharges") AS "OtherCharges",
			SUM(ed."TaxableValue") AS "TaxableValue",
			SUM(ed."IgstAmount") AS "IgstAmount",
			SUM(ed."CgstAmount") AS "CgstAmount",
			SUM(ed."SgstAmount") AS "SgstAmount",
			SUM(ed."CessAmount") AS "CessAmount",
			SUM(ed."StateCessAmount") AS "StateCessAmount",
			SUM(ed."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(ed."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			SUM(ed."TdsAmount") AS "TdsAmount",
			SUM(ed."ItemTotal") AS "ItemTotal",

			MAX(ed."TotalTaxableValue") AS "TotalTaxableValue",
			MAX(ed."TotalTaxAmount") AS "TotalTaxAmount",
			MAX(ed."ReverseCharge"::int)::boolean AS "ReverseCharge",
			MAX(ed."RecoHubRemarks") AS "RecoHubRemarks",
			MAX(ed."Irn") AS "Irn"
		FROM
			"TempEinvData" AS ed			
		GROUP BY ed."Id", ed."MapperId";

		DROP TABLE IF EXISTS "TempEwayBillDataHeader";
		CREATE TEMP TABLE "TempEwayBillDataHeader" AS
		SELECT
			ed."Id",
			ed."MapperId",
			MAX(ed."EntityId") AS "EntityId",
			MAX(ed."SupplyType") AS "SupplyType",		
			MAX(ed."DocumentNumber") AS "DocumentNumber",
			MAX(ed."DocumentDate") AS "DocumentDate",
			MAX(ed."DocFinancialYear") AS "DocFinancialYear",
			MAX(ed."DocumentType") AS "DocumentType",
			MAX(ed."TransactionType") AS "TransactionType",
			MAX(ed."DocumentValue") AS "DocumentValue",
			MAX(ed."Pos") AS "Pos",
			MAX(ed."PushStatus") AS "PushStatus",
			MAX(ed."EinvSection") AS "EinvSection",
			MAX(ed."GstSection") AS "GstSection",
			MAX(ed."EwbSection") AS "EwbSection",
			MAX(ed."EwbReason") AS "EwbReason",
			MAX(ed."EinvReason") AS "EinvReason",
			MAX(ed."GstReason") AS "GstReason",
			MAX(ed."EwbNumber") AS "EwbNumber",
			MAX(ed."ValidUpto") AS "ValidUpto",
			MAX(ed."PartBStatus") AS "PartBStatus",
			MAX(ed."IsAmendment"::int)::boolean AS "IsAmendment",
			MAX(ed."EWBId") AS "EWBId",
			MAX(ed."EInvId") AS "EInvId",
		
			MAX(ed."BillFromGstin") AS "BillFromGstin",
			MAX(ed."BillFromTradeName") AS "BillFromTradeName",
			MAX(ed."BillFromLegalName") AS "BillFromLegalName",
			MAX(ed."BillFromAddress1") AS "BillFromAddress1",
			MAX(ed."BillFromAddress2") AS "BillFromAddress2",
			MAX(ed."BillFromCity") AS "BillFromCity",
			MAX(ed."BillFromStateCode") AS "BillFromStateCode",
			MAX(ed."BillFromPin") AS "BillFromPin",
			MAX(ed."BillToGstin") AS "BillToGstin",
			MAX(ed."BillToTradeName") AS "BillToTradeName",
			MAX(ed."BillToLegalName") AS "BillToLegalName",
			MAX(ed."BillToAddress1") AS "BillToAddress1",
			MAX(ed."BillToAddress2") AS "BillToAddress2",
			MAX(ed."BillToCity") AS "BillToCity",
			MAX(ed."BillToStateCode") AS "BillToStateCode",
			MAX(ed."BillToPin") AS "BillToPin",

			MAX(ed."Custom1") AS "Custom1",
			MAX(ed."Custom2") AS "Custom2",
			MAX(ed."Custom3") AS "Custom3",
			MAX(ed."Custom4") AS "Custom4",
			MAX(ed."Custom5") AS "Custom5",
			MAX(ed."Custom6") AS "Custom6",
			MAX(ed."Custom7") AS "Custom7",
			MAX(ed."Custom8") AS "Custom8",
			MAX(ed."Custom9") AS "Custom9",
			MAX(ed."Custom10") AS "Custom10",
			
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
			SUM(ed."GrossAmount") AS "GrossAmount",
			SUM(ed."OtherCharges") AS "OtherCharges",
			SUM(ed."TaxableValue") AS "TaxableValue",
			SUM(ed."IgstAmount") AS "IgstAmount",
			SUM(ed."CgstAmount") AS "CgstAmount",
			SUM(ed."SgstAmount") AS "SgstAmount",
			SUM(ed."CessAmount") AS "CessAmount",
			SUM(ed."StateCessAmount") AS "StateCessAmount",
			SUM(ed."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(ed."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			SUM(ed."TdsAmount") AS "TdsAmount",
			SUM(ed."ItemTotal") AS "ItemTotal",

			MAX(ed."TotalTaxableValue") AS "TotalTaxableValue",
			MAX(ed."TotalTaxAmount") AS "TotalTaxAmount",
			MAX(ed."ReverseCharge"::int)::boolean AS "ReverseCharge",
			MAX(ed."RecoHubRemarks") AS "RecoHubRemarks",
			MAX(ed."Irn") AS "Irn"
		FROM
			"TempEwaybillData" AS ed			
		GROUP BY ed."Id", ed."MapperId";												

		DROP TABLE IF EXISTS "TempGstDataHeader";
		CREATE TEMP TABLE "TempGstDataHeader" AS
		SELECT
			ed."Id",
			ed."MapperId",
			MAX(ed."EntityId") AS "EntityId",
			MAX(ed."SupplyType") AS "SupplyType",		
			MAX(ed."DocumentNumber") AS "DocumentNumber",
			MAX(ed."DocumentDate") AS "DocumentDate",
			MAX(ed."DocFinancialYear") AS "DocFinancialYear", 		
			MAX(ed."Gstin") AS "Gstin",
			MAX(ed."DocumentValue") AS "DocumentValue",
			MAX(ed."Pos") AS "Pos",
			MAX(ed."PushStatus") AS "PushStatus",
			MAX(ed."IsAmendment"::int)::boolean AS "IsAmendment",
			MAX(ed."DocumentType") AS "DocumentType",
			MAX(ed."TransactionType") AS "TransactionType",
			MAX(ed."EwbSection") AS "EwbSection",
			MAX(ed."EinvSection") AS "EinvSection",
			MAX(ed."AutoDraftSection") AS "AutoDraftSection",
			MAX(ed."EwbReason") AS "EwbReason",
			MAX(ed."EinvReason") AS "EinvReason", 
			MAX(ed."AutoDraftReason") AS "AutoDraftReason",
			MAX(ed."Irn") AS "Irn",
			MAX(ed."GstTradeName") AS "GstTradeName",
			MAX(ed."GstLegalName") AS "GstLegalName",
			MAX(ed."GstinTaxpayerType") AS "GstinTaxpayerType",

			MAX(ed."EInvId") AS "EInvId",
			MAX(ed."EWBId") AS "EWBId",
			MAX(ed."AutoDraftId") AS "AutoDraftId",
			MAX(ed."PurchaseAutoDraftId") AS "PurchaseAutoDraftId",
		
			MAX(ed."BillFromGstin") AS "BillFromGstin",
			MAX(ed."BillFromTradeName") AS "BillFromTradeName",
			MAX(ed."BillFromLegalName") AS "BillFromLegalName",
			MAX(ed."BillFromAddress1") AS "BillFromAddress1",
			MAX(ed."BillFromAddress2") AS "BillFromAddress2",
			MAX(ed."BillFromCity") AS "BillFromCity",
			MAX(ed."BillFromStateCode") AS "BillFromStateCode",
			MAX(ed."BillFromPin") AS "BillFromPin",
			MAX(ed."BillToGstin") AS "BillToGstin",
			MAX(ed."BillToTradeName") AS "BillToTradeName",
			MAX(ed."BillToLegalName") AS "BillToLegalName",
			MAX(ed."BillToAddress1") AS "BillToAddress1",
			MAX(ed."BillToAddress2") AS "BillToAddress2",
			MAX(ed."BillToCity") AS "BillToCity",
			MAX(ed."BillToStateCode") AS "BillToStateCode",
			MAX(ed."BillToPin") AS "BillToPin",

			MAX(ed."Custom1") AS "Custom1",
			MAX(ed."Custom2") AS "Custom2",
			MAX(ed."Custom3") AS "Custom3",
			MAX(ed."Custom4") AS "Custom4",
			MAX(ed."Custom5") AS "Custom5",
			MAX(ed."Custom6") AS "Custom6",
			MAX(ed."Custom7") AS "Custom7",
			MAX(ed."Custom8") AS "Custom8",
			MAX(ed."Custom9") AS "Custom9",
			MAX(ed."Custom10") AS "Custom10",
			
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
			SUM(ed."GrossAmount") AS "GrossAmount",
			SUM(ed."OtherCharges") AS "OtherCharges",
			SUM(ed."TaxableValue") AS "TaxableValue",
			SUM(ed."IgstAmount") AS "IgstAmount",
			SUM(ed."CgstAmount") AS "CgstAmount",
			SUM(ed."SgstAmount") AS "SgstAmount",
			SUM(ed."CessAmount") AS "CessAmount",
			SUM(ed."StateCessAmount") AS "StateCessAmount",
			SUM(ed."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(ed."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			SUM(ed."TdsAmount") AS "TdsAmount",
			SUM(ed."ItemTotal") AS "ItemTotal",

			MAX(ed."TotalTaxableValue") AS "TotalTaxableValue",
			MAX(ed."TotalTaxAmount") AS "TotalTaxAmount",
			MAX(ed."ReverseCharge"::int)::boolean AS "ReverseCharge",
			MAX(ed."RecoHubRemarks") AS "RecoHubRemarks"
		FROM
			"TempGstData" ed
		GROUP BY
			ed."Id", ed."MapperId";

		DROP TABLE IF EXISTS "TempAutoDraftDataHeader";
		CREATE TEMP TABLE "TempAutoDraftDataHeader" AS
		SELECT
			ed."MapperId",
			ed."Id",
			MAX(ed."EntityId") AS "EntityId",			
			MAX(ed."AutoDraftId") AS "AutoDraftId",			
			MAX(ed."GstType") AS "GstType",		
			MAX(ed."DocumentNumber") AS "DocumentNumber",
			MAX(ed."DocumentDate") AS "DocumentDate",
			MAX(ed."DocFinancialYear") AS "DocFinancialYear",
			MAX(ed."Gstin") AS "Gstin",
			MAX(ed."DocumentValue") AS "DocumentValue",
			MAX(ed."Pos") AS "Pos",
			MAX(ed."PushStatus") AS "PushStatus",
			MAX(ed."DocumentType") AS "DocumentType",
			MAX(ed."GstSection") AS "GstSection",
			MAX(ed."AutoDraftSection") AS "AutoDraftSection",
			MAX(ed."TransactionType") AS "TransactionType",
			MAX(ed."IsAmendment"::int)::boolean AS "IsAmendment",
			MAX(ed."GstReason") AS "GstReason",
			MAX(ed."AutoDraftReason") AS "AutoDraftReason",
			MAX(ed."AutoDraftTradeName") AS "AutoDraftTradeName",
			MAX(ed."AutoDraftLegalName") AS "AutoDraftLegalName",

			MAX(ed."BillFromGstin") AS "BillFromGstin",
			MAX(ed."BillFromTradeName") AS "BillFromTradeName",
			MAX(ed."BillFromLegalName") AS "BillFromLegalName",
			MAX(ed."BillFromAddress1") AS "BillFromAddress1",
			MAX(ed."BillFromAddress2") AS "BillFromAddress2",
			MAX(ed."BillFromCity") AS "BillFromCity",
			MAX(ed."BillFromStateCode") AS "BillFromStateCode",
			MAX(ed."BillFromPin") AS "BillFromPin",
			MAX(ed."BillToGstin") AS "BillToGstin",
			MAX(ed."BillToTradeName") AS "BillToTradeName",
			MAX(ed."BillToLegalName") AS "BillToLegalName",
			MAX(ed."BillToAddress1") AS "BillToAddress1",
			MAX(ed."BillToAddress2") AS "BillToAddress2",
			MAX(ed."BillToCity") AS "BillToCity",
			MAX(ed."BillToStateCode") AS "BillToStateCode",
			MAX(ed."BillToPin") AS "BillToPin",

			MAX(ed."Custom1") AS "Custom1",
			MAX(ed."Custom2") AS "Custom2",
			MAX(ed."Custom3") AS "Custom3",
			MAX(ed."Custom4") AS "Custom4",
			MAX(ed."Custom5") AS "Custom5",
			MAX(ed."Custom6") AS "Custom6",
			MAX(ed."Custom7") AS "Custom7",
			MAX(ed."Custom8") AS "Custom8",
			MAX(ed."Custom9") AS "Custom9",
			MAX(ed."Custom10") AS "Custom10",
			
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
			SUM(ed."GrossAmount") AS "GrossAmount",
			SUM(ed."OtherCharges") AS "OtherCharges",
			SUM(ed."TaxableValue") AS "TaxableValue",
			SUM(ed."IgstAmount") AS "IgstAmount",
			SUM(ed."CgstAmount") AS "CgstAmount",
			SUM(ed."SgstAmount") AS "SgstAmount",
			SUM(ed."CessAmount") AS "CessAmount",
			SUM(ed."StateCessAmount") AS "StateCessAmount",
			SUM(ed."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(ed."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			SUM(ed."TdsAmount") AS "TdsAmount",
			SUM(ed."ItemTotal") AS "ItemTotal",

			MAX(ed."TotalTaxableValue") AS "TotalTaxableValue",
			MAX(ed."TotalTaxAmount") AS "TotalTaxAmount",
			MAX(ed."ReverseCharge"::int)::boolean AS "ReverseCharge",
			MAX(ed."RecoHubRemarks") AS "RecoHubRemarks",
			MAX(ed."Irn") AS "Irn"
		FROM
			"TempAutoDraftData" ed
		GROUP BY ed."Id", ed."MapperId";
			
		DROP TABLE IF EXISTS "TempPurchaseGstDataHeader";
		CREATE TEMP TABLE "TempPurchaseGstDataHeader" AS
		SELECT 
			ed."Id",
			ed."MapperId",
			MAX(ed."EntityId") AS "EntityId",
			MAX(ed."GstType") AS "GstType",		
			MAX(ed."DocumentNumber") AS "DocumentNumber",
			MAX(ed."DocumentDate") AS "DocumentDate",
			MAX(ed."Gstin") AS "Gstin",
			MAX(ed."DocumentValue") AS "DocumentValue",
			MAX(ed."Pos") AS "Pos",
			MAX(ed."PushStatus") AS "PushStatus",
			MAX(ed."IsAmendment"::int)::boolean AS "IsAmendment",
			MAX(ed."DocumentType") AS "DocumentType",
			MAX(ed."TransactionType") AS "TransactionType",
			MAX(ed."EwbSection") AS "EwbSection",
			MAX(ed."EinvSection") AS "EinvSection",
			MAX(ed."GstSection") AS "GstSection",
			MAX(ed."AutoDraftSection") AS "AutoDraftSection",
			MAX(ed."GstReason") AS "GstReason",
			MAX(ed."EwbReason") AS "EwbReason",
			MAX(ed."EinvReason") AS "EinvReason",
			MAX(ed."AutoDraftReason") AS "AutoDraftReason",
			MAX(ed."GstTradeName") AS "GstTradeName",
			MAX(ed."GstLegalName") AS "GstLegalName",

			MAX(ed."BillFromGstin") AS "BillFromGstin",
			MAX(ed."BillFromTradeName") AS "BillFromTradeName",
			MAX(ed."BillFromLegalName") AS "BillFromLegalName",
			MAX(ed."BillFromAddress1") AS "BillFromAddress1",
			MAX(ed."BillFromAddress2") AS "BillFromAddress2",
			MAX(ed."BillFromCity") AS "BillFromCity",
			MAX(ed."BillFromStateCode") AS "BillFromStateCode",
			MAX(ed."BillFromPin") AS "BillFromPin",
			MAX(ed."BillToGstin") AS "BillToGstin",
			MAX(ed."BillToTradeName") AS "BillToTradeName",
			MAX(ed."BillToLegalName") AS "BillToLegalName",
			MAX(ed."BillToAddress1") AS "BillToAddress1",
			MAX(ed."BillToAddress2") AS "BillToAddress2",
			MAX(ed."BillToCity") AS "BillToCity",
			MAX(ed."BillToStateCode") AS "BillToStateCode",
			MAX(ed."BillToPin") AS "BillToPin",

			MAX(ed."Custom1") AS "Custom1",
			MAX(ed."Custom2") AS "Custom2",
			MAX(ed."Custom3") AS "Custom3",
			MAX(ed."Custom4") AS "Custom4",
			MAX(ed."Custom5") AS "Custom5",
			MAX(ed."Custom6") AS "Custom6",
			MAX(ed."Custom7") AS "Custom7",
			MAX(ed."Custom8") AS "Custom8",
			MAX(ed."Custom9") AS "Custom9",
			MAX(ed."Custom10") AS "Custom10",
			
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
			SUM(ed."GrossAmount") AS "GrossAmount",
			SUM(ed."OtherCharges") AS "OtherCharges",
			SUM(ed."TaxableValue") AS "TaxableValue",
			SUM(ed."IgstAmount") AS "IgstAmount",
			SUM(ed."CgstAmount") AS "CgstAmount",
			SUM(ed."SgstAmount") AS "SgstAmount",
			SUM(ed."CessAmount") AS "CessAmount",
			SUM(ed."StateCessAmount") AS "StateCessAmount",
			SUM(ed."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(ed."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			SUM(ed."TdsAmount") AS "TdsAmount",
			SUM(ed."ItemTotal") AS "ItemTotal",

			MAX(ed."TotalTaxableValue") AS "TotalTaxableValue",
			MAX(ed."TotalTaxAmount") AS "TotalTaxAmount",
			MAX(ed."ReverseCharge"::int)::boolean AS "ReverseCharge",
			MAX(ed."RecoHubRemarks") AS "RecoHubRemarks",
			MAX(ed."Irn") AS "Irn"
			
		FROM
			"TempPurchaseGstData" ed			
		GROUP BY ed."Id",ed."MapperId";

		DROP TABLE IF EXISTS "TempPurchaseAutoDraftDataHeader";
		CREATE TEMP TABLE "TempPurchaseAutoDraftDataHeader" AS
		SELECT
			ed."AutoDraftId",
			ed."MapperId",
			MAX(ed."EntityId") AS "EntityId",
			MAX(ed."SupplyType") AS "SupplyType",		
			MAX(ed."DocumentNumber") AS "DocumentNumber",
			MAX(ed."DocumentDate") AS "DocumentDate",
			MAX(ed."DocFinancialYear") AS "DocFinancialYear",
			MAX(ed."Gstin") AS "Gstin",
			MAX(ed."DocumentValue") AS "DocumentValue",
			MAX(ed."Pos") AS "Pos",
			MAX(ed."PushStatus") AS "PushStatus",
			MAX(ed."DocumentType") AS "DocumentType",
			MAX(ed."EinvSection") AS "EinvSection",
			MAX(ed."GstSection") AS "GstSection",
			MAX(ed."EwbSection") AS "EwbSection",
			MAX(ed."AutoDraftSection") AS "AutoDraftSection",
			MAX(ed."TransactionType") AS "TransactionType",
			MAX(ed."IsAmendment"::int)::boolean AS "IsAmendment",
			MAX(ed."GstReason") AS "GstReason",
			MAX(ed."AutoDraftReason") AS "AutoDraftReason",
			MAX(ed."AutoDraftTradeName") AS "AutoDraftTradeName",
			MAX(ed."AutoDraftLegalName") AS "AutoDraftLegalName",
			MAX(ed."Irn") AS "Irn",

			MAX(ed."BillFromGstin") AS "BillFromGstin",
			MAX(ed."BillFromTradeName") AS "BillFromTradeName",
			MAX(ed."BillFromLegalName") AS "BillFromLegalName",
			MAX(ed."BillFromAddress1") AS "BillFromAddress1",
			MAX(ed."BillFromAddress2") AS "BillFromAddress2",
			MAX(ed."BillFromCity") AS "BillFromCity",
			MAX(ed."BillFromStateCode") AS "BillFromStateCode",
			MAX(ed."BillFromPin") AS "BillFromPin",
			MAX(ed."BillToGstin") AS "BillToGstin",
			MAX(ed."BillToTradeName") AS "BillToTradeName",
			MAX(ed."BillToLegalName") AS "BillToLegalName",
			MAX(ed."BillToAddress1") AS "BillToAddress1",
			MAX(ed."BillToAddress2") AS "BillToAddress2",
			MAX(ed."BillToCity") AS "BillToCity",
			MAX(ed."BillToStateCode") AS "BillToStateCode",
			MAX(ed."BillToPin") AS "BillToPin",

			MAX(ed."Custom1") AS "Custom1",
			MAX(ed."Custom2") AS "Custom2",
			MAX(ed."Custom3") AS "Custom3",
			MAX(ed."Custom4") AS "Custom4",
			MAX(ed."Custom5") AS "Custom5",
			MAX(ed."Custom6") AS "Custom6",
			MAX(ed."Custom7") AS "Custom7",
			MAX(ed."Custom8") AS "Custom8",
			MAX(ed."Custom9") AS "Custom9",
			MAX(ed."Custom10") AS "Custom10",
			
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
			SUM(ed."GrossAmount") AS "GrossAmount",
			SUM(ed."OtherCharges") AS "OtherCharges",
			SUM(ed."TaxableValue") AS "TaxableValue",
			SUM(ed."IgstAmount") AS "IgstAmount",
			SUM(ed."CgstAmount") AS "CgstAmount",
			SUM(ed."SgstAmount") AS "SgstAmount",
			SUM(ed."CessAmount") AS "CessAmount",
			SUM(ed."StateCessAmount") AS "StateCessAmount",
			SUM(ed."CessNonAdvaloremAmount") AS "CessNonAdvaloremAmount",
			SUM(ed."StateCessNonAdvaloremAmount") AS "StateCessNonAdvaloremAmount",
			SUM(ed."TdsAmount") AS "TdsAmount",
			SUM(ed."ItemTotal") AS "ItemTotal",

			MAX(ed."TotalTaxableValue") AS "TotalTaxableValue",
			MAX(ed."TotalTaxAmount") AS "TotalTaxAmount",
			MAX(ed."ReverseCharge"::int)::boolean AS "ReverseCharge",
			MAX(ed."RecoHubRemarks") AS "RecoHubRemarks",
			MAX(ed."EinvQrId") AS "EinvQrId"
		FROM
			"TempPurchaseAutoDraftData" ed			
		GROUP BY ed."AutoDraftId",ed."MapperId";

	END IF;
	
	IF ("_IncludeAggregatedItems" = True) AND "_BaseSource" IS NOT NULL
	THEN
		"_SqlQuery" := CONCAT(N'
			SELECT 
			COALESCE(gst."EntityId",einv."EntityId",ewb."EntityId",sadm."EntityId",qrcode."EntityId")::integer AS "EntityId",
			einv."MapperId"::bigint AS "EinvMapperId",
			ewb."MapperId"::bigint AS "EwbMapperId",
			"_base"."MapperId"::bigint AS "GstMapperId",
			sadm."MapperId"::bigint AS "SaleAutoDraftMapperId",
			padm."MapperId"::bigint AS "PurchaseAutoDraftMapperId",
			qrcode."MapperId"::bigint AS "EinvQrCodeMapperId",
			"_base"."DocumentNumber"::character varying,
			"_base"."DocumentDate"::timestamp without time zone,
			"_base"."DocFinancialYear"::integer,
			"_base"."DocumentType"::smallint,
			padm."TransactionType"::smallint AS "PurchaseAutodraftTransactionType",
			padm."PushStatus"::smallint AS "PurchaseAutodraftPushStatus",
			"_base"."TransactionType"::smallint AS "GstTransactionType",
			"_base"."PushStatus"::smallint AS "GstPushStatus",
			sadm."TransactionType"::smallint AS "SalesAutodraftTransactionType",
			sadm."PushStatus"::smallint AS "SalesAutodraftPushStatus",
			einv."TransactionType"::smallint AS "EinvTransactionType",
			einv."PushStatus"::smallint AS "EinvPushStatus",
			ewb."TransactionType"::smallint AS "EwbTransactionType",
			ewb."PushStatus"::smallint AS "EwbPushStatus",
			"_base"."DocumentValue"::numeric(18,2),
			"_base"."TotalTaxableValue"::numeric(18,2) AS "DocumentTaxableValue",
			"_base"."TotalTaxAmount"::numeric(18,2) AS "DocumentTaxValue",
			"_base"."Irn"::character varying,
			ewb."EwbNumber"::bigint,
			ewb."PartBStatus"::smallint,
			"_base"."TransactionType"::smallint,
			"_base"."IsAmendment"::boolean,
			"_base"."ReverseCharge"::boolean,
			"_base"."Pos"::smallint,
			"_base"."BillFromGstin"::character varying,
			"_base"."BillFromTradeName"::character varying,
			"_base"."BillFromLegalName"::character varying,
			"_base"."BillFromAddress1"::character varying,
			"_base"."BillFromAddress2"::character varying,
			"_base"."BillFromCity"::character varying,
			"_base"."BillFromStateCode"::smallint,
			"_base"."BillFromPin"::integer,
			"_base"."BillToGstin"::character varying,
			"_base"."BillToTradeName"::character varying,
			"_base"."BillToLegalName"::character varying,
			"_base"."BillToAddress1"::character varying,
			"_base"."BillToAddress2"::character varying,
			"_base"."BillToCity"::character varying,
			"_base"."BillToStateCode"::smallint,
			"_base"."BillToPin"::integer,
			
			gst."EinvSection"::smallint AS "GstVsEinvSection",
			gst."EwbSection"::smallint AS "GstVsEwbSection",
			einv."GstSection"::smallint AS "EinvVsGstSection",
			einv."EwbSection"::smallint AS "EinvVsEwbSection",
			ewb."EinvSection"::smallint AS "EwbVsEinvSection",
			ewb."GstSection"::smallint AS "EwbVsGstSection",
			padm."AutoDraftSection"::smallint AS "GstVsSalesAutodraftSection",
			sadm."GstSection"::smallint AS "SalesAutodraftVsGstSection",
			qrcode."AutoDraftSection"::smallint AS "GstPurchaseVsGstPurchaseAutoDraftedSection",
			qrcode."AutoDraftSection"::smallint AS "EinvQrCodeVsGstPurchaseAutoDraftedSection",
			
			v."TaxpayerStatus"::integer AS "GstinStatus",
			gst."GstinTaxpayerType"::smallint AS "GstinTaxpayerType",
					
			"_base"."Custom1"::character varying,
			"_base"."Custom2"::character varying,
			"_base"."Custom3"::character varying,
			"_base"."Custom4"::character varying,
			"_base"."Custom5"::character varying,
			"_base"."Custom6"::character varying,
			"_base"."Custom7"::character varying,
			"_base"."Custom8"::character varying,
			"_base"."Custom9"::character varying,
			"_base"."Custom10"::character varying,
			
			"_base"."HsnOrSacCode"::character varying,
			"_base"."Name"::character varying,
			"_base"."Description"::character varying,
			"_base"."Uqc"::character varying,
			"_base"."Quantity"::numeric,
			"_base"."PricePerQuantity"::numeric,
			"_base"."Rate"::numeric,
			"_base"."CessRate"::numeric,
			"_base"."StateCessRate"::numeric,
			"_base"."CessNonAdvaloremRate"::numeric,
			"_base"."TdsRate"::numeric,
			"_base"."GrossAmount"::numeric,
			"_base"."OtherCharges"::numeric,
			"_base"."TaxableValue"::numeric,
			"_base"."IgstAmount"::numeric,
			"_base"."CgstAmount"::numeric,
			"_base"."SgstAmount"::numeric,
			"_base"."CessAmount"::numeric,
			"_base"."StateCessAmount"::numeric,
			"_base"."CessNonAdvaloremAmount"::numeric,
			"_base"."StateCessNonAdvaloremAmount"::numeric,
			"_base"."TdsAmount"::numeric,
			 qrcode."ItemTotal"::smallint AS "ItemTotal",
			"_base"."RecoHubRemarks"::character varying AS "Remarks",
	
			gst."EinvReason"::character varying AS "GstVsEinvReasonParameters",
			gst."EwbReason"::character varying AS "GstVsEwbReasonParameters",
			einv."GstReason"::character varying AS "EinvVsGstReasonParameters",
			einv."EwbReason"::character varying AS "EinvVsEwbReasonParameters",
			ewb."EinvReason"::character varying AS "EwbVsEinvReasonParameters",
			ewb."GstReason"::character varying AS "EwbVsGstReasonParameters",
			gst."AutoDraftReason"::character varying AS "GstVsSalesAutodraftReasonParameters",
			sadm."GstReason"::character varying AS "SalesAutodraftVsGstReasonParameters",
			padm."GstReason"::character varying AS "GstPurchaseVsGstPurchaseAutoDraftedReasonParameters",
			qrcode."AutoDraftReason"::character varying AS "EinvQrCodeVsGstPurchaseAutoDraftedReasonParameters"
			FROM
				"TempGstDataHeader" AS gst			
				FULL JOIN "TempEwayBillDataHeader" ewb  ON gst."EWBId" = ewb."EWBId" AND gst."SupplyType" = ewb."SupplyType"
				FULL JOIN "TempEinvDataHeader" AS einv ON einv."EInvId" = COALESCE(gst."EInvId",ewb."EInvId")
				FULL JOIN "TempAutoDraftDataHeader" sadm ON sadm."AutoDraftId" = gst."AutoDraftId"
				FULL JOIN "TempPurchaseAutoDraftDataHeader" padm ON padm."AutoDraftId" = gst."AutoDraftId"
				FULL JOIN "TempEinvoiceQrCodeData" AS qrcode ON qrcode."EinvQrId" = padm."EinvQrId"
				LEFT JOIN subscriber."VendorDetails" v ON gst."BillFromGstin" = v."Gstin" AND v."SubscriberId" = $1
			ORDER BY COALESCE(gst."MapperId",einv."MapperId",ewb."MapperId",sadm."MapperId");'
		);
	
	ELSEIF "_IncludeAggregatedItems" = false AND "_BaseSource" IS NOT NULL
	THEN
		"_SqlQuery" := CONCAT(N'
		SELECT 
			COALESCE(gst."EntityId",einv."EntityId",ewb."EntityId",sadm."EntityId",qrcode."EntityId")::integer AS "EntityId",
			einv."MapperId"::bigint AS "EinvMapperId",
			ewb."MapperId"::bigint AS "EwbMapperId",
			"_base"."MapperId"::bigint AS "GstMapperId",
			sadm."MapperId"::bigint AS "SaleAutoDraftMapperId",
			padm."MapperId"::bigint AS "PurchaseAutoDraftMapperId",
			qrcode."MapperId"::bigint AS "EinvQrCodeMapperId",
			"_base"."DocumentNumber"::character varying,
			"_base"."DocumentDate"::timestamp without time zone,
			"_base"."DocFinancialYear"::integer,
			"_base"."DocumentType"::smallint,
			padm."TransactionType"::smallint AS "PurchaseAutodraftTransactionType",
			padm."PushStatus"::smallint AS "PurchaseAutodraftPushStatus",
			"_base"."TransactionType"::smallint AS "GstTransactionType",
			"_base"."PushStatus"::smallint AS "GstPushStatus",
			sadm."TransactionType"::smallint AS "SalesAutodraftTransactionType",
			sadm."PushStatus"::smallint AS "SalesAutodraftPushStatus",
			einv."TransactionType"::smallint AS "EinvTransactionType",
			einv."PushStatus"::smallint AS "EinvPushStatus",
			ewb."TransactionType"::smallint AS "EwbTransactionType",
			ewb."PushStatus"::smallint AS "EwbPushStatus",
			"_base"."DocumentValue"::numeric(18,2),
			"_base"."TotalTaxableValue"::numeric(18,2) AS "DocumentTaxableValue",
			"_base"."TotalTaxAmount"::numeric(18,2) AS "DocumentTaxValue",
			"_base"."Irn"::character varying,
			ewb."EwbNumber"::bigint,
			ewb."PartBStatus"::smallint,
			"_base"."TransactionType"::smallint,
			"_base"."IsAmendment"::boolean,
			"_base"."ReverseCharge"::boolean,
			"_base"."Pos"::smallint,
			"_base"."BillFromGstin"::character varying,
			"_base"."BillFromTradeName"::character varying,
			"_base"."BillFromLegalName"::character varying,
			"_base"."BillFromAddress1"::character varying,
			"_base"."BillFromAddress2"::character varying,
			"_base"."BillFromCity"::character varying,
			"_base"."BillFromStateCode"::smallint,
			"_base"."BillFromPin"::integer,
			"_base"."BillToGstin"::character varying,
			"_base"."BillToTradeName"::character varying,
			"_base"."BillToLegalName"::character varying,
			"_base"."BillToAddress1"::character varying,
			"_base"."BillToAddress2"::character varying,
			"_base"."BillToCity"::character varying,
			"_base"."BillToStateCode"::smallint,
			"_base"."BillToPin"::integer,
			
			gst."EinvSection"::smallint AS "GstVsEinvSection",
			gst."EwbSection"::smallint AS "GstVsEwbSection",
			einv."GstSection"::smallint AS "EinvVsGstSection",
			einv."EwbSection"::smallint AS "EinvVsEwbSection",
			ewb."EinvSection"::smallint AS "EwbVsEinvSection",
			ewb."GstSection"::smallint AS "EwbVsGstSection",
			padm."AutoDraftSection"::smallint AS "GstVsSalesAutodraftSection",
			sadm."GstSection"::smallint AS "SalesAutodraftVsGstSection",
			qrcode."AutoDraftSection"::smallint AS "GstPurchaseVsGstPurchaseAutoDraftedSection",
			qrcode."AutoDraftSection"::smallint AS "EinvQrCodeVsGstPurchaseAutoDraftedSection",
			
			v."TaxpayerStatus"::integer AS "GstinStatus",
			gst."GstinTaxpayerType"::smallint AS "GstinTaxpayerType",
					
			"_base"."Custom1"::character varying,
			"_base"."Custom2"::character varying,
			"_base"."Custom3"::character varying,
			"_base"."Custom4"::character varying,
			"_base"."Custom5"::character varying,
			"_base"."Custom6"::character varying,
			"_base"."Custom7"::character varying,
			"_base"."Custom8"::character varying,
			"_base"."Custom9"::character varying,
			"_base"."Custom10"::character varying,
			
			"_base"."HsnOrSacCode"::character varying,
			"_base"."Name"::character varying,
			"_base"."Description"::character varying,
			"_base"."Uqc"::character varying,
			"_base"."Quantity"::numeric,
			"_base"."PricePerQuantity"::numeric,
			"_base"."Rate"::numeric,
			"_base"."CessRate"::numeric,
			"_base"."StateCessRate"::numeric,
			"_base"."CessNonAdvaloremRate"::numeric,
			"_base"."TdsRate"::numeric,
			"_base"."GrossAmount"::numeric,
			"_base"."OtherCharges"::numeric,
			"_base"."TaxableValue"::numeric,
			"_base"."IgstAmount"::numeric,
			"_base"."CgstAmount"::numeric,
			"_base"."SgstAmount"::numeric,
			"_base"."CessAmount"::numeric,
			"_base"."StateCessAmount"::numeric,
			"_base"."CessNonAdvaloremAmount"::numeric,
			"_base"."StateCessNonAdvaloremAmount"::numeric,
			"_base"."TdsAmount"::numeric,
			 qrcode."ItemTotal"::smallint AS "ItemTotal",
			"_base"."RecoHubRemarks"::character varying AS "Remarks",
	
			gst."EinvReason"::character varying AS "GstVsEinvReasonParameters",
			gst."EwbReason"::character varying AS "GstVsEwbReasonParameters",
			einv."GstReason"::character varying AS "EinvVsGstReasonParameters",
			einv."EwbReason"::character varying AS "EinvVsEwbReasonParameters",
			ewb."EinvReason"::character varying AS "EwbVsEinvReasonParameters",
			ewb."GstReason"::character varying AS "EwbVsGstReasonParameters",
			gst."AutoDraftReason"::character varying AS "GstVsSalesAutodraftReasonParameters",
			sadm."GstReason"::character varying AS "SalesAutodraftVsGstReasonParameters",
			padm."GstReason"::character varying AS "GstPurchaseVsGstPurchaseAutoDraftedReasonParameters",
			qrcode."AutoDraftReason"::character varying AS "EinvQrCodeVsGstPurchaseAutoDraftedReasonParameters"
		FROM
			"TempGstData" AS gst			
			FULL JOIN "TempEwaybillData" ewb ON gst."EWBId" = ewb."EWBId" AND gst."SupplyType" = ewb."SupplyType"
			FULL JOIN "TempEinvData" AS einv ON einv."EInvId" = COALESCE(gst."EInvId",ewb."EInvId")
			FULL JOIN "TempAutoDraftData" sadm ON sadm."AutoDraftId" = gst."AutoDraftId"
			FULL JOIN "TempPurchaseAutoDraftData" padm ON padm."AutoDraftId" = gst."AutoDraftId"
			FULL JOIN "TempEinvoiceQrCodeData" AS qrcode ON qrcode."EinvQrId" = padm."EinvQrId"
			LEFT JOIN subscriber."VendorDetails" v ON gst."BillFromGstin" = v."Gstin" AND v."SubscriberId" = $1
		ORDER BY COALESCE(gst."MapperId",einv."MapperId",ewb."MapperId",sadm."MapperId");
	');
	
	ELSEIF "_IncludeAggregatedItems" = true AND "_BaseSource" IS NULL
	THEN
		"_SqlQuery" := CONCAT(N'
		SELECT 
			COALESCE(gst."EntityId",einv."EntityId",ewb."EntityId",sadm."EntityId",qrcode."EntityId")::integer AS "EntityId",			  
			einv."MapperId" AS "EinvMapperId",
			ewb."MapperId" AS "EwbMapperId",
			gst."MapperId" AS "GstMapperId",
			sadm."MapperId" AS "SaleAutoDraftMapperId",
			padm."MapperId" AS "PurchaseAutoDraftMapperId",
			NULL::bigint AS "EinvQrCodeMapperId",
			COALESCE(gst."DocumentNumber",einv."DocumentNumber",ewb."DocumentNumber",sadm."DocumentNumber",qrcode."DocumentNumber")::character varying AS "DocumentNumber",
			COALESCE(gst."DocumentDate",einv."DocumentDate",ewb."DocumentDate",sadm."DocumentDate",qrcode."DocumentDate")::timestamp without time zone AS "DocumentDate",
			COALESCE(gst."DocFinancialYear",einv."DocFinancialYear",ewb."DocFinancialYear",sadm."DocFinancialYear",qrcode."DocFinancialYear")::integer AS "DocFinancialYear",
			COALESCE(gst."DocumentType",einv."DocumentType",ewb."DocumentType",sadm."DocumentType",qrcode."DocumentType")::smallint AS "DocumentType",
			gst."TransactionType" AS "PurchaseAutodraftTransactionType",
			gst."PushStatus" AS "PurchaseAutodraftPushStatus",
			gst."TransactionType" AS "GstTransactionType",
			gst."PushStatus" AS "GstPushStatus",
			sadm."TransactionType" AS "SalesAutodraftTransactionType",
			sadm."PushStatus" AS "SalesAutodraftPushStatus",
			einv."TransactionType" AS "EinvTransactionType",
			einv."PushStatus" AS "EinvPushStatus",
			ewb."TransactionType" AS "EwbTransactionType",
			ewb."PushStatus" AS "EwbPushStatus",
			gst."DocumentValue",
			gst."TotalTaxableValue"::numeric(18,2) AS "DocumentTaxableValue",
			gst."TotalTaxAmount"::numeric(18,2) AS "DocumentTaxValue",
			gst."Irn"::character varying,
			ewb."EwbNumber",
			ewb."PartBStatus",
			gst."TransactionType",
			gst."IsAmendment",
			gst."ReverseCharge",
			gst."Pos",
			gst."BillFromGstin"::character varying,
			gst."BillFromTradeName"::character varying,
			gst."BillFromLegalName"::character varying,
			gst."BillFromAddress1"::character varying,
			gst."BillFromAddress2"::character varying,
			gst."BillFromCity"::character varying,
			gst."BillFromStateCode",
			gst."BillFromPin",
			gst."BillToGstin"::character varying,
			gst."BillToTradeName"::character varying,
			gst."BillToLegalName"::character varying,
			gst."BillToAddress1"::character varying,
			gst."BillToAddress2"::character varying,
			gst."BillToCity"::character varying,
			gst."BillToStateCode",
			gst."BillToPin",
			
			gst."EinvSection" AS "GstVsEinvSection",
			gst."EwbSection" AS "GstVsEwbSection",
			einv."GstSection" AS "EinvVsGstSection",
			einv."EwbSection" AS "EinvVsEwbSection",
			ewb."EinvSection" AS "EwbVsEinvSection",
			ewb."GstSection" AS "EwbVsGstSection",
			padm."AutoDraftSection" AS "GstVsSalesAutodraftSection",
			sadm."GstSection" AS "SalesAutodraftVsGstSection",
			NULL::smallint AS "GstPurchaseVsGstPurchaseAutoDraftedSection",
			NULL::smallint AS "EinvQrCodeVsGstPurchaseAutoDraftedSection",
			
			v."TaxpayerStatus"::integer AS "GstinStatus",
			gst."GstinTaxpayerType"::smallint AS "GstinTaxpayerType",
					
			gst."Custom1"::character varying,
			gst."Custom2"::character varying,
			gst."Custom3"::character varying,
			gst."Custom4"::character varying,
			gst."Custom5"::character varying,
			gst."Custom6"::character varying,
			gst."Custom7"::character varying,
			gst."Custom8"::character varying,
			gst."Custom9"::character varying,
			gst."Custom10"::character varying,
			
			gst."HsnOrSacCode",
			gst."Name"::character varying,
			gst."Description"::character varying,
			gst."Uqc",
			gst."Quantity",
			gst."PricePerQuantity",
			gst."Rate",
			gst."CessRate",
			gst."StateCessRate",
			gst."CessNonAdvaloremRate",
			gst."TdsRate",
			gst."GrossAmount",
			gst."OtherCharges",
			gst."TaxableValue",
			gst."IgstAmount",
			gst."CgstAmount",
			gst."SgstAmount",
			gst."CessAmount",
			gst."StateCessAmount",
			gst."CessNonAdvaloremAmount",
			gst."StateCessNonAdvaloremAmount",
			gst."TdsAmount",
			NULL::smallint AS "ItemTotal",
			--gst."RecoHubRemarks"::character varying AS "Remarks",
			COALESCE(gst."RecoHubRemarks",einv."RecoHubRemarks",ewb."RecoHubRemarks",sadm."RecoHubRemarks",qrcode."RecoHubRemarks")::character varying AS "Remarks",							 
	
			gst."EinvReason"::character varying AS "GstVsEinvReasonParameters",
			gst."EwbReason"::character varying AS "GstVsEwbReasonParameters",
			einv."GstReason"::character varying AS "EinvVsGstReasonParameters",
			einv."EwbReason"::character varying AS "EinvVsEwbReasonParameters",
			ewb."EinvReason"::character varying AS "EwbVsEinvReasonParameters",
			ewb."GstReason"::character varying AS "EwbVsGstReasonParameters",
			gst."AutoDraftReason"::character varying AS "GstVsSalesAutodraftReasonParameters",
			sadm."GstReason"::character varying AS "SalesAutodraftVsGstReasonParameters",
			padm."GstReason"::character varying AS "GstPurchaseVsGstPurchaseAutoDraftedReasonParameters",
			NULL::character varying AS "EinvQrCodeVsGstPurchaseAutoDraftedReasonParameters"
		FROM
			"TempGstData" AS gst			
			FULL JOIN "TempEwaybillData" ewb ON gst."EWBId" = ewb."EWBId" AND gst."SupplyType" = ewb."SupplyType"
			FULL JOIN "TempEinvData" AS einv ON einv."EInvId" = COALESCE(gst."EInvId",ewb."EInvId")
			FULL JOIN "TempAutoDraftData" sadm ON sadm."AutoDraftId" = gst."AutoDraftId"
			FULL JOIN "TempPurchaseAutoDraftData" padm ON padm."AutoDraftId" = gst."AutoDraftId"
			FULL JOIN "TempEinvoiceQrCodeData" AS qrcode ON qrcode."EinvQrId" = padm."EinvQrId"
			LEFT JOIN subscriber."VendorDetails" v ON gst."BillFromGstin" = v."Gstin" AND v."SubscriberId" = $1
		ORDER BY COALESCE(gst."MapperId",einv."MapperId",ewb."MapperId",sadm."MapperId");
	');
	
	END IF;
	
	IF "_BaseSource" = "_ReconciliationHubBaseSourceTypeEINV"
	THEN
		"_SqlQuery" := REPLACE("_SqlQuery", '_base', 'einv');
	ELSEIF "_BaseSource" = "_ReconciliationHubBaseSourceTypeGST"
	THEN 
		"_SqlQuery" := REPLACE("_SqlQuery", '_base', 'gst');
	ELSEIF "_BaseSource" = "_ReconciliationHubBaseSourceTypeEWB"
	THEN 
		"_SqlQuery" := REPLACE("_SqlQuery", '_base', 'ewb');
	ELSEIF "_BaseSource" = "_ReconciliationHubBaseSourceTypeGstAutodrafted"
	THEN 
		"_SqlQuery" := REPLACE("_SqlQuery", '_base', 'sadm');
	ELSEIF "_BaseSource" = "_ReconciliationHubBaseSourceTypePurchaseAutoDraft"
	THEN 
		"_SqlQuery" := REPLACE("_SqlQuery", '_base', 'padm');
	ELSEIF "_BaseSource" = "_ReconciliationHubBaseSourceTypeEInvQRCode"
	THEN 
		"_SqlQuery" := REPLACE("_SqlQuery", '_base', 'qrcode');
	END IF;
	
	RAISE NOTICE 'Query : % ', "_SqlQuery";
	
	RETURN QUERY
	EXECUTE
		"_SqlQuery"
	 USING 
		"_SubscriberId" --$1
	;

END;
$function$
;
