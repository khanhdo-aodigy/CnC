@isTest
private class AdditionalChargesMasterSelectorTest {
	@testSetUp
    private static void setUp() {
        Additional_Charges_Master__c addtnlChargeMasterSurcharge = new Additional_Charges_Master__c(ADM_CHRGCD__c = 'R001');
        insert addtnlChargeMasterSurcharge;
    }
    
    @isTest
    private static void test_1() {
        AdditionalChargesMasterSelector o = new AdditionalChargesMasterSelector();
        list<Additional_Charges_Master__c> results = o.selectBasedOnChargeCode(new list<string> {'R001'});
        system.assertEquals(1, results.size());
    }
    
    @isTest
    private static void test_2() {
        AdditionalChargesMasterSelector o = new AdditionalChargesMasterSelector();
        list<Additional_Charges_Master__c> results = o.selectBasedOnChargeCode(new list<string> {'R002'});
        system.assertEquals(0, results.size());
    }
}