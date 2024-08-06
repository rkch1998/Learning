DROP PROCEDURE IF EXISTS [ oregular].[InsertDownloadedSaleDocuments];
GO


/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertDownloadedSaleDocuments]
* 	Comments			: 08-06-2020 | Mayur Ladva | Insert Sale Document From GSTR1 Api download data
						: 28/07/2020 | Pooja Rajpurohit | Renamed table name to SaledocumentDw.
						: 29-07-2020 | Pooja Rajpurohit | Removed Insert/update portion for DW table and instead use sp '[Oregular].[InsertSaleDocumentDW]' for same.
						: 17-03-2021 | Dhruv Amin | Added Autopopulate AutoDraftedEInvoice related logic.
						: 29-09-2021 | Dhruv Amin | AutoDrafted Record Overwrite logic for handling errorcode RET191248.
						: 08-10-2021 | Dhruv Amin | Handled scenario for IsAutodrafted flag update in case of gstr1 manual sync.
						: 19-11-2021 | Dhruv Amin | Handled scenario for updating autodrafted records.
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE oregular.[InsertDownloadedSaleDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@ReturnPeriod INT,
	@FinancialYear INT,
	@IsAutoDrafted BIT,
	@SourceType SMALLINT,
	@SectionType BIGINT,
	@IsAmendment BIT,
	@Gstin VARCHAR(15),
	@IsAutoDraftSummaryGenerationEnabled BIT,
	@SaleDocuments [oregular].[DownloadedSaleDocumentType] READONLY,
	@SaleDocumentContacts [oregular].[DownloadedSaleDocumentContactType] READONLY,
	@SaleDocumentItems oregular.[DownloadedSaleDocumentItemType] READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@MismatchErrors VARCHAR(2000),
	@PushToGstStatusUploadedButNotPushed SMALLINT,
	@PushToGstStatusPushed SMALLINT,
	@PushToGstStatusCancelled SMALLINT,
	@SourceTypeAutoDraft SMALLINT,
	@SourceTypeTaxpayer SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@TaxTypeTAXABLE SMALLINT,
	@ContactTypeBillTo SMALLINT,
	@PushToGstStatusDeleted SMALLINT,
	@GstinErrorTypeApiSectionMismatch SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@False BIT = 0,
		@True BIT= 1,
		@CurrentDate DATETIME = GETDATE();
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	/*Adding Temp tables and Data from TableType Parameters*/
	CREATE TABLE #TempSaleDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		EInvoiceDocumentId BIGINT,
		GroupId INT,
		BillingDate DATETIME,
		SourceType SMALLINT,
		SectionType BIGINT,
		ECommerceGstin VARCHAR(15),
		DocumentDate SMALLDATETIME,
		TransactionType SMALLINT,
		SeriesCode VARCHAR(16),
		Mode CHAR(2),
		DocumentNumber VARCHAR(40),
		DocumentFinancialYear INT,
		DocumentType SMALLINT
	);

	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL	
	);
	
	CREATE CLUSTERED INDEX IDX_TempUpsertDocumentIds ON #TempUpsertDocumentIds (ID);

	SELECT 
		*
	INTO 
		#TempSaleDocuments
	FROM  
		@SaleDocuments tsd;

	SELECT 
		*
	INTO 
		#TempSaleDocumentReferences
	FROM 
		@DocumentReferences

	SELECT
		*
	INTO 
		#TempSaleDocumentItems
	FROM
		@SaleDocumentItems;

	SELECT
		*
	INTO 
		#TempSaleDocumentContacts
	FROM
		@SaleDocumentContacts;

	/*Mapping record with overwrite scenarios*/
	/*
	Flag Description
	U : Update
	UE : Update Section Mismatch records.
	AU : AutoDrafted Record Overwrite.
	C : Cancelled record, Cancelling AutoPopulated records.
	F : Update IsAutoDrafted = 0, Because Deleted records are overwrited by user.
	S : Skip overwriting, Because Record is not autodrafted status anymore.
	*/
	INSERT INTO #TempSaleDocumentIds
	(
		Id,
		GroupId,
		Mode,
		BillingDate,
		SourceType,
		"SectionType",
		"DocumentDate",
		"ECommerceGstin",
		"TransactionType",
		"DocumentNumber",
		"DocumentFinancialYear",
		"DocumentType"
	)
	SELECT
	   sd.Id,
	   tsd.GroupId,
	   CASE 
			WHEN @SourceType = @SourceTypeAutoDraft THEN 'U'
			WHEN @SourceType = @SourceTypeTaxpayer AND sd.SectionType & @SectionType = 0 THEN 'UE' 
			WHEN @SourceType = @SourceTypeTaxpayer AND @IsAutoDrafted = @False THEN 'U' 
			WHEN @SourceType = @SourceTypeTaxpayer AND @IsAutoDrafted = @True AND ss.IsPushed = @True AND tsd.PushStatus = @PushToGstStatusPushed AND ss.PushStatus = @PushToGstStatusPushed AND ISNULL(tsd.AutoDraftSource,'') = ISNULL(ss.AutoDraftSource,'') THEN 'AU'
			WHEN @SourceType = @SourceTypeTaxpayer AND @IsAutoDrafted = @True AND ss.IsAutoDrafted = @True AND ss.IsPushed = @True AND tsd.PushStatus = @PushToGstStatusCancelled AND ss.PushStatus = @PushToGstStatusPushed THEN 'C'
			WHEN @SourceType = @SourceTypeTaxpayer AND @IsAutoDrafted = @True AND ss.IsAutoDrafted = @True AND ss.IsPushed = @True AND tsd.PushStatus = @PushToGstStatusCancelled THEN 'F' 
			ELSE 'S'
	   END,
	   ISNULL(ss.BillingDate,@CurrentDate),
	   sd.SourceType,
	   sd.SectionType,
	   CONVERT (datetime,cast(sd.DocumentDate as varchar)) AS DocumentDate,
	   sd.ECommerceGstin,
	   sd.TransactionType,
	   sd.DocumentNumber,
	   sd.DocumentFinancialYear,
	   sd.DocumentType
	FROM
		#TempSaleDocuments tsd
		INNER JOIN oregular.SaleDocumentDW AS sd ON
		(
			sd.DocumentNumber = tsd.DocumentNumber
			AND sd.ParentEntityId = @EntityId
			AND sd.DocumentFinancialYear = tsd.DocumentFinancialYear 
			AND sd.CombineDocumentType = sd.CombineDocumentType
			AND sd.SourceType = @SourceType
			AND sd.IsAmendment = @IsAmendment
			AND sd.SubscriberId = @SubscriberId			
			AND sd.DocumentType = tsd.DocumentType			
		)
		INNER JOIN oregular.SaleDocumentStatus ss ON sd.Id = ss.SaleDocumentId;

	-- Insert Data For Sale Documnet 

	INSERT INTO [oregular].[SaleDocuments]
	(
		SubscriberId,
		ParentEntityId,
		EntityId,
		UserId,
		IsPreGstRegime,
		Irn,
		IrnGenerationDate,
		DocumentType,
		TransactionType,
		TaxpayerType,
		DocumentNumber,
		DocumentDate,
		BillNumber,
		BillDate,
		PortCode,
		Pos,
		DocumentValue,
		DifferentialPercentage,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		RefundEligibility,
		ECommerceGstin,
		OriginalDocumentNumber,
		OriginalDocumentDate,		
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		TotalRateWiseTaxableValue,
		TotalRateWiseTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,
		SourceType,
		RefPrecedingDocumentDetails,
		GroupId,
		CombineDocumentType,
		TransactionNature,
		DocumentReturnPeriod
	)
	OUTPUT 
		inserted.Id, inserted.GroupId, 'I', @CurrentDate, inserted.SourceType, inserted.SectionType, inserted.DocumentDate, inserted.ECommerceGstin, inserted.TransactionType, inserted.DocumentNumber, inserted.DocumentFinancialYear, inserted.DocumentType
	INTO 
		#TempSaleDocumentIds(Id, GroupId, Mode, BillingDate, SourceType, SectionType, DocumentDate, ECommerceGstin, TransactionType, DocumentNumber, DocumentFinancialYear, DocumentType)
	SELECT
		@SubscriberId,
		@EntityId,
		@EntityId,
		@UserId,
		IsPreGstRegime,
		Irn,
		IrnGenerationDate,
		DocumentType,
		TransactionType,
		TaxpayerType,
		DocumentNumber,
		DocumentDate,
		BillNumber,
		BillDate,
		PortCode,
		Pos,
		DocumentValue,
		DifferentialPercentage,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		RefundEligibility,
		ECommerceGstin,
		OriginalDocumentNumber,
		OriginalDocumentDate,		
		@SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		TotalRateWiseTaxableValue,
		TotalRateWiseTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		@IsAmendment,
		@SourceType,
		RefPrecedingDocumentDetails,
		GroupId,
		CASE WHEN tsd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tsd.DocumentType END AS CombineDocumentType,
		TransactionNature,
		DocumentReturnPeriod
	FROM
		#TempSaleDocuments tsd 
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempSaleDocumentIds)
	
	INSERT INTO oregular.SaleDocumentStatus
	(
		SaleDocumentId,
		[Status],
		PushStatus,
		[Action],
		IsPushed,
		[Checksum],
		AutoDraftSource,
		IsAutoDrafted,
		CancelledDate,
		Errors,
		LastSyncDate,
		OriginalReturnPeriod,
		BillingDate
	)
	SELECT  
		tsdids.Id AS SaleDocumentId,
		tsd.[Status],
		tsd.PushStatus,
		tsd.[Action],
		tsd.IsPushed,
		tsd.[Checksum],
		tsd.AutoDraftSource,
		tsd.IsAutoDrafted,
		tsd.CancelledDate,
		tsd.Errors,
		@CurrentDate,
		tsd.OriginalReturnPeriod,
		@CurrentDate
	FROM
		#TempSaleDocumentIds AS tsdids
		INNER JOIN #TempSaleDocuments tsd on tsdids.GroupId = tsd.GroupId
	WHERE 
		tsdids.Mode = 'I'

	IF EXISTS(SELECT 1 FROM #TempSaleDocumentIds AS tsdids WHERE tsdids.Mode = 'U')
	BEGIN
		UPDATE
			oregular.SaleDocuments
		SET
			ParentEntityId = @EntityId,
			EntityId = @EntityId,
			UserId = @UserId,
			IsPreGstRegime = tsd.IsPreGstRegime,
			Irn = tsd.Irn,
			IrnGenerationDate = tsd.IrnGenerationDate,
			DocumentType = tsd.DocumentType,
			TransactionType = tsd.TransactionType,
			TaxpayerType = tsd.TaxpayerType,
			DocumentNumber = tsd.DocumentNumber,
			DocumentDate = tsd.DocumentDate,
			BillNumber = tsd.BillNumber,
			BillDate = tsd.BillDate,
			PortCode = tsd.PortCode,
			Pos = tsd.Pos,
			DocumentValue = tsd.DocumentValue,
			DifferentialPercentage = tsd.DifferentialPercentage,
			ReverseCharge = tsd.ReverseCharge,
			ClaimRefund = tsd.ClaimRefund,
			UnderIgstAct = tsd.UnderIgstAct,
			RefundEligibility = tsd.RefundEligibility,
			ECommerceGstin = tsd.ECommerceGstin,
			OriginalDocumentNumber = tsd.OriginalDocumentNumber,
			OriginalDocumentDate = tsd.OriginalDocumentDate,		
			TotalRateWiseTaxableValue = tsd.TotalRateWiseTaxableValue,
			TotalRateWiseTaxAmount = tsd.TotalRateWiseTaxAmount,
			ReturnPeriod = tsd.ReturnPeriod,
			DocumentFinancialYear = tsd.DocumentFinancialYear,
			FinancialYear = tsd.FinancialYear,
			ModifiedStamp = @CurrentDate,
			GroupId = tsd.GroupId,
			CombineDocumentType = CASE WHEN tsd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tsd.DocumentType END,
			TransactionNature = tsd.TransactionNature,
			DocumentReturnPeriod = tsd.DocumentReturnPeriod
		FROM
			oregular.SaleDocuments AS sd
			INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdids.Id = sd.Id
			INNER JOIN #TempSaleDocuments AS tsd ON tsd.groupId = tsdids.GroupId
		WHERE
			tsdids.Mode = 'U';
			
		UPDATE
			oregular.SaleDocumentStatus
		SET 
			[Status] = tsd.[Status],
			PushStatus = CASE WHEN @SourceType = @SourceTypeAutoDraft AND ss.PushStatus = @PushToGstStatusDeleted THEN ss.PushStatus ELSE tsd.PushStatus END,
			IsPushed = tsd.IsPushed,
			[Action] = tsd.[Action],
			[Checksum] = tsd.[Checksum],
			IsAutoDrafted = CASE WHEN ss.IsAutoDrafted = @True AND @SourceType = @SourceTypeTaxpayer AND @IsAutoDrafted = @False AND tsd.[Checksum] = ss.[Checksum] THEN ss.IsAutoDrafted ELSE tsd.IsAutoDrafted END, --Handled condition for overwriting IsAutoDrafted flag in case of manaul gstr1 sync.
			AutoDraftSource = tsd.AutoDraftSource,
			CancelledDate = ISNULL(tsd.CancelledDate,ss.CancelledDate),
			Errors = tsd.Errors,
			BillingDate = tsdids.BillingDate,
			LastSyncDate = @CurrentDate,
			ModifiedStamp = @CurrentDate,
			OriginalReturnPeriod = tsd.OriginalReturnPeriod
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIds AS tsdids ON ss.SaleDocumentId = tsdids.Id
			INNER JOIN #TempSaleDocuments tsd on tsdids.GroupId = tsd.GroupId
		WHERE 
			tsdids.Mode = 'U';

		/*Delete and Insert Contact details for BillTo detail*/
		SELECT
			sdc.Id,	
			tsdi.Id AS SaleDocumentId,
			tsdc.Gstin,
			tsdc.TradeName,
			tsdc.LegalName,
			tsdc.[Type]
			--CASE 
			--	WHEN tsdc.Gstin <> sdc.Gstin 
			--		 OR (ISNULL(sdc.TradeName,sdc.LegalName) IS NULL AND ISNULL(tsdc.TradeName,tsdc.LegalName) IS NOT NULL) 
			--	THEN @True 
			--	ELSE @False 
			--END AS UpdateContacts
		INTO
			#TempSaleDocumentContactDetails
		FROM 
			#TempSaleDocumentIds AS tsdi 
			INNER JOIN oregular.SaleDocumentContacts AS sdc ON tsdi.Id = sdc.SaleDocumentId AND sdc.[Type] = @ContactTypeBillTo
			INNER JOIN #TempSaleDocumentContacts tsdc ON tsdi.GroupId = tsdc.GroupId AND tsdc.[Type] = @ContactTypeBillTo
		WHERE
			tsdi.Mode = 'U';

		DELETE 
			sdc
		FROM 
			oregular.SaleDocumentContacts AS sdc
			INNER JOIN #TempSaleDocumentContactDetails AS tsdcd ON tsdcd.Id = sdc.Id;
		
		INSERT INTO [oregular].[SaleDocumentContacts]
		(
			SaleDocumentId,
			Gstin,
			TradeName,
			LegalName,
			[Type]
		)
		SELECT
			tsdcd.SaleDocumentId,
			tsdcd.Gstin,
			tsdcd.TradeName,
			tsdcd.LegalName,
			tsdcd.[Type]
		FROM
			#TempSaleDocumentContactDetails AS tsdcd;

		DROP TABLE #TempSaleDocumentContactDetails;
	END;	
	/* Delete SaleDocumentItems and contacts */
	IF EXISTS (SELECT AutoId FROM #TempSaleDocumentIds WHERE Mode = 'U')
	BEGIN
		DECLARE 
			@Min INT = 1, 
			@Max INT, 
			@BatchSize INT, 
			@Records INT;

		SELECT 
			@Max = COUNT(AutoId)
		FROM 
			#TempSaleDocumentIds

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			SET @Records = @Min + @BatchSize;

			DELETE 
				sdri
			FROM 
				oregular.SaleDocumentRateWiseItems AS sdri
				INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdids.Id = sdri.SaleDocumentId
			WHERE 
				tsdids.Mode = 'U'
				AND tsdids.AutoId BETWEEN @Min AND @Records;
			SET @Min = @Records
		END
	END
	
	INSERT INTO #TempUpsertDocumentIds (Id)
	SELECT 
		Id 
	FROM 
		#TempSaleDocumentIds
	
	INSERT INTO [oregular].[SaleDocumentContacts]
	(
		SaleDocumentId,
		Gstin,
		TradeName,
		LegalName,
		[Type]
	)
	SELECT
		tsdids.Id,
		tsdc.Gstin,
		tsdc.TradeName,
		tsdc.LegalName,
		tsdc.[Type]
	FROM
		#TempSaleDocumentContacts AS tsdc
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdc.GroupId = tsdids.GroupId
	WHERE
		tsdids.Mode = 'I';

	IF(@IsAutoDraftSummaryGenerationEnabled = @True) /*Case when setting is on with checkbox selected*/
	BEGIN
		UPDATE
			tsdi
		SET
			EInvoiceDocumentId = d.Id,
			SectionType = d.SectionType,
			SeriesCode = d.SeriesCode,
			ECommerceGstin = tsd.ECommerceGstin,
			DocumentDate = tsd.DocumentDate,
			TransactionType = tsd.TransactionType
		FROM
			#TempSaleDocumentIds AS tsdi
			INNER JOIN #TempSaleDocuments AS tsd ON tsd.GroupId = tsdi.GroupId
			INNER JOIN einvoice.DocumentStatus AS ds ON ds.Irn = tsd.Irn 
			INNER JOIN einvoice.Documents AS d ON d.Id = ds.DocumentId
		WHERE
			ds.Irn IS NOT NULL
			AND tsdi.Mode IN ('I','AU')
			AND d.SectionType IS NOT NULL
			AND d.SubscriberId = @SubscriberId;
			
		DELETE 
			sdi
		FROM 
			[oregular].[SaleDocumentItems] AS sdi
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdi.SaleDocumentId
		WHERE 
			tsdi.Mode = 'AU'
			AND tsdi.EInvoiceDocumentId IS NOT NULL;

		INSERT INTO [oregular].[SaleDocumentItems]
		(
			SaleDocumentId,
			SerialNumber,
			IsService,
			Hsn,
			ProductCode,
			[Name],
			[Description],
			Barcode,
			Uqc,
			Quantity,
			FreeQuantity,
			Rate,
			CessRate,
			StateCessRate,
			CessNonAdvaloremRate,
			PricePerQuantity,
			DiscountAmount,
			GrossAmount,
			OtherCharges,
			TaxableValue,
			IgstAmount,
			CgstAmount,
			SgstAmount,
			CessAmount,
			StateCessAmount,
			StateCessNonAdvaloremAmount,
			CessNonAdvaloremAmount,
			TaxType,
			Stamp
		)
		SELECT
			tsdi.Id,
			di.SerialNumber,
			di.IsService,
			di.Hsn,
			di.ProductCode,
			di.[Name],
			di.[Description],
			di.Barcode,
			di.Uqc,
			di.Quantity,
			di.FreeQuantity,
			di.Rate,
			di.CessRate,
			di.StateCessRate,
			di.CessNonAdvaloremRate,
			di.PricePerQuantity,
			di.DiscountAmount,
			di.GrossAmount,
			di.OtherCharges,
			di.TaxableValue,
			di.IgstAmount,
			di.CgstAmount,
			di.SgstAmount,
			di.CessAmount,
			di.StateCessAmount,
			di.StateCessNonAdvaloremAmount,
			di.CessNonAdvaloremAmount,
			ISNULL(di.TaxType, @TaxTypeTAXABLE),
			GETDATE()
		FROM
			#TempSaleDocumentIds AS tsdi
			INNER JOIN einvoice.DocumentItems AS di ON di.DocumentId = tsdi.EInvoiceDocumentId
		WHERE
			tsdi.Mode IN ('I','AU')
			AND tsdi.EInvoiceDocumentId IS NOT NULL;

		INSERT INTO [oregular].[SaleDocumentItems] /*Inserting item where Einvoice has data with irn is not available */
		(
			SaleDocumentId,
			TaxType,
			Rate,
			TaxableValue,
			IgstAmount,
			CgstAmount,
			SgstAmount,
			CessAmount,
			GstActOrRuleSection
		)
		SELECT
			tsdids.Id,
			tsdi.TaxType,
			tsdi.Rate,
			tsdi.TaxableValue,
			tsdi.IgstAmount,
			tsdi.CgstAmount,
			tsdi.SgstAmount,
			tsdi.CessAmount,
			tsdi.GstActOrRuleSection
		FROM
			#TempSaleDocumentItems AS tsdi
			INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdi.GroupId = tsdids.GroupId
		WHERE
			tsdids.Mode = 'I'
			AND tsdids.EInvoiceDocumentId IS NULL;

		UPDATE
			sd
		SET
			SectionType = tsdi.SectionType,
			SeriesCode = tsdi.SeriesCode
		FROM
			#TempSaleDocumentIds AS tsdi
			INNER JOIN oregular.SaleDocuments sd on sd.Id = tsdi.Id
			INNER JOIN einvoice.Documents AS d ON d.Id = tsdi.EInvoiceDocumentId
		WHERE
			tsdi.EInvoiceDocumentId IS NOT NULL;

	END
	ELSE
	BEGIN
		INSERT INTO [oregular].[SaleDocumentItems]
		(
			SaleDocumentId,
			TaxType,
			Rate,
			TaxableValue,
			IgstAmount,
			CgstAmount,
			SgstAmount,
			CessAmount,
			Stamp,
			GstActOrRuleSection
		)
		SELECT
			tsdids.Id,
			tsdi.TaxType,
			tsdi.Rate,
			tsdi.TaxableValue,
			tsdi.IgstAmount,
			tsdi.CgstAmount,
			tsdi.SgstAmount,
			tsdi.CessAmount,
			GETDATE(),
			tsdi.GstActOrRuleSection
		FROM
			#TempSaleDocumentItems AS tsdi
			INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdi.GroupId = tsdids.GroupId
		WHERE
			tsdids.Mode = 'I';
	END

	INSERT INTO [oregular].[SaleDocumentRateWiseItems]
	(
		SaleDocumentId,
		Rate,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		tsdids.Id,
		tsdi.Rate,
		tsdi.TaxableValue,
		tsdi.IgstAmount,
		tsdi.CgstAmount,
		tsdi.SgstAmount,
		tsdi.CessAmount
	FROM
		#TempSaleDocumentItems AS tsdi
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdi.GroupId = tsdids.GroupId
	WHERE
		tsdids.Mode IN ('I', 'U');
		
	INSERT INTO oregular.SaleDocumentReferences
	(
		SaleDocumentId,
		DocumentNumber,
		DocumentDate
	)
	SELECT
		tsdids.Id,
		tsdr.DocumentNumber,
		tsdr.DocumentDate
	FROM
		#TempSaleDocumentReferences AS tsdr
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdr.GroupId = tsdids.GroupId
	WHERE
		tsdids.Mode = 'I';
		
	/*Updating cancelled records in Sale Status*/	
	UPDATE
		oregular.SaleDocumentStatus
	SET 
		[Checksum] = tsd.[Checksum],
		CancelledDate = tsd.CancelledDate,
		PushStatus = tsd.PushStatus,
		[Status] = tsd.[Status],
		BillingDate = tsdi.BillingDate,
		LastSyncDate = @CurrentDate,
		ModifiedStamp = @CurrentDate
	FROM
		oregular.SaleDocumentStatus ss
		INNER JOIN #TempSaleDocumentIds AS tsdi ON ss.SaleDocumentId = tsdi.Id
		INNER JOIN #TempSaleDocuments tsd on tsdi.GroupId = tsd.GroupId
	WHERE 
		tsdi.Mode = 'C';
		
	/*Updating user updated with IsAutoDrafted = 0 in Sale Status*/	
	UPDATE
		oregular.SaleDocumentStatus
	SET 
		IsAutoDrafted = @False,
		BillingDate = tsdi.BillingDate,
		LastSyncDate = @CurrentDate,
		ModifiedStamp = @CurrentDate
	FROM
		oregular.SaleDocumentStatus ss
		INNER JOIN #TempSaleDocumentIds AS tsdi ON ss.SaleDocumentId = tsdi.Id
		INNER JOIN #TempSaleDocuments tsd on tsdi.GroupId = tsd.GroupId
	WHERE 
		tsdi.Mode = 'F';
		
	/*Updating RET191248 error in Sale Status for production issue*/	
	IF EXISTS (SELECT 1 FROM #TempSaleDocumentIds WHERE Mode = 'UE')
	BEGIN
		UPDATE
			ss
		SET 
			IsPushed = 0,
			GstinError = @GstinErrorTypeApiSectionMismatch,
			PushStatus = CASE WHEN ss.PushStatus = @PushToGstStatusPushed THEN @PushToGstStatusUploadedButNotPushed ELSE ss.PushStatus END,
			Errors = @MismatchErrors,
			ModifiedStamp = @CurrentDate
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIds AS tsdi ON ss.SaleDocumentId = tsdi.Id
			INNER JOIN #TempSaleDocuments tsd on tsdi.GroupId = tsd.GroupId
		WHERE 
			tsdi.Mode = 'UE';
	END
			
	/*Updating RET191248 error in Sale Status for production issue*/	
	IF EXISTS (SELECT 1 FROM #TempSaleDocumentIds WHERE Mode = 'AU')
	BEGIN
		UPDATE
			oregular.SaleDocumentStatus
		SET 
			[Checksum] = tsd.[Checksum],
			IsAutoDrafted = tsd.IsAutoDrafted,
			AutoDraftSource = tsd.AutoDraftSource,
			Errors = tsd.Errors,
			BillingDate = tsdi.BillingDate,
			LastSyncDate = @CurrentDate,
			ModifiedStamp = @CurrentDate
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIds AS tsdi ON ss.SaleDocumentId = tsdi.Id
			INNER JOIN #TempSaleDocuments tsd on tsdi.GroupId = tsd.GroupId
		WHERE 
			tsdi.Mode = 'AU';
	END
		
	/* Delete Autopopulated records which are delete  */
	IF EXISTS (SELECT 1 FROM #TempSaleDocumentIds WHERE Mode = 'D')
	BEGIN
		DELETE
			sdr
		FROM 
			oregular.SaleDocumentReferences sdr
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdr.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			sdi
		FROM 
			oregular.SaleDocumentItems sdi
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdi.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			sdri
		FROM 
			oregular.SaleDocumentRateWiseItems sdri
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdri.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			ss
		FROM 
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = ss.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			sdc
		FROM 
			oregular.SaleDocumentContacts sdc
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdc.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			sdp
		FROM 
			oregular.SaleDocumentPayments sdp
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdp.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			sdcu
		FROM 
			oregular.SaleDocumentCustoms sdcu
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdcu.SaleDocumentId
		WHERE
			tsdi.Mode = 'D';

		DELETE
			sd
		FROM 
			oregular.SaleDocuments sd
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sd.Id
		WHERE
			tsdi.Mode = 'D';

		DELETE
			dw
		FROM 
			oregular.SaleDocumentDW dw
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = dw.Id
		WHERE
			tsdi.Mode = 'D';

	END
	
	--/* Condition For update sale data which are not on gst portal but exists in system in pushed state */
	--IF (@IsAutoDrafted = @False AND @SourceType = @SourceTypeTaxpayer)
	--BEGIN
	--	UPDATE
	--		ss
	--	SET
	--		ss.PushStatus = @PushToGstStatusUploadedButNotPushed,
	--		ss.IsPushed = @False,
	--		ss.IsAutoDrafted = @False,
	--		ss.LastSyncDate = @CurrentDate,
	--		ss.ModifiedStamp = @CurrentDate
	--	OUTPUT 
	--		INSERTED.SaleDocumentId
	--	INTO 
	--		#TempUpsertDocumentIds(ID)	
	--	FROM
	--		 oregular.SaleDocumentDW AS dw
	--		 INNER JOIN oregular.SaleDocumentStatus AS ss ON ss.SaleDocumentId = dw.Id 
	--		 LEFT JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = dw.Id 
	--	WHERE
	--		dw.SubscriberId = @SubscriberId
	--		AND dw.EntityId = @EntityId
	--		AND dw.ReturnPeriod = @ReturnPeriod
	--		AND dw.SectionType & @SectionType <> 0
	--		AND dw.IsAmendment = @IsAmendment
	--		AND dw.SourceType = @SourceTypeTaxpayer
	--		AND ss.IsPushed = @True
	--		AND tsdi.Id IS NULL;
	--		--AND dw.BillToGstin = ISNULL(@Gstin, dw.BillToGstin)
	--END

	/* SP excuted to Insert/Update data into DW table */	
	EXEC [oregular].[InsertSaleDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN
	;	

	SELECT
		tsd.Id,
		tsd.SectionType,
		tsd.DocumentDate,
		tsd.ECommerceGstin,
		tsd.TransactionType,
		tsd.DocumentNumber,
		tsd.DocumentFinancialYear,
		tsd.DocumentType,
		CASE WHEN tsd.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS PlanLimitApplicable,
		tsd.GroupId
	FROM
		#TempSaleDocumentIds As tsd;
			
	DROP TABLE 
		#TempSaleDocumentIds, 
		#TempSaleDocumentItems, 
		#TempSaleDocuments, 
		#TempSaleDocumentContacts,
		#TempSaleDocumentReferences,
		#TempUpsertDocumentIds;
END

GO


DROP PROCEDURE IF EXISTS [ oregular].[UpdatedMissingGstr1DocumentStatus];
GO


/*-------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[oregular].[UpdatedMissingGstr1DocumentStatus] 	 	 
						:   17/03/2022 | Rippal Patel | This procedure is used to get Sale Document & Summary details.
---------------------------------------------------------------------------------------------------------------------
*	Test Execution		:   DECLARE @PrimaryDetails [common].[SaleDocumentPrimaryDetailType],
									@AuditTrailDetails [audit].[AuditTrailDetailsType];

							EXEC [oregular].[UpdatedMissingGstr1DocumentStatus]
								@SubscriberId = 171,
								@UserId = 373,
								@EntityId = 323,
								@ReturnPeriod = 72020,
								@SourceTypeTaxpayer = 1,
								@PushToGstStatusUploadedButNotPushed = 1,
								@PrimaryDetails = @PrimaryDetails,
								@AuditTrailDetails = @AuditTrailDetails;
-------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[UpdatedMissingGstr1DocumentStatus]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@ReturnPeriod INT,
	@SourceType SMALLINT,
	@SourceTypeTaxpayer SMALLINT,
    @SectionType INT,
    @IsAmendment BIT,
	@PushToGstStatusUploadedButNotPushed SMALLINT,
	@PrimaryDetails [oregular].[SaleDocumentPrimaryDetailType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @CurrentDate DATETIME = GETDATE();

	SELECT 
		*
	INTO 
		#TempPrimaryDetails
	FROM 
		@PrimaryDetails;

	SELECT
	   sd.Id,
	   tpd.SectionType,
	   tpd.IsAmendment
	INTO
		#TempSaleDocumentIds
	FROM
		#TempPrimaryDetails tpd
		INNER JOIN oregular.SaleDocumentDW AS sd ON
		(
			sd.DocumentNumber = tpd.DocumentNumber
			AND sd.ParentEntityId = @EntityId
			AND sd.DocumentFinancialYear = tpd.DocumentFinancialYear 
			AND sd.CombineDocumentType = sd.CombineDocumentType
			AND sd.SourceType = @SourceType
			AND sd.IsAmendment = @IsAmendment
			AND sd.SubscriberId = @SubscriberId			
			AND sd.DocumentType = tpd.DocumentType	
			AND sd.SectionType & @SectionType <> 0		
		)
		INNER JOIN oregular.SaleDocumentStatus ss ON sd.Id = ss.SaleDocumentId;

	UPDATE
		ss
	SET
		PushStatus = @PushToGstStatusUploadedButNotPushed,
		IsPushed = 0,
		IsAutoDrafted = 0,
		LastSyncDate = @CurrentDate,
		BillingDate = NULL,
		ModifiedStamp = @CurrentDate
	FROM
		oregular.SaleDocumentStatus AS ss
		INNER JOIN oregular.SaleDocumentDW AS dw ON ss.SaleDocumentId = dw.Id
		LEFT JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = dw.Id 
	WHERE
		dw.SubscriberId = @SubscriberId
		AND dw.EntityId = @EntityId
		AND dw.ReturnPeriod = @ReturnPeriod
		AND dw.SectionType & @SectionType <> 0
		AND dw.IsAmendment = @IsAmendment
		AND dw.SourceType = @SourceTypeTaxpayer
		AND ss.IsPushed = 1
		AND tsdi.Id IS NULL;

	DROP TABLE #TempSaleDocumentIds, #TempPrimaryDetails;
END

GO


DROP PROCEDURE IF EXISTS [ einvoice].[InsertDocuments];
GO


/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[InsertDocuments]
* 	Comments			: 10-07-2020 | Prakash Parmar | Renamed BillToLegalName to BillToTradeName, BillFromLegalName to BillFromTradeName
						: 28-07-2020 | Pooja Rajpurohit | Removed insert and update portion from sp and called another sp for same task.
						: 28-07-2020 | Pooja Rajpurohit | Removed insert and update portion from sp and called another sp for same task.
						: 10-09-2020 | Prakash Parmar   | Get Bill From Gstin in Vehicle Details FromCity
						: 14-10-2020 | Prakash Parmar | Added EwayBill Generated Pushstatus in vehicle details insert
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
						  DECLARE @Documents [einvoice].[InsertDocumentType];
						  DECLARE @DocumentItems [einvoice].[InsertDocumentItemType];
						  DECLARE @DocumentReferences [common].[DocumentReferenceType];
						  DECLARE @DocumentCustoms [einvoice].[InsertDocumentCustomType];
						  DECLARE @DocumentPayments [einvoice].[InsertDocumentPaymentType];
						  DECLARE @DocumentContacts [einvoice].[InsertDocumentContactType];

							INSERT INTO @Documents ([EntityId],[ParentEntityId],[StatisticId],[Purpose],[SupplyType],[Irn],[Type],[TransactionType],[TransactionTypeDescription],
								[TaxpayerType],[DocumentNumber],[DocumentDate],[TransactionMode],[RefDocumentRemarks],[RefDocumentPeriodStartDate],[RefDocumentPeriodEndDate],
								[RefPrecedingDocumentDetails],[RefContractDetails],[AdditionalSupportingDocumentDetails],[BillNumber],[BillDate],[PortCode],[DocumentCurrencyCode],
								[DestinationCountry],[ExportDuty],[Pos],[DocumentValue],[DocumentDiscount],[DocumentOtherCharges],[DocumentValueInForeignCurrency],
								[DocumentValueInRoundOffAmount],[ReverseCharge],[ClaimRefund],[UnderIgstAct],[ECommerceGstin],[TransporterID],[TransporterName],
								[Distance],[TransportMode],[TransportDocumentNumber],[TransportDocumentDate],[VehicleNumber],[VehicleType],[ToEmailAddresses],
								[ToMobileNumbers],[TotalTaxableValue],[TotalTaxAmount],[ReturnPeriod],[FinancialYear],[DocumentFinancialYear],[GroupId],[AutoGenerate],
								[EInvoicePushStatus],[EwaybillPushStatus],[TransportDateTime],[SeriesCode],[SourceType],[BillFromGstin])
							VALUES 
								(16867,16867,17430,2,1,null,2,1,null,null,'E9202120045','2021-04-05',2,null, '2021-01-01','2021-01-31',
								'[{\"InvNo\":\"9202110133\",\"InvDt\":\"30/09/2020\"}]', null, null, null, null, null, 'INR', 'IN', null, 
								27,1206005.76, null,null,null,null,0,0,0,null,null,null,null,null,null,null,null,null,null,null,942192.0,263813.76,42021,
								202122,202122,1,null,1,1,null,null,2,'27AACPH8447G002')


							--INSERT INTO @DocumentItemsType(Hsn,[Name],Rate,[GroupId])
							--VALUES
							--('123456789', 'test1234', 123,1)
							
							EXEC [einvoice].[InsertDocuments] 
								@SubscriberId =170, 
								@UserId = 664, 
								@Documents = @Documents, 
								@DocumentItems = @DocumentItems, 
								@DocumentReferences = @DocumentReferences,
								@DocumentCustoms = @DocumentCustoms,
								@DocumentPayments = @DocumentPayments,
								@DocumentContacts = @DocumentContacts,
								@DocumentStatusActive=1,
								@VehicleDetailTypeVehicleDetailAdded=1,
								@SupplyTypeS=1,
								@EwaybillPushStatusCancelled=4,
								@EwayBillPushStatusDiscarded=14,
								@DocumentStatusCompleted=3,
								@TransactionTypeB2C=12,
								@DocumentStatusYetNotGenerated=1,
								@ContactTypeBillFrom=1,
								@ContactTypeDispatchFrom=2,
								@ContactTypeBillTo=3,
								@EwayBillPushStatusGenerated=2,
								@DocumentTypeCRN=2,
								@DocumentTypeDBN=3;

*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[InsertDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@VehicleDetailTypeVehicleDetailAdded SMALLINT,
	@DocumentStatusActive SMALLINT,
	@Documents [einvoice].[InsertDocumentType] READONLY,
	@DocumentItems [einvoice].[InsertDocumentItemType] READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@DocumentCustoms [einvoice].[InsertDocumentCustomType] READONLY,
	@DocumentPayments [einvoice].[InsertDocumentPaymentType] READONLY,
	@DocumentContacts [einvoice].[InsertDocumentContactType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@RequestId uniqueidentifier,
	@SupplyTypeS SMALLINT,
	@SupplyTypeP SMALLINT,
	@TransactionTypeB2C SMALLINT,
	@EwaybillPushStatusCancelled SMALLINT,
	@EwayBillPushStatusDiscarded SMALLINT,
	@DocumentStatusCompleted SMALLINT,
	@DocumentStatusYetNotGenerated SMALLINT,
	@ContactTypeBillFrom SMALLINT,
	@ContactTypeDispatchFrom SMALLINT,
	@ContactTypeBillTo SMALLINT,
	@EwayBillPushStatusGenerated SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@UserActionTypeCreate SMALLINT,
	@UserActionTypeEdit SMALLINT,
	@IpAddress VARCHAR(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@TRUE INT = 1,
		@FALSE INT = 0;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempDocumentIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		Mode CHAR
	);

	CREATE CLUSTERED INDEX IDX_TempDocumentIds_GroupId ON #TempDocumentIds(GroupId) 
	CREATE NONCLUSTERED INDEX IDX_TempDocumentIds_GroupIdId ON #TempDocumentIds(GroupId) INCLUDE(Id);

	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL	
	);
	
	CREATE CLUSTERED INDEX IDX_TempUpsertDocumentIds ON #TempUpsertDocumentIds (ID)	
		
	SELECT 
		*,
		CombineType = CASE WHEN [Type] = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE [Type] END
	INTO 
		#TempDocuments
	FROM 
		@Documents ted;

	SELECT 
		*
	INTO
		#TempDocumentReferences
	FROM
		@DocumentReferences;

	SELECT 
		*
	INTO
		#TempDocumentCustoms
	FROM
		@DocumentCustoms;

	SELECT 
		*
	INTO
		#TempDocumentConctacts
	FROM
		@DocumentContacts

	SELECT 
		*
	INTO
		#TempDocumentPayments
	FROM
		@DocumentPayments;

	CREATE CLUSTERED INDEX  IDX_TempDocuments_GroupId ON #TempDocuments(GroupId);

	SELECT
		*
	INTO 
		#TempDocumentItems
	FROM
		@DocumentItems;	
	CREATE CLUSTERED INDEX  IDX_TempDocumentItems_GroupId ON #TempDocumentItems(GroupId);

	SELECT
		ed.Id,
		ed.DocumentNumber,
		ed.ParentEntityId,
		ed.DocumentFinancialYear,
		ed.SupplyType,
		ed.PortCode,
		ed.TransactionType,
		CASE WHEN ed.[Type] = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE ed.[Type] END AS CombineType,
		edc.Gstin AS BillFromGstin,
		ds.[Status] AS EinvoiceStatus,
		eds.[Status] AS EwaybillStatus,
		eds.PushStatus AS EwaybillPushStatus
	INTO
		#TempEinvoiceDocuments
	FROM
		#TempDocuments td
		INNER JOIN einvoice.Documents AS ed ON
		(
				ed.DocumentNumber = td.DocumentNumber
			AND ed.ParentEntityId = td.ParentEntityId
			AND ed.DocumentFinancialYear  = td.DocumentFinancialYear
			AND ed.SubscriberId = @SubscriberId
			AND ed.SupplyType = td.SupplyType
		)
		INNER JOIN ewaybill.DocumentStatus AS eds ON 
		(
			 eds.DocumentId = ed.Id
		)
		INNER JOIN einvoice.DocumentStatus AS ds ON
		(
			 ds.DocumentId = ed.Id
		)
		LEFT JOIN einvoice.DocumentContacts AS edc ON 
		(
			ed.Id = edc.DocumentId AND edc.[Type] = @ContactTypeBillFrom
		);

	/* For same location & same doc number and diff document type remove duplicate Ids */
	;With Cte AS
	(
		SELECT ROW_NUMBER() OVER(PARTITION BY Id ORDER BY Id) RowNum FROM #TempEinvoiceDocuments WHERE Id IS NOT NULL
	)
	DELETE FROM Cte WHERE RowNum > 1;

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode
	)
	SELECT
		ed.Id,
	   td.GroupId,
	   'U'
	FROM
		#TempDocuments td
		INNER JOIN #TempEinvoiceDocuments AS ed ON
		(
				ed.DocumentNumber = td.DocumentNumber
			AND ed.ParentEntityId = td.ParentEntityId
			AND ed.DocumentFinancialYear  = td.DocumentFinancialYear
			AND ed.SupplyType = td.SupplyType
			AND ed.CombineType = td.CombineType
			AND 
			(
				ISNULL(ed.BillFromGstin,'') = ISNULL(td.BillFromGstin,'')
				AND
				(
					td.SupplyType = @SupplyTypeS
					OR
					(
						td.SupplyType = @SupplyTypeP
						AND ISNULL(ed.PortCode,'') = ISNULL(td.PortCode,'')
					)
				)
			)
			AND
			(
				NOT (ed.EinvoiceStatus = @DocumentStatusCompleted AND ed.TransactionType = @TransactionTypeB2C)
				OR
				NOT (ed.EwaybillStatus = @DocumentStatusCompleted AND ed.EwaybillPushStatus IN (@EwayBillPushStatusCancelled, @EwayBillPushStatusDiscarded))
			)
		);


	/*
	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode
	)
	SELECT
		ed.Id,
	   td.GroupId,
	   'U'
	FROM
		einvoice.DocumentDW AS ed
		INNER JOIN einvoice.DocumentStatus ds on ed.Id = ds.DocumentId
		INNER JOIN ewaybill.DocumentStatus eds on ed.Id = eds.DocumentId
		INNER JOIN #TempDocuments td ON
		(
			ed.SubscriberId = @SubscriberId
			AND ed.ParentEntityId = td.ParentEntityId
			-- AND ed.SourceType & td.SourceType <> 0
			AND ed.SupplyType = td.SupplyType
			AND ed.DocumentFinancialYear  = td.DocumentFinancialYear
			AND ed.DocumentNumber = td.DocumentNumber
			AND ed.CombineType = td.CombineType -- CHANGE DOCUMENTTYPE CONDITION
			AND 
			(
				ISNULL(ed.BillFromGstin,'') = ISNULL(td.BillFromGstin,'')
				AND
				(
					td.SupplyType = @SupplyTypeS
					OR
					(
						td.SupplyType = @SupplyTypeP
						AND ISNULL(ed.PortCode,'') = ISNULL(td.PortCode,'')
					)
				)
			)
			AND NOT
			(
				(ds.[Status] = @DocumentStatusCompleted AND ed.TransactionType = @TransactionTypeB2C)
				OR
				(eds.[Status] = @DocumentStatusCompleted AND eds.PushStatus IN (@EwayBillPushStatusCancelled, @EwayBillPushStatusDiscarded))
			)
		)
	*/

	INSERT INTO einvoice.Documents
	(
		SubscriberId,
		EntityId,
		ParentEntityId,
		UserId,
		StatisticId,
		SeriesCode,
		Purpose,
		SupplyType,
		[Type],
		TransactionType,
		TransactionTypeDescription,
		TaxpayerType,	   
		DocumentNumber,
		DocumentDate,
		ReferenceId,
		TransactionMode,
		RefDocumentRemarks,
		RefDocumentPeriodStartDate,
		RefDocumentPeriodEndDate,
		RefPrecedingDocumentDetails,
		RefContractDetails,
		AdditionalSupportingDocumentDetails,
		BillNumber,
		BillDate,
		PortCode,
		DocumentCurrencyCode,
		DestinationCountry,
		ExportDuty,
		POS,
		DocumentValue,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		ECommerceGstin,
		TransporterID,
		TransporterName,
		VehicleType,
		ToEmailAddresses,
		ToMobileNumbers,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		FinancialYear,
		DocumentFinancialYear,
		SourceType,
		SectionType,
		GroupId,
		AttachmentStreamId,
		DocumentReturnPeriod,
		RequestId
	)
	OUTPUT 
		inserted.Id, inserted.GroupId, 'I'
	INTO 
		#TempDocumentIds(Id, GroupId, Mode)
	SELECT
		@SubscriberId,
		EntityId,
		ParentEntityId,
		@UserId,
		StatisticId,
		SeriesCode,
		Purpose,
		SupplyType,
		[Type],
		TransactionType,
		TransactionTypeDescription,
		TaxpayerType,	   
		DocumentNumber,
		DocumentDate,
		ReferenceId,
		TransactionMode,
		RefDocumentRemarks,
		RefDocumentPeriodStartDate,
		RefDocumentPeriodEndDate,
		RefPrecedingDocumentDetails,
		RefContractDetails,
		AdditionalSupportingDocumentDetails,
		BillNumber,
		BillDate,
		PortCode,
		DocumentCurrencyCode,
		DestinationCountry,
		ExportDuty,
		POS,
		DocumentValue,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		ECommerceGstin,
		TransporterID,
		TransporterName,
		VehicleType,
		ToEmailAddresses,
		ToMobileNumbers,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		FinancialYear,
		DocumentFinancialYear,
		SourceType,
		SectionType,
		GroupId,
		AttachmentStreamId,
		DocumentReturnPeriod,
		@RequestId
	FROM
		#TempDocuments
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempDocumentIds);

	IF EXISTS(SELECT 1 FROM #TempDocumentIds tdi WHERE tdi.Mode = 'U')
	BEGIN
		UPDATE
			einvoice.Documents
		SET 
			EntityId = td.EntityId,
			ParentEntityId = td.ParentEntityId,
			UserId = @UserId,
			StatisticId = td.StatisticId,
			SeriesCode = td.SeriesCode,
			Purpose = td.Purpose,
			SupplyType = td.SupplyType,
			[Type] = td.[Type],
			TransactionType = td.TransactionType,
			TransactionTypeDescription = td.TransactionTypeDescription,
			TaxpayerType = td.TaxpayerType,						 
			DocumentNumber = td.DocumentNumber,
			DocumentDate = td.DocumentDate,
			ReferenceId = td.ReferenceId,
			TransactionMode = td.TransactionMode,
			RefDocumentRemarks = td.RefDocumentRemarks,
			RefDocumentPeriodStartDate= td.RefDocumentPeriodStartDate,
			RefDocumentPeriodEndDate = td.RefDocumentPeriodEndDate,
			RefPrecedingDocumentDetails = td.RefPrecedingDocumentDetails,
			RefContractDetails = td.RefContractDetails,
			AdditionalSupportingDocumentDetails = td.AdditionalSupportingDocumentDetails,
			BillNumber = td.BillNumber,
			BillDate = td.BillDate,
			PortCode = td.PortCode,
			DocumentCurrencyCode = td.DocumentCurrencyCode,
			DestinationCountry = td.DestinationCountry,
			ExportDuty = td.ExportDuty,
			POS = td.POS,
			DocumentValue = td.DocumentValue,
			DocumentDiscount = td.DocumentDiscount,
			DocumentOtherCharges = td.DocumentOtherCharges,
			DocumentValueInForeignCurrency = td.DocumentValueInForeignCurrency,
			DocumentValueInRoundOffAmount = td.DocumentValueInRoundOffAmount,
			ReverseCharge = td.ReverseCharge,
			ClaimRefund = td.ClaimRefund,
			UnderIgstAct = td.UnderIgstAct,
			ECommerceGstin = td.ECommerceGstin,
			TransporterID = td.TransporterID,
			TransporterName = td.TransporterName,
			VehicleType = td.VehicleType,
			ToEmailAddresses = td.ToEmailAddresses,
			ToMobileNumbers = td.ToMobileNumbers,
			TotalTaxableValue = td.TotalTaxableValue,
			TotalTaxAmount = td.TotalTaxAmount,
			ReturnPeriod = td.ReturnPeriod,
			FinancialYear = td.FinancialYear,
			DocumentFinancialYear = td.DocumentFinancialYear,
			SourceType = td.SourceType,
			SectionType = td.SectionType,
			AttachmentStreamId = td.AttachmentStreamId,
			DocumentReturnPeriod = td.DocumentReturnPeriod,
			ModifiedStamp =  GETDATE(),
			RequestId = @RequestId
		FROM
			einvoice.Documents AS d
			INNER JOIN #TempDocumentIds tdi ON tdi.Id = d.Id
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE
			tdi.Mode = 'U';			

		UPDATE
			einvoice.DocumentStatus
		SET 
			PushStatus = td.EInvoicePushStatus,
			Irn = td.Irn,
			[Status] = td.DocumentStatus,
			Errors = null,
			CancelRemark = null,
			RequestId = @RequestId,
			UserAction = @UserActionTypeEdit,
			ModifiedStamp = GETDATE()
		FROM
			einvoice.DocumentStatus ds
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = ds.DocumentId
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode = 'U';

		UPDATE
			ewaybill.DocumentStatus
		SET 
			PushStatus = td.EwaybillPushStatus,
			Distance = td.Distance,
			TransportDateTime= td.TransportDateTime,
			Irn = td.Irn,
			[Status] = td.DocumentStatus,
			Errors = null,
			Remarks = null,
			RequestId = @RequestId,
			UserAction = @UserActionTypeEdit,
			ModifiedStamp = GETDATE()
		FROM
			ewaybill.DocumentStatus ds
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = ds.DocumentId
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode = 'U';

	END;
	
	INSERT INTO einvoice.DocumentStatus
	(
		DocumentId,
		Irn,
		PushStatus,
		[Status],
		RequestId,
		UserAction
	)
	SELECT 
		tdi.Id,
		td.Irn,		
		td.EInvoicePushStatus,
		td.DocumentStatus,
		@RequestId,
		@UserActionTypeCreate
	FROM
		#TempDocumentIds AS tdi
		INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
	WHERE 
		tdi.Mode = 'I';
	
	INSERT INTO ewaybill.DocumentStatus
	(
		DocumentId,
		Distance,
		TransportDateTime,
		Irn,
		PushStatus,
		[Status],
		IsMultiVehicleMovementInitiated,
		RequestId,
		UserAction
	)
	SELECT
		tdi.Id,
		td.Distance,
		td.TransportDateTime,
		td.Irn,
		td.EwaybillPushStatus,
		td.DocumentStatus,
		@FALSE,
		@RequestId,
		@UserActionTypeCreate
	FROM
		#TempDocumentIds AS tdi
		INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
	WHERE 
		tdi.Mode = 'I';

	INSERT INTO #TempUpsertDocumentIds (Id)
	SELECT 
		Id 
	FROM 
		#TempDocumentIds
					
	/* Delete DocumentItems for both Insert and Update Case  */	
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
			#TempDocumentIds;

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			SET @Records = @Min + @BatchSize;		
			
			DELETE
				di
			FROM 
				einvoice.DocumentItems AS di
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = di.DocumentId
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				dr
			FROM 
				einvoice.DocumentReferences AS dr
				INNER JOIN #TempDocumentIds AS tdi ON dr.DocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				dc
			FROM 
				einvoice.DocumentCustoms AS dc
				INNER JOIN #TempDocumentIds AS tdi ON dc.DocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				dp
			FROM 
				einvoice.DocumentPayments AS dp
				INNER JOIN #TempDocumentIds AS tdi ON dp.DocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				dc
			FROM 
				einvoice.DocumentContacts AS dc
				INNER JOIN #TempDocumentIds AS tdi ON dc.DocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			DELETE
				dv
			FROM 
				ewaybill.VehicleDetails AS dv
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dv.DocumentId
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;
			
			SET @Min = @Records;
		END
	END
					
	INSERT INTO einvoice.DocumentItems
	(
		DocumentId,
		SerialNumber,
		IsService,
		Hsn,
		ProductCode,
		[Name],
		[Description],
		Barcode,
		UQC,
		Quantity,
		FreeQuantity,
		Rate,
		CessRate,
		StateCessRate,
		CessNonAdvaloremRate,
		PricePerQuantity,
		DiscountAmount,
		GrossAmount,
		OtherCharges,
		TaxableValue,
		PreTaxValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount,
		StateCessAmount,
		StateCessNonAdvaloremAmount,
		CessNonAdvaloremAmount,
		TaxType,
		OrderLineReference,
		OriginCountry,
		ItemSerialNumber,
		ItemTotal,
		ItemAttributeDetails,
		BatchNameNumber,
		BatchExpiryDate,
		WarrantyDate,
		CustomItem1,
		CustomItem2,
		CustomItem3,
		CustomItem4,
		CustomItem5,
		CustomItem6,
		CustomItem7,
		CustomItem8,
		CustomItem9,
		CustomItem10,
		RequestId
	)
	SELECT			
		 tdis.Id,
		 SerialNumber,
		 IsService,
		 Hsn,
		 ProductCode,
		 [Name],
		 [Description],
		 Barcode,
		 UQC,
		 Quantity,
		 FreeQuantity,
		 Rate,
		 CessRate,
		 StateCessRate,
		 CessNonAdvaloremRate,
		 PricePerQuantity,
		 DiscountAmount,
		 GrossAmount,
		 OtherCharges,
		 TaxableValue,
		 PreTaxValue,
		 IgstAmount,
		 CgstAmount,
		 SgstAmount,
		 CessAmount,
		 StateCessAmount,
		 StateCessNonAdvaloremAmount,
		 CessNonAdvaloremAmount,
		 TaxType,
		 OrderLineReference,
		 OriginCountry,
		 ItemSerialNumber,
		 ItemTotal,
		 ItemAttributeDetails,
		 BatchNameNumber,
		 BatchExpiryDate,
		 WarrantyDate,
		 CustomItem1,
		 CustomItem2,
		 CustomItem3,
		 CustomItem4,
		 CustomItem5,
		 CustomItem6,
		 CustomItem7,
		 CustomItem8,
		 CustomItem9,
		 CustomItem10,
		 @RequestId
	FROM
		#TempDocumentItems AS tdi
		INNER JOIN #TempDocumentIds AS tdis ON tdis.GroupId = tdi.GroupId;

	INSERT INTO einvoice.DocumentReferences
	(
		DocumentId,
		DocumentNumber,
		DocumentDate,
		RequestId
	)
	SELECT
		tdids.Id,
		tdr.DocumentNumber,
		tdr.DocumentDate,
		@RequestId
	FROM
		#TempDocumentReferences AS tdr
		INNER JOIN #TempDocumentIds AS tdids ON tdr.GroupId = tdids.GroupId;

	INSERT INTO [einvoice].[DocumentCustoms]
	(
		DocumentId,
		Custom1,
		Custom2,
		Custom3,
		Custom4,
		Custom5,
		Custom6,
		Custom7,
		Custom8,
		Custom9,
		Custom10,
		RequestId
	)
	SELECT
		tdids.Id,
		tdc.Custom1,
		tdc.Custom2,
		tdc.Custom3,
		tdc.Custom4,
		tdc.Custom5,
		tdc.Custom6,
		tdc.Custom7,
		tdc.Custom8,
		tdc.Custom9,
		tdc.Custom10,
		@RequestId
	FROM
		#TempDocumentCustoms AS tdc
		INNER JOIN #TempDocumentIds AS tdids ON tdc.GroupId = tdids.GroupId;

	INSERT INTO [einvoice].[DocumentPayments]
	(
		DocumentId,
		PaymentMode,
		AdvancePaidAmount,
		PaymentDate,
		PaymentTerms,
		PaymentInstruction,
		PayeeName,
		UpiId,
		PayeeAccountNumber,
		PayeeMerchantCode,
		PaymentAmountDue,
		Ifsc,
		CreditTransfer,
		DirectDebit,
		CreditDays,
		TransactionId,
		TransactionReferenceId,
		TransactionNote,
		PaymentMinimumAmount,
		TransactionReferenceUrl,
		PaymentDueDate,
		RequestId
	)
	SELECT
		tdids.Id,
		tdp.PaymentMode,
		tdp.AdvancePaidAmount,
		tdp.PaymentDate,
		tdp.PaymentTerms,
		tdp.PaymentInstruction,
		tdp.PayeeName,
		tdp.UpiId,
		tdp.PayeeAccountNumber,
		tdp.PayeeMerchantCode,
		tdp.PaymentAmountDue,
		tdp.Ifsc,
		tdp.CreditTransfer,
		tdp.DirectDebit,
		tdp.CreditDays,
		tdp.TransactionId,
		tdp.TransactionReferenceId,
		tdp.TransactionNote,
		tdp.PaymentMinimumAmount,
		tdp.TransactionReferenceUrl,
		tdp.PaymentDueDate,
		@RequestId
	FROM
		#TempDocumentPayments AS tdp
		INNER JOIN #TempDocumentIds AS tdids ON tdp.GroupId = tdids.GroupId;

	INSERT INTO [einvoice].[DocumentContacts]
    (	
		DocumentId,
        Gstin,
        LegalName,
        TradeName,
        VendorCode,
        AddressLine1,
        AddressLine2,
        City,
        StateCode,
        Pincode,
        Phone,
        Email,
        [Type],
		RequestId
	)
	SELECT
		tdids.Id,
		tdc.Gstin,
        tdc.LegalName,
        tdc.TradeName,
        tdc.VendorCode,
        tdc.AddressLine1,
        CASE WHEN tdc.AddressLine2 = '.' OR tdc.AddressLine2 = '-' THEN NULL ELSE tdc.AddressLine2 END,
        tdc.City,
        tdc.StateCode,
        tdc.Pincode,
        tdc.Phone,
        tdc.Email,
        tdc.[Type],
		@RequestId
	FROM
		#TempDocumentConctacts AS tdc
		INNER JOIN #TempDocumentIds AS tdids ON tdc.GroupId = tdids.GroupId;

	INSERT INTO ewaybill.VehicleDetails
	(
		DocumentId,
		TransportMode,
		TransportDocumentNumber,
		TransportDocumentDate,
		VehicleNumber,
		FromState,
		FromCity,
		IsLatest,
		[Type],
		[PushStatus],
		RequestId
	)
	SELECT 
		tdi.Id,
		td.TransportMode,
		td.TransportDocumentNumber,
		td.TransportDocumentDate,
		td.VehicleNumber,
		ISNULL(tdcd.StateCode, tdcb.StateCode),
		ISNULL(tdcd.City, tdcb.City),
		@TRUE,
		td.VehicleType,
		@EwayBillPushStatusGenerated,
		@RequestId
	FROM
		#TempDocumentIds AS tdi
		INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		LEFT JOIN #TempDocumentConctacts tdcb ON (tdcb.GroupId = tdi.GroupId AND tdcb.[Type]= @ContactTypeBillFrom)
		LEFT JOIN #TempDocumentConctacts tdcd ON (tdcd.GroupId = tdi.GroupId AND tdcd.[Type]= @ContactTypeDispatchFrom)
	WHERE 		
		td.TransportMode IS NOT NULL; -- TransportMode is mandatory for EWB, no need when TransportationId is supplied

	/* SPs executed to Insert/Update data into DW tables */	
	EXEC [einvoice].[InsertEinvoiceDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;

	SELECT
		tdi.Id,
		tdi.GroupId
	FROM
		#TempDocumentIds as tdi

	DROP TABLE
		#TempDocumentIds,
		#TempDocumentItems,
		#TempDocuments,
		#TempUpsertDocumentIds,
		#TempDocumentReferences,
		#TempDocumentConctacts,
		#TempDocumentCustoms,
		#TempDocumentPayments,
		#TempEinvoiceDocuments;
END

GO


DROP PROCEDURE IF EXISTS [ oregular].[InsertPurchaseDocumentRecoCancelledCreditNotes];
GO



CREATE   PROCEDURE [oregular].[InsertPurchaseDocumentRecoCancelledCreditNotes](
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
	@CancelledInvoiceReasonType VARCHAR(50) = '8589934592')
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
							@ReconciliationSectionTypeGstDiscarded=10,
							@ReconciliationSectionTypeGstOnly=2,
							@CancelledInvoiceReasonType= '8589934592';	
*/--------------------------------------------------------------------------------------------------------------------------------------
BEGIN	
	
	PRINT 'Poten3';
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
	
	PRINT 'Poten4';
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

	PRINT 'Poten7';
	/*Delete record with less preference*/
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
						  THEN CONCAT('[{"Reason":', @CancelledInvoiceReasonType ,',"Value":"',CONCAT(gd."DocumentNumber", '#', CONVERT(VARCHAR, gd.DocumentDate, 105)),'"}]')
					 				ELSE REPLACE(pdrm.Reason,'[',CONCAT('[{"Reason":',
														@CancelledInvoiceReasonType
													,',"Value":"',CONCAT(gd."DocumentNumber", '#', CONVERT(VARCHAR, gd.DocumentDate, 105)),'"},')) END, 
			ReasonType = @CancelledInvoiceReasonType  + ISNULL(pdrm.ReasonType, 0),
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
						  THEN CONCAT('[{Reason:', @CancelledInvoiceReasonType ,',"Value":"',CONCAT(gd.DocumentNumber, '#', CONVERT(VARCHAR, gd.DocumentDate, 105)),'"}],') 
					 				ELSE REPLACE(pdrm.Reason,'[',CONCAT('[{Reason:',
														@CancelledInvoiceReasonType
													,',"Value":"',CONCAT(gd.DocumentNumber, '#', CONVERT(VARCHAR, gd.DocumentDate, 105)),'"},')) END, 
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
						  THEN CONCAT('[{"Reason":', @CancelledInvoiceReasonType ,',"Value":"',CASE WHEN pd.DocumentNumber IS NOT NULL THEN CONCAT(pd.DocumentNumber, '#', CONVERT(VARCHAR, pd.DocumentDate, 105)) ELSE CONCAT(gd.DocumentNumber, '+', CONVERT(VARCHAR, gd.DocumentDate, 105)) END,'"}]') 
					 				ELSE REPLACE(pdrm.Reason,'[',CONCAT('[{Reason:',
														@CancelledInvoiceReasonType
													,',"Value:"',CASE WHEN pd.DocumentNumber IS NOT NULL THEN CONCAT(pd.DocumentNumber, '#', CONVERT(VARCHAR, pd.DocumentDate, 105)) ELSE CONCAT(gd.DocumentNumber, '||', CONVERT(VARCHAR, gd.DocumentDate, 105)) END,'"},')) END, 
			ReasonType = @CancelledInvoiceReasonType  + COALESCE(pdrm."ReasonType", 0),
			CancelledInvoiceId = t_pdrm.PrId
	FROM
		#TempCrossDocumentMatchedData t_pdrm
	INNER JOIN Oregular.Gstr2bDocumentRecoMapper pdrm ON t_pdrm.GstnId = pdrm.GstnId
	LEFT JOIN #TempGstnOnlyData gd ON  t_pdrm.PrId = gd.Id AND t_pdrm.Source = 'Gstn'
	LEFT JOIN #TempPrOnlyData pd ON  t_pdrm.PrId = pd.Id AND t_pdrm.Source = 'Pr'
	WHERE
		COALESCE(pdrm.Reason,'[]') NOT LIKE '%' + @CancelledInvoiceReasonType + '%';																					 
		
END;

GO


