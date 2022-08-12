@IsTest
private with sharing class VehiclePurchaseOrderServicesTest
{
    @TestSetup
    private static void setUp()
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
     * test snapshot capturing when PO is approved
     * expected: an attachment with PO & POLI values will be generated on PO approved
     */
    @IsTest
    private static void testSnapshotCapture_Success()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        order.Stage__c = 'Approved';

        update order;

        // get snapshot
        List<Attachment> snapshots = [SELECT Id, Body, Description FROM Attachment WHERE ParentId = :order.Id];

        System.assert(snapshots.size() == 1, 'No snapshot found');
        System.assert(snapshots[0].Description == '#snapshot', 'Snapshot do not have required description');
    }

    /**
     * test stock conversion successfully
     * expected: units confirmed of POLI converted to stock vehicle master
     */
    @IsTest
    private static void stockConversion_Success()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        order.Stage__c = 'Manufacturer_Confirmed';

        update order;

        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        List<Vehicle_Master2__c> convertedStocks = [SELECT Id FROM Vehicle_Master2__c];

        order = [SELECT Id, Total_Units_Confirmed__c FROM Vehicle_Purchase_Order__c];

        System.assert(convertedStocks.size() == order.Total_Units_Confirmed__c, 'Converted stocks do not equal units confirmed');
    }

    /**
     * test stock conversion partially
     * expected: only the increased units confirmed will be converted
     */
    @IsTest
    private static void stockConversion_PartialConversion()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        order.Stage__c = 'Manufacturer_Confirmed';

        update order;

        // 1st round of converting
        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 1;
        }

        update polis;

        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        // 2nd round of converting
        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Confirmed__c = 2;
        }

        update polis;

        VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });

        List<Vehicle_Master2__c> convertedStocks = [SELECT Id FROM Vehicle_Master2__c];

        order = [SELECT Id, Total_Units_Confirmed__c FROM Vehicle_Purchase_Order__c];

        System.assert(convertedStocks.size() == order.Total_Units_Confirmed__c, 'Converted stocks do not equal units confirmed');
    }

    /**
     * test stock conversion on invalid stage
     * expected: an error is thrown with invalid stage message
     */
    @IsTest
    private static void stockConversion_InvalidStage()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        try
        {
            VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('stage is not Manufacturer Confirmation'), 'Exception message: ' + e.getMessage());
        }
    }

    /**
     * test stock conversion when having no units confirmed
     * expected: an error is thrown with no units confirmed message
     */
    @IsTest
    private static void stockConversion_NoUnitConfirmed()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        order.Stage__c = 'Manufacturer_Confirmed';

        update order;


        try
        {
            VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('no unit confirmed'), 'Exception message: ' + e.getMessage());
        }
    }

    /**
     * test stock conversion when having no units ordered
     * expected: an error is thrown with no units ordered message
     */
    @IsTest
    private static void stockConversion_NoUnitOrdered()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        order.Stage__c = 'Manufacturer_Confirmed';

        update order;

        List<Vehicle_Purchase_Order_Line_Items__c> polis = [SELECT Id, Units_Ordered__c, Units_Confirmed__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c = :order.Id];

        for (Vehicle_Purchase_Order_Line_Items__c poli : polis)
        {
            poli.Units_Ordered__c = 0;
        }

        update polis;

        try
        {
            VehiclePurchaseOrderServices.stockVehicleMasterConversion(new Set<Id> { order.Id });
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('no unit ordered'), 'Exception message: ' + e.getMessage());
        }
    }

    /**
     * test get PO by PO Id
     * expected: correct PO retrieved
     */
    @IsTest
    private static void getVehiclePurchaseOrder_Success()
    {
        Vehicle_Purchase_Order__c order = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];

        List<Vehicle_Purchase_Order__c> orders = VehiclePurchaseOrderServices.getVehiclePurchaseOrderByIds(new Set<Id> { order.Id });

        System.assert(orders.size() == 1, 'No Vehicle Purchase Order found');
    }

    /**
     * test exception message setting
     */
    @IsTest
    private static void exceptionMessage()
    {
        VehiclePurchaseOrderServices.VehiclePurchaseOrderServicesException e = new VehiclePurchaseOrderServices.VehiclePurchaseOrderServicesException();
        e.invalidConversionStage('Order');
        e.invalidConversionNoUnitOrdered('Order');
        e.invalidConversionNoUnitConfirmed('Order');
        e.invalidConversionNoModelMaster('Order');
        e.invalidConversionNoColorMaster('Order');
        e.invalidConversionNoTrimMaster('Order');
        e.invalidConversionNoModelYearMaster('Order');
    }
}