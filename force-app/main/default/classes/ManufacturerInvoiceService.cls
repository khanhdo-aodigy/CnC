/*==========================================================================================================================================================================
 * Service class for Manufacturer Invoice Entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           25 August 2022                      phan.thu@aodigy.com                US-Ship-000027                                            init
*            05 September 2022                   phan.thu@aodigy.com                US-Ship-000006                                            Added selectByInvoiceNo method
 * ========================================================================================================================================================================== 
 */

public inherited sharing class ManufacturerInvoiceService 
{
    private static ManufacturerInvoiceSelector sel = new ManufacturerInvoiceSelector();

    public static List<Manufacturer_Invoice__c> getManufacturerInvoicesByVehicleShipmentIds(Set<Id> shipmentIds)
    {
        return sel.selectManufacturerInvoicesByVehicleShipmentIds(shipmentIds);
    }

    public static List<Manufacturer_Invoice__c> getManufacturerInvoicesByInvoiceNos(Set<String> invoiceNos)
    {
        return sel.selectManufacturerInvoicesByInvoiceNos(invoiceNos);
    }

    public static List<Manufacturer_Invoice__c> getManufacturerInvoiceWithSLIByIds(Set<Id> invoiceIds)
    {
        return sel.selectManufacturerInvoiceWithSLIByIds(invoiceIds);
    }
}