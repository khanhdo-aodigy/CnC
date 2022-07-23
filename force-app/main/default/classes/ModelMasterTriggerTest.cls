@isTest
private class ModelMasterTriggerTest {

    @isTest
    static void Test_onApplyDefaults() {
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(false, 'model name');
        modelMaster.Franchise_Code__c = 'MITPC';
        insert modelMaster;
        
        System.assertEquals(
            'MITPCmodel name', [Select VSMS_Compound_Primary_Key__c From Model_Master__c].VSMS_Compound_Primary_Key__c
        ); 
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Model_Master__c', true);
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(false, 'model name');
        modelMaster.Franchise_Code__c = 'MITPC';
        insert modelMaster;
        TriggerExclusion.excludeTrigger('Model_Master__c', false);
    }
}