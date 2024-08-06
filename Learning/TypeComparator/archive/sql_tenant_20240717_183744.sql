DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3bSection4A5];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [gst].[GenerateGstr3bSection4A5]
*	Comments		: 22/06/2020 | Amit Khanna | This procedure is used to Generate Data of Section 4.1.5 All Other ITC for Gstr3b
					: 02/07/2020 | Amit Khanna | Added Parameter ProvisionalItcPercentage,IsProvisionalItc,ReconciliationSectionTypesMatch,MisMatched,DueToTolerance.

*	Sample Execution : 

					EXEC [gst].[GenerateGstr3bSection4A5]
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3bSection4A5]
(
	@Gstr3bSectionOtherItc INT,
	@ReturnPeriod INT,
	@SourceTypeTaxPayer SMALLINT,
	@SourceTypeCounterPartyFiled SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@ItcAvailabilityTypeY SMALLINT,
	@ItcAvailabilityTypeN SMALLINT,
	@TaxPayerTypeISD SMALLINT,
	@BitTypeN BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempGstr3bSection4A5_Original
	(
		Section INT,
		IsGstr2bData BIT DEFAULT 0,
		TaxableValue DECIMAL(18,2),
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2)
	);

	CREATE TABLE #TempGstr3bUpdateStatus
	(	
		Id BIGINT
	);

	/*4.1.5 All Other ITC Original Data*/
	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(tpdc.IgstAmount) AS IgstAmount,
		SUM(tpdc.CgstAmount) AS CgstAmount,
		SUM(tpdc.SgstAmount) AS SgstAmount,
		SUM(tpdc.CessAmount) AS CessAmount
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
	WHERE 
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod 
		AND (tpdc.ItcClaimReturnPeriod IS NULL OR tpdc.ItcClaimReturnPeriod = @ReturnPeriod)
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);
			
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdc.Id
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod 
		AND (tpdc.ItcClaimReturnPeriod IS NULL OR tpdc.ItcClaimReturnPeriod = @ReturnPeriod)
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcIgstAmount),0) + COALESCE(ABS(tpdcpr.IgstAmount),0)) < ABS(tpdc.IgstAmount),(COALESCE(tpdcpr.ItcIgstAmount,0) + COALESCE(tpdcpr.IgstAmount,0)),tpdc.IgstAmount)) AS IgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCgstAmount),0) + COALESCE(ABS(tpdcpr.CgstAmount),0)) < ABS(tpdc.CgstAmount),(COALESCE(tpdcpr.ItcCgstAmount,0) + COALESCE(tpdcpr.CgstAmount,0)),tpdc.CgstAmount)) AS CgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcSgstAmount),0) + COALESCE(ABS(tpdcpr.SgstAmount),0)) < ABS(tpdc.SgstAmount),(COALESCE(tpdcpr.ItcSgstAmount,0) + COALESCE(tpdcpr.SgstAmount,0)),tpdc.SgstAmount)) AS SgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCessAmount),0) + COALESCE(ABS(tpdcpr.CessAmount),0)) < ABS(tpdc.CessAmount),(COALESCE(tpdcpr.ItcCessAmount,0) + COALESCE(tpdcpr.CessAmount,0)),tpdc.CessAmount)) AS CessAmount
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		LEFT JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE 
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.Gstr2BReturnPeriod <> @ReturnPeriod 
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);
			
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdc.Id
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		LEFT JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.Gstr2BReturnPeriod <> @ReturnPeriod 
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(COALESCE(tpdc.CpIgstAmount,0) + COALESCE(tpdc.PrevCpIgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdc.CpCgstAmount,0) + COALESCE(tpdc.PrevCpCgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdc.CpSgstAmount,0) + COALESCE(tpdc.PrevCpSgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdc.CpCessAmount,0) + COALESCE(tpdc.PrevCpCessAmount,0)) AS CessAmount
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND (tpdc.ItcClaimReturnPeriod IS NULL OR tpdc.ItcClaimReturnPeriod = @ReturnPeriod)
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpd.Id
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
		INNER JOIN #TempPurchaseDocumentIds tpd ON tpdc.MapperId = tpd.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND (tpdc.ItcClaimReturnPeriod IS NULL OR tpdc.ItcClaimReturnPeriod = @ReturnPeriod)
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);
				

	/*4.1.5 All Other ITC Amendment Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			(tpdac.PrTotalItcAmount IS NULL AND tpdac.PrTotalTaxAmount IS NULL)
			OR
			tpdac.PrTotalTaxAmount IS NOT NULL
			OR
			(
				tpdac.PrTotalItcAmount IS NOT NULL
				AND 
				(
					ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
					OR
					(ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) AND ABS(tpdac.PrTotalItcAmount) > ABS(tpdac.TotalTaxAmount_A))
				)
			)
		);
		
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			(tpdac.PrTotalItcAmount IS NULL AND tpdac.PrTotalTaxAmount IS NULL)
			OR
			tpdac.PrTotalTaxAmount IS NOT NULL
			OR
			(
				tpdac.PrTotalItcAmount IS NOT NULL
				AND 
				(
					ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
					OR
					(ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) AND ABS(tpdac.PrTotalItcAmount) > ABS(tpdac.TotalTaxAmount_A))
				)
			)
		);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0) + COALESCE(tpdac.PrItcIgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0) + COALESCE(tpdac.PrItcCgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0) + COALESCE(tpdac.PrItcSgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0) + COALESCE(tpdac.PrItcCessAmount,0)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalItcAmount IS NULL
			OR
			(
				tpdac.PrTotalItcAmount IS NOT NULL
				AND ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
			)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalItcAmount IS NULL
			OR
			(
				tpdac.PrTotalItcAmount IS NOT NULL
				AND ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
			)
		);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0) + COALESCE(tpdac.PrIgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0) + COALESCE(tpdac.PrCgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0) + COALESCE(tpdac.PrSgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0) + COALESCE(tpdac.PrCessAmount,0)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalTaxAmount IS NULL
			OR
			(
				tpdac.PrTotalTaxAmount IS NOT NULL
				AND ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount_A)
			)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalTaxAmount IS NULL
			OR
			(
				tpdac.PrTotalTaxAmount IS NOT NULL
				AND ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount_A)
			)
		);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.IgstAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0) + COALESCE(tpdac.IgstAmount_A,0)
			 ELSE COALESCE(tpdac.IgstAmount,0)
		END) AS IgstAmount,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.CgstAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0) + COALESCE(tpdac.CgstAmount_A,0)
			 ELSE COALESCE(tpdac.CgstAmount,0)
		END) AS CgstAmount,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.SgstAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0) + COALESCE(tpdac.SgstAmount_A,0)
			 ELSE COALESCE(tpdac.SgstAmount,0)
		END) AS SgstAmount,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.CessAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0) + COALESCE(tpdac.CessAmount_A,0)
			 ELSE COALESCE(tpdac.CessAmount,0)
		END) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalItcAmount IS NOT NULL
		AND ABS(tpdac.PrTotalItcAmount) >= ABS(tpdac.TotalTaxAmount_A);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalItcAmount IS NOT NULL
		AND ABS(tpdac.PrTotalItcAmount) >= ABS(tpdac.TotalTaxAmount_A);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.IgstAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0) + COALESCE(tpdac.IgstAmount_A,0)
			 ELSE COALESCE(tpdac.IgstAmount,0)
		END) AS IgstAmount,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.CgstAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0) + COALESCE(tpdac.CgstAmount_A,0)
			 ELSE COALESCE(tpdac.CgstAmount,0)
		END) AS CgstAmount,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.SgstAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0) + COALESCE(tpdac.SgstAmount_A,0)
			 ELSE COALESCE(tpdac.SgstAmount,0)
		END) AS SgstAmount,
		SUM(CASE WHEN ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			 THEN COALESCE(tpdac.CessAmount_A,0)
			 WHEN ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount) 
			 THEN COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0) + COALESCE(tpdac.CessAmount_A,0)
			 ELSE COALESCE(tpdac.CessAmount,0)
		END) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalTaxAmount IS NOT NULL
		AND ABS(tpdac.PrTotalTaxAmount) >= ABS(tpdac.TotalTaxAmount_A);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalTaxAmount IS NOT NULL
		AND ABS(tpdac.PrTotalTaxAmount) >= ABS(tpdac.TotalTaxAmount_A);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(tpdac.PrItcIgstAmount) AS IgstAmount,
		SUM(tpdac.PrItcCgstAmount) AS CgstAmount,
		SUM(tpdac.PrItcSgstAmount) AS SgstAmount,
		SUM(tpdac.PrItcCessAmount) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalItcAmount IS NOT NULL
		AND ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
		AND ABS(tpdac.TotalTaxAmount_A) = ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalItcAmount IS NOT NULL
		AND ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
		AND ABS(tpdac.TotalTaxAmount_A) = ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(tpdac.PrIgstAmount) AS IgstAmount,
		SUM(tpdac.PrCgstAmount) AS CgstAmount,
		SUM(tpdac.PrSgstAmount) AS SgstAmount,
		SUM(tpdac.PrCessAmount) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalTaxAmount IS NOT NULL
		AND ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount_A)
		AND ABS(tpdac.TotalTaxAmount_A) = ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalTaxAmount IS NOT NULL
		AND ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount_A)
		AND ABS(tpdac.TotalTaxAmount_A) = ABS(tpdac.TotalTaxAmount);

	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		SUM(tpdac.IgstAmount_A) AS IgstAmount,
		SUM(tpdac.CgstAmount_A) AS CgstAmount,
		SUM(tpdac.SgstAmount_A) AS SgstAmount,
		SUM(tpdac.CessAmount_A) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeN
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN) 
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeN
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN) 
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4A5_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOtherItc,
		CASE WHEN COALESCE(ABS(tpdac.PrItcIgstAmount),0) < COALESCE(ABS(tpdac.IgstAmount),0) 
			 THEN -tpdac.PrItcIgstAmount 
			 ELSE -tpdac.IgstAmount
		END AS IgstAmount,
		CASE WHEN COALESCE(ABS(tpdac.PrItcCgstAmount),0) < COALESCE(ABS(tpdac.CgstAmount),0) 
			 THEN -tpdac.PrItcCgstAmount 
			 ELSE -tpdac.CgstAmount
		END AS CgstAmount,
		CASE WHEN COALESCE(ABS(tpdac.PrItcSgstAmount),0) < COALESCE(ABS(tpdac.SgstAmount),0) 
			 THEN -tpdac.PrItcSgstAmount 
			 ELSE -tpdac.SgstAmount
		END AS SgstAmount,
		CASE WHEN COALESCE(ABS(tpdac.PrItcCessAmount),0) < COALESCE(ABS(tpdac.CessAmount),0) 
			 THEN -tpdac.PrItcCessAmount 
			 ELSE -tpdac.CessAmount
		END AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN) 
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tpdac.Id
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND (tpdac.Gstr2BReturnPeriod = @ReturnPeriod OR tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod)
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN) 
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	UPDATE 
		oregular.PurchaseDocumentStatus
	SET 
		Gstr3bSection = @Gstr3bSectionOtherItc
	FROM 
		#TempGstr3bUpdateStatus us
	WHERE
		PurchaseDocumentId = us.Id;

	SELECT
		tod.Section,
		tod.IsGstr2bData,
		SUM(tod.TaxableValue) AS TaxableValue,
		SUM(tod.IgstAmount) AS IgstAmount,
		SUM(tod.CgstAmount) AS CgstAmount,
		SUM(tod.SgstAmount) AS SgstAmount,
		SUM(tod.CessAmount) AS CessAmount
	FROM
		#TempGstr3bSection4A5_Original AS tod
	GROUP BY
		tod.Section,
		tod.IsGstr2bData;

	DROP TABLE #TempGstr3bSection4A5_Original,#TempGstr3bUpdateStatus;

END;
GO


DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3bSection4D];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [gst].[GenerateGstr3bSection4D]
*	Comments		: 21-07-2023 | Amit Khanna | This procedure is used to Generate Data of 4.4 Other Details in Gstr3b.
*	Sample Execution : 
					EXEC [gst].[GenerateGstr3bSection4D]
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3bSection4D]
(
	@Gstr3bSectionIneligibleItcAsPerRule INT,
	@Gstr3bSectionIneligibleItcOthers INT,
	@ReturnPeriod INT,
	@SourceTypeTaxPayer SMALLINT,
	@SourceTypeCounterPartyFiled SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@TaxPayerTypeISD SMALLINT,
	@ItcAvailabilityTypeY SMALLINT,
	@ItcAvailabilityTypeN SMALLINT,
	@BitTypeN BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempGstr3bSection4D_Original
	(
		Section INT,
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2)
	);

	CREATE TABLE #TempGstr3bUpdateStatus
	(	
		Id BIGINT,
		Section INT
	);

	/*4D1 ITC reclaimed which was Reversed under Table 4(B)(2) in earlier tax Period */
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcAsPerRule,		
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcIgstAmount),0) + COALESCE(ABS(tpdcpr.IgstAmount),0)) < ABS(tpdc.IgstAmount),(COALESCE(tpdcpr.ItcIgstAmount,0) + COALESCE(tpdcpr.IgstAmount,0)),tpdc.IgstAmount)) AS IgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCgstAmount),0) + COALESCE(ABS(tpdcpr.CgstAmount),0)) < ABS(tpdc.CgstAmount),(COALESCE(tpdcpr.ItcCgstAmount,0) + COALESCE(tpdcpr.CgstAmount,0)),tpdc.CgstAmount)) AS CgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcSgstAmount),0) + COALESCE(ABS(tpdcpr.SgstAmount),0)) < ABS(tpdc.SgstAmount),(COALESCE(tpdcpr.ItcSgstAmount,0) + COALESCE(tpdcpr.SgstAmount,0)),tpdc.SgstAmount)) AS SgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCessAmount),0) + COALESCE(ABS(tpdcpr.CessAmount),0)) < ABS(tpdc.CessAmount),(COALESCE(tpdcpr.ItcCessAmount,0) + COALESCE(tpdcpr.CessAmount,0)),tpdc.CessAmount)) AS CessAmount
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		LEFT JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod 
		AND tpdc.Gstr2BReturnPeriod <> @ReturnPeriod
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdc.Id,
		@Gstr3bSectionIneligibleItcAsPerRule
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		LEFT JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod 
		AND tpdc.Gstr2BReturnPeriod <> @ReturnPeriod
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);
		
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcAsPerRule,
		SUM(tpdc.PrevCpIgstAmount) AS IgstAmount,
		SUM(tpdc.PrevCpCgstAmount) AS CgstAmount,
		SUM(tpdc.PrevCpSgstAmount) AS SgstAmount,
		SUM(tpdc.PrevCpCessAmount) AS CessAmount
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod 
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpd.Id,
		@Gstr3bSectionIneligibleItcAsPerRule
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
		INNER JOIN #TempPurchaseDocumentIds tpd ON tpdc.MapperId = tpd.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod 
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);

	/*4D1 ITC reclaimed which was Reversed under Table 4(B)(2) in earlier tax Period Amendments Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcAsPerRule,
		CASE WHEN tpdac.PrTotalItcAmount IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac.PrIgstAmount) <= ABS(tpdac.IgstAmount_A) AND ABS(tpdac.PrIgstAmount) <= ABS(tpdac.IgstAmount) THEN tpdac.PrIgstAmount
						  WHEN ABS(tpdac.IgstAmount_A) <= ABS(tpdac.PrIgstAmount) AND ABS(tpdac.IgstAmount_A) <= ABS(tpdac.IgstAmount) THEN tpdac.IgstAmount_A
						  ELSE tpdac.IgstAmount
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac.PrItcIgstAmount) <= ABS(tpdac.IgstAmount_A) AND ABS(tpdac.PrItcIgstAmount) <= ABS(tpdac.IgstAmount) THEN tpdac.PrItcIgstAmount
						  WHEN ABS(tpdac.IgstAmount_A) <= ABS(tpdac.PrItcIgstAmount) AND ABS(tpdac.IgstAmount_A) <= ABS(tpdac.IgstAmount) THEN tpdac.IgstAmount_A
						  ELSE tpdac.IgstAmount
					  END)
		END AS IgstAmount,
		CASE WHEN tpdac.PrTotalItcAmount IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac.PrCgstAmount) <= ABS(tpdac.CgstAmount_A) AND ABS(tpdac.PrCgstAmount) <= ABS(tpdac.CgstAmount) THEN tpdac.PrCgstAmount
						  WHEN ABS(tpdac.CgstAmount_A) <= ABS(tpdac.PrCgstAmount) AND ABS(tpdac.CgstAmount_A) <= ABS(tpdac.CgstAmount) THEN tpdac.CgstAmount_A
						  ELSE tpdac.CgstAmount
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac.PrItcCgstAmount) <= ABS(tpdac.CgstAmount_A) AND ABS(tpdac.PrItcCgstAmount) <= ABS(tpdac.CgstAmount) THEN tpdac.PrItcCgstAmount
						  WHEN ABS(tpdac.CgstAmount_A) <= ABS(tpdac.PrItcCgstAmount) AND ABS(tpdac.CgstAmount_A) <= ABS(tpdac.CgstAmount) THEN tpdac.CgstAmount_A
						  ELSE tpdac.CgstAmount
					  END)
		END AS CgstAmount,
		CASE WHEN tpdac.PrTotalItcAmount IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac.PrSgstAmount) <= ABS(tpdac.SgstAmount_A) AND ABS(tpdac.PrSgstAmount) <= ABS(tpdac.SgstAmount) THEN tpdac.PrSgstAmount
						  WHEN ABS(tpdac.SgstAmount_A) <= ABS(tpdac.PrSgstAmount) AND ABS(tpdac.SgstAmount_A) <= ABS(tpdac.SgstAmount) THEN tpdac.SgstAmount_A
						  ELSE tpdac.SgstAmount
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac.PrItcSgstAmount) <= ABS(tpdac.SgstAmount_A) AND ABS(tpdac.PrItcSgstAmount) <= ABS(tpdac.SgstAmount) THEN tpdac.PrItcSgstAmount
						  WHEN ABS(tpdac.SgstAmount_A) <= ABS(tpdac.PrItcSgstAmount) AND ABS(tpdac.SgstAmount_A) <= ABS(tpdac.SgstAmount) THEN tpdac.SgstAmount_A
						  ELSE tpdac.SgstAmount
					  END)
		END AS SgstAmount,
		CASE WHEN tpdac.PrTotalItcAmount IS NULL  
			 THEN SUM(CASE 
						  WHEN ABS(tpdac.PrCessAmount) <= ABS(tpdac.CessAmount_A) AND ABS(tpdac.PrCessAmount) <= ABS(tpdac.CessAmount) THEN tpdac.PrCessAmount
						  WHEN ABS(tpdac.CessAmount_A) <= ABS(tpdac.PrCessAmount) AND ABS(tpdac.CessAmount_A) <= ABS(tpdac.CessAmount) THEN tpdac.CessAmount_A
						  ELSE tpdac.CessAmount
					  END)
			 ELSE SUM(CASE 
						  WHEN ABS(tpdac.PrItcCessAmount) <= ABS(tpdac.CessAmount_A) AND ABS(tpdac.PrItcCessAmount) <= ABS(tpdac.CessAmount) THEN tpdac.PrItcCessAmount
						  WHEN ABS(tpdac.CessAmount_A) <= ABS(tpdac.PrItcCessAmount) AND ABS(tpdac.CessAmount_A) <= ABS(tpdac.CessAmount) THEN tpdac.CessAmount_A
						  ELSE tpdac.CessAmount
					  END)
		END AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND tpdac.Gstr2BReturnPeriod <> @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
	GROUP BY
		tpdac.PrTotalItcAmount;

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionIneligibleItcAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND tpdac.Gstr2BReturnPeriod <> @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcAsPerRule,
		SUM(COALESCE(tpdac.IgstAmount,0) - COALESCE(tpdac.PrItcIgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount,0) - COALESCE(tpdac.PrItcCgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount,0) - COALESCE(tpdac.PrItcSgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount,0) - COALESCE(tpdac.PrItcCessAmount,0)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.Gstr2BReturnPeriod <> @ReturnPeriod
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalItcAmount IS NOT NULL   
			AND ABS(tpdac.PrTotalItcAmount) <  ABS(tpdac.TotalTaxAmount)			
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionIneligibleItcAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.Gstr2BReturnPeriod <> @ReturnPeriod
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalItcAmount IS NOT NULL   
			AND ABS(tpdac.PrTotalItcAmount) <  ABS(tpdac.TotalTaxAmount)			
		);

	/*4.2.2 Ineligible Itc Other*/
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcOthers,
		SUM(tpdc.IgstAmount) AS IgstAmount,
		SUM(tpdc.CgstAmount) AS CgstAmount,
		SUM(tpdc.SgstAmount) AS SgstAmount,
		SUM(tpdc.CessAmount) AS CessAmount
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdc.ItcAvailability = @ItcAvailabilityTypeN
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdc.Id,
		@Gstr3bSectionIneligibleItcOthers
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdc.ItcAvailability = @ItcAvailabilityTypeN
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD);

	/*4.2.2 Ineligible Itc Other Amendments Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcOthers,
		-SUM(tpdac.IgstAmount) AS IgstAmount,
		-SUM(tpdac.CgstAmount) AS CgstAmount,
		-SUM(tpdac.SgstAmount) AS SgstAmount,
		-SUM(tpdac.CessAmount) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeN
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalTaxAmount IS NOT NULL;

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionIneligibleItcOthers
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeN
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdac.PrTotalTaxAmount IS NOT NULL;

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4D_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionIneligibleItcOthers,
		SUM(tpdac.IgstAmount_A) AS IgstAmount,
		SUM(tpdac.CgstAmount_A) AS CgstAmount,
		SUM(tpdac.SgstAmount_A) AS SgstAmount,
		SUM(tpdac.CessAmount_A) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeN
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionIneligibleItcOthers
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 AS tpdac
	WHERE
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeN
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD);

	UPDATE 
		oregular.PurchaseDocumentStatus
	SET 
		Gstr3bSection = CASE WHEN Gstr3bSection IS NULL THEN us.Section WHEN Gstr3bSection & us.Section <> 0 THEN Gstr3bSection ELSE Gstr3bSection + us.Section END
	FROM 
		#TempGstr3bUpdateStatus us
	WHERE
		PurchaseDocumentId = us.Id;
	
	SELECT
		tod.Section,
		SUM(tod.IgstAmount) AS IgstAmount,
		SUM(tod.CgstAmount) AS CgstAmount,
		SUM(tod.SgstAmount) AS SgstAmount,
		SUM(tod.CessAmount) AS CessAmount
	FROM
		#TempGstr3bSection4D_Original AS tod
	GROUP BY
		tod.Section;

	DROP TABLE #TempGstr3bSection4D_Original,#TempGstr3bUpdateStatus;

END;
GO


DROP PROCEDURE IF EXISTS [isd].[InsertDownloadedDocuments];
GO


/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [isd].[InsertDownloadedDocuments]
* 	Comments			: 06-01-2021 | Jitendra Sharma | Insert Document From GSTR6 Api download data
						: 27-01-2021 | Dhruv Amin | Added Gstr6a related changes and refactored code.
						: 11-02-2021 | Dhruv Amin | Added TradeName and legal name from vendor in case of gstr6a.
						: 29-10-2021 | Dhruv Amin | Updated supplytype related uniqueness changes.
*	Review Comments		: 19-03-2021 | Abhishek Shrivas | Doing basic changes and creating index on temp table
-- DROP PROCEDURE [isd].[InsertDownloadedDocuments]
*/--------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [isd].[InsertDownloadedDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@ReturnPeriod INT,
	@FinancialYear INT,
	@AutoSync BIT,
	@ApiCategory SMALLINT,
	@DocumentSectionGroups AS [common].[DocumentSectionGroupType] READONLY,
	@Documents [isd].[DownloadedDocumentType] READONLY,
	@DocumentContacts [isd].[DownloadedDocumentContactType] READONLY,
	@DocumentItems [isd].[DownloadedDocumentItemType] READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@PushToGstStatusUploadedButNotPushed SMALLINT,
	@SupplyTypeS SMALLINT,
	@ApiCategoryTxpGstr6a SMALLINT,
	@ApiCategoryTxpGstr6 SMALLINT,
	@SourceTypeTaxpayer SMALLINT,
	@SourceTypeCounterPartyNotFiled SMALLINT,
	@SourceTypeCounterPartyFiled SMALLINT,
	@DocumentStatusActive SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@ContactTypeBillFrom SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@False BIT = 0,
		@True BIT= 1,
		@CurrentDate DATETIME = GETDATE();

	CREATE TABLE #TempDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		BillingDate DATETIME,
		Mode VARCHAR(2)
	);

	-- Table for delete data ids while autosync = false
	CREATE TABLE #TempDeletedIds
	(
		--AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
	CREATE CLUSTERED INDEX IDX_#TempDeletedIds_ID ON #TempDeletedIds(ID);

	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL	
	);
	CREATE CLUSTERED INDEX IDX_TempUpsertDocumentIds ON #TempUpsertDocumentIds (ID);

	SELECT 
		*
	INTO 
		#TempDocuments
	FROM  
		@Documents tsd;

	;WITH CTE AS (
		SELECT
			GroupId, ROW_NUMBER() OVER(PARTITION BY DocumentNumber, BillFromGstin, DocumentType, SupplyType, IsAmendment ORDER BY GroupID DESC) AS Rno
		FROM
			#TempDocuments
	)
	SELECT
		GroupId
	INTO #DuplicateDocuments
	FROM
		CTE
	WHERE
		Rno > 1

	DELETE td FROM #TempDocuments td
	INNER JOIN #DuplicateDocuments dd ON td.GroupId = dd.GroupId
	
	CREATE NONCLUSTERED INDEX IDX_#TempDocuments_GroupId ON #TempDocuments(GroupId);
	-- Add  document References in temp
	SELECT 
		*
	INTO 
		#TempDocumentReferences
	FROM 
		@DocumentReferences

	DELETE tdr FROM #TempDocumentReferences tdr
	INNER JOIN #DuplicateDocuments dd ON tdr.GroupId = dd.GroupId

	SELECT
		*
	INTO 
		#TempDocumentItems
	FROM
		@DocumentItems;

	DELETE tdi FROM #TempDocumentItems tdi
	INNER JOIN #DuplicateDocuments dd ON tdi.GroupId = dd.GroupId

	SELECT
		*
	INTO 
		#TempDocumentContacts
	FROM
		@DocumentContacts;

	DELETE tdc FROM #TempDocumentContacts tdc
	INNER JOIN #DuplicateDocuments dd ON tdc.GroupId = dd.GroupId

	-- Add purchase section groups in temp
	SELECT
		*
	INTO
		#TempDocumentSectionGroups
	FROM
		@DocumentSectionGroups;

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		BillingDate,
		Mode
	)
	SELECT
		dw.Id,
		td.GroupId,
		ISNULL(ds.BillingDate,@CurrentDate),
		CASE 
			WHEN dw.SourceType = @SourceTypeTaxpayer THEN 'U'
			WHEN dw.ReturnPeriod < @ReturnPeriod THEN 'U'
			WHEN dw.SourceType = @SourceTypeCounterPartyNotFiled AND td.SourceType = @SourceTypeCounterPartyFiled THEN 'US'
			WHEN dw.SourceType = @SourceTypeCounterPartyNotFiled AND ds.[Checksum] <> td.[Checksum] THEN 'U'
			ELSE 'S'
		END AS Mode
	FROM
		#TempDocuments td
		INNER JOIN isd.DocumentDW AS dw ON
		(
			dw.SubscriberId = @SubscriberId
			AND dw.ParentEntityId = @EntityId
			AND CASE WHEN dw.SourceType = @SourceTypeCounterPartyNotFiled THEN @SourceTypeCounterPartyFiled ELSE dw.SourceType END = CASE WHEN td.SourceType = @SourceTypeCounterPartyNotFiled THEN @SourceTypeCounterPartyFiled ELSE td."SourceType" END
			AND dw.DocumentNumber = td.DocumentNumber
			AND dw.DocumentFinancialYear  =  td.DocumentFinancialYear
			AND dw.SupplyType = td.SupplyType			AND (					dw.SupplyType = @SupplyTypeS OR 					(							ISNULL(dw.BillFromGstin,'') = ISNULL(td.BillFromGstin,'')					)			)
			AND dw.TransactionType = td.TransactionType
			AND dw.DocumentType = td.DocumentType
			AND dw.IsAmendment = td.IsAmendment
		)
		INNER JOIN isd.DocumentStatus ds ON ds.DocumentId = dw.Id;

	-- Insert Data For  Document 
	INSERT INTO [isd].[Documents]
	(
		SubscriberId,
		ParentEntityId,
		EntityId,
		UserId,
		Irn,
		IrnGenerationDate,
		IsPreGstRegime,
		SupplyType,
		DocumentType,
		TransactionType,
		TaxPayerType,
		DocumentNumber,
		RecoDocumentNumber,
		DocumentDate,
		Pos,
		ReverseCharge,
		DocumentValue,
		OriginalGstin,
		OriginalStateCode,
		OriginalDocumentNumber,
		OriginalDocumentDate,
		RefPrecedingDocumentDetails,
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,
		SourceType,
		GroupId
	)
	OUTPUT 
		inserted.Id, inserted.GroupId, 'I', @CurrentDate	
	INTO 
		#TempDocumentIds(Id, GroupId, Mode, BillingDate)
	SELECT
		@SubscriberId,
		@EntityId,
		@EntityId,
		@UserId,
		Irn,
		IrnGenerationDate,
		IsPreGstRegime,
		SupplyType,
		DocumentType,
		TransactionType,
		TaxPayerType,
		DocumentNumber,
		RecoDocumentNumber,
		DocumentDate,
		Pos,
		ReverseCharge,
		DocumentValue,
		OriginalGstin,
		OriginalStateCode,
		OriginalDocumentNumber,
		OriginalDocumentDate,
		RefPrecedingDocumentDetails,
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		@ReturnPeriod,
		DocumentFinancialYear,
		@FinancialYear,
		IsAmendment,
		SourceType,
		GroupId
	FROM
		#TempDocuments tsd 
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempDocumentIds);	
	
	UPDATE
		isd.Documents
	SET
		ParentEntityId = @EntityId,
		EntityId = @EntityId,
		UserId = @UserId,
		Irn = tsd.Irn,
		IrnGenerationDate = tsd.IrnGenerationDate,
		IsPreGstRegime = tsd.IsPreGstRegime,
		SupplyType = tsd.SupplyType,
		DocumentType = tsd.DocumentType,
		TransactionType = tsd.TransactionType,
		TaxpayerType = tsd.TaxPayerType,
		DocumentNumber = tsd.DocumentNumber,
		DocumentDate = tsd.DocumentDate,
		Pos = tsd.Pos,
		ReverseCharge = tsd.ReverseCharge,
		DocumentValue = tsd.DocumentValue,
		OriginalGstin = tsd.OriginalGstin,
		OriginalStateCode = tsd.OriginalStateCode ,
		OriginalDocumentNumber = tsd.OriginalDocumentNumber,
		OriginalDocumentDate = tsd.OriginalDocumentDate,
		RefPrecedingDocumentDetails = tsd.RefPrecedingDocumentDetails,
		SectionType = tsd.SectionType,
		TotalTaxableValue = tsd.TotalTaxableValue,
		TotalTaxAmount = tsd.TotalTaxAmount,
		ReturnPeriod = @ReturnPeriod,
		DocumentFinancialYear = tsd.DocumentFinancialYear,
		FinancialYear = @FinancialYear,
		IsAmendment = tsd.IsAmendment,
		SourceType = tsd.SourceType,
		Stamp = CASE WHEN tsdids.Mode = 'US' THEN @CurrentDate ELSE sd.Stamp END,
		ModifiedStamp = @CurrentDate,
		GroupId = tsd.GroupId
	FROM
		isd.Documents AS sd
		INNER JOIN #TempDocumentIds AS tsdids ON tsdids.Id = sd.Id
		INNER JOIN #TempDocuments AS tsd ON tsd.groupId = tsdids.GroupId
	WHERE
		tsdids.Mode IN ('U','US');
		
	UPDATE
		ss
	SET 
		[Status] = @DocumentStatusActive,
		PushStatus = tsd.PushStatus,		
		[Checksum] = tsd.[Checksum],
		AutoDraftSource = tsd.AutoDraftSource,		
		IsPushed = tsd.IsPushed,
		Errors = NULL,
		BillingDate = tsdids.BillingDate,
		LastSyncDate = @CurrentDate,
		ModifiedStamp = @CurrentDate,
		IsReconciled = @False,
		FilingReturnPeriod = tsd.FilingReturnPeriod
	FROM
		isd.DocumentStatus ss
		INNER JOIN #TempDocumentIds AS tsdids ON ss.DocumentId = tsdids.Id
		INNER JOIN #TempDocuments tsd on tsdids.GroupId = tsd.GroupId
	WHERE 
		tsdids.Mode IN ('U','US');
		
	/* Delete DocumentItems */
	IF EXISTS (SELECT AutoId FROM #TempDocumentIds)
	BEGIN
		DECLARE 
			@Min INT = 1, 
			@Max INT, 
			@BatchSize INT, 
			@Records INT;

		SELECT 
			@Max = COUNT(AutoId)
		FROM 
			#TempDocumentIds

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			SET @Records = @Min + @BatchSize;

			DELETE 
				dc
			FROM 
				isd.DocumentContacts AS dc
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dc.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U', 'US')
				AND tdi.AutoId BETWEEN @Min AND @Records;
			
			DELETE 
				di
			FROM 
				isd.DocumentItems AS di
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = di.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U', 'US')
				AND tdi.AutoId BETWEEN @Min AND @Records;
			SET @Min = @Records
		END
	END
	
	INSERT INTO isd.DocumentStatus
	(
		DocumentId,
		[Status],
		PushStatus,
		[Action],
		[Checksum],
		AutoDraftSource,
		IsPushed,
		BillingDate,
		ReconciliationStatus,
		LastSyncDate,
		FilingReturnPeriod
	)
	SELECT  
		tdi.Id AS DocumentId,
		@DocumentStatusActive,
		td.PushStatus,
		td.[Action],
		td.[Checksum],
		td.AutoDraftSource,
		td.IsPushed,
		@CurrentDate,
		td.ReconciliationStatus,
		@CurrentDate,
		td.FilingReturnPeriod
	FROM
		#TempDocumentIds AS tdi
		INNER JOIN #TempDocuments td on tdi.GroupId = td.GroupId
	WHERE 
		tdi.Mode = 'I'

	INSERT INTO [isd].[DocumentContacts]
	(
		DocumentId,
		Gstin,
		[Type],
		StateCode,
		TradeName,
		LegalName
	)
	SELECT
		tdi.Id,
		tdc.Gstin,
		tdc.[Type],
		tdc.StateCode,
		tdc.TradeName,
		tdc.LegalName
	FROM
		#TempDocumentContacts AS tdc
		INNER JOIN #TempDocumentIds AS tdi ON tdc.GroupId = tdi.GroupId
	WHERE 
		tdi.Mode IN ('I', 'U', 'US');

	INSERT INTO [isd].[DocumentItems]
	(
		DocumentId,
		ItcEligibility,
		Rate,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		tdid.Id,
		tdi.ItcEligibility,
		tdi.Rate,
		tdi.TaxableValue,
		tdi.IgstAmount,
		tdi.CgstAmount,
		tdi.SgstAmount,
		tdi.CessAmount
	FROM
		#TempDocumentItems AS tdi
		INNER JOIN #TempDocumentIds AS tdid ON tdi.GroupId = tdid.GroupId
	WHERE 
		tdid.Mode IN ('I', 'U', 'US');

	INSERT INTO isd.DocumentReferences
	(
		DocumentId,
		DocumentNumber,
		DocumentDate
	)
	SELECT
		tdi.Id,
		tdr.DocumentNumber,
		tdr.DocumentDate
	FROM
		#TempDocumentReferences AS tdr
		INNER JOIN #TempDocumentIds AS tdi ON tdr.GroupId = tdi.GroupId
	WHERE 
		tdi.Mode IN ('I');
	
	INSERT INTO #TempUpsertDocumentIds (Id)
	SELECT 
		Id 
	FROM 
		#TempDocumentIds

	IF (@AutoSync = @False AND @ApiCategory = @ApiCategoryTxpGstr6)
	BEGIN
		UPDATE
			ds
		SET
			ds.PushStatus = @PushToGstStatusUploadedButNotPushed,
			ds.IsPushed = @False,
			ds.LastSyncDate = @CurrentDate,
			ds.ModifiedStamp = @CurrentDate,
			ds.IsReconciled = @False
		OUTPUT 
			INSERTED.DocumentId
		INTO 
			#TempUpsertDocumentIds(ID)	
		FROM
			 isd.DocumentDW AS dw
			 INNER JOIN isd.DocumentStatus AS ds ON ds.DocumentId = dw.Id 
			 LEFT JOIN #TempDocumentIds AS tdi ON tdi.Id = dw.Id 
		WHERE
			dw.SubscriberId = @SubscriberId
			AND dw.ParentEntityId = @EntityId
			AND dw.ReturnPeriod = @ReturnPeriod
			AND dw.SectionType IN (SELECT SectionType FROM #TempDocumentSectionGroups)
			AND dw.IsAmendment IN (SELECT IsAmendment FROM #TempDocumentSectionGroups)
			AND ds.IsPushed = @True
			AND tdi.Id IS NULL;
	END
	ELSE IF (@AutoSync = @False AND @ApiCategory = @ApiCategoryTxpGstr6a)
	BEGIN
	INSERT INTO #TempDeletedIds
		(
			Id
		)
		SELECT
			dw.Id
		FROM
			 isd.DocumentDW AS dw
			 LEFT JOIN #TempDocumentIds AS tpdi ON tpdi.Id = dw.Id 
			 LEFT JOIN #TempDocuments AS tpd ON tpdi.GroupId = tpd.GroupId 
		WHERE
			dw.SubscriberId = @SubscriberId
			AND dw.EntityId = @EntityId
			AND dw.ReturnPeriod = @ReturnPeriod
			AND dw.SectionType = tpd.SectionType
			AND dw.IsAmendment = tpd.IsAmendment
			AND dw.SourceType IN (@SourceTypeCounterPartyFiled, @SourceTypeCounterPartyNotFiled)
			AND tpdi.Id IS NULL;
	END

	/*Delete Data for Not Filed */
	IF EXISTS (SELECT Id FROM #TempDeletedIds)
	BEGIN
		/* Delete Document Contact Detail */
		DELETE 
			dc
		FROM 
			isd.DocumentContacts AS dc
			INNER JOIN #TempDeletedIds AS tdi ON dc.DocumentId = tdi.Id

		/* Delete Document Custom Detail */
		DELETE 
			dc
		FROM 
			isd.DocumentCustoms AS dc
			INNER JOIN #TempDeletedIds AS tdi ON dc.DocumentId = tdi.Id

		/* Delete Document Items */
		DELETE 
			di
		FROM 
			isd.DocumentItems AS di
			INNER JOIN #TempDeletedIds AS tdi ON di.DocumentId = tdi.Id

		/* Delete Document Reference */
		DELETE 
			dr
		FROM 
			isd.DocumentReferences AS dr
			INNER JOIN #TempDeletedIds AS tdi ON dr.DocumentId = tdi.Id


		/* Delete Document Status*/
		DELETE 
			ds
		FROM 
			isd.DocumentStatus AS ds
			INNER JOIN #TempDeletedIds AS tdi ON ds.DocumentId = tdi.Id

		/* Delete Document DataWarehouse*/
		DELETE 
			ddw
		FROM 
			isd.DocumentDW AS ddw
			INNER JOIN #TempDeletedIds AS tdi ON ddw.Id = tdi.Id

		/* Delete Document*/
		DELETE 
			d
		FROM 
			isd.Documents AS d
			INNER JOIN #TempDeletedIds AS tdi ON d.Id = tdi.Id
			
	END

	/* SP excuted to Insert/Update data into DW table */	
	EXEC [isd].[InsertDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;	

	SELECT
		tsd.Id,
		CASE WHEN tsd.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS PlanLimitApplicable,
		tsd.GroupId
	FROM
		#TempDocumentIds As tsd
			
	DROP TABLE #TempDocumentIds, 
				#TempDocumentItems, 
				#TempDocuments,
				#TempDeletedIds,
				#TempDocumentContacts;
END;
GO


DROP PROCEDURE IF EXISTS [oregular].[DeletePurchaseDocumentForRecoByIds];
GO


/*-----------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[oregular].[DeletePurchaseDocumentForRecoByIds]
* 	Comments			:	25-06-2020 | Udit Solanki | This procedure marks data for delete in reconciliation
							tables once they are deleted from oregular.PurchaseDocuments
							Parent SP : [oregular].[DeletePurchaseDocumentByIds]
							08/04/2024:|Pooja Rajpurohit|[CGSP2-6701] - 2a2bRewrite
-------------------------------------------------------------------------------------------------------------
*   Test Execution	    :	
							CREATE TABLE #TempPurchaseDocumentIdsNotPushed
							(
								Id INT
							)
							CREATE TABLE #TempPurchaseDocumentIdsPushed
							(
								Id INT
							)
							EXEC [oregular].[DeletePurchaseDocumentForRecoByIds]
								@DocumentStatusDeleted = 2,
								@ReconciliationMappingTypeExtended = 3
*/-----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[DeletePurchaseDocumentForRecoByIds] (
	@DocumentStatusDeleted SMALLINT,
	@ReconciliationMappingTypeExtended SMALLINT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE
		@ReconciliationSectionTypePROnly SMALLINT = 1,
		@ReconciliationSectionTypeGstOnly SMALLINT = 2,
		@FALSE BIT = 0,
		@ReconciledTypeSystem SMALLINT  = 1 ,
		@CURRENT_DATE DATETIME= GETDATE(),
		@SessionId smallint= -4;

	/* code to delete from 2b reco begins */	
	DROP TABLE IF EXISTS #TempIdsForDeleteReco;
	CREATE TABLE #TempIdsForDeleteReco
	(
		Id BIGINT
	);

	INSERT INTO #TempIdsForDeleteReco
	SELECT Id FROM #TempPurchaseDocumentIdsNotPushed;
	
	INSERT INTO #TempIdsForDeleteReco
	SELECT Id FROM #TempPurchaseDocumentIdsPushed;
		 
	SELECT 
		GstnId Id
	INTO #TempUpdateUnReconiled
	FROM 
		#TempIdsForDeleteReco TI
	INNER JOIN 	Oregular.Gstr2bDocumentRecoMapper gbrm ON gbrm.PrId = TI.Id
	WHERE GstnId IS NOT NULL
	UNION
	SELECT 
		PrId
	FROM 
		#TempIdsForDeleteReco TI
	INNER JOIN 	Oregular.Gstr2bDocumentRecoMapper gbrm ON gbrm.GstnId = TI.Id
	WHERE PrId IS NOT NULL;
	
	/*Updating Section to Pr ONLY where Gstin record is in match or mismatch section*/
	UPDATE r_pdrm
	SET GstnId = NULL,
		SectionType = @ReconciliationSectionTypePROnly,
		Reason = NULL,
		ReasonType = NULL,
		PredictableMatchBy = NULL,
		IsCrossHeadTax = @FALSE,
		ReconciledType = @ReconciledTypeSystem,
		SessionId = @SessionId,					
		ModifiedStamp = GETDATE(),
		Gstr2BReturnPeriodDate = NULL
	FROM 
		Oregular.Gstr2bDocumentRecoMapper r_pdrm
		INNER JOIN #TempIdsForDeleteReco t_rpd ON r_pdrm.GstnId = t_rpd.Id
	WHERE
		r_pdrm.GstnId IS NOT NULL AND r_pdrm.PrId IS NOT NULL
		AND r_pdrm.SectionType <> @ReconciliationSectionTypeGstOnly;
		
	/*Deleting data from reco mapper where gstin id is null*/						
	DELETE 
		r_pdrm
	FROM 
		Oregular.Gstr2bDocumentRecoMapper r_pdrm
	INNER JOIN #TempIdsForDeleteReco t_rpd  ON r_pdrm.PrId = t_rpd.Id
	WHERE 
		r_pdrm.GstnId IS NULL;
		
	/*Deleting data from reco mapper where pr id is null*/
	DELETE 
		r_pdrm
	FROM 
		Oregular.Gstr2bDocumentRecoMapper r_pdrm
	INNER JOIN #TempIdsForDeleteReco t_rpd  ON r_pdrm.GstnId = t_rpd.Id
	WHERE 
		r_pdrm.PrId IS NULL;							

	/*Updating Section to GStONLY where PR record is in match or mismatch section*/
	UPDATE  r_pdrm
	SET PrId = NULL,
		SectionType = @ReconciliationSectionTypeGstOnly,
		Reason = NULL,
		ReasonType = NULL,
		IsCrossHeadTax = @FALSE,
		PredictableMatchBy = NULL,
		ReconciledType =  @ReconciledTypeSystem,
		SessionId = @SessionId,					
		ModifiedStamp = GETDATE(),
		PrReturnPeriodDate = NULL
	FROM  
		Oregular.Gstr2bDocumentRecoMapper r_pdrm
		INNER JOIN #TempIdsForDeleteReco t_rpd	ON r_pdrm.PrId = t_rpd.Id
	WHERE 
		r_pdrm.PrId IS NOT NULL AND r_pdrm.GstnId IS NOT NULL		
		AND r_pdrm.SectionType <> @ReconciliationSectionTypePROnly;			
		
-------------------------Delete From 2a Begins -------------------------------------------	

	INSERT INTO #TempUpdateUnReconiled 
	SELECT 
		GstnId
	FROM 
		#TempIdsForDeleteReco TI
	INNER JOIN 	Oregular.Gstr2aDocumentRecoMapper gbrm ON gbrm.PrId = TI.Id
	WHERE GstnId IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM #TempUpdateUnReconiled d WHERE TI.Id = d.Id)
	UNION
	SELECT 
		PrId
	FROM 
		#TempIdsForDeleteReco TI
	INNER JOIN 	Oregular.Gstr2aDocumentRecoMapper gbrm ON gbrm.GstnId = TI.Id
	WHERE PrId IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM #TempUpdateUnReconiled d WHERE TI.Id = d.Id);

	/*Updating Section to Pr ONLY where Gstin record is in match or mismatch section*/
	UPDATE r_pdrm
	SET GstnId = NULL,
		SectionType = @ReconciliationSectionTypePROnly,
		Reason = NULL,
		ReasonType = NULL,
		PredictableMatchBy = NULL,
		IsCrossHeadTax = @FALSE,
		ReconciledType = @ReconciledTypeSystem,
		SessionId = @SessionId,					
		ModifiedStamp = GETDATE(),
		GstnReturnPeriodDate = NULL
	FROM 
		Oregular.Gstr2aDocumentRecoMapper r_pdrm
		INNER JOIN #TempIdsForDeleteReco t_rpd ON r_pdrm.GstnId = t_rpd.Id
	WHERE 
		r_pdrm.GstnId IS NOT NULL AND r_pdrm.PrId IS NOT NULL	
		AND r_pdrm.SectionType <> @ReconciliationSectionTypeGstOnly;
		
	;/*Deleting data from reco mapper where gstin id is null*/					
	DELETE 
		r_pdrm
	FROM 
		Oregular.Gstr2aDocumentRecoMapper r_pdrm
	INNER JOIN #TempIdsForDeleteReco t_rpd ON  r_pdrm.PrId = t_rpd.Id
	WHERE 
		r_pdrm.GstnId IS NULL		;
		
	/*Deleting data from reco mapper where pr id is null*/
	DELETE 
		r_pdrm
	FROM 
		Oregular.Gstr2aDocumentRecoMapper r_pdrm
	INNER JOIN #TempIdsForDeleteReco t_rpd ON r_pdrm.GstnId = t_rpd.Id
	WHERE 
		r_pdrm.PrId IS NULL;
	
	/*Updating Section to GStONLY where PR record is in match or mismatch section*/
	UPDATE 
		r_pdrm
	SET 
		PrId = NULL,
		SectionType = @ReconciliationSectionTypeGstOnly,
		Reason = NULL,
		ReasonType = NULL,
		IsCrossHeadTax = @FALSE,
		PredictableMatchBy = NULL,
		ReconciledType =  @ReconciledTypeSystem,
		SessionId = @SessionId,					
		ModifiedStamp = GETDATE(),
		PrReturnPeriodDate = NULL
	FROM  
		#TempIdsForDeleteReco		t_rpd	
		INNER JOIN Oregular.Gstr2aDocumentRecoMapper r_pdrm ON  r_pdrm.PrId = t_rpd.Id
	WHERE 
		r_pdrm.PrId IS NOT NULL AND r_pdrm.GstnId IS NOT NULL		
		AND r_pdrm.SectionType <> @ReconciliationSectionTypePROnly;			
	
	Update  pds
	SET IsReconciled = @FALSE
	FROM
		oregular.PurchaseDocumentStatus pds
		INNER JOIN 	#TempUpdateUnReconiled  tur ON tur.Id = pds.PurchaseDocumentId;

	DROP TABLE IF EXISTS #TempCancelledInvoiceIds;
	SELECT 
		r_pdrm.GstnId AS CancelledInvoiceId
	INTO
		#TempCancelledInvoiceIds
	FROM  
		#TempIdsForDeleteReco	t_rpd
		INNER JOIN oregular.Gstr2bDocumentRecoMapper r_pdrm ON r_pdrm.CancelledInvoiceId = t_rpd.Id
	WHERE 
		r_pdrm.CancelledInvoiceId IS NOT NULL AND r_pdrm.GstnId IS NOT NULL
	UNION
	SELECT 
		r_pdrm.CancelledInvoiceId
	FROM  
		#TempIdsForDeleteReco	t_rpd
		INNER JOIN oregular.Gstr2bDocumentRecoMapper r_pdrm ON r_pdrm.CancelledInvoiceId = t_rpd.Id
	WHERE 
		r_pdrm.CancelledInvoiceId IS NOT NULL;
		
	DROP TABLE IF EXISTS #TempRecoReasonData;
	SELECT
		rm.Id AS MapperId,		
		[Value] AS Reason,
		CAST(JSON_VALUE([Value],'$.Reason') AS BIGINT) AS ReasonType
	INTO
		#TempRecoReasonData
	FROM  
		#TempCancelledInvoiceIds AS tci
		INNER JOIN oregular.Gstr2bDocumentRecoMapper AS rm ON rm.CancelledInvoiceId = tci.CancelledInvoiceId
		CROSS APPLY OPENJSON(Reason);

	DROP TABLE IF EXISTS #TempGstr2bDocumentRecoMapperIds;
	SELECT
		rm.Id AS MapperId
	INTO
		#TempGstr2bDocumentRecoMapperIds
	FROM  
		#TempCancelledInvoiceIds AS tci
		INNER JOIN oregular.Gstr2bDocumentRecoMapper AS rm ON rm.CancelledInvoiceId = tci.CancelledInvoiceId;

	DROP TABLE IF EXISTS #TempCancelledInvoiceReasonData;
	SELECT
		MapperId,
		CAST(QUOTENAME(STRING_AGG(Reason,'')) AS VARCHAR(MAX)) AS Reason,
		SUM(ReasonType) AS ReasonType
	INTO
		#TempCancelledInvoiceReasonData
	FROM
		#TempRecoReasonData
	WHERE
		ReasonType NOT IN(8589934592, 34359738368)
	GROUP BY MapperId;
		
	UPDATE rm
		SET 
			Reason = tcird.Reason,
			ReasonType = tcird.ReasonType,
			CancelledInvoiceId = NULL,
			SessionId = @SessionId,					
			ModifiedStamp = GETDATE()
	FROM  
		oregular.Gstr2bDocumentRecoMapper AS rm
		INNER JOIN #TempGstr2bDocumentRecoMapperIds AS trrd ON rm.Id = trrd.MapperId
		LEFT JOIN #TempCancelledInvoiceReasonData AS tcird ON trrd.MapperId = tcird.MapperId
		;
	
	SELECT DISTINCT
		pd.EntityId,
		pd.FinancialYear	
	FROM 
		#TempUpdateUnReconiled tpf
	INNER JOIN oregular.PurchaseDocuments pd ON tpf.Id = pd.Id;

	DROP TABLE IF EXISTS #TempAmendmentIdsNotPushed,#TempAmendmentIdsPushed
END	   
;
GO


DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3b];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [gst].[GenerateGstr3b]
*	Comments		: 22/06/2020 | Amit Khanna | This procedure is used to Generate Gstr3b Data.
					: 02/07/2020 | Amit Khanna | Added Parameter ProvisionalItcPercentage,IsProvisionalItc,ReconciliationSectionTypesMatch,MisMatched,DueToTolerance.
					: 10/07/2020 | Amit Khanna | Added Condition to compare return period with document date when liability discharge return period is null and IsQuaterlyFiling = true.
					: 21/07/2020 | Amit Khanna | Removed Parameters TransactionType ISD,TCS,COMP.Added TaxPayerType COM,EMB.
					: 23/07/2020 | Amit Khanna | Removed Parameter IsUnRegisteredPurchase.
					: 03/02/2021 | Amit Khanna | Added logic to calculate Gstr2b data with excluded itc. Add paramter ItcAvailabilityTypeY,ItcAvailabilityTypeT
												 And also added return period for purchase document in subqueries as there will be data for Gstr2b with different return period.
					: 24/02/2021 | Amit Khanna | Replaced DocumentItems Table with RateWiseDocumentItems and removed TaxType conditions
					: 04/05/2021 | Jitendra Sharma | Remove reconciliation logic.
					: 04/06/2024 | Jitendra Sharma | This procedure is used to Generate Gstr3b Data. (Rewrite)

*	Sample Execution : 
					DECLARE @PreviousReturnPeriods AS [common].[IntType];
					INSERT INTO @PreviousReturnPeriods (Item) 
					VALUES (42023), (52023), (62023), (72023), (82023), (92023), (102023), (112023), (122023), (12024), (22024), (32024);

					--Select to check the inserted values
					--SELECT * FROM @PreviousReturnPeriods;

					
					EXEC [gst].[GenerateGstr3b]
								@SubscriberId = 164,
								@EntityId = 16892,
								@FinancialYear = 202324,
								@ReturnPeriod = 22024,
								@PreviousReturnPeriods = @PreviousReturnPeriods,
								@LastFilingDate = NULL,	
								@Gstr3bAutoPopulateType = 1,
								@Month = 2,
								@LocationPos = 33,
								@IsQuarterlyFiling = 0,
								@ReturnTypeGSTR3B = 14,
								@ReturnActionSystemGenerated = 1,
								@TransactionTypeB2C = 12,
								@TransactionTypeB2B = 1,
								@TransactionTypeCBW = 25,
								@TransactionTypeDE = 6,
								@TransactionTypeEXPWP = 2,
								@TransactionTypeEXPWOP = 3,
								@TransactionTypeSEZWP = 4,
								@TransactionTypeSEZWOP = 5,
								@TransactionTypeIMPS = 8,
								@TransactionTypeIMPG = 7,
								@SectTypeAll = 1,
								@DocumentSummaryTypeGstr1B2CS = 2,
								@DocumentSummaryTypeGSTR1ECOM = 25,
								@DocumentSummaryTypeGSTR1SUPECO = 26,
								@DocumentSummaryTypeGstr1ADV = 3,
								@DocumentSummaryTypeGstr1ADVAJ = 4,
								@DocumentSummaryTypeGstr1NIL = 5,
								@DocumentSummaryTypeGstr2NIL = 15,
								@DocumentTypeINV = 1,
								@DocumentTypeCRN = 2,
								@DocumentTypeDBN = 3,
								@DocumentTypeBOE = 4,
								@Gstr3bSectionOutwardTaxSupply = 1,
								@Gstr3bSectionOutwardZeroRated = 2,
								@Gstr3bSectionOutwardNilRated = 3,
								@Gstr3bSectionInwardReverseCharge = 4,
								@Gstr3bSectionOutwardNonGst = 5,
								@Gstr3bSectionInterStateB2c = 6,
								@Gstr3bSectionInterStateComp = 7,
								@Gstr3bSectionInterStateUin = 8,	
								@Gstr3bSectionImportOfGoods = 9,
								@Gstr3bSectionImportOfServices = 10,
								@Gstr3bSectionInwardReverseChargeOther = 11,
								@Gstr3bSectionInwardSuppliesFromIsd = 12,
								@Gstr3bSectionOtherItc = 13,
								@Gstr3bSectionItcReversedAsPerRule = 14,
								@Gstr3bSectionItcReversedOthers = 15,
								@Gstr3bSectionNilExempt = 16,
								@Gstr3bSectionNonGst = 17,
								@Gstr3bSectionEcoSupplies = 18,
								@Gstr3bSectionEcoRegSupplies = 19,
								@Gstr3bSectionIneligibleItcAsPerRule = 20,
								@Gstr3bSectionIneligibleItcOthers = 21,
								@ItcEligibilityNo = 4,
								@TaxPayerTypeCOM = 2,
								@TaxPayerTypeUNB = 9,
								@TaxPayerTypeEMB = 11,
								@TaxPayerTypeISD = 4,
								@TaxPayerTypeONP = 10,
								@NilExemptNonGstTypeINTRB2B = 1,
								@NilExemptNonGstTypeINTRB2C = 3,
								@NilExemptNonGstTypeINTRAB2B = 2,
								@NilExemptNonGstTypeINTRAB2C = 4,
								@NilExemptNonGstTypeINTRA = 5,
								@NilExemptNonGstTypeINTER = 6,
								@SourceTypeTaxPayer = 1,
								@SourceTypeCounterPartyNotFiled = 2,
								@SourceTypeCounterPartyFiled = 3,
								@ReconciliationSectionTypePROnly = 1,
								@ReconciliationSectionTypeMatched = 3 ,
								@ReconciliationSectionTypeMatchedDueToTolerance = 4,
								@ReconciliationSectionTypeNearMatched = 6,
								@ReconciliationSectionTypeMisMatched = 5,
								@ReconciliationSectionTypeGstOnly =2,
								@ReconciliationSectionTypePRExcluded = 7,
								@ReconciliationSectionTypeGstExcluded = 8,
								@ReconciliationSectionTypePRDiscarded = 9,
								@ReconciliationSectionTypeGstDiscarded = 10,
								@DocumentStatusActive = 1,
								@ContactTypeBillFrom = 1,
								@ContactTypeBillTo = 3,
								@ItcAvailabilityTypeN = 0,
								@ItcAvailabilityTypeY = 1,
								@ItcAvailabilityTypeT = 2,
								@GstActOrRuleSectionTypeGstAct95 = 1,
								@GstActOrRuleSectionTypeGstAct38 = 6,
								@GstActOrRuleSectionTypeGstAct42 = 2,
								@GstActOrRuleSectionTypeGstAct43 = 3,
								@GstActOrRuleSectionTypeGstActItc175 = 4,
								@ReconciliationTypeGstr2B  = 8,
								@TaxTypeTAXABLE = 1,
								@Gstr3bAutoPopulateTypeGstActRuleSection = 1,
								@Gstr3bAutoPopulateTypeExemptedTurnoverRatio = 2;
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3b]
(
	@SubscriberId INT,
	@EntityId INT,
	@FinancialYear INT,
	@ReturnPeriod INT,
	@PreviousReturnPeriods [common].[IntType] READONLY,
	@LastFilingDate DATETIME,
	@Gstr3bAutoPopulateType SMALLINT,
	@Month SMALLINT,
	@LocationPos SMALLINT,
	@IsQuarterlyFiling BIT,
	@ReturnTypeGSTR3B SMALLINT,
	@ReturnActionSystemGenerated SMALLINT,
	@TransactionTypeB2C SMALLINT,
	@TransactionTypeB2B SMALLINT,
	@TransactionTypeCBW SMALLINT,
	@TransactionTypeDE SMALLINT,
	@TransactionTypeEXPWP SMALLINT,
	@TransactionTypeEXPWOP SMALLINT,
	@TransactionTypeSEZWP SMALLINT,
	@TransactionTypeSEZWOP SMALLINT,
	@TransactionTypeIMPS SMALLINT,
	@TransactionTypeIMPG SMALLINT,
	@SectTypeAll INTEGER,
	@DocumentSummaryTypeGstr1B2CS SMALLINT,
	@DocumentSummaryTypeGSTR1ECOM SMALLINT, 
	@DocumentSummaryTypeGSTR1SUPECO SMALLINT,
	@DocumentSummaryTypeGstr1ADV SMALLINT,
	@DocumentSummaryTypeGstr1ADVAJ SMALLINT,
	@DocumentSummaryTypeGstr1NIL SMALLINT,
	@DocumentSummaryTypeGstr2NIL SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeBOE SMALLINT,
	@Gstr3bSectionOutwardTaxSupply INT,
	@Gstr3bSectionOutwardZeroRated INT,
	@Gstr3bSectionOutwardNilRated INT,
	@Gstr3bSectionInwardReverseCharge INT,
	@Gstr3bSectionOutwardNonGst INT,
	@Gstr3bSectionInterStateB2c INT,
	@Gstr3bSectionInterStateComp INT,
	@Gstr3bSectionInterStateUin INT,
	@Gstr3bSectionImportOfGoods INT,
	@Gstr3bSectionImportOfServices INT,
	@Gstr3bSectionInwardReverseChargeOther INT,
	@Gstr3bSectionInwardSuppliesFromIsd INT,
	@Gstr3bSectionOtherItc INT,
	@Gstr3bSectionItcReversedAsPerRule INT,
	@Gstr3bSectionItcReversedOthers INT,
	@Gstr3bSectionNilExempt INT,
	@Gstr3bSectionNonGst INT,
	@Gstr3bSectionEcoSupplies INT,
	@Gstr3bSectionEcoRegSupplies INT,
	@Gstr3bSectionIneligibleItcAsPerRule INT,
	@Gstr3bSectionIneligibleItcOthers INT,
	@ItcEligibilityNo SMALLINT,
	@TaxPayerTypeCOM SMALLINT,
	@TaxPayerTypeUNB SMALLINT,
	@TaxPayerTypeEMB SMALLINT,
	@TaxPayerTypeISD SMALLINT,
	@TaxPayerTypeONP SMALLINT,
	@NilExemptNonGstTypeINTRB2B SMALLINT,
	@NilExemptNonGstTypeINTRB2C SMALLINT,
	@NilExemptNonGstTypeINTRAB2B SMALLINT,
	@NilExemptNonGstTypeINTRAB2C SMALLINT,
	@NilExemptNonGstTypeINTRA SMALLINT,
	@NilExemptNonGstTypeINTER SMALLINT,
	@SourceTypeTaxPayer SMALLINT,
	@SourceTypeCounterPartyFiled SMALLINT,
	@SourceTypeCounterPartyNotFiled SMALLINT,
	@ReconciliationSectionTypePROnly SMALLINT,
	@ReconciliationSectionTypeMatched SMALLINT,
	@ReconciliationSectionTypeMatchedDueToTolerance SMALLINT,
	@ReconciliationSectionTypeNearMatched SMALLINT,
	@ReconciliationSectionTypeMisMatched SMALLINT,
	@ReconciliationSectionTypeGstOnly SMALLINT,
	@ReconciliationSectionTypePRExcluded SMALLINT,
	@ReconciliationSectionTypeGstExcluded SMALLINT,
	@ReconciliationSectionTypePRDiscarded SMALLINT,
	@ReconciliationSectionTypeGstDiscarded SMALLINT,
	@DocumentStatusActive SMALLINT,
	@ContactTypeBillFrom SMALLINT,
	@ContactTypeBillTo SMALLINT,
	@ItcAvailabilityTypeN SMALLINT,
	@ItcAvailabilityTypeY SMALLINT,
	@ItcAvailabilityTypeT SMALLINT,
	@GstActOrRuleSectionTypeGstAct95 SMALLINT,
	@GstActOrRuleSectionTypeGstAct38 SMALLINT,
	@GstActOrRuleSectionTypeGstAct42 SMALLINT,
	@GstActOrRuleSectionTypeGstAct43 SMALLINT,
	@GstActOrRuleSectionTypeGstActItc175 SMALLINT,
	@ReconciliationTypeGstr2B SMALLINT,
	@TaxTypeTAXABLE SMALLINT,
	@Gstr3bAutoPopulateTypeGstActRuleSection SMALLINT,
	@Gstr3bAutoPopulateTypeExemptedTurnoverRatio SMALLINT
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsFirstMonthOfQuarter BIT = 0, 
			@IsSecondMonthOfQuarter BIT = 0, 
			@IsThirdMonthOfQurater BIT = 0, 
			@BitTypeN BIT = 0, 
			@BitTypeY BIT= 1;

	

	DROP TABLE IF EXISTS #ManualMapperData,#TempGstr3bInterState_Original,#TempGstr3bSection_Original,#TempMapper,#TempOriginalPrPurchaseDocumentItemsCircular170,#TempOriginalPurchaseDocumentItems,#TempOriginalPurchaseDocumentItemsCircular170,
			   #TempOriginalSaleDocumentItems,#TempPurchaseDocumentIds,#TempPurchaseDocumentItems,#TempPurchaseDocumentItemsCircular170,#TempPurchaseDocuments,#TempPurchaseDocumentsAmendment,#TempPurchaseDocumentsAmendmentCircular170,
			   #TempPurchaseDocumentsCircular170,#TempPurchaseSummary,#TempSaleDocumentIds,#TempSaleDocumentItems,#TempSaleDocuments,#TempSaleDocumentsAmendment,#TempSaleSummary,#TempSaleSummaryAmendment,#TempSections;

	/* Final Result Table of Gstr3b Data or Gstr2b Exclude Itc Data when "IsGstr2bData" = 1 */
	CREATE TABLE #TempGstr3bSection_Original
	(
		Section INT,
		IsGstr2bData BIT DEFAULT 0,
		TaxableValue DECIMAL(18,2),
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2)
	);

	/* Final Result Table of Inter State Data */
	CREATE TABLE #TempGstr3bInterState_Original
	(
		Section INT,
		Pos SMALLINT,
		TaxableValue DECIMAL(18,2),
		IgstAmount DECIMAL(18,2)
	);

	CREATE TABLE #TempSections (Sections INT)
	
	INSERT INTO #TempSections
	(
		Sections
	)
	VALUES
	(@Gstr3bSectionEcoSupplies),
	(@Gstr3bSectionEcoRegSupplies),
	(@Gstr3bSectionOutwardTaxSupply),
	(@Gstr3bSectionOutwardZeroRated),
	(@Gstr3bSectionOutwardNilRated),
	(@Gstr3bSectionInwardReverseCharge),
	(@Gstr3bSectionOutwardNonGst),
	(@Gstr3bSectionImportOfGoods),
	(@Gstr3bSectionImportOfServices),
	(@Gstr3bSectionInwardReverseChargeOther),
	(@Gstr3bSectionInwardSuppliesFromIsd),
	(@Gstr3bSectionOtherItc),
	(@Gstr3bSectionItcReversedAsPerRule),
	(@Gstr3bSectionItcReversedOthers),
	(@Gstr3bSectionIneligibleItcAsPerRule),
	(@Gstr3bSectionIneligibleItcOthers),
	(@Gstr3bSectionNilExempt),
	(@Gstr3bSectionNonGst);

	/* Is quarterly filing check */
	IF(@IsQuarterlyFiling = @BitTypeY)
	BEGIN
		IF(@Month IN (1,4,7,10))
		BEGIN
			SET @IsFirstMonthOfQuarter = 1;
		END
		ELSE IF(@Month IN (2,5,8,11))
		BEGIN
			SET @IsSecondMonthOfQuarter = 1;
		END
		ELSE IF(@Month IN (3,6,9,12))
		BEGIN
			SET @IsThirdMonthOfQurater = 1;
		END
	END

	/*Sales Data*/	
	SELECT 
		sd.Id,
		sd.ParentEntityId,
		sd.SourceType,
		sd.CombineDocumentType,
		sd.IsAmendment,
		sd.OriginalDocumentNumber,
		sd.OriginalDocumentDate
	INTO 
		#TempSaleDocumentIds
	FROM 
		oregular.SaleDocumentDW sd	
		INNER JOIN oregular.SaleDocumentStatus sds on sd.Id = sds.SaleDocumentId
	WHERE 		
		sd.SubscriberId = @SubscriberId
		AND sd.EntityId = @EntityId 
		AND sd.ReturnPeriod = @ReturnPeriod
		AND sd.SourceType = @SourceTypeTaxPayer
		AND sd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)	
		AND sd.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeCBW,@TransactionTypeDE,@TransactionTypeEXPWOP,@TransactionTypeEXPWP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP)
		AND sds.[Status] = @DocumentStatusActive
		AND sds.LiabilityDischargeReturnPeriod IS NULL
	UNION
	SELECT 
		sd.Id,
		sd.ParentEntityId,
		sd.SourceType,
		sd.CombineDocumentType,
		sd.IsAmendment,
		sd.OriginalDocumentNumber,
		sd.OriginalDocumentDate
	FROM 
		oregular.SaleDocumentDW sd	
		INNER JOIN oregular.SaleDocumentStatus sds on sd.Id = sds.SaleDocumentId
	WHERE 		
		sd.SubscriberId = @SubscriberId
		AND sd.EntityId = @EntityId 
		AND sd.SourceType = @SourceTypeTaxPayer
		AND sd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)	
		AND sd.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeCBW,@TransactionTypeDE,@TransactionTypeEXPWOP,@TransactionTypeEXPWP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP)
		AND sds.[Status] = @DocumentStatusActive
		AND sds.LiabilityDischargeReturnPeriod = @ReturnPeriod;

	/* Sale Document Items */
	SELECT
		sdi.SaleDocumentId,
		sdi.GstActOrRuleSection,
		SUM(sdi.TaxableValue) AS TaxableValue,
		SUM(sdi.IgstAmount) AS IgstAmount,
		SUM(sdi.CgstAmount) AS CgstAmount,
		SUM(sdi.SgstAmount) AS SgstAmount,	
		SUM(sdi.CessAmount) AS CessAmount	
	INTO 
		#TempSaleDocumentItems
	FROM
		#TempSaleDocumentIds si
		INNER JOIN oregular.SaleDocumentItems AS sdi On si.Id = sdi.SaleDocumentId AND sdi.TaxType = @TaxTypeTAXABLE
	GROUP BY 
		SaleDocumentId,
		GstActOrRuleSection;							
	
	CREATE INDEX idx_temp_TempSaleDocumentItems_SaleDocumentId ON #TempSaleDocumentItems(SaleDocumentId);

	/*Sales Documents Data*/
	SELECT
		sd.Id,
		sd.DocumentNumber,
		sd.DocumentDate,
		sd.DocumentType,
		sd.DocumentValue,
		sd.TaxPayerType,
		sd.TransactionType,
		sd.ReverseCharge,
		sd.ECommerceGstin,
		sd.Pos,
		sd.IsAmendment,
		sd.OriginalDocumentNumber,
		sd.OriginalDocumentDate,
		sdcf.Gstin AS BillFromGstin,
		sdct.Gstin AS BillToGstin,
		CASE WHEN LEN(sdct.Gstin) = 10 THEN @BitTypeY ELSE @BitTypeN END IsBillToPAN,
		tsdi.GstActOrRuleSection,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.IgstAmount ELSE tsdi.IgstAmount END AS IgstAmount,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.CgstAmount ELSE tsdi.CgstAmount END AS CgstAmount,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.SgstAmount ELSE tsdi.SgstAmount END AS SgstAmount,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.CessAmount ELSE tsdi.CessAmount END AS CessAmount,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.TaxableValue ELSE tsdi.TaxableValue END AS TaxableValue
	INTO 
		#TempSaleDocuments
	FROM 
		#TempSaleDocumentItems tsdi 
		INNER JOIN oregular.SaleDocuments sd ON sd.Id = tsdi.SaleDocumentId
		INNER JOIN oregular.SaleDocumentStatus ss on sd.Id = ss.SaleDocumentid		
		LEFT JOIN oregular.SaleDocumentContacts AS sdcf ON sd.Id = sdcf.SaleDocumentId AND sdcf.[Type] = @ContactTypeBillFrom		
		LEFT JOIN oregular.SaleDocumentContacts AS sdct ON sd.Id = sdct.SaleDocumentId AND sdct.[Type] = @ContactTypeBillTo	
	WHERE 
		sd.IsAmendment = @BitTypeN;
		
	/*Original Sales Data For Amendment*/
	SELECT 		
		tsd.Id, --AmendmentId
		sdo.DocumentType, 
		sdio.GstActOrRuleSection,
		SUM(sdio.TaxableValue) AS TaxableValue,
		SUM(sdio.IgstAmount) AS IgstAmount,
		SUM(sdio.CgstAmount) AS CgstAmount,
		SUM(sdio.SgstAmount) AS SgstAmount,	
		SUM(sdio.CessAmount) AS CessAmount
	INTO 
		#TempOriginalSaleDocumentItems
	FROM 
		#TempSaleDocumentIds tsd
		INNER JOIN oregular.SaleDocumentDW sdo ON sdo.DocumentNumber = tsd.OriginalDocumentNumber AND sdo.DocumentDate = tsd.OriginalDocumentDate
		INNER JOIN oregular.SaleDocumentStatus sdso ON sdo.Id = sdso.SaleDocumentId
		INNER JOIN oregular.SaleDocumentItems sdio ON sdo.Id = sdio.SaleDocumentId
	WHERE
		sdo.SubscriberId = @SubscriberId
		AND tsd.IsAmendment = @BitTypeY
		AND sdo.ParentEntityId = tsd.ParentEntityId	
		AND sdo.SourceType = @SourceTypeTaxPayer
		AND sdo.SourceType = tsd.SourceType
		AND sdo.CombineDocumentType = tsd.CombineDocumentType
		AND sdo.IsAmendment = @BitTypeN		
		AND sdso.Status = @DocumentStatusActive	
		AND sdo.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeCBW,@TransactionTypeDE,@TransactionTypeEXPWOP,@TransactionTypeEXPWP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP)
		AND sdio.TaxType = @TaxTypeTAXABLE
	GROUP BY 
		tsd.Id,
		sdo.DocumentType, 
		sdio.GstActOrRuleSection;

	SELECT
		sd.Id,
		sd.DocumentNumber,
		sd.DocumentDate,
		sd.DocumentType AS DocumentType_A, -- Amendment DocumentType
		tosdi.DocumentType, -- Original DocumentType
		sd.DocumentValue,
		sd.TaxpayerType,
		sd.TransactionType,
		sd.ReverseCharge,
		sd.ECommerceGstin,
		sd.Pos,
		sd.IsAmendment,
		sd.OriginalDocumentNumber,
		sd.OriginalDocumentDate,
		sdcf.Gstin AS BillFromGstin,
		sdct.Gstin AS BillToGstin,
		CASE WHEN LEN(sdct.Gstin) = 10 THEN @BitTypeY ELSE @BitTypeN END IsBillToPAN,
		tsdi.GstActOrRuleSection,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.TaxableValue ELSE tsdi.TaxableValue END AS TaxableValue_A,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.IgstAmount ELSE tsdi.IgstAmount END AS IgstAmount_A,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.CgstAmount ELSE tsdi.CgstAmount END AS CgstAmount_A,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.SgstAmount ELSE tsdi.SgstAmount END AS SgstAmount_A,
		CASE WHEN sd.DocumentType = @DocumentTypeCRN THEN -tsdi.CessAmount ELSE tsdi.CessAmount END AS CessAmount_A,
		CASE WHEN tosdi.DocumentType = @DocumentTypeCRN THEN -tosdi.TaxableValue ELSE tosdi.TaxableValue END AS TaxableValue,
		CASE WHEN tosdi.DocumentType = @DocumentTypeCRN THEN -tosdi.IgstAmount ELSE tosdi.IgstAmount END AS IgstAmount,
		CASE WHEN tosdi.DocumentType = @DocumentTypeCRN THEN -tosdi.CgstAmount ELSE tosdi.CgstAmount END AS CgstAmount,
		CASE WHEN tosdi.DocumentType = @DocumentTypeCRN THEN -tosdi.SgstAmount ELSE tosdi.SgstAmount END AS SgstAmount,
		CASE WHEN tosdi.DocumentType = @DocumentTypeCRN THEN -tosdi.CessAmount ELSE tosdi.CessAmount END AS CessAmount
	INTO 
		#TempSaleDocumentsAmendment
	FROM 
		#TempSaleDocumentItems tsdi	
		INNER JOIN #TempOriginalSaleDocumentItems tosdi ON tsdi.SaleDocumentId = tosdi.Id		
		INNER JOIN oregular.SaleDocuments AS sd ON sd.Id = tsdi.SaleDocumentId		
		LEFT JOIN oregular.SaleDocumentContacts AS sdcf ON sd.Id = sdcf.SaleDocumentId AND sdcf.Type = @ContactTypeBillFrom		
		LEFT JOIN oregular.SaleDocumentContacts AS sdct ON sd.Id = sdct.SaleDocumentId AND sdct.Type = @ContactTypeBillTo; 

	/* Sales Summary Data */
	SELECT
		ss.Id,
		ss.SummaryType,
		CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
			 THEN -ss.AdvanceAmount 
			 ELSE 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADV 
				  THEN ss.AdvanceAmount 
				  ELSE ss.TaxableValue 
			 END 
		END AS TaxableValue,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.IgstAmountForFirstMonthOfQtr 
				  ELSE ss.IgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.IgstAmountForSecondMonthOfQtr 
				  ELSE ss.IgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN
			 CASE WHEN ss.IgstAmount IS NULL AND ss.IgstAmountForFirstMonthOfQtr IS NULL AND ss.IgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.IgstAmount,0) - (COALESCE(ss.IgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.IgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.IgstAmount,0) - (COALESCE(ss.IgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.IgstAmountForSecondMonthOfQtr,0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.IgstAmount 
				  ELSE ss.IgstAmount 
			 END 
		END AS IgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CgstAmountForFirstMonthOfQtr 
				  ELSE ss.CgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CgstAmountForSecondMonthOfQtr 
				  ELSE ss.CgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN
			 CASE WHEN ss.CgstAmount IS NULL AND ss.CgstAmountForFirstMonthOfQtr IS NULL AND ss.CgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.CgstAmount,0) - (COALESCE(ss.CgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.CgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.CgstAmount,0) - (COALESCE(ss.CgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.CgstAmountForSecondMonthOfQtr,0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CgstAmount 
				  ELSE ss.CgstAmount 
			 END 
		END AS CgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.SgstAmountForFirstMonthOfQtr 
				  ELSE ss.SgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.SgstAmountForSecondMonthOfQtr 
				  ELSE ss.SgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN
			 CASE WHEN ss.SgstAmount IS NULL AND ss.SgstAmountForFirstMonthOfQtr IS NULL AND ss.SgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.SgstAmount,0) - (COALESCE(ss.SgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.SgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.SgstAmount,0) - (COALESCE(ss.SgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.SgstAmountForSecondMonthOfQtr,0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.SgstAmount 
				  ELSE ss.SgstAmount 
			 END 
		END AS SgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CessAmountForFirstMonthOfQtr 
				  ELSE ss.CessAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CessAmountForSecondMonthOfQtr 
				  ELSE ss.CessAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN
			 CASE WHEN ss.CessAmount IS NULL AND ss.CessAmountForFirstMonthOfQtr IS NULL AND ss.CessAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.CessAmount,0) - (COALESCE(ss.CessAmountForFirstMonthOfQtr,0) + COALESCE(ss.CessAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.CessAmount,0) - (COALESCE(ss.CessAmountForFirstMonthOfQtr,0) + COALESCE(ss.CessAmountForSecondMonthOfQtr,0)) 
				  END 
			 END 
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CessAmount 
				  ELSE ss.CessAmount 
			 END 
		END AS CessAmount,	
		ss.GstActOrRuleSectionType,
		ss.GstActOrRuleTaxableValue,
		ss.GstActOrRuleIgstAmount,
		ss.GstActOrRuleCgstAmount,
		ss.GstActOrRuleSgstAmount,
		ss.GstActOrRuleCessAmount,
		ss.IsAmendment,
		ss.NilAmount,
		ss.ExemptAmount,
		ss.NonGstAmount,
		ss.GstActOrRuleNilAmount,
		ss.GstActOrRuleExemptAmount,
		ss.Rate,
		ss.Pos,
		ss.DifferentialPercentage,
		ss.Gstin AS ECommerceGstin,
		ss.OriginalReturnPeriod
	INTO
		#TempSaleSummary
	FROM
		oregular.SaleSummaries AS ss
		INNER JOIN oregular.SaleSummaryStatus AS sss ON ss.Id = sss.SaleSummaryId
	WHERE
		ss.SubscriberId = @SubscriberId
		AND ss.EntityId = @EntityId
		AND ss.ReturnPeriod = @ReturnPeriod
		AND ss.IsAmendment = @BitTypeN
		AND sss.[Status] = @DocumentStatusActive;

	CREATE TABLE #TempSaleSummaryAmendment
	(
		Id BIGINT,
		SummaryType SMALLINT,
		TaxableValue_A DECIMAL(18,2),
		IgstAmount_A DECIMAL(18,2),
		CgstAmount_A DECIMAL(18,2),
		SgstAmount_A DECIMAL(18,2),
		CessAmount_A DECIMAL(18,2),
		GstActOrRuleSectionType_A SMALLINT,
		GstActOrRuleTaxableValue_A DECIMAL(18,2),
		GstActOrRuleIgstAmount_A DECIMAL(18,2),
		GstActOrRuleCgstAmount_A DECIMAL(18,2),
		GstActOrRuleSgstAmount_A DECIMAL(18,2),
		GstActOrRuleCessAmount_A DECIMAL(18,2),
		NilAmount_A DECIMAL(18,2),
		ExemptAmount_A DECIMAL(18,2),
		NonGstAmount_A DECIMAL(18,2),
		GstActOrRuleNilAmount_A DECIMAL(18,2),
		GstActOrRuleExemptAmount_A DECIMAL(18,2),
		Rate DECIMAL(18,2),
		Pos SMALLINT,
		DifferentialPercentage DECIMAL(18,2),
		ECommerceGstin VARCHAR(15),
		ReturnPeriod INT,
		TaxableValue DECIMAL(18,2),
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2),
		GstActOrRuleTaxableValue DECIMAL(18,2),
		GstActOrRuleIgstAmount DECIMAL(18,2),
		GstActOrRuleCgstAmount DECIMAL(18,2),
		GstActOrRuleSgstAmount DECIMAL(18,2),
		GstActOrRuleCessAmount DECIMAL(18,2),
		NilAmount DECIMAL(18,2),
		ExemptAmount DECIMAL(18,2),
		NonGstAmount DECIMAL(18,2),
		GstActOrRuleNilAmount DECIMAL(18,2),
		GstActOrRuleExemptAmount DECIMAL(18,2)
	);

	INSERT INTO #TempSaleSummaryAmendment
	(
		Id,
		SummaryType,
		TaxableValue_A,
		IgstAmount_A,
		CgstAmount_A,
		SgstAmount_A,
		CessAmount_A,
		GstActOrRuleSectionType_A,
		GstActOrRuleTaxableValue_A,
		GstActOrRuleIgstAmount_A,
		GstActOrRuleCgstAmount_A,
		GstActOrRuleSgstAmount_A,
		GstActOrRuleCessAmount_A,
		NilAmount_A,
		ExemptAmount_A,
		NonGstAmount_A,
		GstActOrRuleNilAmount_A,
		GstActOrRuleExemptAmount_A,
		Rate,
		Pos,
		DifferentialPercentage,
		ECommerceGstin,
		ReturnPeriod,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount,
		GstActOrRuleTaxableValue,
		GstActOrRuleIgstAmount,
		GstActOrRuleCgstAmount,
		GstActOrRuleSgstAmount,
		GstActOrRuleCessAmount,
		NilAmount,
		ExemptAmount,
		NonGstAmount,
		GstActOrRuleNilAmount,
		GstActOrRuleExemptAmount
	)
	SELECT
		ss.Id,
		ss.SummaryType,
		CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
			 THEN -ss.AdvanceAmount 
			 ELSE 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADV 
				  THEN ss.AdvanceAmount 
				  ELSE ss.TaxableValue 
			 END 
		END AS TaxableValue_A,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.IgstAmountForFirstMonthOfQtr 
				  ELSE ss.IgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.IgstAmountForSecondMonthOfQtr 
				  ELSE ss.IgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN ss.IgstAmount IS NULL AND ss.IgstAmountForFirstMonthOfQtr IS NULL AND ss.IgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.IgstAmount,0) - (COALESCE(ss.IgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.IgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.IgstAmount,0) - (COALESCE(ss.IgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.IgstAmountForSecondMonthOfQtr,0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.IgstAmount 
				  ELSE ss.IgstAmount 
			 END 
		END AS IgstAmount_A,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CgstAmountForFirstMonthOfQtr 
				  ELSE ss.CgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CgstAmountForSecondMonthOfQtr 
				  ELSE ss.CgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN ss.CgstAmount IS NULL AND ss.CgstAmountForFirstMonthOfQtr IS NULL AND ss.CgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.CgstAmount,0) - (COALESCE(ss.CgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.CgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.CgstAmount,0) - (COALESCE(ss.CgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.CgstAmountForSecondMonthOfQtr,0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CgstAmount 
				  ELSE ss.CgstAmount 
			 END 
		END AS CgstAmount_A,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.SgstAmountForFirstMonthOfQtr 
				  ELSE ss.SgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.SgstAmountForSecondMonthOfQtr 
				  ELSE ss.SgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN ss.SgstAmount IS NULL AND ss.SgstAmountForFirstMonthOfQtr IS NULL AND ss.SgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.SgstAmount,0) - (COALESCE(ss.SgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.SgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.SgstAmount,0) - (COALESCE(ss.SgstAmountForFirstMonthOfQtr,0) + COALESCE(ss.SgstAmountForSecondMonthOfQtr,0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.SgstAmount 
				  ELSE ss.SgstAmount 
			 END 
		END AS SgstAmount_A,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CessAmountForFirstMonthOfQtr 
				  ELSE ss.CessAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CessAmountForSecondMonthOfQtr 
				  ELSE ss.CessAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN ss.CessAmount IS NULL AND ss.CessAmountForFirstMonthOfQtr IS NULL AND ss.CessAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(ss.CessAmount,0) - (COALESCE(ss.CessAmountForFirstMonthOfQtr,0) + COALESCE(ss.CessAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(ss.CessAmount,0) - (COALESCE(ss.CessAmountForFirstMonthOfQtr,0) + COALESCE(ss.CessAmountForSecondMonthOfQtr,0)) 
				  END 
			 END
			 ELSE
			 CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -ss.CessAmount 
				  ELSE ss.CessAmount 
			 END 
		END AS CessAmount_A,
		ss.GstActOrRuleSectionType,
		ss.GstActOrRuleTaxableValue,
		ss.GstActOrRuleIgstAmount,
		ss.GstActOrRuleCgstAmount,
		ss.GstActOrRuleSgstAmount,
		ss.GstActOrRuleCessAmount,
		ss.NilAmount,
		ss.ExemptAmount,
		ss.NonGstAmount,
		ss.GstActOrRuleNilAmount,
		ss.GstActOrRuleExemptAmount,
		ss.Rate,
		ss.Pos,
		ss.DifferentialPercentage,
		ss.Gstin AS ECommerceGstin,
		ss.ReturnPeriod,
		CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
			 THEN -sso.AdvanceAmount 
			 ELSE 
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADV 
				  THEN sso.AdvanceAmount 
				  ELSE sso.TaxableValue 
			 END 
		END AS TaxableValue,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType= @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.IgstAmountForFirstMonthOfQtr 
				  ELSE sso.IgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.IgstAmountForSecondMonthOfQtr 
				  ELSE sso.IgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN sso.IgstAmount IS NULL AND sso.IgstAmountForFirstMonthOfQtr IS NULL AND sso.IgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(sso.IgstAmount,0) - (COALESCE(sso.IgstAmountForFirstMonthOfQtr,0) + COALESCE(sso.IgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(sso.IgstAmount,0) - (COALESCE(sso.IgstAmountForFirstMonthOfQtr,0) + COALESCE(sso.IgstAmountForSecondMonthOfQtr,0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.IgstAmount 
				  ELSE sso.IgstAmount 
			 END 
		END AS IgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType= @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.CgstAmountForFirstMonthOfQtr 
				  ELSE sso.CgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.CgstAmountForSecondMonthOfQtr 
				  ELSE sso.CgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN sso.CgstAmount IS NULL AND sso.CgstAmountForFirstMonthOfQtr IS NULL AND sso.CgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(sso.CgstAmount,0) - (COALESCE(sso.CgstAmountForFirstMonthOfQtr,0) + COALESCE(sso.CgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(sso.CgstAmount,0) - (COALESCE(sso.CgstAmountForFirstMonthOfQtr,0) + COALESCE(sso.CgstAmountForSecondMonthOfQtr,0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.CgstAmount 
				  ELSE sso.CgstAmount 
			 END 
		END AS CgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType= @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.SgstAmountForFirstMonthOfQtr 
				  ELSE sso.SgstAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.SgstAmountForSecondMonthOfQtr 
				  ELSE sso.SgstAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN sso.SgstAmount IS NULL AND sso.SgstAmountForFirstMonthOfQtr IS NULL AND sso.SgstAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(sso.SgstAmount,0) - (COALESCE(sso.SgstAmountForFirstMonthOfQtr,0) + COALESCE(sso.SgstAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(sso.SgstAmount,0) - (COALESCE(sso.SgstAmountForFirstMonthOfQtr,0) + COALESCE(sso.SgstAmountForSecondMonthOfQtr,0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.SgstAmount 
				  ELSE sso.SgstAmount 
			 END 
		END AS SgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType= @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.CessAmountForFirstMonthOfQtr 
				  ELSE sso.CessAmountForFirstMonthOfQtr 
			 END
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY
			 THEN 
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.CessAmountForSecondMonthOfQtr 
				  ELSE sso.CessAmountForSecondMonthOfQtr 
			 END
			 WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN 
			 CASE WHEN sso.CessAmount IS NULL AND sso.CessAmountForFirstMonthOfQtr IS NULL AND sso.CessAmountForSecondMonthOfQtr IS NULL
				  THEN NULL
				  ELSE 
				  CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
					   THEN -(COALESCE(sso.CessAmount,0) - (COALESCE(sso.CessAmountForFirstMonthOfQtr,0) + COALESCE(sso.CessAmountForSecondMonthOfQtr,0))) 
					   ELSE COALESCE(sso.CessAmount,0) - (COALESCE(sso.CessAmountForFirstMonthOfQtr,0) + COALESCE(sso.CessAmountForSecondMonthOfQtr,0)) 
				  END
			 END
			 ELSE
			 CASE WHEN sso.SummaryType = @DocumentSummaryTypeGstr1ADVAJ 
				  THEN -sso.CessAmount 
				  ELSE sso.CessAmount 
			 END 
		END AS CessAmount,
		sso.GstActOrRuleTaxableValue,
		sso.GstActOrRuleIgstAmount,
		sso.GstActOrRuleCgstAmount,
		sso.GstActOrRuleSgstAmount,
		sso.GstActOrRuleCessAmount,
		sso.NilAmount,
		sso.ExemptAmount,
		sso.NonGstAmount,
		sso.GstActOrRuleNilAmount,
		sso.GstActOrRuleExemptAmount
	FROM
		oregular.SaleSummaries AS ss
		INNER JOIN oregular.SaleSummaryStatus AS sss ON ss.Id = sss.SaleSummaryId
		INNER JOIN oregular.SaleSummaries AS sso ON sso.EntityId = ss.EntityId 
				   AND sso.SummaryType = ss.SummaryType
				   AND sso.ReturnPeriod = ss.OriginalReturnPeriod 
				   AND COALESCE(sso.Gstin,'') = COALESCE(ss.Gstin,'')
				   AND COALESCE(sso.Rate,-1) = COALESCE(ss.Rate,-1) 
				   AND COALESCE(sso.Pos,-1) = COALESCE(ss.Pos,-1)
				   AND COALESCE(sso.DifferentialPercentage,-1) = COALESCE(ss.DifferentialPercentage,-1) 
				   AND COALESCE(sso.GstActOrRuleSectionType,-1) = COALESCE(ss.GstActOrRuleSectionType,-1)
		INNER JOIN oregular.SaleSummaryStatus AS ssso ON sso.Id = ssso.SaleSummaryId														  
	WHERE
		ss.SubscriberId = @SubscriberId						  
		AND ss.EntityId = @EntityId
		AND ss.ReturnPeriod = @ReturnPeriod
		AND ss.IsAmendment = @BitTypeY
		AND sss.Status = @DocumentStatusActive
		AND sso.IsAmendment = @BitTypeN
		AND ssso.Status = @DocumentStatusActive;
	
	/*Purchase Document Manual Data*/
	SELECT 
		Pr.PrId AS DocumentId,
		M.SectionType,
		M.Id AS MapperId,
		@SourceTypeTaxPayer AS SourceType
	INTO 
		#ManualMapperData
	FROM 
		oregular.PurchaseDocumentRecoManualMapper M
		OUTER APPLY OPENJSON(M.PrIds) WITH(PrId BIGINT '$.PrId') Pr
	WHERE 
		M.SubscriberId = @SubscriberId
		AND M.ParentEntityId = @EntityId
		AND M.ReconciliationType = @ReconciliationTypeGstr2B
	UNION
	SELECT 
		Gst.GstId,
		M.SectionType,
		M.Id AS MapperId,
		@SourceTypeCounterPartyFiled AS SourceType
	FROM 
		oregular.PurchaseDocumentRecoManualMapper M
		OUTER APPLY OPENJSON(M.GstIds) WITH(GstId BIGINT '$.GstId') Gst
	WHERE 
		M.SubscriberId = @SubscriberId
		AND M.ParentEntityId = @EntityId
		AND M.ReconciliationType = @ReconciliationTypeGstr2B;

	/*Purchase Documents Data With Filtered Paramaters*/
	SELECT 
		mmd.MapperId,
		mmd.SourceType AS ManualSourceType,
		mmd.DocumentId,
		pd.Id,
		pd.EntityId,
		pd.SourceType, 
		pd.DocumentType,
		pd.CombineDocumentType,
		pd.TransactionType,
		pd.ReverseCharge,
		pd.BillFromGstin,
		pd.IsAmendment,
		pd.OriginalDocumentNumber,
		pd.OriginalDocumentDate,
		pds.Gstr2BReturnPeriod,
		COALESCE(mmd.SectionType, gdrmcp.SectionType, gdrmpr.SectionType, gdrmcpboe.SectionType, gdrmprboe.SectionType) AS ReconciliationSectionType,
		pds.ItcAvailability,
		pds.IsAvailableInGstr2B,
		pds.ItcClaimReturnPeriod,
		pds.LiabilityDischargeReturnPeriod
	INTO 
		#TempPurchaseDocumentIds
	FROM 
		oregular.PurchaseDocumentDW pd	
		INNER JOIN oregular.PurchaseDocumentStatus AS pds ON pd.Id = pds.PurchaseDocumentId
		LEFT JOIN oregular.Gstr2bDocumentRecoMapper AS gdrmcp ON gdrmcp.GstnId = pd.Id
		LEFT JOIN oregular.Gstr2bDocumentRecoMapper AS gdrmpr ON gdrmpr.PrId = pd.Id
		LEFT JOIN oregular.Gstr2aDocumentRecoMapper AS gdrmcpboe ON gdrmcpboe.GstnId = pd.Id
		LEFT JOIN oregular.Gstr2aDocumentRecoMapper AS gdrmprboe ON gdrmprboe.PrId = pd.Id
		LEFT JOIN #ManualMapperData mmd ON pd.Id = mmd.DocumentId
	WHERE						
		pd.SubscriberId = @SubscriberId
		AND pd.ParentEntityId = @EntityId
		AND pd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE)						
		AND pds.Status = @DocumentStatusActive
		AND (
				(
					(
						pds.ItcClaimReturnPeriod = @ReturnPeriod
						OR 
						pds.LiabilityDischargeReturnPeriod = @ReturnPeriod
						OR 
						(pd.ReturnPeriod = @ReturnPeriod AND pds.LiabilityDischargeReturnPeriod IS NULL AND pds.ItcClaimReturnPeriod IS NULL)
					)
					AND pd.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeIMPS,@TransactionTypeCBW,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeDE,@TransactionTypeIMPG)
				)
				OR
				(
					pds.IsAvailableInGstr2B = @BitTypeY
					AND pds.Gstr2BReturnPeriod = @ReturnPeriod 
				)
			);

	SELECT 
		tp.Id 
	INTO 
		#TempMapper
	FROM 
		#TempPurchaseDocumentIds tp
		INNER JOIN oregular.Gstr2bDocumentRecoMapper AS gdrm ON gdrm.GstnId = tp.Id 
	WHERE 
		gdrm.SectionType IN (@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMisMatched, @ReconciliationSectionTypeNearMatched, @ReconciliationSectionTypeMatchedDueToTolerance)
	UNION
	SELECT 
		tp.Id 	
	FROM 
		#TempPurchaseDocumentIds tp
		INNER JOIN oregular.Gstr2aDocumentRecoMapper AS gdrm ON gdrm.GstnId = tp.Id 
	WHERE 
		tp.DocumentType = @DocumentTypeBOE
		AND gdrm.SectionType IN (@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMisMatched, @ReconciliationSectionTypeNearMatched, @ReconciliationSectionTypeMatchedDueToTolerance);

	/* Purchase Document Items */
	CREATE TABLE #TempPurchaseDocumentItems
	(
		PurchaseDocumentId BIGINT,
		ItcEligibility SMALLINT,
		GstActOrRuleSection SMALLINT,
		TaxableValue DECIMAL(18,2),
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2),
		ItcIgstAmount DECIMAL(18,2),
		ItcCgstAmount DECIMAL(18,2),
		ItcSgstAmount DECIMAL(18,2),
		ItcCessAmount DECIMAL(18,2)
	)		

	INSERT INTO #TempPurchaseDocumentItems
	(
		PurchaseDocumentId,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)		
	SELECT
		pdi.PurchaseDocumentId,
		SUM(pdi.TaxableValue) AS TaxableValue,
		SUM(pdi.IgstAmount) AS IgstAmount,
		SUM(pdi.CgstAmount) AS CgstAmount,
		SUM(pdi.SgstAmount) AS SgstAmount,
		SUM(pdi.CessAmount) AS CessAmount
	FROM
		oregular.PurchaseDocumentItems AS pdi
		INNER JOIN #TempPurchaseDocumentIds tp ON tp.Id = pdi.PurchaseDocumentId
	WHERE				
		tp.SourceType IN (@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled) 
		AND tp.ReconciliationSectionType IN (@ReconciliationSectionTypeGstOnly,@ReconciliationSectionTypeGstExcluded,@ReconciliationSectionTypeGstDiscarded)
		AND NOT EXISTS (SELECT * FROM #TempMapper t where t.Id = tp.Id)
	GROUP BY 
		pdi.PurchaseDocumentId;

	INSERT INTO #TempPurchaseDocumentItems
	(
		PurchaseDocumentId,
		ItcEligibility,
		GstActOrRuleSection,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount,
		ItcIgstAmount,
		ItcCgstAmount,
		ItcSgstAmount,
		ItcCessAmount
	)		
	SELECT
		pdi.PurchaseDocumentId,
		pdi.ItcEligibility,
		pdi.GstActOrRuleSection,
		SUM(pdi.TaxableValue) AS TaxableValue,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo OR tp.ReverseCharge = @BitTypeY THEN pdi.IgstAmount ELSE 0 END) AS IgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo OR tp.ReverseCharge = @BitTypeY THEN pdi.CgstAmount ELSE 0 END) AS CgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo OR tp.ReverseCharge = @BitTypeY THEN pdi.SgstAmount ELSE 0 END) AS SgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo OR tp.ReverseCharge = @BitTypeY THEN pdi.CessAmount ELSE 0 END) AS CessAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdi.ItcIgstAmount END) AS ItcIgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdi.ItcCgstAmount END) AS ItcCgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdi.ItcSgstAmount END) AS ItcSgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdi.ItcCessAmount END) AS ItcCessAmount
	FROM
		oregular.PurchaseDocumentItems AS pdi
		INNER JOIN #TempPurchaseDocumentIds tp ON tp.Id = pdi.PurchaseDocumentId
	WHERE 
		tp.SourceType = @SourceTypeTaxPayer 
		AND 
		(
			(
				tp.ReconciliationSectionType IS NULL 
				AND 
				(
					tp.TransactionType IN (@TransactionTypeB2C,@TransactionTypeCBW,@TransactionTypeIMPS)
					OR
					(
						tp.TransactionType IN (@TransactionTypeB2B,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeDE)
						AND tp.ReverseCharge = @BitTypeY
					)
				)
			)
			OR
			tp.ReconciliationSectionType IN (@ReconciliationSectionTypePROnly, @ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance,@ReconciliationSectionTypeMisMatched,@ReconciliationSectionTypeNearMatched,@ReconciliationSectionTypePRExcluded,@ReconciliationSectionTypePRDiscarded)
		)
	GROUP BY 
		pdi.PurchaseDocumentId,
		pdi.ItcEligibility,
		pdi.GstActOrRuleSection;

	/* Purchase Documents Data*/
	SELECT
		pd.Id,
		pd.SourceType,
		pd.DocumentNumber,
		pd.DocumentDate,
		pd.DocumentType,
		pd.DocumentValue,
		pd.ReturnPeriod,
		pd.TaxpayerType,
		pd.TransactionType,
		pd.ReverseCharge,
		pd.Pos,
		pd.PortCode,
		tp.BillFromGstin,
		CASE WHEN LEN(tp.BillFromGstin) = 10 THEN @BitTypeY ELSE @BitTypeN END IsBillFromPAN,
		tp.Gstr2BReturnPeriod,
		tp.ReconciliationSectionType,
		pds.Action,
		pds.ItcAvailability,
		pds.IsAvailableInGstr2B,
		pds.ItcClaimReturnPeriod,
		pds.LiabilityDischargeReturnPeriod,
		tpdi.GstActOrRuleSection,
		tpdi.ItcEligibility,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.TaxableValue ELSE tpdi.TaxableValue END AS TaxableValue,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.IgstAmount ELSE tpdi.IgstAmount END AS IgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CgstAmount ELSE tpdi.CgstAmount END AS CgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.SgstAmount ELSE tpdi.SgstAmount END AS SgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CessAmount ELSE tpdi.CessAmount END AS CessAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcIgstAmount ELSE tpdi.ItcIgstAmount END AS ItcIgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCgstAmount ELSE tpdi.ItcCgstAmount END AS ItcCgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcSgstAmount ELSE tpdi.ItcSgstAmount END AS ItcSgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCessAmount ELSE tpdi.ItcCessAmount END AS ItcCessAmount,
		COALESCE(pd.ModifiedStamp, pd.Stamp) AS Stamp
	INTO 
		#TempPurchaseDocuments
	FROM 
		#TempPurchaseDocumentIds tp
		INNER JOIN #TempPurchaseDocumentItems tpdi ON tpdi.PurchaseDocumentId = tp.Id	
		INNER JOIN oregular.PurchaseDocuments AS pd ON pd.Id = tp.Id
		INNER JOIN oregular.PurchaseDocumentStatus AS pds ON pd.Id = pds.PurchaseDocumentId
	WHERE
		tp.IsAmendment = @BitTypeN;

	/* Original Purchase Document Items */
	SELECT 		
		tpd.Id,					
		pdo.DocumentType,
		pdso.ItcAvailability,
		pdso.ItcClaimReturnPeriod,
		pdio.ItcEligibility,
		pdio.GstActOrRuleSection,
		pdo.TotalTaxAmount,
		SUM(pdio.TaxableValue) AS TaxableValue,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo OR pdo.ReverseCharge = @BitTypeY THEN pdio.IgstAmount ELSE 0 END) AS IgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo OR pdo.ReverseCharge = @BitTypeY THEN pdio.CgstAmount ELSE 0 END) AS CgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo OR pdo.ReverseCharge = @BitTypeY THEN pdio.SgstAmount ELSE 0 END) AS SgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo OR pdo.ReverseCharge = @BitTypeY THEN pdio.CessAmount ELSE 0 END) AS CessAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdio.ItcIgstAmount END) AS ItcIgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdio.ItcCgstAmount END) AS ItcCgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdio.ItcSgstAmount END) AS ItcSgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN 0 ELSE pdio.ItcCessAmount END) AS ItcCessAmount
	INTO
		#TempOriginalPurchaseDocumentItems
	FROM 				
		#TempPurchaseDocumentIds tpd
		INNER JOIN oregular.PurchaseDocumentDW pdo ON tpd.OriginalDocumentNumber = pdo.DocumentNumber AND tpd.OriginalDocumentDate = pdo.DocumentDate AND COALESCE(pdo.BillFromGstin,'') = COALESCE(tpd.BillFromGstin,'')
		INNER JOIN oregular.PurchaseDocumentStatus pdso on pdo.Id = pdso.PurchaseDocumentId
		INNER JOIN oregular.PurchaseDocumentItems pdio ON pdo.Id = pdio.PurchaseDocumentId
	WHERE 
		pdo.SubscriberId = @SubscriberId
		AND pdo.ParentEntityId = tpd.EntityId
		AND pdo.SourceType = tpd.SourceType									
		AND pdo.CombineDocumentType = tpd.CombineDocumentType
		AND pdo.IsAmendment = @BitTypeN			
		AND pdo.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeIMPS,@TransactionTypeCBW,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeDE,@TransactionTypeIMPG)
		AND pdso.Status = @DocumentStatusActive
		AND tpd.IsAmendment = @BitTypeY	
	GROUP BY 
		tpd.Id,		
		pdo.DocumentType,
		pdso.ItcAvailability,
		pdso.ItcClaimReturnPeriod,
		pdio.ItcEligibility,
		pdio.GstActOrRuleSection,
		pdo.TotalTaxAmount;

	/* Purchase Documents Amendment Data */
	SELECT
		pd.Id,
		pd.DocumentNumber,
		pd.DocumentDate,
		pd.DocumentType AS DocumentType_A, -- Amendment DocumentType
		topdi.DocumentType, -- Original DocumentType
		pd.DocumentValue,
		pd.TaxpayerType,
		pd.TransactionType,
		pd.SourceType,
		pd.ReverseCharge,
		pd.Pos,
		pd.PortCode,
		pd.ReturnPeriod,
		pd.IsAmendment,
		pd.OriginalDocumentNumber,
		pd.OriginalDocumentDate,
		pd.OriginalPortCode,
		tpd.BillFromGstin,
		tpd.ReconciliationSectionType,
		tpd.ItcAvailability,
		tpd.Gstr2BReturnPeriod,
		tpd.IsAvailableInGstr2B,
		tpd.ItcClaimReturnPeriod,
		tpd.LiabilityDischargeReturnPeriod,
		tpdi.ItcEligibility,
		tpdi.GstActOrRuleSection,
		CASE WHEN LEN(tpd.BillFromGstin) = 10 THEN @BitTypeY ELSE @BitTypeN END IsBillFromPAN,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.TaxableValue ELSE tpdi.TaxableValue END AS TaxableValue_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.IgstAmount ELSE tpdi.IgstAmount END AS IgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CgstAmount ELSE tpdi.CgstAmount END AS CgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.SgstAmount ELSE tpdi.SgstAmount END AS SgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CessAmount ELSE tpdi.CessAmount END AS CessAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcIgstAmount ELSE tpdi.ItcIgstAmount END AS ItcIgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCgstAmount ELSE tpdi.ItcCgstAmount END AS ItcCgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcSgstAmount ELSE tpdi.ItcSgstAmount END AS ItcSgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCessAmount ELSE tpdi.ItcCessAmount END AS ItcCessAmount_A,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.TaxableValue ELSE topdi.TaxableValue END AS TaxableValue,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.IgstAmount ELSE topdi.IgstAmount END AS IgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CgstAmount ELSE topdi.CgstAmount END AS CgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.SgstAmount ELSE topdi.SgstAmount END AS SgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CessAmount ELSE topdi.CessAmount END AS CessAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcIgstAmount ELSE topdi.ItcIgstAmount END AS ItcIgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcCgstAmount ELSE topdi.ItcCgstAmount END AS ItcCgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcSgstAmount ELSE topdi.ItcSgstAmount END AS ItcSgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcCessAmount ELSE topdi.ItcCessAmount END AS ItcCessAmount,
		COALESCE(pd.ModifiedStamp,pd.Stamp) AS Stamp
	INTO 
		#TempPurchaseDocumentsAmendment
	FROM 
		#TempPurchaseDocumentIds tpd
		INNER JOIN #TempPurchaseDocumentItems tpdi ON tpdi.PurchaseDocumentId = tpd.Id	
		INNER JOIN #TempOriginalPurchaseDocumentItems topdi ON tpdi.PurchaseDocumentId = topdi.Id AND tpdi.ItcEligibility = topdi.ItcEligibility
		INNER JOIN oregular.PurchaseDocuments pd ON pd.Id = tpdi.PurchaseDocumentId;

	/* Original Purchase Document Items For Circluar 170  */
	SELECT 		
		tpd.Id,					
		pdo.DocumentType,
		pdso.ItcAvailability,
		pdso.ItcClaimReturnPeriod,
		SUM(pdio.TaxableValue) AS TaxableValue,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN pdio.IgstAmount ELSE NULL END) AS IgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN pdio.CgstAmount ELSE NULL END) AS CgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN pdio.SgstAmount ELSE NULL END) AS SgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN pdio.CessAmount ELSE NULL END) AS CessAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdio.ItcIgstAmount END) AS ItcIgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdio.ItcCgstAmount END) AS ItcCgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdio.ItcSgstAmount END) AS ItcSgstAmount,
		SUM(CASE WHEN pdio.ItcEligibility IS NULL OR pdio.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdio.ItcCessAmount END) AS ItcCessAmount,
		SUM(CASE WHEN pdio.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdio.IgstAmount ELSE NULL END) AS IgstAmount_175,
		SUM(CASE WHEN pdio.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdio.CgstAmount ELSE NULL END) AS CgstAmount_175,
		SUM(CASE WHEN pdio.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdio.SgstAmount ELSE NULL END) AS SgstAmount_175,
		SUM(CASE WHEN pdio.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdio.CessAmount ELSE NULL END) AS CessAmount_175,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.IgstAmount ELSE NULL END) AS IgstAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.CgstAmount ELSE NULL END) AS CgstAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.SgstAmount ELSE NULL END) AS SgstAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.CessAmount ELSE NULL END) AS CessAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.ItcIgstAmount ELSE NULL END) AS ItcIgstAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.ItcCgstAmount ELSE NULL END) AS ItcCgstAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.ItcSgstAmount ELSE NULL END) AS ItcSgstAmount_38_42_43,
		SUM(CASE WHEN pdio.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdio.ItcCessAmount ELSE NULL END) AS ItcCessAmount_38_42_43
	INTO
		#TempOriginalPurchaseDocumentItemsCircular170
	FROM 				
		#TempPurchaseDocumentIds tpd
		INNER JOIN oregular.PurchaseDocumentDW pdo ON tpd.OriginalDocumentNumber = pdo.DocumentNumber AND tpd.OriginalDocumentDate = pdo.DocumentDate AND COALESCE(pdo.BillFromGstin,'') = COALESCE(tpd.BillFromGstin,'')
		INNER JOIN oregular.PurchaseDocumentStatus pdso on pdo.Id = pdso.PurchaseDocumentId
		INNER JOIN oregular.PurchaseDocumentItems pdio ON pdo.Id = pdio.PurchaseDocumentId
	WHERE 
		pdo.SubscriberId = @SubscriberId
		AND pdo.ParentEntityId = tpd.EntityId
		AND pdo.SourceType = tpd.SourceType									
		AND pdo.CombineDocumentType = tpd.CombineDocumentType
		AND pdo.IsAmendment = @BitTypeN			
		AND pdo.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeIMPS,@TransactionTypeCBW,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeDE,@TransactionTypeIMPG)
		AND pdso.[Status] = @DocumentStatusActive
		AND tpd.IsAmendment = @BitTypeY	
	GROUP BY 
		tpd.Id,		
		pdo.DocumentType,
		pdso.ItcAvailability,
		pdso.ItcClaimReturnPeriod;
		
	/* Purchase Document Items For Circluar 170 */
	SELECT
		pdi.PurchaseDocumentId,
		SUM(pdi.TaxableValue) AS TaxableValue,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN pdi.IgstAmount ELSE NULL END) AS IgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN pdi.CgstAmount ELSE NULL END) AS CgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN pdi.SgstAmount ELSE NULL END) AS SgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN pdi.CessAmount ELSE NULL END) AS CessAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdi.ItcIgstAmount END) AS ItcIgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdi.ItcCgstAmount END) AS ItcCgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdi.ItcSgstAmount END) AS ItcSgstAmount,
		SUM(CASE WHEN pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdi.ItcCessAmount END) AS ItcCessAmount,
		SUM(CASE WHEN pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdi.IgstAmount ELSE NULL END) AS IgstAmount_175,
		SUM(CASE WHEN pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdi.CgstAmount ELSE NULL END) AS CgstAmount_175,
		SUM(CASE WHEN pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdi.SgstAmount ELSE NULL END) AS SgstAmount_175,
		SUM(CASE WHEN pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdi.CessAmount ELSE NULL END) AS CessAmount_175,
		SUM(CASE WHEN pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdi.ItcIgstAmount ELSE NULL END) AS ItcIgstAmount_38_42_43,
		SUM(CASE WHEN pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdi.ItcCgstAmount ELSE NULL END) AS ItcCgstAmount_38_42_43,
		SUM(CASE WHEN pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdi.ItcSgstAmount ELSE NULL END) AS ItcSgstAmount_38_42_43,
		SUM(CASE WHEN pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdi.ItcCessAmount ELSE NULL END) AS ItcCessAmount_38_42_43
	INTO
		#TempPurchaseDocumentItemsCircular170
	FROM
		oregular.PurchaseDocumentItems AS pdi
		INNER JOIN #TempPurchaseDocumentIds tp ON tp.Id = pdi.PurchaseDocumentId
	WHERE 
		tp.ReconciliationSectionType IN (@ReconciliationSectionTypeGstOnly,@ReconciliationSectionTypeGstExcluded,@ReconciliationSectionTypeGstDiscarded, @ReconciliationSectionTypeMatched, 
		@ReconciliationSectionTypeMatchedDueToTolerance,@ReconciliationSectionTypeMisMatched,@ReconciliationSectionTypeNearMatched)
	GROUP BY 
		pdi.PurchaseDocumentId;

	/* Purchase Documents Data*/
	SELECT
		pd.Id,
		pd.SourceType,
		pd.DocumentNumber,
		pd.DocumentDate,
		pd.DocumentType,
		pd.DocumentValue,
		pd.ReturnPeriod,
		pd.TaxpayerType,
		pd.TransactionType,
		pd.ReverseCharge,
		pd.Pos,
		pd.PortCode,
		tp.BillFromGstin,
		CASE WHEN LEN(tp.BillFromGstin) = 10 THEN @BitTypeY ELSE @BitTypeN END IsBillFromPAN,
		tp.Gstr2BReturnPeriod,
		tp.ReconciliationSectionType,
		tp.ItcAvailability,
		tp.IsAvailableInGstr2B,
		tp.ItcClaimReturnPeriod,
		tp.LiabilityDischargeReturnPeriod,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -(COALESCE(tpdi.IgstAmount,0) + COALESCE(tpdi.CgstAmount,0) + COALESCE(tpdi.SgstAmount,0) + COALESCE(tpdi.CessAmount,0)) 
			 ELSE (COALESCE(tpdi.IgstAmount,0) + COALESCE(tpdi.CgstAmount,0) + COALESCE(tpdi.SgstAmount,0) + COALESCE(tpdi.CessAmount,0)) END AS TotalTaxAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.TaxableValue ELSE tpdi.TaxableValue END AS TaxableValue,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.IgstAmount ELSE tpdi.IgstAmount END AS IgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CgstAmount ELSE tpdi.CgstAmount END AS CgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.SgstAmount ELSE tpdi.SgstAmount END AS SgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CessAmount ELSE tpdi.CessAmount END AS CessAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -(COALESCE(tpdi.IgstAmount_175,0) + COALESCE(tpdi.CgstAmount_175,0) + COALESCE(tpdi.SgstAmount_175,0) + COALESCE(tpdi.CessAmount_175,0)) 
			 ELSE (COALESCE(tpdi.IgstAmount_175,0) + COALESCE(tpdi.CgstAmount_175,0) + COALESCE(tpdi.SgstAmount_175,0) + COALESCE(tpdi.CessAmount_175,0)) END AS TotalTaxAmount_175,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.IgstAmount_175 ELSE tpdi.IgstAmount_175 END AS IgstAmount_175,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CgstAmount_175 ELSE tpdi.CgstAmount_175 END AS CgstAmount_175,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.SgstAmount_175 ELSE tpdi.SgstAmount_175 END AS SgstAmount_175,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CessAmount_175 ELSE tpdi.CessAmount_175 END AS CessAmount_175,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -(COALESCE(tpdi.ItcIgstAmount,0) + COALESCE(tpdi.ItcCgstAmount,0) + COALESCE(tpdi.ItcSgstAmount,0) + COALESCE(tpdi.ItcCessAmount,0)) 
			 ELSE (COALESCE(tpdi.ItcIgstAmount,0) + COALESCE(tpdi.ItcCgstAmount,0) + COALESCE(tpdi.ItcSgstAmount,0) + COALESCE(tpdi.ItcCessAmount,0)) END AS TotalItcAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcIgstAmount ELSE tpdi.ItcIgstAmount END AS ItcIgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCgstAmount ELSE tpdi.ItcCgstAmount END AS ItcCgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcSgstAmount ELSE tpdi.ItcSgstAmount END AS ItcSgstAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCessAmount ELSE tpdi.ItcCessAmount END AS ItcCessAmount,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -(COALESCE(tpdi.ItcIgstAmount_38_42_43,0) + COALESCE(tpdi.ItcCgstAmount_38_42_43,0) + COALESCE(tpdi.ItcSgstAmount_38_42_43,0) + COALESCE(tpdi.ItcCessAmount_38_42_43,0)) 
			 ELSE (COALESCE(tpdi.ItcIgstAmount_38_42_43,0) + COALESCE(tpdi.ItcCgstAmount_38_42_43,0) + COALESCE(tpdi.ItcSgstAmount_38_42_43,0) + COALESCE(tpdi.ItcCessAmount_38_42_43,0)) END AS TotalItcAmount_38_42_43,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcIgstAmount_38_42_43 ELSE tpdi.ItcIgstAmount_38_42_43 END AS ItcIgstAmount_38_42_43,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCgstAmount_38_42_43 ELSE tpdi.ItcCgstAmount_38_42_43 END AS ItcCgstAmount_38_42_43,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcSgstAmount_38_42_43 ELSE tpdi.ItcSgstAmount_38_42_43 END AS ItcSgstAmount_38_42_43,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCessAmount_38_42_43 ELSE tpdi.ItcCessAmount_38_42_43 END AS ItcCessAmount_38_42_43,
		COALESCE(pd.ModifiedStamp, pd.Stamp) AS Stamp
	INTO
		#TempPurchaseDocumentsCircular170
	FROM 
		#TempPurchaseDocumentIds tp
		INNER JOIN #TempPurchaseDocumentItemsCircular170 tpdi ON tpdi.PurchaseDocumentId = tp.Id	
		INNER JOIN oregular.PurchaseDocuments AS pd ON pd.Id = tp.Id
	WHERE
		tp.IsAmendment = @BitTypeN
		AND tp."MapperId" IS NULL;

	CREATE INDEX Idx_TempPurchaseDocumentsCircular170_Id ON #TempPurchaseDocumentsCircular170(Id);

	SELECT
		tp.MapperId,
		tp.ManualSourceType,
		CASE WHEN tp.ItcClaimReturnPeriod IS NULL THEN tp.Gstr2BReturnPeriod ELSE NULL END AS Gstr2BReturnPeriod,
		tp.ItcClaimReturnPeriod,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod = @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.IgstAmount 
							ELSE pdi.IgstAmount 
						END)
				 ELSE NULL 
			END) AS CpIgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod = @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CgstAmount 
							ELSE pdi.CgstAmount 
						END)
				 ELSE NULL 
			END) AS CpCgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod = @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.SgstAmount 
							ELSE pdi.SgstAmount 
						END)
				 ELSE NULL 
			END) AS CpSgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod = @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CessAmount 
							ELSE pdi.CessAmount 
						END)
				 ELSE NULL 
			END) AS CpCessAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod <> @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.IgstAmount 
							ELSE pdi.IgstAmount 
						END)
				 ELSE NULL 
			END) AS PrevCpIgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod <> @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CgstAmount 
							ELSE pdi.CgstAmount 
						END)
				 ELSE NULL 
			END) AS PrevCpCgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod <> @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.SgstAmount 
							ELSE pdi.SgstAmount 
						END)
				 ELSE NULL 
			END) AS PrevCpSgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.Gstr2BReturnPeriod <> @ReturnPeriod
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CessAmount 
							ELSE pdi.CessAmount 
						END)
				 ELSE NULL 
			END) AS PrevCpCessAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.IgstAmount 
							ELSE pdi.IgstAmount 
						END) 
				 ELSE NULL 
			END) AS IgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CgstAmount 
							ELSE pdi.CgstAmount 
						END) 
				 ELSE NULL 
			END) AS CgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.SgstAmount 
							ELSE pdi.SgstAmount 
						END) 
				 ELSE NULL 
			END) AS SgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CessAmount 
							ELSE pdi.CessAmount 
						END) 
				 ELSE NULL 
			END) AS CessAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN NULL 
				 ELSE (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcIgstAmount 
							ELSE pdi.ItcIgstAmount 
						END) 
			END) AS ItcIgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN NULL 
				 ELSE (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcCgstAmount 
							ELSE pdi.ItcCgstAmount 
						END) 
			END) AS ItcCgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN NULL 
				 ELSE (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcSgstAmount 
							ELSE pdi.ItcSgstAmount 
						END) 
			END) AS ItcSgstAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND (pdi.ItcEligibility IS NULL OR pdi.ItcEligibility = @ItcEligibilityNo) 
				 THEN NULL 
				 ELSE (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcCessAmount 
							ELSE pdi.ItcCessAmount 
						END) 
			END) AS ItcCessAmount,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.IgstAmount 
							ELSE pdi.IgstAmount 
						END) 
				 ELSE NULL 
			END) AS IgstAmount_175,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CgstAmount 
							ELSE pdi.CgstAmount 
						END) 
				 ELSE NULL 
			END) AS CgstAmount_175,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.SgstAmount 
							ELSE pdi.SgstAmount 
						END) 
				 ELSE NULL 
			END) AS SgstAmount_175,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.CessAmount 
							ELSE pdi.CessAmount 
						END) 
				 ELSE NULL 
			END) AS CessAmount_175,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcIgstAmount 
							ELSE pdi.ItcIgstAmount 
						END) 
				 ELSE NULL 
			END) AS ItcIgstAmount_38_42_43,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcCgstAmount 
							ELSE pdi.ItcCgstAmount 
						END) 
				 ELSE NULL 
			END) AS ItcCgstAmount_38_42_43,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcSgstAmount 
							ELSE pdi.ItcSgstAmount 
						END) 
				 ELSE NULL 
			END) AS ItcSgstAmount_38_42_43,
		SUM(CASE WHEN tp.ManualSourceType = @SourceTypeTaxPayer AND pdi.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) 
				 THEN (CASE WHEN tp.DocumentType = @DocumentTypeCRN 
							THEN -pdi.ItcCessAmount 
							ELSE pdi.ItcCessAmount 
						END) 
				 ELSE NULL 
			END) AS ItcCessAmount_38_42_43
	INTO 
		#TempManualPurchaseDocumentItemsCircular170
	FROM
		oregular.PurchaseDocumentItems AS pdi
		INNER JOIN #TempPurchaseDocumentIds tp ON tp.Id = pdi.PurchaseDocumentId
	WHERE 
		tp.ReconciliationSectionType IN (@ReconciliationSectionTypeMatched,@ReconciliationSectionTypeMatchedDueToTolerance,@ReconciliationSectionTypeMisMatched,@ReconciliationSectionTypeNearMatched)
		AND tp.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tp.ReverseCharge = @BitTypeN
		AND 
		(
			tp.ManualSourceType = @SourceTypeTaxPayer
			OR
			(tp.ManualSourceType = @SourceTypeCounterPartyFiled AND tp.ItcAvailability = @ItcAvailabilityTypeY)
		)
	GROUP BY 
		tp.MapperId,
		tp.ManualSourceType,		
		CASE WHEN tp.ItcClaimReturnPeriod IS NULL THEN tp.Gstr2BReturnPeriod ELSE NULL END,
		tp.ItcClaimReturnPeriod;

	/* Manual Purchase Documents Data*/
	SELECT DISTINCT
		tp.MapperId,
		tp.ManualSourceType,
		tpdi.Gstr2BReturnPeriod,
		tpdi.ItcClaimReturnPeriod,
		(COALESCE(tpdi.CpIgstAmount,0) + COALESCE(tpdi.CpCgstAmount,0) + COALESCE(tpdi.CpSgstAmount,0) + COALESCE(tpdi.CpCessAmount,0)) AS CpTotalTaxAmount,
		tpdi.CpIgstAmount,
		tpdi.CpCgstAmount,
		tpdi.CpSgstAmount,
		tpdi.CpCessAmount,
		(COALESCE(tpdi.PrevCpIgstAmount,0) + COALESCE(tpdi.PrevCpCgstAmount,0) + COALESCE(tpdi.PrevCpSgstAmount,0) + COALESCE(tpdi.PrevCpCessAmount,0)) AS PrevCpTotalTaxAmount,
		tpdi.PrevCpIgstAmount,
		tpdi.PrevCpCgstAmount,
		tpdi.PrevCpSgstAmount,
		tpdi.PrevCpCessAmount,
		(COALESCE(tpdi.IgstAmount,0) + COALESCE(tpdi.CgstAmount,0) + COALESCE(tpdi.SgstAmount,0) + COALESCE(tpdi.CessAmount,0)) AS TotalTaxAmount,
		tpdi.IgstAmount,
		tpdi.CgstAmount,
		tpdi.SgstAmount,
		tpdi.CessAmount,
		(COALESCE(tpdi.IgstAmount_175,0) + COALESCE(tpdi.CgstAmount_175,0) + COALESCE(tpdi.SgstAmount_175,0) + COALESCE(tpdi.CessAmount_175,0)) AS TotalTaxAmount_175,
		tpdi.IgstAmount_175,
		tpdi.CgstAmount_175,
		tpdi.SgstAmount_175,
		tpdi.CessAmount_175,
		(COALESCE(tpdi.ItcIgstAmount,0) + COALESCE(tpdi.ItcCgstAmount,0) + COALESCE(tpdi.ItcSgstAmount,0) + COALESCE(tpdi.ItcCessAmount,0)) AS TotalItcAmount,
		tpdi.ItcIgstAmount,
		tpdi.ItcCgstAmount,
		tpdi.ItcSgstAmount,
		tpdi.ItcCessAmount,
		(COALESCE(tpdi.ItcIgstAmount_38_42_43,0) + COALESCE(tpdi.ItcCgstAmount_38_42_43,0) + COALESCE(tpdi.ItcSgstAmount_38_42_43,0) + COALESCE(tpdi.ItcCessAmount_38_42_43,0)) AS TotalItcAmount_38_42_43,
		tpdi.ItcIgstAmount_38_42_43,
		tpdi.ItcCgstAmount_38_42_43,
		tpdi.ItcSgstAmount_38_42_43,
		tpdi.ItcCessAmount_38_42_43
	INTO 
		#TempManualPurchaseDocumentsCircular170
	FROM 
		#TempPurchaseDocumentIds tp
		INNER JOIN #TempManualPurchaseDocumentItemsCircular170 tpdi ON tpdi.MapperId = tp.MapperId	AND tp.ManualSourceType = tpdi.ManualSourceType
		LEFT JOIN oregular.PurchaseDocuments AS pd ON pd.Id = tp.DocumentId AND tp.ManualSourceType = @SourceTypeCounterPartyFiled
	WHERE
		tp.IsAmendment = @BitTypeN
		AND tp.MapperId IS NOT NULL
		AND (pd.TaxpayerType IS NULL OR pd.TaxpayerType <> @TaxPayerTypeISD);

	CREATE INDEX Idx_TempManualPurchaseDocumentsCircular170_Id ON #TempManualPurchaseDocumentsCircular170(MapperId);
	
	/* Original Pr Purchase Document Items */
	SELECT 		
		tpd.Id,					
		pdpr.DocumentType,
		SUM(pdipr.TaxableValue) AS TaxableValue,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN pdipr.IgstAmount ELSE NULL END) AS IgstAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN pdipr.CgstAmount ELSE NULL END) AS CgstAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN pdipr.SgstAmount ELSE NULL END) AS SgstAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN pdipr.CessAmount ELSE NULL END) AS CessAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdipr.ItcIgstAmount END) AS ItcIgstAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdipr.ItcCgstAmount END) AS ItcCgstAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdipr.ItcSgstAmount END) AS ItcSgstAmount,
		SUM(CASE WHEN pdipr.ItcEligibility IS NULL OR pdipr.ItcEligibility = @ItcEligibilityNo THEN NULL ELSE pdipr.ItcCessAmount END) AS ItcCessAmount,
		SUM(CASE WHEN pdipr.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdipr.IgstAmount ELSE NULL END) AS IgstAmount_175,
		SUM(CASE WHEN pdipr.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdipr.CgstAmount ELSE NULL END) AS CgstAmount_175,
		SUM(CASE WHEN pdipr.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdipr.SgstAmount ELSE NULL END) AS SgstAmount_175,
		SUM(CASE WHEN pdipr.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175 THEN pdipr.CessAmount ELSE NULL END) AS CessAmount_175,
		SUM(CASE WHEN pdipr.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdipr.ItcIgstAmount ELSE NULL END) AS ItcIgstAmount_38_42_43,
		SUM(CASE WHEN pdipr.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdipr.ItcCgstAmount ELSE NULL END) AS ItcCgstAmount_38_42_43,
		SUM(CASE WHEN pdipr.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdipr.ItcSgstAmount ELSE NULL END) AS ItcSgstAmount_38_42_43,
		SUM(CASE WHEN pdipr.GstActOrRuleSection IN (@GstActOrRuleSectionTypeGstAct38, @GstActOrRuleSectionTypeGstAct42, @GstActOrRuleSectionTypeGstAct43) THEN pdipr.ItcCessAmount ELSE NULL END) AS ItcCessAmount_38_42_43
	INTO
		#TempOriginalPrPurchaseDocumentItemsCircular170
	FROM 				
		#TempPurchaseDocumentIds tpd
		INNER JOIN oregular.PurchaseDocumentDW pdo ON tpd.OriginalDocumentNumber = pdo.DocumentNumber AND tpd.OriginalDocumentDate = pdo.DocumentDate AND COALESCE(pdo.BillFromGstin,'') = COALESCE(tpd.BillFromGstin,'')
		INNER JOIN oregular.PurchaseDocumentStatus pdso ON pdo.Id = pdso.PurchaseDocumentId
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = pdo.Id OR gdrmcp.GstnId = tpd.Id
		INNER JOIN oregular.PurchaseDocumentDW pdpr ON pdpr.Id = gdrmcp.PrId
		INNER JOIN oregular.PurchaseDocumentItems pdipr ON pdpr.Id = pdipr.PurchaseDocumentId
	WHERE 
		pdo.SubscriberId = @SubscriberId
		AND pdo.ParentEntityId = tpd.EntityId
		AND pdo.SourceType = tpd.SourceType									
		AND pdo.CombineDocumentType = tpd.CombineDocumentType
		AND pdo.IsAmendment = @BitTypeN			
		AND pdo.TransactionType IN (@TransactionTypeB2C,@TransactionTypeB2B,@TransactionTypeIMPS,@TransactionTypeCBW,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeDE,@TransactionTypeIMPG)
		AND pdso.[Status] = @DocumentStatusActive
		AND tpd.IsAmendment = @BitTypeY	
	GROUP BY 
		tpd.Id,					
		pdpr.DocumentType;
		
	/* Purchase Documents Amendment Data */
	SELECT
		pd.Id,
		pd.DocumentNumber,
		pd.DocumentDate,
		pd.DocumentType AS DocumentType_A, -- Amendment DocumentType
		topdi.DocumentType, -- Original DocumentType
		pd.DocumentValue,
		pd.TaxpayerType,
		pd.TransactionType,
		pd.SourceType,
		pd.ReverseCharge,
		pd.Pos,
		pd.PortCode,
		pd.ReturnPeriod,
		pd.IsAmendment,
		pd.OriginalDocumentNumber,
		pd.OriginalDocumentDate,
		pd.OriginalPortCode,
		tpd.BillFromGstin,
		tpd.ReconciliationSectionType,
		tpd.ItcAvailability As ItcAvailability_A,		
		topdi.ItcAvailability,
		tpd.Gstr2BReturnPeriod,
		tpd.IsAvailableInGstr2B,
		tpd.ItcClaimReturnPeriod AS ItcClaimReturnPeriod_A,
		topdi.ItcClaimReturnPeriod,
		tpd.LiabilityDischargeReturnPeriod,
		CASE WHEN LEN(tpd.BillFromGstin) = 10 THEN @BitTypeY ELSE @BitTypeN END IsBillFromPAN,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -(COALESCE(tpdi.IgstAmount,0) + COALESCE(tpdi.CgstAmount,0) + COALESCE(tpdi.SgstAmount,0) + COALESCE(tpdi.CessAmount,0)) 
			 ELSE (COALESCE(tpdi.IgstAmount,0) + COALESCE(tpdi.CgstAmount,0) + COALESCE(tpdi.SgstAmount,0) + COALESCE(tpdi.CessAmount,0)) END  AS TotalTaxAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.TaxableValue ELSE tpdi.TaxableValue END AS TaxableValue_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.IgstAmount ELSE tpdi.IgstAmount END AS IgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CgstAmount ELSE tpdi.CgstAmount END AS CgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.SgstAmount ELSE tpdi.SgstAmount END AS SgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CessAmount ELSE tpdi.CessAmount END AS CessAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -(COALESCE(tpdi.IgstAmount_175,0) + COALESCE(tpdi.CgstAmount_175,0) + COALESCE(tpdi.SgstAmount_175,0) + COALESCE(tpdi.CessAmount_175,0)) 
			 ELSE (COALESCE(tpdi.IgstAmount_175,0) + COALESCE(tpdi.CgstAmount_175,0) + COALESCE(tpdi.SgstAmount_175,0) + COALESCE(tpdi.CessAmount_175,0)) END  AS TotalTaxAmount_175_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.IgstAmount_175 ELSE tpdi.IgstAmount_175 END AS IgstAmount_175_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CgstAmount_175 ELSE tpdi.CgstAmount_175 END AS CgstAmount_175_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.SgstAmount_175 ELSE tpdi.SgstAmount_175 END AS SgstAmount_175_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.CessAmount_175 ELSE tpdi.CessAmount_175 END AS CessAmount_175_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcIgstAmount ELSE tpdi.ItcIgstAmount END AS ItcIgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCgstAmount ELSE tpdi.ItcCgstAmount END AS ItcCgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcSgstAmount ELSE tpdi.ItcSgstAmount END AS ItcSgstAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCessAmount ELSE tpdi.ItcCessAmount END AS ItcCessAmount_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcIgstAmount_38_42_43 ELSE tpdi.ItcIgstAmount_38_42_43 END AS ItcIgstAmount_38_42_43_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCgstAmount_38_42_43 ELSE tpdi.ItcCgstAmount_38_42_43 END AS ItcCgstAmount_38_42_43_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcSgstAmount_38_42_43 ELSE tpdi.ItcSgstAmount_38_42_43 END AS ItcSgstAmount_38_42_43_A,
		CASE WHEN pd.DocumentType = @DocumentTypeCRN THEN -tpdi.ItcCessAmount_38_42_43 ELSE tpdi.ItcCessAmount_38_42_43 END AS ItcCessAmount_38_42_43_A,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(topdi.IgstAmount,0) + COALESCE(topdi.CgstAmount,0) + COALESCE(topdi.SgstAmount,0) + COALESCE(topdi.CessAmount,0)) 
			 ELSE (COALESCE(topdi.IgstAmount,0) + COALESCE(topdi.CgstAmount,0) + COALESCE(topdi.SgstAmount,0) + COALESCE(topdi.CessAmount,0)) END  AS TotalTaxAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.TaxableValue ELSE topdi.TaxableValue END AS TaxableValue,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.IgstAmount ELSE topdi.IgstAmount END AS IgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CgstAmount ELSE topdi.CgstAmount END AS CgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.SgstAmount ELSE topdi.SgstAmount END AS SgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CessAmount ELSE topdi.CessAmount END AS CessAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(topdi.IgstAmount_175,0) + COALESCE(topdi.CgstAmount_175,0) + COALESCE(topdi.SgstAmount_175,0) + COALESCE(topdi.CessAmount_175,0)) 
			 ELSE (COALESCE(topdi.IgstAmount_175,0) + COALESCE(topdi.CgstAmount_175,0) + COALESCE(topdi.SgstAmount_175,0) + COALESCE(topdi.CessAmount_175,0)) END  AS TotalTaxAmount_175,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.IgstAmount_175 ELSE topdi.IgstAmount_175 END AS IgstAmount_175,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CgstAmount_175 ELSE topdi.CgstAmount_175 END AS CgstAmount_175,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.SgstAmount_175 ELSE topdi.SgstAmount_175 END AS SgstAmount_175,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CessAmount_175 ELSE topdi.CessAmount_175 END AS CessAmount_175,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(topdi.IgstAmount_38_42_43,0) + COALESCE(topdi.CgstAmount_38_42_43,0) + COALESCE(topdi.SgstAmount_38_42_43,0) + COALESCE(topdi.CessAmount_38_42_43,0)) 
			 ELSE (COALESCE(topdi.IgstAmount_38_42_43,0) + COALESCE(topdi.CgstAmount_38_42_43,0) + COALESCE(topdi.SgstAmount_38_42_43,0) + COALESCE(topdi.CessAmount_38_42_43,0)) END  AS TotalTaxAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.IgstAmount_38_42_43 ELSE topdi.IgstAmount_38_42_43 END AS IgstAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CgstAmount_38_42_43 ELSE topdi.CgstAmount_38_42_43 END AS CgstAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.SgstAmount_38_42_43 ELSE topdi.SgstAmount_38_42_43 END AS SgstAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.CessAmount_38_42_43 ELSE topdi.CessAmount_38_42_43 END AS CessAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcIgstAmount ELSE topdi.ItcIgstAmount END AS ItcIgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcCgstAmount ELSE topdi.ItcCgstAmount END AS ItcCgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcSgstAmount ELSE topdi.ItcSgstAmount END AS ItcSgstAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcCessAmount ELSE topdi.ItcCessAmount END AS ItcCessAmount,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcIgstAmount_38_42_43 ELSE topdi.ItcIgstAmount_38_42_43 END AS ItcIgstAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcCgstAmount_38_42_43 ELSE topdi.ItcCgstAmount_38_42_43 END AS ItcCgstAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcSgstAmount_38_42_43 ELSE topdi.ItcSgstAmount_38_42_43 END AS ItcSgstAmount_38_42_43,
		CASE WHEN topdi.DocumentType = @DocumentTypeCRN THEN -topdi.ItcCessAmount_38_42_43 ELSE topdi.ItcCessAmount_38_42_43 END AS ItcCessAmount_38_42_43,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(toppdi.IgstAmount,0) + COALESCE(toppdi.CgstAmount,0) + COALESCE(toppdi.SgstAmount,0) + COALESCE(toppdi.CessAmount,0)) 
			 ELSE (COALESCE(toppdi.IgstAmount,0) + COALESCE(toppdi.CgstAmount,0) + COALESCE(toppdi.SgstAmount,0) + COALESCE(toppdi.CessAmount,0)) END AS PrTotalTaxAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.TaxableValue ELSE toppdi.TaxableValue END AS PrTaxableValue,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.IgstAmount ELSE toppdi.IgstAmount END AS PrIgstAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.CgstAmount ELSE toppdi.CgstAmount END AS PrCgstAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.SgstAmount ELSE toppdi.SgstAmount END AS PrSgstAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.CessAmount ELSE toppdi.CessAmount END AS PrCessAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(toppdi.IgstAmount_175,0) + COALESCE(toppdi.CgstAmount_175,0) + COALESCE(toppdi.SgstAmount_175,0) + COALESCE(toppdi.CessAmount_175,0)) 
			 ELSE (COALESCE(toppdi.IgstAmount_175,0) + COALESCE(toppdi.CgstAmount_175,0) + COALESCE(toppdi.SgstAmount_175,0) + COALESCE(toppdi.CessAmount_175,0)) END AS PrTotalTaxAmount_175,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.IgstAmount_175 ELSE toppdi.IgstAmount_175 END AS PrIgstAmount_175,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.CgstAmount_175 ELSE toppdi.CgstAmount_175 END AS PrCgstAmount_175,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.SgstAmount_175 ELSE toppdi.SgstAmount_175 END AS PrSgstAmount_175,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.CessAmount_175 ELSE toppdi.CessAmount_175 END AS PrCessAmount_175,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(toppdi.ItcIgstAmount,0) + COALESCE(toppdi.ItcCgstAmount,0) + COALESCE(toppdi.ItcSgstAmount,0) + COALESCE(toppdi.ItcCessAmount,0)) 
			 ELSE (COALESCE(toppdi.ItcIgstAmount,0) + COALESCE(toppdi.ItcCgstAmount,0) + COALESCE(toppdi.ItcSgstAmount,0) + COALESCE(toppdi.ItcCessAmount,0)) END AS PrTotalItcAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcIgstAmount ELSE toppdi.ItcIgstAmount END AS PrItcIgstAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcCgstAmount ELSE toppdi.ItcCgstAmount END AS PrItcCgstAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcSgstAmount ELSE toppdi.ItcSgstAmount END AS PrItcSgstAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcCessAmount ELSE toppdi.ItcCessAmount END AS PrItcCessAmount,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -(COALESCE(toppdi.ItcIgstAmount_38_42_43,0) + COALESCE(toppdi.ItcCgstAmount_38_42_43,0) + COALESCE(toppdi.ItcSgstAmount_38_42_43,0) + COALESCE(toppdi.ItcCessAmount_38_42_43,0)) 
			 ELSE (COALESCE(toppdi.ItcIgstAmount_38_42_43,0) + COALESCE(toppdi.ItcCgstAmount_38_42_43,0) + COALESCE(toppdi.ItcSgstAmount_38_42_43,0) + COALESCE(toppdi.ItcCessAmount,0)) END AS PrTotalItcAmount_38_42_43,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcIgstAmount_38_42_43 ELSE toppdi.ItcIgstAmount_38_42_43 END AS PrItcIgstAmount_38_42_43,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcCgstAmount_38_42_43 ELSE toppdi.ItcCgstAmount_38_42_43 END AS PrItcCgstAmount_38_42_43,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcSgstAmount_38_42_43 ELSE toppdi.ItcSgstAmount_38_42_43 END AS PrItcSgstAmount_38_42_43,
		CASE WHEN toppdi.DocumentType = @DocumentTypeCRN THEN -toppdi.ItcCessAmount_38_42_43 ELSE toppdi.ItcCessAmount_38_42_43 END AS PrItcCessAmount_38_42_43,
		COALESCE(pd.ModifiedStamp,pd.Stamp) AS Stamp
	INTO
		#TempPurchaseDocumentsAmendmentCircular170
	FROM 
		#TempPurchaseDocumentIds tpd
		INNER JOIN #TempPurchaseDocumentItemsCircular170 tpdi ON tpdi.PurchaseDocumentId = tpd.Id	
		INNER JOIN #TempOriginalPurchaseDocumentItemsCircular170 topdi ON tpdi.PurchaseDocumentId = topdi.Id
		LEFT JOIN #TempOriginalPrPurchaseDocumentItemsCircular170 toppdi ON toppdi.Id = tpd.Id
		INNER JOIN oregular.PurchaseDocuments pd ON pd.Id = tpdi.PurchaseDocumentId
	WHERE
		tpd.MapperId IS NULL;

	/*Purchase Summary Data*/
	CREATE TABLE #TempPurchaseSummary
	(
		Id BIGINT,
		SummaryType SMALLINT,
		IsAmendment BIT,
		NilAmount DECIMAL(18,2),
		ExemptAmount DECIMAL(18,2),
		NonGstAmount DECIMAL(18,2),
		CompositionAmount DECIMAL(18,2),
		Rate DECIMAL(18,2),
		Pos SMALLINT,
		ItcReversalOrReclaimType SMALLINT,
		CompositionExemptNilNonGstType SMALLINT,
		OriginalReturnPeriod INT,
		TaxableValue DECIMAL(18,2),
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2),
		ItcIgstAmount DECIMAL(18,2),
		ItcCgstAmount DECIMAL(18,2),
		ItcSgstAmount DECIMAL(18,2),
		ItcCessAmount DECIMAL(18,2)
	);

	INSERT INTO #TempPurchaseSummary
	(
		Id,
		SummaryType,
		IsAmendment,
		NilAmount,
		ExemptAmount,
		NonGstAmount,
		CompositionAmount,
		Rate,
		Pos,
		ItcReversalOrReclaimType,
		CompositionExemptNilNonGstType,
		OriginalReturnPeriod,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount,
		ItcIgstAmount,
		ItcCgstAmount,
		ItcSgstAmount,
		ItcCessAmount
	)
	SELECT
		ps.Id,
		ps.SummaryType,
		ps.IsAmendment,
		ps.NilAmount,
		ps.ExemptAmount,
		ps.NonGstAmount,
		ps.CompositionAmount,
		ps.Rate,
		ps.Pos,	
		ps.ItcReversalOrReclaimType,
		ps.CompositionExemptNilNonGstType,
		ps.OriginalReturnPeriod,
		ps.TaxableValue,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY THEN ps.IgstAmountForFirstMonthOfQtr
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY THEN ps.IgstAmountForSecondMonthOfQtr
			 WHEN @IsThirdMonthOfQurater = @BitTypeY THEN COALESCE(ps.IgstAmount,0) - (COALESCE(ps.IgstAmountForFirstMonthOfQtr,0) + COALESCE(ps.IgstAmountForSecondMonthOfQtr,0))
			 ELSE ps.IgstAmount 
		END AS IgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY THEN ps.CgstAmountForFirstMonthOfQtr
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY THEN ps.CgstAmountForSecondMonthOfQtr
			 WHEN @IsThirdMonthOfQurater = @BitTypeY THEN COALESCE(ps.CgstAmount,0) - (COALESCE(ps.CgstAmountForFirstMonthOfQtr,0) + COALESCE(ps.CgstAmountForSecondMonthOfQtr,0))
			 ELSE ps.CgstAmount 
		END AS CgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY THEN ps.SgstAmountForFirstMonthOfQtr
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY THEN ps.SgstAmountForSecondMonthOfQtr
			 WHEN @IsThirdMonthOfQurater = @BitTypeY THEN COALESCE(ps.SgstAmount,0) - (COALESCE(ps.SgstAmountForFirstMonthOfQtr,0) + COALESCE(ps.SgstAmountForSecondMonthOfQtr,0))
			 ELSE ps.SgstAmount 
		END AS SgstAmount,
		CASE WHEN @IsFirstMonthOfQuarter = @BitTypeY THEN ps.CessAmountForFirstMonthOfQtr
			 WHEN @IsSecondMonthOfQuarter = @BitTypeY THEN ps.CessAmountForSecondMonthOfQtr
			 WHEN @IsThirdMonthOfQurater = @BitTypeY THEN COALESCE(ps.CessAmount,0) - (COALESCE(ps.CessAmountForFirstMonthOfQtr,0) + COALESCE(ps.CessAmountForSecondMonthOfQtr,0))
			 ELSE ps.CessAmount 
		END AS CessAmount,
		CASE WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN COALESCE(ps.ItcIgstAmount,0) - (COALESCE(ps.IgstAmountForFirstMonthOfQtr,0) + COALESCE(ps.IgstAmountForSecondMonthOfQtr,0)) 
			 ELSE ps.ItcIgstAmount 
		END AS ItcIgstAmount,
		CASE WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN COALESCE(ps.ItcCgstAmount,0) - (COALESCE(ps.CgstAmountForFirstMonthOfQtr,0) + COALESCE(ps.CgstAmountForSecondMonthOfQtr,0)) 
			 ELSE ps.ItcCgstAmount 
		END AS ItcCgstAmount,
		CASE WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN COALESCE(ps.ItcSgstAmount,0) - (COALESCE(ps.SgstAmountForFirstMonthOfQtr,0) + COALESCE(ps.SgstAmountForSecondMonthOfQtr,0)) 
			 ELSE ps.ItcSgstAmount 
		END AS ItcSgstAmount,
		CASE WHEN @IsThirdMonthOfQurater = @BitTypeY
			 THEN COALESCE(ps.ItcCessAmount,0) - (COALESCE(ps.CessAmountForFirstMonthOfQtr,0) + COALESCE(ps.CessAmountForSecondMonthOfQtr,0)) 
			 ELSE ps.ItcCessAmount 
		END AS ItcCessAmount
	FROM
		oregular.PurchaseSummaries AS ps
		INNER JOIN oregular.PurchaseSummaryStatus AS pss ON ps.Id = pss.PurchaseSummaryId
	WHERE
		ps.SubscriberId = @SubscriberId
		AND ps.EntityId = @EntityId
		AND ps.ReturnPeriod = @ReturnPeriod
		AND ps.IsAmendment = @BitTypeN
		AND pss.[Status] = @DocumentStatusActive;

	/*3.1(A) Details of supplies notified under section 9(5) of the Act, 2017 and corresponding provisions in IGST/UTGST/SGST Acts*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection31A]
				@Gstr3bSectionEcoSupplies = @Gstr3bSectionEcoSupplies,
				@Gstr3bSectionEcoRegSupplies = @Gstr3bSectionEcoRegSupplies,
				@LocationPos = @LocationPos,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TransactionTypeB2C = @TransactionTypeB2C,
				@TransactionTypeB2B = @TransactionTypeB2B,
				@TransactionTypeCBW = @TransactionTypeCBW,
				@TransactionTypeDE = @TransactionTypeDE,
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP,
				@DocumentSummaryTypeGSTR1ECOM = @DocumentSummaryTypeGSTR1ECOM,
				@DocumentSummaryTypeGSTR1SUPECO = @DocumentSummaryTypeGSTR1SUPECO,
				@GstActOrRuleSectionTypeGstAct95 = @GstActOrRuleSectionTypeGstAct95,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*3.1.1 Outward taxable supplies (other than zero rated", nil rated and exempted) Documents*/		
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection3A1]
				@Gstr3bSectionOutwardTaxSupply = @Gstr3bSectionOutwardTaxSupply,
				@LocationPos = @LocationPos,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TransactionTypeB2C = @TransactionTypeB2C,
				@TransactionTypeB2B = @TransactionTypeB2B,
				@TransactionTypeCBW = @TransactionTypeCBW,
				@TransactionTypeDE = @TransactionTypeDE,
				@DocumentSummaryTypeGstr1B2CS = @DocumentSummaryTypeGstr1B2CS,
				@DocumentSummaryTypeGstr1ADV = @DocumentSummaryTypeGstr1ADV,
				@DocumentSummaryTypeGstr1ADVAJ = @DocumentSummaryTypeGstr1ADVAJ,
				@GstActOrRuleSectionTypeGstAct95 = @GstActOrRuleSectionTypeGstAct95,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*3.1.2 Outward taxable supplies (zero rated)*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection3A2]
				@Gstr3bSectionOutwardZeroRated = @Gstr3bSectionOutwardZeroRated,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TransactionTypeEXPWP = @TransactionTypeEXPWP,
				@TransactionTypeEXPWOP = @TransactionTypeEXPWOP,
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*3.1.3 Other outward supplies (Nil rated, exempted)*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue
	)
	EXEC [gst].[GenerateGstr3bSection3A3]
				@Gstr3bSectionOutwardNilRated = @Gstr3bSectionOutwardNilRated,
				@DocumentSummaryTypeGstr1NIL = @DocumentSummaryTypeGstr1NIL;

	/*3.1.4 Inward supplies (liable to reverse charge)*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection3A4]
				@Gstr3bSectionInwardReverseCharge = @Gstr3bSectionInwardReverseCharge,
				@ReturnPeriod = @ReturnPeriod,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TransactionTypeB2C = @TransactionTypeB2C,
				@TransactionTypeB2B = @TransactionTypeB2B,
				@TransactionTypeCBW = @TransactionTypeCBW,
				@TransactionTypeDE = @TransactionTypeDE,
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP,
				@TransactionTypeIMPS = @TransactionTypeIMPS,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*3.1.5 Non-GST outward supplies*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue
	)
	EXEC [gst].[GenerateGstr3bSection3A5]
				@Gstr3bSectionOutwardNonGst = @Gstr3bSectionOutwardNonGst,
				@DocumentSummaryTypeGstr1NIL = @DocumentSummaryTypeGstr1NIL;

	/*3.2 B2C,Composition And Uin Documents*/
	INSERT INTO #TempGstr3bInterState_Original
	(
		Section,
		Pos,
		TaxableValue,
		IgstAmount
	)
	EXEC [gst].[GenerateGstr3bSection3B]
				@Gstr3bSectionInterStateB2c = @Gstr3bSectionInterStateB2c, 
				@Gstr3bSectionInterStateComp = @Gstr3bSectionInterStateComp,
				@Gstr3bSectionInterStateUin = @Gstr3bSectionInterStateUin, 
				@SubscriberId = @SubscriberId,
				@LocationPos = @LocationPos,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@DocumentSummaryTypeGstr1B2CS = @DocumentSummaryTypeGstr1B2CS,
				@DocumentSummaryTypeGstr1ADV = @DocumentSummaryTypeGstr1ADV,
				@DocumentSummaryTypeGstr1ADVAJ = @DocumentSummaryTypeGstr1ADVAJ,
				@TransactionTypeB2C = @TransactionTypeB2C, 
				@TransactionTypeCBW = @TransactionTypeCBW, 
				@TaxPayerTypeUNB = @TaxPayerTypeUNB,
				@TaxPayerTypeEMB = @TaxPayerTypeEMB,
				@TaxPayerTypeONP = @TaxPayerTypeONP,
				@TaxPayerTypeCOM = @TaxPayerTypeCOM,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*4.1.1 Import of Goods Documents*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IsGstr2bData,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4A1]
				@Gstr3bSectionImportOfGoods= @Gstr3bSectionImportOfGoods,
				@ReturnPeriod= @ReturnPeriod,
				@SourceTypeTaxPayer= @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled= @SourceTypeCounterPartyFiled,
				@DocumentTypeBOE= @DocumentTypeBOE,				
				@TransactionTypeIMPG= @TransactionTypeIMPG,
				@ItcAvailabilityTypeY= @ItcAvailabilityTypeY,
				@ItcAvailabilityTypeT= @ItcAvailabilityTypeT,
				@BitTypeN= @BitTypeN,
				@BitTypeY= @BitTypeY;

	/*4.1.2 Import of Services Documents*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4A2]
				@Gstr3bSectionImportOfServices = @Gstr3bSectionImportOfServices,
				@ReturnPeriod = @ReturnPeriod,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TransactionTypeB2B = @TransactionTypeB2B,
				@TransactionTypeCBW = @TransactionTypeCBW,
				@TransactionTypeDE = @TransactionTypeDE,
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP,
				@TransactionTypeIMPS = @TransactionTypeIMPS,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*4.1.3 Inward supplies liable to reverse charge (other than 1 & 2 above)*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IsGstr2bData,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4A3]
				@Gstr3bSectionInwardReverseChargeOther = @Gstr3bSectionInwardReverseChargeOther,
				@ReturnPeriod = @ReturnPeriod,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TransactionTypeB2C = @TransactionTypeB2C,
				@TransactionTypeB2B = @TransactionTypeB2B,
				@TransactionTypeCBW = @TransactionTypeCBW,
				@TransactionTypeDE = @TransactionTypeDE,
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP,
				@TransactionTypeIMPS = @TransactionTypeIMPS,
				@TransactionTypeIMPG = @TransactionTypeIMPG,
				@ItcAvailabilityTypeY = @ItcAvailabilityTypeY,
				@ItcAvailabilityTypeT = @ItcAvailabilityTypeT,
				@ItcEligibilityNo = @ItcEligibilityNo,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*4.1.4 Inward supplies from ISD*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IsGstr2bData,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4A4]
				@Gstr3bSectionInwardSuppliesFromIsd = @Gstr3bSectionInwardSuppliesFromIsd,
				@ReturnPeriod = @ReturnPeriod,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TaxPayerTypeISD = @TaxPayerTypeISD,
				@TransactionTypeIMPG = @TransactionTypeIMPG,
				@ItcAvailabilityTypeY = @ItcAvailabilityTypeY,
				@ItcAvailabilityTypeT = @ItcAvailabilityTypeT,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;

	/*4.1.5 All Other ITC*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IsGstr2bData,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4A5]
				@Gstr3bSectionOtherItc = @Gstr3bSectionOtherItc,
				@ReturnPeriod = @ReturnPeriod,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@ItcAvailabilityTypeY = @ItcAvailabilityTypeY,
				@ItcAvailabilityTypeN = @ItcAvailabilityTypeN,
				@TaxPayerTypeISD = @TaxPayerTypeISD,
				@BitTypeN = @BitTypeN;

	/*4.2 ITC Reversed As per rules 42 & 43 of CGST Rules And Itc Others*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4B]
				@Gstr3bSectionItcReversedAsPerRule = @Gstr3bSectionItcReversedAsPerRule,
				@Gstr3bSectionItcReversedOthers = @Gstr3bSectionItcReversedOthers,
				@Gstr3bSectionImportOfGoods = @Gstr3bSectionImportOfGoods,
				@Gstr3bSectionImportOfServices = @Gstr3bSectionImportOfServices,
				@Gstr3bSectionInwardReverseChargeOther = @Gstr3bSectionInwardReverseChargeOther,
				@Gstr3bSectionInwardSuppliesFromIsd = @Gstr3bSectionInwardSuppliesFromIsd,
				@Gstr3bSectionOtherItc = @Gstr3bSectionOtherItc,
				@EntityId = @EntityId,
				@ReturnPeriod = @ReturnPeriod,
				@PreviousReturnPeriods = @PreviousReturnPeriods,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,			
				@Gstr3bAutoPopulateType = @Gstr3bAutoPopulateType,			
				@Gstr3bAutoPopulateTypeGstActRuleSection = @Gstr3bAutoPopulateTypeGstActRuleSection,			
				@Gstr3bAutoPopulateTypeExemptedTurnoverRatio = @Gstr3bAutoPopulateTypeExemptedTurnoverRatio,
				@ReturnTypeGSTR3B = @ReturnTypeGSTR3B,
				@ReturnActionSystemGenerated = @ReturnActionSystemGenerated,
				@TransactionTypeB2C = @TransactionTypeB2C,
				@TransactionTypeIMPS = @TransactionTypeIMPS,
				@SectTypeAll = @SectTypeAll,
				@DocumentSummaryTypeGstr1B2CS = @DocumentSummaryTypeGstr1B2CS,
				@DocumentSummaryTypeGSTR1ECOM = @DocumentSummaryTypeGSTR1ECOM,
				@DocumentSummaryTypeGSTR1SUPECO = @DocumentSummaryTypeGSTR1SUPECO,
				@DocumentSummaryTypeGstr1ADV = @DocumentSummaryTypeGstr1ADV,
				@DocumentSummaryTypeGstr1ADVAJ = @DocumentSummaryTypeGstr1ADVAJ,
				@DocumentSummaryTypeGstr1NIL = @DocumentSummaryTypeGstr1NIL,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TaxPayerTypeISD = @TaxPayerTypeISD,
				@GstActOrRuleSectionTypeGstActItc175 = @GstActOrRuleSectionTypeGstActItc175, 
				@ItcAvailabilityTypeY= @ItcAvailabilityTypeY,
				@ItcAvailabilityTypeN= @ItcAvailabilityTypeN,
				@BitTypeN = @BitTypeN,
				@BitTypeY = @BitTypeY;				
				
	/*4.4 Ineligible Itc*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	EXEC [gst].[GenerateGstr3bSection4D]
				@Gstr3bSectionIneligibleItcAsPerRule = @Gstr3bSectionIneligibleItcAsPerRule,
				@Gstr3bSectionIneligibleItcOthers = @Gstr3bSectionIneligibleItcOthers,
				@ReturnPeriod = @ReturnPeriod,
				@SourceTypeTaxPayer = @SourceTypeTaxPayer,
				@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@TaxPayerTypeISD = @TaxPayerTypeISD,
				@ItcAvailabilityTypeY = @ItcAvailabilityTypeY,
				@ItcAvailabilityTypeN = @ItcAvailabilityTypeN,
				@BitTypeN = @BitTypeN;	
		
	--/*5.1 From a supplier under composition scheme, Exempt and Nil rated And NonGst*/
	INSERT INTO #TempGstr3bSection_Original
	(
		Section,
		IgstAmount,
		CgstAmount
	)
	EXEC [gst].[GenerateGstr3bSection5A]
				@Gstr3bSectionNilExempt = @Gstr3bSectionNilExempt,
				@Gstr3bSectionNonGst = @Gstr3bSectionNonGst,
				@DocumentSummaryTypeGstr2NIL = @DocumentSummaryTypeGstr2NIL,
				@NilExemptNonGstTypeINTRA = @NilExemptNonGstTypeINTRA, 
				@NilExemptNonGstTypeINTER = @NilExemptNonGstTypeINTER;

	/*Getting Sections Data*/
	SELECT
		tp.Section,
		SUM(tp.TaxableValue) AS TaxableValue,
		SUM(tp.IgstAmount) AS IgstAmount,
		SUM(tp.CgstAmount) AS CgstAmount,
		SUM(tp.SgstAmount) AS SgstAmount,
		SUM(tp.CessAmount) AS CessAmount
	FROM
	(
		SELECT
			tod.Section,
			SUM(tod.TaxableValue) AS TaxableValue,
			SUM(tod.IgstAmount) AS IgstAmount,
			SUM(tod.CgstAmount) AS CgstAmount,
			SUM(tod.SgstAmount) AS SgstAmount,
			SUM(tod.CessAmount) AS CessAmount
		FROM
			#TempGstr3bSection_Original AS tod
		WHERE
			tod.IsGstr2bData = 0
		GROUP BY
			tod.Section

		UNION ALL
			SELECT
				ts.Sections AS Section,
				0 AS TaxableValue,
				0 AS IgstAmount,
				0 AS CgstAmount,
				0 AS SgstAmount,
				0 AS CessAmount
			FROM
				#TempGstr3bSection_Original AS tpo
				RIGHT JOIN #TempSections AS ts ON tpo.Section = ts.Sections
	) AS tp
	GROUP BY
		tp.Section;

	/*Getting InterState Supplies Data*/
	SELECT
		tid.Section,
		tid.Pos,
		SUM(tid.TaxableValue) AS TaxableValue,
		SUM(tid.IgstAmount) AS IgstAmount
	FROM
		#TempGstr3bInterState_Original AS tid
	GROUP BY
		tid.Section,
		tid.Pos;

	SELECT
		tp.Section,
		SUM(tp.TaxableValue) AS TaxableValue,
		SUM(tp.IgstAmount) AS IgstAmount,
		SUM(tp.CgstAmount) AS CgstAmount,
		SUM(tp.SgstAmount) AS SgstAmount,
		SUM(tp.CessAmount) AS CessAmount
	FROM
	(
		SELECT
			tod.Section AS Section,
			SUM(tod.TaxableValue) AS TaxableValue,
			SUM(tod.IgstAmount) AS IgstAmount,
			SUM(tod.CgstAmount) AS CgstAmount,
			SUM(tod.SgstAmount) AS SgstAmount,
			SUM(tod.CessAmount) AS CessAmount
		FROM
			#TempGstr3bSection_Original AS tod
		WHERE
			tod.IsGstr2bData = 1
		GROUP BY
			tod.Section

		UNION ALL
			SELECT
				ts.Sections AS Section,
				0 AS TaxableValue,
				0 AS IgstAmount,
				0 AS CgstAmount,
				0 AS SgstAmount,
				0 AS CessAmount
			FROM
				#TempGstr3bSection_Original AS tpo
				RIGHT JOIN #TempSections AS ts ON tpo.Section = ts.Sections
			WHERE
				tpo.IsGstr2bData = 1
	) AS tp
	GROUP BY
		tp.Section;

