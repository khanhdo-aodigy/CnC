public without sharing class VPO_LineItemsHistoryDashboardController
{
    @AuraEnabled(cacheable=true)
    public static VehiclePurchaseOrderHistory init(String recordId)
    {
        List<Vehicle_Purchase_Order__c> orders = new VehiclePurchaseOrderSelector().selectByIdsWithLineItems(new Set<Id> { recordId });

        VehiclePurchaseOrderHistory result = new VehiclePurchaseOrderHistory();

        if (orders.size() > 0)
        {
            result.order = orders[0];

            // get all the POLI Ids
            Set<Id> lineItemIds = new Set<Id>();

            for (Vehicle_Purchase_Order_Line_Items__c poli : result.order.Vehicle_Purchase_Order_Line_Items__r)
            {
                lineItemIds.add(poli.Id);
                result.historiesByLineItemId.put(poli.Id, new List<Vehicle_Purchase_Order_Line_Items__History>());
            }

            // get POLI history
            List<Vehicle_Purchase_Order_Line_Items__History> histories = [  SELECT Id, Field, OldValue, NewValue, CreatedBy.Name, ParentId, CreatedDate 
                                                                            FROM Vehicle_Purchase_Order_Line_Items__History
                                                                            WHERE ParentId IN :lineItemIds
                                                                            ORDER BY CreatedDate ASC
                                                                        ];
            for (Vehicle_Purchase_Order_Line_Items__History history : histories)
            {
                result.historiesByLineItemId.get(history.ParentId).add(history);
            }

            // get approved snapshot
            List<Attachment> snapshots = [SELECT Body FROM Attachment WHERE Description = '#snapshot' AND ParentId = :recordId ORDER BY CreatedDate DESC];

            if (snapshots.size() > 0)
            {
                System.debug(snapshots[0].Body.toString());
                result.snapshot = (Vehicle_Purchase_Order__c) JSON.deserialize(snapshots[0].Body.toString(), Vehicle_Purchase_Order__c.class);
            }
        }
        else
        {
            throw new AuraHandledException('Invalid Vehicle Purchase Order Id');
        }

        return result;
    }

    public class VehiclePurchaseOrderHistory
    {
        @AuraEnabled
        public Vehicle_Purchase_Order__c order;

        @AuraEnabled
        public Map<Id, List<Vehicle_Purchase_Order_Line_Items__History>> historiesByLineItemId = new Map<Id, List<Vehicle_Purchase_Order_Line_Items__History>>();

        @AuraEnabled
        public Vehicle_Purchase_Order__c snapshot;
    }
}