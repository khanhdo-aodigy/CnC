@isTest
private class StockVehicleMasterSelectorTest {
	@testSetup
    static void setUp() {
        // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Rate_Master__c modelRateMaster = new Model_Rate_Master__c(Model_Master__c = modelCode.Id,
                                                                       	MRM_MYM_FRNCD__c = 'KIAPC');
        insert modelRateMaster;
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        Vehicle_Master2__c vhMaster = Test_DataFactory.createVehicleMaster2(false, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id, '0119-5047522', 'KIAPC0120190059');
        vhMaster.ProductionMonth__c = Date.newInstance(2019, 01, 01);
        insert vhMaster;
    }

    @isTest
    static void Test_selectStockVehicleMastersBySystemCommcases() {
        StockVehicleMasterSelector svmSelector = new StockVehicleMasterSelector();
        List<Vehicle_Master2__c> vhMasters = svmSelector.selectStockVehicleMastersBySystemCommcases(new Set<String>{'KIAPC0120190059'});

        System.assertEquals(1, vhMasters.size());
    }
}