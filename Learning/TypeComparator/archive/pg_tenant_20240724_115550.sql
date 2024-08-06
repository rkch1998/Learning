DROP FUNCTION IF EXISTS oregular."InsertDownloadedSaleDocuments";

CREATE OR REPLACE FUNCTION oregular."InsertDownloadedSaleDocuments"("_SubscriberId" integer, "_UserId" integer, "_EntityId" integer, "_ReturnPeriod" integer, "_FinancialYear" integer, "_IsAutoDrafted" boolean, "_Gstin" character varying, "_SourceType" smallint, "_SectionType" bigint, "_IsAmendment" boolean, "_IsAutoDraftSummaryGenerationEnabled" boolean, "_SaleDocuments" oregular."DownloadedSaleDocumentType"[], "_SaleDocumentContacts" oregular."DownloadedSaleDocumentContactType"[], "_SaleDocumentItems" oregular."DownloadedSaleDocumentItemType"[], "_DocumentReferences" common."DocumentReferenceType"[], "_AuditTrailDetails" audit."AuditTrailDetailsType"[], "_MismatchErrors" character varying, "_PushToGstStatusUploadedButNotPushed" smallint, "_PushToGstStatusPushed" smallint, "_PushToGstStatusCancelled" smallint, "_SourceTypeAutoDraft" smallint, "_SourceTypeTaxpayer" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeCRN" smallint, "_TaxTypeTAXABLE" smallint, "_ContactTypeBillTo" smallint, "_PushToGstStatusDeleted" smallint, "_GstinErrorTypeApiSectionMismatch" smallint)
 RETURNS TABLE("Id" bigint, "SectionType" bigint, "DocumentDate" timestamp without time zone, "ECommerceGstin" character varying, "TransactionType" smallint, "DocumentNumber" character varying, "DocumentFinancialYear" integer, "DocumentType" smallint, "PlanLimitApplicable" boolean, "GroupId" integer)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	"_CurrentDate" TIMESTAMP WITHOUT TIME ZONE := NOW();
	"_Min" INT := 1; 
	"_Max" INT;
	"_BatchSize" INT; 
	"_Records" INT;
BEGIN

	DROP TABLE IF EXISTS "TempSaleDocumentIds","TempUpsertDocumentIds","TempSaleDocuments","TempSaleDocumentReferences","TempSaleDocumentItems","TempSaleDocumentContacts";
	
	IF (ARRAY_LENGTH("_AuditTrailDetails",1) > 0) 
	THEN
		PERFORM audit."UpdateAuditDetails"("_AuditTrailDetails");
	END IF;
	
	/*Adding Temp tables and Data from TableType Parameters*/
	CREATE TEMPORARY TABLE "TempSaleDocumentIds"(
		"AutoId" INT GENERATED ALWAYS AS IDENTITY,
		"Id" BIGINT,
		"EInvoiceDocumentId" BIGINT,
		"GroupId" INT,
		"BillingDate" TIMESTAMP WITHOUT TIME ZONE,
		"SourceType" SMALLINT,
		"SectionType" BIGINT,
		"ECommerceGstin" VARCHAR(15),
		"DocumentDate" TIMESTAMP WITHOUT TIME ZONE,
		"TransactionType" SMALLINT,
		"SeriesCode" VARCHAR(16),
		"Mode" CHAR(2),
		"DocumentNumber" VARCHAR(40),
		"DocumentFinancialYear" INT,
		"DocumentType" SMALLINT
	);

	CREATE TEMPORARY TABLE "TempUpsertDocumentIds"(
		"Id" BIGINT NOT NULL	
	);
	
	CREATE INDEX "IDX_TempUpsertDocumentIds" ON "TempUpsertDocumentIds" ("Id");

	CREATE TEMPORARY TABLE "TempSaleDocuments" AS
	SELECT 
		*
	FROM  
		UNNEST("_SaleDocuments");
		
	CREATE TEMPORARY TABLE "TempSaleDocumentReferences" AS
	SELECT 
		*
	FROM  
		UNNEST("_DocumentReferences");
		
	CREATE TEMPORARY TABLE "TempSaleDocumentItems" AS
	SELECT 
		*
	FROM  
		UNNEST("_SaleDocumentItems");
		
	CREATE TEMPORARY TABLE "TempSaleDocumentContacts" AS
	SELECT 
		*
	FROM  
		UNNEST("_SaleDocumentContacts");

	/*Mapping record with overwrite scenarios*/
	/*
	Flag Description
	U : Update.
	UE : Update Section Mismatch records.
	AU : AutoDrafted Record Overwrite.
	C : Cancelled record, Cancelling AutoPopulated records.
	F : Update IsAutoDrafted = 0, Because Deleted records are overwrited by user.
	S : Skip overwriting, Because Record is not autodrafted status anymore.
	*/
	
	INSERT INTO "TempSaleDocumentIds"
	(
		"Id",
		"GroupId",
		"Mode",
		"BillingDate",
		"SourceType",
		"SectionType",
		"DocumentDate",
		"ECommerceGstin",
		"TransactionType",
		"DocumentNumber",
		"DocumentFinancialYear",
		"DocumentType"
	)
	SELECT
	   sd."Id",
	   tsd."GroupId",
	   CASE 
			WHEN "_SourceType" = "_SourceTypeAutoDraft" THEN 'U'
			WHEN "_SourceType" = "_SourceTypeTaxpayer" AND sd."SectionType" & "_SectionType" = 0 THEN 'UE' 
			WHEN "_SourceType" = "_SourceTypeTaxpayer" AND "_IsAutoDrafted" = FALSE THEN 'U' 
			WHEN "_SourceType" = "_SourceTypeTaxpayer" AND ss."IsAutoDrafted" = True AND ss."IsPushed" = True AND tsd."PushStatus" = "_PushToGstStatusPushed" AND ss."PushStatus" = "_PushToGstStatusPushed" AND COALESCE(tsd."AutoDraftSource",'') = COALESCE(ss."AutoDraftSource",'') THEN 'AU'  /*ToDo : Ask for manual sync autopopulation*/
			WHEN "_SourceType" = "_SourceTypeTaxpayer" AND "_IsAutoDrafted" = TRUE AND ss."IsAutoDrafted" = True AND ss."IsPushed" = TRUE AND tsd."PushStatus" = "_PushToGstStatusCancelled" AND ss."PushStatus" = "_PushToGstStatusPushed" THEN 'C'
			WHEN "_SourceType" = "_SourceTypeTaxpayer" AND "_IsAutoDrafted" = TRUE AND ss."IsAutoDrafted" = True AND ss."IsPushed" = TRUE AND tsd."PushStatus" = "_PushToGstStatusCancelled" THEN 'F' 
			ELSE 'S'
	   END,
	   COALESCE(ss."BillingDate","_CurrentDate"),
	   sd."SourceType",
	   sd."SectionType",
	   TO_DATE(sd."DocumentDate" :: text,'YYYYMMDD')::TIMESTAMP WITHOUT TIME ZONE,
	   sd."ECommerceGstin",
	   sd."TransactionType",
	   sd."DocumentNumber",
	   sd."DocumentFinancialYear",
	   sd."DocumentType"
	FROM
		"TempSaleDocuments" tsd
		INNER JOIN oregular."SaleDocumentDW" AS sd ON
		(
			sd."DocumentNumber" = tsd."DocumentNumber"
			AND sd."ParentEntityId" = "_EntityId"
			AND sd."DocumentFinancialYear" = tsd."DocumentFinancialYear" 
			AND sd."CombineDocumentType" = sd."CombineDocumentType"
			AND sd."SourceType" = "_SourceType"
			AND sd."IsAmendment" = "_IsAmendment"
			AND sd."SubscriberId" = "_SubscriberId"			
			AND sd."DocumentType" = tsd."DocumentType"			
		)
		INNER JOIN oregular."SaleDocumentStatus" ss ON sd."Id" = ss."SaleDocumentId";

	-- Insert Data For Sale Documnet

	WITH "Cte_Inserted" AS (
		
		INSERT INTO oregular."SaleDocuments"
		(
			"SubscriberId",
			"ParentEntityId",
			"EntityId",
			"UserId",
			"IsPreGstRegime",
			"Irn",
			"IrnGenerationDate",
			"DocumentType",
			"TransactionType",
			"TaxpayerType",
			"DocumentNumber",
			"DocumentDate",
			"BillNumber",
			"BillDate",
			"PortCode",
			"Pos",
			"DocumentValue",
			"DifferentialPercentage",
			"ReverseCharge",
			"ClaimRefund",
			"UnderIgstAct",
			"RefundEligibility",
			"ECommerceGstin",
			"OriginalDocumentNumber",
			"OriginalDocumentDate",		
			"SectionType",
			"TotalTaxableValue",
			"TotalTaxAmount",
			"TotalRateWiseTaxableValue",
			"TotalRateWiseTaxAmount",
			"ReturnPeriod",
			"DocumentFinancialYear",
			"FinancialYear",
			"IsAmendment",
			"SourceType",
			"RefPrecedingDocumentDetails",
			"GroupId",
			"CombineDocumentType",
			"TransactionNature",
			"DocumentReturnPeriod"
		)
		SELECT
			"_SubscriberId",
			"_EntityId",
			"_EntityId",
			"_UserId",
			tsd."IsPreGstRegime",
			tsd."Irn",
			tsd."IrnGenerationDate",
			tsd."DocumentType",
			tsd."TransactionType",
			tsd."TaxpayerType",
			tsd."DocumentNumber",
			tsd."DocumentDate",
			tsd."BillNumber",
			tsd."BillDate",
			tsd."PortCode",
			tsd."Pos",
			tsd."DocumentValue",
			tsd."DifferentialPercentage",
			tsd."ReverseCharge",
			tsd."ClaimRefund",
			tsd."UnderIgstAct",
			tsd."RefundEligibility",
			tsd."ECommerceGstin",
			tsd."OriginalDocumentNumber",
			tsd."OriginalDocumentDate",		
			"_SectionType",
			tsd."TotalTaxableValue",
			tsd."TotalTaxAmount",
			tsd."TotalRateWiseTaxableValue",
			tsd."TotalRateWiseTaxAmount",
			tsd."ReturnPeriod",
			tsd."DocumentFinancialYear",
			tsd."FinancialYear",
			"_IsAmendment",
			"_SourceType",
			tsd."RefPrecedingDocumentDetails",
			tsd."GroupId",
			CASE WHEN tsd."DocumentType" = "_DocumentTypeDBN" THEN "_DocumentTypeCRN" ELSE tsd."DocumentType" END AS "CombineDocumentType",
			tsd."TransactionNature",
			tsd."DocumentReturnPeriod"
		FROM
			"TempSaleDocuments" tsd 
		WHERE 
			tsd."GroupId" NOT IN (SELECT tsdi."GroupId" FROM "TempSaleDocumentIds" tsdi)
		RETURNING 
			oregular."SaleDocuments"."Id",
			oregular."SaleDocuments"."GroupId",
			oregular."SaleDocuments"."SourceType",
			oregular."SaleDocuments"."SectionType",
			oregular."SaleDocuments"."DocumentDate",
			oregular."SaleDocuments"."ECommerceGstin",
			oregular."SaleDocuments"."TransactionType",
			oregular."SaleDocuments"."DocumentNumber",
			oregular."SaleDocuments"."DocumentFinancialYear",
			oregular."SaleDocuments"."DocumentType"
	)
	INSERT INTO "TempSaleDocumentIds"(
		"Id", 
		"GroupId", 
		"Mode",
	 	"BillingDate",
		"SourceType",
		"SectionType",
		"DocumentDate",
		"ECommerceGstin",
		"TransactionType",
		"DocumentNumber",
		"DocumentFinancialYear",
		"DocumentType"
	)
	SELECT
		ci."Id", 
		ci."GroupId", 
		'I' AS "Mode",
		"_CurrentDate",
		ci."SourceType",
		ci."SectionType",
		ci."DocumentDate",
		ci."ECommerceGstin",
		ci."TransactionType",
		ci."DocumentNumber",
		ci."DocumentFinancialYear",
		ci."DocumentType"
	FROM
		"Cte_Inserted" ci;
	
	INSERT INTO oregular."SaleDocumentStatus"
	(
		"SaleDocumentId",
		"Status",
		"PushStatus",
		"Action",
		"IsPushed",
		"Checksum",
		"AutoDraftSource",
		"IsAutoDrafted",
		"CancelledDate",
		"Errors",
		"LastSyncDate",
		"OriginalReturnPeriod",
		"BillingDate"
	)
	SELECT  
		tsdids."Id" AS "SaleDocumentId",
		tsd."Status",
		tsd."PushStatus",
		tsd."Action",
		tsd."IsPushed",
		tsd."Checksum",
		tsd."AutoDraftSource",
		tsd."IsAutoDrafted",
		tsd."CancelledDate",
		tsd."Errors",
		"_CurrentDate",
		tsd."OriginalReturnPeriod",
		"_CurrentDate"
	FROM
		"TempSaleDocumentIds" AS tsdids
		INNER JOIN "TempSaleDocuments" tsd on tsdids."GroupId" = tsd."GroupId"
	WHERE 
		tsdids."Mode" = 'I';

	IF EXISTS(SELECT 1 FROM "TempSaleDocumentIds" AS tsdids WHERE tsdids."Mode" = 'U') THEN
	
		DROP TABLE IF EXISTS "TempSaleDocumentContactDetails";
	
		UPDATE
			oregular."SaleDocuments" AS sd
		SET
			"ParentEntityId" = "_EntityId",
			"EntityId" = "_EntityId",
			"UserId" = "_UserId",
			"IsPreGstRegime" = tsd."IsPreGstRegime",
			"Irn" = tsd."Irn",
			"IrnGenerationDate" = tsd."IrnGenerationDate",
			"DocumentType" = tsd."DocumentType",
			"TransactionType" = tsd."TransactionType",
			"TaxpayerType" = tsd."TaxpayerType",
			--SectionType = CASE WHEN sd.SectionType & @SectionType <> 0 THEN sd.SectionType ELSE sd.SectionType | @SectionType END, // As Discussed with abbas bhai reccord will b persisted in document and summary that will be wrong
			"DocumentNumber" = tsd."DocumentNumber",
			"DocumentDate" = tsd."DocumentDate",
			"BillNumber" = tsd."BillNumber",
			"BillDate" = tsd."BillDate",
			"PortCode" = tsd."PortCode",
			"Pos" = tsd."Pos",
			"DocumentValue" = tsd."DocumentValue",
			"DifferentialPercentage" = tsd."DifferentialPercentage",
			"ReverseCharge" = tsd."ReverseCharge",
			"ClaimRefund" = tsd."ClaimRefund",
			"UnderIgstAct" = tsd."UnderIgstAct",
			"RefundEligibility" = tsd."RefundEligibility",
			"ECommerceGstin" = tsd."ECommerceGstin",
			"OriginalDocumentNumber" = tsd."OriginalDocumentNumber",
			"OriginalDocumentDate" = tsd."OriginalDocumentDate",		
			"TotalRateWiseTaxableValue" = tsd."TotalRateWiseTaxableValue",
			"TotalRateWiseTaxAmount" = tsd."TotalRateWiseTaxAmount",
			"ReturnPeriod" = tsd."ReturnPeriod",
			"DocumentFinancialYear" = tsd."DocumentFinancialYear",
			"FinancialYear" = tsd."FinancialYear",
			"ModifiedStamp" = "_CurrentDate",
			"GroupId" = tsd."GroupId",
			"CombineDocumentType" = CASE WHEN tsd."DocumentType" = "_DocumentTypeDBN" THEN "_DocumentTypeCRN" ELSE tsd."DocumentType" END,
			"TransactionNature" = tsd."TransactionNature",
			"DocumentReturnPeriod" = tsd."DocumentReturnPeriod"
		FROM
			"TempSaleDocumentIds" AS tsdids 
			INNER JOIN "TempSaleDocuments" AS tsd ON tsd."GroupId" = tsdids."GroupId"
		WHERE
			tsdids."Id" = sd."Id"
			AND tsdids."Mode" = 'U';
			
		UPDATE
			oregular."SaleDocumentStatus" ss
		SET 
			"Status" = tsd."Status",
			"PushStatus" = CASE WHEN "_SourceType" = "_SourceTypeAutoDraft" AND ss."PushStatus" = "_PushToGstStatusDeleted" THEN ss."PushStatus" ELSE tsd."PushStatus" END,
			"IsPushed" = tsd."IsPushed",
			"Action" = tsd."Action",
			"Checksum" = tsd."Checksum",
			"IsAutoDrafted" = CASE WHEN ss."IsAutoDrafted" = TRUE AND "_SourceType" = "_SourceTypeTaxpayer" AND "_IsAutoDrafted" = FALSE AND tsd."Checksum" = ss."Checksum" THEN ss."IsAutoDrafted" ELSE tsd."IsAutoDrafted" END, --Handled condition for overwriting IsAutoDrafted flag in case of manaul gstr1 sync.
			"AutoDraftSource" = tsd."AutoDraftSource",
			"CancelledDate" = COALESCE(tsd."CancelledDate",ss."CancelledDate"),
			"Errors" = tsd."Errors",
			"BillingDate" = tsdids."BillingDate",
			"LastSyncDate" = "_CurrentDate",
			"ModifiedStamp" = "_CurrentDate",
			"OriginalReturnPeriod" = tsd."OriginalReturnPeriod"
		FROM
			"TempSaleDocumentIds" AS tsdids 
			INNER JOIN "TempSaleDocuments" tsd on tsdids."GroupId" = tsd."GroupId"
		WHERE 
			ss."SaleDocumentId" = tsdids."Id"
			AND tsdids."Mode" = 'U';

		/*Delete and Insert Contact details for BillTo detail*/
		CREATE TEMPORARY TABLE "TempSaleDocumentContactDetails" AS
		SELECT
			sdc."Id",	
			tsdi."Id" AS "SaleDocumentId",
			tsdc."Gstin",
			tsdc."TradeName",
			tsdc."LegalName",
			tsdc."Type"
			--CASE 
			--	WHEN tsdc.Gstin <> sdc.Gstin 
			--		 OR (ISNULL(sdc.TradeName,sdc.LegalName) IS NULL AND ISNULL(tsdc.TradeName,tsdc.LegalName) IS NOT NULL) 
			--	THEN @True 
			--	ELSE @False 
			--END AS UpdateContacts
		FROM 
			"TempSaleDocumentIds" AS tsdi 
			INNER JOIN oregular."SaleDocumentContacts" AS sdc ON tsdi."Id" = sdc."SaleDocumentId" AND sdc."Type" = "_ContactTypeBillTo"
			INNER JOIN "TempSaleDocumentContacts" tsdc ON tsdi."GroupId" = tsdc."GroupId" AND tsdc."Type" = "_ContactTypeBillTo"
		WHERE
			tsdi."Mode" = 'U';

		DELETE FROM 
			oregular."SaleDocumentContacts" AS sdc
		USING
			"TempSaleDocumentContactDetails" AS tsdcd 
		WHERE
			tsdcd."Id" = sdc."Id";
		
		INSERT INTO oregular."SaleDocumentContacts"
		(
			"SaleDocumentId",
			"Gstin",
			"TradeName",
			"LegalName",
			"Type"
		)
		SELECT
			tsdcd."SaleDocumentId",
			tsdcd."Gstin",
			tsdcd."TradeName",
			tsdcd."LegalName",
			tsdcd."Type"
		FROM
			"TempSaleDocumentContactDetails" AS tsdcd;

		DROP TABLE IF EXISTS "TempSaleDocumentContactDetails";
	
	END IF;
	
	/* Delete SaleDocumentItems and contacts */
	IF EXISTS (SELECT "AutoId" FROM "TempSaleDocumentIds" WHERE "Mode" = 'U') THEN

		SELECT 
			COUNT("AutoId")
		INTO
			"_Max"
		FROM 
			"TempSaleDocumentIds";

		"_BatchSize" := CASE 
							WHEN COALESCE("_Max",0) > 100000 
								THEN (("_Max"*10)/100)
							ELSE "_Max"
						END;
						
		WHILE "_Min" <= "_Max" LOOP
		
			"_Records" := "_Min" + "_BatchSize";

			DELETE FROM	
				oregular."SaleDocumentRateWiseItems" AS sdri
			USING
				"TempSaleDocumentIds" AS tsdids
			WHERE 
				tsdids."Id" = sdri."SaleDocumentId"
				AND tsdids."Mode" = 'U'
				AND tsdids."AutoId" BETWEEN "_Min" AND "_Records";
				
			"_Min" := "_Records";
		
		END LOOP;
		
	END IF;
	
	INSERT INTO "TempUpsertDocumentIds" (
		"Id"
	)
	SELECT 
		tsdi."Id" 
	FROM 
		"TempSaleDocumentIds" tsdi;
	
	INSERT INTO "oregular"."SaleDocumentContacts"
	(
		"SaleDocumentId",
		"Gstin",
		"TradeName",
		"LegalName",
		"Type"
	)
	SELECT
		tsdids."Id",
		tsdc."Gstin",
		tsdc."TradeName",
		tsdc."LegalName",
		tsdc."Type"
	FROM
		"TempSaleDocumentContacts" AS tsdc
		INNER JOIN "TempSaleDocumentIds" AS tsdids ON tsdc."GroupId" = tsdids."GroupId"
	WHERE
		tsdids."Mode" = 'I';

	IF ("_IsAutoDraftSummaryGenerationEnabled" = TRUE) THEN /*Case when setting is on with checkbox selected*/
	
		UPDATE
			"TempSaleDocumentIds" AS tsdi
		SET
			"EInvoiceDocumentId" = d."Id",
			"SectionType" = d."SectionType",
			"SeriesCode" = d."SeriesCode",
			"ECommerceGstin" = tsd."ECommerceGstin",
			"DocumentDate" = tsd."DocumentDate",
			"TransactionType" = tsd."TransactionType"
		FROM
			"TempSaleDocuments" AS tsd
			INNER JOIN einvoice."DocumentStatus" AS ds ON ds."Irn" = tsd."Irn" 
			INNER JOIN einvoice."Documents" AS d ON d."Id" = ds."DocumentId"
		WHERE
			tsd."GroupId" = tsdi."GroupId"
			AND ds."Irn" IS NOT NULL
			AND tsdi."Mode" IN ('I','AU')
			AND d."SectionType" IS NOT NULL
			AND d."SubscriberId" = "_SubscriberId";
			
		DELETE FROM 
			oregular."SaleDocumentItems" AS sdi
		USING
			"TempSaleDocumentIds" AS tsdi
		WHERE 
			tsdi."Id" = sdi."SaleDocumentId"
			AND tsdi."Mode" = 'AU'
			AND tsdi."EInvoiceDocumentId" IS NOT NULL;

		INSERT INTO oregular."SaleDocumentItems"
		(
			"SaleDocumentId",
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
			"IgstAmount",
			"CgstAmount",
			"SgstAmount",
			"CessAmount",
			"StateCessAmount",
			"StateCessNonAdvaloremAmount",
			"CessNonAdvaloremAmount",
			"TaxType",
			"Stamp"
		)
		SELECT
			tsdi."Id",
			di."SerialNumber",
			di."IsService",
			di."Hsn",
			di."ProductCode",
			di."Name",
			di."Description",
			di."Barcode",
			di."Uqc",
			di."Quantity",
			di."FreeQuantity",
			di."Rate",
			di."CessRate",
			di."StateCessRate",
			di."CessNonAdvaloremRate",
			di."PricePerQuantity",
			di."DiscountAmount",
			di."GrossAmount",
			di."OtherCharges",
			di."TaxableValue",
			di."IgstAmount",
			di."CgstAmount",
			di."SgstAmount",
			di."CessAmount",
			di."StateCessAmount",
			di."StateCessNonAdvaloremAmount",
			di."CessNonAdvaloremAmount",
			COALESCE(di."TaxType", "_TaxTypeTAXABLE"),
			NOW()
		FROM
			"TempSaleDocumentIds" AS tsdi
			INNER JOIN einvoice."DocumentItems" AS di ON di."DocumentId" = tsdi."EInvoiceDocumentId"
		WHERE
			tsdi."Mode" IN ('I','AU')
			AND tsdi."EInvoiceDocumentId" IS NOT NULL;

		INSERT INTO oregular."SaleDocumentItems" /*Inserting item where Einvoice has data with irn is not available */
		(
			"SaleDocumentId",
			"TaxType",
			"Rate",
			"TaxableValue",
			"IgstAmount",
			"CgstAmount",
			"SgstAmount",
			"CessAmount",
			"GstActOrRuleSection"
		)
		SELECT
			tsdids."Id",
			tsdi."TaxType",
			tsdi."Rate",
			tsdi."TaxableValue",
			tsdi."IgstAmount",
			tsdi."CgstAmount",
			tsdi."SgstAmount",
			tsdi."CessAmount",
			tsdi."GstActOrRuleSection"
		FROM
			"TempSaleDocumentItems" AS tsdi
			INNER JOIN "TempSaleDocumentIds" AS tsdids ON tsdi."GroupId" = tsdids."GroupId"
		WHERE
			tsdids."Mode" = 'I'
			AND tsdids."EInvoiceDocumentId" IS NULL;

		UPDATE
			oregular."SaleDocuments" sd
		SET
			"SectionType" = tsdi."SectionType",
			"SeriesCode" = tsdi."SeriesCode"
		FROM
			"TempSaleDocumentIds" AS tsdi
			INNER JOIN einvoice."Documents" AS d ON d."Id" = tsdi."EInvoiceDocumentId"
		WHERE
			sd."Id" = tsdi."Id"
			AND tsdi."EInvoiceDocumentId" IS NOT NULL;

	ELSE

		INSERT INTO oregular."SaleDocumentItems"
		(
			"SaleDocumentId",
			"TaxType",
			"Rate",
			"TaxableValue",
			"IgstAmount",
			"CgstAmount",
			"SgstAmount",
			"CessAmount",
			"Stamp",
			"GstActOrRuleSection"
		)
		SELECT
			tsdids."Id",
			tsdi."TaxType",
			tsdi."Rate",
			tsdi."TaxableValue",
			tsdi."IgstAmount",
			tsdi."CgstAmount",
			tsdi."SgstAmount",
			tsdi."CessAmount",
			NOW(),
			tsdi."GstActOrRuleSection"
		FROM
			"TempSaleDocumentItems" AS tsdi
			INNER JOIN "TempSaleDocumentIds" AS tsdids ON tsdi."GroupId" = tsdids."GroupId"
		WHERE
			tsdids."Mode" = 'I';
	
	END IF;

	INSERT INTO oregular."SaleDocumentRateWiseItems"
	(
		"SaleDocumentId",
		"Rate",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		tsdids."Id",
		tsdi."Rate",
		tsdi."TaxableValue",
		tsdi."IgstAmount",
		tsdi."CgstAmount",
		tsdi."SgstAmount",
		tsdi."CessAmount"
	FROM
		"TempSaleDocumentItems" AS tsdi
		INNER JOIN "TempSaleDocumentIds" AS tsdids ON tsdi."GroupId" = tsdids."GroupId"
	WHERE
		tsdids."Mode" IN ('I', 'U');
		
	INSERT INTO oregular."SaleDocumentReferences"
	(
		"SaleDocumentId",
		"DocumentNumber",
		"DocumentDate"
	)
	SELECT
		tsdids."Id",
		tsdr."DocumentNumber",
		tsdr."DocumentDate"
	FROM
		"TempSaleDocumentReferences" AS tsdr
		INNER JOIN "TempSaleDocumentIds" AS tsdids ON tsdr."GroupId" = tsdids."GroupId"
	WHERE
		tsdids."Mode" = 'I';
		
	/*Updating cancelled records in Sale Status*/	
	UPDATE
		oregular."SaleDocumentStatus" ss
	SET 
		"Checksum" = tsd."Checksum",
		"CancelledDate" = tsd."CancelledDate",
		"PushStatus" = tsd."PushStatus",
		"Status" = tsd."Status",
		"BillingDate" = tsdi."BillingDate",
		"LastSyncDate" = "_CurrentDate",
		"ModifiedStamp" = "_CurrentDate"
	FROM
		"TempSaleDocumentIds" AS tsdi
		INNER JOIN "TempSaleDocuments" tsd on tsdi."GroupId" = tsd."GroupId"
	WHERE 
		ss."SaleDocumentId" = tsdi."Id"
		AND tsdi."Mode" = 'C';
		
	/*Updating user updated with IsAutoDrafted = 0 in Sale Status*/	
	UPDATE
		oregular."SaleDocumentStatus" ss
	SET 
		"IsAutoDrafted" = FALSE,
		"BillingDate" = tsdi."BillingDate",
		"LastSyncDate" = "_CurrentDate",
		"ModifiedStamp" = "_CurrentDate"
	FROM
		"TempSaleDocumentIds" AS tsdi 
		INNER JOIN "TempSaleDocuments" tsd on tsdi."GroupId" = tsd."GroupId"
	WHERE 
		ss."SaleDocumentId" = tsdi."Id"
		AND tsdi."Mode" = 'F';
		
	/*Updating Section mismatch error and marking record as not push so that the user can remove the record and related summary*/	
	IF EXISTS (SELECT 1 FROM "TempSaleDocumentIds" WHERE "Mode" = 'UE') THEN
	
		UPDATE
			oregular."SaleDocumentStatus" ss
		SET 
			"IsPushed" = false,
			"GstinError" = "_GstinErrorTypeApiSectionMismatch",
			"PushStatus" = CASE WHEN ss."PushStatus" = "_PushToGstStatusPushed" THEN "_PushToGstStatusUploadedButNotPushed" ELSE ss."PushStatus" END,
			"Errors" = "_MismatchErrors",
			"ModifiedStamp" = "_CurrentDate"
		FROM
			"TempSaleDocumentIds" AS tsdi 
			INNER JOIN "TempSaleDocuments" tsd on tsdi."GroupId" = tsd."GroupId"
		WHERE 
			ss."SaleDocumentId" = tsdi."Id"
			AND tsdi."Mode" = 'UE';
			
	END IF;
		
	/*Updating RET191248 error in Sale Status for production issue*/	
	IF EXISTS (SELECT 1 FROM "TempSaleDocumentIds" WHERE "Mode" = 'AU') THEN
	
		UPDATE
			oregular."SaleDocumentStatus" ss
		SET 
			"Checksum" = tsd."Checksum",
			"IsAutoDrafted" = tsd."IsAutoDrafted",
			"AutoDraftSource" = tsd."AutoDraftSource",
			"Errors" = tsd."Errors",
			"BillingDate" = tsdi."BillingDate",
			"LastSyncDate" = "_CurrentDate",
			"ModifiedStamp" = "_CurrentDate"
		FROM
			"TempSaleDocumentIds" AS tsdi 
			INNER JOIN "TempSaleDocuments" tsd on tsdi."GroupId" = tsd."GroupId"
		WHERE 
			ss."SaleDocumentId" = tsdi."Id"
			AND tsdi."Mode" = 'AU';
			
	END IF;
		
	/* Delete Autopopulated records which are delete  */
	IF EXISTS (SELECT 1 FROM "TempSaleDocumentIds" WHERE "Mode" = 'D') THEN
	
		DELETE FROM 
			oregular."SaleDocumentReferences" sdr
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sdr."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocumentItems" sdi
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sdi."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocumentRateWiseItems" sdri
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sdri."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocumentStatus" ss
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = ss."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocumentContacts" sdc
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sdc."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocumentPayments" sdp
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sdp."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocumentCustoms" sdc
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sdc."SaleDocumentId";
			
		DELETE FROM 
			oregular."SaleDocuments" sd
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = sd."Id";
			
		DELETE FROM 
			oregular."SaleDocumentDW" dw
		USING
			"TempSaleDocumentIds" AS tsdi 
		WHERE
			tsdi."Mode" = 'D'
			AND tsdi."Id" = dw."Id";

	END IF;
	
-- 	/* Condition For update sale data which are not on gst portal but exists in system in pushed state */
-- 	IF ("_IsAutoDrafted" = FALSE AND "_SourceType" = "_SourceTypeTaxpayer") 
-- 	THEN
-- 		WITH "Cte_Updated" AS (
-- 			UPDATE
-- 				oregular."SaleDocumentStatus" AS ss
-- 			SET
-- 				"PushStatus" = "_PushToGstStatusUploadedButNotPushed",
-- 				"IsPushed" = FALSE,
-- 				"IsAutoDrafted" = FALSE,
-- 				"LastSyncDate" = "_CurrentDate",
-- 				"BillingDate" = NULL,
-- 				"ModifiedStamp" = "_CurrentDate"
-- 			FROM
-- 				 oregular."SaleDocumentDW" AS dw 
-- 				 LEFT JOIN "TempSaleDocumentIds" AS tsdi ON tsdi."Id" = dw."Id" 
-- 			WHERE
-- 				ss."SaleDocumentId" = dw."Id"
-- 				AND dw."SubscriberId" = "_SubscriberId"
-- 				AND dw."EntityId" = "_EntityId"
-- 				AND dw."ReturnPeriod" = "_ReturnPeriod"
-- 				AND dw."SectionType" & "_SectionType" <> 0
-- 				AND dw."IsAmendment" = "_IsAmendment"
-- 				AND dw."SourceType" = "_SourceTypeTaxpayer"
-- -- 				AND dw."BillToGstin" = COALESCE("_Gstin", dw."BillToGstin")
-- 				AND ss."IsPushed" = TRUE
-- 				AND tsdi."Id" IS NULL
-- 			RETURNING
-- 				ss."SaleDocumentId"
-- 		)
-- 		INSERT INTO "TempUpsertDocumentIds" (
-- 			"Id"
-- 		)
-- 		SELECT 
-- 			"SaleDocumentId" 
-- 		FROM 
-- 			"Cte_Updated";
-- 	END IF;

	/* Function excuted to Insert/Update data into DW table */	
	PERFORM oregular."InsertSaleDocumentDW"(
		"_DocumentTypeDBN" => "_DocumentTypeDBN",
		"_DocumentTypeCRN" => "_DocumentTypeCRN"
	);

	RETURN QUERY
	SELECT
		tsd."Id",
		tsd."SectionType",
		tsd."DocumentDate",
		tsd."ECommerceGstin",
		tsd."TransactionType",
		tsd."DocumentNumber",
		tsd."DocumentFinancialYear",
		tsd."DocumentType",
		CASE WHEN tsd."BillingDate" = "_CurrentDate" THEN true ELSE false END AS "PlanLimitApplicable",
		tsd."GroupId"
	FROM
		"TempSaleDocumentIds" AS tsd;
		
	DROP TABLE IF EXISTS "TempSaleDocumentIds","TempUpsertDocumentIds","TempSaleDocuments","TempSaleDocumentReferences","TempSaleDocumentItems","TempSaleDocumentContacts";
END;
$function$
;
DROP FUNCTION IF EXISTS oregular."UpdatedMissingGstr1DocumentStatus";

CREATE OR REPLACE FUNCTION oregular."UpdatedMissingGstr1DocumentStatus"("_SubscriberId" integer, "_UserId" integer, "_EntityId" integer, "_ReturnPeriod" integer, "_SourceType" smallint, "_SectionType" integer, "_IsAmendment" boolean, "_SourceTypeTaxpayer" smallint, "_PushToGstStatusUploadedButNotPushed" smallint, "_PrimaryDetails" oregular."SaleDocumentPrimaryDetailType"[], "_AuditTrailDetails" audit."AuditTrailDetailsType"[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
	"_CurrentDate" TIMESTAMP WITHOUT TIME ZONE := NOW();
BEGIN

	DROP TABLE IF EXISTS "TempPrimaryDetails","TempSaleDocumentIds";
	
	CREATE TEMPORARY TABLE "TempPrimaryDetails" AS
	SELECT 
		*
	FROM  
		UNNEST("_PrimaryDetails");
	
	CREATE TEMPORARY TABLE "TempSaleDocumentIds" AS
	SELECT
	   sd."Id"
	FROM
		"TempPrimaryDetails" tpd
		INNER JOIN oregular."SaleDocumentDW" AS sd ON
		(
			sd."DocumentNumber" = tpd."DocumentNumber"
			AND sd."ParentEntityId" = "_EntityId"
			AND sd."DocumentFinancialYear" = tpd."DocumentFinancialYear" 
			AND sd."CombineDocumentType" = sd."CombineDocumentType"
			AND sd."SourceType" = "_SourceType"
			AND sd."IsAmendment" = "_IsAmendment"
			AND sd."SubscriberId" = "_SubscriberId"			
			AND sd."DocumentType" = tpd."DocumentType"
			AND sd."SectionType" & "_SectionType" <> 0			
		)
		INNER JOIN oregular."SaleDocumentStatus" ss ON sd."Id" = ss."SaleDocumentId";

	UPDATE
		oregular."SaleDocumentStatus" AS ss
	SET
		"PushStatus" = "_PushToGstStatusUploadedButNotPushed",
		"IsPushed" = FALSE,
		"IsAutoDrafted" = FALSE,
		"LastSyncDate" = "_CurrentDate",
		"BillingDate" = NULL,
		"ModifiedStamp" = "_CurrentDate"
	FROM
		 oregular."SaleDocumentDW" AS dw 
		 LEFT JOIN "TempSaleDocumentIds" AS tsdi ON tsdi."Id" = dw."Id" 
	WHERE
		ss."SaleDocumentId" = dw."Id"
		AND dw."SubscriberId" = "_SubscriberId"
		AND dw."EntityId" = "_EntityId"
		AND dw."ReturnPeriod" = "_ReturnPeriod"
		AND dw."SectionType" & "_SectionType" <> 0
		AND dw."IsAmendment" = "_IsAmendment"
		AND dw."SourceType" = "_SourceTypeTaxpayer"
		AND ss."IsPushed" = TRUE
		AND tsdi."Id" IS NULL;
END;
$function$
;
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
DROP FUNCTION IF EXISTS oregular."InsertPurchaseDocumentRecoCancelledCreditNotes";

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
