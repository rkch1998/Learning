DROP FUNCTION IF EXISTS gst."GenerateGstr3bSection4A5";

CREATE OR REPLACE FUNCTION gst."GenerateGstr3bSection4A5"("_Gstr3bSectionOtherItc" integer, "_ReturnPeriod" integer, "_SourceTypeTaxPayer" smallint, "_SourceTypeCounterPartyFiled" smallint, "_DocumentTypeINV" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_ItcAvailabilityTypeY" smallint, "_ItcAvailabilityTypeN" smallint, "_TaxPayerTypeISD" smallint, "_BitTypeN" boolean)
 RETURNS TABLE("Section" integer, "IsGstr2bData" boolean, "TaxableValue" numeric, "IgstAmount" numeric, "CgstAmount" numeric, "SgstAmount" numeric, "CessAmount" numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN

	DROP TABLE IF EXISTS "TempGstr3bSection4A5_Original";
	CREATE TEMPORARY TABLE "TempGstr3bSection4A5_Original"
	(
		"Section" INT,
		"IsGstr2bData"  BOOLEAN DEFAULT 0::BOOLEAN,
		"TaxableValue" DECIMAL(18,2),
		"IgstAmount" DECIMAL(18,2),
		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2)
	);

	DROP TABLE IF EXISTS "TempGstr3bUpdateStatus";
	CREATE TEMPORARY TABLE "TempGstr3bUpdateStatus"
	(	
		"Id" BIGINT
	);

	/*4.1.5 All Other ITC Original Data*/
	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(tpdc."IgstAmount") AS "IgstAmount",
		SUM(tpdc."CgstAmount") AS "CgstAmount",
		SUM(tpdc."SgstAmount") AS "SgstAmount",
		SUM(tpdc."CessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
	WHERE 
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND (tpdc."ItcClaimReturnPeriod" IS NULL OR tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod")
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");
			
	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdc."Id"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND (tpdc."ItcClaimReturnPeriod" IS NULL OR tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod")
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcIgstAmount"),0) + COALESCE(ABS(tpdcpr."IgstAmount"),0)) < ABS(tpdc."IgstAmount")
				 THEN (COALESCE(tpdcpr."ItcIgstAmount",0) + COALESCE(tpdcpr."IgstAmount",0))
				 ELSE tpdc."IgstAmount"
			END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCgstAmount"),0) + COALESCE(ABS(tpdcpr."CgstAmount"),0)) < ABS(tpdc."CgstAmount")
				 THEN (COALESCE(tpdcpr."ItcCgstAmount",0) + COALESCE(tpdcpr."CgstAmount",0))
				 ELSE tpdc."CgstAmount"
			END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcSgstAmount"),0) + COALESCE(ABS(tpdcpr."SgstAmount"),0)) < ABS(tpdc."SgstAmount")
				 THEN (COALESCE(tpdcpr."ItcSgstAmount",0) + COALESCE(tpdcpr."SgstAmount",0))
				 ELSE tpdc."SgstAmount"
			END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCessAmount"),0) + COALESCE(ABS(tpdcpr."CessAmount"),0)) < ABS(tpdc."CessAmount")
				 THEN (COALESCE(tpdcpr."ItcCessAmount",0) + COALESCE(tpdcpr."CessAmount",0))
				 ELSE tpdc."CessAmount"
			END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		LEFT JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE 
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");
			
	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdc."Id"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		LEFT JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."Gstr2BReturnPeriod" <> "_ReturnPeriod" 
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(COALESCE(tpdc."CpIgstAmount",0) + COALESCE(tpdc."PrevCpIgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdc."CpCgstAmount",0) + COALESCE(tpdc."PrevCpCgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdc."CpSgstAmount",0) + COALESCE(tpdc."PrevCpSgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdc."CpCessAmount",0) + COALESCE(tpdc."PrevCpCessAmount",0)) AS "CessAmount"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND (tpdc."ItcClaimReturnPeriod" IS NULL OR tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod")
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpd."Id"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
		INNER JOIN "TempPurchaseDocumentIds" tpd ON tpdc."MapperId" = tpd."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND (tpdc."ItcClaimReturnPeriod" IS NULL OR tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod")
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");
				
	/*4.1.5 All Other ITC Amendment Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0)) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			(tpdac."PrTotalItcAmount" IS NULL AND tpdac."PrTotalTaxAmount" IS NULL)
			OR
			tpdac."PrTotalTaxAmount" IS NOT NULL
			OR
			(
				tpdac."PrTotalItcAmount" IS NOT NULL
				AND 
				(
					ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
					OR
					(ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") AND ABS(tpdac."PrTotalItcAmount") > ABS(tpdac."TotalTaxAmount_A"))
				)
			)
		);
		
	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			(tpdac."PrTotalItcAmount" IS NULL AND tpdac."PrTotalTaxAmount" IS NULL)
			OR
			tpdac."PrTotalTaxAmount" IS NOT NULL
			OR
			(
				tpdac."PrTotalItcAmount" IS NOT NULL
				AND 
				(
					ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
					OR
					(ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") AND ABS(tpdac."PrTotalItcAmount") > ABS(tpdac."TotalTaxAmount_A"))
				)
			)
		);

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0) + COALESCE(tpdac."PrItcIgstAmount",0) + COALESCE(tpdac."PrIgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0) + COALESCE(tpdac."PrItcCgstAmount",0) + COALESCE(tpdac."PrCgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0) + COALESCE(tpdac."PrItcSgstAmount",0) + COALESCE(tpdac."PrSgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0) + COALESCE(tpdac."PrItcCessAmount",0) + COALESCE(tpdac."PrCessAmount",0)) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalItcAmount" IS NULL
			OR
			(
				tpdac."PrTotalItcAmount" IS NOT NULL
				AND ABS(tpdac."PrTotalItcAmount") < ABS(tpdac."TotalTaxAmount_A")
			)
			OR
			(
				tpdac."PrTotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount_A")
			)
		);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalItcAmount" IS NULL
			OR
			(
				tpdac."PrTotalItcAmount" IS NOT NULL
				AND ABS(tpdac."PrTotalItcAmount") < ABS(tpdac."TotalTaxAmount_A")
			)
			OR
			(
				tpdac."PrTotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount_A")
			)
		);

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."IgstAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0) + COALESCE(tpdac."IgstAmount_A",0)
			 ELSE COALESCE(tpdac."IgstAmount",0)
		END) AS "IgstAmount",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."CgstAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0) + COALESCE(tpdac."CgstAmount_A",0)
			 ELSE COALESCE(tpdac."CgstAmount",0)
		END) AS "CgstAmount",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."SgstAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0) + COALESCE(tpdac."SgstAmount_A",0)
			 ELSE COALESCE(tpdac."SgstAmount",0)
		END) AS "SgstAmount",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."CessAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0) + COALESCE(tpdac."CessAmount_A",0)
			 ELSE COALESCE(tpdac."CessAmount",0)
		END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalItcAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalItcAmount") >= ABS(tpdac."TotalTaxAmount_A");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalItcAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalItcAmount") >= ABS(tpdac."TotalTaxAmount_A");

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."IgstAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0) + COALESCE(tpdac."IgstAmount_A",0)
			 ELSE COALESCE(tpdac."IgstAmount",0)
		END) AS "IgstAmount",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."CgstAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0) + COALESCE(tpdac."CgstAmount_A",0)
			 ELSE COALESCE(tpdac."CgstAmount",0)
		END) AS "CgstAmount",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."SgstAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0) + COALESCE(tpdac."SgstAmount_A",0)
			 ELSE COALESCE(tpdac."SgstAmount",0)
		END) AS "SgstAmount",
		SUM(CASE WHEN ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			 THEN COALESCE(tpdac."CessAmount_A",0)
			 WHEN ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount") 
			 THEN COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0) + COALESCE(tpdac."CessAmount_A",0)
			 ELSE COALESCE(tpdac."CessAmount",0)
		END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalTaxAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalTaxAmount") >= ABS(tpdac."TotalTaxAmount_A");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalTaxAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalTaxAmount") >= ABS(tpdac."TotalTaxAmount_A");

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(tpdac."PrItcIgstAmount") AS "IgstAmount",
		SUM(tpdac."PrItcCgstAmount") AS "CgstAmount",
		SUM(tpdac."PrItcSgstAmount") AS "SgstAmount",
		SUM(tpdac."PrItcCessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalItcAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalItcAmount") < ABS(tpdac."TotalTaxAmount_A")
		AND ABS(tpdac."TotalTaxAmount_A") = ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalItcAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalItcAmount") < ABS(tpdac."TotalTaxAmount_A")
		AND ABS(tpdac."TotalTaxAmount_A") = ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(tpdac."PrIgstAmount") AS "IgstAmount",
		SUM(tpdac."PrCgstAmount") AS "CgstAmount",
		SUM(tpdac."PrSgstAmount") AS "SgstAmount",
		SUM(tpdac."PrCessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalTaxAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount_A")
		AND ABS(tpdac."TotalTaxAmount_A") = ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalTaxAmount" IS NOT NULL
		AND ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount_A")
		AND ABS(tpdac."TotalTaxAmount_A") = ABS(tpdac."TotalTaxAmount");

	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		SUM(tpdac."IgstAmount_A") AS "IgstAmount",
		SUM(tpdac."CgstAmount_A") AS "CgstAmount",
		SUM(tpdac."SgstAmount_A") AS "SgstAmount",
		SUM(tpdac."CessAmount_A") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeN"
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN") 
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeN"
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN") 
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4A5_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionOtherItc",
		CASE WHEN COALESCE(ABS(tpdac."PrItcIgstAmount"),0) < COALESCE(ABS(tpdac."IgstAmount"),0) 
			 THEN -tpdac."PrItcIgstAmount" 
			 ELSE -tpdac."IgstAmount"
		END AS "IgstAmount",
		CASE WHEN COALESCE(ABS(tpdac."PrItcCgstAmount"),0) < COALESCE(ABS(tpdac."CgstAmount"),0) 
			 THEN -tpdac."PrItcCgstAmount" 
			 ELSE -tpdac."CgstAmount"
		END AS "CgstAmount",
		CASE WHEN COALESCE(ABS(tpdac."PrItcSgstAmount"),0) < COALESCE(ABS(tpdac."SgstAmount"),0) 
			 THEN -tpdac."PrItcSgstAmount" 
			 ELSE -tpdac."SgstAmount"
		END AS "SgstAmount",
		CASE WHEN COALESCE(ABS(tpdac."PrItcCessAmount"),0) < COALESCE(ABS(tpdac."CessAmount"),0) 
			 THEN -tpdac."PrItcCessAmount" 
			 ELSE -tpdac."CessAmount"
		END AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN") 
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id"
	)
	SELECT
		tpdac."Id"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND (tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" OR tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod")
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN") 
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	UPDATE 
		oregular."PurchaseDocumentStatus" pds
	SET 
		"Gstr3bSection" = "_Gstr3bSectionOtherItc"
	FROM 
		"TempGstr3bUpdateStatus" us
	WHERE
		pds."PurchaseDocumentId" = us."Id";
		
	RETURN QUERY
	SELECT
		tod."Section",
		tod."IsGstr2bData",
		SUM(tod."TaxableValue") AS "TaxableValue",
		SUM(tod."IgstAmount") AS "IgstAmount",
		SUM(tod."CgstAmount") AS "CgstAmount",
		SUM(tod."SgstAmount") AS "SgstAmount",
		SUM(tod."CessAmount") AS "CessAmount"
	FROM
		"TempGstr3bSection4A5_Original" AS tod
	GROUP BY
		tod."Section",
		tod."IsGstr2bData";

	DROP TABLE "TempGstr3bSection4A5_Original";

END
$function$
;
DROP FUNCTION IF EXISTS gst."GenerateGstr3bSection4D";

CREATE OR REPLACE FUNCTION gst."GenerateGstr3bSection4D"("_Gstr3bSectionIneligibleItcAsPerRule" integer, "_Gstr3bSectionIneligibleItcOthers" integer, "_ReturnPeriod" integer, "_SourceTypeTaxPayer" smallint, "_SourceTypeCounterPartyFiled" smallint, "_DocumentTypeINV" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_TaxPayerTypeISD" smallint, "_ItcAvailabilityTypeY" smallint, "_ItcAvailabilityTypeN" smallint, "_BitTypeN" boolean)
 RETURNS TABLE("Section" integer, "IgstAmount" numeric, "CgstAmount" numeric, "SgstAmount" numeric, "CessAmount" numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
	CREATE TEMPORARY TABLE "TempGstr3bSection4D_Original"
	(	
		"Section" INT,
		"IgstAmount" DECIMAL(18,2),
		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2)
	);

	DROP TABLE IF EXISTS "TempGstr3bUpdateStatus";
	CREATE TEMPORARY TABLE "TempGstr3bUpdateStatus"
	(	
		"Id" BIGINT,
		"Section" INT
	);
	
	/*4D1 ITC reclaimed which was Reversed under Table 4(B)(2) in earlier tax Period */
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcAsPerRule",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcIgstAmount"),0) + COALESCE(ABS(tpdcpr."IgstAmount"),0)) < ABS(tpdc."IgstAmount")
				 THEN (COALESCE(tpdcpr."ItcIgstAmount",0) + COALESCE(tpdcpr."IgstAmount",0))
				 ELSE tpdc."IgstAmount"
			END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCgstAmount"),0) + COALESCE(ABS(tpdcpr."CgstAmount"),0)) < ABS(tpdc."CgstAmount")
				 THEN (COALESCE(tpdcpr."ItcCgstAmount",0) + COALESCE(tpdcpr."CgstAmount",0))
				 ELSE tpdc."CgstAmount"
			END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcSgstAmount"),0) + COALESCE(ABS(tpdcpr."SgstAmount"),0)) < ABS(tpdc."SgstAmount")
				 THEN (COALESCE(tpdcpr."ItcSgstAmount",0) + COALESCE(tpdcpr."SgstAmount",0))
				 ELSE tpdc."SgstAmount"
			END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCessAmount"),0) + COALESCE(ABS(tpdcpr."CessAmount"),0)) < ABS(tpdc."CessAmount")
				 THEN (COALESCE(tpdcpr."ItcCessAmount",0) + COALESCE(tpdcpr."CessAmount",0))
				 ELSE tpdc."CessAmount"
			END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		LEFT JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod" 
		AND tpdc."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdc."Id",
		"_Gstr3bSectionIneligibleItcAsPerRule"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		LEFT JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod" 
		AND tpdc."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");
		
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcAsPerRule",
		SUM(tpdc."PrevCpIgstAmount") AS "IgstAmount",
		SUM(tpdc."PrevCpCgstAmount") AS "CgstAmount",
		SUM(tpdc."PrevCpSgstAmount") AS "SgstAmount",
		SUM(tpdc."PrevCpCessAmount") AS "CessAmount"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod" 
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpd."Id",
		"_Gstr3bSectionIneligibleItcAsPerRule"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
		INNER JOIN "TempPurchaseDocumentIds" tpd ON tpdc."MapperId" = tpd."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod" 
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");

	/*4D1 ITC reclaimed which was Reversed under Table 4(B)(2) in earlier tax Period Amendments Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcAsPerRule",
		CASE WHEN tpdac."PrTotalItcAmount" IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac."PrIgstAmount") <= ABS(tpdac."IgstAmount_A") AND ABS(tpdac."PrIgstAmount") <= ABS(tpdac."IgstAmount") THEN tpdac."PrIgstAmount"
						  WHEN ABS(tpdac."IgstAmount_A") <= ABS(tpdac."PrIgstAmount") AND ABS(tpdac."IgstAmount_A") <= ABS(tpdac."IgstAmount") THEN tpdac."IgstAmount_A"
						  ELSE tpdac."IgstAmount"
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac."PrItcIgstAmount") <= ABS(tpdac."IgstAmount_A") AND ABS(tpdac."PrItcIgstAmount") <= ABS(tpdac."IgstAmount") THEN tpdac."PrItcIgstAmount"
						  WHEN ABS(tpdac."IgstAmount_A") <= ABS(tpdac."PrItcIgstAmount") AND ABS(tpdac."IgstAmount_A") <= ABS(tpdac."IgstAmount") THEN tpdac."IgstAmount_A"
						  ELSE tpdac."IgstAmount"
					  END)
		END AS "IgstAmount",
		CASE WHEN tpdac."PrTotalItcAmount" IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac."PrCgstAmount") <= ABS(tpdac."CgstAmount_A") AND ABS(tpdac."PrCgstAmount") <= ABS(tpdac."CgstAmount") THEN tpdac."PrCgstAmount"
						  WHEN ABS(tpdac."CgstAmount_A") <= ABS(tpdac."PrCgstAmount") AND ABS(tpdac."CgstAmount_A") <= ABS(tpdac."CgstAmount") THEN tpdac."CgstAmount_A"
						  ELSE tpdac."CgstAmount"
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac."PrItcCgstAmount") <= ABS(tpdac."CgstAmount_A") AND ABS(tpdac."PrItcCgstAmount") <= ABS(tpdac."CgstAmount") THEN tpdac."PrItcCgstAmount"
						  WHEN ABS(tpdac."CgstAmount_A") <= ABS(tpdac."PrItcCgstAmount") AND ABS(tpdac."CgstAmount_A") <= ABS(tpdac."CgstAmount") THEN tpdac."CgstAmount_A"
						  ELSE tpdac."CgstAmount"
					  END)
		END AS "CgstAmount",
		CASE WHEN tpdac."PrTotalItcAmount" IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac."PrSgstAmount") <= ABS(tpdac."SgstAmount_A") AND ABS(tpdac."PrSgstAmount") <= ABS(tpdac."SgstAmount") THEN tpdac."PrSgstAmount"
						  WHEN ABS(tpdac."SgstAmount_A") <= ABS(tpdac."PrSgstAmount") AND ABS(tpdac."SgstAmount_A") <= ABS(tpdac."SgstAmount") THEN tpdac."SgstAmount_A"
						  ELSE tpdac."SgstAmount"
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac."PrItcSgstAmount") <= ABS(tpdac."SgstAmount_A") AND ABS(tpdac."PrItcSgstAmount") <= ABS(tpdac."SgstAmount") THEN tpdac."PrItcSgstAmount"
						  WHEN ABS(tpdac."SgstAmount_A") <= ABS(tpdac."PrItcSgstAmount") AND ABS(tpdac."SgstAmount_A") <= ABS(tpdac."SgstAmount") THEN tpdac."SgstAmount_A"
						  ELSE tpdac."SgstAmount"
					  END)
		END AS "SgstAmount",
		CASE WHEN tpdac."PrTotalItcAmount" IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac."PrCessAmount") <= ABS(tpdac."CessAmount_A") AND ABS(tpdac."PrCessAmount") <= ABS(tpdac."CessAmount") THEN tpdac."PrCessAmount"
						  WHEN ABS(tpdac."CessAmount_A") <= ABS(tpdac."PrCessAmount") AND ABS(tpdac."CessAmount_A") <= ABS(tpdac."CessAmount") THEN tpdac."CessAmount_A"
						  ELSE tpdac."CessAmount"
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac."PrItcCessAmount") <= ABS(tpdac."CessAmount_A") AND ABS(tpdac."PrItcCessAmount") <= ABS(tpdac."CessAmount") THEN tpdac."PrItcCessAmount"
						  WHEN ABS(tpdac."CessAmount_A") <= ABS(tpdac."PrItcCessAmount") AND ABS(tpdac."CessAmount_A") <= ABS(tpdac."CessAmount") THEN tpdac."CessAmount_A"
						  ELSE tpdac."CessAmount"
					  END)
		END AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND tpdac."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
	GROUP BY
		tpdac."PrTotalItcAmount";

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionIneligibleItcAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND tpdac."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcAsPerRule",
		SUM(COALESCE(tpdac."IgstAmount",0) - COALESCE(tpdac."PrItcIgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdac."CgstAmount",0) - COALESCE(tpdac."PrItcCgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdac."SgstAmount",0) - COALESCE(tpdac."PrItcSgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdac."CessAmount",0) - COALESCE(tpdac."PrItcCessAmount",0)) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalItcAmount" IS NOT NULL   
			AND ABS(tpdac."PrTotalItcAmount") <  ABS(tpdac."TotalTaxAmount")			
		);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionIneligibleItcAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."Gstr2BReturnPeriod" <> "_ReturnPeriod"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalItcAmount" IS NOT NULL   
			AND ABS(tpdac."PrTotalItcAmount") <  ABS(tpdac."TotalTaxAmount")			
		);

	/*4.2.2 Ineligible Itc Other*/
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcOthers",
		SUM(tpdc."IgstAmount") AS "IgstAmount",
		SUM(tpdc."CgstAmount") AS "CgstAmount",
		SUM(tpdc."SgstAmount") AS "SgstAmount",
		SUM(tpdc."CessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdc."ItcAvailability" = "_ItcAvailabilityTypeN"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdc."Id",
		"_Gstr3bSectionIneligibleItcOthers"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdc."ItcAvailability" = "_ItcAvailabilityTypeN"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD");

	/*4.2.2 Ineligible Itc Other Amendments Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcOthers",
		-SUM(tpdac."IgstAmount") AS "IgstAmount",
		-SUM(tpdac."CgstAmount") AS "CgstAmount",
		-SUM(tpdac."SgstAmount") AS "SgstAmount",
		-SUM(tpdac."CessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" = "_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" = "_ItcAvailabilityTypeN"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalTaxAmount" IS NOT NULL;

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionIneligibleItcOthers"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" = "_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" = "_ItcAvailabilityTypeN"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdac."PrTotalTaxAmount" IS NOT NULL;

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4D_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionIneligibleItcOthers",
		SUM(tpdac."IgstAmount_A") AS "IgstAmount",
		SUM(tpdac."CgstAmount_A") AS "CgstAmount",
		SUM(tpdac."SgstAmount_A") AS "SgstAmount",
		SUM(tpdac."CessAmount_A") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" = "_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" = "_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionIneligibleItcOthers"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" AS tpdac
	WHERE
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" = "_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" = "_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD");

	UPDATE 
		oregular."PurchaseDocumentStatus" pds
	SET 
		"Gstr3bSection" = CASE WHEN "Gstr3bSection" IS NULL THEN us."Section" WHEN "Gstr3bSection" & us."Section" <> 0 THEN "Gstr3bSection" ELSE "Gstr3bSection" + us."Section" END
	FROM 
		"TempGstr3bUpdateStatus" us
	WHERE
		pds."PurchaseDocumentId" = us."Id";

	RETURN QUERY
	SELECT
		tod."Section",
		SUM(tod."IgstAmount") AS "IgstAmount",
		SUM(tod."CgstAmount") AS "CgstAmount",
		SUM(tod."SgstAmount") AS "SgstAmount",
		SUM(tod."CessAmount") AS "CessAmount"
	FROM
		"TempGstr3bSection4D_Original" AS tod
	GROUP BY
		tod."Section";

	DROP TABLE "TempGstr3bSection4D_Original";

END
$function$
;
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
DROP FUNCTION IF EXISTS oregular."DeletePurchaseDocumentForRecoByIds";

CREATE OR REPLACE FUNCTION oregular."DeletePurchaseDocumentForRecoByIds"("_DocumentStatusDeleted" smallint, "_ReconciliationMappingTypeExtended" smallint)
 RETURNS TABLE("EntityId" integer, "FinancialYear" integer)
 LANGUAGE plpgsql
AS $function$
-------------
/*
	CREATE TEMP TABLE "TempPurchaseDocumentIdsNotPushed" AS
	SELECT 1 AS "Id";
	
	CREATE TEMP TABLE "TempPurchaseDocumentIdsPushed" as
	SELECT 2 AS "Id";
	
	SELECT * FROM oregular."DeletePurchaseDocumentForRecoByIds"
	(
		1 ::smallint,
		4 ::smallint
	)
*/

-----------------
DECLARE 
		"_ReconciliationSectionTypePROnly" SMALLINT = 1;
		"_ReconciliationSectionTypeGstOnly" SMALLINT = 2;
		"_ReconciledTypeSystem" SMALLINT  = 1;
		"_CURRENT_DATE" timestamp without time zone= NOW()::timestamp without time zone;
		"_SessionId" smallint= -4;

BEGIN
	/* code to delete from 2b reco begins */	
	DROP TABLE IF EXISTS "TempIdsForDeleteReco";
	CREATE TEMP TABLE "TempIdsForDeleteReco"
	(
		"Id" BIGINT
	);

	INSERT INTO "TempIdsForDeleteReco"
	SELECT "Id" FROM "TempPurchaseDocumentIdsNotPushed";
	
	INSERT INTO "TempIdsForDeleteReco"
	SELECT "Id" FROM "TempPurchaseDocumentIdsPushed";
	
	CREATE TEMP TABLE "TempUpdateUnReconiled"  AS
	SELECT 
		"GstnId" "Id"
	FROM 
		"TempIdsForDeleteReco" TI
	INNER JOIN 	Oregular."Gstr2bDocumentRecoMapper" gbrm ON gbrm."PrId" = TI."Id"
	WHERE "GstnId" IS NOT NULL
	UNION
	SELECT 
		"PrId"
	FROM 
		"TempIdsForDeleteReco" TI
	INNER JOIN 	Oregular."Gstr2bDocumentRecoMapper" gbrm ON gbrm."GstnId" = TI."Id"
	WHERE "PrId" IS NOT NULL;
	
	/*Updating Section to Pr ONLY where Gstin record is in match or mismatch section*/
	UPDATE Oregular."Gstr2bDocumentRecoMapper" r_pdrm
	SET "GstnId" = NULL,
		"SectionType" = "_ReconciliationSectionTypePROnly",
		"Reason" = NULL,
		"ReasonType" = NULL,
		"PredictableMatchBy" = NULL,
		"IsCrossHeadTax" = FALSE,
		"ReconciledType" = "_ReconciledTypeSystem",
		"SessionId" = "_SessionId",					
		"ModifiedStamp" = NOW(),
		"Gstr2BReturnPeriodDate" = NULL
	FROM 
		"TempIdsForDeleteReco" t_rpd 
	WHERE 
		r_pdrm."GstnId" IS NOT NULL AND r_pdrm."PrId" IS NOT NULL
		AND r_pdrm."GstnId" = t_rpd."Id"
		AND r_pdrm."SectionType" <> "_ReconciliationSectionTypeGstOnly";/*Deleting data from reco mapper where gstin id is null*/					
	
	DELETE 
	FROM 
		Oregular."Gstr2bDocumentRecoMapper" r_pdrm
	USING "TempIdsForDeleteReco" t_rpd 
	WHERE 
		r_pdrm."GstnId" IS NULL
		AND r_pdrm."PrId" = t_rpd."Id";
		
	/*Deleting data from reco mapper where pr id is null*/
	DELETE 
	FROM 
		Oregular."Gstr2bDocumentRecoMapper" r_pdrm
	USING "TempIdsForDeleteReco" t_rpd 
	WHERE 
		r_pdrm."PrId" IS NULL
		AND r_pdrm."GstnId" = t_rpd."Id";							

	/*Updating Section to GStONLY where PR record is in match or mismatch section*/
	UPDATE Oregular."Gstr2bDocumentRecoMapper" r_pdrm
	SET "PrId" = NULL,
		"SectionType" = "_ReconciliationSectionTypeGstOnly",
		"Reason" = NULL,
		"ReasonType" = NULL,
		"IsCrossHeadTax" = FALSE,
		"PredictableMatchBy" = NULL,
		"ReconciledType" =  "_ReconciledTypeSystem",
		"SessionId" = "_SessionId",					
		"ModifiedStamp" = NOW(),
		"PrReturnPeriodDate" = NULL
	FROM  
		"TempIdsForDeleteReco"		t_rpd	
	WHERE 
		r_pdrm."PrId" IS NOT NULL AND r_pdrm."GstnId" IS NOT NULL
		AND r_pdrm."PrId" = t_rpd."Id"
		AND r_pdrm."SectionType" <> "_ReconciliationSectionTypePROnly";			
		
-------------------------Delete From 2a Begins -------------------------------------------	

	INSERT INTO "TempUpdateUnReconiled" 
	SELECT 
		"GstnId"
	FROM 
		"TempIdsForDeleteReco" TI
	INNER JOIN 	Oregular."Gstr2aDocumentRecoMapper" gbrm ON gbrm."PrId" = TI."Id"
	WHERE "GstnId" IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM "TempUpdateUnReconiled" d WHERE TI."Id" = d."Id")
	UNION
	SELECT 
		"PrId"
	FROM 
		"TempIdsForDeleteReco" TI
	INNER JOIN 	Oregular."Gstr2aDocumentRecoMapper" gbrm ON gbrm."GstnId" = TI."Id"
	WHERE "PrId" IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM "TempUpdateUnReconiled" d WHERE TI."Id" = d."Id");

	/*Updating Section to Pr ONLY where Gstin record is in match or mismatch section*/
	UPDATE Oregular."Gstr2aDocumentRecoMapper" r_pdrm
	SET "GstnId" = NULL,
		"SectionType" = "_ReconciliationSectionTypePROnly",
		"Reason" = NULL,
		"ReasonType" = NULL,
		"PredictableMatchBy" = NULL,
		"IsCrossHeadTax" = FALSE,
		"ReconciledType" = "_ReconciledTypeSystem",
		"SessionId" = "_SessionId",					
		"ModifiedStamp" = NOW(),
		"GstnReturnPeriodDate" = NULL
	FROM 
		"TempIdsForDeleteReco" t_rpd 
	WHERE 
		r_pdrm."GstnId" IS NOT NULL AND r_pdrm."PrId" IS NOT NULL
		AND r_pdrm."GstnId" = t_rpd."Id"
		AND r_pdrm."SectionType" <> "_ReconciliationSectionTypeGstOnly";/*Deleting data from reco mapper where gstin id is null*/					

	DELETE 
	FROM 
		Oregular."Gstr2aDocumentRecoMapper" r_pdrm
	USING "TempIdsForDeleteReco" t_rpd 
	WHERE 
		r_pdrm."GstnId" IS NULL
		AND r_pdrm."PrId" = t_rpd."Id";
		
	/*Deleting data from reco mapper where pr id is null*/
	DELETE 
	FROM 
		Oregular."Gstr2aDocumentRecoMapper" r_pdrm
	USING "TempIdsForDeleteReco" t_rpd 
	WHERE 
		r_pdrm."PrId" IS NULL
		AND r_pdrm."GstnId" = t_rpd."Id";							
	
	/*Updating Section to GStONLY where PR record is in match or mismatch section*/
	UPDATE 
		Oregular."Gstr2aDocumentRecoMapper" r_pdrm
	SET 
		"PrId" = NULL,
		"SectionType" = "_ReconciliationSectionTypeGstOnly",
		"Reason" = NULL,
		"ReasonType" = NULL,
		"IsCrossHeadTax" = FALSE,
		"PredictableMatchBy" = NULL,
		"ReconciledType" =  "_ReconciledTypeSystem",
		"SessionId" = "_SessionId",					
		"ModifiedStamp" = NOW(),
		"PrReturnPeriodDate" = NULL
	FROM  
		"TempIdsForDeleteReco"		t_rpd	
	WHERE 
		r_pdrm."PrId" IS NOT NULL AND r_pdrm."GstnId" IS NOT NULL
		AND r_pdrm."PrId" = t_rpd."Id"
		AND r_pdrm."SectionType" <> "_ReconciliationSectionTypePROnly";			
	
	Update oregular."PurchaseDocumentStatus" pds
	SET "IsReconciled" = FALSE
	FROM
		"TempUpdateUnReconiled"  tur
	WHERE 
		tur."Id" = pds."PurchaseDocumentId";
		
	/* Cancelced invoice reason revert  */
	DROP TABLE IF EXISTS "TempCancelledInvoiceIds";
	CREATE TEMP TABLE "TempCancelledInvoiceIds" AS
	SELECT 
		r_pdrm."GstnId" AS "CancelledInvoiceId"
	FROM  
		"TempIdsForDeleteReco"	t_rpd
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" r_pdrm ON r_pdrm."CancelledInvoiceId" = t_rpd."Id"
	WHERE 
		r_pdrm."CancelledInvoiceId" IS NOT NULL AND r_pdrm."GstnId" IS NOT NULL
	UNION
	SELECT 
		r_pdrm."CancelledInvoiceId"
	FROM  
		"TempIdsForDeleteReco"	t_rpd
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" r_pdrm ON r_pdrm."CancelledInvoiceId" = t_rpd."Id"
	WHERE 
		r_pdrm."CancelledInvoiceId" IS NOT NULL;
		
	DROP TABLE IF EXISTS "TempRecoReasonData";
	CREATE TEMP TABLE "TempRecoReasonData" AS
	SELECT
		rm."Id" AS "MapperId",
		json_array_elements(rm."Reason"::json) AS "Reason",
		(json_array_elements(rm."Reason"::json)->>'Reason')::BIGINT AS "ReasonType"
	FROM  
		"TempCancelledInvoiceIds" AS tci
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" AS rm ON rm."CancelledInvoiceId" = tci."CancelledInvoiceId";

	DROP TABLE IF EXISTS "TempGstr2bDocumentRecoMapperIds";
	CREATE TEMP TABLE "TempGstr2bDocumentRecoMapperIds" AS
	SELECT
		rm."Id" AS "MapperId"
	FROM  
		"TempCancelledInvoiceIds" AS tci
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" AS rm ON rm."CancelledInvoiceId" = tci."CancelledInvoiceId";

	DROP TABLE IF EXISTS "TempCancelledInvoiceReasonData";
	CREATE TEMP TABLE "TempCancelledInvoiceReasonData" AS
	SELECT
		"MapperId",
		json_agg("Reason") AS "Reason",
		SUM("ReasonType") AS "ReasonType"
	FROM
		"TempRecoReasonData"
	WHERE
		"ReasonType" NOT IN(8589934592, 34359738368)
	GROUP BY "MapperId";
		
	UPDATE oregular."Gstr2bDocumentRecoMapper" AS rm
	SET 
		"Reason" = tcird."Reason",
		"ReasonType" = tcird."ReasonType",
		"CancelledInvoiceId" = NULL,
		"SessionId" = "_SessionId",					
		"ModifiedStamp" = NOW()
	FROM  
		"TempGstr2bDocumentRecoMapperIds" trrd
		LEFT JOIN "TempCancelledInvoiceReasonData" AS tcird ON trrd."MapperId" = tcird."MapperId"
	WHERE 
		trrd."MapperId" = rm."Id";		
		
	RETURN QUERY
	SELECT DISTINCT
		pd."EntityId",
		pd."FinancialYear"	
	FROM 
		"TempUpdateUnReconiled" tpf
	INNER JOIN oregular."PurchaseDocuments" pd ON tpf."Id" = pd."Id";
	
