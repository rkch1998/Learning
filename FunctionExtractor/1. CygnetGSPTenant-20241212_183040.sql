SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [ims].[GetReconciliationAutoAction]
GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: ims.GetReconciliationAutoAction 
* 	Comments			: 2024-10-09 | Shambhu Das	|  Get auto action on based on ims reco setting
																					
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution: 

						SELECT [ims].[GetReconciliationAutoAction](
							 '[{"IsImsActionEnabled":false,"IsDefault":false,"DefaultAction":null,"IsCustom":false,"IsMatchedActionEnabled":false,"MatchedAction":null,"IsMatchedByToleranceActionEnabled":false,"MatchedByToleranceAction":null,"IsImsOnlyActionEnabled":false,"ImsOnlyAction":null,"IsImsDiscardedActionEnabled":false,"ImsDiscardedAction":null,"IsMismatchedActionEnabled":false,"MismatchedActionsData":null,"IsNearMismatchedActionEnabled":false,"NearMismatchedActionsData":null}]',
							1,
							1,
							1,
							1,
							2,
							3,
							4,
							1,
							'',
							1,
							'');
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ims].[GetReconciliationAutoAction]
(
	@Reason VARCHAR(MAX),
	@ReconciliationSectionType smallint,
	@ReconciliationSectionTypeMisMatched smallint,
	@ReconciliationSectionTypeNearMatched smallint,
	@ActionTypeRejected smallint,
	@ActionTypePending smallint,
	@ActionTypeAccepted smallint,
	@ActionTypeNoAction smallint,
	@IsMismatchedActionEnabled BIT,
	@MismatchedActionsData varchar(MAX),
	@IsNearMismatchedActionEnabled BIT,
	@NearMismatchedActionsData varchar(MAX)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @True BIT = 1;
	DECLARE @Action SMALLINT;
	DECLARE @TempNearMismatchedActionData AS TABLE(ReasonId BIGINT,
            Action SMALLINT);
	DECLARE @TempMismatchedActionData AS TABLE( ReasonId BIGINT,
            Action SMALLINT);
	DECLARE @TempAutoActionPriority AS TABLE(ActionType smallint,
			Priority smallint);

	INSERT INTO @TempAutoActionPriority(ActionType,Priority)
	SELECT @ActionTypeRejected AS ActionType, 1 Priority UNION ALL
	SELECT	@ActionTypePending, 2 Priority UNION ALL
	SELECT	@ActionTypeAccepted, 3 Priority UNION ALL
	SELECT	@ActionTypeNoAction, 4 Priority	;
	
	IF @IsMismatchedActionEnabled = @True AND LEN(@MismatchedActionsData) > 2
	BEGIN 
		;WITH json_data AS (
		SELECT @MismatchedActionsData AS json_values
		)
		INSERT INTO @TempMismatchedActionData (ReasonId, Action)
		SELECT [KEY] as [ReasonId], [VALUE] as [Action]
		FROM json_data
		CROSS APPLY OPENJSON(json_values) AS json;
	END;

	IF @IsNearMismatchedActionEnabled = @True AND LEN(@NearMismatchedActionsData) > 2
	BEGIN
		;WITH json_data AS (
		SELECT @NearMismatchedActionsData AS json_values
		)
		INSERT INTO @TempNearMismatchedActionData (ReasonId, Action)
		SELECT [key], [value]
		FROM json_data
		CROSS APPLY OPENJSON(json_values) AS json;
	END ;

	IF @ReconciliationSectionType = @ReconciliationSectionTypeMisMatched
	BEGIN
	
		WITH cte AS
		(
			SELECT VALUE AS ReasonId FROM OPENJSON(@Reason) WITH ([VALUE] VARCHAR(MAX) '$.Reason')
		)
		SELECT TOP 1
			@Action = tmad.[Action] 
      FROM
			cte c
			INNER JOIN @TempMismatchedActionData AS tmad
				ON c.ReasonId = tmad.ReasonId
			INNER JOIN @TempAutoActionPriority AS taap ON taap.ActionType = tmad.[Action]
		ORDER BY 
			taap.[Priority] ASC;
	END
	ELSE
	BEGIN
		WITH cte AS
		(
				SELECT [VALUE] AS ReasonId FROM OPENJSON(@Reason) WITH ([VALUE] VARCHAR(MAX) '$.Reason')
		)
		SELECT TOP 1
			@Action = tmad.[Action]
      FROM
			cte c
			INNER JOIN @TempNearMismatchedActionData AS tmad
				ON c.ReasonId = tmad.ReasonId
			INNER JOIN @TempAutoActionPriority AS taap ON taap.ActionType = tmad.[Action]
		ORDER BY 
			taap.[Priority] ASC;
	END ;
	
	RETURN @Action;

END
GO

DROP PROCEDURE IF EXISTS [ewaybill].[GetConsolidatedDocumentByIds]
GO

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[GetConsolidatedDocumentByIds] 	 	 
* 	Comments			: 01-06-2020 | Piyush Prajapati |	This procedure is used to get ConsolidatedEwayBill Details
						: 17-07-2020 | Smita Parmar | Renamed FromPlace to FromCity
						: 23-07-2020 | Pooja Rajpurohit | Changes For Optimization - Removed Table varaible instead used temp table
						: 31-07-2020 | Smita Parmar | ewaybill.VehicleDetails --> ConsolidatedEWayBillNumber varchar(20) null is renamed as ConsolidatedEwayBillNumber bigint null 
						: 25-09-2020 | Faraaz Pathan | Changed response to get Ids an item count
						: 04-08-2022 | Krishna Shah | Added UploadedOrDownloadedDateTime in response.
						: 2024-12-12 | Chandresh Prajapati | Added Order by GeneratedDate clasue
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		:	DECLARE @Ids AS [common].[BigIntType];

							INSERT INTO @Ids(Item) VALUES (265);

							EXEC [ewaybill].[GetConsolidatedDocumentByIds]  
								@Ids  = @Ids,
								@BillFromContactType = 1
*/--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[GetConsolidatedDocumentByIds]
(
	@Ids AS [common].[BigIntType] READONLY,
	@ShipToContactType SMALLINT,
	@BillToContactType SMALLINT,
	@BillFromContactType SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @ContactType INT;

	CREATE TABLE #DocumentStatus 
	(
		ConsolidatedDocumentId BIGINT,
		DocumentId BIGINT,
		EwayBillNumber BIGINT,
		GeneratedDate DATETIME,
		ValidUpto SMALLDATETIME
	);

	CREATE CLUSTERED INDEX IDX_#DocumentStatus ON #DocumentStatus (DocumentId);

	CREATE TABLE #TempDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		ConsolidatedDocumentId BIGINT,
		EWayBillNumber NVARCHAR(200),
		DocumentId BIGINT
	);

	CREATE TABLE #TempIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);

	INSERT INTO #TempIds(Id)
	SELECT 
		*
	FROM 
		@Ids;
	
	INSERT INTO #TempDocumentIds
	SELECT
		ConsolidatedDocumentId,
		EWayBillNumber,
		DocumentId	
	FROM 
		ewaybill.ConsolidatedDocumentItems CDI
		INNER JOIN #TempIds I ON CDI.ConsolidatedDocumentId = I.Id;	
		
	INSERT INTO #DocumentStatus
	SELECT 
		tdi.ConsolidatedDocumentId, 
		ds.DocumentId,
		ds.EwayBillNumber,
		ds.GeneratedDate,
		ds.ValidUpto
	FROM 
		ewaybill.DocumentStatus ds 
	INNER JOIN 
		#TempDocumentIds tdi ON ds.EwayBillNumber = tdi.EwayBillNumber and ds.DocumentId = tdi.DocumentId;

	SELECT	
		CD.Id,
		SubscriberId,
		EntityId,
		ParentEntityId,
		UserId,
		StatisticId,
		TransportMode,
		FromState,
		FromCity,
		TransportDocumentNumber,
		TransportDocumentDate,
		VehicleNumber,
		Remarks,
		ToEmailAddresses,
		ToMobileNumbers,
		ReturnPeriod,
		FinancialYear,
		SourceType,
		Stamp
	FROM 
		ewaybill.ConsolidatedDocuments  CD
		INNER JOIN #TempIds I ON CD.ID = I.Id
	ORDER BY 
		I.AutoId;	

	SELECT
		tds.ConsolidatedDocumentId,
		eid.Id,
		tds.EwayBillNumber,
		tds.GeneratedDate,
		ecd2.Gstin,
		eid.DocumentNumber,
		eid.DocumentDate,
		eid.DocumentValue,
		ISNULL(ecd.City,ecd1.City) City,
		ISNULL(ecd.StateCode,ecd1.StateCode) StateCode,
		ISNULL(ecd.Pincode,ecd1.Pincode) Pincode,
		tds.ValidUpto,
		eid.TransporterId
	FROM 
		einvoice.Documents eid
		INNER JOIN #DocumentStatus tds ON eid.Id = tds.DocumentId
		INNER JOIN einvoice.DocumentContacts ecd2 ON eid.Id = ecd2.DocumentId AND ecd2.[Type] = @BillFromContactType
		LEFT JOIN einvoice.DocumentContacts ecd ON eid.Id = ecd.DocumentId AND ecd.[Type] = @ShipToContactType
		LEFT JOIN einvoice.DocumentContacts ecd1 ON eid.Id = ecd1.DocumentId AND ecd1.[Type] = @BillToContactType
	ORDER BY
		tds.GeneratedDate, eid.Id;
		
	SELECT 
		ConsolidatedDocumentId,
		ConsolidatedEwayBillNumber,
		GeneratedDate ,
		[Status],
		pushstatus,
		PushDate,
		Errors,
		[Provider]
	FROM 
		ewaybill.ConsolidatedDocumentStatus CDS
		INNER JOIN #TempIds I ON CDS.ConsolidatedDocumentId = I.Id	

	DROP TABLE #TempDocumentIds, #DocumentStatus;
END
GO

DROP PROCEDURE IF EXISTS [ewaybill].[GetConsolidatedDocumentById]
GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewayBill].[GetConsolidatedDocumentById] 	 	 
* 	Comments			: 25-06-2020 | Chandresh Prajapati |	This procedure is used to get Consolidated EwayBill detail
						: 17-07-2020 | Smita Parmar | Renamed FromPlace to FromCity
						: 2024-12-12 | Chandresh Prajapati | Added Order by GeneratedDate clasue
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: EXEC [ewayBill].[GetConsolidatedDocumentById]  
							@Id  = 10,
							@PushStatus = 1 ,
							@PushStatusYetNotGenerated = 1,
							@PushStatusGenerated = 2,
							@PushStatusRegenerated = 3
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[GetConsolidatedDocumentById]
(
	@Id INT,
	@PushStatus VARCHAR(50),
	@PushStatusYetNotGenerated SMALLINT,
	@PushStatusGenerated SMALLINT,
	@PushStatusRegenerated SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF(@PushStatus = @PushStatusYetNotGenerated)
	BEGIN
		SELECT
			cd.FromCity,
			cd.FromState, 
			cd.TransportMode,
			cd.VehicleNumber,
			cd.TransportDocumentNumber,
			cd.TransportDocumentDate,
			cd.ToEmailAddresses,
			cd.ToMobileNumbers
		FROM 
			ewaybill.ConsolidatedDocuments cd
			INNER JOIN ewaybill.ConsolidatedDocumentItems cdi ON cd.Id = cdi.ConsolidatedDocumentId
		WHERE
			 cdi.Id = @Id;

		SELECT 
			cdi.EwayBillNumber
		FROM 
			ewaybill.ConsolidatedDocuments cd
			INNER JOIN ewaybill.ConsolidatedDocumentItems cdi ON cd.Id = cdi.ConsolidatedDocumentId
			INNER JOIN ewaybill.DocumentStatus ds ON ds.DocumentId = cdi.DocumentId AND ds.EwayBillNumber = cdi.EwayBillNumber
		WHERE
			 cdi.Id = @Id
		ORDER BY 
			ds.GeneratedDate, cdi.DocumentId;
	END
	ELSE IF (@PushStatus = @PushStatusGenerated OR @PushStatus = @PushStatusRegenerated)
	BEGIN
		SELECT
		cds.ConsolidatedEwayBillNumber, 
		cds.PushStatus AS [Status],
		cds.GeneratedDate,
		cd.TransportMode,
		cd.FromCity,
		cd.FromState,
		cd.VehicleNumber,
		cd.TransportDocumentNumber,
		cd.TransportDocumentDate,
		cd.ToEmailAddresses,
		cd.ToMobileNumbers
		FROM 
			ewaybill.ConsolidatedDocuments cd
			INNER JOIN ewaybill.ConsolidatedDocumentStatus cds ON cd.Id = cds.ConsolidatedDocumentId
		WHERE
			 cd.Id = @Id;

		SELECT 
			cdi.EwayBillNumber
		FROM 
			ewaybill.ConsolidatedDocuments cd
			INNER JOIN ewaybill.ConsolidatedDocumentItems cdi ON cd.Id = cdi.ConsolidatedDocumentId
			INNER JOIN ewaybill.DocumentStatus ds ON ds.DocumentId = cdi.DocumentId AND ds.EwayBillNumber = cdi.EwayBillNumber
		WHERE
			 cd.Id = @Id
		ORDER BY 
			ds.GeneratedDate, cdi.DocumentId;
	END
END
GO

