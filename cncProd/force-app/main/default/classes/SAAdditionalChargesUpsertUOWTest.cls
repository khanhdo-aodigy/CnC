@isTest
private class SAAdditionalChargesUpsertUOWTest {
	@isTest
    private static void test() {
        SAAdditionalChargesUpsertUOW uow = new SAAdditionalChargesUpsertUOW();
        uow.registerSAAdditionalCharge(new SA_Additional_Charge__c());
        uow.registerSAAdditionalCharge(new list<SA_Additional_Charge__c> {new SA_Additional_Charge__c()});
        uow.doWork();
        
        // assert
        list<SA_Additional_Charge__c> o = [SELECT id FROM SA_Additional_Charge__c];
        system.assertEquals(2, o.size());
    }
}