/*==========================================================================================================================================================================
 * VPO_massEditSVMExtensionTest for VPO_massEditSVMExtension
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           10 Aug 2022                       dong.nguyen@aodigy.com                    US-VPO-000028                                          init
 * ========================================================================================================================================================================== 
 */
@Istest
public with sharing class VPO_massEditSVMExtensionTest {

    @IsTest
    private static void VPO_massEditSVMExtension_Test(){
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');

        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        // create PO
        Vehicle_Purchase_Order__c order = Test_DataFactory.createVehiclePurchaseOrder(true, supplier.Id);

        // create Vehicle master2 
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, 'originalCommacase', 'systemCommcase');
		vm2.Vehicle_Purchase_Order__c = order.Id;
        vm2.ProductionMonth__c= Date.today().addDays(5);
        insert vm2;

        ApexPages.standardSetController sc = new ApexPages.standardSetController(new List<Vehicle_Master2__c> {vm2});
        VPO_massEditSVMExtension massEdit = new VPO_massEditSVMExtension(sc);
    }
}