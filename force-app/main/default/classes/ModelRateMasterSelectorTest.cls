@isTest
private class ModelRateMasterSelectorTest {
    @testSetup
    static void setUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Rate_Master__c modelRateMaster = new Model_Rate_Master__c(MRM_SECOMM__c = 100,
                                                                        MRM_DEALERMARGIN__c = 200,
                                                                        MRM_EFFDT__c = Date.today(),
                                                                        Model_Master__c = modelCode.Id);
        insert modelRateMaster;
    }
    
    @isTest
    static void testSelectModelRateMasterByModelMasterId() {
        Model_Master__c modelMater = [Select Id from Model_Master__c];
        ModelRateMasterSelector mRMSel = new ModelRateMasterSelector();
        List<Model_Rate_Master__c> modelRateMaster = mRMSel.selectModelRateMasterByModelMasterId(modelMater.Id);
        System.assertEquals(1, modelRateMaster.size());
    }
}