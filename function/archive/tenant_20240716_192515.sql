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


