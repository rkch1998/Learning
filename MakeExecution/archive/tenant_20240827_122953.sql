SELECT * FROM "oregular"."InsertPurchaseDocumentReco"
("_SubscriberId"=>5497::integer,
"_ParentEntityId"=>144410::integer,
"_FinancialYear"=>202425::integer,
"_IsRegenerateNow"=>False::boolean,
"_Settings"=>ARRAY(SELECT json_populate_recordset(null ::oregular."GetReconciliationSettingForInsertResponseType",'[{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":201718,"FilingExtendedDate":"2019-03-24T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":201819,"FilingExtendedDate":"2019-10-20T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":201920,"FilingExtendedDate":"2020-10-20T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202021,"FilingExtendedDate":"2021-10-20T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202122,"FilingExtendedDate":"2022-11-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":false,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":false,"IsExcludeMatchingCriteriaTaxableValue":false,"IsExcludeMatchingCriteriaDocDate":false,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":false,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":false,"IsMatchByTolerance":false,"MatchByToleranceDocumentValueFrom":0.00,"MatchByToleranceDocumentValueTo":0.00,"MatchByToleranceTaxableValueFrom":0.00,"MatchByToleranceTaxableValueTo":0.00,"MatchByToleranceTaxAmountsFrom":0.00,"MatchByToleranceTaxAmountsTo":0.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":0.00,"NearMatchToleranceDocumentValueTo":0.00,"NearMatchToleranceTaxableValueFrom":0.00,"NearMatchToleranceTaxableValueTo":0.00,"NearMatchToleranceTaxAmountsFrom":0.00,"NearMatchToleranceTaxAmountsTo":0.00,"IsDiscardOriginalsWithAmendment":false,"FinancialYear":202223,"FilingExtendedDate":"2023-11-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":false,"IsNearMatchTolerance":false,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":true,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":true,"IsExcludeMatchingCriteriaTaxableValue":true,"IsExcludeMatchingCriteriaDocDate":true,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":true,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":true,"IsMatchByTolerance":true,"MatchByToleranceDocumentValueFrom":-1000.00,"MatchByToleranceDocumentValueTo":1000.00,"MatchByToleranceTaxableValueFrom":-1000.00,"MatchByToleranceTaxableValueTo":1000.00,"MatchByToleranceTaxAmountsFrom":-100.00,"MatchByToleranceTaxAmountsTo":100.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-1000.00,"NearMatchToleranceDocumentValueTo":1000.00,"NearMatchToleranceTaxableValueFrom":-1000.00,"NearMatchToleranceTaxableValueTo":1000.00,"NearMatchToleranceTaxAmountsFrom":-100.00,"NearMatchToleranceTaxAmountsTo":100.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":202324,"FilingExtendedDate":"2024-11-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":true,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00},{"IsReconcileAtDocumentLevel":true,"IsExcludeMatchingCriteria":true,"IsExcludeMatchingCriteriaPos":false,"IsExcludeMatchingCriteriaHsn":false,"IsExcludeMatchingCriteriaRate":false,"IsExcludeMatchingCriteriaDocumentValue":true,"IsExcludeMatchingCriteriaTaxableValue":true,"IsExcludeMatchingCriteriaDocDate":true,"IsExcludeMatchingCriteriaReverseCharge":false,"IsExcludeMatchingCriteriaTransactionType":true,"IsExcludeMatchingCriteriaIrn":true,"IsMatchOnDateDifference":true,"IsMatchByTolerance":true,"MatchByToleranceDocumentValueFrom":-1000.00,"MatchByToleranceDocumentValueTo":1000.00,"MatchByToleranceTaxableValueFrom":-1000.00,"MatchByToleranceTaxableValueTo":1000.00,"MatchByToleranceTaxAmountsFrom":-100.00,"MatchByToleranceTaxAmountsTo":100.00,"IfPrTaxAmountIsLessThanCpTaxAmount":false,"IfCpTaxAmountIsLessThanPrTaxAmount":false,"IsNearMatchViaFuzzyLogic":false,"NearMatchFuzzyLogicPercentage":0,"NearMatchDateRangeFrom":0,"NearMatchDateRangeTo":0,"ExcludeIntercompanyTransaction":false,"NearMatchToleranceDocumentValueFrom":-1000.00,"NearMatchToleranceDocumentValueTo":1000.00,"NearMatchToleranceTaxableValueFrom":-1000.00,"NearMatchToleranceTaxableValueTo":1000.00,"NearMatchToleranceTaxAmountsFrom":-100.00,"NearMatchToleranceTaxAmountsTo":100.00,"IsDiscardOriginalsWithAmendment":true,"FinancialYear":202425,"FilingExtendedDate":"2025-11-30T00:00:00","IsNearMatchDateRestriction":false,"IsRegeneratePreference":false,"IsExcludeCpNotFiledData":true,"IsMismatchIfDocNumberDifferentAfterAmendment":true,"AdvanceNearMatchPoweredByAI":true,"IsNearMatchTolerance":true,"IsRegeneratePreferenceAction":false,"IsRegeneratePreference3bClaimedMonth":false,"NearMatchCancelledInvoiceIdentification":false,"NearMatchCancelledInvoiceToleranceFrom":0.00,"NearMatchCancelledInvoiceToleranceTo":0.00,"IsRegeneratePreferenceSectionChange":false,"IsNearMatchShortCaseIdentification":false,"NearMatchShortCaseToleranceFrom":0.00,"NearMatchShortCaseToleranceTo":0.00}]')),
"_ExcludedGstin"=>ARRAY[]::oregular."FinancialYearWiseGstinType"[],
"_AuditTrailDetails"=>ARRAY(SELECT json_populate_recordset(null ::audit."AuditTrailDetailsType",'[{"RequestId":"5fc1876e-e9a8-47ca-8fdd-01918d608a40","UserId":-10001,"UserAction":33,"RequestIpAddress":"172.22.19.206","IsEnabled":false,"IsSkipActionTrail":false}]')),
"_DocumentTypeINV"=>1::smallint,
"_DocumentTypeCRN"=>2::smallint,
"_DocumentTypeDBN"=>3::smallint,
"_DocumentTypeBOE"=>4::smallint,
"_TransactionTypeB2B"=>1::smallint,
"_TransactionTypeSEZWP"=>4::smallint,
"_TransactionTypeSEZWOP"=>5::smallint,
"_TransactionTypeDE"=>6::smallint,
"_TransactionTypeISD"=>9::smallint,
"_TransactionTypeCBW"=>25::smallint,
"_TransactionTypeIMPG"=>7::smallint,
"_TransactionTypeIMPS"=>8::smallint,
"_DocumentStatusActive"=>1::smallint,
"_DocumentStatusDeleted"=>2::smallint,
"_DocumentStatusCancelled"=>3::smallint,
"_ActionTypeNoAction"=>1::smallint,
"_ReconciliationSectionTypePROnly"=>1::smallint,
"_ReconciliationSectionTypeGstOnly"=>2::smallint,
"_ReconciliationSectionTypeMatched"=>3::smallint,
"_ReconciliationSectionTypeMatchedDueToTolerance"=>4::smallint,
"_ReconciliationSectionTypeMisMatched"=>5::smallint,
"_ReconciliationSectionTypeNearMatched"=>6::smallint,
"_ReconciliationSectionTypePRExcluded"=>7::smallint,
"_ReconciliationSectionTypeGstExcluded"=>8::smallint,
"_ReconciliationSectionTypePRDiscarded"=>9::smallint,
"_ReconciliationSectionTypeGstDiscarded"=>10::smallint,
"_SourceTypeTaxpayer"=>1::smallint,
"_SourceTypeCounterPartyNotFiled"=>2::smallint,
"_SourceTypeCounterPartyFiled"=>3::smallint,
"_ContactTypeBillFrom"=>1::smallint,
"_ReconciledTypeSystem"=>1::smallint,
"_ReconciledTypeManual"=>2::smallint,
"_ReconciledTypeSystemSectionChanged"=>3::smallint,
"_ReconciledTypeManualSectionChanged"=>4::smallint);
