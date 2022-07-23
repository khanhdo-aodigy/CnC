@isTest
private class CommcaseServiceTest {

    @testSetup
    static void setUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id); 
		Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(true, 'CCK', 'NO9999', stockReservation.Id, 'test customer');  
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(
            false, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id, 'originalCommacase', 'systemCommcase'
        );
        vm.ProductionMonth__c = System.today();
        insert vm;        
    }
    
    @isTest
    static void Test_updateVehicleMaster() {
        CommcaseService.updateVehicleMaster(new Map<Id, String>{[Select Id From Stock_Reservation__c].Id => 'systemCommcase'});
        System.assertEquals(
        	[Select Id From Vehicle_Master2__c].Id, [Select Vehicle_Master__c From Stock_Reservation__c].Vehicle_Master__c
        );
    }
}