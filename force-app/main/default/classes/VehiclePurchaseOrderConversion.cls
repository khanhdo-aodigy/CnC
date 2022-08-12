/*==========================================================================================================================================================================
 * Provide Vehicle Purchase Order conversion invocable service
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      27 July 2022                        dangphap.mai@aodigy.com                 US-VPO-000016                                              init
 * ========================================================================================================================================================================== 
 */
global without sharing class VehiclePurchaseOrderConversion
{
    @InvocableMethod(label='Purchase Order' description='Convert Purchase Order Line Items into Stock Vehicle Master' category='Vehicle_Purchase_Order__c')
    global static void stockVehicleMasterConversion(List<Id> purchaseOrderIds)
    {
        Set<Id> orderIds = new Set<Id> (purchaseOrderIds);
        VehiclePurchaseOrderServices.stockVehicleMasterConversion(orderIds);
    }
}