END;
$function$
;
DROP FUNCTION IF EXISTS gst."GenerateGstr3b";

CREATE OR REPLACE FUNCTION gst."GenerateGstr3b"("_SubscriberId" integer, "_EntityId" integer, "_FinancialYear" integer, "_ReturnPeriod" integer, "_PreviousReturnPeriods" integer[], "_LastFilingDate" timestamp without time zone, "_Gstr3bAutoPopulateType" smallint, "_Month" integer, "_LocationPos" smallint, "_IsQuarterlyFiling" boolean, "_ReturnTypeGSTR3B" smallint, "_ReturnActionSystemGenerated" smallint, "_TransactionTypeB2C" smallint, "_TransactionTypeB2B" smallint, "_TransactionTypeCBW" smallint, "_TransactionTypeDE" smallint, "_TransactionTypeEXPWP" smallint, "_TransactionTypeEXPWOP" smallint, "_TransactionTypeSEZWP" smallint, "_TransactionTypeSEZWOP" smallint, "_TransactionTypeIMPS" smallint, "_TransactionTypeIMPG" smallint, "_SectTypeAll" integer, "_DocumentSummaryTypeGstr1B2CS" smallint, "_DocumentSummaryTypeGSTR1ECOM" smallint, "_DocumentSummaryTypeGSTR1SUPECO" smallint, "_DocumentSummaryTypeGstr1ADV" smallint, "_DocumentSummaryTypeGstr1ADVAJ" smallint, "_DocumentSummaryTypeGstr1NIL" smallint, "_DocumentSummaryTypeGstr2NIL" smallint, "_DocumentTypeINV" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeBOE" smallint, "_Gstr3bSectionOutwardTaxSupply" integer, "_Gstr3bSectionOutwardZeroRated" integer, "_Gstr3bSectionOutwardNilRated" integer, "_Gstr3bSectionInwardReverseCharge" integer, "_Gstr3bSectionOutwardNonGst" integer, "_Gstr3bSectionInterStateB2c" integer, "_Gstr3bSectionInterStateComp" integer, "_Gstr3bSectionInterStateUin" integer, "_Gstr3bSectionImportOfGoods" integer, "_Gstr3bSectionImportOfServices" integer, "_Gstr3bSectionInwardReverseChargeOther" integer, "_Gstr3bSectionInwardSuppliesFromIsd" integer, "_Gstr3bSectionOtherItc" integer, "_Gstr3bSectionItcReversedAsPerRule" integer, "_Gstr3bSectionItcReversedOthers" integer, "_Gstr3bSectionNilExempt" integer, "_Gstr3bSectionNonGst" integer, "_Gstr3bSectionEcoSupplies" integer, "_Gstr3bSectionEcoRegSupplies" integer, "_Gstr3bSectionIneligibleItcAsPerRule" integer, "_Gstr3bSectionIneligibleItcOthers" integer, "_ItcEligibilityNo" smallint, "_TaxPayerTypeCOM" smallint, "_TaxPayerTypeUNB" smallint, "_TaxPayerTypeEMB" smallint, "_TaxPayerTypeISD" smallint, "_TaxPayerTypeONP" smallint, "_NilExemptNonGstTypeINTRB2B" smallint, "_NilExemptNonGstTypeINTRB2C" smallint, "_NilExemptNonGstTypeINTRAB2B" smallint, "_NilExemptNonGstTypeINTRAB2C" smallint, "_NilExemptNonGstTypeINTRA" smallint, "_NilExemptNonGstTypeINTER" smallint, "_SourceTypeTaxPayer" smallint, "_SourceTypeCounterPartyFiled" smallint, "_SourceTypeCounterPartyNotFiled" smallint, "_ReconciliationSectionTypePROnly" smallint, "_ReconciliationSectionTypeMatched" smallint, "_ReconciliationSectionTypeMatchedDueToTolerance" smallint, "_ReconciliationSectionTypeNearMatched" smallint, "_ReconciliationSectionTypeMisMatched" smallint, "_ReconciliationSectionTypeGstOnly" smallint, "_ReconciliationSectionTypePRExcluded" smallint, "_ReconciliationSectionTypeGstExcluded" smallint, "_ReconciliationSectionTypePRDiscarded" smallint, "_ReconciliationSectionTypeGstDiscarded" smallint, "_DocumentStatusActive" smallint, "_ContactTypeBillFrom" smallint, "_ContactTypeBillTo" smallint, "_ItcAvailabilityTypeN" smallint, "_ItcAvailabilityTypeY" smallint, "_ItcAvailabilityTypeT" smallint, "_GstActOrRuleSectionTypeGstAct95" smallint, "_GstActOrRuleSectionTypeGstAct38" smallint, "_GstActOrRuleSectionTypeGstAct42" smallint, "_GstActOrRuleSectionTypeGstAct43" smallint, "_GstActOrRuleSectionTypeGstActItc175" smallint, "_ReconciliationTypeGstr2B" smallint, "_TaxTypeTAXABLE" smallint, "_Gstr3bAutoPopulateTypeGstActRuleSection" smallint, "_Gstr3bAutoPopulateTypeExemptedTurnoverRatio" smallint)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$

/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [gst].[GenerateGstr3b]
*	Comments		: 16/04/2024 | Jitendra Sharma | This procedure is used to Generate Gstr3b Data. (Rewrite)					
*	Sample Execution : 

					SELECT * FROM  gst."GenerateGstr3b"
					(
						"_SubscriberId" := 164 :: integer,
						"_EntityId" := 16892 :: integer,
						"_FinancialYear" := 202324 :: integer,
						"_ReturnPeriod" := 22024 :: integer,
						"_PreviousReturnPeriods" := ARRAY[42023,52023,62023,72023,82023,92023,102023,112023,122023,12024,22024,32024] :: integer[],
						"_LastFilingDate" := NULL :: timestamp without time zone,	
						"_Gstr3bAutoPopulateType" := 2:: smallint,
						"_Month" := 7 :: integer,
						"_LocationPos" := 33 :: smallint,
						"_IsQuarterlyFiling" := 0 :: BOOLEAN,	
						"_ReturnTypeGSTR3B" := 14 :: smallint,
						"_ReturnActionSystemGenerated" := 1 :: smallint,
						"_TransactionTypeB2C" := 12:: SMALLINT ,
						"_TransactionTypeB2B" := 1:: SMALLINT ,
						"_TransactionTypeCBW" := 25:: SMALLINT ,
						"_TransactionTypeDE" := 6:: SMALLINT ,
						"_TransactionTypeEXPWP" := 2:: SMALLINT ,
						"_TransactionTypeEXPWOP" :=3:: SMALLINT ,
						"_TransactionTypeSEZWP" :=4:: SMALLINT ,
						"_TransactionTypeSEZWOP" :=5:: SMALLINT ,
						"_TransactionTypeIMPS" := 8:: SMALLINT ,
						"_TransactionTypeIMPG" :=7 :: SMALLINT ,
						"_SectTypeAll" := 1 :: integer,
						"_DocumentSummaryTypeGstr1B2CS" := 2:: SMALLINT ,
						"_DocumentSummaryTypeGSTR1ECOM" := 25:: SMALLINT ,
						"_DocumentSummaryTypeGSTR1SUPECO" := 26:: SMALLINT ,
						"_DocumentSummaryTypeGstr1ADV" := 3:: SMALLINT ,
						"_DocumentSummaryTypeGstr1ADVAJ" := 4:: SMALLINT ,
						"_DocumentSummaryTypeGstr1NIL" := 5:: SMALLINT ,
						"_DocumentSummaryTypeGstr2NIL" := 15:: SMALLINT ,
						"_DocumentTypeINV" := 1:: SMALLINT ,
						"_DocumentTypeCRN" := 2:: SMALLINT ,
						"_DocumentTypeDBN" := 3:: SMALLINT ,
						"_DocumentTypeBOE" := 4:: SMALLINT ,
						"_Gstr3bSectionOutwardTaxSupply" := 1:: INT ,
						"_Gstr3bSectionOutwardZeroRated" :=2:: INT ,
						"_Gstr3bSectionOutwardNilRated" :=3:: INT ,
						"_Gstr3bSectionInwardReverseCharge" :=4:: INT ,
						"_Gstr3bSectionOutwardNonGst" :=5:: INT ,
						"_Gstr3bSectionInterStateB2c" :=6:: INT ,
						"_Gstr3bSectionInterStateComp" :=7:: INT ,
						"_Gstr3bSectionInterStateUin" :=8:: INT ,	
						"_Gstr3bSectionImportOfGoods" :=9:: INT ,
						"_Gstr3bSectionImportOfServices" :=10:: INT ,
						"_Gstr3bSectionInwardReverseChargeOther" :=11:: INT ,
						"_Gstr3bSectionInwardSuppliesFromIsd" :=12:: INT ,
						"_Gstr3bSectionOtherItc" := 13:: INT ,
						"_Gstr3bSectionItcReversedAsPerRule" :=14:: INT ,
						"_Gstr3bSectionItcReversedOthers" :=15:: INT ,
						"_Gstr3bSectionNilExempt" :=16:: INT ,
						"_Gstr3bSectionNonGst" := 17:: INT ,
						"_Gstr3bSectionEcoSupplies" := 18:: INT ,
						"_Gstr3bSectionEcoRegSupplies" := 19:: INT ,
						"_Gstr3bSectionIneligibleItcAsPerRule" :=20:: INT ,
						"_Gstr3bSectionIneligibleItcOthers" :=21:: INT ,
						"_ItcEligibilityNo" := 4:: SMALLINT ,
						"_TaxPayerTypeCOM" := 2:: SMALLINT ,
						"_TaxPayerTypeUNB" := 9:: SMALLINT ,
						"_TaxPayerTypeEMB" := 11::smallint,
						"_TaxPayerTypeISD" := 4::smallint,
						"_TaxPayerTypeONP" := 10:: smallint,				 
						"_NilExemptNonGstTypeINTRB2B" := 1:: SMALLINT ,
						"_NilExemptNonGstTypeINTRB2C" := 3:: SMALLINT ,
						"_NilExemptNonGstTypeINTRAB2B" := 2:: SMALLINT ,
						"_NilExemptNonGstTypeINTRAB2C" := 4:: SMALLINT ,
						"_NilExemptNonGstTypeINTRA" := 5:: SMALLINT ,
						"_NilExemptNonGstTypeINTER" := 6:: SMALLINT ,
						"_SourceTypeTaxPayer" := 1:: SMALLINT ,
						"_SourceTypeCounterPartyFiled" := 3:: SMALLINT ,										 
						"_SourceTypeCounterPartyNotFiled" := 2:: SMALLINT ,
						"_ReconciliationSectionTypePROnly" := 1:: SMALLINT ,
						"_ReconciliationSectionTypeMatched" := 3 :: SMALLINT ,
						"_ReconciliationSectionTypeMatchedDueToTolerance" := 4:: SMALLINT ,
						"_ReconciliationSectionTypeNearMatched" := 6:: SMALLINT ,
						"_ReconciliationSectionTypeMisMatched" := 5:: SMALLINT ,
						"_ReconciliationSectionTypeGstOnly" :=2:: SMALLINT ,
						"_ReconciliationSectionTypePRExcluded" := 7:: SMALLINT ,
						"_ReconciliationSectionTypeGstExcluded" := 8:: SMALLINT ,
						"_ReconciliationSectionTypePRDiscarded" := 9:: SMALLINT ,
						"_ReconciliationSectionTypeGstDiscarded" := 10:: SMALLINT ,
						"_DocumentStatusActive" := 1:: SMALLINT ,
						"_ContactTypeBillFrom" := 1:: SMALLINT ,
						"_ContactTypeBillTo" := 3:: SMALLINT ,
						"_ItcAvailabilityTypeN" := 0:: SMALLINT ,
						"_ItcAvailabilityTypeY" := 1:: SMALLINT ,
						"_ItcAvailabilityTypeT" := 2:: SMALLINT ,
						"_GstActOrRuleSectionTypeGstAct95" := 1:: SMALLINT,
						"_GstActOrRuleSectionTypeGstAct38" := 6:: SMALLINT,
						"_GstActOrRuleSectionTypeGstAct42" := 2:: SMALLINT,
						"_GstActOrRuleSectionTypeGstAct43" := 3:: SMALLINT,
						"_GstActOrRuleSectionTypeGstActItc175" := 4:: SMALLINT,
						"_ReconciliationTypeGstr2B" := 8:: SMALLINT,
						"_TaxTypeTAXABLE" := 1:: SMALLINT,
						"_Gstr3bAutoPopulateTypeGstActRuleSection" := 1:: smallint,
						"_Gstr3bAutoPopulateTypeExemptedTurnoverRatio" := 2:: smallint
					)
-------------------------------------------------------------------------------------------------------------------------------*/
	DECLARE "_IsFirstMonthOfQuarter" BOOLEAN = 0; 
			"_IsSecondMonthOfQuarter" BOOLEAN = 0; 
			"_IsThirdMonthOfQurater" BOOLEAN = 0;
			"_BitTypeN" BOOLEAN = 0; 
			"_BitTypeY" BOOLEAN = 1; 
			"_Gstr3bData" refcursor; 
			"_InterStateData" refcursor; 
			"_Gstr2bExcludeItcData" refcursor;

	BEGIN	
	
	/* Final Result Table of Gstr3b Data or Gstr2b Exclude Itc Data when "IsGstr2bData" = 1 */
	DROP TABLE IF EXISTS "TempGstr3bSection_Original";
	CREATE TEMPORARY TABLE "TempGstr3bSection_Original"
	(
		"Section" INT,
		"IsGstr2bData" BOOLEAN DEFAULT 0::BOOLEAN,
		"TaxableValue" DECIMAL(18,2),
		"IgstAmount" DECIMAL(18,2),
 		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2)
	);

	/* Final Result Table of Inter State Data */
	DROP TABLE IF EXISTS "TempGstr3bInterState_Original";
	CREATE TEMPORARY TABLE "TempGstr3bInterState_Original"
	(
		"Section" INT,
		"Pos" SMALLINT,
		"TaxableValue" DECIMAL(18,2),
		"IgstAmount" DECIMAL(18,2)
	);

	DROP TABLE IF EXISTS "TempSections";
	CREATE TEMPORARY TABLE "TempSections" ("Sections" INT);
	
	INSERT INTO "TempSections"
	(
		"Sections"
	)
	VALUES
	("_Gstr3bSectionEcoSupplies"),
	("_Gstr3bSectionEcoRegSupplies"),
	("_Gstr3bSectionOutwardTaxSupply"),
	("_Gstr3bSectionOutwardZeroRated"),
	("_Gstr3bSectionOutwardNilRated"),
	("_Gstr3bSectionInwardReverseCharge"),
	("_Gstr3bSectionOutwardNonGst"),
	("_Gstr3bSectionImportOfGoods"),
	("_Gstr3bSectionImportOfServices"),
	("_Gstr3bSectionInwardReverseChargeOther"),
	("_Gstr3bSectionInwardSuppliesFromIsd"),
	("_Gstr3bSectionOtherItc"),
	("_Gstr3bSectionItcReversedAsPerRule"),
	("_Gstr3bSectionItcReversedOthers"),
	("_Gstr3bSectionIneligibleItcAsPerRule"),
	("_Gstr3bSectionIneligibleItcOthers"),
	("_Gstr3bSectionNilExempt"),
	("_Gstr3bSectionNonGst");

	/* Is quarterly filing check */
	IF("_IsQuarterlyFiling" = "_BitTypeY")
	THEN
		IF("_Month" IN (1,4,7,10))
		THEN
			"_IsFirstMonthOfQuarter" = 1;		
		ELSIF("_Month" IN (2,5,8,11))
		THEN
			"_IsSecondMonthOfQuarter" = 1;		
		ELSIF("_Month" IN (3,6,9,12))
		THEN
			"_IsThirdMonthOfQurater" = 1;
		END IF;
	END IF;

	/* Sales Data */
	DROP TABLE IF EXISTS "TempSaleDocumentIds";
	CREATE TEMP TABLE "TempSaleDocumentIds" AS
	SELECT 
		sd."Id",
		sd."ParentEntityId",
		sd."SourceType",
		sd."CombineDocumentType",
		sd."IsAmendment",
		sd."OriginalDocumentNumber",
		sd."OriginalDocumentDate"
	FROM 
		oregular."SaleDocumentDW" sd	
		INNER JOIN oregular."SaleDocumentStatus" sds on sd."Id" = sds."SaleDocumentId"
	WHERE 
		sd."SubscriberId" = "_SubscriberId"
		AND sd."ParentEntityId" = "_EntityId"
		AND sd."ReturnPeriod" = "_ReturnPeriod" 
		AND sd."SourceType" = "_SourceTypeTaxPayer"
		AND sd."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")	
		AND sd."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeCBW","_TransactionTypeDE","_TransactionTypeEXPWOP","_TransactionTypeEXPWP","_TransactionTypeSEZWP","_TransactionTypeSEZWOP")
		AND sds."Status" = "_DocumentStatusActive"
		AND sds."LiabilityDischargeReturnPeriod" IS NULL
	UNION 
	SELECT 
		sd."Id",
		sd."ParentEntityId",
		sd."SourceType",
		sd."CombineDocumentType",
		sd."IsAmendment",
		sd."OriginalDocumentNumber",
		sd."OriginalDocumentDate"
	FROM 
		oregular."SaleDocumentDW" sd	
		INNER JOIN oregular."SaleDocumentStatus" sds on sd."Id" = sds."SaleDocumentId"
	WHERE 
		sd."SubscriberId" = "_SubscriberId"
		AND sd."ParentEntityId" = "_EntityId"
		AND sd."SourceType" = "_SourceTypeTaxPayer"
		AND sd."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")	
		AND sd."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeCBW","_TransactionTypeDE","_TransactionTypeEXPWOP","_TransactionTypeEXPWP","_TransactionTypeSEZWP","_TransactionTypeSEZWOP")
		AND sds."Status" = "_DocumentStatusActive"
		AND sds."LiabilityDischargeReturnPeriod" = "_ReturnPeriod";

	/* Sale Document Items */
	DROP TABLE IF EXISTS "TempSaleDocumentItems" ;
	CREATE TEMPORARY TABLE "TempSaleDocumentItems" AS
	SELECT
		sdi."SaleDocumentId",
		sdi."GstActOrRuleSection",
		SUM(sdi."TaxableValue") AS "TaxableValue",
		SUM(sdi."IgstAmount") AS "IgstAmount",
		SUM(sdi."CgstAmount") AS "CgstAmount",
		SUM(sdi."SgstAmount") AS "SgstAmount",	
		SUM(sdi."CessAmount") AS "CessAmount"		
	FROM
		"TempSaleDocumentIds" tsd
		INNER JOIN oregular."SaleDocumentItems" AS sdi ON tsd."Id" = sdi."SaleDocumentId"
	WHERE 
		sdi."TaxType" = "_TaxTypeTAXABLE"
	GROUP BY 
		sdi."SaleDocumentId",
		sdi."GstActOrRuleSection";

	CREATE INDEX "idx_temp_TempSaleDocumentItems_saledocumentid" ON "TempSaleDocumentItems" USING BTREE("SaleDocumentId");

	/* Sales Documents Data */
	DROP TABLE IF EXISTS "TempSaleDocuments";
	CREATE TEMPORARY TABLE "TempSaleDocuments" AS
	SELECT
		sd."Id",
		sd."DocumentNumber",
		sd."DocumentDate",
		sd."DocumentType",
		sd."DocumentValue",
		sd."TaxpayerType",
		sd."TransactionType",
		sd."ReverseCharge",
		sd."ECommerceGstin",
		sd."Pos",
		sd."IsAmendment",
		sd."OriginalDocumentNumber",
		sd."OriginalDocumentDate",
		sdcf."Gstin" AS "BillFromGstin",
		sdct."Gstin" AS "BillToGstin",
		CASE WHEN LENGTH(sdct."Gstin") = 10 THEN "_BitTypeY" ELSE "_BitTypeN" END "IsBillToPAN",
		tsdi."GstActOrRuleSection",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."TaxableValue" ELSE tsdi."TaxableValue" END AS "TaxableValue",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."IgstAmount" ELSE tsdi."IgstAmount" END AS "IgstAmount",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."CgstAmount" ELSE tsdi."CgstAmount" END AS "CgstAmount",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."SgstAmount" ELSE tsdi."SgstAmount" END AS "SgstAmount",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."CessAmount" ELSE tsdi."CessAmount" END AS "CessAmount"
	FROM 
		"TempSaleDocumentItems" tsdi 
		INNER JOIN oregular."SaleDocuments" sd ON sd."Id" = tsdi."SaleDocumentId"		
		LEFT JOIN oregular."SaleDocumentContacts" AS sdcf ON sd."Id" = sdcf."SaleDocumentId" AND sdcf."Type" = "_ContactTypeBillFrom"		
		LEFT JOIN oregular."SaleDocumentContacts" AS sdct ON sd."Id" = sdct."SaleDocumentId" AND sdct."Type" = "_ContactTypeBillTo"	
	WHERE 
		sd."IsAmendment" = "_BitTypeN";

	/* Original Sales Document Items */
	DROP TABLE IF EXISTS "TempOriginalSaleDocumentItems";
	CREATE TEMPORARY TABLE "TempOriginalSaleDocumentItems" AS
	SELECT 		
		tsd."Id",	--AmendmentId
		sdo."DocumentType", 
		sdio."GstActOrRuleSection",
		SUM(sdio."TaxableValue") AS "TaxableValue",
		SUM(sdio."IgstAmount") AS "IgstAmount",
		SUM(sdio."CgstAmount") AS "CgstAmount",
		SUM(sdio."SgstAmount") AS "SgstAmount",	
		SUM(sdio."CessAmount") AS "CessAmount"
	FROM 
		"TempSaleDocumentIds" tsd
		INNER JOIN oregular."SaleDocumentDW" sdo ON sdo."DocumentNumber" = tsd."OriginalDocumentNumber" AND sdo."DocumentDate" = tsd."OriginalDocumentDate"
		INNER JOIN oregular."SaleDocumentStatus" sdso ON sdo."Id" = sdso."SaleDocumentId"
		INNER JOIN oregular."SaleDocumentItems" sdio ON sdo."Id" = sdio."SaleDocumentId"
	WHERE 
		sdo."SubscriberId" = "_SubscriberId"
		AND tsd."IsAmendment" = "_BitTypeY"
		AND sdo."ParentEntityId" = tsd."ParentEntityId"	
		AND sdo."SourceType" = "_SourceTypeTaxPayer"
		AND sdo."SourceType" = tsd."SourceType"
		AND sdo."CombineDocumentType" = tsd."CombineDocumentType"
		AND sdo."IsAmendment" = "_BitTypeN"		
		AND sdso."Status" = "_DocumentStatusActive"	
		AND sdo."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeCBW","_TransactionTypeDE","_TransactionTypeEXPWOP","_TransactionTypeEXPWP","_TransactionTypeSEZWP","_TransactionTypeSEZWOP")
		AND sdio."TaxType" = "_TaxTypeTAXABLE"
	GROUP BY 
		tsd."Id",
		sdo."DocumentType", 
		sdio."GstActOrRuleSection"; 

	/* Sales Documents Amendment Data */
	DROP TABLE IF EXISTS "TempSaleDocumentsAmendment";
	CREATE TEMPORARY TABLE 	"TempSaleDocumentsAmendment" AS
	SELECT
		sd."Id",
		sd."DocumentNumber",
		sd."DocumentDate",
		sd."DocumentType" AS "DocumentType_A", -- Amendment DocumentType
		tosdi."DocumentType", -- Original DocumentType
		sd."DocumentValue",
		sd."TaxpayerType",
		sd."TransactionType",
		sd."ReverseCharge",
		sd."ECommerceGstin",
		sd."Pos",
		sd."IsAmendment",
		sd."OriginalDocumentNumber",
		sd."OriginalDocumentDate",
		sdcf."Gstin" AS "BillFromGstin",
		sdct."Gstin" AS "BillToGstin",
		CASE WHEN length(sdct."Gstin") = 10 THEN "_BitTypeY" ELSE "_BitTypeN" END "IsBillToPAN",
		tsdi."GstActOrRuleSection",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."TaxableValue" ELSE tsdi."TaxableValue" END AS "TaxableValue_A",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."IgstAmount" ELSE tsdi."IgstAmount" END AS "IgstAmount_A",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."CgstAmount" ELSE tsdi."CgstAmount" END AS "CgstAmount_A",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."SgstAmount" ELSE tsdi."SgstAmount" END AS "SgstAmount_A",
		CASE WHEN sd."DocumentType" = "_DocumentTypeCRN" THEN -tsdi."CessAmount" ELSE tsdi."CessAmount" END AS "CessAmount_A",
		CASE WHEN tosdi."DocumentType" = "_DocumentTypeCRN" THEN -tosdi."TaxableValue" ELSE tosdi."TaxableValue" END AS "TaxableValue",
		CASE WHEN tosdi."DocumentType" = "_DocumentTypeCRN" THEN -tosdi."IgstAmount" ELSE tosdi."IgstAmount" END AS "IgstAmount",
		CASE WHEN tosdi."DocumentType" = "_DocumentTypeCRN" THEN -tosdi."CgstAmount" ELSE tosdi."CgstAmount" END AS "CgstAmount",
		CASE WHEN tosdi."DocumentType" = "_DocumentTypeCRN" THEN -tosdi."SgstAmount" ELSE tosdi."SgstAmount" END AS "SgstAmount",
		CASE WHEN tosdi."DocumentType" = "_DocumentTypeCRN" THEN -tosdi."CessAmount" ELSE tosdi."CessAmount" END AS "CessAmount"
	FROM 
		"TempSaleDocumentItems" tsdi	
		INNER JOIN "TempOriginalSaleDocumentItems" tosdi ON tsdi."SaleDocumentId" = tosdi."Id"		
		INNER JOIN oregular."SaleDocuments" AS sd ON sd."Id" = tsdi."SaleDocumentId"		
		LEFT JOIN oregular."SaleDocumentContacts" AS sdcf ON sd."Id" = sdcf."SaleDocumentId" AND sdcf."Type" = "_ContactTypeBillFrom"		
		LEFT JOIN oregular."SaleDocumentContacts" AS sdct ON sd."Id" = sdct."SaleDocumentId" AND sdct."Type" = "_ContactTypeBillTo"; 

	/* Sales Summary Data */
	DROP TABLE IF EXISTS "TempSaleSummary";
	CREATE TEMPORARY TABLE 	"TempSaleSummary" AS
	SELECT
		ss."Id",
		ss."SummaryType",
		CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
			 THEN -ss."AdvanceAmount" 
			 ELSE 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADV" 
				  THEN ss."AdvanceAmount" 
				  ELSE ss."TaxableValue" 
			 END 
		END AS "TaxableValue",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."IgstAmountForFirstMonthOfQtr" 
				  ELSE ss."IgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."IgstAmountForSecondMonthOfQtr" 
				  ELSE ss."IgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN
			 CASE WHEN ss."IgstAmount" IS NULL AND ss."IgstAmountForFirstMonthOfQtr" IS NULL AND ss."IgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."IgstAmount",0) - (COALESCE(ss."IgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."IgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."IgstAmount",0) - (COALESCE(ss."IgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."IgstAmountForSecondMonthOfQtr",0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."IgstAmount" 
				  ELSE ss."IgstAmount" 
			 END 
		END AS "IgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CgstAmountForFirstMonthOfQtr" 
				  ELSE ss."CgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CgstAmountForSecondMonthOfQtr" 
				  ELSE ss."CgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN
			 CASE WHEN ss."CgstAmount" IS NULL AND ss."CgstAmountForFirstMonthOfQtr" IS NULL AND ss."CgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."CgstAmount",0) - (COALESCE(ss."CgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."CgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."CgstAmount",0) - (COALESCE(ss."CgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."CgstAmountForSecondMonthOfQtr",0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CgstAmount" 
				  ELSE ss."CgstAmount" 
			 END 
		END AS "CgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."SgstAmountForFirstMonthOfQtr" 
				  ELSE ss."SgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."SgstAmountForSecondMonthOfQtr" 
				  ELSE ss."SgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN
			 CASE WHEN ss."SgstAmount" IS NULL AND ss."SgstAmountForFirstMonthOfQtr" IS NULL AND ss."SgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."SgstAmount",0) - (COALESCE(ss."SgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."SgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."SgstAmount",0) - (COALESCE(ss."SgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."SgstAmountForSecondMonthOfQtr",0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."SgstAmount" 
				  ELSE ss."SgstAmount" 
			 END 
		END AS "SgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CessAmountForFirstMonthOfQtr" 
				  ELSE ss."CessAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CessAmountForSecondMonthOfQtr" 
				  ELSE ss."CessAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN
			 CASE WHEN ss."CessAmount" IS NULL AND ss."CessAmountForFirstMonthOfQtr" IS NULL AND ss."CessAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."CessAmount",0) - (COALESCE(ss."CessAmountForFirstMonthOfQtr",0) + COALESCE(ss."CessAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."CessAmount",0) - (COALESCE(ss."CessAmountForFirstMonthOfQtr",0) + COALESCE(ss."CessAmountForSecondMonthOfQtr",0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CessAmount" 
				  ELSE ss."CessAmount" 
			 END 
		END AS "CessAmount",	
		ss."GstActOrRuleSectionType",
		ss."GstActOrRuleTaxableValue",
		ss."GstActOrRuleIgstAmount",
		ss."GstActOrRuleCgstAmount",
		ss."GstActOrRuleSgstAmount",
		ss."GstActOrRuleCessAmount",
		ss."IsAmendment",
		ss."NilAmount",
		ss."ExemptAmount",
		ss."NonGstAmount",
		ss."GstActOrRuleNilAmount",
		ss."GstActOrRuleExemptAmount",
		ss."Rate",
		ss."Pos",
		ss."DifferentialPercentage",
		ss."Gstin" AS "ECommerceGstin",
		ss."OriginalReturnPeriod"
	FROM
		oregular."SaleSummaries" AS ss
		INNER JOIN oregular."SaleSummaryStatus" AS sss ON ss."Id" = sss."SaleSummaryId"
	WHERE
		ss."SubscriberId" = "_SubscriberId"
		AND ss."EntityId" = "_EntityId"
		AND ss."ReturnPeriod" = "_ReturnPeriod"
		AND ss."IsAmendment" = "_BitTypeN"
		AND sss."Status" = "_DocumentStatusActive";

	/* Sales Summary Amendment Data */
	DROP TABLE IF EXISTS "TempSaleSummaryAmendment";
	CREATE TEMPORARY TABLE "TempSaleSummaryAmendment"
	(
		"Id" BIGINT,
		"SummaryType" SMALLINT,
		"TaxableValue_A" DECIMAL(18,2),
		"IgstAmount_A" DECIMAL(18,2),
		"CgstAmount_A" DECIMAL(18,2),
		"SgstAmount_A" DECIMAL(18,2),
		"CessAmount_A" DECIMAL(18,2),
		"GstActOrRuleSectionType_A" SMALLINT,
		"GstActOrRuleTaxableValue_A" DECIMAL(18,2),
		"GstActOrRuleIgstAmount_A" DECIMAL(18,2),
		"GstActOrRuleCgstAmount_A" DECIMAL(18,2),
		"GstActOrRuleSgstAmount_A" DECIMAL(18,2),
		"GstActOrRuleCessAmount_A" DECIMAL(18,2),
		"NilAmount_A" DECIMAL(18,2),
		"ExemptAmount_A" DECIMAL(18,2),
		"NonGstAmount_A" DECIMAL(18,2),
		"GstActOrRuleNilAmount_A" DECIMAL(18,2),
		"GstActOrRuleExemptAmount_A" DECIMAL(18,2),
		"Rate" DECIMAL(18,2),
		"Pos" SMALLINT,
		"DifferentialPercentage" DECIMAL(18,2),
		"ECommerceGstin" VARCHAR(15),
		"ReturnPeriod" INT,
		"TaxableValue" DECIMAL(18,2),
		"IgstAmount" DECIMAL(18,2),
		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2),
		"GstActOrRuleTaxableValue" DECIMAL(18,2),
		"GstActOrRuleIgstAmount" DECIMAL(18,2),
		"GstActOrRuleCgstAmount" DECIMAL(18,2),
		"GstActOrRuleSgstAmount" DECIMAL(18,2),
		"GstActOrRuleCessAmount" DECIMAL(18,2),
		"NilAmount" DECIMAL(18,2),
		"ExemptAmount" DECIMAL(18,2),
		"NonGstAmount" DECIMAL(18,2),
		"GstActOrRuleNilAmount" DECIMAL(18,2),
		"GstActOrRuleExemptAmount" DECIMAL(18,2)
	);

	INSERT INTO "TempSaleSummaryAmendment"
	(
		"Id",
		"SummaryType",
		"TaxableValue_A",
		"IgstAmount_A",
		"CgstAmount_A",
		"SgstAmount_A",
		"CessAmount_A",
		"GstActOrRuleSectionType_A",
		"GstActOrRuleTaxableValue_A",
		"GstActOrRuleIgstAmount_A",
		"GstActOrRuleCgstAmount_A",
		"GstActOrRuleSgstAmount_A",
		"GstActOrRuleCessAmount_A",
		"NilAmount_A",
		"ExemptAmount_A",
		"NonGstAmount_A",
		"GstActOrRuleNilAmount_A",
		"GstActOrRuleExemptAmount_A",
		"Rate",
		"Pos",
		"DifferentialPercentage",
		"ECommerceGstin",
		"ReturnPeriod",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount",
		"GstActOrRuleTaxableValue",
		"GstActOrRuleIgstAmount",
		"GstActOrRuleCgstAmount",
		"GstActOrRuleSgstAmount",
		"GstActOrRuleCessAmount",
		"NilAmount",
		"ExemptAmount",
		"NonGstAmount",
		"GstActOrRuleNilAmount",
		"GstActOrRuleExemptAmount"
	)
	SELECT
		ss."Id",
		ss."SummaryType",
		CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
			 THEN -ss."AdvanceAmount" 
			 ELSE 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADV" 
				  THEN ss."AdvanceAmount" 
				  ELSE ss."TaxableValue" 
			 END 
		END AS "TaxableValue_A",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."IgstAmountForFirstMonthOfQtr" 
				  ELSE ss."IgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."IgstAmountForSecondMonthOfQtr" 
				  ELSE ss."IgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."IgstAmount" IS NULL AND ss."IgstAmountForFirstMonthOfQtr" IS NULL AND ss."IgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."IgstAmount",0) - (COALESCE(ss."IgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."IgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."IgstAmount",0) - (COALESCE(ss."IgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."IgstAmountForSecondMonthOfQtr",0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."IgstAmount" 
				  ELSE ss."IgstAmount" 
			 END 
		END AS "IgstAmount_A",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CgstAmountForFirstMonthOfQtr" 
				  ELSE ss."CgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CgstAmountForSecondMonthOfQtr" 
				  ELSE ss."CgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."CgstAmount" IS NULL AND ss."CgstAmountForFirstMonthOfQtr" IS NULL AND ss."CgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."CgstAmount",0) - (COALESCE(ss."CgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."CgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."CgstAmount",0) - (COALESCE(ss."CgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."CgstAmountForSecondMonthOfQtr",0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CgstAmount" 
				  ELSE ss."CgstAmount" 
			 END 
		END AS "CgstAmount_A",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."SgstAmountForFirstMonthOfQtr" 
				  ELSE ss."SgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."SgstAmountForSecondMonthOfQtr" 
				  ELSE ss."SgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SgstAmount" IS NULL AND ss."SgstAmountForFirstMonthOfQtr" IS NULL AND ss."SgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."SgstAmount",0) - (COALESCE(ss."SgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."SgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."SgstAmount",0) - (COALESCE(ss."SgstAmountForFirstMonthOfQtr",0) + COALESCE(ss."SgstAmountForSecondMonthOfQtr",0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."SgstAmount" 
				  ELSE ss."SgstAmount" 
			 END 
		END AS "SgstAmount_A",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CessAmountForFirstMonthOfQtr" 
				  ELSE ss."CessAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CessAmountForSecondMonthOfQtr" 
				  ELSE ss."CessAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN ss."CessAmount" IS NULL AND ss."CessAmountForFirstMonthOfQtr" IS NULL AND ss."CessAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(ss."CessAmount",0) - (COALESCE(ss."CessAmountForFirstMonthOfQtr",0) + COALESCE(ss."CessAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(ss."CessAmount",0) - (COALESCE(ss."CessAmountForFirstMonthOfQtr",0) + COALESCE(ss."CessAmountForSecondMonthOfQtr",0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -ss."CessAmount" 
				  ELSE ss."CessAmount" 
			 END 
		END AS "CessAmount_A",
		ss."GstActOrRuleSectionType",
		ss."GstActOrRuleTaxableValue",
		ss."GstActOrRuleIgstAmount",
		ss."GstActOrRuleCgstAmount",
		ss."GstActOrRuleSgstAmount",
		ss."GstActOrRuleCessAmount",
		ss."NilAmount",
		ss."ExemptAmount",
		ss."NonGstAmount",
		ss."GstActOrRuleNilAmount",
		ss."GstActOrRuleExemptAmount",
		ss."Rate",
		ss."Pos",
		ss."DifferentialPercentage",
		ss."Gstin" AS "ECommerceGstin",
		ss."ReturnPeriod",
		CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
			 THEN -sso."AdvanceAmount" 
			 ELSE 
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADV" 
				  THEN sso."AdvanceAmount" 
				  ELSE sso."TaxableValue" 
			 END 
		END AS "TaxableValue",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType"= "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."IgstAmountForFirstMonthOfQtr" 
				  ELSE sso."IgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."IgstAmountForSecondMonthOfQtr" 
				  ELSE sso."IgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."IgstAmount" IS NULL AND sso."IgstAmountForFirstMonthOfQtr" IS NULL AND sso."IgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(sso."IgstAmount",0) - (COALESCE(sso."IgstAmountForFirstMonthOfQtr",0) + COALESCE(sso."IgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(sso."IgstAmount",0) - (COALESCE(sso."IgstAmountForFirstMonthOfQtr",0) + COALESCE(sso."IgstAmountForSecondMonthOfQtr",0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."IgstAmount" 
				  ELSE sso."IgstAmount" 
			 END 
		END AS "IgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType"= "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."CgstAmountForFirstMonthOfQtr" 
				  ELSE sso."CgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."CgstAmountForSecondMonthOfQtr" 
				  ELSE sso."CgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."CgstAmount" IS NULL AND sso."CgstAmountForFirstMonthOfQtr" IS NULL AND sso."CgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(sso."CgstAmount",0) - (COALESCE(sso."CgstAmountForFirstMonthOfQtr",0) + COALESCE(sso."CgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(sso."CgstAmount",0) - (COALESCE(sso."CgstAmountForFirstMonthOfQtr",0) + COALESCE(sso."CgstAmountForSecondMonthOfQtr",0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."CgstAmount" 
				  ELSE sso."CgstAmount" 
			 END 
		END AS "CgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType"= "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."SgstAmountForFirstMonthOfQtr" 
				  ELSE sso."SgstAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."SgstAmountForSecondMonthOfQtr" 
				  ELSE sso."SgstAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SgstAmount" IS NULL AND sso."SgstAmountForFirstMonthOfQtr" IS NULL AND sso."SgstAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(sso."SgstAmount",0) - (COALESCE(sso."SgstAmountForFirstMonthOfQtr",0) + COALESCE(sso."SgstAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(sso."SgstAmount",0) - (COALESCE(sso."SgstAmountForFirstMonthOfQtr",0) + COALESCE(sso."SgstAmountForSecondMonthOfQtr",0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."SgstAmount" 
				  ELSE sso."SgstAmount" 
			 END 
		END AS "SgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType"= "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."CessAmountForFirstMonthOfQtr" 
				  ELSE sso."CessAmountForFirstMonthOfQtr" 
			 END
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."CessAmountForSecondMonthOfQtr" 
				  ELSE sso."CessAmountForSecondMonthOfQtr" 
			 END
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN 
			 CASE WHEN sso."CessAmount" IS NULL AND sso."CessAmountForFirstMonthOfQtr" IS NULL AND sso."CessAmountForSecondMonthOfQtr" IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
					   THEN -(COALESCE(sso."CessAmount",0) - (COALESCE(sso."CessAmountForFirstMonthOfQtr",0) + COALESCE(sso."CessAmountForSecondMonthOfQtr",0))) 
					   ELSE COALESCE(sso."CessAmount",0) - (COALESCE(sso."CessAmountForFirstMonthOfQtr",0) + COALESCE(sso."CessAmountForSecondMonthOfQtr",0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ" 
				  THEN -sso."CessAmount" 
				  ELSE sso."CessAmount" 
			 END 
		END AS "CessAmount",
		sso."GstActOrRuleTaxableValue",
		sso."GstActOrRuleIgstAmount",
		sso."GstActOrRuleCgstAmount",
		sso."GstActOrRuleSgstAmount",
		sso."GstActOrRuleCessAmount",
		sso."NilAmount",
		sso."ExemptAmount",
		sso."NonGstAmount",
		sso."GstActOrRuleNilAmount",
		sso."GstActOrRuleExemptAmount"
	FROM
		oregular."SaleSummaries" AS ss
		INNER JOIN oregular."SaleSummaryStatus" AS sss ON ss."Id" = sss."SaleSummaryId"
		INNER JOIN oregular."SaleSummaries" AS sso ON sso."EntityId" = ss."EntityId" 
				   AND sso."SummaryType" = ss."SummaryType"
				   AND sso."ReturnPeriod" = ss."OriginalReturnPeriod" 
				   AND COALESCE(sso."Gstin",'') = COALESCE(ss."Gstin",'')
				   AND COALESCE(sso."Rate",-1) = COALESCE(ss."Rate",-1) 
				   AND COALESCE(sso."Pos",-1) = COALESCE(ss."Pos",-1)
				   AND COALESCE(sso."DifferentialPercentage",-1) = COALESCE(ss."DifferentialPercentage",-1) 
				   AND COALESCE(sso."GstActOrRuleSectionType",-1) = COALESCE(ss."GstActOrRuleSectionType",-1)
		INNER JOIN oregular."SaleSummaryStatus" AS ssso ON sso."Id" = ssso."SaleSummaryId"														  
	WHERE
		ss."SubscriberId" = "_SubscriberId"						  
		AND ss."EntityId" = "_EntityId"
		AND ss."ReturnPeriod" = "_ReturnPeriod"
		AND ss."IsAmendment" = "_BitTypeY"
		AND sss."Status" = "_DocumentStatusActive"
		AND sso."IsAmendment" = "_BitTypeN"
		AND ssso."Status" = "_DocumentStatusActive";

	/* Purchase Document Manual Data */
	DROP TABLE IF EXISTS "ManualMapperData";
	CREATE TEMPORARY TABLE "ManualMapperData" AS
	SELECT 
		(Pr ->> 'PrId')::BIGINT AS "DocumentId",
		M."SectionType",
		M."Id" AS "MapperId",
		"_SourceTypeTaxPayer" AS "SourceType"
	FROM
		oregular."PurchaseDocumentRecoManualMapper" M
		INNER JOIN LATERAL json_array_elements("PrIds" :: json) Pr("PrId") on true 
	WHERE 
		M."SubscriberId" = "_SubscriberId"
		AND M."ParentEntityId" = "_EntityId"
		AND M."ReconciliationType" = "_ReconciliationTypeGstr2B"
	UNION
	SELECT 
		(Gst ->> 'GstId')::BIGINT AS "DocumentId",
		M."SectionType",
		M."Id" AS "MapperId",
		"_SourceTypeCounterPartyFiled" AS "SourceType"
	FROM
		oregular."PurchaseDocumentRecoManualMapper" M
		INNER JOIN LATERAL json_array_elements("GstIds" :: json) Gst("GstId") on true 
	WHERE
		M."SubscriberId" = "_SubscriberId"
		AND M."ParentEntityId" = "_EntityId"
		AND M."ReconciliationType" = "_ReconciliationTypeGstr2B";

	/*Purchase Documents Data With Filtered Paramaters*/
	DROP TABLE IF EXISTS "TempPurchaseDocumentIds";
	CREATE TEMPORARY TABLE 	"TempPurchaseDocumentIds" AS
	SELECT 
		mmd."MapperId",
		mmd."SourceType" AS "ManualSourceType",
		mmd."DocumentId",
		pd."Id",
		pd."EntityId",
		pd."SourceType", 
		pd."DocumentType",
		pd."CombineDocumentType",
		pd."TransactionType",
		pd."ReverseCharge",
		pd."BillFromGstin",
		pd."IsAmendment",
		pd."OriginalDocumentNumber",
		pd."OriginalDocumentDate",
		pds."Gstr2BReturnPeriod",
		COALESCE(mmd."SectionType", gdrmcp."SectionType", gdrmpr."SectionType", gdrmcpboe."SectionType", gdrmprboe."SectionType") "ReconciliationSectionType",
		pds."ItcAvailability",
		pds."IsAvailableInGstr2B",
		pds."ItcClaimReturnPeriod",
		pds."LiabilityDischargeReturnPeriod"
	FROM 
		oregular."PurchaseDocumentDW" pd	
		INNER JOIN oregular."PurchaseDocumentStatus" AS pds ON pd."Id" = pds."PurchaseDocumentId"
		LEFT JOIN oregular."Gstr2bDocumentRecoMapper" AS gdrmcp ON gdrmcp."GstnId" = pd."Id"
		LEFT JOIN oregular."Gstr2bDocumentRecoMapper" AS gdrmpr ON gdrmpr."PrId" = pd."Id"
		LEFT JOIN oregular."Gstr2aDocumentRecoMapper" AS gdrmcpboe ON gdrmcpboe."GstnId" = pd."Id"
		LEFT JOIN oregular."Gstr2aDocumentRecoMapper" AS gdrmprboe ON gdrmprboe."PrId" = pd."Id"
		LEFT JOIN "ManualMapperData" mmd ON pd."Id" = mmd."DocumentId"
	WHERE						
		pd."SubscriberId" = "_SubscriberId"
		AND pd."ParentEntityId" = "_EntityId"
		AND pd."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN","_DocumentTypeBOE")						
		AND pds."Status" = "_DocumentStatusActive"
		AND (
				(
					(
						pds."ItcClaimReturnPeriod" = "_ReturnPeriod"
						OR 
						pds."LiabilityDischargeReturnPeriod" = "_ReturnPeriod"
						OR 
						(pd."ReturnPeriod" = "_ReturnPeriod" AND pds."LiabilityDischargeReturnPeriod" IS NULL AND pds."ItcClaimReturnPeriod" IS NULL)
					)
					AND pd."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeIMPS","_TransactionTypeCBW","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeDE","_TransactionTypeIMPG")
				)
				OR
				(
					pds."IsAvailableInGstr2B" = "_BitTypeY"
					AND pds."Gstr2BReturnPeriod" = "_ReturnPeriod" 
				)
			);

	DROP TABLE IF EXISTS "TempMapper";
	CREATE TEMPORARY TABLE "TempMapper" AS
	SELECT 
		tp."Id"		
	FROM 
		"TempPurchaseDocumentIds" tp
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" AS gdrm ON gdrm."GstnId" = tp."Id"
	WHERE 
		gdrm."SectionType" IN ("_ReconciliationSectionTypeMatched", "_ReconciliationSectionTypeMisMatched", "_ReconciliationSectionTypeNearMatched", "_ReconciliationSectionTypeMatchedDueToTolerance")
	UNION 
	SELECT 
		tp."Id"		
	FROM 
		"TempPurchaseDocumentIds" tp
		INNER JOIN oregular."Gstr2aDocumentRecoMapper" AS gdrm ON gdrm."GstnId" = tp."Id"
	WHERE 
		tp."DocumentType" = "_DocumentTypeBOE"
		AND gdrm."SectionType" IN ("_ReconciliationSectionTypeMatched", "_ReconciliationSectionTypeMisMatched", "_ReconciliationSectionTypeNearMatched", "_ReconciliationSectionTypeMatchedDueToTolerance");
	
	/* Purchase Document Items */
	DROP TABLE IF EXISTS "TempPurchaseDocumentItems";
	CREATE TEMPORARY TABLE "TempPurchaseDocumentItems"
	(
		"PurchaseDocumentId" BIGINT,
		"ItcEligibility" SMALLINT,
		"GstActOrRuleSection" SMALLINT,
		"TaxableValue" DECIMAL(18,2),
		"IgstAmount" DECIMAL(18,2),
		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2),
		"ItcIgstAmount" DECIMAL(18,2),
		"ItcCgstAmount" DECIMAL(18,2),
		"ItcSgstAmount" DECIMAL(18,2),
		"ItcCessAmount" DECIMAL(18,2)
	);	

	INSERT INTO "TempPurchaseDocumentItems"
	(
		"PurchaseDocumentId",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)		
	SELECT
		pdi."PurchaseDocumentId",
		SUM(pdi."TaxableValue") AS "TaxableValue",
		SUM(pdi."IgstAmount") AS "IgstAmount",
		SUM(pdi."CgstAmount") AS "CgstAmount",
		SUM(pdi."SgstAmount") AS "SgstAmount",
		SUM(pdi."CessAmount") AS "CessAmount"
	FROM
		oregular."PurchaseDocumentItems" AS pdi
		INNER JOIN "TempPurchaseDocumentIds" tp ON tp."Id" = pdi."PurchaseDocumentId"
	WHERE				
		tp."SourceType" IN ("_SourceTypeCounterPartyFiled","_SourceTypeCounterPartyNotFiled") 
		AND tp."ReconciliationSectionType" IN ("_ReconciliationSectionTypeGstOnly","_ReconciliationSectionTypeGstExcluded","_ReconciliationSectionTypeGstDiscarded")
		AND NOT EXISTS (SELECT * FROM "TempMapper" t where t."Id" = tp."Id")
	GROUP BY 
		pdi."PurchaseDocumentId";

	INSERT INTO "TempPurchaseDocumentItems"
	(
		"PurchaseDocumentId",
		"ItcEligibility",
		"GstActOrRuleSection",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount",
		"ItcIgstAmount",
		"ItcCgstAmount",
		"ItcSgstAmount",
		"ItcCessAmount"
	)		
	SELECT
		pdi."PurchaseDocumentId",
		pdi."ItcEligibility",
		pdi."GstActOrRuleSection",
		SUM(pdi."TaxableValue") AS "TaxableValue",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" OR tp."ReverseCharge" = "_BitTypeY" THEN pdi."IgstAmount" ELSE 0 END) AS "IgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" OR tp."ReverseCharge" = "_BitTypeY" THEN pdi."CgstAmount" ELSE 0 END) AS "CgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" OR tp."ReverseCharge" = "_BitTypeY" THEN pdi."SgstAmount" ELSE 0 END) AS "SgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" OR tp."ReverseCharge" = "_BitTypeY" THEN pdi."CessAmount" ELSE 0 END) AS "CessAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdi."ItcIgstAmount" END) AS "ItcIgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdi."ItcCgstAmount" END) AS "ItcCgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdi."ItcSgstAmount" END) AS "ItcSgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdi."ItcCessAmount" END) AS "ItcCessAmount"
	FROM
		oregular."PurchaseDocumentItems" AS pdi
		INNER JOIN "TempPurchaseDocumentIds" tp ON tp."Id" = pdi."PurchaseDocumentId"
	WHERE 
		tp."SourceType" = "_SourceTypeTaxPayer" 
		AND 
		(
			(
				tp."ReconciliationSectionType" IS NULL 
				AND 
				(
					tp."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeCBW","_TransactionTypeIMPS")
					OR
					(
						tp."TransactionType" IN ("_TransactionTypeB2B","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeDE")
						AND tp."ReverseCharge" = "_BitTypeY"
					)
				)
			)
			OR
			tp."ReconciliationSectionType" IN ("_ReconciliationSectionTypePROnly", "_ReconciliationSectionTypeMatched", "_ReconciliationSectionTypeMatchedDueToTolerance","_ReconciliationSectionTypeMisMatched","_ReconciliationSectionTypeNearMatched","_ReconciliationSectionTypePRExcluded","_ReconciliationSectionTypePRDiscarded")
		)
	GROUP BY 
		pdi."PurchaseDocumentId",
		pdi."ItcEligibility",
		pdi."GstActOrRuleSection";

	/* Purchase Documents Data*/
	DROP TABLE IF EXISTS "TempPurchaseDocuments";
	CREATE TEMPORARY TABLE "TempPurchaseDocuments" AS	
	SELECT
		pd."Id",
		pd."SourceType",
		pd."DocumentNumber",
		pd."DocumentDate",
		pd."DocumentType",
		pd."DocumentValue",
		pd."ReturnPeriod",
		pd."TaxpayerType",
		pd."TransactionType",
		pd."ReverseCharge",
		pd."Pos",
		pd."PortCode",
		tp."BillFromGstin",
		CASE WHEN LENGTH(tp."BillFromGstin") = 10 THEN "_BitTypeY" ELSE "_BitTypeN" END "IsBillFromPAN",
		tp."Gstr2BReturnPeriod",
		tp."ReconciliationSectionType",
		pds."Action",
		pds."ItcAvailability",
		pds."IsAvailableInGstr2B",
		pds."ItcClaimReturnPeriod",
		pds."LiabilityDischargeReturnPeriod",
		tpdi."GstActOrRuleSection",
		tpdi."ItcEligibility",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."TaxableValue" ELSE tpdi."TaxableValue" END AS "TaxableValue",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."IgstAmount" ELSE tpdi."IgstAmount" END AS "IgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CgstAmount" ELSE tpdi."CgstAmount" END AS "CgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."SgstAmount" ELSE tpdi."SgstAmount" END AS "SgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CessAmount" ELSE tpdi."CessAmount" END AS "CessAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcIgstAmount" ELSE tpdi."ItcIgstAmount" END AS "ItcIgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCgstAmount" ELSE tpdi."ItcCgstAmount" END AS "ItcCgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcSgstAmount" ELSE tpdi."ItcSgstAmount" END AS "ItcSgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCessAmount" ELSE tpdi."ItcCessAmount" END AS "ItcCessAmount",
		COALESCE(pd."ModifiedStamp", pd."Stamp") AS "Stamp"
	FROM 
		"TempPurchaseDocumentIds" tp
		INNER JOIN "TempPurchaseDocumentItems" tpdi ON tpdi."PurchaseDocumentId" = tp."Id"	
		INNER JOIN oregular."PurchaseDocuments" AS pd ON pd."Id" = tp."Id"
		INNER JOIN oregular."PurchaseDocumentStatus" AS pds ON pd."Id" = pds."PurchaseDocumentId"
	WHERE
		tp."IsAmendment" = "_BitTypeN";
	
	/* Original Purchase Document Items */
	DROP TABLE IF EXISTS "TempOriginalPurchaseDocumentItems";
	CREATE TEMPORARY TABLE "TempOriginalPurchaseDocumentItems" AS
	SELECT 		
		tpd."Id",					
		pdo."DocumentType",
		pdso."ItcAvailability",
		pdso."ItcClaimReturnPeriod",
		pdio."ItcEligibility",
		pdio."GstActOrRuleSection",
		pdo."TotalTaxAmount",
		SUM(pdio."TaxableValue") AS "TaxableValue",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" OR pdo."ReverseCharge" = "_BitTypeY" THEN pdio."IgstAmount" ELSE 0 END) AS "IgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" OR pdo."ReverseCharge" = "_BitTypeY" THEN pdio."CgstAmount" ELSE 0 END) AS "CgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" OR pdo."ReverseCharge" = "_BitTypeY" THEN pdio."SgstAmount" ELSE 0 END) AS "SgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" OR pdo."ReverseCharge" = "_BitTypeY" THEN pdio."CessAmount" ELSE 0 END) AS "CessAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdio."ItcIgstAmount" END) AS "ItcIgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdio."ItcCgstAmount" END) AS "ItcCgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdio."ItcSgstAmount" END) AS "ItcSgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN 0 ELSE pdio."ItcCessAmount" END) AS "ItcCessAmount"
	FROM 				
		"TempPurchaseDocumentIds" tpd
		INNER JOIN oregular."PurchaseDocumentDW" pdo ON tpd."OriginalDocumentNumber" = pdo."DocumentNumber" AND tpd."OriginalDocumentDate" = pdo."DocumentDate" AND COALESCE(pdo."BillFromGstin",'') = COALESCE(tpd."BillFromGstin",'')
		INNER JOIN oregular."PurchaseDocumentStatus" pdso on pdo."Id" = pdso."PurchaseDocumentId"
		INNER JOIN oregular."PurchaseDocumentItems" pdio ON pdo."Id" = pdio."PurchaseDocumentId"
	WHERE 
		pdo."SubscriberId" = "_SubscriberId"
		AND pdo."ParentEntityId" = tpd."EntityId"
		AND pdo."SourceType" = tpd."SourceType"									
		AND pdo."CombineDocumentType" = tpd."CombineDocumentType"
		AND pdo."IsAmendment" = "_BitTypeN"			
		AND pdo."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeIMPS","_TransactionTypeCBW","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeDE","_TransactionTypeIMPG")
		AND pdso."Status" = "_DocumentStatusActive"
		AND tpd."IsAmendment" = "_BitTypeY"	
	GROUP BY 
		tpd."Id",		
		pdo."DocumentType",
		pdso."ItcAvailability",
		pdso."ItcClaimReturnPeriod",
		pdio."ItcEligibility",
		pdio."GstActOrRuleSection",
		pdo."TotalTaxAmount";

	/* Purchase Documents Amendment Data */
	DROP TABLE IF EXISTS "TempPurchaseDocumentsAmendment";
	CREATE TEMPORARY TABLE "TempPurchaseDocumentsAmendment" AS
	SELECT
		pd."Id",
		pd."DocumentNumber",
		pd."DocumentDate",
		pd."DocumentType" AS "DocumentType_A", -- Amendment DocumentType
		topdi."DocumentType", -- Original DocumentType
		pd."DocumentValue",
		pd."TaxpayerType",
		pd."TransactionType",
		pd."SourceType",
		pd."ReverseCharge",
		pd."Pos",
		pd."PortCode",
		pd."ReturnPeriod",
		pd."IsAmendment",
		pd."OriginalDocumentNumber",
		pd."OriginalDocumentDate",
		pd."OriginalPortCode",
		tpd."BillFromGstin",
		tpd."ReconciliationSectionType",
		tpd."ItcAvailability",
		tpd."Gstr2BReturnPeriod",
		tpd."IsAvailableInGstr2B",
		tpd."ItcClaimReturnPeriod",
		tpd."LiabilityDischargeReturnPeriod",
		tpdi."ItcEligibility",
		tpdi."GstActOrRuleSection",
		CASE WHEN length(tpd."BillFromGstin") = 10 THEN "_BitTypeY" ELSE "_BitTypeN" END "IsBillFromPAN",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."TaxableValue" ELSE tpdi."TaxableValue" END AS "TaxableValue_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."IgstAmount" ELSE tpdi."IgstAmount" END AS "IgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CgstAmount" ELSE tpdi."CgstAmount" END AS "CgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."SgstAmount" ELSE tpdi."SgstAmount" END AS "SgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CessAmount" ELSE tpdi."CessAmount" END AS "CessAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcIgstAmount" ELSE tpdi."ItcIgstAmount" END AS "ItcIgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCgstAmount" ELSE tpdi."ItcCgstAmount" END AS "ItcCgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcSgstAmount" ELSE tpdi."ItcSgstAmount" END AS "ItcSgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCessAmount" ELSE tpdi."ItcCessAmount" END AS "ItcCessAmount_A",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."TaxableValue" ELSE topdi."TaxableValue" END AS "TaxableValue",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."IgstAmount" ELSE topdi."IgstAmount" END AS "IgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."CgstAmount" ELSE topdi."CgstAmount" END AS "CgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."SgstAmount" ELSE topdi."SgstAmount" END AS "SgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."CessAmount" ELSE topdi."CessAmount" END AS "CessAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcIgstAmount" ELSE topdi."ItcIgstAmount" END AS "ItcIgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcCgstAmount" ELSE topdi."ItcCgstAmount" END AS "ItcCgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcSgstAmount" ELSE topdi."ItcSgstAmount" END AS "ItcSgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcCessAmount" ELSE topdi."ItcCessAmount" END AS "ItcCessAmount",
		COALESCE(pd."ModifiedStamp",pd."Stamp") AS "Stamp"
	FROM 
		"TempPurchaseDocumentIds" tpd
		INNER JOIN "TempPurchaseDocumentItems" tpdi ON tpdi."PurchaseDocumentId" = tpd."Id"	
		INNER JOIN "TempOriginalPurchaseDocumentItems" topdi ON tpdi."PurchaseDocumentId" = topdi."Id" AND tpdi."ItcEligibility" = topdi."ItcEligibility"
		INNER JOIN oregular."PurchaseDocuments" pd ON pd."Id" = tpdi."PurchaseDocumentId";

	/* Original Purchase Document Items For Circluar 170  */
	DROP TABLE IF EXISTS "TempOriginalPurchaseDocumentItemsCircular170";
	CREATE TEMPORARY TABLE "TempOriginalPurchaseDocumentItemsCircular170" AS
	SELECT 		
		tpd."Id",					
		pdo."DocumentType",
		pdso."ItcAvailability",
		pdso."ItcClaimReturnPeriod",
		SUM(pdio."TaxableValue") AS "TaxableValue",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN pdio."IgstAmount" ELSE NULL END) AS "IgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN pdio."CgstAmount" ELSE NULL END) AS "CgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN pdio."SgstAmount" ELSE NULL END) AS "SgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN pdio."CessAmount" ELSE NULL END) AS "CessAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdio."ItcIgstAmount" END) AS "ItcIgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdio."ItcCgstAmount" END) AS "ItcCgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdio."ItcSgstAmount" END) AS "ItcSgstAmount",
		SUM(CASE WHEN pdio."ItcEligibility" IS NULL OR pdio."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdio."ItcCessAmount" END) AS "ItcCessAmount",
		SUM(CASE WHEN pdio."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdio."IgstAmount" ELSE NULL END) AS "IgstAmount_175",
		SUM(CASE WHEN pdio."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdio."CgstAmount" ELSE NULL END) AS "CgstAmount_175",
		SUM(CASE WHEN pdio."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdio."SgstAmount" ELSE NULL END) AS "SgstAmount_175",
		SUM(CASE WHEN pdio."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdio."CessAmount" ELSE NULL END) AS "CessAmount_175",
		SUM(CASE WHEN pdio."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdio."ItcIgstAmount" ELSE NULL END) AS "ItcIgstAmount_38_42_43",
		SUM(CASE WHEN pdio."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdio."ItcCgstAmount" ELSE NULL END) AS "ItcCgstAmount_38_42_43",
		SUM(CASE WHEN pdio."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdio."ItcSgstAmount" ELSE NULL END) AS "ItcSgstAmount_38_42_43",
		SUM(CASE WHEN pdio."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdio."ItcCessAmount" ELSE NULL END) AS "ItcCessAmount_38_42_43"
	FROM 				
		"TempPurchaseDocumentIds" tpd
		INNER JOIN oregular."PurchaseDocumentDW" pdo ON tpd."OriginalDocumentNumber" = pdo."DocumentNumber" AND tpd."OriginalDocumentDate" = pdo."DocumentDate" AND COALESCE(pdo."BillFromGstin",'') = COALESCE(tpd."BillFromGstin",'')
		INNER JOIN oregular."PurchaseDocumentStatus" pdso on pdo."Id" = pdso."PurchaseDocumentId"
		INNER JOIN oregular."PurchaseDocumentItems" pdio ON pdo."Id" = pdio."PurchaseDocumentId"
	WHERE 
		pdo."SubscriberId" = "_SubscriberId"
		AND pdo."ParentEntityId" = tpd."EntityId"
		AND pdo."SourceType" = tpd."SourceType"									
		AND pdo."CombineDocumentType" = tpd."CombineDocumentType"
		AND pdo."IsAmendment" = "_BitTypeN"			
		AND pdo."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeIMPS","_TransactionTypeCBW","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeDE","_TransactionTypeIMPG")
		AND pdso."Status" = "_DocumentStatusActive"
		AND tpd."IsAmendment" = "_BitTypeY"	
	GROUP BY 
		tpd."Id",		
		pdo."DocumentType",
		pdso."ItcAvailability",
		pdso."ItcClaimReturnPeriod";

	/* Purchase Document Items For Circluar 170 */
	DROP TABLE IF EXISTS "TempPurchaseDocumentItemsCircular170";
	CREATE TEMPORARY TABLE "TempPurchaseDocumentItemsCircular170" AS
	SELECT
		pdi."PurchaseDocumentId",
		SUM(pdi."TaxableValue") AS "TaxableValue",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN pdi."IgstAmount" ELSE NULL END) AS "IgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN pdi."CgstAmount" ELSE NULL END) AS "CgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN pdi."SgstAmount" ELSE NULL END) AS "SgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN pdi."CessAmount" ELSE NULL END) AS "CessAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdi."ItcIgstAmount" END) AS "ItcIgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdi."ItcCgstAmount" END) AS "ItcCgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdi."ItcSgstAmount" END) AS "ItcSgstAmount",
		SUM(CASE WHEN pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdi."ItcCessAmount" END) AS "ItcCessAmount",
		SUM(CASE WHEN pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdi."IgstAmount" ELSE NULL END) AS "IgstAmount_175",
		SUM(CASE WHEN pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdi."CgstAmount" ELSE NULL END) AS "CgstAmount_175",
		SUM(CASE WHEN pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdi."SgstAmount" ELSE NULL END) AS "SgstAmount_175",
		SUM(CASE WHEN pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdi."CessAmount" ELSE NULL END) AS "CessAmount_175",
		SUM(CASE WHEN pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdi."ItcIgstAmount" ELSE NULL END) AS "ItcIgstAmount_38_42_43",
		SUM(CASE WHEN pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdi."ItcCgstAmount" ELSE NULL END) AS "ItcCgstAmount_38_42_43",
		SUM(CASE WHEN pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdi."ItcSgstAmount" ELSE NULL END) AS "ItcSgstAmount_38_42_43",
		SUM(CASE WHEN pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdi."ItcCessAmount" ELSE NULL END) AS "ItcCessAmount_38_42_43"
	FROM
		oregular."PurchaseDocumentItems" AS pdi
		INNER JOIN "TempPurchaseDocumentIds" tp ON tp."Id" = pdi."PurchaseDocumentId"
	WHERE 
		tp."ReconciliationSectionType" IN ("_ReconciliationSectionTypeGstOnly","_ReconciliationSectionTypeGstExcluded","_ReconciliationSectionTypeGstDiscarded", "_ReconciliationSectionTypeMatched", 
		"_ReconciliationSectionTypeMatchedDueToTolerance","_ReconciliationSectionTypeMisMatched","_ReconciliationSectionTypeNearMatched")
	GROUP BY 
		pdi."PurchaseDocumentId";

	/* Purchase Documents Data*/
	DROP TABLE IF EXISTS "TempPurchaseDocumentsCircular170";
	CREATE TEMPORARY TABLE "TempPurchaseDocumentsCircular170" AS	
	SELECT
		pd."Id",
		pd."SourceType",
		pd."DocumentNumber",
		pd."DocumentDate",
		pd."DocumentType",
		pd."DocumentValue",
		pd."ReturnPeriod",
		pd."TaxpayerType",
		pd."TransactionType",
		pd."ReverseCharge",
		pd."Pos",
		pd."PortCode",
		tp."BillFromGstin",
		CASE WHEN LENGTH(tp."BillFromGstin") = 10 THEN "_BitTypeY" ELSE "_BitTypeN" END "IsBillFromPAN",
		tp."Gstr2BReturnPeriod",
		tp."ReconciliationSectionType",
		tp."ItcAvailability",
		tp."IsAvailableInGstr2B",
		tp."ItcClaimReturnPeriod",
		tp."LiabilityDischargeReturnPeriod",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(tpdi."IgstAmount",0) + COALESCE(tpdi."CgstAmount",0) + COALESCE(tpdi."SgstAmount",0) + COALESCE(tpdi."CessAmount",0)) 
			 ELSE (COALESCE(tpdi."IgstAmount",0) + COALESCE(tpdi."CgstAmount",0) + COALESCE(tpdi."SgstAmount",0) + COALESCE(tpdi."CessAmount",0)) END AS "TotalTaxAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."TaxableValue" ELSE tpdi."TaxableValue" END AS "TaxableValue",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."IgstAmount" ELSE tpdi."IgstAmount" END AS "IgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CgstAmount" ELSE tpdi."CgstAmount" END AS "CgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."SgstAmount" ELSE tpdi."SgstAmount" END AS "SgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CessAmount" ELSE tpdi."CessAmount" END AS "CessAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(tpdi."IgstAmount_175",0) + COALESCE(tpdi."CgstAmount_175",0) + COALESCE(tpdi."SgstAmount_175",0) + COALESCE(tpdi."CessAmount_175",0)) 
			 ELSE (COALESCE(tpdi."IgstAmount_175",0) + COALESCE(tpdi."CgstAmount_175",0) + COALESCE(tpdi."SgstAmount_175",0) + COALESCE(tpdi."CessAmount_175",0)) END AS "TotalTaxAmount_175",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."IgstAmount_175" ELSE tpdi."IgstAmount_175" END AS "IgstAmount_175",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CgstAmount_175" ELSE tpdi."CgstAmount_175" END AS "CgstAmount_175",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."SgstAmount_175" ELSE tpdi."SgstAmount_175" END AS "SgstAmount_175",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CessAmount_175" ELSE tpdi."CessAmount_175" END AS "CessAmount_175",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(tpdi."ItcIgstAmount",0) + COALESCE(tpdi."ItcCgstAmount",0) + COALESCE(tpdi."ItcSgstAmount",0) + COALESCE(tpdi."ItcCessAmount",0)) 
			 ELSE (COALESCE(tpdi."ItcIgstAmount",0) + COALESCE(tpdi."ItcCgstAmount",0) + COALESCE(tpdi."ItcSgstAmount",0) + COALESCE(tpdi."ItcCessAmount",0)) END AS "TotalItcAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcIgstAmount" ELSE tpdi."ItcIgstAmount" END AS "ItcIgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCgstAmount" ELSE tpdi."ItcCgstAmount" END AS "ItcCgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcSgstAmount" ELSE tpdi."ItcSgstAmount" END AS "ItcSgstAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCessAmount" ELSE tpdi."ItcCessAmount" END AS "ItcCessAmount",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(tpdi."ItcIgstAmount_38_42_43",0) + COALESCE(tpdi."ItcCgstAmount_38_42_43",0) + COALESCE(tpdi."ItcSgstAmount_38_42_43",0) + COALESCE(tpdi."ItcCessAmount_38_42_43",0)) 
			 ELSE (COALESCE(tpdi."ItcIgstAmount_38_42_43",0) + COALESCE(tpdi."ItcCgstAmount_38_42_43",0) + COALESCE(tpdi."ItcSgstAmount_38_42_43",0) + COALESCE(tpdi."ItcCessAmount_38_42_43",0)) END AS "TotalItcAmount_38_42_43",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcIgstAmount_38_42_43" ELSE tpdi."ItcIgstAmount_38_42_43" END AS "ItcIgstAmount_38_42_43",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCgstAmount_38_42_43" ELSE tpdi."ItcCgstAmount_38_42_43" END AS "ItcCgstAmount_38_42_43",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcSgstAmount_38_42_43" ELSE tpdi."ItcSgstAmount_38_42_43" END AS "ItcSgstAmount_38_42_43",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCessAmount_38_42_43" ELSE tpdi."ItcCessAmount_38_42_43" END AS "ItcCessAmount_38_42_43",
		COALESCE(pd."ModifiedStamp", pd."Stamp") AS "Stamp"
	FROM 
		"TempPurchaseDocumentIds" tp
		INNER JOIN "TempPurchaseDocumentItemsCircular170" tpdi ON tpdi."PurchaseDocumentId" = tp."Id"	
		INNER JOIN oregular."PurchaseDocuments" AS pd ON pd."Id" = tp."Id"
	WHERE
		tp."IsAmendment" = "_BitTypeN"
		AND tp."MapperId" IS NULL;

	CREATE INDEX "Idx_TempPurchaseDocumentsCircular170_Id" ON "TempPurchaseDocumentsCircular170" USING BTREE("Id");

	/* Manual Purchase Document Items For Circluar 170 */
	DROP TABLE IF EXISTS "TempManualPurchaseDocumentItemsCircular170";
	CREATE TEMPORARY TABLE "TempManualPurchaseDocumentItemsCircular170" AS
	SELECT
		tp."MapperId",
		tp."ManualSourceType",
		CASE WHEN tp."ItcClaimReturnPeriod" IS NULL THEN tp."Gstr2BReturnPeriod" ELSE NULL END AS "Gstr2BReturnPeriod",
		tp."ItcClaimReturnPeriod",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" = "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."IgstAmount" 
							ELSE pdi."IgstAmount" 
						END)
				 ELSE NULL 
			END) AS "CpIgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" = "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CgstAmount" 
							ELSE pdi."CgstAmount" 
						END)
				 ELSE NULL 
			END) AS "CpCgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" = "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."SgstAmount" 
							ELSE pdi."SgstAmount" 
						END)
				 ELSE NULL 
			END) AS "CpSgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" = "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CessAmount" 
							ELSE pdi."CessAmount" 
						END)
				 ELSE NULL 
			END) AS "CpCessAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" <> "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."IgstAmount" 
							ELSE pdi."IgstAmount" 
						END)
				 ELSE NULL 
			END) AS "PrevCpIgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" <> "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CgstAmount" 
							ELSE pdi."CgstAmount" 
						END)
				 ELSE NULL 
			END) AS "PrevCpCgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" <> "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."SgstAmount" 
							ELSE pdi."SgstAmount" 
						END)
				 ELSE NULL 
			END) AS "PrevCpSgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."Gstr2BReturnPeriod" <> "_ReturnPeriod"
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CessAmount" 
							ELSE pdi."CessAmount" 
						END)
				 ELSE NULL 
			END) AS "PrevCpCessAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."IgstAmount" 
							ELSE pdi."IgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "IgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CgstAmount" 
							ELSE pdi."CgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "CgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."SgstAmount" 
							ELSE pdi."SgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "SgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CessAmount" 
							ELSE pdi."CessAmount" 
						END) 
				 ELSE NULL 
			END) AS "CessAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN NULL 
				 ELSE (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcIgstAmount" 
							ELSE pdi."ItcIgstAmount" 
						END) 
			END) AS "ItcIgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN NULL 
				 ELSE (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcCgstAmount" 
							ELSE pdi."ItcCgstAmount" 
						END) 
			END) AS "ItcCgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN NULL 
				 ELSE (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcSgstAmount" 
							ELSE pdi."ItcSgstAmount" 
						END) 
			END) AS "ItcSgstAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND (pdi."ItcEligibility" IS NULL OR pdi."ItcEligibility" = "_ItcEligibilityNo") 
				 THEN NULL 
				 ELSE (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcCessAmount" 
							ELSE pdi."ItcCessAmount" 
						END) 
			END) AS "ItcCessAmount",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."IgstAmount" 
							ELSE pdi."IgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "IgstAmount_175",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CgstAmount" 
							ELSE pdi."CgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "CgstAmount_175",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."SgstAmount" 
							ELSE pdi."SgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "SgstAmount_175",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."CessAmount" 
							ELSE pdi."CessAmount" 
						END) 
				 ELSE NULL 
			END) AS "CessAmount_175",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcIgstAmount" 
							ELSE pdi."ItcIgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "ItcIgstAmount_38_42_43",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcCgstAmount" 
							ELSE pdi."ItcCgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "ItcCgstAmount_38_42_43",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcSgstAmount" 
							ELSE pdi."ItcSgstAmount" 
						END) 
				 ELSE NULL 
			END) AS "ItcSgstAmount_38_42_43",
		SUM(CASE WHEN tp."ManualSourceType" = "_SourceTypeTaxPayer" AND pdi."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") 
				 THEN (CASE WHEN tp."DocumentType" = "_DocumentTypeCRN" 
							THEN -pdi."ItcCessAmount" 
							ELSE pdi."ItcCessAmount" 
						END) 
				 ELSE NULL 
			END) AS "ItcCessAmount_38_42_43"
	FROM
		oregular."PurchaseDocumentItems" AS pdi
		INNER JOIN "TempPurchaseDocumentIds" tp ON tp."Id" = pdi."PurchaseDocumentId"
	WHERE 
		tp."ReconciliationSectionType" IN ("_ReconciliationSectionTypeMatched","_ReconciliationSectionTypeMatchedDueToTolerance","_ReconciliationSectionTypeMisMatched","_ReconciliationSectionTypeNearMatched")
		AND tp."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND tp."ReverseCharge" = "_BitTypeN"
		AND 
		(
			tp."ManualSourceType" = "_SourceTypeTaxPayer"
			OR
			(tp."ManualSourceType" = "_SourceTypeCounterPartyFiled" AND tp."ItcAvailability" ="_ItcAvailabilityTypeY")
		)
	GROUP BY 
		tp."MapperId",
		tp."ManualSourceType",		
		CASE WHEN tp."ItcClaimReturnPeriod" IS NULL THEN tp."Gstr2BReturnPeriod" ELSE NULL END,
		tp."ItcClaimReturnPeriod";

	/* Manual Purchase Documents Data*/
	DROP TABLE IF EXISTS "TempManualPurchaseDocumentsCircular170";
	CREATE TEMPORARY TABLE "TempManualPurchaseDocumentsCircular170" AS	
	SELECT DISTINCT
		tp."MapperId",
		tp."ManualSourceType",		
		tpdi."Gstr2BReturnPeriod",
		tpdi."ItcClaimReturnPeriod",
		(COALESCE(tpdi."CpIgstAmount",0) + COALESCE(tpdi."CpCgstAmount",0) + COALESCE(tpdi."CpSgstAmount",0) + COALESCE(tpdi."CpCessAmount",0)) AS "CpTotalTaxAmount",
		tpdi."CpIgstAmount",
		tpdi."CpCgstAmount",
		tpdi."CpSgstAmount",
		tpdi."CpCessAmount",
		(COALESCE(tpdi."PrevCpIgstAmount",0) + COALESCE(tpdi."PrevCpCgstAmount",0) + COALESCE(tpdi."PrevCpSgstAmount",0) + COALESCE(tpdi."PrevCpCessAmount",0)) AS "PrevCpTotalTaxAmount",
		tpdi."PrevCpIgstAmount",
		tpdi."PrevCpCgstAmount",
		tpdi."PrevCpSgstAmount",
		tpdi."PrevCpCessAmount",
		(COALESCE(tpdi."IgstAmount",0) + COALESCE(tpdi."CgstAmount",0) + COALESCE(tpdi."SgstAmount",0) + COALESCE(tpdi."CessAmount",0)) AS "TotalTaxAmount",
		tpdi."IgstAmount",
		tpdi."CgstAmount",
		tpdi."SgstAmount",
		tpdi."CessAmount",
		(COALESCE(tpdi."IgstAmount_175",0) + COALESCE(tpdi."CgstAmount_175",0) + COALESCE(tpdi."SgstAmount_175",0) + COALESCE(tpdi."CessAmount_175",0)) AS "TotalTaxAmount_175",
		tpdi."IgstAmount_175",
		tpdi."CgstAmount_175",
		tpdi."SgstAmount_175",
		tpdi."CessAmount_175",
		(COALESCE(tpdi."ItcIgstAmount",0) + COALESCE(tpdi."ItcCgstAmount",0) + COALESCE(tpdi."ItcSgstAmount",0) + COALESCE(tpdi."ItcCessAmount",0)) AS "TotalItcAmount",
		tpdi."ItcIgstAmount",
		tpdi."ItcCgstAmount",
		tpdi."ItcSgstAmount",
		tpdi."ItcCessAmount",
		(COALESCE(tpdi."ItcIgstAmount_38_42_43",0) + COALESCE(tpdi."ItcCgstAmount_38_42_43",0) + COALESCE(tpdi."ItcSgstAmount_38_42_43",0) + COALESCE(tpdi."ItcCessAmount_38_42_43",0)) AS "TotalItcAmount_38_42_43",
		tpdi."ItcIgstAmount_38_42_43",
		tpdi."ItcCgstAmount_38_42_43",
		tpdi."ItcSgstAmount_38_42_43",
		tpdi."ItcCessAmount_38_42_43"
	FROM 
		"TempPurchaseDocumentIds" tp
		INNER JOIN "TempManualPurchaseDocumentItemsCircular170" tpdi ON tpdi."MapperId" = tp."MapperId"	AND tp."ManualSourceType" = tpdi."ManualSourceType"
		LEFT JOIN oregular."PurchaseDocuments" AS pd ON pd."Id" = tp."DocumentId" AND tp."ManualSourceType" = "_SourceTypeCounterPartyFiled"
	WHERE
		tp."IsAmendment" = "_BitTypeN"
		AND tp."MapperId" IS NOT NULL
		AND (pd."TaxpayerType" IS NULL OR pd."TaxpayerType" <> "_TaxPayerTypeISD");

	CREATE INDEX "Idx_TempManualPurchaseDocumentsCircular170_Id" ON "TempManualPurchaseDocumentsCircular170" USING BTREE("MapperId");

	/* Original Pr Purchase Document Items */
	DROP TABLE IF EXISTS "TempOriginalPrPurchaseDocumentItemsCircular170";
	CREATE TEMPORARY TABLE "TempOriginalPrPurchaseDocumentItemsCircular170" AS
	SELECT 		
		tpd."Id",					
		pdpr."DocumentType",
		SUM(pdipr."TaxableValue") AS "TaxableValue",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN pdipr."IgstAmount" ELSE NULL END) AS "IgstAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN pdipr."CgstAmount" ELSE NULL END) AS "CgstAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN pdipr."SgstAmount" ELSE NULL END) AS "SgstAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN pdipr."CessAmount" ELSE NULL END) AS "CessAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdipr."ItcIgstAmount" END) AS "ItcIgstAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdipr."ItcCgstAmount" END) AS "ItcCgstAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdipr."ItcSgstAmount" END) AS "ItcSgstAmount",
		SUM(CASE WHEN pdipr."ItcEligibility" IS NULL OR pdipr."ItcEligibility" = "_ItcEligibilityNo" THEN NULL ELSE pdipr."ItcCessAmount" END) AS "ItcCessAmount",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdipr."IgstAmount" ELSE NULL END) AS "IgstAmount_175",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdipr."CgstAmount" ELSE NULL END) AS "CgstAmount_175",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdipr."SgstAmount" ELSE NULL END) AS "SgstAmount_175",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175" THEN pdipr."CessAmount" ELSE NULL END) AS "CessAmount_175",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdipr."ItcIgstAmount" ELSE NULL END) AS "ItcIgstAmount_38_42_43",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdipr."ItcCgstAmount" ELSE NULL END) AS "ItcCgstAmount_38_42_43",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdipr."ItcSgstAmount" ELSE NULL END) AS "ItcSgstAmount_38_42_43",
		SUM(CASE WHEN pdipr."GstActOrRuleSection" IN ("_GstActOrRuleSectionTypeGstAct38", "_GstActOrRuleSectionTypeGstAct42", "_GstActOrRuleSectionTypeGstAct43") THEN pdipr."ItcCessAmount" ELSE NULL END) AS "ItcCessAmount_38_42_43"
	FROM 				
		"TempPurchaseDocumentIds" tpd
		INNER JOIN oregular."PurchaseDocumentDW" pdo ON tpd."OriginalDocumentNumber" = pdo."DocumentNumber" AND tpd."OriginalDocumentDate" = pdo."DocumentDate" AND COALESCE(pdo."BillFromGstin",'') = COALESCE(tpd."BillFromGstin",'')
		INNER JOIN oregular."PurchaseDocumentStatus" pdso ON pdo."Id" = pdso."PurchaseDocumentId"
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = pdo."Id" OR gdrmcp."GstnId" = tpd."Id"
		INNER JOIN oregular."PurchaseDocumentDW" pdpr ON pdpr."Id" = gdrmcp."PrId"
		INNER JOIN oregular."PurchaseDocumentItems" pdipr ON pdpr."Id" = pdipr."PurchaseDocumentId"
	WHERE 
		pdo."SubscriberId" = "_SubscriberId"
		AND pdo."ParentEntityId" = tpd."EntityId"
		AND pdo."SourceType" = tpd."SourceType"									
		AND pdo."CombineDocumentType" = tpd."CombineDocumentType"
		AND pdo."IsAmendment" = "_BitTypeN"			
		AND pdo."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeB2B","_TransactionTypeIMPS","_TransactionTypeCBW","_TransactionTypeSEZWP","_TransactionTypeSEZWOP","_TransactionTypeDE","_TransactionTypeIMPG")
		AND pdso."Status" = "_DocumentStatusActive"
		AND tpd."IsAmendment" = "_BitTypeY"	
	GROUP BY 
		tpd."Id",					
		pdpr."DocumentType";
	
	/* Purchase Documents Amendment Data */
	DROP TABLE IF EXISTS "TempPurchaseDocumentsAmendmentCircular170";
	CREATE TEMPORARY TABLE "TempPurchaseDocumentsAmendmentCircular170" AS
	SELECT
		pd."Id",
		pd."DocumentNumber",
		pd."DocumentDate",
		pd."DocumentType" AS "DocumentType_A", -- Amendment DocumentType
		topdi."DocumentType", -- Original DocumentType
		pd."DocumentValue",
		pd."TaxpayerType",
		pd."TransactionType",
		pd."SourceType",
		pd."ReverseCharge",
		pd."Pos",
		pd."PortCode",
		pd."ReturnPeriod",
		pd."IsAmendment",
		pd."OriginalDocumentNumber",
		pd."OriginalDocumentDate",
		pd."OriginalPortCode",
		tpd."BillFromGstin",
		tpd."ReconciliationSectionType",
		tpd."ItcAvailability" As "ItcAvailability_A",		
		topdi."ItcAvailability",
		tpd."Gstr2BReturnPeriod",
		tpd."IsAvailableInGstr2B",
		tpd."ItcClaimReturnPeriod" AS "ItcClaimReturnPeriod_A",
		topdi."ItcClaimReturnPeriod",
		tpd."LiabilityDischargeReturnPeriod",
		CASE WHEN length(tpd."BillFromGstin") = 10 THEN "_BitTypeY" ELSE "_BitTypeN" END "IsBillFromPAN",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(tpdi."IgstAmount",0) + COALESCE(tpdi."CgstAmount",0) + COALESCE(tpdi."SgstAmount",0) + COALESCE(tpdi."CessAmount",0)) 
			 ELSE (COALESCE(tpdi."IgstAmount",0) + COALESCE(tpdi."CgstAmount",0) + COALESCE(tpdi."SgstAmount",0) + COALESCE(tpdi."CessAmount",0)) END  AS "TotalTaxAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."TaxableValue" ELSE tpdi."TaxableValue" END AS "TaxableValue_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."IgstAmount" ELSE tpdi."IgstAmount" END AS "IgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CgstAmount" ELSE tpdi."CgstAmount" END AS "CgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."SgstAmount" ELSE tpdi."SgstAmount" END AS "SgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CessAmount" ELSE tpdi."CessAmount" END AS "CessAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(tpdi."IgstAmount_175",0) + COALESCE(tpdi."CgstAmount_175",0) + COALESCE(tpdi."SgstAmount_175",0) + COALESCE(tpdi."CessAmount_175",0)) 
			 ELSE (COALESCE(tpdi."IgstAmount_175",0) + COALESCE(tpdi."CgstAmount_175",0) + COALESCE(tpdi."SgstAmount_175",0) + COALESCE(tpdi."CessAmount_175",0)) END  AS "TotalTaxAmount_175_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."IgstAmount_175" ELSE tpdi."IgstAmount_175" END AS "IgstAmount_175_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CgstAmount_175" ELSE tpdi."CgstAmount_175" END AS "CgstAmount_175_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."SgstAmount_175" ELSE tpdi."SgstAmount_175" END AS "SgstAmount_175_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."CessAmount_175" ELSE tpdi."CessAmount_175" END AS "CessAmount_175_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcIgstAmount" ELSE tpdi."ItcIgstAmount" END AS "ItcIgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCgstAmount" ELSE tpdi."ItcCgstAmount" END AS "ItcCgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcSgstAmount" ELSE tpdi."ItcSgstAmount" END AS "ItcSgstAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCessAmount" ELSE tpdi."ItcCessAmount" END AS "ItcCessAmount_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcIgstAmount_38_42_43" ELSE tpdi."ItcIgstAmount_38_42_43" END AS "ItcIgstAmount_38_42_43_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCgstAmount_38_42_43" ELSE tpdi."ItcCgstAmount_38_42_43" END AS "ItcCgstAmount_38_42_43_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcSgstAmount_38_42_43" ELSE tpdi."ItcSgstAmount_38_42_43" END AS "ItcSgstAmount_38_42_43_A",
		CASE WHEN pd."DocumentType" = "_DocumentTypeCRN" THEN -tpdi."ItcCessAmount_38_42_43" ELSE tpdi."ItcCessAmount_38_42_43" END AS "ItcCessAmount_38_42_43_A",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(topdi."IgstAmount",0) + COALESCE(topdi."CgstAmount",0) + COALESCE(topdi."SgstAmount",0) + COALESCE(topdi."CessAmount",0)) 
			 ELSE (COALESCE(topdi."IgstAmount",0) + COALESCE(topdi."CgstAmount",0) + COALESCE(topdi."SgstAmount",0) + COALESCE(topdi."CessAmount",0)) END  AS "TotalTaxAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."TaxableValue" ELSE topdi."TaxableValue" END AS "TaxableValue",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."IgstAmount" ELSE topdi."IgstAmount" END AS "IgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."CgstAmount" ELSE topdi."CgstAmount" END AS "CgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."SgstAmount" ELSE topdi."SgstAmount" END AS "SgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."CessAmount" ELSE topdi."CessAmount" END AS "CessAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(topdi."IgstAmount_175",0) + COALESCE(topdi."CgstAmount_175",0) + COALESCE(topdi."SgstAmount_175",0) + COALESCE(topdi."CessAmount_175",0)) 
			 ELSE (COALESCE(topdi."IgstAmount_175",0) + COALESCE(topdi."CgstAmount_175",0) + COALESCE(topdi."SgstAmount_175",0) + COALESCE(topdi."CessAmount_175",0)) END  AS "TotalTaxAmount_175",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."IgstAmount_175" ELSE topdi."IgstAmount_175" END AS "IgstAmount_175",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."CgstAmount_175" ELSE topdi."CgstAmount_175" END AS "CgstAmount_175",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."SgstAmount_175" ELSE topdi."SgstAmount_175" END AS "SgstAmount_175",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."CessAmount_175" ELSE topdi."CessAmount_175" END AS "CessAmount_175",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcIgstAmount" ELSE topdi."ItcIgstAmount" END AS "ItcIgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcCgstAmount" ELSE topdi."ItcCgstAmount" END AS "ItcCgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcSgstAmount" ELSE topdi."ItcSgstAmount" END AS "ItcSgstAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcCessAmount" ELSE topdi."ItcCessAmount" END AS "ItcCessAmount",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcIgstAmount_38_42_43" ELSE topdi."ItcIgstAmount_38_42_43" END AS "ItcIgstAmount_38_42_43",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcCgstAmount_38_42_43" ELSE topdi."ItcCgstAmount_38_42_43" END AS "ItcCgstAmount_38_42_43",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcSgstAmount_38_42_43" ELSE topdi."ItcSgstAmount_38_42_43" END AS "ItcSgstAmount_38_42_43",
		CASE WHEN topdi."DocumentType" = "_DocumentTypeCRN" THEN -topdi."ItcCessAmount_38_42_43" ELSE topdi."ItcCessAmount_38_42_43" END AS "ItcCessAmount_38_42_43",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(toppdi."IgstAmount",0) + COALESCE(toppdi."CgstAmount",0) + COALESCE(toppdi."SgstAmount",0) + COALESCE(toppdi."CessAmount",0)) 
			 ELSE (COALESCE(toppdi."IgstAmount",0) + COALESCE(toppdi."CgstAmount",0) + COALESCE(toppdi."SgstAmount",0) + COALESCE(toppdi."CessAmount",0)) END AS "PrTotalTaxAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."TaxableValue" ELSE toppdi."TaxableValue" END AS "PrTaxableValue",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."IgstAmount" ELSE toppdi."IgstAmount" END AS "PrIgstAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."CgstAmount" ELSE toppdi."CgstAmount" END AS "PrCgstAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."SgstAmount" ELSE toppdi."SgstAmount" END AS "PrSgstAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."CessAmount" ELSE toppdi."CessAmount" END AS "PrCessAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(toppdi."IgstAmount_175",0) + COALESCE(toppdi."CgstAmount_175",0) + COALESCE(toppdi."SgstAmount_175",0) + COALESCE(toppdi."CessAmount_175",0)) 
			 ELSE (COALESCE(toppdi."IgstAmount_175",0) + COALESCE(toppdi."CgstAmount_175",0) + COALESCE(toppdi."SgstAmount_175",0) + COALESCE(toppdi."CessAmount_175",0)) END AS "PrTotalTaxAmount_175",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."IgstAmount_175" ELSE toppdi."IgstAmount_175" END AS "PrIgstAmount_175",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."CgstAmount_175" ELSE toppdi."CgstAmount_175" END AS "PrCgstAmount_175",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."SgstAmount_175" ELSE toppdi."SgstAmount_175" END AS "PrSgstAmount_175",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."CessAmount_175" ELSE toppdi."CessAmount_175" END AS "PrCessAmount_175",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(toppdi."ItcIgstAmount",0) + COALESCE(toppdi."ItcCgstAmount",0) + COALESCE(toppdi."ItcSgstAmount",0) + COALESCE(toppdi."ItcCessAmount",0)) 
			 ELSE (COALESCE(toppdi."ItcIgstAmount",0) + COALESCE(toppdi."ItcCgstAmount",0) + COALESCE(toppdi."ItcSgstAmount",0) + COALESCE(toppdi."ItcCessAmount",0)) END AS "PrTotalItcAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcIgstAmount" ELSE toppdi."ItcIgstAmount" END AS "PrItcIgstAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcCgstAmount" ELSE toppdi."ItcCgstAmount" END AS "PrItcCgstAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcSgstAmount" ELSE toppdi."ItcSgstAmount" END AS "PrItcSgstAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcCessAmount" ELSE toppdi."ItcCessAmount" END AS "PrItcCessAmount",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -(COALESCE(toppdi."ItcIgstAmount_38_42_43",0) + COALESCE(toppdi."ItcCgstAmount_38_42_43",0) + COALESCE(toppdi."ItcSgstAmount_38_42_43",0) + COALESCE(toppdi."ItcCessAmount_38_42_43",0)) 
			 ELSE (COALESCE(toppdi."ItcIgstAmount_38_42_43",0) + COALESCE(toppdi."ItcCgstAmount_38_42_43",0) + COALESCE(toppdi."ItcSgstAmount_38_42_43",0) + COALESCE(toppdi."ItcCessAmount",0)) END AS "PrTotalItcAmount_38_42_43",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcIgstAmount_38_42_43" ELSE toppdi."ItcIgstAmount_38_42_43" END AS "PrItcIgstAmount_38_42_43",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcCgstAmount_38_42_43" ELSE toppdi."ItcCgstAmount_38_42_43" END AS "PrItcCgstAmount_38_42_43",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcSgstAmount_38_42_43" ELSE toppdi."ItcSgstAmount_38_42_43" END AS "PrItcSgstAmount_38_42_43",
		CASE WHEN toppdi."DocumentType" = "_DocumentTypeCRN" THEN -toppdi."ItcCessAmount_38_42_43" ELSE toppdi."ItcCessAmount_38_42_43" END AS "PrItcCessAmount_38_42_43",
		COALESCE(pd."ModifiedStamp",pd."Stamp") AS "Stamp"
	FROM 
		"TempPurchaseDocumentIds" tpd
		INNER JOIN "TempPurchaseDocumentItemsCircular170" tpdi ON tpdi."PurchaseDocumentId" = tpd."Id"	
		INNER JOIN "TempOriginalPurchaseDocumentItemsCircular170" topdi ON tpdi."PurchaseDocumentId" = topdi."Id"
		LEFT JOIN "TempOriginalPrPurchaseDocumentItemsCircular170" toppdi ON toppdi."Id" = tpd."Id"
		INNER JOIN oregular."PurchaseDocuments" pd ON pd."Id" = tpdi."PurchaseDocumentId"
	WHERE
		tpd."MapperId" IS NULL;

	/*Purchase Summary Data*/
	DROP TABLE IF EXISTS "TempPurchaseSummary";
	CREATE TEMPORARY TABLE "TempPurchaseSummary"
	(
		"Id" BIGINT,
		"SummaryType" SMALLINT,
		"IsAmendment" BOOLEAN,
		"NilAmount" DECIMAL(18,2),
		"ExemptAmount" DECIMAL(18,2),
		"NonGstAmount" DECIMAL(18,2),
		"CompositionAmount" DECIMAL(18,2),
		"Rate" DECIMAL(18,2),
		"Pos" SMALLINT,
		"ItcReversalOrReclaimType" SMALLINT,
		"CompositionExemptNilNonGstType" SMALLINT,
		"OriginalReturnPeriod" INT,
		"TaxableValue" DECIMAL(18,2),
		"IgstAmount" DECIMAL(18,2),
		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2),
		"ItcIgstAmount" DECIMAL(18,2),
		"ItcCgstAmount" DECIMAL(18,2),
		"ItcSgstAmount" DECIMAL(18,2),
		"ItcCessAmount" DECIMAL(18,2)
	);

	INSERT INTO "TempPurchaseSummary"
	(
		"Id",
		"SummaryType",
		"IsAmendment",
		"NilAmount",
		"ExemptAmount",
		"NonGstAmount",
		"CompositionAmount",
		"Rate",
		"Pos",
		"ItcReversalOrReclaimType",
		"CompositionExemptNilNonGstType",
		"OriginalReturnPeriod",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount",
		"ItcIgstAmount",
		"ItcCgstAmount",
		"ItcSgstAmount",
		"ItcCessAmount"
	)
	SELECT
		ps."Id",
		ps."SummaryType",
		ps."IsAmendment",
		ps."NilAmount",
		ps."ExemptAmount",
		ps."NonGstAmount",
		ps."CompositionAmount",
		ps."Rate",
		ps."Pos",	
		ps."ItcReversalOrReclaimType",
		ps."CompositionExemptNilNonGstType",
		ps."OriginalReturnPeriod",
		ps."TaxableValue",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY" THEN ps."IgstAmountForFirstMonthOfQtr"
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY" THEN ps."IgstAmountForSecondMonthOfQtr"
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY" THEN COALESCE(ps."IgstAmount",0) - (COALESCE(ps."IgstAmountForFirstMonthOfQtr",0) + COALESCE(ps."IgstAmountForSecondMonthOfQtr",0))
			 ELSE ps."IgstAmount" 
		END AS "IgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY" THEN ps."CgstAmountForFirstMonthOfQtr"
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY" THEN ps."CgstAmountForSecondMonthOfQtr"
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY" THEN COALESCE(ps."CgstAmount",0) - (COALESCE(ps."CgstAmountForFirstMonthOfQtr",0) + COALESCE(ps."CgstAmountForSecondMonthOfQtr",0))
			 ELSE ps."CgstAmount" 
		END AS "CgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY" THEN ps."SgstAmountForFirstMonthOfQtr"
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY" THEN ps."SgstAmountForSecondMonthOfQtr"
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY" THEN COALESCE(ps."SgstAmount",0) - (COALESCE(ps."SgstAmountForFirstMonthOfQtr",0) + COALESCE(ps."SgstAmountForSecondMonthOfQtr",0))
			 ELSE ps."SgstAmount" 
		END AS "SgstAmount",
		CASE WHEN "_IsFirstMonthOfQuarter" = "_BitTypeY" THEN ps."CessAmountForFirstMonthOfQtr"
			 WHEN "_IsSecondMonthOfQuarter" = "_BitTypeY" THEN ps."CessAmountForSecondMonthOfQtr"
			 WHEN "_IsThirdMonthOfQurater" = "_BitTypeY" THEN COALESCE(ps."CessAmount",0) - (COALESCE(ps."CessAmountForFirstMonthOfQtr",0) + COALESCE(ps."CessAmountForSecondMonthOfQtr",0))
			 ELSE ps."CessAmount" 
		END AS "CessAmount",
		CASE WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN COALESCE(ps."ItcIgstAmount",0) - (COALESCE(ps."IgstAmountForFirstMonthOfQtr",0) + COALESCE(ps."IgstAmountForSecondMonthOfQtr",0)) 
			 ELSE ps."ItcIgstAmount" 
		END AS "ItcIgstAmount",
		CASE WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN COALESCE(ps."ItcCgstAmount",0) - (COALESCE(ps."CgstAmountForFirstMonthOfQtr",0) + COALESCE(ps."CgstAmountForSecondMonthOfQtr",0)) 
			 ELSE ps."ItcCgstAmount" 
		END AS "ItcCgstAmount",
		CASE WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN COALESCE(ps."ItcSgstAmount",0) - (COALESCE(ps."SgstAmountForFirstMonthOfQtr",0) + COALESCE(ps."SgstAmountForSecondMonthOfQtr",0)) 
			 ELSE ps."ItcSgstAmount" 
		END AS "ItcSgstAmount",
		CASE WHEN "_IsThirdMonthOfQurater" = "_BitTypeY"
			 THEN COALESCE(ps."ItcCessAmount",0) - (COALESCE(ps."CessAmountForFirstMonthOfQtr",0) + COALESCE(ps."CessAmountForSecondMonthOfQtr",0)) 
			 ELSE ps."ItcCessAmount" 
		END AS "ItcCessAmount"
	FROM
		oregular."PurchaseSummaries" AS ps
		INNER JOIN oregular."PurchaseSummaryStatus" AS pss ON ps."Id" = pss."PurchaseSummaryId"
	WHERE
		ps."SubscriberId" = "_SubscriberId"
		AND ps."EntityId" = "_EntityId"
		AND ps."ReturnPeriod" = "_ReturnPeriod"
		AND ps."IsAmendment" = "_BitTypeN"
		AND pss."Status" = "_DocumentStatusActive";

	/*3.1(A) Details of supplies notified under section 9(5) of the Act, 2017 and corresponding provisions in IGST/UTGST/SGST Acts*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection31A"
	(
		"_Gstr3bSectionEcoSupplies" := "_Gstr3bSectionEcoSupplies",
		"_Gstr3bSectionEcoRegSupplies" := "_Gstr3bSectionEcoRegSupplies",
		"_LocationPos" := "_LocationPos",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TransactionTypeB2C" := "_TransactionTypeB2C",
		"_TransactionTypeB2B" := "_TransactionTypeB2B",
		"_TransactionTypeCBW" := "_TransactionTypeCBW",
		"_TransactionTypeDE" := "_TransactionTypeDE",
		"_TransactionTypeSEZWP" := "_TransactionTypeSEZWP",
		"_TransactionTypeSEZWOP" := "_TransactionTypeSEZWOP",
		"_DocumentSummaryTypeGSTR1ECOM" := "_DocumentSummaryTypeGSTR1ECOM",
		"_DocumentSummaryTypeGSTR1SUPECO" := "_DocumentSummaryTypeGSTR1SUPECO",
		"_GstActOrRuleSectionTypeGstAct95" := "_GstActOrRuleSectionTypeGstAct95",	
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*3.1.1 Outward taxable supplies (other than zero rated", nil rated and exempted) Documents*/		
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection3A1"
	(
		"_Gstr3bSectionOutwardTaxSupply" := "_Gstr3bSectionOutwardTaxSupply",
		"_LocationPos" := "_LocationPos",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TransactionTypeB2C" := "_TransactionTypeB2C",
		"_TransactionTypeB2B" := "_TransactionTypeB2B",
		"_TransactionTypeCBW" := "_TransactionTypeCBW",
		"_TransactionTypeDE" := "_TransactionTypeDE",
		"_DocumentSummaryTypeGstr1B2CS" := "_DocumentSummaryTypeGstr1B2CS",
		"_DocumentSummaryTypeGstr1ADV" := "_DocumentSummaryTypeGstr1ADV",
		"_DocumentSummaryTypeGstr1ADVAJ" := "_DocumentSummaryTypeGstr1ADVAJ",
		"_GstActOrRuleSectionTypeGstAct95" := "_GstActOrRuleSectionTypeGstAct95",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*3.1.2 Outward taxable supplies (zero rated)*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection3A2"
	(
		"_Gstr3bSectionOutwardZeroRated" := "_Gstr3bSectionOutwardZeroRated",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TransactionTypeEXPWP" := "_TransactionTypeEXPWP",
		"_TransactionTypeEXPWOP" := "_TransactionTypeEXPWOP",
		"_TransactionTypeSEZWP" := "_TransactionTypeSEZWP",
		"_TransactionTypeSEZWOP" := "_TransactionTypeSEZWOP",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*3.1.3 Other outward supplies (Nil rated, exempted)*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue"
	)
	SELECT * FROM gst."GenerateGstr3bSection3A3"
	(
		"_Gstr3bSectionOutwardNilRated" := "_Gstr3bSectionOutwardNilRated",
		"_DocumentSummaryTypeGstr1NIL" := "_DocumentSummaryTypeGstr1NIL"
	);

	/*3.1.4 Inward supplies (liable to reverse charge)*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection3A4"
	(
		"_Gstr3bSectionInwardReverseCharge" := "_Gstr3bSectionInwardReverseCharge",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TransactionTypeB2C" := "_TransactionTypeB2C",
		"_TransactionTypeB2B" := "_TransactionTypeB2B",
		"_TransactionTypeCBW" := "_TransactionTypeCBW",
		"_TransactionTypeDE" := "_TransactionTypeDE",
		"_TransactionTypeSEZWP" := "_TransactionTypeSEZWP",
		"_TransactionTypeSEZWOP" := "_TransactionTypeSEZWOP",
		"_TransactionTypeIMPS" := "_TransactionTypeIMPS",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*3.1.5 Non-GST outward supplies*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue"
	)
	SELECT * FROM gst."GenerateGstr3bSection3A5"
	(
		"_Gstr3bSectionOutwardNonGst" := "_Gstr3bSectionOutwardNonGst",
		"_DocumentSummaryTypeGstr1NIL" := "_DocumentSummaryTypeGstr1NIL"
	);

	/*3.2 B2C,Composition And Uin Documents*/
	INSERT INTO "TempGstr3bInterState_Original"
	(
		"Section",
		"Pos",
		"TaxableValue",
		"IgstAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection3B"
	(
		"_Gstr3bSectionInterStateB2c" := "_Gstr3bSectionInterStateB2c", 
		"_Gstr3bSectionInterStateComp" := "_Gstr3bSectionInterStateComp",
		"_Gstr3bSectionInterStateUin" := "_Gstr3bSectionInterStateUin", 
		"_SubscriberId" := "_SubscriberId",
		"_LocationPos" := "_LocationPos",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_DocumentSummaryTypeGstr1B2CS" := "_DocumentSummaryTypeGstr1B2CS",
		"_DocumentSummaryTypeGstr1ADV" := "_DocumentSummaryTypeGstr1ADV",
		"_DocumentSummaryTypeGstr1ADVAJ" := "_DocumentSummaryTypeGstr1ADVAJ",
		"_TransactionTypeB2C" := "_TransactionTypeB2C", 
		"_TransactionTypeCBW" := "_TransactionTypeCBW", 
		"_TaxPayerTypeUNB" := "_TaxPayerTypeUNB",
		"_TaxPayerTypeEMB" := "_TaxPayerTypeEMB",
		"_TaxPayerTypeONP" := "_TaxPayerTypeONP",
		"_TaxPayerTypeCOM" := "_TaxPayerTypeCOM",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*4.1.1 Import of Goods Documents*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IsGstr2bData",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4A1"
	(
		"_Gstr3bSectionImportOfGoods":= "_Gstr3bSectionImportOfGoods",
		"_ReturnPeriod":= "_ReturnPeriod",
		"_SourceTypeTaxPayer":= "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled":= "_SourceTypeCounterPartyFiled",
		"_DocumentTypeBOE":= "_DocumentTypeBOE",				
		"_TransactionTypeIMPG":= "_TransactionTypeIMPG",
		"_ItcAvailabilityTypeY":= "_ItcAvailabilityTypeY",
		"_ItcAvailabilityTypeT":= "_ItcAvailabilityTypeT",
		"_BitTypeN":= "_BitTypeN",
		"_BitTypeY":= "_BitTypeY"
	);

	/*4.1.2 Import of Services Documents*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4A2"
	(
		"_Gstr3bSectionImportOfServices" := "_Gstr3bSectionImportOfServices",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TransactionTypeB2B" := "_TransactionTypeB2B",
		"_TransactionTypeCBW" := "_TransactionTypeCBW",
		"_TransactionTypeDE" := "_TransactionTypeDE",
		"_TransactionTypeSEZWP" := "_TransactionTypeSEZWP",
		"_TransactionTypeSEZWOP" := "_TransactionTypeSEZWOP",
		"_TransactionTypeIMPS" := "_TransactionTypeIMPS",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*4.1.3 Inward supplies liable to reverse charge (other than 1 & 2 above)*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IsGstr2bData",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4A3"
	(
		"_Gstr3bSectionInwardReverseChargeOther" := "_Gstr3bSectionInwardReverseChargeOther",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TransactionTypeB2C" := "_TransactionTypeB2C",
		"_TransactionTypeB2B" := "_TransactionTypeB2B",
		"_TransactionTypeCBW" := "_TransactionTypeCBW",
		"_TransactionTypeDE" := "_TransactionTypeDE",
		"_TransactionTypeSEZWP" := "_TransactionTypeSEZWP",
		"_TransactionTypeSEZWOP" := "_TransactionTypeSEZWOP",
		"_TransactionTypeIMPS" := "_TransactionTypeIMPS",
		"_TransactionTypeIMPG" := "_TransactionTypeIMPG",
		"_ItcAvailabilityTypeY" := "_ItcAvailabilityTypeY",
		"_ItcAvailabilityTypeT" := "_ItcAvailabilityTypeT",
		"_ItcEligibilityNo" := "_ItcEligibilityNo",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*4.1.4 Inward supplies from ISD*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IsGstr2bData",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4A4"
	(
		"_Gstr3bSectionInwardSuppliesFromIsd" := "_Gstr3bSectionInwardSuppliesFromIsd",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TaxPayerTypeISD" := "_TaxPayerTypeISD",
		"_TransactionTypeIMPG" := "_TransactionTypeIMPG",
		"_ItcAvailabilityTypeY" := "_ItcAvailabilityTypeY",
		"_ItcAvailabilityTypeT" := "_ItcAvailabilityTypeT",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);

	/*4.1.5 All Other ITC*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IsGstr2bData",
		"TaxableValue",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4A5"
	(
		"_Gstr3bSectionOtherItc" := "_Gstr3bSectionOtherItc",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_ItcAvailabilityTypeY" := "_ItcAvailabilityTypeY",
		"_ItcAvailabilityTypeN" := "_ItcAvailabilityTypeN",
		"_TaxPayerTypeISD" := "_TaxPayerTypeISD",
		"_BitTypeN" := "_BitTypeN"
	);

	/*4.2 ITC Reversed As per rules 42 & 43 of CGST Rules And Itc Others*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4B"
	(
		"_Gstr3bSectionItcReversedAsPerRule" := "_Gstr3bSectionItcReversedAsPerRule",
		"_Gstr3bSectionItcReversedOthers" := "_Gstr3bSectionItcReversedOthers",
		"_Gstr3bSectionImportOfGoods" := "_Gstr3bSectionImportOfGoods",
		"_Gstr3bSectionImportOfServices" := "_Gstr3bSectionImportOfServices",
		"_Gstr3bSectionInwardReverseChargeOther" := "_Gstr3bSectionInwardReverseChargeOther",
		"_Gstr3bSectionInwardSuppliesFromIsd" := "_Gstr3bSectionInwardSuppliesFromIsd",
		"_Gstr3bSectionOtherItc" := "_Gstr3bSectionOtherItc",
		"_EntityId" := "_EntityId",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_PreviousReturnPeriods" := "_PreviousReturnPeriods",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",			
		"_Gstr3bAutoPopulateType" := "_Gstr3bAutoPopulateType",			
		"_Gstr3bAutoPopulateTypeGstActRuleSection" := "_Gstr3bAutoPopulateTypeGstActRuleSection",			
		"_Gstr3bAutoPopulateTypeExemptedTurnoverRatio" := "_Gstr3bAutoPopulateTypeExemptedTurnoverRatio",
		"_ReturnTypeGSTR3B" := "_ReturnTypeGSTR3B",
		"_ReturnActionSystemGenerated" := "_ReturnActionSystemGenerated",
		"_TransactionTypeB2C" := "_TransactionTypeB2C",
		"_TransactionTypeIMPS" := "_TransactionTypeIMPS",
		"_SectTypeAll" := "_SectTypeAll",
		"_DocumentSummaryTypeGstr1B2CS" := "_DocumentSummaryTypeGstr1B2CS",
		"_DocumentSummaryTypeGSTR1ECOM" := "_DocumentSummaryTypeGSTR1ECOM",
		"_DocumentSummaryTypeGSTR1SUPECO" := "_DocumentSummaryTypeGSTR1SUPECO",
		"_DocumentSummaryTypeGstr1ADV" := "_DocumentSummaryTypeGstr1ADV",
		"_DocumentSummaryTypeGstr1ADVAJ" := "_DocumentSummaryTypeGstr1ADVAJ",
		"_DocumentSummaryTypeGstr1NIL" := "_DocumentSummaryTypeGstr1NIL",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TaxPayerTypeISD" := "_TaxPayerTypeISD",
		"_GstActOrRuleSectionTypeGstActItc175" := "_GstActOrRuleSectionTypeGstActItc175", 
		"_ItcAvailabilityTypeY":= "_ItcAvailabilityTypeY",
		"_ItcAvailabilityTypeN":= "_ItcAvailabilityTypeN",
		"_BitTypeN" := "_BitTypeN",
		"_BitTypeY" := "_BitTypeY"
	);				
				
	/*4.4 Ineligible Itc*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection4D"
	(
		"_Gstr3bSectionIneligibleItcAsPerRule" := "_Gstr3bSectionIneligibleItcAsPerRule",
		"_Gstr3bSectionIneligibleItcOthers" := "_Gstr3bSectionIneligibleItcOthers",
		"_ReturnPeriod" := "_ReturnPeriod",
		"_SourceTypeTaxPayer" := "_SourceTypeTaxPayer",
		"_SourceTypeCounterPartyFiled" := "_SourceTypeCounterPartyFiled",
		"_DocumentTypeINV" := "_DocumentTypeINV",
		"_DocumentTypeCRN" := "_DocumentTypeCRN",
		"_DocumentTypeDBN" := "_DocumentTypeDBN",
		"_TaxPayerTypeISD" := "_TaxPayerTypeISD",
		"_ItcAvailabilityTypeY" := "_ItcAvailabilityTypeY",
		"_ItcAvailabilityTypeN" := "_ItcAvailabilityTypeN",
		"_BitTypeN" := "_BitTypeN"
	);	
		
	--/*5.1 From a supplier under composition scheme", Exempt and Nil rated And NonGst*/
	INSERT INTO "TempGstr3bSection_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount"
	)
	SELECT * FROM gst."GenerateGstr3bSection5A"
	(
		"_Gstr3bSectionNilExempt" := "_Gstr3bSectionNilExempt",
		"_Gstr3bSectionNonGst" := "_Gstr3bSectionNonGst",
		"_DocumentSummaryTypeGstr2NIL" := "_DocumentSummaryTypeGstr2NIL",
		"_NilExemptNonGstTypeINTRA" := "_NilExemptNonGstTypeINTRA", 
		"_NilExemptNonGstTypeINTER" := "_NilExemptNonGstTypeINTER"
	);
	
	/*Getting Sections Data*/
	OPEN "_Gstr3bData" FOR	
	SELECT
		tp."Section",
		SUM(tp."TaxableValue") AS "TaxableValue",
		SUM(tp."IgstAmount") AS "IgstAmount",
		SUM(tp."CgstAmount") AS "CgstAmount",
		SUM(tp."SgstAmount") AS "SgstAmount",
		SUM(tp."CessAmount") AS "CessAmount"
	FROM
	(
		SELECT
			tod."Section" AS "Section",
			SUM(tod."TaxableValue") AS "TaxableValue",
			SUM(tod."IgstAmount") AS "IgstAmount",
			SUM(tod."CgstAmount") AS "CgstAmount",
			SUM(tod."SgstAmount") AS "SgstAmount",
			SUM(tod."CessAmount") AS "CessAmount"
		FROM
			"TempGstr3bSection_Original" AS tod
		WHERE
			tod."IsGstr2bData" = 0 :: BOOLEAN
		GROUP BY
			tod."Section"
		UNION ALL
		SELECT
			ts."Sections" AS "Section",
			0 AS "TaxableValue",
			0 AS "IgstAmount",
			0 AS "CgstAmount",
			0 AS "SgstAmount",
			0 AS "CessAmount"
		FROM
			"TempGstr3bSection_Original" AS tpo
			RIGHT JOIN "TempSections" AS ts ON tpo."Section" = ts."Sections"
	) AS tp
	GROUP BY
		tp."Section";
	RETURN NEXT "_Gstr3bData"; 	

	OPEN "_InterStateData" FOR 
	
	/*Getting InterState Supplies Data*/
	SELECT
		tid."Section",
		tid."Pos",
		SUM(tid."TaxableValue") AS "TaxableValue",
		SUM(tid."IgstAmount") AS "IgstAmount"
	FROM
		"TempGstr3bInterState_Original" AS tid
	GROUP BY
		tid."Section",
		tid."Pos";
	RETURN NEXT "_InterStateData";
	
	/*Getting Gstr2b Exclude Itc Data*/
	OPEN "_Gstr2bExcludeItcData" FOR 
	SELECT
		tp."Section",
		SUM(tp."TaxableValue") AS "TaxableValue",
		SUM(tp."IgstAmount") AS "IgstAmount",
		SUM(tp."CgstAmount") AS "CgstAmount",
		SUM(tp."SgstAmount") AS "SgstAmount",
		SUM(tp."CessAmount") AS "CessAmount"
	FROM
	(
		SELECT
			tod."Section" AS "Section",
			SUM(tod."TaxableValue") AS "TaxableValue",
			SUM(tod."IgstAmount") AS "IgstAmount",
			SUM(tod."CgstAmount") AS "CgstAmount",
			SUM(tod."SgstAmount") AS "SgstAmount",
			SUM(tod."CessAmount") AS "CessAmount"
		FROM
			"TempGstr3bSection_Original" AS tod
		WHERE
			tod."IsGstr2bData" = 1 :: BOOLEAN
		GROUP BY
			tod."Section"
		UNION ALL
		SELECT
			ts."Sections" AS "Section",
			0 AS "TaxableValue",
			0 AS "IgstAmount",
			0 AS "CgstAmount",
			0 AS "SgstAmount",
			0 AS "CessAmount"
		FROM
			"TempGstr3bSection_Original" AS tpo
			RIGHT JOIN "TempSections" AS ts ON tpo."Section" = ts."Sections"
		WHERE
			tpo."IsGstr2bData" = 1 :: BOOLEAN
	) AS tp
	GROUP BY
		tp."Section";
	RETURN NEXT "_Gstr2bExcludeItcData"; 

	END;
$function$
;
DROP FUNCTION IF EXISTS gst."GenerateGstr3bSection4B";

CREATE OR REPLACE FUNCTION gst."GenerateGstr3bSection4B"("_Gstr3bSectionItcReversedAsPerRule" integer, "_Gstr3bSectionItcReversedOthers" integer, "_Gstr3bSectionImportOfGoods" integer, "_Gstr3bSectionImportOfServices" integer, "_Gstr3bSectionInwardReverseChargeOther" integer, "_Gstr3bSectionInwardSuppliesFromIsd" integer, "_Gstr3bSectionOtherItc" integer, "_EntityId" integer, "_ReturnPeriod" integer, "_PreviousReturnPeriods" integer[], "_SourceTypeTaxPayer" smallint, "_SourceTypeCounterPartyFiled" smallint, "_Gstr3bAutoPopulateType" smallint, "_Gstr3bAutoPopulateTypeGstActRuleSection" smallint, "_Gstr3bAutoPopulateTypeExemptedTurnoverRatio" smallint, "_ReturnTypeGSTR3B" smallint, "_ReturnActionSystemGenerated" smallint, "_TransactionTypeB2C" smallint, "_TransactionTypeIMPS" smallint, "_SectTypeAll" integer, "_DocumentSummaryTypeGstr1B2CS" smallint, "_DocumentSummaryTypeGSTR1ECOM" smallint, "_DocumentSummaryTypeGSTR1SUPECO" smallint, "_DocumentSummaryTypeGstr1ADV" smallint, "_DocumentSummaryTypeGstr1ADVAJ" smallint, "_DocumentSummaryTypeGstr1NIL" smallint, "_DocumentTypeINV" smallint, "_DocumentTypeCRN" smallint, "_DocumentTypeDBN" smallint, "_TaxPayerTypeISD" smallint, "_GstActOrRuleSectionTypeGstActItc175" smallint, "_ItcAvailabilityTypeY" smallint, "_ItcAvailabilityTypeN" smallint, "_BitTypeN" boolean, "_BitTypeY" boolean)
 RETURNS TABLE("Section" integer, "IgstAmount" numeric, "CgstAmount" numeric, "SgstAmount" numeric, "CessAmount" numeric)
 LANGUAGE plpgsql
AS $function$
	DECLARE "_Ratio" DECIMAL(18,2);
			"_ExemptTurnover" DECIMAL(18,2);
			"_TaxableTurnover" DECIMAL(18,2);
			"_Count" INTEGER;
			"_RowNumber" INTEGER := 1;
	
BEGIN

	CREATE TEMPORARY TABLE "TempGstr3bSection4B_Original"
	(	
		"Section" INT,
		"IgstAmount" DECIMAL(18,2),
		"CgstAmount" DECIMAL(18,2),
		"SgstAmount" DECIMAL(18,2),
		"CessAmount" DECIMAL(18,2)
	);

	DROP TABLE IF EXISTS "TempGstr3bUpdateStatus";
	CREATE TEMPORARY TABLE "TempGstr3bUpdateStatus"
	(	
		"Id" BIGINT,
		"Section" INT
	);
	
	
	/*4.2.2 ITC Reversed Others*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedOthers",
		SUM(CASE WHEN tpdc."ItcClaimReturnPeriod" IS NULL 
			 THEN tpdc."IgstAmount"
			 ELSE COALESCE(tpdc."IgstAmount",0) - COALESCE(tpdcpr."ItcIgstAmount",0) - COALESCE(tpdcpr."IgstAmount",0)
		END) AS "IgstAmount",
		SUM(CASE WHEN tpdc."ItcClaimReturnPeriod" IS NULL 
			 THEN tpdc."CgstAmount"
			 ELSE COALESCE(tpdc."CgstAmount",0) - COALESCE(tpdcpr."ItcCgstAmount",0) - COALESCE(tpdcpr."CgstAmount",0)
		END) AS "CgstAmount",
		SUM(CASE WHEN tpdc."ItcClaimReturnPeriod" IS NULL 
			 THEN tpdc."SgstAmount"
			 ELSE COALESCE(tpdc."SgstAmount",0) - COALESCE(tpdcpr."ItcSgstAmount",0) - COALESCE(tpdcpr."SgstAmount",0)
		END) AS "SgstAmount",
		SUM(CASE WHEN tpdc."ItcClaimReturnPeriod" IS NULL 
			 THEN tpdc."CessAmount"
			 ELSE COALESCE(tpdc."CessAmount",0) - COALESCE(tpdcpr."ItcCessAmount",0) - COALESCE(tpdcpr."CessAmount",0)
		END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		LEFT JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND
		(
			tpdc."ItcClaimReturnPeriod" IS NULL
			OR 
			(
				tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
				AND ABS(tpdcpr."TotalItcAmount" + tpdcpr."TotalTaxAmount") > 0 AND ABS(tpdcpr."TotalItcAmount" + tpdcpr."TotalTaxAmount") < ABS(tpdc."TotalTaxAmount") 
			)
		);
		
	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdc."Id",
		"_Gstr3bSectionItcReversedOthers"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		LEFT JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."ReverseCharge" = "_BitTypeN"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD")
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND
		(
			tpdc."ItcClaimReturnPeriod" IS NULL
			OR 
			(
				tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
				AND ABS(tpdcpr."TotalItcAmount" + tpdcpr."TotalTaxAmount") > 0 AND ABS(tpdcpr."TotalItcAmount" + tpdcpr."TotalTaxAmount") < ABS(tpdc."TotalTaxAmount") 
			)
		);

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedOthers",
		SUM(COALESCE(tpdc."CpIgstAmount",0) + COALESCE(tpdc."PrevCpIgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdc."CpCgstAmount",0) + COALESCE(tpdc."PrevCpCgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdc."CpSgstAmount",0) + COALESCE(tpdc."PrevCpSgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdc."CpCessAmount",0) + COALESCE(tpdc."PrevCpCessAmount",0)) AS "CessAmount"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND tpdc."ItcClaimReturnPeriod" IS NULL
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpd."Id",
		"_Gstr3bSectionItcReversedOthers"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
		INNER JOIN "TempPurchaseDocumentIds" tpd ON tpdc."MapperId" = tpd."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND tpdc."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND tpdc."ItcClaimReturnPeriod" IS NULL
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");

	/*4.2.2 ITC Reversed Others Amendment Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedOthers",
		SUM(COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0)) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			(
				tpdac."PrTotalItcAmount" IS NULL 
				AND ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			)
			OR
			(
				tpdac."PrTotalTaxAmount" IS NULL 
			)
			OR 
			(
				tpdac."PrTotalItcAmount" IS NOT NULL 
				AND tpdac."TotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."TotalTaxAmount_A") >= ABS(tpdac."PrTotalItcAmount")
			)
			OR 
			(
				tpdac."PrTotalTaxAmount" IS NOT NULL 
				AND tpdac."TotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."TotalTaxAmount_A") >= ABS(tpdac."PrTotalTaxAmount")
			)
		);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedOthers"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalTaxAmount" IS NULL 
			OR
			(
				tpdac."PrTotalItcAmount" IS NULL 
				AND ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
			)
			OR 
			(
				tpdac."PrTotalItcAmount" IS NOT NULL 
				AND tpdac."TotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."TotalTaxAmount_A") >= ABS(tpdac."PrTotalItcAmount")
			)
			OR 
			(
				tpdac."PrTotalTaxAmount" IS NOT NULL 
				AND tpdac."TotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."TotalTaxAmount_A") >= ABS(tpdac."PrTotalTaxAmount")
			)
		);

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedOthers",
		SUM(COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0)) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalItcAmount" IS NULL 
			OR
			tpdac."PrTotalTaxAmount" IS NULL 
			OR 
			(
				tpdac."PrTotalItcAmount" IS NOT NULL 
				AND tpdac."TotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."TotalTaxAmount_A") <> ABS(tpdac."PrTotalItcAmount")
			)
			OR 
			(
				tpdac."TotalTaxAmount" IS NOT NULL
				AND 
				(
					ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount")
					OR
					(
						tpdac."PrTotalTaxAmount" IS NOT NULL 
						AND ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."PrTotalTaxAmount")
						AND ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
					)
				)
			)
		);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedOthers"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod" 
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			tpdac."PrTotalItcAmount" IS NULL 
			OR
			tpdac."PrTotalTaxAmount" IS NULL 
			OR 
			(
				tpdac."PrTotalItcAmount" IS NOT NULL 
				AND tpdac."TotalTaxAmount" IS NOT NULL
				AND ABS(tpdac."TotalTaxAmount_A") <> ABS(tpdac."PrTotalItcAmount")
			)
			OR 
			(
				tpdac."TotalTaxAmount" IS NOT NULL
				AND 
				(
					ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount")
					OR
					(
						tpdac."PrTotalTaxAmount" IS NOT NULL 
						AND ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."PrTotalTaxAmount")
						AND ABS(tpdac."TotalTaxAmount_A") > ABS(tpdac."TotalTaxAmount")
					)
				)
			)
		);

	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedOthers",
		SUM(CASE WHEN COALESCE(ABS(tpdac."PrItcIgstAmount"),0) < COALESCE(ABS(tpdac."IgstAmount_A"),0)
			 THEN COALESCE(tpdac."PrItcIgstAmount",0) - COALESCE(tpdac."IgstAmount_A",0)
			 ELSE COALESCE(tpdac."PrIgstAmount",0) - COALESCE(tpdac."IgstAmount_A",0)
		END) AS "IgstAmount",
		SUM(CASE WHEN COALESCE(ABS(tpdac."PrItcCgstAmount"),0) < COALESCE(ABS(tpdac."CgstAmount_A"),0)
			 THEN COALESCE(tpdac."PrItcCgstAmount",0) - COALESCE(tpdac."CgstAmount_A",0)
			 ELSE COALESCE(tpdac."PrCgstAmount",0) - COALESCE(tpdac."CgstAmount_A",0)
		END) AS "CgstAmount",
		SUM(CASE WHEN COALESCE(ABS(tpdac."PrItcSgstAmount"),0) < COALESCE(ABS(tpdac."SgstAmount_A"),0)
			 THEN COALESCE(tpdac."PrItcSgstAmount",0) - COALESCE(tpdac."SgstAmount_A",0)
			 ELSE COALESCE(tpdac."PrSgstAmount",0) - COALESCE(tpdac."SgstAmount_A",0)
		END) AS "SgstAmount",
		SUM(CASE WHEN COALESCE(ABS(tpdac."PrItcCessAmount"),0) < COALESCE(ABS(tpdac."CessAmount_A"),0)
			 THEN COALESCE(tpdac."PrItcCessAmount",0) - COALESCE(tpdac."CessAmount_A",0)
			 ELSE COALESCE(tpdac."PrCessAmount",0) - COALESCE(tpdac."CessAmount_A",0)
		END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeN"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			ABS(tpdac."PrTotalItcAmount") < ABS(tpdac."TotalTaxAmount_A")
			OR ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount_A")
		);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedOthers"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeN"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND 
		(
			ABS(tpdac."PrTotalItcAmount") < ABS(tpdac."TotalTaxAmount_A")
			OR ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount_A")
		);

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedOthers",
		-SUM(tpdac."IgstAmount") AS "IgstAmount",
		-SUM(tpdac."CgstAmount") AS "CgstAmount",
		-SUM(tpdac."SgstAmount") AS "SgstAmount",
		-SUM(tpdac."CessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND
		(
			tpdac."ItcClaimReturnPeriod" IS NULL
			OR 
			(
				tpdac."ItcClaimReturnPeriod" IS NOT NULL 
				AND 
				(
					tpdac."PrTotalTaxAmount" IS NULL
					OR
					ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount")
				)
			)
		);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedOthers"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE	
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."Gstr2BReturnPeriod" = "_ReturnPeriod"
		AND tpdac."ItcClaimReturnPeriod_A"  IS NULL
		AND tpdac."ReverseCharge" = "_BitTypeN"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND
		(
			tpdac."ItcClaimReturnPeriod" IS NULL
			OR 
			(
				tpdac."ItcClaimReturnPeriod" IS NOT NULL 
				AND 
				(
					tpdac."PrTotalTaxAmount" IS NULL
					OR
					ABS(tpdac."PrTotalTaxAmount") < ABS(tpdac."TotalTaxAmount")
				)
			)
		);

	IF("_Gstr3bAutoPopulateType" = "_Gstr3bAutoPopulateTypeGstActRuleSection")
	THEN
	/*4B1 ITC Reversed As per rules 38, 42, 43 and 17(5) of CGST Rules and Section 17(5)*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcIgstAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."IgstAmount_175"),0)) < ABS(tpdc."IgstAmount")
				 THEN (COALESCE(tpdcpr."ItcIgstAmount_38_42_43",0) + COALESCE(tpdcpr."IgstAmount_175",0))
				 ELSE tpdc."IgstAmount"
			END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCgstAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."CgstAmount_175"),0)) < ABS(tpdc."CgstAmount")
				 THEN (COALESCE(tpdcpr."ItcCgstAmount_38_42_43",0) + COALESCE(tpdcpr."CgstAmount_175",0))
				 ELSE tpdc."CgstAmount"
			END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcSgstAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."SgstAmount_175"),0)) < ABS(tpdc."SgstAmount")
				 THEN (COALESCE(tpdcpr."ItcSgstAmount_38_42_43",0) + COALESCE(tpdcpr."SgstAmount_175",0))
				 ELSE tpdc."SgstAmount"
			END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCessAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."CessAmount_175"),0)) < ABS(tpdc."CessAmount")
				 THEN (COALESCE(tpdcpr."ItcCessAmount_38_42_43",0) + COALESCE(tpdcpr."CessAmount_175",0))
				 ELSE tpdc."CessAmount"
			END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		INNER JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdcpr."TotalItcAmount_38_42_43") > 0 OR ABS(tpdcpr."TotalTaxAmount_175") > 0);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdc."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrmcp ON gdrmcp."GstnId" = tpdc."Id"
		INNER JOIN "TempPurchaseDocumentsCircular170" AS tpdcpr ON gdrmcp."PrId" = tpdcpr."Id"
	WHERE
		tpdc."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdc."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
		AND tpdc."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND (tpdc."TaxpayerType" IS NULL OR tpdc."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdcpr."TotalItcAmount_38_42_43") > 0 OR ABS(tpdcpr."TotalTaxAmount_175") > 0);

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcIgstAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."IgstAmount_175"),0)) < (COALESCE(ABS(tpdc."CpIgstAmount"),0) + COALESCE(ABS(tpdc."PrevCpIgstAmount"),0))
				 THEN (COALESCE(tpdcpr."ItcIgstAmount_38_42_43",0) + COALESCE(tpdcpr."IgstAmount_175",0))
				 ELSE (COALESCE(tpdc."CpIgstAmount",0) + COALESCE(tpdc."PrevCpIgstAmount",0))
			END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCgstAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."CgstAmount_175"),0)) < (COALESCE(ABS(tpdc."CpCgstAmount"),0) + COALESCE(ABS(tpdc."PrevCpCgstAmount"),0))
				 THEN (COALESCE(tpdcpr."ItcCgstAmount_38_42_43",0) + COALESCE(tpdcpr."CgstAmount_175",0))
				 ELSE (COALESCE(tpdc."CpCgstAmount",0) + COALESCE(tpdc."PrevCpCgstAmount",0))
			END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcSgstAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."SgstAmount_175"),0)) < (COALESCE(ABS(tpdc."CpSgstAmount"),0) + COALESCE(ABS(tpdc."PrevCpSgstAmount"),0))
				 THEN (COALESCE(tpdcpr."ItcSgstAmount_38_42_43",0) + COALESCE(tpdcpr."SgstAmount_175",0))
				 ELSE (COALESCE(tpdc."CpSgstAmount",0) + COALESCE(tpdc."PrevCpSgstAmount",0))
			END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdcpr."ItcCessAmount_38_42_43"),0) + COALESCE(ABS(tpdcpr."CessAmount_175"),0)) < (COALESCE(ABS(tpdc."CpCessAmount"),0) + COALESCE(ABS(tpdc."PrevCpCessAmount"),0))
				 THEN (COALESCE(tpdcpr."ItcCessAmount_38_42_43",0) + COALESCE(tpdcpr."CessAmount_175",0))
				 ELSE (COALESCE(tpdc."CpCessAmount",0) + COALESCE(tpdc."PrevCpCessAmount",0))
			END) AS "CessAmount"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
		AND (ABS(tpdcpr."TotalItcAmount_38_42_43") > 0 OR ABS(tpdcpr."TotalTaxAmount_175") > 0)
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");
		
	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpd."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempManualPurchaseDocumentsCircular170" AS tpdc
		INNER JOIN "TempManualPurchaseDocumentsCircular170" tpdcpr ON tpdcpr."MapperId" = tpdc."MapperId"
		INNER JOIN "TempPurchaseDocumentIds" tpd ON tpdc."MapperId" = tpd."MapperId"
	WHERE
		tpdc."ManualSourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdcpr."ManualSourceType" = "_SourceTypeTaxPayer"
		AND tpdc."ItcClaimReturnPeriod" = "_ReturnPeriod"
		AND (ABS(tpdcpr."TotalItcAmount_38_42_43") > 0 OR ABS(tpdcpr."TotalTaxAmount_175") > 0)
		AND (tpdc."CpTotalTaxAmount" + tpdc."PrevCpTotalTaxAmount") = (tpdcpr."TotalTaxAmount" + tpdcpr."TotalItcAmount");

	/*4B1 ITC Reversed As per rules 38, 42, 43 and 17(5) of CGST Rules and Section 17(5) Amendment Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		CASE WHEN ABS(tpdac."TotalTaxAmount") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0)
			 ELSE COALESCE(tpdac."IgstAmount_A",0) - (COALESCE(tpdac."PrItcIgstAmount_38_42_43",0) + COALESCE(tpdac."PrIgstAmount_175",0))
		END AS "IgstAmount",
		CASE WHEN ABS(tpdac."TotalTaxAmount") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0)
			 ELSE COALESCE(tpdac."CgstAmount_A",0) - (COALESCE(tpdac."PrItcCgstAmount_38_42_43",0) + COALESCE(tpdac."PrCgstAmount_175",0))
		END AS "CgstAmount",
		CASE WHEN ABS(tpdac."TotalTaxAmount") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0)
			 ELSE COALESCE(tpdac."SgstAmount_A",0) - (COALESCE(tpdac."PrItcSgstAmount_38_42_43",0) + COALESCE(tpdac."PrSgstAmount_175",0))
		END AS "SgstAmount",
		CASE WHEN ABS(tpdac."TotalTaxAmount") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0)
			 ELSE COALESCE(tpdac."CessAmount_A",0) - (COALESCE(tpdac."PrItcCessAmount_38_42_43",0) + COALESCE(tpdac."PrCessAmount_175",0))
		END AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND ABS(tpdac."TotalTaxAmount_A") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
		AND ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND ABS(tpdac."TotalTaxAmount_A") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
		AND ABS(tpdac."TotalTaxAmount_A") < ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		CASE WHEN ABS(tpdac."TotalTaxAmount_A") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."IgstAmount_A",0) - COALESCE(tpdac."IgstAmount",0)
			 ELSE (COALESCE(tpdac."PrItcIgstAmount_38_42_43",0) + COALESCE(tpdac."PrIgstAmount_175",0)) - COALESCE(tpdac."IgstAmount",0)
		END AS "IgstAmount",
		CASE WHEN ABS(tpdac."TotalTaxAmount_A") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."CgstAmount_A",0) - COALESCE(tpdac."CgstAmount",0)
			 ELSE (COALESCE(tpdac."PrItcCgstAmount_38_42_43",0) + COALESCE(tpdac."PrCgstAmount_175",0)) - COALESCE(tpdac."CgstAmount",0)
		END AS "CgstAmount",
		CASE WHEN ABS(tpdac."TotalTaxAmount_A") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."SgstAmount_A",0) - COALESCE(tpdac."SgstAmount",0)
			 ELSE (COALESCE(tpdac."PrItcSgstAmount_38_42_43",0) + COALESCE(tpdac."PrSgstAmount_175",0)) - COALESCE(tpdac."SgstAmount",0)
		END AS "SgstAmount",
		CASE WHEN ABS(tpdac."TotalTaxAmount_A") < (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) 
			 THEN COALESCE(tpdac."CessAmount_A",0) - COALESCE(tpdac."CessAmount",0)
			 ELSE (COALESCE(tpdac."PrItcCessAmount_38_42_43",0) + COALESCE(tpdac."PrCessAmount_175",0)) - COALESCE(tpdac."CessAmount",0)
		END AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) >= ABS(tpdac."TotalTaxAmount") 
		AND ABS(tpdac."TotalTaxAmount_A") >= ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") + ABS(tpdac."PrTotalTaxAmount_175")) >= ABS(tpdac."TotalTaxAmount") 
		AND ABS(tpdac."TotalTaxAmount_A") >= ABS(tpdac."TotalTaxAmount");

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcIgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrIgstAmount_175"),0)) < ABS(tpdac."IgstAmount_A")
				 THEN (COALESCE(tpdac."PrItcIgstAmount_38_42_43",0) + COALESCE(tpdac."PrIgstAmount_175",0))
				 ELSE tpdac."IgstAmount_A"
			END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcCgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCgstAmount_175"),0)) < ABS(tpdac."CgstAmount_A")
				 THEN (COALESCE(tpdac."PrItcCgstAmount_38_42_43",0) + COALESCE(tpdac."PrCgstAmount_175",0))
				 ELSE tpdac."CgstAmount_A"
			END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcSgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrSgstAmount_175"),0)) < ABS(tpdac."SgstAmount_A")
				 THEN (COALESCE(tpdac."PrItcSgstAmount_38_42_43",0) + COALESCE(tpdac."PrSgstAmount_175",0))
				 ELSE tpdac."SgstAmount_A"
			END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcCessAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCessAmount_175"),0)) < ABS(tpdac."CessAmount_A")
				 THEN (COALESCE(tpdac."PrItcCessAmount_38_42_43",0) + COALESCE(tpdac."PrCessAmount_175",0))
				 ELSE tpdac."CessAmount_A"
			END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") > 0 OR ABS(tpdac."PrTotalTaxAmount_175") > 0);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") > 0 OR ABS(tpdac."PrTotalTaxAmount_175") > 0);

	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcIgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrIgstAmount_175"),0)) < ABS(tpdac."IgstAmount_A")
				 THEN (COALESCE(tpdac."PrItcIgstAmount_38_42_43",0) + COALESCE(tpdac."PrIgstAmount_175",0))
				 ELSE tpdac."IgstAmount_A"
			END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcCgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCgstAmount_175"),0)) < ABS(tpdac."CgstAmount_A")
				 THEN (COALESCE(tpdac."PrItcCgstAmount_38_42_43",0) + COALESCE(tpdac."PrCgstAmount_175",0))
				 ELSE tpdac."CgstAmount_A"
			END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcSgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrSgstAmount_175"),0)) < ABS(tpdac."SgstAmount_A")
				 THEN (COALESCE(tpdac."PrItcSgstAmount_38_42_43",0) + COALESCE(tpdac."PrSgstAmount_175",0))
				 ELSE tpdac."SgstAmount_A"
			END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcCessAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCessAmount_175"),0)) < ABS(tpdac."CessAmount_A")
				 THEN (COALESCE(tpdac."PrItcCessAmount_38_42_43",0) + COALESCE(tpdac."PrCessAmount_175",0))
				 ELSE tpdac."CessAmount_A"
			END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") > 0 OR ABS(tpdac."PrTotalTaxAmount_175") > 0);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") > 0 OR ABS(tpdac."PrTotalTaxAmount_175") > 0);

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcIgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrIgstAmount_175"),0)) <= COALESCE(ABS(tpdac."IgstAmount"),0)
			 THEN -(COALESCE(ABS(tpdac."PrItcIgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrIgstAmount_175"),0))
			 ELSE -tpdac."IgstAmount"
		END) AS "IgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcCgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCgstAmount_175"),0)) <= COALESCE(ABS(tpdac."CgstAmount"),0)
			 THEN -(COALESCE(ABS(tpdac."PrItcCgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCgstAmount_175"),0))
			 ELSE -tpdac."CgstAmount"
		END) AS "CgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcSgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrSgstAmount_175"),0)) <= COALESCE(ABS(tpdac."SgstAmount"),0)
			 THEN -(COALESCE(ABS(tpdac."PrItcSgstAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrSgstAmount_175"),0))
			 ELSE -tpdac."SgstAmount"
		END) AS "SgstAmount",
		SUM(CASE WHEN (COALESCE(ABS(tpdac."PrItcCessAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCessAmount_175"),0)) <= COALESCE(ABS(tpdac."CessAmount"),0)
			 THEN -(COALESCE(ABS(tpdac."PrItcCessAmount_38_42_43"),0) + COALESCE(ABS(tpdac."PrCessAmount_175"),0))
			 ELSE -tpdac."CessAmount"
		END) AS "CessAmount"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") > 0 OR ABS(tpdac."PrTotalTaxAmount_175") > 0);

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpdac."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocumentsAmendmentCircular170" tpdac
	WHERE 
		tpdac."SourceType" = "_SourceTypeCounterPartyFiled"
		AND tpdac."ItcAvailability_A" ="_ItcAvailabilityTypeN"
		AND tpdac."ItcAvailability" ="_ItcAvailabilityTypeY"
		AND tpdac."ItcClaimReturnPeriod" IS NOT NULL
		AND tpdac."ItcClaimReturnPeriod_A" = "_ReturnPeriod"
		AND tpdac."DocumentType" IN ("_DocumentTypeINV", "_DocumentTypeCRN", "_DocumentTypeDBN")
		AND (tpdac."TaxpayerType" IS NULL OR tpdac."TaxpayerType" <> "_TaxPayerTypeISD")
		AND (ABS(tpdac."PrTotalItcAmount_38_42_43") > 0 OR ABS(tpdac."PrTotalTaxAmount_175") > 0);

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(tpd."IgstAmount") AS "IgstAmount",
		SUM(tpd."CgstAmount") AS "CgstAmount",
		SUM(tpd."SgstAmount") AS "SgstAmount",
		SUM(tpd."CessAmount") AS "CessAmount"
	FROM
		"TempPurchaseDocuments" AS tpd
	WHERE 
		tpd."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND tpd."ReverseCharge" = "_BitTypeY"
		AND tpd."SourceType" = "_SourceTypeTaxPayer"
		AND tpd."ReturnPeriod" = "_ReturnPeriod"
		AND tpd."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeIMPS")
		AND (tpd."BillFromGstin" IS NULL OR tpd."BillFromGstin" = 'URP' OR tpd."IsBillFromPAN" = "_BitTypeY")
		AND tpd."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175";

	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpd."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM
		"TempPurchaseDocuments" AS tpd
	WHERE 
		tpd."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND tpd."ReverseCharge" = "_BitTypeY"
		AND tpd."SourceType" = "_SourceTypeTaxPayer"
		AND tpd."ReturnPeriod" = "_ReturnPeriod"
		AND tpd."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeIMPS")
		AND (tpd."BillFromGstin" IS NULL OR tpd."BillFromGstin" = 'URP' OR tpd."IsBillFromPAN" = "_BitTypeY")
		AND tpd."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175";

	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		SUM(COALESCE(tpda."IgstAmount_A",0) - COALESCE(tpda."IgstAmount",0)) AS "IgstAmount",
		SUM(COALESCE(tpda."CgstAmount_A",0) - COALESCE(tpda."CgstAmount",0)) AS "CgstAmount",
		SUM(COALESCE(tpda."SgstAmount_A",0) - COALESCE(tpda."SgstAmount",0)) AS "SgstAmount",
		SUM(COALESCE(tpda."CessAmount_A",0) - COALESCE(tpda."CessAmount",0)) AS "CessAmount"
	FROM	
		"TempPurchaseDocumentsAmendment" AS tpda
	WHERE
		tpda."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND tpda."ReverseCharge" = "_BitTypeY"
		AND tpda."SourceType" = "_SourceTypeTaxPayer"
		AND tpda."ReturnPeriod" = "_ReturnPeriod"
		AND tpda."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeIMPS")
		AND (tpda."BillFromGstin" IS NULL OR tpda."BillFromGstin" = 'URP' OR tpda."IsBillFromPAN" = "_BitTypeY")
		AND tpda."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175";

	
	INSERT INTO "TempGstr3bUpdateStatus"
	(
		"Id",
		"Section"
	)
	SELECT
		tpda."Id",
		"_Gstr3bSectionItcReversedAsPerRule"
	FROM	
		"TempPurchaseDocumentsAmendment" AS tpda
	WHERE
		tpda."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeCRN","_DocumentTypeDBN")
		AND tpda."ReverseCharge" = "_BitTypeY"
		AND tpda."SourceType" = "_SourceTypeTaxPayer"
		AND tpda."ReturnPeriod" = "_ReturnPeriod"
		AND tpda."TransactionType" IN ("_TransactionTypeB2C","_TransactionTypeIMPS")
		AND (tpda."BillFromGstin" IS NULL OR tpda."BillFromGstin" = 'URP' OR tpda."IsBillFromPAN" = "_BitTypeY")
		AND tpda."GstActOrRuleSection" = "_GstActOrRuleSectionTypeGstActItc175";

	END IF;
		
	IF("_Gstr3bAutoPopulateType" = "_Gstr3bAutoPopulateTypeExemptedTurnoverRatio")
	THEN
		DROP TABLE IF EXISTS "TempReturnPeriods" ;
		CREATE TEMPORARY TABLE "TempReturnPeriods" 
		(
			"RowNumber" Integer generated always as identity,
			"ReturnPeriod" INTEGER
		);

		INSERT INTO "TempReturnPeriods"
		(
			"ReturnPeriod"
		)
		SELECT
			*
		FROM 
			UNNEST("_PreviousReturnPeriods") AS "Item";

		SELECT COUNT(*) INTO "_Count" FROM "TempReturnPeriods";

		DROP TABLE IF EXISTS "TempTaxableTurnover" ;
		CREATE TEMPORARY TABLE "TempTaxableTurnover" AS
		SELECT
			trd."RowNumber",
			CASE WHEN sd."DocumentType" =  "_DocumentTypeCRN" THEN -SUM(sd."TotalTaxableValue") ELSE SUM(sd."TotalTaxableValue") END AS "TaxableValue"
		FROM
			oregular."SaleDocumentDW" sd
			INNER JOIN "TempReturnPeriods" trd ON trd."ReturnPeriod" = sd."ReturnPeriod"
		WHERE 
			sd."ParentEntityId" = "_EntityId"
			AND sd."SectionType" & "_SectTypeAll" <> 0
		GROUP BY 
			trd."RowNumber",
			sd."DocumentType";

		INSERT INTO "TempTaxableTurnover"
		SELECT 
			trd."RowNumber",
			SUM((CASE WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADV"
					 THEN COALESCE(ss."AdvanceAmount",0)
					 WHEN ss."SummaryType" = "_DocumentSummaryTypeGstr1ADVAJ"
					 THEN -COALESCE(ss."AdvanceAmount",0)
					 ELSE COALESCE(ss."TaxableValue",0)
				END) + COALESCE(ss."NilAmount",0) + COALESCE(ss."ExemptAmount",0) + COALESCE(ss."NonGstAmount",0)) AS "TaxableValue"
		FROM
			oregular."SaleSummaries" ss
			INNER JOIN "TempReturnPeriods" trd ON trd."ReturnPeriod" = ss."ReturnPeriod"
		WHERE 
			ss."EntityId" = "_EntityId"
			AND ss."SummaryType" IN ("_DocumentSummaryTypeGstr1B2CS","_DocumentSummaryTypeGSTR1ECOM","_DocumentSummaryTypeGSTR1SUPECO","_DocumentSummaryTypeGstr1ADV","_DocumentSummaryTypeGstr1ADVAJ","_DocumentSummaryTypeGstr1NIL")
		GROUP BY 
			trd."RowNumber";

		DROP TABLE IF EXISTS "TempExemptTurnover" ;
		CREATE TEMPORARY TABLE "TempExemptTurnover" AS
		SELECT
			trd."RowNumber",
			SUM(COALESCE(ss."NilAmount",0) + COALESCE(ss."ExemptAmount",0) + COALESCE(ss."NonGstAmount",0))  AS "TaxableValue"
		FROM
			oregular."SaleSummaries" ss
			INNER JOIN "TempReturnPeriods" trd ON trd."ReturnPeriod" = ss."ReturnPeriod"
		WHERE 
			ss."EntityId" = "_EntityId"
			AND ss."SummaryType" IN ("_DocumentSummaryTypeGstr1NIL")
		GROUP BY 
			trd."RowNumber";

		DROP TABLE IF EXISTS "TempReturnData" ;
		CREATE TEMPORARY TABLE "TempReturnData" AS
		SELECT 
			trd."RowNumber",
			r."ReturnPeriod",
			(SUM(CASE WHEN t2."key" = 'itc_avl' THEN ((t3."value" -> 'iamt')::TEXT::NUMERIC) ELSE 0 END) - SUM(CASE WHEN t2."key" = 'itc_rev' AND (t3.value -> 'ty')::TEXT = '"OTH"' THEN ((t3."value" -> 'iamt')::TEXT::NUMERIC) ELSE 0 END)) AS "IgstAmount",
			(SUM(CASE WHEN t2."key" = 'itc_avl' THEN ((t3."value" -> 'camt')::TEXT::NUMERIC) ELSE 0 END) - SUM(CASE WHEN t2."key" = 'itc_rev' AND (t3.value -> 'ty')::TEXT = '"OTH"' THEN ((t3."value" -> 'camt')::TEXT::NUMERIC) ELSE 0 END)) AS "CgstAmount",
			(SUM(CASE WHEN t2."key" = 'itc_avl' THEN ((t3."value" -> 'samt')::TEXT::NUMERIC) ELSE 0 END) - SUM(CASE WHEN t2."key" = 'itc_rev' AND (t3.value -> 'ty')::TEXT = '"OTH"' THEN ((t3."value" -> 'samt')::TEXT::NUMERIC) ELSE 0 END)) AS "SgstAmount",
			(SUM(CASE WHEN t2."key" = 'itc_avl' THEN ((t3."value" -> 'csamt')::TEXT::NUMERIC) ELSE 0 END) - SUM(CASE WHEN t2."key" = 'itc_rev' AND (t3.value -> 'ty')::TEXT = '"OTH"' THEN ((t3."value" -> 'csamt')::TEXT::NUMERIC) ELSE 0 END)) AS "CessAmount"
		FROM 
			gst."Returns" r
			INNER JOIN "TempReturnPeriods" trd ON r."ReturnPeriod" = trd."ReturnPeriod"
			JOIN json_each_text(r."Data"::JSON) t1 ON TRUE
			JOIN json_each_text(t1."value"::JSON) t2 ON TRUE
			JOIN json_array_elements(t2."value"::JSON) t3 ON TRUE
		WHERE 
			r."EntityId" = "_EntityId"
			AND r."Type" = "_ReturnTypeGSTR3B"
			AND r."Action" = "_ReturnActionSystemGenerated"
			AND r."Data" IS NOT NULL
			AND t1."key" = 'itc_elg'
			AND t2."key" IN ('itc_rev','itc_avl')
			AND r."ReturnPeriod" <> "_ReturnPeriod"
		GROUP BY
			trd."RowNumber",
			r."ReturnPeriod";

		INSERT INTO "TempReturnData"
		(
			"RowNumber",
			"ReturnPeriod",
			"IgstAmount",
			"CgstAmount",
			"SgstAmount",
			"CessAmount"
		)
		SELECT 
			"_Count" AS "RowNumber",
			"_ReturnPeriod" AS "ReturnPeriod",
			SUM(tgso."IgstAmount"),
			SUM(tgso."CgstAmount"),
			SUM(tgso."SgstAmount"),
			SUM(tgso."CessAmount")			
		FROM
			"TempGstr3bSection_Original" tgso
		WHERE 
			tgso."Section" IN ("_Gstr3bSectionImportOfGoods","_Gstr3bSectionImportOfServices","_Gstr3bSectionInwardReverseChargeOther","_Gstr3bSectionInwardSuppliesFromIsd","_Gstr3bSectionOtherItc");

		INSERT INTO "TempReturnData"
		(
			"RowNumber",
			"ReturnPeriod",
			"IgstAmount",
			"CgstAmount",
			"SgstAmount",
			"CessAmount"
		)
		SELECT 
			"_Count" AS "RowNumber",
			"_ReturnPeriod" AS "ReturnPeriod",
			-SUM(tgso."IgstAmount"),
			-SUM(tgso."CgstAmount"),
			-SUM(tgso."SgstAmount"),
			-SUM(tgso."CessAmount")			
		FROM
			"TempGstr3bSection4B_Original" tgso
		WHERE 
			tgso."Section" = "_Gstr3bSectionItcReversedOthers";			

		DROP TABLE IF EXISTS "TempItcReversalData";
		CREATE TEMPORARY TABLE "TempItcReversalData"
		(
			"RowNumber" INTEGER,
			"ItcReversalIgstAmount" DECIMAL(18,2),
			"ItcReversalCgstAmount" DECIMAL(18,2),
			"ItcReversalSgstAmount" DECIMAL(18,2),
			"ItcReversalCessAmount" DECIMAL(18,2)
		);

		WHILE "_RowNumber" <= "_Count"
		LOOP

			SELECT SUM(tsd."TaxableValue") INTO "_TaxableTurnover" FROM "TempTaxableTurnover" tsd WHERE tsd."RowNumber" <= "_RowNumber";
			SELECT SUM(tss."TaxableValue") INTO "_ExemptTurnover" FROM "TempExemptTurnover" tss WHERE tss."RowNumber" <= "_RowNumber";

			"_Ratio" := "_ExemptTurnover" / "_TaxableTurnover";

			INSERT INTO "TempItcReversalData"
			SELECT 
				"_RowNumber" AS "RowNumber",
				(SUM(trd."IgstAmount") * "_Ratio") AS "ItcReversalIgstAmount",
				(SUM(trd."CgstAmount") * "_Ratio") AS "ItcReversalCgstAmount",
				(SUM(trd."SgstAmount") * "_Ratio") AS "ItcReversalSgstAmount",
				(SUM(trd."CessAmount") * "_Ratio") AS "ItcReversalCessAmount"
			FROM 
				"TempReturnData" trd 
			WHERE	
				trd."RowNumber" <= "_RowNumber"
			GROUP BY
				"_RowNumber";

			"_RowNumber" := "_RowNumber" + 1;

		END LOOP;
		
	INSERT INTO "TempGstr3bSection4B_Original"
	(
		"Section",
		"IgstAmount",
		"CgstAmount",
		"SgstAmount",
		"CessAmount"
	)
	SELECT
		"_Gstr3bSectionItcReversedAsPerRule",
		tird."ItcReversalIgstAmount",
		tird."ItcReversalCgstAmount",
		tird."ItcReversalSgstAmount",
		tird."ItcReversalCessAmount"
	FROM 
		"TempItcReversalData" tird
		INNER JOIN "TempReturnPeriods" trd ON trd."RowNumber" = tird."RowNumber"
	WHERE 
		trd."ReturnPeriod" = "_ReturnPeriod";

	END IF;
	
	UPDATE 
		oregular."PurchaseDocumentStatus" pds
	SET 
		"Gstr3bSection" = CASE WHEN "Gstr3bSection" IS NULL THEN us."Section" WHEN "Gstr3bSection" & us."Section" <> 0 THEN "Gstr3bSection" ELSE "Gstr3bSection" + us."Section" END
	FROM 
		"TempGstr3bUpdateStatus" us
	WHERE
		pds."PurchaseDocumentId" = us."Id";

	RETURN QUERY
	SELECT
		tod."Section",
		SUM(tod."IgstAmount") AS "IgstAmount",
		SUM(tod."CgstAmount") AS "CgstAmount",
		SUM(tod."SgstAmount") AS "SgstAmount",
		SUM(tod."CessAmount") AS "CessAmount"
	FROM
		"TempGstr3bSection4B_Original" AS tod
	GROUP BY
		tod."Section";

	DROP TABLE "TempGstr3bSection4B_Original";

END
$function$
;
DROP FUNCTION IF EXISTS oregular."InsertPurchaseDocumentRecoCancelledCreditNotes";

CREATE OR REPLACE FUNCTION oregular."InsertPurchaseDocumentRecoCancelledCreditNotes"("_ParentEntityId" integer, "_FinancialYear" integer, "_SubscriberId" integer, "_DocumentTypeINV" smallint, "_DocumentTypeDBN" smallint, "_DocumentTypeCRN" smallint, "_NearMatchCancelledInvoiceToleranceFrom" numeric, "_NearMatchCancelledInvoiceToleranceTo" numeric, "_ReconciliationSectionTypePrDiscarded" smallint DEFAULT 9, "_ReconciliationSectionTypeGstDiscarded" smallint DEFAULT 10, "_ReconciliationSectionTypeGstOnly" smallint DEFAULT 2, "_CancelledInvoiceReasonType" character varying DEFAULT '8589934592'::bigint, "_ShortCaseReasonType" character varying DEFAULT '34359738368'::bigint)
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
	DROP TABLE IF EXISTS "TempCrossDocumentMatchedData","Reason";
							   
	CREATE TEMP TABLE "TempCrossDocumentMatchedData"("Id" SERIAL, "PrId" BIGINT , "GstnId" BIGINT,"Preference" smallint,"Source" CHARACTER VARYING,"ReturnPeriod" INT);  
	
	DROP TABLE IF EXISTS "TempShortCaseMatchedData";
	CREATE TEMP TABLE "TempShortCaseMatchedData"("Id" SERIAL, "PrId" BIGINT , "GstnId" BIGINT,"Preference" smallint,"Source" CHARACTER VARYING,"ReturnPeriod" INT);  
	
	DROP TABLE IF EXISTS "TempPrOnlyData","TempGstnOnlyData";
	   
	RAISE NOTICE 'CancelledCreditNotes Step 1 %', clock_timestamp()::timestamp without time zone;
	
	DROP TABLE IF EXISTS "TempPrOnlyData";
	
	CREATE TEMP TABLE "TempPrOnlyData" AS
	SELECT 
		pdr."Id",
		pdr."DocumentType",
		pdr."DocumentNumber",
		to_date(pdr."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		pdr."DocumentFinancialYear" "FinancialYear",
		pdr."FinancialYear" "RPFinancialYear" ,
		pdr."BillFromGstin" "Gstin" ,
		pdr."ParentEntityId",
		pdr."TotalTaxableValue",
		pdr."TotalTaxAmount",
		pdr."ReturnPeriod",
		pdr."BillFromPan" "GstinPAN",
		CASE WHEN pdr."DocumentType" = 4 THEN pdr."PortCode"  ELSE '' END "PortCode",
		Pdr."SubscriberId",
		pdr."IsAmendment",
		pdr."DocumentValue",
		ABS(pdr."TotalTaxAmount"-gst."TotalTaxAmount") AS "TotalTaxAmountDiff"
	FROM 
		oregular."PurchaseDocumentDW" pdr 		
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" AS gdrm on pdr."Id" = gdrm."PrId"
		LEFT JOIN oregular."PurchaseDocumentDW" AS gst ON gdrm."GstnId" = gst."Id"
	WHERE   
		pdr."SubscriberId" = "_SubscriberId"    
		AND pdr."FinancialYear" = "_FinancialYear"
		AND Pdr."ParentEntityId" = "_ParentEntityId"
		AND pdr."DocumentType" IN ("_DocumentTypeINV","_DocumentTypeDBN")
		AND gdrm."SectionType" <> "_ReconciliationSectionTypePrDiscarded"
		AND "CancelledInvoiceId" IS NULL;
		
	RAISE NOTICE 'CancelledCreditNotes Step 2 %', clock_timestamp()::timestamp without time zone;
	
	CREATE TEMP TABLE "TempGstnOnlyData" AS
	SELECT 
		pdr."Id",
		pdr."DocumentType",
		"DocumentNumber",
		to_date(pdr."DocumentDate"::text, 'YYYYMMDD') "DocumentDate",
		pdr."DocumentFinancialYear" "FinancialYear",
		pdr."FinancialYear" "RPFinancialYear",
		pdr."BillFromGstin" "Gstin",
		pdr."ParentEntityId",
		pdr."TotalTaxableValue",
		pdr."TotalTaxAmount",
		pdr."ReturnPeriod",
		pdr."SubscriberId",
		pdr."IsAmendment",
		pdr."DocumentValue"		
	FROM 
		oregular."PurchaseDocumentDW" pdr  			
		INNER JOIN oregular."Gstr2bDocumentRecoMapper" gdrm on pdr."Id" = gdrm."GstnId"
	WHERE   
		pdr."SubscriberId" = "_SubscriberId"    		
		AND pdr."FinancialYear" = "_FinancialYear"
		AND Pdr."ParentEntityId" = "_ParentEntityId"
		AND pdr."DocumentType" IN ("_DocumentTypeCRN","_DocumentTypeINV", "_DocumentTypeDBN")
		AND gdrm."SectionType" = "_ReconciliationSectionTypeGstOnly"
		AND "CancelledInvoiceId" IS NULL;

	RAISE NOTICE 'CancelledCreditNotes Step 3 %', clock_timestamp()::timestamp without time zone;
	
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
	
	RAISE NOTICE 'CancelledCreditNotes Step 4 %', clock_timestamp()::timestamp without time zone;
	
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

	RAISE NOTICE 'CancelledCreditNotes Step 5 %', clock_timestamp()::timestamp without time zone;
	
	/*Delete record with less preference*/

	DELETE
		FROM "TempCrossDocumentMatchedData" AS P0 
		USING "TempCrossDocumentMatchedData" AS P1
	WHERE 
		P1."Preference"= 1 
		AND P0."Preference" = 2
		AND P1."GstnId" = P0."GstnId";

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
		AND Pr."DocumentType" = "_DocumentTypeINV"
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
		AND Pr."DocumentType" = "_DocumentTypeINV"
		AND pr."TotalTaxAmount"-Gstn."TotalTaxAmount" BETWEEN "_NearMatchCancelledInvoiceToleranceFrom" AND "_NearMatchCancelledInvoiceToleranceTo"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");

	
	RAISE NOTICE 'CancelledCreditNotes Step 8 %', clock_timestamp()::timestamp without time zone;
	
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

	RAISE NOTICE 'CancelledCreditNotes Step 9 %', clock_timestamp()::timestamp without time zone;

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
	
	RAISE NOTICE 'CancelledCreditNotes Step 10 %', clock_timestamp()::timestamp without time zone;

	/* Start Short Case */
	INSERT INTO "TempShortCaseMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
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
		AND Pr."DocumentType" = "_DocumentTypeINV"
		AND pr."TotalTaxAmountDiff" = Gstn."TotalTaxAmount"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id");
		
	RAISE NOTICE 'CancelledCreditNotes Step 11 %', clock_timestamp()::timestamp without time zone;

	INSERT INTO "TempShortCaseMatchedData"("PrId","GstnId","Preference","ReturnPeriod","Source")  
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
		AND Pr."DocumentType" = "_DocumentTypeINV"
		AND pr."TotalTaxAmountDiff" = Gstn."TotalTaxAmount"
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempCrossDocumentMatchedData" tc WHERE tc."GstnId" = GSTN."Id")
		AND NOT EXISTS (SELECT 1 FROM "TempShortCaseMatchedData" tc WHERE tc."PrId" = pr."Id")  
		AND NOT EXISTS (SELECT 1 FROM "TempShortCaseMatchedData" tc WHERE tc."GstnId" = GSTN."Id");
	
	/* End Short Case */

	RAISE NOTICE 'CancelledCreditNotes Step 12 %', clock_timestamp()::timestamp without time zone;
	
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
		
	WITH "GstnShortCaseCTE"  
	AS  
	(  
		SELECT  
			ROW_NUMBER() OVER(PARTITION BY M."GstnId" ORDER BY "ReturnPeriod") "RowNum", *    
		FROM  
			"TempShortCaseMatchedData" M  				
	)  
	DELETE 
	FROM		  
		"TempShortCaseMatchedData" WHERE "Id" IN(SELECT "Id" FROM "GstnShortCaseCTE"	WHERE "RowNum" > 1); 
	
	 
	WITH "PrShortCaseCTE"  
	AS  
	(  
		SELECT  
			ROW_NUMBER() OVER(PARTITION BY M."PrId" ORDER BY "ReturnPeriod") "RowNum", *    
		FROM  
			"TempShortCaseMatchedData" M  
	)  
	DELETE 
	FROM
		"TempShortCaseMatchedData" WHERE "Id" IN(SELECT "Id" FROM "PrShortCaseCTE"	WHERE "RowNum" > 1);		
	   
	RAISE NOTICE 'CancelledCreditNotes Step 13 %', clock_timestamp()::timestamp without time zone;
	
	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_CancelledInvoiceReasonType" ,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_CancelledInvoiceReasonType"
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"},')) END, 
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
	
	RAISE NOTICE 'CancelledCreditNotes Step 14 %', clock_timestamp()::timestamp without time zone;
	
	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_CancelledInvoiceReasonType" ,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_CancelledInvoiceReasonType"
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"},')) END, 
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

	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_CancelledInvoiceReasonType" ,',"Value":"',CASE WHEN pd."DocumentNumber" IS NOT NULL THEN CONCAT(pd."DocumentNumber", '#', pd."DocumentDate") ELSE CONCAT(gd."DocumentNumber", '||', gd."DocumentDate") END,'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_CancelledInvoiceReasonType"
													,',"Value":"',CASE WHEN pd."DocumentNumber" IS NOT NULL THEN CONCAT(pd."DocumentNumber", '#', pd."DocumentDate") ELSE CONCAT(gd."DocumentNumber", '||', gd."DocumentDate") END,'"},')) END, 
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
	
	RAISE NOTICE 'Short Case Step 15 %', clock_timestamp()::timestamp without time zone;
	
	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_ShortCaseReasonType" ,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_ShortCaseReasonType"
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"},')) END, 
			"ReasonType" = "_ShortCaseReasonType"::BIGINT  + COALESCE(pdrm."ReasonType", 0),
			"CancelledInvoiceId" = t_pdrm."GstnId"
	FROM
		"TempShortCaseMatchedData" t_pdrm
	INNER JOIN Oregular."Gstr2bDocumentRecoMapper" pdrm ON t_pdrm."PrId" = pdrm."PrId"
	INNER JOIN "TempGstnOnlyData" gd ON  t_pdrm."GstnId" = gd."Id"
	WHERE
		pdr."Id" = pdrm."Id"
		AND COALESCE(pdr."Reason",'[]') NOT LIKE '%' || "_ShortCaseReasonType" || '%'
		AND t_pdrm."Source" = 'Pr'; 
	
	RAISE NOTICE 'Short Case Step 16 %', clock_timestamp()::timestamp without time zone;
	
	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_ShortCaseReasonType" ,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_ShortCaseReasonType"
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', gd."DocumentDate"),'"},')) END, 
			"ReasonType" = "_ShortCaseReasonType"::BIGINT  + COALESCE(pdrm."ReasonType", 0),
			"CancelledInvoiceId" = t_pdrm."GstnId"
	FROM
		"TempShortCaseMatchedData" t_pdrm
	INNER JOIN Oregular."Gstr2bDocumentRecoMapper" pdrm ON t_pdrm."PrId" = pdrm."GstnId"
	INNER JOIN "TempGstnOnlyData" gd ON  t_pdrm."GstnId" = gd."Id"
	WHERE
		pdr."Id" = pdrm."Id"
		AND COALESCE(pdr."Reason",'[]') NOT LIKE '%' || "_ShortCaseReasonType" || '%'
		AND t_pdrm."Source" = 'Gstn'; 

	RAISE NOTICE 'Short Case Step 17 %', clock_timestamp()::timestamp without time zone;

	UPDATE Oregular."Gstr2bDocumentRecoMapper" pdr
		SET "Reason" = CASE WHEN COALESCE(pdrm."Reason",'[]') = '[]' 
						  THEN CONCAT('[{"Reason":', "_ShortCaseReasonType" ,',"Value":"',CASE WHEN pd."DocumentNumber" IS NOT NULL THEN CONCAT(pd."DocumentNumber", '#', pd."DocumentDate") ELSE CONCAT(gd."DocumentNumber", '||', gd."DocumentDate") END,'"}]') 
					 				ELSE REPLACE(pdrm."Reason",'[',CONCAT('[{"Reason":',
														"_ShortCaseReasonType"
													,',"Value":"',CASE WHEN pd."DocumentNumber" IS NOT NULL THEN CONCAT(pd."DocumentNumber", '#', pd."DocumentDate") ELSE CONCAT(gd."DocumentNumber", '||', gd."DocumentDate") END,'"},')) END, 
			"ReasonType" = "_ShortCaseReasonType"::BIGINT  + COALESCE(pdrm."ReasonType", 0),
			"CancelledInvoiceId" = t_pdrm."PrId"
	FROM
		"TempShortCaseMatchedData" t_pdrm
	INNER JOIN Oregular."Gstr2bDocumentRecoMapper" pdrm ON t_pdrm."GstnId" = pdrm."GstnId"
	LEFT JOIN "TempGstnOnlyData" gd ON  t_pdrm."PrId" = gd."Id" AND t_pdrm."Source" = 'Gstn'
	LEFT JOIN "TempPrOnlyData" pd ON  t_pdrm."PrId" = pd."Id" AND t_pdrm."Source" = 'Pr'
	WHERE
		pdr."Id" = pdrm."Id"
		AND COALESCE(pdr."Reason",'[]') NOT LIKE '%' || "_ShortCaseReasonType" || '%';
		
	RAISE NOTICE 'Short Case Step 18 %', clock_timestamp()::timestamp without time zone;		
	
