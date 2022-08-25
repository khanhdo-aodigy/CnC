public with sharing class vpo_StockVehicleMasterIOController
{
    @AuraEnabled(cacheable=true)
    public static List<Vehicle_Master2__c> getStockVehicleMaster(String orderId)
    {
        try
        {
            return [SELECT  Id, Name, Model_Code__r.Name, Color_Code__r.ColorCode__c,Trim_Code__r.Name, Manufacturer_Ref_No__c,
                            Vehicle_Purchase_Status__c, Vehicle_Status__c, Model_Description__c, Color_Description__c, Trim_Description__c
                    FROM Vehicle_Master2__c
                    WHERE Vehicle_Purchase_Order__c = :orderId];
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateStockVehicleMaster(String contentDocumentId, String contentVersionId)
    {
        System.debug('updateStockVehicleMaster');

        try
        {
            System.assert(contentDocumentId != null, 'Invalid Content Document Id');

            System.assert(contentVersionId != null, 'Invalid Content Version Id');

            ContentVersion uploadedReport = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];

            // clear uploaded file in a separate context
            deleteUploadedReport(contentDocumentId);

            String csv = uploadedReport.VersionData.toString();

            List<Map<String, String>> consumedData = new ADGLIB_CommaSeparatedValuesFileReader(csv, true).read().exportResultAsMap();

            List<Vehicle_Master2__c> updatingStockVehicleMaster = new List<Vehicle_Master2__c>();

            for (Map<String, String> data : consumedData)
            {
                System.debug(JSON.serialize(data));

                updatingStockVehicleMaster.add(new Vehicle_Master2__c(Id = data.get('Id'), Manufacturer_Ref_No__c = data.get('Manufacturer_Ref_No__c')));
            }

            update updatingStockVehicleMaster;
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future
    private static void deleteUploadedReport(String contentDocumentId)
    {
        delete [SELECT Id FROM ContentDocument WHERE Id =:contentDocumentId];
    }
}
