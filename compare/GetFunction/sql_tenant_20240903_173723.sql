DROP PROCEDURE IF EXISTS [report].[InsertRegularReturns3WayReconciliation];
GO




/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		: report.Insert3WayReconciliation
* 	Comments			: 2020-08-28 | Pooja Rajpurohit | Insert Sales and Purchase reconcilation data in Gst reco mapper table.
----------------------------------------------------------------------------------------------------------------------------------------
*	Test Execution	:	DROP TABLE IF EXISTS #TempEwaybillDuplicateEntries, #GstPushStatuses, #EInvoicePushStatuses,#EwaybillPushStatuses
,#AutoDraftPushStatuses;
						CREATE TABLE #TempEwaybillDuplicateEntries
						(
							id BIGINT not null
						)

						CREATE TABLE #GstPushStatuses
						(
							item smallint
						);
						CREATE TABLE #EInvoicePushStatuses
						(
							item smallint
						);
						CREATE TABLE #EwaybillPushStatuses
						(
							item smallint
						);
						CREATE TABLE #AutoDraftPushStatuses
						(
							item smallint
						);


EXEC [report].[InsertRegularReturns3WayReconciliation]
 
	 @SubscriberId = 164
	,@ParentEntityId = 662
	,@FinancialYear = 202021
			
	,@DocumentTypeINV = 1							
	,@DocumentTypeCRN = 2
	,@DocumentTypeDBN = 3
	,@DocumentTypeBOE = 4 
	,@DocumentTypeCHL = 7
	,@DocumentTypeBIL = 8
	,@PurposeTypeEINV = 2
	,@PurposeTypeEWB = 8

	,@SupplyTypeSale = 1
	,@SupplyTypePurchase = 2
 
	,@SourceTypeTaxpayer  = 1
	,@SourceTypeAutoDraft  = 4

	,@TransactionTypeB2B = 1
	,@TransactionTypeB2C = 12
	,@TransactionTypeSEZWP = 4
	,@TransactionTypeSEZWOP = 5
	,@TransactionTypeEXPWP = 2
	,@TransactionTypeEXPWOP = 3
	,@TransactionTypeDE = 6
	,@TransactionTypeJWR = null
	,@TransactionTypeJW = null
	,@TransactionTypeKD = null
	,@IsDocumentDateReturnPeriod = null
	,@TransactionTypeIMPG = 7
	,@TransactionTypeCBW = 25
	,@TransactionTypeOTH = 23
	,@ReconciliationSectionTypeGstNotAvailable = 1
	,@ReconciliationSectionTypeGstMatched = 2
	,@ReconciliationSectionTypeGstMismatched = 3
	,@ReconciliationSectionTypeEwbNotAvailable = 4
	,@ReconciliationSectionTypeEwbMatched = 5
	,@ReconciliationSectionTypeEwbMismatched = 6
	,@ReconciliationSectionTypeEinvNotAvailable = 7
	,@ReconciliationSectionTypeEinvMatched = 8
	,@ReconciliationSectionTypeEinvMismatched = 9
	,@ReconciliationSectionTypeGstAutodraftedMatched  = 21
	,@ReconciliationSectionTypeGstAutodraftedMismatched = 22
	,@ReconciliationSectionTypeGstAutodraftedNotAvailable = 23
	,@ReconciliationSectionTypeEwbNotApplicable = null											 

	,@ContactTypeBillFromGstin = 3
	,@ReconciliationReasonTypeTaxAmount = 4
	,@ReconciliationReasonTypeItems = 8
	,@ReconciliationReasonTypeSgstAmount = 16
	,@ReconciliationReasonTypeCgstAmount = 32
	,@ReconciliationReasonTypeIgstAmount = 64
	,@ReconciliationReasonTypeCessAmount = 128
	,@ReconciliationReasonTypeTaxableValue = 256
	,@ReconciliationReasonTypeTransactionType = 512
	,@ReconciliationReasonTypePOS = 1024
	,@ReconciliationReasonTypeRate = NULL
	,@ReconciliationReasonTypeReverseCharge = 2048
	,@ReconciliationReasonTypeDocumentValue = 4096
	,@ReconciliationReasonTypeDocumentDate = 8192
	,@ReconciliationReasonTypeDocumentNumber = 16384
	,@ReconciliationReasonTypeGstin = null
	,@SettingTypeExcludeOtherCharges =null
	,@IsMatchByTolerance =null
	,@MatchByToleranceDocumentValueFrom =null
	,@MatchByToleranceDocumentValueTo =null
	,@MatchByToleranceTaxableValueFrom =null
	,@MatchByToleranceTaxableValueTo =null
	,@MatchByToleranceTaxAmountsFrom =null
	,@MatchByToleranceTaxAmountsTo =null
	,@DocValueThresholdForRecoAgainstEwb =null

	,@IsExcludeMatchingCriteriaTransactionType = null
	,@IsExcludeMatchingCriteriaGstin = null	
	,@ReconciliationReasonTypeEinvApplicable = null
	,@ReconciliationReasonTypeEinvNotApplicable = null
	,@TaxTypeTaxable = null
	,@LocationTaxpayerType = null
	,@TaxPayerTypeSEZDeveloper = null
	,@TaxPayerTypeSEZUnit = null