END;
$function$
;
DROP FUNCTION IF EXISTS audit."FilterPurchaseReconciliation";

CREATE OR REPLACE FUNCTION audit."FilterPurchaseReconciliation"("_Ids" bigint[], "_SubscriberId" integer, "_EntityIds" integer[], "_UserIds" text, "_SearchKeywords" text[], "_RequestTypes" text, "_Source" smallint, "_FromDate" timestamp without time zone, "_ToDate" timestamp without time zone, "_Start" integer, "_Size" integer, "_ReconciliationTypeGstr2a" smallint, "_ReconciliationTypeIcegate" smallint, "_ReconciliationTypeGstr2b" smallint, "_DocumentTypeBoe" smallint, "_UserActionTypeSystemReconciliation" smallint DEFAULT (33)::smallint, "_UserActionTypeManualReconciliation" smallint DEFAULT (25)::smallint, "_UserActionTypeLinkDocuments" smallint DEFAULT (26)::smallint, "_UserActionTypeChangeReconciliationSection" smallint DEFAULT (28)::smallint)
 RETURNS TABLE("Id" bigint, "ItemCount" integer, "TotalRecord" integer)
 LANGUAGE plpgsql
AS $function$
/*-----------------------------------------------------------------------
* 	Procedure Name	: audit."FilterPurchaseReconciliation"
*	Comments		: 2024-03-22 | Shambhu Das | This procedure is used to Filter 2A, 2b & Icegate reco audit trail teport.
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: SELECT * FROM audit."FilterPurchaseReconciliation"
													( 													
														null::bigint[], 
														164::integer, 
														null::integer[], 
														null::text, 
														ARRAY['33']::text[], 
														null::text, 
														8:: smallint,
														null::timestamp without time zone, 
														null::timestamp without time zone, 
														0::integer, 
														20::integer,
														2:: SMALLINT,
														5:: SMALLINT,
														8:: SMALLINT,
														4:: SMALLINT,
														33:: SMALLINT,
														25:: SMALLINT,
														27 :: SMALLINT
													);

DROP FUNCTION audit."FilterPurchaseReconciliation";
--------------------------------------------------------------------------------------------------------------------------------------*/

