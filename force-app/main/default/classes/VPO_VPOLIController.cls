/*==========================================================================================================================================================================
 * Controller class for VPO_VPOLI LWC
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           02 Aug 2022                       phan.thu@aodigy.com                    US-VPO-000009                                          init
 * ========================================================================================================================================================================== 
 */

public without sharing class VPO_VPOLIController 
{
    @AuraEnabled(cacheable = true)
    public static List<Vehicle_Purchase_Order_Line_Items__c> getVPOLIDetail(String parentId) {
        try {
            List<Vehicle_Purchase_Order_Line_Items__c> poList = [SELECT Name, Model_Master__r.name, 
            Colour_Description__c, Trim_Master__r.Trim_Description__c, Units_Ordered__c, Units_Confirmed__c, Unit_Price__c, 
            Total_Price__c, Remarks__c FROM Vehicle_Purchase_Order_Line_Items__c WHERE Vehicle_Purchase_Order__c =: parentId ORDER BY Name DESC];
            
            return poList; 
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Model_Color_Trim_Master__c> getColorMasters(String modelMasterId, String franchiseCode, String branchCode)
    {
        try 
        {
            System.debug('getColorMasters' + modelMasterId + ' ' + franchiseCode + ' ' + branchCode);
            if (String.isBlank(modelMasterId)) return new List<Model_Color_Trim_Master__c>();

            String condition = 'Color_Code__r.Color_Description__c != \'\' AND Color_Code__r.Active__c = true';

            if (String.isNotBlank(modelMasterId))
            {
                condition += ' AND Model_Code__c = \'' + modelMasterId + '\'';
            }

            if (String.isNotBlank(franchiseCode))
            {
                condition += ' AND Franchise_Code__c = \'' + franchiseCode + '\'';
            }

            if (String.isNotBlank(branchCode))
            {
                condition += ' AND Branch_Code__c = \'' + branchCode + '\'';
            }

            return (List<Model_Color_Trim_Master__c>) fetchRecords('Model_Color_Trim_Master__c', 
                                                                    'Id, Color_Code__c, Color_Code__r.Name, Color_Code__r.Color_Description__c', 
                                                                    condition, false, '', '');
        } 
        catch (Exception e) 
        {
            System.debug('@@@ getColorMasters - Error: ' + e.getMessage() );
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Model_Color_Trim_Master__c> getTrimMasters(String modelMasterId, String colorMasterId)
    {
        try 
        {
            if (String.isBlank(modelMasterId) || String.isBlank(colorMasterId)) return new List<Model_Color_Trim_Master__c>();

            return (List<Model_Color_Trim_Master__c>) fetchRecords('Model_Color_Trim_Master__c', 
                                                                    'Id, Trim_Code__c, Trim_Code__r.Trim_Description__c, Model_Code__c, Color_Code__c', 
                                                                    'Model_Code__c = \'' + modelMasterId + '\' AND Color_Code__c = \'' + colorMasterId + '\''
                                                                    + ' AND Trim_Code__r.Trim_Description__c != \'\' AND Trim_Code__r.Active__c = true', 
                                                                    false, '', '');
        } 
        catch (Exception e) 
        {
            System.debug('@@@ getColorMasters - Error: ' + e.getMessage() );
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Model_Year_Master__c> getModelYearMasters(String modelMasterId)
    {
        try 
        {
            if (String.isBlank(modelMasterId)) return new List<Model_Year_Master__c>();

            return (List<Model_Year_Master__c>) fetchRecords('Model_Year_Master__c', 
                                                            'Id, Model_Master__c, Name', 
                                                            'Model_Master__c = \'' + modelMasterId + '\'',  
                                                            false, '', '');
        } 
        catch (Exception e) 
        {
            System.debug('@@@ getModelYearMasters - Error: ' + e.getMessage() );
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Vehicle_Master2__c> getStockVehicleMasters(String parentId)
    {
        try 
        {
            return (List<Vehicle_Master2__c>) fetchRecords('Vehicle_Master2__c', 
                                                            'Id, Name, Vehicle_Purchase_Status__c, Vehicle_Status__c,' +
                                                            'Model_Description__c, Color_Description__c, Trim_Description__c, Manufacturer_Ref_No__c', 
                                                            'Vehicle_Purchase_Order__c = \'' + parentId + '\'', 
                                                            false, 'Name', 'DESC');
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Vehicle_Purchase_Order_Line_Items__c> getVPOLI(String parentId){
        try {
            return (List<Vehicle_Purchase_Order_Line_Items__c>) fetchRecords('Vehicle_Purchase_Order_Line_Items__c',
                                                            'Id, Name, Model_Master__r.name,Colour_Description__c, Trim_Master__r.Trim_Description__c,'+
                                                            'Units_Ordered__c, Units_Confirmed__c, Units_Cancelled__c,  Unit_Price__c,'+
                                                            'Total_Price__c, Remarks__c, Vehicle_Purchase_Order__r.Stage__c',
                                                            'Vehicle_Purchase_Order__c = \'' + parentId +'\'',
                                                            false,'Name','DESC');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean upsertVPOLI(Vehicle_Purchase_Order_Line_Items__c vPOLItem)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Vehicle_Purchase_Order_Line_Items__c.SObjectType});
        try 
        {
            uow.registerUpsert(vPOLItem);
            uow.commitWork();
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    private static List<SObject> fetchRecords(String objectName, String fieldNames, String queryConditions, Boolean onlyOne, String orderByField, String orderType)
    {
        String query = 'SELECT ' + fieldNames + ' FROM ' + objectName;

        if (String.isNotBlank(queryConditions))
        {
            query +=  ' WHERE ' + queryConditions;
        }

        if (onlyOne)
        {
            query += ' LIMIT 1';
        }

        if (String.isNotBlank(orderByField) && String.isNotBlank(orderType))
        {
            query += ' ORDER BY ' + orderByField + ' ' + orderType;
        }

        System.debug('fetchRecords - query: ' + query);

        return Database.query(query);
    }
}