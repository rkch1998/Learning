package com.db.execution.function;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.db.execution.util.GetRandomValues;

@Component
public class MakeExecution {
/*
 * In this function arguments have the parameter in the form of key value pair like {name:varchar, age:int, dob:date}
 * functionName contains name of the function with schema name from sql like emp."GetDetails"
 * and this function will provide me execution like
 * SELECT * FROM emp."GetDetails"(
 * name => rare::varchar, 
 * age => 10::int, 
 * dob => '2014-10-01'::date
 * )
 * integer
 * integer[]
 * smallint
 * smallint[]
 * bigint
 * bigint[]
 * character varying
 * character varying[]
 * numeric
 * decimal
 * boolean
 * timestamp without time zone
 * 
 */

    private static final String settings = "[{\"IsReconcileAtDocumentLevel\":false,\"IsExcludeMatchingCriteria\":true,\"IsExcludeMatchingCriteriaPos\":true,\"IsExcludeMatchingCriteriaHsn\":false,\"IsExcludeMatchingCriteriaRate\":false,\"IsExcludeMatchingCriteriaDocumentValue\":false,\"IsExcludeMatchingCriteriaTaxableValue\":false,\"IsExcludeMatchingCriteriaDocDate\":false,\"IsExcludeMatchingCriteriaReverseCharge\":false,\"IsExcludeMatchingCriteriaTransactionType\":true,\"IsExcludeMatchingCriteriaIrn\":false,\"IsMatchOnDateDifference\":true,\"IsMatchByTolerance\":true,\"MatchByToleranceDocumentValueFrom\":-1000.00,\"MatchByToleranceDocumentValueTo\":1000.00,\"MatchByToleranceTaxableValueFrom\":-500.00,\"MatchByToleranceTaxableValueTo\":500.00,\"MatchByToleranceTaxAmountsFrom\":-100.00,\"MatchByToleranceTaxAmountsTo\":100.00,\"IfPrTaxAmountIsLessThanCpTaxAmount\":false,\"IfCpTaxAmountIsLessThanPrTaxAmount\":false,\"IsNearMatchViaFuzzyLogic\":false,\"NearMatchFuzzyLogicPercentage\":0,\"NearMatchDateRangeFrom\":0,\"NearMatchDateRangeTo\":0,\"ExcludeIntercompanyTransaction\":false,\"NearMatchToleranceDocumentValueFrom\":0.00,\"NearMatchToleranceDocumentValueTo\":0.00,\"NearMatchToleranceTaxableValueFrom\":0.00,\"NearMatchToleranceTaxableValueTo\":0.00,\"NearMatchToleranceTaxAmountsFrom\":0.00,\"NearMatchToleranceTaxAmountsTo\":0.00,\"IsDiscardOriginalsWithAmendment\":false,\"FinancialYear\":202425,\"FilingExtendedDate\":\"2025-11-30T00:00:00\",\"IsNearMatchDateRestriction\":false,\"IsRegeneratePreference\":false,\"IsExcludeCpNotFiledData\":false,\"IsMismatchIfDocNumberDifferentAfterAmendment\":false,\"AdvanceNearMatchPoweredByAI\":false,\"IsNearMatchTolerance\":false,\"IsRegeneratePreferenceAction\":false,\"IsRegeneratePreference3bClaimedMonth\":false,\"NearMatchCancelledInvoiceIdentification\":false,\"NearMatchCancelledInvoiceToleranceFrom\":0.00,\"NearMatchCancelledInvoiceToleranceTo\":0.00,\"IsRegeneratePreferenceSectionChange\":false,\"IsNearMatchShortCaseIdentification\":false,\"NearMatchShortCaseToleranceFrom\":0.00,\"NearMatchShortCaseToleranceTo\":0.00}]";

