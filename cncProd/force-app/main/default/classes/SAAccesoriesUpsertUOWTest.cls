@isTest
private class SAAccesoriesUpsertUOWTest {
	@isTest
    private static void test() {
        SAAccesoriesUpsertUOW uow = new SAAccesoriesUpsertUOW();
        uow.registerSAAccessories(new SA_Accessory__c());
        uow.registerSAAccessories(new list<SA_Accessory__c> {new SA_Accessory__c()});
        uow.doWork();
        
        // assert
        list<SA_Accessory__c> o = [SELECT id FROM SA_Accessory__c];
        system.assertEquals(2, o.size());
    }
}