*/--------------------------------------------------------------------------------------------------------------------------------------
CREATE   PROCEDURE [report].[InsertRegularReturns3WayReconciliation]
(
 	 @SubscriberId AS INT
	,@ParentEntityId AS INT
	,@FinancialYear AS INT	
	/* Enums */
	,@DocumentTypeINV SMALLINT
	,@DocumentTypeCRN SMALLINT
	,@DocumentTypeDBN SMALLINT
	,@DocumentTypeBOE SMALLINT
	,@DocumentTypeCHL SMALLINT
	,@DocumentTypeBIL SMALLINT		
	,@PurposeTypeEINV SMALLINT	
	,@PurposeTypeEWB SMALLINT

	,@SupplyTypeSale SMALLINT 
	,@SupplyTypePurchase SMALLINT
	
	,@SourceTypeTaxpayer SMALLINT 
	,@SourceTypeAutoDraft SMALLINT

	,@TransactionTypeB2B SMALLINT
	,@TransactionTypeB2C SMALLINT
	,@TransactionTypeSEZWP SMALLINT
	,@TransactionTypeSEZWOP SMALLINT
	,@TransactionTypeEXPWP SMALLINT
	,@TransactionTypeEXPWOP SMALLINT
	,@TransactionTypeDE SMALLINT
	,@TransactionTypeIMPG SMALLINT
	,@TransactionTypeCBW SMALLINT
	,@TransactionTypeOTH SMALLINT
	,@TransactionTypeKD SMALLINT
	,@TransactionTypeJW SMALLINT
	,@TransactionTypeJWR SMALLINT
	,@IsDocumentDateReturnPeriod BIT
	,@ReconciliationSectionTypeGstNotAvailable SMALLINT
	,@ReconciliationSectionTypeGstMatched SMALLINT
	,@ReconciliationSectionTypeGstMismatched SMALLINT
	,@ReconciliationSectionTypeEwbNotAvailable SMALLINT
	,@ReconciliationSectionTypeEwbMatched SMALLINT
	,@ReconciliationSectionTypeEwbMismatched SMALLINT
	,@ReconciliationSectionTypeEinvNotAvailable SMALLINT
	,@ReconciliationSectionTypeEinvMatched SMALLINT
	,@ReconciliationSectionTypeEinvMismatched SMALLINT
	,@ReconciliationSectionTypeGstAutodraftedMatched SMALLINT 
	,@ReconciliationSectionTypeGstAutodraftedMismatched SMALLINT 
	,@ReconciliationSectionTypeGstAutodraftedNotAvailable SMALLINT 
	,@ReconciliationSectionTypeEwbNotApplicable SMALLINT
	,@ContactTypeBillFromGstin SMALLINT
	,@ReconciliationReasonTypeTaxAmount BIGINT
	,@ReconciliationReasonTypeItems BIGINT
	,@ReconciliationReasonTypeSgstAmount BIGINT
	,@ReconciliationReasonTypeCgstAmount BIGINT
	,@ReconciliationReasonTypeIgstAmount BIGINT
	,@ReconciliationReasonTypeCessAmount BIGINT
	,@ReconciliationReasonTypeTaxableValue BIGINT
	,@ReconciliationReasonTypeTransactionType BIGINT
	,@ReconciliationReasonTypePOS BIGINT
	,@ReconciliationReasonTypeRate BIGINT
	,@ReconciliationReasonTypeReverseCharge BIGINT
	,@ReconciliationReasonTypeDocumentValue BIGINT
	,@ReconciliationReasonTypeDocumentDate BIGINT
	,@ReconciliationReasonTypeDocumentNumber BIGINT
	,@ReconciliationReasonTypeGstin BIGINT
	,@SettingTypeExcludeOtherCharges SMALLINT
	,@IsMatchByTolerance BIT
	,@MatchByToleranceDocumentValueFrom  DECIMAL(15,2)
	,@MatchByToleranceDocumentValueTo DECIMAL(15,2)
	,@MatchByToleranceTaxableValueFrom DECIMAL(15,2)
	,@MatchByToleranceTaxableValueTo  DECIMAL(15,2)
	,@MatchByToleranceTaxAmountsFrom DECIMAL(15,2)
	,@MatchByToleranceTaxAmountsTo DECIMAL(15,2)
	,@DocValueThresholdForRecoAgainstEwb DECIMAL(15,2)

	,@IsExcludeMatchingCriteriaTransactionType BIT
	,@IsExcludeMatchingCriteriaGstin BIT
	,@ReconciliationReasonTypeEinvApplicable bigint
	,@ReconciliationReasonTypeEinvNotApplicable bigint
	,@TaxTypeTaxable smallint
	,@LocationTaxpayerType smallint
	,@TaxPayerTypeSEZDeveloper smallint
	,@TaxPayerTypeSEZUnit smallint
)
AS
BEGIN

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET DEADLOCK_PRIORITY HIGH;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRY

	DECLARE @TRUE AS BIT = 1,
			@FALSE AS BIT = 0,
			@PurposeTypeBoth SMALLINT = @PurposeTypeEInv + @PurposeTypeEWB,
			@MappingTypeMonthly TINYINT = 1,
			@MappingTypeYearly TINYINT = 2;			

	DROP TABLE IF EXISTS #TempEinvoiceData,#TempEinvoiceDetailData,#TempEinvoiceUnreconciledIds,#TempEwayBillData,#TempEwaybillDetailData,#TempEwaybillUnreconciledIds						 
						 ,#TempGstUnreconciledIds,#TempRegularReturnData,#TempRegularReturnDetailData,#TempYearlyGstEinvdetailComp
						,#TempYearlyGstEInvHeaderMatching,#TempYearlyGstEinvMatchedId,#TempYearlyGstEinvReco,#TempYearlyGstEwbdetailComparison,#TempYearlyGstEwbHeaderDataMatching
						,#TempYearlyGstEwbMatchedIds,#TempYearlyGstEwbReco,#TempAutoDraftData,#TempAutoDraftDetailData,#TempAutoDraftUnreconciledIds,#TempYearlyGstAutoDraftdetailComp
						,#TempYearlyGstAutoDraftHeaderMatching,#TempYearlyGstAutoDraftMatchedId,#TempYearlyGstAutoDraftReco

	CREATE TABLE #TempEwaybillUnreconciledIds
	(		
		EwbId BIGINT NOT NULL
	)

	CREATE CLUSTERED INDEX IDX_#TempEwaybillUnreconciledIds ON #TempEwaybillUnreconciledIds(EwbId)

	CREATE TABLE #TempEinvoiceUnreconciledIds
	(		
		EInvId BIGINT NOT NULL
	)

	CREATE CLUSTERED INDEX IDX_#TempEinvoiceUnreconciledIds ON #TempEinvoiceUnreconciledIds(EInvId)

	CREATE TABLE #TempGstUnreconciledIds
	(		
		GstId BIGINT NOT NULL,
		SupplyType TINYINT NOT NULL

	)
	CREATE CLUSTERED INDEX IDX_#TempGstUnreconciledIds ON #TempGstUnreconciledIds(GstId)		

	CREATE TABLE #TempAutoDraftUnreconciledIds
	(		
		AutoDraftId BIGINT NOT NULL
	)
	CREATE CLUSTERED INDEX IDX_#TempAutoDraftUnreconciledIds ON #TempAutoDraftUnreconciledIds(AutoDraftId)		

	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO	#TempGstUnreconciledIds
	SELECT 
		d.Id,1 SupplyType 
	FROM 
		Oregular.SaleDocumentDW d	
		INNER JOIN oregular.SaleDocumentStatus  ds WITH(NOLOCK) ON ds.SaleDocumentId = d.Id		
	WHERE 
			d.SubscriberId = @SubscriberId
		AND d.FinancialYear = @FinancialYear
		AND d.ParentEntityId =  @ParentEntityId
		AND d.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW,@TransactionTypeOTH) 
		AND d.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)			
		AND d.Is3WayReconciled = @FALSE	
		AND (ds.PushStatus IN (SELECT e.item FROM #GstPushStatuses e))
		AND d.SourceType = @SourceTypeTaxpayer
		--AND ds.[Status] = @TRUE 
	UNION 				
	
	SELECT 
		SD.ID,ED.SupplyType
	FROM 
		oregular.SaleDocumentDW SD		
		INNER JOIN oregular.SaleDocumentStatus  ss WITH(NOLOCK) ON ss.SaleDocumentId = sd.Id
		INNER JOIN einvoice.DocumentDW ED ON SD.DocumentNumber = ED.DocumentNumber AND SD.DocumentFinancialYear = ED.DocumentFinancialYear and SD.DocumentType =ED.[Type] 	
		INNER JOIN einvoice.DocumentStatus ds ON ed.Id = ds.DocumentId
	WHERE	
		SD.SubscriberId = @SubscriberId		
		AND ED.SubscriberId = @SubscriberId
		AND ED.FinancialYear = @FinancialYear
		AND SD.ParentEntityId =  @ParentEntityId
		AND ED.ParentEntityId =  @ParentEntityId
		AND ED.Is3WayReconciled = @FALSE
		AND ed.SupplyType IN(@SupplyTypeSale)
		AND SD.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW,@TransactionTypeOTH) 
		AND Sd.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)		
		AND ed.Purpose IN( @PurposeTypeEINV,@PurposeTypeBoth)
		AND (ss.PushStatus IN (SELECT e.item FROM #GstPushStatuses e))
		AND (ds.PushStatus IN (SELECT e.item FROM #EInvoicePushStatuses e))
		--AND SS.[Status]	 = @TRUE
		--AND DS.[Status]	 = @TRUE
		AND SD.SourceType = @SourceTypeTaxpayer
		
	UNION 				
	
	SELECT 
		SD.ID,ED.SupplyType
	FROM 
		oregular.SaleDocumentDW SD	
		INNER JOIN oregular.SaleDocumentStatus  ss WITH(NOLOCK) ON ss.SaleDocumentId = sd.Id
		INNER JOIN einvoice.DocumentDW ED ON SD.DocumentNumber = ED.DocumentNumber AND SD.DocumentFinancialYear = ED.DocumentFinancialYear and SD.DocumentType =ED.[Type] 		
		INNER JOIN ewaybill.DocumentStatus DS ON ED.Id = DS.DocumentId
	WHERE 
		SD.SubscriberId = @SubscriberId
		AND ED.SubscriberId = @SubscriberId
		AND ED.FinancialYear = @FinancialYear
		AND SD.ParentEntityId =  @ParentEntityId
		AND ED.ParentEntityId =  @ParentEntityId
		AND ED.Is3WayReconciled = @FALSE
		AND ed.SupplyType IN(@SupplyTypeSale)
		AND SD.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW,@TransactionTypeOTH) 
		AND Sd.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)				
		AND ED.Purpose IN (@PurposeTypeEWB,@PurposeTypeBoth) 
		AND (ss.PushStatus IN (SELECT e.item FROM #GstPushStatuses e))
		AND (DS.PushStatus IN (SELECT e.item FROM #EwaybillPushStatuses e))
		--AND SS.[Status]	 = @TRUE
		--AND DS.[Status]	 = @TRUE
		AND SD.SourceType = @SourceTypeTaxpayer
	UNION 					
	SELECT 
		SD.ID,@SupplyTypeSale
	FROM 
		oregular.SaleDocumentDW SD	
		INNER JOIN oregular.SaleDocumentStatus  ss WITH(NOLOCK) ON ss.SaleDocumentId = sd.Id
		INNER JOIN oregular.SaleDocumentDW SAD ON SD.DocumentNumber = SAD.DocumentNumber AND SD.DocumentFinancialYear = SAD.DocumentFinancialYear and SD.DocumentType =SAD.DocumentType 				
		INNER JOIN oregular.SaleDocumentStatus ssa WITH(NOLOCK) ON ssa.SaleDocumentId = sad.Id
	WHERE 
		SD.SubscriberId = @SubscriberId		
		AND SAD.SubscriberId = @SubscriberId
		AND SAD.FinancialYear = @FinancialYear
		AND SD.ParentEntityId =  @ParentEntityId
		AND SAD.ParentEntityId =  @ParentEntityId
		AND SAD.Is3WayReconciled = @FALSE		
		AND SD.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW,@TransactionTypeOTH) 
		AND Sd.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)						
		AND (ss.PushStatus IN (SELECT e.item FROM #GstPushStatuses e))
		AND (ssa.PushStatus IN (SELECT e.item FROM #AutoDraftPushStatuses e))
		--AND SS.[Status]	 = @TRUE
		--AND ssa.[Status] = @TRUE
		AND SD.SourceType = @SourceTypeTaxpayer
		AND SAD.SourceType = @SourceTypeAutoDraft
		
	/*To Get Ids of Purchase For Reconciliation  */
	INSERT INTO	#TempGstUnreconciledIds
	SELECT 
		d.Id,2 SupplyType 
	FROM 
		Oregular.PurchaseDocumentDW d	
		INNER JOIN oregular.PurchaseDocumentStatus ss WITH(NOLOCK) ON ss.PurchaseDocumentId = d.Id
	WHERE 
		d.SubscriberId = @SubscriberId
		AND d.FinancialYear = @FinancialYear
		AND d.ParentEntityId =  @ParentEntityId
		AND d.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW,@TransactionTypeOTH) 
		AND d.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)		
		AND d.Is3WayReconciled = @FALSE		
		AND d.SourceType = @SourceTypeTaxpayer
		AND (ss.PushStatus IN (SELECT e.item FROM #GstPushStatuses e))
		--AND SS.[Status] = @TRUE
	
	UNION 				
				
	SELECT 
		SD.ID,ED.SupplyType
	FROM 
		oregular.PurchaseDocumentDW SD		
		INNER JOIN oregular.PurchaseDocumentStatus ss WITH(NOLOCK) ON ss.PurchaseDocumentId = sd.Id
		INNER JOIN einvoice.DocumentDW ED ON SD.DocumentNumber = ED.DocumentNumber AND SD.DocumentFinancialYear = ED.DocumentFinancialYear and SD.DocumentType =ED.[Type] AND ISNULL(SD.BillFromGstin,'URP') = ISNULL(ED.BillFromGstin,'URP')				
		INNER JOIN ewaybill.DocumentStatus DS ON ED.Id = DS.DocumentId
	WHERE 
		SD.SubscriberId = @SubscriberId		
		AND ED.SubscriberId = @SubscriberId
		AND ED.FinancialYear = @FinancialYear
		AND SD.ParentEntityId =  @ParentEntityId
		AND ED.ParentEntityId =  @ParentEntityId	
		AND SD.SourceType = @SourceTypeTaxpayer
		AND ED.Is3WayReconciled = @FALSE
		AND ed.SupplyType IN(@SupplyTypePurchase)
		AND SD.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW,@TransactionTypeOTH) 
		AND Sd.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)			
		AND ED.Purpose IN (@PurposeTypeEWB,@PurposeTypeBoth) 
		AND (SS.PushStatus IN (SELECT e.item FROM #GstPushStatuses e))
		AND (DS.PushStatus IN (SELECT e.item FROM #EwaybillPushStatuses e))	
		--AND SS.[Status]	 = @TRUE
		--AND DS.[Status]	 = @TRUE				

	IF EXISTS (SELECT TOP 1 1 FROM #TempGstUnreconciledIds)
	BEGIN
	/*To Get Ids of Einvoice For Reconciliation  */
	INSERT INTO #TempEinvoiceUnreconciledIds
	SELECT 
		ED.ID
	FROM 
		#TempGstUnreconciledIds tui
		INNER JOIN oregular.SaleDocumentDW sd on tui.GstId = sd.Id  and tui.SupplyType = @SupplyTypeSale
		INNER JOIN Einvoice.DocumentDW ED ON SD.DocumentNumber = ED.DocumentNumber AND SD.DocumentFinancialYear = ED.DocumentFinancialYear and SD.DocumentType =ED.[Type] 	
		INNER JOIN einvoice.DocumentStatus DS ON ED.ID = DS.DocumentId
	WHERE 
		ED.SubscriberId = @SubscriberId		
		AND ED.ParentEntityId =  @ParentEntityId
		AND ED.Purpose IN (@PurposeTypeBoth,@PurposeTypeEINV)				
		AND ED.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE) 
		AND ED.[Type] IN (@DocumentTypeINV,@DocumentTypeDBN,@DocumentTypeCRN)
		AND (ds.PushStatus IN (SELECT e.item FROM #EInvoicePushStatuses e))
		--AND ds.[Status] = @TRUE
	
	;WITH CTE
	AS
	( SELECT ROW_NUMBER()OVER(PARTITION BY EInvId ORDER BY EInvId )Row_Num FROM #TempEinvoiceUnreconciledIds)
	DELETE FROM CTE WHERE Row_Num > 1
	
	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO #TempEwaybillUnreconciledIds
	SELECT 
		EWB.ID
	FROM 
		#TempGstUnreconciledIds tui
		INNER JOIN oregular.SaleDocumentDW sd on tui.GstId = sd.Id  
		INNER JOIN einvoice.DocumentDW EWB 
			ON EWB.ParentEntityId =  @ParentEntityId
			AND EWB.SupplyType = @SupplyTypeSale
			AND EWB.DocumentFinancialYear = SD.DocumentFinancialYear
			AND SD.DocumentType =EWB.Type
			AND LOWER(SD.DocumentNumber) = LOWER(EWB.DocumentNumber)												   
		INNER JOIN ewaybill.DocumentStatus DS ON EWB.ID = DS.DocumentId
	WHERE 
		EWB.SubscriberId = @SubscriberId
		AND EWB.Purpose IN (@PurposeTypeEWB,@PurposeTypeBoth) 		
		AND EWB.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeKD,@TransactionTypeJW,@TransactionTypeJWR,@TransactionTypeOTH) 
		AND EWB.[Type] IN (@DocumentTypeINV,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)		
		AND (DS.PushStatus IN (SELECT e.item FROM #EwaybillPushStatuses e))	
		AND tui.SupplyType = @SupplyTypeSale		

	/*To Get Ids of Ewaybill For Reconciliation  */
	INSERT INTO #TempEwaybillUnreconciledIds
	SELECT 
		EWB.ID
	FROM 
		#TempGstUnreconciledIds tui
		INNER JOIN oregular.PurchaseDocumentDW sd on tui.GstId = sd.Id  
		INNER JOIN EInvoice.DocumentDW EWB 
			ON SD.DocumentNumber = EWB.DocumentNumber
			AND SD.DocumentFinancialYear = EWB.DocumentFinancialYear
			AND SD.DocumentType =EWB.Type
			AND COALESCE(SD.BillFromGstin,'URP') = COALESCE(EWB.BillFromGstin,'URP')				
		INNER JOIN ewaybill.DocumentStatus DS ON EWB.ID = DS.DocumentId
	WHERE 
		EWB.SubscriberId = @SubscriberId
		AND EWB.ParentEntityId =  @ParentEntityId
		AND EWB.Purpose IN (@PurposeTypeEWB,@PurposeTypeBoth) 		
		AND EWB.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeKD,@TransactionTypeJW,@TransactionTypeJWR,@TransactionTypeOTH) 
		AND EWB.[Type] IN (@DocumentTypeINV,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)		
		AND (DS.PushStatus IN (SELECT e.item FROM #EwaybillPushStatuses e))	
		AND tui.SupplyType = @SupplyTypePurchase
		AND EWB.SupplyType = @SupplyTypePurchase		


	;WITH CTE
	AS
	( SELECT ROW_NUMBER()OVER(PARTITION BY EWBID ORDER BY EWBID )Row_Num FROM #TempEwaybillUnreconciledIds)
	DELETE FROM CTE WHERE Row_Num > 1


	/*Delete Duplicate Ewaybill entries*/
	DELETE tdu 
	FROM  
		#TempEwaybillUnreconciledIds tdu
	WHERE EXISTS (SELECT ID FROM #TempEwaybillDuplicateEntries tede WHERE tede.ID = tdu.Ewbid)

	
	DELETE tdu 
	FROM  
		#TempEinvoiceUnreconciledIds tdu
	WHERE EXISTS (SELECT ID FROM #TempEinvoiceDuplicateEntries tede WHERE tede.ID = tdu.EInvId)


	/*To Get Ids of GstAutoDraft For Reconciliation  */
	INSERT INTO #TempAutoDraftUnreconciledIds
	SELECT 
		SAD.ID
	FROM 
		#TempGstUnreconciledIds tui
		INNER JOIN oregular.SaleDocumentDW sd on tui.GstId = sd.Id  
		INNER JOIN oregular.SaleDocumentDW SAD ON SD.DocumentNumber = SAD.DocumentNumber AND SD.DocumentFinancialYear = SAD.DocumentFinancialYear and SD.DocumentType =SAD.DocumentType 				
		INNER JOIN oregular.SaleDocumentStatus SS ON ss.SaleDocumentId = SAD.Id
	WHERE 
		SAD.SubscriberId = @SubscriberId
		AND SAD.ParentEntityId =  @ParentEntityId		
		AND SAD.TransactionType IN(@TransactionTypeB2B,@TransactionTypeB2C,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE,@TransactionTypeIMPG,@TransactionTypeCBW) 
		AND SAD.[DocumentType] IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN,@DocumentTypeBOE,@DocumentTypeCHL,@DocumentTypeBIL)			
		AND SAD.SourceType = @SourceTypeAutoDraft
		AND tui.SupplyType = @SupplyTypeSale
		AND (SS.PushStatus IN (SELECT e.item FROM #AutoDraftPushStatuses e))

	;WITH CTE
	AS
	( SELECT ROW_NUMBER()OVER(PARTITION BY AutoDraftId ORDER BY AutoDraftId )Row_Num FROM #TempAutoDraftUnreconciledIds)
	DELETE FROM CTE WHERE Row_Num > 1

	SELECT
		TED.SupplyType,
		SDI.Id AS DocumentItemId
	INTO #TempOregularDocumentItems
	FROM 
		oregular.SaleDocumentItems SDI
	INNER JOIN #TempGstUnreconciledIds TED ON SDI.SaleDocumentId = TED.GstId AND TED.SupplyType = @SupplyTypeSale;
	
	INSERT INTO #TempOregularDocumentItems
	SELECT
		TED.SupplyType,
		SDI.Id AS DocumentItemId
	FROM 
		oregular.PurchaseDocumentItems SDI
	INNER JOIN #TempGstUnreconciledIds TED ON SDI.PurchaseDocumentId = TED.GstId AND TED.SupplyType = @SupplyTypePurchase;

	/* Get data for Reconcilation in Temp Table */	
	SELECT 
		SDI.SaleDocumentId GstId,		
		SDI.Rate,
		ISNULL(SUM(SDI.TaxableValue),0) TaxableValue,
		ISNULL(SUM(SDI.IgstAmount),0) IgstAmount,
		ISNULL(SUM(SDI.CgstAmount),0) CgstAmount,
		ISNULL(SUM(SDI.SgstAmount),0) SgstAmount,
		COALESCE(SUM(SDI.CessAmount),0)+COALESCE(SUM(SDI.StateCessAmount),0)+COALESCE(SUM(SDI.CessNonAdvaloremAmount),0)+COALESCE(SUM(SDI.StateCessNonAdvaloremAmount),0) AS CessAmount,
		ISNULL(SUM(SDI.StateCessAmount),0) StateCessAmount,
		ISNULL(SUM(SDI.CessNonAdvaloremAmount),0) CessNonAdvaloremAmount,
		ISNULL(SUM(SDI.StateCessNonAdvaloremAmount),0) StateCessNonAdvaloremAmount,
		COUNT(DISTINCT RATE) ItemCount,
		@SupplyTypeSale SupplyType,
		MAX(CASE WHEN sdi.TaxType = @TaxTypeTaxable THEN 1 ELSE NULL END) AS "IsTaxTypeTaxable"
	INTO #TempRegularReturnDetailData			
	FROM 
		oregular.SaleDocumentItems SDI
	INNER JOIN #TempOregularDocumentItems TED ON SDI.Id = TED.DocumentItemId AND TED.SupplyType = @SupplyTypeSale
	GROUP BY SaleDocumentId,SDI.Rate
		
	UNION ALL

	SELECT 
		SDI.PurchaseDocumentId,		
		SDI.Rate,
		ISNULL(SUM(SDI.TaxableValue),0) TaxableValue,
		ISNULL(SUM(SDI.IgstAmount),0) IgstAmount,
		ISNULL(SUM(SDI.CgstAmount),0) CgstAmount,
		ISNULL(SUM(SDI.SgstAmount),0) SgstAmount,
		ISNULL(SUM(SDI.CessAmount),0)+ISNULL(SUM(SDI.StateCessAmount),0)+ISNULL(SUM(SDI.CessNonAdvaloremAmount),0)+ISNULL(SUM(SDI.StateCessNonAdvaloremAmount),0) AS CessAmount,
		ISNULL(SUM(SDI.StateCessAmount),0) StateCessAmount,
		ISNULL(SUM(SDI.CessNonAdvaloremAmount),0) CessNonAdvaloremAmount,
		ISNULL(SUM(SDI.StateCessNonAdvaloremAmount),0) StateCessNonAdvaloremAmount,
		COUNT(DISTINCT Rate) ItemCount,
		@SupplyTypePurchase SupplyType,	
		NULL AS IsTaxTypeTaxable
	FROM 
		oregular.PurchaseDocumentItems SDI
	INNER JOIN #TempOregularDocumentItems TED ON SDI.Id = TED.DocumentItemId AND TED.SupplyType = @SupplyTypePurchase
	GROUP BY PurchaseDocumentId,SDI.Rate;
	DROP TABLE #TempOregularDocumentItems;

	DROP TABLE IF EXISTS #TempRegularReturnDetailDataAgg;
	
	SELECT 
		dd.GstId,
		dd.SupplyType,
		SUM(dd.TaxableValue) TaxableValue,
		SUM(dd.IgstAmount) IgstAmount,
		SUM(dd.CgstAmount) CgstAmount,
		SUM(dd.SgstAmount) SgstAmount,
		SUM(dd.CessAmount) CessAmount,
		SUM(dd.StateCessAmount) StateCessAmount,
		SUM(dd.CessNonAdvaloremAmount) CessNonAdvaloremAmount,
		SUM(dd.StateCessNonAdvaloremAmount) StateCessNonAdvaloremAmount,
		SUM(ItemCount) ItemCount,
		CASE WHEN MAX(dd.IsTaxTypeTaxable) = 1 THEN 1 ELSE NULL END AS IsTaxTypeTaxable
	INTO #TempRegularReturnDetailDataAgg
	FROM #TempRegularReturnDetailData dd  
	GROUP BY dd.GstId,dd.SupplyType;	
	
	SELECT 
		SD.Id,
		SD.DocumentNumber,
		CONVERT(DATETIME,CAST(SD.DocumentDate AS varchar),112)DocumentDate,
		SD.DocumentValue,
		SD.[DocumentType],
		SD.[TransactionType],
		SD.Pos,
		SD.ReverseCharge,
        CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN sd.DocumentReturnPeriod ELSE SD.ReturnPeriod END ReturnPeriod,        
		SD.DocumentFinancialYear,
	    CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN SD.DocumentFinancialYear ELSE SD.FinancialYear END FinancialYear,
		SD.ParentEntityId,
		SD.BillToGstin [Gstin],
		@SupplyTypeSale SupplyType,
		dd.TaxableValue,
		dd.IgstAmount,
		dd.CgstAmount,
		dd.SgstAmount,
		dd.CessAmount,
		dd.StateCessAmount,
		dd.StateCessNonAdvaloremAmount,
		dd.CessNonAdvaloremAmount,
		ItemCount,
		sd.UnderIgstAct,
		CASE
			WHEN @LocationTaxpayerType = @TaxPayerTypeSEZUnit THEN @true
			WHEN SD.TransactionType IN(@TransactionTypeB2B,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE) AND dd.IsTaxTypeTaxable IS NULL THEN @true
			WHEN sd.DocumentType NOT IN (@DocumentTypEInv,@DocumentTypeCRN,@DocumentTypeDBN) THEN @true
			WHEN SD.TransactionType NOT IN(@TransactionTypeB2B,@TransactionTypeSEZWP,@TransactionTypeSEZWOP,@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeDE) THEN @true			
			ELSE NULL END
		AS IsEinvNotApplicable,
		CASE
			WHEN @LocationTaxpayerType = @TaxPayerTypeSEZDeveloper THEN @true
			WHEN dd.IsTaxTypeTaxable = @true THEN @true
			ELSE NULL END
		AS IsEinvApplicable
	INTO #TempRegularReturnData			
	FROM 
		oregular.SaleDocumentDW SD
	INNER JOIN #TempGstUnreconciledIds TED ON SD.Id = TED.GstId AND TED.SupplyType = @SupplyTypeSale
	INNER JOIN #TempRegularReturnDetailDataAgg dd ON SD.Id = dd.GstId AND dd.SupplyType = @SupplyTypeSale		

	UNION ALL

	SELECT 
		SD.Id,
		SD.DocumentNumber,
		CONVERT(DATETIME,CAST(SD.DocumentDate AS varchar),112)DocumentDate,
		SD.DocumentValue,
		SD.[DocumentType],
		SD.[TransactionType],
		SD.Pos,
		SD.ReverseCharge,
        CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN sd.DocumentReturnPeriod ELSE SD.ReturnPeriod END ReturnPeriod,        
		SD.DocumentFinancialYear,
	    CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN SD.DocumentFinancialYear ELSE SD.FinancialYear END FinancialYear,
		SD.ParentEntityId,
		ISNULL(BillFromGstin,'URP') [Gstin],
		@SupplyTypePurchase SupplyType,
		dd.TaxableValue,
		dd.IgstAmount,
		dd.CgstAmount,
		dd.SgstAmount,
		dd.CessAmount,
		dd.StateCessAmount,
		dd.StateCessNonAdvaloremAmount,
		dd.CessNonAdvaloremAmount,
		ItemCount,
		sd.UnderIgstAct,
		NULL AS IsEinvNotApplicable,
		NULL AS IsEinvApplicable		
	FROM 
		oregular.PurchaseDocumentDW SD
	INNER JOIN #TempGstUnreconciledIds TED ON SD.Id = TED.GstId AND TED.SupplyType = @SupplyTypePurchase
	INNER JOIN #TempRegularReturnDetailDataAgg dd ON SD.Id = dd.GstId AND dd.SupplyType = @SupplyTypeSale	
	
	DROP TABLE IF EXISTS #TempAutoDraftDocumentItems;

	SELECT
		SDI.Id AS DocumentItemId
	INTO #TempAutoDraftDocumentItems
	FROM 
		oregular.SaleDocumentItems SDI
	WHERE EXISTS(SELECT 1 FROM #TempAutoDraftUnreconciledIds TED WHERE SDI.SaleDocumentId = TED.AutoDraftId);
																									   
	
	/*Get data of Gst AUTO Drafted */
	SELECT 
		SDI.SaleDocumentId AutoDraftId,		
		SDI.Rate,
		ISNULL(SUM(SDI.TaxableValue),0) TaxableValue,
		ISNULL(SUM(SDI.IgstAmount),0) IgstAmount,
		ISNULL(SUM(SDI.CgstAmount),0) CgstAmount,
		ISNULL(SUM(SDI.SgstAmount),0) SgstAmount,
		ISNULL(SUM(SDI.CessAmount),0) CessAmount,
		ISNULL(SUM(SDI.StateCessAmount),0) StateCessAmount,
		ISNULL(SUM(SDI.CessNonAdvaloremAmount),0) CessNonAdvaloremAmount,
		ISNULL(SUM(SDI.StateCessNonAdvaloremAmount),0) StateCessNonAdvaloremAmount,
		COUNT(DISTINCT Rate) ItemCount,
		@SupplyTypeSale SupplyType
	INTO #TempAutoDraftDetailData
	FROM 
		oregular.SaleDocumentItems SDI
	INNER JOIN #TempAutoDraftDocumentItems TED ON SDI.Id = TED.DocumentItemId
	GROUP BY SaleDocumentId,SDI.Rate

	DROP TABLE IF EXISTS #TempAutoDraftDetailDataAgg;
	SELECT 
		dd.AutoDraftId,
		SUM(dd.TaxableValue) TaxableValue,
		SUM(dd.IgstAmount) IgstAmount,
		SUM(dd.CgstAmount) CgstAmount,
		SUM(dd.SgstAmount) SgstAmount,
		SUM(dd.CessAmount) CessAmount,
		SUM(dd.StateCessAmount) StateCessAmount,
		SUM(dd.CessNonAdvaloremAmount) CessNonAdvaloremAmount,
		SUM(dd.StateCessNonAdvaloremAmount) StateCessNonAdvaloremAmount,
		SUM(ItemCount) ItemCount
	INTO #TempAutoDraftDetailDataAgg
	FROM #TempAutoDraftDetailData dd 
	GROUP BY dd.AutoDraftId																		 
	
	SELECT 
		SD.Id,
		SD.DocumentNumber,
		CONVERT(DATETIME,CAST(SD.DocumentDate AS varchar),112)DocumentDate,
		SD.DocumentValue,
		SD.[DocumentType],
		SD.[TransactionType],
		SD.Pos,
		SD.ReverseCharge,
        CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN sd.DocumentReturnPeriod ELSE SD.ReturnPeriod END ReturnPeriod,        
		SD.DocumentFinancialYear,
	    CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN SD.DocumentFinancialYear ELSE SD.FinancialYear END FinancialYear,
		SD.ParentEntityId,
		SD.BillToGstin AS [Gstin],
		@SupplyTypeSale SupplyType,
		dd.TaxableValue,
		dd.IgstAmount,
		dd.CgstAmount,
		dd.SgstAmount,
		dd.CessAmount,
		dd.StateCessAmount,
		dd.StateCessNonAdvaloremAmount,
		dd.CessNonAdvaloremAmount,
		ItemCount,
		sd.UnderIgstAct
	INTO #TempAutoDraftData			
	FROM 
		oregular.SaleDocumentDW SD
	INNER JOIN #TempAutoDraftUnreconciledIds TED ON SD.Id = TED.AutoDraftId 
	INNER JOIN #TempAutoDraftDetailDataAgg dd ON SD.Id = dd.AutoDraftId ;		

	/*Get dAta of Einvoice for Reconciliation */
	DROP TABLE IF EXISTS #TempEwaybillDocumentItems;

	SELECT
		SDI.Id AS DocumentItemId
	INTO #TempEwaybillDocumentItems
	FROM 
		einvoice.DocumentItems SDI
	WHERE EXISTS(SELECT 1 FROM #TempEwaybillUnreconciledIds TED WHERE SDI.DocumentId = TED.EwbId);

	SELECT 
		EDI.DocumentId,		
		EDI.Rate,
		ISNULL(SUM(EDI.TaxableValue),0) TaxableValue,
		ISNULL(SUM(EDI.IgstAmount),0) IgstAmount,
		ISNULL(SUM(EDI.CgstAmount),0) CgstAmount,
		ISNULL(SUM(EDI.SgstAmount),0) SgstAmount,
		ISNULL(SUM(EDI.CessAmount),0)+ISNULL(SUM(EDI.StateCessAmount),0)+ISNULL(SUM(EDI.CessNonAdvaloremAmount),0)+ISNULL(SUM(EDI.StateCessNonAdvaloremAmount),0) AS CessAmount,		
		ISNULL(SUM(EDI.StateCessAmount),0) StateCessAmount,
		ISNULL(SUM(EDI.OtherCharges),0) OtherCharges,
		ISNULL(SUM(EDI.CessNonAdvaloremAmount),0) AS CessNonAdvaloremAmount,
		ISNULL(SUM(EDI.StateCessNonAdvaloremAmount),0) AS StateCessNonAdvaloremAmount,
		Count(DISTINCT Rate) AS ItemCount
	INTO #TempEwaybillDetailData
	FROM 
		einvoice.DocumentItems EDI
	INNER JOIN #TempEwaybillDocumentItems TED ON EDI.Id = TED.DocumentItemId
	GROUP BY DocumentId,Rate

	DROP TABLE IF EXISTS #TempEwaybillDetailDataAgg;																		   
	SELECT 
		dd.DocumentId,
		SUM(dd.TaxableValue) TaxableValue,
		SUM(dd.IgstAmount) IgstAmount,
		SUM(dd.CgstAmount) CgstAmount,
		SUM(dd.SgstAmount) SgstAmount,
		SUM(dd.CessAmount) CessAmount,
		SUM(dd.OtherCharges) OtherCharges,
		SUM(dd.StateCessAmount) StateCessAmount,
		SUM(dd.CessNonAdvaloremAmount) CessNonAdvaloremAmount,
		SUM(dd.StateCessNonAdvaloremAmount) StateCessNonAdvaloremAmount,
		SUM(ItemCount) ItemCount
	INTO #TempEwaybillDetailDataAgg
	FROM  #TempEwaybillDetailData dd 
	GROUP BY dd.DocumentId
	
	SELECT 
		ED.Id,
		ED.DocumentNumber,
		CONVERT(DATETIME,CAST(ED.DocumentDate AS varchar),112)DocumentDate,
		CASE WHEN @SettingTypeExcludeOtherCharges = @TRUE THEN ISNULL(ED.DocumentValue,0) - ISNULL(ds.DocumentOtherCharges,0) - ISNULL(dd.OtherCharges,0) ELSE ED.DocumentValue END AS DocumentValue,
		ED.[Type],
		ED.[TransactionType],
		ED.Pos,
		ED.ReverseCharge,
		CASE WHEN Ed.SupplyType = @SupplyTypeSale THEN '' ELSE ISNULL(Ed.BillFromGstin,'URP') END [Gstin],
        CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN ed.DocumentReturnPeriod ELSE ED.ReturnPeriod END ReturnPeriod,        
		ED.DocumentFinancialYear,
	    CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN Ed.DocumentFinancialYear ELSE ED.FinancialYear END FinancialYear,
		ED.ParentEntityId,
		ED.SupplyType,
		dd.TaxableValue,
		dd.IgstAmount,
		dd.CgstAmount,
		dd.SgstAmount,
		dd.CessAmount,
		dd.StateCessAmount,
		dd.StateCessNonAdvaloremAmount,
		dd.CessNonAdvaloremAmount,
		ItemCount,
		DS.UnderIgstAct
	INTO #TempEwayBillData			
	FROM 
		einvoice.DocumentDW ED
	INNER JOIN einvoice.Documents DS ON ED.Id = DS.Id
	INNER JOIN #TempEwaybillUnreconciledIds TED ON ED.Id = TED.EwbId
	INNER JOIN #TempEwaybillDetailDataAgg dd ON Ed.Id = dd.DocumentId;			
	
	/*Get dAta of Einvoice for Reconciliation */
	DROP TABLE IF EXISTS #TempEinvoiceDocumentItems;
	
	SELECT
		SDI.Id AS DocumentItemId
	INTO #TempEinvoiceDocumentItems
	FROM 
		einvoice.DocumentItems SDI
	WHERE EXISTS(SELECT 1 FROM #TempEInvoiceUnreconciledIds TED WHERE SDI.DocumentId = TED.EInvId);
	
	SELECT 
		EDI.DocumentId,		
		EDI.Rate,
		ISNULL(SUM(EDI.TaxableValue),0) TaxableValue,
		ISNULL(SUM(EDI.IgstAmount),0) IgstAmount,
		ISNULL(SUM(EDI.CgstAmount),0) CgstAmount,
		ISNULL(SUM(EDI.SgstAmount),0) SgstAmount,
		ISNULL(SUM(EDI.CessAmount),0)+ISNULL(SUM(EDI.StateCessAmount),0)+ISNULL(SUM(EDI.CessNonAdvaloremAmount),0)+ISNULL(SUM(EDI.StateCessNonAdvaloremAmount),0) AS CessAmount,
		ISNULL(SUM(EDI.StateCessAmount),0) StateCessAmount,
		ISNULL(SUM(EDI.OtherCharges),0) OtherCharges,
		ISNULL(SUM(EDI.CessNonAdvaloremAmount),0) CessNonAdvaloremAmount,
		ISNULL(SUM(EDI.StateCessNonAdvaloremAmount),0) StateCessNonAdvaloremAmount,
		COUNT(DISTINCT Rate) ItemCount
	INTO #TempEinvoiceDetailData			
	FROM 
		einvoice.DocumentItems EDI
	INNER JOIN #TempEinvoiceDocumentItems TED ON EDI.Id = TED.DocumentItemId
	GROUP BY DocumentId,Rate

	DROP TABLE IF EXISTS #TempEInvoiceDetailDataAgg;
	
	SELECT 
		dd.DocumentId,
		SUM(dd.TaxableValue) TaxableValue,
		SUM(dd.IgstAmount) IgstAmount,
		SUM(dd.CgstAmount) CgstAmount,
		SUM(dd.SgstAmount) SgstAmount,
		SUM(dd.CessAmount) CessAmount,
		SUM(dd.OtherCharges) OtherCharges,
		SUM(dd.StateCessAmount) StateCessAmount,
		SUM(dd.CessNonAdvaloremAmount) CessNonAdvaloremAmount,
		SUM(dd.StateCessNonAdvaloremAmount) StateCessNonAdvaloremAmount,
		SUM(ItemCount) ItemCount
	INTO #TempEInvoiceDetailDataAgg
	FROM  #TempEinvoiceDetailData dd 
	GROUP BY dd.DocumentId;	
	
	SELECT 
		ED.Id,
		ED.DocumentNumber,
		CONVERT(DATETIME,CAST(ED.DocumentDate AS varchar),112)DocumentDate,
		CASE WHEN @SettingTypeExcludeOtherCharges = @TRUE THEN ISNULL(ED.DocumentValue,0) - ISNULL(DS.DocumentOtherCharges,0) - ISNULL(dd.OtherCharges,0) ELSE ED.DocumentValue END AS DocumentValue,
		ED.[Type],
		ED.[TransactionType],
		ED.Pos,
		ED.ReverseCharge,
        CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN ed.DocumentReturnPeriod ELSE ED.ReturnPeriod END ReturnPeriod,        
		ED.DocumentFinancialYear,
	    CASE WHEN @IsDocumentDateReturnPeriod = 1 THEN Ed.DocumentFinancialYear ELSE ED.FinancialYear END FinancialYear,
		ED.ParentEntityId,
		ISNULL(ED.BillFromGstin,'URP') [Gstin],
		ED.SupplyType,
		dd.TaxableValue,
		dd.IgstAmount,
		dd.CgstAmount,
		dd.SgstAmount,
		dd.CessAmount,
		dd.StateCessAmount,
		dd.StateCessNonAdvaloremAmount,
		dd.CessNonAdvaloremAmount,
		ItemCount,
		DS.UnderIgstAct
	INTO #TempEinvoiceData			
	FROM 
		einvoice.DocumentDW ED
	INNER JOIN einvoice.Documents DS ON ED.Id = DS.Id
	INNER JOIN #TempEinvoiceUnreconciledIds TED ON ED.Id = TED.EInvId	
	INNER JOIN #TempEInvoiceDetailDataAgg dd ON Ed.Id = dd.DocumentId;			
						
	--*************************Monthly Comparison Begin**************************************
	/*Header Level Matching of Gst data with Ewaybill  */
	SELECT
		gst.Id GstId,
		ewb.Id Ewbid,		
		CASE WHEN  (@IsExcludeMatchingCriteriaTransactionType = @False OR ewb.TransactionType = gst.TransactionType OR (gst.TransactionType = @TransactionTypeCBW OR ewb.UnderIgstAct = @TRUE)) THEN NULL ELSE ewb.TransactionType END TransactionType,
		CASE WHEN  ((@IsExcludeMatchingCriteriaGstin = @False OR gst.Gstin = ewb.Gstin) AND ewb.SupplyType=@SupplyTypePurchase) THEN NULL ELSE ewb.Gstin END Gstin,																																																		
		CASE WHEN  EWB.DocumentDate = gst.DocumentDate THEN NULL ELSE ABS(DATEDIFF(DAY,EWB.DocumentDate,gst.DocumentDate)) END DocumentDate,		
		CASE WHEN  EWB.DocumentValue = gst.DocumentValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.DocumentValue BETWEEN ewb.DocumentValue+@MatchByToleranceDocumentValueFrom AND ewb.DocumentValue+@MatchByToleranceDocumentValueTo	THEN NULL		 
			 ELSE ABS(EWB.DocumentValue - gst.DocumentValue) END DocumentValue,
		CASE WHEN  EWb.ItemCount = gst.ItemCount THEN NULL ELSE ABS(EWB.ItemCount - gst.ItemCount) END ItemCount,		
		CASE WHEN  EWb.IgstAmount = gst.IgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.IgstAmount BETWEEN ewb.IgstAmount+@MatchByToleranceTaxAmountsFrom AND ewb.IgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(EWB.IgstAmount - gst.IgstAmount) END IgstAmount,																									 
		CASE WHEN  EWb.SgstAmount = gst.SgstAmount THEN NULL 																											 
			 WHEN @IsMatchByTolerance = @True AND gst.SgstAmount BETWEEN ewb.SgstAmount+@MatchByToleranceTaxAmountsFrom AND ewb.SgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(EWB.SgstAmount - gst.SgstAmount) END SgstAmount,																									 
		CASE WHEN  EWb.CgstAmount = gst.CgstAmount THEN NULL 																											 
			 WHEN @IsMatchByTolerance = @True AND gst.CgstAmount BETWEEN ewb.CgstAmount+@MatchByToleranceTaxAmountsFrom AND ewb.CgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(EWB.CgstAmount - gst.CgstAmount) END CgstAmount,		
		CASE WHEN  EWb.TaxableValue = gst.TaxableValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.TaxableValue BETWEEN ewb.TaxableValue+@MatchByToleranceTaxableValueFrom AND ewb.TaxableValue+@MatchByToleranceTaxableValueTo THEN NULL		 
			 ELSE ABS(EWB.TaxableValue - gst.TaxableValue) END TaxableValue,		
		CASE WHEN  EWb.CessAmount = gst.CessAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CessAmount BETWEEN ewb.CessAmount+@MatchByToleranceTaxAmountsFrom AND ewb.CessAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(EWB.CessAmount - gst.CessAmount) END CessAmount,		
		CASE WHEN  EWb.StateCessAmount = gst.StateCessAmount THEN NULL ELSE ABS(EWB.StateCessAmount - gst.StateCessAmount) END StateCessAmount,		
		gst.SupplyType,
		CASE WHEN EWB.DocumentValue < @DocValueThresholdForRecoAgainstEwb THEN 1 ELSE 0 END IsEwbNotApplicable
	INTO 
		#TempGstEwbHeaderDataMatching
	FROM 
		#TempRegularReturnData gst	
	INNER JOIN #TempEwayBillData ewb on EWB.DocumentNumber = gst.DocumentNumber AND EWB.[Type] = gst.DocumentType and EWB.DocumentFinancialYear = gst.DocumentFinancialYear AND (EWB.Gstin = gst.Gstin OR ewb.SupplyType = @SupplyTypeSale) AND ewb.SupplyType = gst.SupplyType
	WHERE
	    EWB.ParentEntityId = gst.ParentEntityID
		AND EWB.ReturnPeriod = gst.ReturnPeriod

	/*Getting Matched ids to compare data at detail level*/		
	SELECT 
		GstId,
		Ewbid,
		SupplyType	
	INTO #TempGstEwbMatchedIds
	FROM #TempGstEwbHeaderDataMatching
	WHERE (CASE WHEN TransactionType IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN Gstin IS NOT NULL THEN 1 ELSE 0 END +
			+ CASE WHEN DocumentDate IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ISNULL(DocumentValue,0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN ISNULL(ItemCount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(IgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(SgstAmount,0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN ISNULL(CgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(TaxableValue,0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN ISNULL(CessAmount,0) <>0  THEN 1 ELSE  0 END) = 0
	
	/*Comparing data at detail level*/	
	SELECT 
		Ids.GstId,
		Ewbid,
		SUM(CASE WHEN ISNULL(SD.ItemCount,0) <> ISNULL(ED.ItemCount,0) THEN 3
			  ELSE
			  CASE WHEN @IsMatchByTolerance = @TRUE THEN
					CASE WHEN ISNULL(ED.IgstAmount,0) - ISNULL(SD.IgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1 
					       WHEN ISNULL(ED.SgstAmount,0) - ISNULL(SD.SgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
						   WHEN ISNULL(ED.CgstAmount,0) - ISNULL(SD.CgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
						   WHEN ISNULL(ED.CessAmount,0) - ISNULL(SD.CessAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
						   WHEN ISNULL(ED.TaxableValue,0) - ISNULL(SD.TaxableValue,0) NOT BETWEEN @MatchByToleranceTaxableValueFrom AND @MatchByToleranceTaxableValueTo THEN 1
			  	    ELSE 0 END 
			  ELSE CASE WHEN ISNULL(ED.IgstAmount,0) <> ISNULL(SD.IgstAmount,0) THEN 1 
			         WHEN ISNULL(ED.CgstAmount,0) <> ISNULL(SD.CgstAmount,0) THEN 1
			  	   WHEN ISNULL(ED.SgstAmount,0) <> ISNULL(SD.SgstAmount,0) THEN 1
			  	   WHEN ISNULL(ED.CessAmount,0) <> ISNULL(SD.CessAmount,0) THEN 1
			  	   WHEN ISNULL(ED.TaxableValue,0) <> ISNULL(SD.TaxableValue,0) THEN 1
			  	   ELSE 0 END END
			 END) AS DetailComparison,
			Ids.SupplyType
	INTO #TempGstEwbdetailComparison
	FROM #TempGstEwbMatchedIds Ids
	INNER JOIN #TempRegularReturnDetailData ED ON Ids.EwbId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempEwaybillDetailData SD ON  IDS.Ewbid = SD.DocumentId AND ED.Rate = SD.Rate 
	GROUP BY EwbId,Ids.GstId,Ids.SupplyType
	
	/*Finding sectiontype,Reason Type */		
	SELECT 
		Ids.GstId,
		Ed.Ewbid,
		Ids.SupplyType ,
		CASE WHEN ED.GstId IS NOT NULL AND  ED.IsEwbNotApplicable = 0
				THEN CASE WHEN ED.TransactionType IS NULL 
				AND ED.DocumentValue IS NULL AND ED.DocumentDate IS NULL AND ISNULL(DetailComparison,0) = 0 AND ED.ItemCount IS NULL
				AND ED.IgstAmount IS NULL AND ED.SgstAmount IS NULL AND ED.CgstAmount IS NULL AND ED.CessAmount IS NULL AND ED.TaxableValue IS NULL
							THEN @ReconciliationSectionTypeEwbMatched	
							ELSE @ReconciliationSectionTypeEwbMismatched
					 END	
		    ELSE CASE WHEN trd.[DocumentType] IN (@DocumentTypeCRN,@DocumentTypeDBN) OR IsEwbNotApplicable = 1 THEN @ReconciliationSectionTypeEwbNotApplicable  ELSE @ReconciliationSectionTypeEwbNotAvailable END
		END EwbSection,		
		CASE WHEN ED.TransactionType IS NOT NULL Then @ReconciliationReasonTypeTransactionType else 0 END +				
		CASE WHEN ED.Documentdate IS NOT NULL Then @ReconciliationReasonTypeDocumentDate else 0 END +
		CASE WHEN ED.DocumentValue IS NOT NULL Then @ReconciliationReasonTypeDocumentValue else 0 END  + 
		CASE WHEN ED.ItemCount IS NOT NULL Then @ReconciliationReasonTypeItems else 0 END  + 
		CASE WHEN ED.IgstAmount IS NOT NULL Then @ReconciliationReasonTypeIgstAmount else 0 END  + 
		CASE WHEN ED.CgstAmount IS NOT NULL Then @ReconciliationReasonTypeCgstAmount else 0 END  + 
		CASE WHEN ED.SgstAmount IS NOT NULL Then @ReconciliationReasonTypeSgstAmount else 0 END  + 
		CASE WHEN ED.TaxableValue IS NOT NULL Then @ReconciliationReasonTypeTaxableValue else 0 END  +
		CASE WHEN COALESCE(DetailComparison,0) >= 3 Then @ReconciliationReasonTypeRate else 0 END +
		CASE WHEN ED.CessAmount IS NOT NULL Then @ReconciliationReasonTypeCessAmount else 0 END  AS EwbReasonsType,
		(SELECT CASE WHEN ED.TransactionType IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTransactionType  , ',"Value":""},') ELSE '' END + 								
				CASE WHEN ED.Documentdate IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentDate , ',"Value":"', ED.DocumentDate ,'"},') ELSE '' END +
				CASE WHEN ED.DocumentValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentValue , ',"Value":"', ED.DocumentValue ,'"},') ELSE '' END +
				CASE WHEN ED.ItemCount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeItems , ',"Value":"', ED.ItemCount ,'"},') ELSE '' END +
				CASE WHEN ED.IgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeIgstAmount , ',"Value":"',ED.IgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.CgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCgstAmount , ',"Value":"',ED.CgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.SgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeSgstAmount , ',"Value":"',ED.SgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.TaxableValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTaxableValue , ',"Value":"',ED.TaxableValue,'"},') ELSE '' END +
				CASE WHEN COALESCE(DetailComparison,0) >= 3 Then CONCAT('{"Reason":', @ReconciliationReasonTypeRate  , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.CessAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCessAmount , ',"Value":"',ED.CessAmount,'"},') ELSE '' END
				) EwbReason ,	
		@MappingTypeMonthly MappingType
	INTO #TempGstEwbReco					
	FROM 
		#TempGstUnreconciledIds Ids
	INNER JOIN #TempRegularReturnData trd On Ids.GstId = trd.Id and Ids.SupplyType = trd.SupplyType
	LEFT JOIN #TempGstEwbHeaderDataMatching ED ON Ids.GstId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempGstEwbdetailComparison EDI ON IDS.GstId = EDI.GstId	AND Ids.SupplyType = EDI.SupplyType	AND ED.Ewbid = EDI.Ewbid		

	/*Header Level Matching of Gst data with GstAutoDraft  */
	SELECT
		sad.Id AutoDraftId,		
		gst.id GstId,		
		CASE WHEN  (@IsExcludeMatchingCriteriaTransactionType = @False OR gst.TransactionType = sad.TransactionType OR (gst.TransactionType = @TransactionTypeCBW OR sad.UnderIgstAct = @TRUE)) THEN NULL ELSE gst.TransactionType END TransactionType,
		CASE WHEN  (@IsExcludeMatchingCriteriaGstin = @False OR gst."Gstin" = sad."Gstin") THEN NULL ELSE gst."Gstin" END "Gstin",																													 
		CASE WHEN  (gst.Pos = 96 and gst.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (sad.Pos = 96 and sad.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (gst.Pos = sad.POS) THEN NULL ELSE gst.pos END Pos,
		CASE WHEN  gst.DocumentDate = sad.DocumentDate THEN NULL ELSE ABS(DATEDIFF(DAY,gst.DocumentDate,sad.DocumentDate)) END DocumentDate,
		CASE WHEN  gst.reversecharge = sad.reversecharge THEN NULL ELSE IIF(gst.ReverseCharge = 1,'Y','N') END reversecharge,
		CASE WHEN  gst.DocumentValue = sad.DocumentValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.DocumentValue BETWEEN sad.DocumentValue+@MatchByToleranceDocumentValueFrom AND sad.DocumentValue+@MatchByToleranceDocumentValueTo THEN NULL		 
			 ELSE ABS(gst.DocumentValue - sad.DocumentValue) END DocumentValue,
		CASE WHEN  gst.ItemCount = sad.ItemCount THEN NULL ELSE ABS(gst.ItemCount - sad.ItemCount) END ItemCount,		
		CASE WHEN  gst.IgstAmount = sad.IgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.IgstAmount BETWEEN sad.IgstAmount+@MatchByToleranceTaxAmountsFrom AND sad.IgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.IgstAmount - sad.IgstAmount) END IgstAmount,		
		CASE WHEN  gst.SgstAmount = sad.SgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.SgstAmount BETWEEN sad.SgstAmount+@MatchByToleranceTaxAmountsFrom AND sad.SgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.SgstAmount - sad.SgstAmount) END SgstAmount,		
		CASE WHEN  gst.CgstAmount = sad.CgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CgstAmount BETWEEN sad.CgstAmount+@MatchByToleranceTaxAmountsFrom AND sad.CgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.CgstAmount - sad.CgstAmount) END CgstAmount,		
		CASE WHEN  gst.CessAmount = sad.CessAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CessAmount BETWEEN sad.CessAmount+@MatchByToleranceTaxAmountsFrom AND sad.CessAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.CessAmount - sad.CessAmount) END CessAmount,		
		CASE WHEN  gst.TaxableValue = sad.TaxableValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.TaxableValue BETWEEN sad.TaxableValue+@MatchByToleranceTaxableValueFrom AND sad.TaxableValue+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.TaxableValue - sad.TaxableValue) END TaxableValue,		
		CASE WHEN  gst.StateCessAmount = sad.StateCessAmount THEN NULL ELSE ABS(gst.StateCessAmount - sad.StateCessAmount) END StateCessAmount,		
		gst.SupplyType
	INTO 
		#TempGstAutoDraftHeaderMatching
	FROM 
		#TempRegularReturnData gst
	INNER JOIN #TempAutoDraftData sad  ON gst.DocumentNumber = sad.DocumentNumber AND gst.[DocumentType] = sad.[DocumentType] AND gst.DocumentFinancialYear = sad.DocumentFinancialYear 
	WHERE gst.SupplyType = @SupplyTypeSale
		AND gst.ParentEntityId = sad.ParentEntityID
		AND gst.ReturnPeriod = sad.ReturnPeriod
		
	
	/*Getting Matched ids to compare data at detail level*/	
	SELECT 
		GstId,
		AutoDraftId,
		SupplyType
	INTO #TempGstAutoDraftMatchedId
	FROM #TempGstAutoDraftHeaderMatching
	WHERE (CASE WHEN TransactionType IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN Gstin IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN Pos IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN reversecharge IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DocumentDate IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ISNULL(DocumentValue,0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN ISNULL(ItemCount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(IgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(SgstAmount,0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN ISNULL(CgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(TaxableValue,0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN ISNULL(CessAmount,0) <>0  THEN 1 ELSE  0 END) = 0				
	
	/*Comparing data at detail level*/	
	SELECT 
		Ids.GstId,
		Ids.AutoDraftId,		
		SUM(CASE WHEN ISNULL(ED.ItemCount,0) <> ISNULL(sad.ItemCount,0) THEN 3
			 ELSE
				CASE WHEN @IsMatchByTolerance = @TRUE THEN
						CASE WHEN ISNULL(ED.IgstAmount,0) - ISNULL(sad.IgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1 
						       WHEN ISNULL(ED.SgstAmount,0) - ISNULL(sad.SgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CgstAmount,0) - ISNULL(sad.CgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CessAmount,0) - ISNULL(sad.CessAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.TaxableValue,0) - ISNULL(sad.TaxableValue,0) NOT BETWEEN @MatchByToleranceTaxableValueFrom AND @MatchByToleranceTaxableValueTo THEN 1
				 	    ELSE 0 END 
				 ELSE CASE WHEN ISNULL(ED.IgstAmount,0) <> ISNULL(sad.IgstAmount,0) THEN 1 
				       WHEN ISNULL(ED.CgstAmount,0) <> ISNULL(sad.CgstAmount,0) THEN 1
					   WHEN ISNULL(ED.SgstAmount,0) <> ISNULL(sad.SgstAmount,0) THEN 1
					   WHEN ISNULL(ED.CessAmount,0) <> ISNULL(sad.CessAmount,0) THEN 1
					   WHEN ISNULL(ED.TaxableValue,0) <> ISNULL(sad.TaxableValue,0) THEN 1
					   ELSE 0 END END
	   END) AS DetailComparison,
	   ids.SupplyType
	INTO #TempGstAutoDraftDetailComp	
	FROM #TempGstAutoDraftMatchedId Ids
	INNER JOIN #TempRegularReturnDetailData ED ON Ids.GstId= ED.GstId AND ids.SupplyType = Ed.SupplyType
	LEFT JOIN #TempAutoDraftDetailData sad ON IDS.AutoDraftId = sad.AutoDraftId AND ED.Rate = sad.Rate 
	GROUP BY Ids.AutoDraftId,Ids.GstId,ids.SupplyType 

	/*Finding sectiontype,Reason Type */			
	SELECT 
		Ids.GstId,
		ED.AutoDraftId,	
		Ids.SupplyType,	
		CASE WHEN ED.GstId IS NOT NULL
				THEN CASE WHEN TransactionType IS NULL AND Gstin IS NULL AND Pos IS NULL AND DocumentValue IS NULL AND reversecharge IS NULL AND DocumentDate IS NULL AND ISNULL(DetailComparison,0) = 0 AND ItemCount IS NULL
				AND IgstAmount IS NULL AND SgstAmount IS NULL AND CgstAmount IS NULL AND CessAmount IS NULL AND TaxableValue IS NULL
							THEN @ReconciliationSectionTypeGstAutodraftedMatched
							ELSE @ReconciliationSectionTypeGstAutodraftedMismatched
					 END	
			 ELSE @ReconciliationSectionTypeGstAutodraftedNotAvailable END AutoDraftSection,		
		CASE WHEN ED.TransactionType IS NOT NULL Then @ReconciliationReasonTypeTransactionType else 0 END +
		CASE WHEN ED.Gstin IS NOT NULL Then @ReconciliationReasonTypeGstin else 0 END +																			  
		CASE WHEN ED.POS IS NOT NULL Then @ReconciliationReasonTypePOS else 0 END +
		CASE WHEN ED.ReverseCharge IS NOT NULL Then @ReconciliationReasonTypeReverseCharge else 0 END +
		CASE WHEN ED.Documentdate IS NOT NULL Then @ReconciliationReasonTypeDocumentDate else 0 END +
		CASE WHEN ED.DocumentValue IS NOT NULL Then @ReconciliationReasonTypeDocumentValue else 0 END  + 
		CASE WHEN ED.ItemCount IS NOT NULL Then @ReconciliationReasonTypeItems else 0 END  + 
		CASE WHEN ED.IgstAmount IS NOT NULL Then @ReconciliationReasonTypeIgstAmount else 0 END  + 
		CASE WHEN ED.CgstAmount IS NOT NULL Then @ReconciliationReasonTypeCgstAmount else 0 END  + 
		CASE WHEN ED.SgstAmount IS NOT NULL Then @ReconciliationReasonTypeSgstAmount else 0 END  + 
		CASE WHEN ED.TaxableValue IS NOT NULL Then @ReconciliationReasonTypeTaxableValue else 0 END  + 
		CASE WHEN COALESCE(DetailComparison,0) >= 3 Then @ReconciliationReasonTypeRate else 0 END +
		CASE WHEN ED.CessAmount IS NOT NULL Then @ReconciliationReasonTypeCessAmount else 0 END  AS AutoDraftReasonsType,
		(SELECT CASE WHEN ED.TransactionType IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTransactionType  , ',"Value":""},') ELSE '' END + 
				CASE WHEN ED.Gstin IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeGstin , ',"Value":""},') ELSE '' END +																												  
				CASE WHEN ED.POS IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypePOS , ',"Value":"', Pos ,'"},') ELSE '' END +
				CASE WHEN ED.ReverseCharge IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeReverseCharge , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.Documentdate IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentDate , ',"Value":"', DocumentDate ,'"},') ELSE '' END +
				CASE WHEN ED.DocumentValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentValue , ',"Value":"', DocumentValue ,'"},') ELSE '' END +
				CASE WHEN ED.ItemCount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeItems , ',"Value":"', ItemCount ,'"},') ELSE '' END +
				CASE WHEN ED.IgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeIgstAmount , ',"Value":"',IgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.CgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCgstAmount , ',"Value":"',CgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.SgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeSgstAmount , ',"Value":"',SgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.TaxableValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTaxableValue , ',"Value":"',TaxableValue,'"},') ELSE '' END +
				CASE WHEN COALESCE(DetailComparison,0) >= 3 Then CONCAT('{"Reason":', @ReconciliationReasonTypeRate  , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.CessAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCessAmount , ',"Value":"',CessAmount,'"},') ELSE '' END
				) AutoDraftReason ,				
		@MappingTypeMonthly MappingType		
	INTO #TempGstAutoDraftReco				
	FROM #TempGstUnreconciledIds Ids
	LEFT JOIN #TempGstAutoDraftHeaderMatching ED ON Ids.GstId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempGstAutoDraftDetailComp EDI ON Ed.GstId = EDI.GstId AND Ids.SupplyType = EDI.SupplyType AND ED.AutoDraftId = EDI.AutoDraftId		

	/*Header Level Matching of Gst data with Einvoice  */
	SELECT
		Einv.Id EinvId,		
		gst.id GstId,		
		CASE WHEN  (@IsExcludeMatchingCriteriaTransactionType = @TRUE OR gst.TransactionType = EInv.TransactionType OR (gst.TransactionType = @TransactionTypeCBW OR EInv.UnderIgstAct = @TRUE)) THEN NULL ELSE gst.TransactionType END TransactionType,
		CASE WHEN  (gst.Pos = 96 and gst.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (einv.Pos = 96 and einv.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (gst.Pos = Einv.POS) THEN NULL ELSE gst.pos END Pos,
		CASE WHEN  gst.DocumentDate = Einv.DocumentDate THEN NULL ELSE ABS(DATEDIFF(DAY,gst.DocumentDate,Einv.DocumentDate)) END DocumentDate,
		CASE WHEN  gst.reversecharge = Einv.reversecharge THEN NULL ELSE IIF(gst.ReverseCharge = 1,'Y','N') END reversecharge,
		CASE WHEN  gst.DocumentValue = Einv.DocumentValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.DocumentValue BETWEEN Einv.DocumentValue+@MatchByToleranceDocumentValueFrom AND Einv.DocumentValue+@MatchByToleranceDocumentValueTo THEN NULL		 
			 ELSE ABS(gst.DocumentValue - Einv.DocumentValue) END DocumentValue,
		CASE WHEN  gst.ItemCount = Einv.ItemCount THEN NULL ELSE ABS(gst.ItemCount - einv.ItemCount) END ItemCount,		
		CASE WHEN  gst.IgstAmount = Einv.IgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.IgstAmount BETWEEN Einv.IgstAmount+@MatchByToleranceTaxAmountsFrom AND Einv.IgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.IgstAmount - einv.IgstAmount) END IgstAmount,		
		CASE WHEN  gst.SgstAmount = Einv.SgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.SgstAmount BETWEEN Einv.SgstAmount+@MatchByToleranceTaxAmountsFrom AND Einv.SgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.SgstAmount - einv.SgstAmount) END SgstAmount,		
		CASE WHEN  gst.CgstAmount = Einv.CgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CgstAmount BETWEEN Einv.CgstAmount+@MatchByToleranceTaxAmountsFrom AND Einv.CgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.CgstAmount - einv.CgstAmount) END CgstAmount,		
		CASE WHEN  gst.CessAmount = Einv.CessAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CessAmount BETWEEN Einv.CessAmount+@MatchByToleranceTaxAmountsFrom AND Einv.CessAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.CessAmount - einv.CessAmount) END CessAmount,		
		CASE WHEN  gst.TaxableValue = Einv.TaxableValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.TaxableValue BETWEEN Einv.TaxableValue+@MatchByToleranceTaxableValueFrom AND Einv.TaxableValue+@MatchByToleranceTaxableValueTo THEN NULL		 
			 ELSE ABS(gst.TaxableValue - einv.TaxableValue) END TaxableValue,		
		CASE WHEN  gst.StateCessAmount = Einv.StateCessAmount THEN NULL ELSE ABS(gst.StateCessAmount - einv.StateCessAmount) END StateCessAmount,		
		gst.SupplyType,
		gst.IsEinvNotApplicable,
		gst.IsEinvApplicable
	INTO 
		#TempGstEInvHeaderMatching
	FROM 
		#TempRegularReturnData gst
	INNER JOIN #TempEinvoiceData Einv on gst.DocumentNumber = Einv.DocumentNumber AND gst.[DocumentType] = Einv.[Type] and gst.DocumentFinancialYear = Einv.DocumentFinancialYear AND gst.SupplyType = @SupplyTypeSale
	WHERE gst.ParentEntityId = Einv.ParentEntityID
		AND gst.ReturnPeriod = Einv.ReturnPeriod
	
	/*Getting Matched ids to compare data at detail level*/	
	SELECT 
		GstId,
		EinvId,
		SupplyType
	INTO #TempGstEinvMatchedId
	FROM #TempGstEInvHeaderMatching
	WHERE (CASE WHEN TransactionType IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN Pos IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN reversecharge IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DocumentDate IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ISNULL(DocumentValue,0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN ISNULL(ItemCount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(IgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(SgstAmount,0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN ISNULL(CgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(TaxableValue,0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN ISNULL(CessAmount,0) <>0  THEN 1 ELSE  0 END) = 0				
	
	/*Comparing data at detail level*/		
	SELECT 
		Ids.GstId,
		EInvId,		
		SUM(CASE WHEN ISNULL(ED.ItemCount,0) <> ISNULL(Einv.ItemCount,0) THEN 3
			ELSE
				CASE WHEN @IsMatchByTolerance = @TRUE THEN
						CASE WHEN ISNULL(ED.IgstAmount,0) - ISNULL(Einv.IgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1 
						       WHEN ISNULL(ED.SgstAmount,0) - ISNULL(Einv.SgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CgstAmount,0) - ISNULL(Einv.CgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CessAmount,0) - ISNULL(Einv.CessAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.TaxableValue,0) - ISNULL(Einv.TaxableValue,0) NOT BETWEEN @MatchByToleranceTaxableValueFrom AND @MatchByToleranceTaxableValueTo THEN 1
				 	    ELSE 0 END 	
				 ELSE CASE WHEN ISNULL(ED.IgstAmount,0) <> ISNULL(Einv.IgstAmount,0) THEN 1 
					       WHEN ISNULL(ED.CgstAmount,0) <> ISNULL(Einv.CgstAmount,0) THEN 1
						   WHEN ISNULL(ED.SgstAmount,0) <> ISNULL(Einv.SgstAmount,0) THEN 1
						   WHEN ISNULL(ED.CessAmount,0) <> ISNULL(Einv.CessAmount,0) THEN 1
						   WHEN ISNULL(ED.TaxableValue,0) <> ISNULL(Einv.TaxableValue,0) THEN 1
						   ELSE 0 END END
	   END) AS DetailComparison,
	   ids.SupplyType
	INTO #TempGstEinvdetailComp	
	FROM #TempGstEinvMatchedId Ids
	INNER JOIN #TempRegularReturnDetailData ED ON Ids.GstId= ED.GstId AND ids.SupplyType = Ed.SupplyType
	LEFT JOIN #TempEinvoiceDetailData Einv ON IDS.EinvId = Einv.DocumentId AND ED.Rate = Einv.Rate 
	GROUP BY EInvId,Ids.GstId,ids.SupplyType 

	/*Finding sectiontype,Reason Type */			
	SELECT 
		Ids.GstId,
		ED.EinvId,	
		Ids.SupplyType,	
		CASE WHEN ED.GstId IS NOT NULL
				THEN CASE WHEN ed.TransactionType IS NULL AND ed.Pos IS NULL AND ed.DocumentValue IS NULL AND ed.reversecharge IS NULL AND ed.DocumentDate IS NULL AND ISNULL(edi.DetailComparison,0) = 0 AND ed.ItemCount IS NULL
				AND ed.IgstAmount IS NULL AND ed.SgstAmount IS NULL AND ed.CgstAmount IS NULL AND ed.CessAmount IS NULL  AND ed.TaxableValue IS NULL
							THEN @ReconciliationSectionTypeEinvMatched
							ELSE @ReconciliationSectionTypeEinvMismatched
					 END	
			 ELSE @ReconciliationSectionTypeEinvNotAvailable END EINVSection,		
		CASE WHEN ED.TransactionType IS NOT NULL Then @ReconciliationReasonTypeTransactionType else 0 END +
		CASE WHEN ED.POS IS NOT NULL Then @ReconciliationReasonTypePOS else 0 END +
		CASE WHEN ED.ReverseCharge IS NOT NULL Then @ReconciliationReasonTypeReverseCharge else 0 END +
		CASE WHEN ED.Documentdate IS NOT NULL Then @ReconciliationReasonTypeDocumentDate else 0 END +
		CASE WHEN ED.DocumentValue IS NOT NULL Then @ReconciliationReasonTypeDocumentValue else 0 END  + 
		CASE WHEN ED.ItemCount IS NOT NULL Then @ReconciliationReasonTypeItems else 0 END  + 
		CASE WHEN ED.IgstAmount IS NOT NULL Then @ReconciliationReasonTypeIgstAmount else 0 END  + 
		CASE WHEN ED.CgstAmount IS NOT NULL Then @ReconciliationReasonTypeCgstAmount else 0 END  + 
		CASE WHEN ED.SgstAmount IS NOT NULL Then @ReconciliationReasonTypeSgstAmount else 0 END  + 
		CASE WHEN ED.TaxableValue IS NOT NULL Then @ReconciliationReasonTypeTaxableValue else 0 END  + 
		CASE WHEN COALESCE(edi.DetailComparison,0) >= 3 Then @ReconciliationReasonTypeRate else 0 END +
		CASE WHEN ED.CessAmount IS NOT NULL Then @ReconciliationReasonTypeCessAmount else 0 END +	
		CASE WHEN trr.IsEinvNotApplicable = @TRUE AND ED.GstId IS NULL Then @ReconciliationReasonTypeEinvNotApplicable ELSE 0 END +
		CASE WHEN trr.IsEinvApplicable = @TRUE AND trr.IsEinvNotApplicable IS NULL AND ED.GstId IS NULL Then @ReconciliationReasonTypeEinvApplicable ELSE 0 END  AS EinvReasonsType,
		(SELECT CASE WHEN ED.TransactionType IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTransactionType  , ',"Value":""},') ELSE '' END + 
				CASE WHEN ED.POS IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypePOS , ',"Value":"', ed.Pos ,'"},') ELSE '' END +
				CASE WHEN ED.ReverseCharge IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeReverseCharge , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.Documentdate IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentDate , ',"Value":"', ed.DocumentDate ,'"},') ELSE '' END +
				CASE WHEN ED.DocumentValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentValue , ',"Value":"', ed.DocumentValue ,'"},') ELSE '' END +
				CASE WHEN ED.ItemCount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeItems , ',"Value":"', ed.ItemCount ,'"},') ELSE '' END +
				CASE WHEN ED.IgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeIgstAmount , ',"Value":"',ed.IgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.CgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCgstAmount , ',"Value":"',ed.CgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.SgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeSgstAmount , ',"Value":"',ed.SgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.TaxableValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTaxableValue , ',"Value":"',ed.TaxableValue,'"},') ELSE '' END +
				CASE WHEN COALESCE(edi.DetailComparison,0) >= 3 Then CONCAT('{"Reason":', @ReconciliationReasonTypeRate  , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.CessAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCessAmount , ',"Value":"',ed.CessAmount,'"},') ELSE '' END +
				CASE WHEN trr.IsEinvNotApplicable = @TRUE AND ED.GstId IS NULL THEN CONCAT('{"Reason":', @ReconciliationReasonTypeEinvNotApplicable , ',"Value":""},') ELSE '' END +
		 		CASE WHEN trr.IsEinvApplicable = @TRUE AND trr.IsEinvNotApplicable IS NULL AND ED.GstId IS NULL THEN CONCAT('{"Reason":', @ReconciliationReasonTypeEinvApplicable , ',"Value":""},') ELSE '' END
				) EinvReason ,				
		@MappingTypeMonthly MappingType		
	INTO #TempGstEinvReco				
	FROM #TempGstUnreconciledIds Ids
	LEFT JOIN #TempRegularReturnData trr On Ids.GstId = trr.Id and trr.SupplyType = @SupplyTypeSale
	LEFT JOIN #TempGstEInvHeaderMatching ED ON Ids.GstId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempGstEinvdetailComp EDI ON Ed.GstId = EDI.GstId AND ED.SupplyType = EDI.SupplyType  AND ED.EinvId = EDI.EinvId		


	/*Deleting data from RecoMapperTable*/			 	
	DELETE 
		rm 
	FROM
		 report.GstRecoMapper rm 
	INNER JOIN #TempGstUnreconciledIds Ids ON Ids.GstId = rm.GstId AND Ids.SupplyType = rm.GstType	

	/*Inserting data of MonthlyComparison into Mapping Table*/
	INSERT INTO report.GstRecoMapper
	(
		 GstId
		,EInvId
		,EWBId
		,AutoDraftId
		,GstType
		,EInvSection
		,EWBSection
		,AutoDraftSection
		,EInvReasonsType
		,EwbReasonsType
		,AutoDraftReasonsType
		,EInvReason
		,EwbReason
		,AutoDraftReason
		,MappingType
		,Stamp
		,ModifiedStamp
	)
	SELECT 
		GstId			=ES.GstId
		,EInvId			=EE.EinvId
		,EWBId			=CASE WHEN Es.EwbSection = @ReconciliationSectionTypeEwbNotApplicable THEN NULL ELSE ES.Ewbid END
		,AutoDraftId	=AD.AutoDraftId
		,GstType		=ES.SupplyType
		,EInvSection	=EE.EINVSection
		,EWBSection		=ES.EwbSection
		,AutoDraftSection=AD.AutoDraftSection
		,EInvReasonsType=CASE WHEN EE.EInvReasonsType = 0 THEN NULL ELSE EE.EinvReasonsType END
		,EwbReasonsType	=CASE WHEN ES.EwbReasonsType = 0 OR ES.EwbSection = @ReconciliationSectionTypeEwbNotApplicable THEN NULL ELSE ES.EwbReasonsType END
		,AutoDraftReasonsType=CASE WHEN AD.AutoDraftReasonsType = 0 THEN NULL ELSE Ad.AutoDraftReasonsType END
		,EInvReason		=CASE WHEN EE.EinvReason = '' THEN NULL ELSE CONCAT('[',LEFT(EE.EinvReason,LEN(EE.EinvReason)-1) ,']') END
		,EwbReason		=CASE WHEN ES.EWbReason = '' OR Es.EwbSection = @ReconciliationSectionTypeEwbNotApplicable THEN NULL ELSE CONCAT('[',LEFT(ES.EWbReason,LEN(ES.EWbReason)-1) ,']') END
		,AutoDraftReason=CASE WHEN AD.AutoDraftReason = '' THEN NULL ELSE CONCAT('[',LEFT(AD.AutoDraftReason,LEN(AD.AutoDraftReason)-1) ,']') END
		,MappingType	=@MappingTypeMonthly
		,Stamp			=GETDATE()
		,ModifiedStamp	=NULL		
	FROM
		#TempGstEwbReco ES
	LEFT JOIN #TempGstEinvReco EE ON ES.gstID = EE.gstid ANd ES.SupplyType = EE.SupplyType
	LEFT JOIN #TempGstAutoDraftReco AD ON ES.gstID = AD.gstid ANd ES.SupplyType = AD.SupplyType
	
	DROP TABLE IF EXISTS #TempGstEinvdetailComp,#TempGstEInvHeaderMatching,#TempGstEinvMatchedId,#TempGstEinvReco,#TempGstEwbdetailComparison,#TempGstEwbHeaderDataMatching
						,#TempGstEwbMatchedIds,#TempGstEwbReco,#TempYearlyGstEinvdetailComp,#TempGstEinvdetailComp,#TempGstAutoDraftDetailComp,#TempGstAutoDraftHeaderMatching,#TempGstAutoDraftMatchedId,#TempGstAutoDraftReco

	--*************************Monthly Comparison ENDS**************************************
	
	--*************************YEARLY Comparison Starts***************************************

	/*Header data comparsion of Regulardata With Ewaybill data */
	SELECT
		gst.Id GstId,
		ewb.Id Ewbid,		
		CASE WHEN  (@IsExcludeMatchingCriteriaTransactionType = @TRUE OR GST.TransactionType = EWB.TransactionType OR (GST.TransactionType = @TransactionTypeCBW OR EWB.UnderIgstAct = @TRUE)) THEN NULL ELSE gst.TransactionType END TransactionType,
		CASE WHEN  EWB.DocumentDate = gst.DocumentDate THEN NULL ELSE ABS(DATEDIFF(DAY,EWB.DocumentDate,gst.DocumentDate)) END DocumentDate,		
		CASE WHEN  EWB.DocumentValue = gst.DocumentValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.DocumentValue BETWEEN ewb.DocumentValue+@MatchByToleranceDocumentValueFrom AND ewb.DocumentValue+@MatchByToleranceDocumentValueTo	THEN NULL		 			 
			 ELSE ABS(EWB.DocumentValue - gst.DocumentValue) END DocumentValue,
		CASE WHEN  EWb.ItemCount = gst.ItemCount THEN NULL ELSE ABS(EWB.ItemCount - gst.ItemCount) END ItemCount,		
		CASE WHEN  EWb.IgstAmount = gst.IgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.IgstAmount BETWEEN ewb.IgstAmount+@MatchByToleranceTaxAmountsFrom AND ewb.IgstAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(EWB.IgstAmount - gst.IgstAmount) END IgstAmount,		
		CASE WHEN  EWb.SgstAmount = gst.SgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.SgstAmount BETWEEN ewb.SgstAmount+@MatchByToleranceTaxAmountsFrom AND ewb.SgstAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(EWB.SgstAmount - gst.SgstAmount) END SgstAmount,		
		CASE WHEN  EWb.CgstAmount = gst.CgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CgstAmount BETWEEN ewb.CgstAmount+@MatchByToleranceTaxAmountsFrom AND ewb.CgstAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(EWB.CgstAmount - gst.CgstAmount) END CgstAmount,		
		CASE WHEN  EWb.CessAmount = gst.CessAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CessAmount BETWEEN ewb.CessAmount+@MatchByToleranceTaxAmountsFrom AND ewb.CessAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(EWB.CessAmount - gst.CessAmount) END CessAmount,		
		CASE WHEN  EWb.TaxableValue = gst.TaxableValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.TaxableValue BETWEEN ewb.TaxableValue+@MatchByToleranceTaxableValueFrom AND ewb.TaxableValue+@MatchByToleranceTaxableValueTo	THEN NULL		 
			 ELSE ABS(EWB.TaxableValue - gst.TaxableValue) END TaxableValue,		
		CASE WHEN  EWb.StateCessAmount = gst.StateCessAmount THEN NULL ELSE ABS(EWB.StateCessAmount - gst.StateCessAmount) END StateCessAmount,
		gst.SupplyType,
		CASE WHEN EWB.DocumentValue < @DocValueThresholdForRecoAgainstEwb THEN 1 ELSE 0 END IsEwbNotApplicable
	INTO 
		#TempYearlyGstEwbHeaderDataMatching
	FROM 
		#TempRegularReturnData gst	
	INNER JOIN #TempEwayBillData ewb ON EWB.DocumentNumber = gst.DocumentNumber AND EWB.[Type] = gst.DocumentType and EWB.DocumentFinancialYear = gst.DocumentFinancialYear AND (EWB.Gstin = gst.Gstin OR ewb.SupplyType = @SupplyTypeSale) AND ewb.SupplyType = gst.SupplyType
	WHERE
	    EWB.ParentEntityId = gst.ParentEntityID		
		AND EWB.FinancialYear = gst.FinancialYear	
	
	/*Getting Matched ids to compare data at detail level*/
	SELECT 
		GstId,
		Ewbid,
		SupplyType
	INTO #TempYearlyGstEwbMatchedIds
	FROM #TempYearlyGstEwbHeaderDataMatching
	WHERE (CASE WHEN TransactionType IS NOT NULL THEN 1 ELSE 0 END  
			+ CASE WHEN DocumentDate IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ISNULL(DocumentValue,0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN ISNULL(ItemCount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(IgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(SgstAmount,0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN ISNULL(CgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(TaxableValue,0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN ISNULL(CessAmount,0) <>0  THEN 1 ELSE  0 END) = 0	

	/*comparing data at detail level*/		
	SELECT 
		Ids.GstId,
		Ewbid,
		SUM(CASE WHEN ISNULL(SD.ItemCount,0) <> ISNULL(ED.ItemCount,0) THEN 3
			ELSE	
				CASE WHEN @IsMatchByTolerance = @TRUE THEN
					CASE WHEN ISNULL(ED.IgstAmount,0) - ISNULL(SD.IgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1 
				       WHEN ISNULL(ED.SgstAmount,0) - ISNULL(SD.SgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
					   WHEN ISNULL(ED.CgstAmount,0) - ISNULL(SD.CgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
					   WHEN ISNULL(ED.CessAmount,0) - ISNULL(SD.CessAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
					   WHEN ISNULL(ED.TaxableValue,0) - ISNULL(SD.TaxableValue,0) NOT BETWEEN @MatchByToleranceTaxableValueFrom AND @MatchByToleranceTaxableValueTo THEN 1
	  				 ELSE 0 END 
				 ELSE CASE WHEN ISNULL(ED.IgstAmount,0) <> ISNULL(SD.IgstAmount,0) THEN 1 
					       WHEN ISNULL(ED.CgstAmount,0) <> ISNULL(SD.CgstAmount,0) THEN 1
						   WHEN ISNULL(ED.SgstAmount,0) <> ISNULL(SD.SgstAmount,0) THEN 1
						   WHEN ISNULL(ED.CessAmount,0) <> ISNULL(SD.CessAmount,0) THEN 1
						   WHEN ISNULL(ED.TaxableValue,0) <> ISNULL(SD.TaxableValue,0) THEN 1
						   ELSE 0 END END
			 END) AS DetailComparison,
			Ids.SupplyType
	INTO #TempYearlyGstEwbdetailComparison
	FROM #TempYearlyGstEwbMatchedIds Ids
	INNER JOIN #TempRegularReturnDetailData ED ON Ids.EwbId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempEwaybillDetailData SD ON  IDS.Ewbid = SD.DocumentId AND ED.Rate = SD.Rate 
	GROUP BY EwbId,Ids.GstId,Ids.SupplyType

	/*Finding final Section and reason of reconciled data*/		
	SELECT 
		Ids.GstId,
		Ed.Ewbid,
		Ids.SupplyType ,
		CASE WHEN ED.GstId IS NOT NULL AND Ed.IsEwbNotApplicable = 0
				THEN CASE WHEN ED.TransactionType IS NULL 
				AND ED.DocumentValue IS NULL AND ED.DocumentDate IS NULL AND ISNULL(DetailComparison,0) = 0 AND ED.ItemCount IS NULL
				AND ED.IgstAmount IS NULL AND ED.SgstAmount IS NULL AND ED.CgstAmount IS NULL AND ED.CessAmount IS NULL AND ED.TaxableValue IS NULL
							THEN @ReconciliationSectionTypeEwbMatched	
							ELSE @ReconciliationSectionTypeEwbMismatched
					 END	
            ELSE CASE WHEN trd.[DocumentType] IN (@DocumentTypeCRN,@DocumentTypeDBN) OR IsEwbNotApplicable = 1 THEN @ReconciliationSectionTypeEwbNotApplicable  ELSE @ReconciliationSectionTypeEwbNotAvailable END
		END EwbSection,		
		CASE WHEN ED.TransactionType IS NOT NULL Then @ReconciliationReasonTypeTransactionType else 0 END +				
		CASE WHEN ED.Documentdate IS NOT NULL Then @ReconciliationReasonTypeDocumentDate else 0 END +
		CASE WHEN ED.DocumentValue IS NOT NULL Then @ReconciliationReasonTypeDocumentValue else 0 END  + 
		CASE WHEN ED.ItemCount IS NOT NULL Then @ReconciliationReasonTypeItems else 0 END  + 
		CASE WHEN ED.IgstAmount IS NOT NULL Then @ReconciliationReasonTypeIgstAmount else 0 END  + 
		CASE WHEN ED.CgstAmount IS NOT NULL Then @ReconciliationReasonTypeCgstAmount else 0 END  + 
		CASE WHEN ED.SgstAmount IS NOT NULL Then @ReconciliationReasonTypeSgstAmount else 0 END  + 
		CASE WHEN ED.TaxableValue IS NOT NULL Then @ReconciliationReasonTypeTaxableValue else 0 END  + 
		CASE WHEN COALESCE(DetailComparison,0) >= 3 Then @ReconciliationReasonTypeRate else 0 END +
		CASE WHEN ED.CessAmount IS NOT NULL Then @ReconciliationReasonTypeCessAmount else 0 END  AS ewbReasonsType,
		(SELECT CASE WHEN ED.TransactionType IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTransactionType  , ',"Value":""},') ELSE '' END + 								
				CASE WHEN ED.Documentdate IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentDate , ',"Value":"', ED.DocumentDate ,'"},') ELSE '' END +
				CASE WHEN ED.DocumentValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentValue , ',"Value":"', ED.DocumentValue ,'"},') ELSE '' END +
				CASE WHEN ED.ItemCount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeItems , ',"Value":"', ED.ItemCount ,'"},') ELSE '' END +
				CASE WHEN ED.IgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeIgstAmount , ',"Value":"',ED.IgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.CgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCgstAmount , ',"Value":"',ED.CgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.SgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeSgstAmount , ',"Value":"',ED.SgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.TaxableValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTaxableValue , ',"Value":"',ED.TaxableValue,'"},') ELSE '' END +
				CASE WHEN COALESCE(DetailComparison,0) >= 3 Then CONCAT('{"Reason":', @ReconciliationReasonTypeRate  , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.CessAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCessAmount , ',"Value":"',ED.CessAmount,'"},') ELSE '' END
				) ewbReason ,						
		@MappingTypeYearly MappingType
	INTO #TempYearlyGstEwbReco					
	FROM 
		#TempGstUnreconciledIds Ids
	INNER JOIN #TempRegularReturnData trd ON Ids.GstId = trd.Id AND Ids.SupplyType = trd.SupplyType
	LEFT JOIN #TempYearlyGstEwbHeaderDataMatching ED ON Ids.GstId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempYearlyGstEwbdetailComparison EDI ON IDS.GstId = EDI.GstId AND Ids.SupplyType = EDI.SupplyType AND ED.Ewbid = EDI.Ewbid						

	/*Header data comparison of Gst data with einvoice data*/
	SELECT
		Einv.Id EinvId,		
		gst.id GstId,		
		CASE WHEN  (@IsExcludeMatchingCriteriaTransactionType = @TRUE OR einv.TransactionType = gst.TransactionType OR (gst.TransactionType = @TransactionTypeCBW OR einv.UnderIgstAct = @TRUE)) THEN NULL ELSE gst.TransactionType END TransactionType,
		CASE WHEN  (gst.Pos = 96 and gst.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (Einv.Pos = 96 and Einv.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (gst.Pos = Einv.POS) THEN NULL ELSE gst.Pos END Pos,
		CASE WHEN  gst.DocumentDate = Einv.DocumentDate THEN NULL ELSE ABS(DATEDIFF(DAY,gst.DocumentDate,Einv.DocumentDate)) END DocumentDate,
		CASE WHEN  gst.reversecharge = Einv.reversecharge THEN NULL ELSE  IIF(gst.ReverseCharge = 1,'Y','N') END reversecharge,
		CASE WHEN  gst.DocumentValue = Einv.DocumentValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.DocumentValue BETWEEN einv.DocumentValue+@MatchByToleranceDocumentValueFrom AND einv.DocumentValue+@MatchByToleranceDocumentValueTo THEN NULL		 
			 ELSE ABS(gst.DocumentValue - Einv.DocumentValue) END DocumentValue,
		CASE WHEN  gst.ItemCount = Einv.ItemCount THEN NULL ELSE ABS(gst.ItemCount - einv.ItemCount) END ItemCount,		
		CASE WHEN  gst.IgstAmount = Einv.IgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.IgstAmount BETWEEN Einv.IgstAmount+@MatchByToleranceTaxAmountsFrom AND Einv.IgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.IgstAmount - einv.IgstAmount) END IgstAmount,		
		CASE WHEN  gst.SgstAmount = Einv.SgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.SgstAmount BETWEEN Einv.SgstAmount+@MatchByToleranceTaxAmountsFrom AND Einv.SgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.SgstAmount - einv.SgstAmount) END SgstAmount,		
		CASE WHEN  gst.CgstAmount = Einv.CgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CgstAmount BETWEEN Einv.CgstAmount+@MatchByToleranceTaxAmountsFrom AND Einv.CgstAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.CgstAmount - einv.CgstAmount) END CgstAmount,		
		CASE WHEN  gst.CessAmount = Einv.CessAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CessAmount BETWEEN Einv.CessAmount+@MatchByToleranceTaxAmountsFrom AND Einv.CessAmount+@MatchByToleranceTaxAmountsTo THEN NULL		 
			 ELSE ABS(gst.CessAmount - einv.CessAmount) END CessAmount,		
		CASE WHEN  gst.TaxableValue = Einv.TaxableValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.TaxableValue BETWEEN Einv.TaxableValue+@MatchByToleranceTaxableValueFrom AND Einv.TaxableValue+@MatchByToleranceTaxableValueTo THEN NULL		 
			 ELSE ABS(gst.TaxableValue - einv.TaxableValue) END TaxableValue,		
		CASE WHEN  gst.StateCessAmount = Einv.StateCessAmount THEN NULL ELSE ABS(gst.StateCessAmount - einv.StateCessAmount) END StateCessAmount,		
		gst.SupplyType,
		gst."IsEinvNotApplicable",
		gst."IsEinvApplicable"
	INTO 
		#TempYearlyGstEInvHeaderMatching
	FROM 
		#TempRegularReturnData gst
	INNER JOIN #TempEinvoiceData Einv on gst.DocumentNumber = Einv.DocumentNumber AND gst.[DocumentType] = Einv.[Type] and gst.DocumentFinancialYear = Einv.DocumentFinancialYear AND gst.SupplyType = @SupplyTypeSale
	WHERE gst.ParentEntityId = Einv.ParentEntityID		
		  AND Einv.FinancialYear = gst.FinancialYear

	/*Getting matched ids to compare data at detail level*/
	SELECT 
		GstId,
		EinvId,
		SupplyType
	INTO #TempYearlyGstEinvMatchedId
	FROM #TempYearlyGstEInvHeaderMatching
	WHERE (CASE WHEN TransactionType IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN Pos IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN reversecharge IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DocumentDate IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ISNULL(DocumentValue,0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN ISNULL(ItemCount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(IgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(SgstAmount,0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN ISNULL(CgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(TaxableValue,0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN ISNULL(CessAmount,0) <>0  THEN 1 ELSE  0 END) = 0	
	
	/*comparing data at detail level*/
	SELECT 
		Ids.GstId,
		EInvId,		
		SUM(CASE WHEN ISNULL(ED.ItemCount,0) <> ISNULL(Einv.ItemCount,0) THEN 3
			ELSE
				CASE WHEN @IsMatchByTolerance = @TRUE THEN
						CASE WHEN ISNULL(ED.IgstAmount,0) - ISNULL(Einv.IgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1 
						       WHEN ISNULL(ED.SgstAmount,0) - ISNULL(Einv.SgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CgstAmount,0) - ISNULL(Einv.CgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CessAmount,0) - ISNULL(Einv.CessAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.TaxableValue,0) - ISNULL(Einv.TaxableValue,0) NOT BETWEEN @MatchByToleranceTaxableValueFrom AND @MatchByToleranceTaxableValueTo THEN 1
				 	    ELSE 0 END 		
			 ELSE CASE WHEN ISNULL(ED.IgstAmount,0) <> ISNULL(Einv.IgstAmount,0) THEN 1 
				       WHEN ISNULL(ED.CgstAmount,0) <> ISNULL(Einv.CgstAmount,0) THEN 1
					   WHEN ISNULL(ED.SgstAmount,0) <> ISNULL(Einv.SgstAmount,0) THEN 1
					   WHEN ISNULL(ED.CessAmount,0) <> ISNULL(Einv.CessAmount,0) THEN 1
					   WHEN ISNULL(ED.TaxableValue,0) <> ISNULL(Einv.TaxableValue,0) THEN 1
					   ELSE 0 END END
	   END) AS DetailComparison,
	   ids.SupplyType
	INTO #TempYearlyGstEinvdetailComp	
	FROM #TempYearlyGstEinvMatchedId Ids
	INNER JOIN #TempRegularReturnDetailData ED ON Ids.GstId= ED.GstId AND ids.SupplyType = Ed.SupplyType
	LEFT JOIN #TempEinvoiceDetailData Einv ON IDS.EinvId = Einv.DocumentId AND ED.Rate = Einv.Rate 
	GROUP BY EInvId,Ids.GstId,ids.SupplyType 
	
	/*Finding final Section and reason of reconciled data*/		
	SELECT 
		Ids.GstId,
		ED.EinvId,	
		Ids.SupplyType,	
		CASE WHEN ED.GstId IS NOT NULL
			 THEN CASE WHEN ed.TransactionType IS NULL  AND ed.Pos IS NULL AND ed.DocumentValue IS NULL AND ed.reversecharge IS NULL AND ed.DocumentDate IS NULL AND ISNULL(edi.DetailComparison,0) = 0 AND ed.ItemCount IS NULL
							AND ed.IgstAmount IS NULL AND ed.SgstAmount IS NULL AND ed.CgstAmount IS NULL AND ed.CessAmount IS NULL AND ed.TaxableValue IS NULL
					   THEN @ReconciliationSectionTypeEinvMatched
					   ELSE @ReconciliationSectionTypeEinvMismatched
				   END	
			 ELSE @ReconciliationSectionTypeEinvNotAvailable 
		END EINVSection,		
		CASE WHEN ED.TransactionType IS NOT NULL Then @ReconciliationReasonTypeTransactionType else 0 END +
		CASE WHEN ED.POS IS NOT NULL Then @ReconciliationReasonTypePOS else 0 END +
		CASE WHEN ED.ReverseCharge IS NOT NULL Then @ReconciliationReasonTypeReverseCharge else 0 END +
		CASE WHEN ED.Documentdate IS NOT NULL Then @ReconciliationReasonTypeDocumentDate else 0 END +
		CASE WHEN ED.DocumentValue IS NOT NULL Then @ReconciliationReasonTypeDocumentValue else 0 END  + 
		CASE WHEN ED.ItemCount IS NOT NULL Then @ReconciliationReasonTypeItems else 0 END  + 
		CASE WHEN ED.IgstAmount IS NOT NULL Then @ReconciliationReasonTypeIgstAmount else 0 END  + 
		CASE WHEN ED.CgstAmount IS NOT NULL Then @ReconciliationReasonTypeCgstAmount else 0 END  + 
		CASE WHEN ED.SgstAmount IS NOT NULL Then @ReconciliationReasonTypeSgstAmount else 0 END  + 
		CASE WHEN ED.TaxableValue IS NOT NULL Then @ReconciliationReasonTypeTaxableValue else 0 END  + 
		CASE WHEN COALESCE(edi.DetailComparison,0) >= 3 Then @ReconciliationReasonTypeRate else 0 END + 
		CASE WHEN ED.CessAmount IS NOT NULL Then @ReconciliationReasonTypeCessAmount else 0 END +
		CASE WHEN ED.IsEinvNotApplicable = @TRUE AND ED.GstId IS NULL Then @ReconciliationReasonTypeEinvNotApplicable ELSE 0 END +
		CASE WHEN ED.IsEinvApplicable = @TRUE AND trr.IsEinvNotApplicable IS NULL AND ED.GstId IS NULL Then @ReconciliationReasonTypeEinvApplicable ELSE 0 END 
		AS EinvReasonsType,
		(SELECT CASE WHEN ED.TransactionType IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTransactionType  , ',"Value":""},') ELSE '' END + 
				CASE WHEN ED.POS IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypePOS , ',"Value":"', ed.Pos ,'"},') ELSE '' END +
				CASE WHEN ED.ReverseCharge IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeReverseCharge , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.Documentdate IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentDate , ',"Value":"', ed.DocumentDate ,'"},') ELSE '' END +
				CASE WHEN ED.DocumentValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentValue , ',"Value":"', ed.DocumentValue ,'"},') ELSE '' END +
				CASE WHEN ED.ItemCount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeItems , ',"Value":"', ed.ItemCount ,'"},') ELSE '' END +
				CASE WHEN ED.IgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeIgstAmount , ',"Value":"',ed.IgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.CgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCgstAmount , ',"Value":"',ed.CgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.SgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeSgstAmount , ',"Value":"',ed.SgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.TaxableValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTaxableValue , ',"Value":"',ed.TaxableValue,'"},') ELSE '' END +
				CASE WHEN COALESCE(edi.DetailComparison,0) >= 3 Then CONCAT('{"Reason":', @ReconciliationReasonTypeRate  , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.CessAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCessAmount , ',"Value":"',ed.CessAmount,'"},') ELSE '' END +
				CASE WHEN trr.IsEinvNotApplicable = @TRUE AND ED.GstId IS NULL THEN CONCAT('{"Reason":', @ReconciliationReasonTypeEinvNotApplicable, ',"Value":""},') ELSE '' END  +
		 		CASE WHEN trr.IsEinvApplicable = @TRUE AND trr.IsEinvNotApplicable IS NULL AND ED.GstId IS NULL THEN CONCAT('{"Reason":', @ReconciliationReasonTypeEinvApplicable , ',"Value":""},') ELSE '' END
				) EinvReason ,						
		@MappingTypeYearly MappingType		
	INTO #TempYearlyGstEinvReco				
	FROM #TempGstUnreconciledIds Ids
	LEFT JOIN #TempRegularReturnData trr On Ids.GstId = trr.Id and trr.SupplyType = @SupplyTypeSale
	LEFT JOIN #TempYearlyGstEInvHeaderMatching ED ON Ids.GstId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempYearlyGstEinvdetailComp EDI ON Ed.GstId = EDI.GstId AND ED.SupplyType = EDI.SupplyType AND ED.EinvId = EDI.EinvId			
	
	/*Header data comparison of Gst data with AutoDraft data*/
	SELECT
		sad.Id AutodraftId,		
		gst.id GstId,		
		CASE WHEN  (@IsExcludeMatchingCriteriaTransactionType = @False OR gst.TransactionType = sad.TransactionType OR (gst.TransactionType = @TransactionTypeCBW OR sad.UnderIgstAct = @TRUE)) THEN NULL ELSE gst.TransactionType END TransactionType,
		CASE WHEN  (@IsExcludeMatchingCriteriaGstin = @False OR gst.Gstin = sad.Gstin) THEN NULL ELSE gst.Gstin END Gstin,																													 
		CASE WHEN  (gst.Pos = 96 and gst.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (sad.Pos = 96 and sad.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP)) OR (gst.Pos = sad.POS) THEN NULL ELSE gst.Pos END Pos,
		CASE WHEN  gst.DocumentDate = sad.DocumentDate THEN NULL ELSE ABS(DATEDIFF(DAY,gst.DocumentDate,sad.DocumentDate)) END DocumentDate,
		CASE WHEN  gst.reversecharge = sad.reversecharge THEN NULL ELSE  IIF(gst.ReverseCharge = 1,'Y','N') END reversecharge,
		CASE WHEN  gst.DocumentValue = sad.DocumentValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.DocumentValue BETWEEN sad.DocumentValue+@MatchByToleranceDocumentValueFrom AND sad.DocumentValue+@MatchByToleranceDocumentValueTo	THEN NULL		 
			 ELSE ABS(gst.DocumentValue - sad.DocumentValue) END DocumentValue,
		CASE WHEN  gst.ItemCount = sad.ItemCount THEN NULL ELSE ABS(gst.ItemCount - sad.ItemCount) END ItemCount,		
		CASE WHEN  gst.IgstAmount = sad.IgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.IgstAmount BETWEEN sad.IgstAmount+@MatchByToleranceTaxAmountsFrom AND sad.IgstAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(gst.IgstAmount - sad.IgstAmount) END IgstAmount,		
		CASE WHEN  gst.SgstAmount = sad.SgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.SgstAmount BETWEEN sad.SgstAmount+@MatchByToleranceTaxAmountsFrom AND sad.SgstAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(gst.SgstAmount - sad.SgstAmount) END SgstAmount,		
		CASE WHEN  gst.CgstAmount = sad.CgstAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CgstAmount BETWEEN sad.CgstAmount+@MatchByToleranceTaxAmountsFrom AND sad.CgstAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(gst.CgstAmount - sad.CgstAmount) END CgstAmount,		
		CASE WHEN  gst.CessAmount = sad.CessAmount THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.CessAmount BETWEEN sad.CessAmount+@MatchByToleranceTaxAmountsFrom AND sad.CessAmount+@MatchByToleranceTaxAmountsTo	THEN NULL		 
			 ELSE ABS(gst.CessAmount - sad.CessAmount) END CessAmount,		
		CASE WHEN  gst.TaxableValue = sad.TaxableValue THEN NULL 
			 WHEN @IsMatchByTolerance = @True AND gst.TaxableValue BETWEEN sad.TaxableValue+@MatchByToleranceTaxableValueFrom AND sad.TaxableValue+@MatchByToleranceTaxableValueTo	THEN NULL		 
			 ELSE ABS(gst.TaxableValue - sad.TaxableValue) END TaxableValue,
		CASE WHEN  gst.StateCessAmount = sad.StateCessAmount THEN NULL ELSE ABS(gst.StateCessAmount - sad.StateCessAmount) END StateCessAmount,		
		gst.SupplyType
	INTO 
		#TempYearlyGstAutoDraftHeaderMatching
	FROM 
		#TempRegularReturnData gst
	INNER JOIN #TempAutoDraftData sad on gst.DocumentNumber = sad.DocumentNumber AND gst.[DocumentType] = sad.[DocumentType] and gst.DocumentFinancialYear = sad.DocumentFinancialYear 
	WHERE gst.ParentEntityId = sad.ParentEntityID		
		AND gst.SupplyType = @SupplyTypeSale
		AND sad.FinancialYear = gst.FinancialYear

	/*Getting matched ids to compare data at detail level*/
	SELECT 
		GstId,
		AutoDraftId,
		SupplyType
	INTO #TempYearlyGstAutoDraftMatchedId
	FROM #TempYearlyGstAutoDraftHeaderMatching
	WHERE (CASE WHEN TransactionType IS NOT NULL THEN 1 ELSE 0 END  + CASE WHEN Gstin IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN Pos IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN reversecharge IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DocumentDate IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ISNULL(DocumentValue,0) <>0  THEN 1 ELSE  0 END 
			+ CASE WHEN ISNULL(ItemCount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(IgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(SgstAmount,0) <>0  THEN 1 ELSE  0 END  
			+ CASE WHEN ISNULL(CgstAmount,0) <>0  THEN 1 ELSE  0 END + CASE WHEN ISNULL(TaxableValue,0) <>0  THEN 1 ELSE  0 END
			+ CASE WHEN ISNULL(CessAmount,0) <>0  THEN 1 ELSE  0 END) = 0	
	
	/*comparing data at detail level*/
	SELECT 
		Ids.GstId,
		Ids.AutodraftId,		
		SUM(CASE WHEN ISNULL(ED.ItemCount,0) <> ISNULL(sad.ItemCount,0) THEN 3
			ELSE
				CASE WHEN @IsMatchByTolerance = @TRUE THEN
						CASE WHEN ISNULL(ED.IgstAmount,0) - ISNULL(sad.IgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1 
						       WHEN ISNULL(ED.SgstAmount,0) - ISNULL(sad.SgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CgstAmount,0) - ISNULL(sad.CgstAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.CessAmount,0) - ISNULL(sad.CessAmount,0) NOT BETWEEN @MatchByToleranceTaxAmountsFrom AND @MatchByToleranceTaxAmountsTo THEN 1
							   WHEN ISNULL(ED.TaxableValue,0) - ISNULL(sad.TaxableValue,0) NOT BETWEEN @MatchByToleranceTaxableValueFrom AND @MatchByToleranceTaxableValueTo THEN 1
				 	    ELSE 0 END 		
			 ELSE CASE WHEN ISNULL(ED.IgstAmount,0) <> ISNULL(sad.IgstAmount,0) THEN 1 
				       WHEN ISNULL(ED.CgstAmount,0) <> ISNULL(sad.CgstAmount,0) THEN 1
					   WHEN ISNULL(ED.SgstAmount,0) <> ISNULL(sad.SgstAmount,0) THEN 1
					   WHEN ISNULL(ED.CessAmount,0) <> ISNULL(sad.CessAmount,0) THEN 1
					   WHEN ISNULL(ED.TaxableValue,0) <> ISNULL(sad.TaxableValue,0) THEN 1
					   ELSE 0 END END
	   END) AS DetailComparison,
	   ids.SupplyType
	INTO #TempYearlyGstAutoDraftdetailComp	
	FROM #TempYearlyGstAutoDraftMatchedId Ids
	INNER JOIN #TempRegularReturnDetailData ED ON Ids.GstId= ED.GstId 
	LEFT JOIN #TempAutoDraftDetailData sad ON IDS.AutodraftId = sad.AutoDraftId AND ED.Rate = sad.Rate
	GROUP BY Ids.AutodraftId,Ids.GstId,ids.SupplyType 
	
	/*Finding final Section and reason of reconciled data*/		
	SELECT 
		Ids.GstId,
		ED.AutodraftId,	
		Ids.SupplyType,	
		CASE WHEN ED.GstId IS NOT NULL
			 THEN CASE WHEN TransactionType IS NULL  AND Gstin IS NULL AND Pos IS NULL AND DocumentValue IS NULL AND reversecharge IS NULL AND DocumentDate IS NULL AND ISNULL(DetailComparison,0) = 0 AND ItemCount IS NULL
							AND IgstAmount IS NULL AND SgstAmount IS NULL AND CgstAmount IS NULL AND CessAmount IS NULL AND TaxableValue IS NULL
					   THEN @ReconciliationSectionTypeGstAutodraftedMatched
					   ELSE @ReconciliationSectionTypeGstAutodraftedMismatched
				   END	
			 ELSE @ReconciliationSectionTypeGstAutodraftedNotAvailable 
		END AutoDraftSection,		
		CASE WHEN ED.TransactionType IS NOT NULL Then @ReconciliationReasonTypeTransactionType else 0 END +
		CASE WHEN ED.Gstin IS NOT NULL Then @ReconciliationReasonTypeGstin else 0 END +																			  
		CASE WHEN ED.POS IS NOT NULL Then @ReconciliationReasonTypePOS else 0 END +
		CASE WHEN ED.ReverseCharge IS NOT NULL Then @ReconciliationReasonTypeReverseCharge else 0 END +
		CASE WHEN ED.Documentdate IS NOT NULL Then @ReconciliationReasonTypeDocumentDate else 0 END +
		CASE WHEN ED.DocumentValue IS NOT NULL Then @ReconciliationReasonTypeDocumentValue else 0 END  + 
		CASE WHEN ED.ItemCount IS NOT NULL Then @ReconciliationReasonTypeItems else 0 END  + 
		CASE WHEN ED.IgstAmount IS NOT NULL Then @ReconciliationReasonTypeIgstAmount else 0 END  + 
		CASE WHEN ED.CgstAmount IS NOT NULL Then @ReconciliationReasonTypeCgstAmount else 0 END  + 
		CASE WHEN ED.SgstAmount IS NOT NULL Then @ReconciliationReasonTypeSgstAmount else 0 END  + 
		CASE WHEN ED.TaxableValue IS NOT NULL Then @ReconciliationReasonTypeTaxableValue else 0 END  + 
		CASE WHEN COALESCE(DetailComparison,0) >= 3 Then @ReconciliationReasonTypeRate else 0 END +
		CASE WHEN ED.CessAmount IS NOT NULL Then @ReconciliationReasonTypeCessAmount else 0 END  AS AutoDraftReasonsType,
		(SELECT CASE WHEN ED.TransactionType IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTransactionType  , ',"Value":""},') ELSE '' END + 
				CASE WHEN ED.Gstin IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeGstin , ',"Value":""},') ELSE '' END +																												  
				CASE WHEN ED.POS IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypePOS , ',"Value":"', Pos ,'"},') ELSE '' END +
				CASE WHEN ED.ReverseCharge IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeReverseCharge , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.Documentdate IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentDate , ',"Value":"', DocumentDate ,'"},') ELSE '' END +
				CASE WHEN ED.DocumentValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeDocumentValue , ',"Value":"', DocumentValue ,'"},') ELSE '' END +
				CASE WHEN ED.ItemCount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeItems , ',"Value":"', ItemCount ,'"},') ELSE '' END +
				CASE WHEN ED.IgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeIgstAmount , ',"Value":"',IgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.CgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCgstAmount , ',"Value":"',CgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.SgstAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeSgstAmount , ',"Value":"',SgstAmount,'"},') ELSE '' END +
				CASE WHEN ED.TaxableValue IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeTaxableValue , ',"Value":"',TaxableValue,'"},') ELSE '' END +
				CASE WHEN COALESCE(DetailComparison,0) >= 3 Then CONCAT('{"Reason":', @ReconciliationReasonTypeRate  , ',"Value":""},') ELSE '' END +
				CASE WHEN ED.CessAmount IS NOT NULL Then CONCAT('{"Reason":', @ReconciliationReasonTypeCessAmount , ',"Value":"',CessAmount,'"},') ELSE '' END
				) AutoDraftReason ,						
		@MappingTypeYearly MappingType		
	INTO #TempYearlyGstAutoDraftReco				
	FROM #TempGstUnreconciledIds Ids
	LEFT JOIN #TempYearlyGstAutoDraftHeaderMatching ED ON Ids.GstId = ED.GstId AND Ids.SupplyType = ED.SupplyType
	LEFT JOIN #TempYearlyGstAutoDraftdetailComp EDI ON Ed.GstId = EDI.GstId AND ED.SupplyType = EDI.SupplyType AND ED.AutodraftId = EDI.AutodraftId		

	/*Inserting data of MonthlyComparison into Mapping Table*/
	INSERT INTO report.GstRecoMapper
	(
		 GstId
		,EInvId
		,EWBId
		,AutoDraftID
		,GstType
		,EInvSection
		,EWBSection
		,AutoDraftSection
		,EInvReasonsType
		,EwbReasonsType
		,AutoDraftReasonsType
		,EInvReason
		,EwbReason
		,AutoDraftReason
		,MappingType
		,Stamp
		,ModifiedStamp
	)
	SELECT 
		GstId					=ES.GstId
		,EInvId					=EE.EinvId
		,EWBId					=CASE WHEN Es.EwbSection = @ReconciliationSectionTypeEwbNotApplicable THEN NULL ELSE ES.Ewbid END
		,AutoDraftID			=AD.AutodraftId
		,GstType				=EE.SupplyType
		,EInvSection			=EE.EINVSection
		,EWBSection				=ES.EwbSection
		,AutoDraftSection		=AD.AutoDraftSection
		,EInvReasonsType		=CASE WHEN EE.EInvReasonsType = 0 THEN NULL ELSE EE.EinvReasonsType END
		,EwbReasonsType			=CASE WHEN ES.EwbReasonsType = 0 OR Es.EwbSection = @ReconciliationSectionTypeEwbNotApplicable THEN NULL ELSE ES.EwbReasonsType END
		,AutoDraftReasonsType	=CASE WHEN AD.AutoDraftReasonsType = 0 THEN NULL ELSE AD.AutoDraftReasonsType END
		,EInvReason				=CASE WHEN EE.EinvReason = '' THEN NULL ELSE CONCAT('[',LEFT(EE.EinvReason,LEN(EE.EinvReason)-1) ,']') END
		,EwbReason				=CASE WHEN ES.EWbReason = '' OR Es.EwbSection = @ReconciliationSectionTypeEwbNotApplicable THEN NULL ELSE CONCAT('[',LEFT(ES.EWbReason,LEN(ES.EWbReason)-1) ,']') END
		,AutoDraftReason		=CASE WHEN AD.AutoDraftReason = '' THEN NULL ELSE CONCAT('[',LEFT(AD.AutoDraftReason,LEN(AD.AutoDraftReason)-1) ,']') END
		,MappingType			=EE.MappingType
		,Stamp					=GETDATE()
		,ModifiedStamp			=NULL		
	FROM
		#TempYearlyGstEwbReco ES
	INNER JOIN #TempYearlyGstEinvReco EE ON ES.gstID = EE.gstid ANd ES.SupplyType = EE.SupplyType
	INNER JOIN #TempYearlyGstAutoDraftReco AD ON ES.gstID = AD.gstid ANd ES.SupplyType = AD.SupplyType

--	DROP TABLE IF EXISTS #TempGRMIds;
--	
--	;WITH cte AS
--	(
--		SELECT
--			ROW_NUMBER() OVER(PARTITION BY grm.GstId, grm.GstType, grm.MappingType ORDER BY grm.Id) RowNum,
--			grm.Id
--		FROM
--			report.GstRecoMapper grm
--	)
--	
--	SELECT Id 
--	INTO #TempGRMIds
--	FROM cte WHERE RowNum > 1;
--
--	DELETE g FROM report.GstRecoMapper g WHERE g.Id IN (SELECT t.Id FROM #TempGRMIds t);

	SELECT * FROM #TempGstUnreconciledIds;

	
	END
END TRY
BEGIN CATCH

	DECLARE @UNCOMMITTED_STATE SMALLINT = -1, @DB_ERROR SMALLINT = -1, @ErrorLogID UNIQUEIDENTIFIER; 
	/*	
	IF (XACT_STATE()) = @UNCOMMITTED_STATE  
	BEGIN  
			ROLLBACK TRANSACTION;  
	END; 
	*/
	THROW;

END CATCH

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
								@SectTypeB2CL = 8,
								@SectTypeCDNUR = 2048, 
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
								@Gstr3bAutoPopulateTypeExemptedTurnoverRatio = 2,
								@AmendedTypeR = 1;
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
	@SectTypeB2CL INTEGER,
	@SectTypeCDNUR INTEGER,
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
	@Gstr3bAutoPopulateTypeExemptedTurnoverRatio SMALLINT,
	@AmendedTypeR INTEGER
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
		sd.SectionType,
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
		sd.SectionType,
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
		pds.LiabilityDischargeReturnPeriod,
		pds.AmendedType
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
		tp.IsAmendment = @BitTypeN
		OR
		(
			tp.IsAmendment = @BitTypeY
			AND tp.AmendedType = @AmendedTypeR
		);

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
		tp.AmendedType,
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
		 tp.MapperId IS NULL
		 AND
		 (
			tp.IsAmendment = @BitTypeN
			OR
			(
				tp.IsAmendment = @BitTypeY
				AND tp.AmendedType = @AmendedTypeR
			)
		 );

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
				@SectTypeB2CL = @SectTypeB2CL,
				@SectTypeCDNUR = @SectTypeCDNUR,
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
				@SectTypeB2CL = @SectTypeB2CL,
				@SectTypeCDNUR = @SectTypeCDNUR,
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
				@SectTypeB2CL = @SectTypeB2CL,
				@SectTypeCDNUR = @SectTypeCDNUR,
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
				@BitTypeN = @BitTypeN,
				@AmendedTypeR = @AmendedTypeR;

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
				@BitTypeN = @BitTypeN,
				@AmendedTypeR = @AmendedTypeR;	
		
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


DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3bSection31A];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	 : [gst].[GenerateGstr3bSection31A]
*	Comments		 : 26/04/2022 | Jitendra Sharma | This procedure is used to get Data Section 3.1(A) (Eco Supplies) for Gstr3b
*	Sample Execution : EXEC [gst].[GenerateGstr3bSection31A]
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3bSection31A]
(
	@Gstr3bSectionEcoSupplies INT,
	@Gstr3bSectionEcoRegSupplies INT,
	@LocationPos SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@TransactionTypeB2C SMALLINT,
	@TransactionTypeB2B SMALLINT,
	@TransactionTypeCBW SMALLINT,
	@TransactionTypeDE SMALLINT,
	@SectTypeB2CL INTEGER,
	@SectTypeCDNUR INTEGER,
	@DocumentSummaryTypeGSTR1ECOM SMALLINT, 
	@DocumentSummaryTypeGSTR1SUPECO SMALLINT,
	@GstActOrRuleSectionTypeGstAct95 SMALLINT,
	@BitTypeN BIT,
	@BitTypeY BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempGstr3bSection3A_Original
	(
		Section INT,
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

	CREATE TABLE #TempGstr3bSummaryUpdateStatus
	(	
		Id BIGINT,
		SummaryType SMALLINT
	);

	/*Original Documents*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section ,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount 
	)
	SELECT
		@Gstr3bSectionEcoSupplies,
		SUM(tsd.TaxableValue) AS TaxableValue,
		SUM(tsd.IgstAmount) AS IgstAmount,
		SUM(tsd.CgstAmount) AS CgstAmount,
		SUM(tsd.SgstAmount) AS SgstAmount,
		SUM(tsd.CessAmount) AS CessAmount
	FROM
		#TempSaleDocuments tsd
	WHERE 
		tsd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsd.ECommerceGstin IS NULL
		AND tsd.ReverseCharge = @BitTypeN
		AND tsd.GstActOrRuleSection = @GstActOrRuleSectionTypeGstAct95
		AND
		(
			tsd.SectionType & @SectTypeB2CL <> 0
			OR
			(tsd.SectionType & @SectTypeCDNUR <> 0 AND tsd.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsd.BillToGstin IS NOT NULL
				AND tsd.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tsd.Id
	FROM
		#TempSaleDocuments tsd
	WHERE 
		tsd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsd.ECommerceGstin IS NULL
		AND tsd.ReverseCharge = @BitTypeN
		AND tsd.GstActOrRuleSection = @GstActOrRuleSectionTypeGstAct95
		AND
		(
			tsd.SectionType & @SectTypeB2CL <> 0
			OR
			(tsd.SectionType & @SectTypeCDNUR <> 0 AND tsd.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsd.BillToGstin IS NOT NULL
				AND tsd.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		);

	/*Invoice Amendments Documents*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionEcoSupplies,
		SUM(tsda.TaxableValue_A - COALESCE(tsda.TaxableValue,0)) AS TaxableValue,
		SUM(tsda.IgstAmount_A - COALESCE(tsda.IgstAmount,0)) AS IgstAmount,
		SUM(tsda.CgstAmount_A - COALESCE(tsda.CgstAmount,0)) AS CgstAmount,
		SUM(tsda.SgstAmount_A - COALESCE(tsda.SgstAmount,0)) AS SgstAmount,
		SUM(tsda.CessAmount_A - COALESCE(tsda.CessAmount,0)) AS CessAmount
	FROM
		#TempSaleDocumentsAmendment tsda	
	WHERE 
		tsda.DocumentType = @DocumentTypeINV
		AND tsda.ECommerceGstin IS NULL
		AND tsda.ReverseCharge = @BitTypeN
		AND tsda.GstActOrRuleSection = @GstActOrRuleSectionTypeGstAct95
		AND
		(
			tsda.SectionType & @SectTypeB2CL <> 0
			OR
			(tsda.SectionType & @SectTypeCDNUR <> 0 AND tsda.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsda.BillToGstin IS NOT NULL
				AND tsda.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		);
		
	/*CRN And DBN Amendments Documents*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionEcoSupplies,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 			
				 THEN tsda.TaxableValue_A - COALESCE(tsda.TaxableValue,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.TaxableValue_A + COALESCE(ABS(tsda.TaxableValue),0) 
					  ELSE -(ABS(tsda.TaxableValue_A) + COALESCE(tsda.TaxableValue,0)) 
				 END	 
			END) AS TaxableValue,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.IgstAmount_A - COALESCE(tsda.IgstAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.IgstAmount_A + COALESCE(ABS(tsda.IgstAmount),0) 
					  ELSE -(ABS(tsda.IgstAmount_A) + COALESCE(tsda.IgstAmount,0)) 
				 END	 
			END) AS IgstAmount,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.CgstAmount_A - COALESCE(tsda.CgstAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.CgstAmount_A + COALESCE(ABS(tsda.CgstAmount),0) 
					  ELSE -(ABS(tsda.CgstAmount_A) + COALESCE(tsda.CgstAmount,0)) 
				 END	 
			END) AS CgstAmount,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.SgstAmount_A - COALESCE(tsda.SgstAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.SgstAmount_A + COALESCE(ABS(tsda.SgstAmount),0) 
					  ELSE -(ABS(tsda.SgstAmount_A) + COALESCE(tsda.SgstAmount,0)) 
				 END	 
			END) AS SgstAmount,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.CessAmount_A - COALESCE(tsda.CessAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.CessAmount_A + COALESCE(ABS(tsda.CessAmount),0) 
					  ELSE -(ABS(tsda.CessAmount_A) + COALESCE(tsda.CessAmount,0)) 
				 END	 
			END) AS CessAmount
	FROM
		#TempSaleDocumentsAmendment tsda
	WHERE 
		tsda.DocumentType IN (@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsda.ECommerceGstin IS NULL
		AND tsda.ReverseCharge = @BitTypeN
		AND tsda.GstActOrRuleSection = @GstActOrRuleSectionTypeGstAct95
		AND
		(
			tsda.SectionType & @SectTypeB2CL <> 0
			OR
			(tsda.SectionType & @SectTypeCDNUR <> 0 AND tsda.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsda.BillToGstin IS NOT NULL
				AND tsda.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		)
	GROUP BY
		tsda.DocumentType;
	
	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tsda.Id
	FROM
		#TempSaleDocumentsAmendment tsda	
	WHERE 
		tsda.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsda.ECommerceGstin IS NULL
		AND tsda.ReverseCharge = @BitTypeN
		AND tsda.GstActOrRuleSection = @GstActOrRuleSectionTypeGstAct95
		AND
		(
			tsda.SectionType & @SectTypeB2CL <> 0
			OR
			(tsda.SectionType & @SectTypeCDNUR <> 0 AND tsda.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsda.BillToGstin IS NOT NULL
				AND tsda.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		);

	/*B2CS Original Document Summary*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		CASE WHEN tss.SummaryType = @DocumentSummaryTypeGSTR1ECOM THEN @Gstr3bSectionEcoSupplies ELSE @Gstr3bSectionEcoRegSupplies END,
		SUM(tss.TaxableValue) AS TaxableValue,
		SUM(tss.IgstAmount) AS IgstAmount,
		SUM(tss.CgstAmount) AS CgstAmount,
		SUM(tss.SgstAmount) AS SgstAmount,
		SUM(tss.CessAmount) AS CessAmount
	FROM
		#TempSaleSummary AS tss
	WHERE
		(
			tss.SummaryType = @DocumentSummaryTypeGSTR1ECOM
			OR
			(tss.SummaryType = @DocumentSummaryTypeGSTR1SUPECO AND tss.GstActOrRuleSectionType = @GstActOrRuleSectionTypeGstAct95)
		)
	GROUP BY 
		tss.SummaryType;
		
	INSERT INTO #TempGstr3bSummaryUpdateStatus
	(
		Id,
		SummaryType
	)
	SELECT
		tss.Id,
		tss.SummaryType
	FROM
		#TempSaleSummary AS tss
	WHERE
		(
			tss.SummaryType = @DocumentSummaryTypeGSTR1ECOM
			OR
			(tss.SummaryType = @DocumentSummaryTypeGSTR1SUPECO AND tss.GstActOrRuleSectionType = @GstActOrRuleSectionTypeGstAct95)
		);

	/*B2CS Amendment Document Summary*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		CASE WHEN tssa.SummaryType = @DocumentSummaryTypeGSTR1ECOM THEN @Gstr3bSectionEcoSupplies ELSE @Gstr3bSectionEcoRegSupplies END,
		SUM(tssa.TaxableValue_A - COALESCE(tssa.TaxableValue,0)) AS TaxableValue,
		SUM(tssa.IgstAmount_A - COALESCE(tssa.IgstAmount,0)) AS IgstAmount,
		SUM(tssa.CgstAmount_A - COALESCE(tssa.CgstAmount,0)) AS CgstAmount,
		SUM(tssa.SgstAmount_A - COALESCE(tssa.SgstAmount,0)) AS SgstAmount,
		SUM(tssa.CessAmount_A - COALESCE(tssa.CessAmount,0)) AS CessAmount
	FROM
		#TempSaleSummaryAmendment AS tssa
	WHERE
		(
			tssa.SummaryType = @DocumentSummaryTypeGSTR1ECOM
			OR
			(tssa.SummaryType = @DocumentSummaryTypeGSTR1SUPECO AND tssa.GstActOrRuleSectionType_A = @GstActOrRuleSectionTypeGstAct95)
		)
	GROUP BY 
		tssa.SummaryType;
		
	INSERT INTO #TempGstr3bSummaryUpdateStatus
	(
		Id,
		SummaryType
	)
	SELECT
		tssa.Id,
		tssa.SummaryType
	FROM
		#TempSaleSummaryAmendment AS tssa
	WHERE
		(
			tssa.SummaryType = @DocumentSummaryTypeGSTR1ECOM
			OR
			(tssa.SummaryType = @DocumentSummaryTypeGSTR1SUPECO AND tssa.GstActOrRuleSectionType_A = @GstActOrRuleSectionTypeGstAct95)
		);
	
	UPDATE 
		oregular.SaleDocumentStatus
	SET 
		Gstr3bSection = @Gstr3bSectionEcoSupplies
	FROM 
		#TempGstr3bUpdateStatus us
	WHERE
		SaleDocumentId = us.Id;

	UPDATE 
		oregular.SaleSummaryStatus
	SET 
		Gstr3bSection = CASE WHEN us.SummaryType = @DocumentSummaryTypeGSTR1ECOM THEN @Gstr3bSectionEcoSupplies ELSE @Gstr3bSectionEcoRegSupplies END
	FROM 
		#TempGstr3bSummaryUpdateStatus us
	WHERE
		SaleSummaryId = us.Id;
		
	SELECT
		tod.Section,
		SUM(tod.TaxableValue) AS TaxableValue,
		SUM(tod.IgstAmount)	AS IgstAmount,
		SUM(tod.CgstAmount)	AS CgstAmount,
		SUM(tod.SgstAmount)	AS SgstAmount,
		SUM(tod.CessAmount)	AS CessAmount
	FROM
		#TempGstr3bSection3A_Original AS tod
	GROUP BY
		tod.Section;

	DROP TABLE #TempGstr3bSection3A_Original,#TempGstr3bSummaryUpdateStatus,#TempGstr3bUpdateStatus;
END;
GO


DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3bSection3A1];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	 : [gst].[GenerateGstr3bSection3A1]
*	Comments		 : 22/06/2020 | Amit Khanna | This procedure is used to get Data Section 3.1.1 (Outward Tax Supply) for Gstr3b
					 : 03/07/2020 | Amit Khanna | Added Parameter TransactionTypeComp.
					 : 20/07/2020 | Amit Khanna | Removed Parameter TrasanctionType Comp,TCS & TCS.
*	Sample Execution : EXEC [gst].[GenerateGstr3bSection3A1]
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3bSection3A1]
(
	@Gstr3bSectionOutwardTaxSupply INT,
	@LocationPos SMALLINT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@TransactionTypeB2C SMALLINT,
	@TransactionTypeB2B SMALLINT,
	@TransactionTypeCBW SMALLINT,
	@TransactionTypeDE SMALLINT,
	@SectTypeB2CL INTEGER,
	@SectTypeCDNUR INTEGER,
	@DocumentSummaryTypeGstr1B2CS SMALLINT,
	@DocumentSummaryTypeGstr1ADV SMALLINT,
	@DocumentSummaryTypeGstr1ADVAJ SMALLINT,
	@GstActOrRuleSectionTypeGstAct95 SMALLINT,
	@BitTypeN BIT,
	@BitTypeY BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempGstr3bSection3A_Original
	(
		Section INT,
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

	CREATE TABLE #TempGstr3bSummaryUpdateStatus
	(	
		Id BIGINT
	);
	
	/*3.1.1 Outward taxable supplies (other than zero rated, nil rated and exempted) Original Documents*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardTaxSupply,
		SUM(tsd.TaxableValue) AS TaxableValue,
		CASE WHEN tsd.ReverseCharge = @BitTypeN THEN SUM(tsd.IgstAmount) ELSE 0 END AS IgstAmount,
		CASE WHEN tsd.ReverseCharge = @BitTypeN THEN SUM(tsd.CgstAmount) ELSE 0 END AS CgstAmount,
		CASE WHEN tsd.ReverseCharge = @BitTypeN THEN SUM(tsd.SgstAmount) ELSE 0 END AS SgstAmount,
		CASE WHEN tsd.ReverseCharge = @BitTypeN THEN SUM(tsd.CessAmount) ELSE 0 END AS CessAmount
	FROM
		#TempSaleDocuments tsd
	WHERE 
		tsd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tsd.GstActOrRuleSection IS NULL OR tsd.GstActOrRuleSection <> @GstActOrRuleSectionTypeGstAct95)
		AND
		(
			tsd.SectionType & @SectTypeB2CL <> 0
			OR
			(tsd.SectionType & @SectTypeCDNUR <> 0 AND tsd.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsd.BillToGstin IS NOT NULL
				AND tsd.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		)
	GROUP BY 
		tsd.ReverseCharge;

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tsd.Id
	FROM
		#TempSaleDocuments tsd
	WHERE 
		tsd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tsd.GstActOrRuleSection IS NULL OR tsd.GstActOrRuleSection <> @GstActOrRuleSectionTypeGstAct95)
		AND
		(
			tsd.SectionType & @SectTypeB2CL <> 0
			OR
			(tsd.SectionType & @SectTypeCDNUR <> 0 AND tsd.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsd.BillToGstin IS NOT NULL
				AND tsd.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			) 
		);

	/*3.1.1 Outward taxable supplies (other than zero rated, nil rated and exempted) Invoice Amendments Documents*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardTaxSupply,
		SUM(tsda.TaxableValue_A - COALESCE(tsda.TaxableValue,0)) AS TaxableValue,
		CASE WHEN tsda.ReverseCharge = @BitTypeN THEN SUM(tsda.IgstAmount_A - COALESCE(tsda.IgstAmount,0)) ELSE 0 END AS IgstAmount,
		CASE WHEN tsda.ReverseCharge = @BitTypeN THEN SUM(tsda.CgstAmount_A - COALESCE(tsda.CgstAmount,0)) ELSE 0 END AS CgstAmount,
		CASE WHEN tsda.ReverseCharge = @BitTypeN THEN SUM(tsda.SgstAmount_A - COALESCE(tsda.SgstAmount,0)) ELSE 0 END AS SgstAmount,
		CASE WHEN tsda.ReverseCharge = @BitTypeN THEN SUM(tsda.CessAmount_A - COALESCE(tsda.CessAmount,0)) ELSE 0 END AS CessAmount
	FROM
		#TempSaleDocumentsAmendment tsda	
	WHERE 
		tsda.DocumentType = @DocumentTypeINV
		AND (tsda.GstActOrRuleSection IS NULL OR tsda.GstActOrRuleSection <> @GstActOrRuleSectionTypeGstAct95)
		AND
		(
			tsda.SectionType & @SectTypeB2CL <> 0
			OR
			(tsda.SectionType & @SectTypeCDNUR <> 0 AND tsda.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsda.BillToGstin IS NOT NULL
				AND tsda.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		)
	GROUP BY
		tsda.ReverseCharge;

	/*3.1.1 Outward taxable supplies (other than zero rated, nil rated and exempted) CRN And DBN Amendments Documents*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardTaxSupply,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.TaxableValue_A - COALESCE(tsda.TaxableValue,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.TaxableValue_A + COALESCE(ABS(tsda.TaxableValue),0) 
					  ELSE -(ABS(tsda.TaxableValue_A) + COALESCE(tsda.TaxableValue,0)) 
				 END	 
			END) AS TaxableValue,
		CASE WHEN tsda.ReverseCharge = @BitTypeN 
			 THEN 
			 SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
					  THEN tsda.IgstAmount_A - COALESCE(tsda.IgstAmount,0) 
					  ELSE
					  CASE WHEN tsda.DocumentType = @DocumentTypeDBN
						   THEN tsda.IgstAmount_A + COALESCE(ABS(tsda.IgstAmount),0) 
						   ELSE -(ABS(tsda.IgstAmount_A) + COALESCE(tsda.IgstAmount,0)) 
					  END	 
				END)
			 ELSE 0 
		END AS IgstAmount,
		CASE WHEN tsda.ReverseCharge = @BitTypeN 
			 THEN 
			 SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
					  THEN tsda.CgstAmount_A - COALESCE(tsda.CgstAmount,0) 
					  ELSE
					  CASE WHEN tsda.DocumentType = @DocumentTypeDBN
						   THEN tsda.CgstAmount_A + COALESCE(ABS(tsda.CgstAmount),0) 
						   ELSE -(ABS(tsda.CgstAmount_A) + COALESCE(tsda.CgstAmount,0)) 
					  END	 
				END)
			 ELSE 0 
		END AS CgstAmount,
		CASE WHEN tsda.ReverseCharge = @BitTypeN 
			 THEN 
			 SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
					  THEN tsda.SgstAmount_A - COALESCE(tsda.SgstAmount,0) 
					  ELSE
					  CASE WHEN tsda.DocumentType = @DocumentTypeDBN
						   THEN tsda.SgstAmount_A + COALESCE(ABS(tsda.SgstAmount),0) 
						   ELSE -(ABS(tsda.SgstAmount_A) + COALESCE(tsda.SgstAmount,0)) 
					  END	 
				END)
			 ELSE 0 
		END AS SgstAmount,
		CASE WHEN tsda.ReverseCharge = @BitTypeN 
			 THEN 
			 SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
					  THEN tsda.CessAmount_A - COALESCE(tsda.CessAmount,0) 
					  ELSE
					  CASE WHEN tsda.DocumentType = @DocumentTypeDBN
						   THEN tsda.CessAmount_A + COALESCE(ABS(tsda.CessAmount),0) 
						   ELSE -(ABS(tsda.CessAmount_A) + COALESCE(tsda.CessAmount,0)) 
					  END	 
				END)
			 ELSE 0 
		END AS CessAmount
	FROM
		#TempSaleDocumentsAmendment tsda
	WHERE 
		tsda.DocumentType IN (@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tsda.GstActOrRuleSection IS NULL OR tsda.GstActOrRuleSection <> @GstActOrRuleSectionTypeGstAct95)
		AND
		(
			tsda.SectionType & @SectTypeB2CL <> 0
			OR
			(tsda.SectionType & @SectTypeCDNUR <> 0 AND tsda.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsda.BillToGstin IS NOT NULL
				AND tsda.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		)
	GROUP BY
		tsda.ReverseCharge;

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tsda.Id
	FROM
		#TempSaleDocumentsAmendment tsda
	WHERE 
		tsda.DocumentType IN (@DocumentTypeCRN,@DocumentTypeDBN)
		AND (tsda.GstActOrRuleSection IS NULL OR tsda.GstActOrRuleSection <> @GstActOrRuleSectionTypeGstAct95)
		AND
		(
			tsda.SectionType & @SectTypeB2CL <> 0
			OR
			(tsda.SectionType & @SectTypeCDNUR <> 0 AND tsda.TransactionType  = @TransactionTypeB2C)
			OR
			(
				tsda.BillToGstin IS NOT NULL
				AND tsda.TransactionType IN (@TransactionTypeB2B,@TransactionTypeDE,@TransactionTypeCBW)
			)
		);

	/*3.1.1 Outward taxable supplies (other than zero rated, nil rated and exempted) B2CS, ADV, ADVAJ Original Document Summary*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardTaxSupply,
		SUM(tss.TaxableValue) AS TaxableValue,
		SUM(tss.IgstAmount) AS IgstAmount,
		SUM(tss.CgstAmount) AS CgstAmount,
		SUM(tss.SgstAmount) AS SgstAmount,
		SUM(tss.CessAmount) AS CessAmount
	FROM
		#TempSaleSummary AS tss
	WHERE
		tss.SummaryType IN (@DocumentSummaryTypeGstr1B2CS,@DocumentSummaryTypeGstr1ADV,@DocumentSummaryTypeGstr1ADVAJ);

	INSERT INTO #TempGstr3bSummaryUpdateStatus
	(
		Id
	)
	SELECT
		tss.Id
	FROM
		#TempSaleSummary AS tss
	WHERE
		tss.SummaryType IN (@DocumentSummaryTypeGstr1B2CS,@DocumentSummaryTypeGstr1ADV,@DocumentSummaryTypeGstr1ADVAJ);

	/*3.1.1 Outward taxable supplies (other than zero rated, nil rated and exempted) B2CS, ADV, ADVAJ Amendment Document Summary*/
	INSERT INTO #TempGstr3bSection3A_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardTaxSupply,
		SUM(tssa.TaxableValue_A - COALESCE(tssa.TaxableValue,0)) AS TaxableValue,
		SUM(tssa.IgstAmount_A - COALESCE(tssa.IgstAmount,0)) AS IgstAmount,
		SUM(tssa.CgstAmount_A - COALESCE(tssa.CgstAmount,0)) AS CgstAmount,
		SUM(tssa.SgstAmount_A - COALESCE(tssa.SgstAmount,0)) AS SgstAmount,
		SUM(tssa.CessAmount_A - COALESCE(tssa.CessAmount,0)) AS CessAmount
	FROM
		#TempSaleSummaryAmendment AS tssa
	WHERE
		tssa.SummaryType IN (@DocumentSummaryTypeGstr1B2CS,@DocumentSummaryTypeGstr1ADV,@DocumentSummaryTypeGstr1ADVAJ);

	INSERT INTO #TempGstr3bSummaryUpdateStatus
	(
		Id
	)
	SELECT
		tssa.Id
	FROM
		#TempSaleSummaryAmendment AS tssa
	WHERE
		tssa.SummaryType IN (@DocumentSummaryTypeGstr1B2CS,@DocumentSummaryTypeGstr1ADV,@DocumentSummaryTypeGstr1ADVAJ);
		
	UPDATE 
		oregular.SaleDocumentStatus
	SET 
		Gstr3bSection = CASE WHEN Gstr3bSection IS NULL THEN @Gstr3bSectionOutwardTaxSupply WHEN Gstr3bSection & @Gstr3bSectionOutwardTaxSupply <> 0 THEN Gstr3bSection ELSE Gstr3bSection + @Gstr3bSectionOutwardTaxSupply END
	FROM 
		#TempGstr3bUpdateStatus us
	WHERE
		SaleDocumentId = us.Id;

	UPDATE 
		oregular.SaleSummaryStatus
	SET 
		Gstr3bSection = CASE WHEN Gstr3bSection IS NULL THEN @Gstr3bSectionOutwardTaxSupply WHEN Gstr3bSection & @Gstr3bSectionOutwardTaxSupply <> 0 THEN Gstr3bSection ELSE Gstr3bSection + @Gstr3bSectionOutwardTaxSupply END
	FROM 
		#TempGstr3bSummaryUpdateStatus us
	WHERE
		SaleSummaryId = us.Id;

	SELECT
		tod.Section,
		SUM(tod.TaxableValue) AS TaxableValue,
		SUM(tod.IgstAmount)	AS IgstAmount,
		SUM(tod.CgstAmount)	AS CgstAmount,
		SUM(tod.SgstAmount)	AS SgstAmount,
		SUM(tod.CessAmount)	AS CessAmount
	FROM
		#TempGstr3bSection3A_Original AS tod
	GROUP BY
		tod.Section;

	DROP TABLE #TempGstr3bSection3A_Original,#TempGstr3bSummaryUpdateStatus,#TempGstr3bUpdateStatus;
END;
GO


DROP PROCEDURE IF EXISTS [gst].[GenerateGstr3bSection3A2];
GO


/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: [gst].[GenerateGstr3bSection3A2]
*	Comments		: 22/06/2020 | Amit Khanna | This procedure is used to get Data of Section 3.1.2 Outward taxable supplies (zero rated)
*	Sample Execution : 
					EXEC [gst].[GenerateGstr3bSection3A2]
-------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GenerateGstr3bSection3A2]
(
	@Gstr3bSectionOutwardZeroRated INT,
	@DocumentTypeINV SMALLINT,
	@DocumentTypeCRN SMALLINT,
	@DocumentTypeDBN SMALLINT,
	@TransactionTypeEXPWP SMALLINT,
	@TransactionTypeEXPWOP SMALLINT,
	@TransactionTypeSEZWP SMALLINT,
	@TransactionTypeSEZWOP SMALLINT,
	@BitTypeN BIT,
	@BitTypeY BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempGstr3bSection3A2_Original
	(
		Section INT,
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

	/*3.1.2 Outward taxable supplies (zero rated)*/
	INSERT INTO #TempGstr3bSection3A2_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardZeroRated,
		SUM(tsd.TaxableValue) AS TaxableValue,
		SUM(tsd.IgstAmount) AS IgstAmount,
		SUM(tsd.CgstAmount) AS CgstAmount,
		SUM(tsd.SgstAmount) AS SgstAmount,
		SUM(tsd.CessAmount) AS CessAmount
	FROM
		#TempSaleDocuments tsd
	WHERE 
		tsd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsd.ReverseCharge = @BitTypeN
		AND tsd.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP);

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tsd.Id
	FROM
		#TempSaleDocuments tsd
	WHERE 
		tsd.DocumentType IN (@DocumentTypeINV,@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsd.ReverseCharge = @BitTypeN
		AND tsd.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP);
		
	/*3.1.2 Outward taxable supplies (zero rated) Invoice Amendments Documents*/
	INSERT INTO #TempGstr3bSection3A2_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardZeroRated,
		SUM(tsda.TaxableValue_A - COALESCE(tsda.TaxableValue,0)) AS TaxableValue,
		SUM(tsda.IgstAmount_A - COALESCE(tsda.IgstAmount,0)) AS IgstAmount,
		SUM(tsda.CgstAmount_A - COALESCE(tsda.CgstAmount,0)) AS CgstAmount,
		SUM(tsda.SgstAmount_A - COALESCE(tsda.SgstAmount,0)) AS SgstAmount,
		SUM(tsda.CessAmount_A - COALESCE(tsda.CessAmount,0)) AS CessAmount
	FROM
		#TempSaleDocumentsAmendment AS tsda
	WHERE 
		tsda.DocumentType = @DocumentTypeINV
		AND tsda.ReverseCharge = @BitTypeN
		AND tsda.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP);
	
	/*3.1.2 Outward taxable supplies (zero rated) CRN And DBN Amendments Documents*/
	INSERT INTO #TempGstr3bSection3A2_Original
	(
		Section,
		TaxableValue,
		IgstAmount,
		CgstAmount,
		SgstAmount,
		CessAmount
	)
	SELECT
		@Gstr3bSectionOutwardZeroRated,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.TaxableValue_A - COALESCE(tsda.TaxableValue,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.TaxableValue_A + COALESCE(ABS(tsda.TaxableValue),0) 
					  ELSE -(ABS(tsda.TaxableValue_A) + COALESCE(tsda.TaxableValue,0)) 
				 END	 
			END) AS TaxableValue,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.IgstAmount_A - COALESCE(tsda.IgstAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.IgstAmount_A + COALESCE(ABS(tsda.IgstAmount),0) 
					  ELSE -(ABS(tsda.IgstAmount_A) + COALESCE(tsda.IgstAmount,0)) 
				 END	 
			END) AS IgstAmount,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.CgstAmount_A - COALESCE(tsda.CgstAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.CgstAmount_A + COALESCE(ABS(tsda.CgstAmount),0) 
					  ELSE -(ABS(tsda.CgstAmount_A) + COALESCE(tsda.CgstAmount,0)) 
				 END	 
			END) AS CgstAmount,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.SgstAmount_A - COALESCE(tsda.SgstAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.SgstAmount_A + COALESCE(ABS(tsda.SgstAmount),0) 
					  ELSE -(ABS(tsda.SgstAmount_A) + COALESCE(tsda.SgstAmount,0)) 
				 END	 
			END) AS SgstAmount,
		SUM(CASE WHEN tsda.DocumentType = tsda.DocumentType 
				 THEN tsda.CessAmount_A - COALESCE(tsda.CessAmount,0) 
				 ELSE
				 CASE WHEN tsda.DocumentType = @DocumentTypeDBN
					  THEN tsda.CessAmount_A + COALESCE(ABS(tsda.CessAmount),0) 
					  ELSE -(ABS(tsda.CessAmount_A) + COALESCE(tsda.CessAmount,0)) 
				 END	 
			END) AS CessAmount
	FROM
		#TempSaleDocumentsAmendment AS tsda
	WHERE 
		tsda.DocumentType IN (@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsda.ReverseCharge = @BitTypeN
		AND tsda.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP)
	GROUP BY
		tsda.DocumentType;

	INSERT INTO #TempGstr3bUpdateStatus
	(
		Id
	)
	SELECT
		tsda.Id
	FROM
		#TempSaleDocumentsAmendment tsda
	WHERE 
		tsda.DocumentType IN (@DocumentTypeCRN,@DocumentTypeDBN)
		AND tsda.ReverseCharge = @BitTypeN
		AND tsda.TransactionType IN (@TransactionTypeEXPWP,@TransactionTypeEXPWOP,@TransactionTypeSEZWP,@TransactionTypeSEZWOP);
		
	UPDATE 
		oregular.SaleDocumentStatus
	SET 
		Gstr3bSection = @Gstr3bSectionOutwardZeroRated
	FROM 
		#TempGstr3bUpdateStatus us
	WHERE
		SaleDocumentId = us.Id;
		
	SELECT
		tod.Section,
		SUM(tod.TaxableValue),
		SUM(tod.IgstAmount),
		SUM(tod.SgstAmount),
		SUM(tod.CgstAmount),
		SUM(tod.CessAmount)
	FROM
		#TempGstr3bSection3A2_Original AS tod
	GROUP BY
		tod.Section;

	DROP TABLE #TempGstr3bSection3A2_Original,#TempGstr3bUpdateStatus;
END;
GO


DROP PROCEDURE IF EXISTS [subscriber].[UpdateDownloadResponseForVendors];
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
			vs.CancellationDate = CASE WHEN tr.Errors IS NOT NULL THEN vs.CancellationDate ELSE tr.CancellationDate END
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
			vs.CancellationDate = CASE WHEN tr.Errors IS NOT NULL THEN vs.CancellationDate ELSE tr.CancellationDate END
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
END;
GO


DROP PROCEDURE IF EXISTS [gst].[GetReturnPeriodsByEntityId];
GO


/*-------------------------------------------------------------------------------------------------------------------
* 	Procedure Name		:	EXEC [gst].[GetReturnPeriodByEntityId] 	 
* 	Comment				:	29/09/2020 | Mayur Ladva | Get Not Filed Return Period
*	Review Comments		:   19-01-2021 | Abhishek Shrivas | Adding trnsaction ISOLATION LEVEL Read UNCOMMITTED;
						:   28-01-2021 | Dhruv Amin | Add Gstr6a related changes and moved to gst schema;
						:	02-09-2024 | Dhruv Amin | Added logic to return IsGstr3bFiled false/null data as well.
---------------------------------------------------------------------------------------------------------------------
*	Test Execution		:	EXEC [gst].[GetReturnPeriodByEntityId]
								@SubscriberId = 171,
								@EntityId = 373,
								@SourceTypeCounterPartyNotFiled = 2,
								@SourceTypeCounterPartyFiled = 3
-------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [gst].[GetReturnPeriodsByEntityId]
(
	@SubscriberId INT,
	@EntityId INT,
	@SourceTypeCounterPartyNotFiled SMALLINT,
	@SourceTypeCounterPartyFiled SMALLINT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	CREATE TABLE #TempPurchaseReturnPeriod
	(
		ReturnPeriod INT
	);

	INSERT INTO #TempPurchaseReturnPeriod
	(
		ReturnPeriod
	)
	SELECT DISTINCT
		pdw.ReturnPeriod
	FROM 
		oregular.PurchaseDocumentDW pdw
	WHERE
		pdw.SubscriberId = @SubscriberId
		AND pdw.EntityId = @EntityId
		ANd pdw.SourceType = @SourceTypeCounterPartyNotFiled
	UNION ALL 
	SELECT DISTINCT
		pdw.ReturnPeriod
	FROM 
		oregular.PurchaseDocumentDW pdw
		INNER JOIN oregular.PurchaseDocumentStatus pds ON pdw.Id = pds.PurchaseDocumentId
	WHERE
		pdw.SubscriberId = @SubscriberId
		AND pdw.EntityId = @EntityId
		ANd pdw.SourceType = @SourceTypeCounterPartyFiled
		AND pds.IsGstr3bFiled <> 1;

	SELECT DISTINCT 
		tprd.ReturnPeriod
	FROM
		#TempPurchaseReturnPeriod tprd;

	SELECT DISTINCT
		dw.ReturnPeriod
	FROM 
		isd.DocumentDW dw
	WHERE
		dw.SubscriberId = @SubscriberId
		AND dw.EntityId = @EntityId
		ANd dw.SourceType = @SourceTypeCounterPartyNotFiled;
END;
GO


