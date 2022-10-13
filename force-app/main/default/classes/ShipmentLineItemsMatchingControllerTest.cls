@IsTest
private with sharing class ShipmentLineItemsMatchingControllerTest
{
    @TestSetup
    private static void prepareData()
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
     * Test init() with correct vehicle shipment ID
     */
    @IsTest
    private static void initWithCorrectId()
    {
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c LIMIT 1];

        ShipmentLineItemsMatchingController.VehicleShipmentDetail result = ShipmentLineItemsMatchingController.init(shipment.Id);

        // assert the shipment is retrieved correctly
        System.assert(result.shipment.Id == shipment.Id, 'Incorrect shipment retrieved');

        System.assert(result.shipmentLineItems.size() == 0, 'Actual shipment line items number: ' + result.shipmentLineItems.size());

        System.assert(result.shipmentMatchedStocks.size() == 0, 'Actual matched stocks number: ' + result.shipmentMatchedStocks.size());
    }

    /**
     * Test init() with an invalid vehicle shipment ID
     */
    @IsTest
    private static void initWithInvalidId()
    {
        try
        {
            ShipmentLineItemsMatchingController.VehicleShipmentDetail result = ShipmentLineItemsMatchingController.init(null);
        }
        catch (Exception e)
        {
            System.assert(e instanceof AuraHandledException, 'Error message: ' + e.getMessage());
        }
    }

    /**
     * Test shipmentsAutoMatching() success scenario
     */
    @IsTest
    private static void shipmentsAutoMatchingSuccess()
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
        String result = ShipmentLineItemsMatchingController.shipmentsAutoMatching(shipment.Id);

        // assert result
        System.assert(result == 'FULL', 'Actual result: ' + result);

        // assert the matching is completed
        Vehicle_Master2__c updatedVehicle = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :tier1Vehicle.Id];

        System.assert(updatedVehicle.Shipment_Line_Item__c == shipmentLineItem.Id, 'Stock is linked to a different shipment line item: ' + shipmentLineItem.Id);
    }

    /**
     * Test shipmentsAutoMatching() exception handling scenario
     */
    @IsTest
    private static void shipmentsAutoMatchingException()
    {
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c LIMIT 1];

        try
        {
            String result = ShipmentLineItemsMatchingController.shipmentsAutoMatching(shipment.Id);
        }
        catch (Exception e)
        {
            System.assert(e instanceof AuraHandledException, 'Error message: ' + e.getMessage());
        }
    }

    /**
     * Test shipmentManualMatchById() success scenario
     */
    @IsTest
    private static void shipmentManualMatchByIdSuccess()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        // create another non-eligible stock, this stock will be manual match
        Vehicle_Master2__c nonEligibleVehicle = createNonEligibleVehicle(modelColorTrimMaster, modelYearMaster.Id);
        insert nonEligibleVehicle;

        // manual match
        ShipmentLineItemsMatchingController.shipmentManualMatchById(shipmentLineItem.Id, nonEligibleVehicle.Id);

        // assert the matching is completed
        Vehicle_Master2__c updatedVehicle = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :nonEligibleVehicle.Id];

        System.assert(updatedVehicle.Shipment_Line_Item__c == shipmentLineItem.Id, 'Stock is linked to a different shipment line item: ' + shipmentLineItem.Id);
    }

    /**
     * Test shipmentManualMatchById() exception handling scenario
     */
    @IsTest
    private static void shipmentManualMatchByIdException()
    {
        try
        {
            ShipmentLineItemsMatchingController.shipmentManualMatchById(null, null);
        }
        catch (Exception e)
        {
            System.assert(e instanceof AuraHandledException, 'Error message: ' + e.getMessage());
        }
    }

    @IsTest
    private static void shipmentUnmatchingSuccess()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c, Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name FROM Model_Color_Trim_Master__c WHERE Franchise_Code__c = 'KIAPC'];

        Model_Year_Master__c modelYearMaster = [SELECT Id FROM Model_Year_Master__c WHERE Model_Master__c = :modelColorTrimMaster.Model_Code__c];

        // create shipment line item with similar model / color / trim combination
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c WHERE Franchise_Code__c = 'KIAPC'];

        Shipment_Line_Item__c shipmentLineItem = createShipmentLineItem(shipment.Id, modelColorTrimMaster);
        insert shipmentLineItem;

        // create another non-eligible stock, this stock will be manual match
        Vehicle_Master2__c vehicle = createNonEligibleVehicle(modelColorTrimMaster, modelYearMaster.Id);
        vehicle.Shipment_Line_Item__c = shipmentLineItem.Id;
        insert vehicle;

        // manual match
        ShipmentLineItemsMatchingController.shipmentUnmatchingById(shipmentLineItem.Id, vehicle.Id);

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