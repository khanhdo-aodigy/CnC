@isTest
private class AccsRateMasterTriggerTest {
    
    @isTest
    static void Test_recalculateAccessoriesMasterRate() {
        Accessories_Master__c accessoriesMaster = Test_DataFactory.createAccessoriesMaster(true);
        Accs_Rate_Master__c earlierAccsRateMaster = Test_DataFactory.createAccsRateMaster(true, accessoriesMaster.Id, System.today(), 100);
		Accs_Rate_Master__c latestAccsRateMaster = Test_DataFactory.createAccsRateMaster(true, accessoriesMaster.Id, System.today() + 1, 200);       
        
        System.assertEquals(200, [Select Rate__c From Accessories_Master__c].Rate__c);
        
        List<Accs_Rate_Master__c> accsRateMasters = new List<Accs_Rate_Master__c>();
        earlierAccsRateMaster.ARM_SALEPRICE__c = 1000;
        earlierAccsRateMaster.ARM_EFFDT__c = System.today() + 2;
        accsRateMasters.add(earlierAccsRateMaster);
        
        latestAccsRateMaster.ARM_SALEPRICE__c = 1200;
        accsRateMasters.add(latestAccsRateMaster);
        
        update accsRateMasters;
        System.assertEquals(1000, [Select Rate__c From Accessories_Master__c].Rate__c);
        
        delete earlierAccsRateMaster;
        System.assertEquals(1200, [Select Rate__c From Accessories_Master__c].Rate__c);
	} 

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Accs_Rate_Master__c', true);
        Accessories_Master__c accessoriesMaster = Test_DataFactory.createAccessoriesMaster(true);
        Accs_Rate_Master__c earlierAccsRateMaster = Test_DataFactory.createAccsRateMaster(true, accessoriesMaster.Id, System.today(), 100);
        List<Accs_Rate_Master__c> accsRateMasters = new List<Accs_Rate_Master__c>();
        earlierAccsRateMaster.ARM_SALEPRICE__c = 1000;
        earlierAccsRateMaster.ARM_EFFDT__c = System.today() + 2;
        accsRateMasters.add(earlierAccsRateMaster);
        update accsRateMasters;
        TriggerExclusion.excludeTrigger('Accs_Rate_Master__c', false);
    }
}