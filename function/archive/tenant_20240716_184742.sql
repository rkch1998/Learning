DROP FUNCTION IF EXISTS isd."InsertDownloadedDocuments";

CREATE OR REPLACE FUNCTION isd."InsertDownloadedDocuments"("_SubscriberId" integer, "_UserId" integer, "_EntityId" integer, "_ReturnPeriod" integer, "_FinancialYear" integer, "_AutoSync" boolean, "_ApiCategory" smallint, "_DocumentSectionGroups" common."DocumentSectionGroupType"[], "_Documents" isd."DownloadedDocumentType"[], "_DocumentContacts" isd."DownloadedDocumentContactType"[], "_DocumentItems" isd."DownloadedDocumentItemType"[], "_DocumentReferences" common."DocumentReferenceType"[], "_PushToGstStatusUploadedButNotPushed" smallint, "_SupplyTypeS" smallint, "_ApiCategoryTxpGstr6a" smallint, "_ApiCategoryTxpGstr6" smallint, "_SourceTypeTaxpayer" smallint, "_SourceTypeCounterPartyNotFiled" smallint, "_SourceTypeCounterPartyFiled" smallint, "_DocumentStatusActive" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeCRN" smallint, "_ContactTypeBillFrom" smallint)
 RETURNS TABLE("Id" bigint, "PlanLimitApplicable" boolean, "GroupId" integer)
 LANGUAGE plpgsql
AS $function$ 
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: isd."InsertDownloadedDocuments"
*	Comments		: 19-09-2022 | Ravi Chauhan | This procedure is used to Insert Downloaded Documents
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: 	SELECT  
							*
						FROM 
							isd."InsertDownloadedDocuments"
								(
								121::INT,
								121::INT,
								121::INT,
								121::INT,
								121::INT,
								False::BOOLEAN,
								1::SMALLINT,
								array[(121::bigint, False::boolean)]::common."DocumentSectionGroupType"[],
								array[(False::boolean, 1::smallint, 1::smallint, 1::smallint, 1::smallint , 'asde'::varchar(15) , 'asde'::varchar(40), '2002-4-21'::timestamp without time zone, 1::smallint , False::boolean, 121::numeric(18, 2) , 'asde'::varchar(15) , 1::smallint , 'asde'::varchar(40) , '2002-4-21'::timestamp without time zone , 532::bigint, 121::numeric(18, 2) , 121::numeric(18, 2) , 532::int, False::boolean, False::boolean, 1::smallint , 532::int, 1::smallint, 'asde'::varchar(100) , 1::smallint , 1::smallint, 'asde'::varchar(64) , '2002-4-21'::timestamp without time zone , 'asde'::varchar(100) , 'asde'::text )]::isd."DownloadedDocumentType"[],
								array[('asde'::varchar(15) , 'asde'::varchar(200) , 'asde'::varchar(200) , 1::smallint, 532::int, 1::smallint )]::isd."DownloadedDocumentContactType"[],
								array[(1::smallint, 121::numeric(5, 2) , 121::numeric(18, 2) , 121::numeric(18, 2) , 121::numeric(18, 2) , 121::numeric(18, 2) , 121::numeric(18, 2) , 532::int)]::isd."DownloadedDocumentItemType"[],
								array[(121::int,'asd'::varchar(40),'2022-11-23'::TIMESTAMP WITHOUT TIME ZONE)]::common."DocumentReferenceType"[],
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT,
								1::SMALLINT
								);

DROP FUNCTION isd."InsertDownloadedDocuments";
--------------------------------------------------------------------------------------------------------------------------------------*/

DECLARE 
	"_CurrentDate" TIMESTAMP WITHOUT TIME ZONE := NOW();
	"_Min" INT := 1; 
	"_Max" INT; 
	"_BatchSize" INT; 
	"_Records" INT;
	
BEGIN
	
	DROP TABLE IF EXISTS "TempDocumentIds", "TempUpsertDocumentIds", "TempDocuments",
						"TempDocumentReferences", "DuplicateDocuments", "TempDocumentContacts",
						"TempDocumentItems", "TempDeletedIds", "TempDocumentSectionGroups";
	
	CREATE TEMPORARY TABLE "TempDocumentIds"
	(
		"AutoId" SERIAL NOT NULL,
		"Id" BIGINT,
		"GroupId" INT,
		"BillingDate" TIMESTAMP WITHOUT TIME ZONE,
		"Mode" CHARACTER VARYING
	);

	CREATE TEMPORARY TABLE "TempDeletedIds"
	(
		"Id" BIGINT NOT NULL	
	);
	
	CREATE INDEX "IdX_TempDeletedIds" ON "TempDeletedIds" ("Id");	

	CREATE TEMPORARY TABLE "TempUpsertDocumentIds"
	(
		"Id" BIGINT NOT NULL	
	);
	
	CREATE INDEX "IdX_TempUpsertDocumentIds" ON "TempUpsertDocumentIds" ("Id");	
		
	CREATE TEMPORARY TABLE "TempDocuments" AS
	SELECT 
		*
	FROM 
		UNNEST("_Documents");
		
	CREATE TEMPORARY TABLE "DuplicateDocuments"(
		"GroupId" INTEGER
	);

	WITH CTE AS (
		SELECT
			td."GroupId", ROW_NUMBER() OVER(PARTITION BY td."DocumentNumber", td."BillFromGstin", td."DocumentType", td."SupplyType", td."IsAmendment" ORDER BY td."GroupId" DESC) AS "Rno"
		FROM
			"TempDocuments" td
	)
	INSERT INTO "DuplicateDocuments"
	SELECT 
		ct."GroupId"
	FROM
		CTE ct
	WHERE 
		ct."Rno" > 1;
		
	DELETE 
	FROM 
		"TempDocuments" td
		USING "DuplicateDocuments" dd 
	WHERE
		td."GroupId" = dd."GroupId";

	CREATE INDEX "IDX_TempDocuments_GroupId" ON "TempDocuments"("GroupId");
	-- Add  document References in temp
	
	CREATE TEMPORARY TABLE "TempDocumentReferences" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentReferences");

	DELETE 
	FROM 
		"TempDocumentReferences" tdr
		USING "DuplicateDocuments" dd 
	WHERE
		tdr."GroupId" = dd."GroupId";
	
	CREATE TEMPORARY TABLE "TempDocumentItems" AS
	SELECT
		*
	FROM
		UNNEST("_DocumentItems");

	DELETE 
	FROM 
		"TempDocumentItems" tdi
		USING "DuplicateDocuments" dd 
	WHERE
		tdi."GroupId" = dd."GroupId";
	
	CREATE TEMPORARY TABLE "TempDocumentContacts" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentContacts");

	DELETE 
	FROM 
		"TempDocumentContacts" tdc
		USING "DuplicateDocuments" dd 
	WHERE
		tdc."GroupId" = dd."GroupId";
	
	CREATE TEMPORARY TABLE "TempDocumentSectionGroups" AS
	SELECT 
		*
	FROM
		UNNEST("_DocumentSectionGroups");
	
	INSERT INTO "TempDocumentIds"
	(
		"Id",
		"GroupId",
		"BillingDate",
		"Mode"
	)
	SELECT
	   dw."Id",
	   td."GroupId",
	   COALESCE(ds."BillingDate","_CurrentDate"),
	   CASE 
			WHEN dw."SourceType" = "_SourceTypeTaxpayer" THEN 'U'
			WHEN dw."ReturnPeriod" < "_ReturnPeriod" THEN 'U'
			WHEN dw."SourceType" = "_SourceTypeCounterPartyNotFiled" AND td."SourceType" = "_SourceTypeCounterPartyFiled" THEN 'US'
			WHEN dw."SourceType" = "_SourceTypeCounterPartyNotFiled" AND ds."Checksum" <> td."Checksum" THEN 'U'
			ELSE 'S'
		END AS "Mode"
	FROM
		"TempDocuments" td
		INNER JOIN isd."DocumentDW" AS dw ON
		(
			dw."SubscriberId" = "_SubscriberId"
			AND dw."ParentEntityId" = "_EntityId"
			AND CASE WHEN dw."SourceType" = "_SourceTypeCounterPartyNotFiled" THEN "_SourceTypeCounterPartyFiled" ELSE dw."SourceType" END = CASE WHEN td."SourceType" = "_SourceTypeCounterPartyNotFiled" THEN "_SourceTypeCounterPartyFiled" ELSE td."SourceType" END
			AND dw."DocumentNumber" = td."DocumentNumber"
			AND dw."DocumentFinancialYear" =  td."DocumentFinancialYear"
			AND dw."SupplyType" = td."SupplyType"
			AND (
					dw."SupplyType" = "_SupplyTypeS" OR 
					(
							COALESCE(dw."BillFromGstin",'') = COALESCE(td."BillFromGstin",'')
					)
			)
			AND dw."TransactionType" = td."TransactionType"
			AND dw."DocumentType" = td."DocumentType"
			AND dw."IsAmendment" = td."IsAmendment"
		)
		INNER JOIN isd."DocumentStatus" ds ON ds."DocumentId" = dw."Id";
	
	-- Insert Data For Document 
	WITH inserted AS(
	INSERT INTO isd."Documents"
	(
		"SubscriberId",
		"ParentEntityId",
		"EntityId",
		"UserId",
		"Irn",
		"IrnGenerationDate",
		"IsPreGstRegime",
		"SupplyType",
		"DocumentType",
		"TransactionType",
		"TaxpayerType",
		"DocumentNumber",
		"RecoDocumentNumber",
		"DocumentDate",
		"POS",
		"ReverseCharge",
		"DocumentValue",
		"OriginalGstin",
		"OriginalStateCode",
		"OriginalDocumentNumber",
		"OriginalDocumentDate",
		"RefPrecedingDocumentDetails",
		"SectionType",
		"TotalTaxableValue",
		"TotalTaxAmount",
		"ReturnPeriod",
		"DocumentFinancialYear",
		"FinancialYear",
		"IsAmendment",
		"SourceType",
		"GroupId"
	)
	SELECT
		"_SubscriberId",
		"_EntityId",
		"_EntityId",
		"_UserId",
		tsd."Irn",
		tsd."IrnGenerationDate",
		tsd."IsPreGstRegime",
		tsd."SupplyType",
		tsd."DocumentType",
		tsd."TransactionType",
		tsd."TaxPayerType",
		tsd."DocumentNumber",
		tsd."RecoDocumentNumber",
		tsd."DocumentDate",
		tsd."Pos",
		tsd."ReverseCharge",
		tsd."DocumentValue",
		tsd."OriginalGstin",
		tsd."OriginalStateCode",
		tsd."OriginalDocumentNumber",
		tsd."OriginalDocumentDate",
		tsd."RefPrecedingDocumentDetails",
		tsd."SectionType",
		tsd."TotalTaxableValue",
		tsd."TotalTaxAmount",
		"_ReturnPeriod",
		tsd."DocumentFinancialYear",
		"_FinancialYear",
		tsd."IsAmendment",
		tsd."SourceType",
		tsd."GroupId"
	FROM
		"TempDocuments" tsd 
	WHERE 
		tsd."GroupId" NOT IN (SELECT tdi."GroupId" FROM "TempDocumentIds" tdi)
	RETURNING isd."Documents"."Id", isd."Documents"."GroupId")
	
	INSERT INTO "TempDocumentIds"("Id", "GroupId", "BillingDate", "Mode")
	SELECT 
		i."Id",
		i."GroupId",
		"_CurrentDate",
		'I'
	FROM
		inserted i;
	
	UPDATE
		isd."Documents" sd
	SET
		"ParentEntityId" = "_EntityId",
		"EntityId" = "_EntityId",
		"UserId" = "_UserId",
		"Irn" = tsd."Irn",
		"IrnGenerationDate" = tsd."IrnGenerationDate",
		"IsPreGstRegime" = tsd."IsPreGstRegime",
		"SupplyType" = tsd."SupplyType",
		"DocumentType" = tsd."DocumentType",
		"TransactionType" = tsd."TransactionType",
		"TaxpayerType" = tsd."TaxPayerType",
		"DocumentNumber" = tsd."DocumentNumber",
		"DocumentDate" = tsd."DocumentDate",
		"POS" = tsd."Pos",
		"ReverseCharge" = tsd."ReverseCharge",
		"DocumentValue" = tsd."DocumentValue",
		"OriginalGstin" = tsd."OriginalGstin",
		"OriginalStateCode" = tsd."OriginalStateCode",
		"OriginalDocumentNumber" = tsd."OriginalDocumentNumber",
		"OriginalDocumentDate" = tsd."OriginalDocumentDate",
		"RefPrecedingDocumentDetails" = tsd."RefPrecedingDocumentDetails",
		"SectionType" = tsd."SectionType",
		"TotalTaxableValue" = tsd."TotalTaxableValue",
		"TotalTaxAmount" = tsd."TotalTaxAmount",
		"ReturnPeriod" = "_ReturnPeriod",
		"DocumentFinancialYear" = tsd."DocumentFinancialYear",
		"FinancialYear" = "_FinancialYear",
		"IsAmendment" = tsd."IsAmendment",
		"SourceType" = tsd."SourceType",
		"Stamp" = CASE WHEN tsdids."Mode" = 'US' THEN "_CurrentDate" ELSE sd."Stamp" END,
		"ModifiedStamp" = "_CurrentDate",
		"GroupId" = tsd."GroupId"
	FROM
		"TempDocumentIds" AS tsdids  
		INNER JOIN "TempDocuments" AS tsd ON tsd."GroupId" = tsdids."GroupId"
	WHERE
		tsdids."Id" = sd."Id"
		AND tsdids."Mode" IN ('U', 'US');
		
	UPDATE
		isd."DocumentStatus" ss
	SET 
		"Status" = "_DocumentStatusActive",
		"FilingReturnPeriod" = tsd."FilingReturnPeriod",
		"PushStatus" = tsd."PushStatus",		
		"Checksum" = tsd."Checksum",
		"AutoDraftSource" = tsd."AutoDraftSource",		
		"IsPushed" = tsd."IsPushed",
		"BillingDate" = tsdids."BillingDate",
		"Errors" = NULL,
		"LastSyncDate" = "_CurrentDate",
		"ModifiedStamp" = "_CurrentDate",
		"IsReconciled" = False
	FROM
		"TempDocumentIds" AS tsdids  
		INNER JOIN "TempDocuments" tsd on tsdids."GroupId" = tsd."GroupId"
	WHERE 
		ss."DocumentId" = tsdids."Id"
		AND tsdids."Mode"  IN ('U', 'US');
		
	/* Delete DocumentItems */
	IF EXISTS (SELECT tdi."AutoId" FROM "TempDocumentIds" tdi)
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
		
		WHILE("_Min" <= "_Max")
		LOOP 
			"_Records" := "_Min" + "_BatchSize";

			DELETE 
			FROM 
				isd."DocumentContacts" AS dc
				USING "TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = dc."DocumentId"
				AND tdi."Mode" IN ('I', 'U', 'US')
				AND tdi."AutoId" BETWEEN "_Min" AND "_Records";
			
			DELETE 
			FROM 
				isd."DocumentItems" AS di
				USING "TempDocumentIds" AS tdi  
			WHERE 
				tdi."Id" = di."DocumentId"
				AND tdi."Mode" IN ('I', 'U', 'US')
				AND tdi."AutoId" BETWEEN "_Min" AND "_Records";
			
			"_Min" := "_Records";
		
		END LOOP;
	END IF;
	
	INSERT INTO isd."DocumentStatus"
	(
		"DocumentId",
		"Status",
		"PushStatus",
		"Action",
		"Checksum",
		"AutoDraftSource",
		"IsPushed",
		"ReconciliationStatus",
		"LastSyncDate",
		"BillingDate",
		"FilingReturnPeriod"
	)
	SELECT  
		tdi."Id" AS "DocumentId",
		"_DocumentStatusActive",
		td."PushStatus",
		td."Action",
		td."Checksum",
		td."AutoDraftSource",
		td."IsPushed",
		td."ReconciliationStatus",
		"_CurrentDate",
		"_CurrentDate",
		td."FilingReturnPeriod"
	FROM
		"TempDocumentIds" AS tdi
		INNER JOIN "TempDocuments" td on tdi."GroupId" = td."GroupId"
	WHERE 
		tdi."Mode" = 'I';

	INSERT INTO isd."DocumentContacts"
	(
		"DocumentId",
		"Gstin",
		"Type",
		"StateCode",
		"TradeName",
		"LegalName"
	)
	SELECT
		tdi."Id",
		tdc."Gstin",
		tdc."Type",
		tdc."StateCode",
		tdc."TradeName",
		tdc."LegalName"
	FROM
		"TempDocumentContacts" AS tdc
		INNER JOIN "TempDocumentIds" AS tdi ON tdc."GroupId" = tdi."GroupId"
	WHERE 
		tdi."Mode" IN ('I', 'U', 'US');

	INSERT INTO isd."DocumentItems"
	(
		"DocumentId",
		"ItcEligibility",
		"Rate",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		tdid."Id",
		tdi."ItcEligibility",
		tdi."Rate",
		tdi."TaxableValue",
		tdi."IgstAmount",
		tdi."CgstAmount",
		tdi."SgstAmount",
		tdi."CessAmount"
	FROM
		"TempDocumentItems" AS tdi
		INNER JOIN "TempDocumentIds" AS tdid ON tdi."GroupId" = tdid."GroupId"
	WHERE 
		tdid."Mode" IN ('I', 'U', 'US');

	INSERT INTO isd."DocumentReferences"
	(
		"DocumentId",
		"DocumentNumber",
		"DocumentDate"
	)
	SELECT
		tdi."Id",
		tdr."DocumentNumber",
		tdr."DocumentDate"
	FROM
		"TempDocumentReferences" AS tdr
		INNER JOIN "TempDocumentIds" AS tdi ON tdr."GroupId" = tdi."GroupId"
	WHERE 
		tdi."Mode" IN ('I');
	
	INSERT INTO "TempUpsertDocumentIds" ("Id")
	SELECT 
		tdi."Id" 
	FROM 
		"TempDocumentIds" tdi;

	IF ("_AutoSync" = False AND "_ApiCategory" = "_ApiCategoryTxpGstr6")
	THEN
		with inserted2 AS (
		UPDATE
			isd."DocumentStatus" AS ds
		SET
			"PushStatus" = "_PushToGstStatusUploadedButNotPushed",
			"IsPushed" = False,
			"LastSyncDate" = "_CurrentDate",
			"ModifiedStamp" = "_CurrentDate",
			"IsReconciled" = False
		FROM
			 isd."DocumentDW" AS dw  
			 LEFT JOIN "TempDocumentIds" AS tdi ON tdi."Id" = dw."Id" 
		WHERE
			ds."DocumentId" = dw."Id"
			AND dw."SubscriberId" = "_SubscriberId"
			AND dw."ParentEntityId" = "_EntityId"
			AND dw."ReturnPeriod" = "_ReturnPeriod"
			AND dw."SectionType" IN (SELECT tds."SectionType" FROM "TempDocumentSectionGroups" tds)
			AND dw."IsAmendment" IN (SELECT tds."IsAmendment" FROM "TempDocumentSectionGroups" tds)
			AND ds."IsPushed" = True
			AND tdi."Id" IS NULL
		RETURNING ds."DocumentId")
		
	INSERT INTO "TempUpsertDocumentIds"("Id")
	SELECT 
		i2."DocumentId"
	FROM 
		inserted2 i2;
	
	ELSIF ("_AutoSync" = False AND "_ApiCategory" = "_ApiCategoryTxpGstr6a")
	THEN
	INSERT INTO "TempDeletedIds"
		(
			"Id"
		)
		SELECT
			dw."Id"
		FROM
			 isd."DocumentDW" AS dw
			 LEFT JOIN "TempDocumentIds" AS tpdi ON tpdi."Id" = dw."Id" 
			 LEFT JOIN "TempDocuments" AS tpd ON tpdi."GroupId" = tpd."GroupId" 
		WHERE
			dw."SubscriberId" = "_SubscriberId"
			AND dw."EntityId" = "_EntityId"
			AND dw."ReturnPeriod" = "_ReturnPeriod"
			AND dw."SectionType" = tpd."SectionType"
			AND dw."IsAmendment" = tpd."IsAmendment"
			AND dw."SourceType" IN ("_SourceTypeCounterPartyFiled", "_SourceTypeCounterPartyNotFiled")
			AND tpdi."Id" IS NULL;
	END IF;

	/*Delete Data for Not Filed */
	IF EXISTS (SELECT tdi."Id" FROM "TempDeletedIds" tdi)
	THEN
		/* Delete Document Contact Detail */
		DELETE 
		FROM 
			isd."DocumentContacts" AS dc
			USING "TempDeletedIds" AS tdi 
		WHERE 
			dc."DocumentId" = tdi."Id";

		/* Delete Document Custom Detail */
		DELETE 
		FROM 
			isd."DocumentCustoms" AS dc
			USING "TempDeletedIds" AS tdi 
		WHERE 
			dc."DocumentId" = tdi."Id";

		/* Delete Document Items */
		DELETE 
		FROM 
			isd."DocumentItems" AS di
			USING "TempDeletedIds" AS tdi 
		WHERE 
			di."DocumentId" = tdi."Id";

		/* Delete Document Reference */
		DELETE 
		FROM 
			isd."DocumentReferences" AS dr
			USING "TempDeletedIds" AS tdi 
		WHERE 
			dr."DocumentId" = tdi."Id";

		/* Delete Document Status*/
		DELETE 
		FROM 
			isd."DocumentStatus" AS ds
			USING "TempDeletedIds" AS tdi 
		WHERE 
			ds."DocumentId" = tdi."Id";

		/* Delete Document DataWarehouse*/
		DELETE 
		FROM 
			isd."DocumentDW" AS ddw
			USING "TempDeletedIds" AS tdi 
		WHERE 
			ddw."Id" = tdi."Id";

		/* Delete Document*/
		DELETE 
		FROM 
			isd."Documents" AS d
			USING "TempDeletedIds" AS tdi 
		WHERE 
			d."Id" = tdi."Id";
			
	END IF;

	/* SP excuted to Insert/Update data into DW table */	
	EXECUTE isd."InsertDocumentDW"(
					"_DocumentTypeDBN",
					"_DocumentTypeCRN");	

	RETURN QUERY
	SELECT
		tsd."Id",
		CASE WHEN tsd."BillingDate" = "_CurrentDate" THEN true ELSE false END AS "PlanLimitApplicable",
		tsd."GroupId"
	FROM
		"TempDocumentIds" As tsd;
	
END;
$function$
;