    private static final String params = "[{\"ReconciliationSectionTypePrOnly\":1,\"ReconciliationSectionTypeGstOnly\":2,\"ReconciliationSectionTypeMatched\":3,\"ReconciliationSectionTypeMatchedDueToTolerance\":4,\"ReconciliationSectionTypeMisMatched\":5,\"ReconciliationSectionTypeNearMatched\":6,\"ReconciliationSectionTypePrExcluded\":7,\"ReconciliationSectionTypeGstExcluded\":8,\"ReconciliationSectionTypePrDiscarded\":9,\"ReconciliationSectionTypeGstDiscarded\":10,\"ReconciliationMappingTypeYearly\":2,\"ReconciliationMappingTypeMonthly\":1,\"ReconciliationMappingTypeExtended\":3,\"ReconciliationMappingTypeTillDate\":4,\"ReconciliationMappingTypeDocumentYearlyTillDate\":5,\"ReconciliationMappingTypeReturnPeriodTillDate\":7,\"SourceTypeCounterPartyNotFiled\":2,\"ItcEligibilityIneligible\":4,\"ItcEligibilityNone\":-1,\"ReconciliationTypeGstr2a\":2,\"ReconciliationTypeIcegate\":5,\"DocumentTypeINV\":1,\"DocumentTypeCRN\":2,\"DocumentTypeDBN\":3,\"DocumentTypeBOE\":4,\"NotificationSchedulerTypeRegular\":1,\"NotificationSchedulerTypeAsSoonAsReconcile\":2,\"NotificationStatusTypeSent\":3,\"NotificationStatusTypeReplyPartiallyReceived\":4,\"NotificationStatusTypeReplyReceived\":5,\"ContactTypeBillFrom\":1,\"AmendmentTypeOriginal\":1,\"AmendmentTypeOriginalAmended\":2,\"AmendmentTypeAmendment\":3,\"ReconciliationSectionTypePrOnlyItcDelayed\":27,\"ReconciliationTypeGstr2b\":8,\"ModuleTypeOregularPurchase\":10,\"PushToGstStatusUploadedButNotPushed\":1}]"; 

    public String getExecution(String functionName, LinkedHashMap<String, String> arguments){
        
        StringBuilder formattedSql = new StringBuilder();

        formattedSql.append("SELECT * FROM ").append(functionName).append("(\n");

        int count = 0;
        for(Map.Entry<String, String> entry : arguments.entrySet()){
            String paramName = entry.getKey();
            String paramType = entry.getValue();
            Object randomValue;
            // System.out.println("ParamName : "+paramName);
            if(isParamNameofTypes(paramName) && isParamVarchar(paramType)){
                randomValue = GetRandomValues.getRandomIntStringArray(4);
            } else if(isParamOfNames(paramName) && isParamVarchar(paramType)){
                randomValue = GetRandomValues.getRandomQuotesStringArray(4);
            }else if(paramName.toLowerCase().contains("_settings")) {
                randomValue = String.format("ARRAY(SELECT json_populate_recordset(null ::%s,'%s'))", paramType, settings);
            }else if(paramName.toLowerCase().contains("_params")) {
                randomValue = String.format("(SELECT json_populate_recordset(null ::%s,'%s'))", paramType, params);;
            }else {
                randomValue = GetRandomValues.getRandomValue(paramType);
            }
            // System.out.println("RandomValue : " + randomValue);
            formattedSql.append(paramName)
                        .append(" => ")
                        .append(randomValue)
                        .append("::")
                        .append(paramType);
            count++;
            if(count < arguments.size()){
                formattedSql.append(",\n");
            }
        }
        formattedSql.append(");");
        return formattedSql.toString();
    }

    private static boolean isParamOfNames(String param){
        if(param.toLowerCase().contains("names\"")){
            return true;
        }else if(param.toLowerCase().contains("numbers\"")){
            return true;
        }else if(param.toLowerCase().contains("gstins\"")){
            return true;
        }else if(param.toLowerCase().contains("pans\"")){
            return true;
        }else{
            return false;
        }
    }

    private static boolean isParamNameofTypes(String param){
    
        if(param.toLowerCase().contains("types\"") | param.toLowerCase().contains("type\"")){
            return true;
        } else if (param.toLowerCase().contains("status")){
            return true;
        }else if (param.toLowerCase().contains("section")){
            return true;
        }else if (param.toLowerCase().contains("actions\"")){
            return true;
        }else{
            return false;
        }
    }

    private static boolean isParamVarchar(String type){
        return type.toLowerCase().contains("character varying");
    }

}
