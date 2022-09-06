@IsTest
private with sharing class StockVehicleSearchingControllerTest
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

        Vehicle_Master2__c vehicle1 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, randomString(10), randomString(10));
        vehicle1.ProductionMonth__c = Date.today();
        vehicle1.Franchise_Code__c = 'KIAPC';

        Vehicle_Master2__c vehicle2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, randomString(10), randomString(10));
        vehicle2.ProductionMonth__c = Date.today().addMonths(-1);
        vehicle2.Franchise_Code__c = 'CITPC';

        insert new List<Vehicle_Master2__c> { vehicle1, vehicle2 };
    }

    /**
     * Test getVariantCombinationsById() with a model master ID that have combination
     */
    @IsTest
    private static void getVariantCombinationsById_Positive()
    {
        Model_Master__c modelMaster = [SELECT Id FROM Model_Master__c LIMIT 1];

        List<Model_Color_Trim_Master__c> result = StockVehicleMasterSearchingController.getVariantCombinationsById(modelMaster.Id);

        System.assert(result.size() == 1, 'Actual result size: ' + result.size());
    }

    /**
     * Test getVariantCombinationsById() with a model master ID that do not have combination
     */
    @IsTest
    private static void getVariantCombinationsById_Negative()
    {
        Model_Master__c modelMaster2 = Test_DataFactory.createModelCode(true, 'Model Master 2');

        List<Model_Color_Trim_Master__c> result = StockVehicleMasterSearchingController.getVariantCombinationsById(modelMaster2.Id);

        System.assert(result.size() == 0, 'Actual result size: ' + result.size());
    }

    /**
     * Test getVariantCombinationsById() with an invalid model master ID
     */
    @IsTest
    private static void getVariantCombinationsById_InvalidId()
    {
        try
        {
            List<Model_Color_Trim_Master__c> result = StockVehicleMasterSearchingController.getVariantCombinationsById('123456789');
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('invalid ID'), 'Actual error message: ' + e.getMessage());
        }
    }

    /**
     * Get stock vehicle master with no production month and conditions filtering
     */
    @IsTest
    private static void getStockVehicleMaster_NoPrdMth_NoConditions()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c FROM Model_Color_Trim_Master__c LIMIT 1];

        String productionMonth = '';

        String conditions = '';

        List<Vehicle_Master2__c> result = StockVehicleMasterSearchingController.getStockVehicleMaster(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, productionMonth, conditions);

        System.assert(result.size() == 2, 'Actual result size: ' + result.size());
    }

    @IsTest
    private static void getStockVehicleMaster_NoPrdMth_WithConditions()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c FROM Model_Color_Trim_Master__c LIMIT 1];

        String productionMonth = null;

        String conditions = 'Franchise_Code__c = \'KIAPC\'';

        List<Vehicle_Master2__c> result = StockVehicleMasterSearchingController.getStockVehicleMaster(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, productionMonth, conditions);

        System.assert(result.size() == 1, 'Actual result size: ' + result.size());
        System.assert(result[0].Franchise_Code__c == 'KIAPC', 'Actual franchise code: ' + result[0].Franchise_Code__c);
    }

    @IsTest
    private static void getStockVehicleMaster_WithPrdMth_NoConditions()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c FROM Model_Color_Trim_Master__c LIMIT 1];

        String productionMonth = getProductionMonthAsText(Date.today().addMonths(-1));

        String conditions = '';

        List<Vehicle_Master2__c> result = StockVehicleMasterSearchingController.getStockVehicleMaster(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, productionMonth, conditions);

        System.assert(result.size() == 1, 'Actual result size: ' + result.size());
        System.assert(result[0].Franchise_Code__c == 'CITPC', 'Actual franchise code: ' + result[0].Franchise_Code__c);
    }

    @IsTest
    private static void getStockVehicleMaster_WithPrdMth_WithConditions()
    {
        Model_Color_Trim_Master__c modelColorTrimMaster = [SELECT Model_Code__c, Color_Code__c, Trim_Code__c FROM Model_Color_Trim_Master__c LIMIT 1];

        String productionMonth = getProductionMonthAsText(Date.today().addMonths(-1));

        String conditions = 'Franchise_Code__c = \'KIAPC\'';

        List<Vehicle_Master2__c> result = StockVehicleMasterSearchingController.getStockVehicleMaster(modelColorTrimMaster.Model_Code__c, modelColorTrimMaster.Color_Code__c, modelColorTrimMaster.Trim_Code__c, productionMonth, conditions);

        System.assert(result.size() == 0, 'Actual result size: ' + result.size());
    }

    @IsTest
    private static void getStockVehicleMaster_InvalidInput()
    {
        try
        {
            List<Vehicle_Master2__c> result = StockVehicleMasterSearchingController.getStockVehicleMaster(null, null, null, null, null);    
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('invalid ID field'), 'Actual error message: ' + e.getMessage());
        }
        
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

    private static String getProductionMonthAsText(Date d)
    {
        return d != null? String.valueOf(d.month()).leftPad(2, '0') + '/' + String.valueOf(d.year()) : '';
    }
}