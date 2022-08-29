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
    public static void updateStockVehicleMaster(String orderId, String contentDocumentId, String contentVersionId)
    {
        try
        {
            System.assert(contentDocumentId != null, 'Invalid Content Document Id');

            System.assert(contentVersionId != null, 'Invalid Content Version Id');

            System.assert(orderId != null, 'Invalid Vehicle Purchase Order Id');

            // get shipment's stock vehicle master
            Map<Id, Vehicle_Master2__c> stockVehicleMasters = new Map<Id, Vehicle_Master2__c>([SELECT Id FROM Vehicle_Master2__c WHERE Vehicle_Purchase_Order__c = :orderId]);

            System.assert(stockVehicleMasters.size() > 0, 'This shipment do not have any related Stock Vehicle Master');

            ContentVersion uploadedReport = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];

            // clear uploaded file in a separate context
            deleteUploadedReport(contentDocumentId);

            String csv = uploadedReport.VersionData.toString();

            List<Map<String, String>> consumedTable = new ADGLIB_CommaSeparatedValuesFileReader(csv).withHeader().withStrictMode().read().exportResultAsMap();

            List<Vehicle_Master2__c> updatingStockVehicleMaster = new List<Vehicle_Master2__c>();

            for (Map<String, String> row : consumedTable)
            {
                System.assert(row.keySet().contains('Id'), 'A row is uploaded without Id field');
                System.assert(row.keySet().contains('Manufacturer_Ref_No__c'), 'A row is uploaded without Manufacturer_Ref_No__c field');

                Id stockId                  = (Id) row.get('Id');
                String manufacturerRefNo    = row.get('Manufacturer_Ref_No__c');

                System.assert(stockVehicleMasters.keySet().contains(stockId), 'A row is uploaded with stock ID not belong to this purchase order');

                updatingStockVehicleMaster.add(new Vehicle_Master2__c(Id = stockId, Manufacturer_Ref_No__c = manufacturerRefNo));
            }

            update updatingStockVehicleMaster;
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());

            // for DML exception, throw it as a custom exception so that it will be displayed on screen
            // for non DML exception, throw it as a AuraHandledException and do not display on screen
            if (e instanceof System.DmlException)
            {
                throw new StockVehicleMasterReportException(e.getMessage());
            }
            else
            {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    @future
    private static void deleteUploadedReport(String contentDocumentId)
    {
        delete [SELECT Id FROM ContentDocument WHERE Id =:contentDocumentId];
    }

    public class StockVehicleMasterReportException extends Exception {}
}
