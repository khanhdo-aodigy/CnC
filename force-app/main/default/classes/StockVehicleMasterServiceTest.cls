/*==========================================================================================================================================================================
 * Test service class for Stock Vehicle Master Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           8 Sep 2022                       nam@aodigy.com                                                                               init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class StockVehicleMasterServiceTest {
    @TestSetup
    static void makeData(){
        // Create model master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        
        // create model year master
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        
        // create color master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        
        // create trim master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        // create stock vehicle master
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            Duty_Payment_Date__c = Date.today());
        insert vMaster;
        
    }
    @IsTest
    private static void selectStockVehicleMastersForDutyRequest_success()
    {
        List<Vehicle_Master2__c> svms = [SELECT Id FROM Vehicle_Master2__c];
        StockVehicleMasterSelector sel = new StockVehicleMasterSelector();
        StockVehicleMasterService.selectStockVehicleMastersForDutyRequest();
    }
    
    @IsTest
    private static void selectByIds_success()
    {
        List<Vehicle_Master2__c> svms = [SELECT Id FROM Vehicle_Master2__c];
        StockVehicleMasterSelector sel = new StockVehicleMasterSelector();
        List<String> vehiclemasterIds = new List<String>();
        StockVehicleMasterService.selectByIds(vehiclemasterIds);

    }

    @IsTest
    private static void selectStockVehicleMastersByInvoiceIds_success()
    {
        List<Vehicle_Master2__c> svms = [SELECT Id FROM Vehicle_Master2__c];
        StockVehicleMasterSelector sel = new StockVehicleMasterSelector();
        Set<Id> invoiceIds = new Set<Id>();
        StockVehicleMasterService.selectStockVehicleMastersByInvoiceIds(invoiceIds);

    }
}