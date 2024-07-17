DROP PROCEDURE IF EXISTS [subscriber].[SaveNotificationReply];
DROP PROCEDURE IF EXISTS [subscriber].[InsertVendors];
DROP PROCEDURE IF EXISTS [subscriber].[InsertVendorsForAutopopulation];
DROP PROCEDURE IF EXISTS [oregular].[InsertPurchaseDocumentReco];
DROP PROCEDURE IF EXISTS [oregular].[InsertSaleDocuments];
DROP PROCEDURE IF EXISTS [subscriber].[UpdateVendorKycReferenceId];
DROP PROCEDURE IF EXISTS [oregular].[InsertPurchaseDocuments];
DROP PROCEDURE IF EXISTS [subscriber].[UpdateStatusForNotificationReply];
DROP PROCEDURE IF EXISTS [oregular].[InsertGstr2aReconciliationDocuments];
DROP PROCEDURE IF EXISTS [subscriber].[DeleteNotificationReplies];
DROP PROCEDURE IF EXISTS [audit].[UpdateAuditDetails];
DROP PROCEDURE IF EXISTS [einvoice].[DeleteDocumentByIds];
DROP PROCEDURE IF EXISTS [einvoice].[InsertDocuments];
DROP PROCEDURE IF EXISTS [einvoice].[InsertDownloadedDocuments];
DROP PROCEDURE IF EXISTS [einvoice].[UpdatePushRequestForCancellation];
DROP PROCEDURE IF EXISTS [einvoice].[UpdatePushRequestForGeneration];
DROP PROCEDURE IF EXISTS [einvoice].[UpdatePushResponseForCancellation];
DROP PROCEDURE IF EXISTS [einvoice].[UpdatePushResponseForGeneration];
DROP PROCEDURE IF EXISTS [oregular].[InsertDownloadedPurchaseDocuments];
DROP PROCEDURE IF EXISTS [ewaybill].[DeleteDocumentByIds];
DROP PROCEDURE IF EXISTS [ewaybill].[InsertDownloadedDocuments];
DROP PROCEDURE IF EXISTS [ewaybill].[PrepareConsolidatedEwayBillByIds];
DROP PROCEDURE IF EXISTS [ewaybill].[SetDeliveryStatusByIds];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushRequest];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForCancellation];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForExtension];
DROP PROCEDURE IF EXISTS [oregular].[InsertDownloadedEInvoicePurchaseDocuments];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForGeneration];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForGenerationByIrn];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForMultiVehicleAddition];
DROP PROCEDURE IF EXISTS [subscriber].[UpdateBlacklistedVendorStatus];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForMultiVehicleMovementInitiation];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForMultiVehicleUpdation];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForRejection];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForTransporterUpdation];
DROP PROCEDURE IF EXISTS [subscriber].[UpdateDownloadResponseForVendors];
DROP PROCEDURE IF EXISTS [ewaybill].[UpdatePushResponseForVehicleDetailUpdation];
DROP PROCEDURE IF EXISTS [oregular].[ApplyReconciliationAction];
DROP PROCEDURE IF EXISTS [oregular].[ApplyReconciliationActionManual];
DROP PROCEDURE IF EXISTS [oregular].[CancelPurchaseDocumentByIds];
DROP PROCEDURE IF EXISTS [oregular].[CancelSaleDocumentByIds];
DROP PROCEDURE IF EXISTS [oregular].[ClaimItc];
DROP PROCEDURE IF EXISTS [oregular].[DeletePurchaseDocumentByIds];
DROP PROCEDURE IF EXISTS [oregular].[DeleteSaleDocumentByIds];
DROP PROCEDURE IF EXISTS [oregular].[DelinkReconciliationDocumentManual];
DROP PROCEDURE IF EXISTS [oregular].[InsertDownloadedSaleDocuments];
DROP PROCEDURE IF EXISTS [oregular].[InsertGstr2bReconciliationDocuments];
DROP PROCEDURE IF EXISTS [oregular].[InsertPaymentDetailByIds];
DROP PROCEDURE IF EXISTS [oregular].[LinkReconciliationDocumentManual];
DROP PROCEDURE IF EXISTS [oregular].[UpdatePurchaseDocumentByReco];
DROP PROCEDURE IF EXISTS [oregular].[UpdatePurchaseDocumentItcDetails];
DROP PROCEDURE IF EXISTS [oregular].[UpdatePushRequestForSaleDocuments];
DROP PROCEDURE IF EXISTS [oregular].[UpdatePushResponseForSaleDocuments];
DROP PROCEDURE IF EXISTS [oregular].[UpdateTdsDetailForPurchaseDocuments];
DROP PROCEDURE IF EXISTS [oregular].[UpdateTdsDetailsByItemIds];
DROP PROCEDURE IF EXISTS [subscriber].[DeleteVendors];
DROP PROCEDURE IF EXISTS [subscriber].[VerifyAndDownloadVendors];

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [subscriber].[InsertSeries]
* 	Comments			: 25-02-2020 | Bhavik Patel | Insert into subscriber.series
						: 13-05-2024 | Chandresh Prajapati | Added AuditTrailDetails Parameter 
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 	EXEC subscriber.[SaveNotificationReply]
							@id = 24,
							@SubscriberId = 171,
							@UserId = 677,
							@ActionRequired = 10,
							@Action = 'Payment done',
							@Internal = 1,
							@StatusTypeActive = 3
							--select * from subscriber.[NotificationReply]
----------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [subscriber].[SaveNotificationReply]
	@Id INT,
	@SubscriberId INT,
	@UserId INT,
	@ActionRequired SMALLINT,
	@Action VARCHAR(50),
	@Internal BIT,
	@StatusTypeActive SMALLINT,
	@StatusTypeInactive smallint,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
AS
BEGIN
	DECLARE
	@Status int;


	IF(@Id IS NULL)
	BEGIN
		INSERT INTO [subscriber].[NotificationReply]
		       ([SubscriberId]
		       ,[UserId]
		       ,[ActionRequired]
		       ,[Action]
		       ,[Internal]
		       ,[Status]
		       ,[Stamp]
		       ,[ModifiedStamp])
		 VALUES
		       (@SubscriberId
		       ,@UserId
		       ,@ActionRequired
		       ,@Action
		       ,@Internal
		       ,@StatusTypeActive
		       ,GETDATE()
		       ,NULL)
	END

	ELSE
		BEGIN
		SELECT 
			@Status = [Status]
		FROM
			[subscriber].[NotificationReply]
		WHERE
			Id = @Id;

	 IF (@Status = @StatusTypeInactive)
		BEGIN
			RAISERROR('VALD0100', 16, 1); /*Only Active User can be updated*/
			RETURN;
		END
	ELSE
		UPDATE 
			[subscriber].[NotificationReply]
		SET
			ActionRequired = @ActionRequired,
			[Action] = @Action,
			Internal = @Internal,
			ModifiedStamp = GETDATE()
		WHERE 
			ID = @Id
	END
END
GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [subscriber].[InsertVendors]
* 	Comments			: 20-04-2020 | Parth Doshi | Insert Vendors
						: 01-09-2023 | Krishna Shah | Added Multiple Field in Import (CGSP2-5603).
						: 20-02-2024 | Anup Yadav | Update Vendor records PanValidationStatus, PanITRStatus, PanAadhaarSeedingStatus, MsmeId, MsmeType, MsmeStatus, Cin, NameOfEnterprise, MajorActivity, DateOfCommencement and LdcDetails based on Pan and TradeName (CGSP2-5976).
						: 02-05-2024 | Chandresh Prajapati	| Added AuditTrailDetails Parameter
						: 24-05-2024 | Chandresh Prajapati | Added Hash
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 	DECLARE @VendorsData AS [subscriber].[VendorType]
							INSERT INTO @VendorsData (Id, StatisticId, Gstin, Code, TradeName, LegalName, AddressLine1, AddressLine2, StateCode, City, Pincode, EmailAddresses, MobileNumbers, Custom1, Custom2, Custom3, Custom4, Custom5, Custom6, Custom7, Custom8, Custom9, Custom10, VerificationStatus)
							VALUES
							(NULL, 10254, '33GSPTN0161G1ZH', 'PD0001', 'PD Industries Trade', 'PD Industries', 'Address1', 'Address2', 24, 'Ahmedabad', 360009, 'parth.doshi@cygnetinfotech.com', null, null, null, null, null, null, null, null, null, null, null, 1)

							EXEC [subscriber].[InsertVendors]
								@SubscriberId = 164,
								@UserId = 434,
								@Vendors = @VendorsData,
								@AuditTrailDetails = @AuditTrailDetails;
----------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [subscriber].[InsertVendors]
(
	@SubscriberId INT,
	@UserId INT,
	@BitTypeY BIT,
	@BitTypeN BIT,
	@VendorKycStatusYetNotInitiated smallint,
	@Vendors [subscriber].[VendorType] READONLY,
	@LdcDetails [subscriber].[InsertVendorLdcDetailsType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS 
BEGIN
	SET NOCOUNT ON;

	SELECT
		*
	INTO 
		#TempVendors
	FROM 
		@Vendors;

	SELECT
		*
	INTO 
		#TempVendorLdcDetails
	FROM 
		@LdcDetails;

	CREATE TABLE #TempDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		Mode CHAR(1),
		Gstin VARCHAR(15),
		TradeName VARCHAR(110),
		Code VARCHAR(40)
	);

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode,
		Gstin,
		TradeName,
		Code
	)
	SELECT
		tvd.Id,
		tvd.GroupId,
		'U',
		tvd.Gstin,
		tvd.TradeName,
		tvd.Code
	FROM
		#TempVendors tvd
	WHERE
		tvd.Id IS NOT NULL;

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode,
		Gstin,
		TradeName,
		Code
	)
	SELECT
	   v."Id",
	   tvd."GroupId",
	   'U',
	   v."Gstin",
	   v."TradeName",
	   v."Code"
	FROM
	    #TempVendors tvd
		INNER JOIN [subscriber].[Vendors] v ON
		(
			v.SubscriberId = @SubscriberId
			AND v.Id <> ISNULL(tvd.Id,'')
			AND
			(
				ISNULL(v.Gstin, '-1') = ISNULL(tvd.Gstin, '-2')
				AND ISNULL(v.Code, '-1') = ISNULL(tvd.Code, '-1')
			)
		)
	WHERE
		tvd.Id IS NULL;

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode,
		Gstin,
		TradeName,
		Code
	)
	SELECT
	   v."Id",
	   tvd."GroupId",
	   'U',
	   v."Gstin",
	   v."TradeName",
	   v."Code"
	FROM
		#TempVendors tvd
		INNER JOIN [subscriber].[Vendors] v ON
		(
			v.SubscriberId = @SubscriberId
			AND v.Id <> ISNULL(tvd.Id,'')
			AND v.Gstin IS NULL 
			AND
			(
				ISNULL(v.TradeName, '-1') = ISNULL(tvd.TradeName, '-2')
				AND ISNULL(v.Code, '-1') = ISNULL(tvd.Code, '-1')
			)
		)
	WHERE
		tvd.Id IS NULL;

	INSERT INTO [subscriber].[Vendors]
	(
		SubscriberId,
		UserId,
		StatisticId,
		Gstin,
		Code,
		TradeName,
		LegalName,
		AddressLine1,
		AddressLine2,
		StateCode,
		City,
		Pincode,
		EmailAddresses,
		MobileNumbers,
		IsPreferred,
		Turnover,
		VendorType,
		[Description],
		DistributorCode,
		UsePrincipalAddress,
		UseAdditionalAddress,
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
		VerificationStatus,
		Pan,
		PanValidationStatus,
		PanITRStatus,
		PanAadhaarSeedingStatus,
		MsmeId,
		MsmeType,
		MsmeStatus, 
		Cin,
		NameOfEnterprise,
		MajorActivity,
		DateOfCommencement,
		LdcDetails,
		GroupId,
		KycStatus,
		[Hash]
	)
	OUTPUT 
		INSERTED.Id, INSERTED.GroupId, 'I', INSERTED.Gstin, INSERTED.TradeName, INSERTED.Code	
	INTO 
		#TempDocumentIds(Id, GroupId, Mode, Gstin, TradeName, Code)
	SELECT 
		@SubscriberId,
		@UserId,
		StatisticId,
		Gstin,
		Code,
		TradeName,
		LegalName,
		AddressLine1,
		AddressLine2,
		StateCode,
		City,
		Pincode,
		EmailAddresses,
		MobileNumbers,
		IsPreferred,
		Turnover,
		VendorType,
		[Description],
		DistributorCode,
		CASE WHEN tvd.Gstin IS NOT NULL AND tvd.Code IS NULL AND tvd.UseAdditionalAddress = @BitTypeN THEN @BitTypeY ELSE tvd.UsePrincipalAddress END,
		UseAdditionalAddress,
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
		VerificationStatus,
		Pan,
		PanValidationStatus,
		PanITRStatus,
		PanAadhaarSeedingStatus,
		MsmeId,
		MsmeType,
		MsmeStatus , 
		Cin ,
		NameOfEnterprise,
		MajorActivity,
		DateOfCommencement,
		LdcDetails,
		GroupId,
		@VendorKycStatusYetNotInitiated,
		Hash
	FROM 
		#TempVendors tvd
	WHERE
		tvd.GroupId NOT IN (SELECT td.GroupId FROM #TempDocumentIds td);

	IF EXISTS(SELECT 1 FROM #TempDocumentIds tdi WHERE tdi.Mode = 'U')
	BEGIN
		UPDATE
			subscriber.Vendors
		SET
			SubscriberId = @SubscriberId,
			UserId = @UserId,
			StatisticId = tvd.StatisticId,
			Gstin = tvd.Gstin,
			Code = tvd.Code,
			TradeName = tvd.TradeName,
			LegalName = tvd.LegalName,
			AddressLine1 = tvd.AddressLine1,
			AddressLine2 = tvd.AddressLine2,
			StateCode = tvd.StateCode,
			City = tvd.City,
			Pincode = tvd.Pincode,
			EmailAddresses = tvd.EmailAddresses,
			MobileNumbers = tvd.MobileNumbers,
			IsPreferred = tvd.IsPreferred,
			VendorType = tvd.VendorType,
			[Description] = tvd.[Description],
			DistributorCode =tvd.DistributorCode,
			UsePrincipalAddress = CASE WHEN tvd.UsePrincipalAddress IS NOT NULL THEN tvd.UsePrincipalAddress ELSE v.UsePrincipalAddress END,
			UseAdditionalAddress = tvd.UseAdditionalAddress,
			Turnover = tvd.Turnover,
			Custom1 = tvd.Custom1,
			Custom2 = tvd.Custom2,
			Custom3 = tvd.Custom3,
			Custom4 = tvd.Custom4,
			Custom5 = tvd.Custom5,
			Custom6 = tvd.Custom6,
			Custom7 = tvd.Custom7,
			Custom8 = tvd.Custom8,
			Custom9 = tvd.Custom9,
			Custom10 = tvd.Custom10,
			VerificationStatus = tvd.VerificationStatus,
			VerifiedDate = NULL,
			Pan = tvd.pan,
			PanValidationStatus = tvd.PanValidationStatus,
			PanITRStatus = tvd.PanITRStatus,
			PanAadhaarSeedingStatus = tvd.PanAadhaarSeedingStatus,
			MsmeId = tvd.MsmeId,
			MsmeType = tvd.MsmeType,
			MsmeStatus = tvd.MsmeStatus,
			Cin = tvd.Cin,
			NameOfEnterprise = tvd.NameOfEnterprise,
			MajorActivity = tvd.MajorActivity,
			DateOfCommencement = tvd.DateOfCommencement,
			LdcDetails = tvd.LdcDetails,
			ModifiedStamp = GETDATE()
		OUTPUT
			DELETED.Gstin, DELETED.TradeName, DELETED.Code
		FROM
			subscriber.Vendors v
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = v.Id
			INNER JOIN #TempVendors tvd ON tvd.groupId = tdi.GroupId
		WHERE
			tdi.Mode = 'U';
	END;

	SELECT DISTINCT 
		Pan,
		PanValidationStatus,
		PanITRStatus,
		PanAadhaarSeedingStatus,
		MsmeId,
		MsmeType,
		MsmeStatus,
		Cin,
		NameOfEnterprise,
		MajorActivity,
		DateOfCommencement,
		LdcDetails
	INTO
	    #TempUniquePan
	FROM
		#TempVendors
    WHERE
		Pan IS NOT NULL;
		
	SELECT 
		DISTINCT TradeName,
		PanValidationStatus,
		PanITRStatus,
		PanAadhaarSeedingStatus,
		MsmeId,
		MsmeType,
		MsmeStatus,
		Cin,
		NameOfEnterprise,
		MajorActivity,
		DateOfCommencement,
		LdcDetails
	INTO
	    #TempUniqueTradeName
	FROM
		#TempVendors
    WHERE
		Pan IS NULL;

	UPDATE
		subscriber.[Vendors] 
	SET 
		PanValidationStatus = tup.PanValidationStatus,
		PanITRStatus = tup.PanITRStatus,
		PanAadhaarSeedingStatus = tup.PanAadhaarSeedingStatus,
		MsmeId = tup.MsmeId,
		MsmeType = tup.MsmeType,
		MsmeStatus = tup.MsmeStatus,
		Cin = tup.Cin,
		NameOfEnterprise = tup.NameOfEnterprise,
		MajorActivity = tup.MajorActivity,
		DateOfCommencement = tup.DateOfCommencement,
		LdcDetails = tup.LdcDetails,
		ModifiedStamp = GETDATE()
	OUTPUT 
		INSERTED.Id, INSERTED.GroupId, 'U', INSERTED.Gstin, INSERTED.TradeName, INSERTED.Code	
	INTO 
		#TempDocumentIds(Id, GroupId, Mode, Gstin, TradeName, Code)
    FROM 
		#TempUniquePan tup 
		INNER JOIN subscriber.[Vendors] v ON v.Pan = tup.Pan
	WHERE 
		v.SubscriberId = @SubscriberId
		AND v.Pan IS NOT NULL;

	UPDATE
		subscriber.[Vendors] 
	SET 
		PanValidationStatus = tut.PanValidationStatus,
		PanITRStatus = tut.PanITRStatus,
		PanAadhaarSeedingStatus = tut.PanAadhaarSeedingStatus,
		MsmeId = tut.MsmeId,
		MsmeType = tut.MsmeType,
		MsmeStatus = tut.MsmeStatus,
		Cin = tut.Cin,
		NameOfEnterprise = tut.NameOfEnterprise,
		MajorActivity = tut.MajorActivity,
		DateOfCommencement = tut.DateOfCommencement,
		LdcDetails = tut.LdcDetails,
		ModifiedStamp = GETDATE()
	OUTPUT 
		INSERTED.Id, INSERTED.GroupId, 'U', INSERTED.Gstin, INSERTED.TradeName, INSERTED.Code	
	INTO 
		#TempDocumentIds(Id, GroupId, Mode, Gstin, TradeName, Code)
    FROM 
		#TempUniqueTradeName tut
		INNER JOIN subscriber.[Vendors] v ON v.TradeName = tut.TradeName
	WHERE 
		v.SubscriberId = @SubscriberId
		AND v.Pan IS NULL;

	IF EXISTS (SELECT 1 FROM #TempDocumentIds)
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
			
			-- delete items
			DELETE
				sdi
			FROM 
				subscriber.VendorLdcDetails AS sdi
				INNER JOIN #TempDocumentIds AS tsdi ON tsdi.Id = sdi.VendorId
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;
			
			SET @Min = @Records
		END
	END;

	INSERT INTO subscriber.VendorLdcDetails
	(
		VendorId,
		DeductorTan,
		TdsPercentage,
		LdcStartDate,
		LdcEndDate,
		LdcTaxSection, 
		LdcTdsThresholdAmount,
		LdcCertificateId
	)
	SELECT
		tdis.Id,
		DeductorTan,
		TDSPercentage,
		LdcStartDate,
		LdcEndDate,
		LdcTaxSection, 
		LdcTdsThresholdAmount,
		LdcCertificateId
	FROM
		#TempVendorLdcDetails AS tvi
		INNER JOIN #TempDocumentIds AS tdis ON tdis.GroupId = tvi.GroupId;

	SELECT 
		tv.Gstin,
		tv.TradeName,
		tv.Code
	FROM
		#TempDocumentIds tv
	WHERE
		Mode = 'U';

	DROP TABLE #TempVendors, #TempDocumentIds, #TempVendorLdcDetails, #TempUniquePan, #TempUniqueTradeName;

END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [subscriber].[InsertVendorsForAutopopulation]
* 	Comments			: 17-03-2021 | Faraaz Pathan | Insert Vendors For auto population purpose
						: 22-07-2021 | Abbas Pisawadwala | Added new parameter and updated sp to set verification status for download.
						: 24-05-2024 | Chandresh Prajapati | Added Hash when add Vendors
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 	DECLARE @VendorsData AS [subscriber].[VendorType]
							INSERT INTO @VendorsData (Gstin, VerificationStatus)
							VALUES ('33GSPTN0161G1ZH', 1),('04AACPH8447G001', 1)

							EXEC [subscriber].[InsertVendorsForAutopopulation]
								@SubscriberId = 164,
								@UserId = 611,
								@Vendors = @VendorsData
----------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [subscriber].[InsertVendorsForAutopopulation]
(
	@SubscriberId INT,
	@UserId INT,
	@UsePrincipalAddress BIT,
	@VendorKycStatusYetNotInitiated smallint,
	@Vendors [subscriber].[VendorType] READONLY,
	@VendorVerificationStatusYetNotVerified SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;

	CREATE TABLE #TempDownloadVendors
	(
		Id BIGINT,
		Gstin VARCHAR(15),
		City VARCHAR(50),
		Pincode INT,
		UseAdditionalAddress BIT,
		VerificationStatus SMALLINT
	);

	SELECT
		Gstin,
		VerificationStatus,
		[Hash]
	INTO 
		#TempVendors
	FROM 
		@Vendors;

	/* Insert only those records which are not in Vendor table */
	INSERT INTO [subscriber].[Vendors]
	(
		SubscriberId,
		UserId,
		Gstin,
		VerificationStatus,
		UsePrincipalAddress,
		KycStatus,
		[Hash]
	)
	OUTPUT 
		inserted.Id, inserted.Gstin, inserted.City,inserted.Pincode,inserted.UseAdditionalAddress, @VendorVerificationStatusYetNotVerified
	INTO 
		#TempDownloadVendors(Id, Gstin, City, Pincode, UseAdditionalAddress, VerificationStatus)
	SELECT
		@SubscriberId,
		@UserId,
		tv.Gstin,
		tv.VerificationStatus,
		@UsePrincipalAddress,
		@VendorKycStatusYetNotInitiated,
		tv.[Hash]
	FROM 
		#TempVendors tv
		LEFT JOIN [subscriber].[Vendors] v ON
		(
			v.SubscriberId = @SubscriberId
			AND v.Gstin = tv.Gstin
		)
	WHERE
		v.Id IS NULL;

	SELECT
		Id,
		Gstin,
		City,
		Pincode,
		UseAdditionalAddress,
		VerificationStatus
	FROM
		#TempDownloadVendors;

	DROP TABLE #TempVendors, #TempDownloadVendors;
END
GO

CREATE PROCEDURE [oregular].[InsertPurchaseDocumentReco](
	@SubscriberId integer,
	@ParentEntityId integer,
	@FinancialYear integer,
	@IsRegenerateNow BIT,
	@Settings AS Oregular.[ReconciliationSettingType] READONLY,
	@ExcludedGstin AS Oregular.[FinancialYearWiseGstinType] READONLY,
	@DocumentTypeINV smallint,
	@DocumentTypeCRN smallint,
	@DocumentTypeDBN smallint,
	@DocumentTypeBOE smallint,
	@TransactionTypeB2B smallint,
	@TransactionTypeSEZWP smallint,
	@TransactionTypeSEZWOP smallint,
	@TransactionTypeDE smallint,
	@TransactionTypeISD smallint,
	@TransactionTypeCBW smallint,
	@TransactionTypeIMPG smallint,
	@TransactionTypeIMPS smallint,
	@ReconciliationSectionTypePROnly smallint,
	@ReconciliationSectionTypeGstOnly smallint,
	@ReconciliationSectionTypeMatched smallint,
	@ReconciliationSectionTypeMatchedDueToTolerance smallint,
	@ReconciliationSectionTypeMisMatched smallint,
	@ReconciliationSectionTypeNearMatched smallint,
	@ReconciliationSectionTypePRDiscarded smallint,
	@ReconciliationSectionTypeGstDiscarded smallint,
	@ReconciliationSectionTypePRExcluded smallint,
	@ReconciliationSectionTypeGstExcluded smallint,
	@SourceTypeTaxpayer smallint,
	@SourceTypeCounterPartyFiled smallint,
	@SourceTypeCounterPartyNotFiled smallint,
	@ActionTypeNoAction smallint,
	@ContactTypeBillFrom smallint,
	@DocumentStatusDeleted smallint,
	@DocumentStatusCancelled smallint,
	@DocumentStatusActive smallint,
	@ReconciledTypeSystem smallint,
	@ReconciledTypeManual smallint,
	@ReconciledTypeSystemSectionChanged smallint,
	@ReconciledTypeManualSectionChanged smallint,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY)	
AS
BEGIN

SET NOCOUNT ON;
SET DEADLOCK_PRIORITY HIGH;
SET XACT_ABORT ON;

BEGIN TRY

DECLARE @IntraState SMALLINT = 1,
		@InterState SMALLINT = 2,
		@Unreconciled SMALLINT = 51,
		@MappingTypeIncorrect SMALLINT = 6,
		@FinancialYearStartDate DATE = CONCAT(LEFT(CAST(@FinancialYear AS VARCHAR),4), '04', '01'),
		@FinancialYearEndDate DATE,
		@SessionID BIGINT,
		@ReconciliationMappingTypeTillDate SMALLINT = 4,
		@IsReconcileAtDocumentLevel BIT,
		@IsExclude_MatchingCriteria BIT,
		@IsExclude_MatchingCriteria_POS BIT,
		@IsExclude_MatchingCriteria_ReverseCharge BIT,
		@IsExclude_MatchingCriteria_HSN BIT,
		@IsExclude_MatchingCriteria_Rate BIT,
		@IsExclude_MatchingCriteria_DocumentValue BIT,
		@IsExclude_MatchingCriteria_TaxableValue BIT,
		@IsExclude_MatchingCriteria_DocumentDate BIT,
		@IsExclude_MatchingCriteria_TransactionType BIT,
		@IsMatchByTolerance BIT,
		@MatchByTolerance_DocumentValueFrom DECIMAL(15, 2),
		@MatchByTolerance_DocumentValueTo DECIMAL(15, 2),
		@MatchByTolerance_TaxableValueFrom DECIMAL(15, 2),
		@MatchByTolerance_TaxableValueTo DECIMAL(15, 2),
		@MatchByTolerance_TaxAmountsFrom DECIMAL(15, 2),
		@MatchByTolerance_TaxAmountsTo DECIMAL(15, 2),	
		@IsDiscard_Originals_With_Amendment BIT,
		@FilingExtendedDate DATE,
		@IsMatchOnDateDifference  BIT,
		@IsRegeneratePreference  BIT,
		@IsExcludeCpNotFiledData  BIT,
		@IsExcludeMatchingCriteria_Irn  BIT,
		@IsMismatchIfDocNumberDifferentAfterAmendment  BIT,		
		@IfPrTaxAmountIsLessThanCpTaxAmount BIT,
		@IfCpTaxAmountIsLessThanPrTaxAmount BIT,
		@AdvanceNearMatchPoweredByAI BIT,
		@IsNearMatchTolerance BIT,
		@NearMatchTolerance_TaxAmounts DECIMAL(15,2),
		@IsRegeneratePreferenceAction BIT,
		@IsRegeneratePreference3bClaimedMonth BIT,		
		@DeletedPrIds Common.BigIntType,	
		@ReasonType_FalseCreditNote  CHAR(10) = 2147483648,
		@FALSE SMALLINT = 0,		
		@TRUE SMALLINT = 1,
		@IsFuzzyLogic BIT,
		@IsRegeneratePreferenceSectionChange BIT
		
		DECLARE
		@IsCgstSgstAmountNotSumForTolerance BIT = @FALSE
	
	
	SELECT @SessionID = NEXT VALUE FOR Oregular.SessionID;
	
	--DROP TABLE IF EXISTS #Temp2BUnReconciledIds ,#TempPrUnReconciledIds,
	--#Temp2BPurchaseDocumentRecoItems,#TempPrPurchaseDocumentRecoItems;

	CREATE TABLE #Temp2BUnReconciledIds
	(
		Id BIGINT NOT NULL
	);
	
	CREATE TABLE #TempPrUnReconciledIds
	(
		Id BIGINT NOT NULL
	);
	
	/*To Get Reconciliation settings*/
	SELECT @IsReconcileAtDocumentLevel = IsReconcileAtDocumentLevel,
			@IsExclude_MatchingCriteria = IsExcludeMatchingCriteria,
			@IsExclude_MatchingCriteria_POS = IsExcludeMatchingCriteriaPOS,
			@IsExclude_MatchingCriteria_HSN = @FALSE,
			@IsExclude_MatchingCriteria_Rate = @FALSE,
			@IsExclude_MatchingCriteria_DocumentValue = IsExcludeMatchingCriteriaDocumentValue,
			@IsExclude_MatchingCriteria_TaxableValue = IsExcludeMatchingCriteriaTaxableValue,
			@IsExclude_MatchingCriteria_DocumentDate = IsExcludeMatchingCriteriaDocDate,
			@IsExclude_MatchingCriteria_ReverseCharge = IsExcludeMatchingCriteriaReverseCharge,
			@IsExclude_MatchingCriteria_TransactionType = IsExcludeMatchingCriteriaTransactionType,
			@IsMatchByTolerance = IsMatchByTolerance,
			@MatchByTolerance_DocumentValueFrom = MatchByToleranceDocumentValueFrom ,
			@MatchByTolerance_DocumentValueTo = MatchByToleranceDocumentValueTo,
			@MatchByTolerance_TaxableValueFrom = MatchByToleranceTaxableValueFrom,
			@MatchByTolerance_TaxableValueTo = MatchByToleranceTaxableValueTo,
			@MatchByTolerance_TaxAmountsFrom = MatchByToleranceTaxAmountsFrom,
			@MatchByTolerance_TaxAmountsTo = MatchByToleranceTaxAmountsTo,
			@IsDiscard_Originals_With_Amendment = IsDiscardOriginalsWithAmendment,
			@FilingExtendedDate = FilingExtendedDate,
			@IsMatchOnDateDifference = IsMatchOnDateDifference,
			@IsRegeneratePreference = IsRegeneratePreference,
			@IsExcludeCpNotFiledData = IsExcludeCpNotFiledData,
			@IsExcludeMatchingCriteria_Irn = IsExcludeMatchingCriteriaIrn,
			@IsMismatchIfDocNumberDifferentAfterAmendment = IsMismatchIfDocNumberDifferentAfterAmendment,
			@IfPrTaxAmountIsLessThanCpTaxAmount = IfPrTaxAmountIsLessThanCpTaxAmount,
			@IfCpTaxAmountIsLessThanPrTaxAmount = IfCpTaxAmountIsLessThanPrTaxAmount,
			@AdvanceNearMatchPoweredByAI = AdvanceNearMatchPoweredByAI,
			@IsNearMatchTolerance = IsNearMatchTolerance,
			@NearMatchTolerance_TaxAmounts =NearMatchToleranceTaxAmountsTo,
			@IsFuzzyLogic = IsNearMatchViaFuzzyLogic,
			@IsRegeneratePreferenceAction = IsRegeneratePreferenceAction,
			@IsRegeneratePreference3bClaimedMonth = IsRegeneratePreference3bClaimedMonth
	FROM @Settings S WHERE S.FinancialYear = @FinancialYear;
	
	DROP TABLE IF EXISTS #TempDeletedIds;
	CREATE TABLE #TempDeletedIds (Id BIGINT NOT NULL,IsAutoPopulated BIT);
	
	IF @IsExcludeCpNotFiledData = @TRUE
	BEGIN		
		DROP TABLE IF EXISTS #TempCounterPartDeletedId;		
		SELECT 
			r_pdr.Id
		INTO #TempCounterPartDeletedId
		FROM 
			oregular.Gstr2aDocumentRecoMapper pdrm
			INNER JOIN oregular.PurchaseDocumentDW r_pdr ON r_pdr.Id = pdrm.GstnId  
		WHERE 
			r_pdr.SubscriberId = @SubscriberId
			AND r_pdr.ParentEntityId = @ParentEntityId
			AND r_pdr.FinancialYear = @FinancialYear
			AND SourceType = @SourceTypeCounterPartyNotFiled;
	
		IF EXISTS (SELECT 1 FROM #TempCounterPartDeletedId)
		BEGIN		
			UPDATE 
				oregular.PurchaseDocumentStatus 
				SET 
					IsReconciled = @FALSE,
					Gstr2bAction = @ActionTypeNoAction,
					ReconciliationStatus = @ActionTypeNoAction 
			FROM 
				#TempCounterPartDeletedId tcd
			WHERE tcd.Id = PurchaseDocumentId;

			DROP TABLE IF EXISTS  #TempRevertActionCounterFiledPR;			 
			SELECT 
				Distinct Tdr_PR.PrId 				
			INTO #TempRevertActionCounterFiledPR
			FROM 
				#TempCounterPartDeletedId TCD
			INNER JOIN oregular.Gstr2aDocumentRecoMapper Tdr_PR ON TCD.Id = Tdr_PR.GstnId;
								
			UPDATE oregular.PurchaseDocumentStatus 
			SET Gstr2bAction = @ActionTypeNoAction,
					ReconciliationStatus = @ActionTypeNoAction,					
					IsReconciled = @FALSE
			FROM #TempRevertActionCounterFiledPR pr
			WHERE Pr.PrId = PurchaseDocumentId;
		
			INSERT INTO #TempDeletedIds
			SELECT 
				pdrm.Id ,@TRUE IsAutoPopulated
			FROM 
				#TempCounterPartDeletedId pdrm;
		END;
		SET @SourceTypeCounterPartyNotFiled = -1;
	END;	
	
	/*Updatings flag for regenerate reco*/
	IF @IsRegenerateNow = @TRUE
	BEGIN 					
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT pdr.Id
		FROM 	
			oregular.PurchaseDocumentDW pdr
			INNER JOIN Oregular.PurchaseDocumentStatus pds ON pdr.Id = pds.PurchaseDocumentId
		WHERE 	
			pdr.SubscriberId = @SubscriberId
			AND pdr.ParentEntityId = @ParentEntityId 											
			AND DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
			AND pdr.SourceType = @SourceTypeTaxpayer			
			AND pdr.FinancialYear = @FinancialYear
			AND pdr.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)			
			AND pdr.BillFromGstin IS NOT NULL
			AND pds.Status = @DocumentStatusActive;
				
		INSERT INTO #Temp2BUnReconciledIds(Id)
		SELECT pdr.Id		
		FROM 
			oregular.PurchaseDocumentDW pdr
			INNER JOIN Oregular.PurchaseDocumentStatus pds ON pdr.Id = pds.PurchaseDocumentId
		WHERE				
			pdr.SubscriberId = @SubscriberId
			AND pdr.ParentEntityId = @ParentEntityId
			AND pdr.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
			AND pdr.SourceType IN (@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)				
			AND pdr.FinancialYear = @FinancialYear								
			AND pdr.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)				
			AND pdr.BillFromGstin IS NOT NULL
			AND pds.Status = @DocumentStatusActive;


	END;
	ELSE		
	BEGIN
		INSERT INTO #Temp2BUnReconciledIds(Id) 
		SELECT 
			O_PD_DW.Id
		FROM 
			oregular.PurchaseDocumentDW O_PD_DW
			INNER JOIN oregular.PurchaseDocumentStatus pds On O_PD_DW.Id = pds.PurchaseDocumentId
		WHERE 
			O_PD_DW.SubscriberId = @SubscriberId
			AND O_PD_DW.ParentEntityId = @ParentEntityId
			AND O_PD_DW.DocumentType IN(@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
			AND O_PD_DW.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)				
			AND O_PD_DW.FinancialYear = @FinancialYear
			AND O_PD_DW.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
			AND O_PD_DW.BillFromGstin IS NOT NULL
			AND pds.IsReconciled = @FALSE				
			AND pds.Status = @DocumentStatusActive ;

		INSERT INTO  #TempPrUnReconciledIds (Id)
		SELECT 
			O_PD_DW.Id
		FROM 
			Oregular.PurchaseDocumentDW O_PD_DW
			INNER JOIN oregular.PurchaseDocumentStatus PS On O_PD_DW.Id = PS.PurchaseDocumentId
		WHERE 
			O_PD_DW.SubscriberId = @SubscriberId
			AND O_PD_DW.ParentEntityId = @ParentEntityId
			AND O_PD_DW.DocumentType IN(@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
			AND O_PD_DW.SourceType = @SourceTypeTaxpayer				
			AND O_PD_DW.FinancialYear = @FinancialYear			
			AND O_PD_DW.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
			AND O_PD_DW.BillFromGstin IS NOT NULL
			AND PS.IsReconciled = @FALSE					
			AND PS.Status = @DocumentStatusActive;
	END;

		/*Getting id for reconcilation and the deleted ids to delete from recomapper table*/								
		INSERT INTO #Temp2BUnReconciledIds(Id)
		SELECT 
			pdra.Id PurchaseDocumentRecoId
		FROM 
			#Temp2BUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocumentDW r_pd  ON tid.Id = r_pd.Id
			INNER JOIN oregular.PurchaseDocumentDW pdra  
				ON pdra.OriginalDocumentNumber = r_pd.DocumentNumber AND pdra.OriginalDocumentDate = r_pd.DocumentDate			
				AND pdra.SubscriberId = r_pd.SubscriberId
				AND pdra.DocumentType = r_pd.DocumentType
				AND pdra.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)						
				AND pdra.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
				AND pdra.BillFromGstin = r_pd.BillFromGstin
				AND pdra.IsAmendment = @TRUE							
				AND r_pd.IsAmendment = @FALSE		
			WHERE
				pdra.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #Temp2BUnReconciledIds PrId WHERE PrId.Id = pdra.Id);
			
		
		INSERT INTO #Temp2BUnReconciledIds(Id)
		SELECT 
			pdra.Id PurchaseDocumentRecoId
		FROM 
			#Temp2BUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocumentDW r_pd  ON tid.Id = r_pd.Id
			INNER JOIN oregular.PurchaseDocumentDW pdra  
				ON r_pd.OriginalDocumentNumber = pdra.DocumentNumber AND r_pd.OriginalDocumentDate = pdra.DocumentDate			
				AND	pdra.SubscriberId = r_pd.SubscriberId
				AND pdra.DocumentType = r_pd.DocumentType
				AND pdra.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)
				AND pdra.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
				AND pdra.BillFromGstin = r_pd.BillFromGstin
				AND pdra.IsAmendment = @FALSE
				AND r_pd.IsAmendment = @TRUE
			WHERE
				r_pd.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #Temp2BUnReconciledIds PrId WHERE PrId.Id = pdra.Id);			
		
		/*Getting id for reconcilation and the deleted ids to delete from recomapper table*/
		
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT 
			pdra.Id PurchaseDocumentRecoId		
		FROM 
			#TempPrUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocumentDW r_pd  ON tid.Id = r_pd.Id
			INNER JOIN oregular.PurchaseDocumentDW pdra	
				ON  pdra.OriginalDocumentNumber = r_pd.DocumentNumber AND pdra.OriginalDocumentDate = r_pd.DocumentDate	
				AND pdra.SubscriberId = r_pd.SubscriberId
				AND pdra.DocumentType = r_pd.DocumentType
				AND pdra.SourceType = r_pd.SourceType
				AND pdra.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
				AND r_pd.BillFromGstin = pdra.BillFromGstin
				AND pdra.IsAmendment = @TRUE							
				AND r_pd.IsAmendment = @FALSE		
			WHERE
				r_pd.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #TempPrUnReconciledIds PrId WHERE PrId.Id = pdra.Id);
		
		Print 'RecoMain20';	
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT 
			pdra.Id PurchaseDocumentRecoId		
		FROM 
			#TempPrUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocumentDW r_pd  ON tid.Id = r_pd.Id
			INNER JOIN oregular.PurchaseDocumentDW pdra 
				ON  r_pd.OriginalDocumentNumber = pdra.DocumentNumber
				AND r_pd.OriginalDocumentDate = pdra.DocumentDate	
				AND pdra.SubscriberId = r_pd.SubscriberId
				AND pdra.DocumentType = r_pd.DocumentType
				AND pdra.SourceType = r_pd.SourceType			
				AND pdra.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
				AND r_pd.BillFromGstin = pdra.BillFromGstin
				AND pdra.IsAmendment = @FALSE							
				AND r_pd.IsAmendment = @TRUE		
			WHERE 
				r_pd.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #TempPrUnReconciledIds PrId WHERE PrId.Id = pdra.Id);			
		
		INSERT INTO #Temp2BUnReconciledIds(Id)
		SELECT  
			DISTINCT Gstn.Id			
		FROM
			#TempPrUnReconciledIds tids
			INNER JOIN Oregular.PurchaseDocumentDW PR ON tids.Id = PR.Id 
			INNER JOIN Oregular.PurchaseDocumentDW GSTN
				ON 
					PR.DocumentNumber= GSTN.DocumentNumber
					AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.DocumentType = GSTN.DocumentType
					AND GSTN.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)
					AND GSTN.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)
					AND PR.BillFromGstin = GSTN.BillFromGstin
			WHERE
				NOT EXISTS (SELECT * FROM #Temp2BUnReconciledIds PrId WHERE PrId.Id = GSTN.Id);
		
		INSERT INTO  #Temp2BUnReconciledIds (Id)
		SELECT  
			DISTINCT GSTN.Id				
		FROM
			#TempPrUnReconciledIds tids
			INNER JOIN Oregular.PurchaseDocumentDW Pr ON tids.Id = Pr.Id 
			INNER JOIN Oregular.PurchaseDocumentDW GSTN
				ON 												
					Pr.OriginalDocumentNumber = GSTN.DocumentNumber
				AND Pr.DocumentFinancialYear = GSTN.DocumentFinancialYear				
				AND Pr.SubscriberId = GSTN.SubscriberId
				AND Pr.ParentEntityId = GSTN.ParentEntityId
				AND Pr.DocumentType = GSTN.DocumentType
				AND GSTN.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)			
				AND GSTN.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)			
				AND Pr.BillFromGstin = GSTN.BillFromGstin
			WHERE
				Pr.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #Temp2BUnReconciledIds PrId WHERE PrId.Id = GSTN.Id);
		
		Print 'RecoMain23';	
		INSERT INTO #Temp2BUnReconciledIds(Id)
		SELECT Distinct Gstn.Id								 
		FROM
			#TempPrUnReconciledIds tids
			INNER JOIN Oregular.PurchaseDocumentDW PR  ON tids.Id = PR.Id 
			INNER JOIN Oregular.PurchaseDocumentDW GSTN 
					ON 
						GSTN.OriginalDocumentNumber = PR.DocumentNumber
					AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear			
					AND PR.SubscriberId = GSTN.SubscriberId					
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.DocumentType = GSTN.DocumentType								
					AND GSTN.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)
					AND GSTN.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)			
					AND PR.BillFromGstin = GSTN.BillFromGstin
			WHERE
				GSTN.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #Temp2BUnReconciledIds PrId WHERE PrId.Id = GSTN.Id);																
			
		Print 'RecoMain24';		
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT 
			distinct PR.Id				
		FROM
			#Temp2BUnReconciledIds tids
			INNER JOIN Oregular.PurchaseDocumentDW GSTN ON tids.Id = GSTN.Id 
			INNER JOIN Oregular.PurchaseDocumentDW Pr
				ON 
					PR.DocumentNumber = GSTN.DocumentNumber
					AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear
					AND PR.SubscriberId = GSTN.SubscriberId				
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.DocumentType = GSTN.DocumentType
					AND Pr.SourceType = @SourceTypeTaxpayer						
					AND Pr.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)				
					AND PR.BillFromGstin = GSTN.BillFromGstin
		WHERE
			NOT EXISTS (SELECT * FROM #TempPrUnReconciledIds PrId WHERE PrId.Id = Pr.Id);			
		
		
		Print 'RecoMain25';	
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT 
			distinct PR.Id				
		FROM
			#Temp2BUnReconciledIds tids
			INNER JOIN Oregular.PurchaseDocumentDW GSTN ON tids.Id = GSTN.Id 
			INNER JOIN Oregular.PurchaseDocumentDW Pr
				ON 				
					PR.OriginalDocumentNumber = GSTN.DocumentNumber
					AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.DocumentType = GSTN.DocumentType
					AND Pr.SourceType = @SourceTypeTaxpayer			
					AND Pr.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)				
					AND PR.BillFromGstin = GSTN.BillFromGstin
			WHERE 
				PR.OriginalDocumentNumber IS NOT NULL
				AND NOT EXISTS (SELECT * FROM #TempPrUnReconciledIds PrId WHERE PrId.Id = Pr.Id);				
		
		Print 'RecoMain25.1';	
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT 
			distinct PR.Id				
		FROM
			#Temp2BUnReconciledIds tids
			INNER JOIN Oregular.PurchaseDocumentDW GSTN ON tids.Id = GSTN.Id 
			INNER JOIN Oregular.PurchaseDocumentDW Pr
				ON 												
					GSTN.OriginalDocumentNumber = PR.DocumentNumber
					AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear
					AND	PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId				
					AND PR.DocumentType = GSTN.DocumentType
					AND Pr.SourceType = @SourceTypeTaxpayer				
					AND Pr.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)				
					AND PR.BillFromGstin = GSTN.BillFromGstin
		WHERE
			GSTN.OriginalDocumentNumber IS NOT NULL				
			AND  NOT EXISTS (SELECT * FROM #TempPrUnReconciledIds PrId WHERE PrId.Id = Pr.Id);				
		
		
		IF EXISTS (SELECT 1 FROM oregular.PurchaseDocuments WHERE DocumentType = @DocumentTypeBOE )		
		BEGIN
			IF @IsRegenerateNow = @TRUE
			BEGIN
				INSERT INTO #TempPrUnReconciledIds(Id)
				SELECT
					pdr.Id
				FROM 	
					oregular.PurchaseDocumentDW pdr
				INNER JOIN Oregular.PurchaseDocumentStatus pds ON pdr.Id = pds.PurchaseDocumentId
				WHERE 	
					pdr.SubscriberId = @SubscriberId
					AND pdr.ParentEntityId = @ParentEntityId 
					AND pdr.DocumentType  = @DocumentTypeBOE
					AND pdr.SourceType = @SourceTypeTaxpayer																
					AND pdr.FinancialYear = @FinancialYear
					AND pdr.TransactionType = @TransactionTypeIMPG					
					AND pds.Status = @DocumentStatusActive;
			
			INSERT INTO #Temp2BUnReconciledIds(Id)
			SELECT
				pdr.Id		
			FROM 
				oregular.PurchaseDocumentDW pdr
			INNER JOIN Oregular.PurchaseDocumentStatus pds ON pdr.Id = pds.PurchaseDocumentId
			WHERE				
				pdr.SubscriberId = @SubscriberId
				AND pdr.ParentEntityId = @ParentEntityId 
				AND pdr.DocumentType  = @DocumentTypeBOE
				AND pdr.SourceType IN (@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)								
				AND pdr.FinancialYear = @FinancialYear
				AND pdr.TransactionType = @TransactionTypeIMPG				
				AND pds.Status = @DocumentStatusActive;
		END;
		ELSE
		BEGIN
			INSERT INTO #Temp2BUnReconciledIds(Id) 
			SELECT 
				O_PD_DW.Id
			FROM 
				oregular.PurchaseDocumentDW O_PD_DW
			INNER JOIN oregular.PurchaseDocumentStatus pds On O_PD_DW.Id = pds.PurchaseDocumentId
			WHERE 
				O_PD_DW.SubscriberId = @SubscriberId
				AND O_PD_DW.ParentEntityId = @ParentEntityId
				AND O_PD_DW.DocumentType  = @DocumentTypeBOE
				AND O_PD_DW.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)
				AND O_PD_DW.FinancialYear = @FinancialYear
				AND O_PD_DW.TransactionType = @TransactionTypeIMPG								
				AND pds.IsReconciled = @FALSE
				AND pds.Status = @DocumentStatusActive ;

			INSERT INTO #TempPrUnReconciledIds (Id)
			SELECT 
				O_PD_DW.Id
			FROM 
				Oregular.PurchaseDocumentDW O_PD_DW
			INNER JOIN oregular.PurchaseDocumentStatus PS On O_PD_DW.Id = PS.PurchaseDocumentId
			WHERE 
				O_PD_DW.SubscriberId = @SubscriberId
				AND O_PD_DW.ParentEntityId = @ParentEntityId
				AND O_PD_DW.DocumentType  = @DocumentTypeBOE
				AND O_PD_DW.SourceType = @SourceTypeTaxpayer
				AND O_PD_DW.FinancialYear = @FinancialYear							
				AND O_PD_DW.TransactionType = @TransactionTypeIMPG				
				AND PS.IsReconciled = @FALSE
				AND PS.Status = @DocumentStatusActive;	
		END;
		
		INSERT INTO #Temp2BUnReconciledIds(Id)
		SELECT  
			DISTINCT Gstn.Id			
		FROM
			#TempPrUnReconciledIds tids
		INNER JOIN Oregular.PurchaseDocumentDW PR ON tids.Id = PR.Id 
		INNER JOIN Oregular.PurchaseDocumentDW GSTN
			ON 
				PR.DocumentNumber = GSTN.DocumentNumber
				AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear
		INNER JOIN oregular.PurchaseDocumentStatus PS On GSTN.Id = PS.PurchaseDocumentId
		WHERE 
			 PR.SubscriberId = GSTN.SubscriberId			
			AND PR.ParentEntityId = GSTN.ParentEntityId
			AND PR.DocumentType = GSTN.DocumentType
			AND GSTN.SourceType IN(@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)
			AND GSTN.TransactionType = @TransactionTypeIMPG						
			AND NOT EXISTS (SELECT * FROM #Temp2BUnReconciledIds PrId WHERE PrId.Id = GSTN.Id);
		
		INSERT INTO #TempPrUnReconciledIds(Id)
		SELECT 
			distinct PR.Id				
		FROM
			#Temp2BUnReconciledIds tids
		INNER JOIN Oregular.PurchaseDocumentDW GSTN ON tids.Id = GSTN.Id 
		INNER JOIN Oregular.PurchaseDocumentDW Pr
			ON
				PR.DocumentNumber = GSTN.DocumentNumber
			AND PR.DocumentFinancialYear = GSTN.DocumentFinancialYear
		WHERE 
			 PR.SubscriberId = GSTN.SubscriberId
			AND PR.ParentEntityId = GSTN.ParentEntityId
			AND PR.DocumentType = GSTN.DocumentType
			AND Pr.SourceType = @SourceTypeTaxpayer
			AND Pr.TransactionType = @TransactionTypeIMPG						
			AND  NOT EXISTS (SELECT * FROM #TempPrUnReconciledIds PrId WHERE PrId.Id = Pr.Id)			
	END;
		
		
		IF EXISTS (SELECT TOP 1 1 FROM oregular.PurchaseDocumentRecoManualMapper)
		BEGIN
				INSERT INTO #TempDeletedIds
				SELECT 
					pr.PrId ,0 IsAutoPopulated
				FROM 
					oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK)
					CROSS APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr
				WHERE 
					PDRMM.SubscriberId = @SubscriberId
					AND PDRMM.ParentEntityId = @ParentEntityId	
					--AND PDRMM.ReconciliationType = 8
					AND NOT EXISTS (
									SELECT * 
									FROM oregular.PurchaseDocumentDW dw WITH(NOLOCK)
									INNER JOIN oregular.PurchaseDocumentStatus ps WITH(NOLOCK) ON dw.Id = ps.PurchaseDocumentId
									WHERE 
										dw.Id = pr.PrId																
										AND dw.DocumentType IN(@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
										AND dw.SourceType = @SourceTypeTaxPayer
										AND dw.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)								
										AND dw.BillFromGstin IS NOT NULL
										AND PS.[Status] = @DocumentStatusActive	
								);

				INSERT INTO #TempDeletedIds
				SELECT 
					Gst.GstId ,1 IsAutoPopulated
				FROM 
					oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK)
					CROSS APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst
				WHERE
					PDRMM.SubscriberId = @SubscriberId
					AND PDRMM.ParentEntityId = @ParentEntityId
				--	AND PDRMM.ReconciliationType = 8
					AND NOT EXISTS (
									SELECT 
										1
									FROM oregular.PurchaseDocumentDW dw WITH(NOLOCK)
									INNER JOIN oregular.PurchaseDocumentStatus ps WITH(NOLOCK) ON dw.Id = ps.PurchaseDocumentId
									WHERE 
										dw.Id = Gst.GstId																
										AND dw.DocumentType IN(@DocumentTypeINV, @DocumentTypeCRN, @DocumentTypeDBN)
										AND dw.SourceType = @SourceTypeCounterPartyFiled
										AND dw.TransactionType IN(@TransactionTypeB2B, @TransactionTypeSEZWP, @TransactionTypeSEZWOP, @TransactionTypeDE, @TransactionTypeISD, @TransactionTypeCBW, @TransactionTypeIMPS)								
										AND dw.BillFromGstin IS NOT NULL
										AND ps.IsAvailableInGstr2B = @TRUE
										AND PS.[Status] = @DocumentStatusActive	
								);
			END;
			
				
		DROP TABLE IF EXISTS #TempPurchaseDocumentRecoManualMapper;
		CREATE TABLE #TempPurchaseDocumentRecoManualMapper(			
			PurchaseDocumentRecoManualMapperId BIGINT NOT NULL
		);
		
		CREATE  INDEX IX_PurchaseDocumentRMMapper_PDRecoManualMapperId ON #TempPurchaseDocumentRecoManualMapper(PurchaseDocumentRecoManualMapperId);					   
		IF EXISTS (SELECT 1 FROM #TempDeletedIds)		
		BEGIN
			/*Getting the Manually mapped ids*/
			INSERT INTO #TempPurchaseDocumentRecoManualMapper(				
				PurchaseDocumentRecoManualMapperId
			)
			SELECT 
				PDRMM.Id AS PurchaseDocumentRecoManualMapperId
			FROM
				oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK)
				CROSS APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr
				INNER JOIN #TempDeletedIds trpd ON trpd.Id = Pr.PrId					
			UNION 
			SELECT				
				PDRMM.Id AS PurchaseDocumentRecoManualMapperId
			FROM
				oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK)
				CROSS APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst
				INNER JOIN #TempDeletedIds trpd ON trpd.Id = Gst.GstId
		
		/*Getting the total manuaal mapped ids against the deleted ids per mapper id */
			DROP TABLE IF EXISTS ManualMapperPrCount;			
			SELECT
				PDRMM.Id AS PurchaseDocumentRecoManualMapperId,
				COUNT(trpd.Id) TotalPrDeletedIds,
				COUNT(*) TotalPrIds					
			INTO #ManualMapperPrCount	
			FROM
				#TempPurchaseDocumentRecoManualMapper tpdrmm				
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK) ON tpdrmm.PurchaseDocumentRecoManualMapperId = PDRMM.Id
				CROSS APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr				
				LEFT JOIN #TempDeletedIds trpd ON trpd.Id = Pr.Prid AND trpd.IsAutoPopulated = @FALSE
			--WHERE PDRMM.ReconciliationType = 8
			GROUP BY PDRMM.Id
			HAVING COUNT(trpd.Id) > 0;
						
			DROP TABLE IF EXISTS #ManualMapperGstnCount;			
			SELECT
				PDRMM.Id AS PurchaseDocumentRecoManualMapperId,
				COUNT(trpd.Id) TotalGstnDeletedIds,
				COUNT(*) TotalGstnIds					
			INTO #ManualMapperGstnCount	
			FROM
				#TempPurchaseDocumentRecoManualMapper tpdrmm
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK) ON tpdrmm.PurchaseDocumentRecoManualMapperId = PDRMM.Id
				CROSS APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst
				LEFT JOIN #TempDeletedIds trpd ON trpd.Id = gst.GstID AND trpd.IsAutoPopulated = @TRUE
			--WHERE PDRMM.ReconciliationType = 8
			GROUP BY PDRMM.Id
			HAVING COUNT(trpd.Id)  > 0;
			
			/*Updating reconciled flag to @FALSE in reco if all the mapped ids are in deleted status*/
			DROP TABLE IF EXISTS #TempGstDeletedManualIds;	 
			SELECT Gst.GstId  GstId							
			INTO #TempGstDeletedManualIds
			FROM
				#ManualMapperPrCount mppc
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK) ON mppc.PurchaseDocumentRecoManualMapperId = PDRMM.Id
				CROSS APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst
			WHERE
				--PDRMM.ReconciliationType = 8 AND 
				mppc.TotalPrIds = TotalPrDeletedIds;
			
			UPDATE PDR
			SET IsReconciled = @FALSE,
				Gstr2bAction = @ActionTypeNoAction
			FROM
				#TempGstDeletedManualIds Gst
				INNER JOIN oregular.PurchaseDocumentStatus PDR WITH(NOLOCK) ON PDR.PurchaseDocumentId = Gst.GstId
						
			/*Updating reconciled flag to @FALSE in reco if all the mapped ids are in deleted status*/
			DROP TABLE IF EXISTS #TempPrDeletedManualIds;			
			SELECT Pr.PrId AS PrId					
			INTO #TempPrDeletedManualIds
			FROM
				#ManualMapperGstnCount mppc
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM WITH(NOLOCK) ON mppc.PurchaseDocumentRecoManualMapperId = PDRMM.Id
				CROSS APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr
			WHERE				
				mppc.TotalGstnIds = TotalGstnDeletedIds;

			UPDATE PDR
			SET IsReconciled = @FALSE,
				 Gstr2bAction = @ActionTypeNoAction
			FROM
				#TempPrDeletedManualIds Pr
				INNER JOIN oregular.PurchaseDocumentStatus PDR WITH(NOLOCK) ON PDR.PurchaseDocumentId = Pr.PrId

			DROP TABLE IF EXISTS #TempGstDeletedManualIds,#TempPrDeletedManualIds;
			/*Deleting from recomapper if all the mapped ids are in deleted status*/
			DELETE
				PDRMM
			FROM
				#ManualMapperPrCount mppc
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM ON mppc.PurchaseDocumentRecoManualMapperId = PDRMM.Id
			WHERE
				mppc.TotalPrIds = TotalPrDeletedIds;
				
			/*Deleting from recomapper if all the mapped ids are in deleted status*/
			DELETE
				PDRMM
			FROM
				#ManualMapperGstnCount mppc
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM ON mppc.PurchaseDocumentRecoManualMapperId = PDRMM.Id
			WHERE
				mppc.TotalGstnIds = TotalGstnDeletedIds;
															
			/*Storing deleted ids in Variable*/
			 
			/*Storing deleted ids in Variable*/
			INSERT INTO @DeletedPrIds
			(
				Item
			)
			SELECT
				trpd.Id
			FROM #TempDeletedIds trpd;	
			
			/*Updating Prids in recomapper in case partial mapped ids are in deleted status*/
			UPDATE PDRMM
				SET PDRMM.PrIds = [oregular].[ufnGetUpdatedManualMapperJson](PDRMM.PrIds, @DeletedPrIds,0)
			FROM
				#ManualMapperPrCount mppc
				INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM ON mppc.PurchaseDocumentRecoManualMapperId = PDRMM.Id
			WHERE
				mppc.TotalPrIds <> TotalPrDeletedIds;

			/*Updating Prids in recomapper in case partial mapped ids are in deleted status*/
			UPDATE PDRMM
				SET PDRMM.GstIds = [oregular].[ufnGetUpdatedManualMapperJson](PDRMM.GstIds, @DeletedPrIds,1)
			FROM
					#ManualMapperGstnCount mppc
					INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM ON mppc.PurchaseDocumentRecoManualMapperId = PDRMM.Id
			WHERE
				mppc.TotalGstnIds <> TotalGstnDeletedIds;			
		END;

		CREATE TABLE #Temp2BPurchaseDocumentRecoItems(
			Id BIGINT IDENTITY(1,1),
			PurchaseDocumentRecoId bigint NOT NULL,			
			TaxableValue decimal(18, 2) NULL,
			Rate decimal(5, 2) NOT NULL,
			IgstAmount decimal(18, 2) NULL,
			CgstAmount decimal(18, 2) NULL,
			SgstAmount decimal(18, 2) NULL,
			CessAmount decimal(18, 2) NULL,
			HsnRate int NOT NULL
			);
		
		CREATE INDEX IDX_#Temp2BPurchaseDocumentRecoItems ON #Temp2BPurchaseDocumentRecoItems (PurchaseDocumentRecoId,Rate);
		
		CREATE TABLE #TempPrPurchaseDocumentRecoItems(
			Id BIGINT IDENTITY(1,1),
			PurchaseDocumentRecoId bigint NOT NULL,					
			TaxableValue decimal(18, 2) NULL,
			Rate decimal(5, 2) NOT NULL,
			IgstAmount decimal(18, 2) NULL,
			CgstAmount decimal(18, 2) NULL,
			SgstAmount decimal(18, 2) NULL,
			CessAmount decimal(18, 2) NULL,
			HsnRate int NOT NULL			
			);		

		CREATE INDEX IDX_#TempPrPurchaseDocumentRecoItems ON #TempPrPurchaseDocumentRecoItems (PurchaseDocumentRecoId,Rate);
		--Getting Details From detail table in TABLE
		
		DROP TABLE IF EXISTS #Temp2BUnReconciledItemIds;		
		SELECT
			pdri.Id
		INTO #Temp2BUnReconciledItemIds
		FROM
		Oregular.PurchaseDocumentItems pdri
		WHERE EXISTS(SELECT 1 FROM #Temp2BUnReconciledIds tpd WHERE pdri.PurchaseDocumentId = tpd.Id);
		
		Print 'RecoMain51';
		INSERT INTO #Temp2BPurchaseDocumentRecoItems
		(
			 PurchaseDocumentRecoId
			,TaxableValue
			,Rate
			,IgstAmount
			,CgstAmount
			,SgstAmount
			,CessAmount
			,HsnRate
		)
		SELECT 
			pdri.PurchaseDocumentId
			,SUM(pdri.TaxableValue) TaxableValue
			,pdri.Rate
			,SUM(pdri.IgstAmount) IgstAmount
			,SUM(pdri.CgstAmount) CgstAmount
			,SUM(pdri.SgstAmount) SgstAmount
			,SUM(pdri.CessAmount) CessAmount
			,pdri.Rate AS HsnRate			
		FROM 
			Oregular.PurchaseDocumentItems pdri
			INNER JOIN #Temp2BUnReconciledItemIds tpd ON pdri.Id = tpd.Id
		GROUP BY pdri.PurchaseDocumentId,pdri.Rate;
				
		DROP TABLE IF EXISTS #TempPrUnReconciledItemIds;		
		SELECT 
			pdri.Id
		INTO #TempPrUnReconciledItemIds
		FROM 
			Oregular.PurchaseDocumentItems pdri
		WHERE EXISTS (SELECT 1 FROM #TempPrUnReconciledIds tpd WHERE pdri.PurchaseDocumentId = tpd.Id);

		--Getting Details From detail table in TABLE
		INSERT INTO #TempPrPurchaseDocumentRecoItems
		(
			PurchaseDocumentRecoId
			,TaxableValue
			,Rate
			,IgstAmount
			,CgstAmount
			,SgstAmount
			,CessAmount
			,HsnRate
		)
		SELECT 
			 pdri.PurchaseDocumentId
			,SUM(pdri.TaxableValue) TaxableValue
			,pdri.Rate
			,SUM(pdri.IgstAmount) IgstAmount
			,SUM(pdri.CgstAmount) CgstAmount
			,SUM(pdri.SgstAmount) SgstAmount
			,SUM(pdri.CessAmount) CessAmount
			,pdri.Rate AS HsnRate	
		FROM 
			Oregular.PurchaseDocumentItems pdri
			INNER JOIN #TempPrUnReconciledItemIds tpd ON pdri.Id = tpd.Id
		GROUP BY pdri.PurchaseDocumentId,pdri.Rate;						
		Print 'RecoMain53';
		DROP TABLE IF EXISTS #Temp2bHeaderData, #Temp2bAmendmentData, #Temp2BPurchaseDocumentRecoItemsAgg;
				
		SELECT 
			COUNT(*) ItemCount,
			SUM(pdri.IgstAmount) AS IgstAmount,
			SUM(pdri.CgstAmount) AS CgstAmount, 
			SUM(pdri.SgstAmount) AS SgstAmount, 
			SUM(pdri.CessAmount) AS CessAmount,
			CASE WHEN SUM(CASE WHEN pdri.IgstAmount IS NOT NULL THEN 1 ELSE 0 END) >= 1 THEN @InterState ELSE @IntraState END AS SupplyType,
			PurchaseDocumentRecoId 
		INTO #Temp2BPurchaseDocumentRecoItemsAgg	
		FROM 
			#Temp2BPurchaseDocumentRecoItems pdri			
		GROUP BY pdri.PurchaseDocumentRecoId;
		
		Print 'RecoMain54';				
		SELECT 
			pdra.Id PurchaseDocumentRecoId,
			r_pd.Id	   
		INTO #Temp2bAmendmentData
		FROM 
			#Temp2BUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocumentDW r_pd ON tid.Id = r_pd.Id
			INNER JOIN oregular.PurchaseDocumentDW pdra 
				ON pdra.OriginalDocumentNumber =r_pd.DocumentNumber AND pdra.OriginalDocumentDate = r_pd.DocumentDate
				AND pdra.SubscriberId = r_pd.SubscriberId
				AND pdra.DocumentType = r_pd.DocumentType
				AND pdra.SourceType IN (@SourceTypeCounterPartyFiled,@SourceTypeCounterPartyNotFiled)
				AND pdra.BillFromGstin = r_pd.BillFromGstin			
				AND pdra.IsAmendment = @TRUE							
				AND r_pd.IsAmendment = @FALSE
		WHERE pdra.OriginalDocumentNumber IS NOT NULL;

		Print 'RecoMain54.1';		
		SELECT 
			r_pd.Id
			,r_pd.SubscriberId
			,r_pd.EntityId
			,ISNULL(pdc.Gstin, '') AS Gstin
			,CASE WHEN r_pd.DocumentType = 4 THEN r_pd.PortCode ELSE '' END PortCode
			,r_pd.DocumentType DocumentType
			,r_pd.DocumentNumber DocumentNumber 
			,r_pd.DocumentDate
			,COALESCE(r_pd.TransactionType, -1) AS TransactionType
			,r_pd.DocumentValue Value
			,r_pd.TotalTaxableValue
			,r_pd.TotalTaxAmount
			,CASE WHEN r_pd.DocumentType = 4 THEN -1 ELSE COALESCE(r_pd.Pos, -1) END AS POS
			,CASE WHEN r_pd.DocumentType = 4 THEN @TRUE ELSE r_pd.ReverseCharge END ReverseCharge
			,r_pd.OriginalDocumentNumber AS OriginalDocumentNumber
			,r_pd.OriginalDocumentDate
			,r_ps.OriginalReturnPeriod
			,CONCAT(MONTH(r_pd.DocumentDate), YEAR(r_pd.DocumentDate)) DocumentDateReturnPeriod
			,r_pd.ReturnPeriod
			,(CASE WHEN MONTH(r_pd.DocumentDate) >= 4 THEN CONCAT(YEAR(r_pd.DocumentDate), RIGHT(YEAR(r_pd.DocumentDate)+1,2)) ELSE CONCAT(YEAR(r_pd.DocumentDate)-1, RIGHT(YEAR(r_pd.DocumentDate),2)) END) AS FinancialYear
			,r_pd.IsAmendment
			,r_pd.SourceType			
			,r_ps.Status
			,r_ps.Gstr2bAction Gstr2bAction
			,r_pd.ParentEntityId AS ParentEntityId
			,CASE WHEN r_pd.SourceType = @SourceTypeTaxpayer THEN @FALSE ELSE @TRUE END AS IsAutoPopulated
			,CASE WHEN IIF(LEN(r_pd.ReturnPeriod) = 6, LEFT(r_pd.ReturnPeriod,2), LEFT(r_pd.ReturnPeriod,1)) > 3 THEN CONCAT(RIGHT(r_pd.ReturnPeriod,4), RIGHT(r_pd.ReturnPeriod,2)+1) ELSE CONCAT(RIGHT(r_pd.ReturnPeriod,4)-1, RIGHT(r_pd.ReturnPeriod,2)) END AS RPFinancialYear
			,CONCAT(RIGHT(r_pd.ReturnPeriod,4), IIF(LEN(r_pd.ReturnPeriod) = 6, LEFT(r_pd.ReturnPeriod,2), CONCAT('0',LEFT(r_pd.ReturnPeriod,1))), '01') AS ReturnPeriodDate					
			,COALESCE(pdri.ItemCount,0) AS ItemCount
			,COALESCE(pdri.IgstAmount,0) AS IgstAmount
			,COALESCE(pdri.CgstAmount,0) AS CgstAmount
			,COALESCE(pdri.SgstAmount,0) AS SgstAmount
			,COALESCE(pdri.CessAmount,0) AS CessAmount
			,pdri.SupplyType
			,r_ps.Gstr2BReturnPeriod				
			,CASE WHEN r_ps.Gstr2BReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(r_ps.Gstr2BReturnPeriod,4), IIF(LEN(r_ps.Gstr2BReturnPeriod) = 6, LEFT(r_ps.Gstr2BReturnPeriod,2), CONCAT('0',LEFT(r_ps.Gstr2BReturnPeriod,1))), '01') ELSE NULL END AS Gstr2BReturnPeriodDate
			,COALESCE(r_pd.Irn,'') Irn
			,pdra.PurchaseDocumentRecoId PurchaseDocumentRecoId	
			,r_ps.IsAvailableInGstr2B IsAvailableInGstr2b
		INTO #Temp2bHeaderData
		FROM
			#Temp2BUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocuments r_pd ON tid.Id = r_pd.Id
			LEFT JOIN Oregular.PurchaseDocumentContacts pdc ON pdc.PurchaseDocumentId = r_pd.Id AND pdc.Type = @ContactTypeBillFrom
			INNER JOIN Oregular.PurchaseDocumentStatus r_ps ON r_pd.Id = r_ps.PurchaseDocumentId			
			INNER JOIN #Temp2BPurchaseDocumentRecoItemsAgg pdri ON r_pd.Id = pdri.PurchaseDocumentRecoId
			OUTER APPLY (SELECT TOP 1 * FROM #Temp2bAmendmentData pdra WHERE pdra.Id = r_pd.Id ORDER BY pdra.Id DESC ) pdra;

		Print 'RecoMain55';
		CREATE INDEX IDX_#Temp2bHeaderData ON #Temp2bHeaderData (Id);
		   
		DROP TABLE IF EXISTS #Temp2BPurchaseDocumentRecoItemsAgg, #Temp2bAmendmentData,  #TempPrPurchaseDocumentRecoItemsAgg,#TempPrAmendmentData;
						
		SELECT 
			COUNT(*) ItemCount,
			SUM(pdri.IgstAmount) AS IgstAmount,
			SUM(pdri.CgstAmount) AS CgstAmount, 
			SUM(pdri.SgstAmount) AS SgstAmount, 
			SUM(pdri.CessAmount) AS CessAmount,
			CASE WHEN SUM(CASE WHEN pdri.IgstAmount IS NOT NULL THEN 1 ELSE 0 END) >= 1 THEN @InterState ELSE @IntraState END AS SupplyType,								
			pdri.PurchaseDocumentRecoId										 
		INTO #TempPrPurchaseDocumentRecoItemsAgg	
		FROM 
			#TempPrPurchaseDocumentRecoItems pdri		
		GROUP BY pdri.PurchaseDocumentRecoId;	  
		 
		Print 'RecoMain57'; 		
		SELECT 
			pdra.Id PurchaseDocumentRecoId, 
			tid.Id 
		INTO #TempPrAmendmentData
		FROM 
			#TempPrUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocumentDW r_pd ON tid.Id = r_pd.Id
			INNER JOIN oregular.PurchaseDocumentDW pdra ON  pdra.OriginalDocumentNumber = r_pd.DocumentNumber AND pdra.OriginalDocumentDate = r_pd.DocumentDate	
		WHERE 
			pdra.SubscriberId = r_pd.SubscriberId
			AND pdra.DocumentType = r_pd.DocumentType
			AND pdra.SourceType = r_pd.SourceType
			AND r_pd.BillFromGstin = pdra.BillFromGstin
			AND pdra.OriginalDocumentNumber = r_pd.DocumentNumber
			AND pdra.OriginalDocumentDate = r_pd.DocumentDate
			AND pdra.IsAmendment = @TRUE							
			AND r_pd.IsAmendment = @FALSE;
				
		DROP TABLE IF EXISTS #TempPrHeaderData;
		SELECT 
			r_pd.Id
			,r_pd.SubscriberId
			,r_pd.EntityId
			,ISNULL(pdc.Gstin, '') AS Gstin
			,CASE WHEN r_pd.DocumentType = 4 THEN r_pd.PortCode ELSE '' END AS PortCode
			,r_pd.DocumentType DocumentType
			,r_pd.DocumentNumber DocumentNumber
			,r_pd.DocumentDate
			,COALESCE(r_pd.TransactionType, -1) AS TransactionType
			,r_pd.DocumentValue Value
			,r_pd.TotalTaxableValue
			,r_pd.TotalTaxAmount
			,CASE WHEN r_pd.DocumentType = 4 THEN  -1 ELSE COALESCE(r_pd.Pos, -1) END AS POS
			,CASE WHEN r_pd.DocumentType = 4 THEN  @TRUE ELSE r_pd.ReverseCharge END AS ReverseCharge
			,r_pd.OriginalDocumentNumber AS OriginalDocumentNumber
			,r_pd.OriginalDocumentDate
			,r_ps.OriginalReturnPeriod
			,CONCAT(MONTH(r_pd.DocumentDate), YEAR(r_pd.DocumentDate)) DocumentDateReturnPeriod
			,r_pd.ReturnPeriod
			,(CASE WHEN MONTH(r_pd.DocumentDate) >= 4 THEN CONCAT(YEAR(r_pd.DocumentDate), RIGHT(YEAR(r_pd.DocumentDate)+1,2)) ELSE CONCAT(YEAR(r_pd.DocumentDate)-1, RIGHT(YEAR(r_pd.DocumentDate),2)) END) AS FinancialYear
			,r_pd.IsAmendment
			,r_pd.SourceType			
			,r_ps.Status
			,r_ps.Gstr2bAction Gstr2bAction
			,r_pd.ParentEntityId AS ParentEntityId
			,CASE WHEN r_pd.SourceType = @SourceTypeTaxpayer THEN @FALSE ELSE @TRUE END AS IsAutoPopulated
			,CASE WHEN IIF(LEN(r_pd.ReturnPeriod) = 6, LEFT(r_pd.ReturnPeriod,2), LEFT(r_pd.ReturnPeriod,1)) > 3 THEN CONCAT(RIGHT(r_pd.ReturnPeriod,4), RIGHT(r_pd.ReturnPeriod,2)+1) ELSE CONCAT(RIGHT(r_pd.ReturnPeriod,4)-1, RIGHT(r_pd.ReturnPeriod,2)) END AS RPFinancialYear
			,CONCAT(RIGHT(r_pd.ReturnPeriod,4), IIF(LEN(r_pd.ReturnPeriod) = 6, LEFT(r_pd.ReturnPeriod,2), CONCAT('0',LEFT(r_pd.ReturnPeriod,1))), '01') AS ReturnPeriodDate					
			,COALESCE(pdri.ItemCount,0) AS ItemCount
			,COALESCE(pdri.IgstAmount,0) AS IgstAmount
			,COALESCE(pdri.CgstAmount,0) AS CgstAmount
			,COALESCE(pdri.SgstAmount,0) AS SgstAmount
			,COALESCE(pdri.CessAmount,0) AS CessAmount
			,pdri.SupplyType
			,r_ps.Gstr2BReturnPeriod				
			,CASE WHEN r_ps.Gstr2BReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(r_ps.Gstr2BReturnPeriod,4), IIF(LEN(r_ps.Gstr2BReturnPeriod) = 6, LEFT(r_ps.Gstr2BReturnPeriod,2), CONCAT('0',LEFT(r_ps.Gstr2BReturnPeriod,1))), '01') ELSE NULL END AS Gstr2BReturnPeriodDate
			,COALESCE(r_pd.Irn,'') Irn
			,pda.PurchaseDocumentRecoId PurchaseDocumentRecoId
		INTO #TempPrHeaderData
		FROM
			#TempPrUnReconciledIds tid
			INNER JOIN Oregular.PurchaseDocuments r_pd ON tid.Id = r_pd.Id
			LEFT JOIN Oregular.PurchaseDocumentContacts pdc ON pdc.PurchaseDocumentId = r_pd.Id AND pdc.Type = @ContactTypeBillFrom
			INNER JOIN Oregular.PurchaseDocumentStatus r_ps ON r_pd.Id = r_ps.PurchaseDocumentId			
			INNER JOIN #TempPrPurchaseDocumentRecoItemsAgg pdri ON pdri.PurchaseDocumentRecoId = r_pd.Id
			OUTER APPLY (SELECT TOP 1 * FROM #TempPrAmendmentData pdra WHERE pdra.Id =r_pd.Id ORDER BY pdra.Id ) pda
	
	CREATE INDEX IDX_#TempPrHeaderData ON #TempPrHeaderData (Id);
	/*To get action taken records in TABLE to preserve in reconciliation */
	DROP TABLE IF EXISTS #ManualMappingID;
	CREATE TABLE #ManualMappingID(PurchaseDocumentId BIGINT NOT NULL,IsAutopopulated BIT,PreserveType CHARACTER VARYING(10));
				
	IF (@IsRegenerateNow = @FALSE OR (@IsRegenerateNow = @TRUE AND @IsRegeneratePreference = @TRUE))
	BEGIN
		IF @IsRegeneratePreferenceAction = @TRUE OR @IsRegenerateNow = @FALSE
		BEGIN	
			INSERT INTO #ManualMappingID(PurchaseDocumentId,IsAutopopulated,PreserveType)
			SELECT  PDR.Id,CASE WHEN pdr.SourceType = 1 THEN @FALSE ELSE @TRUE END,'2b'
			FROM 
				oregular.PurchaseDocuments PDR
			INNER JOIN oregular.PurchaseDocumentStatus pds ON pdr.Id = pds.PurchaseDocumentId
			WHERE 
				PDR.SubscriberId = @SubscriberId
				AND COALESCE(pds.Gstr2bAction,1) <> @ActionTypeNoAction;					
		END
		IF (@IsRegeneratePreferenceSectionChange = @TRUE OR @IsRegenerateNow = @FALSE)
		BEGIN
			IF(@IsRegenerateNow = @FALSE)
			BEGIN	
				SET @IsRegeneratePreferenceSectionChange = @TRUE;
			END
			
			INSERT INTO #ManualMappingID(PurchaseDocumentId,IsAutopopulated,PreserveType)
			SELECT   
				PDRM.PrId,@FALSE,'2a'
			FROM 
				Oregular.Gstr2aDocumentRecoMapper PDRM			
			WHERE 
			(
				PDRM.ReconciledType IN(@ReconciledTypeManual)			
				OR 
				(
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @FALSE AND PDRM.SectionType <> @ReconciliationSectionTypePROnly						
					)
					OR
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @TRUE 
					)
				 )
			)	
				AND PDRM.PrId IS NOT NULL

			UNION

			SELECT   
				Pdrm.GstnId,@TRUE,'2a'
			FROM 
				Oregular.Gstr2aDocumentRecoMapper PDRM			
			WHERE 
			(
				PDRM.ReconciledType IN(@ReconciledTypeManual)			
				OR 
				(
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @FALSE AND PDRM.SectionType <> @ReconciliationSectionTypeGstOnly						
					)
					OR
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @TRUE 
					)
				 )
			)	
			AND Pdrm.GstnId IS NOT NULL;						
			
			INSERT INTO #ManualMappingID(PurchaseDocumentId,IsAutopopulated,PreserveType)
			SELECT   
				PDRM.PrId,@FALSE,'2b'
			FROM 
				Oregular.Gstr2bDocumentRecoMapper PDRM			
			WHERE 
			(
				PDRM.ReconciledType IN(@ReconciledTypeManual)			
				OR 
				(
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @FALSE AND PDRM.SectionType <> @ReconciliationSectionTypePROnly
					)
					OR
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @TRUE 						
					)
				 )
			)
			AND PDRM.PrId IS NOT NULL
			UNION
			SELECT   
				Pdrm.GstnId,@TRUE,'2b'
			FROM 
				Oregular.Gstr2bDocumentRecoMapper PDRM			
			WHERE 
			(
				PDRM.ReconciledType IN(@ReconciledTypeManual)			
				OR 
				(
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @FALSE AND PDRM.SectionType <> @ReconciliationSectionTypeGstOnly
					)
					OR
					(
						PDRM.ReconciledType IN (@ReconciledTypeManualSectionChanged, @ReconciledTypeSystemSectionChanged) 
						AND @IsRegeneratePreferenceSectionChange = @TRUE 						
					)
				 )
			)
			AND Pdrm.GstnId IS NOT NULL;			
		END;
		
		IF @IsRegeneratePreference3bClaimedMonth = @TRUE OR @IsRegenerateNow = @FALSE
		BEGIN
			Print 'RecoMain65';			
			INSERT INTO #ManualMappingID(PurchaseDocumentId,IsAutopopulated,PreserveType)
			SELECT  PDR.Id,CASE WHEN pdr.SourceType = 1 THEN @FALSE ELSE @TRUE END,'2b'
			FROM 
				oregular.PurchaseDocuments PDR
			INNER JOIN oregular.PurchaseDocumentStatus pds ON pdr.Id = pds.PurchaseDocumentId
			WHERE 
				PDR.SubscriberId = @SubscriberId
				AND pds.ItcClaimReturnPeriod IS NOT NULL
				AND NOT EXISTS(SELECT 1 FROM #ManualMappingID mmid WHERE PDR.Id = mmid.PurchaseDocumentId);
			Print 'RecoMain66';			
		END;		
	END ;
			
		INSERT INTO #ManualMappingID(PurchaseDocumentId,IsAutopopulated,PreserveType)
		SELECT DISTINCT
			PrId,@FALSE,CASE WHEN PDRMM.ReconciliationType = 8 THEN '2b'	ELSE '2a' END			
		FROM
			oregular.PurchaseDocumentRecoManualMapper PDRMM
			CROSS APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr			
		WHERE
			PDRMM.SubscriberId = @SubscriberId
			--AND PDRMM.ParentEntityId = @ParentEntityId	
			--AND PDRMM.ReconciliationType = 8
		UNION	
		SELECT
			Gst.GstId,@TRUE,CASE WHEN PDRMM.ReconciliationType = 8 THEN '2b'	ELSE '2a' END							
		FROM
			oregular.PurchaseDocumentRecoManualMapper PDRMM
			CROSS APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst				
		WHERE
			PDRMM.SubscriberId = @SubscriberId;
			--AND PDRMM.ParentEntityId = @ParentEntityId	
			--AND PDRMM.ReconciliationType = 8;			

		/*
		Print 'RecoMain68';			
		IF EXISTS (SELECT 1 FROM #ManualMappingID)		
		THEN
			Print 'RecoMain69';			
			DELETE
			FROM #TempPrHeaderData PDR
			USING #ManualMappingID MMID  
			WHERE PDR.Id = MMID.PurchaseDocumentId;
		
			Print 'RecoMain70';			
			DELETE 
			FROM #Temp2bHeaderData PDR
			USING #ManualMappingID MMID  WHERE PDR.Id = MMID.PurchaseDocumentId;			
		
			Print 'RecoMain71';			
			UPDATE Oregular.PurchaseDocumentStatus PDR
				SET IsReconciled = @TRUE
			FROM 
				#ManualMappingID MMID  
			WHERE 
				PDR.PurchaseDocumentId = MMID.PurchaseDocumentId
				AND PDR.IsReconciled = @FALSE;
			
			Print 'RecoMain72';				
		END IF;
		*/
		
		DROP TABLE IF EXISTS #Temp2aExcludedManualMappedID;
		Print 'RecoMain73';				
		SELECT 
			Id,IsAutoPopulated		
		INTO #Temp2aExcludedManualMappedID	
	   	FROM
			#Temp2bHeaderData hd
		WHERE NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE hd.Id = mp.PurchaseDocumentId AND PreserveType = '2a' AND IsAutopopulated = @TRUE)	
		UNION
		SELECT 
			Id,IsAutoPopulated
		FROM
			#TempPrHeaderData hd
		WHERE NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE hd.Id = mp.PurchaseDocumentId AND PreserveType = '2a' AND IsAutopopulated = @FALSE)	
		UNION		
		SELECT 
			Id,
			IsAutoPopulated 
		FROM 
			#TempDeletedIds;

		DROP TABLE IF EXISTS #Temp2bExcludedManualMappedID;
		SELECT 
			Id,IsAutoPopulated					  
		INTO #Temp2bExcludedManualMappedID
	   	FROM
			#Temp2bHeaderData hd
		WHERE NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE hd.Id = mp.PurchaseDocumentId AND PreserveType = '2b' AND IsAutopopulated = @TRUE)		
		UNION
		SELECT 
			Id,IsAutoPopulated
		FROM
			#TempPrHeaderData hd
		WHERE NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE hd.Id = mp.PurchaseDocumentId AND PreserveType = '2b' AND IsAutopopulated = @FALSE)				
		UNION		
		SELECT 
			Id,
			IsAutoPopulated 
		FROM 
			#TempDeletedIds;
		
		Print 'RecoMain74';			
		/*Updating Section to Pr ONLY where Gstin record is in match or mismatch section*/
		UPDATE r_pdrm
		SET GstnId = NULL,
				SectionType = @ReconciliationSectionTypePROnly,
				Reason = NULL,
				ReasonType = NULL,
				PredictableMatchBy = NULL,
				IsCrossHeadTax = @FALSE,
				ReconciledType = @ReconciledTypeSystem ,
				SessionId = @SessionID,					
				ModifiedStamp = GETDATE(),
				GstnReturnPeriodDate = NULL												
		FROM 
			Oregular.Gstr2aDocumentRecoMapper  r_pdrm
			INNER JOIN #Temp2aExcludedManualMappedID t_rpd ON  GstnId = t_rpd.Id
		WHERE 
			r_pdrm.GstnId IS NOT NULL AND r_pdrm.PrId IS NOT NULL
			AND r_pdrm.SectionType <> @ReconciliationSectionTypeGstOnly
			AND t_rpd.IsAutoPopulated = @TRUE
            

		Print 'RecoMain75';			
		/*Deleting data from reco mapper where gstin id is null*/					
		DELETE 
			r_pdrm
		FROM 
			Oregular.Gstr2aDocumentRecoMapper r_pdrm
			INNER JOIN #Temp2aExcludedManualMappedID t_rpd ON r_pdrm.PrId = t_rpd.Id
		WHERE 
			r_pdrm.GstnId IS NULL
			AND t_rpd.IsAutoPopulated = @FALSE;	
						
		/*Deleting data from reco mapper where pr id is null*/
		DELETE 
			r_pdrm
		FROM 
			Oregular.Gstr2aDocumentRecoMapper 	r_pdrm							 
			INNER JOIN #Temp2aExcludedManualMappedID t_rpd  ON r_pdrm.GstnId = t_rpd.Id  									   
		WHERE 
			r_pdrm.PrId IS NULL
			AND t_rpd.IsAutoPopulated = @TRUE		
			;
		
		/*Updating Section to GStONLY where PR record is in match or mismatch section*/
		UPDATE 
			r_pdrm
			SET PrId = NULL,
				SectionType = @ReconciliationSectionTypeGstOnly,
				Reason = NULL,
				ReasonType = NULL,
				IsCrossHeadTax = @FALSE,
				PredictableMatchBy = NULL,
				ReconciledType =  @ReconciledTypeSystem,
				SessionId = @SessionID,
				ModifiedStamp = Getdate(),
				PrReturnPeriodDate = NULL												
		FROM 
			Oregular.Gstr2aDocumentRecoMapper  r_pdrm
			INNER JOIN #Temp2aExcludedManualMappedID t_rpd	ON r_pdrm.PrId = t_rpd.Id 																															
		WHERE 			
			r_pdrm.PrId IS NOT NULL AND r_pdrm.GstnId IS NOT NULL
			AND r_pdrm.SectionType <> @ReconciliationSectionTypePROnly
			AND t_rpd.IsAutoPopulated = @FALSE		;				
		
		/*Update in 2b Document reco Mapper*/
		UPDATE  r_pdrm
			SET GstnId = NULL,
				SectionType = @ReconciliationSectionTypePROnly,
				Reason = NULL,
				ReasonType = NULL,
				PredictableMatchBy = NULL,
				IsCrossHeadTax = @FALSE,
				ReconciledType = @ReconciledTypeSystem ,
				SessionId = @SessionID,					
				ModifiedStamp = GETDATE(),
				Gstr2BReturnPeriodDate = NULL												
		FROM 
			Oregular.Gstr2bDocumentRecoMapper r_pdrm
			INNER JOIN #Temp2bExcludedManualMappedID t_rpd ON r_pdrm.GstnId = t_rpd.Id
		WHERE 
			r_pdrm.GstnId IS NOT NULL AND r_pdrm.PrId IS NOT NULL
			AND r_pdrm.SectionType <> @ReconciliationSectionTypeGstOnly
			AND t_rpd.IsAutoPopulated = @TRUE
            ;			

		Print 'RecoMain79';				
		/*Deleting data from reco mapper where gstin id is null*/					
		DELETE
			r_pdrm
		FROM 
			Oregular.Gstr2bDocumentRecoMapper r_pdrm
			INNER JOIN #Temp2bExcludedManualMappedID t_rpd ON r_pdrm.PrId = t_rpd.Id
		WHERE 
			r_pdrm.GstnId IS NULL
			AND t_rpd.IsAutoPopulated = @FALSE	
			;			
		
		Print 'RecoMain80';			
		/*Deleting data from reco mapper where pr id is null*/
		DELETE 
			r_pdrm
		FROM 
			Oregular.Gstr2bDocumentRecoMapper r_pdrm
			INNER JOIN #Temp2bExcludedManualMappedID t_rpd ON r_pdrm.GstnId = t_rpd.Id   									   
		WHERE 
			r_pdrm.PrId IS NULL
			AND t_rpd.IsAutoPopulated = @TRUE		
			;
		
		Print 'RecoMain81';			
		/*Updating Section to GStONLY where PR record is in match or mismatch section*/
		UPDATE r_pdrm
			SET PrId = NULL,
				SectionType = @ReconciliationSectionTypeGstOnly,
				Reason = NULL,
				ReasonType = NULL,
				IsCrossHeadTax = @FALSE,
				PredictableMatchBy = NULL,
				ReconciledType =  @ReconciledTypeSystem,
				SessionId = @SessionID,
				ModifiedStamp = GETDATE(),
				PrReturnPeriodDate = NULL												
		FROM 
			 Oregular.Gstr2bDocumentRecoMapper r_pdrm
			INNER JOIN #Temp2bExcludedManualMappedID t_rpd	ON r_pdrm.PrId = t_rpd.Id 																															
		WHERE 			
			r_pdrm.PrId IS NOT NULL AND r_pdrm.GstnId IS NOT NULL
			AND r_pdrm.SectionType <> @ReconciliationSectionTypePROnly
			AND t_rpd.IsAutoPopulated = @FALSE		;				
/*	
		IF NOT EXISTS(SELECT 1 FROM TempExcludedManualMappedID) AND NOT EXISTS (SELECT 1 FROM #ManualMappingID)
																																																																									
		THEN 
			RETURN QUERY
			SELECT 															  
				@SubscriberId AS SubscriberId,
				@ParentEntityId AS EntityId,
				@FinancialYear AS FinancialYear			
			WHERE
				1 = 0;
			RETURN;
																		   
		END IF ;
*/		
		--DROP TABLE IF EXISTS TempExcludedManualMappedID,ManualMapperGstnCount,ManualMapperPrCount,TempDeletedIds,TempIncorrectGstnId,#Temp2BUnReconciledIds,TempIncorrectPrId,#TempPrUnReconciledIds;		
		
		/**********************************************************************************************************************************************
																	Till Date
		***********************************************************************************************************************************************/
																				 
			CREATE TABLE #TempPurchaseDocument2a2bRecoMapper(Id INT IDENTITY(1,1), QuerySrNo SMALLINT NOT NULL, DocumentFinancialYear INT NOT NULL, PrId BIGINT NOT NULL, GstnId BIGINT NOT NULL, SectionType smallint NOT NULL, Reason VARCHAR(500) NULL, ReasonType BIGINT NULL, IsAmendment BIT DEFAULT 0, IsCrossHeadTax BIT  NOT NULL,PrReturnPeriodDate date,Gstr2bReturnPeriodDate date,ReturnPeriodDate date,IsAvailableInGstr2b BIT,DocumentType SMALLINT);
			CREATE  INDEX IDX_tempGstr2bDocumentRecoMapperTillDate_Id ON #TempPurchaseDocument2a2bRecoMapper(Id);
			
			INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)
			SELECT 1 AS QuerySrNo, PR.FinancialYear AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GstnId,
					CASE WHEN
							PR.SgstAmount = GSTN.SgstAmount
						AND PR.CgstAmount = GSTN.CgstAmount
						AND PR.IgstAmount = GSTN.IgstAmount
						AND PR.CessAmount = GSTN.CessAmount
						AND (@IsExclude_MatchingCriteria_TaxableValue  = @TRUE OR PR.TotalTaxableValue = GSTN.TotalTaxableValue)
						AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
						AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
								OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
								OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
							)
						AND (@IsExclude_MatchingCriteria_POS		   = @TRUE OR PR.POS = GSTN.POS)
						AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
						AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
						AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
						AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																																												
					THEN @ReconciliationSectionTypeMatched 
					ELSE
						CASE WHEN @IsMatchByTolerance = @TRUE
						THEN
								CASE WHEN (((PR.SgstAmount+PR.CgstAmount) BETWEEN (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsFrom AND (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
								 OR (PR.SgstAmount BETWEEN GSTN.SgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.SgstAmount + @MatchByTolerance_TaxAmountsTo
				   				   AND PR.CgstAmount BETWEEN GSTN.CgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CgstAmount + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
								AND PR.IgstAmount BETWEEN GSTN.IgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.IgstAmount + @MatchByTolerance_TaxAmountsTo
								AND PR.CessAmount BETWEEN GSTN.CessAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CessAmount + @MatchByTolerance_TaxAmountsTo
								AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) <= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) >= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
										OR PR.TotalTaxableValue BETWEEN GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
										OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
										OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
										OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
									)
								AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
								AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
								AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
								AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
								AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
								THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END
						ELSE @ReconciliationSectionTypeMisMatched END END AS ReconciliationType,
				CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN @TRUE ELSE @FALSE END IsCrossHeadTax,
				Pr.ReturnPeriodDate,
				Gstn.Gstr2BReturnPeriodDate,
				GSTN.IsAvailableInGstr2b,
				GSTN.ReturnPeriodDate,
				Pr.DocumentType
			FROM 
				#TempPrHeaderData PR
				INNER JOIN #Temp2bHeaderData GSTN
					ON PR.DocumentType = GSTN.DocumentType
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.Gstin = GSTN.Gstin
					AND PR.PortCode = GSTN.PortCode
					AND PR.DocumentNumber = GSTN.DocumentNumber
					AND PR.FinancialYear = GSTN.FinancialYear
					AND PR.IsAmendment = GSTN.IsAmendment
			WHERE 
				((@IsDiscard_Originals_With_Amendment = @TRUE AND Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL) OR
				(@IsDiscard_Originals_With_Amendment = @FALSE))
				AND (@IsReconcileAtDocumentLevel = @TRUE OR PR.DocumentType = @DocumentTypeBOE);
				
		IF @IsReconcileAtDocumentLevel = @FALSE
		BEGIN	
			INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)
			SELECT 
				1 AS QuerySrNo, MAX(PR.FinancialYear) AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GstnId,
				CASE WHEN COUNT(PRDetails.Id) = MAX(PR.ItemCount)
								   AND COUNT(GSTNDetails.Id) = MAX(GSTN.ItemCount)
								   AND MAX(PR.ItemCount) = MAX(GSTN.ItemCount)
							 THEN 
								CASE WHEN SUM(CASE WHEN (PRDetails.IgstAmount IS NOT NULL AND GSTNDetails.IgstAmount IS NULL)
												OR 
											  (PRDetails.IgstAmount IS NULL AND GSTNDetails.IgstAmount IS NOT NULL)
											  THEN 1 ELSE 0 END) >=1
									 THEN @ReconciliationSectionTypeMisMatched 
									 ELSE 
										 CASE WHEN SUM(CASE WHEN
													COALESCE(PRDetails.SgstAmount,-1) = COALESCE(GSTNDetails.SgstAmount,-1)
												AND COALESCE(PRDetails.CgstAmount,-1) = COALESCE(GSTNDetails.CgstAmount,-1)
												AND COALESCE(PRDetails.IgstAmount,-1) = COALESCE(GSTNDetails.IgstAmount,-1)
												AND COALESCE(PRDetails.CessAmount, 0) = COALESCE(GSTNDetails.CessAmount, 0)													
												AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE OR PRDetails.TaxableValue = GSTNDetails.TaxableValue)
												AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
												AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
														OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
														OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
													)
												AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
												AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
												AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
												AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
												AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR  CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END = GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP)))
											THEN 0 ELSE 1 END
											) =  0 
											THEN  @ReconciliationSectionTypeMatched ELSE
											CASE WHEN @IsMatchByTolerance = @TRUE THEN 												 
												CASE WHEN SUM(CASE WHEN
														(((COALESCE(PRDetails.SgstAmount,-1)+COALESCE(PRDetails.CgstAmount,-1)) BETWEEN (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsFrom AND (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
													  	 OR (COALESCE(PRDetails.SgstAmount,-1) BETWEEN COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
													 	 AND COALESCE(PRDetails.CgstAmount,-1) BETWEEN COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
														AND COALESCE(PRDetails.IgstAmount,-1) BETWEEN COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
														AND COALESCE(PRDetails.CessAmount,0)  BETWEEN COALESCE(GSTNDetails.CessAmount,0)  + @MatchByTolerance_TaxAmountsFrom  AND COALESCE(GSTNDetails.CessAmount,0) + @MatchByTolerance_TaxAmountsTo														
														AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) <= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) >= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
																OR PRDetails.TaxableValue BETWEEN GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
																OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END = GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))
													THEN 0 ELSE 1 END
													) =  0 
													THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END  ELSE @ReconciliationSectionTypeMisMatched END END 
									 END			 
					ELSE @ReconciliationSectionTypeMisMatched END  AS ReconciliationType 
					,
					MAX(CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN 1 ELSE 0 END) IsCrossHeadTax,
					MAX(Pr.ReturnPeriodDate),
					MAX(Gstn.Gstr2BReturnPeriodDate),
					MAX(CAST(IsAvailableInGstr2b AS INT)),
					MAX(GSTN.ReturnPeriodDate),
					MAX(Pr.DocumentType)
			FROM 
				#TempPrHeaderData PR
				INNER JOIN #Temp2bHeaderData GSTN
					ON PR.DocumentType = GSTN.DocumentType
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.Gstin = GSTN.Gstin
					AND PR.DocumentNumber = GSTN.DocumentNumber
					AND PR.FinancialYear = GSTN.FinancialYear
					AND PR.IsAmendment = GSTN.IsAmendment
				INNER JOIN #TempPrPurchaseDocumentRecoItems PRDetails ON PR.Id = PRDetails.PurchaseDocumentRecoId
				LEFT JOIN #Temp2BPurchaseDocumentRecoItems GSTNDetails ON GSTN.Id = GSTNDetails.PurchaseDocumentRecoId AND PRDetails.Rate = GSTNDetails.Rate
			WHERE 
				((@IsDiscard_Originals_With_Amendment = @TRUE AND Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL) OR
				(@IsDiscard_Originals_With_Amendment = @FALSE))
				AND PR.DocumentType <> @DocumentTypeBOE
			GROUP BY PR.Id, GSTN.Id;			
		END;
		
		IF @IsDiscard_Originals_With_Amendment = @TRUE
		BEGIN
			IF @IsReconcileAtDocumentLevel = @TRUE
			BEGIN
				INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsAmendment, IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)
				SELECT 3 AS QuerySrNo, PR.FinancialYear AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GstnId,
					CASE WHEN
							PR.SgstAmount = GSTN.SgstAmount
						AND PR.CgstAmount = GSTN.CgstAmount
						AND PR.IgstAmount = GSTN.IgstAmount
						AND PR.CessAmount = GSTN.CessAmount
						AND (@IsExclude_MatchingCriteria_TaxableValue  = @TRUE OR PR.TotalTaxableValue = GSTN.TotalTaxableValue)
						AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
						AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
								OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
								OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
							)
						AND (@IsExclude_MatchingCriteria_POS		   = @TRUE OR PR.POS = GSTN.POS)
						AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
						AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
						AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
						AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
					THEN @ReconciliationSectionTypeMatched 
					ELSE
						CASE WHEN @IsMatchByTolerance = @TRUE
						THEN
								CASE WHEN (((PR.SgstAmount+PR.CgstAmount) BETWEEN (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsFrom AND (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
								 OR (PR.SgstAmount BETWEEN GSTN.SgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.SgstAmount + @MatchByTolerance_TaxAmountsTo
				   				   AND PR.CgstAmount BETWEEN GSTN.CgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CgstAmount + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
								AND PR.IgstAmount BETWEEN GSTN.IgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.IgstAmount + @MatchByTolerance_TaxAmountsTo
								AND PR.CessAmount BETWEEN GSTN.CessAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CessAmount + @MatchByTolerance_TaxAmountsTo
								AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) <= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) >= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
										OR PR.TotalTaxableValue BETWEEN GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
										OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
										OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
										OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
									)
								AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
								AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
								AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
								AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
								AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
								THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END
						ELSE @ReconciliationSectionTypeMisMatched END END AS ReconciliationType,
						@TRUE AS IsAmendment,
						CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN @TRUE ELSE @FALSE END IsCrossHeadTax,
						Pr.ReturnPeriodDate,
						Gstn.Gstr2BReturnPeriodDate,
						GSTN.IsAvailableInGstr2b,
						GSTN.ReturnPeriodDate,
						Pr.DocumentType
				FROM 
					#TempPrHeaderData PR
					INNER JOIN #Temp2bHeaderData GSTN
				ON PR.DocumentType = GSTN.DocumentType
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.Gstin = GSTN.Gstin
					AND PR.DocumentNumber = GSTN.DocumentNumber
					AND PR.FinancialYear = GSTN.FinancialYear
				WHERE					
					(PR.IsAmendment<>GSTN.IsAmendment)
					AND (Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL)
					AND PR.DocumentType <> @DocumentTypeBOE;
								
				INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsAmendment, IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)				
				SELECT 5 AS QuerySrNo, PR.FinancialYear AS DocumentFinancialYear, PR.Id AS PRID, GSTN.Id AS GSTNID,
					CASE WHEN
							PR.SgstAmount = GSTN.SgstAmount
						AND PR.CgstAmount = GSTN.CgstAmount
						AND PR.IgstAmount = GSTN.IgstAmount
						AND PR.CessAmount = GSTN.CessAmount
						AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE OR PR.TotalTaxableValue = GSTN.TotalTaxableValue)
						AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
						AND (@IsExclude_MatchingCriteria_DocumentDate = @TRUE 
								OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
								OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
							)
						AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
						AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
						AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
						AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
						AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
						THEN 
							@ReconciliationSectionTypeMatched
						ELSE
						CASE WHEN @IsMatchByTolerance = @TRUE
						THEN
								CASE WHEN (((PR.SgstAmount+PR.CgstAmount) BETWEEN (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsFrom AND (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
								 OR (PR.SgstAmount BETWEEN GSTN.SgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.SgstAmount + @MatchByTolerance_TaxAmountsTo
				   				   AND PR.CgstAmount BETWEEN GSTN.CgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CgstAmount + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
								AND PR.IgstAmount BETWEEN GSTN.IgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.IgstAmount + @MatchByTolerance_TaxAmountsTo
								AND PR.CessAmount BETWEEN GSTN.CessAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CessAmount + @MatchByTolerance_TaxAmountsTo
								AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) <= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) >= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
										OR PR.TotalTaxableValue BETWEEN GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
										OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentDate = @TRUE 
										OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
										OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
									)
								AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
								AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
								AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
								AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
								AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
								THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END
						ELSE @ReconciliationSectionTypeMisMatched END END AS ReconciliationType,
						@TRUE AS IsAmendment,
						CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN @TRUE ELSE @FALSE END IsCrossHeadTax,
						Pr.ReturnPeriodDate,
						Gstn.Gstr2BReturnPeriodDate,
						GSTN.IsAvailableInGstr2b,
						GSTN.ReturnPeriodDate,
						Pr.DocumentType
					FROM 
						#TempPrHeaderData PR
					INNER JOIN #Temp2bHeaderData GSTN
					ON PR.DocumentType = GSTN.DocumentType
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.Gstin = GSTN.Gstin
					AND PR.DocumentNumber = GSTN.OriginalDocumentNumber 	
					AND PR.FinancialYear = GSTN.FinancialYear
				WHERE
					(PR.IsAmendment<>GSTN.IsAmendment)
					AND (Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL)
					AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.PrId = Pr.Id)
					AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.GstnId = GSTN.Id)
					AND PR.DocumentType <> @DocumentTypeBOE;
				
				Print 'RecoMain90';
				
				INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsAmendment, IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)				
				SELECT 4 AS QuerySrNo, PR.FinancialYear AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GSTNID,
					CASE WHEN
							PR.SgstAmount = GSTN.SgstAmount
						AND PR.CgstAmount = GSTN.CgstAmount
						AND PR.IgstAmount = GSTN.IgstAmount
						AND PR.CessAmount = GSTN.CessAmount
						AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE OR PR.TotalTaxableValue = GSTN.TotalTaxableValue)
						AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
						AND (@IsExclude_MatchingCriteria_DocumentDate = @TRUE 
								OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
								OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
							)
						AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
						AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
						AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
						AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
						AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
					THEN @ReconciliationSectionTypeMatched
					ELSE
						CASE WHEN @IsMatchByTolerance = @TRUE
						THEN
								CASE WHEN (((PR.SgstAmount+PR.CgstAmount) BETWEEN (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsFrom AND (GSTN.SgstAmount+GSTN.CgstAmount) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
								 OR (PR.SgstAmount BETWEEN GSTN.SgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.SgstAmount + @MatchByTolerance_TaxAmountsTo
				   				   AND PR.CgstAmount BETWEEN GSTN.CgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CgstAmount + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
								AND PR.IgstAmount BETWEEN GSTN.IgstAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.IgstAmount + @MatchByTolerance_TaxAmountsTo
								AND PR.CessAmount BETWEEN GSTN.CessAmount + @MatchByTolerance_TaxAmountsFrom AND GSTN.CessAmount + @MatchByTolerance_TaxAmountsTo
								AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) <= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (PR.SgstAmount+PR.CgstAmount+PR.IgstAmount) >= (GSTN.SgstAmount+GSTN.CgstAmount+GSTN.IgstAmount))
								AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
										OR PR.TotalTaxableValue BETWEEN GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTN.TotalTaxableValue + @MatchByTolerance_TaxableValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
										OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
								AND (@IsExclude_MatchingCriteria_DocumentDate = @TRUE 
										OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
										OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate)= MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
									)
								AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
								AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
								AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
								AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
								AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
								THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END
						ELSE @ReconciliationSectionTypeMisMatched END END AS ReconciliationType,
						@TRUE AS IsAmendment,
						CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN @TRUE ELSE @FALSE END IsCrossHeadTax,
						Pr.ReturnPeriodDate,
						Gstn.Gstr2BReturnPeriodDate,
						GSTN.IsAvailableInGstr2b,
						GSTN.ReturnPeriodDate,
						Pr.DocumentType
					FROM 
						#TempPrHeaderData PR
					INNER JOIN #Temp2bHeaderData GSTN
					ON PR.DocumentType = GSTN.DocumentType
					AND PR.SubscriberId = GSTN.SubscriberId
					AND PR.ParentEntityId = GSTN.ParentEntityId
					AND PR.Gstin = GSTN.Gstin
					AND PR.OriginalDocumentNumber = GSTN.DocumentNumber
					AND PR.FinancialYear = GSTN.FinancialYear
				WHERE
					(PR.IsAmendment<>GSTN.IsAmendment)
					AND (Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL)
					AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.PrId = Pr.Id)
					AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.GstnId = GSTN.Id)
					AND PR.DocumentType <> @DocumentTypeBOE;	
					
					END
				ELSE
					BEGIN	
					INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsAmendment,IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)
					SELECT 3 AS QuerySrNo, MAX(PR.FinancialYear) AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GstnId,
							CASE WHEN COUNT(PRDetails.Id) = MAX(PR.ItemCount)
										   AND COUNT(GSTNDetails.Id) = MAX(GSTN.ItemCount)
										   AND MAX(PR.ItemCount) = MAX(GSTN.ItemCount)
									 THEN 
										CASE WHEN SUM(CASE WHEN (PRDetails.IgstAmount IS NOT NULL AND GSTNDetails.IgstAmount IS NULL)
														OR 
													  (PRDetails.IgstAmount IS NULL AND GSTNDetails.IgstAmount IS NOT NULL)
													  THEN 1 ELSE 0 END) >=1
											 THEN @ReconciliationSectionTypeMisMatched 
											 ELSE 
											  CASE WHEN SUM(CASE WHEN
															COALESCE(PRDetails.SgstAmount,-1) = COALESCE(GSTNDetails.SgstAmount,-1)
														AND COALESCE(PRDetails.CgstAmount,-1) = COALESCE(GSTNDetails.CgstAmount,-1)
														AND COALESCE(PRDetails.IgstAmount,-1) = COALESCE(GSTNDetails.IgstAmount,-1)
														AND COALESCE(PRDetails.CessAmount, 0) = COALESCE(GSTNDetails.CessAmount, 0)														
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE OR PRDetails.TaxableValue = GSTNDetails.TaxableValue)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																																				
													THEN 0 ELSE 1 END
													) =  0 
													THEN @ReconciliationSectionTypeMatched ELSE 	CASE WHEN @IsMatchByTolerance = @TRUE THEN
												 CASE WHEN SUM(CASE WHEN
												     (((COALESCE(PRDetails.SgstAmount,-1)+COALESCE(PRDetails.CgstAmount,-1)) BETWEEN (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsFrom AND (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
															  OR (COALESCE(PRDetails.SgstAmount,-1) BETWEEN COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
															 AND COALESCE(PRDetails.CgstAmount,-1) BETWEEN COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
														AND COALESCE(PRDetails.IgstAmount,-1) BETWEEN COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
														AND COALESCE(PRDetails.CessAmount,0)  BETWEEN COALESCE(GSTNDetails.CessAmount,0)  + @MatchByTolerance_TaxAmountsFrom  AND COALESCE(GSTNDetails.CessAmount,0) + @MatchByTolerance_TaxAmountsTo															
														AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) <= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) >= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
																OR PRDetails.TaxableValue BETWEEN GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
																OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
													THEN 0 ELSE 1 END
													) =  0 
													THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END ELSE @ReconciliationSectionTypeMisMatched END END
											 END			 
							ELSE @ReconciliationSectionTypeMisMatched END  AS ReconciliationType,
									@TRUE AS IsAmendment,
							MAX(CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN 1 ELSE 0 END) IsCrossHeadTax,
							MAX(PR.ReturnPeriodDate),
							MAX(Gstn.Gstr2BReturnPeriodDate),
							MAX(CAST(GSTN.IsAvailableInGstr2b AS INT)),
							MAX(GSTN.ReturnPeriodDate),
							MAX(Pr.DocumentType)
					FROM 
						#TempPrHeaderData PR
						INNER JOIN #Temp2bHeaderData GSTN
							ON PR.DocumentType = GSTN.DocumentType
							AND PR.SubscriberId = GSTN.SubscriberId
							AND PR.ParentEntityId = GSTN.ParentEntityId
							AND PR.Gstin = GSTN.Gstin
							AND (PR.DocumentNumber = GSTN.DocumentNumber)	
							AND PR.FinancialYear = GSTN.FinancialYear
						INNER JOIN #TempPrPurchaseDocumentRecoItems PRDetails ON PR.Id = PRDetails.PurchaseDocumentRecoId
						LEFT JOIN #Temp2BPurchaseDocumentRecoItems GSTNDetails ON GSTN.Id = GSTNDetails.PurchaseDocumentRecoId AND PRDetails.Rate = GSTNDetails.Rate
					WHERE 						
						 PR.IsAmendment <> Gstn.IsAmendment 						
						AND (Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL)
					 	AND PR.DocumentType <> @DocumentTypeBOE
					GROUP BY PR.Id, GSTN.Id;	
					
					Print 'RecoMain83';
					
					INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsAmendment, IsCrossHeadTax, PrReturnPeriodDate, Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)
					SELECT 4 AS QuerySrNo, MAX(PR.FinancialYear) AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GSTNID,
							CASE WHEN COUNT(PRDetails.Id) = MAX(PR.ItemCount)
										   AND COUNT(GSTNDetails.Id) = MAX(GSTN.ItemCount)
										   AND MAX(PR.ItemCount) = MAX(GSTN.ItemCount)
									 THEN 
										CASE WHEN SUM(CASE WHEN (PRDetails.IgstAmount IS NOT NULL AND GSTNDetails.IgstAmount IS NULL)
														OR 
													  (PRDetails.IgstAmount IS NULL AND GSTNDetails.IgstAmount IS NOT NULL)
													  THEN 1 ELSE 0 END) >=1
											 THEN @ReconciliationSectionTypeMisMatched 
											 ELSE 
												 CASE WHEN SUM(CASE WHEN
															COALESCE(PRDetails.SgstAmount,-1) = COALESCE(GSTNDetails.SgstAmount,-1)
														AND COALESCE(PRDetails.CgstAmount,-1) = COALESCE(GSTNDetails.CgstAmount,-1)
														AND COALESCE(PRDetails.IgstAmount,-1) = COALESCE(GSTNDetails.IgstAmount,-1)
														AND COALESCE(PRDetails.CessAmount, 0) = COALESCE(GSTNDetails.CessAmount, 0)														
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE OR PRDetails.TaxableValue = GSTNDetails.TaxableValue)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
													THEN 0 ELSE 1 END
													) =  0 
													 THEN @ReconciliationSectionTypeMatched ELSE 											CASE WHEN @IsMatchByTolerance = @TRUE THEN 												 
												CASE WHEN SUM(CASE WHEN
														(((COALESCE(PRDetails.SgstAmount,-1)+COALESCE(PRDetails.CgstAmount,-1)) BETWEEN (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsFrom AND (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
													  	 OR (COALESCE(PRDetails.SgstAmount,-1) BETWEEN COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
													 	 AND COALESCE(PRDetails.CgstAmount,-1) BETWEEN COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
														AND COALESCE(PRDetails.IgstAmount,-1) BETWEEN COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
														AND COALESCE(PRDetails.CessAmount,0)  BETWEEN COALESCE(GSTNDetails.CessAmount,0)  + @MatchByTolerance_TaxAmountsFrom  AND COALESCE(GSTNDetails.CessAmount,0) + @MatchByTolerance_TaxAmountsTo														
														AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) <= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) >= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
																OR PRDetails.TaxableValue BETWEEN GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
																OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
													THEN 0 ELSE 1 END
													) =  0 
													 THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END ELSE @ReconciliationSectionTypeMisMatched END END
													END			 
													ELSE @ReconciliationSectionTypeMisMatched END  AS ReconciliationType,
									@TRUE AS IsAmendment,
							MAX(CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN 1 ELSE 0 END) IsCrossHeadTax,
							MAX(Pr.ReturnPeriodDate),
							MAX(Gstn.Gstr2BReturnPeriodDate),
							MAX(CAST(GSTN.IsAvailableInGstr2b AS INT)),
							MAX(GSTN.ReturnPeriodDate),
							MAX(Pr.DocumentType)
						FROM #TempPrHeaderData PR
					INNER JOIN #Temp2bHeaderData GSTN
						ON PR.DocumentType = GSTN.DocumentType
						AND PR.SubscriberId = GSTN.SubscriberId
						AND PR.ParentEntityId = GSTN.ParentEntityId
						AND PR.Gstin = GSTN.Gstin
						AND (PR.OriginalDocumentNumber = GSTN.DocumentNumber)	
						AND PR.FinancialYear = GSTN.FinancialYear
					INNER JOIN #TempPrPurchaseDocumentRecoItems PRDetails ON PR.Id = PRDetails.PurchaseDocumentRecoId
					LEFT JOIN #Temp2BPurchaseDocumentRecoItems GSTNDetails ON GSTN.Id = GSTNDetails.PurchaseDocumentRecoId AND PRDetails.Rate = GSTNDetails.Rate
					WHERE 						
						 PR.IsAmendment <> Gstn.IsAmendment						
						 AND (Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL)
						 AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.PrId = Pr.Id)
						 AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.GstnId = GSTN.Id)
					 	 AND PR.DocumentType <> @DocumentTypeBOE
					GROUP BY PR.Id, GSTN.Id;	

					Print 'RecoMain84';
					INSERT INTO #TempPurchaseDocument2a2bRecoMapper(QuerySrNo, DocumentFinancialYear, PrId, GstnId, SectionType, IsAmendment,IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate,IsAvailableInGstr2b,ReturnPeriodDate,DocumentType)
					SELECT 5 AS QuerySrNo, MAX(PR.FinancialYear) AS DocumentFinancialYear, PR.Id AS PrId, GSTN.Id AS GSTNID,
							CASE WHEN COUNT(PRDetails.Id) = MAX(PR.ItemCount)
										   AND COUNT(GSTNDetails.Id) = MAX(GSTN.ItemCount)
										   AND MAX(PR.ItemCount) = MAX(GSTN.ItemCount)
									 THEN 
										CASE WHEN SUM(CASE WHEN (PRDetails.IgstAmount IS NOT NULL AND GSTNDetails.IgstAmount IS NULL)
														OR 
													  (PRDetails.IgstAmount IS NULL AND GSTNDetails.IgstAmount IS NOT NULL)
													  THEN 1 ELSE 0 END) >=1
											 THEN @ReconciliationSectionTypeMisMatched 
											 ELSE 
												 CASE WHEN SUM(CASE WHEN
															COALESCE(PRDetails.SgstAmount,-1) = COALESCE(GSTNDetails.SgstAmount,-1)
														AND COALESCE(PRDetails.CgstAmount,-1) = COALESCE(GSTNDetails.CgstAmount,-1)
														AND COALESCE(PRDetails.IgstAmount,-1) = COALESCE(GSTNDetails.IgstAmount,-1)
														AND COALESCE(PRDetails.CessAmount, 0) = COALESCE(GSTNDetails.CessAmount, 0)														
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE OR PRDetails.TaxableValue = GSTNDetails.TaxableValue)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE OR PR.Value = GSTN.Value)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
													THEN 0 ELSE 1 END
													) =  0 
													THEN @ReconciliationSectionTypeMatched ELSE 											CASE WHEN @IsMatchByTolerance = @TRUE THEN 												 
												CASE WHEN SUM(CASE WHEN
														(((COALESCE(PRDetails.SgstAmount,-1)+COALESCE(PRDetails.CgstAmount,-1)) BETWEEN (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsFrom AND (COALESCE(GSTNDetails.SgstAmount,-1)+COALESCE(GSTNDetails.CgstAmount,-1)) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @FALSE) 
													  	 OR (COALESCE(PRDetails.SgstAmount,-1) BETWEEN COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.SgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
													 	 AND COALESCE(PRDetails.CgstAmount,-1) BETWEEN COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.CgstAmount,-1) + @MatchByTolerance_TaxAmountsTo AND @IsCgstSgstAmountNotSumForTolerance = @TRUE))									     									
														AND COALESCE(PRDetails.IgstAmount,-1) BETWEEN COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsFrom AND COALESCE(GSTNDetails.IgstAmount,-1) + @MatchByTolerance_TaxAmountsTo
														AND COALESCE(PRDetails.CessAmount,0)  BETWEEN COALESCE(GSTNDetails.CessAmount,0)  + @MatchByTolerance_TaxAmountsFrom  AND COALESCE(GSTNDetails.CessAmount,0) + @MatchByTolerance_TaxAmountsTo														
														AND (@IfPrTaxAmountIsLessThanCpTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) <= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IfCpTaxAmountIsLessThanPrTaxAmount = @FALSE OR (COALESCE(PR.SgstAmount,0)+COALESCE(PR.CgstAmount,0)+COALESCE(PR.IgstAmount,0)) >= (COALESCE(GSTN.SgstAmount,0)+COALESCE(GSTN.CgstAmount,0)+COALESCE(GSTN.IgstAmount,0)))
														AND (@IsExclude_MatchingCriteria_TaxableValue = @TRUE 
																OR PRDetails.TaxableValue BETWEEN GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueFrom AND GSTNDetails.TaxableValue + @MatchByTolerance_TaxableValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentValue = @TRUE 
																OR PR.Value BETWEEN GSTN.Value + @MatchByTolerance_DocumentValueFrom AND GSTN.Value + @MatchByTolerance_DocumentValueTo)
														AND (@IsExclude_MatchingCriteria_DocumentDate  = @TRUE 
																OR (@IsMatchOnDateDifference = @FALSE AND PR.DocumentDate = GSTN.DocumentDate)
																OR (@IsMatchOnDateDifference = @TRUE AND MONTH(PR.DocumentDate) = MONTH(GSTN.DocumentDate) AND YEAR(PR.DocumentDate) = YEAR(GSTN.DocumentDate))
															)
														AND (@IsExclude_MatchingCriteria_POS = @TRUE OR PR.POS = GSTN.POS)
														AND (@IsExclude_MatchingCriteria_ReverseCharge = @TRUE OR PR.ReverseCharge = GSTN.ReverseCharge)
														AND (@IsExcludeMatchingCriteria_Irn = @TRUE OR PR.Irn = GSTN.Irn)
														AND (@IsMismatchIfDocNumberDifferentAfterAmendment = @FALSE OR PR.DocumentNumber = GSTN.DocumentNumber)
														AND (@IsExclude_MatchingCriteria_TransactionType = @TRUE OR (CASE WHEN PR.TransactionType = @TransactionTypeIMPS THEN @TransactionTypeB2B ELSE PR.TransactionType END= GSTN.TransactionType OR (Pr.TransactionType = @TransactionTypeIMPS AND GSTN.TransactionType IN (@TransactionTypeSEZWP,@TransactionTypeSEZWOP))))																						
													THEN 0 ELSE 1 END
													) =  0 
													THEN @ReconciliationSectionTypeMatchedDueToTolerance ELSE @ReconciliationSectionTypeMisMatched END ELSE @ReconciliationSectionTypeMisMatched END END 
													END			 
													ELSE @ReconciliationSectionTypeMisMatched END  AS ReconciliationType,
									@TRUE AS IsAmendment,
							MAX(CASE WHEN PR.SupplyType <> Gstn.SupplyType THEN 1 ELSE 0 END) IsCrossHeadTax,
							MAX(Pr.ReturnPeriodDate),
							MAX(Gstn.Gstr2BReturnPeriodDate),
							MAX(CAST(GSTN.IsAvailableInGstr2b AS INT)),
							MAX(GSTN.ReturnPeriodDate),
							MAX(Pr.DocumentType)
						FROM #TempPrHeaderData PR
					INNER JOIN #Temp2bHeaderData GSTN
						ON PR.DocumentType = GSTN.DocumentType
						AND PR.SubscriberId = GSTN.SubscriberId
						AND PR.ParentEntityId = GSTN.ParentEntityId
						AND PR.Gstin = GSTN.Gstin
						AND (PR.DocumentNumber = GSTN.OriginalDocumentNumber)	
						AND PR.FinancialYear = GSTN.FinancialYear
					INNER JOIN #TempPrPurchaseDocumentRecoItems PRDetails ON PR.Id = PRDetails.PurchaseDocumentRecoId
					LEFT JOIN #Temp2BPurchaseDocumentRecoItems GSTNDetails ON GSTN.Id = GSTNDetails.PurchaseDocumentRecoId AND PRDetails.Rate = GSTNDetails.Rate
					WHERE 						
						 PR.IsAmendment <> Gstn.IsAmendment 						
					 	 AND PR.DocumentType <> @DocumentTypeBOE
						 AND (Pr.PurchaseDocumentRecoId IS NULL AND GSTN.PurchaseDocumentRecoId IS NULL)
						 AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.PrId = Pr.Id)
						 AND NOT EXISTS (SELECT * FROM #TempPurchaseDocument2a2bRecoMapper t WHERE t.GstnId = GSTN.Id)
					GROUP BY PR.Id, GSTN.Id;				
			END;
		END;  

		IF @IsDiscard_Originals_With_Amendment = @TRUE
		BEGIN 	
			DELETE 
				IsAmendment_0
			FROM 
				#TempPurchaseDocument2a2bRecoMapper AS IsAmendment_0
				INNER JOIN #TempPurchaseDocument2a2bRecoMapper AS IsAmendment_1  ON IsAmendment_0.PrId = IsAmendment_1.PrId
			WHERE 
				IsAmendment_1.IsAmendment = @TRUE 
				AND IsAmendment_0.IsAmendment = @FALSE 
				;
		
			Print 'RecoMain88';
			DELETE 
				IsAmendment_0
			FROM 
				#TempPurchaseDocument2a2bRecoMapper AS IsAmendment_0
				INNER JOIN #TempPurchaseDocument2a2bRecoMapper AS IsAmendment_1  ON IsAmendment_0.GstnId = IsAmendment_1.GstnId
			WHERE 
				IsAmendment_1.IsAmendment = @TRUE 
				AND IsAmendment_0.IsAmendment = @FALSE ;

			Print 'RecoMain89';
			DELETE 
				IsAmendment_0
			FROM 
				#TempPurchaseDocument2a2bRecoMapper AS IsAmendment_0
				INNER JOIN  #TempPurchaseDocument2a2bRecoMapper AS IsAmendment_1  ON IsAmendment_0.PrId = IsAmendment_1.PrId AND IsAmendment_0.GstnId = IsAmendment_1.GstnId
			WHERE 
				IsAmendment_1.Id <> IsAmendment_0.Id;								
		END;
		
		DECLARE @MatchMismatchIDs AS Oregular.[MatchMismatchIDs];
		
		INSERT INTO @MatchMismatchIDs(PrId, GstnId, ReconciliationType, MappingType)			
			SELECT PrId, GstnId, SectionType, 4 AS MappingType FROM #TempPurchaseDocument2a2bRecoMapper WHERE SectionType IN(4, 5);
		
		DROP TABLE IF EXISTS #Reason;
		CREATE TABLE #Reason(Id INT IDENTITY, PrId BIGINT NOT NULL, GstnId BIGINT NOT NULL, ReconciliationType SMALLINT NOT NULL, MappingType SMALLINT NOT NULL, Reason VARCHAR(500), ReasonType BIGINT);
		
		INSERT INTO #Reason(PrId, GstnId, ReconciliationType, MappingType, Reason, ReasonType)
		EXEC oregular.GetGstr2bDocumentMatchMisMatchReason				
				@MatchMismatchIDs = @MatchMismatchIDs,
				@IsReconcileAtDocumentLevel = @IsReconcileAtDocumentLevel,
				@IsExclude_MatchingCriteria_Irn = @IsExcludeMatchingCriteria_Irn,
				@IsExclude_MatchingCriteria_POS = @IsExclude_MatchingCriteria_POS,
				@IsExclude_MatchingCriteria_HSN = @IsExclude_MatchingCriteria_HSN,
				@IsExclude_MatchingCriteria_Rate = @IsExclude_MatchingCriteria_Rate,
				@IsExclude_MatchingCriteria_ReverseCharge = @IsExclude_MatchingCriteria_ReverseCharge,
				@IsExclude_MatchingCriteria_DocumentValue = @IsExclude_MatchingCriteria_DocumentValue,
				@IsExclude_MatchingCriteria_TaxableValue = @IsExclude_MatchingCriteria_TaxableValue,
				@IsExclude_MatchingCriteria_DocumentDate = @IsExclude_MatchingCriteria_DocumentDate,
				@IsMismatchIfDocNumberDifferentAfterAmendment = @IsMismatchIfDocNumberDifferentAfterAmendment,
				@TransactionTypeIMPS = @TransactionTypeIMPS,
				@TransactionTypeB2B = @TransactionTypeB2B ,
				@TransactionTypeSEZWP = @TransactionTypeSEZWP ,
				@TransactionTypeSEZWOP =  @TransactionTypeSEZWOP ;
				
		UPDATE 
			M
			SET Reason = R.Reason,
				ReasonType = R.ReasonType
		FROM
			#TempPurchaseDocument2a2bRecoMapper M
			INNER JOIN #Reason R ON  M.PrId = R.PrId
			AND M.GstnId = R.GstnId
		WHERE 
			M.SectionType = R.ReconciliationType;

		/**********************************************************************************************************************************************
																	Till Date
		***********************************************************************************************************************************************/
			DROP TABLE IF EXISTS #TempPurchaseDocument2aRecoMapper;			
			SELECT 
				* 
			INTO #TempPurchaseDocument2aRecoMapper
			FROM 			
				 #TempPurchaseDocument2a2bRecoMapper tpa
			 WHERE 
			 	NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE tpa.PrId = mp.PurchaseDocumentId AND IsAutopopulated = @FALSE AND PreserveType = '2a')
				AND NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE tpa.GstnId = mp.PurchaseDocumentId AND IsAutopopulated = @TRUE AND PreserveType = '2a');
			
			DELETE 
				r_pdrm
			FROM 
				Oregular.Gstr2aDocumentRecoMapper r_pdrm
				INNER JOIN #TempPurchaseDocument2aRecoMapper  t_pdrm
			ON 
				r_pdrm.PrId = t_pdrm.PrId
				AND r_pdrm.GstnId = t_pdrm.GstnId;
						
			
			DELETE 									
				r_pdrm 
			FROM 
				Oregular.Gstr2aDocumentRecoMapper r_pdrm 
				INNER JOIN #TempPurchaseDocument2aRecoMapper t_pdrm ON r_pdrm.PrId = t_pdrm.PrId
			WHERE 
				r_pdrm.GstnId IS NULL;					
			
			DELETE 								 
				r_pdrm
			FROM 
				Oregular.Gstr2aDocumentRecoMapper r_pdrm
				INNER JOIN  #TempPurchaseDocument2aRecoMapper t_pdrm ON  r_pdrm.GstnId = t_pdrm.GstnId
			WHERE
				 r_pdrm.PrId IS NULL;
						
			UPDATE 
				gPDRM 
			SET 
				PrId = NULL,
				SectionType = CASE WHEN @IsDiscard_Originals_With_Amendment = @TRUE AND GSTN.PurchaseDocumentRecoId IS NOT NULL THEN @ReconciliationSectionTypeGstDiscarded ELSE @ReconciliationSectionTypeGstOnly END,
				Reason = NULL,
				ReasonType = NULL,
				SessionId = @SessionID,
				PredictableMatchBy = NULL,
				ReconciledType = @ReconciledTypeSystem,	
				ModifiedStamp = GETDATE(),
				IsCrossHeadTax = @FALSE,
				PrReturnPeriodDate = NULL			   
			FROM
				Oregular.Gstr2aDocumentRecoMapper gPDRM 
				INNER JOIN #TempPurchaseDocument2aRecoMapper tPDRM
					ON gPDRM.PrId = tPDRM.PrId
				INNER JOIN #Temp2bHeaderData GSTN
					ON GSTN.Id = gPDRM.GstnId 
				WHERE
					gPDRM.GstnId IS NOT NULL 
			
			UPDATE PDRM
				SET GstnId = NULL,
					SectionType = CASE WHEN @IsDiscard_Originals_With_Amendment=@TRUE 
					AND PR.PurchaseDocumentRecoId IS NOT NULL 
					THEN @ReconciliationSectionTypePRDiscarded 
					ELSE @ReconciliationSectionTypePROnly END,
					Reason = NULL,
					ReasonType = NULL,
					SessionId = @SessionID,
					PredictableMatchBy = NULL,					
					ReconciledType = @ReconciledTypeSystem,	
					Stamp = GETDATE(),
					ModifiedStamp = GETDATE(),
					IsCrossHeadTax = @FALSE,
					GstnReturnPeriodDate = NULL				   
			FROM 
				Oregular.Gstr2aDocumentRecoMapper PDRM
				INNER JOIN #TempPurchaseDocument2aRecoMapper tPDRM
					ON PDRM.GstnId = tPDRM.GstnId
				INNER JOIN #TempPrHeaderData PR
					ON PR.Id = PDRM.PrId
			WHERE 
				PDRM.PrId IS NOT NULL;				

			INSERT INTO Oregular.Gstr2aDocumentRecoMapper(DocumentFinancialYear, PrId, GstnId, SectionType, MappingType, Reason, ReasonType, SessionId,IsCrossHeadTax,IsAvailableInGstr2b,PrReturnPeriodDate,GstnReturnPeriodDate)
			SELECT DocumentFinancialYear, PrId, GstnId, SectionType, @ReconciliationMappingTypeTillDate AS MappingType, Reason, ReasonType, @SessionID, IsCrossHeadTax,IsAvailableInGstr2b,PrReturnPeriodDate,ReturnPeriodDate
			FROM #TempPurchaseDocument2aRecoMapper t_pdrm;
			
			Print 'RecoMain100';
			INSERT INTO Oregular.Gstr2aDocumentRecoMapper(DocumentFinancialYear, PrId, GstnId, SectionType, MappingType, Reason, ReasonType, SessionId,PrReturnPeriodDate,GstnReturnPeriodDate)
			SELECT PR.FinancialYear AS DocumentFinancialYear, PR.Id AS PrId, NULL GstnId, CASE WHEN @IsDiscard_Originals_With_Amendment=@TRUE AND PR.PurchaseDocumentRecoId IS NOT NULL THEN @ReconciliationSectionTypePRDiscarded ELSE @ReconciliationSectionTypePROnly END  AS SectionType, @ReconciliationMappingTypeTillDate AS MappingType,NULL Reason, NULL ReasonType, @SessionID,ReturnPeriodDate,NULL
			FROM #TempPrHeaderData PR
			WHERE 
				NOT EXISTS(SELECT 1 FROM #TempPurchaseDocument2aRecoMapper t_pdrm WHERE t_pdrm.PrId = PR.Id)	
			 	AND NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE pr.Id = mp.PurchaseDocumentId AND IsAutopopulated = @FALSE AND PreserveType = '2a');								

			INSERT INTO Oregular.Gstr2aDocumentRecoMapper(DocumentFinancialYear, PrId, GstnId, SectionType, MappingType, Reason, ReasonType, SessionId,IsAvailableInGstr2b,PrReturnPeriodDate,GstnReturnPeriodDate)
			SELECT GSTN.FinancialYear AS DocumentFinancialYear, NULL AS PrId, GSTN.Id AS GstnId, CASE WHEN @IsDiscard_Originals_With_Amendment=@TRUE AND GSTN.PurchaseDocumentRecoId IS NOT NULL THEN @ReconciliationSectionTypeGstDiscarded ELSE @ReconciliationSectionTypeGstOnly END AS SectionType, @ReconciliationMappingTypeTillDate AS MappingType,NULL Reason, NULL ReasonType, @SessionID,IsAvailableInGstr2b,NULL,ReturnPeriodDate
			FROM #Temp2bHeaderData GSTN
			WHERE 
				NOT EXISTS(SELECT 1 FROM #TempPurchaseDocument2a2bRecoMapper t_pdrm WHERE t_pdrm.GstnId = GSTN.Id)
				AND NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE GSTN.Id = mp.PurchaseDocumentId AND IsAutopopulated = @TRUE AND PreserveType = '2a');
			
			/*Insert 2b Documents*/
			DROP TABLE IF EXISTS #TempPurchaseDocument2bRecoMapper;				
			SELECT 
				temp.*
			INTO #TempPurchaseDocument2bRecoMapper
			FROM 
				#TempPurchaseDocument2a2bRecoMapper temp
			WHERE 
				IsAvailableInGstr2b = @TRUE AND DocumentType <> @DocumentTypeBOE
				AND NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE temp.GstnId = mp.PurchaseDocumentId AND IsAutopopulated = @TRUE AND PreserveType = '2b')
				AND  NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE temp.PrId = mp.PurchaseDocumentId AND IsAutopopulated = @FALSE AND PreserveType = '2b');
			
			DELETE 
				r_pdrm
			FROM 
				Oregular.Gstr2bDocumentRecoMapper r_pdrm
				INNER JOIN #TempPurchaseDocument2bRecoMapper  t_pdrm
			ON 
				r_pdrm.PrId = t_pdrm.PrId
				AND r_pdrm.GstnId = t_pdrm.GstnId;

			DELETE 									
				r_pdrm 
			FROM 
				Oregular.Gstr2bDocumentRecoMapper r_pdrm 
				INNER JOIN #TempPurchaseDocument2bRecoMapper t_pdrm ON  r_pdrm.PrId = t_pdrm.PrId
			WHERE 
				r_pdrm.GstnId IS NULL;
			
			DELETE 								 
				r_pdrm
			FROM 
				Oregular.Gstr2bDocumentRecoMapper r_pdrm
				INNER JOIN  #TempPurchaseDocument2bRecoMapper t_pdrm ON r_pdrm.GstnId = t_pdrm.GstnId
			WHERE
				 r_pdrm.PrId IS NULL;				 
			
			UPDATE PDRM 
				SET PrId = NULL,
					SectionType = CASE WHEN @IsDiscard_Originals_With_Amendment = @TRUE AND GSTN.PurchaseDocumentRecoId IS NOT NULL THEN @ReconciliationSectionTypeGstDiscarded ELSE @ReconciliationSectionTypeGstOnly END,
					Reason = NULL,
					ReasonType = NULL,
					SessionId = @SessionID,
					PredictableMatchBy = NULL,
					ReconciledType = @ReconciledTypeSystem,	
					ModifiedStamp = GETDATE(),
					IsCrossHeadTax = @FALSE,
					PrReturnPeriodDate = NULL			   
			FROM 
				Oregular.Gstr2bDocumentRecoMapper PDRM
				INNER JOIN #TempPurchaseDocument2bRecoMapper tPDRM
					ON PDRM.PrId = tPDRM.PrId
				INNER JOIN #Temp2bHeaderData GSTN
					ON GSTN.Id = PDRM.GstnId 
				WHERE
					PDRM.GstnId IS NOT NULL; 
				
			UPDATE 
				PDRM
				SET GstnId = NULL,
					SectionType = CASE WHEN @IsDiscard_Originals_With_Amendment=@TRUE 
											AND PR.PurchaseDocumentRecoId IS NOT NULL 
										 THEN @ReconciliationSectionTypePRDiscarded 
										 ELSE @ReconciliationSectionTypePROnly END,
					Reason = NULL,
					ReasonType = NULL,
					SessionId = @SessionID,
					PredictableMatchBy = NULL,					
					ReconciledType = @ReconciledTypeSystem,	
					Stamp = GETDATE(),
					ModifiedStamp = GETDATE(),
					IsCrossHeadTax = @FALSE,
					Gstr2BReturnPeriodDate = NULL				   
			FROM 
				Oregular.Gstr2bDocumentRecoMapper PDRM
				INNER JOIN #TempPurchaseDocument2bRecoMapper tPDRM
					ON PDRM.GstnId = tPDRM.GstnId
				INNER JOIN #TempPrHeaderData PR
					ON PR.Id = PDRM.PrId
			WHERE 
				PDRM.PrId IS NOT NULL;				
					
			INSERT INTO Oregular.Gstr2bDocumentRecoMapper(DocumentFinancialYear, PrId, GstnId, SectionType, MappingType, Reason, ReasonType, SessionId,IsCrossHeadTax,PrReturnPeriodDate,Gstr2BReturnPeriodDate)
			SELECT DocumentFinancialYear, PrId, GstnId, SectionType, @ReconciliationMappingTypeTillDate AS MappingType, Reason, ReasonType, @SessionID, IsCrossHeadTax,PrReturnPeriodDate,Gstr2bReturnPeriodDate
			FROM #TempPurchaseDocument2bRecoMapper t_pdrm;
			
			INSERT INTO Oregular.Gstr2bDocumentRecoMapper(DocumentFinancialYear, PrId, GstnId, SectionType, MappingType, Reason, ReasonType, SessionId,PrReturnPeriodDate,Gstr2BReturnPeriodDate)
			SELECT PR.FinancialYear AS DocumentFinancialYear, PR.Id AS PrId, NULL GstnId, CASE WHEN @IsDiscard_Originals_With_Amendment=@TRUE AND PR.PurchaseDocumentRecoId IS NOT NULL THEN @ReconciliationSectionTypePRDiscarded ELSE @ReconciliationSectionTypePROnly END  AS SectionType, @ReconciliationMappingTypeTillDate AS MappingType,NULL Reason, NULL ReasonType, @SessionID,ReturnPeriodDate,NULL
			FROM #TempPrHeaderData PR
			WHERE 
				NOT EXISTS(SELECT 1 FROM #TempPurchaseDocument2bRecoMapper t_pdrm WHERE t_pdrm.PrId = PR.Id)
				AND DocumentType <> @DocumentTypeBOE
				AND  NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE Pr.Id = mp.PurchaseDocumentId AND IsAutopopulated = @FALSE AND PreserveType = '2b');

			Print 'RecoMain110';
			INSERT INTO Oregular.Gstr2bDocumentRecoMapper(DocumentFinancialYear, PrId, GstnId, SectionType, MappingType, Reason, ReasonType, SessionId,Gstr2BReturnPeriodDate)
			SELECT GSTN.FinancialYear AS DocumentFinancialYear, NULL AS PrId, GSTN.Id AS GstnId, CASE WHEN @IsDiscard_Originals_With_Amendment=@TRUE AND GSTN.PurchaseDocumentRecoId IS NOT NULL THEN @ReconciliationSectionTypeGstDiscarded ELSE @ReconciliationSectionTypeGstOnly END AS SectionType, @ReconciliationMappingTypeTillDate AS MappingType,NULL Reason, NULL ReasonType, @SessionID,Gstr2BReturnPeriodDate
			FROM #Temp2bHeaderData GSTN
			WHERE 
				NOT EXISTS(SELECT 1 FROM #TempPurchaseDocument2bRecoMapper t_pdrm WHERE t_pdrm.GstnId = GSTN.Id)
				AND GSTN.IsAvailableInGstr2b = @TRUE
				AND DocumentType <> @DocumentTypeBOE
				AND NOT EXISTS (SELECT 1 FROM #ManualMappingID mp WHERE Gstn.Id = mp.PurchaseDocumentId AND IsAutopopulated = @TRUE AND PreserveType = '2b');				
			
		 	UPDATE pdr 
			SET 
				IsReconciled = @TRUE
			FROM
				oregular.PurchaseDocumentStatus pdr 
				INNER JOIN #Temp2bHeaderData tu ON  pdr.PurchaseDocumentId = tu.Id
			WHERE pdr.IsReconciled = @FALSE;
		
			UPDATE pdr  
			SET IsReconciled = @TRUE
			FROM
				oregular.PurchaseDocumentStatus pdr
				INNER JOIN #TempPrHeaderData tu ON pdr.PurchaseDocumentId = tu.Id
			WHERE pdr.IsReconciled = @FALSE;

		--DROP TABLE IF  EXISTS #TempPurchaseDocument2a2bRecoMapper,#TempPurchaseDocument2bRecoMapper;
		IF @AdvanceNearMatchPoweredByAI = @TRUE
		BEGIN
			Print 'RecoMain114';
			EXEC oregular.InsertPurchaseDocumentRecoAi2a		
				@ParentEntityId = @ParentEntityId,  
				@FinancialYear = @FinancialYear,  
				@SubscriberId = @SubscriberId,   
				@SessionID = @SessionID,  
				@TransactionTypeIMPS = @TransactionTypeIMPS,  
				@TransactionTypeB2B = @TransactionTypeB2B,  
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,  
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP ,
				@DocumentTypeINV = @DocumentTypeINV,
			    @DocumentTypeDBN = @DocumentTypeDBN,
			    @DocumentTypeCRN = @DocumentTypeCRN,
			    @DocumentTypeBOE = 4 ,
				@IsNearMatchTolerance = @IsNearMatchTolerance,
				@NearMatchTolerance_TaxAmounts = @NearMatchTolerance_TaxAmounts,
				@IfPrTaxAmountIsLessThanCpTaxAmount = @IfPrTaxAmountIsLessThanCpTaxAmount,
				@IfCpTaxAmountIsLessThanPrTaxAmount = @IfCpTaxAmountIsLessThanPrTaxAmount,
				@ReconciledTypeSystemSectionChanged = @ReconciledTypeSystemSectionChanged, 
				@ReconciledTypeManualSectionChanged = @ReconciledTypeManualSectionChanged,
				@ReconciledTypeManual = @ReconciledTypeManual,
				@ReconciliationTypeGstr2b = 8,
				@SourceTypeCounterPartyFiled  =@SourceTypeCounterPartyFiled,
				@SourceTypeCounterPartyNotFiled =@SourceTypeCounterPartyFiled

			
			EXEC oregular.InsertPurchaseDocumentRecoAi2b
				@ParentEntityId = @ParentEntityId,  
				@FinancialYear = @FinancialYear,  
				@SubscriberId = @SubscriberId,   
				@SessionID = @SessionID,  
				@TransactionTypeIMPS = @TransactionTypeIMPS,  
				@TransactionTypeB2B = @TransactionTypeB2B,  
				@TransactionTypeSEZWP = @TransactionTypeSEZWP,  
				@TransactionTypeSEZWOP = @TransactionTypeSEZWOP ,
				@DocumentTypeINV = @DocumentTypeINV,
			    @DocumentTypeDBN = @DocumentTypeDBN,
			    @DocumentTypeCRN = @DocumentTypeCRN,
			    @DocumentTypeBOE = 4,
				@IsNearMatchTolerance = @IsNearMatchTolerance,
				@NearMatchTolerance_TaxAmounts = @NearMatchTolerance_TaxAmounts,
				@IfPrTaxAmountIsLessThanCpTaxAmount = @IfPrTaxAmountIsLessThanCpTaxAmount,
				@IfCpTaxAmountIsLessThanPrTaxAmount = @IfCpTaxAmountIsLessThanPrTaxAmount,
				@ReconciledTypeSystemSectionChanged = @ReconciledTypeSystemSectionChanged, 
				@ReconciledTypeManualSectionChanged = @ReconciledTypeManualSectionChanged,
				@ReconciledTypeManual = @ReconciledTypeManual,
				@ReconciliationTypeGstr2b = 8
		END;
		
		/*To revert actions incase setting is @FALSE and there is mismatch in action */
		
		IF (@IsRegenerateNow = @TRUE AND @IsRegeneratePreference = @FALSE)
		BEGIN	
			DROP TABLE IF  EXISTS #TempRevertActions;			
			SELECT 
				PrId Id  
			INTO #TempRevertActions
			FROM 
				Oregular.Gstr2aDocumentRecoMapper PDRM
				INNER JOIN oregular.PurchaseDocumentStatus  PR ON PDRM.PrId = PR.PurchaseDocumentId
				INNER JOIN oregular.PurchaseDocumentStatus  GSTN ON PDRM.GstnId = GSTN.PurchaseDocumentId
			WHERE 
				SessionId = @SessionID
				AND PDRM.SectionType IN (@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance, @ReconciliationSectionTypeMisMatched, @ReconciliationSectionTypeNearMatched)
				AND PR.Gstr2bAction <> GSTN.Gstr2bAction 
			UNION
			SELECT 
				GstnId
			FROM 
				Oregular.Gstr2aDocumentRecoMapper PDRM
				INNER JOIN oregular.PurchaseDocumentStatus  PR ON PDRM.PrId = PR.PurchaseDocumentId
				INNER JOIN oregular.PurchaseDocumentStatus  GSTN ON PDRM.GstnId = GSTN.PurchaseDocumentId
			WHERE 
				SessionId = @SessionID
				AND PDRM.SectionType IN (@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance, @ReconciliationSectionTypeMisMatched, @ReconciliationSectionTypeNearMatched)
				AND PR.Gstr2bAction <> GSTN.Gstr2bAction ;

			Update	oregular.PurchaseDocumentStatus 
			 SET Gstr2bAction = @ActionTypeNoAction
			FROM 
				#TempRevertActions TRA
			WHERE TRA.Id = PurchaseDocumentId;									
			DROP  TABLE if exists  TempRevertActions;
		END;	
			
			/*whether to include */	
		UPDATE o_pdr_cr
			SET ItcClaimReturnPeriod = o_pdr_pr.ItcClaimReturnPeriod
		FROM
			Oregular.Gstr2bDocumentRecoMapper o_pdrm
			INNER JOIN Oregular.PurchaseDocumentStatus o_pdr_pr ON o_pdrm.PrId = o_pdr_pr.PurchaseDocumentId
			INNER JOIN Oregular.PurchaseDocumentStatus o_pdr_cr ON o_pdrm.GstnId = o_pdr_cr.PurchaseDocumentId
		WHERE				
			o_pdrm.SectionType IN(@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance, @ReconciliationSectionTypeMisMatched, @ReconciliationSectionTypeNearMatched)
			AND o_pdr_pr.ItcClaimReturnPeriod IS NOT NULL
			AND o_pdr_cr.ItcClaimReturnPeriod IS NULL
			AND o_pdrm.SessionId = @SessionID;
		
		/* Update @ReasonType_FalseCreditNote */
		/*
		DROP TABLE IF EXISTS TempInvoiceGstin;
		CREATE TABLE # TempInvoiceGstin AS 
		SELECT DISTINCT
			pd.BillFromGstin
		FROM
			oregular.Gstr2aDocumentRecoMapper m
		INNER JOIN oregular.PurchaseDocumentDW pd ON m.GstnId = pd.Id AND pd.DocumentType = @DocumentTypeINV
		WHERE
			pd.ParentEntityId = @ParentEntityId
			AND m.GstnId IS NOT NULL;

		UPDATE oregular.Gstr2aDocumentRecoMapper m
			SET	Reason = CASE WHEN tig.BillFromGstin IS NULL AND m.Gstr2BReturnPeriodDate BETWEEN CONCAT(LEFT(s.FinancialYear::character varying,4), '-04', '-01')::TIMESTAMP WITHOUT TIME ZONE AND S.FilingExtendedDate THEN '[{Reason:' || @ReasonType_FalseCreditNote || ',Value:}]' ELSE NULL END,
				ReasonType = CASE WHEN tig.BillFromGstin IS NULL AND m.Gstr2BReturnPeriodDate BETWEEN CONCAT(LEFT(s.FinancialYear::character varying,4), '-04', '-01')::TIMESTAMP WITHOUT TIME ZONE AND S.FilingExtendedDate THEN @ReasonType_FalseCreditNote::BIGINT ELSE NULL END
		FROM
			 oregular.PurchaseDocumentDW pd 
		LEFT JOIN TempInvoiceGstin tig ON tig.BillFromGstin = pd.BillFromGstin
		LEFT JOIN UNNEST(@Settings) s ON s.FinancialYear = pd.FinancialYear
		WHERE
			pd.ParentEntityId = @ParentEntityId
			AND pd.DocumentType = @DocumentTypeCRN
			AND	m.GstnId IS NOT NULL
			AND m.GstnId = pd.Id
			AND m.SectionType = @ReconciliationSectionTypeGstOnly;
		*/
		
		/* Q Entry for 2a Vs 6a Reconciliation Report */
		
		SELECT
			TOP 1
			@SubscriberId AS SubscriberId,
			@ParentEntityId AS EntityId,
			@FinancialYear AS FinancialYear
		FROM
			Oregular.Gstr2aDocumentRecoMapper o_pdrm
		WHERE
			o_pdrm.SectionType NOT IN(@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance, @ReconciliationSectionTypeMisMatched)
			AND o_pdrm.SessionId = @SessionID
		ORDER BY Id DESC;

END TRY
BEGIN CATCH

	DECLARE @UNCOMMITTED_STATE SMALLINT = -1, @DB_ERROR SMALLINT = -1, @ErrorLogID UNIQUEIDENTIFIER; 

	IF (XACT_STATE()) = @UNCOMMITTED_STATE  
	BEGIN  
			ROLLBACK TRANSACTION;  
	END; 

	THROW;

END CATCH


END;

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertSaleDocuments]
* 	Comments			: 25-05-2020 | Bhavik Patel | INSERT SALE DOCUMENT
						: 23-06-2020 | Dhruv amin | Added IsAutoPush to response for aotupush logic.
						: 28/07/2020 | Pooja Rajpurohit | Renamed table name to SaledocumentDw.
						: 29-07-2020 | Pooja Rajpurohit | Removed Insert/update portion for DW table and instead use sp for same.
						: 22-12-2020 | Bhavik Patel | Added document type condition
*	Review Comment		: 
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[InsertSaleDocuments]
(
	@SubscriberId INT,
	@SaleDocuments [oregular].[InsertSaleDocumentType] READONLY,
	@SaleDocumentItems [oregular].[InsertSaleDocumentItemType] READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@SaleDocumentCustoms [oregular].[InsertSaleDocumentCustomType] READONLY,
	@SaleDocumentPayments [oregular].[InsertSaleDocumentPaymentType] READONLY,
	@SaleDocumentContacts [oregular].[InsertSaleDocumentContactType] READONLY,
	@SaleDocumentRateWiseItems [oregular].[InsertSaleDocumentRateWiseItemType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@RequestId uniqueidentifier,
	@MergeDifferentCessAmountsIntoCessAmount BIT,
	@UserId INT,
	@DocumentStatusActive SMALLINT,
	@SourceTypeTaxpayer SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@TaxTypeTAXABLE SMALLINT,
	@TransactionTypeEXPWOP SMALLINT,
	@TransactionTypeEXPWP SMALLINT,
	@TransactionTypeSEZWOP SMALLINT,
	@TransactionTypeSEZWP SMALLINT,
	@UserActionTypeCreate SMALLINT,
	@UserActionTypeEdit SMALLINT,
	@IpAddress VARCHAR(40),
	@DocumentStatusCancelled SMALLINT,
	@PushToGstStatusCancelled SMALLINT,
	@PushToGstStatusRemovedButNotPushed SMALLINT,
	@PushToGstStatusInEligible SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempSaleDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		Mode char
	);

	CREATE CLUSTERED INDEX IDX_TempSaleDocumentIds_Id ON #TempSaleDocumentIds(ID)
	CREATE INDEX  IDX_TempSaleDocumentIds_GroupId ON #TempSaleDocumentIds(GroupId) INCLUDE(Id);

	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL	
	);
	
	CREATE CLUSTERED INDEX IDX_TempUpsertDocumentIds ON #TempUpsertDocumentIds (ID);	
	
	SELECT 
		*,
		CombineDocumentType = CASE WHEN DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE DocumentType END -- IMPACT ON report.GetBiDashboardSaleSummary
	INTO 
		#TempSaleDocuments
	FROM  
		@SaleDocuments tsd;

	CREATE CLUSTERED INDEX  IDX_TempSaleDocuments_GroupId ON #TempSaleDocuments(GroupId);

	-- Add Sale document References in temp
	SELECT 
		*
	INTO 
		#TempSaleDocumentReferences
	FROM 
		@DocumentReferences

	-- Add Sale document customs in temp
	SELECT 
		*
	INTO 
		#TempSaleDocumentCustoms
	FROM 
		@SaleDocumentCustoms

	SELECT
		*
	INTO 
		#TempSaleDocumentContacts
	FROM 
		@SaleDocumentContacts
	
	SELECT 
		*
	INTO 
		#TempSaleDocumentPayments
	FROM 
		@SaleDocumentPayments

	SELECT
		*
	INTO 
		#TempSaleDocumentItems
	FROM
		@SaleDocumentItems;

	SELECT
		*
	INTO 
		#TempSaleDocumentRateWiseItems
	FROM
		@SaleDocumentRateWiseItems;

	INSERT INTO #TempSaleDocumentIds
	(
		Id,
		GroupId,
		Mode 
	)
	SELECT
	   sd.Id,
	   tsd.GroupId,
	   'U'
	FROM
		#TempSaleDocuments tsd
		INNER JOIN oregular.SaleDocuments AS sd ON
		(
			sd.DocumentNumber = tsd.DocumentNumber
			AND sd.ParentEntityId = tsd.ParentEntityId
			AND sd.DocumentFinancialYear  =  tsd.DocumentFinancialYear 
			AND sd.CombineDocumentType = tsd.CombineDocumentType -- CHANGE DOCUMENTTYPE CONDITION
			AND sd.SourceType = @SourceTypeTaxpayer
			AND sd.IsAmendment = tsd.IsAmendment
			AND sd.SubscriberId = @SubscriberId

		);

	/* insert rest of inv to manage association with sales */
	INSERT INTO [oregular].[SaleDocuments]
	(
		SubscriberId,
		ParentEntityId,
		EntityId,
		UserId,
		StatisticId,
		IsPreGstRegime,		
		Irn,
		DocumentType,
		TransactionType,
		TransactionNature,
		TransactionTypeDescription,
		TaxpayerType,
		DocumentNumber,
		SeriesCode,
		DocumentDate,
		ReferenceId,
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
		Pos,
		DocumentValue,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount,
		DifferentialPercentage,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		RefundEligibility,
		ECommerceGstin,
		TDSGstin,
		OriginalDocumentNumber,
		OriginalDocumentDate,
		OriginalGstin,
		OriginalReturnPeriod,
		ToEmailAddresses,
		ToMobileNumbers,
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,
		SourceType,
		GroupId,
		CombineDocumentType,
		AttachmentStreamId,
		DocumentReturnPeriod,
		RequestId
	)
	OUTPUT 
		inserted.Id, inserted.GroupId, 'I'	
	INTO 
		#TempSaleDocumentIds(Id, GroupId, Mode)
	SELECT
		@SubscriberId,
		ParentEntityId,
		EntityId,
		@UserId,
		StatisticId,
		IsPreGstRegime,		
		Irn,
		DocumentType,
		TransactionType,
		TransactionNature,
		TransactionTypeDescription,
		TaxpayerType,
		DocumentNumber,
		SeriesCode,
		DocumentDate,
		ReferenceId,
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
		Pos,
		DocumentValue,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount,
		DifferentialPercentage,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		RefundEligibility,
		ECommerceGstin,
		TdsGstin,
		OriginalDocumentNumber,
		OriginalDocumentDate,
		OriginalGstin,
		OriginalReturnPeriod,
		ToEmailAddresses,
		ToMobileNumbers,
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,
		@SourceTypeTaxpayer,
		GroupId,
		CASE WHEN tsd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tsd.DocumentType END AS CombineDocumentType,
		AttachmentStreamId,
		DocumentReturnPeriod,
		@RequestId
	FROM
		#TempSaleDocuments tsd 
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempSaleDocumentIds);	

	IF EXISTS(SELECT 1 FROM #TempSaleDocumentIds tsdi WHERE tsdi.Mode = 'U')
	BEGIN
		UPDATE
			oregular.SaleDocuments
		SET
			ParentEntityId = tsd.ParentEntityId,
			EntityId = tsd.EntityId,
			UserId = @UserId,
			StatisticId = tsd.StatisticId,
			IsPreGstRegime = tsd.IsPreGstRegime,		
			Irn = tsd.Irn,
			DocumentType = tsd.DocumentType,
			TransactionType = tsd.TransactionType,
			TransactionNature = tsd.TransactionNature,
			TransactionTypeDescription = tsd.TransactionTypeDescription,
			TaxpayerType = tsd.TaxpayerType,
			DocumentNumber = tsd.DocumentNumber,
			SeriesCode = tsd.SeriesCode,
			DocumentDate = tsd.DocumentDate,
			ReferenceId = tsd.ReferenceId,
			RefDocumentRemarks = tsd.RefDocumentRemarks,
			RefDocumentPeriodStartDate = tsd.RefDocumentPeriodStartDate,
			RefDocumentPeriodEndDate = tsd.RefDocumentPeriodEndDate,
			RefPrecedingDocumentDetails = tsd.RefPrecedingDocumentDetails,
			RefContractDetails = tsd.RefContractDetails,
			AdditionalSupportingDocumentDetails = tsd.AdditionalSupportingDocumentDetails,
			BillNumber = tsd.BillNumber,
			BillDate = tsd.BillDate,
			PortCode = tsd.PortCode,
			DocumentCurrencyCode = tsd.DocumentCurrencyCode,
			DestinationCountry = tsd.DestinationCountry,
			Pos = tsd.Pos,
			DocumentValue = tsd.DocumentValue,
			DocumentDiscount = tsd.DocumentDiscount,
			DocumentOtherCharges = tsd.DocumentOtherCharges,
			DocumentValueInForeignCurrency = tsd.DocumentValueInForeignCurrency,
			DocumentValueInRoundOffAmount = tsd.DocumentValueInRoundOffAmount,
			DifferentialPercentage = tsd.DifferentialPercentage,
			ReverseCharge = tsd.ReverseCharge,
			ClaimRefund = tsd.ClaimRefund,
			UnderIgstAct = tsd.UnderIgstAct,
			RefundEligibility = tsd.RefundEligibility,
			ECommerceGstin = tsd.ECommerceGstin,
			TdsGstin = tsd.TdsGstin,
			OriginalDocumentNumber = tsd.OriginalDocumentNumber,
			OriginalDocumentDate = tsd.OriginalDocumentDate,
			OriginalGstin = tsd.OriginalGstin,
			OriginalReturnPeriod = tsd.OriginalReturnPeriod,
			ToEmailAddresses = tsd.ToEmailAddresses,
			ToMobileNumbers = tsd.ToMobileNumbers,
			SectionType = tsd.SectionType,
			TotalTaxableValue = tsd.TotalTaxableValue,
			TotalTaxAmount = tsd.TotalTaxAmount,
			ReturnPeriod = tsd.ReturnPeriod,
			DocumentFinancialYear = tsd.DocumentFinancialYear,
			FinancialYear = tsd.FinancialYear,
			IsAmendment = tsd.IsAmendment,
			SourceType = @SourceTypeTaxpayer,
			ModifiedStamp = GETDATE(),
			GroupId = tsd.GroupId,
			CombineDocumentType = CASE WHEN tsd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tsd.DocumentType END,
			AttachmentStreamId = tsd.AttachmentStreamId,
			DocumentReturnPeriod = tsd.DocumentReturnPeriod,
			RequestId = @RequestId
		FROM
			oregular.SaleDocuments AS sd
			INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sd.Id
			INNER JOIN #TempSaleDocuments AS tsd ON tsd.groupId = tsdi.GroupId
		WHERE
			tsdi.Mode = 'U';
			
		UPDATE ss
		SET 
			[Status] = CASE WHEN tsd.CancelledDate IS NULL THEN @DocumentStatusActive ELSE @DocumentStatusCancelled END,
			PushStatus = CASE WHEN tsd.CancelledDate IS NULL THEN tsd.GstPushStatus ELSE @PushToGstStatusCancelled END,
			[Action] = tsd.GstAction,
			Errors = NULL,
			GstinError = NULL,
			ModifiedStamp = GETDATE(),
			LiabilityDischargeReturnPeriod = tsd.LiabilityDischargeReturnPeriod,
			OriginalReturnPeriod = tsd.OriginalReturnPeriod,
			RequestId = @RequestId,
			UserAction = @UserActionTypeEdit
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIds AS tsdi ON ss.SaleDocumentId = tsdi.Id
			INNER JOIN #TempSaleDocuments tsd on tsdi.GroupId = tsd.GroupId
		WHERE 
			tsdi.Mode = 'U';
	END;
	
	INSERT INTO oregular.SaleDocumentStatus
	(
		SaleDocumentId,
		[Status],
		PushStatus,
		[Action],
		LiabilityDischargeReturnPeriod,
		OriginalReturnPeriod,
		BillingDate,
		RequestId,
		UserAction,
		CancelledDate
	)
	SELECT  
		tsdi.Id AS SaleDocumentId,
		(CASE WHEN tsd.CancelledDate IS NULL THEN @DocumentStatusActive ELSE @DocumentStatusCancelled END),
		(CASE WHEN tsd.CancelledDate IS NULL THEN tsd.GstPushStatus ELSE @PushToGstStatusCancelled END),
		tsd.GstAction,
		tsd.LiabilityDischargeReturnPeriod,
		tsd.OriginalReturnPeriod,
		GETDATE(),
		@RequestId,
		@UserActionTypeCreate,
		tsd.CancelledDate
	FROM
		#TempSaleDocumentIds AS tsdi
		INNER JOIN #TempSaleDocuments tsd on tsdi.GroupId = tsd.GroupId
	WHERE 
		tsdi.Mode = 'I';

	/*Inserting ids into temp table to use in below sp */
	INSERT INTO #TempUpsertDocumentIds (Id)
	SELECT 
		Id 
	FROM 
		#TempSaleDocumentIds
			
	/* Delete SaleDocumentItems for both Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempSaleDocumentIds)
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
			
			-- delete items
			DELETE
				sdi
			FROM 
				oregular.SaleDocumentItems AS sdi
				INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdi.SaleDocumentId
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;
			
			-- delete rate wise items
			DELETE
				sdri
			FROM 
				oregular.SaleDocumentRateWiseItems AS sdri
				INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdri.SaleDocumentId
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;
			

			-- delete reference
			DELETE 
				sdr
			FROM 
				oregular.SaleDocumentReferences AS sdr
				INNER JOIN #TempSaleDocumentIds AS tsdi ON sdr.SaleDocumentId = tsdi.Id
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;

			-- delete from payment
			DELETE 
				sdp
			FROM 
				oregular.SaleDocumentPayments AS sdp
				INNER JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = sdp.SaleDocumentId
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;

			-- delete contact
			DELETE 
				sdc
			FROM 
				oregular.SaleDocumentContacts AS sdc
				INNER JOIN #TempSaleDocumentIds AS tsdi ON sdc.SaleDocumentId = tsdi.Id
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;

			-- delete custom
			DELETE 
				sdr
			FROM 
				oregular.SaleDocumentCustoms AS sdr
				INNER JOIN #TempSaleDocumentIds AS tsdi ON sdr.SaleDocumentId = tsdi.Id
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;
			
			SET @Min = @Records
		END
	END
	
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
		GstActOrRuleSection,
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
		tsdids.Id,
		tsdi.SerialNumber,
		tsdi.IsService,
		tsdi.Hsn,
		tsdi.ProductCode,
		tsdi.[Name],
		tsdi.[Description],
		tsdi.Barcode,
		tsdi.Uqc,
		tsdi.Quantity,
		tsdi.FreeQuantity,
		tsdi.Rate,
		tsdi.CessRate,
		tsdi.StateCessRate,
		tsdi.CessNonAdvaloremRate,
		tsdi.PricePerQuantity,
		tsdi.DiscountAmount,
		tsdi.GrossAmount,
		tsdi.OtherCharges,
		tsdi.TaxableValue,
		tsdi.IgstAmount,
		tsdi.CgstAmount,
		tsdi.SgstAmount,
		tsdi.CessAmount,
		tsdi.StateCessAmount,
		tsdi.StateCessNonAdvaloremAmount,
		tsdi.CessNonAdvaloremAmount,
		tsdi.TaxType,
		tsdi.GstActOrRuleSection,
		tsdi.CustomItem1,
		tsdi.CustomItem2,
		tsdi.CustomItem3,
		tsdi.CustomItem4,
		tsdi.CustomItem5,
		tsdi.CustomItem6,
		tsdi.CustomItem7,
		tsdi.CustomItem8,
		tsdi.CustomItem9,
		tsdi.CustomItem10,
		@RequestId
	FROM
		#TempSaleDocumentItems AS tsdi
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdi.GroupId = tsdids.GroupId;

	INSERT INTO [oregular].[SaleDocumentRateWiseItems]
    (
		[SaleDocumentId]
        ,[Rate]
        ,[TaxableValue]
        ,[IgstAmount]
        ,[CgstAmount]
        ,[SgstAmount]
        ,[CessAmount]
	)
	SELECT
		tpdids.Id,
		tpdi.Rate,
		tpdi.TaxableValue,
		tpdi.IgstAmount,
		tpdi.CgstAmount,
		tpdi.SgstAmount,
		tpdi.CessAmount
	FROM
		#TempSaleDocumentRateWiseItems AS tpdi
		INNER JOIN #TempSaleDocumentIds AS tpdids ON tpdi.GroupId = tpdids.GroupId;

	INSERT INTO [oregular].[SaleDocumentCustoms]
    (
		SaleDocumentId,
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
		tsdids.Id,
		tsdc.Custom1,
        tsdc.Custom2,
        tsdc.Custom3,
        tsdc.Custom4,
        tsdc.Custom5,
        tsdc.Custom6,
        tsdc.Custom7,
        tsdc.Custom8,
        tsdc.Custom9,
        tsdc.Custom10,
		@RequestId
	FROM
		#TempSaleDocumentCustoms AS tsdc
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdc.GroupId = tsdids.GroupId;

	INSERT INTO oregular.SaleDocumentReferences
	(
		SaleDocumentId,
		DocumentNumber,
		DocumentDate,
		RequestId
	)
	SELECT
		tsdids.Id,
		tsdr.DocumentNumber,
		tsdr.DocumentDate,
		@RequestId
	FROM
		#TempSaleDocumentReferences AS tsdr
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdr.GroupId = tsdids.GroupId;

	INSERT INTO [oregular].[SaleDocumentPayments]
	(
		SaleDocumentId,
		PaymentType,
		PaymentMode,
		PaymentAmount,
		AdvancePaidAmount,
		PaymentDate,
		PaymentDueDate,
		PaymentRemarks,
		PaymentTerms,
		PaymentInstruction,
		PayeeName,
		UpiId,
		PayeeAccountNumber,
		PaymentAmountDue,
		Ifsc,
		CreditTransfer,
		DirectDebit,
		CreditDays,
		TransactionId,
		TransactionNote,
		RequestId
	)
	SELECT
		tsdids.Id,
		tsdp.PaymentType,
		tsdp.PaymentMode,
		tsdp.PaymentAmount,
		tsdp.AdvancePaidAmount,
		tsdp.PaymentDate,
		tsdp.PaymentDueDate,
		tsdp.PaymentRemarks,
		tsdp.PaymentTerms,
		tsdp.PaymentInstruction,
		tsdp.PayeeName,
		tsdp.UpiId,
		tsdp.PayeeAccountNumber,
		tsdp.PaymentAmountDue,
		tsdp.Ifsc,
		tsdp.CreditTransfer,
		tsdp.DirectDebit,
		tsdp.CreditDays,
		tsdp.TransactionId,
		tsdp.TransactionNote,
		@RequestId
	FROM
		#TempSaleDocumentPayments AS tsdp
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdp.GroupId = tsdids.GroupId;

	INSERT INTO [oregular].[SaleDocumentContacts]
    (	
		SaleDocumentId,
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
		tsdids.Id,
		tsdc.Gstin,
        tsdc.LegalName,
        tsdc.TradeName,
        tsdc.VendorCode,
        tsdc.AddressLine1,
        tsdc.AddressLine2,
        tsdc.City,
        tsdc.StateCode,
        tsdc.Pincode,
        tsdc.Phone,
        tsdc.Email,
        tsdc.[Type],
		@RequestId
	FROM
		#TempSaleDocumentContacts AS tsdc
		INNER JOIN #TempSaleDocumentIds AS tsdids ON tsdc.GroupId = tsdids.GroupId;

	/* SP excuted to Insert/Update data into DW table */	
	EXEC [Oregular].[InsertSaleDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN
	;


	SELECT
		tsdi.Id,
		tsdi.GroupId,
		tsd.IsAutoPush
	FROM
		#TempSaleDocumentIds As tsdi
		INNER JOIN #TempSaleDocuments tsd ON tsdi.GroupId = tsd.GroupId
			
	DROP TABLE #TempSaleDocumentIds, #TempSaleDocumentItems, #TempSaleDocuments, #TempSaleDocumentContacts, #TempSaleDocumentCustoms, #TempSaleDocumentPayments, #TempSaleDocumentReferences, #TempUpsertDocumentIds, #TempSaleDocumentRateWiseItems;
END
GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[subscriber].[UpdateVendorKycReferenceId] 
* 	Comments			:	20-09-2023 | Chandresh Prajapati | This procedure is used to update ReferenceId to Vendors.
						:	20-10-2023 | Chandresh Prajapati | Added VendorKycStatus for update
						: 02-05-2024 | Chandresh Prajapati	| Added AuditTrailDetails Parameter
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		:	DECLARE @UpdateVendorKycReferenceIdDatas [subscriber].[UpdateVendorKycReferenceIdDataType];
							INSERT INTO @VendorGstStatusLists
							(
								[SubscriberId],
								[Pan],
								[ReferenceId]
							) 
							VALUES 
							(
								164,
								'33TAA00000GT',
								NULL
							);

						   EXEC [subscriber].[UpdateVendorKycReferenceId]
								@UpdateVendorKycReferenceIdDatas = @UpdateVendorKycReferenceIdDatas,
								@AuditTrailDetails = @AuditTrailDetails;
--------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [subscriber].[UpdateVendorKycReferenceId]
(
	 @UpdateVendorKycReferenceIdDatas [subscriber].[UpdateVendorKycReferenceIdDataType] READONLY,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT 
		*
	INTO
		#TempUpdateVendorKycReferenceIdDatas
	FROM
		@UpdateVendorKycReferenceIdDatas;
	
	UPDATE 
		v
	SET
		v.ReferenceId = tuvkrd.ReferenceId,
		v.KycStatus = tuvkrd.VendorKycStatus,
		v.ModifiedStamp = getdate()
	FROM
		subscriber.Vendors v
		INNER JOIN #TempUpdateVendorKycReferenceIdDatas tuvkrd ON tuvkrd.SubscriberId = v.SubscriberId AND tuvkrd.Pan = v.Pan;
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertPurchaseDocuments]
* 	Comments			: 25-05-2020 | Bhavik Patel | INSERT PURCHASE DOCUMENT
*	Review Comment		: 29-01-2021 | Abhishek Shrivas| Again doing Db review
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[InsertPurchaseDocuments]
(
	 @SubscriberId INT,
	 @PurchaseDocuments oregular.InsertPurchaseDocumentType READONLY,
	 @PurchaseDocumentItems oregular.InsertPurchaseDocumentItemType READONLY,
	 @DocumentReferences [common].[DocumentReferenceType] READONLY,
	 @PurchaseDocumentCustoms [oregular].[InsertPurchaseDocumentCustomType] READONLY,
	 @PurchaseDocumentPayments [oregular].[InsertPurchaseDocumentPaymentType] READONLY,
	 @PurchaseDocumentContacts [oregular].[InsertPurchaseDocumentContactType] READONLY,
	 @PurchaseDocumentRateWiseItems [oregular].[InsertPurchaseDocumentRateWiseItemType] READONLY,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @RequestId uniqueidentifier,
	 @UserId INT,
	 @DocumentStatusActive SMALLINT,
	 @SourceTypeTaxpayer SMALLINT,
	 @ContactTypeBillFrom SMALLINT,
	 @DocumentTypeDBN SMALLINT,
	 @DocumentTypeCRN SMALLINT,
	 @TaxTypeTAXABLE SMALLINT,
	 @TransactionTypeSEZWOP SMALLINT,
     @TransactionTypeSEZWP SMALLINT,
	 @TransactionTypeIMPG SMALLINT,
	 @TransactionTypeIMPS SMALLINT,
	 @UserActionTypeCreate SMALLINT,
	 @UserActionTypeEdit SMALLINT,
	 @IpAddress VARCHAR(40),
	 @DocumentStatusCancelled SMALLINT,
	 @PushToGstStatusRemovedButNotPushed SMALLINT,
	 @PushToGstStatusCancelled SMALLINT,
	 @PushToGstStatusInEligible SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@FALSE BIT = 0,
		@TRUE BIT = 1,
		@NewRecordCount INT;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	-- Create table for Id and Mode
	CREATE TABLE #TempPurchaseDocumentIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		Mode CHAR
	);

	CREATE INDEX IDX_TempPurchaseDocumentIds_Id ON #TempPurchaseDocumentIds(GroupId) INCLUDE(Id);
	
	-- Add Purchase document in temp
	SELECT 
		*,
		CombineDocumentType = CASE WHEN DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE DocumentType END
	INTO 
		#TempPurchaseDocuments
	FROM 
		@PurchaseDocuments

	-- Add Purchase document References in temp
	SELECT 
		*
	INTO 
		#TempPurchaseDocumentReferences
	FROM 
		@DocumentReferences;

	SELECT
		*
	INTO 
		#TempPurchaseDocumentPayments
	FROM 
		@PurchaseDocumentPayments

	SELECT
		*
	INTO 
		#TempPurchaseDocumentContacts
	FROM 
		@PurchaseDocumentContacts

	-- Add Purchase document Customs in temp
	SELECT 
		*
	INTO 
		#TempPurchaseDocumentCustoms
	FROM 
		@PurchaseDocumentCustoms;

	CREATE NONCLUSTERED INDEX  IDX_TempPurchaseDocuments_GroupId ON #TempPurchaseDocuments(GroupId);

	-- Add Purchase document items in temp
	SELECT
		*
	INTO 
		#TempPurchaseDocumentItems 
	FROM 
		@PurchaseDocumentItems;

	-- Add Purchase document items in temp
	SELECT
		*
	INTO 
		#TempPurchaseDocumentRateWiseItems 
	FROM 
		@PurchaseDocumentRateWiseItems;

	-- Get Update Mode Data
	INSERT INTO #TempPurchaseDocumentIds
	(
		Id,
		GroupId,
		Mode 
	)
	SELECT
	   pd.Id,
	   tpd.GroupId,
	   'U'
	FROM
		#TempPurchaseDocuments tpd
		LEFT JOIN #TempPurchaseDocumentContacts tpdc ON (tpd.GroupId = tpdc.GroupId AND tpdc.[Type] = @ContactTypeBillFrom)
		INNER JOIN oregular.purchaseDocumentDW AS pd ON 
		(
			pd.SubscriberId = @SubscriberId
			AND pd.EntityId = tpd.EntityId 
			AND pd.DocumentFinancialYear = tpd.DocumentFinancialYear
			AND pd.SourceType = @SourceTypeTaxpayer
			AND pd.DocumentNumber = tpd.DocumentNumber
			AND pd.CombineDocumentType = tpd.CombineDocumentType -- CHANGE DOCUMENTTYPE CONDITION
			AND pd.IsAmendment = tpd.IsAmendment
			AND ISNULL(pd.BillFromGstin, '') = ISNULL(tpdc.Gstin, '') 
			AND ISNULL(pd.PortCode, '') = ISNULL(tpd.PortCode, '')
		)

	/* INSERT PurchaseDocuments  */
	INSERT INTO [oregular].[PurchaseDocuments]
	(
		SubscriberId,
		ParentEntityId,
		EntityId,
		UserId,
		StatisticId,
		IsPreGstRegime,
		--LiabilityDischargeReturnPeriod,
		--ItcClaimReturnPeriod,
		Irn,
		DocumentType,
		TransactionType,
		TransactionTypeDescription,
		TransactionNature,
		TaxpayerType,
		DocumentNumber,
		SeriesCode,
		DocumentDate,
		ReferenceId,
		CreditAvailedDate,
		CreditReversalDate,
		RefDocumentRemarks,
		RefDocumentPeriodStartDate,
		RefDocumentPeriodEndDate,
		RefPrecedingDocumentDetails,
		RefContractDetails,
		AdditionalSupportingDocumentDetails,
		PortCode,
		DocumentCurrencyCode,
		DestinationCountry,
		Pos,
		DocumentValue,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount,
		DifferentialPercentage,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		RefundEligibility,
		PnrOrUniqueNumber,
		AvailProvisionalItc,
		OriginalDocumentNumber,
		OriginalDocumentDate,
		OriginalGstin,
		OriginalReturnPeriod,
		OriginalPortCode,
		ToEmailAddresses,
		ToMobileNumbers,
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,
		SourceType,
		GroupId,
		CombineDocumentType,
		AttachmentStreamId,
		RecoDocumentNumber,
		DocumentReturnPeriod,
		RequestId,
		TotalRateWiseTaxableValue,
		TotalRateWiseTaxAmount
	)
	OUTPUT
		inserted.Id, inserted.GroupId, 'I'	
	INTO 
		#TempPurchaseDocumentIds(Id, GroupId, Mode)
	SELECT
		@SubscriberId,
		ParentEntityId,
		EntityId,
		@UserId,
		StatisticId,
		IsPreGstRegime,
		--LiabilityDischargeReturnPeriod,
		--ItcClaimReturnPeriod,
		Irn,
		DocumentType,
		TransactionType,
		TransactionTypeDescription,
		TransactionNature,
		TaxpayerType,
		DocumentNumber,
		SeriesCode,
		DocumentDate,
		ReferenceId,
		CreditAvailedDate,
		CreditReversalDate,
		RefDocumentRemarks,
		RefDocumentPeriodStartDate,
		RefDocumentPeriodEndDate,
		RefPrecedingDocumentDetails,
		RefContractDetails,
		AdditionalSupportingDocumentDetails,
		PortCode,
		DocumentCurrencyCode,
		DestinationCountry,
		Pos,
		DocumentValue,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount,
		DifferentialPercentage,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,
		RefundEligibility,
		PnrOrUniqueNumber,
		AvailProvisionalItc,
		OriginalDocumentNumber,
		OriginalDocumentDate,
		OriginalGstin,
		OriginalReturnPeriod,
		OriginalPortCode,
		ToEmailAddresses,
		ToMobileNumbers,
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,
		@SourceTypeTaxpayer,
		GroupId,
		CASE WHEN DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE DocumentType END AS CombineDocumentType,
		AttachmentStreamId,
		RecoDocumentNumber,
		DocumentReturnPeriod,
		@RequestId,
		TotalRateWiseTaxableValue,
		TotalRateWiseTaxAmount
	FROM
		#TempPurchaseDocuments
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempPurchaseDocumentIds);

	
	UPDATE oregular.PurchaseDocuments 
	SET
		ParentEntityId = tpd.ParentEntityId,
		EntityId = tpd.EntityId,
		UserId = @UserId,
		StatisticId = tpd.StatisticId,
		IsPreGstRegime = tpd.IsPreGstRegime,
		--LiabilityDischargeReturnPeriod = tpd.LiabilityDischargeReturnPeriod,
		--ItcClaimReturnPeriod = tpd.ItcClaimReturnPeriod,
		Irn = tpd.Irn,
		DocumentType = tpd.DocumentType,
		TransactionType = tpd.TransactionType,
		TransactionTypeDescription = tpd.TransactionTypeDescription,
		TransactionNature = tpd.TransactionNature,
		TaxpayerType = tpd.TaxpayerType,
		DocumentNumber = tpd.DocumentNumber,
		SeriesCode = tpd.SeriesCode,
		DocumentDate = tpd.DocumentDate,
		ReferenceId = tpd.ReferenceId,
		CreditAvailedDate = tpd.CreditAvailedDate,
		CreditReversalDate = tpd.CreditReversalDate,
		RefDocumentRemarks = tpd.RefDocumentRemarks,
		RefDocumentPeriodStartDate = tpd.RefDocumentPeriodStartDate,
		RefDocumentPeriodEndDate = tpd.RefDocumentPeriodEndDate,
		RefPrecedingDocumentDetails = tpd.RefPrecedingDocumentDetails,
		RefContractDetails = tpd.RefContractDetails,
		AdditionalSupportingDocumentDetails = tpd.AdditionalSupportingDocumentDetails,
		PortCode = tpd.PortCode,
		DocumentCurrencyCode = tpd.DocumentCurrencyCode,
		DestinationCountry = tpd.DestinationCountry,
		Pos = tpd.Pos,
		DocumentValue = tpd.DocumentValue,
		DocumentDiscount = tpd.DocumentDiscount,
		DocumentOtherCharges = tpd.DocumentOtherCharges,
		DocumentValueInForeignCurrency = tpd.DocumentValueInForeignCurrency,
		DocumentValueInRoundOffAmount = tpd.DocumentValueInRoundOffAmount,
		DifferentialPercentage = tpd.DifferentialPercentage,
		ReverseCharge = tpd.ReverseCharge,
		ClaimRefund = tpd.ClaimRefund,
		UnderIgstAct = tpd.UnderIgstAct,
		RefundEligibility = tpd.RefundEligibility,
		PnrOrUniqueNumber= tpd.PnrOrUniqueNumber,
		AvailProvisionalItc= tpd.AvailProvisionalItc,
		OriginalDocumentNumber = tpd.OriginalDocumentNumber,
		OriginalDocumentDate = tpd.OriginalDocumentDate,
		OriginalGstin = tpd.OriginalGstin,
		OriginalReturnPeriod = tpd.OriginalReturnPeriod,
		OriginalPortCode = tpd.OriginalPortCode,
		ToEmailAddresses = tpd.ToEmailAddresses,
		ToMobileNumbers = tpd.ToMobileNumbers,
		SectionType = tpd.SectionType,
		TotalTaxableValue = tpd.TotalTaxableValue,
		TotalTaxAmount = tpd.TotalTaxAmount,
		ReturnPeriod = tpd.ReturnPeriod,
		DocumentFinancialYear = tpd.DocumentFinancialYear,
		FinancialYear = tpd.FinancialYear,
		IsAmendment = tpd.IsAmendment,
		SourceType = @SourceTypeTaxpayer,
		GroupId = tpd.GroupId,
		ModifiedStamp = GETDATE(),
		CombineDocumentType = CASE WHEN tpd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tpd.DocumentType END,
		AttachmentStreamId = tpd.AttachmentStreamId,
		RecoDocumentNumber = tpd.RecoDocumentNumber,
		DocumentReturnPeriod = tpd.DocumentReturnPeriod,
		RequestId = @RequestId,
		TotalRateWiseTaxableValue = tpd.TotalRateWiseTaxableValue,
		TotalRateWiseTaxAmount= tpd.TotalRateWiseTaxAmount
	FROM
		oregular.PurchaseDocuments AS pd
		INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = pd.Id
		INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode = 'U';
	
	INSERT INTO oregular.PurchaseDocumentStatus
	(
		PurchaseDocumentId,
		[Status],
		PushStatus,
		[Action],
		ReconciliationStatus,
		AutoDraftSource,
		ItcClaimReturnPeriod,
		LiabilityDischargeReturnPeriod,
		OriginalReturnPeriod,
		IsReconciledGstr2b,
		Gstr2bAction,
		BillingDate,
		RequestId,
		UserAction,
		CancelledDate
	)
	SELECT  
		tpdi.Id,
		(CASE WHEN tpd.CancelledDate IS NULL THEN @DocumentStatusActive ELSE @DocumentStatusCancelled END),
		(CASE WHEN tpd.CancelledDate IS NULL THEN tpd.GstPushStatus ELSE @PushToGstStatusCancelled END),
		tpd.GstAction,
		tpd.ReconciliationStatus,
		tpd.AutoDraftSource,
		tpd.ItcClaimReturnPeriod,
		tpd.LiabilityDischargeReturnPeriod,
		tpd.OriginalReturnPeriod,
		@FALSE,
		tpd.GstAction,
		GETDATE(),
		@RequestId,
		@UserActionTypeCreate,
		tpd.CancelledDate
	FROM
		#TempPurchaseDocumentIds AS tpdi 
		INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
	WHERE 
		tpdi.Mode = 'I'

	/* update salestatus */
	UPDATE ss
	SET 
		[Status] = (CASE WHEN tpd.CancelledDate IS NULL THEN @DocumentStatusActive ELSE @DocumentStatusCancelled END),
		PushStatus = (CASE WHEN tpd.CancelledDate IS NULL THEN tpd.GstPushStatus ELSE @PushToGstStatusCancelled END),
		[Action] = tpd.GstAction,
		ReconciliationStatus = tpd.ReconciliationStatus,
		-- AutoDraftSource = tpd.AutoDraftSource,
		Errors = null,
		IsReconciled = @FALSE,
		ModifiedStamp = GETDATE(),
		ItcClaimReturnPeriod = tpd.ItcClaimReturnPeriod,
		LiabilityDischargeReturnPeriod = tpd.LiabilityDischargeReturnPeriod,
		OriginalReturnPeriod = tpd.OriginalReturnPeriod,
		IsReconciledGstr2b = @FALSE,
		[Gstr2bAction] = tpd.GstAction,
		RequestId = @RequestId,
		UserAction = @UserActionTypeEdit,
		CancelledDate = tpd.CancelledDate
	FROM
		oregular.PurchaseDocumentStatus ss
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON ss.PurchaseDocumentId = tpdi.ID
		INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
	WHERE 
		tpdi.Mode = 'U';

	UPDATE PDS
	SET 
		IsReconciledGstr2b = @FALSE,
		[Gstr2bAction] = tpd.GstAction
	FROM
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
		INNER JOIN oregular.Gstr2bDocumentRecoMapper M ON M.PrId = tpdi.Id
		INNER JOIN oregular.PurchaseDocumentStatus PDS ON M.GstnId = PDS.PurchaseDocumentId
	WHERE 
		tpdi.Mode = 'U'
		AND M.GstnId IS NOT NULL;
	
	/* Delete PurchaseDocumentItems and PurchaseDocumentPayments for both Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempPurchaseDocumentIds)
	BEGIN
		DECLARE 
			@Min INT = 1, 
			@Max INT, 
			@BatchSize INT, 
			@Records INT;

		SELECT 
			@Max = COUNT(AutoId)
		FROM 
			#TempPurchaseDocumentIds

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN  ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize;
			
			/* delete purchase document items */
			DELETE 
				pdi
			FROM 
				oregular.PurchaseDocumentItems AS pdi
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdi.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase rate wise document items */
			DELETE 
				pdri
			FROM 
				oregular.PurchaseDocumentRateWiseItems AS pdri
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdri.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				pdr
			FROM 
				oregular.PurchaseDocumentReferences AS pdr
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdr.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				pdp
			FROM 
				oregular.PurchaseDocumentPayments AS pdp
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdp.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.AutoId BETWEEN @Min AND @Records;

			-- delete contact
			DELETE 
				pdc
			FROM 
				oregular.PurchaseDocumentContacts AS pdc
				INNER JOIN #TempPurchaseDocumentIds AS tsdi ON pdc.PurchaseDocumentId = tsdi.Id
			WHERE 
				tsdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				pdr
			FROM 
				oregular.PurchaseDocumentCustoms AS pdr
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdr.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.AutoId BETWEEN @Min AND @Records;
			
			SET @Min = @Records
		END
	END

	INSERT INTO [oregular].[PurchaseDocumentItems]
	(
		PurchaseDocumentId,
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
		ItcEligibility,
		GstActOrRuleSection,
		ItcIgstAmount,
		ItcCgstAmount,
		ItcSgstAmount,
		ItcCessAmount,
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
		TdsRate,
		TdsAmount,
		RequestId
	)
	SELECT
		tpdids.Id,
		tpdi.SerialNumber,
		tpdi.IsService,
		tpdi.Hsn,
		tpdi.ProductCode,
		tpdi.[Name],
		tpdi.[Description],
		tpdi.Barcode,
		tpdi.Uqc,
		tpdi.Quantity,
		tpdi.FreeQuantity,
		tpdi.Rate,
		tpdi.CessRate,
		tpdi.StateCessRate,
		tpdi.CessNonAdvaloremRate,
		tpdi.PricePerQuantity,
		tpdi.DiscountAmount,
		tpdi.GrossAmount,
		tpdi.OtherCharges,
		tpdi.TaxableValue,
		tpdi.IgstAmount,
		tpdi.CgstAmount,
		tpdi.SgstAmount,
		tpdi.CessAmount,
		tpdi.StateCessAmount,
		tpdi.StateCessNonAdvaloremAmount,
		tpdi.CessNonAdvaloremAmount,
		tpdi.TaxType,
		tpdi.ItcEligibility,
		tpdi.GstActOrRuleSection,
		tpdi.ItcIgstAmount,
		tpdi.ItcCgstAmount,
		tpdi.ItcSgstAmount,
		tpdi.ItcCessAmount,
		tpdi.CustomItem1,
		tpdi.CustomItem2,
		tpdi.CustomItem3,
		tpdi.CustomItem4,
		tpdi.CustomItem5,
		tpdi.CustomItem6,
		tpdi.CustomItem7,
		tpdi.CustomItem8,
		tpdi.CustomItem9,
		tpdi.CustomItem10,
		tpdi.TdsRate,
		tpdi.TdsAmount,
		@RequestId
	FROM
		#TempPurchaseDocumentItems AS tpdi
		INNER JOIN #TempPurchaseDocumentIds AS tpdids ON tpdi.GroupId = tpdids.GroupId;

	INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
    (
		[PurchaseDocumentId]
		,[Rate]
		,[TaxableValue]
		,[IgstAmount]
		,[CgstAmount]
		,[SgstAmount]
		,[CessAmount]
	)
	SELECT
		tpdids.Id,
		tpdi.Rate,
		tpdi.TaxableValue,
		tpdi.IgstAmount,
		tpdi.CgstAmount,
		tpdi.SgstAmount,
		tpdi.CessAmount
	FROM
		#TempPurchaseDocumentRateWiseItems AS tpdi
		INNER JOIN #TempPurchaseDocumentIds AS tpdids ON tpdi.GroupId = tpdids.GroupId;

	INSERT INTO oregular.PurchaseDocumentReferences
	(
		PurchaseDocumentId,
		DocumentNumber,
		DocumentDate,
		RequestId
	)
	SELECT
		tpdids.Id,
		tpdr.DocumentNumber,
		tpdr.DocumentDate,
		@RequestId
	FROM
		#TempPurchaseDocumentReferences AS tpdr
		INNER JOIN #TempPurchaseDocumentIds AS tpdids ON tpdr.GroupId = tpdids.GroupId;

	INSERT INTO [oregular].[PurchaseDocumentCustoms]
    (
		PurchaseDocumentId,
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
		tpdids.Id,
		tpdc.Custom1,
        tpdc.Custom2,
        tpdc.Custom3,
        tpdc.Custom4,
        tpdc.Custom5,
        tpdc.Custom6,
        tpdc.Custom7,
        tpdc.Custom8,
        tpdc.Custom9,
        tpdc.Custom10,
		@RequestId
	FROM
		#TempPurchaseDocumentCustoms AS tpdc
		INNER JOIN #TempPurchaseDocumentIds AS tpdids ON tpdc.GroupId = tpdids.GroupId;

	INSERT INTO [oregular].[PurchaseDocumentPayments]
	(
		PurchaseDocumentId,
		PaymentType,
		PaymentMode,
		PaymentAmount,
		AdvancePaidAmount,
		PaymentDate,
		PaymentDueDate,
		PaymentRemarks,
		PaymentTerms,
		PaymentInstruction,
		PayeeName,
		UpiId,
		PayeeAccountNumber,
		PaymentAmountDue,
		Ifsc,
		CreditTransfer,
		DirectDebit,
		CreditDays,
		TransactionId,
		TransactionNote,
		RequestId
	)
	SELECT
		tpdids.Id,
		tpdp.PaymentType,
		tpdp.PaymentMode,
		tpdp.PaymentAmount,
		tpdp.AdvancePaidAmount,
		tpdp.PaymentDate,
		tpdp.PaymentDueDate,
		tpdp.PaymentRemarks,
		tpdp.PaymentTerms,
		tpdp.PaymentInstruction,
		tpdp.PayeeName,
		tpdp.UpiId,
		tpdp.PayeeAccountNumber,
		tpdp.PaymentAmountDue,
		tpdp.Ifsc,
		tpdp.CreditTransfer,
		tpdp.DirectDebit,
		tpdp.CreditDays,
		tpdp.TransactionId,
		tpdp.TransactionNote,
		@RequestId
	FROM
		#TempPurchaseDocumentPayments AS tpdp
		INNER JOIN #TempPurchaseDocumentIds AS tpdids ON tpdp.GroupId = tpdids.GroupId;

	INSERT INTO [oregular].[PurchaseDocumentContacts]
    (	
		PurchaseDocumentId,
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
		tpdids.Id,
		tpdc.Gstin,
        tpdc.LegalName,
        tpdc.TradeName,
        tpdc.VendorCode,
        tpdc.AddressLine1,
        tpdc.AddressLine2,
        tpdc.City,
        tpdc.StateCode,
        tpdc.Pincode,
        tpdc.Phone,
        tpdc.Email,
        tpdc.[Type],
		@RequestId
	FROM
		#TempPurchaseDocumentContacts AS tpdc
		INNER JOIN #TempPurchaseDocumentIds AS tpdids ON tpdc.GroupId = tpdids.GroupId;
	
	EXEC [oregular].[InsertPurchaseDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;
		
	SELECT
		@NewRecordCount = COUNT(1)
	FROM
		#TempPurchaseDocumentIds as tpdids
		INNER JOIN #TempPurchaseDocuments as tpd ON tpdids.GroupId = tpd.GroupId
	WHERE 
		tpdids.Mode = 'I';

	SELECT @NewRecordCount;

	DROP TABLE 
		#TempPurchaseDocumentIds, #TempPurchaseDocumentItems, #TempPurchaseDocuments, #TempPurchaseDocumentContacts, #TempPurchaseDocumentCustoms, #TempPurchaseDocumentPayments, #TempPurchaseDocumentReferences, #TempPurchaseDocumentRateWiseItems;
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [subscriber].[UpdateStatusForIpAddress]
*	Comments		: 01-02-2021 | Chandresh Prajapati | This procedure is used to update status of IpAddress.
					: 13-05-2024 | Chandresh Prajapati | Added AuditTrailDetails Parameter 
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: EXEC [subscriber].[UpdateStatusForNotificationReply]
						@Id = 36,
						@SubscriberId = 196,
						@StatusTypeActive = 1,
						@StatusTypeInactive = 3
--------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [subscriber].[UpdateStatusForNotificationReply]
(
	 @SubscriberId INT,
	 @Id INT,
	 @StatusTypeActive SMALLINT,
	 @StatusTypeInactive SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	DECLARE @Status INT;

	SET @Status = (SELECT [Status] FROM subscriber.NotificationReply where Id = @Id);

	IF (@Status = @StatusTypeActive)
	BEGIN 
		UPDATE
			subscriber.NotificationReply
		SET 
			[Status] = @StatusTypeInactive,
			ModifiedStamp = GETDATE()
		WHERE 
			Id = @Id
			AND SubscriberId = @SubscriberId;
	END
	ELSE
	BEGIN 
		UPDATE
			subscriber.NotificationReply
		SET 
			[Status] = @StatusTypeActive,
			ModifiedStamp = GETDATE()
		WHERE 
			Id = @Id
			AND SubscriberId = @SubscriberId;
	END
END
GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: oregular.InsertGstr2aReconciliationDocuments
* 	Comments			: 12/10/2022 | Pooja Rajpurohit | SP to validate Gstr2aReconciliationDocuments.					
*	Review Comment		: 
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 	
DECLARE  @ValSetting AS oregular.ValidateGstr2aReconciliationDocumentType,@ExcludedGstin AS Oregular.[FinancialYearWiseGstinType],
	@AuditTrailDetails AS [audit].AuditTrailDetailsType;

INSERT INTO @ValSetting
SELECT
		*
FROM 
OPENJSON('[{"ParentEntityId":947,"PrDocumentType":2,"PrDocumentNumber":"PR/ONLY/3","PrDocumentDate":"2024-01-07T00:00:00","PrGstin":"37GEOPS0823B2ZE","PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":null,"CpDocumentNumber":null,"CpDocumentDate":null,"CpGstin":null,"CpPortCode":null,"CpIsAmendment":false,"GroupKey":null,"ManualReconciliation":false,"RecordName":null,"Source":"2A","Type":null,"FinancialYear":202324,"ReconciliationSection":1,"Action":null,"ItcClaimReturnPeriod":null,"GroupId":2},{"ParentEntityId":947,"PrDocumentType":1,"PrDocumentNumber":"AB/XGST/1","PrDocumentDate":"2024-01-07T00:00:00","PrGstin":"37GEOPS0823B2ZE","PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":null,"CpDocumentNumber":null,"CpDocumentDate":null,"CpGstin":null,"CpPortCode":null,"CpIsAmendment":false,"GroupKey":null,"ManualReconciliation":false,"RecordName":null,"Source":"2A","Type":null,"FinancialYear":202324,"ReconciliationSection":1,"Action":null,"ItcClaimReturnPeriod":null,"GroupId":1}]')
WITH
(
ParentEntityId int '$.ParentEntityId'
,PrDocumentType smallint '$.PrDocumentType'
,PrDocumentNumber varchar(40) '$.PrDocumentNumber'
,PrDocumentDate datetime '$.PrDocumentDate'
,PrGstin varchar(15) '$.PrGstin'
,PrPortCode varchar(6) '$.PrPortCode'
,PrIsAmendment bit '$.PrIsAmendment'
,CpDocumentType smallint '$.CpDocumentType'
,CpDocumentNumber varchar(40) '$.CpDocumentNumber'
,CpDocumentDate datetime '$.CpDocumentDate'
,CpGstin varchar(15) '$.CpGstin'
,CpPortCode varchar(6) '$.CpPortCode'
,CpIsAmendment bit '$.CpIsAmendment'
,GroupKey int '$.GroupKey'
,ManualReconciliation bit '$.ManualReconciliation'
,RecordName varchar(50) '$.RecordName'
,Source char '$.Source'
,Type smallint '$.Type'
,FinancialYear int '$.FinancialYear'
,ReconciliationSection smallint '$.ReconciliationSection'
,Action smallint '$.Action'
,ItcClaimReturnPeriod int '$.ItcClaimReturnPeriod'
,GroupId int '$.GroupId'
)
;

DECLARE @TempSetting AS oregular.GetReconciliationSettingForInsertResponseType;
INSERT INTO @TempSetting
SELECT 
	*
FROM 
	OPENJSON('[{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":true,"MatchByToleranceDocumentValueFrom":-5.00,"MatchByToleranceDocumentValueTo":5.00,"MatchByToleranceTaxableValueFrom":-5.00,"MatchByToleranceTaxableValueTo":5.00,"MatchByToleranceTaxAmountsFrom":-5.00,"MatchByToleranceTaxAmountsTo":5.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":true,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":201718,"FilingExtendedDate":"2020-03-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":201819,"FilingExtendedDate":"2020-03-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":201920,"FilingExtendedDate":"2021-03-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":true,"MatchByToleranceDocumentValueFrom":-111.00,"MatchByToleranceDocumentValueTo":111.00,"MatchByToleranceTaxableValueFrom":-111.00,"MatchByToleranceTaxableValueTo":111.00,"MatchByToleranceTaxAmountsFrom":-111.00,"MatchByToleranceTaxAmountsTo":111.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-200.00,"NearMatchToleranceDocumentValueTo":200.00,"NearMatchToleranceTaxableValueFrom":-200.00,"NearMatchToleranceTaxableValueTo":200.00,"NearMatchToleranceTaxAmountsFrom":-200.00,"NearMatchToleranceTaxAmountsTo":200.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":202021,"FilingExtendedDate":"2021-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":202122,"FilingExtendedDate":"2022-10-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":true,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-1000.00,"NearMatchToleranceDocumentValueTo":1000.00,"NearMatchToleranceTaxableValueFrom":-100.00,"NearMatchToleranceTaxableValueTo":100.00,"NearMatchToleranceTaxAmountsFrom":-100.00,"NearMatchToleranceTaxAmountsTo":100.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202223,"FilingExtendedDate":"2023-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-1000.00,"NearMatchToleranceDocumentValueTo":1000.00,"NearMatchToleranceTaxableValueFrom":-100.00,"NearMatchToleranceTaxableValueTo":100.00,"NearMatchToleranceTaxAmountsFrom":-100.00,"NearMatchToleranceTaxAmountsTo":100.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202324,"FilingExtendedDate":"2024-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":true,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202425,"FilingExtendedDate":"2025-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false}]')
WITH
(
	IsReconcileAtDocumentLevel bit '$.IsReconcileAtDocumentLevel'
	,IsExcludeMatchingCriteria bit '$.IsExcludeMatchingCriteria'
	,IsExcludeMatchingCriteriaPos bit '$.IsExcludeMatchingCriteriaPos'
	,IsExcludeMatchingCriteriaHsn bit '$.IsExcludeMatchingCriteriaHsn'
	,IsExcludeMatchingCriteriaRate bit '$.IsExcludeMatchingCriteriaRate'
	,IsExcludeMatchingCriteriaDocumentValue bit '$.IsExcludeMatchingCriteriaDocumentValue'
	,IsExcludeMatchingCriteriaTaxableValue bit '$.IsExcludeMatchingCriteriaTaxableValue'
	,IsExcludeMatchingCriteriaDocDate bit '$.IsExcludeMatchingCriteriaDocDate'
	,IsExcludeMatchingCriteriaReverseCharge bit '$.IsExcludeMatchingCriteriaReverseCharge'
	,IsExcludeMatchingCriteriaTransactionType bit '$.IsExcludeMatchingCriteriaTransactionType'
	,IsExcludeMatchingCriteriaIrn bit '$.IsExcludeMatchingCriteriaIrn'
	,IsMatchOnDateDifference bit '$.IsMatchOnDateDifference'
	,IsMatchByTolerance bit '$.IsMatchByTolerance'
	,MatchByToleranceDocumentValueFrom decimal(15,2) '$.MatchByToleranceDocumentValueFrom'
	,MatchByToleranceDocumentValueTo decimal(15,2) '$.MatchByToleranceDocumentValueTo'
	,MatchByToleranceTaxableValueFrom decimal(15,2) '$.MatchByToleranceTaxableValueFrom'
	,MatchByToleranceTaxableValueTo decimal(15,2) '$.MatchByToleranceTaxableValueTo'
	,MatchByToleranceTaxAmountsFrom decimal(15,2) '$.MatchByToleranceTaxAmountsFrom'
	,MatchByToleranceTaxAmountsTo decimal(15,2) '$.MatchByToleranceTaxAmountsTo'
	,IfPrTaxAmountIsLessThanCpTaxAmount bit '$.IfPrTaxAmountIsLessThanCpTaxAmount'
	,IfCpTaxAmountIsLessThanPrTaxAmount bit '$.IfCpTaxAmountIsLessThanPrTaxAmount'
	,IsNearMatchViaFuzzyLogic bit '$.IsNearMatchViaFuzzyLogic'
	,NearMatchFuzzyLogicPercentage tinyint '$.NearMatchFuzzyLogicPercentage'
	,NearMatchDateRangeFrom int '$.NearMatchDateRangeFrom'
	,NearMatchDateRangeTo int '$.NearMatchDateRangeTo'
	,ExcludeIntercompanyTransaction bit '$.ExcludeIntercompanyTransaction'
	,NearMatchToleranceDocumentValueFrom decimal(15,2) '$.NearMatchToleranceDocumentValueFrom'
	,NearMatchToleranceDocumentValueTo decimal(15,2) '$.NearMatchToleranceDocumentValueTo'
	,NearMatchToleranceTaxableValueFrom decimal(15,2) '$.NearMatchToleranceTaxableValueFrom'
	,NearMatchToleranceTaxableValueTo decimal(15,2) '$.NearMatchToleranceTaxableValueTo'
	,NearMatchToleranceTaxAmountsFrom decimal(15,2) '$.NearMatchToleranceTaxAmountsFrom'
	,NearMatchToleranceTaxAmountsTo decimal(15,2) '$.NearMatchToleranceTaxAmountsTo'
	,IsDiscardOriginalsWithAmendment bit '$.IsDiscardOriginalsWithAmendment'
	,FinancialYear int '$.FinancialYear'
	,FilingExtendedDate date '$.FilingExtendedDate'
	,IsNearMatchDateRestriction bit '$.IsNearMatchDateRestriction'
	,IsRegeneratePreference bit '$.IsRegeneratePreference'
	,IsExcludeCpNotFiledData bit '$.IsExcludeCpNotFiledData'
	,IsMismatchIfDocNumberDifferentAfterAmendment bit '$.IsMismatchIfDocNumberDifferentAfterAmendment'
	,AdvanceNearMatchPoweredByAI bit '$.AdvanceNearMatchPoweredByAI'
	,IsNearMatchTolerance bit '$.IsNearMatchTolerance'
	,IsRegeneratePreferenceAction bit '$.IsRegeneratePreferenceAction'
	,IsRegeneratePreference3bClaimedMonth bit '$.IsRegeneratePreference3bClaimedMonth'
)


							EXEC [oregular].[InsertGstr2aReconciliationDocuments]
								 @ReconciliationSectionTypePROnly = 1
								,@ReconciliationSectionTypeGstOnly = 2
								,@ReconciliationMappingTypeTillDate = 4
								,@Documents = @ValSetting
								,@Settings = @TempSetting
								,@Statisticid = 1011
								,@ReconciliationSectionTypePRExcluded  = 7
								,@ReconciliationSectionTypeGstExcluded  = 8
								,@ExcludedGstin = @ExcludedGstin
								,@ActionTypeNoAction=1
								,@ReconciliationStatusActionsNotTaken=1
								,@ReconciliationStatusActionsNotPushed=2
								,@ReconciledTypeManual = 2
								,@IsRestrictItcClaim  = 0
								,@ReconciliationSourceType2b = '2b'
								,@ReconciliationType2b  = 8
								,@ReconciliationType2a  = 2
								,@AuditTrailDetails = @AuditTrailDetails

----------------------------------------------------------------------------------------------------------------------------------------*/	

CREATE PROCEDURE [oregular].[InsertGstr2aReconciliationDocuments](
	 @ReconciliationSectionTypePROnly SMALLINT
	,@ReconciliationSectionTypeGstOnly SMALLINT    
	,@ReconciliationSectionTypePRExcluded SMALLINT = 7
	,@ReconciliationSectionTypeGstExcluded SMALLINT = 8
	,@ReconciliationMappingTypeTillDate SMALLINT
	,@Documents [oregular].[ValidateGstr2aReconciliationDocumentType] READONLY
	,@Settings AS Oregular.GetReconciliationSettingForInsertResponseType READONLY
	,@ExcludedGstin AS Oregular.[FinancialYearWiseGstinType] READONLY
	,@ActionTypeNoAction AS SMALLINT = 1
	,@ReconciliationStatusActionsNotTaken AS SMALLINT = 1
	,@ReconciliationStatusActionsNotPushed AS SMALLINT = 2
	,@StatisticId BIGINT
	,@ReconciledTypeManual SMALLINT = 2
	,@IsRestrictItcClaim BIT = 0
	,@ReconciliationSourceType2b VARCHAR(10) = '2b'
	,@ReconciliationType2b SMALLINT = 8
	,@ReconciliationType2a SMALLINT = 2
	,@DocumentTypeBOE SMALLINT = 4
	,@AuditTrailDetails [audit].AuditTrailDetailsType READONLY
)
AS
BEGIN
		
	DECLARE @CURRENT_DATE DATETIME = GETDATE(),@FALSE SMALLINT = 0,@TRUE SMALLINT = 1;

	DROP TABLE IF EXISTS #TempImportReconciliationData,#TempRecoId,#TempSettings,#TempManualRecoData,#ReturnData,#ExcludedGstin,#ManualMapperIds;
	CREATE TABLE #TempImportReconciliationData
		(
			ParentEntityId integer,
			PrDocumentType smallint,
			PrDocumentNumber VARCHAR(40),
			PrDocumentDate DATETIME,
			PrGstin VARCHAR(15),
			PrPortCode VARCHAR(6),
			PrIsAmendment bit,
			CpDocumentType smallint,
			CpDocumentNumber VARCHAR(40),
			CpDocumentDate DATETIME,
			CpGstin VARCHAR(15),
			CpPortCode VARCHAR(6),
			CpIsAmendment bit,
			GroupKey integer,
			ManualReconciliation bit,
			RecordName VARCHAR(50),
			Source character(3),
			[Type] smallint,
			FinancialYear integer,
			ReconciliationSection smallint,
			[Action] smallint,
			ItcClaimReturnPeriod integer,
			GroupId integer,
			PrDocumentDateBigInt BIGINT,
			CpDocumentDateBigInt BIGINT,
			IsPreserved BIT DEFAULT 0
		);
		
		INSERT INTO #TempImportReconciliationData
		(		
			ParentEntityId,
			PrDocumentType,
			PrDocumentNumber,
			PrDocumentDate,
			PrGstin,
			PrPortCode,
			PrIsAmendment,
			CpDocumentType,
			CpDocumentNumber,
			CpDocumentDate,
			CpGstin,
			CpPortCode,
			CpIsAmendment,
			GroupKey,
			ManualReconciliation,
			RecordName,
			Source,
			Type,
			FinancialYear,
			ReconciliationSection,
			Action,
			ItcClaimReturnPeriod,
			GroupId,
			PrDocumentDateBigInt, 
			CpDocumentDateBigInt 
		)
		SELECT 			
			 ParentEntityId
			,PrDocumentType 
			,ISNULL(PrDocumentNumber,'') 
			,ISNULL(PrDocumentDate,'1900-01-01') 
			,ISNULL(PrGstin,'')	
			,ISNULL(PrPortCode,'') 
			,ISNULL(PrIsAmendment,0)
			,CpDocumentType
			,ISNULL(CpDocumentNumber,'')  
			,ISNULL(CpDocumentDate,'1900-01-01') 
			,ISNULL(CpGstin,'') 
			,ISNULL(CpPortCode,'')
			,ISNULL(CpIsAmendment,0) 
			,GroupKey
			,ManualReconciliation 
			,RecordName 
			,Source		
			,Type 
			,d.FinancialYear 
			,ReconciliationSection  
			,Action 
			,ItcClaimReturnPeriod 
			,GroupId
			,CAST(CONVERT(VARCHAR(10),ISNULL(PrDocumentDate,'') ,112) AS BIGINT) PrDocumentDate
			,CAST(CONVERT(VARCHAR(10),ISNULL(CpDocumentDate,'') ,112) AS BIGINT)CpDocumentDate
		FROM 
			@Documents d
		WHERE Source <> @ReconciliationSourceType2b	;	 
	
	   CREATE INDEX IDX_TempValidatePurchaseDocuments_GroupId ON #TempImportReconciliationData(GroupId);
	   IF EXISTS (SELECT 1 FROM #TempImportReconciliationData)
	   BEGIN
		/*Getting details of data from actual tables */
		SELECT 
			trd.Type,
			PDRPR.Id PrId, 
			PDRCP.Id GstnId, 
			trd.GroupId,
			PDRPR.ReturnPeriod PrReturnPeriod, 
            PDRCP.ReturnPeriod CPReturnPeriod, 
			PDRPR.ParentEntityId PRParentEntityId,
			PDRCP.ParentEntityId ParentEntityIdCP ,
			trd.ReconciliationSection SectionType,		
			PDRPR.DocumentFinancialYear PRDocumentFinancialyear,
			PDRPR.FinancialYear PRRPFinancialyear,
			PDRCP.DocumentFinancialYear CPDocumentFinancialyear,
			PDRCP.FinancialYear CPRPFinancialyear,
			trd.Action,
			trd.ItcClaimReturnPeriod,
			@StatisticId StatisticId,
			Type PrevType,
			IsPreserved,
			trd.PrDocumentType,
			trd.CpDocumentType
		INTO #TempRecoId
		FROM 
			#TempImportReconciliationData trd
			LEFT JOIN oregular.PurchaseDocumentDW PDRPR ON trd.PrDocumentNumber = PDRPR.DocumentNumber 
																AND trd.PrDocumentDateBigInt = PDRPR.DocumentDate 
																AND PDRPR.SourceType = 1 --AND 
																AND trd.PrDocumentType = PDRPR.DocumentType															
																AND trd.ParentEntityId = PDRPR.ParentEntityId
																AND ISNULL(PDRPR.IsAmendment,0) = ISNULL(trd.PrIsAmendment,0)
																AND ISNULL(trd.PrGstin,'') = ISNULL(PDRPR.BillFromGstin,'') 
																AND ISNULL(PDRPR.PortCode,'') = ISNULL(trd.PrPortCode,'')
			LEFT JOIN oregular.PurchaseDocumentDW PDRCP ON trd.CpDocumentNumber = PDRCP.DocumentNumber
																AND trd.CpDocumentDateBigInt = PDRCP.DocumentDate 
																AND PDRCP.SourceType IN (2,3)
																AND trd.CpDocumentType = PDRCP.DocumentType																														
																AND trd.ParentEntityId = PDRCP.ParentEntityId		
																AND ISNULL(PDRCP.IsAmendment,0) = ISNULL(trd.CpIsAmendment,0)
																AND ISNULL(trd.CpGstin,'') = ISNULL(PDRCP.BillFromGstin,'') 
																AND ISNULL(PDRCP.PortCode,'') = ISNULL(trd.CpPortCode,'')
		WHERE trd.ManualReconciliation = @FALSE;
			
	SELECT 
		*
	INTO #TempSettings
	FROM 
		@Settings;
			
	IF EXISTS (SELECT  1 FROM #TempRecoId)
	BEGIN
		DROP TABLE IF EXISTS #TempRecoMapperPr;				
		SELECT 
			pdrm.Id PrMApperId,
			pdrm.SectionType PrCurrentSection,  			
			tri.SectionType PrNewSection,
			tri.GroupId			
		INTO #TempRecoMapperPr
		FROM
			#TempRecoId tri
			LEFT JOIN oregular.Gstr2aDocumentRecoMapper pdrm ON tri.PrId = pdrm.PrId ;
	
		CREATE INDEX IdX_TempRecoMapperPr_GroupId ON #TempRecoMapperPr(GroupId);
	
		DROP TABLE IF EXISTS #TempRecoMapperGstn;				
		SELECT 
			pdrm.Id GstnMApperId,
			pdrm.SectionType GstnCurrentSection,  
			tri.SectionType GstnNewSection,
			tri.GroupId			
		INTO #TempRecoMapperGstn
		FROM
			#TempRecoId tri
			LEFT JOIN oregular.Gstr2aDocumentRecoMapper pdrm ON  tri.GstnId = pdrm.GstnId ;		
	
		UPDATE
			tri 
		SET IsPreserved = @TRUE  --'Section Type Doesnt Match'
		FROM 
			#TempRecoId tri
			INNER JOIN #TempRecoMapperPr pr  ON tri.GroupId = pr.GroupId
		WHERE 				
			PrCurrentSection <> PrNewSection;
	
	 	UPDATE
			tri
		SET IsPreserved = @TRUE  --'Section Type Doesnt Match'
		FROM 
			#TempRecoId tri 
			INNER JOIN #TempRecoMapperGstn pr  ON tri.GroupId = pr.GroupId 
		WHERE 					
			IsPreserved = @FALSE
			AND GstnCurrentSection <> GstnNewSection;				    			

		DELETE 
			r_pdrm
		FROM 
			Oregular.Gstr2aDocumentRecoMapper r_pdrm
		INNER JOIN #TempRecoId t_pdrm ON r_pdrm.PrId = t_pdrm.PrId AND  r_pdrm.GstnId = t_pdrm.GstnId				
		WHERE IsPreserved = @TRUE;					

		UPDATE  
		 PDRM
		SET PrId = NULL,
				SectionType = @ReconciliationSectionTypeGstOnly,
				Reason = NULL,
				ReasonType = NULL,	
				PredictableMatchBy = NULL,
				Stamp = @CURRENT_DATE,
				ModifiedStamp = @CURRENT_DATE,						
				PrReturnPeriodDate = NULL
		FROM 
			Oregular.Gstr2aDocumentRecoMapper PDRM
			INNER JOIN #TempRecoId tPDRM ON PDRM.PrId = tPDRM.PrId		 
		WHERE
			PDRM.GstnId IS NOT NULL
			AND IsPreserved = @TRUE;			


		UPDATE  
		PDRM
		SET GstnId = NULL,
			SectionType = @ReconciliationSectionTypePROnly,
			Reason = NULL,
			ReasonType = NULL,	
			PredictableMatchBy = NULL,
			Stamp = @CURRENT_DATE,
			ModifiedStamp = @CURRENT_DATE,
			GstnReturnPeriodDate = NULL
		FROM 
			Oregular.Gstr2aDocumentRecoMapper PDRM
			INNER JOIN #TempRecoId tPDRM ON  PDRM.GstnId = tPDRM.GstnId			
		WHERE  
			PDRM.PrId IS NOT NULL
			AND IsPreserved = @TRUE;			

			
		DELETE 
			r_pdrm
		FROM 
			Oregular.Gstr2aDocumentRecoMapper r_pdrm
		INNER JOIN #TempRecoId t_pdrm ON r_pdrm.PrId = t_pdrm.PrId
		WHERE 
			 r_pdrm.GstnId IS NULL
 			AND IsPreserved = @TRUE;			


		DELETE 
			r_pdrm
		FROM 
			Oregular.Gstr2aDocumentRecoMapper r_pdrm 
			INNER JOIN #TempRecoId t_pdrm ON  r_pdrm.GstnId = t_pdrm.GstnId	
		WHERE 
			r_pdrm.PrId IS NULL
			AND IsPreserved = @TRUE;			

		
		INSERT INTO Oregular.Gstr2aDocumentRecoMapper(DocumentFinancialYear,PrId,GstnId,SectionType,MappingType,Reason,ReasonType,IsCrossHeadTax,SessionId,ReconciledType,GstnReturnPeriodDate,PrReturnPeriodDate)
		SELECT 					
		ISNULL (FM.PRDocumentFinancialyear,FM.CPDocumentFinancialyear), FM.PrId, FM.GstnId, FM.SectionType SectionType,@ReconciliationMappingTypeTillDate AS MappingType, NULL AS Reason,0 ReasonType,@FALSE IsCrossHeadTax, -2 SessionId,@ReconciledTypeManual,				
		CASE WHEN FM.CPReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(FM.CPReturnPeriod,4), IIF(LEN(FM.CPReturnPeriod) = 6, LEFT(FM.CPReturnPeriod,2), CONCAT('0',LEFT(FM.CPReturnPeriod,1))), '01') ELSE NULL END,
		CASE WHEN PrReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(FM.PrReturnPeriod,4), IIF(LEN(FM.PrReturnPeriod) = 6, LEFT(FM.PrReturnPeriod,2), CONCAT('0',LEFT(FM.PrReturnPeriod,1))), '01') ELSE NULL END AS ReturnPeriodDate
		FROM 
			#TempRecoId FM
		Where IsPreserved = @TRUE;							

		/* ITC CLAIM RETURN PERIOD UPDATE */				
		IF(@IsRestrictItcClaim = 0)
		BEGIN
			UPDATE 
				PD 
			SET 
				ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
				Gstr3bSection = NULL
			FROM 
				#TempRecoId TRI
				INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
			WHERE 
				TRI.PRID IS NOT NULL 
				AND TRI.PrDocumentType = @DocumentTypeBOE
				--AND TRI.ItcClaimReturnPeriod IS NOT NULL						
		
			UPDATE 
				PD 
			SET 
				ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
				Gstr3bSection = NULL
			FROM 
				#TempRecoId TRI
				INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
			WHERE 
				TRI.Gstnid IS NOT NULL 
				AND TRI.CPDocumentType = @DocumentTypeBOE
				--AND TRI.ItcClaimReturnPeriod IS NOT NULL;						
		END
		ELSE
		BEGIN
			UPDATE 
				PD 
			SET 
				ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
				Gstr3bSection = NULL
			FROM 
				#TempRecoId TRI
				INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
			WHERE 
					TRI.PRID IS NOT NULL 
				AND TRI.ItcClaimReturnPeriod IS NOT NULL 
				AND PD.ItcClaimReturnPeriod IS NULL
				AND TRI.PrDocumentType = @DocumentTypeBOE;
		
			UPDATE 
				PD 
			SET 
				ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
				Gstr3bSection = NULL
			FROM 
				#TempRecoId TRI
				INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
			WHERE 
					TRI.Gstnid IS NOT NULL 
				AND TRI.ItcClaimReturnPeriod IS NOT NULL 
				AND PD.ItcClaimReturnPeriod IS NULL
				AND TRI.CpDocumentType = @DocumentTypeBOE;

		END

	END;

	/*
	/* Action Update */
	--Revert Actions 	
	SELECT 
		PR.GstnId Id
	INTO #TempRevertActions		
	FROM 
		#TempRecoId TRI
	INNER JOIN Oregular.Gstr2aDocumentRecoMapper  PR ON TRI.PrId = PR.PrId		
	INNER JOIN oregular.PurchaseDocumentStatus  PDR ON TRI.PrId = PDR.PurchaseDocumentId
	WHERE 
		(TRI.Action IS NOT NULL OR PDR.Action <> 1) AND PR.GstnId IS NOT NULL 	
	
	UNION
	
	SELECT 
		GSTN.PrId
	FROM 
		#TempRecoId TRI		
	INNER JOIN Oregular.Gstr2aDocumentRecoMapper  GSTN ON TRI.GstnId = GSTN.GstnId
	INNER JOIN oregular.PurchaseDocumentStatus  PDR ON TRI.PrId = PDR.PurchaseDocumentId
	WHERE 
		(TRI.Action IS NOT NULL OR PDR.Action <> 1) AND GSTN.GstnId IS NOT NULL 	

	UNION

	SELECT 
		TRI.PrId Id
	FROM 
		#TempRecoId	TRI
	INNER JOIN oregular.PurchaseDocumentStatus  PR ON TRI.PrId = PR.PurchaseDocumentId		
	WHERE 
		PR.Action IS NOT NULL AND TRI.SectionType = @ReconciliationSectionTypePROnly
	UNION
	SELECT 
		TRI.GstnId
	FROM 
		#TempRecoId TRI		
	INNER JOIN oregular.PurchaseDocumentStatus  GSTN ON TRI.PrId = GSTN.PurchaseDocumentId		
	WHERE 
		GSTN.Action IS NOT NULL 
		AND TRI.SectionType = @ReconciliationSectionTypeGstOnly;
			
	Update 
		 PR
	SET 
		Action = @ActionTypeNoAction,
		ReconciliationStatus = @ReconciliationStatusActionsNotTaken
	FROM
		oregular.PurchaseDocumentStatus PR
		INNER JOIN #TempRevertActions TRA ON TRA.Id = PR.PurchaseDocumentId;	

	DROP TABLE IF EXISTS #TempRevertActions;		
	UPDATE 
		PD 
	SET 
		Action = TRI.Action, 
		ReconciliationStatus = CASE WHEN tri.Action = @ActionTypeNoAction THEN @ReconciliationStatusActionsNotTaken ELSE @ReconciliationStatusActionsNotPushed END,
		ModifiedStamp = GETDATE()
	FROM
		oregular.PurchaseDocumentStatus AS PD 
		INNER JOIN #TempRecoId TRI ON PD.PurchaseDocumentId = TRI.PrId			 
	WHERE 
			TRI.PrId IS NOT NULL 
		AND TRI.Action <> PD.Action 
		AND TRI.Action IS NOT NULL;
	
	UPDATE 
		PD 
	SET 
		Action = TRI.Action, 
		ReconciliationStatus = CASE WHEN tri.Action = @ActionTypeNoAction THEN @ReconciliationStatusActionsNotTaken ELSE @ReconciliationStatusActionsNotPushed END,
		ModifiedStamp = GETDATE()
	FROM
		oregular.PurchaseDocumentStatus AS PD 
		INNER JOIN #TempRecoId TRI ON PD.PurchaseDocumentId = TRI.GstnId			 
	WHERE 
		TRI.GstnId IS NOT NULL AND tri.Action <> PD.Action AND TRI.Action IS NOT NULL;
	
	*/	
	IF EXISTS (SELECT * FROM #TempImportReconciliationData WHERE ManualReconciliation = @TRUE)
	BEGIN
		/*Getting Data for manual reconciliation*/
		SELECT 				
			ISNULL(PDRPR.SubscriberId,PDRCP.SubscriberId)SubscriberId,trd.Type,PDRPR.Id PrId, PDRCP.Id GstnId, trd.GroupId,ISNULL(PDRPR.ReturnPeriod,-1) PrReturnPeriod, 
			ISNULL(PDRCP.ReturnPeriod,-1) CPReturnPeriod, PDRPR.ParentEntityId PRParentEntityId,PDRCP.ParentEntityId CPParentEntityId ,trd.ReconciliationSection SectionType					
			,PDRPR.DocumentFinancialYear PRDocumentFinancialyear,PDRPR.FinancialYear PRRPFinancialyear,PDRCP.DocumentFinancialYear CPDocumentFinancialyear,PDRCP.FinancialYear CPRPFinancialyear
			,GroupKey,trd.Action,trd.ItcClaimReturnPeriod,@StatisticId StatisticId
			,trd.FinancialYear,trd.RecordName
		INTO #TempManualRecoData
		FROM 
			#TempImportReconciliationData trd
			LEFT JOIN oregular.PurchaseDocumentDW PDRPR ON trd.PrDocumentNumber = PDRPR.DocumentNumber 
															AND trd.PrGstin = PDRPR.BillFromGstin 
															AND trd.PrDocumentDateBigInt = PDRPR.DocumentDate 
															AND trd.PrDocumentType = PDRPR.DocumentType															
															AND trd.ParentEntityId = PDRPR.ParentEntityId
															AND PDRPR.SourceType = 1
															AND ISNULL(PDRPR.PortCode,'') = ISNULL(trd.PrPortCode,'')
															AND ISNULL(PDRPR.IsAmendment,0) = ISNULL(trd.PrIsAmendment,0)
			LEFT JOIN oregular.PurchaseDocumentDW PDRCP ON trd.CpDocumentNumber = PDRCP.DocumentNumber 
															AND trd.CpGstin = PDRCP.BillFromGstin 
															AND trd.CpDocumentDateBigInt = PDRCP.DocumentDate 
															AND trd.CpDocumentType = PDRCP.DocumentType															
															AND PDRCP.SourceType IN (2,3)
															AND trd.ParentEntityId = PDRCP.ParentEntityId		
															AND ISNULL(PDRCP.PortCode,'') = ISNULL(trd.CpPortCode,'')
															AND ISNULL(PDRCP.IsAmendment,0) = ISNULL(trd.CpIsAmendment,0)
		WHERE trd.ManualReconciliation = @TRUE;
		
		/*Delink already Manually Reconciled records */
		DECLARE @ManualMapperIds Common.BigIntType

		INSERT INTO @ManualMapperIds
		SELECT pdrmm.Id			
		FROM 
			oregular.PurchaseDocumentRecoManualMapper pdrmm
			CROSS APPLY (SELECT * FROM OPENJSON(pdrmm.PRIDS) WITH (PrId BIGINT))d
			INNER JOIN #TempManualRecoData ri ON ri.PrId = d.PrId
		WHERE 
			pdrmm.ReconciliationType = @ReconciliationType2a   
		
		UNION
		
		SELECT 
			pdrmm.Id
		FROM 
			oregular.PurchaseDocumentRecoManualMapper pdrmm
			CROSS APPLY (SELECT * FROM OPENJSON(pdrmm.GstIds) WITH (GstId BIGINT))d
			INNER JOIN #TempManualRecoData ri ON ri.GstnId =d.GstId
		WHERE 
			pdrmm.ReconciliationType = @ReconciliationType2a 
		   ;		
						
		CREATE TABLE #ReturnData 
		(
			SubscriberId INT,
			EntityId INT,
			FinancialYear INT							
		);
			
		IF EXISTS (SELECT 1 FROM @ManualMapperIds)
		BEGIN				
			INSERT INTO #ReturnData 
			(
				SubscriberId,
				EntityId,
				FinancialYear
			)
			EXEC oregular.DelinkReconciliationDocumentManual				
						@ManualMapperIds = @ManualMapperIds,
						@ExcludedGstin = @ExcludedGstin,
						@ActionTypeNoAction =@ActionTypeNoAction,						
						@ReconciliationType = @ReconciliationType2b,						
						@AuditTrailDetails =@AuditTrailDetails,
						@ReconciliationStatusActionsNotTaken = 1,					
						@ReconciliationSectionTypePROnly = @ReconciliationSectionTypePROnly,
						@ReconciliationSectionTypeGstOnly = @ReconciliationSectionTypeGstOnly,
						@ReconciliationTypeGstr2b = @ReconciliationType2b,
						@ReconciliationMappingTypeTillDate = @ReconciliationMappingTypeTillDate,
						@ReconciliationSectionTypePRExcluded = @ReconciliationSectionTypePRExcluded,
						@ReconciliationSectionTypeGstExcluded = @ReconciliationSectionTypeGstExcluded
		END
 		ELSE
			BEGIN

				SELECT 								
					r.SubscriberId,
					r.EntityId,
					r.FinancialYear			
				FROM #ReturnData r		;
				
		END;	
			 
			/* Insert record in PurchaseDocumentRecoManualMapper table */
			INSERT INTO oregular.PurchaseDocumentRecoManualMapper
			(
				SubscriberId,
				ParentEntityId,
				RPFinancialYear,
				DocumentFinancialYear,
				RecordName,
				SectionType,
				MappingType,
				PrIds,
				GstIds,
				Reason,
				IsAvailableInGstr2b,
				StatisticId,
				ReconciliationType	   
			)
			SELECT
				tmrd.SubscriberId,
				ISNULL(PRParentEntityId,CPParentEntityId),
				MAX(COALESCE(tmrd.FinancialYear,CPRPFinancialyear,PRRPFinancialyear)),
			    MIN(ISNULL(CPDocumentFinancialyear,PRDocumentFinancialyear)),
				MAX(ISNULL(tmrd.RecordName,'Import')),
				tmrd.SectionType,
				@ReconciliationMappingTypeTillDate,
				MAX(d.PrIds),
				MAX(Gst.GstnIds),
				NULL Reason,
				@FALSE,
				@StatisticId,
				@ReconciliationType2a						  
			FROM 
				#TempManualRecoData tmrd
				CROSS APPLY (SELECT (SELECT pd.PrId  FROM #TempManualRecoData pd WHERE tmrd.GroupKey = pd.GroupKey AND PrId IS NOT NULL for json auto) PrIds)d
				CROSS APPLY (SELECT (SELECT gstn.GstnId GstId FROM #TempManualRecoData Gstn WHERE tmrd.GroupKey = Gstn.GroupKey AND GstnId IS NOT NULL for json auto) GstnIds)Gst
			GROUP BY tmrd.SubscriberId,ISNULL(PRParentEntityId,CPParentEntityId), GroupKey,Type,tmrd.SectionType;
			
			UPDATE  PDRM
				SET PrId = NULL,
					SectionType = @ReconciliationSectionTypeGstOnly,
					Reason = NULL,
					ReasonType = NULL,
					IsCrossHeadTax  = @FALSE,
					PrReturnPeriodDate = NULL
			FROM
				Oregular.Gstr2aDocumentRecoMapper PDRM
				INNER JOIN #TempManualRecoData Pr ON Pr.PrId = PDRM.PrId	
			WHERE				
				PDRM.GstnId IS NOT NULL;
		
			UPDATE  PDRM
			SET GstnId = NULL,
				SectionType = @ReconciliationSectionTypePROnly,
				Reason = NULL,
				ReasonType = NULL,
				IsCrossHeadTax  = @FALSE,
				GstnReturnPeriodDate = NULL						
			FROM
				Oregular.Gstr2aDocumentRecoMapper PDRM
				INNER JOIN #TempManualRecoData Gst ON Gst.GstnId = PDRM.GstnId
			WHERE 
				PDRM.PrId IS NOT NULL
				;
								
			UPDATE 
				PS
			SET 
				Action =@ActionTypeNoAction,
				ReconciliationStatus = @ReconciliationStatusActionsNotTaken,
				ActionDate = NULL
			FROM
				oregular.PurchaseDocumentStatus PS
				INNER JOIN #TempManualRecoData Pr ON Pr.PrId = PS.PurchaseDocumentId
			WHERE 
				PrId IS NOT NULL
				;
																																																					 
			UPDATE 
				 PS
			SET 
				Action = @ActionTypeNoAction,
				ReconciliationStatus = @ReconciliationStatusActionsNotTaken	
			FROM
				oregular.PurchaseDocumentStatus PS
				INNER JOIN #TempManualRecoData Gst ON Gst.GstnId = PS.PurchaseDocumentId
			WHERE 
				GstnId IS NOT NULL;
				
		DELETE		
			PDRM				
		FROM
			Oregular.Gstr2aDocumentRecoMapper PDRM				
		INNER JOIN #TempManualRecoData Pr ON  Pr.PrId = PDRM.PrId
			WHERE 
				PDRM.GstnId IS NULL;				

		DELETE				
			PDRM
		FROM
			Oregular.Gstr2aDocumentRecoMapper PDRM
		INNER JOIN #TempManualRecoData Gst	ON Gst.GstnId = PDRM.GstnId			
		WHERE 
	 		PDRM.PrId IS NULL;	

		/*	
		/* Action UPDATE FOR MANUAL DATA*/
		UPDATE oregular.PurchaseDocumentStatus AS PD 
		SET 
			Action = TRI.Action, 
			ReconciliationStatus = CASE WHEN tri.Action = @ActionTypeNoAction THEN @ReconciliationStatusActionsNotTaken ELSE @ReconciliationStatusActionsNotPushed END,
			ModifiedStamp = GETDATE()::TIMESTAMP(3)	
		FROM 
			#TempManualRecoData TRI				
		WHERE 
			PD.PurchaseDocumentId = TRI.PrId
			AND TRI.PrId IS NOT NULL 
			AND TRI.Action <> PD.Action
			AND TRI.Action IS NOT NULL;

			
		UPDATE 
			oregular.PurchaseDocumentStatus AS PD 
		SET 
			Action = TRI.Action, 
			ReconciliationStatus = CASE WHEN tri.Action = @ActionTypeNoAction THEN @ReconciliationStatusActionsNotTaken ELSE @ReconciliationStatusActionsNotPushed END,
			ModifiedStamp = GETDATE()::TIMESTAMP(3)	
		FROM 
			#TempManualRecoData TRI				
		WHERE 
			TRI.GstnId IS NOT NULL 
			AND TRI.Action <> PD.Action 
			AND TRI.Action IS NOT NULL
			AND PD.PurchaseDocumentId = TRI.GstnId;
			
		*/
	END;
	END;
	IF EXISTS(SELECT 1 FROM @Documents WHERE Source = @ReconciliationSourceType2b)
	BEGIN
		EXEC oregular.InsertGstr2bReconciliationDocuments
			@Documents=@Documents,
			@StatisticId=@StatisticId ,
			@ReconciledTypeManual=@ReconciledTypeManual,
			@ActionTypeNoAction=@ActionTypeNoAction,			
			@IsRestrictItcClaim=@IsRestrictItcClaim,
			@ReconciliationSourceType2b=@ReconciliationSourceType2b,
			@ReconciliationSectionTypeGstOnly=@ReconciliationSectionTypeGstOnly, 
			@ReconciliationSectionTypePROnly=@ReconciliationSectionTypePROnly, 			
			@ReconciliationMappingTypeTillDate=@ReconciliationMappingTypeTillDate, 
			@ExcludedGstin=@ExcludedGstin, 			
			@ReconciliationSectionTypePRExcluded=@ReconciliationSectionTypePRExcluded, 
			@ReconciliationSectionTypeGstExcluded=@ReconciliationSectionTypeGstExcluded, 
			@ReconciliationType2b=@ReconciliationType2b, 
			@ReconciliationType2a=@ReconciliationType2a, 
			@AuditTrailDetails =@AuditTrailDetails;
	END;
END;

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[subscriber].[DeleteSeries] 
* 	Comments			:	23-06-2021 | Komal PArmar | This procedure is used to delete Notification reply
						:   13-05-2024 | Chandresh Prajapati | Added AuditTrailDetails Parameter
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		:   DECLARE  @TotalRecord INT,
								@Ids [common].[IntType]

						 -- INSERT INTO @Ids VALUES (2);

						  EXEC [subscriber].[DeleteNotificationReplies]
								@Ids =  @Ids,
								@SubscriberId  = 164 ,
								@Actions = null,
								@Internal = null,
								@statuses =null,
								@StatusTypeDelete = 3,
						  		@Start  = 0,
						  		@Size  = 1000,
						  		@TotalRecord  = @TotalRecord OUT
						  		Select @TotalRecord;
--------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [subscriber].[DeleteNotificationReplies]
(
	@Ids [common].[IntType] READONLY,
	 @SubscriberId INT,
	 @ActionsRequired VARCHAR(max),
	 @Actions VARCHAR(max),
	 @Internal bit NULL,
	 @Statuses VARCHAR(max),
	 @StatusTypeDelete SMALLINT,
	 @Start INT,
	 @Size INT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @TotalRecord INT = NULL OUTPUT
)
AS
BEGIN	
	SET NOCOUNT ON;

	CREATE TABLE #TempIds
	(
		Id BIGINT
	);

	INSERT INTO #TempIds(Id)
	EXEC [subscriber].[FilterNotificationReplies]
		@Ids = @Ids,
		@SubscriberId = @SubscriberId,
		@ActionsRequired = @ActionsRequired,
		@Actions = @Actions,
		@Internal = @Internal,
		@Statuses = @Statuses,
		@StatusTypeDelete = @StatusTypeDelete,
		@Start = @Start,
		@Size = @Size ,
		@TotalRecord = @TotalRecord OUTPUT

	CREATE TABLE #TempDeletabalIds
	(
		Id BIGINT
	);

	INSERT INTO #TempDeletabalIds
	SELECT 
		ids.Id
	FROM
		#TempIds ids
	WHERE 
		ids.Id NOT IN (SELECT nd.actionTaken FROM GST.NotificationDocumentMapper nd WHERE nd.actionTaken = ids.Id)

	UPDATE
		Subscriber.[NotificationReply]
	SET
		[STATUS] = @StatusTypeDelete
	WHERE 
		Id in (SELECT tsna.Id FROM #TempDeletabalIds tsna)
			
	DROP TABLE #TempIds,#TempDeletabalIds;
END
GO
--CREATE TYPE [audit].[AuditTrailDetailsType] AS TABLE
--(
--	[RequestId] UNIQUEIDENTIFIER,
--	[UserId] INT,
--	[UserAction] smallint,
--	[RequestIpAddress] VARCHAR(40),
--	[IsEnabled] BIT,
--	[IsSkipActionTrail] BIT
--);


/*-----------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[audit].[UpdateAuditDetails]
* 	Comments			:	01-04-2024 | Dhruv Amin | This procedure is used for Temp table fpr Audit Details .
-------------------------------------------------------------------------------------------------------------
*   Test Execution	    :	EXEC [audit].[UpdateAuditDetails]
								@AuditTrailDetails =  NULL
*/-----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [audit].[UpdateAuditDetails]
(
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	DROP TABLE IF EXISTS #TempCurrentAppUser;

	SELECT
		RequestId,
		UserId AS AuditUserId,
		UserAction,
		RequestIpAddress AS AuditIpAddress,
		IsEnabled,
		IsSkipActionTrail
	INTO
		#TempCurrentAppUser
	FROM  
		@AuditTrailDetails;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[DeleteDocumentByIds] 	 	 
* 	Comments			: 24-06-2020 | Kartik Bariya | This procedure is used to Delete EInvoice Documents By Ids.
						: 21-07-2020 | Pooja Rajpurohit |Changes for Optimization: Added delete code for New table created.
						: 28-07-2020 | Pooja Rajpurohit | Renamed table DocumentWh to DocumentDW
						: 27-11-2020 | Sagar Patel		| Returned result containing  EntityId and Financial year
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE  @TotalRecord INT,
								@Ids [common].[BigIntType];
						  INSERT INTO @Ids VALUES (11744);

						  EXEC [einvoice].[DeleteDocumentByIds]
								@Ids =  @Ids,
								@PurposeTypeEINV = 2,
								@PurposeTypeEWB = 8,
								@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[DeleteDocumentByIds] 	 	 
(
	 @Ids [common].[BigIntType] READONLY,
	 @PurposeTypeEINV SMALLINT,
	 @PurposeTypeEWB SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @TotalRecord INT = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempEInvoiceDocumentIds
	(
		Id BIGINT
	);

	CREATE TABLE #TempEInvoiceDocumentIdsEINVPurpose(
		Id BIGINT NOT NULL
	);
	CREATE TABLE #TempEInvoiceDocumentIdsEINVEWBPurpose(
		Id BIGINT NOT NULL
	);

	CREATE NONCLUSTERED INDEX IDX_TempEInvoiceDocumentIds_Id ON #TempEInvoiceDocumentIds(Id);
	CREATE CLUSTERED INDEX IDX_#TempEInvoiceDocumentIdsEINVPurpose ON #TempEInvoiceDocumentIdsEINVPurpose(Id);
	CREATE CLUSTERED INDEX IDX_#TempEInvoiceDocumentIdsEINVEWBPurpose ON #TempEInvoiceDocumentIdsEINVEWBPurpose(Id);
	
	INSERT INTO #TempEInvoiceDocumentIds (Id) 
	SELECT
		Item
	FROM
		@Ids;


	SELECT
		DISTINCT
		eid.ParentEntityId AS EntityId,
		eid.FinancialYear AS FinancialYear
	INTO
		#EntityDetails
	FROM
		einvoice.DocumentDW AS eid
		INNER JOIN #TempEInvoiceDocumentIds AS teidi ON teidi.Id = eid.Id

	--Store Ids to #TempEInvoiceDocumentIdsEINVPurpose which have purpose Einvoice
	INSERT INTO #TempEInvoiceDocumentIdsEINVPurpose(
		Id
	)
	SELECT 
		teidi.Id
	FROM 
		#TempEInvoiceDocumentIds AS teidi
		INNER JOIN einvoice.DocumentDW AS eid ON teidi.Id = eid.Id
	WHERE
		eid.Purpose = @PurposeTypeEINV

	--Store Ids to #TempEInvoiceDocumentIdsEINVEWBPurpose which have purpose Einvoice and Ewaybill both
	INSERT INTO #TempEInvoiceDocumentIdsEINVEWBPurpose(
		Id
	)
	SELECT 
		teidi.Id
	FROM 
		#TempEInvoiceDocumentIds AS teidi
		INNER JOIN einvoice.DocumentDW AS eid ON teidi.Id = eid.Id
	WHERE
		eid.Purpose = (@PurposeTypeEINV | @PurposeTypeEWB);
	
	--Update purpose to einvoice only if both status is there
	IF EXISTS (SELECT Id FROM #TempEInvoiceDocumentIdsEINVEWBPurpose)
	BEGIN
		UPDATE 
			einvoice.Documents 
		SET 
			Purpose = @PurposeTypeEWB
		FROM 
			#TempEInvoiceDocumentIdsEINVEWBPurpose AS teidi
			INNER JOIN einvoice.Documents AS d	ON teidi.Id = d.Id

		UPDATE 
			einvoice.DocumentDW
		SET 
			Purpose = @PurposeTypeEWB
		FROM 
			#TempEInvoiceDocumentIdsEINVEWBPurpose AS teidi
			INNER JOIN einvoice.DocumentDW AS dwh ON teidi.Id = dwh.Id
	END

	--Delete Ids which have purpose EINV only
	IF EXISTS (SELECT Id FROM #TempEInvoiceDocumentIdsEINVPurpose)
	BEGIN
		
		DELETE 
		dsd
		FROM 
			einvoice.DocumentSignedDetails dsd
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = dsd.DocumentId

		DELETE 
		dr 
		FROM 
			einvoice.DocumentReferences dr 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = dr.DocumentId
		
		DELETE 
			eidi 
		FROM 
			einvoice.DocumentItems eidi 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eidi.DocumentId
		
		DELETE 
			eids
		FROM 
			einvoice.DocumentStatus eids 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eids.DocumentId

		DELETE 
			ds
		FROM 
			ewaybill.DocumentStatus ds 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = ds.DocumentId
		
		DELETE	
			eic
		FROM 
			einvoice.DocumentContacts eic 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eic.Documentid

		DELETE	
			eip
		FROM 
			einvoice.DocumentPayments eip 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eip.DocumentId

		DELETE	
			eicu
		FROM 
			einvoice.DocumentCustoms eicu
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eicu.DocumentId

		DELETE	
			eid
		FROM 
			einvoice.Documents eid 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eid.Id

		DELETE	
			eid
		FROM 
			einvoice.DocumentDW eid 
			INNER JOIN  #TempEInvoiceDocumentIdsEINVPurpose teidi ON teidi.Id = eid.Id
	END

	SELECT
		ED.EntityId,
		ED.FinancialYear
	FROM 
		#EntityDetails ED

	DROP TABLE #TempEInvoiceDocumentIds, #TempEInvoiceDocumentIdsEINVPurpose, #TempEInvoiceDocumentIdsEINVEWBPurpose, #EntityDetails;
END

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

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[InsertDownloadedDocuments]
* 	Comments			: 17-01-2020 | Amit Khanna | This procedure is used to insert download einvoice.
* 	Change 1 			: 23-01-2020 | Amit Khanna | Added Parameter EntityIds which contains child location to check if the downloaded record exists in child or not.
* 			 			: 19-03-2020 | Amit Khanna | Removed Status Paramter.Added/Deleted Table Columns while inserting updating values according to new einvoice changes.
* 			 			: 08-04-2020 | Amit Khanna | Removed Parameter EntityIds.Now it will check parent EntityId in Where Condition.
* 			 			: 15-05-2020 | Amit Khanna | Inserting Value in Status column in DocumentStatus.
* 			 			: 08-06-2020 | Amit Khanna | Removed VehicleDetailTypeVehicleDetailAdded parameter.
						: 06-07-2020 | Smita Parmar| Added EInvoiceStatus and EwayBillStatus into DownloadedDocumentType for status, move status related logic into C# code
													 Vehicle Details IsLatest related changes and corrected column name for IsEInvoicePushed, IsEwayBillPushed
						: 10-07-2020 | Prakash Parmar | Renamed BillToLegalName to BillToTradeName, BillFromLegalName to BillFromTradeName
						: 21-07-2020 | Pooja Rajpurohit | Changes for Optimization - Added Insert and Update code portion for new table created
						: 27-07-2020 | Amit Khanna | Added Condition to Update whole records if push status is yet not geneateated and update partially if record is in generated or cancelled status 
						: 28-07-2020 | Pooja Rajpurohit | Removed insert and update portion from sp and called another sp for same task.
						: 31-07-2020 | Amit Khanna | Added DocumentReference Parameter.Removed parameters StatisticId,BitTypeY,BitTypeN.Changed Logic to identify records to be updated partially or fully update.
						: 06-08-2020 | Amit Khanna | Added Columns UnderIgstAct and ExportDuty in Documents Table.
						: 11-08-2020 | Prakash Parmar | Added Columns DocumentDiscount and DocumentOtherCharges in Documents Table.
						: 18-08-2020 | Chandresh Prajapati | Split table in DocumentContacts and DocumentPayments
						: 08-09-2020 | Chandresh Prajapati | Removed QRCode, QRCodeData and inserted SignedInvoice and SignedQRCode into einvoice.DocumentSignedDetails
						: 22-09-2020 | Chandresh Prajapati | Moved distance column from einvoice.documents to ewaybill.documentstatus
						: 29-09-2020 | Chandresh Prajapati | Changed GeneratedDate = AckDate and PushDate = AckDate
						: 02-11-2020 | Prakash Parmar | Added IsDuplicateIrn flag to make errors to null
						: 22-04-2021 | Chandresh Prajapati | Added Parameter DocumentStatusDraft,DocumentStatusApproved and DocumentStatusRejected
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: DECLARE @Documents AS [einvoice].[DownloadedDocumentType] 
						  DECLARE @DocumentItems AS [einvoice].[DownloadedDocumentItemType]
						  DECLARE @DocumentReferences AS [common].[DocumentReferenceType]
						  DECLARE @EntityIds AS [common].[IntType];
						  EXEC [einvoice].[InsertDownloadedDocuments]
								@SubscriberId  = 164,
								@UserId = 486,
								@EntityId = 340,
								@SourceType = 1,
								@SupplyType = 1,
								@Documents = @Documents,
								@DocumentItems = @DocumentItems,
								@DocumentReferences = @DocumentReferences,
								@EInvoicePushStatusYetNotGenerated = 1,
								@EwayBillPushStatusYetNotGenerated =  1,
								@DocumentContactTypeBillFrom SMALLINT =1,
								@DocumentContactTypeBillTo SMALLINT = 2,
								@DocumentContactTypeDispatchFrom SMALLINT = 3,
								@DocumentContactTypeShipTo SMALLINT = 4,
								@DocumentStatusYetNotGenerated = 1,
								@DocumentStatusGenerated = 2,
								@DocumentStatusCompleted = 3,
								@DocumentTypeDBN = 3,
								@DocumentTypeCRN = 2,
								@DocumentStatusDraft = 4,
								@DocumentStatusApproved = 5,
								@DocumentStatusRejected = 6,
								@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[InsertDownloadedDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@SourceType SMALLINT,
	@SupplyType SMALLINT,
	@Documents [einvoice].[DownloadedDocumentType] READONLY,
	@DocumentItems [einvoice].[DownloadedDocumentItemType] READONLY,
	@DocumentContacts [einvoice].[DownloadedDocumentContactType] READONLY,
	@DocumentPayments [einvoice].[DownloadedDocumentPaymentType] READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@IsDuplicateIrn BIT,
	@IsGstRequest BIT,
	@EInvoicePushStatusYetNotGenerated SMALLINT,
	@EwayBillPushStatusYetNotGenerated SMALLINT,
	@EInvoicePushStatusGenerated smallint,
	@EInvoicePushStatusCancelled smallint,
	@DocumentContactTypeBillFrom SMALLINT,
	@DocumentContactTypeBillTo SMALLINT,
	@DocumentContactTypeDispatchFrom SMALLINT,
	@DocumentContactTypeShipTo SMALLINT,
	@DocumentStatusYetNotGenerated SMALLINT,
	@DocumentStatusGenerated SMALLINT,
	@DocumentStatusCompleted SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentStatusDraft SMALLINT,
	@DocumentStatusApproved SMALLINT,
	@DocumentStatusRejected SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CurrentDate DATETIME = GETDATE(),
			@BitTypeN BIT = 0,
			@BitTypeY BIT = 1;

	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL,
		GroupId INT NOT NULL
	);

	CREATE CLUSTERED INDEX IDX_#TempUpsertDocumentIds_GROUPID ON #TempUpsertDocumentIds(GroupId)

	CREATE TABLE #TempDocumentIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		Mode CHAR (2),
		GeneratedDate SMALLDATETIME,
		[Priority] SMALLINT
	);
	
	CREATE INDEX  IDX_TempDocumentIds_GroupId ON #TempDocumentIds(GroupId) INCLUDE(Id);

	CREATE TABLE #TempDocuments(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		[Id] [bigint]  NULL,
		[EntityId] [int] NOT NULL,
		[UserId] [int] NOT NULL,
		[SupplyType] [smallint] NOT NULL,
		[PurposeType] [smallint] NOT NULL,
		[Irn] [varchar](64) NULL,
		[Type] [smallint] NOT NULL,
		[TransactionType] [smallint] NULL,
		[DocumentNumber] [varchar](40) NOT NULL,
		[DocumentDate] [smalldatetime] NOT NULL,
		[TransactionMode] [smallint] NULL,
		[UnderIgstAct] [BIT] NOT NULL,
		[RefDocumentRemarks] [varchar](100) NULL,
		[RefDocumentPeriodStartDate] [smalldatetime] NULL,
		[RefDocumentPeriodEndDate] [smalldatetime] NULL,
		[RefPrecedingDocumentDetails] [varchar](max) NULL,
		[RefContractDetails] [varchar](max) NULL,
		[AdditionalSupportingDocumentDetails] [varchar](max) NULL,
		[BillNumber] [varchar](20) NULL,
		[BillDate] [smalldatetime] NULL,
		[PortCode] [varchar](10) NULL,
		[DocumentCurrencyCode] [varchar](3) NULL,
		[DestinationCountry] [varchar](2) NULL,
		[ExportDuty] [decimal](14,2) NULL,
		[POS] [smallint] NULL,
		[DocumentValue] [decimal](18, 2) NULL,
		[DocumentDiscount] [decimal](18, 2) NULL,
		[DocumentOtherCharges] [decimal](18, 2) NULL,
		[DocumentValueInForeignCurrency] [decimal](18, 2) NULL,
		[DocumentValueInRoundOffAmount] [decimal](6, 2) NULL,
		[ReverseCharge] [bit] NOT NULL,
		[ClaimRefund] [bit] NOT NULL,
		[ECommerceGstin] [varchar](15) NULL,
		[EwayBillNumber] [varchar](20) NULL,
		[EwayBillDate] [smalldatetime] NULL,
		[EwayBillValidTill] [smalldatetime] NULL,
		[TransporterID] [varchar](15) NULL,
		[TransporterName] [varchar](200) NULL,
		[TransportDateTime] [smalldatetime] NULL,
		[Distance] [smallint] NULL,
		[TransportMode] [smallint] NULL,
		[TransportDocumentNumber] [varchar](15) NULL,
		[TransportDocumentDate] [smalldatetime] NULL,
		[VehicleNumber] [varchar](20) NULL,
		[VehicleType] [smallint] NULL,
		[ToEmailAddresses] [varchar](324) NULL,
		[ToMobileNumbers] [varchar](54) NULL,
		[TotalTaxableValue] [decimal](18, 2) NOT NULL,
		[TotalTaxAmount] [decimal](18, 2) NOT NULL,
		[ReturnPeriod] [int] NOT NULL,
		[DocumentFinancialYear] [int] NOT NULL,
		[IsAmendment] [bit] NOT NULL,
		[AckNumber] [varchar](36) NULL,
		[AckDate] [datetime] NULL,
		[SignedInvoice] [varbinary](max) NULL,
		[SignedQRCode] [varchar](max) NULL,
		[EInvoicePushStatus] [smallint] NOT NULL,
		[IsEInvoicePushed] [bit] NOT NULL,
		[EwayBillPushStatus] [smallint] NOT NULL,
		[IsEwayBillPushed] [bit] NOT NULL,
		[GroupId] [int] NOT NULL,
		[Errors] [varchar](2000) NULL,
		[EInvoiceStatus] [smallint] NOT NULL,
		[EwayBillStatus] [smallint] NOT NULL,
		[CancellationDate] [smalldatetime] NULL,
		[CancellationReason] [smallint]	NULL,
		[CancellationRemark] VARCHAR(250) NULL,
		[Mode] CHAR (2) NULL,
		[Provider] SMALLINT NULL
	);

	INSERT INTO #TempDocuments
	(
		[EntityId],
		[UserId],
		[SupplyType],
		[PurposeType],
		[Irn],
		[Type],
		[TransactionType],
		[DocumentNumber],
		[DocumentDate],
		[TransactionMode],
		[UnderIgstAct],
		[RefDocumentRemarks],
		[RefDocumentPeriodStartDate],
		[RefDocumentPeriodEndDate],
		[RefPrecedingDocumentDetails],
		[RefContractDetails],
		[AdditionalSupportingDocumentDetails],
		[BillNumber],
		[BillDate],
		[PortCode],
		[DocumentCurrencyCode],
		[DestinationCountry],
		[ExportDuty],
		[POS],
		[DocumentValue],
		[DocumentDiscount],
		[DocumentOtherCharges],
		[DocumentValueInForeignCurrency],
		[DocumentValueInRoundOffAmount],
		[ReverseCharge],
		[ClaimRefund],
		[ECommerceGstin],
		[EwayBillNumber],
		[EwayBillDate],
		[EwayBillValidTill],
		[TransporterID],
		[TransporterName],
		[TransportDateTime],
		[Distance],
		[TransportMode],
		[TransportDocumentNumber],
		[TransportDocumentDate],
		[VehicleNumber],
		[VehicleType],
		[ToEmailAddresses],
		[ToMobileNumbers],
		[TotalTaxableValue],
		[TotalTaxAmount],
		[ReturnPeriod],
		[DocumentFinancialYear],
		[IsAmendment],
		[AckNumber],
		[AckDate],
		[SignedInvoice],
		[SignedQRCode],
		[EInvoicePushStatus],
		[IsEInvoicePushed],
		[EwayBillPushStatus],
		[IsEwayBillPushed],
		[GroupId],
		[EInvoiceStatus],
		[EwayBillStatus],
		[CancellationDate],
		[CancellationReason],
		[CancellationRemark],
		[Provider]
	)
	SELECT 
		@EntityId,
		@UserId,
		ted.SupplyType,
		ted.PurposeType,
		ted.IRN,
		ted.[Type],
		ted.TransactionType,
		ted.DocumentNumber,
		ted.DocumentDate,
		ted.TransactionMode,
		ted.UnderIgstAct,

		ted.RefDocumentRemarks,
		ted.RefDocumentPeriodStartDate,
		ted.RefDocumentPeriodEndDate,
		ted.RefPrecedingDocumentDetails,
		ted.RefContractDetails,
		ted.AdditionalSupportingDocumentDetails,

		ted.BillNumber,
		ted.BillDate,
		ted.PortCode,
		ted.DocumentCurrencyCode,
		ted.DestinationCountry,
		ted.ExportDuty,
		ted.POS,

		ted.DocumentValue,
		ted.DocumentDiscount,
		ted.DocumentOtherCharges,
		ted.DocumentValueInForeignCurrency,
		ted.DocumentValueInRoundOffAmount,
		ted.ReverseCharge,
		ted.ClaimRefund,
		ted.ECommerceGstin,

		ted.EwayBillNumber,
		ted.EwayBillDate,
		ted.EwayBillValidTill,
		ted.TransporterID,
		ted.TransporterName,
		ted.TransportDateTime,
		ted.Distance,
		ted.TransportMode,
		ted.TransportDocumentNumber,
		ted.TransportDocumentDate,
		ted.VehicleNumber,
		ted.VehicleType,
		ted.ToEmailAddresses,
		ted.ToMobileNumbers,

		ted.TotalTaxableValue,
		ted.TotalTaxAmount,
		ted.ReturnPeriod,
		ted.DocumentFinancialYear,
		ted.IsAmendment,
		ted.AckNumber,
		ted.AckDate,
		ted.SignedInvoice,
		ted.SignedQRCode,
		ted.EInvoicePushStatus,
		ted.IsEInvoicePushed,
		ted.EwayBillPushStatus,
		ted.IsEwayBillPushed,
		ted.GroupId,
		ted.EInvoiceStatus,
		ted.EwayBillStatus,
		ted.CancellationDate,
		ted.CancellationReason,
		ted.CancellationRemark,
		ted.[Provider]
	FROM 
		@Documents ted;

	SELECT
		*
	INTO 
		#TempDocumentContacts
	FROM
		@DocumentContacts;

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode,
		GeneratedDate,
		[Priority]
	)
	SELECT
		ed.Id,
		ted.GroupId,
		Mode = (CASE 
		  	WHEN @IsGstRequest = 1 AND ds.[PushStatus] = @EInvoicePushStatusGenerated AND ted."EInvoicePushStatus" = @EInvoicePushStatusCancelled THEN 'PU'
		  	WHEN @IsGstRequest = 1 THEN 'S'
			WHEN ds.[Status] = @DocumentStatusGenerated THEN 'PU'
			WHEN eds.[Status] = @DocumentStatusGenerated AND ds.[Status] IN (@DocumentStatusYetNotGenerated,@DocumentStatusDraft,@DocumentStatusApproved,@DocumentStatusRejected) 
			THEN 
				CASE 
					WHEN ds.PushStatus  = 6 
					THEN 'U' ELSE 'PU' 
				END
			WHEN ds.[Status] IN (@DocumentStatusYetNotGenerated,@DocumentStatusDraft,@DocumentStatusApproved,@DocumentStatusRejected) THEN 'U'
			WHEN ds.[Status] = @DocumentStatusCompleted  THEN 'S' 
		END),
		ds.GeneratedDate,
		CASE
			WHEN eds.EwayBillNumber = ted.EwayBillNumber THEN 2 /*Matched*/
			WHEN ted.EwayBillNumber IS NULL OR eds.EwayBillNumber IS NULL THEN 1 /*Near Matched*/
			ELSE 0 /*Not Matched*/
		END
	FROM
		#TempDocuments ted
		INNER JOIN einvoice.Documents AS ed ON
		(
			ed.ParentEntityId = @EntityId
			AND ed.SupplyType =  @SupplyType
			AND ed.DocumentFinancialYear  =  ted.DocumentFinancialYear
			AND ed.[Type] = ted.[Type]
			AND ed.DocumentNumber = ted.DocumentNumber
		)
		INNER JOIN einvoice.DocumentContacts as edc ON 
		(
			ed.Id = edc.DocumentId AND edc.Type = @DocumentContactTypeBillFrom
		)
		INNER JOIN #TempDocumentContacts tdc ON
		(
			 tdc.GroupId = ted.GroupId AND tdc.[Type] = @DocumentContactTypeBillFrom AND tdc.Gstin = edc.Gstin
		)
		INNER JOIN ewaybill.DocumentStatus eds ON
		(
			 eds.DocumentId = ed.Id
		)
		INNER JOIN einvoice.DocumentStatus ds ON
		(
			 ds.DocumentId = ed.Id
		);

	DELETE 
	FROM 
		#TempDocumentIds 
	WHERE 
		[Priority] = 0 
		OR 
		(
			[Priority] = 1 AND GroupId IN (SELECT GroupId FROM #TempDocumentIds WHERE [Priority] = 2)
		);

	;WITH cte
	 AS
	 (
	 	SELECT ROW_NUMBER() OVER(Partition by GroupId order by GeneratedDate desc) rownum,*
	 	FROM 
	 		#TempDocumentIds
	 )
	 DELETE FROM cte WHERE rownum > 1;

	SELECT
		*
	INTO 
		#TempDocumentItems
	FROM
		@DocumentItems;

	SELECT
		*
	INTO 
		#TempDocumentReferences
	FROM
		@DocumentReferences;

	SELECT
		*
	INTO 
		#TempDocumentPayments
	FROM
		@DocumentPayments;

	INSERT INTO einvoice.Documents
	(
		SubscriberId,
		EntityId,
		ParentEntityId,
		UserId,
		SupplyType,
		Purpose,
		[Type],
		TransactionType,
		DocumentNumber,
		DocumentDate,
		TransactionMode,
		UnderIgstAct,

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
		ECommerceGstin,

		TransporterID,
		TransporterName,
		ToEmailAddresses,
		ToMobileNumbers,

		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		FinancialYear,
		DocumentFinancialYear,
		SourceType,
		GroupId,
		DocumentReturnPeriod
	)
	OUTPUT 
		inserted.Id, inserted.GroupId, 'I'
	INTO 
		#TempDocumentIds(Id, GroupId, Mode)
	SELECT
		@SubscriberId,  
		EntityId,
		EntityId,
		UserId,
		@SupplyType,
		PurposeType,
		[Type],
		TransactionType,
		DocumentNumber,
		DocumentDate,
		TransactionMode,
		UnderIgstAct,

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
		ECommerceGstin,
		
		TransporterID,
		TransporterName,
		ToEmailAddresses,
		ToMobileNumbers,

		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		DocumentFinancialYear,
		@SourceType,
		GroupId,
		ReturnPeriod
	FROM
		#TempDocuments
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempDocumentIds);

	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode = 'I')
	BEGIN
		INSERT INTO einvoice.DocumentStatus
		(
			DocumentId,
			IRN,
			[Provider],
			AckNumber,
			AckDate,
			GeneratedDate,
			IsPushed,
			PushStatus,
			PushDate,
			[Status]
		)
		SELECT  
			tdi.Id AS DocumentId,
			td.Irn,
			td.[Provider],
			td.AckNumber,
			td.AckDate,
			td.AckDate,
			td.IsEInvoicePushed,
			td.EInvoicePushStatus,
			td.AckDate,
			td.EInvoiceStatus
		FROM
			#TempDocuments AS td
			INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = td.GroupId
		WHERE 
			tdi.Mode = 'I';

		INSERT INTO ewaybill.DocumentStatus
		(
			DocumentId,
			Irn,
			PushStatus,
			EwayBillNumber,
			ValidUpto,
			GeneratedDate,
			IsPushed,
			PushDate,
			LastSyncDate,
			[Status],
			IsMultiVehicleMovementInitiated,
			Distance
		)
		SELECT  
			tdi.Id,
			td.Irn,
			td.EWaybillPushStatus,
			td.EwayBillNumber,
			td.EwayBillValidTill,
			td.EwayBillDate,
			td.IsEwayBillPushed,
			td.EwayBillDate,
			@CurrentDate,
			td.EwayBillStatus,
			@BitTypeN,
			td.Distance
		FROM
			#TempDocuments AS td
			INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = td.GroupId
		WHERE 
			tdi.Mode = 'I';

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
			[Type]
		)
		SELECT 
			tdi.Id,
			td.TransportMode,
			td.TransportDocumentNumber,
			td.TransportDocumentDate,
			td.VehicleNumber,
			ISNULL((SELECT StateCode FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeDispatchFrom AND tdc.GroupId = tdi.GroupId),(SELECT StateCode FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeBillFrom AND tdc.GroupId = tdi.GroupId)),
			ISNULL((SELECT City FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeDispatchFrom AND tdc.GroupId = tdi.GroupId),(SELECT City FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeBillFrom AND tdc.GroupId = tdi.GroupId)),
			@BitTypeY,
			td.VehicleType
		FROM
			#TempDocuments AS td
			INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = td.GroupId
		WHERE 
			tdi.Mode = 'I'
			AND td.EwayBillValidTill IS NOT NULL;
	END
	
	
	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode IN ('U', 'PU'))
	BEGIN	
		UPDATE
			einvoice.Documents
		SET 
			Purpose = ted.PurposeType,
			TransactionType = ted.TransactionType,
			DocumentDate = ted.DocumentDate,
			TransactionMode = ted.TransactionMode,
			UnderIgstAct = ted.UnderIgstAct,

			RefDocumentRemarks = ted.RefDocumentRemarks,
			RefDocumentPeriodStartDate = ted.RefDocumentPeriodStartDate,
			RefDocumentPeriodEndDate  = ted.RefDocumentPeriodEndDate,
			RefPrecedingDocumentDetails  = ted.RefPrecedingDocumentDetails,
			RefContractDetails  = ted.RefContractDetails,
			AdditionalSupportingDocumentDetails = ted.AdditionalSupportingDocumentDetails,

			BillNumber = ted.BillNumber,
			BillDate = ted.BillDate,
			PortCode = ted.PortCode,
			DocumentCurrencyCode = ted.DocumentCurrencyCode,
			DestinationCountry = ted.DestinationCountry,
			ExportDuty = ted.ExportDuty,
			POS = ted.POS,

			DocumentValue  = ted.DocumentValue,
			DocumentDiscount = ted.DocumentDiscount,
			DocumentOtherCharges = ted.DocumentOtherCharges,
			DocumentValueInForeignCurrency = ted.DocumentValueInForeignCurrency,
			DocumentValueInRoundOffAmount = ted.DocumentValueInRoundOffAmount,
			ReverseCharge = ted.ReverseCharge,
			ClaimRefund = ted.ClaimRefund,
			ECommerceGstin = ted.ECommerceGstin,

			TransporterID = ted.TransporterID,
			TransporterName = ted.TransporterName,
			ToEmailAddresses = ted.ToEmailAddresses,
			ToMobileNumbers = ted.ToMobileNumbers,

			TotalTaxableValue = ted.TotalTaxableValue,
			TotalTaxAmount = ted.TotalTaxAmount,
			ReturnPeriod = ted.ReturnPeriod,
			FinancialYear = ted.DocumentFinancialYear,
			DocumentFinancialYear = ted.DocumentFinancialYear,
			DocumentReturnPeriod = ted.ReturnPeriod,
			--SourceType = @SourceType,
			GroupId = ted.GroupId,
			ModifiedStamp =  @CurrentDate
		FROM
			einvoice.Documents AS ed
			INNER JOIN #TempDocumentIds tdi ON tdi.Id = ed.Id
			INNER JOIN #TempDocuments AS ted ON ted.GroupId = tdi.GroupId
		WHERE
			tdi.Mode = 'U';

		UPDATE
			einvoice.Documents
		SET 
			ModifiedStamp =  @CurrentDate,
			GroupId = ted.GroupId,
			Purpose = ted.PurposeType
		FROM
			einvoice.Documents AS ed
			INNER JOIN #TempDocumentIds tdi ON tdi.Id = ed.Id
			INNER JOIN #TempDocuments AS ted ON ted.GroupId = tdi.GroupId
		WHERE
			tdi.Mode = 'PU';

		UPDATE
			einvoice.DocumentStatus
		SET 
			IRN = tsd.Irn,
			[Provider] = tsd.[Provider],
			AckNumber = tsd.AckNumber,
			AckDate = tsd.AckDate,
			GeneratedDate = tsd.AckDate,
			PushDate = tsd.AckDate,
			IsPushed = tsd.IsEInvoicePushed,
			PushStatus = tsd.EInvoicePushStatus,
			[Status] = tsd.EInvoiceStatus,
			CancelDate = tsd.CancellationDate,
			CancelReason = tsd.CancellationReason,
			CancelRemark = tsd.CancellationRemark,
			ModifiedStamp = @CurrentDate,
			[Errors] = CASE WHEN @IsDuplicateIrn = 1 THEN NULL ELSE ss.Errors END
		FROM
			einvoice.DocumentStatus ss
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = ss.DocumentId 
			INNER JOIN #TempDocuments tsd ON tsd.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode IN  ('U','PU');

		UPDATE
			ds 
		SET 
			IRN = ISNULL(tsd.Irn,ds.Irn),
			PushStatus = CASE WHEN tsd.EwayBillNumber IS NOT NULL AND ds.PushStatus = @EwayBIllPushStatusYetNotGenerated THEN tsd.EwayBillPushStatus ELSE ds.PushStatus END,
			EwayBillNumber = CASE WHEN tsd.EwayBillNumber IS NOT NULL AND ds.PushStatus = @EwayBIllPushStatusYetNotGenerated THEN tsd.EwayBillNumber ELSE ds.EwayBillNumber END,
			GeneratedDate = CASE WHEN tsd.EwayBillNumber IS NOT NULL AND ds.PushStatus = @EwayBIllPushStatusYetNotGenerated THEN tsd.EwayBillDate ELSE ds.GeneratedDate END,
			ValidUpto = CASE WHEN tsd.EwayBillValidTill IS NOT NULL AND ds.PushStatus = @EwayBIllPushStatusYetNotGenerated THEN tsd.EwayBillValidTill ELSE ds.ValidUpto END,
			IsPushed = CASE WHEN tsd.EwayBillNumber IS NOT NULL AND ds.PushStatus = @EwayBIllPushStatusYetNotGenerated THEN tsd.IsEwayBillPushed ELSE ds.IsPushed END,
			[Status] = CASE WHEN ds.PushStatus = @EwayBIllPushStatusYetNotGenerated  THEN tsd.EwayBillStatus ELSE ds.[Status] END,
 			ModifiedStamp = @CurrentDate,
			Distance = CASE WHEN ds.PushStatus = @EwayBIllPushStatusYetNotGenerated  THEN  tsd.Distance ELSE ds.Distance END
		FROM
			ewaybill.DocumentStatus ds
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = ds.DocumentId
			INNER JOIN #TempDocuments tsd ON tsd.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode IN ('U','PU');

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
			[Type]	
		)
		SELECT
			tdi.Id,
			td.TransportMode,
			td.TransportDocumentNumber,
			td.TransportDocumentDate,
			td.VehicleNumber,
			ISNULL((SELECT StateCode FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeDispatchFrom AND tdc.GroupId = tdi.GroupId),(SELECT StateCode FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeBillFrom AND tdc.GroupId = tdi.GroupId)),
			ISNULL((SELECT City FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeDispatchFrom AND tdc.GroupId = tdi.GroupId),(SELECT City FROM #TempDocumentContacts tdc WHERE tdc.[Type] = @DocumentContactTypeBillFrom AND tdc.GroupId = tdi.GroupId)),
			@BitTypeY,
			td.VehicleType
		FROM
			#TempDocuments AS td
			INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = td.GroupId 
		WHERE
			tdi.Mode IN ('U','PU')
			AND td.EwayBillValidTill IS NOT NULL
			AND NOT EXISTS 
			(
				SELECT
					vd.DocumentId
				FROM
					ewaybill.VehicleDetails AS vd
				WHERE 
					vd.DocumentId = tdi.Id
			);
	END
	
	/* Delete DocumentItems for both Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode IN ('I', 'U'))
	BEGIN
		DECLARE @Min INT = 1, @Max INT, @BatchSize INT , @Records INT
		SELECT 
			@Max = MAX(AutoId)
		FROM #TempDocumentIds

		SELECT @Batchsize = CASE WHEN ISNULL(@Max,0) > 100000 
							THEN  ((@Max*10)/100)
							ELSE @Max
							END
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize		
			
			DELETE di
			FROM 
				einvoice.DocumentItems AS di
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = di.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;

			DELETE dc
			FROM 
				einvoice.DocumentContacts AS dc
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dc.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;

			DELETE dp
			FROM 
				einvoice.DocumentPayments AS dp
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dp.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;

			DELETE dcd
			FROM 
				einvoice.DocumentSignedDetails AS dcd
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dcd.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;
			
			DELETE dr
			FROM 
				einvoice.DocumentReferences AS dr
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dr.DocumentId
			WHERE 
				tdi.Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;

			SET @Min = @Records;
		END
	END;

	INSERT INTO einvoice.DocumentItems
	(
		DocumentId,
		SerialNumber,
		IsService,
		Hsn,
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
		OrderLineReference,
		OriginCountry,
		ItemSerialNumber,
		ItemTotal,
		ItemAttributeDetails,
		BatchNameNumber,
		BatchExpiryDate,
		WarrantyDate
	)
	SELECT			
		 tdi.Id,
		 tsdi.SerialNumber,
		 tsdi.IsService,
		 tsdi.Hsn,
		 tsdi.[Name],
		 tsdi.[Description],
		 tsdi.Barcode,
		 tsdi.UQC,
		 tsdi.Quantity,
		 tsdi.FreeQuantity,
		 tsdi.Rate,
		 tsdi.CessRate,
		 tsdi.StateCessRate,
		 tsdi.CessNonAdvaloremRate,
		 tsdi.PricePerQuantity,
		 tsdi.DiscountAmount,
		 tsdi.GrossAmount,
		 tsdi.OtherCharges,
		 tsdi.TaxableValue,
		 tsdi.PreTaxValue,
		 tsdi.IgstAmount,
		 tsdi.CgstAmount,
		 tsdi.SgstAmount,
		 tsdi.CessAmount,
		 tsdi.StateCessAmount,
		 tsdi.StateCessNonAdvaloremAmount,
		 tsdi.CessNonAdvaloremAmount,
		 tsdi.OrderLineReference,
		 tsdi.OriginCountry,
		 tsdi.ItemSerialNumber,
		 tsdi.ItemTotal,
		 tsdi.ItemAttributeDetails,
		 tsdi.BatchNameNumber,
		 tsdi.BatchExpiryDate,
		 tsdi.WarrantyDate
	FROM
		#TempDocumentItems AS tsdi
		INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = tsdi.GroupId
	WHERE 
		tdi.Mode IN ('I', 'U');
	
	INSERT INTO einvoice.DocumentContacts
	(
		DocumentId,
		Gstin,
		LegalName,
		TradeName,
		AddressLine1,
		AddressLine2,
		City,
		StateCode,
		Pincode,
		Phone,
		Email,
		[Type]
	)
	SELECT			
		 tdi.Id,
		 tdc.Gstin,
		 tdc.LegalName,
		 tdc.TradeName,
		 tdc.AddressLine1,
		 tdc.AddressLine2,
		 tdc.City,
		 tdc.StateCode,
		 tdc.Pincode,
		 tdc.Phone,
		 tdc.Email,
		 tdc.[Type]
	FROM
		#TempDocumentContacts AS tdc
		INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = tdc.GroupId
	WHERE 
		tdi.Mode IN ('I', 'U');

	INSERT INTO einvoice.DocumentPayments
	(
		DocumentId,
		PaymentMode,
		AdvancePaidAmount,
		PaymentTerms,
		PaymentInstruction,
		PayeeName,
		PayeeAccountNumber,
		PaymentAmountDue,
		Ifsc,
		CreditTransfer,
		DirectDebit,
		CreditDays
	)
	SELECT			
		 tdi.Id,
		 tdp.PaymentMode,
		 tdp.AdvancePaidAmount,
		 tdp.PaymentTerms,
		 tdp.PaymentInstruction,
		 tdp.PayeeName,
		 tdp.PayeeAccountNumber,
		 tdp.PaymentAmountDue,
		 tdp.Ifsc,
		 tdp.CreditTransfer,
		 tdp.DirectDebit,
		 tdp.CreditDays
	FROM
		#TempDocumentPayments AS tdp
		INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = tdp.GroupId
	WHERE 
		tdi.Mode IN ('I', 'U');

	INSERT INTO einvoice.DocumentSignedDetails
	(
		DocumentId,
		SignedInvoice,
		SignedQrCode,
		Stamp,
		IsCompress
	)
	SELECT  
		tdi.Id AS DocumentId,
		ted.SignedInvoice,
		ted.SignedQRCode,
		@CurrentDate,
		@BitTypeY
	FROM
		#TempDocuments AS ted
		INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = ted.GroupId
	WHERE 
		tdi.Mode IN ('I', 'U');

	INSERT INTO einvoice.DocumentReferences
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
		INNER JOIN #TempDocumentIds AS tdi ON tdi.GroupId = tdr.GroupId
	WHERE 
		tdi.Mode IN ('I', 'U');

	INSERT INTO #TempUpsertDocumentIds (Id, GroupId)
	SELECT 
		Id,
		GroupId
	FROM 
		#TempDocumentIds;

	/* SP excuted to Insert/Update data into DW tables */
	EXEC [einvoice].[InsertEinvoiceDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;

	SELECT
		td.Id,
		td.GroupId
	FROM
		#TempUpsertDocumentIds td;

	SELECT
		td.Id,
		td.GroupId
	FROM
		#TempUpsertDocumentIds td;

	DROP TABLE #TempUpsertDocumentIds,#TempDocuments,#TempDocumentItems,#TempDocumentReferences,#TempDocumentIds;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[UpdatePushRequestForCancellation] 	 	 
* 	Comments			: 13-01-2019 | Faraaz Pathan | This procedure is used to Update EInvoice Documents status.
						: 13-01-2019 | Faraaz Pathan | Changed Procedure's parameters.
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from DocumentWH to DocumentDW
						: 10-08-2020 | Chandresh Prajapati | Added Purpose in select statement
						: 17-04-2024 | Chandresh Prajapati | Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @Ids AS [common].[BigIntType]

						  INSERT INTO @Ids VALUES (14489);

						  EXEC [einvoice].[UpdatePushRequestForCancellation]
								@Ids =  @Ids,
								@BackgroundTaskId = 54321,
								@EInvoicePushStatusInProgress = 2,
								@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[UpdatePushRequestForCancellation]
(
	 @Ids [common].[BigIntType] READONLY,
	 @BackgroundTaskId BIGINT,
	 @EInvoicePushStatusInProgress SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE #TempEInvoiceDocumentIds
	(
		Id BIGINT
	);

	CREATE CLUSTERED INDEX IDX_#TempEInvoiceDocumentIds ON #TempEInvoiceDocumentIds (ID)

	INSERT INTO #TempEInvoiceDocumentIds 
	(
		Id
	)
	SELECT
		Item
	FROM 
		@Ids;
	

	UPDATE einvoice.DocumentStatus
	SET
	    PushStatus = @EInvoicePushStatusInProgress,
	    BackgroundTaskId = @BackgroundTaskId,
		Errors = NULL
	FROM 
		einvoice.DocumentStatus ds
		INNER JOIN #TempEInvoiceDocumentIds tedi ON ds.DocumentId = tedi.Id;	
				
	SELECT 
		d.Id,
		d.EntityId,
		d.ReturnPeriod,
		d.[Type]
	FROM 
		#TempEInvoiceDocumentIds eid
		INNER JOIN einvoice.Documents d on d.Id = eid.Id;

	DROP TABLE #TempEInvoiceDocumentIds;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[UpdatePushRequestForGeneration] 	 	 
* 	Comments			: 07-01-2019 | Amit Khanna | This procedure is used to update EInvoice Document Status to InProgress based on filter parameters.
* 	Change 1			: 23-01-2019 | Amit Khanna | Removed filter Documents sp call and updating EInvoicePushStatus of Documents based on DocumentIds.
						: 10-04-2020 | Amit Khanna | Added Logic to Update Ewaybill DocumentStatus PushStatus and BackgroundTask only when PurposeType is EINV|EWB.
						: 27-05-2020 | Amit Khanna | Added Parameter PurposeTypeEWB.
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from DocumentWH to DocumentDW
						: 01-10-2020 | Chandresh Prajapati | Added Purpose and TransactionType in last select statement
						: 10-05-2022 | Prakash Parmar | Added Request Id Parameter
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @Ids [common].[BigIntType];

						  INSERT INTO @Ids VALUES (6278);

						  EXEC [einvoice].[UpdatePushRequestForGeneration]
								@Ids =  @Ids,
								@BackgroundTaskId = 14489,
								@RequestId = '708c8e39-8566-4571-9a38-018801fdf2c5',
								@PurposeTypeEINV = 2,
								@PurposeTypeEWB = 8,
								@EInvoicePushStatusInProgress = 2,
								@EwaybillPushStatusInProgress = 4,
								@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[UpdatePushRequestForGeneration]
(
	@Ids [common].[BigIntType] READONLY,
	@BackgroundTaskId BIGINT,
	@RequestId UNIQUEIDENTIFIER,
	@PurposeTypeEINV SMALLINT,
	@PurposeTypeEWB SMALLINT,
	@EInvoicePushStatusInProgress INT,
	@EwaybillPushStatusInProgress INT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempEInvoiceDocumentIds
	(
		Id BIGINT
	);
	
	CREATE CLUSTERED INDEX IDX_#TempEInvoiceDocumentIds ON #TempEInvoiceDocumentIds (ID)
		
	INSERT INTO #TempEInvoiceDocumentIds (Id) 
	SELECT
		Item
	FROM
		@Ids;
	
	UPDATE 
		ds
	SET 
		ds.PushStatus = @EInvoicePushStatusInProgress,
		ds.BackgroundTaskId = @BackgroundTaskId,
		ds.RequestId = @RequestId,
		ds.Errors = NULL
	FROM 
		#TempEInvoiceDocumentIds AS tedi 
		INNER JOIN einvoice.DocumentStatus AS ds ON ds.DocumentId = tedi.Id;

	UPDATE 
		ds
	SET 
		ds.PushStatus = @EwaybillPushStatusInProgress,
		ds.RequestId = @RequestId,
		ds.Errors = NULL
	FROM 
		#TempEInvoiceDocumentIds AS tedi
		INNER JOIN ewaybill.DocumentStatus AS ds ON ds.DocumentId = tedi.Id
		INNER JOIN einvoice.Documents AS d ON d.Id = ds.DocumentId
	WHERE 
		d.Purpose & @PurposeTypeEWB <> 0;
			
	SELECT 
		dw.Id,
		dw.EntityId,
		dw.ReturnPeriod,
		dw.[Type],
		dw.Purpose AS PurposeType,
		dw.TransactionType
	FROM 
		#TempEInvoiceDocumentIds tedi
		INNER JOIN einvoice.DocumentDW dw ON tedi.Id = dw.Id
	ORDER BY 
		dw.Id;

	DROP TABLE #TempEInvoiceDocumentIds;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[UpdatePushResponseForCancellation] 	 	 
* 	Comments			: 13-01-2019 | Pathan Faraaz | This procedure is used to cancel EInvoice Documents.
						: 15-05-2020 | Amit khanna   | Added Parameter DocumentStatusCompleted.
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from DocumentWH to DocumentDW
						: 17-08-2020 | Chandresh Prajapati | Added EwayBillPushStatusCancelled
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Cancellation
						: 08-09-2020 | Chandresh Prajapati | Removed QRCode, QRCodeData, SignedInvoice and SignedQRCode
						: 28-09-2020 | Prakash Parmar | Removed IsSandboxEnvironment
						: 21-12-2020 | Chandresh Prajapati | Update CancelRemarks length 250
						: 29-12-2022 | Jasmin Kansagra | Not update PushDate in the case of B2C
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponse AS [einvoice].[PushResponseType]
						  
						  INSERT INTO  @PushResponse(Id, AcknowledgementNumber, UpdatedDate, Irn, SignedInvoice, SignedQRCode,EwayBillNumber,EwayBillDate,EwayBillValidUpto,EInvoicePushStatus,EwayBillPushStatus,EInvoiceIsPushed,EwayBillIsPushed,EInvoiceErrors,EwayBillErrors)
						  VALUES (14489,null,'2020-08-18T11:43:00', 'de255cbc67246bd9d6ca069529291fb04b4f9d41bd1b673c81e1f402539e1273',null,null,null,null,5,4,null,null,null,null,1)
						  
						  EXEC [einvoice].[UpdatePushResponseForCancellation]
								@PushResponse = @PushResponse,
								@CancelReason= 1,
								@CancelRemarks ='test',
								@EInvoicePushStatusCancelled = 5,
								@EwayBillPushStatusCancelled = 4,
								@DocumentStatusCompleted = 3,
								@BitTypeY = 1,
								@AuditTrailDetails = @AuditTrailDetails;;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[UpdatePushResponseForCancellation]
(
	@PushResponse [einvoice].[PushResponseType] READONLY,
	@CancelReason SMALLINT,
	@CancelRemarks VARCHAR(250),
	@EInvoicePushStatusCancelled SMALLINT,
	@DocumentStatusCompleted SMALLINT,
	@EwayBillPushStatusCancelled SMALLINT,
	@BitTypeY SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		pr.Id,
		pr.AcknowledgementNumber,
		pr.UpdatedDate,
		pr.Irn,
		pr.EInvoiceIsPushed,
		pr.EwayBillIsPushed,	
		pr.SignedInvoice,
		pr.SignedQRCode,
		pr.EInvoicePushStatus,
		pr.EInvoiceErrors,
		pr.EwaybillErrors,
		pr.EwayBillNumber,
		pr.EwayBillDate,
		pr.EwayBillValidUpto,
		pr.EwayBillPushStatus
	INTO
		#TempEInvoiceStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEInvoiceStatusDetails ON #TempEInvoiceStatusDetails(Id)
	
	UPDATE einvoice.DocumentStatus
	SET
		CancelReason = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN @CancelReason ELSE NULL END,
		CancelRemark = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN @CancelRemarks ELSE NULL END,
		CancelDate = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN teid.UpdatedDate ELSE NULL END,
		PushStatus = teid.EInvoicePushStatus,
		[Status] = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN @DocumentStatusCompleted ELSE ds.[Status] END,
		Errors = teid.EInvoiceErrors,
		ModifiedStamp = GETDATE(),
		PushDate = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusCancelled AND teid.EInvoiceIsPushed = @BitTypeY THEN teid.UpdatedDate ELSE ds.PushDate END
	FROM
		einvoice.DocumentStatus ds
		INNER JOIN #TempEInvoiceStatusDetails teid ON teid.Id = ds.DocumentId;

	UPDATE ds
	SET
		[Status] = CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusCancelled THEN @DocumentStatusCompleted ELSE ds.[Status] END,
		PushStatus = CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusCancelled THEN @EwayBillPushStatusCancelled ELSE ds.PushStatus END,
		[CancelledDate] = CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusCancelled THEN teid.UpdatedDate ELSE null END,
		ModifiedStamp = GETDATE(),
		PushDate =  CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusCancelled THEN teid.UpdatedDate ELSE ds.PushDate END,
		Reason = (CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusCancelled THEN @CancelReason ELSE ds.Reason END ),
		Remarks = (CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusCancelled THEN @CancelRemarks ELSE ds.Remarks END )
	FROM
		ewaybill.DocumentStatus ds
		INNER JOIN #TempEInvoiceStatusDetails teid ON teid.Id = ds.DocumentId;		
		
	DROP TABLE 	#TempEInvoiceStatusDetails;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [einvoice].[UpdatePushResponseForGeneration] 	 	 
* 	Comments			: 13-01-2020 | Amit Khanna | This procedure is used to update EInvoice Document Status after uploading on Nic.
* 						: 02-03-2020 | Amit Khanna | Updating Irn Column in DocumentStatus.
* 						: 10-04-2020 | Amit Khanna | Added Logic to Update Ewaybill DocumentStatus Details only when PurposeType is EINV|EWB.
						: 15-05-2020 | Amit khanna | Added Parameter DocumentStatusGenerated.
						: 25-05-2020 | Amit khanna | Removed Parameter PurposeType.
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from DocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Generation
						: 08-09-2020 | Chandresh Prajapati | Removed QRCode, QRCodeData and inserted SignedInvoice and SignedQRCode into einvoice.DocumentSignedDetails
						: 22-09-2020 | Prakash Parmar | Added ActualDistance
						: 06-10-2020 | Prakash Parmar | Added AckDate In einvoice.documentdw table
						: 16-10-2020 | Chandresh Prajapati | Added code for update vehicle detial when ewaybillpushstatus is generated
						: 08-12-2021 | Prakash Parmar | Added GenerationModeApi Parameter
						: 18-12-2023 | Prakash Parmar | Added deletion of document signed details
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		:  DECLARE @PushResponse AS [einvoice].[PushResponseType]
						  
						  INSERT INTO  @PushResponse(Id, AcknowledgementNumber, UpdatedDate, Irn, SignedInvoice, SignedQRCode,EwayBillNumber,EwayBillDate,EwayBillValidUpto,EInvoicePushStatus,EwayBillPushStatus,EInvoiceIsPushed,EwayBillIsPushed,EInvoiceErrors,EwayBillErrors)
						  VALUES (14489,null,'2020-08-18T11:43:00', 'de255cbc67246bd9d6ca069529291fb04b4f9d41bd1b673c81e1f402539e1273',null,null,null,null,null,5,4,null,null,null,null)						  
						  EXEC [einvoice].[UpdatePushResponseForGeneration]
							  @PushResponse = @PushResponse,
							  @UserId = 486,
							  @UpdatedByGstin = NULL,
							  @BitTypeY = 1,
							  @EInvoicePushStatusGenerated = 4,
							  @EwayBillPushStatusGenerated = 2,
							  @DocumentStatusGenerated = 1,
							  @GenerationModeApi = 1,
							  @AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [einvoice].[UpdatePushResponseForGeneration]
(
	@PushResponse [einvoice].[PushResponseType] READONLY,
	@UserId INT,
	@BitTypeY SMALLINT,
	@EInvoicePushStatusGenerated SMALLINT,
	@EwayBillPushStatusGenerated SMALLINT,
	@DocumentStatusGenerated SMALLINT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CurrentDate DATETIME = GETDATE();

	SELECT
		pr.Id,
		pr.[Provider],
		pr.UpdatedByGstin,
		pr.AcknowledgementNumber,
		pr.UpdatedDate,
		pr.Irn,
		pr.EInvoiceIsPushed,
		pr.EwayBillIsPushed,	
		pr.SignedInvoice,
		pr.SignedQRCode,
		pr.EInvoicePushStatus,
		pr.EInvoiceErrors,
		pr.EwayBillErrors,
		pr.EwayBillNumber,
		pr.EwayBillDate,
		pr.EwayBillValidUpto,
		pr.EwayBillPushStatus,
		pr.ActualDistance
	INTO
		#TempEInvoiceStatusDetails
	FROM
		@PushResponse AS pr;
	
	CREATE CLUSTERED INDEX IDX_#TempEInvoiceStatusDetails ON #TempEInvoiceStatusDetails(Id)	

	UPDATE
		ds
	SET
		ds.IRN = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN  teid.Irn ELSE ds.Irn END,
		ds.AckNumber = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN  teid.AcknowledgementNumber ELSE ds.AckNumber END,
		ds.AckDate = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN teid.UpdatedDate ELSE ds.AckDate END,
		ds.IsPushed = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN teid.EInvoiceIsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated AND teid.EInvoiceIsPushed = @BitTypeY THEN teid.UpdatedDate ELSE ds.PushDate END,
		ds.GeneratedDate = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN @CurrentDate ELSE ds.GeneratedDate END,
		ds.[Provider] = ISNULL(teid.[Provider], ds.[Provider]),
		ds.PushStatus = teid.EInvoicePushStatus,
		ds.[Status] = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN @DocumentStatusGenerated ELSE ds.[Status] END,
		ds.PushByUserId = @UserId,
		ds.Errors= teid.EInvoiceErrors,
		ds.ModifiedStamp = @CurrentDate
	FROM
		einvoice.DocumentStatus AS ds
		INNER JOIN #TempEInvoiceStatusDetails teid ON ds.DocumentId = teid.Id;

	DELETE dsd 
	FROM 
		einvoice.DocumentSignedDetails dsd
		INNER JOIN #TempEInvoiceStatusDetails teid ON dsd.DocumentId = teid.Id
	WHERE
		teid.EInvoicePushStatus = @EInvoicePushStatusGenerated;

	INSERT INTO einvoice.DocumentSignedDetails
	(
		DocumentId,
		SignedInvoice,
		SignedQrCode,
		Stamp,
		IsCompress
	)
	SELECT 
		ds.DocumentId,
		teid.SignedInvoice,
		teid.SignedQrCode,
		@CurrentDate,
		@BitTypeY
	FROM 
		einvoice.DocumentStatus AS ds
		INNER JOIN #TempEInvoiceStatusDetails teid ON ds.DocumentId = teid.Id
	WHERE 
		teid.EInvoicePushStatus = @EInvoicePushStatusGenerated
		AND teid.SignedQrCode IS NOT NULL;

	UPDATE
		ds
	SET
		ds.IRN = CASE WHEN teid.EInvoicePushStatus = @EInvoicePushStatusGenerated THEN  teid.Irn ELSE ds.Irn END,
		ds.EwayBillNumber = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN teid.EwayBillNumber ELSE ds.EwayBillNumber END,
		ds.ValidUpto = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN teid.EwayBillValidUpto ELSE ds.ValidUpto END,
		ds.GeneratedDate = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN teid.EwayBillDate ELSE ds.GeneratedDate END,
		ds.PushByUserId = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN @UserId ELSE ds.PushByUserId END,
		ds.IsPushed = CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusGenerated THEN teid.EwayBillIsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN teid.EwayBillDate ELSE ds.PushDate END,
		ds.Errors = teid.EwayBillErrors,
		ds.[Status] = CASE WHEN teid.EwayBillPushStatus = @EwayBillPushStatusGenerated THEN @DocumentStatusGenerated ELSE ds.[Status] END,
		ds.PushStatus = teid.EwaybillPushStatus,
		ds.ModifiedStamp = @CurrentDate,
		ds.CancelledDate = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN NULL ELSE ds.CancelledDate END,
		ds.Distance = ISNULL(teid.ActualDistance, ds.Distance),
		ds.GenerationMode = CASE WHEN teid.EwaybillPushStatus = @EwayBillPushStatusGenerated THEN @GenerationModeApi ELSE ds.GenerationMode END
	FROM
		ewaybill.DocumentStatus AS ds
		INNER JOIN #TempEInvoiceStatusDetails teid ON ds.DocumentId = teid.Id;

	UPDATE
		vd
	SET
		PushDate = teid.EwayBillDate,
		UpdatedByGstin = teid.UpdatedByGstin,
		ModifiedStamp = @CurrentDate,
		UpdationMode = @GenerationModeApi
	FROM 
		[ewaybill].[VehicleDetails] vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushDate))
		INNER JOIN #TempEInvoiceStatusDetails teid ON teid.Id = vd.DocumentId
	WHERE 
		teid.EwayBillPushStatus = @EwayBillPushStatusGenerated;				

	DROP TABLE #TempEInvoiceStatusDetails
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertDownloadedPurchaseDocuments]
* 	Comments			: 03-06-2020 | Mayur Ladva | INSERT PURCHASE DOCUMENT Data From Gstn Download
						: 10/07/2020 | Kartik Bariya | Added @FinancialYear to request and added QuarterMonthIndex, QuarterReturnPeriod to response for the call of Sp [gst].[GetReturns].
						: 03/04/2023 | Dhruv Amin | Updated impg uniqueness changes for deletion code.
						: 24/05/2023 | Dhruv Amin | Updated Deletion logic to only notfiled records due to tata steel issue.
						: 01/09/2023 | Dhruv Amin | Removed Itc Eligibilty from RatewiseItem (CGSP2-5712).
*	Review Comment		: 01/01/2021 | Abhishek Shrivas	| further verified all the conditions 
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: DECLARE
								@PurchaseDocuments [oregular].[DownloadedPurchaseDocumentType],
								@PurchaseDocumentItems [oregular].[DownloadedPurchaseDocumentItemType],
								@DocumentReferences [common].[DocumentReferenceType],
								@BillFrom [oregular].[DownloadedPurchaseDocumentContactType],
								@BillTo  [oregular].[DownloadedPurchaseDocumentContactType],
								@PurchaseDocumentContacts [oregular].[DownloadedPurchaseDocumentContactType] ,
								@DocumentSectionGroups [common].[DocumentSectionGroupType];

							EXEC [oregular].[InsertDownloadedPurchaseDocuments]
								@SubscriberId=164,
								@UserId=663,
								@EntityId=372,
								@ReturnPeriod=72019,
								@FinancialYear=201920,
								@AutoSync = 0,							
								@Gstin = NULL,
								@DocumentSectionGroups = @DocumentSectionGroups,
								@PurchaseDocuments=@PurchaseDocuments,
								@PurchaseDocumentItems=@PurchaseDocumentItems,
								@DocumentReferences = @DocumentReferences ,
								@PurchaseDocumentContacts = @PurchaseDocumentContacts,
								@SourceTypeCounterPartyNotFiled = 2,
								@SourceTypeCounterPartyFiled = 3,
								@ApiCategory = 1,
								@DocumentStatusActive = 1,
								@ApiCategoryTxpGstr2a = 2,
								@ApiCategoryTxpGstr9 = 9,																
								@SectTypeIMPG = 8,
								@DocumentTypeDBN = 3,
								@DocumentTypeCRN = 2;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[InsertDownloadedPurchaseDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@ReturnPeriod INT,
	@FinancialYear INT,
	@Gstin VARCHAR(15),
	@AutoSync BIT,
	@IsImpg BIT,
	@ApiCategory SMALLINT,
	@DocumentSectionGroups AS [common].[DocumentSectionGroupType] READONLY,
	@PurchaseDocuments [oregular].[DownloadedPurchaseDocumentType] READONLY,
	@PurchaseDocumentContacts [oregular].[DownloadedPurchaseDocumentContactType] READONLY,
	@PurchaseDocumentItems oregular.[DownloadedPurchaseDocumentItemType] READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@ApiCategoryTxpGstr2a SMALLINT,
	@ApiCategoryTxpGstr9 SMALLINT,
	@ContactTypeBillFrom SMALLINT,
	@SourceTypeCounterPartyNotFiled SMALLINT,
	@SourceTypeCounterPartyFiled SMALLINT,
	@DocumentStatusActive SMALLINT,
	@SectTypeIMPG BIGINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	DECLARE 
		@False BIT = 0,
		@True BIT= 1,
		@Min INT = 1, 
		@Max INT, 
		@BatchSize INT, 
		@Records INT,
		@CurrentDate DATETIME = GETDATE();

	/* Create table for Id and Mode */
	CREATE TABLE #TempPurchaseDocumentIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		FinancialYear INT,
		BillingDate DATETIME,
		BillFromGstin VARCHAR(15),
		Mode VARCHAR(2)
	);
	CREATE CLUSTERED INDEX IDX_TempPurchaseDocumentIds_Id ON #TempPurchaseDocumentIds(ID);
	CREATE NONCLUSTERED INDEX IDX_TempPurchaseDocumentIds_GroupId ON #TempPurchaseDocumentIds(GroupId) INCLUDE(Id);
	
	/* create table for delete data ids while autosync = false */
	CREATE TABLE #TempDeletedIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
	CREATE CLUSTERED INDEX IDX_#TempDeletedIds_ID ON #TempDeletedIds (ID);
	/* Add Purchase document in temp */
	SELECT 
		[IsPreGstRegime],
		[DocumentType],
		[TransactionType],
		[TaxPayerType],
		[DocumentNumber],
		[DocumentDate],
		[BillFromGstin],
		[Pos],
		[PortCode],
		[DocumentValue],
		[ReverseCharge],
		[ClaimRefund],
		[UnderIgstAct],
		[RefundEligibility],
		[OriginalDocumentNumber],
		[OriginalDocumentDate],
		[OriginalDocumentType],
		[OriginalReturnPeriod],
		[SectionType],
		[TotalTaxableValue],
		[TotalTaxAmount],
		[TotalRateWiseTaxableValue],
		[TotalRateWiseTaxAmount],
		[ReturnPeriod],
		[DocumentFinancialYear],
		[FinancialYear],
		[IsAmendment],
		[AmendedType],
		[IsGstr3bFiled],
		[CancellationDate],
		[FilingDate],
		[FilingReturnPeriod],
		[GroupId],
		[Action],
		[SourceType],
		[Checksum],
		[DifferentialPercentage],
		[PushStatus],
		[IsPushed],
		[ReconciliationStatus],
		SUBSTRING([Irn],1,64) AS [Irn],
		[IrnGenerationDate],
		[AutoDraftSource],
		[RefPrecedingDocumentDetails],
		[Gstr2BReturnPeriod],
		[IsAvailableInGstr2B],
		[ItcAvailability],
		[ItcUnavailabilityReason],
		[ItcUnavailabilityReasonGstr98a],
		[ReceivedDate],
		[RecoDocumentNumber],
		TransactionNature,
		DocumentReturnPeriod
	INTO 
		#TempPurchaseDocuments
	FROM 
		@PurchaseDocuments
	WHERE NOT EXISTS (SELECT 1 FROM oregular.ExcludedGstin EG WHERE ISNULL(BillFromGstin,'') = EG.Gstin); /*This condition is added for cloudtail by DB team- Pls dont remove it*/

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocuments_GroupId ON #TempPurchaseDocuments(GroupId);
	/* Add Purchase document contact in temp */
	SELECT
		*
	INTO 
		#TempPurchaseDocumentContacts
	FROM 
		@PurchaseDocumentContacts;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentContacts_GroupId ON #TempPurchaseDocumentContacts(GroupId);
	/* Add Purchase document items in temp */
	SELECT
		*
	INTO 
		#TempPurchaseDocumentItems 
	FROM 
		@PurchaseDocumentItems;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentItems_GroupId ON #TempPurchaseDocumentItems(GroupId);
	/* Add Purchase document References in temp */
	SELECT 
		*
	INTO 
		#TempPurchaseDocumentReferences
	FROM 
		@DocumentReferences;

	/* Add purchase section groups in temp */
	SELECT
		*
	INTO
		#TempDocumentSectionGroups
	FROM
		@DocumentSectionGroups;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentReferences_GroupId ON #TempPurchaseDocumentReferences(GroupId);

	/* Get Update Mode Data */
	INSERT INTO #TempPurchaseDocumentIds
	(
		Id,
		FinancialYear,
		BillingDate,
		GroupId,
		BillFromGstin,
		Mode
	)
	SELECT
	   dw.Id,
	   dw.FinancialYear,
	   ISNULL(ps.BillingDate,@CurrentDate),
	   tpd.GroupId,
	   dw.BillFromGstin,
	   CASE 
			WHEN @ApiCategory = @ApiCategoryTxpGstr9 THEN '8A' -- Flag for updating Gstr8a details
			WHEN dw.SourceType = @SourceTypeCounterPartyNotFiled AND tpd.SourceType = @SourceTypeCounterPartyFiled THEN 'UF'
			WHEN CAST(CONCAT(RIGHT(dw.ReturnPeriod,4),'-', LEFT(RIGHT(CONCAT('0',dw.ReturnPeriod),6),2),'-01') AS DATE) < CAST(CONCAT(RIGHT(tpd.ReturnPeriod,4),'-', LEFT(RIGHT(CONCAT('0',tpd.ReturnPeriod),6),2),'-01') AS DATE) THEN 'U'
			WHEN dw.SourceType = @SourceTypeCounterPartyNotFiled AND ISNULL(ps.[Checksum], '') <> ISNULL(tpd.[Checksum], '') THEN 'U'
			WHEN dw.SourceType = @SourceTypeCounterPartyFiled AND (ISNULL(CAST(ps.IsGstr3bFiled AS INT), -1) <> CAST(tpd.IsGstr3bFiled AS INT) OR (ISNULL(ps.AmendedType,-1) <> tpd.AmendedType)) THEN '2A'
			WHEN dw.SourceType = @SourceTypeCounterPartyFiled AND ISNULL(CAST(ps.Gstr2BReturnPeriod AS INT), -1) <> CAST(tpd.Gstr2BReturnPeriod AS INT) THEN '2B'
			WHEN ps.LastSyncDate IS NULL THEN 'T' /* Temp flag to updated originalreturnperiod and filingreturnperiod fields */
			ELSE 'S'
		END AS Mode
	FROM
		#TempPurchaseDocuments tpd
		INNER JOIN oregular.PurchaseDocumentDW AS dw ON 
		(
			dw.SubscriberId = @SubscriberId
			AND dw.EntityId = @EntityId
			AND LOWER(dw.DocumentNumber) = LOWER(tpd.DocumentNumber) 
			AND dw.DocumentFinancialYear = tpd.DocumentFinancialYear
			AND dw.SourceType IN (@SourceTypeCounterPartyNotFiled, @SourceTypeCounterPartyFiled)
			AND ISNULL(dw.BillFromGstin, '') = ISNULL(tpd.BillFromGstin, '')
			AND ISNULL(dw.PortCode, '') = ISNULL(tpd.PortCode, '')
			AND dw.DocumentType = tpd.DocumentType
			AND dw.IsAmendment = tpd.IsAmendment
		)
		INNER JOIN oregular.PurchaseDocumentStatus ps ON ps.PurchaseDocumentId = dw.Id

	/* INSERT PurchaseDocuments*/
	IF(@ApiCategory <> @ApiCategoryTxpGstr9)
	BEGIN
		INSERT INTO [oregular].[PurchaseDocuments]
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
			RecoDocumentNumber,
			DocumentDate,
			Pos,
			PortCode,
			DocumentValue,
			ReverseCharge,
			ClaimRefund,
			UnderIgstAct,
			RefundEligibility,
			OriginalDocumentNumber,
			OriginalDocumentDate,
			OriginalDocumentType,			
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
			DifferentialPercentage,
			RefPrecedingDocumentDetails,
			GroupId,
			CombineDocumentType,
			TransactionNature,
			DocumentReturnPeriod
		)
		OUTPUT
			inserted.Id, inserted.GroupId, 'I', @CurrentDate
		INTO 
			#TempPurchaseDocumentIds(Id, GroupId, Mode, BillingDate)
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
			RecoDocumentNumber,
			DocumentDate,
			Pos,
			PortCode,
			DocumentValue,
			ReverseCharge,
			ClaimRefund,
			UnderIgstAct,
			RefundEligibility,
			OriginalDocumentNumber,
			OriginalDocumentDate,
			OriginalDocumentType,			
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
			DifferentialPercentage,
			RefPrecedingDocumentDetails,
			GroupId,
			CASE WHEN DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE DocumentType END AS CombineDocumentType,
			TransactionNature,
			DocumentReturnPeriod	
		FROM
			#TempPurchaseDocuments
		WHERE 
			GroupId NOT IN (SELECT GroupId FROM #TempPurchaseDocumentIds);

		/* Insert oregular.PurchaseDocumentStatus for matched records  */
		INSERT INTO oregular.PurchaseDocumentStatus
		(
			PurchaseDocumentId,
			CancelledDate,
			[Status],
			PushStatus,
			IsPushed,
			[Action],
			LastAction,
			[Checksum],
			AutoDraftSource,
			ReconciliationStatus,
			IsGstr3bFiled,
			IsReconciled,
			LastSyncDate,
			Gstr2BReturnPeriod,
			IsAvailableInGstr2B,
			ItcAvailability,
			ItcUnavailabilityReason,
			ReceivedDate,
			OriginalReturnPeriod,
			AmendedType,
			FilingDate,
			FilingReturnPeriod,
			IsReconciledGstr2b,
			Gstr2bAction,
			BillingDate
		)
		SELECT  
			tpdi.Id,
			tpd.CancellationDate,
			@DocumentStatusActive,
			tpd.PushStatus,
			tpd.IsPushed,
			tpd.[Action],
			tpd.[Action],
			tpd.[Checksum],
			tpd.AutoDraftSource,
			tpd.ReconciliationStatus,
			tpd.IsGstr3bFiled,
			@False,
			@CurrentDate,
			Gstr2BReturnPeriod,
			IsAvailableInGstr2B,
			ItcAvailability,
			ItcUnavailabilityReason,
			ReceivedDate,
			tpd.OriginalReturnPeriod,
			tpd.AmendedType,
			tpd.FilingDate,
			tpd.FilingReturnPeriod,
			@False,
			tpd.[Action],
			@CurrentDate
		FROM
			#TempPurchaseDocumentIds AS tpdi 
			INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
		WHERE 
			tpdi.Mode = 'I';
	END

	/* Update PurchaseDocuments AND PurchaseDocumentStatus with Flag IN ('U','UF')*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode IN ('U','UF'))
	BEGIN
		UPDATE 
			oregular.PurchaseDocuments 
		SET
			ParentEntityId = @EntityId,
			EntityId = @EntityId,
			UserId = @UserId,
			IsPreGstRegime = tpd.IsPreGstRegime,
			Irn = tpd.Irn,
			IrnGenerationDate = tpd.IrnGenerationDate,
			DocumentType = tpd.DocumentType,
			TransactionType = tpd.TransactionType,
			TaxpayerType = tpd.TaxpayerType,
			DocumentNumber = tpd.DocumentNumber,
			DocumentDate = tpd.DocumentDate,
			Pos = tpd.Pos,
			PortCode = tpd.PortCode,
			DocumentValue = tpd.DocumentValue,
			ReverseCharge = tpd.ReverseCharge,
			ClaimRefund = tpd.ClaimRefund,
			UnderIgstAct = tpd.UnderIgstAct,
			RefundEligibility = tpd.RefundEligibility,
			OriginalDocumentNumber = tpd.OriginalDocumentNumber,
			OriginalDocumentDate = tpd.OriginalDocumentDate,
			OriginalDocumentType = tpd.OriginalDocumentType,			
			SectionType = tpd.SectionType,
			TotalTaxableValue = tpd.TotalTaxableValue,
			TotalTaxAmount = tpd.TotalTaxAmount,
			TotalRateWiseTaxableValue = tpd.TotalRateWiseTaxableValue,
			TotalRateWiseTaxAmount = tpd.TotalRateWiseTaxAmount,
			ReturnPeriod = tpd.ReturnPeriod,
			DocumentFinancialYear = tpd.DocumentFinancialYear,
			FinancialYear = tpd.FinancialYear,
			IsAmendment = tpd.IsAmendment,			
			SourceType = tpd.SourceType,
			DifferentialPercentage = tpd.DifferentialPercentage,
			RefPrecedingDocumentDetails = tpd.RefPrecedingDocumentDetails,
			GroupId = tpd.GroupId,
			Stamp = CASE WHEN tpdi.Mode = 'UF' THEN @CurrentDate ELSE pd.Stamp END,
			ModifiedStamp = @CurrentDate,
			CombineDocumentType = CASE WHEN tpd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tpd.DocumentType END,
			TransactionNature = tpd.TransactionNature,
			DocumentReturnPeriod = tpd.DocumentReturnPeriod
		FROM
			oregular.PurchaseDocuments AS pd
			INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = pd.Id
			INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
		WHERE 
			tpdi.Mode IN ('U','UF');
		
		UPDATE
			oregular.PurchaseDocumentStatus 
		SET 
			Gstr2BReturnPeriod = ISNULL(tpd.Gstr2BReturnPeriod, ps.Gstr2BReturnPeriod),
			IsAvailableInGstr2B = ISNULL(tpd.IsAvailableInGstr2B, ps.IsAvailableInGstr2B),
			ItcAvailability = ISNULL(tpd.ItcAvailability, ps.ItcAvailability),
			ItcUnavailabilityReason = ISNULL(tpd.ItcUnavailabilityReason, ps.ItcUnavailabilityReason),
			ReceivedDate = ISNULL(tpd.ReceivedDate, ps.ReceivedDate),
			[Status] = @DocumentStatusActive,
			CancelledDate = ISNULL(tpd.CancellationDate,ps.CancelledDate),			
			PushStatus = tpd.PushStatus,
			IsPushed = tpd.IsPushed,
			[Checksum] = ISNULL(tpd.[Checksum], ps.[Checksum]),
			AutoDraftSource = tpd.AutoDraftSource,
			IsReconciled = @False,
			IsGstr3bFiled = ISNULL(tpd.IsGstr3bFiled, ps.IsGstr3bFiled),
			BillingDate = tpdi.BillingDate,
			LastSyncDate = @CurrentDate,
 			ModifiedStamp = @CurrentDate,
			AmendedType = ISNULL(tpd.AmendedType, ps.AmendedType),
			FilingDate =  ISNULL(tpd.FilingDate, ps.FilingDate),
			FilingReturnPeriod =  ISNULL(tpd.FilingReturnPeriod, ps.FilingReturnPeriod),
			OriginalReturnPeriod =  ISNULL(tpd.OriginalReturnPeriod, ps.OriginalReturnPeriod),
			IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus ps
			INNER JOIN #TempPurchaseDocumentIds AS tpdi ON ps.PurchaseDocumentId = tpdi.ID
			INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
		WHERE 
			tpdi.Mode IN ('U','UF');
	END
	
	/* Update PurchaseDocuments AND PurchaseDocumentStatus with Flag = T'*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode = 'T')
	BEGIN				
		UPDATE 
			ps
		SET
			LastSyncDate = @CurrentDate,
			--ModifiedStamp = @CurrentDate,
			IsReconciled = @False,
			ps.OriginalReturnPeriod = tpd.OriginalReturnPeriod,
			ps.FilingReturnPeriod = tpd.FilingReturnPeriod,
			ps.ModifiedStamp = @CurrentDate,
			ps.IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus AS ps
			INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = ps.PurchaseDocumentId
			INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
		WHERE 
			tpdi.Mode = 'T';
	END

	/* Update PurchaseDocuments AND PurchaseDocumentStatus with Flag = '2A'*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode = '2A')
	BEGIN

		UPDATE 
			ps
		SET
			ps.IsGstr3bFiled = tpd.IsGstr3bFiled, -- isGstr3BFiled 
			ps.CancelledDate = tpd.CancellationDate, --dtcancel
			ps.[Checksum] = tpd.[Checksum], --chksum
			ps.LastSyncDate = @CurrentDate,
			ps.IsReconciled = @False,
			ps.OriginalReturnPeriod = tpd.OriginalReturnPeriod, --aspd
			ps.AmendedType = tpd.AmendedType, -- atyp
			ps.BillingDate = tpdi.BillingDate,
			ps.ModifiedStamp = @CurrentDate,
			ps.IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus AS ps
			INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = ps.PurchaseDocumentId
			INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
		WHERE 
			tpdi.Mode = '2A';
	END
	
	/* Update PurchaseDocumentStatus with Flag = '2B'*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode = '2B')
	BEGIN

		UPDATE 
			ps
		SET
			ps.Gstr2BReturnPeriod = tpd.Gstr2BReturnPeriod,
			ps.IsAvailableInGstr2B = tpd.IsAvailableInGstr2B,
			ps.ItcAvailability = tpd.ItcAvailability,
			ps.ItcUnavailabilityReason = tpd.ItcUnavailabilityReason,
			ps.ReceivedDate = tpd.ReceivedDate,
			ps.LastSyncDate = @CurrentDate,
			--ps.ModifiedStamp = @CurrentDate,
			ps.IsReconciled = @False,
			ps.FilingDate = ISNULL(ps.FilingDate, tpd.FilingDate),
			ps.FilingReturnPeriod = ISNULL(ps.FilingReturnPeriod,tpd.FilingReturnPeriod),
			ps.BillingDate = tpdi.BillingDate,
			ps.ModifiedStamp = @CurrentDate,
			ps.IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus AS ps
			INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = ps.PurchaseDocumentId
			INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
		WHERE 
			tpdi.Mode = '2B';
	END
	
	/* Update PurchaseDocumentStatus with Flag = '8A'*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode = '8A')
	BEGIN
		UPDATE 
			ps
		SET
			ps.IsAvailableInGstr98a = @True,
			ps.ItcAvailability = ISNULL(ps.ItcAvailability, tpd.ItcAvailability),
			ps.ItcUnavailabilityReasonGstr98a = ISNULL(ps.ItcUnavailabilityReasonGstr98a, tpd.ItcUnavailabilityReasonGstr98a),
			ps.BillingDate = tpdi.BillingDate,
			ps.LastSyncDate = @CurrentDate,
			ps.ModifiedStamp = @CurrentDate,
			ps.IsReconciled = @False,
			ps.IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus AS ps
			INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = ps.PurchaseDocumentId
			INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
		WHERE 
			tpdi.Mode = '8A';
	END

		
	/* Delete PurchaseDocumentItems and PurchaseDocumentPayments for both Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempPurchaseDocumentIds)
	BEGIN
		

		SELECT 
			@Max = COUNT(AutoId)
		FROM 
			#TempPurchaseDocumentIds

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN  ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize;
			
			/* delete purchase contact detail */
			DELETE 
				pdc
			FROM 
				oregular.PurchaseDocumentContacts AS pdc
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdc.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode IN ('I', 'U','UF') 
				AND tpdi.AutoId BETWEEN @Min AND @Records;
			
			/* delete purchase document items */
			DELETE 
				pdi
			FROM 
				oregular.PurchaseDocumentItems AS pdi
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdi.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode IN ('I', 'U','UF') 
				AND tpdi.AutoId BETWEEN @Min AND @Records;

			DELETE 
				pdri
			FROM 
				oregular.PurchaseDocumentRateWiseItems AS pdri
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdri.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode IN ('I', 'U','UF') 
				AND tpdi.AutoId BETWEEN @Min AND @Records;

			SET @Min = @Records
		END
	END

	INSERT INTO [oregular].[PurchaseDocumentItems]
	(
		[PurchaseDocumentId],
		[TaxType],
		[ItcEligibility],
		[TaxableValue],
		[Rate],
		[IgstAmount],
		[CgstAmount],
		[SgstAmount],
		[CessAmount],
		[GstActOrRuleSection]
	)
	SELECT
		tpdi.Id,
		tid.TaxType,
		tid.ItcEligibility,
		tid.TaxableValue,
		tid.Rate,
		tid.IgstAmount,
		tid.CgstAmount,
		tid.SgstAmount,
		tid.CessAmount,
		tid.GstActOrRuleSection
	FROM
		#TempPurchaseDocumentItems AS tid
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tid.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I', 'U','UF');

	INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
	(
		[PurchaseDocumentId],
		[TaxableValue],
		[Rate],
		[IgstAmount],
		[CgstAmount],
		[SgstAmount],
		[CessAmount]
	)
	SELECT
		tpdi.Id,
		tid.TaxableValue,
		tid.Rate,
		tid.IgstAmount,
		tid.CgstAmount,
		tid.SgstAmount,
		tid.CessAmount
	FROM
		#TempPurchaseDocumentItems AS tid
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tid.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I', 'U','UF');

	INSERT INTO oregular.PurchaseDocumentContacts
	(
		PurchaseDocumentId,
		Gstin,
		TradeName,
		LegalName,
		[Type]
	)
	SELECT
		tpdi.Id,
		tpdc.Gstin,
		tpdc.TradeName,
		tpdc.LegalName,
		tpdc.[Type]
	FROM
		#TempPurchaseDocumentContacts AS tpdc
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdc.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I','U','UF');
		
	UPDATE tpdi
	Set
		BillFromGstin = tpdc.Gstin 
	FROM
		#TempPurchaseDocumentContacts AS tpdc
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdc.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I')
		AND tpdc.[Type] = @ContactTypeBillFrom;

	INSERT INTO oregular.PurchaseDocumentReferences
	(
		PurchaseDocumentId,
		DocumentNumber,
		DocumentDate
	)
	SELECT
		tpdi.Id,
		tpdr.DocumentNumber,
		tpdr.DocumentDate
	FROM
		#TempPurchaseDocumentReferences AS tpdr
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdr.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I');

	/* Condition For Delete Data */
	IF (@AutoSync = @False AND @ApiCategory = @ApiCategoryTxpGstr2a)
	BEGIN
		IF (@IsImpg = @True)
		BEGIN
			INSERT INTO #TempDeletedIds
			(
				Id
			)
			SELECT
				dw.Id
			FROM
				 oregular.PurchaseDocumentDW AS dw
				 LEFT JOIN #TempPurchaseDocumentIds AS tpdi ON tpdi.Id = dw.Id 
			WHERE
				dw.SubscriberId = @SubscriberId
				AND dw.EntityId = @EntityId
				AND dw.ReturnPeriod = @ReturnPeriod
				AND dw.BillFromGstin IS NULL 
				AND tpdi.BillFromGstin IS NULL 
				AND dw.SectionType = @SectTypeIMPG 
				AND @SectTypeIMPG IN (SELECT SectionType FROM #TempDocumentSectionGroups)
				AND dw.IsAmendment IN (SELECT IsAmendment FROM #TempDocumentSectionGroups)
				AND dw.SourceType = @SourceTypeCounterPartyNotFiled
				AND dw.BillFromGstin = ISNULL(@Gstin, dw.BillFromGstin)
				AND tpdi.Id IS NULL;
		END
		ELSE
		BEGIN
			INSERT INTO #TempDeletedIds
			(
				Id
			)
			SELECT
				dw.Id
			FROM
				 oregular.PurchaseDocumentDW AS dw
				 LEFT JOIN #TempPurchaseDocumentIds AS tpdi ON tpdi.Id = dw.Id AND dw.BillFromGstin IS NOT NULL AND tpdi.BillFromGstin IS NOT NULL
			WHERE
				dw.SubscriberId = @SubscriberId
				AND dw.EntityId = @EntityId
				AND dw.ReturnPeriod = @ReturnPeriod
				AND dw.SectionType IN (SELECT SectionType FROM #TempDocumentSectionGroups)
				AND dw.IsAmendment IN (SELECT IsAmendment FROM #TempDocumentSectionGroups)
				AND dw.SourceType = @SourceTypeCounterPartyNotFiled
				AND dw.BillFromGstin = ISNULL(@Gstin, dw.BillFromGstin)
				AND tpdi.Id IS NULL;
		END
		
	END

	/*Delete Data for Not Filed */
	IF EXISTS (SELECT 1 FROM #TempDeletedIds)
	BEGIN
		DECLARE
			@DocumentStatusDeleted SMALLINT = 2,
			@ReconciliationMappingTypeExtended SMALLINT = 3;

		SELECT
			d.Id 	
		INTO
			#TempPurchaseDocumentIdsNotPushed
		FROM 
			#TempDeletedIds d;

		EXEC [oregular].[DeletePurchaseDocumentForRecoByIds]
			@DocumentStatusDeleted = @DocumentStatusDeleted,
			@ReconciliationMappingTypeExtended = @ReconciliationMappingTypeExtended;

		SET @Min = 1;

		SELECT 
			@Max = COUNT(AutoId)
		FROM 
			#TempDeletedIds

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN  ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize;

			/* delete purchase contact detail */
			DELETE 
				pdct
			FROM 
				oregular.PurchaseDocumentContacts AS pdct
				INNER JOIN #TempDeletedIds AS tdi ON pdct.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase custome detail */
			DELETE 
				pdcm
			FROM 
				oregular.PurchaseDocumentCustoms AS pdcm
				INNER JOIN #TempDeletedIds AS tdi ON pdcm.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase payment detail */
			DELETE 
				pdp
			FROM 
				oregular.PurchaseDocumentPayments AS pdp
				INNER JOIN #TempDeletedIds AS tdi ON pdp.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			
			/* delete purchase document items */
			DELETE 
				pdit
			FROM 
				oregular.PurchaseDocumentItems AS pdit
				INNER JOIN #TempDeletedIds AS tdi ON pdit.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase document rate wise items */
			DELETE 
				pdrit
			FROM 
				oregular.PurchaseDocumentRateWiseItems AS pdrit
				INNER JOIN #TempDeletedIds AS tdi ON pdrit.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase Document reference */
			DELETE 
				pdrf
			FROM 
				oregular.PurchaseDocumentReferences AS pdrf
				INNER JOIN #TempDeletedIds AS tdi ON pdrf.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;


			/* delete purchase document status table*/
			DELETE 
				ps
			FROM 
				oregular.PurchaseDocumentStatus AS ps
				INNER JOIN #TempDeletedIds AS tdi ON ps.PurchaseDocumentId = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase document data warehouse table*/
			DELETE 
				pdw
			FROM 
				oregular.PurchaseDocumentDW AS pdw
				INNER JOIN #TempDeletedIds AS tdi ON pdw.Id = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase document table data*/
			DELETE 
				pd
			FROM 
				oregular.PurchaseDocuments AS pd
				INNER JOIN #TempDeletedIds AS tdi ON pd.Id = tdi.Id
			WHERE 
				tdi.AutoId BETWEEN @Min AND @Records;

			SET @Min = @Records
		END
	END

	/* Don't move this execution pls add any code above this execution not below */
	EXEC [oregular].[InsertPurchaseDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;
		
	SELECT
		tpdi.Id,
		tpdi.GroupId,
		CASE WHEN tpdi.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS PlanLimitApplicable,
		CASE
			WHEN @ApiCategory IN (@ApiCategoryTxpGstr2a, @ApiCategoryTxpGstr9)
			THEN
				tpdi.FinancialYear
			ELSE
				CASE 
					WHEN IIF(LEN(ps.Gstr2BReturnPeriod) = 6, LEFT(ps.Gstr2BReturnPeriod,2), LEFT(ps.Gstr2BReturnPeriod,1)) > 3 
					THEN CONCAT(RIGHT(ps.Gstr2BReturnPeriod,4), RIGHT(ps.Gstr2BReturnPeriod,2)+1) 
					ELSE CONCAT(RIGHT(ps.Gstr2BReturnPeriod,4)-1, RIGHT(ps.Gstr2BReturnPeriod,2)) 
				END 
		END AS FinancialYear
	FROM
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN oregular.PurchaseDocumentStatus ps ON tpdi.Id = ps.PurchaseDocumentId

	DROP TABLE 
		#TempPurchaseDocumentIds, #TempPurchaseDocumentItems, #TempPurchaseDocuments,#TempDeletedIds,
		#TempPurchaseDocumentContacts,#TempPurchaseDocumentReferences;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[DeleteDocumentByIds]	 	 
* 	Comments			: 24-06-2020 | Kartik Bariya | This procedure is used to delete EwayBill Documents by Ids. 
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from DocumentWH to DocumentDW
						: 27-11-2020 | Sagar Patel		| Returned result containing  EntityId and Financial year
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE  @TotalRecord INT,
								@Ids [common].[BigIntType];
						  INSERT INTO @Ids VALUES (12547);

						  EXEC [ewaybill].[DeleteDocumentByIds]
								@Ids  =  @Ids,
								@PurposeTypeEWB = 8,
								@PurposeTypeEINV = 2,
								@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[DeleteDocumentByIds]
(
	@Ids [common].[BigIntType] READONLY,
	@PurposeTypeEINV SMALLINT, 
	@PurposeTypeEWB SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempEwayBillDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
	
	CREATE CLUSTERED INDEX IDX_#TempEwayBillDocumentIds ON #TempEwayBillDocumentIds(ID)

	INSERT INTO #TempEwayBillDocumentIds (Id) 
	SELECT
		Item
	FROM
		@Ids;
	
	SELECT
		DISTINCT
		eid.ParentEntityId AS EntityId,
		eid.FinancialYear AS FinancialYear
	INTO
		#EntityDetails
	FROM
		einvoice.DocumentDW AS eid
		INNER JOIN #TempEwayBillDocumentIds AS teidi ON teidi.Id = eid.Id

	-- Adding data with the purpose ewaybill only
	SELECT 
		teidi.Id 
	INTO
		#TempEwayBillDocumentIdsPurposeEWB
	FROM 
		#TempEwayBillDocumentIds AS teidi
		INNER JOIN einvoice.DocumentDW AS d	ON teidi.Id = d.Id
	WHERE 
		d.Purpose = @PurposeTypeEWB;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillDocumentIdsPurposeEWB ON #TempEwayBillDocumentIdsPurposeEWB (Id)

	-- Adding data with the purpose Ewaybill and EInvoice
	SELECT 
		teidi.Id 
	INTO
		#TempEwayBillDocumentIdsPurposeBoth
	FROM 
		#TempEwayBillDocumentIds AS teidi
		INNER JOIN einvoice.DocumentDW AS d	ON teidi.Id = d.Id
	WHERE 
		d.Purpose = (@PurposeTypeEINV | @PurposeTypeEWB);
	
	CREATE CLUSTERED INDEX IDX_#TempEwayBillDocumentIdsPurposeBoth ON #TempEwayBillDocumentIdsPurposeBoth (ID)

	IF EXISTS (SELECT Id FROM #TempEwayBillDocumentIdsPurposeBoth)
	BEGIN
		UPDATE 
			einvoice.Documents 
		SET 
			Purpose = @PurposeTypeEINV
		FROM 
			#TempEwayBillDocumentIdsPurposeBoth AS teidi
			INNER JOIN einvoice.Documents AS d	ON teidi.Id = d.Id

		UPDATE 
			einvoice.DocumentDW 
		SET 
			Purpose = @PurposeTypeEINV
		FROM 
			#TempEwayBillDocumentIdsPurposeBoth AS teidi
			INNER JOIN einvoice.DocumentDW AS d	ON teidi.Id = d.Id

		DELETE 
			vd 
		FROM 
			ewaybill.VehicleDetails vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushDate))
			INNER JOIN  #TempEwayBillDocumentIdsPurposeBoth teidi ON teidi.Id = vd.DocumentId
		
		DELETE 
			vm 
		FROM 
			ewaybill.VehicleMovements vm WITH(INDEX(NON_IDX_ewaybill_VehicleMovements_DocumentId_PushDate))
			INNER JOIN  #TempEwayBillDocumentIdsPurposeBoth teidi ON teidi.Id = vm.DocumentId
	END

	IF EXISTS (SELECT Id FROM #TempEwayBillDocumentIdsPurposeEWB)
	BEGIN
		DELETE 
			dr 
		FROM 
			einvoice.DocumentReferences dr 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = dr.DocumentId
		
		DELETE 
			di 
		FROM 
			einvoice.DocumentItems di 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = di.DocumentId
		
		DELETE 
			vd 
		FROM 
			ewaybill.VehicleDetails vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushDate))
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = vd.DocumentId
		
		DELETE 
			vm 
		FROM 
			ewaybill.VehicleMovements vm WITH(INDEX(NON_IDX_ewaybill_VehicleMovements_DocumentId_PushDate))
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = vm.DocumentId
		
		DELETE 
			ds
		FROM 
			einvoice.DocumentStatus ds 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = ds.DocumentId
		
		DELETE 
			ds
		FROM 
			ewaybill.DocumentStatus ds 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = ds.DocumentId
		
		DELETE	
			eic
		FROM 
			einvoice.DocumentContacts eic 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = eic.Documentid

		DELETE	
			eip
		FROM 
			einvoice.DocumentPayments eip 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = eip.DocumentId

		DELETE	
			eicu
		FROM 
			einvoice.DocumentCustoms eicu
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = eicu.DocumentId

		DELETE	
			d
		FROM 
			einvoice.Documents d 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = d.Id

		DELETE	
			dwh
		FROM 
			einvoice.DocumentDW dwh 
			INNER JOIN  #TempEwayBillDocumentIdsPurposeEWB teidi ON teidi.Id = dwh.Id
	END

	SELECT
		ED.EntityId,
		ED.FinancialYear
	FROM 
		#EntityDetails ED

	DROP TABLE #TempEwayBillDocumentIds, #TempEwayBillDocumentIdsPurposeEWB, #TempEwayBillDocumentIdsPurposeBoth, #EntityDetails;
END

GO

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[InsertDownloadedDocuments]
* 	Comments			: 15-05-2020 | Smita Parmar | This procedure is used to insert download ewaybill documents.
						  22-05-2020 | Smita Parmar | SourceType related changes and Updated logic for VechicleDetails
						  06-07-2020 | Smita Parmar | Added  EInvoiceStatus and EwayBillStatus into DownloadedDocumentType for status, move status related logic into C# code
						  13-07-2020 | Smita Parmar | Added SendNotification and EwayBillNumber in result
						  21-07-2020 | Smita Parmar | Renamed [ewaybill].[InsertDownloadedEwaybillDocuments] to [ewaybill].[InsertDownloadedDocuments]
						  28-07-2020 | Smita Parmar | Modified SP for document Uniquness criteria, Mode : I - Insert, U- Update, PU - Partial Update, S-Skip
						  28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						  31-07-2020 | Smita Parmar | Added condition to identified PU- partial update and Added ConsolidatedEwayBillNumber in VehicleDetails - I, U
						  06-08-2020 | Smita Parmar | Added Pos
						  18-08-2020 | Smita Parmar | Added DownloadedDocumentContactType Parameter for Address related destails
						  10-09-2020 | Smita Parmar | Added ISNULL check for FromCity for vehicle details
						  11-09-2020 | Smita Parmar | Added PushStatus in VehicleDetails
						  21-09-2020 | Smita Parmar | Added Condition to consider only Date instead of time to upsert Vehicle details 
						  22-09-2020 | Smita Parmar | Moved distance column from einvoice.documents to ewaybill.documentstatus
						  08-10-2020 | Chandresh Prajapati | Removed merge and add insert/update logic for vehicle detail
						  13-11-2020 | Chandresh Prajapati | Added TotalOtherCharges in Downloaded Documents
						  22-12-2020 | Prakash Parmar | Added condition for Document Type
						  05-02-2021 | Prakash Parmar | Added ExportShipTo And DispatchFrom2 ContactType In case of Irn generated and ewb not generated
						  11-03-2021 | Prakash Parmar | Added Parameter EwayBillPushStatusExpired
						  22-04-2021 | Chandresh Prajapati | Added Parameter DocumentStatusDraft,DocumentStatusApproved and DocumentStatusRejected
						  28-05-2021 | Prakash Parmar | Added Parameter ToEmailAddresses and ToMobileNumbers
						  08-12-2021 | Prakash Parmar | Added Parameter GenerationMode, ExtendedTimes
						  08-12-2021 | Prakash Parmar | Added Parameter UpdationMode
						  12-06-2023 | Prakash Parmar | Added IsDuplicateEwayBill Parameter
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
						  DECLARE @Documents AS ewaybill.[DownloadedDocumentType] 
						  DECLARE @DocumentContacts AS ewaybill.[DownloadedDocumentContactType]
						  DECLARE @DocumentItems AS ewaybill.[DownloadedDocumentItemType]
						  DECLARE @VehicleDetails AS ewaybill.[DownloadedVehicleDetails]
						  DECLARE @EntityIds AS [common].[IntType];
						  EXEC [ewaybill].[InsertDownloadedDocuments]
								@SubscriberId  = 164,
								@UserId = 486,
								@EntityId = 340,											
								@Documents = @Documents,
								@DocumentContacts = @DocumentContacts, 
								@DocumentItems = @DocumentItems,
								@VehicleDetails = @VehicleDetails,
								@BitTypeN = 0,
								@DocumentStatusYetNotGenerated = 1,
								@DocumentStatusGenerated = 2,
								@DocumentStatusCompleted = 3,
								@DocumentTypeDBN = 3,
								@DocumentTypeCRN = 2,
								@ContactTypeDispatchFrom = 2,
								@ContactTypeShipTo = 4,
								@ContactTypeExportShipTo = 5,
								@ContactTypeDispatchFrom2 = 6,
								@EwayBillPushStatusExpired = 7,
								@DocumentStatusDraft = 4,
								@DocumentStatusApproved = 5,
								@DocumentStatusRejected = 6,
								@SourceTypeGeneratedAgainstMe = 4,
								@SourceTypeAssignedForTransportation = 8;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[InsertDownloadedDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,	
	@Documents [ewaybill].[DownloadedDocumentType] READONLY,
	@DocumentContacts [ewaybill].[DownloadedDocumentContactType] READONLY,
	@DocumentItems [ewaybill].[DownloadedDocumentItemType] READONLY,	
	@VehicleDetails [ewayBill].[DownloadedVehicleDetails] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,	
	@ToEmailAddresses VARCHAR(324),
	@ToMobileNumbers VARCHAR(54),
	@IsDuplicateEwayBill BIT,
	@BitTypeN BIT,
	@DocumentStatusYetNotGenerated SMALLINT,
	@DocumentStatusGenerated SMALLINT,
	@DocumentStatusCompleted SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@ContactTypeDispatchFrom SMALLINT,
	@ContactTypeShipTo SMALLINT,
	@ContactTypeExportShipTo SMALLINT,
	@ContactTypeDispatchFrom2 SMALLINT,
	@EwayBillPushStatusExpired SMALLINT,
	@DocumentStatusDraft SMALLINT,
	@DocumentStatusApproved SMALLINT,
	@DocumentStatusRejected SMALLINT,
	@SourceTypeGeneratedAgainstMe SMALLINT,
	@SourceTypeAssignedForTransportation SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @INSERT INT = 1,
			@UPDATE INT = 2,
			@True BIT = 1,
			@False BIT = 0,			
			@CurrentDate DATETIME = GETDATE();

	SELECT 
		* 
	INTO 
		#TempDocuments
	FROM 
		@Documents ted;

	CREATE NONCLUSTERED INDEX IDX_TempDocuments_GroupId ON #TempDocuments(GroupId);
	
	SELECT
		*
	INTO 
		#TempDocumentItems
	FROM
		@DocumentItems;

	SELECT
		*
	INTO 
		#TempDocumentContacts
	FROM
		@DocumentContacts;

	SELECT 
		*
	INTO 
		#TempVehicleDetails
	FROM
		@VehicleDetails;

	CREATE TABLE #TempDocumentIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		Mode CHAR (6),
		GeneratedDate SMALLDATETIME,
		[Priority] SMALLINT,
		SendNotification BIT NULL Default 0
	);
	
	CREATE INDEX  IDX_TempDocumentIds_GroupId ON #TempDocumentIds(GroupId) INCLUDE(Id);

	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL	
	);

	CREATE CLUSTERED INDEX IDX_TempUpsertDocumentIds ON #TempUpsertDocumentIds (ID)	

	INSERT INTO #TempDocumentIds
	(
		Id,
		GroupId,
		Mode,
		GeneratedDate,
		[Priority]
	)
	SELECT
		edw.Id,
		td.GroupId,
		CASE 
			WHEN ds.[Status] = @DocumentStatusGenerated OR (ds.[Status] = @DocumentStatusCompleted AND ds.PushStatus = @EwayBillPushStatusExpired AND ds.PushStatus != td.EwayBillPushStatus) THEN 'PU'
			WHEN eds.[Status] = @DocumentStatusGenerated AND ds.[Status] IN (@DocumentStatusYetNotGenerated,@DocumentStatusDraft,@DocumentStatusApproved,@DocumentStatusRejected) THEN 'PUEINV'
			WHEN ds.[Status] IN (@DocumentStatusYetNotGenerated,@DocumentStatusDraft,@DocumentStatusApproved,@DocumentStatusRejected) THEN 'U'
			WHEN ds.[Status] = @DocumentStatusCompleted AND edw.TransporterId IS NOT NULL AND edw.TransporterId != td.TransporterId THEN 'PU'
			WHEN ds.[Status] = @DocumentStatusCompleted  THEN 'S'
		END,
		td.EwayBillDate,
		CASE
			WHEN ds.EwayBillNumber = td.EwayBillNumber THEN 2 /*Matched*/
			WHEN ds.EwayBillNumber IS NULL THEN 1 /*Near Matched*/
			ELSE 0 /*Not Matched*/
		END
	FROM
		#TempDocuments td
		INNER JOIN einvoice.Documents AS edw ON
		(
			edw.DocumentNumber = td.DocumentNumber
			AND edw.ParentEntityId =  @EntityId
			AND edw.DocumentFinancialYear  = td.DocumentFinancialYear
			AND edw.SubscriberId = @SubscriberId
			AND edw.SupplyType = td.SupplyType
			AND edw.[Type] = td.[Type]
		)
		INNER JOIN einvoice.DocumentContacts AS dc ON (
			edw.Id = dc.DocumentId
			AND dc.[Type] = 1
			AND ISNULL(dc.Gstin,'') = ISNULL(td.BillFromGstin,'')
		)
		INNER JOIN ewaybill.DocumentStatus ds ON
		(
			 ds.DocumentId = edw.Id
		)
		INNER JOIN einvoice.DocumentStatus eds ON
		(
			 eds.DocumentId = edw.Id
		)

	DELETE 
	FROM 
		#TempDocumentIds 
	WHERE 
		[Priority] = 0 
		OR 
		(
			[Priority] = 1 AND GroupId IN (SELECT GroupId FROM #TempDocumentIds WHERE [Priority] = 2)
		)

	;WITH cte
	 AS
	 (
	 	SELECT ROW_NUMBER() OVER(Partition by Id order by GeneratedDate) rownum,*
	 	FROM 
	 		#TempDocumentIds
		WHERE
			[Priority] = 1
	 )
	 
	 DELETE FROM cte WHERE rownum > 1;

	 INSERT INTO einvoice.Documents
		(
			[SubscriberId],
			[EntityId],
			[ParentEntityId],
			[UserId],
			[SupplyType],
			[Purpose],	
			[Type],
			[TransactionType],
			[TransactionMode],
			[DocumentNumber],
			[DocumentDate],			
			[TotalTaxableValue],
			[TotalTaxAmount],
			[TransporterID],
			[TransporterName],
			[VehicleType],	
			[ReturnPeriod],
			[Pos],
			[DocumentValue],
			[ReverseCharge],
			[ClaimRefund],
			[FinancialYear],
			[DocumentFinancialYear],
			[SourceType],			
			[GroupId],
			[DocumentOtherCharges],
			[ToEmailAddresses],
			[ToMobileNumbers]
		)
		OUTPUT 
			inserted.Id, inserted.GroupId, 'I', @True
		INTO 
			#TempDocumentIds(Id, GroupId, Mode, SendNotification)
		SELECT
			@SubscriberId,  
			@EntityId,
			@EntityId,
			@UserId,
			d.SupplyType,		
			d.PurposeType,	
			d.Type,
			d.TransactionType,
			d.TransactionMode,
			d.DocumentNumber,
			d.DocumentDate,			
			d.TotalTaxableValue,
			d.TotalTaxAmount,
			d.TransporterID,
			d.TransporterName,
			d.VehicleType,	
			d.ReturnPeriod,
			d.Pos,
			d.DocumentValue,
			d.ReverseCharge,
			d.ClaimRefund,
			d.DocumentFinancialYear,
			d.DocumentFinancialYear,
			d.SourceType,			
			d.GroupId,
			d.TotalOtherCharges,
			CASE WHEN (d.SourceType & (@SourceTypeGeneratedAgainstMe | @SourceTypeAssignedForTransportation) <> 0) THEN @ToEmailAddresses END,
			CASE WHEN (d.SourceType & (@SourceTypeGeneratedAgainstMe | @SourceTypeAssignedForTransportation) <> 0) THEN @ToMobileNumbers END
		FROM
			#TempDocuments d
		WHERE 
			d.GroupId NOT IN (SELECT GroupId FROM #TempDocumentIds);

	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode = 'I')
	BEGIN
		INSERT INTO einvoice.DocumentStatus
		(
			DocumentId,		
			IsPushed,
			PushStatus,
			[Status]
		)
		SELECT  
			tdi.Id AS DocumentId,
			td.IsEInvoicePushed,
			td.EInvoicePushStatus,
			td.EInvoiceStatus
		FROM
			#TempDocumentIds AS tdi
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode = 'I';

		INSERT INTO ewaybill.DocumentStatus
		(
			DocumentId,
			Distance,
			PushStatus,
			EwayBillNumber,
			ValidUpto,
			GeneratedDate,
			IsPushed,
			PushDate,
			LastSyncDate,			
			[Status],
			IsMultiVehicleMovementInitiated,
			GenerationMode,
			ExtendedTimes,
			BillingDate
		)
		SELECT 
			tdi.Id AS DocumentId,
			td.Distance,
			td.EwayBillPushStatus,
			td.EwayBillNumber,
			td.EwayBillValidTill,
			td.EwayBillDate,
			td.IsEwayBillPushed,
			td.EwayBillDate,
			@CurrentDate,
			td.EwayBillStatus,
			@BitTypeN,
			td.GenerationMode,
			td.ExtendedTimes,
			@CurrentDate
		FROM
			#TempDocumentIds AS tdi
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode = 'I';
		END

	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode IN ('U', 'PU', 'PUEINV'))
	BEGIN		
		UPDATE
			einvoice.Documents
		SET 			
			SupplyType = td.SupplyType,
			[Type] = td.[Type],
			TransactionType = td.TransactionType,
			DocumentDate = td.DocumentDate,		
			VehicleType = td.VehicleType,
			TotalTaxableValue = td.TotalTaxableValue,
			TotalTaxAmount = td.TotalTaxAmount,
			ReturnPeriod = td.ReturnPeriod,		
			FinancialYear = td.DocumentFinancialYear,
			DocumentFinancialYear = td.DocumentFinancialYear,
			Pos = td.Pos,
			DocumentValue = td.DocumentValue,
			GroupId = td.GroupId,
			ModifiedStamp =  @CurrentDate,
			DocumentOtherCharges = td.TotalOtherCharges
		FROM
			einvoice.Documents AS d
			INNER JOIN #TempDocumentIds tdi ON tdi.Id = d.Id
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE
			tdi.Mode = 'U';	

		UPDATE
			einvoice.Documents
		SET 			
			TransporterID = td.TransporterID,
			TransporterName = td.TransporterName,			
			SourceType = td.SourceType,
			Purpose = CASE WHEN d.Purpose & td.PurposeType = 0 THEN (td.PurposeType | d.Purpose) ELSE  d.Purpose  END
		FROM
			einvoice.Documents AS d
			INNER JOIN #TempDocumentIds tdi ON tdi.Id = d.Id
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE
			tdi.Mode IN ('U', 'PU', 'PUEINV');

		UPDATE 
			tdi
		SET
			tdi.SendNotification =	CASE 
										WHEN ds.PushStatus = td.EwayBillPushStatus 
										THEN @False 
										ELSE @True 
									END  
		FROM
			ewaybill.DocumentStatus ds
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = ds.DocumentId
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode IN ('U', 'PU', 'PUEINV');

		UPDATE 
			ds
		SET 
			Distance = td.Distance,
			PushStatus = td.EwayBillPushStatus,
			ValidUpto = td.EwayBillValidTill,
			LastSyncDate = @CurrentDate,
			[Status] = td.EwayBillStatus,
			ModifiedStamp = @CurrentDate,
			EwayBillNumber = ISNULL(ds.EwayBillNumber,td.EwayBillNumber),
			GeneratedDate = ISNULL(ds.GeneratedDate,td.EwayBillDate),
			IsPushed = CASE WHEN ds.IsPushed = 0 THEN 1 ELSE ds.IsPushed END,
			ExtendedTimes = td.ExtendedTimes,
			GenerationMode = td.GenerationMode,
			BillingDate = ISNULL(ds.BillingDate, @CurrentDate),
			[Errors] = CASE WHEN @IsDuplicateEwayBill = @True THEN NULL ELSE ds.Errors END
		FROM
			ewaybill.DocumentStatus ds
			INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = ds.DocumentId
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE 
			tdi.Mode IN ('U', 'PU', 'PUEINV');
	END
			
	/* VehicleDetails Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode IN ('I', 'U', 'PU', 'PUEINV'))
	BEGIN

		DELETE
			vd
		FROM
			#TempDocumentIds tdi
			INNER JOIN ewaybill.VehicleDetails AS vd ON vd.DocumentId = tdi.Id
		WHERE 
			tdi.Mode IN ('U', 'PU', 'PUEINV');
		
		SELECT  
			tdi.Id,
			vd.Id AS VehicleDetailId,
			tv.VehicleNumber,
			tv.FromCity,
			tv.FromState,
			tv.UpdatedByGSTIN,
			tv.ConsolidatedEwayBillNumber,
			tv.PushDate,
			tv.TransportMode,
			tv.TransportDocumentNumber,
			tv.[TransportDocumentDate],
			tv.GroupNumber,
			tv.IsLatest,
			tv.PushStatus,
			tv.UpdationMode
		INTO 
			#TempUpdateVehicleDetails
		FROM
			#TempVehicleDetails tv
			INNER JOIN #TempDocuments AS td ON tv.GroupId = td.GroupId
			INNER JOIN #TempDocumentIds AS tdi ON td.GroupId = tdi.GroupId
			LEFT JOIN ewaybill.VehicleDetails vd ON
			(
				vd.DocumentId = tdi.Id
				AND vd.TransportMode = tv.TransportMode
				AND vd.PushDate = tv.PushDate
			)
		WHERE 
			tdi.Mode IN ('I', 'U', 'PU', 'PUEINV')
			
		--WHEN MATCHED THEN
		UPDATE vd
			SET vd.IsLatest = tvd.IsLatest,
				vd.UpdatedByGSTIN = tvd.UpdatedByGSTIN,
				vd.ConsolidatedEwayBillNumber = tvd.ConsolidatedEwayBillNumber,
				vd.ModifiedStamp = @CurrentDate
		 FROM ewaybill.VehicleDetails vd
			INNER JOIN #TempUpdateVehicleDetails AS tvd ON vd.Id = tvd.VehicleDetailId

		--WHEN NOT MATCHED THEN
		INSERT into ewaybill.VehicleDetails
		(	 [DocumentId]
			,[VehicleNumber]
			,[FromCity]
			,[FromState]
			,[UpdatedByGSTIN]
			,[ConsolidatedEwayBillNumber]
			,[PushDate]
			,[TransportMode]
			,[TransportDocumentNumber]
			,[TransportDocumentDate]
			,[GroupNumber]
			,[IsLatest]
			,[PushStatus]
			,[Stamp]
			,[UpdationMode]
		)
		SELECT 
			tvd.Id,
			tvd.VehicleNumber,
			tvd.FromCity,
			tvd.FromState,
			tvd.UpdatedByGSTIN,
			tvd.ConsolidatedEwayBillNumber,
			tvd.PushDate,
			tvd.TransportMode,
			tvd.TransportDocumentNumber,
			tvd.TransportDocumentDate,
			tvd.GroupNumber,
			tvd.IsLatest,
			tvd.PushStatus,
			@CurrentDate,
			tvd.UpdationMode
		FROM
			#TempUpdateVehicleDetails tvd
		WHERE 
			tvd.VehicleDetailId IS NULL 

		DROP TABLE #TempUpdateVehicleDetails;
	END

	/* DocumentItems, DocumentContacts Insert and Update Case */	
	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode IN ('I', 'U'))
	BEGIN
		DECLARE @Min INT = 1, @Max INT, @BatchSize INT , @Records INT
		SELECT 
			@Max = MAX(AutoId)
		FROM #TempDocumentIds

		SELECT @Batchsize = CASE WHEN ISNULL(@Max,0) > 100000 
							THEN  ((@Max*10)/100)
							ELSE @Max
							END
		WHILE(@Min <= @Max)
		BEGIN 
			SET @Records = @Min + @BatchSize		
			DELETE
				di
			FROM 
				einvoice.DocumentItems AS di
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = di.DocumentId
			WHERE 
				Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;

			DELETE
				dc
			FROM 
				einvoice.DocumentContacts AS dc
				INNER JOIN #TempDocumentIds AS tdi ON tdi.Id = dc.DocumentId
			WHERE 
				Mode IN ('I', 'U')
				AND tdi.AutoId BETWEEN @Min AND @Records;
			
			SET @Min = @Records
		END

		INSERT INTO einvoice.DocumentItems
		(
			DocumentId,	
			[IsService],
			[Name],
			[Description],
			[Hsn],
			Quantity,
			UQC,
			Rate,
			CessRate,
			CessNonAdvaloremRate,
			CgstAmount,
			SgstAmount,
			IgstAmount,
			CessAmount,
			CessNonAdvaloremAmount,	
			TaxableValue
		)
		SELECT			
			 tdis.Id,
			 tdi.[IsService],
			 tdi.[Name],
			 tdi.[Description],
			 tdi.Hsn,
			 tdi.Quantity,
			 tdi.UQC,
			 tdi.Rate,
			 tdi.CessRate,
			 tdi.CessNonAdvaloremRate,		
			 tdi.CgstAmount,
			 tdi.SgstAmount,
			 tdi.IgstAmount,
			 tdi.CessAmount,
			 tdi.CessNonAdvaloremAmount,
			 tdi.TaxableValue
		FROM
			#TempDocumentItems AS tdi
			INNER JOIN #TempDocumentIds AS tdis ON tdis.GroupId = tdi.GroupId
		WHERE tdis.Mode IN ('I', 'U')

		INSERT INTO [einvoice].[DocumentContacts]
        (	
			[DocumentId]
           ,[Gstin]
           ,[LegalName]
           ,[TradeName]           
           ,[AddressLine1]
           ,[AddressLine2]
           ,[City]
           ,[StateCode]
           ,[Pincode]
           ,[Type]
           ,[Stamp]
		)
		SELECT
		   tdis.Id,
           tdc.Gstin,
           tdc.LegalName,
           tdc.TradeName,          
           tdc.AddressLine1,
           tdc.AddressLine2,
           tdc.City,
           tdc.StateCode,
           tdc.Pincode,
           tdc.Type,
           @CurrentDate
		FROM
			#TempDocumentContacts AS tdc
			INNER JOIN #TempDocumentIds AS tdis ON tdis.GroupId = tdc.GroupId
		WHERE tdis.Mode IN ('I', 'U')
	END;
	
	-- Handle 5 and 6 contact type
	IF EXISTS (SELECT AutoId FROM #TempDocumentIds Where Mode IN ('PUEINV'))
	BEGIN
		
		SELECT
			tdi.Id,
			tdi.GroupId
		INTO #TempUpdateContactDocumentIds
		FROM #TempDocumentIds tdi
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdi.GroupId
		WHERE tdi.Mode IN ('PUEINV');

		SELECT
			tdi.Id,
			shipto.Id AS ShipToDocumentContactId,
			dispatchfrom.Id AS DispatchFromDocumentContactId,
			tdc.AddressLine1,
			tdc.AddressLine2,
			tdc.City,
			tdc.GroupId,
			tdc.Gstin,
			tdc.LegalName,
			tdc.Pincode,
			tdc.StateCode,
			tdc.TradeName,
			tdc.[Type]
		INTO 
			#TempUpdateDocumentContact
		FROM
			#TempDocumentContacts tdc
			INNER JOIN #TempDocuments AS td ON td.GroupId = tdc.GroupId
			INNER JOIN #TempUpdateContactDocumentIds AS tdi ON tdi.GroupId = td.GroupId
			LEFT JOIN einvoice.DocumentContacts shipto ON
			(
				shipto.DocumentId = tdi.Id
				AND shipto.[Type] = @ContactTypeShipTo
				AND shipto.AddressLine1 = tdc.AddressLine1
				AND shipto.City = tdc.City
				AND shipto.Pincode = tdc.Pincode
				AND shipto.StateCode = tdc.StateCode
			)
			LEFT JOIN einvoice.DocumentContacts dispatchfrom ON
			(
				dispatchfrom.DocumentId = tdi.Id
				AND dispatchfrom.[Type] = @ContactTypeDispatchFrom
				AND dispatchfrom.AddressLine1 = tdc.AddressLine1
				AND dispatchfrom.City = tdc.City
				AND dispatchfrom.Pincode = tdc.Pincode
				AND dispatchfrom.StateCode = tdc.StateCode
			)
		WHERE
			tdc.[Type] In (@ContactTypeShipTo, @ContactTypeDispatchFrom);
			
		DELETE dc
		FROM
			einvoice.DocumentContacts dc
			INNER JOIN #TempUpdateDocumentContact tdc ON dc.DocumentId = tdc.Id
 		WHERE (tdc.ShipToDocumentContactId IS NULL AND tdc.[Type] = @ContactTypeShipTo AND dc.[Type] = @ContactTypeExportShipTo) OR
			  (tdc.DispatchFromDocumentContactId IS NULL AND tdc.[Type] = @ContactTypeDispatchFrom AND dc.[Type] = @ContactTypeDispatchFrom2);

		--WHEN NOT MATCHED THEN
		INSERT INTO einvoice.DocumentContacts
		(	 
			 [DocumentId]
			,[Gstin]
			,[LegalName]
			,[TradeName]
			,[AddressLine1]
			,[AddressLine2]
			,[City]
			,[StateCode]
			,[Pincode]
			,[Type]
			,[Stamp]
		)
		SELECT 
			tdc.Id,
			tdc.Gstin,
			tdc.LegalName,
			tdc.TradeName,
			tdc.AddressLine1,
			tdc.AddressLine2,
			tdc.City,
			tdc.StateCode,
			tdc.Pincode,
			CASE WHEN tdc.[Type] = @ContactTypeShipTo THEN @ContactTypeExportShipTo ELSE @ContactTypeDispatchFrom2 END,
			@CurrentDate
		FROM
			#TempUpdateDocumentContact tdc
		WHERE
			(tdc.ShipToDocumentContactId IS NULL AND tdc.[Type] = @ContactTypeShipTo) OR
			(tdc.DispatchFromDocumentContactId IS NULL AND tdc.[Type] = @ContactTypeDispatchFrom);

		DROP TABLE #TempUpdateDocumentContact;

	END

	INSERT INTO #TempUpsertDocumentIds (Id)
	SELECT 
		Id 
	FROM 
		#TempDocumentIds
		
	EXEC [einvoice].[InsertEinvoiceDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;

	SELECT
		td.Id,
		td.GroupId,
		ds.EwayBillNumber,
		td.SendNotification,
		CASE WHEN ds.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS PlanLimitApplicable
	FROM
		#TempDocumentIds td
		INNER JOIN ewaybill.DocumentStatus ds ON ds.DocumentId = td.Id

	DROP TABLE #TempDocuments, #TempDocumentContacts, #TempDocumentItems, #TempDocumentIds, #TempVehicleDetails;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[PrepareConsolidatedEwayBillByIds] 
* 	Comments			: 10-06-2020 | Smita Parmar	| Use to Prepare Consolidated Ewaybills
						  25-06-2020 | Smita Parmar	| Removed Filter Documents SP call and Added Ids as parameter, Also renamed this SP
						  17-07-2020 | Smita Parmar | Renamed FromPlace to FromCity
						  23-07-2020 | Pooja Rajpurohit | Optimization changes -Removed Merge syntax for Itemlevel data insert
  					                                     , DenseRank to calculate Groupid and an update for #tempDocument nd added index on temp table
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: 
						   DECLARE @Ids [common].[BigIntType];

						   ----INSERT INTO @Ids VALUES (12495);
						   --INSERT INTO @Ids VALUES (12496);
						   ----INSERT INTO @Ids VALUES (12497);
						 						 						  
						  EXEC [ewaybill].[PrepareConsolidatedEwayBillByIds]
								@TransportMode = 1,
								@FromState = 24,
								@FromCity = 'Ahmedabad',
								@TransportDocumentNumber = 'INV/PK/00015',
								@TransportDocumentDate = '2020-06-29 00:00:00',
								@VehicleNumber = 'GJ09AP5170',
								@ToEmailAddresses = '',
								@ToMobileNumbers = '',
								@Ids  =  @Ids,
								@SubscriberId = 164,								
								@SourceTypeGeneratedByMe = 2,
								@DocumentStatusGenerated = 2,							
								@UserId = 663,
								@ConsolidatedEwayBillPushStatusYetNotGenerated = 1,
								@ConsolidatedEwayBillPushStatusGenerated = 2,
								@ConsolidatedEwayBillPushStatusRegenerated = 3,
								@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[PrepareConsolidatedEwayBillByIds]
(
	@TransportMode SMALLINT,
	@FromState SMALLINT,
	@FromCity VARCHAR(50),
	@TransportDocumentNumber VARCHAR(15),
	@TransportDocumentDate SMALLDATETIME,
	@VehicleNumber VARCHAR(15),
	@ToEmailAddresses VARCHAR(324),
	@ToMobileNumbers VARCHAR(54),
	@Ids [common].[BigIntType] READONLY,
	@SubscriberId INT,	
	@SourceTypeGeneratedByMe SMALLINT,
	@DocumentStatusGenerated SMALLINT,
	@UserId INT,
	@ConsolidatedEwayBillPushStatusYetNotGenerated SMALLINT,
	@ConsolidatedEwayBillPushStatusGenerated SMALLINT,
	@ConsolidatedEwayBillPushStatusRegenerated SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @INSERT INT = 1,
			@UPDATE INT = 2,
			@False BIT = 0;

	CREATE TABLE #TempEwayBillDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
		

	CREATE TABLE #TempDocuments(
		[GroupId] BIGINT IDENTITY(1,1) NOT NULL,
		[Id] [BigInt] NULL,
		[SubscriberId] [int] NOT NULL,
		[EntityId] [int] NOT NULL,
		[ParentEntityId] [int] NOT NULL,
		[UserId] [int] NOT NULL,
		[StatisticId] [bigint] NULL,
		[TransportMode] [smallint] NULL,
		[FromState] [smallint] NULL,
		[FromCity] [varchar](50) NULL,
		[TransportDocumentNumber] [varchar](15) NULL,
		[TransportDocumentDate] [smalldatetime] NULL,
		[VehicleNumber] [varchar](20) NULL,
		[Reason] [smallint] NULL,
		[Remarks] [varchar](50) NULL,
		[ToEmailAddresses] [varchar](324) NULL,
		[ToMobileNumbers] [varchar](54) NULL,
		[ReturnPeriod] [int]  NULL,
		[FinancialYear] [int]  NULL,
		[SourceType] [smallint]  NULL,
		[Mode] [int] NULL		
	);
	
	INSERT INTO #TempEwayBillDocumentIds(Id)
	SELECT
		Item
	FROM
		@Ids;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillDocumentIds ON #TempEwayBillDocumentIds(Id)
	
	CREATE TABLE #TempUpsertDocumentIds
	(
		Id BIGINT NOT NULL,
		GroupId INT NOT NULL
	);

	---- Get entity wise documents
	SELECT 
		dw.EntityId,
		dw.Id as DocumentId, 
		ds.EwayBillNumber, 
		dw.ParentEntityId, 
		(SELECT [common].[GetReturnPeriodFromDate](GETDATE())) ReturnPeriod,
		(CASE WHEN MONTH(getdate()) >= 4 THEN CONCAT(YEAR(getdate()), RIGHT(YEAR(getdate())+1,2)) ELSE CONCAT(YEAR(getdate())-1, RIGHT(YEAR(getdate()),2)) END) FinancialYear
	INTO 
		#TempEntitiesWiseDocuments
	FROM 
		einvoice.DocumentDW dw
		INNER JOIN ewaybill.DocumentStatus ds ON ds.DocumentId = dw.Id
		INNER JOIN #TempEwayBillDocumentIds teds ON teds.Id = dw.Id
	WHERE 
		ds.[Status] = @DocumentStatusGenerated AND ds.EwayBillNumber IS NOT NULL; -- Generated
			
	INSERT INTO #TempDocuments
	(
		[SubscriberId],
		[EntityId],
		[ParentEntityId],
		[UserId],	
		[ReturnPeriod],
		[FinancialYear],
		[SourceType],		
		[TransportMode],
		[FromState],
		[FromCity],
		[TransportDocumentNumber],
		[TransportDocumentDate],
		[VehicleNumber],
		[ToEmailAddresses],
		[ToMobileNumbers]
	)
	SELECT distinct 
		@SubscriberId, 
		td.EntityId, 
		td.ParentEntityId, 
		@UserId, 
		td.ReturnPeriod,
		td.FinancialYear, 
		@SourceTypeGeneratedByMe AS [SourceType],
		@TransportMode,
		@FromState,
		@FromCity,
		@TransportDocumentNumber,
		@TransportDocumentDate,
		@VehicleNumber,
		@ToEmailAddresses,
		@ToMobileNumbers
	FROM
		#TempEntitiesWiseDocuments  td;

	CREATE CLUSTERED INDEX IDX_#TempDocuments ON #TempDocuments (EntityId,ReturnPeriod);
	
	-- Decide where need to perform insert or update operation
	UPDATE
		#TempDocuments
	SET 
	   Id = cd.Id,	   
	   Mode = (	CASE 
					WHEN cd.Id IS NULL OR cds.PushStatus = @ConsolidatedEwayBillPushStatusRegenerated OR cds.PushStatus = @ConsolidatedEwayBillPushStatusGenerated 
					THEN @INSERT
					WHEN cds.PushStatus = @ConsolidatedEwayBillPushStatusYetNotGenerated 
					THEN @UPDATE 
				END)
	FROM
		#TempDocuments td
		LEFT JOIN ewaybill.ConsolidatedDocuments AS cd ON
		(
			cd.TransportMode = td.TransportMode 
			AND ISNULL(cd.TransportDocumentNumber,'') = ISNULL(td.TransportDocumentNumber,'')
			AND ISNULL(cd.TransportDocumentDate,'') = ISNULL(td.TransportDocumentDate,'')
			AND ISNULL(cd.VehicleNumber, '') = ISNULL(td.VehicleNumber, '') 
			AND cd.FromCity = td.FromCity
			AND cd.FromState = td.FromState
			AND cd.EntityId = td.EntityId
		)
		LEFT JOIN ewaybill.ConsolidatedDocumentStatus AS cds ON cds.ConsolidatedDocumentId = cd.Id;

	INSERT INTO ewaybill.ConsolidatedDocuments
	(
		[SubscriberId],
		[EntityId],
		[ParentEntityId],
		[UserId],
		[StatisticId],
		[TransportMode],
		[FromState],
		[FromCity],
		[TransportDocumentNumber],
		[TransportDocumentDate],
		[VehicleNumber],
		[Reason],
		[Remarks],
		[ToEmailAddresses],
		[ToMobileNumbers],
		[ReturnPeriod],
		[FinancialYear],
		[SourceType],
		[Stamp],
		[GroupId]
	)
	OUTPUT 
		inserted.Id, inserted.GroupId
	INTO 
		#TempUpsertDocumentIds(Id, GroupId)
	SELECT
		@SubscriberId,  
		d.EntityId,
		d.ParentEntityId,
		d.UserId,
		d.StatisticId,	
		d.TransportMode,
		d.FromState,
		d.FromCity,
		d.TransportDocumentNumber,
		d.TransportDocumentDate,
		d.VehicleNumber,
		d.Reason,
		d.Remarks,
		d.ToEmailAddresses,
		d.ToMobileNumbers,
		d.ReturnPeriod,
		d.FinancialYear,
		d.SourceType,
		Getdate(),
		GroupId
	FROM
		#TempDocuments d
	WHERE 
		Mode = @INSERT;


	-- Insert status for prepared consildated ewaybills that yet not generated
	INSERT INTO [ewaybill].[ConsolidatedDocumentStatus]
        ([ConsolidatedDocumentId]          
        ,[IsPushed]
        ,[PushStatus]         
        ,[Status]         
        ,[Stamp])
	SELECT 
		teudi.Id AS ConsolidatedDocumentId,
		@False,
		@ConsolidatedEwayBillPushStatusYetNotGenerated,
		@ConsolidatedEwayBillPushStatusYetNotGenerated,
		Getdate()
	FROM
		#TempDocuments AS ted
		INNER JOIN #TempUpsertDocumentIds AS teudi ON ted.GroupId = teudi.GroupId
	WHERE 
		ted.Mode = @INSERT; 


	Update 
		ewaybill.ConsolidatedDocuments
	SET 
		ModifiedStamp = Getdate()
	OUTPUT 
		inserted.Id, inserted.GroupId
	INTO 
		#TempUpsertDocumentIds(Id, GroupId)
    FROM
		ewaybill.ConsolidatedDocuments AS cd
		INNER JOIN #TempDocuments AS ted ON ted.Id = cd.Id
	WHERE
		ted.Mode = @UPDATE;	


	CREATE TABLE #TempDeletedDocuments(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		ID BIGINT NOT NULL
	);
	
	INSERT INTO #TempDeletedDocuments(ID)
	SELECT 
		Id
	FROM #TempUpsertDocumentIds;
	
	/* Delete DocumentItems for both Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempDeletedDocuments)
	BEGIN
	
		DECLARE @Min INT = 1, @Max INT, @BatchSize INT , @Records INT
		SELECT 
			@Max = COUNT(AutoId)
		FROM #TempDeletedDocuments

		SELECT @Batchsize = CASE WHEN ISNULL(@Max,0) > 100000 
							THEN  ((@Max*10)/100)
							ELSE @Max
							END
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize		
			
			DELETE CDI
			FROM 
				[ewaybill].[ConsolidatedDocumentItems] AS CDI
				INNER JOIN #TempDeletedDocuments AS tded ON CDI.ConsolidatedDocumentId = tded.ID
			WHERE 
				tded.AutoId BETWEEN @Min AND @Records;
			
			SET @Min = @Records
		END
	END;

	INSERT INTO [ewaybill].[ConsolidatedDocumentItems]
	(
		[ConsolidatedDocumentId]
		,[DocumentId]
		,[EwayBillNumber]
		,[Stamp]
	)
	SELECT
		cd.Id AS ConsolidatedDocumentId,
		tewd.DocumentId,
		tewd.EwayBillNumber,
		GETDATE()
	FROM 
	ewaybill.ConsolidatedDocuments cd
	INNER JOIN #TempUpsertDocumentIds teud ON teud.Id = cd.Id
	INNER JOIN #TempEntitiesWiseDocuments tewd ON tewd.Entityid = cd.EntityID

	DROP TABLE #TempEwayBillDocumentIds, #TempEntitiesWiseDocuments, #TempDocuments, #TempUpsertDocumentIds 

END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[SetDeliveryStatusByIds] 	 	 
* 	Comments			: 24-06-2020 | Prakash Parmar | This procedure is used to set Eway bill Delivery Status.
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 21-12-2020 | Chandresh Prajapati | Update Remarks length 250
						: 17-04-2024 | Chandresh Prajapati		| Added @AuditTrailDetails parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @Ids [common].[BigIntType];
						  INSERT INTO @Ids (Item) VALUES (234)

						  EXEC [ewaybill].[SetDeliveryStatusByIds]
							@Ids = @Ids,
							@DeliveryDate = '2020-05-14 00:00:00',
							@Remarks = 'Delivered',
							@EwayBillPushStatusDelivered = 10,
							@DocumentStatusCompleted = 3,
							@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[SetDeliveryStatusByIds]
(
	@Ids [common].[BigIntType] READONLY,
	@DeliveryDate SMALLDATETIME,
	@Remarks VARCHAR(250),
	@EwayBillPushStatusDelivered SMALLINT,
	@DocumentStatusCompleted SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	
		doc.Item
	INTO
		#TempIds
	FROM
		@Ids AS doc;
	
	CREATE CLUSTERED INDEX IDX_#TempIds ON #TempIds (Item)

	UPDATE
		ds
	SET
		ds.DeliveredDate = @DeliveryDate,
		ds.Remarks = @Remarks,
		ds.ModifiedStamp = GETDATE(),
		ds.PushStatus = @EwayBillPushStatusDelivered,
		ds.[Status] = @DocumentStatusCompleted,
		ds.Errors = NULL
	FROM
		ewaybill.DocumentStatus AS ds
		INNER JOIN #TempIds teid ON ds.DocumentId = teid.Item;
	
	DROP TABLE #TempIds;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushRequest] 	 	 
* 	Comments			: 10-04-2020 | Prakash Parmar | This procedure is used to Update Eway bills status.
						:  01-06-2020 | Prakash Parmar | Make Errors null in case of inprogress state.
						:  01-07-2020 | Prakash Parmar | Change DocumentIds to Ids
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 24-09-2020 | Chandresh Prajapati | Added TransactionType, EinvStatus,Purpose in select statement
						: 03-02-2023 | Prakash Parmar | Change to handle pricing plan impact
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @Ids AS [common].[BigIntType]

						  INSERT INTO @Ids VALUES (274683);

						  EXEC [ewaybill].[UpdatePushRequest]
								@Ids =  @Ids,
								@RequestId = '',
								@TransactionLimit = 10,
								@PushType = NULL,
								@IsFallback = 0,
								@EwayBillPushStatusInProgress = 2
								@PushTypeGenerateByIrn = 4,
								@PushTypeGenerate = 2,
								@TransactionTypeB2C = 12,
								@DocumentStatusGenerated = 2,
								@PurposeTypeEINV = 2;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushRequest]
(
	 @Ids [common].[BigIntType] READONLY,
	 @RequestId UNIQUEIDENTIFIER,
	 @TransactionLimit INT,
	 @PushType SMALLINT,
	 @IsFallback BIT,
	 @EwayBillPushStatusInProgress SMALLINT,
	 @EwayBillPushStatusGenerated SMALLINT,
	 @PushTypeGenerateByIrn SMALLINT,
	 @PushTypeGenerate SMALLINT,
	 @TransactionTypeB2C SMALLINT,
	 @DocumentStatusGenerated SMALLINT,
	 @PurposeTypeEINV SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@CurrentDate DATETIME = GETDATE(),
		@True BIT = 1;
	
	CREATE TABLE #TempEwayBillDocuments
	(
		Id BIGINT,
		PushStatus SMALLINT,
		IsPlanLimitApplicable BIT
	);

	CREATE CLUSTERED INDEX IDX_#TempEwayBillDocuments ON #TempEwayBillDocuments(ID);

	INSERT INTO #TempEwayBillDocuments 
	(
		Id,
		PushStatus,
		IsPlanLimitApplicable
	)
	SELECT
		di.Item,
		ds.PushStatus,
		CASE 
			WHEN ds.BillingDate IS NULL THEN
				CASE 
					 WHEN @PushType IS NULL
					 THEN 1
					 WHEN @PushType = @PushTypeGenerateByIrn THEN
						CASE WHEN d.TransactionType = @TransactionTypeB2C 
					 		 THEN 1 
					 		 ELSE 0 
						END
					 WHEN @PushType = @PushTypeGenerate THEN
						CASE WHEN d.TransactionType != @TransactionTypeB2C AND ds.[Status] = @DocumentStatusGenerated AND d.Purpose & @PurposeTypeEINV <> 0 AND @IsFallback <> @True
					 		 THEN 0
					 		 ELSE 1 
						END
				END
			ELSE 0
		END
	FROM
		@Ids di
		INNER JOIN einvoice.Documents d on d.Id = di.Item
		INNER JOIN ewaybill.DocumentStatus ds ON ds.DocumentId = d.Id
	WHERE
		NOT (@PushType IS NOT NULL 
			 AND @PushType In (@PushTypeGenerate,@PushTypeGenerateByIrn)
			 AND ds.PushStatus In (@EwayBillPushStatusGenerated,@EwayBillPushStatusInProgress));

	IF (@TransactionLimit < (SELECT COUNT(1) FROM #TempEwayBillDocuments WHERE IsPlanLimitApplicable = 1))
	BEGIN
		RAISERROR('VAL0662', 16, 1);
		RETURN;
	END;

	UPDATE 
		ds
	SET
	    PushStatus = @EwayBillPushStatusInProgress,
	    RequestId = @RequestId,
		ds.BillingDate = CASE WHEN tedi.IsPlanLimitApplicable = @True THEN ISNULL(ds.BillingDate, @CurrentDate) ELSE ds.BillingDate END,
		Errors = null,
		ds.ModifiedStamp = GETDATE()
	FROM
		ewaybill.DocumentStatus ds
		INNER JOIN #TempEwayBillDocuments tedi ON ds.DocumentId = tedi.Id;
	
	SELECT 
		dw.Id,
		dw.EntityId,
		dw.ReturnPeriod,
		dw.[Type],
		teid.PushStatus,
		dw.TransactionType,
		ds.[Status] AS EInvoiceDocumentStatus,
		dw.Purpose,
		CASE WHEN eds.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS IsPlanLimitApplicable
	FROM
		einvoice.DocumentDW dw WITH (NOLOCK)
		INNER JOIN #TempEwayBillDocuments teid ON teid.Id = dw.Id
		INNER JOIN einvoice.DocumentStatus ds ON ds.DocumentId = dw.Id
		INNER JOIN ewaybill.DocumentStatus eds ON eds.DocumentId = dw.Id;

	DROP TABLE #TempEwayBillDocuments;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForCancellation] 	 	 
* 	Comments			: 10-04-2020 | Prakash Parmar | This procedure is used to cancel Eway Bills.
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of cancellation
						: 21-12-2020 | Chandresh Prajapati | Update CancelRemarks length 250
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							CAST('2018/09/01' AS SMALLDATETIME),
							NULL,
							NULL,
							4,
							1,
							''
						  );
						  
						  EXEC [ewaybill].[UpdatePushResponseForCancellation]
								@PushResponse = @PushResponseType,
								@CancelReason = 1,
								@CancelRemarks = 'Test remark',
								@EwayBillPushStatusCancelled = 4,
								@DocumentStatusCompleted = 3;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForCancellation]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@CancelReason SMALLINT NULL,
	@CancelRemarks VARCHAR(250) NULL,
	@EwayBillPushStatusCancelled INT,
	@DocumentStatusCompleted INT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails (ID)

	UPDATE 
		ds
	SET
		ds.Reason = (CASE WHEN teid.PushStatus = @EwayBillPushStatusCancelled THEN @CancelReason ELSE ds.Reason END ),
		ds.Remarks = (CASE WHEN teid.PushStatus = @EwayBillPushStatusCancelled THEN @CancelRemarks ELSE ds.Remarks END ),
		ds.CancelledDate = (CASE WHEN teid.PushStatus = @EwayBillPushStatusCancelled THEN teid.UpdatedDate ELSE ds.CancelledDate END ),
		ds.PushDate = (CASE WHEN teid.PushStatus = @EwayBillPushStatusCancelled THEN teid.UpdatedDate ELSE ds.PushDate END ),
		ds.[Status] = (CASE WHEN teid.PushStatus = @EwayBillPushStatusCancelled THEN @DocumentStatusCompleted ELSE ds.[Status] END ),
	    ds.PushStatus = teid.PushStatus,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = GETDATE()
	FROM
		ewaybill.DocumentStatus AS ds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ds.DocumentId;		
	
	DROP TABLE 	#TempEwayBillStatusDetails;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForExtension] 	 	 
* 	Comments			: 12-05-2020 | Amit Khanna | This procedure is used to update Eway bill Vehicle Details.
						: 18-06-2020 | Prakash Parmar | Added BackgroundTaskId
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Extension
						: 10-09-2020 | Prakash Parmar | Changes In PushStatus
						: 11-09-2020 | Prakash Parmar | Added UpdatedByGstin
						: 24-12-2020 | Prakash Parmar | Added Actual Distance
						: 08-12-2021 | Prakash Parmar | Added Parameter UpdationMode
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							'01-09-2018',
							NULL,
							NULL,
							2,
							1,
							''
						  );

						  EXEC [ewaybill].[UpdatePushResponseForExtension]
							@PushResponse = @PushResponseType,
							@UserId = 486,
							@TransportMode  = 1,
							@FromCity = 'Ahmedabad',
							@FromState = 33,
							@Reason  = 2,
							@Remarks = NULL,
							@TransportDocumentNumber = NULL,
							@TransportDocumentDate = NULL,
							@VehicleNumber   = 'GJ021245',
							@FromPincode = 382345,
							@RemainingDistance = 255,
							@ConsignmentStatus = 1,
							@BackgroundTaskId = 524,
							@TransitType = NULL,
							@TransitAddressLine1 = NULL,
							@TransitAddressLine2 = NULL,
							@TransitAddressLine3 = NULL,
							@UpdatedByGstin = '28ADDABCDE54875',
							@EwayBillPushStatusValidityExtended = 6,
							@BitTypeYes = 1,
							@BitTypeNo = 0,
							@GenerationModeApi = 1;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForExtension]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@UserId INT,
	@TransportMode SMALLINT,
	@FromCity VARCHAR(110),
	@FromState SMALLINT,
	@Reason SMALLINT,
	@Remarks VARCHAR(50),
	@TransportDocumentNumber VARCHAR(15),
	@TransportDocumentDate SMALLDATETIME,
	@VehicleNumber VARCHAR(20),
	@FromPincode INT,
	@RemainingDistance SMALLINT,
	@ConsignmentStatus SMALLINT,
	@BackgroundTaskId BIGINT,
	@TransitType SMALLINT,
	@TransitAddressLine1 VARCHAR(120),
	@TransitAddressLine2 VARCHAR(120),
	@TransitAddressLine3 VARCHAR(120),
	@UpdatedByGstin VARCHAR(15),
	@EwayBillPushStatusValidityExtended INT,
	@BitTypeYes SMALLINT,
	@BitTypeNo SMALLINT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors,
		pr.ActualDistance
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;
	
	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails (ID)

	UPDATE
		ds
	SET
		ds.ValidUpto = CASE WHEN teid.PushStatus = @EwayBillPushStatusValidityExtended AND teid.UpdatedDate IS NOT NULL THEN teid.ValidUpto ELSE ds.ValidUpto END,
		ds.PushByUserId = @UserId,
		ds.IsPushed = CASE WHEN teid.PushStatus = @EwayBillPushStatusValidityExtended AND teid.UpdatedDate IS NOT NULL THEN teid.IsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusValidityExtended AND teid.UpdatedDate IS NOT NULL THEN teid.UpdatedDate ELSE ds.PushDate END,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = GETDATE(),
		ds.ExtendedTimes = CASE WHEN teid.PushStatus = @EwayBillPushStatusValidityExtended AND teid.UpdatedDate IS NOT NULL THEN 
								  CASE WHEN ds.ExtendedTimes IS NULL THEN 1 ELSE ds.ExtendedTimes + 1 END
								  ELSE ds.ExtendedTimes END,
		ds.PushStatus = teid.PushStatus
	FROM
		ewaybill.DocumentStatus AS ds
		INNER JOIN #TempEwayBillStatusDetails teid ON ds.DocumentId = teid.Id;
	 

	UPDATE 
		vd
	SET
		vd.IsLatest = CASE WHEN tewbs.UpdatedDate IS NOT NULL THEN  @BitTypeNo  ELSE vd.IsLatest END
	FROM 
		ewaybill.VehicleDetails AS vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate))
		INNER JOIN #TempEwayBillStatusDetails tewbs ON vd.DocumentId = tewbs.Id
	WHERE
		vd.IsLatest = @BitTypeYes;
	
	DELETE
		vd
	 FROM 
		ewaybill.VehicleDetails vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate))
		INNER JOIN #TempEwayBillStatusDetails ewbs ON vd.DocumentId = ewbs.Id
	WHERE  
		vd.IsLatest = @BitTypeNo
		AND vd.PushDate IS NULL;
		

	INSERT INTO ewaybill.VehicleDetails
	(
		DocumentId,
		TransportMode,
		TransportDocumentNumber,
		TransportDocumentDate,
		VehicleNumber,
		FromState,
		FromCity,
		FromPinCode,
		RemainingDistance,
		ConsignmentStatus,
		Reason,
		Remarks,
		TransitType,
		TransitAddressLine1,
		TransitAddressLine2,
		TransitAddressLine3,
		IsLatest,
		PushDate,
		PushStatus,
		Errors,
		BackgroundTaskId,
		UpdatedByGstin,
		UpdationMode
	)
	SELECT
		tewbs.Id,
		@TransportMode,
		@TransportDocumentNumber,
		@TransportDocumentDate,
		@VehicleNumber,
		@FromState,
		@FromCity,
		@FromPincode,
		ISNULL(tewbs.ActualDistance, @RemainingDistance),
		@ConsignmentStatus,
		@Reason,
		@Remarks,
		@TransitType,
		@TransitAddressLine1,
		@TransitAddressLine2,
		@TransitAddressLine3,
		CASE WHEN tewbs.UpdatedDate IS NOT NULL THEN @BitTypeYes ELSE @BitTypeNo END,
		tewbs.UpdatedDate,
		@EwayBillPushStatusValidityExtended,
		tewbs.Errors,
		@BackgroundTaskId,
		@UpdatedByGstin,
		@GenerationModeApi
	FROM
		#TempEwayBillStatusDetails AS tewbs;
	
	DROP TABLE #TempEwayBillStatusDetails;
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertDownloadedEInvoicePurchaseDocuments]
* 	Comments			: 27-03-2023 | Dhruv Amin | This procedure is used to insert purchase document based on cirp generated against me api
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: DECLARE
								@PurchaseDocuments [einvoice].DownloadedPurchaseDocumentType,
								@PurchaseDocumentItems [einvoice].DownloadedPurchaseDocumentItemType,
								@DocumentReferences [common].[DocumentReferenceType],
								@PurchaseDocumentPayments [einvoice].[DownloadedPurchaseDocumentPaymentType],
								@PurchaseDocumentContacts [einvoice].[DownloadedPurchaseDocumentContactType];

							EXEC [oregular].[InsertDownloadedEInvoicePurchaseDocuments]
								@SubscriberId=164,
								@UserId=663,
								@EntityId=372,
								@PurchaseDocuments = @PurchaseDocuments,
								@PurchaseDocumentItems = @PurchaseDocumentItems,
								@DocumentReferences = @DocumentReferences,
								@PurchaseDocumentPayments = @PurchaseDocumentPayments,
								@PurchaseDocumentContacts = @PurchaseDocumentContacts,
								@SourceTypeEInvoice = 1,
								@EInvoicePushStatusGenerated = 1,
								@EInvoicePushStatusCancelled = 2,
								@DocumentStatusActive = 1,
								@DocumentStatusCancelled = 2,
								@PushToGstStatusCancelled = 6,
								@ContactTypeBillFrom = 1,
								@DocumentTypeDBN = 3,
								@DocumentTypeCRN = 2;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[InsertDownloadedEInvoicePurchaseDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@PurchaseDocuments gst.DownloadedGstnEInvoiceDocumentType READONLY,
	@PurchaseDocumentItems gst.DownloadedGstnEInvoiceDocumentItemType READONLY,
	@DocumentReferences [common].[DocumentReferenceType] READONLY,
	@PurchaseDocumentPayments gst.[DownloadedGstnEInvoiceDocumentPaymentType] READONLY,
	@PurchaseDocumentContacts gst.[DownloadedGstnEInvoiceDocumentContactType] READONLY,
	@PurchaseDocumentSignedDetails gst.[DownloadedGstnEInvoiceDocumentSignedDetailType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@OverwritePrRecord BIT,
	@SourceType SMALLINT,
	@SourceTypeEInvoice SMALLINT,
	@SourceTypeTaxpayer SMALLINT,
	@EInvoicePushStatusGenerated SMALLINT,
	@EInvoicePushStatusCancelled SMALLINT,
	@DocumentStatusActive SMALLINT,
	@DocumentStatusCancelled SMALLINT,
	@PushToGstStatusCancelled SMALLINT,
	@ContactTypeBillFrom SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	DECLARE 
		@False BIT = 0,
		@True BIT= 1,
		@Min INT = 1, 
		@Max INT, 
		@BatchSize INT, 
		@Records INT,
		@CurrentDate DATETIME = GETDATE();

	/* Create table for Id and Mode */
	CREATE TABLE #TempPurchaseDocumentIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT,
		GroupId INT,
		FinancialYear INT,
		BillingDate DATETIME,
		ReturnPeriod INT,
		SectionType INT,
		DocumentDate SMALLDATETIME,
		ItcClaimReturnPeriod SMALLINT,
		Mode VARCHAR(2)
	);
	CREATE CLUSTERED INDEX IDX_TempPurchaseDocumentIds_Id ON #TempPurchaseDocumentIds(ID);
	CREATE NONCLUSTERED INDEX IDX_TempPurchaseDocumentIds_GroupId ON #TempPurchaseDocumentIds(GroupId) INCLUDE(Id);
	
	/* create table for delete data ids while autosync = false */
	CREATE TABLE #TempDeletedIds
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
	CREATE CLUSTERED INDEX IDX_#TempDeletedIds_ID ON #TempDeletedIds (ID);
	/* Add Purchase document in temp */
	SELECT 
		*
	INTO 
		#TempPurchaseDocuments
	FROM 
		@PurchaseDocuments;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocuments_GroupId ON #TempPurchaseDocuments(GroupId);
	/* Add Purchase document contact in temp */
	SELECT
		*
	INTO 
		#TempPurchaseDocumentContacts
	FROM 
		@PurchaseDocumentContacts;
		
	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentContacts_GroupId ON #TempPurchaseDocumentContacts(GroupId);
	/* Add Purchase document signed detail in temp */
	SELECT
		*
	INTO 
		#TempPurchaseDocumentSignedDetail
	FROM 
		@PurchaseDocumentSignedDetails;
		
	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentSignedDetail_GroupId ON #TempPurchaseDocuments(GroupId);
	/* Add Purchase document payment in temp */
	SELECT
		*
	INTO 
		#TempPurchaseDocumentPayments
	FROM 
		@PurchaseDocumentPayments;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentPayments_GroupId ON #TempPurchaseDocumentPayments(GroupId);
	/* Add Purchase document items in temp */
	SELECT
		*
	INTO 
		#TempPurchaseDocumentItems 
	FROM 
		@PurchaseDocumentItems;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentItems_GroupId ON #TempPurchaseDocumentItems(GroupId);
	/* Add Purchase document References in temp */
	SELECT 
		*
	INTO 
		#TempPurchaseDocumentReferences
	FROM 
		@DocumentReferences;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocumentReferences_GroupId ON #TempPurchaseDocumentReferences(GroupId);

	/* Get Update Mode Data */
	INSERT INTO #TempPurchaseDocumentIds
	(
		Id,
		FinancialYear,
		BillingDate,
		GroupId,
		ReturnPeriod,
		SectionType,
		DocumentDate,
		ItcClaimReturnPeriod,
		Mode
	)
	SELECT
		dw.Id,
		dw.FinancialYear,
		ps.BillingDate, --ISNULL(ps.BillingDate,@CurrentDate),
		tpd.GroupId,
		tpd.ReturnPeriod,
		tpd.SectionType,
		tpd.DocumentDate,
		ps.ItcClaimReturnPeriod,
		CASE 
			WHEN @SourceType = @SourceTypeEInvoice AND tpd.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN 'C'
			WHEN @SourceType = @SourceTypeTaxpayer AND @OverwritePrRecord = 1 THEN 'U'
			ELSE 'S'
		END AS Mode
	FROM
		#TempPurchaseDocuments tpd
		INNER JOIN oregular.PurchaseDocumentDW AS dw ON 
		(
			dw.SubscriberId = @SubscriberId
			AND dw.EntityId = @EntityId
			AND dw.DocumentNumber = tpd.DocumentNumber 
			AND dw.DocumentFinancialYear = tpd.DocumentFinancialYear
			AND dw.SourceType = @SourceType
			AND ISNULL(dw.BillFromGstin, '') = ISNULL(tpd.BillFromGstin, '')
			AND ISNULL(dw.PortCode, '') = ISNULL(tpd.PortCode, '')
			AND dw.DocumentType = tpd.DocumentType
			AND dw.IsAmendment = @False
		)
		INNER JOIN oregular.PurchaseDocumentStatus ps ON ps.PurchaseDocumentId = dw.Id

	/* INSERT PurchaseDocuments*/
	INSERT INTO [oregular].[PurchaseDocuments]
	(
		SubscriberId,
		ParentEntityId,
		EntityId,
		UserId,
		Irn,
		IrnGenerationDate,
		DocumentType,
		TransactionType,
		TaxpayerType,
		DocumentNumber,
		RecoDocumentNumber,
		DocumentDate,
		Pos,
		PortCode,
		DocumentValue,
		ReverseCharge,
		ClaimRefund,
		UnderIgstAct,		
		SectionType,
		TotalTaxableValue,
		TotalTaxAmount,
		ReturnPeriod,
		DocumentFinancialYear,
		FinancialYear,
		IsAmendment,	
		SourceType,
		AdditionalSupportingDocumentDetails,
		DestinationCountry,
		DocumentCurrencyCode,
		DocumentDiscount,
		DocumentOtherCharges,
		DocumentValueInRoundOffAmount,
		RefContractDetails,
		RefDocumentPeriodEndDate,
		RefDocumentPeriodStartDate,
		RefDocumentRemarks,
		RefPrecedingDocumentDetails,
		RefundEligibility,
		GroupId,
		CombineDocumentType,
		DocumentReturnPeriod
	)
	OUTPUT
		inserted.Id, 
		inserted.GroupId, 
		'I', 
		NULL,
		inserted.ReturnPeriod, 
		inserted.SectionType, 
		inserted.DocumentDate
	INTO 
		#TempPurchaseDocumentIds(Id, GroupId, Mode, BillingDate, ReturnPeriod, SectionType, DocumentDate)
	SELECT
		@SubscriberId,
		@EntityId,
		@EntityId,
		@UserId,
		tpd.Irn,
		tpd.IrnGenerationDate,
		tpd.DocumentType,
		tpd.TransactionType,
		tpd.TaxpayerType,
		tpd.DocumentNumber,
		tpd.RecoDocumentNumber,
		tpd.DocumentDate,
		tpd.Pos,
		tpd.PortCode,
		tpd.DocumentValue,
		tpd.ReverseCharge,
		tpd.ClaimRefund,
		tpd.UnderIgstAct,		
		tpd.SectionType,
		tpd.TotalTaxableValue,
		tpd.TotalTaxAmount,
		tpd.ReturnPeriod,
		tpd.DocumentFinancialYear,
		tpd.FinancialYear,
		@False,			
		@SourceType,
		tpd.AdditionalSupportingDocumentDetails,
		tpd.DestinationCountry,
		tpd.DocumentCurrencyCode,
		tpd.DocumentDiscount,
		tpd.DocumentOtherCharges,
		tpd.DocumentValueInRoundOffAmount,
		tpd.RefContractDetails,
		tpd.RefDocumentPeriodEndDate,
		tpd.RefDocumentPeriodStartDate,
		tpd.RefDocumentRemarks,
		tpd.RefPrecedingDocumentDetails,
		@False,
		tpd.GroupId,
		CASE WHEN DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE DocumentType END AS CombineDocumentType,
		tpd.DocumentReturnPeriod		
	FROM
		#TempPurchaseDocuments tpd
	WHERE 
		GroupId NOT IN (SELECT GroupId FROM #TempPurchaseDocumentIds);

	/* Insert oregular.PurchaseDocumentStatus for matched records  */
	INSERT INTO oregular.PurchaseDocumentStatus
	(
		PurchaseDocumentId,
		CancelledDate,
		[Status],
		PushStatus,
		IsPushed,
		[Action],
		LastAction,
		AutoDraftSource,
		IsReconciled,
		LastSyncDate,
		IsReconciledGstr2b,
		Gstr2bAction,
		BillingDate
	)
	SELECT  
		tpdi.Id,
		CASE WHEN tpd.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN GETDATE() ELSE NULL END,
		CASE WHEN tpd.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN @DocumentStatusCancelled ELSE @DocumentStatusActive END,
		CASE WHEN tpd.EInvoicePushStatus = @EInvoicePushStatusCancelled THEN @PushToGstStatusCancelled ELSE tpd.GstPushStatus END,
		@False,
		tpd.GstAction,
		tpd.GstAction,
		tpd.EInvoiceSource,
		@False,
		@CurrentDate,
		@False,
		tpd.GstAction,
		NULL --@CurrentDate
	FROM
		#TempPurchaseDocumentIds AS tpdi 
		INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
	WHERE 
		tpdi.Mode = 'I';

	/* Update PurchaseDocuments AND PurchaseDocumentStatus with Flag = 'U'*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode = 'U')
	BEGIN
		UPDATE 
			oregular.PurchaseDocuments 
		SET
			ParentEntityId = @EntityId,
			EntityId = @EntityId,
			UserId = @UserId,
			Irn = tpd.Irn,
			IrnGenerationDate = tpd.IrnGenerationDate,
			DocumentType = tpd.DocumentType,
			TransactionType = tpd.TransactionType,
			TaxpayerType = tpd.TaxpayerType,
			DocumentNumber = tpd.DocumentNumber,
			DocumentDate = tpd.DocumentDate,
			Pos = tpd.Pos,
			PortCode = tpd.PortCode,
			DocumentValue = tpd.DocumentValue,
			ReverseCharge = tpd.ReverseCharge,
			ClaimRefund = tpd.ClaimRefund,
			UnderIgstAct = tpd.UnderIgstAct,			
			SectionType = tpd.SectionType,
			TotalTaxableValue = tpd.TotalTaxableValue,
			TotalTaxAmount = tpd.TotalTaxAmount,
			ReturnPeriod = tpd.ReturnPeriod,
			DocumentFinancialYear = tpd.DocumentFinancialYear,
			FinancialYear = tpd.FinancialYear,
			ModifiedStamp = @CurrentDate,
			CombineDocumentType = CASE WHEN tpd.DocumentType = @DocumentTypeDBN THEN @DocumentTypeCRN ELSE tpd.DocumentType END,
			AdditionalSupportingDocumentDetails = tpd.AdditionalSupportingDocumentDetails,
			DestinationCountry = tpd.DestinationCountry,
			DocumentCurrencyCode = tpd.DocumentCurrencyCode,
			DocumentDiscount = tpd.DocumentDiscount,
			DocumentOtherCharges = tpd.DocumentOtherCharges,
			DocumentValueInRoundOffAmount = tpd.DocumentValueInRoundOffAmount,
			RefContractDetails = tpd.RefContractDetails,
			RefDocumentPeriodEndDate = tpd.RefDocumentPeriodEndDate,
			RefDocumentPeriodStartDate = tpd.RefDocumentPeriodStartDate,
			RefDocumentRemarks = tpd.RefDocumentRemarks,
			RefPrecedingDocumentDetails = tpd.RefPrecedingDocumentDetails,
			DocumentReturnPeriod = tpd.DocumentReturnPeriod,
			SourceType = @SourceTypeEInvoice,
			IsAmendment = @False,			
			GroupId = tpd.GroupId,
			ModifiedStamp = @CurrentDate
		FROM
			oregular.PurchaseDocuments AS pd
			INNER JOIN #TempPurchaseDocumentIds tpdi ON tpdi.Id = pd.Id
			INNER JOIN #TempPurchaseDocuments AS tpd ON tpd.GroupId = tpdi.GroupId
		WHERE 
			tpdi.Mode = 'U';
		
		UPDATE
			oregular.PurchaseDocumentStatus 
		SET 
			[Status] = @DocumentStatusActive,
			AutoDraftSource = tpd.EInvoiceSource,
			IsReconciled = @False,
			--BillingDate = tpdi.BillingDate,
			LastSyncDate = @CurrentDate,
 			ModifiedStamp = @CurrentDate,
			IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus ps
			INNER JOIN #TempPurchaseDocumentIds AS tpdi ON ps.PurchaseDocumentId = tpdi.ID
			INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
		WHERE 
			tpdi.Mode = 'U';
	END
	
	/* Update PurchaseDocuments AND PurchaseDocumentStatus with Flag = 'C'*/
	IF EXISTS (SELECT 1 FROM #TempPurchaseDocumentIds WHERE Mode = 'C')
	BEGIN
		UPDATE
			oregular.PurchaseDocumentStatus 
		SET 
			[Status] = @DocumentStatusCancelled,
			PushStatus = @PushToGstStatusCancelled,
			CancelledDate = GETDATE(),			
			AutoDraftSource = tpd.EInvoiceSource,
			IsReconciled = @False,
			--BillingDate = tpdi.BillingDate,
			LastSyncDate = @CurrentDate,
 			ModifiedStamp = @CurrentDate,
			IsReconciledGstr2b = @False
		FROM
			oregular.PurchaseDocumentStatus ps
			INNER JOIN #TempPurchaseDocumentIds AS tpdi ON ps.PurchaseDocumentId = tpdi.ID
			INNER JOIN #TempPurchaseDocuments tpd on tpdi.GroupId = tpd.GroupId
		WHERE 
			tpdi.Mode = 'C';
	END
	
	/* Delete PurchaseDocumentItems and PurchaseDocumentPayments for both Insert and Update Case  */	
	IF EXISTS (SELECT AutoId FROM #TempPurchaseDocumentIds)
	BEGIN
		

		SELECT 
			@Max = COUNT(AutoId)
		FROM 
			#TempPurchaseDocumentIds

		SELECT @Batchsize = CASE 
								WHEN ISNULL(@Max,0) > 100000 THEN  ((@Max*10)/100)
								ELSE @Max
							END;
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize;
			
			/* delete purchase contact detail */
			DELETE 
				pdc
			FROM 
				oregular.PurchaseDocumentContacts AS pdc
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdc.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode = 'U'
				AND tpdi.AutoId BETWEEN @Min AND @Records;
			
			/* delete purchase signed detail */
			DELETE 
				pdsd
			FROM 
				oregular.PurchaseDocumentSignedDetails AS pdsd
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdsd.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode = 'U'
				AND tpdi.AutoId BETWEEN @Min AND @Records;
			
			/* delete purchase payments detail */
			DELETE 
				pdp
			FROM 
				oregular.PurchaseDocumentPayments AS pdp
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdp.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode = 'U'
				AND tpdi.AutoId BETWEEN @Min AND @Records;
			
			/* delete purchase items detail */
			DELETE 
				pdi
			FROM 
				oregular.PurchaseDocumentItems AS pdi
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdi.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode = 'U'
				AND tpdi.AutoId BETWEEN @Min AND @Records;

			/* delete purchase rate wise items detail */
			DELETE 
				pdri
			FROM 
				oregular.PurchaseDocumentRateWiseItems AS pdri
				INNER JOIN #TempPurchaseDocumentIds AS tpdi ON pdri.PurchaseDocumentId = tpdi.Id
			WHERE 
				tpdi.Mode = 'U'
				AND tpdi.AutoId BETWEEN @Min AND @Records;

			SET @Min = @Records
		END
	END

	INSERT INTO [oregular].[PurchaseDocumentItems]
	(
		[PurchaseDocumentId],
		[SerialNumber],
		[IsService],
		[Hsn],
		[Description],
		[Barcode],
		[Uqc],
		[TaxType],
		[Quantity],
		[FreeQuantity],
		[Rate],
		[CessRate],
		[StateCessRate],
		[PricePerQuantity],
		[DiscountAmount],
		[GrossAmount],
		[OtherCharges],
		[TaxableValue],
		[IgstAmount],
		[CgstAmount],
		[SgstAmount],
		[CessAmount],
		[StateCessAmount],
		[StateCessNonAdvaloremAmount],
		[CessNonAdvaloremAmount]
	)
	SELECT
		tpdi.Id,
		tid.SerialNumber,
		tid.IsService,
		tid.Hsn,
		tid.[Description],
		tid.Barcode,
		tid.Uqc,
		tid.TaxType,
		tid.Quantity,
		tid.FreeQuantity,
		tid.Rate,
		tid.CessRate,
		tid.StateCessRate,
		tid.PricePerQuantity,
		tid.DiscountAmount,
		tid.GrossAmount,
		tid.OtherCharges,
		tid.TaxableValue,
		tid.IgstAmount,
		tid.CgstAmount,
		tid.SgstAmount,
		tid.CessAmount,
		tid.StateCessAmount,
		tid.StateCessNonAdvaloremAmount,
		tid.CessNonAdvaloremAmount
	FROM
		#TempPurchaseDocumentItems AS tid
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tid.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I', 'U');

	INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
	(
		[PurchaseDocumentId],
		[Rate],
		[TaxableValue],
		[IgstAmount],
		[CgstAmount],
		[SgstAmount],
		[CessAmount]
	)
	SELECT
		tpdi.Id,
		tid.Rate,
		SUM(tid.TaxableValue),
		SUM(tid.IgstAmount),
		SUM(tid.CgstAmount),
		SUM(tid.SgstAmount),
		SUM(tid.CessAmount)
	FROM
		#TempPurchaseDocumentItems AS tid
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tid.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I', 'U')
	GROUP BY 
		tid.GroupId, tid.Rate, tpdi.Id;
		
	INSERT INTO oregular.PurchaseDocumentPayments
	(
		PurchaseDocumentId,
		PaymentMode,
		AdvancePaidAmount,
		PaymentTerms,
		PaymentInstruction,
		PayeeName,
		PayeeAccountNumber,
		PaymentAmountDue,
		Ifsc,
		CreditTransfer,
		DirectDebit,
		CreditDays,
		Stamp
	)
	SELECT
		tpdi.Id,
		tpdp.PaymentMode,
		tpdp.AdvancePaidAmount,
		tpdp.PaymentTerms,
		tpdp.PaymentInstruction,
		tpdp.PayeeName,
		tpdp.PayeeAccountNumber,
		tpdp.PaymentAmountDue,
		tpdp.Ifsc,
		tpdp.CreditTransfer,
		tpdp.DirectDebit,
		tpdp.CreditDays,
		@CurrentDate
	FROM
		#TempPurchaseDocumentPayments AS tpdp
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdp.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I','U');

	INSERT INTO oregular.PurchaseDocumentContacts
	(
		PurchaseDocumentId,
		Gstin,
		TradeName,
		LegalName,
		AddressLine1,
        AddressLine2,
        City,
        StateCode,
        Pincode,
        Phone,
        Email,
		[Type]
	)
	SELECT
		tpdi.Id,
		tpdc.Gstin,
		tpdc.TradeName,
		tpdc.LegalName,
		tpdc.AddressLine1,
        tpdc.AddressLine2,
        tpdc.City,
        tpdc.StateCode,
        tpdc.Pincode,
        tpdc.Phone,
        tpdc.Email,
		tpdc.[Type]
	FROM
		#TempPurchaseDocumentContacts AS tpdc
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdc.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I','U');
		
	INSERT INTO oregular.PurchaseDocumentSignedDetails
	(
		PurchaseDocumentId,
		AckNumber,
		SignedInvoice,
		SignedQrCode,
		IsCompress,
		EwayBillNumber,
		EwayBillDate,
		EwayBillValidTill,
		Remarks,
		CancellationDate,
		CancellationReason,
		CancellationRemark,
		ProviderType,
		Stamp
	)
	SELECT
		tpdi.Id,
		tpdsd.AcknowledgementNumber,
		tpdsd.SignedInvoice,
		tpdsd.SignedQrCode,
		tpdsd.IsCompress,
		tpdsd.EwayBillNumber,
		tpdsd.EwayBillDate,
		tpdsd.EwayBillValidTill,
		tpdsd.Remarks,
		tpdsd.CancellationDate,
		tpdsd.CancellationReason,
		tpdsd.CancellationRemark,
		tpdsd.ProviderType,
		GETDATE()
	FROM
		#TempPurchaseDocumentSignedDetail AS tpdsd
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdsd.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I','U');

	INSERT INTO oregular.PurchaseDocumentReferences
	(
		PurchaseDocumentId,
		DocumentNumber,
		DocumentDate
	)
	SELECT
		tpdi.Id,
		tpdr.DocumentNumber,
		tpdr.DocumentDate
	FROM
		#TempPurchaseDocumentReferences AS tpdr
		INNER JOIN #TempPurchaseDocumentIds AS tpdi ON tpdr.GroupId = tpdi.GroupId
	WHERE 
		tpdi.Mode IN ('I');

	/* Don't move this execution pls add any code above this execution not below */
	EXEC [oregular].[InsertPurchaseDocumentDW]
		@DocumentTypeDBN = @DocumentTypeDBN,
		@DocumentTypeCRN = @DocumentTypeCRN;

	SELECT
		tpdi.Id,
		tpdi.GroupId,
		CASE WHEN tpdi.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS PlanLimitApplicable,
		tpdi.FinancialYear,
		tpdi.ReturnPeriod,
		tpdi.SectionType,
		tpdi.DocumentDate
	FROM
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN oregular.PurchaseDocumentStatus ps ON tpdi.Id = ps.PurchaseDocumentId

	DROP TABLE 
		#TempPurchaseDocumentIds, #TempPurchaseDocumentItems, #TempPurchaseDocuments,#TempDeletedIds,
		#TempPurchaseDocumentContacts,#TempPurchaseDocumentReferences;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForGeneration] 	 	 
* 	Comments			: 06-04-2020 | Prakash Parmar | This procedure is used to update Eway bill Document Status after uploading on Nic.
						: 11-06-2020 | Chandresh Prajapati | Added ActualDistance in PushResponseType and update distance in einvoice.Documents
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Generation
						: 11-09-2020 | Prakash Parmar | Added UpdatedByGstin
						: 22-09-2020 | Prakash Parmar | Added ActualDistance
						: 28-09-2020 | Prakash Parmar | Added overwrite transport and shipping details scenarios
						: 14-10-2020 | Prakash Parmar | Changed vehicle details flow
						: 01-12-2020 | Prakash Parmar | Added Dispatch From Contact Type related fields
						: 20-01-2021 | Prakash Parmar | Added IsFallback, PurposeTypeEINV, PurposeTypeEWB 
						: 25-01-2021 | Prakash Parmar | Updated Transaction Mode in case of overwrite dispatch details
						: 09-02-2021 | Chandresh Prajapati | Removed IsFallBack
						: 31-05-2021 | Prakash Parmar | Updated CancelledDate,reason,remarks fileds in documentstatus table
						: 08-12-2021 | Prakash Parmar | Added GenerationModeApi Parameter
						: 04-02-2022 | Prakash Parmar | Updated Transaction Mode in case of overwrite ship details
						: 24-01-2024 | Prakash Parmar | Removed transaction type in override shipping detail
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[ActualDistance],
							[PushStatus],
							[IsPushed],
							[Errors]

						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							CAST('2018/09/01' AS SMALLDATETIME),
							NULL,
							NULL,
							NULL,
							2,
							1,
							''
						  );

						  EXEC [ewaybill].[UpdatePushResponseForGeneration]
							@PushResponse = @PushResponseType,
							@UserId = 663,
							@UpdatedByGstin = '28ADDABCDE54875',
							@EwayBillPushStatusGenerated = 2,
							@DocumentStatusGenerated = 2														
							,@TransporterId					= NULL
							,@TransporterName				= NULL
							,@TransportMode					= NULL
							,@TransportDocumentNumber		= NULL
							,@TransportDocumentDate			= NULL
							,@Distance						= NULL
							,@VehicleNumber					= NULL
							,@VehicleType					= NULL
							,@ShipToAddress1				= NULL
							,@ShipToAddress2				= NULL
							,@ShipToCity					= NULL
							,@ShipToStateCode				= NULL
							,@ShipToPincode					= NULL
							,@OverwriteTransportDetails		= 1
							,@OverwriteShippingExportDetails= 1
							,@BackgroundTaskId				= 1			
							,@BitTypeYes					= 1
							,@BitTypeNo						= 0
							,@ContactTypeBillFrom			= 1
							,@ContactTypeDispatchFrom		= 2
							,@ContactTypeShipTo				= 4
							,@TransactionTypeExpwop			= NULL
							,@TransactionTypeExpwp			= NULL
							,@OverwriteDispatchDetails = 0
							,@DispatchFromTradeName = 'trade name'
							,@DispatchFromAddress1 = 'address 1'
							,@DispatchFromAddress2 = 'address25'
							,@DispatchFromCity = 'citu 2'
							,@DispatchFromStateCode = 8
							,@DispatchFromPincode = '382654'
							,@PurposeTypeEINV = 2
							,@PurposeTypeEWB = 8
							,@GenerationModeApi = 1;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForGeneration]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@UserId INT,
	@UpdatedByGstin VARCHAR(15),
	@TransporterId VARCHAR(15) NULL,
	@TransporterName VARCHAR(200) NULL,
	@TransportMode SMALLINT NULL,
	@TransportDocumentNumber VARCHAR(40) NULL,
	@TransportDocumentDate SMALLDATETIME NULL,
	@Distance SMALLINT NULL,
	@VehicleNumber VARCHAR(15) NULL,
	@VehicleType SMALLINT NULL,
	@ShipToAddress1 VARCHAR(120),
	@ShipToAddress2 VARCHAR(120),
	@ShipToCity VARCHAR(110),
	@ShipToStateCode SMALLINT,
	@ShipToPincode INT,
	@OverwriteTransportDetails BIT,
	@OverwriteShippingExportDetails BIT,
	@BackgroundTaskId BIGINT,
	@OverwriteDispatchDetails BIT,
	@DispatchFromTradeName VARCHAR(200),
	@DispatchFromAddress1 VARCHAR(120),
	@DispatchFromAddress2 VARCHAR(120),
	@DispatchFromCity VARCHAR(110),
	@DispatchFromStateCode SMALLINT,
	@DispatchFromPincode INT,
	@OverwriteNotificationDetails BIT,
	@ToEmailAddresses VARCHAR(330),
	@ToMobileNumbers VARCHAR(60),
	@EwayBillPushStatusGenerated INT,
	@DocumentStatusGenerated INT,
	@BitTypeYes BIT,
	@BitTypeNo BIT,
	@ContactTypeBillFrom INT,
	@ContactTypeDispatchFrom INT,
	@ContactTypeShipTo INT,
	@TransactionTypeExpwop SMALLINT,
	@TransactionTypeExpwp SMALLINT,
	@PurposeTypeEINV SMALLINT,
	@PurposeTypeEWB SMALLINT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @today AS DATETIME = GETDATE();
	
	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.ActualDistance,
		pr.PushStatus,
		pr.IsPushed,
		pr.TransactionMode,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails(ID)
	
	IF (@OverwriteShippingExportDetails = @BitTypeYes AND @ShipToAddress1 IS NOT NULL AND @ShipToCity IS NOT NULL AND 
	    @ShipToStateCode IS NOT NULL AND @ShipToPincode IS NOT NULL)
	BEGIN
		
		UPDATE
			dc
		SET
			dc.AddressLine1 = @ShipToAddress1,
			dc.AddressLine2 = @ShipToAddress2,
			dc.City = @ShipToCity,
			dc.StateCode = @ShipToStateCode,
			dc.Pincode = @ShipToPincode,
			dc.ModifiedStamp = @today
		FROM 
		    einvoice.DocumentContacts dc
			INNER JOIN #TempEwayBillStatusDetails teid ON dc.DocumentId = teid.Id
			INNER JOIN einvoice.DocumentDW dw ON dw.Id = teid.Id
		WHERE
		    dc.[Type] = @ContactTypeShipTo;

		INSERT INTO einvoice.DocumentContacts 
			([DocumentId]
			,[AddressLine1]
			,[AddressLine2]
			,[City]
			,[StateCode]
			,[Pincode]
			,[Type]
			,[Stamp])
		SELECT  
			teid.Id,
			@ShipToAddress1,
			@ShipToAddress2,
			@ShipToCity,
			@ShipToStateCode,
			@ShipToPincode,
			@ContactTypeShipTo,
			@today
		FROM
			#TempEwayBillStatusDetails teid
			INNER JOIN einvoice.DocumentDW dw ON dw.Id = teid.Id
			LEFT JOIN einvoice.DocumentContacts dcst ON dcst.DocumentId = teid.Id AND dcst.[Type] = @ContactTypeShipTo
		WHERE
			dcst.Id IS NULL;
	END

	IF (@OverwriteDispatchDetails = @BitTypeYes AND @DispatchFromTradeName IS NOT NULL AND @DispatchFromAddress1 IS NOT NULL AND 
	    @DispatchFromCity IS NOT NULL AND @DispatchFromStateCode IS NOT NULL AND @DispatchFromPincode IS NOT NULL)
	BEGIN
		
		UPDATE
			dc
		SET
			dc.TradeName = @DispatchFromTradeName,
			dc.AddressLine1 = @DispatchFromAddress1,
			dc.AddressLine2 = @DispatchFromAddress2,
			dc.City = @DispatchFromCity,
			dc.StateCode = @DispatchFromStateCode,
			dc.Pincode = @DispatchFromPincode,
			dc.ModifiedStamp = @today
		FROM 
		    einvoice.DocumentContacts dc
			INNER JOIN #TempEwayBillStatusDetails teid ON dc.DocumentId = teid.Id
		WHERE
		    dc.[Type] = @ContactTypeDispatchFrom;

		INSERT INTO einvoice.DocumentContacts 
			([DocumentId]
			,[TradeName]
			,[AddressLine1]
			,[AddressLine2]
			,[City]
			,[StateCode]
			,[Pincode]
			,[Type]
			,[Stamp])
		SELECT  
			teid.Id,
			@DispatchFromTradeName,
			@DispatchFromAddress1,
			@DispatchFromAddress2,
			@DispatchFromCity,
			@DispatchFromStateCode,
			@DispatchFromPincode,
			@ContactTypeDispatchFrom,
			@today
		FROM
			#TempEwayBillStatusDetails teid
			LEFT JOIN einvoice.DocumentContacts dcdf ON dcdf.DocumentId = teid.Id AND dcdf.[Type] = @ContactTypeDispatchFrom
		WHERE
			dcdf.Id IS NULL;
	END
	
	UPDATE
		d
	SET
		d.[TransporterId] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterId ELSE d.[TransporterId] END,
		d.[TransporterName] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterName ELSE d.[TransporterName] END,
		d.[TransactionMode] = CASE WHEN (@OverwriteDispatchDetails = @BitTypeYes OR @OverwriteShippingExportDetails = @BitTypeYes) THEN teid.TransactionMode ELSE d.[TransactionMode] END,
		d.[VehicleType] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @VehicleType ELSE d.[VehicleType] END,
		d.ToEmailAddresses = CASE WHEN @OverwriteNotificationDetails = @BitTypeYes THEN @ToEmailAddresses ELSE d.ToEmailAddresses END,
		d.ToMobileNumbers = CASE WHEN @OverwriteNotificationDetails = @BitTypeYes THEN @ToMobileNumbers ELSE d.ToMobileNumbers END,
		d.[Purpose] = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated AND d.[Purpose] = @PurposeTypeEINV THEN @PurposeTypeEINV | @PurposeTypeEWB ELSE d.[Purpose] END,
		d.[ModifiedStamp] = @today
 	FROM
		einvoice.Documents d
		INNER JOIN #TempEwayBillStatusDetails teid ON d.Id = teid.Id;


	IF EXISTS(SELECT
				  TOP 1 dw.Id 
			  FROM 
				  einvoice.DocumentDW dw 
				  INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = dw.Id
			  WHERE 
				  ((teid.PushStatus = @EwaybillPushStatusGenerated AND dw.[Purpose] = @PurposeTypeEINV)
				    OR @OverwriteTransportDetails = @BitTypeYes))
	BEGIN
		UPDATE
			dw
		SET
			dw.[TransporterId] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterId ELSE dw.[TransporterId] END,
			dw.[TransporterName] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterName ELSE dw.[TransporterName] END,
			dw.[Purpose] = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated AND dw.[Purpose] = @PurposeTypeEINV THEN @PurposeTypeEINV | @PurposeTypeEWB ELSE dw.[Purpose] END
 		FROM
			einvoice.DocumentDW dw
			INNER JOIN #TempEwayBillStatusDetails teid ON dw.Id = teid.Id;
	END

	IF @OverwriteTransportDetails = @BitTypeYes
	BEGIN
		
		DELETE 
			vd
		FROM 
			[ewaybill].[VehicleDetails] vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushStatus_BackGroundTaskId))
			INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = vd.DocumentId
		
		INSERT INTO [ewaybill].[VehicleDetails]
			([DocumentId]
			,[TransportMode]
			,[TransportDocumentNumber]
			,[TransportDocumentDate]
			,[VehicleNumber]
			,[FromState]
			,[FromCity]
			,[IsLatest]
			,[Type]
			,[Stamp]
			,[PushDate]
			,[PushStatus]
			,[BackgroundTaskId]
			,[UpdatedByGSTIN]
			,[UpdationMode])
		SELECT 
			 teid.Id
			,@TransportMode
			,@TransportDocumentNumber
			,@TransportDocumentDate
			,@VehicleNumber
			,ISNULL(dfcd.StateCode, bfcd.StateCode)
			,ISNULL(dfcd.City, bfcd.City)
			,@BitTypeYes
			,@VehicleType
			,@today
			,teid.UpdatedDate
			,@EwaybillPushStatusGenerated
			,@BackgroundTaskId
			,@UpdatedByGstin
			,CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @GenerationModeApi ELSE NULL END
		FROM
			#TempEwayBillStatusDetails teid
			INNER JOIN einvoice.Documents d ON d.Id = teid.Id
			LEFT JOIN einvoice.DocumentContacts bfcd ON bfcd.DocumentId = d.Id AND bfcd.[Type] = @ContactTypeBillFrom
			LEFT JOIN einvoice.DocumentContacts dfcd ON dfcd.DocumentId = d.Id AND dfcd.[Type] = @ContactTypeDispatchFrom
		WHERE
			@TransportMode IS NOT NULL;
	END
	ELSE
	BEGIN

		UPDATE
			vd
		SET
			PushDate = teid.UpdatedDate,
			UpdatedByGstin = @UpdatedByGstin,
			ModifiedStamp = @today,
			UpdationMode = @GenerationModeApi
		FROM 
			[ewaybill].[VehicleDetails] vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushDate))
			INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = vd.DocumentId
		WHERE 
			teid.PushStatus = @EwaybillPushStatusGenerated;

	END

	UPDATE
		ds
	SET
		ds.EwayBillNumber = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.EwayBillNumber ELSE ds.EwayBillNumber END,
		ds.ValidUpto = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.ValidUpto ELSE ds.ValidUpto END,
		ds.GeneratedDate = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.UpdatedDate ELSE ds.GeneratedDate END,
		ds.PushByUserId = @UserId,
		ds.IsPushed = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.IsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.UpdatedDate ELSE ds.PushDate END,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = @today,
		ds.[Status] = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @DocumentStatusGenerated ELSE ds.[Status] END,
		ds.PushStatus = teid.PushStatus,
		ds.Distance = CASE WHEN @OverwriteTransportDetails = @BitTypeYes 
							 THEN ISNULL(teid.ActualDistance, @Distance) 
							 ELSE
								ISNULL(teid.ActualDistance, ds.Distance)
							 END,
		ds.CancelledDate = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN NULL ELSE ds.CancelledDate END,
		ds.Reason = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN NULL ELSE ds.Reason END,
		ds.Remarks = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN NULL ELSE ds.Remarks END,
		ds.GenerationMode = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @GenerationModeApi ELSE ds.GenerationMode END
	FROM
		ewaybill.DocumentStatus AS ds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ds.DocumentId;	
	
	DROP TABLE #TempEwayBillStatusDetails;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForGenerationByIrn] 	 	 
* 	Comments			: 04-05-2020 | Prakash Parmar | This procedure is used to update Eway bill Document Status after uploading on Nic.
						: 19-05-2020 | Prakash Parmar | added PushStatus and PushDate, Change vehicle detail insert,update flow
						: 18-06-2020 | Prakash Parmar | Added BackgroundTaskId
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Generation By Irn
						: 10-09-2020 | Prakash Parmar | Changes In PushStatus
						: 11-09-2020 | Prakash Parmar | Added UpdatedByGstin
						: 17-09-2020 | Prakash Parmar | Added Export shipping details
						: 22-09-2020 | Prakash Parmar | Added ActualDistance
						: 14-10-2020 | Prakash Parmar | Changed vehicle details flow
						: 01-12-2020 | Prakash Parmar | Added Dispatch From Contact Type related fields
						: 31-05-2021 | Prakash Parmar | Updated CancelledDate,reason,remarks fileds in documentstatus table
						: 08-12-2021 | Prakash Parmar | Added GenerationModeApi Parameter
						: 01-02-2022 | Prakash Parmar | Updated Transaction Mode in case of overwrite dispatch and shipping details
						: 24-01-2024 | Prakash Parmar | Removed transaction type in override shipping detail
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							CAST('2018/09/01' AS SMALLDATETIME),
							NULL,
							NULL,
							2,
							1,
							''
						  );

						  EXEC [ewaybill].[UpdatePushResponseForGenerationByIrn]
							@PushResponse = @PushResponseType,
							@UserId = 486,
							@TransporterId = '05DAFDAF465DF',
							@TransporterName = 'ABC', 
							@TransportMode = 1,
							@TransportDocumentNumber = NULL,
							@TransportDocumentDate = NULL,
							@Distance = 100,
							@VehicleNumber = 'GH01AS1234',
							@VehicleType = 1,
							@BackgroundTaskId = 524,
							@UpdatedByGstin = '28ADDABCDE54875',
							@ShipToAddress1 = 'Addre1',
							@ShipToAddress2 = 'Addre2',
							@TransactionTypeExpwop = NULL,
							@TransactionTypeExpwp = NULL,
							@ShipToCity = "jaipur",
							@ShipToStateCode = 8,
							@ShipToPincode = 382610,
							@EwayBillPushStatusGenerated = 2,
							@PurposeTypeEINV = 2,
							@PurposeTypeEWB = 8,
							@DocumentStatusGenerated = 2,
							@BitTypeYes = 1,
							@BitTypeNo = 0,
							@ContactTypeBillFrom = 1,
							@ContactTypeDispatchFrom = 2,
							@ContactTypeShipTo = 4,
							@ContactTypeExportShipTo = 5,
							@OverwriteShippingExportDetails =1,
							@OverwriteTransportDetails = 6,
							@OverwriteDispatchDetails = 0,
							@DispatchFromTradeName = 'trade name',
							@DispatchFromAddress1 = 'address 1',
							@DispatchFromAddress2 = 'address25',
							@DispatchFromCity = 'citu 2',
							@DispatchFromStateCode = 8,
							@DispatchFromPincode = '382654',
							@ContactTypeDispatchFrom2 = 6,
							@OverwriteNotificationDetails BIT,
							@ToEmailAddresses VARCHAR(330),
							@ToMobileNumbers VARCHAR(60),
							@GenerationModeApi = 1;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForGenerationByIrn]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@UserId INT,
	@TransporterId VARCHAR(15) NULL,
	@TransporterName VARCHAR(200) NULL,
	@TransportMode SMALLINT NULL,
	@TransportDocumentNumber VARCHAR(40) NULL,
	@TransportDocumentDate SMALLDATETIME NULL,
	@Distance SMALLINT NULL,
	@VehicleNumber VARCHAR(15) NULL,
	@VehicleType SMALLINT NULL,
	@BackgroundTaskId BIGINT,
	@UpdatedByGstin VARCHAR(15),
	@ShipToAddress1 VARCHAR(120),
	@ShipToAddress2 VARCHAR(120),
	@ShipToCity VARCHAR(110),
	@ShipToStateCode SMALLINT,
	@ShipToPincode INT,
	@OverwriteTransportDetails BIT,
	@OverwriteShippingExportDetails BIT,
	@OverwriteDispatchDetails BIT,
	@DispatchFromTradeName VARCHAR(200),
	@DispatchFromAddress1 VARCHAR(120),
	@DispatchFromAddress2 VARCHAR(120),
	@DispatchFromCity VARCHAR(110),
	@DispatchFromStateCode SMALLINT,
	@DispatchFromPincode INT,
	@OverwriteNotificationDetails BIT,
	@ToEmailAddresses VARCHAR(324),
	@ToMobileNumbers VARCHAR(54),
	@EwayBillPushStatusGenerated INT,
	@PurposeTypeEINV SMALLINT,
	@PurposeTypeEWB SMALLINT,
	@DocumentStatusGenerated INT,
	@BitTypeYes BIT,
	@BitTypeNo BIT,
	@ContactTypeBillFrom INT,
	@ContactTypeDispatchFrom INT,
	@ContactTypeShipTo INT,
	@ContactTypeExportShipTo INT,
	@ContactTypeDispatchFrom2 INT,
	@TransactionTypeExpwop SMALLINT,
	@TransactionTypeExpwp SMALLINT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @today AS DATETIME = GETDATE();
	DECLARE @PushStaus AS SMALLINT;

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors,
		pr.TransactionMode,
		pr.ActualDistance
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails(ID);

	IF (@OverwriteShippingExportDetails = @BitTypeYes AND @ShipToAddress1 IS NOT NULL AND @ShipToCity IS NOT NULL AND 
	    @ShipToStateCode IS NOT NULL AND @ShipToPincode IS NOT NULL)
	BEGIN
		
		UPDATE
			dc
		SET
			dc.Gstin = edc.Gstin,
			dc.LegalName = edc.LegalName,
			dc.TradeName = edc.TradeName,
			dc.VendorCode = edc.VendorCode,
			dc.AddressLine1 = @ShipToAddress1,
			dc.AddressLine2 = @ShipToAddress2,
			dc.City = @ShipToCity,
			dc.StateCode = @ShipToStateCode,
			dc.Pincode = @ShipToPincode,
			dc.ModifiedStamp = @today
		FROM 
		    einvoice.DocumentContacts dc
			INNER JOIN #TempEwayBillStatusDetails tebsd ON dc.DocumentId = tebsd.Id
			INNER JOIN einvoice.DocumentDW dw ON dw.Id = tebsd.Id
			LEFT JOIN einvoice.DocumentContacts edc ON edc.DocumentId = tebsd.Id AND edc.[Type] = @ContactTypeShipTo
		WHERE
			dc.[Type] = @ContactTypeExportShipTo;

		INSERT INTO einvoice.DocumentContacts 
			([DocumentId]
			,[Gstin]
			,[LegalName]
			,[TradeName]
			,[VendorCode]
			,[AddressLine1]
			,[AddressLine2]
			,[City]
			,[StateCode]
			,[Pincode]
			,[Type]
			,[Stamp])
		SELECT  
			tesd.Id,
			dcst.Gstin,
			dcst.LegalName,
			dcst.TradeName,
			dcst.VendorCode,
			@ShipToAddress1,
			@ShipToAddress2,
			@ShipToCity,
			@ShipToStateCode,
			@ShipToPincode,
			@ContactTypeExportShipTo,
			@today
		FROM
			#TempEwayBillStatusDetails tesd
			INNER JOIN einvoice.DocumentDW dw ON dw.Id = tesd.Id
			LEFT JOIN einvoice.DocumentContacts dcst ON dcst.DocumentId = tesd.Id AND dcst.[Type] = @ContactTypeShipTo
			LEFT JOIN einvoice.DocumentContacts dcest ON dcest.DocumentId = tesd.Id AND dcest.[Type] = @ContactTypeExportShipTo
		WHERE 
			dcest.Id IS NULL;
	END

	IF (@OverwriteDispatchDetails = @BitTypeYes AND @DispatchFromTradeName IS NOT NULL AND @DispatchFromAddress1 IS NOT NULL AND 
	    @DispatchFromCity IS NOT NULL AND @DispatchFromStateCode IS NOT NULL AND @DispatchFromPincode IS NOT NULL)
	BEGIN
		
		UPDATE
			dc
		SET
			dc.Gstin = dcdf.Gstin,
			dc.LegalName = dcdf.LegalName,
			dc.TradeName = @DispatchFromTradeName,
			dc.VendorCode = dcdf.VendorCode,
			dc.AddressLine1 = @DispatchFromAddress1,
			dc.AddressLine2 = @DispatchFromAddress2,
			dc.City = @DispatchFromCity,
			dc.StateCode = @DispatchFromStateCode,
			dc.Pincode = @DispatchFromPincode,
			dc.ModifiedStamp = @today
		FROM
		    einvoice.DocumentContacts dc
			INNER JOIN #TempEwayBillStatusDetails teid ON dc.DocumentId = teid.Id
			LEFT JOIN einvoice.DocumentContacts dcdf ON dcdf.DocumentId = teid.Id AND dcdf.[Type] = @ContactTypeDispatchFrom
		WHERE
			dc.[Type] = @ContactTypeDispatchFrom2;

		INSERT INTO einvoice.DocumentContacts 
			([DocumentId]
			,[Gstin]
			,[LegalName]
			,[TradeName]
			,[VendorCode]
			,[AddressLine1]
			,[AddressLine2]
			,[City]
			,[StateCode]
			,[Pincode]
			,[Type]
			,[Stamp])
		SELECT  
			teid.Id,
			dcdf.Gstin,
			dcdf.LegalName,
			@DispatchFromTradeName,
			dcdf.VendorCode,
			@DispatchFromAddress1,
			@DispatchFromAddress2,
			@DispatchFromCity,
			@DispatchFromStateCode,
			@DispatchFromPincode,
			@ContactTypeDispatchFrom2,
			@today
		FROM
			#TempEwayBillStatusDetails teid
			LEFT JOIN einvoice.DocumentContacts dcdf ON dcdf.DocumentId = teid.Id AND dcdf.[Type] = @ContactTypeDispatchFrom
			LEFT JOIN einvoice.DocumentContacts dcdf2 ON dcdf2.DocumentId = teid.Id AND dcdf2.[Type] = @ContactTypeDispatchFrom2
		WHERE 
			dcdf2.Id IS NULL;
	END

	UPDATE
		d
	SET
		d.[TransporterId] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterId ELSE d.[TransporterId] END,
		d.[TransporterName] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterName ELSE d.[TransporterName] END,
		d.[TransactionMode] = CASE WHEN (@OverwriteDispatchDetails = @BitTypeYes OR @OverwriteShippingExportDetails = @BitTypeYes) THEN teid.TransactionMode ELSE d.[TransactionMode] END,
		d.[VehicleType] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @VehicleType ELSE d.[VehicleType] END,
		d.[Purpose] = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @PurposeTypeEINV | @PurposeTypeEWB ELSE d.[Purpose] END,
		d.ToEmailAddresses = CASE WHEN @OverwriteNotificationDetails = @BitTypeYes THEN @ToEmailAddresses ELSE d.ToEmailAddresses END,
		d.ToMobileNumbers = CASE WHEN @OverwriteNotificationDetails = @BitTypeYes THEN @ToMobileNumbers ELSE d.ToMobileNumbers END,
		d.[ModifiedStamp] = @today
 	FROM
		einvoice.Documents d
		INNER JOIN #TempEwayBillStatusDetails teid ON d.Id = teid.Id;

	IF EXISTS(SELECT 
			  	  TOP 1 dw.Id 
			  FROM 
			  	  einvoice.DocumentDW dw 
			  	  INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = dw.Id
			  WHERE 
			  	  teid.PushStatus = @EwaybillPushStatusGenerated
			  	  OR @OverwriteTransportDetails = @BitTypeYes)
	BEGIN
		UPDATE
			dw
		SET
			dw.[TransporterId] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterId ELSE dw.[TransporterId] END,
			dw.[TransporterName] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes THEN @TransporterName ELSE dw.[TransporterName] END,
			dw.[Purpose] = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @PurposeTypeEINV | @PurposeTypeEWB ELSE dw.[Purpose] END
 		FROM
			einvoice.DocumentDW dw
			INNER JOIN #TempEwayBillStatusDetails teid ON dw.Id = teid.Id;
	END

	IF @OverwriteTransportDetails = @BitTypeYes
	BEGIN

		DELETE 
			vd
		FROM 
			[ewaybill].[VehicleDetails] vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushStatus_BackGroundTaskId)) 
			INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = vd.DocumentId
		
		INSERT INTO [ewaybill].[VehicleDetails]
			([DocumentId]
			,[TransportMode]
			,[TransportDocumentNumber]
			,[TransportDocumentDate]
			,[VehicleNumber]
			,[FromState]
			,[FromCity]
			,[IsLatest]
			,[Type]
			,[Stamp]
			,[PushDate]
			,[PushStatus]
			,[BackgroundTaskId]
			,[UpdatedByGSTIN]
			,[UpdationMode])
		SELECT 
			 teid.Id
			,@TransportMode
			,@TransportDocumentNumber
			,@TransportDocumentDate
			,@VehicleNumber
			,ISNULL(dfcd.StateCode, bfcd.StateCode)
			,ISNULL(dfcd.City, bfcd.City)
			,@BitTypeYes
			,@VehicleType
			,@today
			,teid.UpdatedDate
			,@EwaybillPushStatusGenerated
			,@BackgroundTaskId
			,@UpdatedByGstin
			,CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @GenerationModeApi ELSE NULL END
		FROM
			#TempEwayBillStatusDetails teid
			INNER JOIN einvoice.Documents d ON d.Id = teid.Id
			LEFT JOIN einvoice.DocumentContacts bfcd ON bfcd.DocumentId = d.Id AND bfcd.[Type] = @ContactTypeBillFrom
			LEFT JOIN einvoice.DocumentContacts dfcd ON dfcd.DocumentId = d.Id AND dfcd.[Type] = @ContactTypeDispatchFrom
		WHERE
			@TransportMode IS NOT NULL;
	END
	ELSE
	BEGIN

		UPDATE
			vd
		SET
			PushDate = teid.UpdatedDate,
			UpdatedByGstin = @UpdatedByGstin,
			ModifiedStamp = @today,
			UpdationMode = @GenerationModeApi
		FROM 
			[ewaybill].[VehicleDetails] vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_PushDate))
			INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = vd.DocumentId
		WHERE 
			teid.PushStatus = @EwaybillPushStatusGenerated;

	END

	UPDATE
		ewds
	SET
		ewds.EwayBillNumber = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.EwayBillNumber ELSE ewds.EwayBillNumber END,
		ewds.ValidUpto = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.ValidUpto ELSE ewds.ValidUpto END,
		ewds.GeneratedDate = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.UpdatedDate ELSE ewds.GeneratedDate END,
		ewds.PushByUserId = @UserId,
		ewds.IsPushed = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.IsPushed ELSE ewds.IsPushed END,
		ewds.PushDate = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN teid.UpdatedDate ELSE ewds.PushDate END,
		ewds.Errors = teid.Errors,
		ewds.ModifiedStamp = @today,
		ewds.[Status] = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @DocumentStatusGenerated ELSE ewds.[Status] END,
		ewds.PushStatus = teid.PushStatus,
		ewds.[Distance] = CASE WHEN @OverwriteTransportDetails = @BitTypeYes
							   THEN ISNULL(teid.ActualDistance, @Distance)
							   ELSE
								 ISNULL(teid.ActualDistance, ewds.Distance) 
							   END,
		ewds.CancelledDate = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN NULL ELSE ewds.CancelledDate END,
		ewds.Reason = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN NULL ELSE ewds.Reason END,
		ewds.Remarks = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN NULL ELSE ewds.Remarks END,
		ewds.GenerationMode = CASE WHEN teid.PushStatus = @EwaybillPushStatusGenerated THEN @GenerationModeApi ELSE ewds.GenerationMode END
	FROM
		ewaybill.DocumentStatus AS ewds
		INNER JOIN #TempEwayBillStatusDetails teid ON ewds.DocumentId = teid.Id;	
	
	DROP TABLE #TempEwayBillStatusDetails;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForMultiVehicleAddition] 	 	 
* 	Comments			: 29-05-2020 | Prakash Parmar | This procedure is used to add multi vehicle of Eway Bills.
						  18-06-2020 | Prakash Parmar | Added BackgroundTaskId
						: 19-06-2020 | Chandresh Prajapati |	Renamed  FromPlace  -> FromCity 
						: 13-07-2020 | Prakash Parmar | Removed FromState And FromCity in insert vehicledetails
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of MultiVehicle Addition
						: 10-09-2020 | Prakash Parmar | Changes In PushStatus
						: 11-09-2020 | Prakash Parmar | Added UpdatedByGstin
						: 08-12-2021 | Prakash Parmar | Added GenerationModeApi Parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'791000879982',
							CAST('2020/05/26' AS SMALLDATETIME),
							NULL,
							NULL,
							11,
							1,
							'sfdfsdf'
						  );
						  
						  EXEC [ewaybill].[UpdatePushResponseForMultiVehicleAddition]
								@PushResponse = @PushResponseType,
								@MultiVehicleMovementId = 1,
								@Quantity = 1,
								@VehicleNumber = 'GJ18RK7894',
								@TransportDocumentNumber = 'YHU001',
								@TransportDocumentDate = '2020-05-29',
								@UserId = 663,
								@BackgroundTaskId = 524,
								@UpdatedByGstin = '28ADDABCDE54875',
								@EwayBillPushStatusMultiVehicleAdded = 12,
								@BitTypeYes = 1,
								@BitTypeNo = 0,
								@GenerationModeApi = 1;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForMultiVehicleAddition]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@MultiVehicleMovementId BIGINT,
	@Quantity INT,	
	@VehicleNumber VARCHAR(20),
	@TransportDocumentNumber VARCHAR(15),
	@TransportDocumentDate SMALLDATETIME,
	@UserId INT,
	@BackgroundTaskId BIGINT,
	@UpdatedByGstin VARCHAR(15),
	@EwayBillPushStatusMultiVehicleAdded SMALLINT,
	@BitTypeYes BIT,
	@BitTypeNo BIT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails (ID)

	UPDATE
		ds
	SET
		ds.PushStatus = teid.PushStatus,
		ds.PushByUserId = @UserId,
		ds.IsPushed = CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleAdded AND teid.UpdatedDate IS NOT NULL THEN teid.IsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleAdded AND teid.UpdatedDate IS NOT NULL THEN teid.UpdatedDate ELSE ds.PushDate END,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = GETDATE()
	FROM
		ewaybill.DocumentStatus ds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ds.DocumentId;
	

	UPDATE 
		vd
	SET
		vd.IsLatest = CASE WHEN teid.UpdatedDate IS NOT NULL THEN @BitTypeNo ELSE vd.IsLatest END
	FROM
		[ewaybill].[VehicleDetails] AS vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate)) 
		INNER JOIN #TempEwayBillStatusDetails teid ON vd.DocumentId = teid.Id
	WHERE 
		vd.IsLatest = @BitTypeYes;

	 DELETE
		vd
	 FROM 
		ewaybill.VehicleDetails AS vd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate)) 
		INNER JOIN #TempEwayBillStatusDetails AS teid ON vd.DocumentId = teid.Id
	 WHERE
		vd.IsLatest = @BitTypeNo
		AND vd.PushDate IS NULL;

	INSERT INTO ewaybill.VehicleDetails
	(
		DocumentId,
		VehicleMovementId,
		TransportMode,
		TransportDocumentNumber,
		TransportDocumentDate,
		VehicleNumber,
		FromState,
		FromCity,
		IsLatest,
		PushDate,
		PushStatus,
		Errors,
		Quantity,
		GroupNumber,
		BackgroundTaskId,
		UpdatedByGstin,
		UpdationMode
	)
	SELECT
		teid.Id,
		@MultiVehicleMovementId,
		vm.Mode,
		@TransportDocumentNumber,
		@TransportDocumentDate,
		@VehicleNumber,
		vm.FromState,
		vm.FromCity,
		CASE WHEN teid.UpdatedDate IS NOT NULL THEN @BitTypeYes ELSE @BitTypeNo END,
		teid.UpdatedDate,
		@EwayBillPushStatusMultiVehicleAdded,
		teid.Errors,
		@Quantity,
		vm.GroupNumber,
		@BackgroundTaskId,
		@UpdatedByGstin,
		CASE WHEN teid.UpdatedDate IS NOT NULL THEN @GenerationModeApi ELSE NULL END
	FROM
		#TempEwayBillStatusDetails teid
		INNER JOIN ewaybill.VehicleMovements vm ON vm.Id = @MultiVehicleMovementId;

	DROP TABLE 	#TempEwayBillStatusDetails;
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [subscriber].[UpdateBlacklistedVendorStatus] 	 

* 	Comments			: 23-01-2024 | Sumant Kumar | This Procedure is used to update vendor status.
                        : 24-01-2024 | Chandresh Prajapati | Added Notification Filters.
                        : 16-02-2024 | Sumant Kumar | Added Gstr1GrcScore and Gstr3bGrcScore Filter.
						: 04-03-2024 | Sumant Kumar	| Modify Gstr1GrcScore and Gstr3bGrcScore to single filter GstrGrcScore.
						: 02-05-2024 | Chandresh Prajapati	| Added AuditTrailDetails Parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE  @TotalRecord INT,
								@Ids [common].[BigIntType]
								@VerifiedAgings AS [common].[IntType];

  						  INSERT INTO @Ids VALUES (3);
						  --INSERT INTO  @VerifiedAgings VALUES (2);
						  EXEC [subscriber].[UpdateBlacklistedVendorStatus]
								@Ids =  @Ids,
								@SubscriberId  = 164 ,
						  		@Gstins = null,
								@Codes =null,
								@TradeNames = null,
								@LegalNames = null,
								@StateCodes = null,
								@PinCodes = null,
								@FromVerifiedDate = null,
								@ToVerifiedDate = null,
								@VerifiedAgings = @VerifiedAgings,
								@VerificationStatuses = null,
								@TaxpayerTypes = null,
								@IsPreferred = null,
								@VerificationError = null,
								@Custom = null,
								@BitTypeYes = 1,
								@UserIds = NULL,
								@FromUploadedDate = NULL,
								@ToUploadedDate = NULL,
								@FromChangeDate = NULL,
								@ToChangeDate = NULL,
						  		@Start  = 0,
						  		@Size  = 1000,
						  		@SortExpression = 'id desc',
								@IncludeVendorVerificationStatuses = '1,2,3',
								@VendorKycStatuses = NULL,
								@NotificationType =  NULL,
								@NotificationStatuses  = NULL,
								@NotificationError = NULL,
								@NotificationTypeSent  = 1,
								@NotificationTypeReceived  = 2,
								@AuditTrailDetails = @AuditTrailDetails,
						  		@TotalRecord  = @TotalRecord OUT
						  		Select @TotalRecord;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE  PROCEDURE [subscriber].[UpdateBlacklistedVendorStatus]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @Gstins VARCHAR(MAX),
	 @Codes VARCHAR(MAX),
	 @TradeNames VARCHAR(MAX),
	 @LegalNames VARCHAR(MAX),
	 @StateCodes VARCHAR(MAX),
	 @Pincodes VARCHAR(MAX),
	 @FromVerifiedDate DATETIME NULL,
	 @ToVerifiedDate DATETIME NULL,
	 @VerifiedAgings [common].[IntType] READONLY,
	 @VerificationStatuses VARCHAR(MAX),
	 @TaxpayerTypes VARCHAR(MAX),
	 @IsPreferred BIT NULL,
	 @VerificationError BIT NULL,
	 @VendorType SMALLINT NULL,
	 @Custom VARCHAR(2000),
	 @BitTypeYes BIT,
	 @UserIds VARCHAR(MAX),
	 @FromUploadedDate DATETIME,
	 @ToUploadedDate DATETIME,
	 @FromChangeDate DATETIME,
	 @ToChangeDate DATETIME,
	 @EnablementStatus SMALLINT,
	 @VendorEnablementStatusYes SMALLINT,
	 @VendorEnablementStatusNo SMALLINT,
	 @VendorEnablementStatusNotAvailable SMALLINT,
	 @IsVerifiedAndAutoPopulateRequest BIT,
	 @TaxpayerStatuses [common].[IntType]READONLY,
	 @TaxpayerStatusNotAvailable INTEGER,
	 @Pans VARCHAR(MAX),
	 @Tans VARCHAR(MAX),
	 @LdcAvailability Smallint,
	 @LdcAvailable smallint,
	 @LdcNotAvailable smallint,
	 @LdcExpiring smallint,
	 @LdcExpired  smallint,
	 @SortExpression VARCHAR(128),
	 @IncludeVendorVerificationStatuses VARCHAR(20) NULL,
	 @IncludeSendVendorsKycRecordsOnly bit,
	 @VendorTypeV smallint,
	 @VendorKycStatuses varchar(max),
	 @Start INT,
	 @Size INT,
	 @BlacklistedVendor BIT,
	 @NotificationType SMALLINT,
	 @NotificationStatuses VARCHAR(MAX),
	 @NotificationError BIT,
	 @NotificationTypeSent SMALLINT,
	 @NotificationTypeReceived SMALLINT,
	 @TotalRecord INT = NULL OUTPUT,
	 @BlackListStatus BIT,
	 @GrcScoreFrom SMALLINT,
	 @GrcScoreTo SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE #TempVendorIds
     (
	   VendorId BIGINT
     );

	 INSERT INTO #TempVendorIds(VendorId)
	 EXEC [subscriber].[FilterVendors]
		@Ids = @Ids,
		@SubscriberId = @SubscriberId,
		@Gstins = @Gstins,
		@Codes = @Codes, 
		@TradeNames = @TradeNames,
		@LegalNames = @LegalNames,
		@StateCodes = @StateCodes,
		@Pincodes = @Pincodes,
		@FromVerifiedDate = @FromVerifiedDate,
		@ToVerifiedDate = @ToVerifiedDate,
		@VerifiedAgings = @VerifiedAgings,
		@VendorType = @VendorType,
		@VerificationStatuses = @VerificationStatuses,
		@TaxpayerTypes = @TaxpayerTypes,
		@IsPreferred = @IsPreferred,
		@VerificationError = @VerificationError,
		@Custom = @Custom,
		@BitTypeYes = @BitTypeYes,
		@UserIds = @UserIds,
		@FromUploadedDate = @FromUploadedDate,
		@ToUploadedDate = @ToUploadedDate,
		@FromChangeDate = @FromChangeDate,
		@ToChangeDate = @ToChangeDate,
		@EnablementStatus = @EnablementStatus,
		@VendorEnablementStatusYes = @VendorEnablementStatusYes,
		@VendorEnablementStatusNo = @VendorEnablementStatusNo,
		@VendorEnablementStatusNotAvailable = @VendorEnablementStatusNotAvailable,
		@IsVerifiedAndAutoPopulateRequest =  @IsVerifiedAndAutoPopulateRequest,
		@TaxpayerStatuses = @TaxpayerStatuses,
		@TaxpayerStatusNotAvailable = @TaxpayerStatusNotAvailable,
		@Pans  = @Pans,
		@Tans = @Tans,
		@LdcAvailability = @LdcAvailability,
		@LdcAvailable = @LdcAvailable, 
		@LdcNotAvailable = @LdcNotAvailable ,
		@LdcExpiring = @LdcExpiring ,
		@LdcExpired = @LdcExpired  ,
		@SortExpression = @SortExpression,
		@Start = @Start,
		@Size = @Size,
		@IncludeVendorVerificationStatuses = @IncludeVendorVerificationStatuses,
		@IncludeSendVendorsKycRecordsOnly = @IncludeSendVendorsKycRecordsOnly,
		@VendorTypeV = @VendorTypeV,
		@VendorKycStatuses = @VendorKycStatuses,
		@BlacklistedVendor =  @BlacklistedVendor,
		@NotificationType = @NotificationType,
		@NotificationStatuses = @NotificationStatuses,
		@NotificationError = @NotificationError,
		@NotificationTypeSent  = @NotificationTypeSent,
		@NotificationTypeReceived = @NotificationTypeReceived,
		@GrcScoreFrom = @GrcScoreFrom,
	    @GrcScoreTo = @GrcScoreTo,
		@TotalRecord = @TotalRecord OUTPUT



	 CREATE TABLE #TempUniqueGstinTrade
     (
	   SubscriberId INT,
	   Gstin VARCHAR(15),
	   TradeName VARCHAR(300)
     );

	 INSERT INTO #TempUniqueGstinTrade(Gstin, TradeName)
	 SELECT
	     Gstin,
		 TradeName
	 FROM
	     subscriber.Vendors as sv
		 INNER JOIN "#TempVendorIds" as tvid ON tvid.VendorId = sv.Id;  

     CREATE TABLE #TempUniqueGstin
     (
	   VendorGstin VARCHAR(15),
     );

	 INSERT INTO #TempUniqueGstin(VendorGstin)
	 SELECT DISTINCT
	     Gstin
	 FROM
	     #TempUniqueGstinTrade
     WHERE
		Gstin IS NOT NULL;

	 CREATE TABLE #TempUniqueTrade
     (
	   Trade VARCHAR(300)
     );

	 INSERT INTO #TempUniqueTrade(Trade)
	 SELECT DISTINCT
	     TradeName
	 FROM
	    #TempUniqueGstinTrade
     WHERE
		Gstin IS NULL;

	 UPDATE
		subscriber.[Vendors]
	 SET 
		[IsBlackListed] = @BlackListStatus,
		ModifiedStamp = GETDATE()
     FROM
        #TempUniqueTrade tut
     WHERE 
		[SubscriberId] = @SubscriberId
        AND [TradeName] = tut.Trade;

	UPDATE
		subscriber.[Vendors]
	SET 
		[IsBlackListed] = @BlackListStatus,
		ModifiedStamp = GETDATE()
	FROM 
		#TempUniqueGstin tug
	WHERE 
		[SubscriberId] = @SubscriberId
		AND [Gstin] = tug.VendorGstin;

			DROP TABLE #TempVendorIds, #TempUniqueGstin, #TempUniqueGstinTrade, #TempUniqueTrade;
END;
GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForMultiVehicleMovementInitiation] 	 	 
* 	Comments			: 25-05-2020 | Prakash Parmar | This procedure is used to intiate multi vehicle of Eway Bills.
						  18-06-2020 | Prakash Parmar | Added BackgroundTaskId
						: 19-06-2020 | Chandresh Prajapati |	Renamed  FromPlace And ToPlace -> FromCity And ToCity
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of MultiVehicle Initiate
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'791000879982',
							CAST('2020/05/26' AS SMALLDATETIME),
							NULL,
							NULL,
							11,
							1,
							'erer'
						  );
						  
						  EXEC [ewaybill].[UpdatePushResponseForMultiVehicleMovementInitiation]
								@PushResponse = @PushResponseType,
								@FromCity = 'VAPI',
								@FromState = 5,
								@ReasonCode = 1,
								@ReasonRemarks = 'Test remark',
								@ToCity = 'PUNE',
								@ToState = 8,
								@TotalQuantity = 10,
								@TransportMode = 1,
								@Uqc = 'BOX',
								@BackgroundTaskId = 524,
								@UserId = 663,
								@EwayBillPushStatusMultiVehicleInitiated = 11,
								@BitTypeYes = 1,
								@BitTypeNo = 0;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForMultiVehicleMovementInitiation]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@FromCity VARCHAR(50),
	@FromState SMALLINT,
	@ReasonCode SMALLINT,
	@ReasonRemarks VARCHAR(50),
	@ToCity VARCHAR(50),
	@ToState SMALLINT,
	@TotalQuantity INT,	
	@TransportMode SMALLINT,
	@Uqc VARCHAR(30),
	@BackgroundTaskId BIGINT,
	@UserId INT,
	@EwayBillPushStatusMultiVehicleInitiated SMALLINT,
	@BitTypeYes SMALLINT,
	@BitTypeNo SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @CurrentDate DATETIME = GETDATE();

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails(ID)				

	UPDATE
		ds
	SET
		ds.PushStatus = teid.PushStatus,
		ds.PushByUserId = @UserId,
		ds.IsPushed = CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleInitiated AND teid.Errors IS NULL THEN teid.IsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleInitiated AND teid.Errors IS NULL THEN teid.UpdatedDate ELSE ds.PushDate END,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = @CurrentDate,
		ds.IsMultiVehicleMovementInitiated = (CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleInitiated THEN @BitTypeYes ELSE ds.IsMultiVehicleMovementInitiated END)
	FROM
		ewaybill.DocumentStatus ds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ds.DocumentId;	

	UPDATE 
		evm
	SET
		evm.IsLatest = CASE WHEN teid.UpdatedDate IS NOT NULL THEN @BitTypeNo ELSE evm.IsLatest END
	FROM 
		[ewaybill].[VehicleMovements] AS evm
		INNER JOIN #TempEwayBillStatusDetails teid ON evm.DocumentId = teid.Id
	WHERE 
		evm.IsLatest = @BitTypeYes;

	 DELETE
		evm
	 FROM 
		[ewaybill].[VehicleMovements] AS evm
		INNER JOIN #TempEwayBillStatusDetails AS teid ON evm.DocumentId = teid.Id
	 WHERE  
		evm.PushDate IS NULL
		AND evm.IsLatest = @BitTypeNo;

	INSERT INTO [ewaybill].[VehicleMovements]
			   ([DocumentId]
			   ,[Mode]
			   ,[FromState]
			   ,[FromCity]
			   ,[ToState]
			   ,[ToCity]
			   ,[Quantity]
			   ,[Uqc]
			   ,[Reason]
			   ,[Remarks]
			   ,[GroupNumber]
			   ,[IsLatest]
			   ,[PushStatus]
			   ,[Errors]
			   ,[PushDate]
			   ,[Stamp]
			   ,[BackgroundTaskId])
			 SELECT 
				teid.Id,
				@TransportMode,
				@FromState,
				@FromCity,
				@ToState,
				@ToCity,
				@TotalQuantity,
				@Uqc,
				@ReasonCode,
				@ReasonRemarks,
				teid.GroupNumber,
				CASE WHEN teid.UpdatedDate IS NOT NULL THEN @BitTypeYes ELSE @BitTypeNo END,
				teid.PushStatus,
				teid.Errors,
				teid.UpdatedDate,
				@CurrentDate,
				@BackgroundTaskId
			 FROM
				#TempEwayBillStatusDetails teid;		

	DROP TABLE 	#TempEwayBillStatusDetails;

END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForMultiVehicleUpdation] 	 	 
* 	Comments			: 29-05-2020 | Prakash Parmar | This procedure is used to update multi vehicle of Eway Bills.
						  18-06-2020 | Prakash Parmar | Added BackgroundTaskId
						: 19-06-2020 | Chandresh Prajapati |	Renamed  FromPlace -> FromCity
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of MultiVehicle Updation
						: 10-09-2020 | Prakash Parmar | Changes In PushStatus
						: 11-09-2020 | Prakash Parmar | Added UpdatedByGstin
						: 08-12-2021 | Prakash Parmar | Added GenerationModeApi Parameter
 ----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'791000879982',
							CAST('2020/05/26' AS SMALLDATETIME),
							NULL,
							NULL,
							11,
							1,
							''
						  );
						  
						  EXEC [ewaybill].[UpdatePushResponseForMultiVehicleUpdation]
								@PushResponse = @PushResponseType,
								@UserId = 663,
								@VehicleNumber = 'GJ18RK7894',
								@MultiVehicleMovementId = 1,
								@VehicleDetailId = 7906,
								@TransportDocumentNumber = 'YHU001',
								@ReasonCode = 1,
								@ReasonRemarks = 'test reamarks',
								@FromState = 5,
								@FromCity = 'ABAD',
								@BackgroundTaskId = 524,
								@UpdatedByGstin = '28ADDABCDE54875',
								@EwayBillPushStatusMultiVehicleUpdated = 13,
								@BitTypeYes = 1,
								@BitTypeNo = 0,
								@GenerationModeApi = 1;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForMultiVehicleUpdation]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@UserId INT,
	@VehicleNumber VARCHAR(20),
	@MultiVehicleMovementId BIGINT,
	@VehicleDetailId BIGINT,
	@TransportDocumentNumber VARCHAR(15),
	@ReasonCode SMALLINT,
	@ReasonRemarks VARCHAR(50),
	@FromState SMALLINT,
	@FromCity VARCHAR(110),
	@BackgroundTaskId BIGINT,
	@UpdatedByGstin VARCHAR(15),
	@EwayBillPushStatusMultiVehicleUpdated SMALLINT,
	@BitTypeYes BIT,
	@BitTypeNo BIT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails (ID)	

	UPDATE
		ds
	SET
		ds.PushStatus = teid.PushStatus,
		ds.PushByUserId = @UserId,
		ds.IsPushed = CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.IsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusMultiVehicleUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.UpdatedDate ELSE ds.PushDate END,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = GETDATE()
	FROM
		ewaybill.DocumentStatus ds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ds.DocumentId;
	
	UPDATE 
		evd
	SET
		evd.IsLatest = CASE WHEN teid.UpdatedDate IS NOT NULL THEN @BitTypeNo ELSE evd.IsLatest END
	FROM
		[ewaybill].[VehicleDetails] AS evd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate)) 
		INNER JOIN #TempEwayBillStatusDetails teid ON evd.DocumentId = teid.Id
	WHERE 
		evd.IsLatest = @BitTypeYes;

	 DELETE
		evd
	 FROM 
		ewaybill.VehicleDetails AS evd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate)) 
		INNER JOIN #TempEwayBillStatusDetails AS teid ON evd.DocumentId = teid.Id
	 WHERE
		evd.IsLatest = @BitTypeNo
		AND evd.PushDate IS NULL;
		
	INSERT INTO ewaybill.VehicleDetails
	(
		DocumentId,
		VehicleDetailId,
		VehicleMovementId,
		TransportMode,
		TransportDocumentNumber,
		TransportDocumentDate,
		VehicleNumber,
		FromState,
		FromCity,
		Reason,
		Remarks,
		IsLatest,
		PushDate,
		PushStatus,
		Errors,
		Quantity,
		GroupNumber,
		BackgroundTaskId,
		UpdatedByGstin,
		UpdationMode
	)
	SELECT
		teid.Id,
		@VehicleDetailId,
		@MultiVehicleMovementId,
		vm.Mode,
		@TransportDocumentNumber,
		vd.TransportDocumentDate,
		@VehicleNumber,
		@FromState,
		@FromCity,
		@ReasonCode,
		@ReasonRemarks,
		CASE WHEN teid.UpdatedDate IS NOT NULL THEN @BitTypeYes ELSE @BitTypeNo END,
		teid.UpdatedDate,
		@EwayBillPushStatusMultiVehicleUpdated,
		teid.Errors,
		vd.Quantity,
		vm.GroupNumber,
		@BackgroundTaskId,
		@UpdatedByGstin,
		CASE WHEN teid.UpdatedDate IS NOT NULL THEN @GenerationModeApi ELSE NULL END
	FROM
		#TempEwayBillStatusDetails teid
		INNER JOIN ewaybill.VehicleMovements vm ON vm.Id = @MultiVehicleMovementId
		INNER JOIN ewaybill.VehicleDetails vd ON vd.Id = @VehicleDetailId;
		
	DROP TABLE 	#TempEwayBillStatusDetails;

END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForRejection] 	 	 
* 	Comments			: 10-04-2020 | Prakash Parmar | This procedure is used to reject Eway Bills.
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Rejection
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							CAST('2018/09/01' AS SMALLDATETIME),
							NULL,
							NULL,
							8,
							1,
							''
						  );
						  
						  EXEC [ewaybill].[UpdatePushResponseForRejection]
								@PushResponse = @PushResponseType,
								@EwayBillPushStatusRejected = 8,
								@DocumentStatusCompleted = 3;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForRejection]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@EwayBillPushStatusRejected INT,
	@DocumentStatusCompleted INT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;
	
	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails(ID)	

	UPDATE 
		ewds
	SET
		ewds.RejectedDate = (CASE WHEN teid.PushStatus = @EwayBillPushStatusRejected THEN teid.UpdatedDate ELSE ewds.RejectedDate END),
		ewds.[Status] = (CASE WHEN teid.PushStatus = @EwayBillPushStatusRejected THEN @DocumentStatusCompleted ELSE ewds.[Status] END),
	    ewds.PushStatus = teid.PushStatus,
		ewds.PushDate = (CASE WHEN teid.PushStatus = @EwayBillPushStatusRejected THEN teid.UpdatedDate ELSE ewds.PushDate END),
		ewds.Errors = teid.Errors,
		ewds.ModifiedStamp = GETDATE()
	FROM
		ewaybill.DocumentStatus AS ewds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ewds.DocumentId;
	
	DROP TABLE 	#TempEwayBillStatusDetails;

END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForTransporterUpdation] 	 	 
* 	Comments			: 11-05-2020 | Prakash Parmar | This procedure is used to update transporter details of Eway Bills.
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Transporter Updation
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							CAST('2018/09/01' AS SMALLDATETIME),
							NULL,
							NULL,
							5,
							1,
							''
						  );
						  
						  EXEC [ewaybill].[UpdatePushResponseForTransporterUpdation]
								@PushResponse = @PushResponseType,
								@TransporterId = '33GSPTN9061G3ZY',
								@TransporterName = 'Test remark 123',
								@UserId = 1,
								@IsLocationGstinMatched = 0,
								@EwayBillPushStatusTransporterUpdated = 5,
								@SourceTypeGeneratedByMe = 2,
								@SourceTypeGeneratedAgainstMe = 4,
								@SourceTypeAssignedForTransportation = 8,
								@BitTypeYes = 1,
								@BitTypeNo = 0,
								@DocumentStatusCompleted = 3;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForTransporterUpdation]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@TransporterId VARCHAR(15) NULL,
	@TransporterName VARCHAR(200) NULL,
	@IsLocationGstinMatched BIT,
	@UserId INT,
	@EwayBillPushStatusTransporterUpdated SMALLINT,
	@SourceTypeGeneratedByMe SMALLINT,
	@SourceTypeGeneratedAgainstMe SMALLINT,
	@SourceTypeAssignedForTransportation SMALLINT,
	@BitTypeYes SMALLINT,
	@BitTypeNo SMALLINT,
	@DocumentStatusCompleted SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.GroupNumber,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors,
		(CASE WHEN pr.PushStatus = @EwayBillPushStatusTransporterUpdated THEN 
			CASE WHEN @IsLocationGstinMatched = @BitTypeNo THEN 
				CASE WHEN d.SourceType = @SourceTypeAssignedForTransportation THEN @BitTypeYes
				END
			END
		END) AS IsSourceTypeAssignedForTransportation
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr
		INNER JOIN einvoice.DocumentDW d ON d.Id = pr.Id;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails(ID)	

	UPDATE
		d
	SET
		d.TransporterId = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN @TransporterId ELSE d.TransporterId END),
		d.TransporterName = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN @TransporterName ELSE d.TransporterName END),
		d.SourceType = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN 
							CASE WHEN @IsLocationGstinMatched = @BitTypeNo THEN 
								CASE WHEN d.SourceType IN (@SourceTypeGeneratedByMe | @SourceTypeAssignedForTransportation) THEN @SourceTypeGeneratedByMe
									 WHEN d.SourceType IN (@SourceTypeGeneratedAgainstMe | @SourceTypeAssignedForTransportation) THEN @SourceTypeGeneratedAgainstMe
								ELSE d.SourceType END
							     WHEN @IsLocationGstinMatched = @BitTypeYes THEN
								CASE WHEN d.SourceType = @SourceTypeGeneratedByMe THEN @SourceTypeGeneratedByMe | @SourceTypeAssignedForTransportation
									 WHEN d.SourceType = @SourceTypeGeneratedAgainstMe THEN @SourceTypeGeneratedAgainstMe | @SourceTypeAssignedForTransportation
								ELSE d.SourceType END
							END
						ELSE
							d.SourceType
						END)
	FROM
		einvoice.Documents d
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = d.Id;
	
	UPDATE
		dw
	SET
		dw.TransporterId = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN @TransporterId ELSE dw.TransporterId END),
		dw.TransporterName = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN @TransporterName ELSE dw.TransporterName END),
		dw.SourceType = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN 
							CASE WHEN @IsLocationGstinMatched = @BitTypeNo THEN 
								CASE WHEN dw.SourceType IN (@SourceTypeGeneratedByMe | @SourceTypeAssignedForTransportation) THEN @SourceTypeGeneratedByMe
										WHEN dw.SourceType IN (@SourceTypeGeneratedAgainstMe | @SourceTypeAssignedForTransportation) THEN @SourceTypeGeneratedAgainstMe
								ELSE dw.SourceType END
									WHEN @IsLocationGstinMatched = @BitTypeYes THEN
								CASE WHEN dw.SourceType = @SourceTypeGeneratedByMe THEN @SourceTypeGeneratedByMe | @SourceTypeAssignedForTransportation
										WHEN dw.SourceType = @SourceTypeGeneratedAgainstMe THEN @SourceTypeGeneratedAgainstMe | @SourceTypeAssignedForTransportation
								ELSE dw.SourceType END
							END
						ELSE
							dw.SourceType
						END)
	FROM
		einvoice.DocumentDW dw
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = dw.Id;

	UPDATE
		ds
	SET
		ds.TransporterUpdatedDate = (CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated THEN teid.UpdatedDate ELSE ds.TransportDateTime END ),
	    ds.PushStatus = teid.PushStatus,
		ds.Errors = teid.Errors,
		ds.ModifiedStamp = GETDATE(),
		ds.[Status] = (CASE WHEN teid.IsSourceTypeAssignedForTransportation = @BitTypeYes THEN @DocumentStatusCompleted ELSE ds.[Status] END),
		ds.PushByUserId = @UserId,
		ds.IsPushed = CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.IsPushed ELSE ds.IsPushed END,
		ds.PushDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusTransporterUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.UpdatedDate ELSE ds.PushDate END
	FROM
		ewaybill.DocumentStatus ds
		INNER JOIN #TempEwayBillStatusDetails teid ON teid.Id = ds.DocumentId;		
	
	DROP TABLE 	#TempEwayBillStatusDetails;

END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:   [subscriber].[UpdateDownloadResponseForVendors]
* 	Comments			:   29-04-2020 | Amit Khanna | This procedure used to update vendor details.
						:	17-06-2020 | Amit Khanna | Added TaxPayerType and TaxPayerStatus Parameters.
						:	02-06-2021 | Chandresh Prajapati | Added LastChangeDate as NULL, LastChangeType AS NULL
						:   22-07-2021 | Abbas Pisawadwala | Renamed sp from UpdateVerifiedVendorResponseForVendors to UpdateDownloadResponseForVendors
						:	13-01-2023 | Chandresh Prajapati | Removed LastChangeDate and lastChangeType from update query
						:	19-01-2023 | Chandresh Prajapati | Added SkipError paramter to handle error with update case
						:   27-03-2023 | Bhavik Patel | Return all updated data old values
						:   02-05-2024 | Chandresh Prajapati	| Added AuditTrailDetails Parameter
						:   02-05-2024 | Chandresh Prajapati | Added CancellationDate
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		:	DECLARE @Responses [subscriber].[UpdateDownloadResponseForVendor]
							INSERT INTO @Responses VALUES(1,'Abc Infotech','Abc Infotech','Addressline1', 'AddressLine2','33','Ahd',800663,1,1,1,NULL)
							
							EXEC [subscriber].[UpdateDownloadResponseForVendors]
									@UserId =646,
									@Responses = @Responses,
									@VendorVerificationStatusYetNotVerified = 1,
									@VendorVerificationStatusInProgress = 2,
									@VendorVerificationStatusVerified = 3,
									@AuditTrailDetails = @AuditTrailDetails;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [subscriber].[UpdateDownloadResponseForVendors]
(
	@UserId INT,
	@Responses [subscriber].[UpdateDownloadResponseForVendor] READONLY,
	@SearchVendor bit,
	@VendorVerificationStatusYetNotVerified smallint,
	@VendorVerificationStatusInProgress smallint,
	@VendorVerificationStatusVerified smallint,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	DECLARE  @True bit = 1, @False bit = 0;
	SELECT
		*
	INTO
		#TempResponses
	FROM
		@Responses;

	SET NOCOUNT ON;

	CREATE TABLE #TempVendorDetails
	(
		Gstin VARCHAR(15),
		TradeName VARCHAR(110),
		Code VARCHAR(40)
	);
		
	IF(@SearchVendor = 1)
	BEGIN
		UPDATE
		vs
		SET
			vs.LegalName = ISNULL(tr.LegalName, vs.LegalName),
			vs.TradeName = ISNULL(tr.TradeName, vs.TradeName),
			vs.AddressLine1 = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.AddressLine1 ELSE vs.AddressLine1 END,
			vs.AddressLine2 = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.AddressLine2 ELSE vs.AddressLine2 END,
			vs.StateCode = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.StateCode ELSE vs.StateCode END,
			vs.City = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.City ELSE vs.City END,
			vs.Pincode = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.Pincode ELSE vs.Pincode END,
			vs.TaxpayerType = ISNULL(tr.TaxPayerType, vs.TaxPayerType),
			vs.TaxpayerStatus = ISNULL(tr.TaxPayerStatus, vs.TaxPayerStatus),
			vs.VerificationStatus = CASE 
									   WHEN tr.VerificationStatus = @VendorVerificationStatusInProgress THEN
											CASE 
												WHEN vs.VerifiedDate IS NULL THEN @VendorVerificationStatusYetNotVerified
												ELSE @VendorVerificationStatusVerified
											END
										ELSE
											tr.VerificationStatus
										END,
			vs.VerifiedDate = GETDATE(),
			vs.UserId = @UserId,
			vs.ModifiedStamp = GETDATE(),
			vs.Errors = tr.Errors,
			vs.EinvoiceEnablementStatus = ISNULL(tr.EinvoiceEnablementStatus,vs.EinvoiceEnablementStatus),
			vs.CancellationDate  = ISNULL(tr.CancellationDate,vs.CancellationDate)
		OUTPUT 
			DELETED.Gstin,
			DELETED.TradeName,
			DELETED.Code
		INTO #TempVendorDetails(Gstin, TradeName, Code)
		FROM
			[subscriber].Vendors AS vs
			INNER JOIN #TempResponses tr ON vs.Id = tr.Id
		where
			tr.SkipError = @True;
	
		UPDATE
			vs
		SET
			vs.LegalName = ISNULL(tr.LegalName, vs.LegalName),
			vs.TradeName = ISNULL(tr.TradeName, vs.TradeName),
			vs.AddressLine1 = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.AddressLine1 ELSE vs.AddressLine1 END,
			vs.AddressLine2 = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.AddressLine2 ELSE vs.AddressLine2 END,
			vs.StateCode =CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.StateCode ELSE vs.StateCode END,
			vs.City = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.City ELSE vs.City END,
			vs.Pincode = CASE WHEN vs.UsePrincipalAddress = @True OR (tr.UpdateAdditionalAddress = @True and vs.UseAdditionalAddress = @True) THEN tr.Pincode ELSE vs.Pincode END,
			vs.TaxpayerType = ISNULL(tr.TaxPayerType, vs.TaxPayerType),
			vs.TaxpayerStatus = ISNULL(tr.TaxPayerStatus, vs.TaxPayerStatus),
			vs.VerificationStatus = CASE 
									   WHEN tr.VerificationStatus = @VendorVerificationStatusInProgress THEN
											CASE 
												WHEN vs.VerifiedDate IS NULL THEN @VendorVerificationStatusYetNotVerified
												ELSE @VendorVerificationStatusVerified
											END
										ELSE
											tr.VerificationStatus
										END,
			vs.VerifiedDate = GETDATE(),
			vs.UserId = @UserId,
			vs.ModifiedStamp = GETDATE(),
			vs.Errors = tr.Errors,
			vs.EinvoiceEnablementStatus = ISNULL(tr.EinvoiceEnablementStatus,vs.EinvoiceEnablementStatus),
			vs.CancellationDate  = ISNULL(tr.CancellationDate,vs.CancellationDate)
		OUTPUT 
			DELETED.Gstin,
			DELETED.TradeName,
			DELETED.Code
		INTO #TempVendorDetails(Gstin, TradeName, Code)
		FROM
			[subscriber].Vendors AS vs
			INNER JOIN #TempResponses tr ON vs.Id = tr.Id
		WHERE 
			tr.Errors IS NULL
			AND tr.SkipError = @False;

		UPDATE
			vs
		SET
			vs.VerificationStatus = CASE 
									WHEN tr.VerificationStatus = @VendorVerificationStatusInProgress THEN
										CASE 
											WHEN vs.VerifiedDate IS NULL THEN @VendorVerificationStatusYetNotVerified
											ELSE @VendorVerificationStatusVerified
										END
									ELSE
										tr.VerificationStatus
									END,
			vs.UserId = @UserId,
			vs.ModifiedStamp = GETDATE(),
			vs.Errors = tr.Errors
		FROM
			[subscriber].Vendors AS vs
			INNER JOIN #TempResponses tr ON vs.Id = tr.Id
		WHERE
			tr.Errors IS NOT NULL
			AND tr.SkipError = @False;
	END
	ELSE
	BEGIN
		UPDATE
			vs
		SET
			vs.VerificationStatus = CASE 
									WHEN tr.VerificationStatus = @VendorVerificationStatusInProgress THEN
										CASE 
											WHEN vs.VerifiedDate IS NULL THEN @VendorVerificationStatusYetNotVerified
											ELSE @VendorVerificationStatusVerified
										END
									ELSE
										tr.VerificationStatus
									END
		FROM
			[subscriber].Vendors AS vs
			INNER JOIN #TempResponses tr ON vs.Id = tr.Id
	END

	SELECT
		* 
	FROM 
		#TempVendorDetails;

	DROP TABLE #TempResponses, #TempVendorDetails;
END
GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [ewaybill].[UpdatePushResponseForVehicleDetailUpdation] 	 	 
* 	Comments			: 12-05-2020 | Amit Khanna | This procedure is used to update Eway bill Vehicle Details.
						:  18-06-2020 | Prakash Parmar | Added BackgroundTaskId
						: 20-07-2020 | Pooja Rajpurohit | Changes for optimzation - Added update Portion for DocumentWh table and EwbDocumentDW table
						: 28-07-2020 | Pooja Rajpurohit | Renamed table from EWBDocumentWH to DocumentDW
						: 31-08-2020 | Chandresh Prajapati | Updated PushDate on success of Vehicle Detail Updation
						: 10-09-2020 | Prakash Parmar | Changes In PushStatus
						: 11-09-2020 | Prakash Parmar | Added UpdatedByGstin
						: 08-12-2021 | Prakash Parmar | Added GenerationModeApi Parameter			
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE @PushResponseType [ewaybill].[PushResponseType];

						  INSERT INTO @PushResponseType
						  (
							[Id],
							[EWayBillNumber],
							[UpdatedDate],
							[ValidUpto],
							[GroupNumber],
							[PushStatus],
							[IsPushed],
							[Errors]
						  ) 
						  VALUES 
						  (
							14489,
							'123456789012',
							'01-09-2018',
							NULL,
							NULL,
							2,
							1,
							''
						  );

						  EXEC [ewaybill].[UpdatePushResponseForVehicleDetailUpdation]
							@PushResponse = @PushResponseType,
							@UserId = 486,
							@TransportMode  = 1,
							@FromCity = 'Ahmedabad',
							@FromState = 33,
							@Reason  = 2,
							@Remarks = NULL,
							@TransportDocumentNumber = NULL,
							@TransportDocumentDate = NULL,
							@VehicleNumber   = 'GJ021245',
							@VehicleType  = 1,
							@BackgroundTaskId = 524,
							@UpdatedByGstin = '28ADDABCDE54875',
							@EwayBillPushStatusVehicleDetailsUpdated = 6,
							@BitTypeYes = 1,
							@BitTypeNo = 0,
							@GenerationModeApi = 1;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ewaybill].[UpdatePushResponseForVehicleDetailUpdation]
(
	@PushResponse [ewaybill].[PushResponseType] READONLY,
	@UserId INT,
	@TransportMode SMALLINT,
	@FromCity VARCHAR(110),
	@FromState SMALLINT,
	@Reason SMALLINT,
	@Remarks VARCHAR(50),
	@TransportDocumentNumber VARCHAR(15),
	@TransportDocumentDate SMALLDATETIME,
	@VehicleNumber VARCHAR(20),
	@VehicleType SMALLINT,
	@BackgroundTaskId BIGINT,
	@UpdatedByGstin VARCHAR(15),
	@EwayBillPushStatusVehicleDetailsUpdated INT,
	@BitTypeYes SMALLINT,
	@BitTypeNo SMALLINT,
	@GenerationModeApi SMALLINT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	
		pr.Id,
		pr.EWayBillNumber,
		pr.UpdatedDate,
		pr.ValidUpto,
		pr.PushStatus,
		pr.IsPushed,
		pr.Errors
	INTO
		#TempEwayBillStatusDetails
	FROM
		@PushResponse AS pr;

	CREATE CLUSTERED INDEX IDX_#TempEwayBillStatusDetails ON #TempEwayBillStatusDetails (ID)			

	UPDATE
		ewds
	SET
		ewds.ValidUpto = CASE WHEN teid.PushStatus = @EwayBillPushStatusVehicleDetailsUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.ValidUpto ELSE ewds.ValidUpto END,
		ewds.PushByUserId = @UserId,
		ewds.IsPushed = CASE WHEN teid.PushStatus = @EwayBillPushStatusVehicleDetailsUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.IsPushed ELSE ewds.IsPushed END,
		ewds.PushDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusVehicleDetailsUpdated AND teid.UpdatedDate IS NOT NULL THEN teid.UpdatedDate ELSE ewds.PushDate END,
		ewds.Errors = teid.Errors,
		ewds.ModifiedStamp = GETDATE(),
		ewds.PushStatus = teid.PushStatus,
		ewds.GeneratedDate = CASE WHEN teid.PushStatus = @EwayBillPushStatusVehicleDetailsUpdated AND teid.UpdatedDate IS NOT NULL AND ewds.ValidUpto IS NULL THEN teid.UpdatedDate ELSE ewds.GeneratedDate END
	FROM
		ewaybill.DocumentStatus AS ewds
		INNER JOIN #TempEwayBillStatusDetails teid ON ewds.DocumentId = teid.Id;
		
	UPDATE 
		evd
	SET
		evd.IsLatest = CASE WHEN ewbs.UpdatedDate IS NOT NULL THEN  @BitTypeNo  ELSE evd.IsLatest END
	FROM 
		ewaybill.VehicleDetails AS evd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate))
		INNER JOIN #TempEwayBillStatusDetails ewbs ON evd.DocumentId = ewbs.Id
	WHERE
		evd.IsLatest = @BitTypeYes;

	DELETE
		evd
	FROM 
		ewaybill.VehicleDetails AS evd WITH(INDEX(NON_IDX_ewaybill_VehicleDetails_DocumentId_IsLatest_PushDate))
		INNER JOIN #TempEwayBillStatusDetails AS ewbs ON evd.DocumentId = ewbs.Id
	WHERE  
		evd.IsLatest = @BitTypeNo
		AND evd.PushDate IS NULL;

	INSERT INTO ewaybill.VehicleDetails
	(
		DocumentId,
		TransportMode,
		TransportDocumentNumber,
		TransportDocumentDate,
		VehicleNumber,
		FromState,
		FromCity,
		Reason,
		Remarks,
		[Type],
		IsLatest,
		PushDate,
		PushStatus,
		Errors,
		BackgroundTaskId,
		UpdatedByGstin,
		UpdationMode
	)
	SELECT
		ewbs.Id,
		@TransportMode,
		@TransportDocumentNumber,
		@TransportDocumentDate,
		@VehicleNumber,
		@FromState,
		@FromCity,
		@Reason,
		@Remarks,
		@VehicleType,
		CASE WHEN ewbs.UpdatedDate IS NOT NULL THEN @BitTypeYes ELSE @BitTypeNo END,
		ewbs.UpdatedDate,
		@EwayBillPushStatusVehicleDetailsUpdated,
		ewbs.Errors,
		@BackgroundTaskId,
		@UpdatedByGstin,
		CASE WHEN ewbs.UpdatedDate IS NOT NULL THEN @GenerationModeApi ELSE NULL END
	FROM
		#TempEwayBillStatusDetails ewbs;

	DROP TABLE #TempEwayBillStatusDetails;
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[ApplyReconciliationAction] 
* 	Comments			: 10-12-2019 | Udit Solanki | This procedure is used to perform action for given mapperIDs or filters.
						  20-07-2020 | Sagar Patel | Added IsErrorRecordsOnly parameter	
						  21-07-2020 | Sagar Patel | CGSP2-1380: Added new parameters
						  12-11-2020 | Sagar Patel | CGSP2-2051: Implemented PAN based search. 
						  18-11-2020 | Sagar Patel | CGSP2-1719: Icegate reconciliation
						  14-06-2021 | Sagar Patel | CGSP2-3097: Added Exclude Pan Filter
						  28-06-2021 | Sagar Patel | CGSP2-3146: Added Filing Status, Reverse charge Filter
						  02-07-2021 | Sagar Patel | CGSP2-3146: Added Notification closed status Filter
						  06-07-2021 | Sagar Patel | CGSP2-3186: Added IsGstr3bFiled Filter
						  28-07-2021 | Sagar Patel | CGSP2-3304: Added ItcClaimReturnPeriod Filter
						  08-02-2022 | Krishna Shah | CGSP2-3675: Added IsTradeNamesLikeSearch Filter
						  23-03-2022 | Hiren Suthar | CGSP2-3799: Added Remarks Value
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
DECLARE  @TotalRecord INT,
	@EntityIds AS [common].[IntType],
	@SelectedEntityIds AS oregular.[EntityIdGstinType],
	@Ids AS [common].[BigIntType],
	@AuditTrailDetails AS [audit].[AuditTrailDetailsType],
	@MapperIds AS [oregular].[ReconciliationBulkActionType];

	INSERT INTO @EntityIds VALUES(341);

EXEC [oregular].[ApplyReconciliationAction]
	@SubscriberId = 3, 
	@DocFinancialYear = 20232024, 
	@FromPrReturnPeriod = null, 
	@ToPrReturnPeriod = null, 
	@FromGstnReturnPeriod = null, 
	@ToGstnReturnPeriod = null, 
	@SelectedEntityIds = @SelectedEntityIds,
	@EntityIds = @EntityIds,
	@MapperIds = @MapperIds,
	@Ids = @Ids,
	@Remarks = null, 
	@DocumentNumbers = null, 
	@IsDocNumberLikeSearch = 0, 
	@Gstins = null, 
	@Pans = null, 
	@ExcludePans = null, 
	@TradeNames = null, 
	@IsTradeNamesLikeSearch = 0, 
	@DocumentTypes = null, 
	@TransactionTypes = null, 
	@ReconciliationSections = null, 
	@Actions = null, 
	@ActionStatus = null, 
	@PaymentStatus = null, 
	@Custom = null, 
	@ReasonType = null, 
	@IsExactMatchReason = null, 
	@ItcEligibility = null, 
	@ValueDiffFrom = null, 
	@ValueDiffTo = null, 
	@TaxableDiffFrom = null, 
	@TaxableDiffTo = null, 
	@TaxDiffFrom = null, 
	@TaxDiffTo = null, 
	@DaysDiffFrom = null, 
	@DaysDiffTo = null, 
	@IsErrorRecordsOnly = null, 
	@FromReconciliationDate = null, 
	@ToReconciliationDate = null, 
	@PortCode = null, 
	@FromDocumentDate = null, 
	@ToDocumentDate = null, 
	@FromStamp = null, 
	@ToStamp = null, 
	@FromActionsDate = null, 
	@ToActionsDate = null, 
	@IsCrossHeadTaxData = null, 
	@TaxPayerType = null, 
	@ReconciliationType = 2, 
	@IsAvailableInGstr2b = null, 
	@IsShowClaimedItcRecords = null, 
	@IsAvailableInGstr98a = null, 
	@Gstr98aFinancialYear = null, 
	@ItcAvailability = null, 
	@ItcUnavailabilityReason = null, 
	@AmendmentType = null, 
	@SourceType = null, 
	@IsReverseCharge = null, 
	@IsGstr3bFiled = null, 
	@ItcClaimReturnPeriod = null, 
	@ReconciledBy = null, 
	@Remark = null, 
	@IsNotificationSentReceived = 0, 
	@IsNotificationStatusClosed = 0, 
	@IsNotificationSentButNoReply = 0, 
	@ActionTypeNoAction = null, 
	@AmendedType = null, 
	@SuggReconciliationSection = 0, 
	@EInvoiceEnablement = null, 
	@GstActOrRuleSection = null, 
	@CpFilingPreference = null, 
	@Gstr3bSection = null, 
	@Gstr2bReturnPeriod = null, 
	@IsShowInterCompanyTransfer = null, 
	@AuditTrailDetails = @AuditTrailDetails,
	@TransactionNature = 0,  
	@SourceTypeCounterPartyNotFiled = 1, 
	@ReconciliationSectionTypePrOnly = 2, 
	@ReconciliationSectionTypeGstOnly = 3, 
	@ReconciliationSectionTypeMatched = 4, 
	@ReconciliationSectionTypeMatchedDueToTolerance = 1, 
	@ReconciliationSectionTypeMisMatched = 2, 
	@ReconciliationSectionTypeNearMatched = 3, 
	@ReconciliationSectionTypeGstDiscarded = 4, 
	@ReconciliationSectionTypeGstExcluded = 5, 
	@ReconciliationSectionTypePrDiscarded = 6, 
	@ReconciliationSectionTypePrExcluded = 7, 
	@ReconciliationSectionTypePrOnlyItcDelayed = 8, 
	@ItcEligibilityNone = 9, 
	@ReconciliationTypeGstr2b = 2, 
	@ReconciliationTypeIcegate = 1, 
	@AmendmentTypeOriginal = 2, 
	@AmendmentTypeAmendment = 4, 
	@AmendmentTypeOriginalAmended = 3, 
	@ModuleTypeOregularPurchase = 1, 
	@DocumentTypeINV = 1, 
	@DocumentTypeCRN = 2, 
	@DocumentTypeDBN = 3, 
	@DocumentTypeBOE = 4;
SELECT @TotalRecord;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[ApplyReconciliationAction](
	@SubscriberId integer,
	@DocFinancialYear integer,
	@FromPrReturnPeriod integer,
	@ToPrReturnPeriod integer,
	@FromGstnReturnPeriod integer,
	@ToGstnReturnPeriod integer,
	@SelectedEntityIds AS oregular.EntityIdGstinType READONLY,
	@EntityIds AS [common].[IntType] READONLY,
	@MapperIds AS oregular.ReconciliationBulkActionType READONLY,
	@Ids AS [common].[BigIntType] READONLY,
	@Remarks VARCHAR(MAX),
	@DocumentNumbers VARCHAR(MAX),
	@IsDocNumberLikeSearch bit,
	@Gstins VARCHAR(MAX),
	@Pans VARCHAR(MAX),
	@ExcludePans VARCHAR(MAX),
	@TradeNames VARCHAR(MAX),
	@IsTradeNamesLikeSearch bit,
	@DocumentTypes VARCHAR(MAX),
	@TransactionTypes VARCHAR(MAX),
	@ReconciliationSections VARCHAR(MAX),
	@Actions VARCHAR(MAX),
	@ActionStatus smallint,
	@PaymentStatus VARCHAR(MAX),
	@Custom VARCHAR(MAX),
	@ReasonType bigint,
	@IsExactMatchReason bit,
	@ItcEligibility VARCHAR(MAX),
	@ValueDiffFrom numeric,
	@ValueDiffTo numeric,
	@TaxableDiffFrom numeric,
	@TaxableDiffTo numeric,
	@TaxDiffFrom numeric,
	@TaxDiffTo numeric,
	@DaysDiffFrom integer,
	@DaysDiffTo integer,
	@IsErrorRecordsOnly bit,
	@FromReconciliationDate DATETIME,
	@ToReconciliationDate DATETIME,
	@PortCode character varying,
	@FromDocumentDate DATETIME,
	@ToDocumentDate DATETIME,
	@FromStamp DATETIME,
	@ToStamp DATETIME,
	@FromActionsDate DATETIME,
	@ToActionsDate DATETIME,
	@IsCrossHeadTaxData bit,
	@TaxPayerType character varying,
	@ReconciliationType smallint,
	@IsAvailableInGstr2b bit,
	@IsShowClaimedItcRecords bit,
	@IsAvailableInGstr98a bit,
	@Gstr98aFinancialYear integer,
	@ItcAvailability smallint,
	@ItcUnavailabilityReason smallint,
	@AmendmentType smallint,
	@SourceType smallint,
	@IsReverseCharge bit,
	@IsGstr3bFiled bit,
	@ItcClaimReturnPeriod integer,
	@ReconciledBy smallint,
	@Remark character varying,
	@IsNotificationSentReceived bit,
	@IsNotificationStatusClosed bit,
	@IsNotificationSentButNoReply bit,
	@ActionTypeNoAction smallint,
	@AmendedType integer,
	@SuggReconciliationSection VARCHAR(MAX),
	@EInvoiceEnablement smallint,
	@GstActOrRuleSection smallint,
	@CpFilingPreference smallint,
	@Gstr3bSection VARCHAR(MAX),
	@Gstr2bReturnPeriod integer,
	@IsShowInterCompanyTransfer bit,
	@AuditTrailDetails AS [audit].[AuditTrailDetailsType] READONLY,
	@TransactionNature smallint = NULL,
	@TotalRecord INT = NULL OUTPUT,
	@SourceTypeCounterPartyNotFiled SMALLINT,
	@ReconciliationSectionTypePrOnly SMALLINT,
	@ReconciliationSectionTypeGstOnly SMALLINT,
	@ReconciliationSectionTypeMatched SMALLINT,
	@ReconciliationSectionTypeMatchedDueToTolerance SMALLINT,
	@ReconciliationSectionTypeMisMatched SMALLINT,
	@ReconciliationSectionTypeNearMatched SMALLINT,
	@ReconciliationSectionTypeGstDiscarded SMALLINT,
	@ReconciliationSectionTypeGstExcluded SMALLINT,
	@ReconciliationSectionTypePrDiscarded SMALLINT,
	@ReconciliationSectionTypePrExcluded SMALLINT,
	@ReconciliationSectionTypePrOnlyItcDelayed SMALLINT,
	@ItcEligibilityNone SMALLINT,
	@ReconciliationTypeGstr2b SMALLINT,
	@ReconciliationTypeIcegate SMALLINT,
	@AmendmentTypeOriginal SMALLINT,
	@AmendmentTypeAmendment SMALLINT,
	@AmendmentTypeOriginalAmended SMALLINT,
	@ModuleTypeOregularPurchase SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeBOE SMALLINT,
	@TaxpayerStatus varchar(max),
	@IsBlacklistedVendor bit,
	@GrcScoreFrom smallint,
	@GrcScoreTo smallint,
	@ReversalReclaim int)

AS 
BEGIN
	
	DECLARE @ReconciliationSectionTypeManualMap SMALLINT = -1;


	IF EXISTS(SELECT 1 FROM @AuditTrailDetails) 
	BEGIN
		EXEC [audit].[UpdateAuditDetails] @AuditTrailDetails;
	END;

	/* Drop temp tables */
	DROP TABLE IF EXISTS #TempFilterId,#TempSelectedIds;	
	CREATE  TABLE #TempFilterId (
		Id INT IDENTITY(1,1), 
		PurchaseDocumentMapperId BIGINT,
		SectionType SMALLINT,
		PrId BIGINT,
		GstnId BIGINT
	);

	/* Temp table to store PurchaseDocumentMapperId */
	CREATE TABLE #TempSelectedIds (
		PurchaseDocumentMapperId BIGINT NOT NULL
	);
	/* Create  index on PurchaseDocumentMapperId for faster retrieval */
	CREATE CLUSTERED INDEX Idx_SelectedIds_PurchaseDocumentMapperId ON #TempSelectedIds(PurchaseDocumentMapperId);

	/* Temp table to store PR/GSTN Id and actions to be taken against them */
	DROP TABLE IF EXISTS #TempActionId,#TempIntialReconciliationBulkActionType,#TempIdsForActionRevert,#TempReconciliationBulkActionType;
	CREATE  TABLE #TempActionId (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		PurchaseDocumentRecoId BIGINT,		
		Action SMALLINT,
		ReconciliationStatus SMALLINT
	);
	
	/* Insert what is directly coming from table type */
	CREATE  TABLE #TempIntialReconciliationBulkActionType (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		PurchaseDocumentMapperId INT,
		ReconciliationSection SMALLINT NULL,
		Action SMALLINT NULL
	);

	/* Ids to revert actions */
	CREATE  TABLE #TempIdsForActionRevert (
		Id BIGINT NOT NULL
	);

	INSERT INTO #TempSelectedIds
	(
		PurchaseDocumentMapperId
	)
	SELECT
		*
	FROM
		@Ids;

	INSERT INTO #TempIntialReconciliationBulkActionType(
		PurchaseDocumentMapperId,
		ReconciliationSection,
		Action
	)
	SELECT
		PurchaseDocumentMapperId,
		ReconciliationSection,
		Action
	FROM @MapperIds;

	/* Insert on the basis if its single/bulk action or call is coming from UI/Enriched API */
	CREATE  TABLE #TempReconciliationBulkActionType (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		PurchaseDocumentMapperId INT,
		PrId BIGINT,
		GstnId BIGINT,
		ReconciliationSection SMALLINT NULL,
		Action SMALLINT NULL
	);

	/* Give priority to checked invoices */
	IF EXISTS (SELECT 1 FROM #TempIntialReconciliationBulkActionType WHERE PurchaseDocumentMapperId IS NOT NULL) AND NOT EXISTS(SELECT 1 FROM #TempSelectedIds)
	BEGIN
		INSERT INTO #TempReconciliationBulkActionType(
				PurchaseDocumentMapperId,
				PrId,
				GstnId,
				ReconciliationSection,
				Action
			)
			SELECT
				IRBA.PurchaseDocumentMapperId,
				PDRM.PrId,
				PDRM.GstnId,
				PDRM.SectionType,
				IRBA.Action
			FROM 
				#TempIntialReconciliationBulkActionType IRBA
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON IRBA.PurchaseDocumentMapperId = PDRM.Id	;	
	END
	ELSE IF EXISTS (SELECT 1 FROM #TempIntialReconciliationBulkActionType WHERE PurchaseDocumentMapperId IS NULL) AND EXISTS(SELECT 1 FROM #TempSelectedIds)
	BEGIN
		INSERT INTO #TempReconciliationBulkActionType(
			PurchaseDocumentMapperId,
			PrId,
			GstnId,
			ReconciliationSection,
			Action
		)
		SELECT
			SIds.PurchaseDocumentMapperId,
			PDRM.PrId,
			PDRM.GstnId,
			PDRM.SectionType,
			IRBA.Action
		FROM 
			#TempSelectedIds SIds
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON SIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN #TempIntialReconciliationBulkActionType IRBA ON IRBA.ReconciliationSection = PDRM.SectionType;
	END
	ELSE
	BEGIN
		/* Get Incorrect location data between selected and rest of the locations */
		INSERT INTO #TempFilterId (
			PurchaseDocumentMapperId,PrId,GstnId,SectionType
		)
		EXEC oregular.[FilterReconciliationData]
			@SubscriberId = @SubscriberId,
			@EntityIds = @EntityIds,
			@SelectedEntityIds = @SelectedEntityIds,
			@DocFinancialYear = @DocFinancialYear,
			@FromPrReturnPeriod = @FromPrReturnPeriod,
			@ToPrReturnPeriod = @ToPrReturnPeriod,
			@FromGstnReturnPeriod = @FromGstnReturnPeriod,
			@ToGstnReturnPeriod = @ToGstnReturnPeriod,
			@DocumentNumbers = @DocumentNumbers,
			@Gstins = @Gstins,
			@PortCode = @PortCode,
			@Pans = @Pans,
			@ExcludePans = @ExcludePans,
			@TradeNames = @TradeNames,
			@DocumentTypes = @DocumentTypes,
			@TransactionTypes = @TransactionTypes,
			@TaxPayerType = @TaxPayerType,
			@ReconciliationSections = @ReconciliationSections,
			@Gstr2bReturnPeriod = @Gstr2bReturnPeriod,
			@Actions = @Actions,
			@ActionStatus = @ActionStatus,
			@PaymentStatus = @PaymentStatus,
			@Custom = @Custom,
			@ReasonType = @ReasonType,
			@IsExactMatchReason = @IsExactMatchReason,
			@ItcEligibility = @ItcEligibility,
			@ValueDiffFrom = @ValueDiffFrom,
			@ValueDiffTo = @ValueDiffTo,
			@TaxableDiffFrom = @TaxableDiffFrom,
			@TaxableDiffTo = @TaxableDiffTo,
			@TaxDiffFrom = @TaxDiffFrom,
			@TaxDiffTo = @TaxDiffTo,
			@DaysDiffFrom = @DaysDiffFrom,
			@DaysDiffTo = @DaysDiffTo,
			@FromDocumentDate = @FromDocumentDate,
			@ToDocumentDate = @ToDocumentDate,
			@FromStamp = @FromStamp,
			@ToStamp = @FromStamp,
			@FromReconciliationDate = @FromReconciliationDate,
			@ToReconciliationDate = @ToReconciliationDate,
			@FromActionsDate = @FromActionsDate,
			@ToActionsDate = @ToActionsDate,
			@IsShowInterCompanyTransfer = @IsShowInterCompanyTransfer,
			@IsCrossHeadTaxData = @IsCrossHeadTaxData ,
			@IsErrorRecordsOnly = @IsErrorRecordsOnly ,
			@ReconciliationType = @ReconciliationType,
			@IsAvailableInGstr2b = @IsAvailableInGstr2b,
			@IsShowClaimedItcRecords = @IsShowClaimedItcRecords,
			@ItcAvailability = @ItcAvailability,
			@ItcUnavailabilityReason = @ItcUnavailabilityReason,
			@AmendmentType = @AmendmentType,
			@IsAvailableInGstr98a = @IsAvailableInGstr98a,
			@Gstr98aFinancialYear = @Gstr98aFinancialYear,
			@SourceType = @SourceType,
			@IsReverseCharge = @IsReverseCharge,
			@IsNotificationSentReceived = @IsNotificationSentReceived,
			@IsNotificationStatusClosed = @IsNotificationStatusClosed,
			@IsGstr3bFiled = @IsGstr3bFiled,
			@ItcClaimReturnPeriod = @ItcClaimReturnPeriod,
			@ReconciledBy = @ReconciledBy,
			@AmendedType = @AmendedType,
			@IsNotificationSentButNoReply = @IsNotificationSentButNoReply,
			@Remark = @Remark,
			@GetAllData = 1,
			@IsDocNumberLikeSearch = @IsDocNumberLikeSearch,
			@IsTradeNamesLikeSearch = @IsTradeNamesLikeSearch,
			@EInvoiceEnablement = @EInvoiceEnablement,
			@GstActOrRuleSection = @GstActOrRuleSection,
			@CpFilingPreference = @CpFilingPreference,
			@Gstr3bSection = @Gstr3bSection,
			@SuggReconciliationSection = @SuggReconciliationSection,
			@IsDsu = 0,
			@Start = NULL,
			@Size = NULL,
			@TransactionNature = @TransactionNature,
			@TotalRecord = @TotalRecord OUTPUT,
			@SourceTypeCounterPartyNotFiled = @SourceTypeCounterPartyNotFiled,
			@ReconciliationSectionTypePrOnly = @ReconciliationSectionTypePrOnly,
			@ReconciliationSectionTypeGstOnly = @ReconciliationSectionTypeGstOnly,
			@ReconciliationSectionTypeMatched = @ReconciliationSectionTypeMatched,
			@ReconciliationSectionTypeMatchedDueToTolerance = @ReconciliationSectionTypeMatchedDueToTolerance,
			@ReconciliationSectionTypeMisMatched = @ReconciliationSectionTypeMisMatched,
			@ReconciliationSectionTypeNearMatched = @ReconciliationSectionTypeNearMatched,
			@ReconciliationSectionTypeGstDiscarded = @ReconciliationSectionTypeGstDiscarded,
			@ReconciliationSectionTypeGstExcluded = @ReconciliationSectionTypeGstExcluded,
			@ReconciliationSectionTypePrDiscarded = @ReconciliationSectionTypePrDiscarded,
			@ReconciliationSectionTypePrExcluded = @ReconciliationSectionTypePrExcluded,
			@ReconciliationSectionTypePrOnlyItcDelayed = @ReconciliationSectionTypePrOnlyItcDelayed,
			@ItcEligibilityNone = @ItcEligibilityNone,
			@ReconciliationTypeGstr2b = @ReconciliationTypeGstr2b,
			@ReconciliationTypeIcegate = @ReconciliationTypeIcegate,
			@AmendmentTypeOriginal = @AmendmentTypeOriginal,
			@AmendmentTypeAmendment = @AmendmentTypeAmendment,
			@AmendmentTypeOriginalAmended = @AmendmentTypeOriginalAmended,
			@ModuleTypeOregularPurchase = @ModuleTypeOregularPurchase,
			@DocumentTypeINV = @DocumentTypeINV,
			@DocumentTypeCRN = @DocumentTypeCRN,
			@DocumentTypeDBN = @DocumentTypeDBN,
			@DocumentTypeBOE = @DocumentTypeBOE,
			@TaxpayerStatus = @TaxpayerStatus,
			@IsBlacklistedVendor = @IsBlacklistedVendor,
			@GrcScoreFrom = @GrcScoreFrom,
			@GrcScoreTo = @GrcScoreTo,
			@ReversalReclaim = @ReversalReclaim;	


		INSERT INTO #TempReconciliationBulkActionType(
			PurchaseDocumentMapperId,
			PrId,
			GstnId,
			ReconciliationSection,
			Action
		)
		SELECT
			FI.PurchaseDocumentMapperId,
			FI.PrId,
			FI.GstnId,
			IRBA.ReconciliationSection,
			IRBA.Action
		FROM #TempFilterId FI			
			INNER JOIN #TempIntialReconciliationBulkActionType IRBA ON FI.SectionType = IRBA.ReconciliationSection;
	END;	
	
	
	/* | --------------------------- Action ValIdations --------------------------- | */		
	INSERT INTO #TempActionId(
		PurchaseDocumentRecoId,
		Action
	)
	SELECT
		RBIA.PrId,		
		RBIA.Action		
	FROM 
		#TempReconciliationBulkActionType RBIA		
	WHERE PrId IS NOT NULL;
	
	INSERT INTO #TempActionId(
		PurchaseDocumentRecoId,
		Action
	)
	SELECT
		RBIA.GstnId,		
		RBIA.Action
	FROM 
		#TempReconciliationBulkActionType RBIA		
	WHERE GstnId IS NOT NULL;

/*
	INSERT INTO #TempActionId(
		PurchaseDocumentRecoId,
		Action
	)
	SELECT
		PDRM.PrId,	
		RBIA.Action
	FROM 
		#TempReconciliationBulkActionType RBIA
		INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON RBIA.GstnId = PDRM.GstnId
	WHERE
		PDRM.PrId IS NOT NULL AND
		NOT EXISTS (SELECT 1 FROM #TempActionId AI2 WHERE AI2.PurchaseDocumentRecoId = RBIA.PrId);

	INSERT INTO #TempActionId(
		PurchaseDocumentRecoId,
		Action
	)
	SELECT		
		PDRM.GstnId,
		RBIA.Action
	FROM 
		#TempReconciliationBulkActionType RBIA
		INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON RBIA.PrId = PDRM.PrId
	WHERE
		PDRM.GstnId IS NOT NULL AND
		NOT EXISTS (SELECT 1 FROM #TempActionId AI2 WHERE AI2.PurchaseDocumentRecoId = PDRM.GstnId);
*/
	/* | --------------------------- Revert Actions --------------------------- | */
	/*
	UPDATE
		ps
	SET
		ps.Gstr2bAction = @ReconciliationActionNoAction,
		ps.IsReconciledGstr2b = 0,
		ps.Remarks = CASE WHEN @Remarks IS NOT NULL THEN @Remarks ELSE PS.Remarks END
	FROM
		#TempActionId ifar 
		INNER JOIN oregular.PurchaseDocumentStatus ps ON ps.PurchaseDocumentId = ifar.PurchaseDocumentRecoId
	WHERE
		ps.Action <> @ReconciliationActionNoAction;
		
	*/
	
	SELECT 
	DISTINCT
		pdr.SubscriberId SubscriberId,
		pdr.ParentEntityId EntityId,
		CASE
			WHEN pdr.SourceType = 1 THEN pdr.FinancialYear 
			ELSE CASE WHEN CASE WHEN LEN(pds.Gstr2BReturnPeriod) = 6 THEN LEFT(pds.Gstr2BReturnPeriod,2) ELSE LEFT(pds.Gstr2BReturnPeriod,1) END > 3 THEN CONCAT(RIGHT(pds.Gstr2BReturnPeriod,4), RIGHT(pds.Gstr2BReturnPeriod,2)+1) ELSE CONCAT(RIGHT(pds.Gstr2BReturnPeriod,4)-1, RIGHT(pds.Gstr2BReturnPeriod,2)) END
		END AS FinancialYear
	FROM 
		#TempActionId ifar		
		INNER JOIN oregular.PurchaseDocuments pdr ON pdr.Id = ifar.PurchaseDocumentRecoId
		INNER JOIN oregular.PurchaseDocumentStatus pds ON pds.PurchaseDocumentId = pdr.Id
	WHERE ifar.Action = @ActionTypeNoAction;

	/* | --------------------------- Revert Actions --------------------------- | */	
	--IF EXISTS (SELECT 1 FROM @AuditTrailDetails) 
	--BEGIN
		UPDATE gdrm
		SET gdrm.ModifiedStamp = GETDATE(), gdrm.Stamp = GETDATE()
		FROM #TempReconciliationBulkActionType trba
			INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrm ON gdrm.Id = trba.PurchaseDocumentMapperId;
	--END;
	
	/* Update Action - CP */
	UPDATE
		PS
	SET
		PS.Gstr2bAction = AI.Action,		
		PS.IsReconciled = CASE WHEN AI.Action = @ActionTypeNoAction THEN 0 ELSE 1 END,
		PS.Gstr2bActionDate = GETDATE(),
		PS.Remarks = CASE WHEN @Remarks IS NOT NULL THEN @Remarks ELSE PS.Remarks END
	FROM
		#TempActionId AI
		INNER JOIN oregular.PurchaseDocumentStatus PS ON PS.PurchaseDocumentId = AI.PurchaseDocumentRecoId;

END;

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[ApplyReconciliationActionManual] 
* 	Comments			: 2020-08-11 | Shambhu Das | This procedure is used to perform action for given @ManualMapperId .
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
DECLARE  @TotalRecord INT,
		@EntityIds AS [common].[IntType],
		@Ids Common.BigIntType,
		@AuditTrailDetails AS audit.[AuditTrailDetailsType],
		@MapperIds AS oregular.[ApplyGstr2aManualReconciliationActionDataType];

INSERT INTO @EntityIds VALUES(340);
INSERT INTO @EntityIds VALUES(341);

EXEC [oregular].[ApplyReconciliationActionManual]
	@SubscriberId = 3,
	@EntityIds = @EntityIds,
	@DocFinancialYear = 20172018,
	@ReconciliationSections = NULL,
	@FromPrReturnPeriod = NULL,
	@ToPrReturnPeriod = NULL,
	@FromGstnReturnPeriod = NULL,
	@ToGstnReturnPeriod = NULL,	
	@RecordName = NULL,
	@DocumentNumbers = NULL,
	@Gstins = NULL,
	@Pans = NULL,
	@ExcludePans = NULL,
	@TradeNames = NULL,
	@DocumentTypes= NULL,
	@TransactionTypes= NULL,
	@TaxPayerType = NULL,
	@Actions = NULL,
	@PaymentStatus = NULL,
	@ActionStatus = NULL,
	@Custom = NULL,
	@ItcEligibility = NULL,	   
	@FromDocumentDate = NULL,
	@ToDocumentDate = NULL,
	@FromStamp = NULL,
	@ToStamp = NULL,	
	@FromActionsDate = NULL,
	@ToActionsDate = NULL,
	@ItcAvailability = NULL,
	@ItcUnavailabilityReason = NULL,
	@AmendmentType = NULL,
	@SourceType = NULL,
	@IsGstr3bFiled = NULL,
	@MapperIds = @MapperIds,
	@Ids = @Ids,
	@ManualMappingType = NULL,
	@IsAvailableInGstr2b = NULL,
	@IsReverseCharge = NULL,
	@IsShowClaimedItcRecords = NULL,
	@IsAvailableInGstr98a = NULL,
	@Gstr98aFinancialYear = NULL,
	@IsNotificationSentReceived = NULL,
	@IsNotificationStatusClosed = NULL,
	@ItcClaimReturnPeriod = NULL,
	@Gstr2bReturnPeriod = NULL,
	@Remarks = NULL,
	@IsDocNumberLikeSearch = 0,
	@IsTradeNamesLikeSearch = 0,
	@Remark = NULL,
	@ReconciliationType = NULL,
	@CpFilingPreference = NULL,
	@Gstr3bSection = NULL,
	@TransactionNature = NULL,
	@AuditTrailDetails = @AuditTrailDetails,
	/* Enums */
	@ItcEligibilityNone = 2,
	@AmendmentTypeOriginal = 1,
	@AmendmentTypeOriginalAmended = 2,
	@AmendmentTypeAmendment = 3,
	@ReconciliationTypeGstr2b = 2,
	@ModuleTypeOregularPurchase = 4

						SELECT @TotalRecord AS TotalRecord
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[ApplyReconciliationActionManual]
(
	@SubscriberId INT,
	@EntityIds AS [common].[IntType] READONLY,
	@DocFinancialYear INT,
	@ReconciliationSections VARCHAR(MAX),
	@FromPrReturnPeriod INT,
	@ToPrReturnPeriod INT,
	@FromGstnReturnPeriod INT,
	@ToGstnReturnPeriod INT,
	@RecordName AS VARCHAR(50),
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
	@ActionStatus VARCHAR(MAX),
	@Custom VARCHAR(2000),
	@ItcEligibility VARCHAR(20),
	@FromDocumentDate DATE,
	@ToDocumentDate DATE,
	@FromStamp DATETIME,
	@ToStamp DATETIME,	
	@FromActionsDate DATETIME,
	@ToActionsDate DATETIME,
	@ItcAvailability SMALLINT,
	@ItcUnavailabilityReason SMALLINT,
	@AmendmentType TINYINT,
	@SourceType TINYINT,
	@IsGstr3bFiled BIT,
	@MapperIds AS oregular.[ApplyGstr2aManualReconciliationActionDataType] READONLY,
	@Ids AS [common].[BigIntType] READONLY,
	@TotalRecord INT = NULL OUTPUT,
	@ManualMappingType TINYINT = NULL,
	@IsAvailableInGstr2b BIT NULL,
	@IsReverseCharge BIT NULL,
	@IsShowClaimedItcRecords BIT = NULL,
	@IsAvailableInGstr98a BIT = NULL,
	@Gstr98aFinancialYear INT = NULL,
	@IsNotificationSentReceived BIT = NULL,
	@IsNotificationStatusClosed BIT = NULL,
	@ItcClaimReturnPeriod INT = NULL,
	@Gstr2bReturnPeriod INT = NULL,
	@Remarks VARCHAR(MAX),
	@IsDocNumberLikeSearch BIT = 0,
	@IsTradeNamesLikeSearch BIT = 0,
	@Remark VARCHAR(100) = NULL,
	@ReconciliationType TINYINT,
	@CpFilingPreference TINYINT,
	@Gstr3bSection VARCHAR(MAX) = NULL,
	@TransactionNature BIT,
	@AuditTrailDetails AS audit.[AuditTrailDetailsType] READONLY,
	@TaxpayerStatus varchar(max),
	@IsBlacklistedVendor bit,
	@GrcScoreFrom smallint,
	@GrcScoreTo smallint,
	@ReversalReclaim int,
	/* Enums */
	@ItcEligibilityNone SMALLINT,
	@AmendmentTypeOriginal SMALLINT,
	@AmendmentTypeOriginalAmended SMALLINT,
	@AmendmentTypeAmendment SMALLINT,
	@ReconciliationTypeGstr2b SMALLINT,
	@ModuleTypeOregularPurchase SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC audit.[UpdateAuditDetails] 
						@AuditTrailDetails;
	END;

	/* Temp table for manual mapped Pr & Gst Ids */
	CREATE TABLE #TempPurchaseDocumentRecoOuter(
		PurchaseDocumentRecoId BIGINT NOT NULL,
		IsAutopopulated BIT NOT NULL,
		Action SMALLINT
	);

	--CREATE INDEX IX_PurchaseDocumentReco_GstId ON #TempPurchaseDocumentRecoOuter(PurchaseDocumentRecoId);

	CREATE TABLE #TempManualMapperIds(
		ManualMapperId BIGINT NOT NULL
	);

	/* Temp table to store PurchaseDocumentMapperID */
	CREATE TABLE #TempSelectedIds (
		ManualMapperId BIGINT NOT NULL
	);

	/* Insert what is directly coming from table type */
	CREATE TABLE #TempIntialReconciliationBulkActionType (
		Id INT IDENTITY(1,1),
		ManualMapperId INT,
		ReconciliationSection SMALLINT,
		Action SMALLINT
	);

	/* Ids to revert actions */
	CREATE TABLE #IdsForActionRevert (
		Id BIGINT NOT NULL
	);

	INSERT INTO #TempSelectedIds
	(
		ManualMapperId
	)
	SELECT
		*
	FROM
		@Ids;

	INSERT INTO #TempIntialReconciliationBulkActionType(
		ManualMapperId,
		ReconciliationSection,
		Action
	)
	SELECT
		[PurchaseDocumentMapperId],
		[ReconciliationSection],
		[Action]
	FROM @MapperIds m;

	IF EXISTS (SELECT 1 FROM #TempIntialReconciliationBulkActionType WHERE ManualMapperId IS NOT NULL) AND NOT EXISTS(SELECT 1 FROM #TempSelectedIds)
	BEGIN
		INSERT INTO #TempManualMapperIds(
			ManualMapperId
		)
		SELECT
			M.ManualMapperId
		FROM #TempIntialReconciliationBulkActionType M
		WHERE M.ManualMapperId IS NOT NULL;
	END	
	ELSE IF EXISTS (SELECT 1 FROM #TempIntialReconciliationBulkActionType WHERE ManualMapperId IS NULL) AND EXISTS(SELECT 1 FROM #TempSelectedIds)
	BEGIN
		INSERT INTO #TempManualMapperIds(
			ManualMapperId
		)
		SELECT
			ManualMapperId
		FROM #TempSelectedIds M;	
	END
	ELSE
	BEGIN	
		INSERT INTO #TempManualMapperIds(
			ManualMapperId
		)
		--DROP TABLE DocumentNumbers
		EXEC oregular.[FilterReconciliationDataManual]
			@SubscriberId= @SubscriberId, 
			@EntityIds= @EntityIds, 
			@DocFinancialYear= @DocFinancialYear, 						
			@ManualMappingType = @ManualMappingType,
			@FromPrReturnPeriod= @FromPrReturnPeriod, 
			@ToPrReturnPeriod= @ToPrReturnPeriod, 
			@FromGstnReturnPeriod = @FromGstnReturnPeriod,
			@ToGstnReturnPeriod = @ToGstnReturnPeriod,
			@RecordName= @RecordName, 
			@DocumentNumbers= @DocumentNumbers, 
			@Gstins= @Gstins, 
			@Pans= @Pans, 
			@ExcludePans= @ExcludePans, 
			@TradeNames= @TradeNames, 
			@DocumentTypes= @DocumentTypes, 
			@TransactionTypes= @TransactionTypes, 
			@TaxPayerType= @TaxPayerType, 
			@Actions= @Actions, 
			@PaymentStatus= @PaymentStatus, 
			@ActionStatus= @ActionStatus, 
			@Custom= @Custom, 
			@ItcEligibility= @ItcEligibility, 
			@FromDocumentDate= @FromDocumentDate, 
			@ToDocumentDate= @ToDocumentDate, 
			@FromStamp= @FromStamp, 
			@ToStamp= @ToStamp, 
			@FromActionsDate= @FromActionsDate, 
			@ToActionsDate= @ToActionsDate, 
			@ItcAvailability= @ItcAvailability, 
			@ItcUnavailabilityReason= @ItcUnavailabilityReason, 
			@AmendmentType= @AmendmentType, 
			@SourceType= @SourceType, 
			@IsGstr3bFiled= @IsGstr3bFiled,			
			@Start= 0, 
			@Size= 0, 
			@TotalRecord = @TotalRecord OUTPUT,
			@Remark=@Remark,
			@ReconciliationSections=@ReconciliationSections, 
			@AmendedType = NULL,
			@IsDocNumberLikeSearch= @IsDocNumberLikeSearch, 
			@IsTradeNamesLikeSearch= @IsTradeNamesLikeSearch, 
			@IsAvailableInGstr2b= @IsAvailableInGstr2b, 
			@IsShowClaimedItcRecords= @IsShowClaimedItcRecords, 
			@IsAvailableInGstr98a= @IsAvailableInGstr98a, 
			@Gstr98aFinancialYear= @Gstr98aFinancialYear, 
			@IsReverseCharge= @IsReverseCharge, 
			@IsNotificationSentReceived= @IsNotificationSentReceived, 
			@IsNotificationStatusClosed= @IsNotificationStatusClosed, 
			--@IsNotificationSentButNoReply= @IsNotificationSentButNoReply,
			@ItcClaimReturnPeriod= @ItcClaimReturnPeriod, 
			@Gstr2bReturnPeriod= @Gstr2bReturnPeriod, 
			@GetAllData= 1, 
			@ReconciliationType= @ReconciliationType,
			@CpFilingPreference = @CpFilingPreference,	
			@Gstr3bSection = @Gstr3bSection,
			@IsDsu = 0,
			@TransactionNature = @TransactionNature,
			@ItcEligibilityNone = @ItcEligibilityNone,
			@AmendmentTypeOriginal = @AmendmentTypeOriginal,
			@AmendmentTypeOriginalAmended = @AmendmentTypeOriginalAmended,
			@AmendmentTypeAmendment = @AmendmentTypeAmendment,
			@ReconciliationTypeGstr2b = @ReconciliationTypeGstr2b,
			@ModuleTypeOregularPurchase = @ModuleTypeOregularPurchase,
			@TaxpayerStatus = @TaxpayerStatus,
			@IsBlacklistedVendor = @IsBlacklistedVendor,
			@GrcScoreFrom = @GrcScoreFrom,
			@GrcScoreTo = @GrcScoreTo,
			@ReversalReclaim = @ReversalReclaim;
	END;
	
	--IF EXISTS(SELECT 1 FROM @AuditTrailDetails) 
	--BEGIN
		UPDATE gdrm
		SET gdrm.ModifiedStamp = GETDATE(), gdrm.Stamp = GETDATE()			
		FROM #TempManualMapperIds trba
		INNER JOIN oregular.PurchaseDocumentRecoManualMapper gdrm ON gdrm.Id = trba.ManualMapperId;
	--END;

	
	/* Get Purchase register and couter party Ids from Json */
	INSERT INTO #TempPurchaseDocumentRecoOuter(
		PurchaseDocumentRecoId,
		IsAutopopulated,
		Action
	)
	SELECT
		Pr.PrId  AS PurchaseDocumentRecoId,
		0 AS IsAutopopulated,
		bat.Action
	FROM
		oregular.PurchaseDocumentRecoManualMapper PDRMM
		INNER JOIN #TempManualMapperIds tMM ON PDRMM.Id = tMM.ManualMapperId
		INNER JOIN #TempIntialReconciliationBulkActionType bat ON bat.ReconciliationSection = PDRMM.SectionType
		OUTER APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr 
	UNION ALL
	SELECT
		Gst.GstId AS PurchaseDocumentRecoId,
		1 AS IsAutopopulated,
		bat.Action
	FROM
		oregular.PurchaseDocumentRecoManualMapper PDRMM
		INNER JOIN #TempManualMapperIds tMM ON PDRMM.Id = tMM.ManualMapperId
		INNER JOIN #TempIntialReconciliationBulkActionType bat ON bat.ReconciliationSection = PDRMM.SectionType
		OUTER APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst
	;
		
	
	/* Update Action in oregular.PurchaseStatus table*/
	UPDATE 
		PS
	 SET 
		PS.Gstr2bAction = tPDR.Action,
		PS.Gstr2bActionDate = GETDATE(),
		PS.Remarks = CASE WHEN @Remarks IS NOT NULL THEN @Remarks ELSE PS.Remarks END							
	FROM							
		#TempPurchaseDocumentRecoOuter tPDR
		INNER JOIN oregular.PurchaseDocumentStatus PS ON tPDR.PurchaseDocumentRecoId = PS.PurchaseDocumentId;
					
	DROP TABLE IF EXISTS #TempPurchaseDocumentRecoOuter,#TempManualMapperIds,#TempSelectedIds,#TempIntialReconciliationBulkActionType,#IdsForActionRevert;

END

GO

/*-----------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[oregular].[CancelPurchaseDocumentByIds]
* 	Comments			:	25-06-2020 | Rippal Patel | This procedure is used for Cancel Purchase Documents.
							05-08-2020 | Sagar Patel  | Added Financial year and Bill from Gsting in result set.
							07-08-2020 | Faraaz Pathan | Removed Resultset for DocumentItems.
						:	09-02-2021 | Faraaz Pathan | Added IsAmendment field in select result.
-------------------------------------------------------------------------------------------------------------
*   Test Execution	    :	DECLARE @Ids [common].[BigIntType];

							EXEC [oregular].[CancelPurchaseDocumentByIds]
								@Ids =  @Ids,
								@SubscriberId  = 172,
								@DocumentStatusCancelled = 3,
								@PushToGstStatusRemovedButNotPushed = 3,
								@PushToGstStatusCancelled = 6,
								@GstActionNoAction = 1,
								@GstActionUnlocked = 5,
								@ReconciliationMappingTypeExtended = 3
*/-----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[CancelPurchaseDocumentByIds]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @DocumentStatusCancelled SMALLINT,
	 @PushToGstStatusRemovedButNotPushed SMALLINT,
	 @PushToGstStatusCancelled SMALLINT,
	 @GstActionNoAction SMALLINT,
	 @GstActionUnlocked SMALLINT,
	 @ReconciliationMappingTypeExtended SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempPurchaseDocumentIds
	(
		Id BIGINT
	);
	CREATE TABLE #TempPurchaseDocumentIdsNotPushed
	(
		Id BIGINT NOT NULL
	);
	CREATE TABLE #TempPurchaseDocumentIdsPushed
	(
		Id BIGINT NOT NULL
	);

	INSERT INTO #TempPurchaseDocumentIds(Id)
	SELECT * FROM @Ids;

	DECLARE @GstReturnPeriods [common].[IntType],
			@EntityIds [common].[IntType];	

	/*Send Result of Documents*/
	SELECT
		dw.ParentEntityId AS EntityId,
		dw.ReturnPeriod,
		dw.SectionType,
		ps.ItcClaimReturnPeriod,
		Cast(Cast(dw.DocumentDate As Varchar(10)) AS smalldatetime) DocumentDate,
		dw.FinancialYear,
		dw.BillFromGstin,
		dw.IsAmendment
	FROM 
		#TempPurchaseDocumentIds tpdi 
		INNER JOIN oregular.purchaseDocumentDW dw ON tpdi.Id = dw.Id
		Inner JOIN oregular.PurchaseDocumentStatus ps ON dw.ID = ps.PurchaseDocumentId;

	INSERT INTO #TempPurchaseDocumentIdsNotPushed(
		Id
	)
	SELECT 
		tpdi.Id
	FROM 
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN oregular.PurchaseDocumentStatus as ps	ON tpdi.Id = ps.PurchaseDocumentId
	WHERE
		ps.IsPushed = 0;

	INSERT INTO #TempPurchaseDocumentIdsPushed(
		Id
	)
	SELECT 
		tpdi.Id
	FROM 
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN oregular.PurchaseDocumentStatus as ps ON tpdi.Id = ps.PurchaseDocumentId
	WHERE
		ps.IsPushed = 1;
	
	IF EXISTS (SELECT Id FROM #TempPurchaseDocumentIdsPushed)
	BEGIN
		UPDATE ps
		SET 
			[Status] = @DocumentStatusCancelled,
			[PushStatus] = @PushToGstStatusRemovedButNotPushed,
			Errors = NULL,
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentStatus ps
			INNER JOIN #TempPurchaseDocumentIdsPushed tpdip ON ps.PurchaseDocumentId = tpdip.Id;
	
		--UPDATE dw
		--SET 
		--	dw.[Status] = @DocumentStatusCancelled,
		--	dw.[PushStatus] = @PushToGstStatusRemovedButNotPushed,
		--	dw.Errors = NULL
		--FROM
		--	oregular.purchaseDocumentDW dw
		--	INNER JOIN #TempPurchaseDocumentIdsPushed tpdip ON dw.Id = tpdip.Id;
	END
	
	IF EXISTS (SELECT Id FROM #TempPurchaseDocumentIdsNotPushed)
	BEGIN
		
		-- Records for which action is Accepted or pending should not be deleted
		DELETE 
			tpdip 
		FROM 
			#TempPurchaseDocumentIdsNotPushed tpdip
			LEFT JOIN oregular.PurchaseDocumentStatus ps ON tpdip.Id = ps.PurchaseDocumentId
		WHERE
			ps.Gstr2bAction IS NOT NULL
			AND ps.Gstr2bAction <> @GstActionNoAction;
		
		UPDATE ps
		SET 
			[Status] = @DocumentStatusCancelled,
			[PushStatus] = @PushToGstStatusCancelled,
			CancelledDate = GETDATE(),
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentStatus ps
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdip ON ps.PurchaseDocumentId = tpdip.Id;
	
		--UPDATE dw
		--SET 
		--	dw.[Status] = @DocumentStatusCancelled,
		--	dw.[PushStatus] = @PushToGstStatusCancelled
		--FROM
		--	oregular.purchaseDocumentDW dw
		--	INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdip ON dw.Id = tpdip.Id;
	END

	/* Update status in reconciliation tables for processing effect of delete on reconciliation. After next
	   call for reconciliation these deleted records will get reflected on reconciliation page as well.
	*/

	EXEC [oregular].[DeletePurchaseDocumentForRecoByIds]
		@DocumentStatusDeleted = @DocumentStatusCancelled,
		@ReconciliationMappingTypeExtended = @ReconciliationMappingTypeExtended

	DROP TABLE #TempPurchaseDocumentIds, #TempPurchaseDocumentIdsNotPushed, #TempPurchaseDocumentIdsPushed;

END

GO

/*-----------------------------------------------------------------------------------------------------
* 	Procedure Name	:	 [oregular].[CancelSaleDocumentByIds]
* 	Comment			:	 24/06/2020 | Rippal Patel | This procedure is used to Cancel Sales Documents by Ids.					
					:	 28/07/2020 | Pooja Rajpurohit | Renamed table name to SaledocumentDw. 
					:	 05/08/2020 | Abhishek Shrivas | Replace SaleStatus table with SaledocumentDw. 
					:	 07-08-2020 | Faraaz Pathan | Removed Resultset for DocumentItems.
					:	 09-02-2021 | Faraaz Pathan | Added IsAmendment field in select result.
					:	 12-02-2021 | Faraaz Pathan | Added TransactionType field in select result.
--------------------------------------------------------------------------------------------------------
	*  Test Execution   :	DECLARE @Ids [common].[BigIntType];
											
							EXEC [oregular].[CancelSaleDocumentByIds]
								@Ids = @Ids,
								@SubscriberId  = 172,
								@DocumentStatusCancelled = 3,
								@PushToGstStatusRemovedButNotPushed = 3,
								@PushToGstStatusCancelled = 7,
								@GstActionAccepted = 2,
								@GstActionPending = 4;
--------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[CancelSaleDocumentByIds]
(
	@Ids [common].[BigIntType] READONLY,
	@SubscriberId INT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@DocumentStatusCancelled SMALLINT,
	@PushToGstStatusRemovedButNotPushed SMALLINT,
	@PushToGstStatusCancelled SMALLINT,
	@GstActionAccepted SMALLINT,
	@GstActionPending SMALLINT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempSaleDocumentIds
	(
		Id BIGINT
	);

	CREATE CLUSTERED INDEX IDX_#TempSaleDocumentIds ON #TempSaleDocumentIds(ID)
	
	CREATE TABLE #TempSaleDocumentIdsNotPushed
	(
		Id BIGINT NOT NULL
	)
	
	CREATE TABLE #TempSaleDocumentIdsPushed(
		Id BIGINT NOT NULL
	)

	INSERT INTO #TempSaleDocumentIds(Id)
	SELECT *FROM @Ids;
	
	SELECT 
		sd.ParentEntityId,
		sd.ReturnPeriod,
		sd.SectionType,
		sd.ECommerceGstin,
		ss.LiabilityDischargeReturnPeriod,
		CONVERT(SMALLDATETIME,CAST(sd.DocumentDate as VARCHAR),112) DocumentDate,
		sd.IsAmendment,
		sd.TransactionType
	FROM 
		#TempSaleDocumentIds tsdi 
		INNER JOIN oregular.SaleDocumentDW sd ON tsdi.Id = sd.Id
		INNER JOIN oregular.SaleDocumentStatus ss ON ss.SaleDocumentId = sd.Id;

	INSERT INTO #TempSaleDocumentIdsNotPushed(
		Id
	)
	SELECT
		tsdi.Id
	FROM
		#TempSaleDocumentIds AS tsdi
		INNER JOIN oregular.SaleDocumentStatus AS ss ON tsdi.Id = ss.SaleDocumentId
	WHERE 
		ss.IsPushed = 0
		AND ss.IsAutoDrafted = 0;

	INSERT INTO #TempSaleDocumentIdsPushed(
		Id
	)
	SELECT
		tsdi.Id
	FROM
		#TempSaleDocumentIds AS tsdi
		INNER JOIN oregular.SaleDocumentStatus AS ss ON tsdi.Id = ss.SaleDocumentId
	WHERE 
		ss.IsPushed = 1
		OR ss.IsAutoDrafted = 1;

	IF EXISTS (SELECT Id FROM #TempSaleDocumentIdsPushed)
	BEGIN

		UPDATE ss
		SET
			[Status] = (CASE WHEN ss.IsPushed = 1 THEN @DocumentStatusCancelled ELSE ss.[Status] END),
			PushStatus = @PushToGstStatusRemovedButNotPushed,
			Errors = NULL,
			ModifiedStamp = GETDATE()
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIdsPushed tsdip ON ss.SaleDocumentId = tsdip.Id;
	END

	IF EXISTS (SELECT Id FROM #TempSaleDocumentIdsNotPushed)
	BEGIN

		UPDATE ss
		SET
			[Status] = @DocumentStatusCancelled,
			[PushStatus] = @PushToGstStatusCancelled,
			CancelledDate = GETDATE(),
			ModifiedStamp = GETDATE()
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIdsNotPushed tsdip ON ss.SaleDocumentId = tsdip.Id;		

	END

	DROP TABLE #TempSaleDocumentIds, #TempSaleDocumentIdsPushed, #TempSaleDocumentIdsNotPushed;
END

GO

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[ClaimItc]
						: 28-05-2020 | Rippal Patel | This procedure is used to update ITC based on base Type taxAmount comparison.
						: 30-07-2020 | Rippal Patel | Added IsCounterPartyFiledData, IsCounterPartyNotFiledData filters & removed IsCounterPartRecords filter
						: 08-08-2023 | Rippal Patel | Removed TradeNames & added TradeNamesOrLegalNames filter.
*	Review Comments		: 28/07/2020 | Abhishek Shrivas | Understanding the logic from Rippal and doing some changes related to performace, Doing Formatting, Removing Unused Cases, Used PurchaseDocumentDw Table
						: 02-09-2020 | Piyush Prajapati | Added @IncludePdfRecordsOnly @TransactionTypeB2C @TransactionTypeCBW @TransactionTypeSEZWP @TransactionTypeSEZWOP @TransactionTypeIMPS 
						: 23-12-2020 | Rippal Patel | Added UserIds parameter
						: 21-04-2022 | Krishna Shah | Added GstActOrRuleSectionType filter.
						: 09-08-2023 | Rippal Patel | Added ComputationStatus filter.
						: 01-12-2023 | Krishna Shah | Added Gstr3bSection Filter.
						: 12-01-2024 | Krishna Shah | Added TransactionNature Filter.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: DECLARE @TotalRecord INT,
						   	@EntityIds AS [common].[IntType],
							@UserIds AS [common].[IntType],
						   	@Ids [common].[BigIntType],
						   	@ItcForPrRecordsTaxAmounts AS [oregular].[ItcTaxAmountType],
						   	@ItcForLesserTaxAmounts AS [oregular].[ItcTaxAmountType],
						   	@ItcForGreaterTaxAmounts AS [oregular].[ItcTaxAmountType],
							@ReturnTypes [common].[SmallIntType];

						  INSERT INTO @ReturnTypes VALUES (1);
						  INSERT INTO @ReturnTypes VALUES (14);
						  INSERT INTO @EntityIds VALUES(16882);
						  INSERT INTO @Ids VALUES (102434);
						  --INSERT INTO @ItcForPrRecordsTaxAmounts(IsUnfurnished, ItcEligiblity, ItcPercentage) VALUES (1, 1, 12);
						  INSERT INTO @ItcForLesserTaxAmounts(IsUnfurnished, ItcEligiblity, ItcPercentage) VALUES (0, 1, 5), (1, 1, 5);
						  --INSERT INTO @ItcForGreaterTaxAmounts(IsUnfurnished, ItcEligiblity, ItcPercentage) VALUES (0, 1, 10), (0, 2, 10), (0, 3, 10), (1, 1, 10);
						
						  EXEC [oregular].[ClaimItc]
						  	    @Ids =  @Ids,
								@SubscriberId  = 164,
								@UserId = 795,
								@UserIds = @UserIds,
								@FinancialYear  = 202324,
								@EntityIds =  @EntityIds,
								@ReturnPeriods = null,
								@Gstins =  null,
								@Pans = null,
								@TradeNamesOrLegalNames  = null,
								@DocumentNumbers  = null,
								@DocumentTypes  = NULL,
								@TransactionTypes = null ,
								@PushStatuses  = NULL,
								@RefDocumentNumber = NULL,
								@RefDocumentDate = NULL,
								@PortCode = NULL,
								@OriginalDocumentDate = NULL,
								@OriginalDocumentNumber = NULL,
								@OriginalPortCode = NULL,
								@Hsn = NULL,
								@Custom = NULL,
								@IsReverseCharge = NULL,
								@Pos = NULL,
								@IsUnderIgstAct = NULL,
								@ItcEligibility = NULL,
								@TdsComputationStatus = NULL,
								@PaymentStatus = Null,
								@SectionType = NULL,
								@GstActOrRuleSectionType = NULL,
								@Status = NULL,
								@AmendmentType = NULL,
								@Amended = NULL,
								@LiabilityDischargeReturnPeriod = null,
								@ItcClaimReturnPeriod = null,
								@IsCounterPartyFiledData = 0,
								@IsCounterPartyNotFiledData = 0,
								@AmendmentTypeOriginal = 1,
								@AmendmentTypeOriginalAmended = 2,
								@AmendmentTypeAmendment = 3,
								@IncludePdfRecordsOnly = NULL,
								@Start  = 0,
								@Size  = 20,
								@SourceTypeTaxpayer = 1,
								@SortExpression = 'Id ASC',
								@FromDocumentDate = null,
								@ToDocumentDate = null,
								@FromStamp = null,
								@ToStamp = null,
								@SourceTypeCounterPartyFiled = 2,
								@SourceTypeCounterPartyNotFiled = 3,
								@IsErrorRecordsOnly = 0,
								@AutoDraftSource = NULL,
								@IsAvailableInGstr2B = NULL,
								@IsAvailableInGstr98a = NULL,
								@Gstr98aFinancialYear = NULL,
								@IsClaimedItcRecords = NULL,
								@ItcAvailability = NULL,
								@ItcUnavailabilityReason = NULL,
								@ItcEligibilityNone = 0,
								@BaseType = NULL,
								@ItcForPrRecordsTaxAmounts = @ItcForPrRecordsTaxAmounts,
								@ItcForLesserTaxAmounts = @ItcForLesserTaxAmounts,
								@ItcForGreaterTaxAmounts = @ItcForGreaterTaxAmounts,
								@ReconciliationSectionTypePROnly = 1,
								@ReconciliationSectionTypePRExcluded = 7,
								@ReconciliationSectionTypePRDiscarded = 9,
								@ReconciliationSectionTypeMatched = 3,
								@ReconciliationSectionTypeMatchedDueToTolerance = 4,
								@ReconciliationSectionTypeMismatched = 5,
								@ReconciliationSectionTypeNearMatched = 6,
								@ReconciliationMappingTypeTillDate = 4,
								@IncludeCancelOrDeleteRecordsOnly = 0,
								@ExcludeGstr3BRecordsOnly = 0,
								@IncludeUploadedByMeRecordsOnly = 0,
								@ReturnPeriodForItcClaimedRecords = NULL,
								@ReturnTypes = @ReturnTypes,
								@ReturnTypeGstr2 = 3,
								@ReturnTypeGstr3B = 14,
								@ReturnActionFile = 9,
								@ReturnActionSubmit = 4,
								@PushToGstStatusPushed = 5,
								@Limit = 500,
								@TransactionTypeIMPG = 7,
								@TransactionTypeIMPS = 8,
								@ContactTypeBillFrom = 1,
								@ContactTypeDispatchFrom = 2,
								@TdsComputationStatusCompleted = 1,
								@TdsComputationStatusYetNotStarted = 2,
								@TransactionNature = 6,
								@TdsComputationStatusInProgress = 3,
								@TdsComputationStatusFailed = 4,
								@ComputationStatusCompleted = 1,
								@ComputationStatusInProgress = 2,
								@ComputationStatusFailed = 3,
								@SourceTypeEInvoice = 5,
								@TotalRecord  = @TotalRecord OUT
						  		Select @TotalRecord;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[ClaimItc]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @UserId INT,
	 @UserIds [common].[IntType] READONLY,
	 @FinancialYear INT,
	 @EntityIds [common].[IntType] READONLY,
	 @ReturnPeriods VARCHAR(MAX),
	 @Gstins VARCHAR(MAX),
	 @Pans VARCHAR(MAX),
	 @TradeNamesOrLegalNames VARCHAR(MAX),
	 @DocumentNumbers VARCHAR(MAX),
	 @DocumentTypes VARCHAR(MAX),
	 @TransactionTypes VARCHAR(MAX),
	 @PushStatuses VARCHAR(MAX),
	 @RefDocumentNumber VARCHAR(40) NULL,
	 @RefDocumentDate SMALLDATETIME NULL,
	 @PortCode VARCHAR(6) NULL,
	 @OriginalDocumentNumber VARCHAR(40) NULL,
	 @OriginalDocumentDate SMALLDATETIME NULL,
	 @OriginalPortCode VARCHAR(6) NULL,
	 @Hsn VARCHAR(10) NULL,
	 @Custom VARCHAR(100) NULL,
	 @IsReverseCharge BIT NULL,
	 @Pos SMALLINT NULL,
	 @IsUnderIgstAct BIT NULL,
	 @ItcEligibility VARCHAR(20),
	 @TdsComputationStatus SMALLINT NULL,
	 @PaymentStatus SMALLINT NULL,
	 @SectionType INT NULL,
	 @GstActOrRuleSectionType INT NULL,
	 @Status SMALLINT NULL,
	 @AmendmentType SMALLINT NULL,
	 @Amended INT NULL,
	 @LiabilityDischargeReturnPeriod INT NULL,
	 @ItcClaimReturnPeriod INT NULL,
	 @IsCounterPartyFiledData BIT,
	 @IsCounterPartyNotFiledData BIT,
	 @AmendmentTypeOriginal SMALLINT,
	 @AmendmentTypeOriginalAmended SMALLINT,
	 @AmendmentTypeAmendment SMALLINT,
	 @TotalRecord INT = NULL OUTPUT,
	 @BaseType SMALLINT,
	 @ItcForPrRecordsTaxAmounts [oregular].[ItcTaxAmountType] READONLY,
	 @ItcForLesserTaxAmounts [oregular].[ItcTaxAmountType] READONLY,
	 @ItcForGreaterTaxAmounts [oregular].[ItcTaxAmountType] READONLY,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @SourceTypeTaxpayer SMALLINT,
	 @SourceTypeCounterPartyFiled SMALLINT,
	 @SourceTypeCounterPartyNotFiled SMALLINT,
	 @ReconciliationSectionTypePROnly SMALLINT,
	 @ReconciliationSectionTypePRExcluded SMALLINT,
	 @ReconciliationSectionTypePRDiscarded SMALLINT,
	 @ReconciliationSectionTypeMatched SMALLINT,
	 @ReconciliationSectionTypeMatchedDueToTolerance SMALLINT,
	 @ReconciliationSectionTypeMismatched SMALLINT,
	 @ReconciliationSectionTypeNearMatched SMALLINT,
	 @ReconciliationMappingTypeTillDate SMALLINT,
	 @FromDocumentDate DATETIME NULL,
	 @ToDocumentDate DATETIME NULL,
	 @FromStamp DATETIME NULL,
	 @ToStamp DATETIME NULL,	 
	 @Gstr3bSection INT,
	 @IsErrorRecordsOnly BIT NULL,
	 @AutoDraftSource VARCHAR(40) NULL,
	 @IsAvailableInGstr2B BIT NULL,
	 @IsAvailableInGstr98a BIT NULL,
	 @Gstr98aFinancialYear INT = NULL,
	 @IsClaimedItcRecords BIT NULL,
	 @ItcAvailability SMALLINT NULL,
	 @ItcUnavailabilityReason SMALLINT NULL,
	 @Start INT,
	 @Size INT,
	 @SortExpression VARCHAR(50),
	 @ItcEligibilityNone SMALLINT,
	 @IncludeCancelOrDeleteRecordsOnly BIT,
	 @ExcludeGstr3BRecordsOnly BIT,
	 @IncludeUploadedByMeRecordsOnly BIT,
	 @ReturnPeriodForItcClaimedRecords INT NULL,
	 @ReturnTypes [common].[SmallIntType] READONLY,
	 @IncludePdfRecordsOnly BIT,
	 @TransactionTypeIMPG SMALLINT,
	 @TransactionTypeIMPS SMALLINT,
	 @ReturnTypeGstr2 SMALLINT,
	 @ReturnTypeGstr3B SMALLINT,
	 @ReturnActionFile SMALLINT,
	 @ReturnActionSubmit SMALLINT,
	 @PushToGstStatusPushed SMALLINT,
	 @ContactTypeBillFrom SMALLINT,
	 @ContactTypeDispatchFrom SMALLINT,
	 @TdsComputationStatusCompleted SMALLINT,
	 @TdsComputationStatusYetNotStarted SMALLINT,
	 @TdsComputationStatusInProgress SMALLINT,
	 @TdsComputationStatusFailed SMALLINT,
	 @ComputationStatusCompleted SMALLINT,
	 @TransactionNature SMALLINT,
	 @ComputationStatusInProgress SMALLINT,
	 @ComputationStatusFailed SMALLINT,
	 @SourceTypeEInvoice SMALLINT,
	 @Limit BIGINT NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@True BIT = 1,
		@UnfurnishedItcPercentageForPrRecords DECIMAL(5,2),
		@UnfurnishedItcEligibilityForPrRecords SMALLINT,
		@UnfurnishedItcPercentageForLesserRecords DECIMAL(5,2),
		@UnfurnishedItcEligibilityForLesserRecords SMALLINT,
		@UnfurnishedItcPercentageForGreaterRecords DECIMAL(5,2),
		@UnfurnishedItcEligibilityForGreaterRecords SMALLINT;

	CREATE TABLE #TempPurchaseDocumentIds
	(
		Id BIGINT
	);

	CREATE TABLE #TempPurchaseDocumentsForPrRecords
	(
		SourceType SMALLINT NOT NULL,
		ItemId BIGINT NOT NULL,
		IgstAmount DECIMAL(18,2) NULL,
		CgstAmount DECIMAL(18,2) NULL, 
		SgstAmount DECIMAL(18,2) NULL, 
		ItcEligibility SMALLINT NULL, 
		ItcIgstAmount DECIMAL(18,2) NULL, 
		ItcCgstAmount DECIMAL(18,2) NULL, 
		ItcSgstAmount DECIMAL(18,2) NULL,
		ItcCessAmount DECIMAL(18,2) NULL
	);

	CREATE TABLE #TempPurchaseDocumentIdsForLesserRecords
	(
		PrId BIGINT NOT NULL,
		CpId BIGINT NOT NULL
	);

	CREATE TABLE #TempPurchaseDocumentIdsForGreaterRecords
	(
		PrId BIGINT NOT NULL,
		CpId BIGINT NOT NULL
	);

	CREATE TABLE #TempPurchaseDocumentsForLesserRecords
	(
		DocumentItemId BIGINT NOT NULL,
		ItcEligiblity SMALLINT NULL,
		ItcIgstAmount DECIMAL(18,2) NULL,
		ItcCgstAmount DECIMAL(18,2) NULL,
		ItcSgstAmount DECIMAL(18,2) NULL,
		ItcCessAmount DECIMAL(18,2) NULL,
		IsIgstNotNull BIT NOT NULL,
		IsCgstNotNull BIT NOT NULL,
		IsSgstNotNull BIT NOT NULL,
		IsCessNotNull BIT NOT NULL
	);

	CREATE TABLE #TempPurchaseDocumentsForGreaterRecords
	(
		DocumentItemId BIGINT NOT NULL,
		ItcEligiblity SMALLINT NULL,
		ItcIgstAmount DECIMAL(18,2) NULL,
		ItcCgstAmount DECIMAL(18,2) NULL,
		ItcSgstAmount DECIMAL(18,2) NULL,
		ItcCessAmount DECIMAL(18,2) NULL,
		IsIgstNotNull BIT NOT NULL,
		IsCgstNotNull BIT NOT NULL,
		IsSgstNotNull BIT NOT NULL,
		IsCessNotNull BIT NOT NULL
	);

	SELECT
		IsUnfurnished,
		ItcEligiblity,
		ItcPercentage
	INTO
		#TempItcForLesserTaxAmount
	FROM
		@ItcForLesserTaxAmounts;

	SELECT
		IsUnfurnished,
		ItcEligiblity,
		ItcPercentage
	INTO
		#TempItcForGreaterTaxAmount
	FROM
		@ItcForGreaterTaxAmounts;

	SELECT
		IsUnfurnished,
		ItcEligiblity,
		ItcPercentage
	INTO
		#TempItcForPrTaxAmount
	FROM
		@ItcForPrRecordsTaxAmounts;

	INSERT INTO #TempPurchaseDocumentIds(Id)
	EXEC [oregular].[FilterPurchaseDocuments]
		@Ids = @Ids,
		@SubscriberId  = @SubscriberId,
		@UserId = @UserId,
		@UserIds = @UserIds,
		@FinancialYear  = @FinancialYear,
		@EntityIds =  @EntityIds,
		@ReturnPeriods = @ReturnPeriods,
		@Gstins = @Gstins,
		@Pans = @Pans,
		@TradeNamesOrLegalNames  = @TradeNamesOrLegalNames,
		@DocumentNumbers  = @DocumentNumbers,
		@DocumentTypes  = @DocumentTypes,
		@TransactionTypes = @TransactionTypes,
		@PushStatuses  = @PushStatuses,
		@RefDocumentNumber = @RefDocumentNumber,
		@RefDocumentDate = @RefDocumentDate,
		@PortCode = @PortCode,
		@OriginalDocumentNumber = @OriginalDocumentNumber,
		@OriginalDocumentDate = @OriginalDocumentDate,
		@OriginalPortCode = @OriginalPortCode,
		@Hsn = @Hsn,
		@Custom = @Custom,
		@IsReverseCharge = @IsReverseCharge,
		@Pos = @Pos,
		@IsUnderIgstAct = @IsUnderIgstAct,
		@ItcEligibility = @ItcEligibility,
		@TdsComputationStatus = @TdsComputationStatus,
		@PaymentStatus = @PaymentStatus,
		@SectionType = @SectionType,
		@GstActOrRuleSectionType = @GstActOrRuleSectionType,
		@Status = @Status,
		@AmendmentType = @AmendmentType,
		@Amended = @Amended,
		@LiabilityDischargeReturnPeriod = @LiabilityDischargeReturnPeriod,
		@ItcClaimReturnPeriod = @ItcClaimReturnPeriod, 
		@IsCounterPartyFiledData = @IsCounterPartyFiledData,
		@IsCounterPartyNotFiledData = @IsCounterPartyNotFiledData,
		@Start  = @Start,
		@Size  = @Size,
		@SortExpression = @SortExpression,
		@TotalRecord = @TotalRecord OUT,
		@SourceTypeTaxpayer = @SourceTypeTaxpayer,
		@SourceTypeCounterPartyNotFiled = @SourceTypeCounterPartyNotFiled,
		@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
		@ItcELigibilityNone = @ItcEligibilityNone,
		@FromDocumentDate = @FromDocumentDate,
		@ToDocumentDate = @ToDocumentDate,
		@FromStamp = @FromStamp,
		@ToStamp = @ToStamp,
		@Gstr3bSection = @Gstr3bSection,
		@IsErrorRecordsOnly = @IsErrorRecordsOnly,
		@AutoDraftSource = @AutoDraftSource, 
		@IsAvailableInGstr2B = @IsAvailableInGstr2B,
		@IsAvailableInGstr98a = @IsAvailableInGstr98a,		
		@Gstr98aFinancialYear = @Gstr98aFinancialYear,
		@IsClaimedItcRecords = @IsClaimedItcRecords,
		@ItcAvailability = @ItcAvailability,
		@ItcUnavailabilityReason = @ItcUnavailabilityReason,
		@AmendmentTypeOriginal = @AmendmentTypeOriginal,
		@AmendmentTypeOriginalAmended = @AmendmentTypeOriginalAmended,
		@AmendmentTypeAmendment = @AmendmentTypeAmendment,
		@IncludeCancelOrDeleteRecordsOnly = @IncludeCancelOrDeleteRecordsOnly,
		@ExcludeGstr3BRecordsOnly = @ExcludeGstr3BRecordsOnly,
		@IncludeUploadedByMeRecordsOnly = @IncludeUploadedByMeRecordsOnly,
		@ReturnPeriodForItcClaimedRecords = @ReturnPeriodForItcClaimedRecords,
		@ReturnTypes = @ReturnTypes,
		@IncludePdfRecordsOnly = @IncludePdfRecordsOnly,
		@TransactionTypeIMPG = @TransactionTypeIMPG,
		@TransactionTypeIMPS = @TransactionTypeIMPS,
		@ReturnTypeGstr2 = @ReturnTypeGstr2,
		@ReturnTypeGstr3B = @ReturnTypeGstr3B,
		@ReturnActionFile = @ReturnActionFile,
		@ReturnActionSubmit = @ReturnActionSubmit,
		@PushToGstStatusPushed = @PushToGstStatusPushed,
		@ContactTypeBillFrom = @ContactTypeBillFrom,
		@ContactTypeDispatchFrom = @ContactTypeDispatchFrom,
		@TdsComputationStatusCompleted = @TdsComputationStatusCompleted,
		@TdsComputationStatusYetNotStarted = @TdsComputationStatusYetNotStarted,
		@TdsComputationStatusInProgress = @TdsComputationStatusInProgress,
		@TdsComputationStatusFailed = @TdsComputationStatusFailed,
		@TransactionNature = @TransactionNature,
		@ComputationStatusCompleted = @ComputationStatusCompleted,
		@ComputationStatusInProgress = @ComputationStatusInProgress,
		@ComputationStatusFailed = @ComputationStatusFailed,
		@SourceTypeEInvoice = @SourceTypeEInvoice;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;

		UPDATE pds
		SET
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentStatus pds
			INNER JOIN #TempPurchaseDocumentIds tpdi ON pds.PurchaseDocumentId = tpdi.Id;
	END;

	IF NOT EXISTS(SELECT 1 FROM #TempPurchaseDocumentIds)
	BEGIN
		RAISERROR('VAL0114|406', 16, 1);
		RETURN;
	END

	IF (@Limit IS NOT NULL AND (SELECT COUNT(Id) FROM #TempPurchaseDocumentIds) > @Limit)
	BEGIN
		RAISERROR('VAL0479|406', 16, 1);
		RETURN;
	END

	IF EXISTS(SELECT 1 FROM #TempItcForPrTaxAmount)
	BEGIN

		SELECT 
			@UnfurnishedItcPercentageForPrRecords = tpa.ItcPercentage, 
			@UnfurnishedItcEligibilityForPrRecords = tpa.ItcEligiblity 
		FROM 
			#TempItcForPrTaxAmount tpa 
		WHERE 
			tpa.IsUnfurnished = @True;

		INSERT INTO #TempPurchaseDocumentsForPrRecords
		(
			SourceType,
			ItemId,
			IgstAmount,
			CgstAmount, 
			SgstAmount, 
			ItcEligibility, 
			ItcIgstAmount, 
			ItcCgstAmount, 
			ItcSgstAmount,
			ItcCessAmount
		)
		SELECT
			dw.SourceType,
			pdi.Id AS ItemId,
			pdi.IgstAmount,
			pdi.CgstAmount, 
			pdi.SgstAmount, 
			pdi.ItcEligibility, 
			pdi.ItcIgstAmount, 
			pdi.ItcCgstAmount, 
			pdi.ItcSgstAmount,
			pdi.ItcCessAmount
		FROM
			oregular.PurchaseDocumentDW dw
			INNER JOIN oregular.PurchaseDocumentItems pdi ON dw.Id = pdi.PurchaseDocumentId
			INNER JOIN oregular.PurchaseDocumentStatus ps ON ps.PurchaseDocumentId = dw.Id
			INNER JOIN oregular.Gstr2bDocumentRecoMapper pdrm ON pdrm.PrId = dw.Id
			INNER JOIN #TempPurchaseDocumentIds tpdi ON dw.Id = tpdi.Id
		WHERE 
			ps.IsReconciledGstr2b  = @True
			AND pdrm.SectionType IN (@ReconciliationSectionTypePROnly, @ReconciliationSectionTypePRExcluded, @ReconciliationSectionTypePRDiscarded)
			AND dw.SourceType = @SourceTypeTaxpayer
			AND pdrm.MappingType = @ReconciliationMappingTypeTillDate;

		/*Updating Itc for PR records only*/
		UPDATE 
			pdi
		SET
			pdi.ItcEligibility = CASE WHEN pdi.ItcEligibility IS NOT NULL THEN pdi.ItcEligibility ELSE @UnfurnishedItcEligibilityForPrRecords END,
			pdi.ItcIgstAmount = CASE WHEN pdi.ItcEligibility IS NOT NULL THEN (pdi.IgstAmount * tpa.ItcPercentage / 100) ELSE (pdi.IgstAmount * @UnfurnishedItcPercentageForPrRecords / 100) END,
			pdi.ItcSgstAmount = CASE WHEN pdi.ItcEligibility IS NOT NULL THEN (pdi.CgstAmount * tpa.ItcPercentage / 100) ELSE (pdi.CgstAmount * @UnfurnishedItcPercentageForPrRecords / 100) END,
			pdi.ItcCgstAmount = CASE WHEN pdi.ItcEligibility IS NOT NULL THEN (pdi.SgstAmount * tpa.ItcPercentage / 100) ELSE (pdi.SgstAmount * @UnfurnishedItcPercentageForPrRecords / 100) END,
			pdi.ItcCessAmount = CASE WHEN pdi.ItcEligibility IS NOT NULL THEN (pdi.CessAmount * tpa.ItcPercentage / 100) ELSE (pdi.CessAmount * @UnfurnishedItcPercentageForPrRecords / 100) END,
			pdi.ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentItems pdi
			INNER JOIN #TempPurchaseDocumentsForPrRecords tpd ON tpd.ItemId = pdi.Id
			LEFT JOIN #TempItcForPrTaxAmount tpa ON tpa.ItcEligiblity = tpd.ItcEligibility

		SELECT 
			DISTINCT pdi.PurchaseDocumentId
			INTO #TempPurchaseIdForPrRecords
		FROM
			oregular.PurchaseDocumentItems AS pdi
			INNER JOIN #TempPurchaseDocumentsForPrRecords AS tpdpr ON pdi.Id = tpdpr.ItemId;

		DELETE 
			pdri
		FROM
			#TempPurchaseIdForPrRecords tpipr
			INNER JOIN oregular.PurchaseDocumentRateWiseItems pdri ON pdri.PurchaseDocumentId = tpipr.PurchaseDocumentId	

		INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
		(
			[PurchaseDocumentId]
			,[Rate]
			,[TaxableValue]
			,[IgstAmount]
			,[CgstAmount]
			,[SgstAmount]
			,[CessAmount]
		)
		SELECT
			pdi.PurchaseDocumentId,
			pdi.Rate,
			SUM(pdi.TaxableValue),
			SUM(pdi.IgstAmount),
			SUM(pdi.CgstAmount),
			SUM(pdi.SgstAmount),
			SUM(pdi.CessAmount)
		FROM
			#TempPurchaseIdForPrRecords AS tpipr
			INNER JOIN oregular.PurchaseDocumentItems AS pdi ON tpipr.PurchaseDocumentId = pdi.PurchaseDocumentId
		GROUP BY 
			pdi.PurchaseDocumentId, pdi.Rate, pdi.ItcEligibility;

		DROP TABLE IF EXISTS #TempRecoItems1;
		SELECT
			pdi.PurchaseDocumentId,
			pdi.Rate,
			MAX(pdi.ItcEligibility) AS ItcEligibility,
			SUM(pdi.ItcIgstAmount) AS ItcIgstAmount,
			SUM(pdi.ItcCgstAmount) AS ItcCgstAmount,
			SUM(pdi.ItcSgstAmount) AS ItcSgstAmount,
			SUM(pdi.ItcCessAmount) AS ItcCessAmount
		INTO #TempRecoItems1
		FROM
			#TempPurchaseIdForPrRecords tpipr
			INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpipr.PurchaseDocumentId
		GROUP BY pdi.PurchaseDocumentId, pdi.Rate;

		UPDATE pdri
		SET pdri.ItcEligibility = tr.ItcEligibility,
			pdri.ItcIgstAmount = tr.ItcIgstAmount,
			pdri.ItcCgstAmount = tr.ItcCgstAmount,
			pdri.ItcSgstAmount = tr.ItcSgstAmount,
			pdri.ItcCessAmount = tr.ItcCessAmount,
			pdri.ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentRecoItems pdri
			INNER JOIN #TempRecoItems1 tr ON pdri.PurchaseDocumentRecoId = tr.PurchaseDocumentId AND pdri.Rate = tr.Rate;

		DROP TABLE IF EXISTS #tempReco1;
		SELECT
			ri.PurchaseDocumentRecoId,
			SUM(ri.ItcIgstAmount) AS ItcIgstAmount,
			SUM(ri.ItcCgstAmount) AS ItcCgstAmount,
			SUM(ri.ItcSgstAmount) AS ItcSgstAmount,
			SUM(ri.ItcCessAmount) AS ItcCessAmount
		INTO #tempReco1
		FROM
			#TempPurchaseIdForPrRecords tpigr
			INNER JOIN oregular.PurchaseDocumentRecoItems ri ON ri.PurchaseDocumentRecoId = tpigr.PurchaseDocumentId
		GROUP BY ri.PurchaseDocumentRecoId;

		UPDATE r
			SET r.ItcIgstAmount = ISNULL(tr.ItcIgstAmount, 0),
				r.ItcCgstAmount = ISNULL(tr.ItcCgstAmount, 0),
				r.ItcSgstAmount = ISNULL(tr.ItcSgstAmount, 0),
				r.ItcCessAmount = ISNULL(tr.ItcCessAmount, 0)
		FROM oregular.PurchaseDocumentReco r
		INNER JOIN #tempReco1 tr ON r.Id = tr.PurchaseDocumentRecoId;
		DROP TABLE IF EXISTS #tempReco1;
	END
	
	IF EXISTS (SELECT 1 FROM #TempItcForLesserTaxAmount)
	BEGIN

		SELECT 
			@UnfurnishedItcPercentageForLesserRecords = tla.ItcPercentage, 
			@UnfurnishedItcEligibilityForLesserRecords = tla.ItcEligiblity 
		FROM 
			#TempItcForLesserTaxAmount tla
		WHERE 
			tla.IsUnfurnished = @True;

		INSERT INTO #TempPurchaseDocumentIdsForLesserRecords
		(
			PrId,
			CpId
		)		
		SELECT
			dw.Id,
			pdrm.GstnId
		FROM
			#TempPurchaseDocumentIds tpdi
			INNER JOIN oregular.PurchaseDocumentDW dw ON tpdi.Id = dw.Id
			INNER JOIN oregular.PurchaseDocumentStatus ps ON ps.PurchaseDocumentId = dw.Id
			INNER JOIN oregular.Gstr2bDocumentRecoMapper pdrm ON tpdi.Id = pdrm.PrId
		WHERE 
			ps.IsReconciledGstr2b  = @True
			AND pdrm.SectionType IN (@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance, @ReconciliationSectionTypeMismatched, @ReconciliationSectionTypeNearMatched)
			AND pdrm.MappingType = @ReconciliationMappingTypeTillDate;

		INSERT INTO #TempPurchaseDocumentsForLesserRecords
		(
			DocumentItemId,
			ItcEligiblity,
			ItcIgstAmount,
			ItcCgstAmount,
			ItcSgstAmount,
			ItcCessAmount,
			IsIgstNotNull,
			IsCgstNotNull,
			IsSgstNotNull,
			IsCessNotNull
		)
		SELECT
			Prpdi.Id,
			ISNULL(Prpdi.ItcEligibility ,@UnfurnishedItcEligibilityForLesserRecords ),
			CASE 
				WHEN @BaseType = @SourceTypeTaxpayer 
					  AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) < (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
					  THEN 
							CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
								THEN (Prpdi.IgstAmount * tilt.ItcPercentage / 100) 
								ELSE (Prpdi.IgstAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						    END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled  
					  AND  (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) > (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Cppdi.IgstAmount * tilt.ItcPercentage / 100) 
							 ELSE (Cppdi.IgstAmount * @UnfurnishedItcPercentageForLesserRecords / 100)  
						END
			END,
			CASE 
				WHEN @BaseType = @SourceTypeTaxpayer 
					 AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) < (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
					 THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Prpdi.CgstAmount * tilt.ItcPercentage / 100) 
							 ELSE (Prpdi.CgstAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) > (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Cppdi.CgstAmount * tilt.ItcPercentage / 100) 
							 ELSE (Cppdi.CgstAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						END
			END,
			CASE WHEN @BaseType = @SourceTypeTaxpayer 
					  AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) < (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Prpdi.SgstAmount * tilt.ItcPercentage / 100) 
							 ELSE (Prpdi.SgstAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) > (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
				 	  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Cppdi.SgstAmount * tilt.ItcPercentage / 100) 
							 ELSE (Cppdi.SgstAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						END
			END,
			CASE 
				WHEN @BaseType = @SourceTypeTaxpayer 
				 AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) < (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Prpdi.CessAmount * tilt.ItcPercentage / 100) 
							 ELSE (Prpdi.CessAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) > (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Cppdi.CessAmount * tilt.ItcPercentage / 100) 
							 ELSE (Cppdi.CessAmount * @UnfurnishedItcPercentageForLesserRecords / 100) 
						END
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.IgstAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.IgstAmount IS NOT NULL THEN 1 ELSE 0 END 
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.CgstAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.CgstAmount IS NOT NULL THEN 1 ELSE 0 END 
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.SgstAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
				   CASE WHEN Prpdi.SgstAmount IS NOT NULL THEN 1 ELSE 0 END 
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.CessAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.CessAmount IS NOT NULL THEN 1 ELSE 0 END 
			END
		FROM 
			#TempPurchaseDocumentIdsForLesserRecords tpd
			LEFT JOIN oregular.PurchaseDocumentItems Prpdi ON tpd.PrId = Prpdi.PurchaseDocumentId
			LEFT JOIN oregular.PurchaseDocumentItems Cppdi ON tpd.CpId = Cppdi.PurchaseDocumentId AND ISNULL(Prpdi.Hsn,0) = ISNULL(Cppdi.Hsn,0) AND Prpdi.Rate = Cppdi.Rate
			LEFT JOIN #TempItcForLesserTaxAmount tilt ON Prpdi.ItcEligibility = tilt.ItcEligiblity
		WHERE
			(
				(
			 		@BaseType = @SourceTypeTaxpayer
			 		AND
			 		(ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) < (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
				)
				OR
				(
					@BaseType = @SourceTypeCounterPartyNotFiled
					AND 
					(ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) > (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
				)
			);

		IF EXISTS(SELECT 1 FROM #TempPurchaseDocumentsForLesserRecords)
		BEGIN
			UPDATE pdi
			SET
				ItcEligibility =  tpd.ItcEligiblity,
				ItcIgstAmount =  CASE WHEN pdi.IgstAmount IS NULL AND tpd.IsIgstNotNull = 1 
									  THEN tpd.ItcIgstAmount
									  WHEN pdi.IgstAmount IS NOT NULL AND tpd.IsIgstNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcIgstAmount END,
				ItcCgstAmount =  CASE WHEN pdi.CgstAmount IS NULL AND tpd.IsCgstNotNull = 1 
									  THEN tpd.ItcCgstAmount
									  WHEN pdi.CgstAmount IS NOT NULL AND tpd.IsCgstNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcCgstAmount END,
				ItcSgstAmount =  CASE WHEN pdi.SgstAmount IS NULL AND tpd.IsSgstNotNull = 1 
									  THEN tpd.ItcSgstAmount 
									  WHEN pdi.SgstAmount IS NOT NULL AND tpd.IsSgstNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcSgstAmount END,
				ItcCessAmount =  CASE WHEN pdi.CessAmount IS NULL AND tpd.IsCessNotNull = 1 
									  THEN tpd.ItcCessAmount
									  WHEN pdi.CessAmount IS NOT NULL AND tpd.IsCessNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcCessAmount END,
				ModifiedStamp = GETDATE()
			FROM 
				#TempPurchaseDocumentsForLesserRecords tpd
				INNER JOIN oregular.PurchaseDocumentItems pdi ON tpd.DocumentItemId = pdi.Id

			SELECT 
				DISTINCT pdi.PurchaseDocumentId
			INTO 
				#TempPurchaseIdForLesserRecords
			FROM
				oregular.PurchaseDocumentItems AS pdi
				INNER JOIN #TempPurchaseDocumentsForLesserRecords AS tpdlr ON pdi.Id = tpdlr.DocumentItemId;

			DELETE 
			pdri
			FROM
				#TempPurchaseIdForLesserRecords tpilr
				INNER JOIN oregular.PurchaseDocumentRateWiseItems pdri ON pdri.PurchaseDocumentId = tpilr.PurchaseDocumentId	

			INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
			(
				[PurchaseDocumentId]
				,[Rate]
				,[TaxableValue]
				,[IgstAmount]
				,[CgstAmount]
				,[SgstAmount]
				,[CessAmount]
			)
			SELECT
				pdi.PurchaseDocumentId,
				pdi.Rate,
				SUM(pdi.TaxableValue),
				SUM(pdi.IgstAmount),
				SUM(pdi.CgstAmount),
				SUM(pdi.SgstAmount),
				SUM(pdi.CessAmount)
			FROM
				#TempPurchaseIdForLesserRecords tpilr
				INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpilr.PurchaseDocumentId
			GROUP BY 
				pdi.PurchaseDocumentId, pdi.Rate, pdi.ItcEligibility;

			DROP TABLE IF EXISTS #TempRecoItems2;
			SELECT
				pdi.PurchaseDocumentId,
				pdi.Rate,
				MAX(pdi.ItcEligibility) AS ItcEligibility,
				SUM(pdi.ItcIgstAmount) AS ItcIgstAmount,
				SUM(pdi.ItcCgstAmount) AS ItcCgstAmount,
				SUM(pdi.ItcSgstAmount) AS ItcSgstAmount,
				SUM(pdi.ItcCessAmount) AS ItcCessAmount
			INTO #TempRecoItems2
			FROM
				#TempPurchaseIdForLesserRecords tpilr
				INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpilr.PurchaseDocumentId
			GROUP BY pdi.PurchaseDocumentId, pdi.Rate;

			UPDATE pdri
			SET pdri.ItcEligibility = tr.ItcEligibility,
				pdri.ItcIgstAmount = tr.ItcIgstAmount,
				pdri.ItcCgstAmount = tr.ItcCgstAmount,
				pdri.ItcSgstAmount = tr.ItcSgstAmount,
				pdri.ItcCessAmount = tr.ItcCessAmount,
				pdri.ModifiedStamp = GETDATE()
			FROM
				oregular.PurchaseDocumentRecoItems pdri
				INNER JOIN #TempRecoItems2 tr ON pdri.PurchaseDocumentRecoId = tr.PurchaseDocumentId AND pdri.Rate = tr.Rate;

			DROP TABLE IF EXISTS #tempReco2;
			SELECT
				ri.PurchaseDocumentRecoId,
				SUM(ri.ItcIgstAmount) AS ItcIgstAmount,
				SUM(ri.ItcCgstAmount) AS ItcCgstAmount,
				SUM(ri.ItcSgstAmount) AS ItcSgstAmount,
				SUM(ri.ItcCessAmount) AS ItcCessAmount
			INTO #tempReco2
			FROM
				#TempPurchaseIdForLesserRecords tpigr
				INNER JOIN oregular.PurchaseDocumentRecoItems ri ON ri.PurchaseDocumentRecoId = tpigr.PurchaseDocumentId
			GROUP BY ri.PurchaseDocumentRecoId;

			UPDATE r
				SET r.ItcIgstAmount = ISNULL(tr.ItcIgstAmount, 0),
					r.ItcCgstAmount = ISNULL(tr.ItcCgstAmount, 0),
					r.ItcSgstAmount = ISNULL(tr.ItcSgstAmount, 0),
					r.ItcCessAmount = ISNULL(tr.ItcCessAmount, 0)
			FROM oregular.PurchaseDocumentReco r
			INNER JOIN #tempReco2 tr ON r.Id = tr.PurchaseDocumentRecoId;
			DROP TABLE IF EXISTS #tempReco2;
		END
	END

	IF EXISTS (SELECT 1 FROM #TempItcForGreaterTaxAmount)
	BEGIN

		SELECT 
			@UnfurnishedItcPercentageForGreaterRecords = tga.ItcPercentage, 
			@UnfurnishedItcEligibilityForGreaterRecords = tga.ItcEligiblity 
		FROM 
			#TempItcForGreaterTaxAmount tga
		WHERE 
			tga.IsUnfurnished = @True;

		INSERT INTO #TempPurchaseDocumentIdsForGreaterRecords
		(
			PrId,
			CpId
		)	
		SELECT
			dw.Id,
			pdrm.GstnId
		FROM
			#TempPurchaseDocumentIds tpdi
			INNER JOIN oregular.PurchaseDocumentDW dw ON tpdi.Id = dw.Id
			INNER JOIN oregular.PurchaseDocumentStatus ps ON ps.PurchaseDocumentId = dw.Id
			INNER JOIN oregular.Gstr2bDocumentRecoMapper pdrm ON tpdi.Id = pdrm.PrId
		WHERE 
			ps.IsReconciledGstr2b  = @True
			AND pdrm.SectionType IN (@ReconciliationSectionTypeMatched, @ReconciliationSectionTypeMatchedDueToTolerance, @ReconciliationSectionTypeMismatched, @ReconciliationSectionTypeNearMatched)
			AND pdrm.MappingType = @ReconciliationMappingTypeTillDate;

		INSERT INTO #TempPurchaseDocumentsForGreaterRecords
		(
			DocumentItemId,
			ItcEligiblity,
			ItcIgstAmount,
			ItcCgstAmount,
			ItcSgstAmount,
			ItcCessAmount,
			IsIgstNotNull,
			IsCgstNotNull,
			IsSgstNotNull,
			IsCessNotNull
		)
		SELECT
			Prpdi.Id,
			ISNULL(Prpdi.ItcEligibility ,@UnfurnishedItcEligibilityForGreaterRecords ),
			CASE 
				WHEN @BaseType = @SourceTypeTaxpayer 
					 AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) > (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
				THEN 
					CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
						 THEN (Prpdi.IgstAmount * tilt.ItcPercentage / 100) 
						 ELSE (Prpdi.IgstAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
					END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) < (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
				 THEN 
					CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
						 THEN (Cppdi.IgstAmount * tilt.ItcPercentage / 100) 
						 ELSE (Cppdi.IgstAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
					END
			END,
			CASE WHEN @BaseType = @SourceTypeTaxpayer 
					  AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) > (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
				 THEN 
					CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
						 THEN (Prpdi.CgstAmount * tilt.ItcPercentage / 100) 
						 ELSE (Prpdi.CgstAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
					END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) < (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
				 THEN 
					CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
						 THEN (Cppdi.CgstAmount * tilt.ItcPercentage / 100) 
						 ELSE (Cppdi.CgstAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
					END
			END,
			CASE WHEN @BaseType = @SourceTypeTaxpayer 
					  AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) > (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
				 THEN 
					CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
						 THEN (Prpdi.SgstAmount * tilt.ItcPercentage / 100) 
						 ELSE (Prpdi.SgstAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
					END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) < (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Cppdi.SgstAmount * tilt.ItcPercentage / 100) 
							 ELSE (Cppdi.SgstAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
						END
			END,
			CASE WHEN @BaseType = @SourceTypeTaxpayer 
				 AND (ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) > (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
						THEN (Prpdi.CessAmount * tilt.ItcPercentage / 100) 
						ELSE (Prpdi.CessAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
					  END
				 WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
					  AND (ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) < (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
					  THEN 
						CASE WHEN Prpdi.ItcEligibility IS NOT NULL 
							 THEN (Cppdi.CessAmount * tilt.ItcPercentage / 100) 
							 ELSE (Cppdi.CessAmount * @UnfurnishedItcPercentageForGreaterRecords / 100) 
						END
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN
					 CASE WHEN Cppdi.IgstAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.IgstAmount IS NOT NULL THEN 1 ELSE 0 END 
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.CgstAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.CgstAmount IS NOT NULL THEN 1 ELSE 0 END 
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.SgstAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.SgstAmount IS NOT NULL THEN 1 ELSE 0 END 
			END,
			CASE WHEN @BaseType = @SourceTypeCounterPartyNotFiled 
				 THEN 
					CASE WHEN Cppdi.CessAmount IS NOT NULL THEN 1 ELSE 0 END 
				 ELSE 
					CASE WHEN Prpdi.CessAmount IS NOT NULL THEN 1 ELSE 0 END 
			END
		FROM 
			#TempPurchaseDocumentIdsForGreaterRecords tpd
			LEFT JOIN oregular.PurchaseDocumentItems Prpdi ON tpd.PrId = Prpdi.PurchaseDocumentId
			LEFT JOIN oregular.PurchaseDocumentItems Cppdi ON tpd.CpId = Cppdi.PurchaseDocumentId AND ISNULL(Prpdi.Hsn,0) = ISNULL(Cppdi.Hsn,0) AND Prpdi.Rate = Cppdi.Rate
			LEFT JOIN #TempItcForGreaterTaxAmount tilt ON Prpdi.ItcEligibility = tilt.ItcEligiblity
		WHERE
			(
				(
					@BaseType = @SourceTypeTaxpayer
					AND
					(ISNULL(Cppdi.ItcIgstAmount,0) + ISNULL(Cppdi.ItcCgstAmount,0) +  ISNULL(Cppdi.ItcSgstAmount,0) + ISNULL(Cppdi.ItcCessAmount,0)) > (ISNULL(Prpdi.IgstAmount,0) + ISNULL(Prpdi.CgstAmount,0) +  ISNULL(Prpdi.SgstAmount,0) + ISNULL(Prpdi.CessAmount,0))
				)
				OR
				(
					@BaseType = @SourceTypeCounterPartyNotFiled
					AND
					(ISNULL(Cppdi.IgstAmount,0) + ISNULL(Cppdi.CgstAmount,0) +  ISNULL(Cppdi.SgstAmount,0) + ISNULL(Cppdi.CessAmount,0)) < (ISNULL(Prpdi.ItcIgstAmount,0) + ISNULL(Prpdi.ItcCgstAmount,0) +  ISNULL(Prpdi.ItcSgstAmount,0) + ISNULL(Prpdi.ItcCessAmount,0))
				)
			);

		IF EXISTS(SELECT 1 FROM #TempPurchaseDocumentsForGreaterRecords)
		BEGIN

			UPDATE pdi
			SET
				ItcEligibility =  tpd.ItcEligiblity,
				ItcIgstAmount =  CASE WHEN pdi.IgstAmount IS NULL AND tpd.IsIgstNotNull = 1 
									  THEN tpd.ItcIgstAmount
									  WHEN pdi.IgstAmount IS NOT NULL AND tpd.IsIgstNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcIgstAmount END,
				ItcCgstAmount =  CASE WHEN pdi.CgstAmount IS NULL AND tpd.IsCgstNotNull = 1 
									  THEN tpd.ItcCgstAmount
									  WHEN pdi.CgstAmount IS NOT NULL AND tpd.IsCgstNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcCgstAmount END,
				ItcSgstAmount =  CASE WHEN pdi.SgstAmount IS NULL AND tpd.IsSgstNotNull = 1 
									  THEN tpd.ItcSgstAmount
									  WHEN pdi.SgstAmount IS NOT NULL AND tpd.IsSgstNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcSgstAmount END,
				ItcCessAmount =  CASE WHEN pdi.CessAmount IS NULL AND tpd.IsCessNotNull = 1 
									  THEN tpd.ItcCessAmount
									  WHEN pdi.CessAmount IS NOT NULL AND tpd.IsCessNotNull = 0 
									  THEN NULL 
									  ELSE tpd.ItcCessAmount END,
				ModifiedStamp = GETDATE()
			FROM 
				#TempPurchaseDocumentsForGreaterRecords tpd
				INNER JOIN oregular.PurchaseDocumentItems pdi ON tpd.DocumentItemId = pdi.Id

			SELECT 
				DISTINCT pdi.PurchaseDocumentId
			INTO 
				#TempPurchaseIdForGreaterRecords
			FROM
				oregular.PurchaseDocumentItems AS pdi
				INNER JOIN #TempPurchaseDocumentsForGreaterRecords AS tpdgr ON pdi.Id = tpdgr.DocumentItemId;

			DELETE 
			pdri
			FROM
				#TempPurchaseIdForGreaterRecords tpigr
				INNER JOIN oregular.PurchaseDocumentRateWiseItems pdri ON pdri.PurchaseDocumentId = tpigr.PurchaseDocumentId	

			INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
			(
				[PurchaseDocumentId]
				,[Rate]
				,[TaxableValue]
				,[IgstAmount]
				,[CgstAmount]
				,[SgstAmount]
				,[CessAmount]
			)
			SELECT
				pdi.PurchaseDocumentId,
				pdi.Rate,
				SUM(pdi.TaxableValue),
				SUM(pdi.IgstAmount),
				SUM(pdi.CgstAmount),
				SUM(pdi.SgstAmount),
				SUM(pdi.CessAmount)
			FROM
				#TempPurchaseIdForGreaterRecords tpigr
				INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpigr.PurchaseDocumentId
			GROUP BY 
				pdi.PurchaseDocumentId, pdi.Rate, pdi.ItcEligibility;

			DROP TABLE IF EXISTS #TempRecoItems3;
			SELECT
				pdi.PurchaseDocumentId,
				pdi.Rate,
				MAX(pdi.ItcEligibility) AS ItcEligibility,
				SUM(pdi.ItcIgstAmount) AS ItcIgstAmount,
				SUM(pdi.ItcCgstAmount) AS ItcCgstAmount,
				SUM(pdi.ItcSgstAmount) AS ItcSgstAmount,
				SUM(pdi.ItcCessAmount) AS ItcCessAmount
			INTO #TempRecoItems3
			FROM
				#TempPurchaseIdForGreaterRecords tpipr
				INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpipr.PurchaseDocumentId
			GROUP BY pdi.PurchaseDocumentId, pdi.Rate;

			UPDATE pdri
			SET pdri.ItcEligibility = tr.ItcEligibility,
				pdri.ItcIgstAmount = tr.ItcIgstAmount,
				pdri.ItcCgstAmount = tr.ItcCgstAmount,
				pdri.ItcSgstAmount = tr.ItcSgstAmount,
				pdri.ItcCessAmount = tr.ItcCessAmount,
				pdri.ModifiedStamp = GETDATE()
			FROM
				oregular.PurchaseDocumentRecoItems pdri
				INNER JOIN #TempRecoItems3 tr ON pdri.PurchaseDocumentRecoId = tr.PurchaseDocumentId AND pdri.Rate = tr.Rate;

			DROP TABLE IF EXISTS #tempReco3;
			SELECT
				ri.PurchaseDocumentRecoId,
				SUM(ri.ItcIgstAmount) AS ItcIgstAmount,
				SUM(ri.ItcCgstAmount) AS ItcCgstAmount,
				SUM(ri.ItcSgstAmount) AS ItcSgstAmount,
				SUM(ri.ItcCessAmount) AS ItcCessAmount
			INTO #tempReco3
			FROM
				#TempPurchaseIdForGreaterRecords tpigr
				INNER JOIN oregular.PurchaseDocumentRecoItems ri ON ri.PurchaseDocumentRecoId = tpigr.PurchaseDocumentId
			GROUP BY ri.PurchaseDocumentRecoId;

			--UPDATE r
			--	SET r.ItcIgstAmount = ISNULL(tr.ItcIgstAmount, 0),
			--		r.ItcCgstAmount = ISNULL(tr.ItcCgstAmount, 0),
			--		r.ItcSgstAmount = ISNULL(tr.ItcSgstAmount, 0),
			--		r.ItcCessAmount = ISNULL(tr.ItcCessAmount, 0)
			--FROM oregular.PurchaseDocumentReco r
			--INNER JOIN #tempReco3 tr ON r.Id = tr.PurchaseDocumentRecoId;
			DROP TABLE IF EXISTS #tempReco3;
		END
	END

	DROP TABLE 
		#TempPurchaseDocumentsForPrRecords,
		#TempPurchaseDocumentIdsForLesserRecords,
		#TempPurchaseDocumentsForLesserRecords,
		#TempPurchaseDocumentIdsForGreaterRecords,
		#TempPurchaseDocumentsForGreaterRecords,
		#TempItcForLesserTaxAmount,
		#TempItcForGreaterTaxAmount,
		#TempItcForPrTaxAmount;

END

GO
/*-----------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[oregular].[DeletePurchaseDocumentByIds]
* 	Comments			:	25-06-2020 | Rippal Patel | This procedure is used for Delete Purchase Documents by Ids.
							25-06-2020 | Dhurv Amin | Added logic related to delete not applicable records. 
							07-08-2020 | Faraaz Pathan | Removed Resultset for DocumentItems.
						:	09-02-2021 | Faraaz Pathan | Added IsAmendment field in select result.
-------------------------------------------------------------------------------------------------------------
*   Test Execution	    :	DECLARE @Ids [common].[BigIntType];
					
							EXEC [oregular].[DeletePurchaseDocumentByIds]
								@Ids =  @Ids,
								@SubscriberId  = 172,
								@DocumentStatusDeleted = 2,
								@PushToGstStatusRemovedButNotPushed = 3,
								@GstActionNoAction = 1,
								@GstActionUnlocked = 5,
								@ReconciliationMappingTypeExtended = 3
*/-----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[DeletePurchaseDocumentByIds]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @DocumentStatusDeleted SMALLINT,
	 @PushToGstStatusRemovedButNotPushed SMALLINT,
	 @GstActionNoAction SMALLINT,
	 @GstActionUnlocked SMALLINT,
	 @ReconciliationMappingTypeExtended SMALLINT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempPurchaseDocumentIds
	(
		Id BIGINT NOT NULL
	);
	CREATE TABLE #TempPurchaseDocumentIdsNotPushed
	(
		Id BIGINT NOT NULL
	);
	CREATE TABLE #TempPurchaseDocumentIdsPushed
	(
		Id BIGINT NOT NULL
	);

	INSERT INTO #TempPurchaseDocumentIds(Id)
	SELECT * FROM @Ids;

	CREATE CLUSTERED INDEX IDX_NON_#TempPurchaseDocumentIds_ID ON #TempPurchaseDocumentIds(ID);

	SELECT 
		pd.ParentEntityId AS EntityId,
		pd.ReturnPeriod,
		pd.SectionType,
		ps.ItcClaimReturnPeriod,
		CAST(Cast(pd.DocumentDate AS VARCHAR(10)) AS SMALLDATETIME) AS DocumentDate,
		pd.FinancialYear,
		pd.BillFromGstin,
		pd.IsAmendment,
		pd.TransactionType
	FROM 
		#TempPurchaseDocumentIds tpdi 
		INNER JOIN oregular.purchaseDocumentDW pd ON tpdi.Id = pd.Id
		INNER JOIN [oregular].[PurchaseDocumentStatus] ps ON ps.PurchaseDocumentId = pd.Id;

	INSERT INTO #TempPurchaseDocumentIdsNotPushed(
		Id
	)
	SELECT 
		tpdi.Id
	FROM 
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN [oregular].[PurchaseDocumentStatus] as ps	ON tpdi.Id = ps.PurchaseDocumentId
	WHERE
		ps.IsPushed = 0;

	INSERT INTO #TempPurchaseDocumentIdsPushed(
		Id
	)
	SELECT 
		tpdi.Id
	FROM 
		#TempPurchaseDocumentIds AS tpdi
		INNER JOIN [oregular].[PurchaseDocumentStatus] as ps ON tpdi.Id = ps.PurchaseDocumentId
	WHERE
		ps.IsPushed = 1;
	
	IF EXISTS (SELECT Id FROM #TempPurchaseDocumentIdsPushed)
	BEGIN
		UPDATE ps
		SET 
			[Status] = @DocumentStatusDeleted,
			[PushStatus] = @PushToGstStatusRemovedButNotPushed,
			Errors = NULL,
			ModifiedStamp = GETDATE()
		FROM
			[oregular].[PurchaseDocumentStatus] ps
			INNER JOIN #TempPurchaseDocumentIdsPushed tpdip ON ps.PurchaseDocumentId = tpdip.Id;

		--UPDATE dw
		--SET 
		--	[Status] = @DocumentStatusDeleted,
		--	[PushStatus] = @PushToGstStatusRemovedButNotPushed,
		--	Errors = NULL
		--FROM
		--	oregular.purchaseDocumentDW dw
		--	INNER JOIN #TempPurchaseDocumentIdsPushed tpdip ON dw.ID = tpdip.Id;
	END
	
	IF EXISTS (SELECT Id FROM #TempPurchaseDocumentIdsNotPushed)
	BEGIN
		
		-- Records for which action is Accepted or pending should not be deleted
		DELETE 
			tpdip 
		FROM 
			#TempPurchaseDocumentIdsNotPushed tpdip
			LEFT JOIN [oregular].[PurchaseDocumentStatus] ps ON tpdip.Id = ps.PurchaseDocumentId
		WHERE
			ps.Gstr2bAction IS NOT NULL
			AND ps.Gstr2bAction <> @GstActionNoAction;
		
		DELETE
			pdr
		FROM 
			oregular.PurchaseDocumentReferences pdr
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdinp ON tpdinp.Id = pdr.PurchaseDocumentId

		DELETE
			pdrwi
		FROM 
			oregular.PurchaseDocumentRateWiseItems pdrwi
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdinp ON tpdinp.Id = pdrwi.PurchaseDocumentId

		DELETE
			pdi
		FROM 
			oregular.PurchaseDocumentItems pdi
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdinp ON tpdinp.Id = pdi.PurchaseDocumentId

		DELETE
			ps
		FROM 
			[oregular].[PurchaseDocumentStatus] ps
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdinp ON tpdinp.Id = ps.PurchaseDocumentId

		DELETE
			pdc
		FROM 
			#TempPurchaseDocumentIdsNotPushed tpdinp
			LEFT JOIN oregular.PurchaseDocumentContacts pdc ON tpdinp.Id = pdc.PurchaseDocumentId

		DELETE
			pdp
		FROM 
			#TempPurchaseDocumentIdsNotPushed tpdinp
			LEFT JOIN oregular.PurchaseDocumentPayments pdp ON tpdinp.Id = pdp.PurchaseDocumentId

		DELETE
			pdc
		FROM 
			#TempPurchaseDocumentIdsNotPushed tpdinp
			LEFT JOIN oregular.PurchaseDocumentCustoms pdc ON tpdinp.Id = pdc.PurchaseDocumentId
	
		DELETE
			pdsd
		FROM 
			#TempPurchaseDocumentIdsNotPushed tpdinp
			INNER JOIN oregular.PurchaseDocumentSignedDetails pdsd ON tpdinp.Id = pdsd.PurchaseDocumentId
	
		DELETE
			pd
		FROM 
			oregular.PurchaseDocuments pd
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdinp ON tpdinp.Id = pd.Id

	
		DELETE
			dw
		FROM 
			oregular.purchaseDocumentDW dw
			INNER JOIN #TempPurchaseDocumentIdsNotPushed tpdinp ON tpdinp.Id = dw.Id
	END

	/* Update status in reconciliation tables for processing effect of delete on reconciliation. After next
	   call for reconciliation these deleted records will get reflected on reconciliation page as well.
	*/

	EXEC [oregular].[DeletePurchaseDocumentForRecoByIds]
		@DocumentStatusDeleted = @DocumentStatusDeleted,
		@ReconciliationMappingTypeExtended = @ReconciliationMappingTypeExtended

	DROP TABLE #TempPurchaseDocumentIds, #TempPurchaseDocumentIdsNotPushed, #TempPurchaseDocumentIdsPushed;

END
GO

/*-----------------------------------------------------------------------------------------------------
* 	Procedure Name	:	 [oregular].[DeleteSaleDocumentByIds]
* 	Comment			:	 24/06/2020 | Rippal Patel | This procedure is used to Delete Sales Documents by Ids.
					:	 28/07/2020 | Pooja Rajpurohit | Renamed table name to SaledocumentDw.
					:	 05/08/2020 | Abhishek Shrivas | Replace SaleStatus table with SaledocumentDw. 
					:	 07-08-2020 | Faraaz Pathan | Removed Resultset for DocumentItems. 
					:	 09-02-2021 | Faraaz Pathan | Added IsAmendment field in select result.
					:	 12-02-2021 | Faraaz Pathan | Added TransactionType field in select result.
--------------------------------------------------------------------------------------------------------
*  Test Execution   :	DECLARE @Ids [common].[BigIntType];
											
						INSERT INTO @Ids VALUES(752);
								
						EXEC [oregular].[DeleteSaleDocumentByIds]
							@Ids = @Ids,
							@SubscriberId  = 172,
							@DocumentStatusDeleted = 2,
							@PushToGstStatusRemovedButNotPushed = 3,
							@GstActionAccepted = 2,
							@GstActionPending = 4
--------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[DeleteSaleDocumentByIds]
(
	@Ids [common].[BigIntType] READONLY,
	@SubscriberId INT,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@DocumentStatusDeleted SMALLINT,
	@PushToGstStatusRemovedButNotPushed SMALLINT,
	@GstActionAccepted SMALLINT,
	@GstActionPending SMALLINT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempSaleDocumentIds
	(
		Id BIGINT NOT NULL
	);
	CREATE CLUSTERED INDEX IDX_TempSaleDocumentIds_Id ON #TempSaleDocumentIds(Id);

	CREATE TABLE #TempSaleDocumentIdsNotPushed
	(
		AutoId BIGINT IDENTITY(1,1) NOT NULL,
		Id BIGINT NOT NULL
	);
	CREATE NONCLUSTERED INDEX Idx_TempSaleDocumentIdsNotPushed_Id ON #TempSaleDocumentIdsNotPushed(Id);

	CREATE TABLE #TempSaleDocumentIdsPushed(
		Id BIGINT NOT NULL
	)
	INSERT INTO #TempSaleDocumentIds(Id)
	SELECT * FROM @Ids;
	
	SELECT 
		sd.ParentEntityId,
		sd.ReturnPeriod,
		sd.SectionType,
		sd.ECommerceGstin,
		ss.LiabilityDischargeReturnPeriod,
		CONVERT(SMALLDATETIME,CAST(sd.DocumentDate as VARCHAR),112) DocumentDate,
		sd.IsAmendment,
		sd.TransactionType
	FROM 
		#TempSaleDocumentIds tsdi 
		INNER JOIN oregular.SaleDocumentDW sd ON tsdi.Id = sd.Id
		INNER JOIN oregular.SaleDocumentStatus ss ON ss.SaleDocumentId = sd.Id;

	INSERT INTO #TempSaleDocumentIdsNotPushed(
		Id
	)
	SELECT
		tsdi.Id
	FROM
		#TempSaleDocumentIds AS tsdi
		INNER JOIN oregular.SaleDocumentStatus AS ss ON tsdi.Id = ss.SaleDocumentId
	WHERE 
		ss.IsPushed = 0
		AND ss.IsAutoDrafted = 0;

	INSERT INTO #TempSaleDocumentIdsPushed(
		Id
	)
	SELECT
		tsdi.Id
	FROM
		#TempSaleDocumentIds AS tsdi
		INNER JOIN oregular.SaleDocumentStatus AS ss ON tsdi.Id = ss.SaleDocumentId
	WHERE 
		ss.IsPushed = 1
		OR ss.IsAutoDrafted = 1;
	
	IF EXISTS (SELECT Id FROM #TempSaleDocumentIdsPushed)
	BEGIN

		UPDATE ss
		SET
			[Status] = (CASE WHEN ss.IsPushed = 1 THEN @DocumentStatusDeleted ELSE ss.[Status] END),
			PushStatus = @PushToGstStatusRemovedButNotPushed,
			Errors = null,
			ModifiedStamp = GETDATE()
		FROM
			oregular.SaleDocumentStatus ss
			INNER JOIN #TempSaleDocumentIdsPushed tsdip ON ss.SaleDocumentId = tsdip.Id;

	END

	IF EXISTS (SELECT Id FROM #TempSaleDocumentIdsNotPushed)
	BEGIN
		DECLARE @Min INT = 1, @Max INT, @BatchSize INT , @Records INT
		
		SELECT 
			@Max = COUNT(AutoId) 
		FROM #TempSaleDocumentIdsNotPushed

		SELECT @Batchsize = CASE WHEN ISNULL(@Max,0) > 100000 
							THEN  ((@Max*10)/100)
							ELSE @Max
							END
		WHILE(@Min <= @Max)
		BEGIN 
			
			SET @Records = @Min + @BatchSize
			DELETE sdr
			FROM 
				oregular.SaleDocumentReferences sdr
				INNER JOIN  #TempSaleDocumentIdsNotPushed tspinp ON tspinp.Id = sdr.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sdrwi
			FROM 
				oregular.SaleDocumentRateWiseItems sdrwi
				INNER JOIN  #TempSaleDocumentIdsNotPushed tspinp ON tspinp.Id = sdrwi.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sdi
			FROM 
				oregular.SaleDocumentItems sdi
				INNER JOIN  #TempSaleDocumentIdsNotPushed tspinp ON tspinp.Id = sdi.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;
	
			DELETE ss
			FROM 
				oregular.SaleDocumentStatus ss
				INNER JOIN #TempSaleDocumentIdsNotPushed tspinp ON tspinp.Id = ss.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sdc
			FROM 
				#TempSaleDocumentIdsNotPushed tspinp
				LEFT JOIN oregular.SaleDocumentContacts sdc ON tspinp.Id = sdc.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sdp
			FROM 
				#TempSaleDocumentIdsNotPushed tspinp 
				LEFT JOIN oregular.SaleDocumentPayments sdp ON tspinp.Id = sdp.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sdc
			FROM 
				#TempSaleDocumentIdsNotPushed tspinp
				LEFT JOIN oregular.SaleDocumentCustoms sdc ON tspinp.Id = sdc.SaleDocumentId
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sd
			FROM 
				oregular.SaleDocuments sd
				INNER JOIN #TempSaleDocumentIdsNotPushed tspinp ON tspinp.Id = sd.Id
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;

			DELETE sd
			FROM 
				oregular.SaleDocumentDW sd
				INNER JOIN #TempSaleDocumentIdsNotPushed tspinp ON tspinp.Id = sd.Id
			WHERE tspinp.AutoId BETWEEN @Min AND @Records;				
			
			SET @Min = @Records
		END
	END

	DROP TABLE #TempSaleDocumentIds, #TempSaleDocumentIdsPushed, #TempSaleDocumentIdsNotPushed;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[DelinkReconciliationDocumentManual] 
* 	Comments			: 05-04-2024 | Udit Solanki	| Delink Reconciliation Document Manually
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
DECLARE @ManualMapperIds AS Common.[BigIntType],
		@ExcludedGstin AS [oregular].[FinancialYearWiseGstinType],
		@AuditTrailDetails AS [audit].[AuditTrailDetailsType],
		@JSON1 VARCHAR(MAX)='[{"Item":191}]',
		@JSON2 VARCHAR(MAX)='[{"FinancialYear":201718,"Gstin":"50"},{"FinancialYear":201819,"Gstin":"50"},{"FinancialYear":202324,"Gstin":"50"},{"FinancialYear":202425,"Gstin":"50"}]';
								  
INSERT INTO @ManualMapperIds
SELECT * FROM OPENJSON(@JSON1)
WITH (Item INT '$.Item');

INSERT INTO @ExcludedGstin
SELECT * FROM OPENJSON(@JSON2)
WITH (FinancialYear INT '$.FinancialYear',
	  Gstin VARCHAR(15) '$.Gstin')
						  
EXEC oregular.DelinkReconciliationDocumentManual
	@ManualMapperIds=@ManualMapperIds,
	@ExcludedGstin=@ExcludedGstin,
	@ReconciliationType=8,
	@AuditTrailDetails=@AuditTrailDetails,
	@ReconciliationMappingTypeTillDate=4,
	@ReconciliationSectionTypePRExcluded=7,
	@ReconciliationSectionTypeGstExcluded=8,
	@ReconciliationSectionTypePROnly=1,
	@ReconciliationSectionTypeGstOnly=2,
	@ActionTypeNoAction=1,
	@ReconciliationStatusActionsNotTaken=1,
	@ReconciliationTypeGstr2b=8;

*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[DelinkReconciliationDocumentManual](
	@ManualMapperIds AS [common].[BigIntType] READONLY,
	@ExcludedGstin AS [oregular].[FinancialYearWiseGstinType] READONLY,
	@ActionTypeNoAction smallint,
	@ReconciliationStatusActionsNotTaken smallint,
	@ReconciliationType smallint,
	@AuditTrailDetails AS [audit].[AuditTrailDetailsType] READONLY,
	@ReconciliationTypeGstr2b TINYINT,
	@ReconciliationSectionTypePrOnly TINYINT,
	@ReconciliationSectionTypeGstOnly TINYINT,
	@ReconciliationMappingTypeTillDate TINYINT,
	@ReconciliationSectionTypePrExcluded TINYINT,
	@ReconciliationSectionTypeGstExcluded TINYINT)

AS
BEGIN	
DECLARE 
	@RPFinancialYear  INT,
	@DocumentFinancialYear  INT,
	@ParentEntityId  INT,
	@ReconciliationMappingType  SMALLINT,
	@Reason  VARCHAR(500);

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC audit.UpdateAuditDetails
				@AuditTrailDetails;
	END;

	/* Temp table to store Excluded Gstin */
	DROP TABLE IF EXISTS #ExcludedGstin,#ManualMapperIds;
	CREATE TABLE #ExcludedGstin(
		FinancialYear INT NOT NULL,
		Gstin VARCHAR(15) NOT NULL
	);

	/* Temp table to store manual mapper Ids */
	CREATE TABLE #ManualMapperIds (
		ManualMapperId BIGINT NOT NULL
	);

	/* Create clustered index on PurchaseDocumentMapperID for fter retrieval */
	CREATE CLUSTERED INDEX IDX_ManualMapperIds_PurchaseDocumentMapperId ON #ManualMapperIds(ManualMapperId);

	/* Temp table to store PR Ids */
	CREATE TABLE #PrIds (
		PrId BIGINT NOT NULL
	);
	
	/* Create clustered index on PrId for fter retrieval */
	CREATE CLUSTERED INDEX IDX_PrIds_PrId ON #PrIds(PrId);

	/* Temp table to store PR Ids */
	CREATE TABLE #GstIds (
		GstId BIGINT NOT NULL
	);
	/* Create clustered index on GstId for fter retrieval */
	CREATE CLUSTERED INDEX IDX_GstIds_GstId ON #GstIds(GstId);
	
	/* Get Excluded Gstin data */
	INSERT INTO #ExcludedGstin(FinancialYear,Gstin)
	SELECT FinancialYear, Gstin FROM @ExcludedGstin ;

	/* Insert data in ManualMapperIds form @ManualMapperIds table type */
	INSERT INTO #ManualMapperIds(ManualMapperId)
	SELECT * FROM @ManualMapperIds;

	/* Get All PrIds for DeLink */
	INSERT INTO #PrIds(PrId)
	SELECT
		Pr.PrId
	FROM
		oregular.PurchaseDocumentRecoManualMapper PDRMM
		INNER JOIN #ManualMapperIds MMIds ON PDRMM.Id = MMIds.ManualMapperId
		OUTER APPLY OPENJSON(PrIds) WITH(PrId BIGINT '$.PrId')AS Pr;

	/* Get All GstIds for DeLink */
	INSERT INTO #GstIds(GstId)
	SELECT
		 Gst.GstId
	FROM
		oregular.PurchaseDocumentRecoManualMapper PDRMM
		INNER JOIN #ManualMapperIds MMIds ON PDRMM.Id = MMIds.ManualMapperId
		OUTER APPLY OPENJSON(GstIds) WITH(GstId BIGINT '$.GstId') AS Gst;
			
	/* Insert data in old reco section */
	IF (@ReconciliationType = @ReconciliationTypeGstr2b)
	BEGIN
		INSERT INTO Oregular.Gstr2bDocumentRecoMapper
		(			
			DocumentFinancialYear,
			PrId,
			GstnId,			
			SectionType,			
			MappingType,
			Reason,
			ReasonType,
			IsCrossHeadTax,		
			SessionId,
			PrReturnPeriodDate,
			Gstr2BReturnPeriodDate
		)
		SELECT			
			PDR.DocumentFinancialYear AS DocumentFinancialYear,
			PDR.Id AS PrId,
			NULL AS GstnId,
			@ReconciliationSectionTypePrOnly AS SectionType,
			@ReconciliationMappingTypeTillDate AS MappingType,
			NULL AS Reason,
			NULL AS ReasonType,
			0 AS IsCrossHeadTax,
			-1 AS SessionId,
			CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LEN(PDR.ReturnPeriod) = 6 THEN LEFT(PDR.ReturnPeriod,2) ELSE CONCAT('0',LEFT(PDR.ReturnPeriod,1)) END, '01') AS ReturnPeriodDate, 
			NULL
		FROM
			#PrIds PrIds
			INNER JOIN oregular.PurchaseDocumentDW PDR ON PrIds.PrId = PDR.Id
			LEFT JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON PDRM.PrId = PDR.Id AND MappingType = @ReconciliationMappingTypeTillDate
		WHERE PDRM.Id IS NULL;

		/* Insert data in old reco section */
		INSERT INTO Oregular.Gstr2bDocumentRecoMapper
		(
			DocumentFinancialYear,
			PrId,
			GstnId,
			SectionType,
			MappingType,
			Reason,
			ReasonType,
			IsCrossHeadTax,
			SessionId,
			PrReturnPeriodDate,
			Gstr2BReturnPeriodDate
		)
		SELECT
			PDR.DocumentFinancialYear AS DocumentFinancialYear,
			NULL AS PrId,
			PDR.Id AS GstnId,
			@ReconciliationSectionTypeGstOnly SectionType,
			@ReconciliationMappingTypeTillDate AS MappingType,
			NULL AS Reason,
			NULL AS ReasonType,
			0 AS IsCrossHeadTax,
			-1 AS SessionId,
			NULL,
			CASE WHEN r_ps.Gstr2BReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(r_ps.Gstr2BReturnPeriod,4), CASE WHEN LEN(r_ps.Gstr2BReturnPeriod) = 6 THEN LEFT(r_ps.Gstr2BReturnPeriod,2) ELSE CONCAT('0',LEFT(r_ps.Gstr2BReturnPeriod,1) ) END , '01') ELSE NULL END
		FROM
			#GstIds GstIds
			INNER JOIN oregular.PurchaseDocumentDW PDR ON GstIds.GstId = PDR.Id
			INNER JOIN oregular.PurchaseDocumentStatus r_ps ON r_ps.PurchaseDocumentId = PDR.Id
			LEFT JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON PDRM.GstnId = PDR.Id AND MappingType = @ReconciliationMappingTypeTillDate
		WHERE PDRM.Id IS NULL
			--NOT EXISTS (SELECT 1 FROM oregular.PurchaseDocumentRecoMapper PDRM WHERE PDRM.GstnId = PDR.Id AND MappingType = @ReconciliationMappingTypeMonthly)
		;
		/* Set IsReconciled = 0 in PurchaseStatus table  for re-run reco */
		UPDATE 
			PDR
		SET PDR.IsReconciled = 0,
		    PDR.Gstr2bAction = @ActionTypeNoAction
		FROM
			#PrIds PrIds
		INNER JOIN oregular.PurchaseDocumentStatus PDR ON PrIds.PrId = PDR.PurchaseDocumentId;
			
		/* Set IsReconciled = 0 in PurchaseStatus table  for re-run reco */
		UPDATE 
			PDR
		SET PDR.IsReconciled = 0,
			PDR.Gstr2bAction = @ActionTypeNoAction
		FROM
			#GstIds GstIds
			INNER JOIN oregular.PurchaseDocumentStatus PDR ON GstIds.GstId = PDR.PurchaseDocumentId;			
	END
	ELSE
	BEGIN
		INSERT INTO Oregular.Gstr2aDocumentRecoMapper
		(
			 DocumentFinancialYear
			,PrId
			,GstnId
			,SectionType
			,MappingType
			,Reason
			,ReasonType
			,IsCrossHeadTax
			,SessionId
			,Stamp
			,ModifiedStamp
			,IsAvailableInGstr2b
			,PrReturnPeriodDate
			,GstnReturnPeriodDate
		)
		SELECT
			PDR.DocumentFinancialYear  DocumentFinancialYear,
			PDR.Id  PrId,
			NULL  GstnId,
			CASE WHEN EG.Gstin IS NULL THEN @ReconciliationSectionTypePrOnly ELSE @ReconciliationSectionTypePrExcluded END  SectionType,
			@ReconciliationMappingTypeTillDate AS MappingType,			
			NULL  Reason,
			NULL  ReasonType,
			0 IsCrossHeadTax,
			-1  SessionId,
			GETDATE() AS Stamp,
			GETDATE() AS ModifiedStamp,
			NULL IsAvailableInGstr2b,
			CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LEN(PDR.ReturnPeriod) = 6 THEN LEFT(PDR.ReturnPeriod,2) ELSE CONCAT('0',LEFT(PDR.ReturnPeriod,1)) END, '01') AS  PrReturnPeriodDate,
			NULL GstnReturnPeriodDate
		FROM
			#PrIds PrIds
			INNER JOIN oregular.PurchaseDocumentDW PDR ON PrIds.PrId = PDR.Id
			LEFT JOIN #ExcludedGstin EG ON EG.Gstin = PDR.BillFromGstin AND EG.FinancialYear = PDR.FinancialYear
			LEFT JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON PDRM.PrId = PDR.Id 
		WHERE PDRM.Id IS NULL;
		
		/* Insert data in old reco section */
		INSERT INTO Oregular.Gstr2aDocumentRecoMapper
		(
			DocumentFinancialYear,
			PrId,
			GstnId,
			SectionType,
			MappingType,
			Reason,
			ReasonType,
			IsCrossHeadTax,
			SessionId,
			Stamp,
			ModifiedStamp,
			IsAvailableInGstr2b,
			PrReturnPeriodDate,
			GstnReturnPeriodDate
		)
		SELECT
			PDR.DocumentFinancialYear  DocumentFinancialYear,
			NULL  PrId,
			PDR.Id  GstnId,
			CASE WHEN EG.Gstin IS NULL THEN @ReconciliationSectionTypeGstOnly ELSE @ReconciliationSectionTypeGstExcluded END  SectionType,			
			@ReconciliationMappingTypeTillDate AS MappingType,			
			NULL  Reason,
			NULL  ReasonType,
			0  IsCrossHeadTax,
			-1  SessionId,
			GETDATE() Stamp,
			GETDATE() ModifiedStamp,
			IsAvailableInGstr2b,
			NULL PrReturnPeriodDate,
			CONCAT(RIGHT(PDR.ReturnPeriod,4), CASE WHEN LEN(PDR.ReturnPeriod) = 6 THEN LEFT(PDR.ReturnPeriod,2) ELSE CONCAT('0',LEFT(PDR.ReturnPeriod,1)) END, '01') AS GstnReturnPeriodDate
		FROM
			#GstIds GstIds
			INNER JOIN oregular.PurchaseDocumentDW PDR ON GstIds.GstId = PDR.Id
			LEFT JOIN #ExcludedGstin EG ON EG.Gstin = PDR.BillFromGstin AND EG.FinancialYear = PDR.FinancialYear
			LEFT JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON PDRM.GstnId = PDR.Id 
		WHERE PDRM.Id IS NULL;
		
		
		/* Set IsReconciled = 0 in PurchaseStatus table  for re-run reco */
		UPDATE pdr
			SET pdr.IsReconciled = 0 ,	
				pdr.Action = @ActionTypeNoAction,
				pdr.ReconciliationStatus = @ReconciliationStatusActionsNotTaken
		FROM
			#PrIds PrIds
			INNER JOIN oregular.PurchaseDocumentStatus pdr ON PrIds.PrId = pdr.PurchaseDocumentId;
		   
		/* Set IsReconciled = 0 in PurchaseStatus table  for re-run reco */
		UPDATE
			PDR
			SET PDR.IsReconciled = 0,				
				PDR.Action = @ActionTypeNoAction,
				PDR.ReconciliationStatus = @ReconciliationStatusActionsNotTaken		   
		FROM
			#GstIds GstIds
			INNER JOIN oregular.PurchaseDocumentStatus PDR ON GstIds.GstId = PDR.PurchaseDocumentId;
						
	END;
 
	/* Get Data for re-run reco for link-data */
	
	SELECT DISTINCT
		PDRMM.SubscriberId,
		PDRMM.ParentEntityId  EntityId,
		PDRMM.RPFinancialYear  FinancialYear
	FROM
		oregular.PurchaseDocumentRecoManualMapper PDRMM
		INNER JOIN #ManualMapperIds MMIds ON PDRMM.Id = MMIds.ManualMapperId;
	
	
	/* Delete record from PurchaseDocumentRecoManualMapper table */
	DELETE PDRMM
	FROM
		oregular.PurchaseDocumentRecoManualMapper PDRMM
		INNER JOIN #ManualMapperIds MMIds ON PDRMM.Id = MMIds.ManualMapperId;
												
	/* Drop temp tables */
	DROP TABLE IF EXISTS EXISTS#GstIds, #PrIds;

END;

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
CREATE PROCEDURE [oregular].[InsertDownloadedSaleDocuments]
(
	@SubscriberId INT,
	@UserId INT,
	@EntityId INT,
	@ReturnPeriod INT,
	@FinancialYear INT,
	@AutoSync BIT,
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
	@PushToGstStatusUploadedButNotPushed SMALLINT,
	@PushToGstStatusPushed SMALLINT,
	@PushToGstStatusCancelled SMALLINT,
	@SourceTypeAutoDraft SMALLINT,
	@SourceTypeTaxpayer SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@TaxTypeTAXABLE SMALLINT,
	@ContactTypeBillTo SMALLINT,
	@PushToGstStatusDeleted SMALLINT
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
		Mode CHAR(2)
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
	AU : AutoDrafted Record Overwrite.
	C : Cancelled record, Cancelling AutoPopulated records
	F : Update IsAutoDrafted = 0, Because Deleted records are overwrited by user
	S : Skip overwriting, Because Record is not autodrafted status anymore
	*/
	INSERT INTO #TempSaleDocumentIds
	(
		Id,
		GroupId,
		Mode,
		BillingDate,
		SourceType
	)
	SELECT
	   sd.Id,
	   tsd.GroupId,
	   CASE 
			WHEN @SourceType = @SourceTypeAutoDraft THEN 'U'
			WHEN @SourceType = @SourceTypeTaxpayer AND @AutoSync = @False THEN 'U' 
			WHEN @SourceType = @SourceTypeTaxpayer AND @AutoSync = @True AND ss.IsPushed = @True AND tsd.PushStatus = @PushToGstStatusPushed AND ss.PushStatus = @PushToGstStatusPushed AND ISNULL(tsd.AutoDraftSource,'') = ISNULL(ss.AutoDraftSource,'') THEN 'AU'
			WHEN @SourceType = @SourceTypeTaxpayer AND @AutoSync = @True AND ss.IsAutoDrafted = @True AND ss.IsPushed = @True AND tsd.PushStatus = @PushToGstStatusCancelled AND ss.PushStatus = @PushToGstStatusPushed THEN 'C'
			WHEN @SourceType = @SourceTypeTaxpayer AND @AutoSync = @True AND ss.IsAutoDrafted = @True AND ss.IsPushed = @True AND tsd.PushStatus = @PushToGstStatusCancelled THEN 'F' 
			ELSE 'S'
	   END,
	   ISNULL(ss.BillingDate,@CurrentDate),
	   sd.SourceType
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
		inserted.Id, inserted.GroupId, 'I', @CurrentDate, inserted.SourceType
	INTO 
		#TempSaleDocumentIds(Id, GroupId, Mode, BillingDate, SourceType)
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
			--SectionType = CASE WHEN sd.SectionType & @SectionType <> 0 THEN sd.SectionType ELSE sd.SectionType | @SectionType END, // As Discussed with abbas bhai reccord will b persisted in document and summary that will be wrong
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
			IsAutoDrafted = CASE WHEN ss.IsAutoDrafted = @True AND @SourceType = @SourceTypeTaxpayer AND @AutoSync = @False AND tsd.[Checksum] = ss.[Checksum] THEN ss.IsAutoDrafted ELSE tsd.IsAutoDrafted END, --Handled condition for overwriting IsAutoDrafted flag in case of manaul gstr1 sync.
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
			AND d.SectionType IS NOT NULL;
			
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
	
	/* Condition For update sale data which are not on gst portal but exists in system in pushed state */
	IF (@AutoSync = @False AND @SourceType = @SourceTypeTaxpayer)
	BEGIN
		UPDATE
			ss
		SET
			ss.PushStatus = @PushToGstStatusUploadedButNotPushed,
			ss.IsPushed = @False,
			ss.IsAutoDrafted = @False,
			ss.LastSyncDate = @CurrentDate,
			ss.ModifiedStamp = @CurrentDate
		OUTPUT 
			INSERTED.SaleDocumentId
		INTO 
			#TempUpsertDocumentIds(ID)	
		FROM
			 oregular.SaleDocumentDW AS dw
			 INNER JOIN oregular.SaleDocumentStatus AS ss ON ss.SaleDocumentId = dw.Id 
			 LEFT JOIN #TempSaleDocumentIds AS tsdi ON tsdi.Id = dw.Id 
		WHERE
			dw.SubscriberId = @SubscriberId
			AND dw.EntityId = @EntityId
			AND dw.ReturnPeriod = @ReturnPeriod
			AND dw.SectionType & @SectionType <> 0
			AND dw.IsAmendment = @IsAmendment
			AND dw.SourceType = @SourceTypeTaxpayer
			AND ss.IsPushed = @True
			AND tsdi.Id IS NULL;
			--AND dw.BillToGstin = ISNULL(@Gstin, dw.BillToGstin)
	END

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
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertGstr2aReconciliationDocuments]
* 	Comments			: 28/02/2022 | Pooja Rajpurohit | SP to validate Gstr2aReconciliationDocuments.					
*	Review Comment		: 
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 	
					DECLARE  @ValSetting AS oregular.ValidateGstr2aReconciliationDocumentType,@ExcludedGstin AS Oregular.[FinancialYearWiseGstinType],
							 @AuditTrailDetails AS [audit].AuditTrailDetailsType;

							INSERT INTO @ValSetting
							SELECT
									*
							FROM 
							OPENJSON('[{"ParentEntityId":947,"PrDocumentType":1,"PrDocumentNumber":"AB/XGST/1","PrDocumentDate":"2024-01-07T00:00:00","PrGstin":"37GEOPS0823B2ZE","PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":null,"CpDocumentNumber":null,"CpDocumentDate":null,"CpGstin":null,"CpPortCode":null,"CpIsAmendment":false,"GroupKey":196,"ManualReconciliation":true,"RecordName":null,"Source":"2B","Type":null,"FinancialYear":202324,"ReconciliationSection":3,"Action":2,"ItcClaimReturnPeriod":null,"GroupId":1},{"ParentEntityId":947,"PrDocumentType":null,"PrDocumentNumber":null,"PrDocumentDate":null,"PrGstin":null,"PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":1,"CpDocumentNumber":"APTB2B1","CpDocumentDate":"2023-07-17T00:00:00","CpGstin":"37GEOPS0823B2ZE","CpPortCode":null,"CpIsAmendment":false,"GroupKey":196,"ManualReconciliation":true,"RecordName":null,"Source":"2B","Type":null,"FinancialYear":202324,"ReconciliationSection":3,"Action":2,"ItcClaimReturnPeriod":62023,"GroupId":1},{"ParentEntityId":947,"PrDocumentType":null,"PrDocumentNumber":null,"PrDocumentDate":null,"PrGstin":null,"PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":1,"CpDocumentNumber":"APTB2B2","CpDocumentDate":"2023-07-17T00:00:00","CpGstin":"37GEOPS0823B2ZE","CpPortCode":null,"CpIsAmendment":false,"GroupKey":196,"ManualReconciliation":true,"RecordName":null,"Source":"2B","Type":null,"FinancialYear":202324,"ReconciliationSection":3,"Action":2,"ItcClaimReturnPeriod":62023,"GroupId":1},{"ParentEntityId":947,"PrDocumentType":null,"PrDocumentNumber":null,"PrDocumentDate":null,"PrGstin":null,"PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":1,"CpDocumentNumber":"APTB2B45","CpDocumentDate":"2023-07-17T00:00:00","CpGstin":"37GEOPS0823B2ZE","CpPortCode":null,"CpIsAmendment":false,"GroupKey":196,"ManualReconciliation":true,"RecordName":null,"Source":"2B","Type":null,"FinancialYear":202324,"ReconciliationSection":3,"Action":2,"ItcClaimReturnPeriod":null,"GroupId":1},{"ParentEntityId":947,"PrDocumentType":2,"PrDocumentNumber":"PR/ONLY/3","PrDocumentDate":"2024-01-07T00:00:00","PrGstin":"37GEOPS0823B2ZE","PrPortCode":null,"PrIsAmendment":false,"CpDocumentType":null,"CpDocumentNumber":null,"CpDocumentDate":null,"CpGstin":null,"CpPortCode":null,"CpIsAmendment":false,"GroupKey":196,"ManualReconciliation":true,"RecordName":null,"Source":"2B","Type":null,"FinancialYear":202324,"ReconciliationSection":3,"Action":2,"ItcClaimReturnPeriod":null,"GroupId":1}]')
							WITH
							(
							ParentEntityId int '$.ParentEntityId'
							,PrDocumentType smallint '$.PrDocumentType'
							,PrDocumentNumber varchar(40) '$.PrDocumentNumber'
							,PrDocumentDate datetime '$.PrDocumentDate'
							,PrGstin varchar(15) '$.PrGstin'
							,PrPortCode varchar(6) '$.PrPortCode'
							,PrIsAmendment bit '$.PrIsAmendment'
							,CpDocumentType smallint '$.CpDocumentType'
							,CpDocumentNumber varchar(40) '$.CpDocumentNumber'
							,CpDocumentDate datetime '$.CpDocumentDate'
							,CpGstin varchar(15) '$.CpGstin'
							,CpPortCode varchar(6) '$.CpPortCode'
							,CpIsAmendment bit '$.CpIsAmendment'
							,GroupKey int '$.GroupKey'
							,ManualReconciliation bit '$.ManualReconciliation'
							,RecordName varchar(50) '$.RecordName'
							,Source char(3) '$.Source'
							,Type smallint '$.Type'
							,FinancialYear int '$.FinancialYear'
							,ReconciliationSection smallint '$.ReconciliationSection'
							,Action smallint '$.Action'
							,ItcClaimReturnPeriod int '$.ItcClaimReturnPeriod'
							,GroupId int '$.GroupId'
							)
							
							select * from @ValSetting
							;
							
							DECLARE @TempSetting AS oregular.GetReconciliationSettingForInsertResponseType;
							INSERT INTO @TempSetting
							SELECT 
								*
							FROM 
								OPENJSON('[{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":true,"MatchByToleranceDocumentValueFrom":-5.00,"MatchByToleranceDocumentValueTo":5.00,"MatchByToleranceTaxableValueFrom":-5.00,"MatchByToleranceTaxableValueTo":5.00,"MatchByToleranceTaxAmountsFrom":-5.00,"MatchByToleranceTaxAmountsTo":5.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":true,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":201718,"FilingExtendedDate":"2020-03-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":201819,"FilingExtendedDate":"2020-03-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":201920,"FilingExtendedDate":"2021-03-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":true,"MatchByToleranceDocumentValueFrom":-111.00,"MatchByToleranceDocumentValueTo":111.00,"MatchByToleranceTaxableValueFrom":-111.00,"MatchByToleranceTaxableValueTo":111.00,"MatchByToleranceTaxAmountsFrom":-111.00,"MatchByToleranceTaxAmountsTo":111.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-200.00,"NearMatchToleranceDocumentValueTo":200.00,"NearMatchToleranceTaxableValueFrom":-200.00,"NearMatchToleranceTaxableValueTo":200.00,"NearMatchToleranceTaxAmountsFrom":-200.00,"NearMatchToleranceTaxAmountsTo":200.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":202021,"FilingExtendedDate":"2021-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":202122,"FilingExtendedDate":"2022-10-31T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":true,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-1000.00,"NearMatchToleranceDocumentValueTo":1000.00,"NearMatchToleranceTaxableValueFrom":-100.00,"NearMatchToleranceTaxableValueTo":100.00,"NearMatchToleranceTaxAmountsFrom":-100.00,"NearMatchToleranceTaxAmountsTo":100.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202223,"FilingExtendedDate":"2023-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":true,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-1000.00,"NearMatchToleranceDocumentValueTo":1000.00,"NearMatchToleranceTaxableValueFrom":-100.00,"NearMatchToleranceTaxableValueTo":100.00,"NearMatchToleranceTaxAmountsFrom":-100.00,"NearMatchToleranceTaxAmountsTo":100.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202324,"FilingExtendedDate":"2024-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":true,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":false,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":false,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202425,"FilingExtendedDate":"2025-09-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":false,"IsMismatchIfDocNumberDifferentAfterAmendment":false,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false}]')
							WITH
							(
								IsReconcileAtDocumentLevel bit '$.IsReconcileAtDocumentLevel'
								,IsExcludeMatchingCriteria bit '$.IsExcludeMatchingCriteria'
								,IsExcludeMatchingCriteriaPos bit '$.IsExcludeMatchingCriteriaPos'
								,IsExcludeMatchingCriteriaHsn bit '$.IsExcludeMatchingCriteriaHsn'
								,IsExcludeMatchingCriteriaRate bit '$.IsExcludeMatchingCriteriaRate'
								,IsExcludeMatchingCriteriaDocumentValue bit '$.IsExcludeMatchingCriteriaDocumentValue'
								,IsExcludeMatchingCriteriaTaxableValue bit '$.IsExcludeMatchingCriteriaTaxableValue'
								,IsExcludeMatchingCriteriaDocDate bit '$.IsExcludeMatchingCriteriaDocDate'
								,IsExcludeMatchingCriteriaReverseCharge bit '$.IsExcludeMatchingCriteriaReverseCharge'
								,IsExcludeMatchingCriteriaTransactionType bit '$.IsExcludeMatchingCriteriaTransactionType'
								,IsExcludeMatchingCriteriaIrn bit '$.IsExcludeMatchingCriteriaIrn'
								,IsMatchOnDateDifference bit '$.IsMatchOnDateDifference'
								,IsMatchByTolerance bit '$.IsMatchByTolerance'
								,MatchByToleranceDocumentValueFrom decimal(15,2) '$.MatchByToleranceDocumentValueFrom'
								,MatchByToleranceDocumentValueTo decimal(15,2) '$.MatchByToleranceDocumentValueTo'
								,MatchByToleranceTaxableValueFrom decimal(15,2) '$.MatchByToleranceTaxableValueFrom'
								,MatchByToleranceTaxableValueTo decimal(15,2) '$.MatchByToleranceTaxableValueTo'
								,MatchByToleranceTaxAmountsFrom decimal(15,2) '$.MatchByToleranceTaxAmountsFrom'
								,MatchByToleranceTaxAmountsTo decimal(15,2) '$.MatchByToleranceTaxAmountsTo'
								,IfPrTaxAmountIsLessThanCpTaxAmount bit '$.IfPrTaxAmountIsLessThanCpTaxAmount'
								,IfCpTaxAmountIsLessThanPrTaxAmount bit '$.IfCpTaxAmountIsLessThanPrTaxAmount'
								,IsNearMatchViaFuzzyLogic bit '$.IsNearMatchViaFuzzyLogic'
								,NearMatchFuzzyLogicPercentage tinyint '$.NearMatchFuzzyLogicPercentage'
								,NearMatchDateRangeFrom int '$.NearMatchDateRangeFrom'
								,NearMatchDateRangeTo int '$.NearMatchDateRangeTo'
								,ExcludeIntercompanyTransaction bit '$.ExcludeIntercompanyTransaction'
								,NearMatchToleranceDocumentValueFrom decimal(15,2) '$.NearMatchToleranceDocumentValueFrom'
								,NearMatchToleranceDocumentValueTo decimal(15,2) '$.NearMatchToleranceDocumentValueTo'
								,NearMatchToleranceTaxableValueFrom decimal(15,2) '$.NearMatchToleranceTaxableValueFrom'
								,NearMatchToleranceTaxableValueTo decimal(15,2) '$.NearMatchToleranceTaxableValueTo'
								,NearMatchToleranceTaxAmountsFrom decimal(15,2) '$.NearMatchToleranceTaxAmountsFrom'
								,NearMatchToleranceTaxAmountsTo decimal(15,2) '$.NearMatchToleranceTaxAmountsTo'
								,IsDiscardOriginalsWithAmendment bit '$.IsDiscardOriginalsWithAmendment'
								,FinancialYear int '$.FinancialYear'
								,FilingExtendedDate date '$.FilingExtendedDate'
								,IsNearMatchDateRestriction bit '$.IsNearMatchDateRestriction'
								,IsRegeneratePreference bit '$.IsRegeneratePreference'
								,IsExcludeCpNotFiledData bit '$.IsExcludeCpNotFiledData'
								,IsMismatchIfDocNumberDifferentAfterAmendment bit '$.IsMismatchIfDocNumberDifferentAfterAmendment'
								,AdvanceNearMatchPoweredByAI bit '$.AdvanceNearMatchPoweredByAI'
								,IsNearMatchTolerance bit '$.IsNearMatchTolerance'
								,IsRegeneratePreferenceAction bit '$.IsRegeneratePreferenceAction'
								,IsRegeneratePreference3bClaimedMonth bit '$.IsRegeneratePreference3bClaimedMonth'
							)


							EXEC [oregular].[InsertGstr2aReconciliationDocuments]
								 @ReconciliationSectionTypePROnly = 1
								,@ReconciliationSectionTypeGstOnly = 2
								,@ReconciliationMappingTypeTillDate = 4
								,@Documents = @ValSetting
								,@Settings = @TempSetting
								,@Statisticid = 1011
								,@ReconciliationSectionTypePRExcluded  = 7
								,@ReconciliationSectionTypeGstExcluded  = 8
								,@ExcludedGstin = @ExcludedGstin
								,@ActionTypeNoAction=1
								,@ReconciliationStatusActionsNotTaken=1
								,@ReconciliationStatusActionsNotPushed=2
								,@ReconciledTypeManual = 2
								,@IsRestrictItcClaim  = 0
								,@ReconciliationSourceType2b = '2b'
								,@ReconciliationType2b  = 8
								,@ReconciliationType2a  = 2
								,@AuditTrailDetails = @AuditTrailDetails
															
----------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[InsertGstr2bReconciliationDocuments]
(
	 @Documents [oregular].[ValidateGstr2aReconciliationDocumentType] READONLY
	,@StatisticId BIGINT
	,@IsRestrictItcClaim BIT = 0
	,@ReconciliationSourceType2b VARCHAR(3)= '2b'
	,@ReconciliationSectionTypeGstOnly SMALLINT
	,@ReconciliationSectionTypePROnly SMALLINT
	,@ReconciledTypeManual SMALLINT
	,@ActionTypeNoAction SMALLINT
	,@ReconciliationMappingTypeTillDate SMALLINT
	,@ExcludedGstin AS Oregular.[FinancialYearWiseGstinType] READONLY
	,@ReconciliationSectionTypePRExcluded SMALLINT
	,@ReconciliationSectionTypeGstExcluded SMALLINT
	,@ReconciliationType2b SMALLINT = 8
	,@ReconciliationType2a SMALLINT = 2
	,@AuditTrailDetails [audit].AuditTrailDetailsType READONLY
)
AS
BEGIN
		
	DECLARE @CURRENT_DATE DATETIME = GETDATE(),@FALSE SMALLINT = 0,@TRUE SMALLINT = 1;

	CREATE TABLE #Temp2bImportReconciliationData
		(
			 ParentEntityId INT -- LocationGstin VARCHAR(15)
			,PrDocumentType   SMALLINT
			,PrDocumentNumber VARCHAR(40)
			,PrDocumentDate  BIGINT
			,PrGstin	VARCHAR(15)
			,PrPortCode VARCHAR(6)
			,PrIsAmendment  BIT
			,CpDocumentType SMALLINT
			,CpDocumentNumber  VARCHAR(40) 
			,CpDocumentDate BIGINT
			,CpGstin VARCHAR(15)
			,CpPortCode VARCHAR(6)
			,CpIsAmendment BIT
			,GroupID INT
			,ManualReconciliation bit
			,Source	CHAR(3)
			,Type SMALLINT
			,ReconciliationSection  SMALLINT
			,Action SMALLINT
			,ItcClaimReturnPeriod INT
			,GroupKey INT
			,RecordName VARCHAR(50)
			,FinancialYear INT
			,"IsPreserved" BIT DEFAULT 0
		)
		
		INSERT INTO #Temp2bImportReconciliationData
		(		
			 ParentEntityId 
			,PrDocumentType   
			,PrDocumentNumber 
			,PrDocumentDate 
			,PrGstin	
			,PrPortCode 
			,PrIsAmendment
			,CpDocumentType
			,CpDocumentNumber  
			,CpDocumentDate 
			,CpGstin 
			,CpPortCode 
			,CpIsAmendment 
			,GroupID 
			,ManualReconciliation 
			,Source		
			,Type 
			,ReconciliationSection  
			,Action 
			,ItcClaimReturnPeriod 
			,GroupKey
			,RecordName 
			,FinancialYear
		)
		SELECT 			
			 ParentEntityId 
			,PrDocumentType   
			,ISNULL(PrDocumentNumber,'') 
			,CAST(CONVERT(VARCHAR(10),ISNULL(PrDocumentDate,'') ,112) AS BIGINT) PrDocumentDate
			,ISNULL(PrGstin,'')	
			,ISNULL(PrPortCode,'') 
			,ISNULL(PrIsAmendment,'')
			,CpDocumentType
			,ISNULL(CpDocumentNumber,'')  
			,CAST(CONVERT(VARCHAR(10),ISNULL(CpDocumentDate,'') ,112) AS BIGINT)CpDocumentDate
			,ISNULL(CpGstin,'') 
			,ISNULL(CpPortCode,'')
			,ISNULL(CpIsAmendment,'') 
			,GroupID 
			,ManualReconciliation 
			,Source		
			,Type 
			,ReconciliationSection  
			,Action 
			,ItcClaimReturnPeriod  
			,GroupKey
			,RecordName 
			,FinancialYear
		FROM 
			@Documents
		WHERE Source = @ReconciliationSourceType2b
		
		CREATE NONCLUSTERED INDEX IDX_#TempValidatePurchaseDocuments_GroupId ON #Temp2bImportReconciliationData(GroupId);
		/*Getting details of data from actual tables */
		SELECT 
			 trd.Type,PDRPR.Id PrId, PDRCP.Id Gstnid, trd.GroupID,PDRPR.ReturnPeriod PrReturnPeriod 
			,PDRCP.returnPeriod CPreturnPeriod, PDRPR.ParentEntityId PRParentEntityId,PDRCP.ParentEntityId ParentEntityIdCP ,trd.ReconciliationSection SectionType			
			,PDRPR.DocumentFinancialYear AS PRDocumentFinancialyear,PDRPR.FinancialYear PRRPFinancialyear,PDRCP.DocumentFinancialYear AS CPDocumentFinancialyear,PDRCP.FinancialYear CPRPFinancialyear
			,trd.Action,trd.ItcClaimReturnPeriod,@StatisticId StatisticId,[Type] PrevType,PDS.Gstr2BReturnPeriod,trd.IsPreserved
		INTO #Temp2bRecoId
		FROM 
			#Temp2bImportReconciliationData trd
			LEFT JOIN oregular.PurchaseDocumentDW PDRPR ON trd.PrDocumentNumber = PDRPR.DocumentNumber 
															AND ISNULL(trd.PrGstin,'') = ISNULL(PDRPR.BillFromGstin,'') 
															AND trd.PrDocumentDate = PDRPR.DocumentDate AND trd.PrDocumentType = PDRPR.DocumentType															
															AND trd.ParentEntityId = PDRPR.ParentEntityId
															AND PDRPR.SourceType = 1 --AND 
															AND ISNULL(PDRPR.PortCode,'') = ISNULL(trd.PrPortCode,'')
															AND ISNULL(PDRPR.IsAmendment,'') = ISNULL(trd.PrIsAmendment,'')
			LEFT JOIN oregular.PurchaseDocumentDW PDRCP ON trd.CpDocumentNumber = PDRCP.DocumentNumber 
															AND ISNULL(trd.CpGstin,'') = ISNULL(PDRCP.BillFromGstin,'') 
															AND trd.CpDocumentDate = PDRCP.DocumentDate 
															AND trd.CpDocumentType = PDRCP.DocumentType																														
															AND trd.ParentEntityId = PDRCP.ParentEntityId		
															AND PDRCP.SourceType = 3
															AND ISNULL(PDRCP.PortCode,'') = ISNULL(trd.CpPortCode,'')
															AND ISNULL(PDRCP.IsAmendment,'') = ISNULL(trd.CpIsAmendment,'')
			LEFT JOIN oregular.PurchaseDocumentStatus PDS ON PDRCP.Id = PDS.PurchaseDocumentId
			WHERE trd.ManualReconciliation = 0

			IF EXISTS (SELECT TOP 1 1 FROM #Temp2bRecoId)
			BEGIN
				DROP TABLE IF EXISTS #Temp2bRecoMapperPr;				
				SELECT 
					pdrm.Id PrMApperId,
					pdrm.SectionType PrCurrentSection,  			
					tri.SectionType PrNewSection,
					tri.GroupId			
				INTO #Temp2bRecoMapperPr
				FROM
					#Temp2bRecoId tri
					LEFT JOIN oregular.Gstr2bDocumentRecoMapper pdrm ON tri.PrId = pdrm.PrId ;
	
				CREATE INDEX IdX_Temp2bRecoMapperPr_GroupId ON #Temp2bRecoMapperPr(GroupId);
	
				DROP TABLE IF EXISTS #Temp2bRecoMapperGstn;				
				SELECT 
					pdrm.Id GstnMApperId,
					pdrm.SectionType GstnCurrentSection,  
					tri.SectionType GstnNewSection,
					tri.GroupId			
				INTO #Temp2bRecoMapperGstn
				FROM
					#Temp2bRecoId tri
					LEFT JOIN oregular.Gstr2bDocumentRecoMapper pdrm ON  tri.GstnId = pdrm.GstnId ;		
	
				UPDATE
					tri 
				SET IsPreserved = @TRUE  --'Section Type Doesnt Match'
				FROM 
					#Temp2bRecoId tri
					INNER JOIN #Temp2bRecoMapperPr pr  ON tri.GroupId = pr.GroupId
				WHERE 				
					PrCurrentSection <> PrNewSection;
	
	 			UPDATE
					tri
				SET IsPreserved = @TRUE  --'Section Type Doesnt Match'
				FROM 
					#Temp2bRecoId tri 
					INNER JOIN #Temp2bRecoMapperGstn pr  ON tri.GroupId = pr.GroupId 
				WHERE 					
					IsPreserved = @FALSE
					AND GstnCurrentSection <> GstnNewSection;				    			
				
				DELETE r_pdrm
				FROM 
					Oregular.Gstr2bDocumentRecoMapper r_pdrm
				INNER JOIN #Temp2bRecoId t_pdrm
					ON r_pdrm.PrId = t_pdrm.PrId AND  r_pdrm.GstnId = t_pdrm.GstnId	
				WHERE IsPreserved = @TRUE;					

				UPDATE PDRM
					SET PDRM.PrId = NULL,
						PDRM.SectionType = @ReconciliationSectionTypeGstOnly,
						PDRM.Reason = NULL,
						PDRM.ReasonType = NULL,	
						PDRM.PredictableMatchBy = NULL,
						PDRM.Stamp = @CURRENT_DATE,
						PDRM.ModifiedStamp = @CURRENT_DATE,						
						PDRM.PrReturnPeriodDate = NULL
				FROM Oregular.Gstr2bDocumentRecoMapper PDRM
				INNER JOIN #Temp2bRecoId tPDRM
					ON PDRM.PrId = tPDRM.PrId
				WHERE
					PDRM.GstnId IS NOT NULL
					AND IsPreserved = @TRUE;			

				UPDATE PDRM
					SET PDRM.GstnId = NULL,
						PDRM.SectionType = @ReconciliationSectionTypePROnly,
						PDRM.Reason = NULL,
						PDRM.ReasonType = NULL,	
						PDRM.PredictableMatchBy = NULL,
						PDRM.Stamp = @CURRENT_DATE,
						PDRM.ModifiedStamp = @CURRENT_DATE,
						PDRM.Gstr2BReturnPeriodDate = NULL
				FROM Oregular.Gstr2bDocumentRecoMapper PDRM
					INNER JOIN #Temp2bRecoId tPDRM
					ON PDRM.GstnId = tPDRM.GstnId
				WHERE  
					PDRM.PrId IS NOT NULL
					AND IsPreserved = @TRUE;			
					
				DELETE r_pdrm
				FROM 
					Oregular.Gstr2bDocumentRecoMapper r_pdrm
					INNER JOIN #Temp2bRecoId t_pdrm
						ON r_pdrm.PrId = t_pdrm.PrId
				WHERE 
					 r_pdrm.GstnId IS NULL
					 AND IsPreserved = @TRUE;			

				DELETE r_pdrm
				FROM 
					Oregular.Gstr2bDocumentRecoMapper r_pdrm 
					INNER JOIN #Temp2bRecoId t_pdrm	ON r_pdrm.GstnId = t_pdrm.GstnId
				WHERE 
					r_pdrm.PrId IS NULL 
					AND IsPreserved = @TRUE;			
				
				INSERT INTO Oregular.Gstr2bDocumentRecoMapper(DocumentFinancialYear,PrId,GstnId,SectionType,MappingType,Reason,ReasonType,IsCrossHeadTax,SessionId,ReconciledType,Gstr2BReturnPeriodDate,PrReturnPeriodDate)
				SELECT 					
				ISNULL(FM.PRDocumentFinancialyear,FM.CPDocumentFinancialyear), FM.PrId, FM.GstnId, FM.SectionType SectionType, @ReconciliationMappingTypeTillDate AS MappingType, NULL AS Reason,0 ReasonType,0 IsCrossHeadTax, -2 SessionID,@ReconciledTypeManual,				
				CASE WHEN FM.Gstr2BReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(FM.Gstr2BReturnPeriod,4), IIF(LEN(FM.Gstr2BReturnPeriod) = 6, LEFT(FM.Gstr2BReturnPeriod,2), CONCAT('0',LEFT(FM.Gstr2BReturnPeriod,1))), '01') ELSE NULL END,
				CASE WHEN PrReturnPeriod IS NOT NULL THEN CONCAT(RIGHT(FM.PrReturnPeriod,4), IIF(LEN(FM.PrReturnPeriod) = 6, LEFT(FM.PrReturnPeriod,2), CONCAT('0',LEFT(FM.PrReturnPeriod,1))), '01') ELSE NULL END AS ReturnPeriodDate
				FROM 
					#Temp2bRecoId FM				
				WHERE IsPreserved = @TRUE;			
				
				/* ITC CLAIM RETURN PERIOD UPDATE */				
				IF(@IsRestrictItcClaim = 0)
				BEGIN
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bRecoId TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
					WHERE 
						TRI.PRID IS NOT NULL 
						--AND TRI.ItcClaimReturnPeriod IS NOT NULL						
				
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bRecoId TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
					WHERE 
						TRI.Gstnid IS NOT NULL 
						--AND TRI.ItcClaimReturnPeriod IS NOT NULL;						
				END
				ELSE
				BEGIN
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bRecoId TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
					WHERE 
							TRI.PRID IS NOT NULL 
						AND TRI.ItcClaimReturnPeriod IS NOT NULL 
						AND PD.ItcClaimReturnPeriod IS NULL;
				
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bRecoId TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
					WHERE 
							TRI.Gstnid IS NOT NULL 
						AND TRI.ItcClaimReturnPeriod IS NOT NULL 
						AND PD.ItcClaimReturnPeriod IS NULL;

				END

				/* Action Update */
				--Revert Actions 
				SELECT 
					PR.GstnId ID
				INTO #TempRevertActions
				FROM 
					#Temp2bRecoId	TRI
				INNER JOIN oregular.Gstr2bDocumentRecoMapper  PR ON TRI.PRID = PR.PrId		
				INNER JOIN oregular.PurchaseDocumentStatus  PDR ON TRI.PRID = PDR.PurchaseDocumentId
				WHERE 
					(TRI.[Action] IS NOT NULL OR PDR.Gstr2bAction <> 1) AND PR.GstnId IS NOT NULL 
				UNION
				SELECT 
					GSTN.PrId
				FROM 
					#Temp2bRecoId TRI		
				INNER JOIN oregular.Gstr2bDocumentRecoMapper  GSTN ON TRI.Gstnid = GSTN.GstnId
				INNER JOIN oregular.PurchaseDocumentStatus PDR ON TRI.Gstnid = PDR.PurchaseDocumentId
				WHERE 
					(TRI.[Action] IS NOT NULL OR PDR.Gstr2bAction <> 1) AND GSTN.PrId IS NOT NULL	
				UNION
				SELECT 
					PR.PurchaseDocumentId ID		
				FROM 
					#Temp2bRecoId	TRI
				INNER JOIN oregular.PurchaseDocumentStatus  PR ON TRI.PRID = PR.PurchaseDocumentId		
				WHERE 
					PR.Gstr2bAction IS NOT NULL AND TRI.SectionType = @ReconciliationSectionTypePROnly
				UNION
				SELECT 
					GSTN.PurchaseDocumentId
				FROM 
					#Temp2bRecoId TRI		
				INNER JOIN oregular.PurchaseDocumentStatus  GSTN ON TRI.GSTNID = GSTN.PurchaseDocumentId
				WHERE 
					GSTN.Gstr2bAction IS NOT NULL 
					AND TRI.SectionType = @ReconciliationSectionTypeGstOnly
								
				Update PR 
				SET 
					[Gstr2bAction] = @ActionTypeNoAction				
				FROM 
					#TempRevertActions TRA
				INNER JOIN oregular.PurchaseDocumentStatus PR ON TRA.ID = PR.PurchaseDocumentId	

				DROP TABLE #TempRevertActions;		

				UPDATE 
					PD 
				SET 
					[Gstr2bAction] = TRI.[Action]
				FROM 
					#Temp2bRecoId TRI
					INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
				WHERE TRI.PRID IS NOT NULL AND TRI.[Action] <> PD.[Gstr2bAction] AND TRI.[Action] IS NOT NULL

				
				UPDATE 
					PD 
				SET 
					[Gstr2bAction] = TRI.[Action]
				FROM 
					#Temp2bRecoId TRI
					INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
				WHERE 
					TRI.Gstnid IS NOT NULL AND tri.[Action] <> PD.[Gstr2bAction] AND TRI.[Action] IS NOT NULL
			END;
			
			IF EXISTS (SELECT * FROM #Temp2bImportReconciliationData WHERE ManualReconciliation = 1)
			BEGIN
				/*Getting Data for manual reconciliation*/
				SELECT 				
					ISNULL(PDRPR.SubscriberId,PDRCP.SubscriberId)SubscriberId,trd.Type,PDRPR.Id PrId, PDRCP.Id Gstnid, trd.GroupID,ISNULL(PDRPR.ReturnPeriod,-1) PrReturnPeriod, 
					ISNULL(PDRCP.returnPeriod,-1) CPreturnPeriod, PDRPR.ParentEntityId PRParentEntityId,PDRCP.ParentEntityId CPParentEntityId ,trd.ReconciliationSection SectionType					
					,PDRPR.DocumentFinancialYear PRDocumentFinancialyear,PDRPR.FinancialYear PRRPFinancialyear,PDRCP.DocumentFinancialYear CPDocumentFinancialyear,PDRCP.FinancialYear CPRPFinancialyear
					,GroupKey,trd.Action,trd.ItcClaimReturnPeriod,@StatisticId StatisticId
					,trd.FinancialYear,trd.RecordName
				INTO #Temp2bManualRecoData
				FROM 
					#Temp2bImportReconciliationData trd
					LEFT JOIN oregular.PurchaseDocumentDW PDRPR ON trd.PrDocumentNumber = PDRPR.DocumentNumber 
																	AND trd.PrGstin = PDRPR.BillFromGstin 
																	AND trd.PrDocumentDate = PDRPR.DocumentDate 
																	AND trd.PrDocumentType = PDRPR.DocumentType															
																	AND trd.ParentEntityId = PDRPR.ParentEntityId
																	AND PDRPR.SourceType = 1
																	AND ISNULL(PDRPR.PortCode,'') = ISNULL(trd.PrPortCode,'')
																	AND ISNULL(PDRPR.IsAmendment,'') = ISNULL(trd.PrIsAmendment,'')
					LEFT JOIN oregular.PurchaseDocumentDW PDRCP ON trd.CpDocumentNumber = PDRCP.DocumentNumber 
																	AND trd.CpGstin = PDRCP.BillFromGstin 
																	AND trd.CpDocumentDate = PDRCP.DocumentDate 
																	AND trd.CpDocumentType = PDRCP.DocumentType															
																	AND PDRCP.SourceType = 3
																	AND trd.ParentEntityId = PDRCP.ParentEntityId		
																	AND ISNULL(PDRCP.PortCode,'') = ISNULL(trd.CpPortCode,'')
																	AND ISNULL(PDRCP.IsAmendment,'') = ISNULL(trd.CpIsAmendment,'')
				WHERE trd.ManualReconciliation = 1
				
				/*Delink already Manually Reconciled records */
				DECLARE @ManualMapperIds Common.BigIntType

				INSERT INTO @ManualMapperIds
				SELECT pdrmm.Id			
				FROM oregular.PurchaseDocumentRecoManualMapper pdrmm
					CROSS APPLY (SELECT * FROM OPENJSON(pdrmm.PRIDS) WITH (PrId BIGINT))d
					INNER JOIN #Temp2bManualRecoData ri ON ri.PrId = d.PrId		
				WHERE pdrmm.ReconciliationType = @ReconciliationType2b
				UNION
				SELECT pdrmm.Id
				FROM oregular.PurchaseDocumentRecoManualMapper pdrmm
					CROSS APPLY (SELECT * FROM OPENJSON(pdrmm.GstIds) WITH (GstId BIGINT))d
					INNER JOIN #Temp2bManualRecoData ri ON ri.Gstnid = d.GstId							
				WHERE pdrmm.ReconciliationType = @ReconciliationType2b
				
				IF EXISTS (SELECT 1 FROM @ManualMapperIds)
				BEGIN
					EXEC oregular.DelinkReconciliationDocumentManual				
						@ManualMapperIds = @ManualMapperIds,
						@ExcludedGstin = @ExcludedGstin,
						@ActionTypeNoAction =@ActionTypeNoAction,						
						@ReconciliationType = @ReconciliationType2b,						
						@AuditTrailDetails =@AuditTrailDetails,
						@ReconciliationStatusActionsNotTaken = 1,					
						@ReconciliationSectionTypePROnly = @ReconciliationSectionTypePROnly,
						@ReconciliationSectionTypeGstOnly = @ReconciliationSectionTypeGstOnly,
						@ReconciliationTypeGstr2b = @ReconciliationType2b,
						@ReconciliationMappingTypeTillDate = @ReconciliationMappingTypeTillDate,
						@ReconciliationSectionTypePRExcluded = @ReconciliationSectionTypePRExcluded,
						@ReconciliationSectionTypeGstExcluded = @ReconciliationSectionTypeGstExcluded
				END
				ELSE
				BEGIN
					SELECT 								
						'' AS SubscriberId,
						'' AS EntityId,
						'' AS FinancialYear			
					WHERE
						1 = 2;
				END	;				
				
				/* Insert record in PurchaseDocumentRecoManualMapper table */
				INSERT INTO oregular.PurchaseDocumentRecoManualMapper
				(
					SubscriberId,
					ParentEntityId,
					RPFinancialYear,
					DocumentFinancialYear,
					RecordName,
					SectionType,
					MappingType,
					PrIds,
					GstIds,
					Reason,
					IsAvailableInGstr2b,
					StatisticId,
					ReconciliationType
				)
				SELECT
					SubscriberId,
					ISNULL(PRParentEntityId,CPParentEntityId),
					MAX(COALESCE(tmrd.FinancialYear,CPRPFinancialyear,PRRPFinancialyear)),
					MIN(ISNULL(CPDocumentFinancialyear,PRDocumentFinancialyear)),
					MAX(ISNULL(tmrd.RecordName,'Import')),
					tmrd.SectionType,
					@ReconciliationMappingTypeTillDate,
					MAX(PrIds),
					MAX(GstnIds),
					NULL Reason,
					1,
					@StatisticId,
					@ReconciliationType2b
				FROM 
					#Temp2bManualRecoData tmrd
				CROSS APPLY (SELECT (SELECT pd.PrId  FROM #Temp2bManualRecoData pd WHERE tmrd.GroupKey = pd.GroupKey AND PrId IS NOT NULL for json auto) PrIds)d
				CROSS APPLY (SELECT (SELECT gstn.GstnId GstId FROM #Temp2bManualRecoData Gstn WHERE tmrd.GroupKey = Gstn.GroupKey AND GstnId IS NOT NULL for json auto) GstnIds)Gst
				GROUP BY SubscriberId,ISNULL(PRParentEntityId,CPParentEntityId), GroupKey,[Type],tmrd.SectionType;
				
				UPDATE PDRM
					SET PDRM.PrId = NULL,
						PDRM.SectionType = @ReconciliationSectionTypeGstOnly,
						PDRM.Reason = NULL,
						PDRM.ReasonType = NULL,
						PDRM.IsCrossHeadTax  = @FALSE,
						PDRM.PredictableMatchBy = NULL,
						PDRM.PrReturnPeriodDate = NULL
				FROM
					#Temp2bManualRecoData Pr
					INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON Pr.PrId = PDRM.PrId
				WHERE PDRM.GstnId IS NOT NULL;

				UPDATE PDRM
					SET PDRM.GstnId = NULL,
						PDRM.SectionType = @ReconciliationSectionTypePROnly,
						PDRM.Reason = NULL,
						PDRM.ReasonType = NULL,
						PDRM.IsCrossHeadTax  = @FALSE,
						PDRM.PredictableMatchBy = NULL,
						PDRM.Gstr2BReturnPeriodDate = NULL						
				FROM
					#Temp2bManualRecoData Gst
					INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON Gst.GstnId = PDRM.GstnId
				WHERE PDRM.PrId IS NOT NULL;

				UPDATE PS
					SET
						PS.[Gstr2bAction] =@ActionTypeNoAction,						
						PS.ActionDate = NULL
				FROM
					#Temp2bManualRecoData Pr
					INNER JOIN oregular.PurchaseDocumentStatus PS ON Pr.PrId = PS.PurchaseDocumentId
				WHERE PrId IS NOT NULL;

				UPDATE PS
					SET PS.[Gstr2bAction] = @ActionTypeNoAction						
				FROM
					#Temp2bManualRecoData Gst
					INNER JOIN oregular.PurchaseDocumentStatus PS ON Gst.Gstnid = PS.PurchaseDocumentId
				WHERE GstnId IS NOT NULL;
				
				DELETE
					PDRM
				FROM
					#Temp2bManualRecoData Pr
					INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON Pr.PrId = PDRM.PrId
				WHERE PDRM.GstnId IS NULL;

				DELETE
					PDRM
				FROM
					#Temp2bManualRecoData Gst
					INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON Gst.Gstnid = PDRM.GstnId
				WHERE PDRM.PrId IS NULL;

				IF(@IsRestrictItcClaim = 0)
				BEGIN
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bManualRecoData TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
					WHERE 
						TRI.PRID IS NOT NULL 
						AND TRI.ItcClaimReturnPeriod IS NOT NULL;
				
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bManualRecoData TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
					WHERE 
						TRI.Gstnid IS NOT NULL 
						AND TRI.ItcClaimReturnPeriod IS NOT NULL;
				END
				ELSE
				BEGIN
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bManualRecoData TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
					WHERE 
							TRI.PRID IS NOT NULL 
						AND TRI.ItcClaimReturnPeriod IS NOT NULL 
						AND PD.ItcClaimReturnPeriod IS NULL;
				
					UPDATE 
						PD 
					SET 
						ItcClaimReturnPeriod = TRI.ItcClaimReturnPeriod,
						Gstr3bSection = NULL
					FROM 
						#Temp2bManualRecoData TRI
						INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
					WHERE 
							TRI.Gstnid IS NOT NULL 
						AND TRI.ItcClaimReturnPeriod IS NOT NULL 
						AND PD.ItcClaimReturnPeriod IS NULL;
				END
				
				/* Action UPDATE FOR MANUAL DATA*/
				UPDATE 
					PD 
				SET 
					[Gstr2bAction] = TRI.[Action]
				FROM 
					#Temp2bManualRecoData TRI
					INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.PrId
				WHERE TRI.PRID IS NOT NULL AND TRI.[Action] <> PD.[Gstr2bAction] 
				AND TRI.[Action] IS NOT NULL
				
				UPDATE 
					PD 
				SET 
					[Gstr2bAction] = TRI.[Action]
				FROM 
					#Temp2bManualRecoData TRI
					INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = TRI.Gstnid
				WHERE TRI.Gstnid IS NOT NULL AND TRI.[Action] <> PD.[Gstr2bAction]
				AND TRI.[Action] IS NOT NULL						
		END;

END;

GO

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[InsertPaymentDetailByIds]
						: 27-05-2020 | Rippal Patel | This procedure is used to insert Payment Details.
						: 30-07-2020 | Rippal Patel | Added IsCounterPartyFiledData, IsCounterPartyNotFiledData filters & removed IsCounterPartRecords filter
						: 02-09-2020 | Piyush Prajapati | Added @IncludePdfRecordsOnly @TransactionTypeB2C @TransactionTypeCBW @TransactionTypeSEZWP @TransactionTypeSEZWOP @TransactionTypeIMPS 
						: 23-12-2020 | Rippal Patel | Added UserIds parameter
*	Review Comments		: 30-12-2020 | Abhishek Shrivas | doing basic changes like table alias name and creatig index on temp table
-------------------------------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: DECLARE  @TotalRecord INT,
								@Ids [common].[BigIntType];

						  EXEC [oregular].[InsertPaymentDetailByIds]
								@Ids =  @Ids,
								@SubscriberId  = 172,
								@PaymentType = 2,
								@PaymentAmount = 3000,
								@PaymentDate = '2020-07-08 00:00:00',
								@PaymentRemarks = null,
								@PercentageOfDocumentValue = null,
								@CreditAvailedDate = null,
								@CreditReversalDate = null;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[InsertPaymentDetailByIds]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @PaymentType SMALLINT,
	 @PaymentDate SMALLDATETIME,
	 @PercentageOfDocumentValue DECIMAL(5,2) = NULL,
	 @PaymentAmount DECIMAL(18,2),
	 @PaymentRemarks VARCHAR(250),
	 @CreditAvailedDate SMALLDATETIME,
	 @CreditReversalDate SMALLDATETIME,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempPurchaseDocumentIds
	(
		Id BIGINT NOT NULL
	);

	INSERT INTO #TempPurchaseDocumentIds(Id)
	SELECT * FROM @Ids;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;

		UPDATE ps
		SET
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentStatus ps
			INNER JOIN #TempPurchaseDocumentIds tpdi ON ps.PurchaseDocumentId = tpdi.Id;
	END;

	CREATE NONCLUSTERED INDEX IDX_TempPurchaseDocumentIds_Id ON #TempPurchaseDocumentIds(Id);

	SELECT
		pd.Id,
		pd.DocumentValue
	INTO
		#TempPurchaseDocuments
	FROM
		oregular.PurchaseDocuments pd
		INNER JOIN #TempPurchaseDocumentIds tpdi ON pd.Id = tpdi.Id;

	CREATE NONCLUSTERED INDEX IDX_#TempPurchaseDocuments_Id ON #TempPurchaseDocuments(Id);

	SELECT 
		tpd.Id
	INTO
		#TempInsertPurchaseDocumentIds
	FROM 
		#TempPurchaseDocumentIds tpd
	WHERE
		NOT EXISTS(SELECT 1 FROM oregular.PurchaseDocumentPayments pdp WHERE pdp.PurchaseDocumentId = tpd.Id);

	SELECT 
		tpd.Id
	INTO
		#TempUpdatePurchaseDocumentIds
	FROM 
		#TempPurchaseDocumentIds tpd
	WHERE 
		NOT EXISTS(SELECT 1 FROM #TempInsertPurchaseDocumentIds tipd WHERE tpd.Id = tipd.Id);

	IF EXISTS(SELECT 1 FROM #TempInsertPurchaseDocumentIds)
	BEGIN
		INSERT INTO oregular.PurchaseDocumentPayments
		(
			PurchaseDocumentId,
			PaymentType,
			PaymentDate,
			PaymentAmount,
			PaymentRemarks,
			Stamp
		)
		SELECT
			tipd.Id,
			@PaymentType,
			@PaymentDate,
			CASE WHEN @PercentageOfDocumentValue IS NOT NULL THEN (@PercentageOfDocumentValue * tpd.DocumentValue/100) ELSE @PaymentAmount END,
			@PaymentRemarks,
			GETDATE()
		FROM
			#TempInsertPurchaseDocumentIds tipd
			INNER JOIN #TempPurchaseDocuments tpd ON tipd.Id = tpd.Id
	END

	IF EXISTS(SELECT 1 FROM #TempUpdatePurchaseDocumentIds)
	BEGIN
		UPDATE 
			pdp 
		SET 
			PaymentType = @PaymentType,
			PaymentDate = @PaymentDate,
			PaymentAmount = CASE WHEN @PercentageOfDocumentValue IS NOT NULL THEN (@PercentageOfDocumentValue * tpd.DocumentValue/100) ELSE @PaymentAmount END,
			PaymentRemarks = @PaymentRemarks,
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentPayments pdp
			INNER JOIN #TempUpdatePurchaseDocumentIds tupd ON pdp.PurchaseDocumentId = tupd.Id
			INNER JOIN #TempPurchaseDocuments tpd ON pdp.PurchaseDocumentId = tpd.Id
	END

	UPDATE 
		pd
	SET 
		CreditAvailedDate = @CreditAvailedDate,
		CreditReversalDate = @CreditReversalDate,
		ModifiedStamp = GETDATE()
	FROM
		oregular.PurchaseDocuments pd
		INNER JOIN #TempPurchaseDocumentIds tpd ON pd.Id = tpd.Id

	DROP TABLE #TempPurchaseDocumentIds, #TempPurchaseDocuments, #TempInsertPurchaseDocumentIds, #TempUpdatePurchaseDocumentIds;
END

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[LinkReconciliationDocumentManual] 
* 	Comments			: 05-04-2024 | Udit Solanki	| Link Reconciliation Document Manually
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
DECLARE @SourceMapperIds AS common.[BigIntType],
	@DestinationMapperIds AS common.[BigIntType],
	@ExcludedGstin AS oregular.FinancialYearWiseGstinType,
	@AuditTrailDetails AS audit.AuditTrailDetailsType;

EXEC [oregular].[LinkReconciliationDocumentManual]
	@SourceMapperIds = @SourceMapperIds,
	@DestinationMapperIds = @DestinationMapperIds,
	@ExcludedGstin = @ExcludedGstin,
	@RecordName = null,
	@FinancialYear = 20232024,
	@ReconciliationSection = null,
	@ActionTypeNoAction = null,
	@ReconciliationStatusActionsNotTaken = null,
	@ReconciliationType = null,
	@AuditTrailDetails = @AuditTrailDetails,
	@ReconciliationType = 2,
	@ReconciliationTypeGstr2a = 1,
	@ReconciliationTypeGstr2b = 2,
	@ReconciliationSectionTypePrOnly = 3,
	@ReconciliationSectionTypePrExcluded = 4,
	@ReconciliationSectionTypeGstOnly = 5,
	@ReconciliationSectionTypeGstExcluded = 6,
	@ReconciliationSectionTypeMatched = 7

*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE oregular.LinkReconciliationDocumentManual(
	@SourceMapperIds AS common.[BigIntType] READONLY,
	@DestinationMapperIds AS common.[BigIntType] READONLY,
	@ExcludedGstin AS oregular.[FinancialYearWiseGstinType] READONLY,
	@RecordName VARCHAR(MAX),
	@FinancialYear integer,
	@ReconciliationSection integer,
	@ActionTypeNoAction smallint,
	@ReconciliationStatusActionsNotTaken smallint,
	@ReconciliationType smallint,
	@AuditTrailDetails AS audit.[AuditTrailDetailsType] READONLY,
	@ReconciliationTypeGstr2a TINYINT,
	@ReconciliationTypeGstr2b TINYINT,
	@ReconciliationSectionTypePrOnly TINYINT,
	@ReconciliationSectionTypePrExcluded TINYINT,
	@ReconciliationSectionTypeGstOnly TINYINT,
	@ReconciliationSectionTypeGstExcluded TINYINT,
	@ReconciliationSectionTypeMatched TINYINT
)
AS 
BEGIN
DECLARE 
	@SubscriberId  INT,
	@RPFinancialYear  INT,
	@DocumentFinancialYear  INT,
	@ParentEntityId  INT,
	@ReconciliationMappingType  SMALLINT,
	@IsAvailableInGstr2b BIT,
	@PrIds  VARCHAR(MAX),
	@GstIds  VARCHAR(MAX),
	@Reason  VARCHAR(500);


	IF EXISTS (SELECT 1 FROM @AuditTrailDetails) 
	BEGIN
		EXEC audit.UpdateAuditDetails  
					@AuditTrailDetails;
	END;

	DROP TABLE IF EXISTS #TempExcludedGstin,#TempSourceMapperIds, #TempDestinationMapperIds, #TempGstIds, #TempPrIds;
	/* Temp table to store Excluded Gstin */
	CREATE TABLE #TempExcludedGstin(
		FinancialYear INT NOT NULL,
		Gstin VARCHAR(15) NOT NULL
	);

	/* Temp table to store source mapper Ids */
	CREATE TABLE #TempSourceMapperIds (
		PurchaseDocumentMapperId BIGINT NOT NULL
	);
	/* Create clustered index on PurchaseDocumentMapperID for faster retrieval */
	CREATE CLUSTERED INDEX IDX_SourceMapperIds_PurchaseDocumentMapperId ON #TempSourceMapperIds(PurchaseDocumentMapperId);

	/* Temp table to store destination mapper Ids */
	CREATE TABLE #TempDestinationMapperIds (
		PurchaseDocumentMapperId BIGINT NOT NULL
	);
	/* Create clustered index on PurchaseDocumentMapperID for faster retrieval */
	CREATE CLUSTERED INDEX IDX_DestinationMapperIds_PurchaseDocumentMapperID ON #TempDestinationMapperIds(PurchaseDocumentMapperId);
	
	/* Temp table to store PR Ids */
	CREATE TABLE #TempPrIds (
		PurchaseDocumentMapperId BIGINT NOT NULL,
		PrId BIGINT NOT NULL,
		RPFinancialYear INT NOT NULL,
		DocumentFinancialYear INT NOT NULL,
		ParentEntityId INT NOT NULL,
		ReconciliationMappingType SMALLINT NOT NULL,
		SubscriberId INT NOT NULL
	);
	/* Create clustered index on PrId for faster retrieval */
	CREATE CLUSTERED INDEX IDX_PrIds_PrId ON #TempPrIds(PrId);

	/* Temp table to store PR Ids */
	CREATE TABLE #TempGstIds (
		PurchaseDocumentMapperId BIGINT NOT NULL,
		GstId BIGINT NOT NULL,
		RPFinancialYear INT NOT NULL,
		DocumentFinancialYear INT NOT NULL,
		ParentEntityId INT NOT NULL,
		IsAvailableInGstr2b BIT		
	);
	
	/* Create clustered index on GstId for faster retrieval */
	CREATE INDEX IDX_GstIds_GstId ON #TempGstIds(GstId);

	/* Insert data in SourceMapperIds form @SourceMapperIds table type */
	INSERT INTO #TempSourceMapperIds(PurchaseDocumentMapperId)
	SELECT 
		*
	FROM 
		@SourceMapperIds;

	/* Insert data in DestinationMapperIds form @DestinationMapperIds table type */
	INSERT INTO #TempDestinationMapperIds(PurchaseDocumentMapperId)
	SELECT *
		FROM @DestinationMapperIds;

	IF (@ReconciliationType = @ReconciliationTypeGstr2b)
	BEGIN
	
		/* Get Taxpayer data */
		INSERT INTO #TempPrIds(PurchaseDocumentMapperId,PrId,RPFinancialYear,DocumentFinancialYear,ParentEntityId,ReconciliationMappingType,SubscriberId)
		SELECT DISTINCT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.Id AS PrId,
			PDR.FinancialYear,
			PDR.DocumentFinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			PDRM.MappingType AS ReconciliationMappingType,
			PDR.SubscriberId
		FROM
			#TempSourceMapperIds SMIds
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON SMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocumentDW PDR ON PDRM.PrId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypePrOnly, @ReconciliationSectionTypePrExcluded)
			AND PDR.SourceType = 1
		UNION ALL
		SELECT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.Id AS PrId,
			PDR.FinancialYear,
			PDR.DocumentFinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			PDRM.MappingType AS ReconciliationMappingType,
			PDR.SubscriberId
		FROM
			#TempDestinationMapperIds DMIds
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON DMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocumentDW PDR ON PDRM.PrId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypePrOnly, @ReconciliationSectionTypePrExcluded)
			AND PDR.SourceType = 1;
	
	/* Get Counter Party data */
		INSERT INTO #TempGstIds(PurchaseDocumentMapperId, GstId, RPFinancialYear, DocumentFinancialYear, ParentEntityId,IsAvailableInGstr2b)
		SELECT DISTINCT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.Id AS GstId,
			PDR.FinancialYear,
			PDR.DocumentFinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			1
		FROM
			#TempSourceMapperIds SMIds
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON SMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocumentDW PDR ON PDRM.GstnId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypeGstOnly, @ReconciliationSectionTypeGstExcluded)
			AND PDR.SourceType = 3
		UNION ALL
		SELECT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.Id AS GstId,
			PDR.FinancialYear,
			PDR.DocumentFinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			1
		FROM
			#TempDestinationMapperIds DMIds
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON DMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocumentDW PDR ON PDRM.GstnId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypeGstOnly, @ReconciliationSectionTypeGstExcluded)
			AND PDR.SourceType = 3;			
	END
	ELSE	
	BEGIN
			/* Get Taxpayer data */
		INSERT INTO #TempPrIds(PurchaseDocumentMapperId,RPFinancialYear ,PrId, DocumentFinancialYear, ParentEntityId, ReconciliationMappingType, SubscriberId)
		SELECT DISTINCT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.FinancialYear,
			PDR.Id AS PrId,			
			PDR.FinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			PDRM.MappingType AS ReconciliationMappingType,
			PDR.SubscriberId
		FROM
			#TempSourceMapperIds SMIds
			INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON SMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocuments PDR ON PDRM.PrId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypePrOnly, @ReconciliationSectionTypePrExcluded)			
		UNION ALL
		SELECT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.FinancialYear,
			PDR.Id AS PrId,			
			PDR.FinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			PDRM.MappingType AS ReconciliationMappingType,
			PDR.SubscriberId
		FROM
			#TempDestinationMapperIds DMIds
			INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON DMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocuments PDR ON PDRM.PrId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypePrOnly, @ReconciliationSectionTypePrExcluded);

		/* Get Counter Party data */
		INSERT INTO #TempGstIds(PurchaseDocumentMapperId,RPFinancialYear, GstId, DocumentFinancialYear, ParentEntityId,IsAvailableInGstr2b)
		SELECT DISTINCT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.FinancialYear,
			PDR.Id AS GstId,			
			PDR.FinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			PDRM.IsAvailableInGstr2b
		FROM
			#TempSourceMapperIds SMIds
			INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON SMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocuments PDR ON PDRM.GstnId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypeGstOnly, @ReconciliationSectionTypeGstExcluded)
		UNION ALL
		SELECT
			PDRM.Id AS PurchaseDocumentMapperId,
			PDR.FinancialYear,
			PDR.Id AS GstId,			
			PDR.FinancialYear AS DocumentFinancialYear,
			PDR.ParentEntityId,
			PDRM.IsAvailableInGstr2b
		FROM
			#TempDestinationMapperIds DMIds
			INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON DMIds.PurchaseDocumentMapperId = PDRM.Id
			INNER JOIN oregular.PurchaseDocuments PDR ON PDRM.GstnId = PDR.Id
		WHERE
			PDRM.SectionType IN(@ReconciliationSectionTypeGstOnly, @ReconciliationSectionTypeGstExcluded);
	END;
	
	
	/* Get RPFinancialYear & ParentEntityId for check unique @RecordName validate */
	
	SELECT TOP 1 
		@RPFinancialYear = RPFinancialYear, 
		@DocumentFinancialYear = DocumentFinancialYear, 
		@SubscriberId = SubscriberId, 
		@ParentEntityId = ParentEntityId, 
		@ReconciliationMappingType = ReconciliationMappingType 
	FROM #TempPrIds;

	/* Get Excluded Gstin data */
	INSERT INTO #TempExcludedGstin(FinancialYear, Gstin)
	SELECT FinancialYear, Gstin FROM @ExcludedGstin;
		
	SELECT @IsAvailableInGstr2b =  CASE WHEN IsAvailableInGstr2b = 1  THEN 1 END FROM #TempGstIds;

	/* PrIds convert as JSON */
	SET @PrIds = 
		(	
			SELECT
				Pr.PrId
			FROM
				#TempPrIds AS Pr
			FOR JSON AUTO
		);
	
	/* GstIds convert as JSON */
	SET @GstIds =
		(
			SELECT
				Gst.GstId
			FROM
				#TempGstIds AS Gst	
			FOR JSON AUTO
		);

	/* Rais Error If reco mapper id change */
	IF @PrIds IS NULL OR @GstIds IS NULL
	BEGIN
		RAISERROR('VALD0085', 16, 1);
		RETURN;
	END;

	IF EXISTS (SELECT 1 WHERE @FinancialYear NOT IN (SELECT DISTINCT COALESCE(COALESCE(G.RPFinancialYear,P.RPFinancialYear,P.DocumentFinancialYear,G.DocumentFinancialYear),-1) FROM #TempGstIds G INNER JOIN #TempPrIds P ON 1 = 1 GROUP BY GROUPING SETS (G.RPFinancialYear,P.RPFinancialYear,P.DocumentFinancialYear,G.DocumentFinancialYear)) AND @FinancialYear IS NOT NULL)
	BEGIN
		RAISERROR('VALD0143', 16, 1);
		RETURN;
	END; 

	/* Insert record in PurchaseDocumentRecoManualMapper table */
	INSERT INTO oregular.PurchaseDocumentRecoManualMapper
	(
		SubscriberId,
		ParentEntityId,
		RPFinancialYear,
		DocumentFinancialYear,
		RecordName,
		SectionType,
		MappingType,
		PrIds,
		GstIds,
		Reason,
		IsAvailableInGstr2b,
		ReconciliationType			
	)
	SELECT
		@SubscriberId,
		@ParentEntityId,
		CASE WHEN @FinancialYear IS NULL THEN @RPFinancialYear ELSE @FinancialYear END AS RPFinancialYear,
		CASE WHEN @FinancialYear IS NULL THEN @DocumentFinancialYear ELSE @FinancialYear END AS DocumentFinancialYear,
		@RecordName,
		CASE WHEN @ReconciliationSection IS NULL THEN @ReconciliationSectionTypeMatched ELSE @ReconciliationSection END AS SectionType,
		@ReconciliationMappingType,
		@PrIds,
		@GstIds,
		@Reason,
		@IsAvailableInGstr2b,
		CASE WHEN @ReconciliationType = @ReconciliationTypeGstr2b THEN @ReconciliationTypeGstr2b ELSE @ReconciliationTypeGstr2a END													 
	;
	IF(@ReconciliationType = @ReconciliationTypeGstr2b)
	BEGIN
		UPDATE PDRM
		SET PDRM.PrId = NULL,
			PDRM.SectionType =@ReconciliationSectionTypeGstOnly,
			PDRM.Reason = NULL,
			PDRM.ReasonType = NULL,
			PDRM.IsCrossHeadTax  = 0
		FROM
			#TempPrIds Pr
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON Pr.PrId = PDRM.PrId
		WHERE PDRM.GstnId IS NOT NULL;						

		UPDATE PDRM
		SET PDRM.GstnId = NULL,
			PDRM.SectionType = @ReconciliationSectionTypePrOnly,
			PDRM.Reason = NULL,
			PDRM.ReasonType = NULL,
			PDRM.IsCrossHeadTax  = 0
		FROM
			#TempGstIds Gst
			INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON Gst.GstId = PDRM.GstnId
		WHERE PDRM.PrId IS NOT NULL;

		UPDATE PS
		SET 
			PS.Gstr2bAction= @ActionTypeNoAction
		FROM
			#TempPrIds Pr
			INNER JOIN oregular.PurchaseDocumentStatus PS ON Pr.PrId = PS.PurchaseDocumentId;

		UPDATE PS
		SET
			Gstr2bAction = @ActionTypeNoAction
		FROM
			#TempGstIds Gst
			INNER JOIN oregular.PurchaseDocumentStatus PS ON Gst.GstId = PS.PurchaseDocumentId;

		DELETE PDRM FROM 
			oregular.Gstr2bDocumentRecoMapper PDRM
			INNER JOIN #TempPrIds Pr ON Pr.PrId = PDRM.PrId
		WHERE 
			PDRM.GstnId IS NULL;

		DELETE PDRM FROM  
			oregular.Gstr2bDocumentRecoMapper PDRM
			INNER JOIN #TempGstIds Gst ON Gst.GstId = PDRM.GstnId
		WHERE 
			PDRM.PrId IS NULL ;
	END
	ELSE
	BEGIN
		UPDATE PDRM
		SET PDRM.PrId = NULL,
			PDRM.SectionType =@ReconciliationSectionTypeGstOnly ,
			PDRM.Reason = NULL,
			PDRM.ReasonType = NULL,
			PDRM.IsCrossHeadTax  = 0
		FROM
			#TempPrIds Pr
			INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON Pr.PrId = PDRM.PrId
		WHERE PDRM.GstnId IS NOT NULL;
			  
		UPDATE PDRM
		SET PDRM.GstnId = NULL,
			PDRM.SectionType = @ReconciliationSectionTypePrOnly ,
			PDRM.Reason = NULL,
			PDRM.ReasonType = NULL,
			PDRM.IsCrossHeadTax  = 0
		FROM
			#TempGstIds Gst
			INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON Gst.GstId = PDRM.GstnId 
		WHERE PDRM.PrId IS NOT NULL;

		UPDATE PS 
		SET 
			PS.Action = @ActionTypeNoAction,
			PS.ReconciliationStatus = @ReconciliationStatusActionsNotTaken,
			PS.ActionDate = NULL
		FROM
			#TempPrIds Pr
			INNER JOIN oregular.PurchaseDocumentStatus PS ON Pr.PrId = PS.PurchaseDocumentId;

		UPDATE PS
		SET 
			PS.Action = @ActionTypeNoAction,
			PS.ReconciliationStatus = @ReconciliationStatusActionsNotTaken	
		FROM
			#TempGstIds Gst
			INNER JOIN oregular.PurchaseDocumentStatus PS ON Gst.GstId = PS.PurchaseDocumentId;

		DELETE PDRM
		FROM
			oregular.Gstr2aDocumentRecoMapper PDRM
			INNER JOIN #TempPrIds Pr ON  Pr.PrId = PDRM.PrId
		WHERE 
			PDRM.GstnId IS NULL;

		DELETE PDRM
		FROM
			oregular.Gstr2aDocumentRecoMapper PDRM
			INNER JOIN #TempGstIds Gst	ON Gst.GstId = PDRM.GstnId
		WHERE 
			PDRM.PrId IS NULL;
	END;
	/* Drop temp tables */
	
END;

GO

/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[UpdatePurchaseDocumentByReco] 
* 	Comments			: 10-04-2024 | Ravi Chauhan	| Update Purchase Document By Reco.
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		: 
DECLARE @Ids AS common.[BigIntType],
	@EntityIds AS common.[IntType],
	@SelectedEntityIds oregular.EntityIdGstinType,
	@GstActOrRuleSectionToUpdate oregular.BulkUpdateGstActOrRuleSectionType,
	@AuditTrailDetails audit.AuditTrailDetailsType;

EXEC oregular.UpdatePurchaseDocumentByReco
	@Ids = @Ids,
	@SubscriberId = 164,
	@DocFinancialYear = null,
	@FromPrReturnPeriod = null,
	@ToPrReturnPeriod = null,
	@FromGstnReturnPeriod = null,
	@ToGstnReturnPeriod = null,
	@EntityIds = @EntityIds,
	@SelectedEntityIds = @SelectedEntityIds,
	@DocumentNumbers = null,
	@IsDocNumberLikeSearch = null,
	@Gstins = null,
	@Pans = null,
	@ExcludePans = null,
	@TradeNames = null,
	@IsTradeNamesLikeSearch = null,
	@DocumentTypes = null,
	@TransactionTypes = null,
	@ReconciliationSections = null,
	@Actions = null,
	@ActionStatus = null,
	@PaymentStatus = null,
	@Custom = null,
	@ReasonType = null,
	@ItcEligibility = null,
	@ValueDiffFrom = null,
	@ValueDiffTo = null,
	@TaxableDiffFrom = null,
	@TaxableDiffTo = null,
	@TaxDiffFrom = null,
	@TaxDiffTo = null,
	@DaysDiffFrom = null,
	@DaysDiffTo = null,
	@FromDocumentDate = null,
	@ToDocumentDate = null,
	@FromStamp = null,
	@ToStamp = null,
	@FromReconciliationDate = null,
	@ToReconciliationDate = null,
	@PortCode = null,
	@FromActionsDate = null,
	@ToActionsDate = null,
	@IsCrossHeadTaxData = null,
	@TaxPayerType = null,
	@ReconciliationType = 8,
	@ItcAvailability = null,
	@ItcUnavailabilityReason = null,
	@AmendmentType = null,
	@SourceType = 0,
	@IsNotificationStatusClosed = null,
	@IsGstr3bFiled = null,
	@ReconciledBy = null,
	@ItcClaimReturnPeriodToUpdate = null,
	@IsRestrictItcClaim = null,
	@IsShowInterCompanyTransfer = null,
	@Remark = null,
	@IsReverseCharge = null,
	@IsExactMatchReason = null,
	@IsAvailableInGstr2b = null,
	@IsErrorRecordsOnly = null,
	@IsShowClaimedItcRecords = null,
	@IsAvailableInGstr98a = null,
	@Gstr98aFinancialYear = null,
	@IsNotificationSentReceived = null,
	@IsNotificationSentButNoReply = null,
	@ItcClaimReturnPeriod = null,
	@Gstr2bReturnPeriod = null,
	@AmendedType = null,
	@SuggReconciliationSection = null,
	@EInvoiceEnablement = null,
	@GstActOrRuleSection = null,
	@CpFilingPreference = null,
	@Gstr3bSection = null,
	@Remarks = null,
	@RecordName = null,
	@ManualMappingType = null,
	@ReconciliationSectionToBeUpdated = null,
	@ReconciliationUpdateType = null,
	@GstActOrRuleSectionToUpdate = @GstActOrRuleSectionToUpdate,
	@AuditTrailDetails = @AuditTrailDetails,
	@TransactionNature = 0,
    /* Update Enums*/
	@ReconciliationSectionTypeDelinkNearMatched = 1,
	@ReconciliationSectionTypeDelinkMismatched = 2,
	@ReconciledTypeSystem = 3,
	@ReconciledTypeSystemSectionChanged = 4,
	@ReconciledTypeManualSectionChanged = 5,
	@ReconciliationUpdateTypeRemarks = 6,
	@ReconciliationUpdateTypeRemarksManual = 8,
	@ReconciliationUpdateTypeGstActOrRule = 7,
	@ReconciliationUpdateTypeGstActOrRuleManual = 9,
	@ReconciliationUpdateTypeReconciliationSection = 0,
	@ReconciliationUpdateTypeGstr3BClaimMonth = 9,
	@ReconciliationUpdateTypeGstr3BClaimMonthManual = 7,
	/* Filter Enums*/
    @SourceTypeCounterPartyNotFiled = 1,
	@ReconciliationSectionTypePrOnly = 2,
	@ReconciliationSectionTypeGstOnly = 3,
	@ReconciliationSectionTypeMatched = 4,
	@ReconciliationSectionTypeMatchedDueToTolerance = 27,
	@ReconciliationSectionTypeMisMatched = 5,
	@ReconciliationSectionTypeNearMatched = 6,
	@ReconciliationSectionTypeGstDiscarded = 7,
	@ReconciliationSectionTypeGstExcluded = 8,
	@ReconciliationSectionTypePrDiscarded = 9,
	@ReconciliationSectionTypePrExcluded = 10,
	@ReconciliationSectionTypePrOnlyItcDelayed = 5,
	@ItcEligibilityNone = 0,
	@ReconciliationTypeGstr2b = 8,
	@ReconciliationTypeIcegate = 1,
	@AmendmentTypeOriginal = 3,
	@AmendmentTypeAmendment = 2,
	@AmendmentTypeOriginalAmended = 1,
	@ModuleTypeOregularPurchase = 1,
	@DocumentTypeINV = 1,
	@DocumentTypeCRN = 2,
	@DocumentTypeDBN = 3,
	@DocumentTypeBOE = 4,

*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[UpdatePurchaseDocumentByReco](
	@Ids AS common.[BigIntType] READONLY,
	@SubscriberId integer,
	@DocFinancialYear integer,
	@FromPrReturnPeriod integer,
	@ToPrReturnPeriod integer,
	@FromGstnReturnPeriod integer,
	@ToGstnReturnPeriod integer,
	@EntityIds AS common.[IntType] READONLY,
	@SelectedEntityIds oregular.EntityIdGstinType READONLY,
	@DocumentNumbers varchar(max),
	@IsDocNumberLikeSearch bit,
	@Gstins varchar(max),
	@Pans varchar(max),
	@ExcludePans varchar(max),
	@TradeNames varchar(max),
	@IsTradeNamesLikeSearch bit,
	@DocumentTypes varchar(max),
	@TransactionTypes varchar(max),
	@ReconciliationSections varchar(max),
	@Actions varchar(max),
	@ActionStatus smallint,
	@PaymentStatus varchar(max),
	@Custom varchar(max),
	@ReasonType bigint,
	@ItcEligibility varchar(max),
	@ValueDiffFrom numeric,
	@ValueDiffTo numeric,
	@TaxableDiffFrom numeric,
	@TaxableDiffTo numeric,
	@TaxDiffFrom numeric,
	@TaxDiffTo numeric,
	@DaysDiffFrom integer,
	@DaysDiffTo integer,
	@FromDocumentDate datetime,
	@ToDocumentDate datetime,
	@FromStamp datetime,
	@ToStamp datetime,
	@FromReconciliationDate datetime,
	@ToReconciliationDate datetime,
	@PortCode varchar(max),
	@FromActionsDate datetime,
	@ToActionsDate datetime,
	@IsCrossHeadTaxData bit,
	@TaxPayerType varchar(max),
	@ReconciliationType smallint,
	@ItcAvailability smallint,
	@ItcUnavailabilityReason smallint,
	@AmendmentType smallint,
	@SourceType smallint,
	@IsNotificationStatusClosed bit,
	@IsGstr3bFiled bit,
	@ReconciledBy smallint,
	@ItcClaimReturnPeriodToUpdate integer,
	@IsRestrictItcClaim bit,
	@IsShowInterCompanyTransfer bit,
	@Remark varchar(max),
	@IsReverseCharge bit,
	@IsExactMatchReason bit,
	@IsAvailableInGstr2b bit,
	@IsErrorRecordsOnly bit,
	@IsShowClaimedItcRecords bit,
	@IsAvailableInGstr98a bit,
	@Gstr98aFinancialYear integer,
	@IsNotificationSentReceived bit,
	@IsNotificationSentButNoReply bit,
	@ItcClaimReturnPeriod integer,
	@Gstr2bReturnPeriod integer,
	@AmendedType integer,
	@SuggReconciliationSection varchar(max),
	@EInvoiceEnablement smallint,
	@GstActOrRuleSection smallint,
	@CpFilingPreference smallint,
	@Gstr3bSection varchar(max),
	@Remarks varchar(max),
	@TotalRecord int = null,
	@RecordName varchar(max),
	@ManualMappingType smallint,
	@ReconciliationSectionToBeUpdated smallint,
	@ReconciliationUpdateType smallint,
	@GstActOrRuleSectionToUpdate oregular.BulkUpdateGstActOrRuleSectionType READONLY,
	@AuditTrailDetails audit.AuditTrailDetailsType READONLY,
	@TransactionNature smallint = NULL,
	@TaxpayerStatus varchar(max),
	@IsBlacklistedVendor bit,
	@GrcScoreFrom smallint,
	@GrcScoreTo smallint,
	@ReversalReclaim int,
	/* Update Enums*/
	@ReconciliationSectionTypeDelinkNearMatched smallint,
	@ReconciliationSectionTypeDelinkMismatched smallint,
	@ReconciledTypeSystem smallint,
	@ReconciledTypeSystemSectionChanged smallint,
	@ReconciledTypeManualSectionChanged smallint,
	@ReconciliationUpdateTypeRemarks smallint,
	@ReconciliationUpdateTypeRemarksManual smallint,
	@ReconciliationUpdateTypeGstActOrRule smallint,
	@ReconciliationUpdateTypeGstActOrRuleManual smallint,
	@ReconciliationUpdateTypeReconciliationSection smallint,
	@ReconciliationUpdateTypeGstr3BClaimMonth smallint,
	@ReconciliationUpdateTypeGstr3BClaimMonthManual smallint,
	/* Filter Enums*/
	@SourceTypeCounterPartyNotFiled SMALLINT,
	@ReconciliationSectionTypePrOnly SMALLINT,
	@ReconciliationSectionTypeGstOnly SMALLINT,
	@ReconciliationSectionTypeMatched SMALLINT,
	@ReconciliationSectionTypeMatchedDueToTolerance SMALLINT,
	@ReconciliationSectionTypeMisMatched SMALLINT,
	@ReconciliationSectionTypeNearMatched SMALLINT,
	@ReconciliationSectionTypeGstDiscarded SMALLINT,
	@ReconciliationSectionTypeGstExcluded SMALLINT,
	@ReconciliationSectionTypePrDiscarded SMALLINT,
	@ReconciliationSectionTypePrExcluded SMALLINT,
	@ReconciliationSectionTypePrOnlyItcDelayed SMALLINT,
	@ItcEligibilityNone SMALLINT,
	@ReconciliationTypeGstr2b SMALLINT,
	@ReconciliationTypeIcegate SMALLINT,
	@AmendmentTypeOriginal SMALLINT,
	@AmendmentTypeAmendment SMALLINT,
	@AmendmentTypeOriginalAmended SMALLINT,
	@ModuleTypeOregularPurchase SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeBOE SMALLINT)
	
AS 
BEGIN
		
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails) 
	BEGIN
		EXEC audit.UpdateAuditDetails
					@AuditTrailDetails;
	END;

	DROP TABLE IF EXISTS #TempPurchaseDocumentIds, #TempFilterId,#TempBulkUpdateGstActOrRuleSectionDetail,#TempIds;

	CREATE TABLE #TempBulkUpdateGstActOrRuleSectionDetail
	(
		ItcEligibility SMALLINT,
		GstActOrRuleSection SMALLINT
	);

	CREATE TABLE #TempFilterId (
		Id INT IDENTITY(1,1), 
		PurchaseDocumentMapperId BIGINT,
		SectionType SMALLINT,
		PrId BIGINT,
		GstnId BIGINT
	);

	/* Create clustered index on PurchaseDocumentMapperID for faster retrieval */
	CREATE INDEX FilterID_PurchaseDocumentMapperId ON #TempFilterId(PurchaseDocumentMapperId);

	INSERT INTO #TempBulkUpdateGstActOrRuleSectionDetail(
		ItcEligibility,
		GstActOrRuleSection
	)
	SELECT
		ItcEligibility,
		GstActOrRuleSection
	FROM @GstActOrRuleSectionToUpdate;

	/* Temp table to store id purchase document Id*/
	CREATE TABLE #TempPurchaseDocumentIds (
		PurchaseDocumentId BIGINT Not NULL, 
		AutoPopulated bit
	);

	IF (@ReconciliationUpdateType IN (@ReconciliationUpdateTypeRemarksManual,@ReconciliationUpdateTypeGstActOrRuleManual,@ReconciliationUpdateTypeGstr3BClaimMonthManual))
	BEGIN
		
		IF EXISTS(SELECT 1 FROM @Ids)
		BEGIN
			INSERT INTO #TempFilterId (PurchaseDocumentMapperId)
			SELECT * FROM @Ids;
		END
		ELSE
		BEGIN
			/* Get filtered Ids */
			INSERT INTO #TempFilterId(
			PurchaseDocumentMapperId
			)
			EXEC oregular.FilterReconciliationDataManual
				@SubscriberId= @SubscriberId , 
				@EntityIds= @EntityIds, 
				@DocFinancialYear= @DocFinancialYear , 						
				@ManualMappingType = @ManualMappingType ,
				@FromPrReturnPeriod= @FromPrReturnPeriod , 
				@ToPrReturnPeriod= @ToPrReturnPeriod , 
				@FromGstnReturnPeriod = @FromGstnReturnPeriod ,
				@ToGstnReturnPeriod = @ToGstnReturnPeriod,
				@RecordName= @RecordName , 
				@DocumentNumbers= @DocumentNumbers , 
				@Gstins= @Gstins , 
				@Pans= @Pans , 
				@ExcludePans= @ExcludePans , 
				@TradeNames= @TradeNames , 
				@DocumentTypes= @DocumentTypes , 
				@TransactionTypes= @TransactionTypes , 
				@TaxPayerType= @TaxPayerType , 
				@Actions= @Actions , 
				@PaymentStatus= @PaymentStatus , 
				@ActionStatus= @ActionStatus , 
				@Custom= @Custom , 
				@ItcEligibility= @ItcEligibility , 
				@FromDocumentDate= @FromDocumentDate , 
				@ToDocumentDate= @ToDocumentDate , 
				@FromStamp= @FromStamp , 
				@ToStamp= @ToStamp , 
				@FromActionsDate= @FromActionsDate , 
				@ToActionsDate= @ToActionsDate , 
				@ItcAvailability= @ItcAvailability , 
				@ItcUnavailabilityReason= @ItcUnavailabilityReason , 
				@AmendmentType= @AmendmentType , 
				@SourceType= @SourceType , 
				@IsGstr3bFiled= @IsGstr3bFiled ,			
				@Start= NULL, 
				@Size= NULL,
				@TotalRecord = @TotalRecord OUTPUT,
				@Remark=@Remark,
				@ReconciliationSections=@ReconciliationSections , 
				@AmendedType = @AmendedType ,
				@IsDocNumberLikeSearch= @IsDocNumberLikeSearch , 
				@IsTradeNamesLikeSearch= @IsTradeNamesLikeSearch , 
				@IsAvailableInGstr2b= @IsAvailableInGstr2b , 
				@IsShowClaimedItcRecords= @IsShowClaimedItcRecords , 
				@IsAvailableInGstr98a= @IsAvailableInGstr98a , 
				@Gstr98aFinancialYear= @Gstr98aFinancialYear , 
				@IsReverseCharge= @IsReverseCharge , 
				@IsNotificationSentReceived= @IsNotificationSentReceived , 
				@IsNotificationStatusClosed= @IsNotificationStatusClosed , 				
				@ItcClaimReturnPeriod= @ItcClaimReturnPeriod , 
				@Gstr2bReturnPeriod= @Gstr2bReturnPeriod , 
				@GetAllData= 1, 
				@ReconciliationType= @ReconciliationType,
				@CpFilingPreference = @CpFilingPreference,	
				@Gstr3bSection = @Gstr3bSection,
				@IsDsu = 0,
				@TransactionNature = @TransactionNature,
				/*Enum*/
				@ItcEligibilityNone = @ItcEligibilityNone,
				@AmendmentTypeOriginal = @AmendmentTypeOriginal,
				@AmendmentTypeOriginalAmended = @AmendmentTypeOriginalAmended,
				@AmendmentTypeAmendment = @AmendmentTypeAmendment,
				@ReconciliationTypeGstr2b = @ReconciliationTypeGstr2b,
				@ModuleTypeOregularPurchase = @ModuleTypeOregularPurchase,
				@TaxpayerStatus = @TaxpayerStatus,
				@IsBlacklistedVendor = @IsBlacklistedVendor,
				@GrcScoreFrom = @GrcScoreFrom,
				@GrcScoreTo = @GrcScoreTo,
				@ReversalReclaim = @ReversalReclaim;
		END;
		
		/* Get Purchase register Ids from Json */
		INSERT INTO #TempPurchaseDocumentIds(
			PurchaseDocumentId,AutoPopulated
		)
		SELECT
			Pr.PrId  AS PurchaseDocumentRecoId,0
		FROM
			#TempFilterId FId
			INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM ON FId.PurchaseDocumentMapperId = PDRMM.Id
			OUTER APPLY OPENJSON(PrIds) WITH (PrId BIGINT '$.PrId') AS Pr ;
		
		INSERT INTO #TempPurchaseDocumentIds(
			PurchaseDocumentId,AutoPopulated
		)
		SELECT
			Gst.GstId AS PurchaseDocumentRecoId,1
		FROM
			#TempFilterId FId
			INNER JOIN oregular.PurchaseDocumentRecoManualMapper PDRMM ON FId.PurchaseDocumentMapperId = PDRMM.Id
			OUTER APPLY OPENJSON(GstIds) WITH (GstId BIGINT '$.GstId') AS Gst; 
			
		IF EXISTS(SELECT 1 FROM @AuditTrailDetails)  
		BEGIN
			UPDATE gdrm
			SET gdrm.ModifiedStamp = GETDATE()			
			FROM #TempFilterId trba
			INNER JOIN oregular.PurchaseDocumentRecoManualMapper gdrm ON gdrm.Id = trba.PurchaseDocumentMapperId;
		END;
	
	END	
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM @Ids)
		BEGIN			
			
			SELECT 
				*
			INTO #TempIds
			FROM @Ids;

			IF (@ReconciliationType = @ReconciliationTypeGstr2b)		
			BEGIN
				
				INSERT INTO #TempFilterId (PurchaseDocumentMapperId,PrId,GstnId,SectionType)
				SELECT 
					drm.Id,drm.PrId,drm.GstnId,drm.SectionType
				FROM 
					#TempIds Ti
					INNER JOIN oregular.Gstr2bDocumentRecoMapper drm On Ti.Item = drm.Id;
			END
			ELSE
			BEGIN
				INSERT INTO #TempFilterId (PurchaseDocumentMapperId,PrId,GstnId,SectionType)
				SELECT 
					drm.Id,drm.PrId,drm.GstnId,drm.SectionType
				FROM 
					#TempIds Ti
					INNER JOIN oregular.Gstr2aDocumentRecoMapper drm On Ti.Item = drm.Id;
			END;
		END
		ELSE
		BEGIN	
			INSERT INTO #TempFilterId (
				PurchaseDocumentMapperId,PrId,GstnId,SectionType
			)
			EXEC oregular.FilterReconciliationData
				@SubscriberId = @SubscriberId,
				@EntityIds = @EntityIds,
				@SelectedEntityIds = @SelectedEntityIds,
				@DocFinancialYear = @DocFinancialYear,
				@FromPrReturnPeriod = @FromPrReturnPeriod,
				@ToPrReturnPeriod = @ToPrReturnPeriod,
				@FromGstnReturnPeriod = @FromGstnReturnPeriod,
				@ToGstnReturnPeriod = @ToGstnReturnPeriod,
				@DocumentNumbers = @DocumentNumbers,
				@Gstins = @Gstins,
				@PortCode = @PortCode,
				@Pans = @Pans,
				@ExcludePans = @ExcludePans,
				@TradeNames = @TradeNames,
				@DocumentTypes = @DocumentTypes,
				@TransactionTypes = @TransactionTypes,
				@TaxPayerType = @TaxPayerType,
				@ReconciliationSections = @ReconciliationSections,
				@Gstr2bReturnPeriod = @Gstr2bReturnPeriod,
				@Actions = @Actions,
				@ActionStatus = @ActionStatus,
				@PaymentStatus = @PaymentStatus,
				@Custom = @Custom,
				@ReasonType = @ReasonType,
				@IsExactMatchReason = @IsExactMatchReason,
				@ItcEligibility = @ItcEligibility,
				@ValueDiffFrom = @ValueDiffFrom,
				@ValueDiffTo = @ValueDiffTo,
				@TaxableDiffFrom = @TaxableDiffFrom,
				@TaxableDiffTo = @TaxableDiffTo,
				@TaxDiffFrom = @TaxDiffFrom,
				@TaxDiffTo = @TaxDiffTo,
				@DaysDiffFrom = @DaysDiffFrom,
				@DaysDiffTo = @DaysDiffTo,
				@FromDocumentDate = @FromDocumentDate,
				@ToDocumentDate = @ToDocumentDate,
				@FromStamp = @FromStamp,
				@ToStamp = @FromStamp,
				@FromReconciliationDate = @FromReconciliationDate,
				@ToReconciliationDate = @ToReconciliationDate,
				@FromActionsDate = @FromActionsDate,
				@ToActionsDate = @ToActionsDate,
				@IsShowInterCompanyTransfer = @IsShowInterCompanyTransfer,
				@IsCrossHeadTaxData = @IsCrossHeadTaxData ,
				@IsErrorRecordsOnly = @IsErrorRecordsOnly ,
				@ReconciliationType = @ReconciliationType,
				@IsAvailableInGstr2b = @IsAvailableInGstr2b,
				@IsShowClaimedItcRecords = @IsShowClaimedItcRecords,
				@ItcAvailability = @ItcAvailability,
				@ItcUnavailabilityReason = @ItcUnavailabilityReason,
				@AmendmentType = @AmendmentType,
				@IsAvailableInGstr98a = @IsAvailableInGstr98a,
				@Gstr98aFinancialYear = @Gstr98aFinancialYear,
				@SourceType = @SourceType,
				@IsReverseCharge = @IsReverseCharge,
				@IsNotificationSentReceived = @IsNotificationSentReceived,
				@IsNotificationStatusClosed = @IsNotificationStatusClosed,
				@IsGstr3bFiled = @IsGstr3bFiled,
				@ItcClaimReturnPeriod = @ItcClaimReturnPeriod,
				@ReconciledBy = @ReconciledBy,
				@AmendedType = @AmendedType,
				@IsNotificationSentButNoReply = @IsNotificationSentButNoReply,
				@Remark = @Remark,
				@GetAllData = 1,
				@IsDocNumberLikeSearch = @IsDocNumberLikeSearch,
				@IsTradeNamesLikeSearch = @IsTradeNamesLikeSearch,
				@EInvoiceEnablement = @EInvoiceEnablement,
				@GstActOrRuleSection = @GstActOrRuleSection,
				@CpFilingPreference = @CpFilingPreference,
				@Gstr3bSection = @Gstr3bSection,
				@SuggReconciliationSection = @SuggReconciliationSection,
				@IsDsu = 0,
				@Start = NULL,
				@Size = NULL,
				@TotalRecord = @TotalRecord OUTPUT,
				@TransactionNature = @TransactionNature,
				@SourceTypeCounterPartyNotFiled = @SourceTypeCounterPartyNotFiled,
				@ReconciliationSectionTypePrOnly = @ReconciliationSectionTypePrOnly,
				@ReconciliationSectionTypeGstOnly = @ReconciliationSectionTypeGstOnly,
				@ReconciliationSectionTypeMatched = @ReconciliationSectionTypeMatched,
				@ReconciliationSectionTypeMatchedDueToTolerance = @ReconciliationSectionTypeMatchedDueToTolerance,
				@ReconciliationSectionTypeMisMatched = @ReconciliationSectionTypeMisMatched,
				@ReconciliationSectionTypeNearMatched = @ReconciliationSectionTypeNearMatched,
				@ReconciliationSectionTypeGstDiscarded = @ReconciliationSectionTypeGstDiscarded,
				@ReconciliationSectionTypeGstExcluded = @ReconciliationSectionTypeGstExcluded,
				@ReconciliationSectionTypePrDiscarded = @ReconciliationSectionTypePrDiscarded,
				@ReconciliationSectionTypePrExcluded = @ReconciliationSectionTypePrExcluded,
				@ReconciliationSectionTypePrOnlyItcDelayed = @ReconciliationSectionTypePrOnlyItcDelayed,
				@ItcEligibilityNone = @ItcEligibilityNone,
				@ReconciliationTypeGstr2b = @ReconciliationTypeGstr2b,
				@ReconciliationTypeIcegate = @ReconciliationTypeIcegate,
				@AmendmentTypeOriginal = @AmendmentTypeOriginal,
				@AmendmentTypeAmendment = @AmendmentTypeAmendment,
				@AmendmentTypeOriginalAmended = @AmendmentTypeOriginalAmended,
				@ModuleTypeOregularPurchase = @ModuleTypeOregularPurchase,
				@DocumentTypeINV = @DocumentTypeINV,
				@DocumentTypeCRN = @DocumentTypeCRN,
				@DocumentTypeDBN = @DocumentTypeDBN,
				@DocumentTypeBOE = @DocumentTypeBOE,
				@TaxpayerStatus = @TaxpayerStatus,
				@IsBlacklistedVendor = @IsBlacklistedVendor,
				@GrcScoreFrom = @GrcScoreFrom,
				@GrcScoreTo = @GrcScoreTo,
				@ReversalReclaim = @ReversalReclaim;
		END;
			
			
			INSERT INTO #TempPurchaseDocumentIds
			SELECT PrId,0 FROM #TempFilterId WHERE PrId IS NOT NULL
			UNION
			SELECT GstnId,1 FROM #TempFilterId WHERE GstnId IS NOT NULL;
			
			IF (@ReconciliationType = @ReconciliationTypeGstr2b)		
			BEGIN
				IF EXISTS(SELECT 1 FROM @AuditTrailDetails) 
				BEGIN
					UPDATE gdrm
					SET gdrm.ModifiedStamp = GETDATE()
					FROM #TempFilterId trba
					INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrm ON gdrm.Id = trba.PurchaseDocumentMapperId;					
				END;
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT 1 FROM @AuditTrailDetails) 
				BEGIN
					UPDATE gdrm
					SET gdrm.ModifiedStamp = GETDATE()
					FROM #TempFilterId trba
					INNER JOIN oregular.Gstr2aDocumentRecoMapper gdrm ON gdrm.Id = trba.PurchaseDocumentMapperId;					
				END;				
			END;			
	END;

	IF (@ReconciliationUpdateType IN (@ReconciliationUpdateTypeGstr3BClaimMonth,@ReconciliationUpdateTypeGstr3BClaimMonthManual ))
	BEGIN		
		IF(@IsRestrictItcClaim = 0)
		BEGIN					
			UPDATE 
				PD 
			SET 
				PD.ItcClaimReturnPeriod = @ItcClaimReturnPeriodToUpdate,
				PD.Gstr3bSection = NULL,
				PD.ModifiedStamp = GETDATE(),
				PD.IsReconciled = CASE WHEN @ItcClaimReturnPeriodToUpdate IS NULL THEN 0 ELSE pd.IsReconciled END
			FROM 
				#TempPurchaseDocumentIds AS PDID 
			INNER JOIN oregular.PurchaseDocumentStatus AS PD ON PD.PurchaseDocumentId = PDID.PurchaseDocumentId;    
		END
		ELSE
		BEGIN		
			UPDATE 
				PD 
			SET 
				PD.ItcClaimReturnPeriod = @ItcClaimReturnPeriodToUpdate,
				PD.Gstr3bSection = NULL,
				PD.ModifiedStamp = GETDATE(),
				PD.IsReconciled = CASE WHEN @ItcClaimReturnPeriodToUpdate IS NULL THEN 0 ELSE pd.IsReconciled END
			FROM 
				#TempPurchaseDocumentIds AS PDID 
				INNER JOIN oregular.PurchaseDocumentStatus AS PD ON  PD.PurchaseDocumentId = PDID.PurchaseDocumentId
			WHERE 
				PD.ItcClaimReturnPeriod IS NULL;
		
		END;
		RETURN;
	END;
	IF (@ReconciliationUpdateType IN (@ReconciliationUpdateTypeRemarks,@ReconciliationUpdateTypeRemarksManual ))
	BEGIN
		UPDATE 
			PS 
		SET 
			PS.Remarks = @Remarks
		FROM 
			#TempPurchaseDocumentIds AS PDID 
		INNER JOIN oregular.PurchaseDocumentStatus AS PS ON PS.PurchaseDocumentId = PDID.PurchaseDocumentId;
		RETURN;
	END;
	IF  (@ReconciliationUpdateType = @ReconciliationUpdateTypeReconciliationSection)
	BEGIN
		IF (@ReconciliationSectionTypeDelinkNearMatched = @ReconciliationSectionToBeUpdated OR @ReconciliationSectionTypeDelinkMismatched = @ReconciliationSectionToBeUpdated)
		BEGIN				
			EXEC oregular.DelinkRecoDocuments  
					@ReconciledTypeSystem=@ReconciledTypeSystem,
					@ReconciledTypeSystemSectionChanged=@ReconciledTypeSystemSectionChanged,
					@ReconciledTypeManualSectionChanged=@ReconciledTypeManualSectionChanged,
					@ReconciliationType=@ReconciliationType,
					@ReconciliationTypeGstr2b = @ReconciliationTypeGstr2b,
					@ReconciliationSectionTypePrOnly = @ReconciliationSectionTypePrOnly,
					@ReconciliationSectionTypeGstOnly = @ReconciliationSectionTypeGstOnly;
			RETURN;
		END
		ELSE
		BEGIN
			IF (@ReconciliationType = @ReconciliationTypeGstr2b)		
			BEGIN
				/* Update Reconciliation Section in oregular.PurchaseDocumentRecoMapper table */
				UPDATE 
					PDRM
				SET PDRM.SectionType = @ReconciliationSectionToBeUpdated,
					PDRM.ReconciledType = CASE WHEN PDRM.ReconciledType IN (@ReconciledTypeSystem,@ReconciledTypeSystemSectionChanged) THEN @ReconciledTypeSystemSectionChanged ELSE @ReconciledTypeManualSectionChanged END,
					PDRM.Stamp = GETDATE()
				FROM 
					#TempFilterId FI
				INNER JOIN oregular.Gstr2bDocumentRecoMapper PDRM ON FI.PurchaseDocumentMapperId = PDRM.Id;
			END
			ELSE
			BEGIN
				/* Update Reconciliation Section in oregular.PurchaseDocumentRecoMapper table */
				UPDATE PDRM
				SET PDRM.SectionType = @ReconciliationSectionToBeUpdated,
					PDRM.ReconciledType = CASE WHEN PDRM.ReconciledType IN (@ReconciledTypeSystem,@ReconciledTypeSystemSectionChanged) THEN @ReconciledTypeSystemSectionChanged ELSE @ReconciledTypeManualSectionChanged END,
					PDRM.Stamp = GETDATE()
				FROM 
					#TempFilterId FI
				INNER JOIN oregular.Gstr2aDocumentRecoMapper PDRM ON FI.PurchaseDocumentMapperId = PDRM.Id;
			END;
		END;
	END;

	IF (@ReconciliationUpdateType IN (@ReconciliationUpdateTypeGstActOrRule,@ReconciliationUpdateTypeGstActOrRuleManual))
	BEGIN
		
		DROP TABLE IF EXISTS #TempDataIds;
		
		SELECT 
			pdi.Id,BUGRS.GstActOrRuleSection 
		INTO #TempDataIds
		FROM
			#TempPurchaseDocumentIds  pd			
		INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = pd.PurchaseDocumentId
		INNER JOIN #TempBulkUpdateGstActOrRuleSectionDetail BUGRS ON pdi.ItcEligibility = BUGRS.ItcEligibility
		WHERE
			pd.AutoPopulated = 0;
	
		UPDATE
			pdi
		SET
			pdi.GstActOrRuleSection = tdi.GstActOrRuleSection,
			pdi.ModifiedStamp = GETDATE()
		FROM
			#TempDataIds tdi
		INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.Id = tdi.Id;

		IF EXISTS (SELECT 1 FROM @AuditTrailDetails) 
		BEGIN
			UPDATE gdrm
			SET gdrm.ModifiedStamp = GETDATE()		
			FROM #TempFilterId trba
			INNER JOIN oregular.Gstr2bDocumentRecoMapper gdrm ON gdrm.Id = trba.PurchaseDocumentMapperId;					
		END;

	RETURN;

	END;

END;

GO

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[oregular].[UpdatePurchaseDocumentItcDetails] 	 	 
* 	Comment				:	28-05-2020 | Rippal Patel | This procedure is used to update Itc Detail For Purchase Document
*	Review Comments		:   19-01-2021 | Abhishek Shrivas| Only creating Clustered index on Temp table Id column for better performance
							13-12-2022 | Shambhu Das | Add reco table for update itc column value
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution		:	DECLARE @PurchaseDocumentItcDetailsItem [oregular].[PurchaseDocumentItcDetailType];
						
							INSERT INTO @PurchaseDocumentItcDetailsItem(Id, ItcEligibility, ItcIgstAmount, ItcCgstAmount, ItcSgstAmount, ItcCessAmount) VALUES (157775, 1, 1000, NULL, NULL, NULL);

							EXEC [oregular].[UpdatePurchaseDocumentItcDetails]
								@PurchaseDocumentItcDetailsItems = @PurchaseDocumentItcDetailsItem;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[UpdatePurchaseDocumentItcDetails]
(
	 @PurchaseDocumentItcDetailsItems [oregular].[PurchaseDocumentItcDetailType] READONLY,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		pdi.Id,
		pdi.ItcEligibility,
		pdi.ItcIgstAmount,
		pdi.ItcCgstAmount,
		pdi.ItcSgstAmount,
		pdi.ItcCessAmount
	INTO
		#TempPurchaseDocumentItems
	FROM
		@PurchaseDocumentItcDetailsItems as pdi;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;

		CREATE TABLE #TempPurchaseDocumentIds
		(
			Id BIGINT NOT NULL
		);

		INSERT INTO #TempPurchaseDocumentIds
		SELECT DISTINCT
			pdi.PurchaseDocumentId AS Id
		FROM 
			#TempPurchaseDocumentItems tpdi
			INNER JOIN oregular.PurchaseDocumentItems pdi ON tpdi.Id = pdi.Id; 

		UPDATE pds
		SET
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentStatus pds
			INNER JOIN #TempPurchaseDocumentIds tpdi ON pds.PurchaseDocumentId = tpdi.Id;
	END;
	
	CREATE CLUSTERED INDEX  IDX_#TempPurchaseDocumentItems_Id ON #TempPurchaseDocumentItems(Id);

	BEGIN
		UPDATE 
			pdi
		SET 
			pdi.ItcEligibility = tpdit.ItcEligibility,
			pdi.ItcIgstAmount = tpdit.ItcIgstAmount,
			pdi.ItcCgstAmount = tpdit.ItcCgstAmount,
			pdi.ItcSgstAmount = tpdit.ItcSgstAmount,
			pdi.ItcCessAmount = tpdit.ItcCessAmount,
			ModifiedStamp = GETDATE()
		FROM 
			oregular.PurchaseDocumentItems AS pdi
			INNER JOIN #TempPurchaseDocumentItems AS tpdit ON pdi.Id = tpdit.Id;

		SELECT 
			DISTINCT pdi.PurchaseDocumentId
			INTO #TempPurchaseId
		FROM
			oregular.PurchaseDocumentItems AS pdi
			INNER JOIN #TempPurchaseDocumentItems AS tpdit ON pdi.Id = tpdit.Id;
		
		DELETE 
			pdri
		FROM
			#TempPurchaseId tpi
			INNER JOIN oregular.PurchaseDocumentRateWiseItems pdri ON pdri.PurchaseDocumentId = tpi.PurchaseDocumentId		

		INSERT INTO [oregular].[PurchaseDocumentRateWiseItems]
		(
			[PurchaseDocumentId]
			,[Rate]
			,[TaxableValue]
			,[IgstAmount]
			,[CgstAmount]
			,[SgstAmount]
			,[CessAmount]
		)
		SELECT
			pdi.PurchaseDocumentId,
			pdi.Rate,
			SUM(pdi.TaxableValue),
			SUM(pdi.IgstAmount),
			SUM(pdi.CgstAmount),
			SUM(pdi.SgstAmount),
			SUM(pdi.CessAmount)
		FROM
			#TempPurchaseId AS tpdi
			INNER JOIN oregular.PurchaseDocumentItems AS pdi ON tpdi.PurchaseDocumentId = pdi.PurchaseDocumentId
		GROUP BY 
			pdi.PurchaseDocumentId, pdi.Rate, pdi.ItcEligibility;
		
		DROP TABLE IF EXISTS #TempRecoItems1;
		SELECT
			pdi.PurchaseDocumentId,
			pdi.Rate,
			MAX(pdi.ItcEligibility) AS ItcEligibility,
			SUM(pdi.ItcIgstAmount) AS ItcIgstAmount,
			SUM(pdi.ItcCgstAmount) AS ItcCgstAmount,
			SUM(pdi.ItcSgstAmount) AS ItcSgstAmount,
			SUM(pdi.ItcCessAmount) AS ItcCessAmount
		INTO #TempRecoItems1
		FROM
			#TempPurchaseId tpi
			INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpi.PurchaseDocumentId
		GROUP BY pdi.PurchaseDocumentId, pdi.Rate;

		UPDATE pdri
			SET pdri.ItcEligibility = tr.ItcEligibility,
				pdri.ItcIgstAmount = tr.ItcIgstAmount,
				pdri.ItcCgstAmount = tr.ItcCgstAmount,
				pdri.ItcSgstAmount = tr.ItcSgstAmount,
				pdri.ItcCessAmount = tr.ItcCessAmount,
				pdri.ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentRecoItems pdri
			INNER JOIN #TempRecoItems1 tr ON pdri.PurchaseDocumentRecoId = tr.PurchaseDocumentId AND pdri.Rate = tr.Rate;
				 
		SELECT
			ri.PurchaseDocumentRecoId,
			SUM(ri.ItcIgstAmount) AS ItcIgstAmount,
			SUM(ri.ItcCgstAmount) AS ItcCgstAmount,
			SUM(ri.ItcSgstAmount) AS ItcSgstAmount,
			SUM(ri.ItcCessAmount) AS ItcCessAmount
		INTO #tempReco
		FROM
			#TempPurchaseId tpigr
			INNER JOIN oregular.PurchaseDocumentRecoItems ri ON ri.PurchaseDocumentRecoId = tpigr.PurchaseDocumentId
		GROUP BY ri.PurchaseDocumentRecoId;
		
		UPDATE r
			SET r.ItcIgstAmount = ISNULL(tr.ItcIgstAmount,0),
				r.ItcCgstAmount = ISNULL(tr.ItcCgstAmount,0),
				r.ItcSgstAmount = ISNULL(tr.ItcSgstAmount,0),
				r.ItcCessAmount = ISNULL(tr.ItcCessAmount,0)
		FROM oregular.PurchaseDocumentReco r
		INNER JOIN #tempReco tr ON r.Id = tr.PurchaseDocumentRecoId;

		DROP TABLE #TempPurchaseDocumentItems,#TempPurchaseId, #tempReco, #TempRecoItems1;
	END
END

GO

/*-----------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	[oregular].[UpdatePushRequestForSaleDocuments] 	 	 
* 	Comment				:	20-05-2020 | Mayur Ladva | Update background task id and gst status (in progress status)
						:	28/07/2020 | Pooja Rajpurohit | Renamed table name to SaledocumentDw.
-----------------------------------------------------------------------------------------------------------------------------
*	Test Execution	    :	DECLARE @Ids AS [common].[BigIntType];

							INSERT INTO @Ids VALUES(31187);
								
							EXEC [oregular].[UpdatePushRequestForSaleDocuments]
									@UserId = 663,
									@BackgroundTaskId  = 15996,
									@Ids = @Ids,
									@PushToGstStatusInProgress = 4,
									@DocumentTypeDBN = 3,
									@DocumentTypeCRN = 2
								
-----------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[UpdatePushRequestForSaleDocuments]
(
	@UserId INT,
	@BackgroundTaskId INT,
	@Ids [common].[BigIntType] READONLY,
	@TransactionLimit INT,
	@RequestId UNIQUEIDENTIFIER,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@PushToGstStatusInProgress SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT
)
AS
BEGIN
	DECLARE 
		@CurrentDate DATETIME = GETDATE(),
		@IsTransactionLimitExceed BIT = 0;

	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	SELECT
		Item
	INTO
		#TempIds
	FROM
		@Ids;
		
	SELECT
		@IsTransactionLimitExceed = CASE WHEN COUNT(ss.SaleDocumentId) > @TransactionLimit THEN 1 ELSE 0 END
	FROM
		oregular.SaleDocumentStatus AS ss
		INNER JOIN #TempIds AS tid ON tid.Item = ss.SaleDocumentId
	WHERE
		ss.BillingDate IS NULL;

	IF (@IsTransactionLimitExceed = 1)
	BEGIN
		RAISERROR('VAL0662', 16, 1);
		RETURN;
	END

	UPDATE 
		ss
	SET 
		ss.PushStatus = @PushToGstStatusInProgress,
		ss.BackgroundTaskId = @BackgroundTaskId,
		ss.PushByUserId = @UserId,
		ss.BillingDate = ISNULL(ss.BillingDate, @CurrentDate),
		ss.RequestId = @RequestId,
		ss.Errors = null,
		ss.ModifiedStamp = GETDATE()
	FROM 
		oregular.SaleDocumentStatus AS ss
		INNER JOIN #TempIds AS tid ON tid.Item = ss.SaleDocumentId;	

	SELECT 
		sd.Id,
		sd.EntityId,
		sd.ReturnPeriod,
		sd.DocumentType,
		CASE WHEN ss.BillingDate = @CurrentDate THEN 1 ELSE 0 END AS IsPlanLimitApplicable
	FROM 
		oregular.SaleDocuments AS sd
		INNER JOIN oregular.SaleDocumentStatus AS ss ON sd.Id = ss.SaleDocumentId
		INNER JOIN #TempIds AS tid ON tid.Item = sd.Id
	ORDER BY 
		sd.Id ;

	DROP TABLE #TempIds;

END

GO

/*-----------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [oregular].[UpdatePushResponseForSaleDocuments] 	 	 
* 	Comment			: 21-05-2020 | Mayur Ladva | This procedure used to update gst status as per gst return(api) request into sale status table
					: 28/07/2020 | Pooja Rajpurohit | Renamed table name to SaledocumentDw.
					: 19/11/2021 | Dhruv Amin | Added logic for clearing gstr1Einvoice field for success scenarios.
-------------------------------------------------------------------------------------------------------------------------------
*	Test Execution	:	DECLARE 
							@PushResponses [common].[PushResponseType];
						INSERT INTO @PushResponses VALUES(221978,0,0,1,5,NULL,NULL,NULL,0);

						EXEC [oregular].[UpdatePushResponseForSaleDocuments]
							@PushResponses = @PushResponses,
							@DocumentTypeDBN = 3,
							@DocumentTypeCRN = 2
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [oregular].[UpdatePushResponseForSaleDocuments]
(
	@PushResponses [common].[PushResponseType]  READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	@DocumentTypeDBN SMALLINT,
	@DocumentTypeCRN SMALLINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@False BIT = 0,
		@True BIT= 1,
		@CurrentDate SMALLDATETIME = GETDATE();
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	SELECT 
		*
	INTO 
		#TempPushResponses
	FROM
		@PushResponses;

	CREATE CLUSTERED INDEX IDX_#TempPushResponses ON #TempPushResponses(Id)


	SELECT 
		Id
	INTO 
		#TempDeletedIds
	FROM
		#TempPushResponses tpr
	where 
		tpr.Errors IS NULL
		AND tpr.IsDeleted = 1;

	CREATE CLUSTERED INDEX IDX_#TempDeletedIds ON #TempDeletedIds(Id)

	--1. Delete records which are in 'ToBeRemoved' state

	DELETE
		sdr
	FROM 
		oregular.SaleDocumentReferences sdr
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sdr.SaleDocumentId

	DELETE
		sdi
	FROM 
		oregular.SaleDocumentItems sdi
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sdi.SaleDocumentId

	DELETE
		sdri
	FROM 
		oregular.SaleDocumentRateWiseItems sdri
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sdri.SaleDocumentId

	DELETE
		ss
	FROM 
		oregular.SaleDocumentStatus ss
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = ss.SaleDocumentId

	DELETE
		sdc
	FROM 
		oregular.SaleDocumentContacts sdc
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sdc.SaleDocumentId

	DELETE
		sdp
	FROM 
		oregular.SaleDocumentPayments sdp
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sdp.SaleDocumentId

	DELETE
		sdcu
	FROM 
		oregular.SaleDocumentCustoms sdcu
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sdcu.SaleDocumentId
		
	DELETE
		sd
	FROM 
		oregular.SaleDocuments sd
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sd.Id

	DELETE
		sd
	FROM 
		oregular.SaleDocumentDW sd
		INNER JOIN #TempDeletedIds AS tdi ON tdi.Id = sd.Id

	--2. Update records state according to gst push response.
	
	UPDATE
		sd
	SET
		sd.Irn = NULL,
		sd.IrnGenerationDate = NULL
	FROM
		oregular.SaleDocuments AS sd 
		INNER JOIN oregular.SaleDocumentStatus AS ss ON sd.Id = ss.SaleDocumentId
		INNER JOIN #TempPushResponses AS tpr ON tpr.Id = sd.Id
	WHERE
		tpr.Errors IS NULL
		AND ss.IsAutoDrafted = @True;

	UPDATE 
		ss
	SET 
		ss.PushStatus = tpr.PushStatus,
		ss.CancelledDate = tpr.CancelledDate,
		ss.IsPushed = ISNULL(tpr.IsPushed,ss.IsPushed),
		ss.Errors = tpr.Errors,
		ss.IsAutoDrafted = ISNULL(tpr.IsAutoDrafted,ss.IsAutoDrafted),
		ss.PushDate = ISNULL(tpr.PushDate,ss.PushDate),
		ss.AutoDraftSource = CASE WHEN tpr.Errors IS NULL AND ss.IsAutoDrafted = @True THEN NULL ELSE ss.AutoDraftSource END,
		ss.UploadedDate = CASE WHEN tpr.Errors IS NULL AND ss.UploadedDate IS NULL THEN @CurrentDate ELSE ss.UploadedDate END,
		ss.GstinError = tpr.GstinError,
		ss.ModifiedStamp = @CurrentDate
	FROM 
		oregular.SaleDocumentStatus AS ss
		INNER JOIN #TempPushResponses AS tpr ON tpr.Id = ss.SaleDocumentId;

	DROP TABLE #TempPushResponses,#TempDeletedIds
END

GO

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[UpdateTdsDetailForPurchaseDocuments]
* 	Comments			: 07-09-2023 | Dhruv Amin | This procedure is used to get purchase document to update tds details.(CGSP2-5663)
						: 25-10-2023 | Dhruv Amin | Added changes for B2C transaction based on vendor code. (CGSP2-6022)
						: 01-12-2023 | Krishna Shah | Added Gstr3bSection Filter.
						: 12-01-2024 | Krishna Shah | Added TransactionNature Filter.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	    : DECLARE  @TotalRecord INT,
								@EntityIds AS [common].[IntType],
								@UserIds AS [common].[IntType],
								@Ids [common].[BigIntType],
								@ReturnTypes [common].[SmallIntType];

						  EXEC [oregular].[UpdateTdsDetailForPurchaseDocuments]
								@Ids =  @Ids,
								@SubscriberId  = 172,
								@UserId = 676,
								@UserIds = @UserIds,
						  		@FinancialYear  = 202021,
						  		@EntityIds =  @EntityIds,
						  		@ReturnPeriods = null,
						  		@Gstins =  null,
								@Pans = null,
						  		@TradeNames  = null,
						  		@DocumentNumbers  = null,
						  		@DocumentTypes  = NULL,
						  		@TransactionTypes = null ,
								@PushStatuses  = NULL,
						  		@RefDocumentNumber = NULL,
						  		@RefDocumentDate = NULL,
						  		@PortCode = NULL,
						  		@OriginalDocumentDate = NULL,
						  		@OriginalDocumentNumber = NULL,
								@OriginalPortCode = NULL,
						  		@Hsn = NULL,
						  		@Custom = NULL,
						  		@IsReverseCharge = NULL,
						  		@POS = NULL,
						  		@IsUnderIgstAct = NULL,
						  		@ItcEligibility = NULL,
								@PaymentStatus = Null,
						  		@SectionType = NULL,
								@GstActOrRuleSectionType = NULL,
						  		@Status = NULL,
								@AmendmentType = NULL,
								@Amended = NULL,
								@LiabilityDischargeReturnPeriod = 062020,
								@ItcClaimReturnPeriod = 072020,
						  		@Start  = 0,
						  		@Size  = 20,
						  		@SourceTypeTaxpayer = 1,
						  		@SortExpression = 'Id ASC',
								@FromDocumentDate = null,
								@ToDocumentDate = null,
								@FromStamp = null,
								@ToStamp = null,
								@IsCounterPartyFiledData = 0,
								@IsCounterPartyNotFiledData = 1 ,
								@SourceTypeCounterPartyFiled = 2,
								@SourceTypeCounterPartyNotFiled = 3,
								@IsErrorRecordsOnly = 0,
								@AutoDraftSource = NULL,
								@IsAvailableInGstr2B = NULL,
								@IsAvailableInGstr98a = NULL,
								@Gstr98aFinancialYear = NULL,
								@IsClaimedItcRecords = NULL,
								@ItcAvailability = NULL,
								@ItcUnavailabilityReason = NULL,
								@ItcEligibilityNone = 0,
								@AmendmentTypeOriginal = 1,
								@AmendmentTypeOriginalAmended = 2, 
								@AmendmentTypeAmendment = 3,
								@IncludeCancelOrDeleteRecordsOnly = 0,
								@ExcludeGstr3BRecordsOnly = 0,
								@IncludeUploadedByMeRecordsOnly = 0,
								@ReturnPeriodForItcClaimedRecords = NULL,
								@ReturnTypes = @ReturnTypes,
								@ReturnTypeGstr2 = 3,
								@ReturnTypeGstr3B = 14,
								@ReturnActionFile = 9,
								@ReturnActionSubmit = 4,
								@IncludePdfRecordsOnly =0,
								@TransactionTypeIMPG = 7,
								@TransactionTypeIMPS = 8,
								@PushToGstStatusPushed = 5,
								@ContactTypeBillFrom = 1,
								@ContactTypeDispatchFrom = 2,
								@TdsComputationStatusCompleted = 1,
								@TdsComputationStatusYetNotStarted = 2,
								@TdsComputationStatusInProgress = 3,
								@TdsComputationStatusFailed = 4,
								@ComputationStatusCompleted = 1,
								@ComputationStatusInProgress = 2,
								@ComputationStatusFailed = 3,
								@SourceTypeEInvoice = 5,
						  		@TotalRecord  = @TotalRecord OUT
						  		Select @TotalRecord;
*/-----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[UpdateTdsDetailForPurchaseDocuments]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @UserId INT,
	 @UserIds [common].[IntType] READONLY,
	 @FinancialYear INT,
	 @EntityIds [common].[IntType] READONLY,
	 @ReturnPeriods VARCHAR(MAX),
	 @Gstins VARCHAR(MAX),
	 @Pans VARCHAR(MAX),
	 @TradeNamesOrLegalNames VARCHAR(MAX),
	 @DocumentNumbers VARCHAR(MAX),
	 @DocumentTypes VARCHAR(MAX),
	 @TransactionTypes VARCHAR(MAX),
	 @PushStatuses VARCHAR(MAX),
	 @RefDocumentNumber VARCHAR(40) NULL,
	 @RefDocumentDate SMALLDATETIME NULL,
	 @PortCode VARCHAR(6) NULL,
	 @OriginalDocumentNumber VARCHAR(40) NULL,
	 @OriginalDocumentDate SMALLDATETIME NULL,
	 @OriginalPortCode VARCHAR(6) NULL,
	 @Hsn VARCHAR(10) NULL,
	 @Custom VARCHAR(100) NULL,
	 @IsReverseCharge BIT NULL,
	 @Pos SMALLINT NULL,
	 @IsUnderIgstAct BIT NULL,
	 @ItcEligibility VARCHAR(20),
	 @TdsComputationStatus SMALLINT NULL,
	 @PaymentStatus SMALLINT NULL,
	 @SectionType VARCHAR(20),
	 @GstActOrRuleSectionType INT NULL,
	 @Status SMALLINT NULL,
	 @AmendmentType SMALLINT NULL,
	 @Amended INT NULL,
	 @LiabilityDischargeReturnPeriod INT NULL,
	 @ItcClaimReturnPeriod INT NULL,
	 @IsCounterPartyFiledData BIT,
	 @IsCounterPartyNotFiledData BIT,
	 @IsRecompute BIT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY,
	 @Start INT,
	 @Size INT,
	 @SortExpression VARCHAR(50),
	 @SourceTypeTaxpayer SMALLINT,
	 @SourceTypeCounterPartyFiled SMALLINT,
	 @SourceTypeCounterPartyNotFiled SMALLINT,
	 @FromDocumentDate DATETIME NULL,
	 @ToDocumentDate DATETIME NULL,
	 @FromStamp DATETIME NULL,
	 @ToStamp DATETIME NULL,
	 @Gstr3bSection INT,
	 @IsErrorRecordsOnly BIT NULL,
	 @AutoDraftSource VARCHAR(40) NULL,
	 @IsAvailableInGstr2B BIT NULL,
	 @IsAvailableInGstr98a BIT NULL,
	 @Gstr98aFinancialYear INT NULL,
	 @TransactionNature SMALLINT,
	 @IsClaimedItcRecords BIT NULL,
	 @ItcAvailability SMALLINT NULL,
	 @ItcUnavailabilityReason SMALLINT NULL,
	 @ItcEligibilityNone SMALLINT,
	 @AmendmentTypeOriginal SMALLINT,
	 @AmendmentTypeOriginalAmended SMALLINT,
	 @AmendmentTypeAmendment SMALLINT,
	 @IncludeCancelOrDeleteRecordsOnly BIT,
	 @ExcludeGstr3BRecordsOnly BIT,
	 @IncludeUploadedByMeRecordsOnly BIT,
	 @ReturnPeriodForItcClaimedRecords INT NULL,
	 @ReturnTypes [common].[SmallIntType] READONLY,
	 @ReturnTypeGstr2 SMALLINT,
	 @ReturnTypeGstr3B SMALLINT,
	 @ReturnActionFile SMALLINT,
	 @ReturnActionSubmit SMALLINT,
	 @IncludePdfRecordsOnly BIT,
	 @TransactionTypeIMPG SMALLINT,
	 @TransactionTypeIMPS SMALLINT,
	 @PushToGstStatusPushed SMALLINT,
	 @ContactTypeBillFrom SMALLINT,
	 @ContactTypeDispatchFrom SMALLINT,
	 @TdsComputationStatusCompleted SMALLINT,
	 @TdsComputationStatusYetNotStarted SMALLINT,
	 @TdsComputationStatusInProgress SMALLINT,
	 @TdsComputationStatusFailed SMALLINT,
	 @ComputationStatusCompleted SMALLINT,
	 @ComputationStatusInProgress SMALLINT,
	 @ComputationStatusFailed SMALLINT,
	 @SourceTypeEInvoice SMALLINT,
	 @DocumentTypeINV SMALLINT,
	 @DocumentTypeCRN SMALLINT,
	 @DocumentTypeDBN SMALLINT,
	 @TransactionTypeB2B SMALLINT,
	 @TransactionTypeB2C SMALLINT,
	 @TransactionTypeSEZWP SMALLINT,
	 @TransactionTypeSEZWOP SMALLINT,
	 @TransactionTypeDE SMALLINT,
	 @TotalRecord INT = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	CREATE TABLE #TempPurchaseDocumentIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
	
	CREATE TABLE #TempPurchaseDocuments
	(
		PurchaseDocumentItemId BIGINT,
		EntityId INT,
		DocumentType SMALLINT
	);
	
	CREATE TABLE #TempVendorDetails
	(
		VendorCode VARCHAR(40),
		Gstin VARCHAR(15)
	);
	
	--CREATE NONCLUSTERED INDEX IDX_TempPurchaseDocumentIds_Id ON #TempPurchaseDocumentIds(Id);
	INSERT INTO #TempPurchaseDocumentIds(Id)
	EXEC [oregular].[FilterPurchaseDocuments]
		@Ids = @Ids,
		@SubscriberId  = @SubscriberId,
		@UserId = @UserId,
		@UserIds = @UserIds,
		@FinancialYear  = @FinancialYear,
		@EntityIds =  @EntityIds,
		@ReturnPeriods = @ReturnPeriods,
		@Gstins = @Gstins,
		@Pans = @Pans,
		@TradeNamesOrLegalNames  = @TradeNamesOrLegalNames,
		@DocumentNumbers  = @DocumentNumbers,
		@DocumentTypes  = @DocumentTypes,
		@TransactionTypes = @TransactionTypes,
		@PushStatuses  = @PushStatuses,
		@RefDocumentNumber = @RefDocumentNumber,
		@RefDocumentDate = @RefDocumentDate,
		@PortCode = @PortCode,
		@OriginalDocumentNumber = @OriginalDocumentNumber,
		@OriginalDocumentDate = @OriginalDocumentDate,
		@OriginalPortCode = @OriginalPortCode,
		@Hsn = @Hsn,
		@Custom = @Custom,
		@IsReverseCharge = @IsReverseCharge,
		@Pos = @Pos,
		@IsUnderIgstAct = @IsUnderIgstAct,
		@ItcEligibility = @ItcEligibility,
		@TdsComputationStatus = @TdsComputationStatus,
		@PaymentStatus = @PaymentStatus,
		@SectionType = @SectionType,
		@GstActOrRuleSectionType = @GstActOrRuleSectionType,
		@Status = @Status,
		@AmendmentType = @AmendmentType,
		@Amended = @Amended,
		@LiabilityDischargeReturnPeriod = @LiabilityDischargeReturnPeriod,
		@ItcClaimReturnPeriod = @ItcClaimReturnPeriod, 
		@IsCounterPartyFiledData = @IsCounterPartyFiledData,
		@IsCounterPartyNotFiledData = @IsCounterPartyNotFiledData,
		@Start  = @Start,
		@Size  = @Size,
		@SortExpression = @SortExpression,
		@TotalRecord = @TotalRecord OUT,
		@SourceTypeTaxpayer = @SourceTypeTaxpayer,
		@SourceTypeCounterPartyNotFiled = @SourceTypeCounterPartyNotFiled,
		@SourceTypeCounterPartyFiled = @SourceTypeCounterPartyFiled,
		@ItcELigibilityNone = @ItcEligibilityNone,
		@FromDocumentDate = @FromDocumentDate,
		@ToDocumentDate = @ToDocumentDate,
		@FromStamp = @FromStamp,
		@ToStamp = @ToStamp,
		@Gstr3bSection = @Gstr3bSection,
		@IsErrorRecordsOnly = @IsErrorRecordsOnly,
		@AutoDraftSource = @AutoDraftSource,
		@IsAvailableInGstr2B = @IsAvailableInGstr2B,
		@IsAvailableInGstr98a = @IsAvailableInGstr98a,
		@Gstr98aFinancialYear = @Gstr98aFinancialYear,
		@IsClaimedItcRecords = @IsClaimedItcRecords,
		@ItcAvailability = @ItcAvailability,
		@ItcUnavailabilityReason = @ItcUnavailabilityReason,
		@AmendmentTypeOriginal = @AmendmentTypeOriginal,
		@AmendmentTypeOriginalAmended = @AmendmentTypeOriginalAmended,
		@AmendmentTypeAmendment = @AmendmentTypeAmendment,
		@IncludeCancelOrDeleteRecordsOnly = @IncludeCancelOrDeleteRecordsOnly,
		@ExcludeGstr3BRecordsOnly = @ExcludeGstr3BRecordsOnly,
		@IncludeUploadedByMeRecordsOnly = @IncludeUploadedByMeRecordsOnly,
		@ReturnPeriodForItcClaimedRecords = @ReturnPeriodForItcClaimedRecords,
		@ReturnTypes = @ReturnTypes,
		@ReturnTypeGstr2 = @ReturnTypeGstr2,
		@ReturnTypeGstr3B = @ReturnTypeGstr3B,
		@ReturnActionFile = @ReturnActionFile,
		@IncludePdfRecordsOnly = @IncludePdfRecordsOnly,
		@TransactionTypeIMPG = @TransactionTypeIMPG,
		@TransactionTypeIMPS = @TransactionTypeIMPS,
		@ReturnActionSubmit = @ReturnActionSubmit,
		@PushToGstStatusPushed = @PushToGstStatusPushed,
		@ContactTypeBillFrom = @ContactTypeBillFrom,
		@ContactTypeDispatchFrom = @ContactTypeDispatchFrom,
		@TdsComputationStatusCompleted = @TdsComputationStatusCompleted,
		@TdsComputationStatusYetNotStarted = @TdsComputationStatusYetNotStarted,
		@TdsComputationStatusInProgress = @TdsComputationStatusInProgress,
		@TdsComputationStatusFailed = @TdsComputationStatusFailed,
		@TransactionNature = @TransactionNature ,
		@ComputationStatusCompleted = @ComputationStatusCompleted,
		@ComputationStatusInProgress = @ComputationStatusInProgress,
		@ComputationStatusFailed = @ComputationStatusFailed,
		@SourceTypeEInvoice = @SourceTypeEInvoice;

		SELECT 
			pdi.Id AS PurchaseDocumentItemId,
			pd.EntityId,
			pd.DocumentType,
			pd.TransactionType,
			pdcbf.Gstin,
			pdcbf.VendorCode
		INTO
			#TempPurchaseDocumentItemDetails
		FROM
			#TempPurchaseDocumentIds tpdi
			INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.PurchaseDocumentId = tpdi.Id
			INNER JOIN oregular.PurchaseDocuments pd ON pd.Id = tpdi.Id
			INNER JOIN oregular.PurchaseDocumentContacts pdcbf ON pdcbf.PurchaseDocumentId = pd.Id AND pdcbf.[Type] = @ContactTypeBillFrom
		WHERE
			pd.DocumentType IN (@DocumentTypeINV, @DocumentTypeDBN)
			AND pd.TransactionType IN (@TransactionTypeB2B, @TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP, @TransactionTypeDE)
			AND (pdi.[Description] IS NOT NULL OR pdi.Hsn IS NOT NULL)
			AND (
					(@IsRecompute = 1 AND  ISNULL(pdi.ComputationStatus, 0) <> @ComputationStatusInProgress)
					OR (@IsRecompute = 0 AND  ISNULL(pdi.ComputationStatus, 0) NOT IN (@ComputationStatusInProgress, @ComputationStatusCompleted))
				);

		SELECT DISTINCT
			tpdid.Gstin,
			tpdid.VendorCode
		INTO
			#TempPurchaseDocumentVendorDetails
		FROM 
			#TempPurchaseDocumentItemDetails tpdid;

		INSERT INTO #TempVendorDetails
		(
			Gstin,
			VendorCode
		)
		SELECT
			vd.Gstin,
			vd.Code AS VendorCode
		FROM
			#TempPurchaseDocumentVendorDetails tpdvd
			INNER JOIN subscriber.VendorDetails vd ON
			(
				vd.SubscriberId = @SubscriberId 
				AND vd.Gstin = tpdvd.Gstin
			)
		WHERE
			vd.Pan IS NOT NULL
			AND vd.PanValidationStatus IS NOT NULL
			AND vd.PanITRStatus IS NOT NULL
			AND vd.PanAadhaarSeedingStatus IS NOT NULL
		UNION
		SELECT
			vd.Gstin,
			vd.Code AS VendorCode
		FROM
			#TempPurchaseDocumentVendorDetails tpdvd
			INNER JOIN subscriber.VendorDetails vd ON
			(
				vd.SubscriberId = @SubscriberId 
				AND vd.Code = tpdvd.VendorCode
			)
		WHERE
			vd.Pan IS NOT NULL
			AND vd.PanValidationStatus IS NOT NULL
			AND vd.PanITRStatus IS NOT NULL
			AND vd.PanAadhaarSeedingStatus IS NOT NULL

		INSERT INTO #TempPurchaseDocuments
		(
			PurchaseDocumentItemId,
			EntityId,
			DocumentType
		)
		SELECT 
			 tpdid.PurchaseDocumentItemId,
			 tpdid.EntityId,
			 tpdid.DocumentType
		FROM
			#TempPurchaseDocumentItemDetails tpdid
			INNER JOIN #TempVendorDetails vd ON
			(
				vd.Gstin = tpdid.Gstin
				AND tpdid.TransactionType <> @TransactionTypeB2C 
			)
		UNION
		SELECT 
			 tpdid.PurchaseDocumentItemId,
			 tpdid.EntityId,
			 tpdid.DocumentType
		FROM
			#TempPurchaseDocumentItemDetails tpdid
			INNER JOIN #TempVendorDetails vd ON
			(
				vd.VendorCode = tpdid.VendorCode
				AND tpdid.TransactionType = @TransactionTypeB2C 
			);

		UPDATE 
			pdi
		SET
			ComputationStatus = @ComputationStatusInProgress,
			TdsErrors = NULL,
			ModifiedStamp = GETDATE()
		FROM
			#TempPurchaseDocuments tpd
			INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.Id = tpd.PurchaseDocumentItemId;

		SELECT 
			 PurchaseDocumentItemId,
			 EntityId,
			 DocumentType
		FROM
			#TempPurchaseDocuments;

	DROP TABLE 
		#TempPurchaseDocumentIds, 
		#TempPurchaseDocuments, 
		#TempVendorDetails, 
		#TempPurchaseDocumentItemDetails, 
		#TempPurchaseDocumentVendorDetails;
END

GO

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [oregular].[UpdateTdsDetailsByItemIds]
* 	Comments			: 01-09-2023 | Dhruv Amin | This procedure is used to update purchase document item tds detail by itemId. (CGSP2-5663)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	    : DECLARE  @TdsDetails [oregular].[TdsDetailsType];

						  EXEC [oregular].[UpdateTdsDetailsByItemIds]
								@TdsDetails =  @TdsDetails;
*/-----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [oregular].[UpdateTdsDetailsByItemIds]
(
	@TdsDetails [oregular].[TdsDetailsType] READONLY,
	@AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;
	END;

	SELECT 
		*
	INTO
		#TempTdsDetails
	FROM 
		@TdsDetails;

	IF EXISTS(SELECT 1 FROM @AuditTrailDetails)
	BEGIN
		EXEC [audit].[UpdateAuditDetails]
			@AuditTrailDetails =  @AuditTrailDetails;

		CREATE TABLE #TempPurchaseDocumentIds
		(
			Id BIGINT NOT NULL
		);

		INSERT INTO #TempPurchaseDocumentIds
		SELECT DISTINCT
			pdi.PurchaseDocumentId AS Id
		FROM 
			#TempTdsDetails ttd
			INNER JOIN oregular.PurchaseDocumentItems pdi ON ttd.PurchaseDocumentItemId = pdi.Id; 

		UPDATE pds
		SET
			ModifiedStamp = GETDATE()
		FROM
			oregular.PurchaseDocumentStatus pds
			INNER JOIN #TempPurchaseDocumentIds tpdi ON pds.PurchaseDocumentId = tpdi.Id;
	END;
	
	UPDATE
		pdi
	SET
		ComputationStatus = ttd.ComputationStatus,			
		TdsAmount = ISNULL(ttd.TdsAmount, pdi.TdsAmount),				
		TdsRate = ISNULL(ttd.TdsRate, pdi.TdsRate),			
		TdsTaxSection = ISNULL(ttd.TaxSection, pdi.TdsTaxSection),			
		IsTdsApplicable = ISNULL(ttd.IsTdsApplicable, pdi.IsTdsApplicable),
		IsTdsThresholdCrossed = ISNULL(ttd.IsTdsThresholdCrossed, pdi.IsTdsThresholdCrossed),		
		IsLdcApplied = ISNULL(ttd.IsLdcApplied, pdi.IsLdcApplied),			
		LdcCertificateId = ISNULL(ttd.LdcCertificateId, pdi.LdcCertificateId),		
		TdsConfidenceScore = ISNULL(ttd.TdsConfidenceScore,pdi.TdsConfidenceScore),	
		TdsRulePath = ISNULL(ttd.TdsRulePath,pdi.TdsRulePath),	
		TdsErrors = ttd.Errors,
		ModifiedStamp = GETDATE()
	FROM
		#TempTdsDetails ttd
		INNER JOIN oregular.PurchaseDocumentItems pdi ON pdi.Id = ttd.PurchaseDocumentItemId;

	DROP TABLE #TempTdsDetails;
END

GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [subscriber].[DeleteVendors] 	 
* 	Comments			: 06-04-2020 | Kartik Bariya | This procedure is used to Delete Vendors.
* 	Comments			: 16-12-2020 | Abhishek Shrivas | This procedure called inside another procedure, there is no optimization required in main procedure
						: 18/05/2021 | Prakash Parmar | Added ChangedGstin and BitTypeYes Parameters
						: 18/05/2021 | Chandresh Prajapati | Changed VerifiedAgings string to table type
						: 07/04/2022 | Chandresh Prajapati | Added FromUploadedDate and ToUploadedDate
						: 10/05/2022 | Rippal Patel | Added FromChangeDate and ToChangeDate filter
						: 26/05/2022 | Rippal Patel : Added IsPreferred filter
						: 11/07/2022 | Chandresh Prajapati | Added UserIds Parameters
						: 06/12/2022 | Chandresh Prajapati | Added TaxpayerTypes Parameters
						: 21-03-2022 | Krishna Shah | Added VendorType.
						: 27-03-2023 | Bhavik Patel | return deleted gstins.
						: 04-04-2023 | Krishna Shah | Added EinvoiceEnablementStatus.
						: 11-04-2023 | Krishna Shah | Added TaxpayerStatus.
						: 07-08-2023 | Krishna Shah | Added Ldc Detail.
						: 12-09-2023 | Chandresh Prajapati | Added IncludeSendVendorsKycRecordsOnly.
						: 20-10-2023 | Chandresh Prajapati | Added VendorKycStatus filter.
						: 16-01-2023 | Sumant Kumar  | Added BlacklistedVendor Column.
						: 24-01-2024 | Chandresh Prajapati | Added Notification Filters.
						: 16-02-2024 | Sumant Kumar | Added Gstr1GrcScore and Gstr3bGrcScore Filter.
						: 04-03-2024 | Sumant Kumar	| Modify Gstr1GrcScore and Gstr3bGrcScore to single filter GstrGrcScore.
						: 02-05-2024 | Chandresh Prajapati	| Added AuditTrailDetails Parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE  @TotalRecord INT,
								@Ids [common].[BigIntType]
								@VerifiedAgings AS [common].[IntType];

  						  INSERT INTO @Ids VALUES (3);
						  --INSERT INTO  @VerifiedAgings VALUES (2);
						  EXEC [subscriber].[DeleteVendors]
								@Ids =  @Ids,
								@SubscriberId  = 164 ,
						  		@Gstins = null,
								@Codes =null,
								@TradeNames = null,
								@LegalNames = null,
								@StateCodes = null,
								@PinCodes = null,
								@FromVerifiedDate = null,
								@ToVerifiedDate = null,
								@VerifiedAgings = @VerifiedAgings,
								@VerificationStatuses = null,
								@TaxpayerTypes = null,
								@IsPreferred = null,
								@VerificationError = null,
								@Custom = null,
								@BitTypeYes = 1,
								@UserIds = NULL,
								@FromUploadedDate = NULL,
								@ToUploadedDate = NULL,
								@FromChangeDate = NULL,
								@ToChangeDate = NULL,
						  		@Start  = 0,
						  		@Size  = 1000,
						  		@SortExpression = 'id desc',
								@IncludeVendorVerificationStatuses = '1,2,3',
								@VendorKycStatuses = NULL,
								@NotificationType =  NULL,
								@NotificationStatuses  = NULL,
								@NotificationError = NULL,
								@NotificationTypeSent  = 1,
								@NotificationTypeReceived  = 2,
								@AuditTrailDetails = @AuditTrailDetails;
						  		@TotalRecord  = @TotalRecord OUT
						  		Select @TotalRecord;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [subscriber].[DeleteVendors]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @Gstins VARCHAR(MAX),
	 @Codes VARCHAR(MAX),
	 @TradeNames VARCHAR(MAX),
	 @LegalNames VARCHAR(MAX),
	 @StateCodes VARCHAR(MAX),
	 @Pincodes VARCHAR(MAX),
	 @FromVerifiedDate DATETIME NULL,
	 @ToVerifiedDate DATETIME NULL,
	 @VerifiedAgings [common].[IntType] READONLY,
	 @VerificationStatuses VARCHAR(MAX),
	 @VendorType Smallint,
	 @TaxpayerTypes VARCHAR(MAX),
	 @IsPreferred BIT NULL,
	 @VerificationError BIT NULL,
	 @Custom VARCHAR(2000),
	 @BitTypeYes BIT,
	 @UserIds VARCHAR(MAX),
	 @FromUploadedDate DATETIME,
	 @ToUploadedDate DATETIME,
	 @FromChangeDate DATETIME,
	 @ToChangeDate DATETIME,
	 @EnablementStatus SMALLINT,
	 @VendorEnablementStatusYes SMALLINT,
	 @VendorEnablementStatusNo SMALLINT,
	 @VendorEnablementStatusNotAvailable SMALLINT,
	 @IsVerifiedAndAutoPopulateRequest BIT,
	 @TaxpayerStatuses [common].[IntType] READONLY,
	 @TaxpayerStatusNotAvailable INTEGER,
	 @Pans VARCHAR(MAX),
	 @Tans VARCHAR(MAX),
	 @LdcNotAvailable SMALLINT,
	 @LdcAvailability SMALLINT,
	 @LdcAvailable SMALLINT,
	 @LdcExpiring SMALLINT,
	 @LdcExpired SMALLINT,
	 @SortExpression VARCHAR(128),
	 @Start INT,
	 @Size INT,
	 @IncludeVendorVerificationStatuses VARCHAR(20) NULL,
	 @VendorTypeV smallint,
	 @VendorKycStatuses varchar(max),
	 @IncludeSendVendorsKycRecordsOnly bit,
	 @NotificationType SMALLINT,
	 @NotificationStatuses VARCHAR(MAX),
	 @NotificationError BIT,
	 @NotificationTypeSent SMALLINT,
	 @NotificationTypeReceived SMALLINT,
	 @TotalRecord INT = NULL OUTPUT,
	 @BlacklistedVendor BIT,
	 @GrcScoreFrom SMALLINT,
	 @GrcScoreTo SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempVendorIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);
	CREATE NONCLUSTERED INDEX IDX_TempVendorIds_Id ON #TempVendorIds(Id);

	INSERT INTO #TempVendorIds(Id)
	EXEC [subscriber].[FilterVendors]
		@Ids = @Ids,
		@SubscriberId = @SubscriberId,
		@Gstins = @Gstins,
		@Codes = @Codes, 
		@TradeNames = @TradeNames,
		@LegalNames = @LegalNames,
		@StateCodes = @StateCodes,
		@Pincodes = @Pincodes,
		@FromVerifiedDate = @FromVerifiedDate,
		@ToVerifiedDate = @ToVerifiedDate,
		@VerifiedAgings = @VerifiedAgings,
		@VerificationStatuses = @VerificationStatuses,
		@VendorType = @VendorType,
		@TaxpayerTypes = @TaxpayerTypes,
		@IsPreferred = @IsPreferred,
		@VerificationError = @VerificationError,
		@Custom = @Custom,
		@BitTypeYes = @BitTypeYes,
		@UserIds = @UserIds,
		@FromUploadedDate = @FromUploadedDate,
		@ToUploadedDate = @ToUploadedDate,
		@FromChangeDate = @FromChangeDate,
		@ToChangeDate = @ToChangeDate,
		@EnablementStatus = @EnablementStatus,
		@VendorEnablementStatusYes = @VendorEnablementStatusYes,
		@VendorEnablementStatusNo = @VendorEnablementStatusNo,
		@VendorEnablementStatusNotAvailable = @VendorEnablementStatusNotAvailable,
		@IsVerifiedAndAutoPopulateRequest =  @IsVerifiedAndAutoPopulateRequest,
		@TaxpayerStatuses = @TaxpayerStatuses,
		@TaxpayerStatusNotAvailable = @TaxpayerStatusNotAvailable,
		@Pans  = @Pans,
		@Tans = @Tans,
		@LdcAvailability = @LdcAvailability,
		@LdcAvailable = @LdcAvailable,
		@LdcNotAvailable = @LdcNotAvailable,
		@LdcExpiring = @LdcExpiring,
		@LdcExpired = @LdcExpired,
 		@SortExpression = @SortExpression,
		@Start = @Start,
		@Size = @Size ,
		@IncludeVendorVerificationStatuses = @IncludeVendorVerificationStatuses,
		@VendorTypeV = @VendorTypeV,
		@VendorKycStatuses  = @VendorKycStatuses,
		@IncludeSendVendorsKycRecordsOnly = @IncludeSendVendorsKycRecordsOnly,
		@NotificationType = @NotificationType,
		@NotificationStatuses = @NotificationStatuses,
		@NotificationError = @NotificationError,
		@NotificationTypeSent  = @NotificationTypeSent,
		@NotificationTypeReceived = @NotificationTypeReceived,
		@TotalRecord = @TotalRecord OUTPUT,
		@BlacklistedVendor = @BlacklistedVendor,	 
		@GrcScoreFrom = @GrcScoreFrom ,
	    @GrcScoreTo = @GrcScoreTo

	DELETE 
		vld
	FROM 
		subscriber.VendorLdcDetails vld
		INNER JOIN #TempVendorIds tvid ON tvid.Id = vld.VendorId;

	DELETE 
		sv
	OUTPUT
		DELETED.Gstin, DELETED.TradeName, DELETED.Code
	FROM 
		[subscriber].Vendors sv
		INNER JOIN #TempVendorIds tvid ON tvid.Id = sv.Id

	DROP TABLE #TempVendorIds;
END
GO
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: [subscriber].[VerifyAndDownloadVendors] 	 	 
* 	Comments			: 22-07-2021 | Abbas Pisawadwala | This procedure is used to Download Vendors Data.
						: 07/04/2022 | Chandresh Prajapati | Added FromUploadedDate and ToUploadedDate
						: 10/05/2022 | Rippal Patel | Added FromChangeDate and ToChangeDate
						: 11/07/2022 | Chandresh Prajapati | Added UserIds Parameters
						: 06/12/2022 | Chandresh Prajapati | Added TaxpayerTypes Parameters
						: 21-03-2022 | Krishna Shah | Added VendorType.
						: 04-04-2023 | Krishna Shah | Added EinvoiceEnablementStatus.
						: 11-04-2023 | Krishna Shah | Added TaxpayerStatus.
						: 07-08-2023 | Krishna Shah | Added Ldc Detail.
						: 12-09-2023 | Chandresh Prajapati | Added IncludeSendVendorsKycRecordsOnly.
						: 20-10-2023 | Chandresh Prajapati | Added VendorKycStatus filter.
						: 16-01-2023 | Sumant Kumar  | Added BlacklistedVendor Column
						: 24-01-2024 | Chandresh Prajapati | Added Notification Filters.
						: 16-02-2024 | Sumant Kumar | Added Gstr1GrcScore and Gstr3bGrcScore Filter.
						: 04-03-2024 | Sumant Kumar	| Modify Gstr1GrcScore and Gstr3bGrcScore to single filter GstrGrcScore.
						: 02-05-2024 | Chandresh Prajapati	| Added AuditTrailDetails Parameter
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution		: DECLARE  @TotalRecord INT,
								@Ids [common].[BigIntType]
								@VerifiedAgings AS [common].[IntType];

  						  --INSERT INTO @Ids VALUES (340);
						  --INSERT INTO  @VerifiedAgings VALUES (2);
						  EXEC [subscriber].[VerifyAndDownloadVendors]
								@Ids =  @Ids,
								@SubscriberId  = 164 ,
						  		@Gstins = null,
								@Codes =null,
								@TradeNames = null,
								@LegalNames = null,
								@StateCodes = null,
								@PinCodes = null,
								@FromVerifiedDate = null,
								@ToVerifiedDate = null,
								@VerifiedAgings = @VerifiedAgings,
								@VerificationStatuses = null,
								@TaxpayerTypes = null,
								@IsPreferred = null,
								@Custom = null,
								@BitTypeYes = 1,
								@UserIds = NULL,
								@FromUploadedDate = NULL,
								@ToUploadedDate = NULL,
								@FromChangeDate = NULL,
								@ToChangeDate = NULL,
								@VendorKycStatuses = NULL,
						  		@Start  = 0,
						  		@Size  = 1000,
						  		@SortExpression = 'id desc',
								@IncludeVendorVerificationStatuses = '1,2,3',
								@NotificationType =  NULL,
								@NotificationStatuses  = NULL,
								@NotificationError = NULL,
								@NotificationTypeSent  = 1,
								@NotificationTypeReceived  = 2,
								@AuditTrailDetails = @AuditTrailDetails,
						  		@TotalRecord  = @TotalRecord OUT
						  		Select @TotalRecord;
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [subscriber].[VerifyAndDownloadVendors]
(
	 @Ids [common].[BigIntType] READONLY,
	 @SubscriberId INT,
	 @Gstins VARCHAR(MAX),
	 @Codes VARCHAR(MAX),
	 @TradeNames VARCHAR(MAX),
	 @LegalNames VARCHAR(MAX),
	 @StateCodes VARCHAR(MAX),
	 @Pincodes VARCHAR(MAX),
	 @FromVerifiedDate DATETIME NULL,
	 @ToVerifiedDate DATETIME NULL,
	 @VerifiedAgings [common].[IntType] READONLY,
	 @VerificationStatuses VARCHAR(MAX),
	 @VendorType Smallint,
	 @TaxpayerTypes VARCHAR(MAX),
	 @IsPreferred BIT NULL,
	 @VerificationError BIT,
	 @Custom VARCHAR(2000),
	 @BitTypeYes BIT,
	 @UserIds VARCHAR(MAX),
	 @FromUploadedDate DATETIME,
	 @ToUploadedDate DATETIME,
	 @FromChangeDate DATETIME,
	 @EnablementStatus SMALLINT,
	 @VendorEnablementStatusYes SMALLINT,
	 @VendorEnablementStatusNo SMALLINT,
	 @VendorEnablementStatusNotAvailable SMALLINT,
	 @ToChangeDate DATETIME,
	 @IsVerifiedAndAutoPopulateRequest BIT,
	 @TaxpayerStatuses [common].[IntType] READONLY,
	 @TaxpayerStatusNotAvailable INTEGER,
	 @Pans VARCHAR(MAX),
	 @Tans VARCHAR(MAX),
	 @LdcAvailability SMALLINT,
	 @LdcNotAvailable SMALLINT,
	 @LdcAvailable SMALLINT,
	 @LdcExpiring SMALLINT,
	 @LdcExpired SMALLINT,
	 @SortExpression VARCHAR(128),
	 @Start INT,
	 @Size INT,
	 @IncludeVendorVerificationStatuses VARCHAR(20) NULL,
	 @VendorVerificationStatusInProgress SMALLINT,
	 @VendorTypeV smallint,
	 @VendorKycStatuses varchar(max),
	 @IncludeSendVendorsKycRecordsOnly bit,
	 @NotificationType SMALLINT,
	 @NotificationStatuses VARCHAR(MAX),
	 @NotificationError BIT,
	 @NotificationTypeSent SMALLINT,
	 @NotificationTypeReceived SMALLINT,
	 @TotalRecord INT = NULL OUTPUT,
	 @BlacklistedVendor BIT,
	 @GrcScoreFrom SMALLINT,
	 @GrcScoreTo SMALLINT,
	 @AuditTrailDetails [audit].[AuditTrailDetailsType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempDownloadVendors
	(
		Id BIGINT,
		Gstin VARCHAR(15),
		City VARCHAR(50),
		Pincode INT,
		UseAdditionalAddress BIT,
		VerificationStatus SMALLINT
	);

	CREATE TABLE #TempVendorIds
	(
		Id BIGINT
	);

	CREATE NONCLUSTERED INDEX IDX_TempVendorIds_Id ON #TempVendorIds(Id);

	INSERT INTO #TempVendorIds
	(
		Id
	)
	EXEC [subscriber].[FilterVendors]
		@Ids = @Ids,
		@SubscriberId = @SubscriberId,
		@Gstins = @Gstins,
		@Codes = @Codes, 
		@TradeNames = @TradeNames,
		@LegalNames = @LegalNames,
		@StateCodes = @StateCodes,
		@Pincodes = @Pincodes,
		@FromVerifiedDate = @FromVerifiedDate,
		@ToVerifiedDate = @ToVerifiedDate,
		@VerifiedAgings = @VerifiedAgings,
		@VerificationStatuses = @VerificationStatuses,
		@VendorType = @VendorType,
		@TaxpayerTypes = @TaxpayerTypes,
		@IsPreferred = @IsPreferred,
		@VerificationError = @VerificationError,
		@Custom = @Custom,
		@BitTypeYes = @BitTypeYes,
		@UserIds = @UserIds,
		@FromUploadedDate = @FromUploadedDate,
		@ToUploadedDate = @ToUploadedDate,
		@FromChangeDate = @FromChangeDate,
		@ToChangeDate = @ToChangeDate,
		@EnablementStatus = @EnablementStatus,
		@VendorEnablementStatusYes = @VendorEnablementStatusYes,
		@VendorEnablementStatusNo = @VendorEnablementStatusNo,
		@VendorEnablementStatusNotAvailable = @VendorEnablementStatusNotAvailable,
		@IsVerifiedAndAutoPopulateRequest =  @IsVerifiedAndAutoPopulateRequest,
		@TaxpayerStatuses = @TaxpayerStatuses,
		@TaxpayerStatusNotAvailable = @TaxpayerStatusNotAvailable,
		@Pans  = @Pans,
		@Tans = @Tans,
		@LdcAvailability = @LdcAvailability ,
		@LdcNotAvailable =  @LdcNotAvailable, 
		@LdcAvailable =  @LdcAvailable,
		@LdcExpiring = @LdcExpiring,
		@LdcExpired = @LdcExpired,
		@SortExpression = @SortExpression,
		@Start = @Start,
		@Size = @Size ,
		@IncludeVendorVerificationStatuses = @IncludeVendorVerificationStatuses,
		@VendorTypeV = @VendorTypeV,
		@VendorKycStatuses = @VendorKycStatuses,
		@IncludeSendVendorsKycRecordsOnly = @IncludeSendVendorsKycRecordsOnly,
		@NotificationType = @NotificationType,
		@NotificationStatuses = @NotificationStatuses,
		@NotificationError = @NotificationError,
		@NotificationTypeSent  = @NotificationTypeSent,
		@NotificationTypeReceived = @NotificationTypeReceived,
		@TotalRecord = @TotalRecord OUTPUT,
		@BlacklistedVendor = @BlacklistedVendor,
	    @GrcScoreFrom = @GrcScoreFrom ,
	    @GrcScoreTo = @GrcScoreTo;

	UPDATE
		v
	SET
		v.VerificationStatus = @VendorVerificationStatusInProgress
	OUTPUT 
		inserted.Id, inserted.Gstin, inserted.City, inserted.Pincode, inserted.UseAdditionalAddress, deleted.VerificationStatus
	INTO 
		#TempDownloadVendors(Id, Gstin, City,Pincode,UseAdditionalAddress,VerificationStatus)
	FROM
		subscriber.Vendors AS v
		INNER JOIN #TempVendorIds ti ON v.Id = ti.Id;

	SELECT
		Id,
		Gstin,
		City,
		Pincode,
		UseAdditionalAddress,
		VerificationStatus
	FROM
		#TempDownloadVendors;
	
	DROP TABLE #TempDownloadVendors, #TempVendorIds;
END
GO
