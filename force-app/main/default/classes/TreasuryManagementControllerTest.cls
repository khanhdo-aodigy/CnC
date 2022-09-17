@isTest
private class TreasuryManagementControllerTest {
    @testSetup
    static void setUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        
        Date productionMonth = Date.newInstance(2019, 08, 01);  

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        

        // Create Purchase Order
		Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC', Production_Month__c = productionMonth);
        insert po;
        
        // create PO
        Vehicle_Purchase_Order__c order = new Vehicle_Purchase_Order__c(
            Franchise_Code__c = 'CITPC',
            Production_Month__c = productionMonth,
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD'
        );
        insert order;

        // create PO
        Vehicle_Purchase_Order__c order2 = new Vehicle_Purchase_Order__c(
            Franchise_Code__c = 'KIAPC',
            Production_Month__c = productionMonth,
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD',
            Stage__c = 'Closed'
        );
        insert order2;

        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            FOB_Gain_Loss__c = 0,
                                                            Duty_Gain_Loss__c = 0,
                                                            Purchase_Order__c = po.Id);
        insert vMaster;

        Vehicle_Master2__c vMaster2 = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190087', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190087', 
                                                            Engine_No__c = 'ENGINE279832',
                                                            Chassis__c = 'CHAS279832', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            Purchase_Order__c = po.Id,
                                                            FOB_Gain_Loss__c = 0,
                                                            Duty_Gain_Loss__c = 0,
                                                            Vehicle_Purchase_Order__c = order.Id);
        insert vMaster2;

        Vehicle_Master2__c vMaster3 = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190088', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190088', 
                                                            Engine_No__c = 'ENGINE279833',
                                                            Chassis__c = 'CHAS279833', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            Purchase_Order__c = po.Id,
                                                            FOB_Gain_Loss__c = 0,
                                                            Duty_Gain_Loss__c = 0,
                                                            Vehicle_Purchase_Order__c = order2.Id);
        insert vMaster3;
        
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

        // Forward_FOB_Contract_Line_Item__c fobItem2 = new Forward_FOB_Contract_Line_Item__c(Forward_FOB_Contract__c = fobContract.Id,
        //                                                                                   Stock_Vehicle_Master__c = vMaster.Id);
        // insert fobItem2;

        Forward_Duty_Contract__c dutyContract = new Forward_Duty_Contract__c(Status__c = 'Active',
                                                                             Cover_Percentage__c = 75,
                                                                             Spot_Rate__c = 1.2345663,
                                                                             Premium_Discount__c = 1.1,
                                                                             Purchase_Order__c = po.Id);
        insert dutyContract;

        Duty_Additional_Contract__c addnlDutyContract = new Duty_Additional_Contract__c(Forward_Duty_Contract__c = dutyContract.Id,
                                                                                        Status__c = 'Forward Contract Sell');
        insert addnlDutyContract;
        Forward_Duty_Contract_Line_Item__c dutyItem = new Forward_Duty_Contract_Line_Item__c(Forward_Duty_Contract__c = dutyContract.Id,
                                                                                         	Duty_Additional_Contract__c = addnlDutyContract.Id,
                                                                                            Stock_Vehicle_Master__c = vMaster.Id);
        insert dutyItem;
    }

    //treasuryManagement_FC
    @isTest
    static void construcDataTable_FOBContractLineItem_Test(){
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];
        String  selectFieldsNm  = 'Name,Stock_Vehicle_Master__r.Name,FOB_Additional_Contract__r.Name,Vehicle_Status__c,ETA_Date__c,Estimated_FOB__c,FOB_Amount__c,Cover_Amount_Foreign__c,Balance_to_Cover__c,Status__c';
        String targetObjNm = 'Forward_FOB_Contract_Line_Item__c';
        Test.startTest();
        try{
            TreasuryManagementController.construcDataTable(fobContract.Id, targetObjNm, selectFieldsNm, 10, null, '');
        }catch(Exception e){

        }
        
        Test.stopTest();
    }

    //treasuryManagement_FC
    @isTest
    static void construcDataTable_DutyContractLineItem_Test(){
        Forward_Duty_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c];
        Forward_Duty_Contract_Line_Item__c fobItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c
                                                     FROM Forward_Duty_Contract_Line_Item__c 
                                                     WHERE Forward_Duty_Contract__c =: fobContract.Id];
        String  selectFieldsNm  = 'Name,Stock_Vehicle_Master__r.Name,FOB_Additional_Contract__r.Name,Vehicle_Status__c,ETA_Date__c,Estimated_FOB__c,FOB_Amount__c,Cover_Amount_Foreign__c,Balance_to_Cover__c,Status__c';
        String targetObjNm = 'Forward_Duty_Contract_Line_Item__c';
        Test.startTest();
        try{
            TreasuryManagementController.construcDataTable(fobContract.Id, targetObjNm, selectFieldsNm, 10, null, '');
        }catch(Exception e){

        }
        
        Test.stopTest();
    }

    //treasuryManagement_PO
    @isTest
    static void construcDataTable_PurchaseOrder_Test(){
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
        Vehicle_Master2__c vm2 = [SELECT ID FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190086'];
        String  selectFieldsNm  = 'Name,Stock_Vehicle_Master__r.Name,Duty_Additional_Contract__r.Name,Vehicle_Status__c,Duty_Payment_Date__c,Estimated_Duty__c,Duty_Amount__c,Cover_Amount_Foreign__c,Status__c';
        String targetObjNm = 'Vehicle_Master2__c';
        Test.startTest();
        try{
            TreasuryManagementController.construcDataTable(po.Id, targetObjNm, selectFieldsNm, 10, null, '');
        }catch(Exception e){

        }
        
        Test.stopTest();
    }

    //treasuryManagement_FC
    @isTest
    static void getRecordsByIds(){
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];
        String objNm = 'Forward_FOB_Contract__c';
        List<String> selectFields = new List<String>{'Forward_Contract_Buy_Approved__c','Spot_Rate__c','Status__c'};
        Test.startTest();
        TreasuryManagementController.getRecordsByIds(objNm, selectFields, 'Id', New List<String>{fobItem.Id});
        Test.stopTest();
    }

    //treasuryManagement_PO
    @isTest
    static void processBuyContract_Test(){
        Map<String, String> buyContractInfo = new Map<String, String>();
        buyContractInfo.put('Bank_Contract_No__c', '1223');
        buyContractInfo.put('Currency_Code__c', 'USD');
        buyContractInfo.put('Bank__c', 'USDAC - USD Account');
        buyContractInfo.put('Maturity_Date__c', '2022-09-30');
        buyContractInfo.put('Effective_Date__c', '2022-09-05');
        buyContractInfo.put('Bank_Contract_Amount__c', '18750');
        buyContractInfo.put('Spot_Rate__c', '1.39');
        buyContractInfo.put('Premium_Discount__c', '-0.02');
        buyContractInfo.put('Remarks__c', '');
        buyContractInfo.put('Cover_Percentage__c', '50');

        String buyContractObjAPI = 'Forward_FOB_Contract__c';
        String lineItemObjAPI = 'Forward_FOB_Contract_Line_Item__c';
        Vehicle_Master2__c vm2 = [SELECT ID FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190087'];
        Test.startTest();
        try {
            TreasuryManagementController.processBuyContract(buyContractInfo , New List<String>{vm2.Id}, buyContractObjAPI, lineItemObjAPI);
        } catch (Exception e) {
            
        }
        
        Test.stopTest();
    }

    @isTest
    static void processBuyContract_Test_Duty(){
        Map<String, String> buyContractInfo = new Map<String, String>();
        buyContractInfo.put('Bank_Contract_No__c', '1223');
        buyContractInfo.put('Currency_Code__c', 'USD');
        buyContractInfo.put('Bank__c', 'USDAC - USD Account');
        buyContractInfo.put('Maturity_Date__c', '2022-09-30');
        buyContractInfo.put('Effective_Date__c', '2022-09-05');
        buyContractInfo.put('Bank_Contract_Amount__c', '18750');
        buyContractInfo.put('Spot_Rate__c', '1.39');
        buyContractInfo.put('Premium_Discount__c', '-0.02');
        buyContractInfo.put('Remarks__c', '');
        buyContractInfo.put('Cover_Percentage__c', '50');

        String buyContractObjAPI = 'Forward_Duty_Contract__c';
        String lineItemObjAPI = 'Forward_Duty_Contract_Line_Item__c';
        Vehicle_Master2__c vm2 = [SELECT ID FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190087'];
        Test.startTest();
        try {
            TreasuryManagementController.processBuyContract(buyContractInfo , New List<String>{vm2.Id}, buyContractObjAPI, lineItemObjAPI);
        } catch (Exception e) {
            
        }
        
        Test.stopTest();
    }

    //treasuryManagement_FC
    @isTest
    static void processAddnlContract_Test(){
        String lineItemObjAPI = 'Forward_FOB_Contract_Line_Item__c';
        Map<String, String> addnlContractInfo = new Map<String, String>();
        addnlContractInfo.put('Status__c', 'Forward Contract Sell');
        addnlContractInfo.put('Bank_Contract_No_Sell_Execute__c', '8765432');
        addnlContractInfo.put('Effective_Date_Sell_Execute__c', '2022-08-30');
        addnlContractInfo.put('Transaction_Date_Sell_Execute__c', '2022-08-30');
        addnlContractInfo.put('Spot_Rate_Sell_Execute__c', '1.38');

        Forward_FOB_Contract__c fobContract = [SELECT ID FROM Forward_FOB_Contract__c];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];

        Test.startTest();
        TreasuryManagementController.processAddnlContract(addnlContractInfo, New List<String>{fobItem.Id}, lineItemObjAPI, fobContract.Id);
        Test.stopTest();
    }

    @isTest
    static void calculateGainLoss_Test(){
        Forward_FOB_Contract__c fobContract = [SELECT ID FROM Forward_FOB_Contract__c];
        Vehicle_Master2__c vMaster = [SELECT ID, FOB_Gain_Loss__c, Duty_Gain_Loss__c FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190087'];

        FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                     Status__c = 'PO Cancellation');
        insert addnlFOBContract;
        Forward_FOB_Contract_Line_Item__c fobItem = new Forward_FOB_Contract_Line_Item__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                          FOB_Additional_Contract__c = addnlFOBContract.Id,
                                                                                          Stock_Vehicle_Master__c = vMaster.Id);
        insert fobItem;
        fobItem = [SELECT Id, Status__c, Gain_Loss__c FROM Forward_FOB_Contract_Line_Item__c WHERE FOB_Additional_Contract__c = :addnlFOBContract.Id];
        Test.startTest();
        TreasuryManagementController.calculateGainLoss(new Set<String>{vMaster.Id}, 'Forward_FOB_Contract_Line_Item__c', 'FOB_Additional_Contract__c');
        Test.stopTest();
    }

    @isTest
    static void processAddnlContract_Test_Duty(){
        String lineItemObjAPI = 'Forward_Duty_Contract_Line_Item__c';
        Map<String, String> addnlContractInfo = new Map<String, String>();
        addnlContractInfo.put('Status__c', 'Forward Contract Sell');
        addnlContractInfo.put('Bank_Contract_No_Sell_Execute__c', '8765432');
        addnlContractInfo.put('Effective_Date_Sell_Execute__c', '2022-08-30');
        addnlContractInfo.put('Transaction_Date_Sell_Execute__c', '2022-08-30');
        addnlContractInfo.put('Spot_Rate_Sell_Execute__c', '1.38');

        Forward_Duty_Contract__c dutyContract = [SELECT ID FROM Forward_Duty_Contract__c];
        Forward_Duty_Contract_Line_Item__c dutyItem = [SELECT ID
                                                     FROM Forward_Duty_Contract_Line_Item__c 
                                                     WHERE Forward_Duty_Contract__c =: dutyContract.Id];

        Test.startTest();
        TreasuryManagementController.processAddnlContract(addnlContractInfo, New List<String>{dutyItem.Id}, lineItemObjAPI, dutyContract.Id);
        Test.stopTest();
    }

    @isTest
    static void reCalculateAmounts_Test(){
        Forward_FOB_Contract__c fobContract = [SELECT ID FROM Forward_FOB_Contract__c];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];
                                                     
        Test.startTest();
        TreasuryManagementController.reCalculateAmounts(addnlContract.Id);
        Test.stopTest();
    }

    //treasuryManagement_PO
    @isTest
    static void validateBuyContract_Test(){
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
        String buyContractObjAPI = 'Forward_FOB_Contract__c';
        Test.startTest();
        TreasuryManagementController.validateBuyContract(po.Id, buyContractObjAPI);
        Test.stopTest();
    }

    @isTest
    static void searchVehiclePurchaseOrder_Test(){
        Date productionMonth = Date.newInstance(2019, 08, 01);
        Vehicle_Purchase_Order__c vpo = [SELECT Id, Production_Month__c, Franchise_Code__c FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'KIAPC'];
        Test.startTest();
        List<Vehicle_Purchase_Order__c> vpoList = TreasuryManagementController.searchVehiclePurchaseOrder(vpo.Franchise_Code__c, productionMonth);
        System.assertEquals(vpo.Id, vpoList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void createTMSPurchaseOrder_Test(){
        Vehicle_Purchase_Order__c vpo = [SELECT Id FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'CITPC'];
        Test.startTest();
        TreasuryManagementController.createTMSPurchaseOrder(New List<Id>{vpo.Id});
        Vehicle_Purchase_Order__c vpo2 = [SELECT Id, TMS_Purchase_Order__c FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'CITPC'];
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c WHERE Franchise__c = 'CITPC'];
        system.assertEquals(po.Id, vpo2.TMS_Purchase_Order__c);
        Test.stopTest();
    }

    @isTest
    static void searchTMSPOGroup_Test(){
        Purchase_Order__c po = [SELECT ID, Franchise__c, Production_Month__c FROM Purchase_Order__c];
        Test.startTest();
        TreasuryManagementController.searchTMSPOGroup(po.Franchise__c, po.Production_Month__c);
        Test.stopTest();
    }
}