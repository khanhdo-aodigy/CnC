/*==========================================================================================================================================================================
 * Test class for Stock Vehicle Master entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          7 Sep 2022                       trung@aodigy.com    
 *         14 Sep 2022                       nam@aodigy.com                                                                                 init
 *         30 Sep 2022                       quy.tan@aodigy.com                         US-WMS-000004                                       selectStockVehicleMastersByVehicleShipment_success
 * ========================================================================================================================================================================== 
 */
@isTest
private class StockVehicleMasterSelectorTest {
    @testSetup
    static void setUp() {
        // create supplier account
        //Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //create Vehicle shipment
        //Vehicle_Shipment__c vehicleShipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);
        // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Rate_Master__c modelRateMaster = new Model_Rate_Master__c(Model_Master__c = modelCode.Id
                                                                        );
        insert modelRateMaster;
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC');
        insert po;
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
                                                            Duty_Payment_Date__c = Date.today(),
                                                            // Vehicle_Shipment__c = vehicleShipment.id,
                                                            Purchase_Order__c = po.Id);
        insert vMaster;
         Forward_FOB_Contract__c fobContract = new Forward_FOB_Contract__c(Status__c = 'Active',
                                                                          Cover_Percentage__c = 75,
                                                                          Spot_Rate__c = 1.2345663,
                                                                          Premium_Discount__c = 1.1,
                                                                          Purchase_Order__c = po.Id);
         insert fobContract;

         FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                      Status__c = 'Forward Contract Sell');
         insert addnlFOBContract;

         Forward_FOB_Contract_Line_Item__c fobItem = new Forward_FOB_Contract_Line_Item__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                           FOB_Additional_Contract__c = addnlFOBContract.Id,
                                                                                           Stock_Vehicle_Master__c = vMaster.Id);
         insert fobItem;
    }

     @isTest
     static void Test_selectStockVehicleMastersBySystemCommcases() {
         StockVehicleMasterSelector svmSelector = new StockVehicleMasterSelector();
         List<Vehicle_Master2__c> vhMasters = svmSelector.selectStockVehicleMastersBySystemCommcases(new Set<String>{'KIAPC0120190086'});

         System.assertEquals(1, vhMasters.size());
     }

     @isTest
     static void selectRecordsByForUpdateER_Test(){
         Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c LIMIT 1];
         Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID
                                                      FROM Forward_FOB_Contract_Line_Item__c 
                                                      WHERE Forward_FOB_Contract__c =: fobContract.Id];
         StockVehicleMasterSelector svms = new StockVehicleMasterSelector();
         svms.selectRecordsByForUpdateER(new List<Id>{fobItem.Id});
     }

    @isTest
    static void getRecordsByIds_Test(){
        Vehicle_Master2__c vm2 = [SELECT Id FROM Vehicle_Master2__c];
        StockVehicleMasterSelector svms = new StockVehicleMasterSelector();
        svms.getRecordsByIds(new List<Id>{vm2.Id});
    }

    @isTest
    static void getStockVehicleMastersForDutyRequest_Test(){
        Vehicle_Master2__c vm2 = [SELECT Id, Duty_Payment_Date__c  FROM Vehicle_Master2__c];
        StockVehicleMasterSelector svms = new StockVehicleMasterSelector();
        svms.getStockVehicleMastersForDutyRequest();
    }

    @isTest
    static void getStockVehicleMastersByInvoiceIds_success(){
        Vehicle_Master2__c vm2 = [SELECT Id,Inward_Declaration_Invoice__c   FROM Vehicle_Master2__c];
        StockVehicleMasterSelector svms = new StockVehicleMasterSelector();
        svms.getStockVehicleMastersByInvoiceIds(new Set<Id>{vm2.Id});
    }

    // @isTest
    // static void selectStockVehicleMastersByVehicleShipment_success(){
    //     Vehicle_Shipment__c vm = [SELECT Id FROM Vehicle_Shipment__c LIMIT 1];
    //     StockVehicleMasterSelector svms = new StockVehicleMasterSelector();
    //     svms.selectStockVehicleMastersByVehicleShipment(vm.id);
    // }
}