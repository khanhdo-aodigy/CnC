/*==========================================================================================================================================================================
 * Controller class for Stock Vehicle Master Searching component
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          18 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000008                                       init
 * ========================================================================================================================================================================== 
 */
public with sharing class StockVehicleMasterSearchingController
{
    /**
     * ============================================================================================
     * Retrieve model-color-trim combinations for selected model
     * @param variantId: selected model id
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    @AuraEnabled(cacheable=true)
    public static List<Model_Color_Trim_Master__c> getVariantCombinationsById(String variantId)
    {
        String soql = String.format('SELECT {0} FROM Model_Color_Trim_Master__c WHERE Model_Code__c = {1}', new List<String> {
            String.join(getModelColorTrimMasterFields(), ', '),
            '\'' + String.escapeSingleQuotes(variantId) + '\''
        });

        return Database.query(soql);
    }

    /**
     * ============================================================================================
     * Retrieve stock vehicle master
     * @param variantId: selected model id
     * @param colorId: selected color id
     * @param trimId: select trim id
     * @param productionMonth: optional production month
     * @param conditions: optional conditions
     * History
     *          DATE::                              BY::                                CHANGELOG::
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    @AuraEnabled(cacheable=true)
    public static List<Vehicle_Master2__c> getStockVehicleMaster(String variantId, String colorId, String trimId, String productionMonth, String conditions)
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

        if (String.isNotEmpty(productionMonth))
        {
            soql += ' AND Production_Month__c = ' + '\'' + productionMonth + '\'';
        }

        System.debug('getStockVehicleMaster::soql > ' + soql);

        return Database.query(soql);
    }

    /**
     * ============================================================================================
     * Get Model Color Trim Master fields for retrieving
     * History
     *          DATE::                              BY::                                CHANGELOG::
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static List<String> getModelColorTrimMasterFields()
    {
        // TODO: use SObjectField token
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

    /**
     * ============================================================================================
     * Get Stock Vehicle Master fields for retrieving
     * History
     *          DATE::                              BY::                                CHANGELOG::
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static List<String> getStockVehicleMasterFields()
    {
        // TODO: use SObjectField token
        return new List<String> {
            'Id',
            'Name',
            'Model_Description__c',
            'Color_Description__c',
            'Trim_Description__c',
            'Vehicle_Purchase_Status__c',
            'Vehicle_Status__c',
            'Production_Month__c',
            'Manufacturer_Ref_No__c',
            'Franchise_Code__c'
        };
    }
}