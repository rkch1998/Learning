DROP PROCEDURE IF EXISTS [einvoice].[InsertDocuments];
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
;
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
;
GO


