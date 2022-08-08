/*==========================================================================================================================================================================
 * Domain class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          27 July 2022                        dangphap.mai@aodigy.com             US-VPO-000016                                       init
 *          08 Aug 2-22                         dangphap.mai@aodigy.com             US-VPO-000029                                       added checkCancellationEligibility
 * ========================================================================================================================================================================== 
 */
public inherited sharing class VehiclePurchaseOrders extends ADGLIB_SObjectDomain
{
    public VehiclePurchaseOrders(List<Vehicle_Purchase_Order__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new VehiclePurchaseOrders(sObjectList);
		}
	}

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        Map<Id, Vehicle_Purchase_Order__c> existingOrders = (Map<Id, Vehicle_Purchase_Order__c>) existingRecords;

        this.snapshotCapture(Records, existingOrders);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        Map<Id, Vehicle_Purchase_Order__c> existingOrders = (Map<Id, Vehicle_Purchase_Order__c>) existingRecords;

        this.checkCancellationEligibility(Records, existingOrders);
    }

    /**
     * ===================================================================================
     * Take a snapshot of PO & POLI and upload as PO's attachment
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===================================================================================
     */
    private void snapshotCapture(List<Vehicle_Purchase_Order__c> Records, Map<Id, Vehicle_Purchase_Order__c> existingOrders)
    {
        Set<Id> applicableOrderIds = new Set<Id>();

        for (Vehicle_Purchase_Order__c order : Records)
        {
            if (order.Stage__c == 'Approved' && existingOrders.get(order.Id).Stage__c != order.Stage__c)
            {
                applicableOrderIds.add(order.Id);
            }
        }

        if (applicableOrderIds.size() > 0)
        {
            VehiclePurchaseOrderServices.takePurchaseOrderSnapshot(applicableOrderIds);
        }
    }

    /**
     * ===================================================================================
     * Check if PO is eligible for calcellation
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===================================================================================
     */
    private void checkCancellationEligibility(List<Vehicle_Purchase_Order__c> Records, Map<Id, Vehicle_Purchase_Order__c> existingOrders)
    {
        Map<Id, Vehicle_Purchase_Order__c> applicableOrders = new Map<Id, Vehicle_Purchase_Order__c>();

        for (Vehicle_Purchase_Order__c order : Records)
        {
            if (order.Stage__c == 'Cancelled' && existingOrders.get(order.Id).Stage__c != 'Cancelled')
            {
                applicableOrders.put(order.Id, order);
            }
        }

        // boring early quit
        if (applicableOrders.size() == 0) return;

        Map<Id, Vehicle_Master2__c> totalConvertedStocks = new Map<Id, Vehicle_Master2__c>([SELECT Id, Vehicle_Purchase_Status__c, Vehicle_Status__c, Vehicle_Purchase_Order__c
                                                                                            FROM Vehicle_Master2__c
                                                                                            WHERE Vehicle_Purchase_Order__c IN :applicableOrders.keySet()]);
        //
        
        // boring early quit
        if (totalConvertedStocks.size() == 0) return;

        // re-arrange by order id
        Map<Id, List<Vehicle_Master2__c>> convertedStocksByOrderId = new Map<Id, List<Vehicle_Master2__c>>();

        for (Vehicle_Master2__c convertedStock : totalConvertedStocks.values())
        {
            if (!convertedStocksByOrderId.keySet().contains(convertedStock.Vehicle_Purchase_Order__c))
            {
                convertedStocksByOrderId.put(convertedStock.Vehicle_Purchase_Order__c, new List<Vehicle_Master2__c> { convertedStock });
            }
            else
            {
                convertedStocksByOrderId.get(convertedStock.Vehicle_Purchase_Order__c).add(convertedStock);
            }
        }

        // start checking
        for (Vehicle_Purchase_Order__c order : applicableOrders.values())
        {
            List<Vehicle_Master2__c> convertedStocks = convertedStocksByOrderId.get(order.Id);

            if (convertedStocks != null && convertedStocks.size() > 0)
            {
                for (Vehicle_Master2__c convertedStock : convertedStocks)
                {
                    if (convertedStock.Vehicle_Purchase_Status__c == 'In Shipment' || convertedStock.Vehicle_Purchase_Status__c == 'Arrived')
                    {
                        order.addError('PO with In Shipment or Arrived vehicle purchase status is not eligible for cancellation');
                    }

                    if (convertedStock.Vehicle_Status__c != 'FREE')
                    {
                        order.addError('PO with non-free vehicle status is not eligible for cancellation');
                    }
                }
            }
        }
    }
}