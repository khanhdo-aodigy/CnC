/*==========================================================================================================================================================================
 * Domain class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      27 July 2022                        dangphap.mai@aodigy.com                 US-VPO-000016                                              init
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

    /**
     * take a snapshot of PO & POLI and upload as PO's attachment
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
}