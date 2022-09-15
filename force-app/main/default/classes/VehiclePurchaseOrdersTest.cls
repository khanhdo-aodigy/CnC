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
            Currency_Code__c = 'USD',
            Stage__c = 'Manufacturer_Confirmed'
        );
        insert order;
        
        // create SVM
        // Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearCode.Id, 'originalCommacase', 'systemCommcase');
		// vm2.Vehicle_Purchase_Order__c = order.Id;
        // vm2.Vehicle_Purchase_Status__c = 'In Shipment';
        // vm2.Vehicle_Status__c = 'ORD';
        // vm2.ProductionMonth__c= Date.today().addDays(5);
        // insert vm2;

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
    @IsTest
    private static void snapshotCapture_Success()
    {
        // update vehicle purchase order status
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];
        order.Stage__c = 'Approved';
        update order;

        // assert whether vehicle purchase order status successfully updated
        Vehicle_Purchase_Order__c updatedOrder = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c WHERE Id = :order.Id];
        System.assert(updatedOrder.Stage__c == 'Approved', 'Actual stage: ' + updatedOrder.Stage__c);

        // assert snapshot txt is captured
        Attachment snapshot = [SELECT Id, Description FROM Attachment WHERE ParentId = :order.Id];
        System.assert(snapshot.Description == '#snapshot', 'Snapshot do not have correct tagging description');
    }

    /**
     *  Test closing PO with some converted stock are In Shipment
     *  Expected: PO is no eligible for closing
     */
    @IsTest
    private static void checkCancellationEligibility_InShipment()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // update POLI unit confirmed
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        // convert some stocks for testing
        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        // update some converted stock to 'In Shipment'
        List<Vehicle_Master2__c> convertedStocks = [SELECT Vehicle_Purchase_Status__c FROM Vehicle_Master2__c WHERE Vehicle_Purchase_Order__c = :order.Id LIMIT 3];

        for (Vehicle_Master2__c convertedStock : convertedStocks)
        {
            convertedStock.Vehicle_Purchase_Status__c = 'In Shipment';
        }

        update convertedStocks;

        try
        {
            order.Stage__c = 'Cancelled';
            order.Cancellation_Reason__c = 'Testing';
            update order;
        } catch(Exception e)
        {
            System.assert(e.getMessage().contains('PO with In Shipment or Arrived vehicle purchase status is not eligible for cancellation'), e.getMessage());
        }    	
    }

    /**
     *  Test closing PO with some converted stock are Arrived
     *  Expected: PO is no eligible for closing
     */
    @IsTest
    private static void checkCancellationEligibility_Arrived()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // update POLI unit confirmed
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        // convert some stocks for testing
        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        // update some converted stock to 'Arrived'
        List<Vehicle_Master2__c> convertedStocks = [SELECT Vehicle_Purchase_Status__c FROM Vehicle_Master2__c WHERE Vehicle_Purchase_Order__c = :order.Id LIMIT 3];

        for (Vehicle_Master2__c convertedStock : convertedStocks)
        {
            convertedStock.Vehicle_Purchase_Status__c = 'Arrived';
        }

        update convertedStocks;

        try
        {
            order.Stage__c = 'Cancelled';
            order.Cancellation_Reason__c = 'Testing';
            update order;
        } catch(Exception e)
        {
            System.assert(e.getMessage().contains('PO with In Shipment or Arrived vehicle purchase status is not eligible for cancellation'), e.getMessage());
        }
    }

    /**
     *  Test closing PO with some converted stock are Reserved
     *  Expected: PO is no eligible for closing
     */
    @IsTest
    private static void checkCancellationEligibility_Reserved()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // update POLI unit confirmed
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        // convert some stocks for testing
        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        // update some converted stock to 'RESRV'
        List<Vehicle_Master2__c> convertedStocks = [SELECT Vehicle_Status__c FROM Vehicle_Master2__c WHERE Vehicle_Purchase_Order__c = :order.Id LIMIT 3];

        for (Vehicle_Master2__c convertedStock : convertedStocks)
        {
            convertedStock.Vehicle_Status__c = 'RESRV';
        }

        update convertedStocks;

        try
        {
            order.Stage__c = 'Cancelled';
            order.Cancellation_Reason__c = 'Testing';
            update order;
        } catch(Exception e)
        {
            System.assert(e.getMessage().contains('PO with non-free vehicle status is not eligible for cancellation'), e.getMessage());
        }
    }

    /**
     *  Test closing PO with no converted stock
     *  Expected: PO can be cancelled
     */
    @IsTest
    private static void checkCancellationEligibility_NoConvertedStock()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // update POLI unit confirmed
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        // update stage to Cancelled
        order.Stage__c = 'Cancelled';
        order.Cancellation_Reason__c = 'Testing';
        update order;

        // assert whether stage is successfully updated
        Vehicle_Purchase_Order__c updatedOrder = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c WHERE Id = :order.Id LIMIT 3];

        System.assert(updatedOrder.Stage__c == 'Cancelled', 'Actual stage: ' + updatedOrder.Stage__c);
    }

    /**
     *  Test closing PO with full converted stock
     *  Expected: PO can be cancelled
     */
    @IsTest
    private static void checkCloseEligibility_NoConvertedStock()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // close vehicle purchase order
        order.Stage__c = 'Closed';
        update order;

        // assert whether stage is successfully updated
        Vehicle_Purchase_Order__c updatedOrder = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c WHERE Id = :order.Id];

        System.assert(updatedOrder.Stage__c == 'Closed', 'Actual stage: ' + updatedOrder.Stage__c);
    }

    /**
     *  Test closing PO with full converted stock
     *  Expected: PO can be cancelled
     */
    @IsTest
    private static void checkCloseEligibility_FullConvertedStock()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // update POLI unit confirmed
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = poli.Units_Ordered__c;
        }

        update polis;

        // convert some stocks for testing
        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        // close vehicle purchase order
        order.Stage__c = 'Closed';
        update order;

        // assert whether stage is successfully updated
        Vehicle_Purchase_Order__c updatedOrder = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c WHERE Id = :order.Id];

        System.assert(updatedOrder.Stage__c == 'Closed', 'Actual stage: ' + updatedOrder.Stage__c);
    }

    /**
     *  Test closing PO with full converted stock
     *  Expected: PO can not be cancelled
     */
    @IsTest
    private static void checkCloseEligibility_PartiallyConvertedStock()
    {
        // get vehicle purchase order
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        // update POLI unit confirmed
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        // convert some stocks for testing
        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        // update POLI unit confirmed again but do not convert
        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 2;
        }

        update polis;

        try
        {
            order.Stage__c = 'Closed';
            update order;
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('Number of converted Stock Vehicle Master do not match Total Unit Confirmed. Please convert stock first or contact System Administrator.'), e.getMessage());
        }
    }   
}