DECLARE 
	"_TotalRecord" integer DEFAULT 0;
	"_SQL" text;
	"_FilterSQL" text;
	
BEGIN
	
	DROP TABLE IF EXISTS "TempEntities","TempIds","TempSearchKeywords","TempDocumentIds";
	
	CREATE TEMP TABLE "TempEntities" AS
	SELECT * FROM UNNEST("_EntityIds") AS "EntityIds";
	
	CREATE TEMP TABLE "TempIds" AS
	SELECT * FROM UNNEST("_Ids") AS "Ids";
	
	CREATE TEMP TABLE "TempSearchKeywords" AS
	SELECT * FROM UNNEST("_SearchKeywords") AS "SearchKeywords";

	"_FilterSQL" := CONCAT(N'
						   	DROP TABLE IF EXISTS "TempDocumentIds";
						   	CREATE TEMP TABLE "TempDocumentIds" AS
							SELECT
						   		d."AuditId"
						   	FROM ',
						   	CASE 
								WHEN "_Source" = "_ReconciliationTypeGstr2b"
								THEN 'audit."oregular.Gstr2bDocumentRecoMapper" AS d '
									ELSE 'audit."oregular.Gstr2aDocumentRecoMapper" AS d '
							END,'						   		
							WHERE
								d."AuditUserAction" > 0 
								AND d."SubscriberId" = ', "_SubscriberId",' 
								AND (d."AuditAction" <> ''D'' OR d."AuditUserAction" IN (', "_UserActionTypeSystemReconciliation",',', "_UserActionTypeChangeReconciliationSection", ',', "_UserActionTypeManualReconciliation",'))',
								CASE 
									WHEN "_Source" = "_ReconciliationTypeIcegate"
									THEN ' AND COALESCE(d."PrDocumentType", d."CpDocumentType") = ' || "_DocumentTypeBoe" || ''
										ELSE ' '
								END,						   
								CASE
									WHEN EXISTS (SELECT "EntityIds" FROM "TempEntities")
									THEN ' AND COALESCE(d."PrEntityId", d."CpEntityId") IN (SELECT "EntityIds" FROM "TempEntities")'
									ELSE ''
								END, 
						 		CASE
									WHEN EXISTS (SELECT "Ids" FROM "TempIds")
									THEN ' AND d."AuditId" IN (SELECT "Ids" FROM "TempIds")'
									ELSE ''
								END,
								CASE 
									WHEN "_RequestTypes" IS NULL
									THEN ''
									ELSE ' AND d."AuditUserAction" IN ('|| "_RequestTypes" ||')'
								END,
								CASE 
									WHEN "_UserIds" IS NULL
									THEN ''
									ELSE ' AND d."AuditUserId" IN ('|| "_UserIds" ||')'
								END,
								CASE 
									WHEN "_FromDate" IS NOT NULL
									THEN ' AND d."AuditActionStampTx" BETWEEN '''|| "_FromDate" || ''' AND ''' || "_ToDate" ||''''
									ELSE ''
								END,
								CASE 
									WHEN EXISTS (SELECT "SearchKeywords" From "TempSearchKeywords")
									THEN 
									 ' AND (
						   					EXISTS (SELECT 
														1 
													FROM 
														"TempSearchKeywords" te
													WHERE LOWER(coalesce(d."PrGstin", d."CpGstin")) LIKE ''%'' || LOWER(te."SearchKeywords") || ''%'')
											OR
											EXISTS (SELECT 
														1 
													FROM 
														"TempSearchKeywords" te
													WHERE LOWER(coalesce(d."PrDocumentNumber",d."CpDocumentNumber")) LIKE ''%'' || LOWER(te."SearchKeywords") || ''%'')
						  				)' 
								END);
	
	EXECUTE "_FilterSQL";

	IF "_Start" = 0
	THEN	
		SELECT
			COUNT(*) AS "TotalRecord"
		INTO
			"_TotalRecord"
		FROM
			"TempDocumentIds" AS d;		
	END IF;

	RETURN QUERY
	SELECT 
		d."AuditId" AS "Id",
		1 As "ItemCount",
		"_TotalRecord" AS "TotalRecord"
	FROM 
		"TempDocumentIds" AS d
	ORDER BY
		d."AuditId" DESC 
	LIMIT "_Size" OFFSET  "_Start";
		
END;
$function$
;
DROP FUNCTION IF EXISTS audit."InsertDataTrails";

CREATE OR REPLACE FUNCTION audit."InsertDataTrails"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: audit."InsertDataTrails"
*	Comments		: 19-03-2024 | Shambhu Das | Insert data in audit tables.
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: 
						SELECT * FROM audit."InsertDataTrails"();
--------------------------------------------------------------------------------------------------------------------------------------*/
DECLARE
	"_AuditRequestId" uuid;
	"_AuditUserId" integer;
	"_AuditUserAction" smallint;
	"_AuditIpAddress" text;
	"_IsEnabled" boolean;
	"_IsSkipActionTrail" boolean;
		
BEGIN
	
	BEGIN
        SELECT
			"RequestId",
			"UserId",
			"UserAction",
			"RequestIpAddress",
			"IsEnabled",
			"IsSkipActionTrail"
		INTO
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",
			"_IsEnabled",
			"_IsSkipActionTrail"
		FROM
			"TempCurrentAppUser";		
    EXCEPTION WHEN undefined_table THEN
			"_AuditRequestId" := NULL;
			"_AuditUserId" := -10000;
			"_AuditUserAction" := -1;
			"_AuditIpAddress" := 'unknown_user';
    END;
	
	IF "_IsEnabled" = false OR "_IsSkipActionTrail" = true
	THEN
		RETURN NULL;
	END IF;
	
    IF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentContacts')
    THEN
		INSERT INTO audit."einvoice.DocumentContacts"
        (
			"AuditSessionUser",
			"AuditActionStampTx",
			"AuditActionStampStm",
			"AuditActionStampClk",
			"AuditTransactionId",
			"AuditClientQuery",
			"AuditAction",
			"AuditRequestId",
			"AuditUserId",
			"AuditUserAction",
			"AuditIpAddress",
			"Id",
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
			"Stamp",
			"ModifiedStamp",
			"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."Id",
			o."DocumentId",
			o."Gstin",
			o."LegalName",
			o."TradeName",
			o."VendorCode",
			o."AddressLine1",
			o."AddressLine2",
			o."City",
			o."StateCode",
			o."Pincode",
			o."Phone",
			o."Email",
			o."Type",
			o."Stamp",
			o."ModifiedStamp",
			o."RequestId"
        FROM
            old_table o;

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentCustoms')
    THEN
        INSERT INTO audit."einvoice.DocumentCustoms"
        (
			"AuditSessionUser",
			"AuditActionStampTx",
			"AuditActionStampStm",
			"AuditActionStampClk",
			"AuditTransactionId",
			"AuditClientQuery",
			"AuditAction",
			"AuditRequestId",
			"AuditUserId",
			"AuditUserAction",
			"AuditIpAddress",			
			"Id",
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
			"Stamp",
			"ModifiedStamp",
			"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."Id",
			o."DocumentId",
			o."Custom1",
			o."Custom2",
			o."Custom3",
			o."Custom4",
			o."Custom5",
			o."Custom6",
			o."Custom7",
			o."Custom8",
			o."Custom9",
			o."Custom10",
			o."Stamp",
			o."ModifiedStamp",
			o."RequestId"	
        FROM
            old_table o;
            
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentItems')
    THEN
        INSERT INTO audit."einvoice.DocumentItems"
        (
			"AuditSessionUser",
			"AuditActionStampTx",
			"AuditActionStampStm",
			"AuditActionStampClk",
			"AuditTransactionId",
			"AuditClientQuery",
			"AuditAction",
			"AuditRequestId",
			"AuditUserId",
			"AuditUserAction",
			"AuditIpAddress",			
			"Id",
			"DocumentId",
			"SerialNumber",
			"IsService",
			"Hsn",
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
			"Stamp",
			"ModifiedStamp",
			"ProductCode",
			"TaxType",
			"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."Id",
			o."DocumentId",
			o."SerialNumber",
			o."IsService",
			o."Hsn",
			o."Name",
			o."Description",
			o."Barcode",
			o."Uqc",
			o."Quantity",
			o."FreeQuantity",
			o."Rate",
			o."CessRate",
			o."StateCessRate",
			o."CessNonAdvaloremRate",
			o."PricePerQuantity",
			o."DiscountAmount",
			o."GrossAmount",
			o."OtherCharges",
			o."TaxableValue",
			o."PreTaxValue",
			o."IgstAmount",
			o."CgstAmount",
			o."SgstAmount",
			o."CessAmount",
			o."StateCessAmount",
			o."StateCessNonAdvaloremAmount",
			o."CessNonAdvaloremAmount",
			o."OrderLineReference",
			o."OriginCountry",
			o."ItemSerialNumber",
			o."ItemTotal",
			o."ItemAttributeDetails",
			o."BatchNameNumber",
			o."BatchExpiryDate",
			o."WarrantyDate",
			o."CustomItem1",
			o."CustomItem2",
			o."CustomItem3",
			o."CustomItem4",
			o."CustomItem5",
			o."CustomItem6",
			o."CustomItem7",
			o."CustomItem8",
			o."CustomItem9",
			o."CustomItem10",
			o."Stamp",
			o."ModifiedStamp",
			o."ProductCode",
			o."TaxType",
			o."RequestId"
        FROM
            old_table o;
            
            
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentPayments')
    THEN
         INSERT INTO audit."einvoice.DocumentPayments"
         (
			"AuditSessionUser",
			"AuditActionStampTx",
			"AuditActionStampStm",
			"AuditActionStampClk",
			"AuditTransactionId",
			"AuditClientQuery",
			"AuditAction",
			"AuditRequestId",
			"AuditUserId",
			"AuditUserAction",
			"AuditIpAddress",			 
			"Id",
			"DocumentId",
			"PaymentMode",
			"AdvancePaidAmount",
			"PaymentTerms",
			"PaymentInstruction",
			"PayeeName",
			"PayeeAccountNumber",
			"PaymentAmountDue",
			"Ifsc",
			"CreditTransfer",
			"DirectDebit",
			"CreditDays",
			"PayeeMerchantCode",
			"TransactionId",
			"TransactionReferenceId",
			"TransactionNote",
			"PaymentMinimumAmount",
			"TransactionReferenceUrl",
			"PaymentDate",
			"UpiId",
			"ResponseTransactionId",
			"ResponseCode",
			"ResponseApprovalRefNo",
			"ResponseStatus",
			"Stamp",
			"ModifiedStamp",
			"UpiResponse",
			"PaymentDueDate",
			"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."Id",
			o."DocumentId",
			o."PaymentMode",
			o."AdvancePaidAmount",
			o."PaymentTerms",
			o."PaymentInstruction",
			o."PayeeName",
			o."PayeeAccountNumber",
			o."PaymentAmountDue",
			o."Ifsc",
			o."CreditTransfer",
			o."DirectDebit",
			o."CreditDays",
			o."PayeeMerchantCode",
			o."TransactionId",
			o."TransactionReferenceId",
			o."TransactionNote",
			o."PaymentMinimumAmount",
			o."TransactionReferenceUrl",
			o."PaymentDate",
			o."UpiId",
			o."ResponseTransactionId",
			o."ResponseCode",
			o."ResponseApprovalRefNo",
			o."ResponseStatus",
			o."Stamp",
			o."ModifiedStamp",
			o."UpiResponse",
			o."PaymentDueDate",
			o."RequestId"
        FROM
            old_table o;                        
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentReferences')
        THEN
            INSERT INTO audit."einvoice.DocumentReferences"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"DocumentId",
				"DocumentNumber",
				"DocumentDate",
				"Stamp",
				"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."Id",
			o."DocumentId",
			o."DocumentNumber",
			o."DocumentDate",
			o."Stamp",
			o."RequestId"	
        FROM
            old_table o;

	ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentSignedDetails')
        THEN
            INSERT INTO audit."einvoice.DocumentSignedDetails"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",			
				"DocumentId",
				"SignedQrCode",
				"Stamp",
				"SignedInvoice",
				"IsCompress",
				"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."DocumentId",
			o."SignedQrCode",
			o."Stamp",
			o."SignedInvoice",
			o."IsCompress",
			o."RequestId"
        FROM
            old_table o;
                        

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.DocumentStatus')
        THEN
            INSERT INTO audit."einvoice.DocumentStatus"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				"DocumentId",
				"Irn",
				"AckNumber",
				"AckDate",
				"CancelDate",
				"CancelReason",
				"CancelRemark",
				"GeneratedDate",
				"IsPushed",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"Errors",
				"BackgroundTaskId",
				"Stamp",
				"ModifiedStamp",
				"Status",
				"Provider",
				"RequestId",
				"UserAction"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",
			o."DocumentId",
			o."Irn",
			o."AckNumber",
			o."AckDate",
			o."CancelDate",
			o."CancelReason",
			o."CancelRemark",
			o."GeneratedDate",
			o."IsPushed",
			o."PushStatus",
			o."PushDate",
			o."PushByUserId",
			o."Errors",
			o."BackgroundTaskId",
			o."Stamp",
			o."ModifiedStamp",
			o."Status",
			o."Provider",
			o."RequestId",
			o."UserAction"
        FROM
            old_table o;                       

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.Documents')
        THEN
            INSERT INTO audit."einvoice.Documents"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SubscriberId",
				"EntityId",
				"ParentEntityId",
				"UserId",
				"StatisticId",
				"Purpose",
				"SupplyType",
				"Type",
				"TransactionType",
				"TransactionTypeDescription",
				"DocumentNumber",
				"DocumentDate",
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
				"Pos",
				"DocumentValue",
				"DocumentValueInForeignCurrency",
				"DocumentValueInRoundOffAmount",
				"ReverseCharge",
				"ClaimRefund",
				"ECommerceGstin",
				"TransporterId",
				"TransporterName",
				"VehicleType",
				"ToEmailAddresses",
				"ToMobileNumbers",
				"TotalTaxableValue",
				"TotalTaxAmount",
				"ReturnPeriod",
				"DocumentFinancialYear",
				"FinancialYear",
				"SourceType",
				"Stamp",
				"ModifiedStamp",
				"GroupId",
				"SeriesCode",
				"TaxpayerType",
				"ExportDuty",
				"UnderIgstAct",
				"DocumentDiscount",
				"DocumentOtherCharges",
				"LegacyId",
				"SectionType",
				"ReferenceId",
				"AttachmentStreamId",
				"DocumentReturnPeriod",
				"RequestId"
        )
        SELECT
            SESSION_USER::text AS "AuditSessionUser",
            CURRENT_TIMESTAMP AS "AuditActionStampTx",
            STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
            CLOCK_TIMESTAMP() AS "AuditActionStampClk",
            TXID_CURRENT() AS "AuditTransactionId",
            NULL AS "ClientQuery",
            SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",			
			o."Id",
			o."SubscriberId",
			o."EntityId",
			o."ParentEntityId",
			o."UserId",
			o."StatisticId",
			o."Purpose",
			o."SupplyType",
			o."Type",
			o."TransactionType",
			o."TransactionTypeDescription",
			o."DocumentNumber",
			o."DocumentDate",
			o."TransactionMode",
			o."RefDocumentRemarks",
			o."RefDocumentPeriodStartDate",
			o."RefDocumentPeriodEndDate",
			o."RefPrecedingDocumentDetails",
			o."RefContractDetails",
			o."AdditionalSupportingDocumentDetails",
			o."BillNumber",
			o."BillDate",
			o."PortCode",
			o."DocumentCurrencyCode",
			o."DestinationCountry",
			o."Pos",
			o."DocumentValue",
			o."DocumentValueInForeignCurrency",
			o."DocumentValueInRoundOffAmount",
			o."ReverseCharge",
			o."ClaimRefund",
			o."ECommerceGstin",
			o."TransporterId",
			o."TransporterName",
			o."VehicleType",
			o."ToEmailAddresses",
			o."ToMobileNumbers",
			o."TotalTaxableValue",
			o."TotalTaxAmount",
			o."ReturnPeriod",
			o."DocumentFinancialYear",
			o."FinancialYear",
			o."SourceType",
			o."Stamp",
			o."ModifiedStamp",
			o."GroupId",
			o."SeriesCode",
			o."TaxpayerType",
			o."ExportDuty",
			o."UnderIgstAct",
			o."DocumentDiscount",
			o."DocumentOtherCharges",
			o."LegacyId",
			o."SectionType",
			o."ReferenceId",
			o."AttachmentStreamId",
			o."DocumentReturnPeriod",
			o."RequestId"
        FROM
            old_table o;
                        

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'einvoice.QrCodeDetails')
        THEN
            INSERT INTO audit."einvoice.QrCodeDetails"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SubscriberId",
				"EntityId",
				"UserId",
				"StatisticId",
				"Irn",
				"IrnGenerationDate",
				"DocumentNumber",
				"DocumentDate",
				"Gstin",
				"TradeName",
				"DocumentValue",
				"NoOfItems",
				"Hsn",
				"DocumentType",
				"ReturnPeriod",
				"FinancialYear",
				"Stamp",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SubscriberId",
				"EntityId",
				"UserId",
				"StatisticId",
				"Irn",
				"IrnGenerationDate",
				"DocumentNumber",
				"DocumentDate",
				"Gstin",
				"TradeName",
				"DocumentValue",
				"NoOfItems",
				"Hsn",
				"DocumentType",
				"ReturnPeriod",
				"FinancialYear",
				"Stamp",
				"RequestId"
            FROM
                old_table o;
                        

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'ewaybill.ConsolidatedDocumentItems')
        THEN
            INSERT INTO audit."ewaybill.ConsolidatedDocumentItems"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"ConsolidatedDocumentId",
				"EwayBillNumber",
				"Stamp",
				"ModifiedStamp",
				"DocumentId",
				"RequestId"
        )
        SELECT
			SESSION_USER::text AS "AuditSessionUser",
			CURRENT_TIMESTAMP AS "AuditActionStampTx",
			STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
			CLOCK_TIMESTAMP() AS "AuditActionStampClk",
			TXID_CURRENT() AS "AuditTransactionId",
			NULL AS "ClientQuery",
			SUBSTRING(TG_OP,1,1) AS "AuditAction",
			"_AuditRequestId",
			"_AuditUserId",
			"_AuditUserAction",
			"_AuditIpAddress",				
			o."Id",
			o."ConsolidatedDocumentId",
			o."EwayBillNumber",
			o."Stamp",
			o."ModifiedStamp",
			o."DocumentId",
			o."RequestId"
        FROM
            old_table o;
                        

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'ewaybill.ConsolidatedDocumentStatus')
        THEN
            INSERT INTO audit."ewaybill.ConsolidatedDocumentStatus"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"ConsolidatedDocumentId",
				"ConsolidatedEwayBillNumber",
				"GeneratedDate",
				"IsPushed",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"Status",
				"Errors",
				"BackgroundTaskId",
				"Stamp",
				"ModifiedStamp",
				"RequestId",
				"BillingDate",
				"UserAction"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"ConsolidatedDocumentId",
				"ConsolidatedEwayBillNumber",
				"GeneratedDate",
				"IsPushed",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"Status",
				"Errors",
				"BackgroundTaskId",
				"Stamp",
				"ModifiedStamp",
				"RequestId",
				"BillingDate",
				"UserAction"	
            FROM
                old_table o;
                       

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'ewaybill.ConsolidatedDocuments')
        THEN
            INSERT INTO audit."ewaybill.ConsolidatedDocuments"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SubscriberId",
				"EntityId",
				"ParentEntityId",
				"UserId",
				"StatisticId",
				"TransportMode",
				"FromState",
				"TransportDocumentNumber",
				"TransportDocumentDate",
				"VehicleNumber",
				"Reason",
				"Remarks",
				"ToEmailAddresses",
				"ToMobileNumbers",
				"ReturnPeriod",
				"FinancialYear",
				"SourceType",
				"Stamp",
				"ModifiedStamp",
				"GroupId",
				"FromCity",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				o."Id",
				o."SubscriberId",
				o."EntityId",
				o."ParentEntityId",
				o."UserId",
				o."StatisticId",
				o."TransportMode",
				o."FromState",
				o."TransportDocumentNumber",
				o."TransportDocumentDate",
				o."VehicleNumber",
				o."Reason",
				o."Remarks",
				o."ToEmailAddresses",
				o."ToMobileNumbers",
				o."ReturnPeriod",
				o."FinancialYear",
				o."SourceType",
				o."Stamp",
				o."ModifiedStamp",
				o."GroupId",
				o."FromCity",
				o."RequestId"
            FROM
                old_table o;
                        

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'ewaybill.DocumentStatus')
        THEN
            INSERT INTO audit."ewaybill.DocumentStatus"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				"DocumentId",
				"TransportDateTime",
				"Irn",
				"EwayBillNumber",
				"ValidUpto",
				"ExtendedTimes",
				"GeneratedDate",
				"CancelledDate",
				"RejectedDate",
				"DeliveredDate",
				"Reason",
				"Remarks",
				"IsPushed",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"Errors",
				"BackgroundTaskId",
				"Stamp",
				"ModifiedStamp",
				"TransporterUpdatedDate",
				"IsMultiVehicleMovementInitiated",
				"Status",
				"LastSyncDate",
				"Distance",
				"GenerationMode",
				"BillingDate",
				"RequestId",
				"UserAction"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",
				o."DocumentId",
				o."TransportDateTime",
				o."Irn",
				o."EwayBillNumber",
				o."ValidUpto",
				o."ExtendedTimes",
				o."GeneratedDate",
				o."CancelledDate",
				o."RejectedDate",
				o."DeliveredDate",
				o."Reason",
				o."Remarks",
				o."IsPushed",
				o."PushStatus",
				o."PushDate",
				o."PushByUserId",
				o."Errors",
				o."BackgroundTaskId",
				o."Stamp",
				o."ModifiedStamp",
				o."TransporterUpdatedDate",
				o."IsMultiVehicleMovementInitiated",
				o."Status",
				o."LastSyncDate",
				o."Distance",
				o."GenerationMode",
				o."BillingDate",
				o."RequestId",
				o."UserAction"
            FROM
                old_table o;
                        

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'ewaybill.VehicleDetails')
        THEN
            INSERT INTO audit."ewaybill.VehicleDetails"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"DocumentId",
				"VehicleDetailId",
				"VehicleMovementId",
				"TransportMode",
				"TransportDocumentNumber",
				"TransportDocumentDate",
				"VehicleNumber",
				"Type",
				"FromState",
				"FromCity",
				"FromPinCode",
				"Quantity",
				"Reason",
				"Remarks",
				"ConsolidatedEwayBillNumber",
				"GroupNumber",
				"RemainingDistance",
				"ConsignmentStatus",
				"UpdatedByGSTIN",
				"TransitType",
				"TransitAddressLine1",
				"TransitAddressLine2",
				"TransitAddressLine3",
				"IsLatest",
				"PushStatus",
				"PushDate",
				"Errors",
				"BackgroundTaskId",
				"Stamp",
				"ModifiedStamp",
				"LegacyId",
				"UpdationMode",
				"DisplayNumber",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				o."Id",
				o."DocumentId",
				o."VehicleDetailId",
				o."VehicleMovementId",
				o."TransportMode",
				o."TransportDocumentNumber",
				o."TransportDocumentDate",
				o."VehicleNumber",
				o."Type",
				o."FromState",
				o."FromCity",
				o."FromPinCode",
				o."Quantity",
				o."Reason",
				o."Remarks",
				o."ConsolidatedEwayBillNumber",
				o."GroupNumber",
				o."RemainingDistance",
				o."ConsignmentStatus",
				o."UpdatedByGSTIN",
				o."TransitType",
				o."TransitAddressLine1",
				o."TransitAddressLine2",
				o."TransitAddressLine3",
				o."IsLatest",
				o."PushStatus",
				o."PushDate",
				o."Errors",
				o."BackgroundTaskId",
				o."Stamp",
				o."ModifiedStamp",
				o."LegacyId",
				o."UpdationMode",
				o."DisplayNumber",
				o."RequestId"	
            FROM
                old_table o;
             

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'ewaybill.VehicleMovements')
        THEN
            INSERT INTO audit."ewaybill.VehicleMovements"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"DocumentId",
				"Mode",
				"FromState",
				"FromCity",
				"ToState",
				"ToCity",
				"Quantity",
				"Uqc",
				"Reason",
				"Remarks",
				"GroupNumber",
				"IsLatest",
				"PushStatus",
				"Errors",
				"PushDate",
				"Stamp",
				"ModifiedStamp",
				"BackgroundTaskId",
				"LegacyId",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"DocumentId",
				"Mode",
				"FromState",
				"FromCity",
				"ToState",
				"ToCity",
				"Quantity",
				"Uqc",
				"Reason",
				"Remarks",
				"GroupNumber",
				"IsLatest",
				"PushStatus",
				"Errors",
				"PushDate",
				"Stamp",
				"ModifiedStamp",
				"BackgroundTaskId",
				"LegacyId",
				"RequestId"
            FROM
                old_table o;
       
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentContacts')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentContacts"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
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
				"Stamp",
				"ModifiedStamp",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
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
				"Stamp",
				"ModifiedStamp",
				"RequestId"
            FROM
                old_table o;
				
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentCustoms')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentCustoms"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
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
				"Stamp",
				"ModifiedStamp"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
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
				"Stamp",
				"ModifiedStamp"
            FROM
                old_table o;
				
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentItems')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentItems"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
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
				"ItcEligibility",
				"ItcIgstAmount",
				"ItcCgstAmount",
				"ItcSgstAmount",
				"ItcCessAmount",
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
				"Stamp",
				"ModifiedStamp",
				"ComputationStatus",
				"TdsRate",
				"TdsAmount",
				"GstActOrRuleSection",
				"IsTdsApplicable",
				"TdsTaxSection",
				"IsTdsThresholdCrossed",
				"IsLdcApplied",
				"LdcCertificateId",
				"TdsErrors",
				"TdsConfidenceScore",
				"TdsRulePath",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
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
				"ItcEligibility",
				"ItcIgstAmount",
				"ItcCgstAmount",
				"ItcSgstAmount",
				"ItcCessAmount",
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
				"Stamp",
				"ModifiedStamp",
				"ComputationStatus",
				"TdsRate",
				"TdsAmount",
				"GstActOrRuleSection",
				"IsTdsApplicable",
				"TdsTaxSection",
				"IsTdsThresholdCrossed",
				"IsLdcApplied",
				"LdcCertificateId",
				"TdsErrors",
				"TdsConfidenceScore",
				"TdsRulePath",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentPayments')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentPayments"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
				"PaymentType",
				"PaymentMode",
				"PaymentAmount",
				"AdvancePaidAmount",
				"PaymentDate",
				"PaymentRemarks",
				"PaymentTerms",
				"PaymentInstruction",
				"PayeeName",
				"PayeeAccountNumber",
				"PaymentAmountDue",
				"Ifsc",
				"CreditTransfer",
				"DirectDebit",
				"CreditDays",
				"Stamp",
				"ModifiedStamp",
				"TransactionId",
				"TransactionNote",
				"UpiId",
				"PaymentDueDate",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
				"PaymentType",
				"PaymentMode",
				"PaymentAmount",
				"AdvancePaidAmount",
				"PaymentDate",
				"PaymentRemarks",
				"PaymentTerms",
				"PaymentInstruction",
				"PayeeName",
				"PayeeAccountNumber",
				"PaymentAmountDue",
				"Ifsc",
				"CreditTransfer",
				"DirectDebit",
				"CreditDays",
				"Stamp",
				"ModifiedStamp",
				"TransactionId",
				"TransactionNote",
				"UpiId",
				"PaymentDueDate",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentRateWiseItems')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentRateWiseItems"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
				"Rate",
				"TaxableValue",
				"IgstAmount",
				"CgstAmount",
				"SgstAmount",
				"CessAmount",
				"Stamp",
				"ModifiedStamp"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
				"Rate",
				"TaxableValue",
				"IgstAmount",
				"CgstAmount",
				"SgstAmount",
				"CessAmount",
				"Stamp",
				"ModifiedStamp"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentReferences')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentReferences"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
				"DocumentNumber",
				"DocumentDate",
				"Stamp",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"PurchaseDocumentId",
				"DocumentNumber",
				"DocumentDate",
				"Stamp",
				"RequestId"
				"ModifiedStamp"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentSignedDetails')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentSignedDetails"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"PurchaseDocumentId",
				"AckNumber",
				"SignedInvoice",
				"SignedQrCode",
				"IsCompress",
				"EwayBillNumber",
				"EwayBillDate",
				"EwayBillValidTill",
				"Remarks",
				"CancellationDate",
				"CancellationReason",
				"CancellationRemark",
				"Stamp",
				"ProviderType",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"PurchaseDocumentId",
				"AckNumber",
				"SignedInvoice",
				"SignedQrCode",
				"IsCompress",
				"EwayBillNumber",
				"EwayBillDate",
				"EwayBillValidTill",
				"Remarks",
				"CancellationDate",
				"CancellationReason",
				"CancellationRemark",
				"Stamp",
				"ProviderType",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentStatus')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentStatus"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				"PurchaseDocumentId",
				"Checksum",
				"IsGstr3bFiled",
				"Gstr2BReturnPeriod",
				"IsAvailableInGstr2B",
				"IsAvailableInGstr98a",
				"ItcAvailability",
				"ItcUnavailabilityReason",
				"ItcUnavailabilityReasonGstr98a",
				"LiabilityDischargeReturnPeriod",
				"ItcClaimReturnPeriod",
				"AutoDraftSource",
				"ReceivedDate",
				"Status",
				"CancelledDate",
				"Remarks",
				"Action",
				"ActionDate",
				"LastAction",
				"IsPushed",
				"UploadedDate",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"IsReconciled",
				"ReconciliationStatus",
				"Reason",
				"Errors",
				"LastSyncDate",
				"AmendedType",
				"OriginalReturnPeriod",
				"FilingDate",
				"FilingReturnPeriod",
				"Stamp",
				"ModifiedStamp",
				"BackgroundTaskId",
				"Gstr2bAction",
				"IsReconciledGstr2b",
				"Gstr2bActionDate",
				"BillingDate",
				"IsGlReconciled",
				"Gstr3bSection",
				"UserAction",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",
				"PurchaseDocumentId",
				"Checksum",
				"IsGstr3bFiled",
				"Gstr2BReturnPeriod",
				"IsAvailableInGstr2B",
				"IsAvailableInGstr98a",
				"ItcAvailability",
				"ItcUnavailabilityReason",
				"ItcUnavailabilityReasonGstr98a",
				"LiabilityDischargeReturnPeriod",
				"ItcClaimReturnPeriod",
				"AutoDraftSource",
				"ReceivedDate",
				"Status",
				"CancelledDate",
				"Remarks",
				"Action",
				"ActionDate",
				"LastAction",
				"IsPushed",
				"UploadedDate",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"IsReconciled",
				"ReconciliationStatus",
				"Reason",
				"Errors",
				"LastSyncDate",
				"AmendedType",
				"OriginalReturnPeriod",
				"FilingDate",
				"FilingReturnPeriod",
				"Stamp",
				"ModifiedStamp",
				"BackgroundTaskId",
				"Gstr2bAction",
				"IsReconciledGstr2b",
				"Gstr2bActionDate",
				"BillingDate",
				"IsGlReconciled",
				"Gstr3bSection",
				"UserAction",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocuments')
        THEN
            INSERT INTO audit."oregular.PurchaseDocuments"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SubscriberId",
				"ParentEntityId",
				"EntityId",
				"UserId",
				"StatisticId",
				"IsPreGstRegime",
				"Irn",
				"DocumentType",
				"TransactionType",
				"TransactionTypeDescription",
				"DocumentNumber",
				"DocumentDate",
				"CreditAvailedDate",
				"CreditReversalDate",
				"RefDocumentRemarks",
				"RefDocumentPeriodStartDate",
				"RefDocumentPeriodEndDate",
				"RefPrecedingDocumentDetails",
				"RefContractDetails",
				"AdditionalSupportingDocumentDetails",
				"PortCode",
				"DocumentCurrencyCode",
				"Pos",
				"DocumentValue",
				"DocumentValueInForeignCurrency",
				"DocumentValueInRoundOffAmount",
				"ReverseCharge",
				"ClaimRefund",
				"UnderIgstAct",
				"RefundEligibility",
				"OriginalDocumentNumber",
				"OriginalDocumentDate",
				"OriginalPortCode",
				"ToEmailAddresses",
				"ToMobileNumbers",
				"SectionType",
				"TotalTaxableValue",
				"TotalTaxAmount",
				"ReturnPeriod",
				"DocumentFinancialYear",
				"FinancialYear",
				"IsAmendment",
				"SourceType",
				"Stamp",
				"ModifiedStamp",
				"GroupId",
				"PnrOrUniqueNumber",
				"AvailProvisionalItc",
				"DifferentialPercentage",
				"SeriesCode",
				"TaxpayerType",
				"DocumentDiscount",
				"DocumentOtherCharges",
				"LegacyId",
				"IrnGenerationDate",
				"OriginalDocumentType",
				"TotalRateWiseTaxableValue",
				"TotalRateWiseTaxAmount",
				"DestinationCountry",
				"CombineDocumentType",
				"ReferenceId",
				"AttachmentStreamId",
				"RecoDocumentNumber",
				"DocumentReturnPeriod",
				"OriginalGstin",
				"OriginalReturnPeriod",
				"TransactionNature",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SubscriberId",
				"ParentEntityId",
				"EntityId",
				"UserId",
				"StatisticId",
				"IsPreGstRegime",
				"Irn",
				"DocumentType",
				"TransactionType",
				"TransactionTypeDescription",
				"DocumentNumber",
				"DocumentDate",
				"CreditAvailedDate",
				"CreditReversalDate",
				"RefDocumentRemarks",
				"RefDocumentPeriodStartDate",
				"RefDocumentPeriodEndDate",
				"RefPrecedingDocumentDetails",
				"RefContractDetails",
				"AdditionalSupportingDocumentDetails",
				"PortCode",
				"DocumentCurrencyCode",
				"Pos",
				"DocumentValue",
				"DocumentValueInForeignCurrency",
				"DocumentValueInRoundOffAmount",
				"ReverseCharge",
				"ClaimRefund",
				"UnderIgstAct",
				"RefundEligibility",
				"OriginalDocumentNumber",
				"OriginalDocumentDate",
				"OriginalPortCode",
				"ToEmailAddresses",
				"ToMobileNumbers",
				"SectionType",
				"TotalTaxableValue",
				"TotalTaxAmount",
				"ReturnPeriod",
				"DocumentFinancialYear",
				"FinancialYear",
				"IsAmendment",
				"SourceType",
				"Stamp",
				"ModifiedStamp",
				"GroupId",
				"PnrOrUniqueNumber",
				"AvailProvisionalItc",
				"DifferentialPercentage",
				"SeriesCode",
				"TaxpayerType",
				"DocumentDiscount",
				"DocumentOtherCharges",
				"LegacyId",
				"IrnGenerationDate",
				"OriginalDocumentType",
				"TotalRateWiseTaxableValue",
				"TotalRateWiseTaxAmount",
				"DestinationCountry",
				"CombineDocumentType",
				"ReferenceId",
				"AttachmentStreamId",
				"RecoDocumentNumber",
				"DocumentReturnPeriod",
				"OriginalGstin",
				"OriginalReturnPeriod",
				"TransactionNature",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentContacts')
        THEN
            INSERT INTO audit."oregular.SaleDocumentContacts"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SaleDocumentId",
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
				"Stamp",
				"ModifiedStamp",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SaleDocumentId",
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
				"Stamp",
				"ModifiedStamp",
				"RequestId"
            FROM
                old_table o;
				
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentCustoms')
        THEN
            INSERT INTO audit."oregular.SaleDocumentCustoms"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				
				"Id",
				"SaleDocumentId",
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
				"Stamp",
				"ModifiedStamp",
				"RequestId"				
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				
				o."Id",
				o."SaleDocumentId",
				o."Custom1",
				o."Custom2",
				o."Custom3",
				o."Custom4",
				o."Custom5",
				o."Custom6",
				o."Custom7",
				o."Custom8",
				o."Custom9",
				o."Custom10",
				o."Stamp",
				o."ModifiedStamp",
				o."RequestId"				
            FROM
                old_table o;
				
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentItems')
        THEN
            INSERT INTO audit."oregular.SaleDocumentItems"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"SerialNumber",
				"IsService",
				"Hsn",
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
				"Stamp",
				"ModifiedStamp",
				"ProductCode",
				"GstActOrRuleSection",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"SerialNumber",
				"IsService",
				"Hsn",
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
				"Stamp",
				"ModifiedStamp",
				"ProductCode",
				"GstActOrRuleSection",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentPayments')
        THEN
            INSERT INTO audit."oregular.SaleDocumentPayments"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"PaymentType",
				"PaymentMode",
				"PaymentAmount",
				"AdvancePaidAmount",
				"PaymentDate",
				"PaymentRemarks",
				"PaymentTerms",
				"PaymentInstruction",
				"PayeeName",
				"PayeeAccountNumber",
				"PaymentAmountDue",
				"Ifsc",
				"CreditTransfer",
				"DirectDebit",
				"CreditDays",
				"Stamp",
				"ModifiedStamp",
				"TransactionId",
				"TransactionNote",
				"UpiId",
				"PaymentDueDate",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"PaymentType",
				"PaymentMode",
				"PaymentAmount",
				"AdvancePaidAmount",
				"PaymentDate",
				"PaymentRemarks",
				"PaymentTerms",
				"PaymentInstruction",
				"PayeeName",
				"PayeeAccountNumber",
				"PaymentAmountDue",
				"Ifsc",
				"CreditTransfer",
				"DirectDebit",
				"CreditDays",
				"Stamp",
				"ModifiedStamp",
				"TransactionId",
				"TransactionNote",
				"UpiId",
				"PaymentDueDate",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentRateWiseItems')
        THEN
            INSERT INTO audit."oregular.SaleDocumentRateWiseItems"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"Rate",
				"TaxableValue",
				"IgstAmount",
				"CgstAmount",
				"SgstAmount",
				"CessAmount",
				"Stamp",
				"ModifiedStamp"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"Rate",
				"TaxableValue",
				"IgstAmount",
				"CgstAmount",
				"SgstAmount",
				"CessAmount",
				"Stamp",
				"ModifiedStamp"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentReferences')
        THEN
            INSERT INTO audit."oregular.SaleDocumentReferences"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"DocumentNumber",
				"DocumentDate",
				"Stamp",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SaleDocumentId",
				"DocumentNumber",
				"DocumentDate",
				"Stamp",
				"RequestId"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocumentStatus')
        THEN
            INSERT INTO audit."oregular.SaleDocumentStatus"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				"SaleDocumentId",
				"Checksum",
				"IsAutoDrafted",
				"AutoDraftSource",
				"LiabilityDischargeReturnPeriod",
				"Status",
				"CancelledDate",
				"Remarks",
				"Action",
				"LastAction",
				"IsPushed",
				"UploadedDate",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"IsReconciled",
				"ReconciliationSectionType",
				"ReconciliationStatus",
				"OriginalReturnPeriod",
				"Errors",
				"LastSyncDate",
				"Stamp",
				"ModifiedStamp",
				"BackgroundTaskId",
				"GstinError",
				"BillingDate",
				"RequestId",
				"IsGlReconciled",
				"Gstr3bSection",
				"UserAction"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",
				"SaleDocumentId",
				"Checksum",
				"IsAutoDrafted",
				"AutoDraftSource",
				"LiabilityDischargeReturnPeriod",
				"Status",
				"CancelledDate",
				"Remarks",
				"Action",
				"LastAction",
				"IsPushed",
				"UploadedDate",
				"PushStatus",
				"PushDate",
				"PushByUserId",
				"IsReconciled",
				"ReconciliationSectionType",
				"ReconciliationStatus",
				"OriginalReturnPeriod",
				"Errors",
				"LastSyncDate",
				"Stamp",
				"ModifiedStamp",
				"BackgroundTaskId",
				"GstinError",
				"BillingDate",
				"RequestId",
				"IsGlReconciled",
				"Gstr3bSection",
				"UserAction"
            FROM
                old_table o;		
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.SaleDocuments')
        THEN
            INSERT INTO audit."oregular.SaleDocuments"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",				
				"Id",
				"SubscriberId",
				"ParentEntityId",
				"EntityId",
				"UserId",
				"StatisticId",
				"Irn",
				"DocumentType",
				"TransactionType",
				"TransactionTypeDescription",
				"DocumentNumber",
				"DocumentDate",
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
				"Pos",
				"DocumentValue",
				"DocumentValueInForeignCurrency",
				"DocumentValueInRoundOffAmount",
				"DifferentialPercentage",
				"ReverseCharge",
				"ClaimRefund",
				"UnderIgstAct",
				"RefundEligibility",
				"ECommerceGstin",
				"OriginalDocumentNumber",
				"OriginalDocumentDate",
				"ToEmailAddresses",
				"ToMobileNumbers",
				"SectionType",
				"TotalTaxableValue",
				"TotalTaxAmount",
				"ReturnPeriod",
				"DocumentFinancialYear",
				"FinancialYear",
				"IsAmendment",
				"SourceType",
				"Stamp",
				"ModifiedStamp",
				"GroupId",
				"IsPreGstRegime",
				"TransactionNature",
				"SeriesCode",
				"TaxpayerType",
				"TDSGstin",
				"DocumentDiscount",
				"DocumentOtherCharges",
				"IrnGenerationDate",
				"TotalRateWiseTaxableValue",
				"TotalRateWiseTaxAmount",
				"CombineDocumentType",
				"ReferenceId",
				"AttachmentStreamId",
				"DocumentReturnPeriod",
				"OriginalGstin",
				"OriginalReturnPeriod",
				"RequestId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				"Id",
				"SubscriberId",
				"ParentEntityId",
				"EntityId",
				"UserId",
				"StatisticId",
				"Irn",
				"DocumentType",
				"TransactionType",
				"TransactionTypeDescription",
				"DocumentNumber",
				"DocumentDate",
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
				"Pos",
				"DocumentValue",
				"DocumentValueInForeignCurrency",
				"DocumentValueInRoundOffAmount",
				"DifferentialPercentage",
				"ReverseCharge",
				"ClaimRefund",
				"UnderIgstAct",
				"RefundEligibility",
				"ECommerceGstin",
				"OriginalDocumentNumber",
				"OriginalDocumentDate",
				"ToEmailAddresses",
				"ToMobileNumbers",
				"SectionType",
				"TotalTaxableValue",
				"TotalTaxAmount",
				"ReturnPeriod",
				"DocumentFinancialYear",
				"FinancialYear",
				"IsAmendment",
				"SourceType",
				"Stamp",
				"ModifiedStamp",
				"GroupId",
				"IsPreGstRegime",
				"TransactionNature",
				"SeriesCode",
				"TaxpayerType",
				"TDSGstin",
				"DocumentDiscount",
				"DocumentOtherCharges",
				"IrnGenerationDate",
				"TotalRateWiseTaxableValue",
				"TotalRateWiseTaxAmount",
				"CombineDocumentType",
				"ReferenceId",
				"AttachmentStreamId",
				"DocumentReturnPeriod",
				"OriginalGstin",
				"OriginalReturnPeriod",
				"RequestId"
            FROM
                old_table o;
    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.Gstr2aDocumentRecoMapper')
    	THEN
            INSERT INTO audit."oregular.Gstr2aDocumentRecoMapper"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				"Id",
				"DocumentFinancialYear",
				"PrId",
				"GstnId",
				"SectionType",
				"MappingType",
				"Reason",
				"ReasonType",
				"IsCrossHeadTax",
				"Stamp",
				"ModifiedStamp",
				"IsAvailableInGstr2b",
				"StatisticId",
				"ReconciledType",
				"SessionId",
				"PredictableMatchBy",
				"Source",
				"PrReturnPeriodDate",
				"GstnReturnPeriodDate",
				"PrEntityId",
				"CpEntityId",
				"PrDocumentNumber",
				"CpDocumentNumber",
				"PrDocumentDate",
				"CpDocumentDate",
				"PrGstin",
				"CpGstin",
				"PrDocumentType",
				"CpDocumentType",
				"PrPortCode",
				"CpPortCode",
				"SubscriberId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				o."Id",
				o."DocumentFinancialYear",
				o."PrId",
				o."GstnId",
				o."SectionType",
				o."MappingType",
				o."Reason",
				o."ReasonType",
				o."IsCrossHeadTax",
				o."Stamp",
				o."ModifiedStamp",
				o."IsAvailableInGstr2b",
				o."StatisticId",
				o."ReconciledType",
				o."SessionId",
				o."PredictableMatchBy",
				o."Source",
				o."PrReturnPeriodDate",
				o."GstnReturnPeriodDate",
				pd_pr."EntityId" AS "PrEntityId",
				pd_cp."EntityId" AS "CpEntityId",
				pd_pr."DocumentNumber" AS "PrDocumentNumber",
				pd_cp."DocumentNumber" AS "CpDocumentNumber",
				CAST(pd_pr."DocumentDate"::TEXT AS DATE) AS "PrDocumentDate",
				CAST(pd_cp."DocumentDate"::TEXT AS DATE) AS "CpDocumentDate",
				pd_pr."BillFromGstin" AS "PrGstin",
				pd_cp."BillFromGstin" AS "CpGstin",
				pd_pr."DocumentType" AS "PrDocumentType",
				pd_cp."DocumentType" AS "CpDocumentType",
				pd_pr."PortCode" AS "PrPortCode",
				pd_cp."PortCode" AS "CpPortCode",
				COALESCE(pd_pr."SubscriberId", pd_cp."SubscriberId")
            FROM
                old_table o
				LEFT JOIN oregular."PurchaseDocumentDW" pd_pr ON o."PrId" = pd_pr."Id"
				LEFT JOIN oregular."PurchaseDocumentDW" pd_cp ON o."GstnId" = pd_cp."Id";

    ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.Gstr2bDocumentRecoMapper')
    	THEN
            INSERT INTO audit."oregular.Gstr2bDocumentRecoMapper"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				"Id",
				"DocumentFinancialYear",
				"PrId",
				"GstnId",
				"SectionType",
				"MappingType",
				"Reason",
				"ReasonType",
				"IsCrossHeadTax",
				"SessionId",
				"Stamp",
				"ModifiedStamp",
				"ReconciledType",
				"PredictableMatchBy",
				"Gstr2BReturnPeriodDate",
				"PrReturnPeriodDate",
				"PrEntityId",
				"CpEntityId",
				"PrDocumentNumber",
				"CpDocumentNumber",
				"PrDocumentDate",
				"CpDocumentDate",
				"PrGstin",
				"CpGstin",
				"PrDocumentType",
				"CpDocumentType",
				"PrPortCode",
				"CpPortCode",
				"SubscriberId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",				
				o."Id",
				o."DocumentFinancialYear",
				o."PrId",
				o."GstnId",
				o."SectionType",
				o."MappingType",
				o."Reason",
				o."ReasonType",
				o."IsCrossHeadTax",
				o."SessionId",
				o."Stamp",
				o."ModifiedStamp",
				o."ReconciledType",
				o."PredictableMatchBy",
				o."Gstr2BReturnPeriodDate",
				o."PrReturnPeriodDate",
				pd_pr."EntityId" AS "PrEntityId",
				pd_cp."EntityId" AS "CpEntityId",
				pd_pr."DocumentNumber" AS "PrDocumentNumber",
				pd_cp."DocumentNumber" AS "CpDocumentNumber",
				CAST(pd_pr."DocumentDate"::TEXT AS DATE) AS "PrDocumentDate",
				CAST(pd_cp."DocumentDate"::TEXT AS DATE) AS "CpDocumentDate",
				pd_pr."BillFromGstin" AS "PrGstin",
				pd_cp."BillFromGstin" AS "CpGstin",
				pd_pr."DocumentType" AS "PrDocumentType",
				pd_cp."DocumentType" AS "CpDocumentType",
				pd_pr."PortCode" AS "PrPortCode",
				pd_cp."PortCode" AS "CpPortCode",
				COALESCE(pd_pr."SubscriberId", pd_cp."SubscriberId")
            FROM
                old_table o
				LEFT JOIN oregular."PurchaseDocumentDW" pd_pr ON o."PrId" = pd_pr."Id"
				LEFT JOIN oregular."PurchaseDocumentDW" pd_cp ON o."GstnId" = pd_cp."Id";
				
  		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'gl.ChartOfAccounts')
        THEN
            INSERT INTO audit."gl.ChartOfAccounts"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				
				"Id",
				"SubscriberId",
				"UserId",
				"StatisticId",
				"Code",
				"Name",
				"Type",
				"Group",
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
				"Stamp",
				"ModifiedStamp",
				"GroupId"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",
				
				o."Id",
				o."SubscriberId",
				o."UserId",
				o."StatisticId",
				o."Code",
				o."Name",
				o."Type",
				o."Group",
				o."Custom1",
				o."Custom2",
				o."Custom3",
				o."Custom4",
				o."Custom5",
				o."Custom6",
				o."Custom7",
				o."Custom8",
				o."Custom9",
				o."Custom10",
				o."Stamp",
				o."ModifiedStamp",
				o."GroupId"
            FROM
                old_table o;				

  		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'subscriber.HsnSac')
        THEN
            INSERT INTO audit."subscriber.HsnSac"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				
				"Id",
				"SubscriberId",
				"UserId",
				"StatisticId",
				"HsnSacCode",
				"ProductCode",
				"IsService",
				"Description",
				"Name",
				"Rate",
				"TaxType",
				"ReverseCharge",
				"EffectiveDate",
				"AmountSlab",
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
				"Stamp",
				"ModifiedStamp"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",
				
				o."Id",
				o."SubscriberId",
				o."UserId",
				o."StatisticId",
				o."HsnSacCode",
				o."ProductCode",
				o."IsService",
				o."Description",
				o."Name",
				o."Rate",
				o."TaxType",
				o."ReverseCharge",
				o."EffectiveDate",
				o."AmountSlab",
				o."Custom1",
				o."Custom2",
				o."Custom3",
				o."Custom4",
				o."Custom5",
				o."Custom6",
				o."Custom7",
				o."Custom8",
				o."Custom9",
				o."Custom10",
				o."Stamp",
				o."ModifiedStamp"
            FROM
                old_table o;	
				
		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'subscriber.Vendors')
        THEN
            INSERT INTO audit."subscriber.Vendors"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
			
				"Id",
				"SubscriberId",
				"UserId",
				"Gstin",
				"Code",
				"TradeName",
				"LegalName",
				"AddressLine1",
				"AddressLine2",
				"StateCode",
				"City",
				"Pincode",
				"EmailAddresses",
				"MobileNumbers",
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
				"Stamp",
				"ModifiedStamp",
				"StatisticId",
				"VerifiedDate",
				"Errors",
				"BackgroundTaskId",
				"VerificationStatus",
				"TaxpayerType",
				"TaxpayerStatus",
				"LastChangeDate",
				"LastChangeType",
				"IsPreferred",
				"Turnover",
				"TDSPercentage",
				"DistributorCode",
				"Description",
				"UsePrincipalAddress",
				"VendorType",
				"Gstr1GrcScore",
				"Gstr3bGrcScore",
				"LastGrcScoreSyncedDate",
				"EinvoiceEnablementStatus",
				"UseAdditionalAddress",
				"MsmeId",
				"Pan",
				"Tan",
				"GstinFilingFrequencyQtr",
				"GstinFilingFrequency",
				"MsmeType",
				"MsmeStatus",
				"MajorActivity",
				"PanValidationStatus",
				"PanITRStatus",
				"PanAadhaarSeedingStatus",
				"Cin",
				"NameOfEnterprise",
				"DateOfCommencement",
				"ReferenceId",
				"GroupId",
				"LdcDetails",
				"KycStatus",
				"Gstr1LastFiledTaxPeriod",
				"Gstr1LastFilingDate",
				"Gstr1SecondLastFiledTaxPeriod",
				"Gstr1SecondLastFilingDate",
				"Gstr3bLastFiledTaxPeriod",
				"Gstr3bLastFilingDate",
				"Gstr3bSecondLastFiledTaxPeriod",
				"Gstr3bSecondLastFilingDate",
				"Gstr1Periodicity",
				"Gstr3bPeriodicity",
				"SupplierGrcScore",
				"Remarks",
				"IsBlackListed"				

            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",
				
				o."Id",
				o."SubscriberId",
				o."UserId",
				o."Gstin",
				o."Code",
				o."TradeName",
				o."LegalName",
				o."AddressLine1",
				o."AddressLine2",
				o."StateCode",
				o."City",
				o."Pincode",
				o."EmailAddresses",
				o."MobileNumbers",
				o."Custom1",
				o."Custom2",
				o."Custom3",
				o."Custom4",
				o."Custom5",
				o."Custom6",
				o."Custom7",
				o."Custom8",
				o."Custom9",
				o."Custom10",
				o."Stamp",
				o."ModifiedStamp",
				o."StatisticId",
				o."VerifiedDate",
				o."Errors",
				o."BackgroundTaskId",
				o."VerificationStatus",
				o."TaxpayerType",
				o."TaxpayerStatus",
				o."LastChangeDate",
				o."LastChangeType",
				o."IsPreferred",
				o."Turnover",
				o."TDSPercentage",
				o."DistributorCode",
				o."Description",
				o."UsePrincipalAddress",
				o."VendorType",
				o."Gstr1GrcScore",
				o."Gstr3bGrcScore",
				o."LastGrcScoreSyncedDate",
				o."EinvoiceEnablementStatus",
				o."UseAdditionalAddress",
				o."MsmeId",
				o."Pan",
				o."Tan",
				o."GstinFilingFrequencyQtr",
				o."GstinFilingFrequency",
				o."MsmeType",
				o."MsmeStatus",
				o."MajorActivity",
				o."PanValidationStatus",
				o."PanITRStatus",
				o."PanAadhaarSeedingStatus",
				o."Cin",
				o."NameOfEnterprise",
				o."DateOfCommencement",
				o."ReferenceId",
				o."GroupId",
				o."LdcDetails",
				o."KycStatus",
				o."Gstr1LastFiledTaxPeriod",
				o."Gstr1LastFilingDate",
				o."Gstr1SecondLastFiledTaxPeriod",
				o."Gstr1SecondLastFilingDate",
				o."Gstr3bLastFiledTaxPeriod",
				o."Gstr3bLastFilingDate",
				o."Gstr3bSecondLastFiledTaxPeriod",
				o."Gstr3bSecondLastFilingDate",
				o."Gstr1Periodicity",
				o."Gstr3bPeriodicity",
				o."SupplierGrcScore",
				o."Remarks",
				o."IsBlackListed"
            FROM
                old_table o;
				
		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'subscriber.VendorLdcDetails')
        THEN
            INSERT INTO audit."subscriber.VendorLdcDetails"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				
				"Id",
				"VendorId",
				"DeductorTan",
				"TdsPercentage",
				"LdcStartDate",
				"LdcEndDate",
				"LdcTaxSection",
				"LdcTdsThresholdAmount",
				"LdcCertificateId",
				"Stamp"			
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",

				"Id",
				"VendorId",
				"DeductorTan",
				"TdsPercentage",
				"LdcStartDate",
				"LdcEndDate",
				"LdcTaxSection",
				"LdcTdsThresholdAmount",
				"LdcCertificateId",
				"Stamp"					

            FROM
                old_table o;				
		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'subscriber.NotificationReply')
        THEN
            INSERT INTO audit."subscriber.NotificationReply"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				
				"Id",
			    "SubscriberId",
			    "UserId",
			    "ActionRequired",
			    "Action",
			    "Internal",
			    "Status",
			    "Stamp",
			    "ModifiedStamp"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",

				"Id",
			    "SubscriberId",
			    "UserId",
			    "ActionRequired",
			    "Action",
			    "Internal",
			    "Status",
			    "Stamp",
			    "ModifiedStamp"
            FROM
                old_table o;
				
		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'oregular.PurchaseDocumentRecoManualMapper')
        THEN
            INSERT INTO audit."oregular.PurchaseDocumentRecoManualMapper"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				
				"Id",
				"SubscriberId",
				"ParentEntityId",
				"RPFinancialYear",
				"DocumentFinancialYear",
				"RecordName",
				"SectionType",
				"MappingType",
				"PrIds",
				"GstIds",
				"Reason",
				"Stamp",
				"ModifiedStamp",
				"IsAvailableInGstr2b",
				"StatisticId",
				"ReconciliationType"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",

				"Id",
				"SubscriberId",
				"ParentEntityId",
				"RPFinancialYear",
				"DocumentFinancialYear",
				"RecordName",
				"SectionType",
				"MappingType",
				"PrIds",
				"GstIds",
				"Reason",
				"Stamp",
				"ModifiedStamp",
				"IsAvailableInGstr2b",
				"StatisticId",
				"ReconciliationType"
            FROM
                old_table o;
		ELSEIF(CONCAT(TG_TABLE_SCHEMA,'.',TG_TABLE_NAME)::text = 'gst.Returns')
        THEN
            INSERT INTO audit."gst.Returns"
            (
				"AuditSessionUser",
				"AuditActionStampTx",
				"AuditActionStampStm",
				"AuditActionStampClk",
				"AuditTransactionId",
				"AuditClientQuery",
				"AuditAction",
				"AuditRequestId",
				"AuditUserId",
				"AuditUserAction",
				"AuditIpAddress",
				
				"Id",
				"SubscriberId",
				"EntityId",
				"UserId",
				"Type",
				"Action",
				"ReturnPeriod",
				"FinancialYear",
				"Data",
				"IpAddress",
				"GstPushStatus",
				"GstUploadedDate",
				"GstStamp",
				"Errors",
				"IsSyncFromGst",
				"Stamp",
				"ModifiedStamp",
				"AdditionalData",
				"TransactionId",
				"AckDate"
            )
            SELECT
				SESSION_USER::text AS "AuditSessionUser",
				CURRENT_TIMESTAMP AS "AuditActionStampTx",
				STATEMENT_TIMESTAMP() AS "AuditActionStampStm",
				CLOCK_TIMESTAMP() AS "AuditActionStampClk",
				TXID_CURRENT() AS "AuditTransactionId",
				NULL AS "ClientQuery",
				SUBSTRING(TG_OP,1,1) AS "AuditAction",
				"_AuditRequestId",
				"_AuditUserId",
				"_AuditUserAction",
				"_AuditIpAddress",

				"Id",
				"SubscriberId",
				"EntityId",
				"UserId",
				"Type",
				"Action",
				"ReturnPeriod",
				"FinancialYear",
				"Data",
				"IpAddress",
				"GstPushStatus",
				"GstUploadedDate",
				"GstStamp",
				"Errors",
				"IsSyncFromGst",
				"Stamp",
				"ModifiedStamp",
				"AdditionalData",
				"TransactionId",
				"AckDate"
            FROM
                old_table o;
	END IF;
	RETURN NULL;
END;
$function$
;
