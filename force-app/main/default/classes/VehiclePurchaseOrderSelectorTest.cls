@IsTest
private class VehiclePurchaseOrderSelectorTest
{
    @TestSetup
    private static void makeData()
    {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');

        // create model color trim master
        Model_Color_Trim_Master__c modelColorTrimMaster = new Model_Color_Trim_Master__c(
            Name = 'Model Color Trim Master',
            Branch_Code__c = 'KIA',
            Franchise_Code__c = 'KIAPC',
            Model_Code__c = modelMaster.Id,
            Color_Code__c = colorMaster.Id,
            Trim_Code__c = trimMaster.Id
        );
        insert modelColorTrimMaster;

        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        // create PO
        Vehicle_Purchase_Order__c order = new Vehicle_Purchase_Order__c(
            Franchise_Code__c = 'KIAPC',
            Production_Month__c = Date.today(),
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD'
        );
        insert order;

        Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC');
        insert po;

        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearMaster.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelMaster.ID, 
                                                            ProductionMonth__c = Date.today(),
                                                            Color_Code__c = colorMaster.ID, 
                                                            Trim_Code__c = trimMaster.ID,
                                                            Purchase_Order__c = po.Id);
        insert vMaster;

        // create POLIs
        final Integer POLI_NO = 10;

        List<Vehicle_Purchase_Order_Line_Items__c> polis = new List<Vehicle_Purchase_Order_Line_Items__c>();

        for (Integer i = 0; i < POLI_NO; i++)
        {
            polis.add(new Vehicle_Purchase_Order_Line_Items__c(
                Vehicle_Purchase_Order__c = order.Id,
                Model_Master__c = modelMaster.Id,
                Color_Master__c = colorMaster.Id,
                Trim_Master__c = trimMaster.Id,
                Model_Color_Trim_Master__c = modelColorTrimMaster.Id,
                Model_Year_Master__c = modelYearMaster.Id,
                Units_Ordered__c = 5
            ));
        }

        insert polis;
    }

    /**
     * Get VPO together with VPOLI via correct VPO Id
     * Expected: correct VPO retrieved together with all related VPOLI
     */
    @IsTest
    private static void getOrderWithLineItems_success()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c];

        VehiclePurchaseOrderSelector selector = new VehiclePurchaseOrderSelector();

        List<Vehicle_Purchase_Order__c> result = selector.selectByIdsWithLineItems(new Set<Id> {order.Id});

        // result should contain 1 order
        System.assert(result.size() == 1, 'Actual result size: ' + result.size());

        // result should retrieve correct order
        System.assert(result.get(0).Id == order.Id, 'Incorrect order retrieved: ' + result.get(0).Id);

        // result should retrieve all PO's line items
        System.assert(result.get(0).Vehicle_Purchase_Order_Line_Items__r.size() == 10, 'Actual POLI size: ' + result.get(0).Vehicle_Purchase_Order_Line_Items__r.size());
    }

    /**
     * Get VPO together with VPOLI via invalid VPO Id
     * Expected: no PO retrieved
     */
    @IsTest
    private static void getOrderWithLineItems_invalidId()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, CreatedById FROM Vehicle_Purchase_Order__c];

        VehiclePurchaseOrderSelector selector = new VehiclePurchaseOrderSelector();

        List<Vehicle_Purchase_Order__c> result = selector.selectByIdsWithLineItems(new Set<Id> {order.CreatedById});

        // result should contain 1 order
        System.assert(result.size() == 0, 'Actual result size: ' + result.size());
    }

    /**
     * Get VPO together with VPOLI via correct VPO Id but PO contains no POLO
     * Expected: correct VPO retrieved together no POLI
     */
    @IsTest
    private static void getOrderWithLineItems_noPOLI()
    {
        // delete all POLIs
        delete [SELECT Id FROM Vehicle_Purchase_Order_Line_Items__c];

        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c];

        VehiclePurchaseOrderSelector selector = new VehiclePurchaseOrderSelector();

        List<Vehicle_Purchase_Order__c> result = selector.selectByIdsWithLineItems(new Set<Id> {order.Id});

        // result should contain 1 order
        System.assert(result.size() == 1, 'Actual result size: ' + result.size());

        // result should retrieve correct order
        System.assert(result.get(0).Id == order.Id, 'Incorrect order retrieved: ' + result.get(0).Id);

        // result should retrieve all PO's line items
        System.assert(result.get(0).Vehicle_Purchase_Order_Line_Items__r.size() == 0, 'Actual POLI size: ' + result.get(0).Vehicle_Purchase_Order_Line_Items__r.size());
    }

    @isTest
    static void selectVPObyFranchiseAndProductionMonth_Test(){
        Vehicle_Purchase_Order__c order = [SELECT Id, Franchise_Code__c, Production_Month__c FROM Vehicle_Purchase_Order__c];
        VehiclePurchaseOrderSelector vpos = new VehiclePurchaseOrderSelector();
        vpos.selectVPObyFranchiseAndProductionMonth(order.Franchise_Code__c, order.Production_Month__c);
    }

    @isTest
    static void selectVPO_WithRelatedSVM_Test(){
        Vehicle_Master2__c vMaster = [SELECT Id FROM Vehicle_Master2__c];
        VehiclePurchaseOrderSelector vpos = new VehiclePurchaseOrderSelector();
        vpos.selectVPO_WithRelatedSVM(new List<Id>{vMaster.Id});
    }

    @isTest
    static void getRecordsByPOIds_Test(){
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
        VehiclePurchaseOrderSelector vpos = new VehiclePurchaseOrderSelector();
        vpos.getRecordsByPOIds(new List<Id>{po.Id});
    }

    @isTest
    static void getRecordsBySVMIds_Test(){
        Vehicle_Master2__c vMaster = [SELECT Id FROM Vehicle_Master2__c];
        VehiclePurchaseOrderSelector vpos = new VehiclePurchaseOrderSelector();
        vpos.getRecordsBySVMIds(new Set<Id>{vMaster.Id});
    }
}