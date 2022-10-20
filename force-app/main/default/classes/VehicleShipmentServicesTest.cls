@IsTest
public with sharing class VehicleShipmentServicesTest
{
    @TestSetup
    private static void init()
    {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');

        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

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

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(false, 'Supplier Account');

        Id PrincipalRecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Principal').getRecordTypeId();

        supplier.RecordTypeId = PrincipalRecordTypeId;

        insert supplier;

        // create a vehicle shipment record
        Vehicle_Shipment__c shipment = new Vehicle_Shipment__c(Franchise_Code__c = 'KIAPC', Supplier_Account__c = supplier.Id, Currency_Code__c = 'SGD');
        insert shipment;

        // create a vehicle purchase order record
        Vehicle_Purchase_Order__c order = new Vehicle_Purchase_Order__c(
            Franchise_Code__c = 'KIAPC',
            Production_Month__c = Date.newInstance(Date.today().year(), Date.today().month(), 1),
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD'
        );
        insert order;
    }

    /**
     * Test ability to match single tier 1 vehicle
     * Expected: tier 1 SVM is linked to shipment line item successfully
     */
    @IsTest
    private static void autoMatchTier1Vehicle()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'KIAPC'];

        // insert a vehicle purchase order line item
        Vehicle_Purchase_Order_Line_Items__c orderLineItem = createPurchaseOrderLineItem(order.Id, modelColorTrimMaster, modelYearMaster.Id);
        insert orderLineItem;

        // insert a tier 1 vehicle and link it to order line item
        Vehicle_Master2__c tier1Vehicle = createTier1Vehicle(modelColorTrimMaster, modelYearMaster.Id, orderLineItem.Id);
        insert tier1Vehicle;

        // insert a shipment line item with matching manufacturer ref no
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        shipmentLineItem.Manufacturer_Ref_No__c = tier1Vehicle.Manufacturer_Ref_No__c;
        insert shipmentLineItem;

        // invoke auto match method
        String result = VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });

        // assert result
        System.assert(result == 'FULL', 'Actual result is: ' + result);

        // assert stock vehicle master is linked to shipment line item
        Vehicle_Master2__c updatedVehicle = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :tier1Vehicle.Id];

        System.assert(updatedVehicle.Shipment_Line_Item__c == shipmentLineItem.Id, 'Stock is linked to a different shipment line item: ' + shipmentLineItem.Id);
    }

    /**
     * Test ability to match single tier 2 vehicle
     * Expected: tier 2 SVM is linked to shipment line item successfully
     */
    @IsTest
    private static void autoMatchTier2Vehicle()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'KIAPC'];

        // insert a vehicle purchase order line item
        Vehicle_Purchase_Order_Line_Items__c orderLineItem = createPurchaseOrderLineItem(order.Id, modelColorTrimMaster, modelYearMaster.Id);
        insert orderLineItem;

        // insert a tier 2 vehicle and link it to order line item
        Vehicle_Master2__c tier2Vehicle = createTier2Vehicle(modelColorTrimMaster, modelYearMaster.Id, orderLineItem.Id);
        insert tier2Vehicle;

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        // invoke auto match method
        String result = VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });

        // assert result
        System.assert(result == 'FULL', 'Actual result is: ' + result);

        // assert stock vehicle master is linked to shipment line item
        Vehicle_Master2__c updatedVehicle = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :tier2Vehicle.Id];

        System.assert(updatedVehicle.Shipment_Line_Item__c == shipmentLineItem.Id, 'Stock is linked to a different shipment line item: ' + shipmentLineItem.Id);
    }

    /**
     * Test ability to match single tier 3 vehicle
     * Expected: tier 3 SVM is linked to shipment line item successfully
     */
    @IsTest
    private static void autoMatchTier3Vehicle()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'KIAPC'];

        // insert a vehicle purchase order line item
        Vehicle_Purchase_Order_Line_Items__c orderLineItem = createPurchaseOrderLineItem(order.Id, modelColorTrimMaster, modelYearMaster.Id);
        insert orderLineItem;

        // insert a tier 2 vehicle and link it to order line item
        Vehicle_Master2__c tier3Vehicle = createTier3Vehicle(modelColorTrimMaster, modelYearMaster.Id);
        insert tier3Vehicle;

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        // invoke auto match method
        String result = VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });

        // assert result
        System.assert(result == 'FULL', 'Actual result is: ' + result);

        // assert stock vehicle master is linked to shipment line item
        Vehicle_Master2__c updatedVehicle = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :tier3Vehicle.Id];

        System.assert(updatedVehicle.Shipment_Line_Item__c == shipmentLineItem.Id, 'Stock is linked to a different shipment line item: ' + shipmentLineItem.Id);
    }

    /**
     * Shipment line items is matched partially
     */
    @IsTest
    private static void partialMatching()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'KIAPC'];

        // insert a vehicle purchase order line item
        Vehicle_Purchase_Order_Line_Items__c orderLineItem = createPurchaseOrderLineItem(order.Id, modelColorTrimMaster, modelYearMaster.Id);
        insert orderLineItem;

        // insert a tier 2 vehicle and link it to order line item
        Vehicle_Master2__c tier3Vehicle = createTier3Vehicle(modelColorTrimMaster, modelYearMaster.Id);
        insert tier3Vehicle;

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem1 = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        Shipment_Line_Item__c shipmentLineItem2 = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert new List<Shipment_Line_Item__c> { shipmentLineItem1, shipmentLineItem2 };

        // invoke auto match method
        String result = VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });

        // assert result
        System.assert(result == 'PARTIAL', 'Actual result is: ' + result);
    }

    /**
     * No shipment line item get match
     */
    @IsTest
    private static void failMatching()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        Vehicle_Purchase_Order__c order = [SELECT Id FROM Vehicle_Purchase_Order__c WHERE Franchise_Code__c = 'KIAPC'];

        // insert a vehicle purchase order line item
        Vehicle_Purchase_Order_Line_Items__c orderLineItem = createPurchaseOrderLineItem(order.Id, modelColorTrimMaster, modelYearMaster.Id);
        insert orderLineItem;

        // insert a tier 3 vehicle with different production month
        Vehicle_Master2__c tier3Vehicle = createTier3Vehicle(modelColorTrimMaster, modelYearMaster.Id);
        tier3Vehicle.ProductionMonth__c = Date.today().addDays(-10);
        insert tier3Vehicle;

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem1 = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        Shipment_Line_Item__c shipmentLineItem2 = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert new List<Shipment_Line_Item__c> { shipmentLineItem1, shipmentLineItem2 };

        // invoke auto match method
        String result = VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });

        // assert result
        System.assert(result == 'PARTIAL', 'Actual result is: ' + result);
    }

    /**
     * Test manual match a non-eligible stock vehicle master to a shiment line item. This shipment line item current do not match to any stock
     * Expected: the selected stock vehicle master is linked to shipment line item
     */
    @IsTest
    private static void manualMatchNonEligibleVehicle()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        // create a non-eligible stock and link it to shipment line item
        Vehicle_Master2__c nonEligibleVehicle1 = createNonEligibleVehicle(modelColorTrimMaster, modelYearMaster.Id);
        nonEligibleVehicle1.Shipment_Line_Item__c = shipmentLineItem.Id;
        insert nonEligibleVehicle1;

        // create another non-eligible stock, this stock will be manual match and replace @nonEligibleVehicle1
        Vehicle_Master2__c nonEligibleVehicle2 = createNonEligibleVehicle(modelColorTrimMaster, modelYearMaster.Id);
        insert nonEligibleVehicle2;

        // manual match
        VehicleShipmentServices.shipmentManualMatchById(shipmentLineItem.Id, nonEligibleVehicle2.Id);

        // assert @nonEligibleVehicle2 is linked to shipment line item
        Vehicle_Master2__c updatedVehicle2 = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :nonEligibleVehicle2.Id];
        System.assert(updatedVehicle2.Shipment_Line_Item__c == shipmentLineItem.Id, 'Stock is linked to a different shipment line item: ' + shipmentLineItem.Id);

        // assert @nonEligibleVehicle1 is unlinked to shipment line item
        Vehicle_Master2__c updatedVehicle1 = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :nonEligibleVehicle1.Id];
        System.assert(updatedVehicle1.Shipment_Line_Item__c == null, 'Matched stock is not unmatch from shipment line item');
    }

    /**
     * Pass invalid shipment Id to auto matching method
     * Expected: exception is thrown
     */
    @IsTest
    private static void invalidShipmentId()
    {
        try
        {
            VehicleShipmentServices.shipmentsAutoMatching(null);
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('Invalid id for shipment matching'), 'Actual error message: ' + e.getMessage());
        }
    }

    /**
     * Perform auto match on shipment that do not have any line item
     * Expected: exception is thrown
     */
    @IsTest
    private static void noShipmentLineItemForMatching()
    {
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        try
        {
            VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('There is no eligible shipment line item for matching'), 'Actual error message: ' + e.getMessage());
        }
    }

    /**
     * Perform auto match when there is no eligible stock vehicle master for matching
     * Expected: exception is thrown
     */
    @IsTest
    private static void noStockForMatching()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        // create a non-eligible stock
        Vehicle_Master2__c nonEligibleVehicle = createNonEligibleVehicle(modelColorTrimMaster, modelYearMaster.Id);
        insert nonEligibleVehicle;

        // create shipment line item
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        try
        {
            VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { shipment.Id });
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('There is no eligible stock vehicle master for matching'), 'Actual error message: ' + e.getMessage());
        }
    }

    @IsTest
    private static void unmatchingSuccess()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        // create a non-eligible stock and link it to shipment line item
        Vehicle_Master2__c vehicle = createNonEligibleVehicle(modelColorTrimMaster, modelYearMaster.Id);
        vehicle.Shipment_Line_Item__c = shipmentLineItem.Id;
        insert vehicle;

        // unmatching
        VehicleShipmentServices.shipmentUnmatchingById(shipmentLineItem.Id, vehicle.Id);

        Vehicle_Master2__c updatedVehicle = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :vehicle.Id];

        System.assert(String.isBlank(updatedVehicle.Shipment_Line_Item__c), 'Stock is linked to shipment line item: ' + shipmentLineItem.Id);
    }

    /**
     * Generate a eligible tier 1 for shipment matching
     * @param modelColorTrimMaster model / color / trim package
     * @param modelYearId model year master ID
     * @param orderLineItemId vehicle purchase order line item id
     */
    private static Vehicle_Master2__c createTier1Vehicle(Model_Color_Trim_Master__c modelColorTrimMaster, Id modelYearId, Id orderLineItemId)
    {
        return createTier1Vehicle(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, modelYearId, orderLineItemId);
    }

    /**
     * Generate a eligible tier 1 for shipment matching
     * @param modelId model master ID
     * @param colorId color master ID
     * @param trimId trim master ID
     * @param modelYearId model year master ID
     */
    private static Vehicle_Master2__c createTier1Vehicle(Id modelId, Id colorId, Id trimId, Id modelYearId, Id orderLineItemId)
    {
        String originalCommcase = randomString(10);
        String systemCommcase   = randomString(10);
        String manRefNo         = randomString(10);

        Vehicle_Master2__c tier1Vehicle                     = Test_DataFactory.createVehicleMaster2(false, modelId, colorId, trimId, modelYearId, originalCommcase, systemCommcase);
        tier1Vehicle.ProductionMonth__c                     = Date.today();
        tier1Vehicle.Vehicle_Purchase_Status__c             = 'Confirmed';
        tier1Vehicle.Vehicle_Purchase_Order_Line_Items__c   = orderLineItemId;
        tier1Vehicle.Manufacturer_Ref_No__c                 = manRefNo;

        return tier1Vehicle;
    }

    /**
     * Generate a eligible tier 2 for shipment matching
     * @param modelColorTrimMaster model / color / trim package
     * @param modelYearId model year master ID
     * @param orderLineItemId vehicle purchase order line item id
     */
    private static Vehicle_Master2__c createTier2Vehicle(Model_Color_Trim_Master__c modelColorTrimMaster, Id modelYearId, Id orderLineItemId)
    {
        return createTier2Vehicle(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, modelYearId, orderLineItemId);
    }

    /**
     * Generate a eligible tier 2 for shipment matching
     * @param modelId model master ID
     * @param colorId color master ID
     * @param trimId trim master ID
     * @param modelYearId model year master ID
     */
    private static Vehicle_Master2__c createTier2Vehicle(Id modelId, Id colorId, Id trimId, Id modelYearId, Id orderLineItemId)
    {
        String originalCommcase = randomString(10);
        String systemCommcase   = randomString(10);

        Vehicle_Master2__c tier2Vehicle                     = Test_DataFactory.createVehicleMaster2(false, modelId, colorId, trimId, modelYearId, originalCommcase, systemCommcase);
        tier2Vehicle.ProductionMonth__c                     = Date.today();
        tier2Vehicle.Vehicle_Purchase_Status__c             = 'Confirmed';
        tier2Vehicle.Vehicle_Purchase_Order_Line_Items__c   = orderLineItemId;

        return tier2Vehicle;
    }

    /**
     * Generate a eligible tier 2 for shipment matching
     * @param modelColorTrimMaster model / color / trim package
     * @param modelYearId model year master ID
     */
    private static Vehicle_Master2__c createTier3Vehicle(Model_Color_Trim_Master__c modelColorTrimMaster, Id modelYearId)
    {
        return createTier3Vehicle(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, modelYearId);
    }

    /**
     * Generate a eligible tier 3 for shipment matching
     * @param modelId model master ID
     * @param colorId color master ID
     * @param trimId trim master ID
     * @param modelYearId model year master ID
     */
    private static Vehicle_Master2__c createTier3Vehicle(Id modelId, Id colorId, Id trimId, Id modelYearId)
    {
        String originalCommcase = randomString(10);
        String systemCommcase   = randomString(10);

        Vehicle_Master2__c tier3Vehicle = Test_DataFactory.createVehicleMaster2(false, modelId, colorId, trimId, modelYearId, originalCommcase, systemCommcase);
        tier3Vehicle.ProductionMonth__c = Date.today();
        tier3Vehicle.Vehicle_Status__c  = 'RESRV';

        return tier3Vehicle;
    }

    /**
     * Generate a non eligible vehicle for shipment matching
     * @param modelColorTrimMaster model / color / trim package
     * @param modelYearId model year master ID
     * 
     */
    private static Vehicle_Master2__c createNonEligibleVehicle(Model_Color_Trim_Master__c modelColorTrimMaster, Id modelYearId)
    {
        String originalCommcase = randomString(10);
        String systemCommcase   = randomString(10);

        Vehicle_Master2__c noTierVehicle            = Test_DataFactory.createVehicleMaster2(false, modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, modelYearId, originalCommcase, systemCommcase);
        noTierVehicle.ProductionMonth__c            = Date.today();
        noTierVehicle.Vehicle_Purchase_Status__c    = null;
        noTierVehicle.Vehicle_Status__c             = null;

        return noTierVehicle;
    }

    /**
     * Generate a vehicle purchase order line item
     * @param orderId vehicle purchase order id
     * @param modelColorTrimMaster model / color / trim combination
     * @param modelYearId model year id
     */
    private static Vehicle_Purchase_Order_Line_Items__c createPurchaseOrderLineItem(Id orderId, Model_Color_Trim_Master__c modelColorTrimMaster, Id modelYearId)
    {
        return new Vehicle_Purchase_Order_Line_Items__c(
            Vehicle_Purchase_Order__c = orderId,
            Model_Master__c = modelColorTrimMaster.Model_Code__c,
            Color_Master__c = modelColorTrimMaster.Color_Code__c,
            Trim_Master__c = modelColorTrimMaster.Trim_Code__c,
            Model_Color_Trim_Master__c = modelColorTrimMaster.Id,
            Model_Year_Master__c = modelYearId,
            Units_Ordered__c = 1
        );
    }

    /**
     * Generate a shipment line item
     * @param shipmentId shipment Id
     * @param modelColorTrimMaster model / color / trim combination
     */
    private static Shipment_Line_Item__c createShipmentLineItem(Id shipmentId, Model_Color_Trim_Master__c modelColorTrimMaster)
    {
        String month = String.valueOf(Date.today().month()).leftPad(2, '0');

        String year = String.valueOf(Date.today().year());

        return new Shipment_Line_Item__c(
            Vehicle_Shipment__c = shipmentId,
            Chassis_No__c = randomString(10),
            Engine_No__c = randomString(10),
            Model__c = modelColorTrimMaster.Model_Code__r.Name,
            Colour_Code__c = modelColorTrimMaster.Color_Code__r.ColorCode__c,
            Trim__c = modelColorTrimMaster.Trim_Code__r.Name,
            Production_Month__c = month + '/' + year,
            Ex_Factory_Charges_Currency_Code__c = 'SGD',
            Transport_Charges_Currency_Code__c = 'SGD',
            FOB_Amount_Currency_Code__c = 'SGD',
            Freight_Charges_Currency_Code__c = 'SGD',
            Insurance_Charges_Currency_Code__c = 'SGD',
            Other_Charges_Currency_Code__c = 'SGD',
            Transport_Charges__c = 1000,
            FOB_Amount__c = 1000,
            Freight_Charges__c = 1000,
            Insurance_Charges__c = 1000,
            Other_Charges__c = 1000,
            Ex_Factory_Charges__c = 1000
        );
    }

    /**
     * Generate a string of @length random characters. This method is for testing purpose so no input validate is applied.
     * @param length desired length of string. The method expect @length to be greater than 1.
     */
    private static String randomString(Integer length)
    {
        List<String> ALPHA_NUMERIC_CHARACTERS = new List<String> {
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
        };

        String result = '';

        for (Integer i = 0; i < length; i++)
        {
            Integer randomNumber = (Integer) ( Math.random() * (ALPHA_NUMERIC_CHARACTERS.size() - 1) );

            result += ALPHA_NUMERIC_CHARACTERS[randomNumber];
        }

        return result;
    }
}