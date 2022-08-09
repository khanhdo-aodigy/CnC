/*==========================================================================================================================================================================
 * Extention controller for VPO_MassEditSVM.page
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           05 Aug 2022                       phan.thu@aodigy.com                    US-VPO-000028                                          init
 * ========================================================================================================================================================================== 
 */

public class VPO_massEditSVMExtension 
{
    public List<Vehicle_Master2__c> vehicleMasters {get; private set;}

    public VPO_massEditSVMExtension(ApexPages.StandardSetController stdSetController)
    {
        vehicleMasters = (List<Vehicle_Master2__c>) stdSetController.getSelected();
    }
}