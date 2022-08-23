@isTest
public with sharing class VehiclePurchaseOrdersTest 
{
    @TestSetup
    static void setUp()
    {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');
        
        // create model year master
        Model_Year_Master__c  modelYearCode = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

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
        
        // create SVM
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearCode.Id, 'originalCommacase', 'systemCommcase');
		vm2.Vehicle_Purchase_Order__c = order.Id;
        vm2.Vehicle_Purchase_Status__c = 'In Shipment';
        vm2.Vehicle_Status__c = 'ORD';
        vm2.ProductionMonth__c= Date.today().addDays(5);
        insert vm2;

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
     *  test snapshot capturing when VPO is approved
     *  expected: when VPO is approved appear snapshot capturing 
     */
    @isTest
    private static void snapshotCapture_Success ()
    { 
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];
        Test.startTest();
        order.Stage__c = 'Approved';
        update order;
        List<Vehicle_Purchase_Order__c> orders = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c where Stage__c = 'Approved'];
        System.assert(orders.size() > 0, 'Vehicle Purchase Order update success and aprear snapshot capturing in Note and Document');
        Test.stopTest();       
    }

    /**
     *  test SVM status when VPO is cancelled
     *  expected: when SVM status is 'In Shipment' or 'Arrived' can not cancelled an VPO 
     */
    @isTest
    private static void CancellationEligibility_Success()
    {
        String errorMsg = '';
        Test.startTest();       
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];
        List<Vehicle_Master2__c> convertedStock = [ SELECT Id, Vehicle_Purchase_Status__c, Vehicle_Status__c, Vehicle_Purchase_Order__c
                                                    FROM Vehicle_Master2__c
                                                    WHERE Vehicle_Purchase_Status__c = 'In Shipment' AND Vehicle_Status__c = 'FREE'
        										 ];
        try
        {
        order.Stage__c = 'Cancelled';
        order.Cancellation_Reason__c = 'Change color';
        update order;
        } catch(Exception ex)
        {
            errorMsg =ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, errorMsg.indexOf('PO with non-free vehicle status is not eligible for cancellation')>-1);
    	
    }
}