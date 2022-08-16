/*==========================================================================================================================================================================
 * Services provider for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      27 July 2022                        dangphap.mai@aodigy.com                 US-VPO-000016                                              init
 * ========================================================================================================================================================================== 
 */
public inherited sharing class VehiclePurchaseOrderServices
{
    private static VehiclePurchaseOrderSelector sel = new VehiclePurchaseOrderSelector();

    /**
     * convert Vehicle Purchase Order Line Item into Stock Vehicle Master
     * @param orderIds: list of targeted Vehicle Purchase Order's Id
     */
    public static void stockVehicleMasterConversion(Set<Id> orderIds)
    {
        List<Vehicle_Purchase_Order__c> orders = new VehiclePurchaseOrderSelector().selectByIdsWithLineItems(orderIds);

        stockVehicleMasterConversionValidate(orders);

        List<Vehicle_Master2__c> vehicles = new List<Vehicle_Master2__c>();

        Set<Id> modelIds = new Set<Id>();

        
        Map<Id, List<Vehicle_Master2__c>> convertedStocksByLineItemId = new Map<Id, List<Vehicle_Master2__c>>();

        
        for (Vehicle_Purchase_Order__c order : orders)
        {
            // get the Model Master Ids
            for (Vehicle_Purchase_Order_Line_Items__c item : order.Vehicle_Purchase_Order_Line_Items__r)
            {
                modelIds.add(item.Model_Master__c);

                convertedStocksByLineItemId.put(item.Id, new List<Vehicle_Master2__c>());
            }

            // rearrange the converted stock vehicle master by line items
            for (Vehicle_Master2__c convertedStock : order.Stock_Vehicle_Masters__r)
            {
                // the below for loop has already create an empty list for adding
                convertedStocksByLineItemId.get(convertedStock.Vehicle_Purchase_Order_Line_Items__c)?.add(convertedStock);
            }

        }



        // get Branch Code and Franchise Code from Model Master
        Map<Id, Model_Master__c> models = new Map<Id, Model_Master__c> ([SELECT Id, Branch_Code__c, Franchise_Code__c FROM Model_Master__c WHERE Id IN :modelIds]);

        for (Vehicle_Purchase_Order__c order : orders)
        {
            for (Vehicle_Purchase_Order_Line_Items__c item : order.Vehicle_Purchase_Order_Line_Items__r)
            {
                Integer unitConfirmed = (Integer) item.Units_Confirmed__c;
                Integer unitConverted = convertedStocksByLineItemId.get(item.Id) == null? 0 : (Integer) convertedStocksByLineItemId.get(item.Id).size();

                if (unitConverted >= unitConfirmed) continue;

                Integer unitToConvert = unitConfirmed - unitConverted;

                for (Integer i = 0; i < unitToConvert; i++)
                {
                    vehicles.add(new Vehicle_Master2__c(
                        Color_Code__c = item.Color_Master__c,
                        Model_Code__c = item.Model_Master__c,
                        Model_Year_Code__c = item.Model_Year_Master__c,
                        Original_Commcase__c = 'N/A',
                        System_Commcase__c = 'N/A',
                        Trim_Code__c = item.Trim_Master__c,
                        IsSold__c = false,
                        Vehicle_Purchase_Order__c = order.Id,
                        Vehicle_Purchase_Order_Line_Items__c = item.Id,
                        ProductionMonth__c = order.Production_Month__c,
                        Vehicle_Purchase_Status__c = 'Confirmed',
                        Estimated_FOB__c = item.Unit_Price__c,
                        Branch_Code__c = models.get(item.Model_Master__c)?.get('Branch_Code__c') == null? '' : (String) models.get(item.Model_Master__c)?.get('Branch_Code__c'),
                        Franchise_Code__c = models.get(item.Model_Master__c)?.get('Franchise_Code__c') == null? '' : (String) models.get(item.Model_Master__c)?.get('Franchise_Code__c')
                    ));
                }
            }
        }

        insert vehicles;

    }

    /**
     * take a snapshot of Purchase Order and Purchase Order Line Item and attach to Purchase Order
     * @param orderIds: list of targeted Vehicle Purchase Order's Id
     */
    public static void takePurchaseOrderSnapshot(Set<Id> orderIds)
    {
        List<Vehicle_Purchase_Order__c> orders = new VehiclePurchaseOrderSelector().selectByIdsWithLineItems(orderIds);

        List<Attachment> snapshots = new List<Attachment>();

        if (orders.size() > 0)
        {
            for (Vehicle_Purchase_Order__c order : orders)
            {
                snapshots.add(new Attachment(
                    Name = 'Snapshot.txt',
                    Body = Blob.valueOf(JSON.serialize(order)),
                    ContentType = '.txt',
                    ParentId = order.Id,
                    IsPrivate = true,
                    Description = '#snapshot'
                ));
            }

            new Helper().insertAttachments(snapshots);
            // insert snapshots;
        }
    }

    /**
     * Get List of Vehicle Purchase Orders using Set of Ids
     * @param orderIds: Set of targeted Vehicle Purchase Order Id
     */
    public static List<Vehicle_Purchase_Order__c> getVehiclePurchaseOrderByIds(Set<Id> orderIds)
    {
        return sel.selectSObjectsById(orderIds);
    }

    /**
     * check if vehicle purchase order is valid for stock vehicle master conversion
     */
    private static void stockVehicleMasterConversionValidate(List<Vehicle_Purchase_Order__c> orders)
    {
        // TODO: have a check on model + color + trim + model year + model color trim
        for (Vehicle_Purchase_Order__c order : orders)
        {
            if (order.Stage__c != 'Manufacturer_Confirmed')
            {
                throw new VehiclePurchaseOrderServicesException().invalidConversionStage(order.Name);
            }

            if (order.Total_Units_Ordered__c == 0)
            {
                throw new VehiclePurchaseOrderServicesException().invalidConversionNoUnitOrdered(order.Name);
            }

            for (Vehicle_Purchase_Order_Line_Items__c item : order.Vehicle_Purchase_Order_Line_Items__r)
            {
                if (item.Units_Confirmed__c == null || item.Units_Confirmed__c < 1)
                {
                    throw new VehiclePurchaseOrderServicesException().invalidConversionNoUnitConfirmed(item.Name);
                }

                if (String.isBlank(item.Model_Master__c))
                {
                    throw new VehiclePurchaseOrderServicesException().invalidConversionNoModelMaster(item.Name);
                }

                if (String.isBlank(item.Color_Master__c))
                {
                    throw new VehiclePurchaseOrderServicesException().invalidConversionNoColorMaster(item.Name);
                }

                if (String.isBlank(item.Trim_Master__c))
                {
                    throw new VehiclePurchaseOrderServicesException().invalidConversionNoTrimMaster(item.Name);
                }

                if (String.isBlank(item.Model_Year_Master__c))
                {
                    throw new VehiclePurchaseOrderServicesException().invalidConversionNoModelYearMaster(item.Name);
                }
            }
        }
    }

    /**
     * inner without sharing class to help by pass sharing setting in some special cases
     */
    private without sharing class Helper
    {
        private void insertAttachments(List<Attachment> attachments)
        {
            insert attachments;
        }
    }
    
    @TestVisible
    private class VehiclePurchaseOrderServicesException extends Exception
    {
        @TestVisible
        private Exception invalidConversionStage(String orderName)
        {
            this.setMessage(String.format('Vehicle Purchase Order {0} is invalid for stock conversion. Reason: stage is not Manufacturer Confirmation', new List<String> { orderName }));
            return this;
        }

        @TestVisible
        private Exception invalidConversionNoUnitOrdered(String orderName)
        {
            this.setMessage(String.format('Vehicle Purchase Order {0} is invalid for stock conversion. Reason: no unit ordered', new List<String> { orderName }));
            return this;
        }

        @TestVisible
        private Exception invalidConversionNoUnitConfirmed(String lineItemName)
        {
            this.setMessage(String.format('Line Item {0} is invalid for stock conversion. Reason: no unit confirmed', new List<String> { lineItemName }));
            return this;
        }

        @TestVisible
        private Exception invalidConversionNoColorMaster(String lineItemName)
        {
            this.setMessage(String.format('Line Item {0} is invalid for stock conversion. Reason: no color master', new List<String> { lineItemName }));
            return this;
        }

        @TestVisible
        private Exception invalidConversionNoTrimMaster(String lineItemName)
        {
            this.setMessage(String.format('Line Item {0} is invalid for stock conversion. Reason: no trim master', new List<String> { lineItemName }));
            return this;
        }

        @TestVisible
        private Exception invalidConversionNoModelMaster(String lineItemName)
        {
            this.setMessage(String.format('Line Item {0} is invalid for stock conversion. Reason: no model master', new List<String> { lineItemName }));
            return this;
        }

        @TestVisible
        private Exception invalidConversionNoModelYearMaster(String lineItemName)
        {
            this.setMessage(String.format('Line Item {0} is invalid for stock conversion. Reason: no model year master', new List<String> { lineItemName }));
            return this;
        }
    }
}