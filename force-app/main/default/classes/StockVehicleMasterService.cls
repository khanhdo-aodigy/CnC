/*==========================================================================================================================================================================
 * Service class for Stock Vehicle Master entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           05 Sep 2022                       phan.thu@aodigy.com                    US-Ship-000035                                          Init
 *  ========================================================================================================================================================================== 
 */

public inherited sharing class StockVehicleMasterService 
{
    private static StockVehicleMasterSelector sel = new StockVehicleMasterSelector();

    public static List<Vehicle_Master2__c> selectStockVehicleMastersForDutyRequest()
    {
        return sel.getStockVehicleMastersForDutyRequest();
    }

    public static List<Vehicle_Master2__c> selectByIds(List<String> Ids)
    {
        return sel.getRecordsByIds(Ids);
    }

    public static List<Vehicle_Master2__c> selectStockVehicleMastersByInvoiceIds(Set<Id> invoiceIds)
    {
        return sel.getStockVehicleMastersByInvoiceIds(invoiceIds);
    }
}