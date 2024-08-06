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
		SUM(COALESCE(tpdac.IgstAmount_A,0) - COALESCE(tpdac.IgstAmount,0) + COALESCE(tpdac.PrItcIgstAmount,0) + COALESCE(tpdac.PrIgstAmount,0)) AS IgstAmount,
		SUM(COALESCE(tpdac.CgstAmount_A,0) - COALESCE(tpdac.CgstAmount,0) + COALESCE(tpdac.PrItcCgstAmount,0) + COALESCE(tpdac.PrCgstAmount,0)) AS CgstAmount,
		SUM(COALESCE(tpdac.SgstAmount_A,0) - COALESCE(tpdac.SgstAmount,0) + COALESCE(tpdac.PrItcSgstAmount,0) + COALESCE(tpdac.PrSgstAmount,0)) AS SgstAmount,
		SUM(COALESCE(tpdac.CessAmount_A,0) - COALESCE(tpdac.CessAmount,0) + COALESCE(tpdac.PrItcCessAmount,0) + COALESCE(tpdac.PrCessAmount,0)) AS CessAmount
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
			(
				tpdac.PrTotalItcAmount > 0
				AND ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
			)
			OR
			(
				tpdac.PrTotalTaxAmount > 0
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
			(
				tpdac.PrTotalItcAmount > 0
				AND ABS(tpdac.PrTotalItcAmount) < ABS(tpdac.TotalTaxAmount_A)
			)
			OR
			(
				tpdac.PrTotalTaxAmount > 0
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


