/*==========================================================================================================================================================================
 * Service class for Inward Declaration Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            29 Aug 2022                        phan.thu@aodigy.com                 US-VPO-000027                                              init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class InwardDeclarationService 
{
    private static InwardDeclarationSelector sel = new InwardDeclarationSelector();

    public static Inward_Declaration__c getByRecordTypeAndVehicleShipmentId(String recordTypeName, Id vehicleShipmentId)
    {
        return sel.selectByRecordTypeAndVehicleShipmentId(recordTypeName, vehicleShipmentId);
    }

    public static List<Inward_Declaration__c> getByIdsWithInvoices(Set<Id> inwardDeclarationIds, Boolean withInvoices)
    {
        return sel.selectByIdsWithInvoices(inwardDeclarationIds, withInvoices);
    }

    public static List<Inward_Declaration__c> getTodayExistingInwardDeclarations()
    {
        return sel.selectTodayExistingInwardDeclarations();
    }
}