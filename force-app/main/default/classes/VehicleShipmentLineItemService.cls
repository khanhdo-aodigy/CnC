/*==========================================================================================================================================================================
 * Services provider for Shipment Line Item Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            18 Aug 2022                        phan.thu@aodigy.com                 US-VPO-000023                                              init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class VehicleShipmentLineItemService 
{
    private static VehicleShipmentLineItemSelector sel = new VehicleShipmentLineItemSelector();

    public static List<Shipment_Line_Item__c> getLineItemsNotTaggedToInvoicesByShipmentId(String vehicleShipmentId)
    {
        return sel.selectLineItemsNotTaggedToInvoicesByShipmentId(vehicleShipmentId);
    }

    public static List<Shipment_Line_Item__c> getLineItemsByVehicleShipmentIds(Set<Id> shipmentIds)
    {
        return sel.selectByVehicleShipmentIds(shipmentIds);
    }

    public static List<Shipment_Line_Item__c> getLineItemsByIds(Set<String> Ids)
    {
        return sel.selectByIds(Ids);
    }
}