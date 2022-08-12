/*==========================================================================================================================================================================
 * VPO_EditVPOLIPageExtensionTest for VPO_EditVPOLIPageExtension
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           10 Aug 2022                       dong.nguyen@aodigy.com                    US-VPO-000028                                          init
 * ========================================================================================================================================================================== 
 */

@IsTest
public with sharing class VPO_EditVPOLIPageExtensionTest {
    @IsTest
    public static void VPO_EditVPOLIPageExtensionTest() {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        //create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        //create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');

        //create model color trim master
        Model_Color_Trim_Master__c modelColorTrimMaster = Test_DataFactory.createModelColorTrimMaster(true, colorMaster.Id, modelMaster.Id, trimMaster.Id);

        //create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        //create suplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //create PO
        Vehicle_Purchase_Order__c order = Test_DataFactory.createVehiclePurchaseOrder(True, supplier.Id);

        //create VPOLI
        Vehicle_Purchase_Order_Line_Items__c vpoli = Test_DataFactory.createVehiclePurchaseOrderedLineItems(true, order.Id, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelColorTrimMaster.Id, modelYearMaster.Id);

        List<Vehicle_Purchase_Order_Line_Items__c> vp = [SELECT Id FROM Vehicle_Purchase_Order_Line_Items__c];
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(vp);
        VPO_EditVPOLIPageExtension massEdit = new VPO_EditVPOLIPageExtension(sc);
    }
}