END
;
GO


DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3bSection4B];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [gst].[GenerateGstr3bSection4B]
*	Comments		: 22/06/2020 | Amit Khanna | This procedure is used to Generate Data of 4.2.1 ITC Reversed As per rules 42 & 43 of CGST Rules and Section 17(5) And Itc Others in Gstr3b.
*	Sample Execution : 
					EXEC [gst].[GenerateGstr3bSection4B]
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3bSection4B]
(
	@Gstr3bSectionItcReversedAsPerRule integer,
	@Gstr3bSectionItcReversedOthers integer,
	@Gstr3bSectionImportOfGoods integer,
	@Gstr3bSectionImportOfServices integer,
	@Gstr3bSectionInwardReverseChargeOther integer,
	@Gstr3bSectionInwardSuppliesFromIsd integer,
	@Gstr3bSectionOtherItc integer,
	@EntityId integer,
	@ReturnPeriod integer,
	@PreviousReturnPeriods [common].[IntType] READONLY,
	@SourceTypeTaxPayer smallint,
	@SourceTypeCounterPartyFiled smallint,
	@Gstr3bAutoPopulateType smallint,
	@Gstr3bAutoPopulateTypeGstActRuleSection smallint,
	@Gstr3bAutoPopulateTypeExemptedTurnoverRatio smallint,
	@ReturnTypeGSTR3B smallint,
	@ReturnActionSystemGenerated smallint,
	@TransactionTypeB2C smallint,
	@TransactionTypeIMPS smallint,
	@SectTypeAll integer,
	@DocumentSummaryTypeGstr1B2CS smallint,
	@DocumentSummaryTypeGSTR1ECOM smallint,
	@DocumentSummaryTypeGSTR1SUPECO smallint,
	@DocumentSummaryTypeGstr1ADV smallint,
	@DocumentSummaryTypeGstr1ADVAJ smallint,
	@DocumentSummaryTypeGstr1NIL smallint,
	@DocumentTypeINV smallint,
	@DocumentTypeCRN smallint,
	@DocumentTypeDBN smallint,
	@TaxPayerTypeISD smallint,
	@GstActOrRuleSectionTypeGstActItc175 smallint,
	@ItcAvailabilityTypeY smallint,
	@ItcAvailabilityTypeN smallint,
	@BitTypeN bit,
	@BitTypeY bit
)
AS
BEGIN
	DECLARE @Ratio DECIMAL(18,2),
			@ExemptTurnover DECIMAL(18,2),
			@TaxableTurnover DECIMAL(18,2),
			@Count INTEGER,
			@RowNumber INTEGER = 1;

	SET NOCOUNT ON;

	CREATE TABLE #TempGstr3bSection4B_Original
	(
		Section INT,
		IgstAmount DECIMAL(18,2),
		CgstAmount DECIMAL(18,2),
		SgstAmount DECIMAL(18,2),
		CessAmount DECIMAL(18,2)
	);

	CREATE TABLE #TempGstr3bUpdateStatus
	(	
		Id BIGINT,
		Section INT
	);

		/*4.2.2 ITC Reversed Others*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedOthers,
		SUM(CASE WHEN tpdc.ItcClaimReturnPeriod IS NULL 
			 THEN tpdc.IgstAmount
			 ELSE COALESCE(tpdc.IgstAmount,0) - COALESCE(tpdcpr.ItcIgstAmount,0) - COALESCE(tpdcpr.IgstAmount,0)
		END) AS IgstAmount,
		SUM(CASE WHEN tpdc.ItcClaimReturnPeriod IS NULL 
			 THEN tpdc.CgstAmount
			 ELSE COALESCE(tpdc.CgstAmount,0) - COALESCE(tpdcpr.ItcCgstAmount,0) - COALESCE(tpdcpr.CgstAmount,0)
		END) AS CgstAmount,
		SUM(CASE WHEN tpdc.ItcClaimReturnPeriod IS NULL 
			 THEN tpdc.SgstAmount
			 ELSE COALESCE(tpdc.SgstAmount,0) - COALESCE(tpdcpr.ItcSgstAmount,0) - COALESCE(tpdcpr.SgstAmount,0)
		END) AS SgstAmount,
		SUM(CASE WHEN tpdc.ItcClaimReturnPeriod IS NULL 
			 THEN tpdc.CessAmount
			 ELSE COALESCE(tpdc.CessAmount,0) - COALESCE(tpdcpr.ItcCessAmount,0) - COALESCE(tpdcpr.CessAmount,0)
		END) AS CessAmount
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		LEFT JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod
		AND 
		(
			tpdc.ItcClaimReturnPeriod IS NULL
			OR 
			(
				tpdc.ItcClaimReturnPeriod = @ReturnPeriod
				AND ABS(tpdcpr.TotalItcAmount + tpdcpr.TotalTaxAmount) > 0 AND ABS(tpdcpr.TotalItcAmount + tpdcpr.TotalTaxAmount) < ABS(tpdc.TotalTaxAmount) 
			)
		);
		
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdc.Id,
		@Gstr3bSectionItcReversedOthers
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		LEFT JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.ReverseCharge = @BitTypeN
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD)
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod
		AND 
		(
			tpdc.ItcClaimReturnPeriod IS NULL
			OR 
			(
				tpdc.ItcClaimReturnPeriod = @ReturnPeriod
				AND ABS(tpdcpr.TotalItcAmount + tpdcpr.TotalTaxAmount) > 0 AND ABS(tpdcpr.TotalItcAmount + tpdcpr.TotalTaxAmount) < ABS(tpdc.TotalTaxAmount) 
			)
		);

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedOthers,
		SUM(COALESCE(tpdc.CpIgstAmount,0) + COALESCE(tpdc.PrevCpIgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdc.CpCgstAmount,0) + COALESCE(tpdc.PrevCpCgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdc.CpSgstAmount,0) + COALESCE(tpdc.PrevCpSgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdc.CpCessAmount,0) + COALESCE(tpdc.PrevCpCessAmount,0)) AS CessAmount
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdc.ItcClaimReturnPeriod IS NULL
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpd.Id,
		@Gstr3bSectionItcReversedOthers
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
		INNER JOIN #TempPurchaseDocumentIds tpd ON tpdc.MapperId = tpd.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND tpdc.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdc.ItcClaimReturnPeriod IS NULL
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);

	/*4.2.2 ITC Reversed Others Amendment Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedOthers,
		SUM(COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod 
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			(
				tpdac.PrTotalItcAmount IS NULL 
				AND ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			)
			OR
			(
				tpdac.PrTotalTaxAmount IS NULL 
			)
			OR 
			(
				tpdac.PrTotalItcAmount IS NOT NULL 
				AND tpdac.TotalTaxAmount IS NOT NULL
				AND ABS(tpdac.TotalTaxAmount_A) >= ABS(tpdac.PrTotalItcAmount)
			)
			OR 
			(
				tpdac.PrTotalTaxAmount IS NOT NULL 
				AND tpdac.TotalTaxAmount IS NOT NULL
				AND ABS(tpdac.TotalTaxAmount_A) >= ABS(tpdac.PrTotalTaxAmount)
			)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedOthers
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod 
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalTaxAmount IS NULL 
			OR
			(
				tpdac.PrTotalItcAmount IS NULL 
				AND ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
			)
			OR 
			(
				tpdac.PrTotalItcAmount IS NOT NULL 
				AND tpdac.TotalTaxAmount IS NOT NULL
				AND ABS(tpdac.TotalTaxAmount_A) >= ABS(tpdac.PrTotalItcAmount)
			)
			OR 
			(
				tpdac.PrTotalTaxAmount IS NOT NULL 
				AND tpdac.TotalTaxAmount IS NOT NULL
				AND ABS(tpdac.TotalTaxAmount_A) >= ABS(tpdac.PrTotalTaxAmount)
			)
		);

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedOthers,
		SUM(COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod 
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalItcAmount IS NULL 
			OR
			tpdac.PrTotalTaxAmount IS NULL 
			OR 
			(
				tpdac.PrTotalItcAmount IS NOT NULL 
				AND tpdac.TotalTaxAmount IS NOT NULL
				AND ABS(tpdac.TotalTaxAmount_A) <> ABS(tpdac.PrTotalItcAmount)
			)
			OR 
			(
				tpdac.TotalTaxAmount IS NOT NULL
				AND 
				(
					ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount)
					OR
					(
						tpdac.PrTotalTaxAmount IS NOT NULL 
						AND ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.PrTotalTaxAmount)
						AND ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
					)
				)
			)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedOthers
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod 
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			tpdac.PrTotalItcAmount IS NULL 
			OR
			tpdac.PrTotalTaxAmount IS NULL 
			OR 
			(
				tpdac.PrTotalItcAmount IS NOT NULL 
				AND tpdac.TotalTaxAmount IS NOT NULL
				AND ABS(tpdac.TotalTaxAmount_A) <> ABS(tpdac.PrTotalItcAmount)
			)
			OR 
			(
				tpdac.TotalTaxAmount IS NOT NULL
				AND 
				(
					ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount)
					OR
					(
						tpdac.PrTotalTaxAmount IS NOT NULL 
						AND ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.PrTotalTaxAmount)
						AND ABS(tpdac.TotalTaxAmount_A) > ABS(tpdac.TotalTaxAmount)
					)
				)
			)
		);

	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedOthers,
		SUM(CASE WHEN COALESCE(ABS(tpdac.PrItcIgstAmount),0) < COALESCE(ABS(tpdac.IgstAmount_A),0)
			 THEN COALESCE(tpdac.PrItcIgstAmount,0) - COALESCE(tpdac.IgstAmount_A,0)
			 ELSE COALESCE(tpdac.PrIgstAmount,0) - COALESCE(tpdac.IgstAmount_A,0)
		END) AS IgstAmount,
		SUM(CASE WHEN COALESCE(ABS(tpdac.PrItcCgstAmount),0) < COALESCE(ABS(tpdac.CgstAmount_A),0)
			 THEN COALESCE(tpdac.PrItcCgstAmount,0) - COALESCE(tpdac.CgstAmount_A,0)
			 ELSE COALESCE(tpdac.PrCgstAmount,0) - COALESCE(tpdac.CgstAmount_A,0)
		END) AS CgstAmount,
		SUM(CASE WHEN COALESCE(ABS(tpdac.PrItcSgstAmount),0) < COALESCE(ABS(tpdac.SgstAmount_A),0)
			 THEN COALESCE(tpdac.PrItcSgstAmount,0) - COALESCE(tpdac.SgstAmount_A,0)
			 ELSE COALESCE(tpdac.PrSgstAmount,0) - COALESCE(tpdac.SgstAmount_A,0)
		END) AS SgstAmount,
		SUM(CASE WHEN COALESCE(ABS(tpdac.PrItcCessAmount),0) < COALESCE(ABS(tpdac.CessAmount_A),0)
			 THEN COALESCE(tpdac.PrItcCessAmount,0) - COALESCE(tpdac.CessAmount_A,0)
			 ELSE COALESCE(tpdac.PrCessAmount,0) - COALESCE(tpdac.CessAmount_A,0)
		END) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeN
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
			OR ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount_A)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedOthers
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeN
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND 
		(
			ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
			OR ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount_A)
		);

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedOthers,
		-SUM(tpdac.IgstAmount) AS IgstAmount,
		-SUM(tpdac.CgstAmount) AS CgstAmount,
		-SUM(tpdac.SgstAmount) AS SgstAmount,
		-SUM(tpdac.CessAmount) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND
		(
			tpdac.ItcClaimReturnPeriod IS NULL
			OR 
			(
				tpdac.ItcClaimReturnPeriod IS NOT NULL 
				AND 
				(
					tpdac.PrTotalTaxAmount IS NULL
					OR
					ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount)
				)
			)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedOthers
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE	
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.Gstr2BReturnPeriod = @ReturnPeriod
		AND tpdac.ItcClaimReturnPeriod_A  IS NULL
		AND tpdac.ReverseCharge = @BitTypeN
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND
		(
			tpdac.ItcClaimReturnPeriod IS NULL
			OR 
			(
				tpdac.ItcClaimReturnPeriod IS NOT NULL 
				AND 
				(
					tpdac.PrTotalTaxAmount IS NULL
					OR
					ABS(tpdac.PrTotalTaxAmount) < ABS(tpdac.TotalTaxAmount)
				)
			)
		);

	IF(@Gstr3bAutoPopulateType = @Gstr3bAutoPopulateTypeGstActRuleSection)
	BEGIN
	/*4B1 ITC Reversed As per rules 38, 42, 43 and 17(5) of CGST Rules and Section 17(5)*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcIgstAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.IgstAmount_175),0)) < ABS(tpdc.IgstAmount), (COALESCE(tpdcpr.ItcIgstAmount_38_42_43,0) + COALESCE(tpdcpr.IgstAmount_175,0)), tpdc.IgstAmount)) AS IgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCgstAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.CgstAmount_175),0)) < ABS(tpdc.CgstAmount), (COALESCE(tpdcpr.ItcCgstAmount_38_42_43,0) + COALESCE(tpdcpr.CgstAmount_175,0)), tpdc.CgstAmount)) AS CgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcSgstAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.SgstAmount_175),0)) < ABS(tpdc.SgstAmount), (COALESCE(tpdcpr.ItcSgstAmount_38_42_43,0) + COALESCE(tpdcpr.SgstAmount_175,0)), tpdc.SgstAmount)) AS SgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCessAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.CessAmount_175),0)) < ABS(tpdc.CessAmount), (COALESCE(tpdcpr.ItcCessAmount_38_42_43,0) + COALESCE(tpdcpr.CessAmount_175,0)), tpdc.CessAmount)) AS CessAmount
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		INNER JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdcpr.TotalItcAmount_38_42_43) > 0 OR ABS(tpdcpr.TotalTaxAmount_175) > 0);
		
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdc.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrmcp ON gdrmcp.GstnId = tpdc.Id
		INNER JOIN #TempPurchaseDocumentsCircular170 AS tpdcpr ON gdrmcp.PrId = tpdcpr.Id
	WHERE
		tpdc.SourceType = @SourceTypeCounterPartyFiled
		AND tpdc.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod
		AND tpdc.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tpdc.TaxpayerType IS NULL OR tpdc.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdcpr.TotalItcAmount_38_42_43) > 0 OR ABS(tpdcpr.TotalTaxAmount_175) > 0);

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcIgstAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.IgstAmount_175),0)) < (COALESCE(ABS(tpdc.CpIgstAmount),0) + COALESCE(ABS(tpdc.PrevCpIgstAmount),0)), (COALESCE(tpdcpr.ItcIgstAmount_38_42_43,0) + COALESCE(tpdcpr.IgstAmount_175,0)), (COALESCE(tpdc.CpIgstAmount,0) + COALESCE(tpdc.PrevCpIgstAmount,0)))) AS IgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCgstAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.CgstAmount_175),0)) < (COALESCE(ABS(tpdc.CpCgstAmount),0) + COALESCE(ABS(tpdc.PrevCpCgstAmount),0)), (COALESCE(tpdcpr.ItcCgstAmount_38_42_43,0) + COALESCE(tpdcpr.CgstAmount_175,0)), (COALESCE(tpdc.CpCgstAmount,0) + COALESCE(tpdc.PrevCpCgstAmount,0)))) AS CgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcSgstAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.SgstAmount_175),0)) < (COALESCE(ABS(tpdc.CpSgstAmount),0) + COALESCE(ABS(tpdc.PrevCpSgstAmount),0)), (COALESCE(tpdcpr.ItcSgstAmount_38_42_43,0) + COALESCE(tpdcpr.SgstAmount_175,0)), (COALESCE(tpdc.CpSgstAmount,0) + COALESCE(tpdc.PrevCpSgstAmount,0)))) AS SgstAmount,
		SUM(IIF((COALESCE(ABS(tpdcpr.ItcCessAmount_38_42_43),0) + COALESCE(ABS(tpdcpr.CessAmount_175),0)) < (COALESCE(ABS(tpdc.CpCessAmount),0) + COALESCE(ABS(tpdc.PrevCpCessAmount),0)), (COALESCE(tpdcpr.ItcCessAmount_38_42_43,0) + COALESCE(tpdcpr.CessAmount_175,0)), (COALESCE(tpdc.CpCessAmount,0) + COALESCE(tpdc.PrevCpCessAmount,0)))) AS CessAmount
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod
		AND (ABS(tpdcpr.TotalItcAmount_38_42_43) > 0 OR ABS(tpdcpr.TotalTaxAmount_175) > 0)
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);
		
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpd.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempManualPurchaseDocumentsCircular170 AS tpdc
		INNER JOIN #TempManualPurchaseDocumentsCircular170 tpdcpr ON tpdcpr.MapperId = tpdc.MapperId
		INNER JOIN #TempPurchaseDocumentIds tpd ON tpdc.MapperId = tpd.MapperId
	WHERE
		tpdc.ManualSourceType = @SourceTypeCounterPartyFiled
		AND tpdcpr.ManualSourceType = @SourceTypeTaxPayer
		AND tpdc.ItcClaimReturnPeriod = @ReturnPeriod
		AND (ABS(tpdcpr.TotalItcAmount_38_42_43) > 0 OR ABS(tpdcpr.TotalTaxAmount_175) > 0)
		AND (tpdc.CpTotalTaxAmount + tpdc.PrevCpTotalTaxAmount) = (tpdcpr.TotalTaxAmount + tpdcpr.TotalItcAmount);


	/*4B1 ITC Reversed As per rules 38, 42, 43 and 17(5) of CGST Rules and Section 17(5) Amendment Data*/
	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		CASE WHEN ABS(tpdac.TotalTaxAmount) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0)
			 ELSE COALESCE(tpdac.IgstAmount_A,0) - (COALESCE(tpdac.PrItcIgstAmount_38_42_43,0) + COALESCE(tpdac.PrIgstAmount_175,0))
		END AS IgstAmount,
		CASE WHEN ABS(tpdac.TotalTaxAmount) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0)
			 ELSE COALESCE(tpdac.CgstAmount_A,0) - (COALESCE(tpdac.PrItcCgstAmount_38_42_43,0) + COALESCE(tpdac.PrCgstAmount_175,0))
		END AS CgstAmount,
		CASE WHEN ABS(tpdac.TotalTaxAmount) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0)
			 ELSE COALESCE(tpdac.SgstAmount_A,0) - (COALESCE(tpdac.PrItcSgstAmount_38_42_43,0) + COALESCE(tpdac.PrSgstAmount_175,0))
		END AS SgstAmount,
		CASE WHEN ABS(tpdac.TotalTaxAmount) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0)
			 ELSE COALESCE(tpdac.CessAmount_A,0) - (COALESCE(tpdac.PrItcCessAmount_38_42_43,0) + COALESCE(tpdac.PrCessAmount_175,0))
		END AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND ABS(tpdac.TotalTaxAmount_A) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
		AND ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND ABS(tpdac.TotalTaxAmount_A) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
		AND ABS(tpdac.TotalTaxAmount_A) < ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		CASE WHEN ABS(tpdac.TotalTaxAmount_A) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0)
			 ELSE (COALESCE(tpdac.PrItcIgstAmount_38_42_43,0) + COALESCE(tpdac.PrIgstAmount_175,0)) - COALESCE(tpdac.IgstAmount,0)
		END AS IgstAmount,
		CASE WHEN ABS(tpdac.TotalTaxAmount_A) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0)
			 ELSE (COALESCE(tpdac.PrItcCgstAmount_38_42_43,0) + COALESCE(tpdac.PrCgstAmount_175,0)) - COALESCE(tpdac.CgstAmount,0)
		END AS CgstAmount,
		CASE WHEN ABS(tpdac.TotalTaxAmount_A) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0)
			 ELSE (COALESCE(tpdac.PrItcSgstAmount_38_42_43,0) + COALESCE(tpdac.PrSgstAmount_175,0)) - COALESCE(tpdac.SgstAmount,0)
		END AS SgstAmount,
		CASE WHEN ABS(tpdac.TotalTaxAmount_A) < (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) 
			 THEN COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0)
			 ELSE (COALESCE(tpdac.PrItcCessAmount_38_42_43,0) + COALESCE(tpdac.PrCessAmount_175,0)) - COALESCE(tpdac.CessAmount,0)
		END AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) >= ABS(tpdac.TotalTaxAmount) 
		AND ABS(tpdac.TotalTaxAmount_A) >= ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A = @ItcAvailabilityTypeY
		AND tpdac.ItcAvailability = @ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) + ABS(tpdac.PrTotalTaxAmount_175)) >= ABS(tpdac.TotalTaxAmount) 
		AND ABS(tpdac.TotalTaxAmount_A) >= ABS(tpdac.TotalTaxAmount);

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcIgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrIgstAmount_175),0)) < ABS(tpdac.IgstAmount_A), (COALESCE(tpdac.PrItcIgstAmount_38_42_43,0) + COALESCE(tpdac.PrIgstAmount_175,0)), tpdac.IgstAmount_A)) AS IgstAmount,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcCgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCgstAmount_175),0)) < ABS(tpdac.CgstAmount_A), (COALESCE(tpdac.PrItcCgstAmount_38_42_43,0) + COALESCE(tpdac.PrCgstAmount_175,0)), tpdac.CgstAmount_A)) AS CgstAmount,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcSgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrSgstAmount_175),0)) < ABS(tpdac.SgstAmount_A), (COALESCE(tpdac.PrItcSgstAmount_38_42_43,0) + COALESCE(tpdac.PrSgstAmount_175,0)), tpdac.SgstAmount_A)) AS SgstAmount,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcCessAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCessAmount_175),0)) < ABS(tpdac.CessAmount_A), (COALESCE(tpdac.PrItcCessAmount_38_42_43,0) + COALESCE(tpdac.PrCessAmount_175,0)), tpdac.CessAmount_A)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) > 0 OR ABS(tpdac.PrTotalTaxAmount_175) > 0);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) > 0 OR ABS(tpdac.PrTotalTaxAmount_175) > 0);

	/*Amendment Itc Availability = 'Y' and Original Itc Availability = 'N'*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcIgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrIgstAmount_175),0)) < ABS(tpdac.IgstAmount_A), (COALESCE(tpdac.PrItcIgstAmount_38_42_43,0) + COALESCE(tpdac.PrIgstAmount_175,0)), tpdac.IgstAmount_A)) AS IgstAmount,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcCgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCgstAmount_175),0)) < ABS(tpdac.CgstAmount_A), (COALESCE(tpdac.PrItcCgstAmount_38_42_43,0) + COALESCE(tpdac.PrCgstAmount_175,0)), tpdac.CgstAmount_A)) AS CgstAmount,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcSgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrSgstAmount_175),0)) < ABS(tpdac.SgstAmount_A), (COALESCE(tpdac.PrItcSgstAmount_38_42_43,0) + COALESCE(tpdac.PrSgstAmount_175,0)), tpdac.SgstAmount_A)) AS SgstAmount,
		SUM(IIF((COALESCE(ABS(tpdac.PrItcCessAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCessAmount_175),0)) < ABS(tpdac.CessAmount_A), (COALESCE(tpdac.PrItcCessAmount_38_42_43,0) + COALESCE(tpdac.PrCessAmount_175,0)), tpdac.CessAmount_A)) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeN
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) > 0 OR ABS(tpdac.PrTotalTaxAmount_175) > 0);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeY
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeN
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) > 0 OR ABS(tpdac.PrTotalTaxAmount_175) > 0);

	/*Amendment Itc Availability = 'N' and Original Itc Availability = 'Y'*/
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(CASE WHEN (COALESCE(ABS(tpdac.PrItcIgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrIgstAmount_175),0)) <= COALESCE(ABS(tpdac.IgstAmount),0)
			 THEN -(COALESCE(ABS(tpdac.PrItcIgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrIgstAmount_175),0))
			 ELSE -tpdac.IgstAmount
		END) AS IgstAmount,
		SUM(CASE WHEN (COALESCE(ABS(tpdac.PrItcCgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCgstAmount_175),0)) <= COALESCE(ABS(tpdac.CgstAmount),0)
			 THEN -(COALESCE(ABS(tpdac.PrItcCgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCgstAmount_175),0))
			 ELSE -tpdac.CgstAmount
		END) AS CgstAmount,
		SUM(CASE WHEN (COALESCE(ABS(tpdac.PrItcSgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrSgstAmount_175),0)) <= COALESCE(ABS(tpdac.SgstAmount),0)
			 THEN -(COALESCE(ABS(tpdac.PrItcSgstAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrSgstAmount_175),0))
			 ELSE -tpdac.SgstAmount
		END) AS SgstAmount,
		SUM(CASE WHEN (COALESCE(ABS(tpdac.PrItcCessAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCessAmount_175),0)) <= COALESCE(ABS(tpdac.CessAmount),0)
			 THEN -(COALESCE(ABS(tpdac.PrItcCessAmount_38_42_43),0) + COALESCE(ABS(tpdac.PrCessAmount_175),0))
			 ELSE -tpdac.CessAmount
		END) AS CessAmount
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) > 0 OR ABS(tpdac.PrTotalTaxAmount_175) > 0);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpdac.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocumentsAmendmentCircular170 tpdac
	WHERE 
		tpdac.SourceType = @SourceTypeCounterPartyFiled
		AND tpdac.ItcAvailability_A =@ItcAvailabilityTypeN
		AND tpdac.ItcAvailability =@ItcAvailabilityTypeY
		AND tpdac.ItcClaimReturnPeriod IS NOT NULL
		AND tpdac.ItcClaimReturnPeriod_A = @ReturnPeriod
		AND tpdac.DocumentType IN (@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
		AND (tpdac.TaxpayerType IS NULL OR tpdac.TaxpayerType <> @TaxPayerTypeISD)
		AND (ABS(tpdac.PrTotalItcAmount_38_42_43) > 0 OR ABS(tpdac.PrTotalTaxAmount_175) > 0);

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(tpd.IgstAmount) AS IgstAmount,
		SUM(tpd.CgstAmount) AS CgstAmount,
		SUM(tpd.SgstAmount) AS SgstAmount,
		SUM(tpd.CessAmount) AS CessAmount
	FROM
		#TempPurchaseDocuments AS tpd
	WHERE 
		tpd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tpd.ReverseCharge = @BitTypeY
		AND tpd.SourceType = @SourceTypeTaxPayer
		AND tpd.ReturnPeriod = @ReturnPeriod
		AND tpd.TransactionType IN (@TransactionTypeB2C,@TransactionTypeIMPS)
		AND (tpd.BillFromGstin IS NULL OR tpd.BillFromGstin = 'URP' OR tpd.IsBillFromPAN = @BitTypeY)
		AND tpd.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175;

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpd.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM
		#TempPurchaseDocuments AS tpd
	WHERE 
		tpd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tpd.ReverseCharge = @BitTypeY
		AND tpd.SourceType = @SourceTypeTaxPayer
		AND tpd.ReturnPeriod = @ReturnPeriod
		AND tpd.TransactionType IN (@TransactionTypeB2C,@TransactionTypeIMPS)
		AND (tpd.BillFromGstin IS NULL OR tpd.BillFromGstin = 'URP' OR tpd.IsBillFromPAN = @BitTypeY)
		AND tpd.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175;

	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		SUM(COALESCE(tpda.IgstAmount_A,0) - COALESCE(tpda.IgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpda.CgstAmount_A,0) - COALESCE(tpda.CgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpda.SgstAmount_A,0) - COALESCE(tpda.SgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpda.CessAmount_A,0) - COALESCE(tpda.CessAmount,0)) AS CessAmount
	FROM	
		#TempPurchaseDocumentsAmendment AS tpda
	WHERE
		tpda.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tpda.ReverseCharge = @BitTypeY
		AND tpda.SourceType = @SourceTypeTaxPayer
		AND tpda.ReturnPeriod = @ReturnPeriod
		AND tpda.TransactionType IN (@TransactionTypeB2C,@TransactionTypeIMPS)
		AND (tpda.BillFromGstin IS NULL OR tpda.BillFromGstin = 'URP' OR tpda.IsBillFromPAN = @BitTypeY)
		AND tpda.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175;

	
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id,
		Section
	)
	SELECT
		tpda.Id,
		@Gstr3bSectionItcReversedAsPerRule
	FROM	
		#TempPurchaseDocumentsAmendment AS tpda
	WHERE
		tpda.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tpda.ReverseCharge = @BitTypeY
		AND tpda.SourceType = @SourceTypeTaxPayer
		AND tpda.ReturnPeriod = @ReturnPeriod
		AND tpda.TransactionType IN (@TransactionTypeB2C,@TransactionTypeIMPS)
		AND (tpda.BillFromGstin IS NULL OR tpda.BillFromGstin = 'URP' OR tpda.IsBillFromPAN = @BitTypeY)
		AND tpda.GstActOrRuleSection = @GstActOrRuleSectionTypeGstActItc175;

	END;
		
	IF(@Gstr3bAutoPopulateType = @Gstr3bAutoPopulateTypeExemptedTurnoverRatio)
	BEGIN
		CREATE TABLE #TempReturnPeriods 
		(
			RowNumber Integer IDENTITY(1,1) NOT NULL,
			ReturnPeriod INTEGER
		);

		INSERT INTO #TempReturnPeriods
		(
			ReturnPeriod
		)
		SELECT
			*
		FROM 
			@PreviousReturnPeriods;

		SELECT @Count = COUNT(*) FROM #TempReturnPeriods;

		SELECT
			trd.RowNumber,
			CASE WHEN sd.DocumentType =  @DocumentTypeCRN THEN -SUM(sd.TotalTaxableValue) ELSE SUM(sd.TotalTaxableValue) END AS TaxableValue
		INTO 
			#TempTaxableTurnover
		FROM
			oregular.SaleDocumentDW sd
			INNER JOIN #TempReturnPeriods trd ON trd.ReturnPeriod = sd.ReturnPeriod
		WHERE 
			sd.ParentEntityId = @EntityId
			AND sd.SectionType & @SectTypeAll <> 0
		GROUP BY 
			trd.RowNumber,
			sd.DocumentType;

		INSERT INTO #TempTaxableTurnover
		SELECT 
			trd.RowNumber,
			SUM((CASE WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADV
					 THEN COALESCE(ss.AdvanceAmount,0)
					 WHEN ss.SummaryType = @DocumentSummaryTypeGstr1ADVAJ
					 THEN -COALESCE(ss.AdvanceAmount,0)
					 ELSE COALESCE(ss.TaxableValue,0)
				END) + COALESCE(ss.NilAmount,0) + COALESCE(ss.ExemptAmount,0) + COALESCE(ss.NonGstAmount,0)) AS TaxableValue
		FROM
			oregular.SaleSummaries ss
			INNER JOIN #TempReturnPeriods trd ON trd.ReturnPeriod = ss.ReturnPeriod
		WHERE 
			ss.EntityId = @EntityId
			AND ss.SummaryType IN (@DocumentSummaryTypeGstr1B2CS,@DocumentSummaryTypeGSTR1ECOM,@DocumentSummaryTypeGSTR1SUPECO,@DocumentSummaryTypeGstr1ADV,@DocumentSummaryTypeGstr1ADVAJ,@DocumentSummaryTypeGstr1NIL)
		GROUP BY 
			trd.RowNumber;

		SELECT
			trd.RowNumber,
			SUM(COALESCE(ss.NilAmount,0) + COALESCE(ss.ExemptAmount,0) + COALESCE(ss.NonGstAmount,0))  AS TaxableValue
		INTO
			#TempExemptTurnover
		FROM
			oregular.SaleSummaries ss
			INNER JOIN #TempReturnPeriods trd ON trd.ReturnPeriod = ss.ReturnPeriod
		WHERE 
			ss.EntityId = @EntityId
			AND ss.SummaryType IN (@DocumentSummaryTypeGstr1NIL)
		GROUP BY 
			trd.RowNumber;

		SELECT 
			trd.RowNumber, 
			r.ReturnPeriod,
			(SUM(CAST(JSON_VALUE(t1.value, '$.iamt') AS decimal(18,2))) - SUM(CASE WHEN JSON_VALUE(t2.value, '$.ty') = 'OTH' THEN CAST(JSON_VALUE(t2.value, '$.iamt') AS decimal(18,2)) ELSE 0 END)) AS IgstAmount,
			(SUM(CAST(JSON_VALUE(t1.value, '$.camt') AS decimal(18,2))) - SUM(CASE WHEN JSON_VALUE(t2.value, '$.ty') = 'OTH' THEN CAST(JSON_VALUE(t2.value, '$.camt') AS decimal(18,2)) ELSE 0 END)) AS CgstAmount,
			(SUM(CAST(JSON_VALUE(t1.value, '$.samt') AS decimal(18,2))) - SUM(CASE WHEN JSON_VALUE(t2.value, '$.ty') = 'OTH' THEN CAST(JSON_VALUE(t2.value, '$.samt') AS decimal(18,2)) ELSE 0 END)) AS SgstAmount,
			(SUM(CAST(JSON_VALUE(t1.value, '$.csamt') AS decimal(18,2))) - SUM(CASE WHEN JSON_VALUE(t2.value, '$.ty') = 'OTH' THEN CAST(JSON_VALUE(t2.value, '$.csamt') AS decimal(18,2)) ELSE 0 END)) AS CessAmount
		INTO
			#TempReturnData
		FROM 
			gst.Returns r
			INNER JOIN #TempReturnPeriods trd ON r.ReturnPeriod = trd.ReturnPeriod
			CROSS APPLY OPENJSON(r.Data, '$.itc_elg.itc_avl') t1
			CROSS APPLY OPENJSON(r.Data, '$.itc_elg.itc_rev') t2
		WHERE 
			r.EntityId = @EntityId
			AND r.[Type] = @ReturnTypeGSTR3B
			AND r.[Action] = @ReturnActionSystemGenerated
			AND r.[Data] IS NOT NULL
			AND r.ReturnPeriod <> @ReturnPeriod
		GROUP BY
			trd.RowNumber,
			r.ReturnPeriod;

		INSERT INTO #TempReturnData
		(
			RowNumber,
			ReturnPeriod,
			IgstAmount,
			CgstAmount,
			SgstAmount,
			CessAmount
		)
		SELECT 
			@Count AS RowNumber,
			@ReturnPeriod AS ReturnPeriod,
			SUM(tgso.IgstAmount),
			SUM(tgso.CgstAmount),
			SUM(tgso.SgstAmount),
			SUM(tgso.CessAmount)			
		FROM
			#TempGstr3bSection_Original tgso
		WHERE 
			tgso.Section IN (@Gstr3bSectionImportOfGoods,@Gstr3bSectionImportOfServices,@Gstr3bSectionInwardReverseChargeOther,@Gstr3bSectionInwardSuppliesFromIsd,@Gstr3bSectionOtherItc);

		INSERT INTO #TempReturnData
		(
			RowNumber,
			ReturnPeriod,
			IgstAmount,
			CgstAmount,
			SgstAmount,
			CessAmount
		)
		SELECT 
			@Count AS RowNumber,
			@ReturnPeriod AS ReturnPeriod,
			-SUM(tgso.IgstAmount),
			-SUM(tgso.CgstAmount),
			-SUM(tgso.SgstAmount),
			-SUM(tgso.CessAmount)			
		FROM
			#TempGstr3bSection4B_Original tgso
		WHERE 
			tgso.Section = @Gstr3bSectionItcReversedOthers;			

		CREATE TABLE #TempItcReversalData
		(
			RowNumber INTEGER,
			ItcReversalIgstAmount DECIMAL(18,2),
			ItcReversalCgstAmount DECIMAL(18,2),
			ItcReversalSgstAmount DECIMAL(18,2),
			ItcReversalCessAmount DECIMAL(18,2)
		);

		WHILE @RowNumber <= @Count
		BEGIN

			SELECT @TaxableTurnover = SUM(tsd.TaxableValue) FROM #TempTaxableTurnover tsd WHERE tsd.RowNumber <= @RowNumber;
			SELECT @ExemptTurnover = SUM(tss.TaxableValue) FROM #TempExemptTurnover tss WHERE tss.RowNumber <= @RowNumber;

			SET @Ratio = @ExemptTurnover / @TaxableTurnover;

			INSERT INTO #TempItcReversalData
			SELECT 
				@RowNumber AS RowNumber,
				(SUM(trd.IgstAmount) * @Ratio) AS ItcReversalIgstAmount,
				(SUM(trd.CgstAmount) * @Ratio) AS ItcReversalCgstAmount,
				(SUM(trd.SgstAmount) * @Ratio) AS ItcReversalSgstAmount,
				(SUM(trd.CessAmount) * @Ratio) AS ItcReversalCessAmount
			FROM 
				#TempReturnData trd 
			WHERE	
				trd.RowNumber <= @RowNumber;

			SET @RowNumber = @RowNumber + 1;

		END;
		
	INSERT INTO #TempGstr3bSection4B_Original
	(
		Section,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionItcReversedAsPerRule,
		tird.ItcReversalIgstAmount,
		tird.ItcReversalCgstAmount,
		tird.ItcReversalSgstAmount,
		tird.ItcReversalCessAmount
	FROM 
		#TempItcReversalData tird
		INNER JOIN #TempReturnPeriods trd ON trd.RowNumber = tird.RowNumber
	WHERE 
		trd.ReturnPeriod = @ReturnPeriod;

	END;
	
	UPDATE 
		oregular.PurchaseDocumentStatus
	SET 
		Gstr3bSection = CASE WHEN Gstr3bSection IS NULL THEN us.Section WHEN Gstr3bSection & us.Section <> 0 THEN Gstr3bSection ELSE Gstr3bSection + us.Section END
	FROM 
		#TempGstr3bUpdateStatus us
	WHERE
		PurchaseDocumentId = us.Id;
	
	SELECT
		tod.Section,
		SUM(tod.IgstAmount) AS IgstAmount,
		SUM(tod.CgstAmount) AS CgstAmount,
		SUM(tod.SgstAmount) AS SgstAmount,
		SUM(tod.CessAmount) AS CessAmount
	FROM
		#TempGstr3bSection4B_Original AS tod
	GROUP BY
		tod.Section;

	DROP TABLE #TempGstr3bSection4B_Original,#TempGstr3bUpdateStatus;

END;
GO


DROP PROCEDURE IF EXISTS [oregular].[InsertPurchaseDocumentRecoCancelledCreditNotes];
GO


CREATE PROCEDURE [oregular].[InsertPurchaseDocumentRecoCancelledCreditNotes](
	@ParentEntityId integer,
	@FinancialYear integer,
	@SubscriberId integer,
	@DocumentTypeINV smallint,
	@DocumentTypeDBN smallint,
	@DocumentTypeCRN smallint,
	@NearMatchCancelledInvoiceToleranceFrom numeric,
	@NearMatchCancelledInvoiceToleranceTo numeric,
	@ReconciliationSectionTypePrDiscarded smallint = 9,
	@ReconciliationSectionTypeGstDiscarded smallint = 10,
	@ReconciliationSectionTypeGstOnly smallint = 2,
	@CancelledInvoiceReasonType VARCHAR(10) = '8589934592')
AS
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: oregular.InsertGstr2bDocumentPotentialMatchReco 
* 	Comments			: 17-01-2023 | Chetan Saini	|  Added test execution and modification done.						 																					
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		
					EXEC oregular.InsertPurchaseDocumentRecoCancelledCreditNotes
							@ParentEntityId=16882 ,
							@FinancialYear=202324,
							@SubscriberId=164 ,
							@DocumentTypeINV=1,
							@DocumentTypeDBN=2 ,
							@DocumentTypeCRN=3 ,
							@NearMatchCancelledInvoiceToleranceFrom = -5,
							@NearMatchCancelledInvoiceToleranceTo = 5,
							@ReconciliationSectionTypePrDiscarded=9 ,
							@ReconciliationSectionTypeGstDiscarded=10;	
*/--------------------------------------------------------------------------------------------------------------------------------------
BEGIN	
	DROP TABLE IF EXISTS #TempCrossDocumentMatchedData,#Reason;
							   
	CREATE TABLE #TempCrossDocumentMatchedData(Id BIGINT IDENTITY(1,1), PrId BIGINT , GstnId BIGINT,Preference smallint,Source VARCHAR(10),ReturnPeriod INT);  
	
	DROP TABLE IF EXISTS #TempPrOnlyData,#TempGstnOnlyData;
	   
	PRINT 'Poten3';			
	
	DROP TABLE IF EXISTS #TempPrOnlyData;
		
	SELECT 
		pdr.Id,
		pdr.DocumentType,
		pdr.DocumentNumber AS DocumentNumber,
		CAST(CAST(pdr.DocumentDate AS VARCHAR)AS Date) AS DocumentDate,
		pdr.DocumentFinancialYear FinancialYear,
		pdr.FinancialYear RPFinancialYear ,
		pdr.BillFromGstin Gstin ,
		pdr.ParentEntityId,
		pdr.TotalTaxableValue,
		pdr.TotalTaxAmount,
		pdr.ReturnPeriod,
		pdr.BillFromPan GstinPAN,
		CASE WHEN pdr.DocumentType = 4 THEN pdr.PortCode  ELSE '' END PortCode,																	   
		Pdr.SubscriberId,
		pdr.IsAmendment,
		pdr.DocumentValue,
		ABS(pdr.TotalTaxAmount-gst.TotalTaxAmount) AS TotalTaxAmountDiff
	INTO #TempPrOnlyData
	FROM 
		oregular.PurchaseDocumentDW pdr 		
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrm on pdr.Id = gdrm.PrId
		LEFT JOIN oregular.PurchaseDocumentDW AS gst ON gdrm.GstnId = gst.Id																	
	WHERE   
		pdr.SubscriberId = @SubscriberId    
		AND pdr.FinancialYear = @FinancialYear
		AND Pdr.ParentEntityId = @ParentEntityId
		AND pdr.DocumentType IN (@DocumentTypeINV,@DocumentTypeDBN)
		AND gdrm.SectionType <> @ReconciliationSectionTypePrDiscarded
		AND CancelledInvoiceId IS NULL;
		
	PRINT 'Poten4';			
	SELECT 
		pdr.Id,
		pdr.DocumentType,
		pdr.DocumentNumber AS DocumentNumber,
		CAST(CAST(pdr.DocumentDate AS VARCHAR)AS Date) DocumentDate,
		pdr.DocumentFinancialYear FinancialYear,
		pdr.FinancialYear RPFinancialYear,
		pdr.BillFromGstin Gstin,
		pdr.ParentEntityId,
		pdr.TotalTaxableValue,
		pdr.TotalTaxAmount,
		pdr.ReturnPeriod,
		pdr.SubscriberId,
		pdr.IsAmendment,
		pdr.DocumentValue	
	INTO #TempGstnOnlyData	
	FROM 
		oregular.PurchaseDocumentDW pdr  			
		INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrm on pdr.Id = gdrm.GstnId
	WHERE   
		pdr.SubscriberId = @SubscriberId    		
		AND pdr.FinancialYear = @FinancialYear
		AND Pdr.ParentEntityId = @ParentEntityId
		AND pdr.DocumentType IN (@DocumentTypeCRN,@DocumentTypeINV,@DocumentTypeDBN)
		AND gdrm.SectionType = @ReconciliationSectionTypeGstOnly
		AND CancelledInvoiceId IS NULL;

	PRINT 'Poten5';
	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,
		CASE WHEN Pr.DocumentType = @DocumentTypeINV THEN 1
			 WHEN Pr.DocumentType = @DocumentTypeDBN THEN 2
		END,Pr.ReturnPeriod,'Pr'
	FROM  
		#TempPrOnlyData Pr  
	INNER JOIN #TempGstnOnlyData GSTN 
		ON Pr.SubscriberId = GSTN.SubscriberId			
		AND Pr.Gstin = GSTN.Gstin
		AND Pr.ParentEntityId = GSTN.ParentEntityId
		AND Pr.DocumentDate = Gstn.DocumentDate
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND pr.TotalTaxAmount-Gstn.TotalTaxAmount BETWEEN @NearMatchCancelledInvoiceToleranceFrom AND @NearMatchCancelledInvoiceToleranceTo;
	
	PRINT 'Poten5';
	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,
		CASE WHEN Pr.DocumentType = @DocumentTypeINV THEN 1
			 WHEN Pr.DocumentType = @DocumentTypeDBN THEN 2
		END,Pr.ReturnPeriod,'Pr'
	FROM  
		#TempPrOnlyData Pr  
		INNER JOIN #TempGstnOnlyData GSTN 
		ON 
			Pr.SubscriberId = GSTN.SubscriberId			
			AND Pr.Gstin = GSTN.Gstin
			AND Pr.ParentEntityId = GSTN.ParentEntityId
			AND Pr.FinancialYear = Gstn.FinancialYear
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND pr.TotalTaxAmount-Gstn.TotalTaxAmount BETWEEN @NearMatchCancelledInvoiceToleranceFrom AND @NearMatchCancelledInvoiceToleranceTo
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);

	/*Delete record with less preference*/
	PRINT 'Poten7';
	DELETE P0
		FROM #TempCrossDocumentMatchedData AS P0 
	INNER JOIN #TempCrossDocumentMatchedData AS P1 ON P1.GstnId = P0.GstnId
	WHERE 
		P1.Preference= 1 
		AND P0.Preference = 2;

	/* Gst crn comparison with gst inv */
	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,
		1,Pr.ReturnPeriod,'Gstn'
	FROM  
		#TempGstnOnlyData Pr  
	INNER JOIN #TempGstnOnlyData GSTN 
			ON 
				Pr.SubscriberId = GSTN.SubscriberId			
				AND Pr.Gstin = GSTN.Gstin
				AND Pr.ParentEntityId = GSTN.ParentEntityId
				AND Pr.DocumentDate = Gstn.DocumentDate
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND Pr.DocumentType = @DocumentTypeINV
		AND pr.TotalTaxAmount-Gstn.TotalTaxAmount BETWEEN @NearMatchCancelledInvoiceToleranceFrom AND @NearMatchCancelledInvoiceToleranceTo
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);

	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,1,Pr.ReturnPeriod,'Gstn'
	FROM  
		#TempGstnOnlyData Pr  
		INNER JOIN #TempGstnOnlyData GSTN 
		ON 
			Pr.SubscriberId = GSTN.SubscriberId			
			AND Pr.Gstin = GSTN.Gstin
			AND Pr.ParentEntityId = GSTN.ParentEntityId
			AND Pr.FinancialYear = Gstn.FinancialYear
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND Pr.DocumentType = @DocumentTypeINV
		AND pr.TotalTaxAmount-Gstn.TotalTaxAmount BETWEEN @NearMatchCancelledInvoiceToleranceFrom AND @NearMatchCancelledInvoiceToleranceTo
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);

	/* Gst crn comparison with gst inv */
	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,
		1,Pr.ReturnPeriod,'Gstn'
	FROM  
		#TempGstnOnlyData Pr  
	INNER JOIN #TempGstnOnlyData GSTN 
			ON 
				Pr.SubscriberId = GSTN.SubscriberId			
				AND Pr.Gstin = GSTN.Gstin
				AND Pr.ParentEntityId = GSTN.ParentEntityId
				AND Pr.DocumentDate = Gstn.DocumentDate
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND Pr.DocumentType = @DocumentTypeDBN
		AND pr.TotalTaxAmount-Gstn.TotalTaxAmount BETWEEN @NearMatchCancelledInvoiceToleranceFrom AND @NearMatchCancelledInvoiceToleranceTo
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);

	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,1,Pr.ReturnPeriod,'Gstn'
	FROM  
		#TempGstnOnlyData Pr  
		INNER JOIN #TempGstnOnlyData GSTN 
		ON 
			Pr.SubscriberId = GSTN.SubscriberId			
			AND Pr.Gstin = GSTN.Gstin
			AND Pr.ParentEntityId = GSTN.ParentEntityId
			AND Pr.FinancialYear = Gstn.FinancialYear
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND Pr.DocumentType = @DocumentTypeDBN
		AND pr.TotalTaxAmount-Gstn.TotalTaxAmount BETWEEN @NearMatchCancelledInvoiceToleranceFrom AND @NearMatchCancelledInvoiceToleranceTo
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);
																													  
	PRINT 'Poten31';	 

	/* Start Short Case */
	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,
		CASE WHEN Pr.DocumentType = @DocumentTypeINV THEN 1
			 WHEN Pr.DocumentType = @DocumentTypeDBN THEN 2	
		END,Pr.ReturnPeriod,'Pr'
	FROM  
		#TempPrOnlyData Pr  
	INNER JOIN #TempGstnOnlyData GSTN 
		ON Pr.SubscriberId = GSTN.SubscriberId			
		AND Pr.Gstin = GSTN.Gstin
		AND Pr.ParentEntityId = GSTN.ParentEntityId
		AND Pr.DocumentDate = Gstn.DocumentDate
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND Pr.DocumentType = @DocumentTypeINV
		AND pr.TotalTaxAmountDiff = Gstn.TotalTaxAmount
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);
		

	INSERT INTO #TempCrossDocumentMatchedData(PrId,GstnId,Preference,ReturnPeriod,Source)  
	SELECT   
		Pr.Id PrId,Gstn.Id GstId,
		CASE WHEN Pr.DocumentType = @DocumentTypeINV THEN 1
			 WHEN Pr.DocumentType = @DocumentTypeDBN THEN 2	
		END,Pr.ReturnPeriod,'Pr'
	FROM  
		#TempPrOnlyData Pr  
		INNER JOIN #TempGstnOnlyData GSTN 
		ON 
			Pr.SubscriberId = GSTN.SubscriberId			
			AND Pr.Gstin = GSTN.Gstin
			AND Pr.ParentEntityId = GSTN.ParentEntityId
			AND Pr.FinancialYear = Gstn.FinancialYear
	WHERE 
		GSTN.DocumentType = @DocumentTypeCRN
		AND Pr.DocumentType = @DocumentTypeINV
		AND pr.TotalTaxAmountDiff = Gstn.TotalTaxAmount
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.PrId = pr.Id)  
		AND NOT EXISTS (SELECT 1 FROM #TempCrossDocumentMatchedData tc WHERE tc.GstnId = GSTN.Id);
	
	/* End Short Case */
	WITH GstnCTE  
	AS  
	(  
		SELECT  
			ROW_NUMBER() OVER(PARTITION BY M.GstnId ORDER BY ReturnPeriod) RowNum, *    
		FROM  
			#TempCrossDocumentMatchedData M  				
	)  
	DELETE 
	FROM		  
		#TempCrossDocumentMatchedData WHERE Id IN(SELECT Id FROM GstnCTE	WHERE RowNum > 1); 
	
	PRINT 'Poten32';	 
	WITH PrCTE  
	AS  
	(  
		SELECT  
			ROW_NUMBER() OVER(PARTITION BY M.PrId ORDER BY ReturnPeriod) RowNum, *    
		FROM  
			#TempCrossDocumentMatchedData M  
	)  
	DELETE 
	FROM
		#TempCrossDocumentMatchedData WHERE Id IN(SELECT Id FROM PrCTE	WHERE RowNum > 1);
	      	
	PRINT 'Poten39';
	UPDATE pdrm
	SET Reason = CASE WHEN COALESCE(pdrm.Reason,'[]') = '[]' 
						  THEN CONCAT('[{Reason:', @CancelledInvoiceReasonType ,',"Value":""}]') 
					 				ELSE REPLACE(pdrm.Reason,'[',CONCAT('[{Reason:',
														@CancelledInvoiceReasonType
													,',"Value":""},')) END, 
			ReasonType = @CancelledInvoiceReasonType  + pdrm.ReasonType,
			CancelledInvoiceId = t_pdrm.GstnId
	FROM
		#TempCrossDocumentMatchedData t_pdrm
	INNER JOIN Oregular.Gstr2bDocumentRecoMapper pdrm ON t_pdrm.PrId = pdrm.PrId
	INNER JOIN #TempGstnOnlyData gd ON  t_pdrm.GstnId = gd.Id														   
	WHERE		
		COALESCE(pdrm.Reason,'[]') NOT LIKE '%' + @CancelledInvoiceReasonType + '%'
		AND t_pdrm.[Source] = 'Pr'; 
	
	UPDATE pdrm
		SET Reason = CASE WHEN COALESCE(pdrm.Reason,'[]') = '[]' 
						  THEN CONCAT('[{Reason:', @CancelledInvoiceReasonType ,',"Value":"',CONCAT(gd.DocumentNumber, '#', gd.DocumentDate),'"}],') 
					 				ELSE REPLACE(pdrm.Reason,'[',CONCAT('[{Reason:',
														@CancelledInvoiceReasonType
													,',"Value":"',CONCAT(gd.DocumentNumber, '#', gd.DocumentDate),'"},')) END, 
			ReasonType = @CancelledInvoiceReasonType  + COALESCE(pdrm."ReasonType", 0),
			CancelledInvoiceId = t_pdrm.GstnId
	FROM
		#TempCrossDocumentMatchedData t_pdrm
	INNER JOIN Oregular.Gstr2bDocumentRecoMapper pdrm ON t_pdrm.PrId = pdrm.GstnId
	INNER JOIN #TempGstnOnlyData gd ON  t_pdrm.GstnId = gd.Id													   
	WHERE
		COALESCE(pdrm.Reason,'[]') NOT LIKE '%' + @CancelledInvoiceReasonType + '%'
		AND t_pdrm.Source = 'Gstn'; 

	UPDATE pdrm
		SET Reason = CASE WHEN COALESCE(pdrm.Reason,'[]') = '[]' 
						  THEN CONCAT('[{Reason:', @CancelledInvoiceReasonType ,',"Value":"',CASE WHEN pd.DocumentNumber IS NOT NULL THEN CONCAT(pd.DocumentNumber, '#', pd.DocumentDate) ELSE CONCAT(gd.DocumentNumber, '+', gd.DocumentDate) END,'"}]') 
					 				ELSE REPLACE(pdrm.Reason,'[',CONCAT('[{Reason:',
														@CancelledInvoiceReasonType
													,',"Value:"',CASE WHEN pd.DocumentNumber IS NOT NULL THEN CONCAT(pd.DocumentNumber, '#', pd.DocumentDate) ELSE CONCAT(gd.DocumentNumber, '||', gd.DocumentDate) END,'"},')) END, 
			ReasonType = @CancelledInvoiceReasonType  + COALESCE(pdrm."ReasonType", 0),
			CancelledInvoiceId = t_pdrm.PrId
	FROM
		#TempCrossDocumentMatchedData t_pdrm
	INNER JOIN Oregular.Gstr2bDocumentRecoMapper pdrm ON t_pdrm.GstnId = pdrm.GstnId
	LEFT JOIN #TempGstnOnlyData gd ON  t_pdrm.PrId = gd.Id AND t_pdrm.Source = 'Gstn'
	LEFT JOIN #TempPrOnlyData pd ON  t_pdrm.PrId = pd.Id AND t_pdrm.Source = 'Pr'
	WHERE
		COALESCE(pdrm.Reason,'[]') NOT LIKE '%' + @CancelledInvoiceReasonType + '%';																					 
	
	--DROP TABLE IF EXISTS #TempCrossDocumentMatchedData,Reason;
	
END;
;
GO


DROP PROCEDURE IF EXISTS [oregular].[FilterReconciliationDataManual];
GO


/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[FilterReconciliationDataManual] 
* 	Comments			: 14-11-2019 | Udit Solanki	| Generate the reconciliation action summary on the basis of filtered data
							21-07-2020 | Sagar Patel | CGSP2-1380: Added new parameters
							18-11-2020 | Sagar Patel | CGSP2-1719: Icegate reconciliation
							21-04-2021 | Sagar Patel | Added IsShowClaimedItcRecords parameter
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 

DECLARE  @TotalRecord INT,
		@Ids Common.[BigIntType],
		@EntityIds AS [common].[IntType],
		@JSON1 VARCHAR(MAX) = '[{"Item":14639}]';

	INSERT INTO @EntityIds 
	SELECT * FROM OPENJSON(@JSON1) WITH(Item INT '$.Item');


EXEC oregular.SearchReconciliationDataManual
@Ids=@Ids,
@Start=0,
@Size=20,
@SubscriberId=531,
@EntityIds=@EntityIds,
@DocFinancialYear=202425,
@ManualMappingType=null,
@FromPrReturnPeriod=72017,
@ToPrReturnPeriod=72014,
@FromGstnReturnPeriod=null,
@ToGstnReturnPeriod=null,
@RecordName=null,
@DocumentNumbers=null,
@Gstins=null,
@Pans=null,
@ExcludePans=null,
@TradeNames=null,
@DocumentTypes=null,
@TransactionTypes=null,
@TaxPayerType=null,
@Actions=null,
@ActionStatus=null,
@PaymentStatus=null,
@Custom=null,
@ItcEligibility=null,
@FromDocumentDate=null,
@ToDocumentDate=null,
@FromStamp=null,
@ToStamp=null,
@FromActionsDate=null,
@ToActionsDate=null,
@ItcAvailability=null,
@ItcUnavailabilityReason=null,
@AmendmentType=1,
@SourceType=null,
@IsGstr3bFiled=null,
@Remark=null,
@ReconciliationSections=null,
@IsDocNumberLikeSearch=False,
@IsTradeNamesLikeSearch=False,
@IsAvailableInGstr2b=null,
@IsShowClaimedItcRecords=null,
@IsAvailableInGstr98a=null,
@Gstr98aFinancialYear=null,
@IsReverseCharge=null,
@IsNotificationSentReceived=null,
@IsNotificationStatusClosed=null,
@ItcClaimReturnPeriod=null,
@Gstr2bReturnPeriod=null,
@ReconciliationType=8,
@CpFilingPreference=null,
@Gstr3bSection=null,
@TransactionNature=null,
@TaxpayerStatus=null,
@IsBlacklistedVendor=null,
@GrcScoreFrom=0,
@GrcScoreTo=10,
@ReversalReclaim=null,
@TotalRecord=0,
@ModuleTypeORegularPurchase=10,
@AmendmentTypeOriginal=1,
@AmendmentTypeOriginalAmended=2,
@AmendmentTypeAmendment=3,
@ReconciliationTypeGstr2B=8,
@ItcEligibilityNone=-1,
@DocumentTypeCRN=2;
SELECT @TotalRecord;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[FilterReconciliationDataManual](
	@SubscriberId INT,
	@EntityIds AS common.[IntType] READONLY,
	@DocFinancialYear INT,
	@ManualMappingType INT,
	@FromPrReturnPeriod INT,
	@ToPrReturnPeriod INT,
	@FromGstnReturnPeriod INT,
	@ToGstnReturnPeriod INT,
	@RecordName VARCHAR(MAX),
	@DocumentNumbers VARCHAR(MAX),
	@Gstins VARCHAR(MAX),
	@Pans VARCHAR(MAX),
	@ExcludePans VARCHAR(MAX),
	@TradeNames VARCHAR(MAX),
	@DocumentTypes VARCHAR(MAX),
	@TransactionTypes VARCHAR(MAX),
	@TaxPayerType VARCHAR(MAX),
	@Actions VARCHAR(MAX),
	@PaymentStatus VARCHAR(MAX),
	@ActionStatus SMALLINT,
	@Custom VARCHAR(MAX),
	@ItcEligibility VARCHAR(MAX),
	@FromDocumentDate DATETIME,
	@ToDocumentDate DATETIME,
	@FromStamp DATETIME,
	@ToStamp DATETIME,
	@FromActionsDate DATETIME,
	@ToActionsDate DATETIME,
	@ItcAvailability SMALLINT,
	@ItcUnavailabilityReason SMALLINT,
	@AmendmentType SMALLINT,
	@SourceType INT,
	@IsGstr3bFiled BIT,
	@Start INT,
	@Size INT,
	@TotalRecord INT = null OUTPUT,
	@Remark VARCHAR(MAX),
	@ReconciliationSections VARCHAR(MAX),
	@AmendedType INT,
	@IsDocNumberLikeSearch BIT,
	@IsTradeNamesLikeSearch BIT,
	@IsAvailableInGstr2b BIT,
	@IsShowClaimedItcRecords BIT,
	@IsAvailableInGstr98a BIT,
	@Gstr98aFinancialYear BIT,
	@IsReverseCharge BIT,
	@IsNotificationSentReceived BIT,
	@IsNotificationStatusClosed BIT,
	@ItcClaimReturnPeriod INT,
	@Gstr2bReturnPeriod INT,
	@GetAllData BIT,
	@ReconciliationType SMALLINT,
	@CpFilingPreference SMALLINT,
	@IsDsu BIT,
	@Gstr3bSection VARCHAR(MAX),
	@TransactionNature SMALLINT = null,
	@ItcEligibilityNone SMALLINT,
	@AmendmentTypeOriginal SMALLINT,
	@AmendmentTypeOriginalAmended SMALLINT,
	@AmendmentTypeAmendment SMALLINT,
	@ReconciliationTypeGstr2b SMALLINT,
	@ModuleTypeOregularPurchase SMALLINT,
	@TaxpayerStatus varchar(max) = null,
	@IsBlacklistedVendor bit = null,
	@GrcScoreFrom smallint = null,
	@GrcScoreTo smallint = null,
	@ReversalReclaim int = null,
 	@ToBeClaimInSameMonth AS SMALLINT = 1,
	@ToBeReclaimFromOpeningBalance_4_D_1 AS SMALLINT = 2,
	@Reversal_4_B_2 AS SMALLINT = 3
)

AS
BEGIN

	/* Declare Variables */
	DECLARE @SQL AS NVARCHAR(MAX) = '',
		@OneToOneMapped AS TINYINT = 1,
		@MultipleMapped AS TINYINT = 2,
		@FromPrReturnPeriodDate date = convert(date,IIF(@FromPrReturnPeriod IS NOT NULL, CONCAT(RIGHT(@FromPrReturnPeriod,4), IIF(LEN(@FromPrReturnPeriod) = 6, LEFT(@FromPrReturnPeriod,2), CONCAT('0',LEFT(@FromPrReturnPeriod,1))), '01'), NULL),102),
		@ToPrReturnPeriodDate date = convert(date,IIF(@ToPrReturnPeriod IS NOT NULL, CONCAT( RIGHT(@ToPrReturnPeriod,4), IIF(LEN(@ToPrReturnPeriod) = 6, LEFT(@ToPrReturnPeriod,2), CONCAT('0',LEFT(@ToPrReturnPeriod,1))), '01'), NULL),102),
		@FromGstnReturnPeriodDate date = convert(date,IIF(@FromGstnReturnPeriod IS NOT NULL, CONCAT( RIGHT(@FromGstnReturnPeriod,4), IIF(LEN(@FromGstnReturnPeriod) = 6, LEFT(@FromGstnReturnPeriod,2), CONCAT('0',LEFT(@FromGstnReturnPeriod,1))), '01'), NULL),102),
		@ToGstnReturnPeriodDate date = convert(date,IIF(@ToGstnReturnPeriod IS NOT NULL, CONCAT( RIGHT(@ToGstnReturnPeriod,4), IIF(LEN(@ToGstnReturnPeriod) = 6, LEFT(@ToGstnReturnPeriod,2), CONCAT('0',LEFT(@ToGstnReturnPeriod,1))), '01'), NULL),102);


	DROP TABLE IF EXISTS #TempFilteredId, #TempEntities, #TempPurchaseDocumentReco, #TempPurchaseDocumentRecoManualMapperIds,#TempTradeNames,#TempDocumentNumbers;
	DROP TABLE IF EXISTS #TempGstinPreferences;
	CREATE TABLE #TempGstinPreferences(
		Gstin varchar
	);
	

	IF @CpFilingPreference IS NOT NULL
	BEGIN
		
		;WITH cte AS
		(
			SELECT
				ROW_NUMBER() OVER(PARTITION BY gp.GstinId ORDER BY gp.FinancialYear, gp.Quarter DESC) RowNum,
				sg.Gstin,
				gp.Preference
			FROM
				gst.SubscriberGstin sg
				INNER JOIN gst.GstinPreferences gp ON gp.GstinId = sg.Id
			WHERE sg.SubscriberId = @SubscriberId
		)
		
		INSERT INTO #TempGstinPreferences(Gstin)
		SELECT
			c.Gstin
		FROM
			cte c
		WHERE
			c.RowNum = 1 
			AND c.Preference = @CpFilingPreference;
	END;	
	
	/* table to store filtered IDs */
	CREATE TABLE #TempFilteredId(
		Id Int IDENTITY(1,1),
		PurchaseDocumentRecoManualMapperId BIGINT NOT NULL,
		ModifiedStamp DATETIME,
		Stamp DATETIME
	);

	/* table to store entities */
	CREATE TABLE #TempEntities(
		Id Int IDENTITY(1,1),
		EntityId BIGINT NOT NULL
	);
	
	CREATE CLUSTERED INDEX IX_Entities ON #TempEntities(EntityId);

	/* table for manual mapped Pr & Gst Ids */
	CREATE TABLE #TempPurchaseDocumentReco(
		PurchaseDocumentRecoManualMapperId BIGINT NOT NULL,
		PurchaseDocumentRecoId BIGINT NOT NULL,
		ModifiedStamp DATETIME,
		Stamp DATETIME
	);
	
	CREATE INDEX IX_PurchaseDocumentReco_GstId ON #TempPurchaseDocumentReco(PurchaseDocumentRecoId);

	
	/* Insert entity in table from table type */
	INSERT INTO #TempEntities(
		EntityId
	)
	SELECT 
		* 
	FROM 
		@EntityIds;

	/* Insert data in from @DocumentNumbers */
	SELECT
		REPLACE([Value], '''', '') AS Value
	INTO #TempDocumentNumbers
	FROM
		STRING_SPLIT(@DocumentNumbers, ',');

	SELECT
		REPLACE([Value], '''', '') AS Value
	INTO #TempTradeNames
	FROM
		STRING_SPLIT(@TradeNames, ',');

	DROP TABLE IF EXISTS #TempGstr3bSection;
	SELECT
		REPLACE([Value], '''', '') AS Item
	INTO #TempGstr3bSection
	FROM
		STRING_SPLIT(@Gstr3bSection, ',');

	DROP TABLE IF EXISTS #TempTaxpayerStatus;
	SELECT
		[Value]
	INTO #TempTaxpayerStatus
	FROM
		STRING_SPLIT(@TaxpayerStatus, ',');

	IF (@FromPrReturnPeriod IS NOT NULL AND @ToPrReturnPeriod IS NOT NULL)
	BEGIN	
	print 'Test1';
		SELECT @SQL += CONCAT(
						N'
						INSERT INTO #TempPurchaseDocumentReco
						(
							PurchaseDocumentRecoManualMapperId,
							PurchaseDocumentRecoId,
							Stamp,
							ModifiedStamp
						)
						SELECT
							PDRMM.Id AS PurchaseDocumentRecoManualMapperId,
							Pr.PrId,
							PDRMM.Stamp,
							PDRMM.ModifiedStamp
						FROM
							oregular.PurchaseDocumentRecoManualMapper PDRMM 
							OUTER APPLY OPENJSON(PrIds) WITH (PrId BIGINT ''$.PrId'') AS Pr 																						  
						WHERE
								PDRMM.SubscriberId = @SubscriberId
							AND PDRMM.ParentEntityId IN (SELECT EntityId FROM #TempEntities)
						', 
						CASE 
						WHEN @RecordName IS NOT NULL
						THEN  ' AND PDRMM.RecordName = @RecordName '
						END,
						CASE 
						WHEN @ReconciliationSections IS NOT NULL
						THEN  ' AND PDRMM.SectionType IN (' + @ReconciliationSections +') '
						END,
						CASE 
						WHEN @IsAvailableInGstr2b IS NOT NULL 
						THEN ' AND PDRMM.IsAvailableInGstr2b = @IsAvailableInGstr2b '
						END,
						CASE
						WHEN @ReconciliationType IS NOT NULL
						THEN ' AND PDRMM.ReconciliationType = @ReconciliationType'  
						END
			);
		END;
		print 'SQL 1: ' + @SQL;
		--SET @SQL = '';

		IF (@FromGstnReturnPeriod IS NOT NULL AND @ToGstnReturnPeriod IS NOT NULL)
		BEGIN
		print 'Test2';
			SELECT @SQL += CONCAT(@SQL, ';', 
								N' 
								INSERT INTO #TempPurchaseDocumentReco
								(
									PurchaseDocumentRecoManualMapperId,
									PurchaseDocumentRecoId,
									Stamp,
									ModifiedStamp
								)
								SELECT
									PDRMM.Id AS PurchaseDocumentRecoManualMapperId,
									Gst.GstId,
									PDRMM.Stamp,
									PDRMM.ModifiedStamp
								FROM
									oregular.PurchaseDocumentRecoManualMapper PDRMM
									OUTER APPLY OPENJSON(GstIds) WITH (GstId BIGINT ''$.GstId'') AS Gst 															   
								WHERE
										PDRMM.SubscriberId = @SubscriberId
									AND PDRMM.ParentEntityId IN (SELECT EntityId FROM #TempEntities)
								',
								CASE 
									WHEN @ReconciliationSections IS NOT NULL
									THEN  ' AND PDRMM.SectionType IN (' + @ReconciliationSections +') '
								END,
								CASE 
									WHEN @RecordName IS NOT NULL
									THEN  ' AND PDRMM.RecordName = @RecordName '
								END,
								CASE 
									WHEN @IsAvailableInGstr2b IS NOT NULL 
									THEN ' AND PDRMM.IsAvailableInGstr2b = @IsAvailableInGstr2b '
								END,
								CASE
									WHEN @ReconciliationType IS NOT NULL
									THEN ' AND PDRMM.ReconciliationType = @ReconciliationType' 
								END
							);
					END;
	
	EXEC SP_EXECUTESQL @SQL, 
			N'@SubscriberId INT,
			@RecordName VARCHAR(50),
			@IsAvailableInGstr2b BIT,
			@ReconciliationType SMALLINT
			',
			@SubscriberId = @SubscriberId,
			@RecordName = @RecordName,
			@IsAvailableInGstr2b = @IsAvailableInGstr2b,
			@ReconciliationType = @ReconciliationType;													 
	print 'SQL 1.1: ' + @SQL;
	SET @SQL = '';
	print 'SQL 1: ' + @SQL;
	IF EXISTS (SELECT 1 From #TempPurchaseDocumentReco)
	BEGIN		
	print 'Test3';
		SELECT @SQL = CONCAT(
					N'
					INSERT INTO #TempFilteredId (
						PurchaseDocumentRecoManualMapperId,
						ModifiedStamp,
						Stamp
					) 
					SELECT DISTINCT
						tPDR.PurchaseDocumentRecoManualMapperId,
						tPDR.ModifiedStamp,
						tPDR.Stamp
					FROM oregular.PurchaseDocuments PDR
						INNER JOIN #TempPurchaseDocumentReco tPDR ON PDR.Id = tPDR.PurchaseDocumentRecoId
						INNER JOIN oregular.PurchaseDocumentStatus PS ON PS.PurchaseDocumentId = PDR.Id									
					',
					CASE 
						WHEN @PaymentStatus IS NOT NULL
						THEN 
							' LEFT JOIN oregular.PurchaseDocumentPayments PDP ON PDR.Id = PDP.PurchaseDocumentId '
					END,
					CASE 
						WHEN @AmendmentType IS NOT NULL OR @Gstins IS NOT NULL OR @Pans IS NOT NULL OR @ExcludePans IS NOT NULL OR @TradeNames IS NOT NULL  OR @CpFilingPreference IS NOT NULL OR @TaxpayerStatus IS NOT NULL OR @IsBlacklistedVendor IS NOT NULL OR @GrcScoreFrom IS NOT NULL
						THEN 
							' LEFT JOIN oregular.PurchaseDocumentContacts PDC ON PDR.Id = PDC.PurchaseDocumentId AND PDC.Type= 1'
					END,
					CASE WHEN @Custom IS NOT NULL
						THEN
							' LEFT JOIN oregular.PurchaseDocumentCustoms pdcu ON PDR.Id = pdcu.PurchaseDocumentId'
					END,
					CASE WHEN @TaxpayerStatus IS NOT NULL OR @IsBlacklistedVendor IS NOT NULL OR @GrcScoreFrom IS NOT NULL 
						THEN
						  ' INNER JOIN subscriber.Vendors V ON PDC.Gstin = v.Gstin AND PDR.SubscriberId = V.SubscriberId'
						END,
					'
					WHERE 
						1 = 1 ' ,
					CASE WHEN @ReconciliationType = @ReconciliationTypeGstr2b
							THEN
								' AND ((CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LEN(PDR.ReturnPeriod) = 6 THEN LEFT(PDR.ReturnPeriod,2) ELSE CONCAT(''0'',LEFT(PDR.ReturnPeriod,1)) END,''01'') Between @FromPrReturnPeriodDate AND @ToPrReturnPeriodDate AND PDR.SourceType = 1) OR
								(CASE WHEN PS.Gstr2BReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(PS.Gstr2BReturnPeriod,4), CASE WHEN LEN(PS.Gstr2BReturnPeriod) = 6 THEN LEFT(PS.Gstr2BReturnPeriod,2) ELSE CONCAT(''0'',LEFT(PS.Gstr2BReturnPeriod,1)) END ,''01'') END Between @FromGstnReturnPeriodDate AND @ToGstnReturnPeriodDate AND PDR.SourceType <> 1))' 									
							ELSE
								' AND ((CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LEN(PDR.ReturnPeriod) = 6 THEN LEFT(PDR.ReturnPeriod,2) ELSE CONCAT(''0'',LEFT(PDR.ReturnPeriod,1)) END,''01'') Between @FromPrReturnPeriodDate AND @ToPrReturnPeriodDate AND PDR.SourceType = 1) OR
								(CASE WHEN PDR.ReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LEN(PDR.ReturnPeriod) = 6 THEN LEFT(PDR.ReturnPeriod,2) ELSE CONCAT(''0'',LEFT(PDR.ReturnPeriod,1)) END ,''01'') END Between @FromGstnReturnPeriodDate AND @ToGstnReturnPeriodDate AND PDR.SourceType <> 1))' 										
					END,
					CASE 
						WHEN @DocumentTypes IS NOT NULL
						THEN  ' AND PDR.DocumentType IN ('+ @DocumentTypes +')'
						END,
					CASE 
						WHEN @DocFinancialYear IS NOT NULL
						THEN  ' AND PDR.DocumentFinancialYear IN ( @DocFinancialYear )'
						END,	
					CASE 
						WHEN @SourceType IS NOT NULL
						THEN ' AND PDR.SourceType = @SourceType' 
						END,
					CASE 
						WHEN @IsReverseCharge IS NOT NULL
						THEN ' AND PDR.ReverseCharge = @IsReverseCharge '  
						END,
					CASE 
						WHEN @TransactionTypes IS NOT NULL
						THEN  ' AND PDR.TransactionType IN ('+ @TransactionTypes +') '
						END,
					CASE 
						WHEN @TaxPayerType IS NOT NULL
						THEN ' AND PDR.TaxPayerType IN ('+ @TaxPayerType +') '
						END,
					CASE 
						WHEN @Gstins IS NOT NULL 
						THEN ' AND LOWER(PDC.Gstin) IN ('+ LOWER(@Gstins) +') '
						END,
					CASE 
						WHEN @CpFilingPreference IS NOT NULL 
						THEN ' AND EXISTS(SELECT 1 FROM #TempGstinPreferences tgp WHERE LOWER(tgp.Gstin) = LOWER(PDC.Gstin)) '
						END,
					CASE 
						WHEN @Pans IS NOT NULL 
						THEN ' AND LOWER(SUBSTRING(pdc.Gstin,3,10))  IN ('+ LOWER(@Pans) +') '
						END,
					CASE 
						WHEN @ExcludePans IS NOT NULL 
						THEN ' AND LOWER(SUBSTRING(pdc.Gstin,3,10))  NOT IN ('+ LOWER(@ExcludePans) +') '
					END,								
					CASE 
						WHEN @TradeNames IS NOT NULL AND @IsTradeNamesLikeSearch = 1
						THEN ' AND EXISTS(SELECT 1 FROM #TempTradeNames ttn WHERE LOWER(ISNULL(PDC.TradeName,PDC.LegalName)) LIKE ''%'' + LOWER(ttn.Value) + ''%'' )'
						END,
					CASE 
						WHEN @TradeNames IS NOT NULL And @IsTradeNamesLikeSearch = 0
						THEN ' AND LOWER(ISNULL(PDC.TradeName,PDC.LegalName)) IN ('+ LOWER(@TradeNames) +') '
						END,
					CASE	
						WHEN @DocumentNumbers IS NOT NULL AND @IsDocNumberLikeSearch = 1
						THEN ' AND EXISTS(SELECT 1 FROM #TempDocumentNumbers doc WHERE LOWER(PDR.DocumentNumber) LIKE ''%'' + LOWER(doc.Value) + ''%'' )'
						END,
					CASE	
						WHEN @DocumentNumbers IS NOT NULL AND @IsDocNumberLikeSearch = 0
						THEN ' AND EXISTS(SELECT 1 FROM #TempDocumentNumbers doc WHERE LOWER(PDR.DocumentNumber) = LOWER(doc.Value) )'
						END,
					CASE 
						WHEN @ActionStatus IS NOT NULL
						THEN ' AND CASE WHEN ps.Gstr2bAction= 1 THEN 1 ELSE 2 END = @ActionStatus '  
						END,
					CASE 
						WHEN @Actions IS NOT NULL
						THEN ' AND PS.Gstr2bAction IN (' + @Actions +') '
						END,
					CASE 
						WHEN @PaymentStatus IS NOT NULL
						THEN ' AND PDP.PaymentType IN ('+ @PaymentStatus +')'
						END,
					CASE
						WHEN @FromDocumentDate IS NOT NULL AND @ToDocumentDate IS NOT NULL
						THEN ' AND PDR.DocumentDate BETWEEN @FromDocumentDate AND @ToDocumentDate '
						END,
					CASE 
						WHEN @FromStamp IS NOT NULL AND @ToStamp IS NOT NULL  AND @IsDsu = 0
						THEN ' AND PS.Stamp BETWEEN @FromStamp AND @ToStamp '
						END,
					CASE 
						WHEN @FromStamp IS NOT NULL AND @ToStamp IS NOT NULL  AND @IsDsu = 1
						THEN ' AND tPDR.Stamp BETWEEN @FromStamp AND @ToStamp '
						END,
					CASE 
						WHEN @FromActionsDate IS NOT NULL AND @ToActionsDate IS NOT NULL
						THEN ' AND PS.ActionDate BETWEEN @FromActionsDate AND @ToActionsDate '
						END,
					CASE
						WHEN @ItcEligibility IS NOT NULL
						THEN ' AND EXISTS (SELECT 1 FROM oregular.PurchaseDocumentItems PDRI WHERE PDR.Id = PDRI.PurchaseDocumentId AND ISNULL( PDRI.ItcEligibility , @ItcEligibilityNone ) IN ('+ @ItcEligibility +')) '
						END,
					CASE 
						WHEN @ItcAvailability IS NOT NULL
						THEN ' AND PS.ItcAvailability = @ItcAvailability ' 
						END,
					CASE 
						WHEN @ItcUnavailabilityReason IS NOT NULL
						THEN ' AND PS.ItcUnavailabilityReason = @ItcUnavailabilityReason '
						END,
					CASE
						WHEN @AmendmentType IS NULL
						THEN ''
						ELSE 
							CASE 
								WHEN @AmendmentType = @AmendmentTypeOriginal
								THEN 
									' AND (NOT EXISTS(SELECT 1 FROM Oregular.PurchaseDocumentDW pda WHERE LOWER(pda.OriginalDocumentNumber) = LOWER(pdr.DocumentNumber) AND CAST(CAST(pda.OriginalDocumentDate AS VARCHAR) AS DATE) = pdr.DocumentDate AND ISNULL(pda.OriginalPortCode,'''') = ISNULL(pdr.PortCode,'''') AND ISNULL(LOWER(pda.BillFromGstin),'''') = ISNULL(LOWER(pdc.Gstin),'''')  AND pda.ParentEntityId IN (SELECT EntityId FROM #TempEntities) AND pda.CombineDocumentType = pdr.CombineDocumentType AND pda.SourceType = pdr.SourceType) AND pdr.IsAmendment = 0)'
								WHEN @AmendmentType = @AmendmentTypeOriginalAmended
								THEN 
										' AND (EXISTS(SELECT 1 FROM Oregular.PurchaseDocumentDW pda WHERE LOWER(pda.OriginalDocumentNumber) = LOWER(pdr.DocumentNumber) AND CAST(CAST(pda.OriginalDocumentDate AS VARCHAR) AS DATE) = pdr.DocumentDate AND ISNULL(pda.OriginalPortCode,'''') = ISNULL(pdr.PortCode,'''') AND ISNULL(LOWER(pda.BillFromGstin),'''') = ISNULL(LOWER(pdc.Gstin),'''')  AND pda.ParentEntityId IN (SELECT EntityId FROM #TempEntities) AND pda.CombineDocumentType = pdr.CombineDocumentType AND pda.SourceType = pdr.SourceType) AND pdr.IsAmendment = 0)'									
								WHEN @AmendmentType = @AmendmentTypeAmendment
								THEN ' AND pdr.IsAmendment = 1 '
							END
					END,
					CASE 
						WHEN @IsAvailableInGstr98a IS NOT NULL
						THEN 'AND PDR.SourceType <> 1 AND PS.IsAvailableInGstr98a = @IsAvailableInGstr98a' 
					END,
					CASE 
						WHEN @IsAvailableInGstr98a IS NOT NULL AND @Gstr98aFinancialYear IS NOT NULL
						THEN ' AND PDR.FinancialYear = @Gstr98aFinancialYear '
					END,
					CASE 
						WHEN @IsGstr3bFiled IS NOT NULL
						THEN '  AND PS.IsGstr3bFiled = @IsGstr3bFiled '
					END,
					CASE 
						WHEN @IsShowClaimedItcRecords = 1
						THEN ' AND PS.ItcClaimReturnPeriod IS NOT NULL '
					END,
					CASE 
						WHEN @ItcClaimReturnPeriod IS NOT NULL
						THEN ' AND PS.ItcClaimReturnPeriod = @ItcClaimReturnPeriod '
					END,
					CASE 
						WHEN @Remark IS NOT NULL
						THEN  ' AND LOWER(PS.Remarks) LIKE ''%' + LOWER(@Remark) + '%'''
					END,									
					CASE 
						WHEN @Gstr2bReturnPeriod IS NOT NULL
						THEN ' AND PS.Gstr2bReturnPeriod = @Gstr2bReturnPeriod '
					END,									
					CASE 
						WHEN @IsShowClaimedItcRecords = 0
						THEN ' AND PS.ItcClaimReturnPeriod IS NULL '
					END,
					CASE	
						WHEN @AmendedType IS NULL
						THEN ''
						ELSE ' AND PS.AmendedType = @AmendedType'
					END,
					CASE WHEN @Gstr3bSection IS NOT NULL 
						THEN ' AND EXISTS (SELECT 1 FROM #TempGstr3bSection WHERE PS.Gstr3bSection & Item <> 0)'
					END,
					CASE WHEN @TaxpayerStatus IS NOT NULL
							THEN ' AND V.TaxpayerType IN (SELECT * FROM #TempTaxpayerStatus) ' 
						END,
					CASE WHEN @IsBlacklistedVendor IS NOT NULL
							THEN ' AND V.IsBlackListed = @IsBlacklistedVendor ' 
						END,
					CASE WHEN @GrcScoreFrom IS NOT NULL
							THEN ' AND (V.SupplierGrcScore BETWEEN @GrcScoreFrom AND @GrcScoreTo OR V.Gstr1GrcScore BETWEEN @GrcScoreFrom AND @GrcScoreTo OR V.Gstr3bGrcScore BETWEEN @GrcScoreFrom AND @GrcScoreTo) ' 
						END,
					CASE 
						WHEN @ReversalReclaim = @ToBeClaimInSameMonth
						THEN ' AND PS.ItcClaimReturnPeriod = PS.Gstr2bReturnPeriod '
						END,
					CASE 
						WHEN @ReversalReclaim = @ToBeReclaimFromOpeningBalance_4_D_1
						THEN ' AND (CASE WHEN PS.ItcClaimReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(PS.ItcClaimReturnPeriod,4), CASE WHEN LENGTH(PS.ItcClaimReturnPeriod ) = 6 THEN  LEFT(PS.ItcClaimReturnPeriod,2) ELSE CONCAT(''0'',LEFT(PS.ItcClaimReturnPeriod,1)) END, ''01'') ELSE NULL END < (CASE WHEN PDR.ReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LENGTH(PDR.ReturnPeriod ) = 6 THEN  LEFT(PDR.ReturnPeriod,2) ELSE CONCAT(''0'',LEFT(PDR.ReturnPeriod,1)) END, ''01'') ELSE NULL END) '
						END,
					CASE 
						WHEN @ReversalReclaim = @Reversal_4_B_2
						THEN ' AND PS.ItcClaimReturnPeriod IS NULL '
						END,
					CASE 
						WHEN @Custom IS NOT NULL
						THEN ' AND 
								(LOWER(pdcu.Custom1) LIKE ''%''+ @Custom  +''%'' OR LOWER(pdcu.Custom2) LIKE ''%''+ @Custom  +''%'' OR LOWER(pdcu.Custom3) LIKE ''%''+ @Custom  +''%''
								OR LOWER(pdcu.Custom4) LIKE ''%''+ @Custom  +''%'' OR LOWER(pdcu.Custom5) LIKE ''%''+ @Custom  +''%'' OR LOWER(pdcu.Custom6) LIKE ''%''+ @Custom  +''%''
								OR LOWER(pdcu.Custom7) LIKE ''%''+ @Custom  +''%'' OR LOWER(pdcu.Custom8) LIKE ''%''+ @Custom  +''%'' OR LOWER(pdcu.Custom9) LIKE ''%''+ @Custom  +''%''
								OR LOWER(pdcu.Custom10) LIKE ''%''+ @Custom  +''%'')
								'
					END
					);
		
	END;
	print 'Test4';
	PRINT 'SQL: '+ @SQL;
	EXEC SP_EXECUTESQL  @SQL,
		N'	
		@IsReverseCharge bit,
		@FromDocumentDate datetime,
		@ToDocumentDate datetime,
		@FromStamp datetime,
		@ToStamp datetime,
		@FromActionsDate datetime,
		@ToActionsDate datetime,
		@ItcEligibilityNone smallint,
		@ItcAvailability smallint,
		@ItcUnavailabilityReason smallint,
		@IsAvailableInGstr98a bit,
		@Gstr98aFinancialYear int,
		@IsGstr3bFiled bit,
		@ItcClaimReturnPeriod int,
		@Gstr2bReturnPeriod int,
		@ActionStatus smallint,
		@SourceType smallint,
		@Custom varchar(MAX),
		@FromGstnReturnPeriodDate date,
		@ToGstnReturnPeriodDate date,
		@FromPrReturnPeriodDate date,
		@ToPrReturnPeriodDate date,
		@AmendedType smallint,
		@DocFinancialYear int,
		@IsBlacklistedVendor BIT,
		@GrcScoreFrom SMALLINT,
		@GrcScoreTo SMALLINT
		',		
		@IsReverseCharge = @IsReverseCharge,
		@FromDocumentDate = @FromDocumentDate,
		@ToDocumentDate = @ToDocumentDate,
		@FromStamp = @FromStamp,
		@ToStamp = @ToStamp,
		@FromActionsDate = @FromActionsDate,
		@ToActionsDate = @ToActionsDate,
		@ItcEligibilityNone = @ItcEligibilityNone,
		@ItcAvailability = @ItcAvailability,
		@ItcUnavailabilityReason = @ItcUnavailabilityReason,
		@IsAvailableInGstr98a = @IsAvailableInGstr98a,
		@Gstr98aFinancialYear = @Gstr98aFinancialYear,
		@IsGstr3bFiled = @IsGstr3bFiled,
		@ItcClaimReturnPeriod = @ItcClaimReturnPeriod,
		@Gstr2bReturnPeriod = @Gstr2bReturnPeriod,
		@ActionStatus = @ActionStatus,
		@SourceType = @SourceType,
		@Custom = @Custom,
		@FromGstnReturnPeriodDate = @FromGstnReturnPeriodDate,
		@ToGstnReturnPeriodDate = @ToGstnReturnPeriodDate,
		@FromPrReturnPeriodDate = @FromPrReturnPeriodDate,
		@ToPrReturnPeriodDate = @ToPrReturnPeriodDate,
		@AmendedType = @AmendedType,
		@DocFinancialYear = @DocFinancialYear,
		@IsBlacklistedVendor = @IsBlacklistedVendor,
		@GrcScoreFrom = @GrcScoreFrom,
		@GrcScoreTo = @GrcScoreTo;

	SELECT 
		DISTINCT 
		F.PurchaseDocumentRecoManualMapperId,
		F.ModifiedStamp,
		F.Stamp 						   
	INTO #TempPurchaseDocumentRecoManualMapperIds
	FROM 
		#TempFilteredId AS F;
		
	DROP TABLE IF EXISTS #TempFilterManualId;
	CREATE TABLE #TempFilterManualId
	(
		Id BIGINT
	);
	
	IF @ManualMappingType = @OneToOneMapped
	BEGIN
		INSERT INTO #TempFilterManualId
		SELECT 
			pdrm.Id
		FROM 
			#TempPurchaseDocumentRecoManualMapperIds fi
			INNER JOIN oregular.PurchaseDocumentRecoManualMapper pdrm ON fi.PurchaseDocumentRecoManualMapperId = pdrm.Id
			CROSS APPLY (SELECT * FROM OPENJSON(PrIds) WITH (PrId BIGINT))Pr
			CROSS APPLY (SELECT * FROM OPENJSON(GstIds) WITH (GstId BIGINT))Gst
		GROUP BY pdrm.Id HAVING COUNT(*) = 1;

		DELETE pdrm FROM #TempPurchaseDocumentRecoManualMapperIds pdrm WHERE NOT EXISTS (SELECT 1 FROM #TempFilterManualId fi WHERE fi.Id= pdrm.PurchaseDocumentRecoManualMapperId) ;
	END
	ELSE IF @ManualMappingType = @MultipleMapped
	BEGIN
		INSERT INTO #TempFilterManualId
		SELECT 
			pdrm.Id
		FROM 
			#TempPurchaseDocumentRecoManualMapperIds fi
			INNER JOIN oregular.PurchaseDocumentRecoManualMapper pdrm ON fi.PurchaseDocumentRecoManualMapperId = pdrm.Id
			CROSS APPLY (SELECT * FROM OPENJSON(PrIds) WITH (PrId BIGINT))Pr
			CROSS APPLY (SELECT * FROM OPENJSON(GstIds) WITH (GstId BIGINT))Gst
		GROUP BY pdrm.Id HAVING COUNT(*) > 1;

		DELETE pdrm FROM #TempPurchaseDocumentRecoManualMapperIds pdrm WHERE NOT EXISTS (SELECT 1 FROM #TempFilterManualId fi WHERE fi.Id= pdrm.PurchaseDocumentRecoManualMapperId) ;
	END;

	IF @Start = 0
	BEGIN
		
		SELECT 
			@TotalRecord = COUNT(PurchaseDocumentRecoManualMapperID)
		FROM 
			#TempPurchaseDocumentRecoManualMapperIds
	END;

	IF @GetAllData = 1
	BEGIN
		
			SELECT
				PurchaseDocumentRecoManualMapperId
			FROM 
				#TempPurchaseDocumentRecoManualMapperIds
			ORDER BY 
				ISNULL(ModifiedStamp, Stamp) DESC;
	END
	ELSE
	BEGIN
		
			SELECT
				PurchaseDocumentRecoManualMapperId
			FROM 
				#TempPurchaseDocumentRecoManualMapperIds
			ORDER BY 
				ISNULL(ModifiedStamp, Stamp) DESC
			OFFSET 
				@Start ROWS
			FETCH NEXT 
				@Size ROWS ONLY;
	END;
	print 'Test5';
	/* Drop tables */
	--DROP TABLE #TempFilteredId, #TempEntities, #TempPurchaseDocumentReco, #TempPurchaseDocumentRecoManualMapperIds,#TempTradeNames,#TempDocumentNumbers;

END;
;
GO


