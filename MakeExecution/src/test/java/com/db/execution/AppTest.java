package com.db.execution;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import com.db.execution.function.GetFunctionName;


@SpringBootTest
class AppTest {

	@Test
	void contextLoads() {
	}

	@Test
    public void testGetFunctionName_WithValidInput() {
        String query = "SELECT * FROM \"oregular\".\"GenerateItcDashboardLiabilityComplianceReport\"";
        GetFunctionName app = new GetFunctionName();
        String functionName = app.getFunctionName(query);
        assertEquals("oregular.GenerateItcDashboardLiabilityComplianceReport", functionName);
    }

    @Test
    public void testGetFunctionName_WithDifferentSchema() {
        String query = "SELECT * FROM \"oregular\".\"GenerateItcDashboardLiabilityComplianceReport\"\r(\"_SubscriberId\"=>1236,\r\"_EntityIds\"=>[30895,30896,30071,36015,30079,141299,30080,36018,36017,143224,30070,36016,30078,30073,30076,36019,141175,30075,30077,30072,141176,30074,31391],\r\"_FinancialYear\"=>null,\r\"_PRReturnPeriods\"=>[42024,52024,62024,72024,82024],\r\"_Gstr2BReturnPeriods\"=>[],\r\"_TransactionTypeB2B\"=>1,\r\"_TransactionTypeB2C\"=>12,\r\"_TransactionTypeDE\"=>6,\r\"_TransactionTypeCBW\"=>25,\r\"_TransactionTypeEXPWP\"=>2,\r\"_TransactionTypeEXPWOP\"=>3,\r\"_TransactionTypeSEZWP\"=>4,\r\"_TransactionTypeSEZWOP\"=>5,\r\"_TransactionTypeIMPS\"=>8,\r\"_DocumentSummaryTypeGSTR1NIL\"=>5,\r\"_DocumentSummaryTypeGSTR1ADV\"=>3,\r\"_DocumentSummaryTypeGSTR1ADVAJ\"=>4,\r\"_DocumentSummaryTypeGSTR1B2CS\"=>2,\r\"_DocumentSummaryTypeGSTR1ECOM\"=>25,\r\"_DocumentSummaryTypeGSTR1SUPECO\"=>26,\r\"_DocumentTypeINV\"=>1,\r\"_DocumentTypeCRN\"=>2,\r\"_DocumentTypeDBN\"=>3,\r\"_ContactTypeBillFrom\"=>1,\r\"_ContactTypeBillTo\"=>3,\r\"_DocumentStatusActive\"=>1,\r\"_SourceTypeTaxpayer\"=>1,\r\"_SectTypeCDNUR\"=>2048,\r\"_GstActOrRuleSectionTypeGstAct95\"=>1);";
        GetFunctionName app = new GetFunctionName();
        String functionName = app.getFunctionName(query);
        assertEquals("oregular.GenerateItcDashboardLiabilityComplianceReport", functionName);
    }

    @Test
    public void testGetFunctionName_WithNoSchema() {
        String query = "SELECT * FROM \"FunctionWithoutSchema\"";
        GetFunctionName app = new GetFunctionName();
        assertThrows(IllegalArgumentException.class, () -> {
            app.getFunctionName(query);
        });
    }

    @Test
    public void testGetFunctionName_WithComplexQuery() {
        String query = "SELECT param1, param2 FROM \"complexSchema\".\"ComplexFunctionName\" WHERE param1 = 'value'";
        GetFunctionName app = new GetFunctionName();
        String functionName = app.getFunctionName(query);
        assertEquals("complexSchema.ComplexFunctionName", functionName);
    }

    @Test
    public void testGetFunctionName_WithEmptyString() {
        String query = "";
        GetFunctionName app = new GetFunctionName();
        assertThrows(IllegalArgumentException.class, () -> {
            app.getFunctionName(query);
        });
    }

    @Test
    public void testGetFunctionName_WithInvalidString() {
        String query = "SELECT * FROM table";
        GetFunctionName app = new GetFunctionName();
        assertThrows(IllegalArgumentException.class, () -> {
            app.getFunctionName(query);
        });
    }

}
