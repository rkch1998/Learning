DROP FUNCTION IF EXISTS einvoice."InsertDocuments";

CREATE OR REPLACE FUNCTION einvoice."InsertDocuments"("_SubscriberId" integer, "_UserId" integer, "_VehicleDetailTypeVehicleDetailAdded" smallint, "_DocumentStatusActive" smallint, "_Documents" einvoice."InsertDocumentType"[], "_DocumentItems" einvoice."InsertDocumentItemType"[], "_DocumentReferences" common."DocumentReferenceType"[], "_DocumentCustoms" einvoice."InsertDocumentCustomType"[], "_DocumentPayments" einvoice."InsertDocumentPaymentType"[], "_DocumentContacts" einvoice."InsertDocumentContactType"[], "_AuditTrailDetails" audit."AuditTrailDetailsType"[], "_RequestId" uuid, "_SupplyTypeS" smallint, "_SupplyTypeP" smallint, "_TransactionTypeB2C" smallint, "_EwaybillPushStatusCancelled" smallint, "_EwayBillPushStatusDiscarded" smallint, "_DocumentStatusCompleted" smallint, "_DocumentStatusYetNotGenerated" smallint, "_ContactTypeBillFrom" smallint, "_ContactTypeDispatchFrom" smallint, "_ContactTypeBillTo" smallint, "_EwayBillPushStatusGenerated" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeCRN" smallint, "_UserActionTypeCreate" smallint, "_UserActionTypeEdit" smallint, "_IpAddress" character varying)
 RETURNS TABLE("Id" bigint, "GroupId" integer)
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: einvoice."InsertDocuments"
* 	Comments			: 2022-08-27 | Shambhu Das | This procedure is used to insert data in all einvoice tables.
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: SELECT * FROM einvoice."InsertDocuments"
							(
								"_SubscriberId" := 170 ::integer,
								"_UserId" := 664 ::integer,
								"_Documents" := ARRAY[ROW(
															379::integer, --AS "EntityId",
															379::integer, --AS "ParentEntityId",
															114::bigint, --AS "StatisticId",
															8::integer, --AS "Purpose",
															1::smallint, --AS "SupplyType",
															null :: character varying, --AS "Irn",
															1::smallint, --AS "Type",
															1::smallint, --AS "TransactionType",
															'TransactionType Desc'::character varying(20), --AS "TransactionTypeDescription",
															null::smallint, --AS "TaxpayerType",
															'1710A1'::character varying(40), --AS "DocumentNumber",
															'2022-10-27'::timestamp without time zone, --AS "DocumentDate",
															NULL::character varying(40), --AS "ReferenceId",
															4::smallint, --AS "TransactionMode",
															NULL::character varying(100), --AS "RefDocumentRemarks",
															NULL::timestamp without time zone, --AS "RefDocumentPeriodStartDate",
															NULL::timestamp without time zone, --AS "RefDocumentPeriodEndDate",
															NULL::character varying, --AS "RefPrecedingDocumentDetails",
															NULL::character varying, --AS "RefContractDetails",
															NULL::character varying, --AS "AdditionalSupportingDocumentDetails",
															NULL::character varying(20), --AS "BillNumber",
															NULL::timestamp without time zone, --AS "BillDate",
															NULL::character varying(10), --AS "PortCode",
															'BDT'::character varying(3), --AS "DocumentCurrencyCode",
															'US'::character varying(2), --AS "DestinationCountry",
															NULL::numeric(14,2), --AS "ExportDuty",
															96::smallint, --AS "Pos",
															8346::numeric(18,2), --AS "DocumentValue",
															NULL::numeric(18,2), --AS "DocumentDiscount",
															100::numeric(18,2), --AS "DocumentOtherCharges",
															NULL::numeric(18,2), --AS "DocumentValueInForeignCurrency",
															NULL::numeric(6,2), --AS "DocumentValueInRoundOffAmount",
															false::boolean, --AS "ReverseCharge",
															false::boolean, --AS "ClaimRefund",
															false::boolean, --AS "UnderIgstAct",
															NULL::character varying(15), --AS "ECommerceGstin",
															'08AAYPB9429Q1ZM'::character varying(15), --AS "TransporterId",
															NULL::character varying(200), --AS "TransporterName",
															100::smallint, --AS "Distance",
															1::smallint, --AS "TransportMode",
															NULL::character varying(15), --AS "TransportDocumentNumber",
															NULL::timestamp without time zone, --AS "TransportDocumentDate",
															'MP09MX6140'::character varying(20), --AS "VehicleNumber",
															1::smallint, --AS "VehicleType",
															NULL::character varying(324), --AS "ToEmailAddresses",
															NULL::character varying(54), --AS "ToMobileNumbers",
															200::numeric(18,2), --AS "TotalTaxableValue",
															8046::numeric(18,2), --AS "TotalTaxAmount",
															102022::integer, --AS "ReturnPeriod",
															202223::integer, --AS "FinancialYear",
															202223::integer, --AS "DocumentFinancialYear",
															1::integer, --AS "GroupId",
															NULL::integer, --AS "AutoGenerate",
															1::integer, --AS "EInvoicePushStatus",
															1::integer, --AS "EwaybillPushStatus",
															NULL::timestamp without time zone, --AS "TransportDateTime",
															NULL::character varying(16), --AS "SeriesCode",
															2::smallint, --AS "SourceType",
															'33TBBTN2058C1ZH'::character varying(15), --AS "BillFromGstin",
															1::smallint, --AS "DocumentStatus",
															516::bigint --AS "SectionType"
															)] :: einvoice."InsertDocumentType"[],
								"_DocumentItems" := ARRAY[ROW(	
															1::integer, --AS "SerialNumber",
															false::boolean, --AS "IsService",
															111541::character varying(40), --AS "Hsn",
															NULL::character varying(40), --AS "ProductCode",
															null::character varying(40), --AS "Name",
															null::character varying(40), --AS "Description",
															null::character varying(40), --AS "Barcode",
															'BAG'::character varying(40), --AS "UQC",
															10.0::numeric(18,2), --AS "Quantity",
															NULL::numeric(18,2), --AS "null",
															18.0::numeric(18,2), --AS "Rate",
															5.0::numeric(18,2), --AS "CessRate",
															1.0::numeric(18,2), --AS "StateCessRate",
															0.0::numeric(18,2), --AS "CessNonAdvaloremRate",
															 10.0::numeric(18,2), --AS "PricePerQuantity",
															null::numeric(18,2), --AS "DiscountAmount",
															100.0::numeric(18,2), --AS "GrossAmount",
															null::numeric(18,2), --AS "OtherCharges",
															100.0::numeric(18,2), --AS "TaxableValue",
															null::numeric(18,2), --AS "PreTaxValue",
															null::numeric(18,2), --AS "IgstAmount",
															9.0::numeric(18,2), --AS "CgstAmount",
															9.0::numeric(18,2), --AS "SgstAmount",
															5.0::numeric(18,2), --AS "CessAmount",
															null::numeric(18,2), --AS "StateCessAmount",
															null::numeric(18,2), --AS "StateCessNonAdvaloremAmount",
															4000::numeric(18,2), --AS "CessNonAdvaloremAmount",
															1::smallint, --AS "TaxType",
															null::character varying(40), --AS "OrderLineReference",
															null::character varying(40), --AS "OriginCountry",
															null::character varying(40), --AS "ItemSerialNumber",
															null::numeric(18,2), --AS "ItemTotal",
															'[{\"Nm\":\"ABCDEFGHIJKLMNOPQRSTUVWXYZ\",\"Val\":\"ABCDEFG\"}]'::character varying(100), --AS "ItemAttributeDetails",
															null::character varying(40), --AS "BatchNameNumber",
															NULL::timestamp without time zone, --AS "BatchExpiryDate",
															NULL::timestamp without time zone, --AS "WarrantyDate",
															null::character varying(40), --AS "CustomItem1",
															null::character varying(40), --AS "CustomItem2",
															null::character varying(40), --AS "CustomItem3",
															null::character varying(40), --AS "CustomItem4",
															null::character varying(40), --AS "CustomItem5",
															null::character varying(40), --AS "CustomItem6",
															null::character varying(40), --AS "CustomItem7",
															null::character varying(40), --AS "CustomItem8",
															null::character varying(40), --AS "CustomItem9",
															null::character varying(40), --AS "CustomItem10",
															1::SMALLINT --AS "GroupId"
															)] :: einvoice."InsertDocumentItemType"[],
								"_DocumentReferences" := NULL :: common."DocumentReferenceType"[],
								"_DocumentCustoms" := NULL :: einvoice."InsertDocumentCustomType"[],
								"_DocumentPayments" := NULL :: einvoice."InsertDocumentPaymentType"[],
								"_DocumentContacts" := NULL :: einvoice."InsertDocumentContactType"[],
								"_SupplyTypeS" := 1 ::smallint,
								"_SupplyTypeP" := 2 ::smallint,
								"_VehicleDetailTypeVehicleDetailAdded" := 1 ::smallint,
								"_DocumentStatusActive" := 1 ::smallint,
								"_TransactionTypeB2C" := 1 ::smallint,
								"_EwaybillPushStatusCancelled" := 4 ::smallint,
								"_EwayBillPushStatusDiscarded" := 14 ::smallint,
								"_DocumentStatusCompleted" := 3 ::smallint,
								"_DocumentStatusYetNotGenerated" := 1 ::smallint,
								"_ContactTypeBillFrom" := 1 ::smallint,
								"_ContactTypeDispatchFrom" := 2 ::smallint,
								"_ContactTypeBillTo" := 3 ::smallint,
								"_EwayBillPushStatusGenerated" := 2 ::smallint,
								"_DocumentTypeDBN" := 2 ::smallint,
								"_DocumentTypeCRN" := 3 ::smallint																
							);
*/--------------------------------------------------------------------------------------------------------------------------------------*/ 		
DECLARE 
	"_Min" integer := 1;
	"_Max" integer; 
	"_BatchSize" integer;
	"_Records" integer;
	
BEGIN

	IF (ARRAY_LENGTH("_AuditTrailDetails",1) > 0) 
	THEN
		PERFORM audit."UpdateAuditDetails"("_AuditTrailDetails");
	END IF;
	
	/* Create temp table and insert data into temp table from table types */
	DROP TABLE IF EXISTS "TempDocumentIds";
	CREATE TEMP TABLE "TempDocumentIds"
	(
		"AutoId" serial,
		"Id" bigint not null,
		"GroupId" integer not null,
		"Mode" char(1) not null
	);
	CREATE INDEX "Idx_TempDocumentIds_GroupId" ON "TempDocumentIds" USING BTREE("GroupId") INCLUDE("Id");

	DROP TABLE IF EXISTS "TempUpsertDocumentIds";
	CREATE TEMP TABLE "TempUpsertDocumentIds"
	(
		"Id" bigint not null	
	);	
	CREATE INDEX "Idx_TempUpsertDocumentIds_Id" ON "TempUpsertDocumentIds" USING BTREE("Id");
		
	DROP TABLE IF EXISTS "TempDocuments";
	CREATE TEMP TABLE "TempDocuments" AS	
	SELECT 
		*,
		CASE WHEN d."Type" = "_DocumentTypeDBN" THEN "_DocumentTypeCRN" ELSE "Type" END AS "CombineType"
	FROM 
		UNNEST("_Documents") as d;
	CREATE INDEX "Idx_TempDocuments_GroupId" ON "TempDocuments" USING BTREE("GroupId");

	DROP TABLE IF EXISTS "TempDocumentReferences";
	CREATE TEMP TABLE "TempDocumentReferences" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentReferences") as dr;

	DROP TABLE IF EXISTS "TempDocumentCustoms";
	CREATE TEMP TABLE "TempDocumentCustoms" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentCustoms") AS dc;

	DROP TABLE IF EXISTS "TempDocumentConctacts";
	CREATE TEMP TABLE "TempDocumentConctacts" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentContacts") AS dc;

	DROP TABLE IF EXISTS "TempDocumentPayments";
	CREATE TEMP TABLE "TempDocumentPayments" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentPayments") AS dp;

	DROP TABLE IF EXISTS "TempDocumentItems";
	CREATE TEMP TABLE "TempDocumentItems" AS
	SELECT
		*
	FROM
		UNNEST("_DocumentItems") AS di;
	CREATE INDEX "Idx_TempDocumentItems_GroupId" ON "TempDocumentItems" USING BTREE("GroupId");
	
		
	DROP TABLE IF EXISTS "TempEinvoiceDocuments";
	CREATE TEMP TABLE "TempEinvoiceDocuments"
	(
		"AutoId" SERIAL,
		"Id" BIGINT,
		"Purpose" SMALLINT,
		"DocumentNumber" CHARACTER VARYING(40),
		"ParentEntityId" INTEGER,
		"DocumentFinancialYear" INTEGER,
		"SupplyType" SMALLINT,
		"PortCode" CHARACTER VARYING(10),
		"TransactionType" SMALLINT,
		"CombineType" SMALLINT,
		"BillFromGstin" CHARACTER VARYING,
		"EinvoiceStatus" SMALLINT,
		"EwaybillStatus" SMALLINT,
		"EwaybillPushStatus" SMALLINT,
		"EinvoicePushStatus" SMALLINT
	);

	INSERT INTO "TempEinvoiceDocuments"
	(
		"Id",
		"Purpose",
		"DocumentNumber",
		"ParentEntityId",
		"DocumentFinancialYear",
		"SupplyType",
		"PortCode",
		"TransactionType",
		"CombineType",
		"BillFromGstin",
		"EinvoiceStatus",
		"EwaybillStatus",
		"EwaybillPushStatus",
		"EinvoicePushStatus"
	)
	SELECT
		ed."Id",
		ed."Purpose",
		ed."DocumentNumber",
		ed."ParentEntityId",
		ed."DocumentFinancialYear",
		ed."SupplyType",
		ed."PortCode",
		ed."TransactionType",
		CASE WHEN ed."Type" = "_DocumentTypeDBN" THEN "_DocumentTypeCRN" ELSE ed."Type" END AS "CombineType",
		edc."Gstin" AS "BillFromGstin",
		ds."Status" AS "EinvoiceStatus",
		eds."Status" AS "EwaybillStatus",
		eds."PushStatus" AS "EwaybillPushStatus",
		ds."PushStatus" AS "EinvoicePushStatus"
	FROM
		"TempDocuments" AS td
		INNER JOIN einvoice."Documents" AS ed ON
		(
				ed."DocumentNumber" = td."DocumentNumber"
			AND ed."ParentEntityId" = td."ParentEntityId"
			AND ed."DocumentFinancialYear"  = td."DocumentFinancialYear"
			AND ed."SubscriberId" = "_SubscriberId"
			AND ed."SupplyType" = td."SupplyType"
		)
		INNER JOIN ewaybill."DocumentStatus" AS eds ON
		(
			eds."DocumentId" = ed."Id"
		)
		INNER JOIN einvoice."DocumentStatus" AS ds ON
		(
			 ds."DocumentId" = ed."Id"
		)
		LEFT JOIN einvoice."DocumentContacts" AS edc ON 
		(
			ed."Id" = edc."DocumentId" AND edc."Type" = "_ContactTypeBillFrom"
		);
	
	/* For same location & same doc number and diff document type remove duplicate Ids */

	WITH cte AS (
		SELECT
			s."AutoId"
		FROM (
			SELECT
				td."AutoId",
				ROW_NUMBER() OVER (PARTITION BY td."Id") "Row_Num"
			FROM 
				"TempEinvoiceDocuments" td
			WHERE  
				td."Id" IS NOT NULL
    	) s
    	WHERE 
			"Row_Num" > 1
	)
	DELETE FROM "TempEinvoiceDocuments" te
	WHERE te."AutoId" IN (SELECT "AutoId" FROM cte);

	INSERT INTO "TempDocumentIds"
	(
		"Id",
		"GroupId",
		"Mode"
	)
	SELECT
		ed."Id",
	    td."GroupId",
		'U' AS "Mode"
	FROM
		"TempDocuments" AS td
		INNER JOIN "TempEinvoiceDocuments" AS ed ON
		(
				ed."DocumentNumber" = td."DocumentNumber"
			AND ed."ParentEntityId" = td."ParentEntityId"
			AND ed."DocumentFinancialYear"  = td."DocumentFinancialYear"
			AND ed."SupplyType" = td."SupplyType"
			AND ed."CombineType" = td."CombineType"
			AND 
			(
				COALESCE(LOWER(ed."BillFromGstin"),'') = COALESCE(LOWER(td."BillFromGstin"),'')
				AND
				(
					td."SupplyType" = "_SupplyTypeS"
					OR
					(
						td."SupplyType" = "_SupplyTypeP"
						AND COALESCE(LOWER(ed."PortCode"),'') = COALESCE(LOWER(td."PortCode"),'')
					)
				)
			)
-- 			AND NOT
-- 			(
-- 				(
					
-- 					(ed."Purpose" & 2 <> 0) AND (ed."EinvoiceStatus" = "_DocumentStatusCompleted" AND ed."TransactionType" = "_TransactionTypeB2C")
-- 				)
-- 				OR
-- 				(
-- 					(ed."Purpose" & 8 <> 0) AND (ed."EwaybillStatus" = "_DocumentStatusCompleted" AND ed."EwaybillPushStatus" IN ("_EwaybillPushStatusCancelled", "_EwayBillPushStatusDiscarded")) 
-- 				)
-- 			)
			AND
			(
				NOT (ed."EinvoiceStatus" = "_DocumentStatusCompleted" AND ed."TransactionType" = "_TransactionTypeB2C")
				OR
				NOT (ed."EwaybillStatus" = "_DocumentStatusCompleted" AND ed."EwaybillPushStatus" IN ("_EwaybillPushStatusCancelled", "_EwayBillPushStatusDiscarded"))
			)
		);

	WITH inserted AS
	(	
		INSERT INTO einvoice."Documents"(
			"SubscriberId",
			"EntityId",
			"ParentEntityId",
			"UserId",
			"StatisticId",
			"SeriesCode",
			"Purpose",
			"SupplyType",
			"Type",
			"TransactionType",
			"TransactionTypeDescription",
			"TaxpayerType",	   
			"DocumentNumber",
			"DocumentDate",
			"ReferenceId",
			"TransactionMode",
			"RefDocumentRemarks",
			"RefDocumentPeriodStartDate",
			"RefDocumentPeriodEndDate",
			"RefPrecedingDocumentDetails",
			"RefContractDetails",
			"AdditionalSupportingDocumentDetails",
			"BillNumber",
			"BillDate",
			"PortCode",
			"DocumentCurrencyCode",
			"DestinationCountry",
			"ExportDuty",
			"Pos",
			"DocumentValue",
			"DocumentDiscount",
			"DocumentOtherCharges",
			"DocumentValueInForeignCurrency",
			"DocumentValueInRoundOffAmount",
			"ReverseCharge",
			"ClaimRefund",
			"UnderIgstAct",
			"ECommerceGstin",
			"TransporterId",
			"TransporterName",
			"VehicleType",
			"ToEmailAddresses",
			"ToMobileNumbers",
			"TotalTaxableValue",
			"TotalTaxAmount",
			"ReturnPeriod",
			"FinancialYear",
			"DocumentFinancialYear",
			"SourceType",
			"SectionType",
			"GroupId",
			"AttachmentStreamId",
			"DocumentReturnPeriod",
			"RequestId"
		)
		SELECT
			"_SubscriberId",
			"EntityId",
			"ParentEntityId",
			"_UserId",
			"StatisticId",
			"SeriesCode",
			"Purpose",
			"SupplyType",
			"Type",
			"TransactionType",
			"TransactionTypeDescription",
			"TaxpayerType",	   
			"DocumentNumber",
			"DocumentDate",
			"ReferenceId",
			"TransactionMode",
			"RefDocumentRemarks",
			"RefDocumentPeriodStartDate",
			"RefDocumentPeriodEndDate",
			"RefPrecedingDocumentDetails",
			"RefContractDetails",
			"AdditionalSupportingDocumentDetails",
			"BillNumber",
			"BillDate",
			"PortCode",
			"DocumentCurrencyCode",
			"DestinationCountry",
			"ExportDuty",
			"Pos",
			"DocumentValue",
			"DocumentDiscount",
			"DocumentOtherCharges",
			"DocumentValueInForeignCurrency",
			"DocumentValueInRoundOffAmount",
			"ReverseCharge",
			"ClaimRefund",
			"UnderIgstAct",
			"ECommerceGstin",
			"TransporterId",
			"TransporterName",
			"VehicleType",
			"ToEmailAddresses",
			"ToMobileNumbers",
			"TotalTaxableValue",
			"TotalTaxAmount",
			"ReturnPeriod",
			"FinancialYear",
			"DocumentFinancialYear",
			"SourceType",
			"SectionType",
			td."GroupId",
			"AttachmentStreamId",
			"DocumentReturnPeriod",
			"_RequestId"
		FROM
			"TempDocuments" td
		WHERE 
			td."GroupId" NOT IN (SELECT t."GroupId" FROM "TempDocumentIds" t)
		RETURNING einvoice."Documents"."Id" As "Id", einvoice."Documents"."GroupId" AS "GroupId", 'I' As "Mode"
	)
	INSERT INTO "TempDocumentIds"
	(
		"Id"
		  ,"GroupId"
	 	,"Mode"
	)
	SELECT
		ins."Id",
		ins."GroupId",
		 ins."Mode"
	FROM "inserted" ins;
	IF EXISTS(SELECT 1 FROM "TempDocumentIds" tdi WHERE tdi."Mode" = 'U' )	
	THEN
	UPDATE
		einvoice."Documents" d
	SET 
		"EntityId" = td."EntityId",
		"ParentEntityId" = td."ParentEntityId",
		"UserId" = "_UserId",
		"StatisticId" = td."StatisticId",
		"SeriesCode" = td."SeriesCode",
		"Purpose" = td."Purpose",
		"SupplyType" = td."SupplyType",
		"Type" = td."Type",
		"TransactionType" = td."TransactionType",
		"TransactionTypeDescription" = td."TransactionTypeDescription",
		"TaxpayerType" = td."TaxpayerType",						 
		"DocumentNumber" = td."DocumentNumber",
		"DocumentDate" = td."DocumentDate",
		"ReferenceId" = td."ReferenceId",
		"TransactionMode" = td."TransactionMode",
		"RefDocumentRemarks" = td."RefDocumentRemarks",
		"RefDocumentPeriodStartDate"= td."RefDocumentPeriodStartDate",
		"RefDocumentPeriodEndDate" = td."RefDocumentPeriodEndDate",
		"RefPrecedingDocumentDetails" = td."RefPrecedingDocumentDetails",
		"RefContractDetails" = td."RefContractDetails",
		"AdditionalSupportingDocumentDetails" = td."AdditionalSupportingDocumentDetails",
		"BillNumber" = td."BillNumber",
		"BillDate" = td."BillDate",
		"PortCode" = td."PortCode",
		"DocumentCurrencyCode" = td."DocumentCurrencyCode",
		"DestinationCountry" = td."DestinationCountry",
		"ExportDuty" = td."ExportDuty",
		"Pos" = td."Pos",
		"DocumentValue" = td."DocumentValue",
		"DocumentDiscount" = td."DocumentDiscount",
		"DocumentOtherCharges" = td."DocumentOtherCharges",
		"DocumentValueInForeignCurrency" = td."DocumentValueInForeignCurrency",
		"DocumentValueInRoundOffAmount" = td."DocumentValueInRoundOffAmount",
		"ReverseCharge" = td."ReverseCharge",
		"ClaimRefund" = td."ClaimRefund",
		"UnderIgstAct" = td."UnderIgstAct",
		"ECommerceGstin" = td."ECommerceGstin",
		"TransporterId" = td."TransporterId",
		"TransporterName" = td."TransporterName",
		"VehicleType" = td."VehicleType",
		"ToEmailAddresses" = td."ToEmailAddresses",
		"ToMobileNumbers" = td."ToMobileNumbers",
		"TotalTaxableValue" = td."TotalTaxableValue",
		"TotalTaxAmount" = td."TotalTaxAmount",
		"ReturnPeriod" = td."ReturnPeriod",
		"FinancialYear" = td."FinancialYear",
		"DocumentFinancialYear" = td."DocumentFinancialYear",
		"SourceType" = td."SourceType",
		"SectionType" = td."SectionType",
		"AttachmentStreamId"  =td."AttachmentStreamId",
		"DocumentReturnPeriod" = td."DocumentReturnPeriod",
		"ModifiedStamp" =  NOW()::timestamp without time zone,
		"RequestId" = "_RequestId"
    FROM
		"TempDocumentIds" tdi
		INNER JOIN "TempDocuments" AS td ON td."GroupId" = tdi."GroupId"
	WHERE
		tdi."Id" = d."Id"
		AND tdi."Mode" = 'U';

	
 	UPDATE
		einvoice."DocumentStatus" ds
	SET 
		"PushStatus" = td."EInvoicePushStatus",
		"Irn" = td."Irn",
		"Status" = td."DocumentStatus",
		"Errors" = null,
		"CancelRemark" = null,
		"ModifiedStamp" = NOW()::timestamp without time zone,
		"RequestId" = "_RequestId",
		"UserAction" = "_UserActionTypeEdit"
	FROM
		"TempDocumentIds" AS tdi
		INNER JOIN "TempDocuments" AS td ON td."GroupId" = tdi."GroupId"
	WHERE 
		tdi."Id" = ds."DocumentId"
		AND tdi."Mode" = 'U';
	
	UPDATE
		ewaybill."DocumentStatus" ds				 
	SET 
		"PushStatus" = td."EwaybillPushStatus",
		"Distance" = td."Distance",
		"TransportDateTime"= td."TransportDateTime",
		"Irn" = td."Irn",
		"Status" = td."DocumentStatus",
		"Errors" = null,
		"Remarks" = null,
		"ModifiedStamp" = NOW()::timestamp without time zone,
		"RequestId" = "_RequestId",
		"UserAction" = "_UserActionTypeEdit"
	FROM
		"TempDocumentIds" AS tdi
		INNER JOIN "TempDocuments" AS td ON td."GroupId" = tdi."GroupId"
	WHERE 
	 tdi."Id" = ds."DocumentId"
	 AND tdi."Mode" = 'U';		
END IF; 
	INSERT INTO einvoice."DocumentStatus"
	(
		"DocumentId",
		"Irn",
		"PushStatus",
		"Status",
		"RequestId",
		"UserAction"
	)
	SELECT 
		tdi."Id",
		td."Irn",		
		td."EInvoicePushStatus",
		td."DocumentStatus",
		"_RequestId",
		"_UserActionTypeCreate"
	FROM
		"TempDocumentIds" AS tdi
		INNER JOIN "TempDocuments" AS td ON td."GroupId" = tdi."GroupId"
	WHERE 
		tdi."Mode" = 'I';
		
	INSERT INTO ewaybill."DocumentStatus"
	(
		"DocumentId",
		"Distance",
		"TransportDateTime",
		"Irn",
		"PushStatus",
		"Status",
		"IsMultiVehicleMovementInitiated",
		"RequestId",
		"UserAction"
	)
	SELECT
		tdi."Id",
		td."Distance",
		td."TransportDateTime",
		td."Irn",
		td."EwaybillPushStatus",
		td."DocumentStatus",
		false,
		"_RequestId",
		"_UserActionTypeCreate"
	FROM
		"TempDocumentIds" AS tdi
		INNER JOIN "TempDocuments" AS td ON td."GroupId" = tdi."GroupId"
	WHERE 
		tdi."Mode" = 'I';
	
	
	INSERT INTO "TempUpsertDocumentIds"("Id")
	SELECT 
		tdi."Id"
	FROM 
		"TempDocumentIds" tdi;
	/* Delete DocumentItems for both Insert and Update Case  */	
	IF EXISTS (SELECT 1 FROM "TempDocumentIds")
	THEN
		SELECT 
			COUNT("AutoId")
		INTO
			"_Max"
		FROM 
			"TempDocumentIds";

		"_BatchSize" := CASE 
							WHEN COALESCE("_Max",0) > 100000 THEN (("_Max"*10)/100)
							ELSE "_Max"
						END;
		WHILE("_Min" <= "_Max") LOOP
		
			"_Records" := "_Min" + "_BatchSize";
			
			DELETE
			FROM 
				einvoice."DocumentItems" AS di
			USING 
				"TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = di."DocumentId" AND
				tdi."AutoId" BETWEEN "_Min" AND "_Records";				

			DELETE
			FROM 
				einvoice."DocumentReferences" AS dr
			USING 
				"TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = dr."DocumentId" AND
				tdi."AutoId" BETWEEN "_Min" AND "_Records";	

			DELETE
			FROM 
				einvoice."DocumentCustoms" AS dc
			USING 
				"TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = dc."DocumentId" AND
				tdi."AutoId" BETWEEN "_Min" AND "_Records";

			DELETE
			FROM 
				einvoice."DocumentPayments" AS dp
			USING 
				"TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = dp."DocumentId" AND
				tdi."AutoId" BETWEEN "_Min" AND "_Records";

			DELETE
			FROM 
				einvoice."DocumentContacts" AS dc
			USING 
				"TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = dc."DocumentId" AND
				tdi."AutoId" BETWEEN "_Min" AND "_Records";

			DELETE
			FROM 
				ewaybill."VehicleDetails" AS vd
			USING 
				"TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = vd."DocumentId" AND
				tdi."AutoId" BETWEEN "_Min" AND "_Records";
			
			"_Min" := "_Records";
			
		END LOOP;
		
	END IF;
		
	INSERT INTO einvoice."DocumentItems"
	(
		"DocumentId",
		"SerialNumber",
		"IsService",
		"Hsn",
		"ProductCode",
		"Name",
		"Description",
		"Barcode",
		"Uqc",
		"Quantity",
		"FreeQuantity",
		"Rate",
		"CessRate",
		"StateCessRate",
		"CessNonAdvaloremRate",
		"PricePerQuantity",
		"DiscountAmount",
		"GrossAmount",
		"OtherCharges",
		"TaxableValue",
		"PreTaxValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount",
		"StateCessAmount",
		"StateCessNonAdvaloremAmount",
		"CessNonAdvaloremAmount",
		"TaxType",
		"OrderLineReference",
		"OriginCountry",
		"ItemSerialNumber",
		"ItemTotal",
		"ItemAttributeDetails",
		"BatchNameNumber",
		"BatchExpiryDate",
		"WarrantyDate",
		"CustomItem1",
		"CustomItem2",
		"CustomItem3",
		"CustomItem4",
		"CustomItem5",
		"CustomItem6",
		"CustomItem7",
		"CustomItem8",
		"CustomItem9",
		"CustomItem10",
		"RequestId"
	)
	SELECT			
		 tdis."Id",
		 "SerialNumber",
		 "IsService",
		 "Hsn",
		 "ProductCode",
		 "Name",
		 "Description",
		 "Barcode",
		 "UQC",
		 "Quantity",
		 "FreeQuantity",
		 "Rate",
		 "CessRate",
		 "StateCessRate",
		 "CessNonAdvaloremRate",
		 "PricePerQuantity",
		 "DiscountAmount",
		 "GrossAmount",
		 "OtherCharges",
		 "TaxableValue",
		 "PreTaxValue",
		 "IgstAmount",
		 "CgstAmount",
		 "SgstAmount",
		 "CessAmount",
		 "StateCessAmount",
		 "StateCessNonAdvaloremAmount",
		 "CessNonAdvaloremAmount",
		 "TaxType",
		 "OrderLineReference",
		 "OriginCountry",
		 "ItemSerialNumber",
		 "ItemTotal",
		 "ItemAttributeDetails",
		 "BatchNameNumber",
		 "BatchExpiryDate",
		 "WarrantyDate",
		 "CustomItem1",
		 "CustomItem2",
		 "CustomItem3",
		 "CustomItem4",
		 "CustomItem5",
		 "CustomItem6",
		 "CustomItem7",
		 "CustomItem8",
		 "CustomItem9",
		 "CustomItem10",
		 "_RequestId"
	FROM
		"TempDocumentItems" AS tdi
		INNER JOIN "TempDocumentIds" AS tdis ON tdis."GroupId" = tdi."GroupId";

	
	INSERT INTO einvoice."DocumentReferences"
	(
		"DocumentId",
		"DocumentNumber",
		"DocumentDate"
	)
	SELECT
		tdids."Id",
		tdr."DocumentNumber",
		tdr."DocumentDate"
	FROM
		"TempDocumentReferences" AS tdr
		INNER JOIN "TempDocumentIds" AS tdids ON tdr."GroupId" = tdids."GroupId";

	INSERT INTO einvoice."DocumentCustoms"
	(
		"DocumentId",
		"Custom1",
		"Custom2",
		"Custom3",
		"Custom4",
		"Custom5",
		"Custom6",
		"Custom7",
		"Custom8",
		"Custom9",
		"Custom10",
		"RequestId"
	)
	SELECT
		tdids."Id",
		tdc."Custom1",
		tdc."Custom2",
		tdc."Custom3",
		tdc."Custom4",
		tdc."Custom5",
		tdc."Custom6",
		tdc."Custom7",
		tdc."Custom8",
		tdc."Custom9",
		tdc."Custom10",
		"_RequestId"
	FROM
		"TempDocumentCustoms" AS tdc
		INNER JOIN "TempDocumentIds" AS tdids ON tdc."GroupId" = tdids."GroupId";
		
	INSERT INTO einvoice."DocumentPayments"
	(
		"DocumentId",
		"PaymentMode",
		"AdvancePaidAmount",
		"PaymentDate",
		"PaymentDueDate",
		"PaymentTerms",
		"PaymentInstruction",
		"PayeeName",
		"UpiId",
		"PayeeAccountNumber",
		"PayeeMerchantCode",
		"PaymentAmountDue",
		"Ifsc",
		"CreditTransfer",
		"DirectDebit",
		"CreditDays",
		"TransactionId",
		"TransactionReferenceId",
		"TransactionNote",
		"PaymentMinimumAmount",
		"TransactionReferenceUrl",
		"RequestId"
	)
	SELECT
		tdids."Id",
		tdp."PaymentMode",
		tdp."AdvancePaidAmount",
		tdp."PaymentDate",
		tdp."PaymentDueDate",
		tdp."PaymentTerms",
		tdp."PaymentInstruction",
		tdp."PayeeName",
		tdp."UpiId",
		tdp."PayeeAccountNumber",
		tdp."PayeeMerchantCode",
		tdp."PaymentAmountDue",
		tdp."Ifsc",
		tdp."CreditTransfer",
		tdp."DirectDebit",
		tdp."CreditDays",
		tdp."TransactionId",
		tdp."TransactionReferenceId",
		tdp."TransactionNote",
		tdp."PaymentMinimumAmount",
		tdp."TransactionReferenceUrl",
		"_RequestId"
	FROM
		"TempDocumentPayments" AS tdp
		INNER JOIN "TempDocumentIds" AS tdids ON tdp."GroupId" = tdids."GroupId";
	
	INSERT INTO einvoice."DocumentContacts"
    (	
		"DocumentId",
        "Gstin",
        "LegalName",
        "TradeName",
        "VendorCode",
        "AddressLine1",
        "AddressLine2",
        "City",
        "StateCode",
        "Pincode",
        "Phone",
        "Email",
        "Type",
		"RequestId"
	)
	SELECT
		tdids."Id",
		tdc."Gstin",
        tdc."LegalName",
        tdc."TradeName",
        tdc."VendorCode",
        tdc."AddressLine1",
        CASE WHEN tdc."AddressLine2" = '.' OR tdc."AddressLine2" = '-' THEN NULL ELSE tdc."AddressLine2" END,
        tdc."City",
        tdc."StateCode",
        tdc."Pincode",
        tdc."Phone",
        tdc."Email",
        tdc."Type",
		"_RequestId"
	FROM
		"TempDocumentConctacts" AS tdc
		INNER JOIN "TempDocumentIds" AS tdids ON tdc."GroupId" = tdids."GroupId";
	
	INSERT INTO ewaybill."VehicleDetails"
	(
		"DocumentId",
		"TransportMode",
		"TransportDocumentNumber",
		"TransportDocumentDate",
		"VehicleNumber",
		"FromState",
		"FromCity",
		"IsLatest",
		"Type",
		"PushStatus",
		"RequestId"
	)
	SELECT 
		tdi."Id",
		td."TransportMode",
		td."TransportDocumentNumber",
		td."TransportDocumentDate",
		td."VehicleNumber",
		COALESCE(tdcd."StateCode", tdcb."StateCode"),
		COALESCE(tdcd."City", tdcb."City"),
		true,
		td."VehicleType",
		"_EwayBillPushStatusGenerated",
		"_RequestId"
	FROM
		"TempDocumentIds" AS tdi
		INNER JOIN "TempDocuments" AS td ON td."GroupId" = tdi."GroupId"
		LEFT JOIN "TempDocumentConctacts" tdcb ON (tdcb."GroupId" = tdi."GroupId" AND tdcb."Type" = "_ContactTypeBillFrom")
		LEFT JOIN "TempDocumentConctacts" tdcd ON (tdcd."GroupId" = tdi."GroupId" AND tdcd."Type" = "_ContactTypeDispatchFrom")
	WHERE 		
		td."TransportMode" IS NOT NULL; /* TransportMode is mandatory for EWB, no need when TransportationId is supplied */
		
	/* SPs executed to Insert/Update data into DW tables */	
	PERFORM einvoice."InsertEinvoiceDocumentDW"
		(
			"_DocumentTypeDBN" := "_DocumentTypeDBN",
			"_DocumentTypeCRN" := "_DocumentTypeCRN"
		);
	
	RETURN QUERY
	SELECT
		tdi."Id",
		tdi."GroupId"
	FROM
		"TempDocumentIds" as tdi;
		
END;
$function$
;
DROP FUNCTION IF EXISTS  oregular."InsertPurchaseDocumentRecoCancelledCreditNotes";

CREATE OR REPLACE FUNCTION oregular."InsertPurchaseDocumentRecoCancelledCreditNotes"("_ParentEntityId" integer, "_FinancialYear" integer, "_SubscriberId" integer, "_DocumentTypeINV" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeCRN" smallint, "_NearMatchCancelledInvoiceToleranceFrom" numeric, "_NearMatchCancelledInvoiceToleranceTo" numeric, "_ReconciliationSectionTypePrDiscarded" smallint DEFAULT 9, "_ReconciliationSectionTypeGstDiscarded" smallint DEFAULT 10, "_ReconciliationSectionTypeGstOnly" smallint DEFAULT 2, "_CancelledInvoiceReasonType" character varying DEFAULT '8589934592'::bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: oregular."InsertGstr2bDocumentPotentialMatchReco 
* 	Comments			: 17-01-2023 | Chetan Saini	|  Added test execution and modification done.						 																					
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		
					SELECT * FROM oregular."InsertPurchaseDocumentRecoCancelledCreditNotes"(
							"_ParentEntityId":=16882:: integer,
							"_FinancialYear":=202324::integer,
							"_SubscriberId":=164:: integer,
							"_DocumentTypeINV":=1::smallint,
							"_DocumentTypeDBN":=2:: smallint,
							"_DocumentTypeCRN":=3:: smallint,
							"_NearMatchCancelledInvoiceToleranceFrom" := 50::numeric,
							"_NearMatchCancelledInvoiceToleranceTo" := 100::numeric,
							"_ReconciliationSectionTypePrDiscarded":=9:: smallint,
							"_ReconciliationSectionTypeGstDiscarded":=10:: smallint);	
*/--------------------------------------------------------------------------------------------------------------------------------------
BEGIN

	DROP TABLE IF EXISTS "TempCrossDocumentMatchedData";						   
	CREATE TEMP TABLE "TempCrossDocumentMatchedData"("Id" SERIAL, "PrId" BIGINT , "GstnId" BIGINT,"Preference" smallint,"Source" CHARACTER VARYING,"ReturnPeriod" INT);  
		
	RAISE NOTICE 'CancelledCreditNotes Step 1 %', clock_timestamp()::timestamp without time zone;
	
	INSERT INTO "TempCrossDocumentMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
	SELECT   
		Pr."Id" "PrId",Gstn."Id" "GstId",
		CASE WHEN Pr."DocumentType" = "_DocumentTypeINV" THEN 1::smallint
			 WHEN Pr."DocumentType" = "_DocumentTypeDBN" THEN 2::smallint	
		END,Pr."ReturnPeriod",'Pr'
	FROM  
		"TempPrOnlyData" Pr  
	INNER JOIN "TempGstnOnlyData" GSTN 
		ON Pr."SubscriberId" = GSTN."SubscriberId"			
		AND Pr."Gstin" = GSTN."Gstin"
		AND Pr."ParentEntityId" = GSTN."ParentEntityId"
		AND Pr."DocumentDate" = Gstn."DocumentDate"
	WHERE 
		GSTN."DocumentType" = "_DocumentTypeCRN"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo";
	
	RAISE NOTICE 'CancelledCreditNotes Step 2 %', clock_timestamp()::timestamp without time zone;
	
	INSERT INTO "TempCrossDocumentMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
	SELECT   
		Pr."Id" "PrId",Gstn."Id" "GstId",
		CASE WHEN Pr."DocumentType" = "_DocumentTypeINV" THEN 1::smallint
			 WHEN Pr."DocumentType" = "_DocumentTypeDBN" THEN 2::smallint	
		END,Pr."ReturnPeriod",'Pr'
	FROM  
		"TempPrOnlyData" Pr  
		INNER JOIN "TempGstnOnlyData" GSTN 
		ON 
			Pr."SubscriberId" = GSTN."SubscriberId"			
			AND Pr."Gstin" = GSTN."Gstin"
			AND Pr."ParentEntityId" = GSTN."ParentEntityId"
			AND Pr."FinancialYear" = Gstn."FinancialYear"
	WHERE 
		GSTN."DocumentType" = "_DocumentTypeCRN"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");

	RAISE NOTICE 'CancelledCreditNotes Step 3 %', clock_timestamp()::timestamp without time zone;
	
	/*Delete record with less preference*/

	DELETE
		FROM "TempCrossDocumentMatchedData" AS P0 
		USING "TempCrossDocumentMatchedData" AS P1
	WHERE 
		P1."Preference"= 1 
		AND P0."Preference" = 2
		AND P1."GstnId" = P0."GstnId";

	RAISE NOTICE 'CancelledCreditNotes Step 4 %', clock_timestamp()::timestamp without time zone;

	/* Gst crn comparison with gst inv */
	INSERT INTO "TempCrossDocumentMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
	SELECT   
		Pr."Id" "PrId",Gstn."Id" "GstId",
		1,Pr."ReturnPeriod",'Gstn'
	FROM  
		"TempGstnOnlyData" Pr  
	INNER JOIN "TempGstnOnlyData" GSTN 
			ON 
				Pr."SubscriberId" = GSTN."SubscriberId"			
				AND Pr."Gstin" = GSTN."Gstin"
				AND Pr."ParentEntityId" = GSTN."ParentEntityId"
				AND Pr."DocumentDate" = Gstn."DocumentDate"
	WHERE 
		GSTN."DocumentType" = "_DocumentTypeCRN"
		AND Pr."DocumentType" = "_DocumentTypeINV"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");

	RAISE NOTICE 'CancelledCreditNotes Step 5 %', clock_timestamp()::timestamp without time zone;

	INSERT INTO "TempCrossDocumentMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
	SELECT   
		Pr."Id" "PrId",Gstn."Id" "GstId",1,Pr."ReturnPeriod",'Gstn'
	FROM  
		"TempGstnOnlyData" Pr  
		INNER JOIN "TempGstnOnlyData" GSTN 
		ON 
			Pr."SubscriberId" = GSTN."SubscriberId"			
			AND Pr."Gstin" = GSTN."Gstin"
			AND Pr."ParentEntityId" = GSTN."ParentEntityId"
			AND Pr."FinancialYear" = Gstn."FinancialYear"
	WHERE 
		GSTN."DocumentType" = "_DocumentTypeCRN"
		AND Pr."DocumentType" = "_DocumentTypeINV"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");

	
	RAISE NOTICE 'CancelledCreditNotes Step 6 %', clock_timestamp()::timestamp without time zone;
	
	/* Gst crn comparison with gst inv */
	INSERT INTO "TempCrossDocumentMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
	SELECT   
		Pr."Id" "PrId",Gstn."Id" "GstId",
		1,Pr."ReturnPeriod",'Gstn'
	FROM  
		"TempGstnOnlyData" Pr  
	INNER JOIN "TempGstnOnlyData" GSTN 
			ON 
				Pr."SubscriberId" = GSTN."SubscriberId"			
				AND Pr."Gstin" = GSTN."Gstin"
				AND Pr."ParentEntityId" = GSTN."ParentEntityId"
				AND Pr."DocumentDate" = Gstn."DocumentDate"
	WHERE 
		GSTN."DocumentType" = "_DocumentTypeCRN"
		AND Pr."DocumentType" = "_DocumentTypeDBN"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");

	RAISE NOTICE 'CancelledCreditNotes Step 7 %', clock_timestamp()::timestamp without time zone;

	INSERT INTO "TempCrossDocumentMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
	SELECT   
		Pr."Id" "PrId",Gstn."Id" "GstId",1,Pr."ReturnPeriod",'Gstn'
	FROM  
		"TempGstnOnlyData" Pr  
		INNER JOIN "TempGstnOnlyData" GSTN 
		ON 
			Pr."SubscriberId" = GSTN."SubscriberId"			
			AND Pr."Gstin" = GSTN."Gstin"
			AND Pr."ParentEntityId" = GSTN."ParentEntityId"
			AND Pr."FinancialYear" = Gstn."FinancialYear"
	WHERE 
		GSTN."DocumentType" = "_DocumentTypeCRN"
		AND Pr."DocumentType" = "_DocumentTypeDBN"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");
	
	RAISE NOTICE 'CancelledCreditNotes Step 8 %', clock_timestamp()::timestamp without time zone;
	
	WITH "GstnCTE"  
	AS  
	(  
		SELECT  
			ROW_NUMBER() OVER(PARTITION BY M."GstnId" ORDER BY "ReturnPeriod") "RowNum", *    
		FROM  
			"TempCrossDocumentMatchedData" M  				
	)  
	DELETE 
	FROM		  
		"TempCrossDocumentMatchedData" WHERE "Id" IN(SELECT "Id" FROM "GstnCTE"	WHERE "RowNum" > 1); 
	
	RAISE NOTICE 'CancelledCreditNotes Step 9 %', clock_timestamp()::timestamp without time zone;
	 
	WITH "PrCTE"  
	AS  
	(  
		SELECT  
			ROW_NUMBER() OVER(PARTITION BY M."PrId" ORDER BY "ReturnPeriod") "RowNum", *    
		FROM  
			"TempCrossDocumentMatchedData" M  
	)  
	DELETE 
	FROM
		"TempCrossDocumentMatchedData" WHERE "Id" IN(SELECT "Id" FROM "PrCTE"	WHERE "RowNum" > 1);
		
	RAISE NOTICE 'CancelledCreditNotes Step 10 %', clock_timestamp()::timestamp without time zone;
	
	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_CancelledInvoiceReasonType" ,',"Value":"',CONCAT(gd."DocumentNumber", '#', TO_CHAR(gd."DocumentDate", 'DD-MM-YYYY')),'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_CancelledInvoiceReasonType"
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', TO_CHAR(gd."DocumentDate", 'DD-MM-YYYY')),'"},')) END, 
			"ReasonType" = "_CancelledInvoiceReasonType"::BIGINT  + COALESCE(pdrm."ReasonType", 0),
			"CancelledInvoiceId" = t_pdrm."GstnId"
	FROM
		"TempCrossDocumentMatchedData" t_pdrm
	INNER JOIN Oregular."Gstr2bDocumentRecoMapper" pdrm ON t_pdrm."PrId" = pdrm."PrId"
	INNER JOIN "TempGstnOnlyData" gd ON  t_pdrm."GstnId" = gd."Id"
	WHERE
		pdr."Id" = pdrm."Id"
		AND COALESCE(pdr."Reason",'[]') NOT LIKE '%' || "_CancelledInvoiceReasonType" || '%'
		AND t_pdrm."Source" = 'Pr'; 
	
	RAISE NOTICE 'CancelledCreditNotes Step 11 %', clock_timestamp()::timestamp without time zone;
	
	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_CancelledInvoiceReasonType" ,',"Value":"',CONCAT(gd."DocumentNumber", '#', TO_CHAR(gd."DocumentDate", 'DD-MM-YYYY')),'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_CancelledInvoiceReasonType"
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', TO_CHAR(gd."DocumentDate", 'DD-MM-YYYY')),'"},')) END, 
			"ReasonType" = "_CancelledInvoiceReasonType"::BIGINT  + COALESCE(pdrm."ReasonType", 0),
			"CancelledInvoiceId" = t_pdrm."GstnId"
	FROM
		"TempCrossDocumentMatchedData" t_pdrm
	INNER JOIN Oregular."Gstr2bDocumentRecoMapper" pdrm ON t_pdrm."PrId" = pdrm."GstnId"
	INNER JOIN "TempGstnOnlyData" gd ON  t_pdrm."GstnId" = gd."Id"
	WHERE
		pdr."Id" = pdrm."Id"
		AND COALESCE(pdr."Reason",'[]') NOT LIKE '%' || "_CancelledInvoiceReasonType" || '%'
		AND t_pdrm."Source" = 'Gstn'; 

	RAISE NOTICE 'CancelledCreditNotes Step 12 %', clock_timestamp()::timestamp without time zone;

	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_CancelledInvoiceReasonType" ,',"Value":"',CASE WHEN pd."DocumentNumber" IS NOT NULL THEN CONCAT(pd."DocumentNumber", '#', TO_CHAR(pd."DocumentDate", 'DD-MM-YYYY')) ELSE CONCAT(gd."DocumentNumber", '||', TO_CHAR(gd."DocumentDate", 'DD-MM-YYYY')) END,'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_CancelledInvoiceReasonType"
													,',"Value":"',CASE WHEN pd."DocumentNumber" IS NOT NULL THEN CONCAT(pd."DocumentNumber", '#',TO_CHAR(pd."DocumentDate", 'DD-MM-YYYY')) ELSE CONCAT(gd."DocumentNumber", '||', TO_CHAR(gd."DocumentDate", 'DD-MM-YYYY')) END,'"},')) END, 
			"ReasonType" = "_CancelledInvoiceReasonType"::BIGINT  + COALESCE(pdrm."ReasonType", 0),
			"CancelledInvoiceId" = t_pdrm."PrId"
	FROM
		"TempCrossDocumentMatchedData" t_pdrm
	INNER JOIN Oregular."Gstr2bDocumentRecoMapper" pdrm ON t_pdrm."GstnId" = pdrm."GstnId"
	LEFT JOIN "TempGstnOnlyData" gd ON  t_pdrm."PrId" = gd."Id" AND t_pdrm."Source" = 'Gstn'
	LEFT JOIN "TempPrOnlyData" pd ON  t_pdrm."PrId" = pd."Id" AND t_pdrm."Source" = 'Pr'
	WHERE
		pdr."Id" = pdrm."Id"
		AND COALESCE(pdr."Reason",'[]') NOT LIKE '%' || "_CancelledInvoiceReasonType" || '%'; 
	
	RAISE NOTICE 'Short Case Step 13 %', clock_timestamp()::timestamp without time zone;		
	
END;
$function$
;
