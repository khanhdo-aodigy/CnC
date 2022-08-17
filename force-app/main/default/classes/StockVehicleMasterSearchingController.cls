public with sharing class StockVehicleMasterSearchingController
{
    @AuraEnabled(cacheable=true)
    public static List<Model_Color_Trim_Master__c> getVariantCombinationsById(String variantId)
    {
        String soql = String.format('SELECT {0} FROM Model_Color_Trim_Master__c WHERE Model_Code__c = {1}', new List<String> {
            String.join(getModelColorTrimMasterFields(), ', '),
            '\'' + String.escapeSingleQuotes(variantId) + '\''
        });

        return Database.query(soql);
    }

    @AuraEnabled(cacheable=true)
    public static List<Vehicle_Master2__c> getStockVehicleMaster(String variantId, String colorId, String trimId, String conditions)
    {
        String soql = String.format('SELECT {0} FROM Vehicle_Master2__c WHERE Model_Code__c = {1} AND Color_Code__c = {2} AND Trim_Code__c = {3}', new List<String> {
            String.join(getStockVehicleMasterFields(), ', '),
            '\'' + variantId + '\'',
            '\'' + colorId + '\'',
            '\'' + trimId + '\''
        });

        if (String.isNotEmpty(conditions))
        {
            soql += ' AND ' + conditions;
        }

        System.debug('getStockVehicleMaster::soql > ' + soql);

        return Database.query(soql);
    }

    private static List<String> getModelColorTrimMasterFields()
    {
        return new List<String> {
            'Color_Code__c',
            'Trim_Code__c',
            'Model_Code__c',
            'Model_Code__r.Model_Description__c',
            'Color_Code__r.Color_Description__c',
            'Trim_Code__r.Trim_Description__c',
            'Color_Code__r.ColorCode__c',
            'Trim_Code__r.Name'
        };
    }

    private static List<String> getStockVehicleMasterFields()
    {
        return new List<String> {
            'Id',
            'Name',
            'Model_Description__c',
            'Color_Description__c',
            'Trim_Description__c',
            'Vehicle_Purchase_Status__c',
            'Vehicle_Status__c'
        };
    }
}
