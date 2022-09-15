@isTest
private class TMSPurchaseOrderSelectorTest {
    @TestSetup
    static void setUp(){
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');
        Date productionMonth = Date.newInstance(2022, 08, 01); 
        Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC', Production_Month__c = productionMonth);
        insert po;

        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            Purchase_Order__c = po.Id);
        insert vMaster;

        Forward_FOB_Contract__c fobContract = new Forward_FOB_Contract__c(Status__c = 'Active',
                                                                         Cover_Percentage__c = 75,
                                                                         Spot_Rate__c = 1.2345663,
                                                                         Premium_Discount__c = 1.1,
                                                                         Purchase_Order__c = po.Id);
        insert fobContract;

        Forward_Duty_Contract__c dutyContract = new Forward_Duty_Contract__c(Status__c = 'Active',
                                                                             Cover_Percentage__c = 75,
                                                                             Spot_Rate__c = 1.2345663,
                                                                             Premium_Discount__c = 1.1,
                                                                             Purchase_Order__c = po.Id);
        insert dutyContract;

        Vehicle_Purchase_Order__c vehiclePurchaseOrder = new Vehicle_Purchase_Order__c(Franchise_Code__c = 'KIAPC',
                                                                                       Production_Month__c = productionMonth,
                                                                                       Supplier_Account__c = supplier.Id,
                                                                                       Currency_Code__c = 'USD',
                                                                                       TMS_Purchase_Order__c = po.Id);

        insert vehiclePurchaseOrder;
    }
    
    @isTest
    static void selectTMSPObyFranchiseAndProductionMonth_Test(){
        Purchase_Order__c po = [SELECT ID, Franchise__c, Production_Month__c  FROM Purchase_Order__c];
        TMSPurchaseOrderSelector pos = new TMSPurchaseOrderSelector();
        pos.selectTMSPObyFranchiseAndProductionMonth(po.Franchise__c, po.Production_Month__c);
    }

    @isTest
    static void getRecordsByVPOIds_Test(){
        Vehicle_Purchase_Order__c vpo = [SELECT Id, TMS_Purchase_Order__c FROM Vehicle_Purchase_Order__c];
        TMSPurchaseOrderSelector pos = new TMSPurchaseOrderSelector();
        pos.getRecordsByVPOIds(new Set<Id>{vpo.TMS_Purchase_Order__c});
    }

    @isTest
    static void getRecordsBySVMIds_Test(){
        Vehicle_Master2__c vm2 = [SELECT Id, Purchase_Order__c FROM Vehicle_Master2__c];
        TMSPurchaseOrderSelector pos = new TMSPurchaseOrderSelector();
        pos.getRecordsBySVMIds(new Set<Id>{vm2.Purchase_Order__c});
    }
}