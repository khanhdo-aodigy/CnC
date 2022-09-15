/*==========================================================================================================================================================================
 * Extention controller for VPO_editVPOLIPage.page
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           07 Aug 2022                       dong.nguyen@aodigy.com                    US-VPO-000027                                          init
 * ========================================================================================================================================================================== 
 */
public with sharing class VPO_EditVPOLIPageExtension {
    public List<Vehicle_Purchase_Order_Line_Items__c> VPOLIs {get; private set;}

    public VPO_EditVPOLIPageExtension(ApexPages.StandardSetController stdSetController) {
        VPOLIs = (List<Vehicle_Purchase_Order_Line_Items__c>) stdSetController.getSelected();
    }
   
}