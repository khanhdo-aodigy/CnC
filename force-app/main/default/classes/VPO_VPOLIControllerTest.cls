/*==========================================================================================================================================================================
 * VPO_VPOLIControllerTest for VPO_VPOLIController
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           10 Aug 2022                       dong.nguyen@aodigy.com                    US-VPO-000028                                          init
 * ========================================================================================================================================================================== 
 */
@IsTest
public with sharing class VPO_VPOLIControllerTest {
    @TestSetup
    private static void setUp()
    {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(false, 'Color Master', 'CM', 'KIA', 'KIAPC');
        colorMaster.Color_Description__c = 'description';
        colorMaster.Active__c = true;
        insert colorMaster;

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(false, 'Trim Master');
        trimMaster.Trim_Description__c = 'description';
        trimMaster.Active__c = true;
        insert trimMaster;

        //create model color trim master
        Model_Color_Trim_Master__c modelColorTrimMaster = Test_DataFactory.createModelColorTrimMaster(true, colorMaster.Id, modelMaster.Id, trimMaster.Id);
      
        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //create PO
        Vehicle_Purchase_Order__c order = Test_DataFactory.createVehiclePurchaseOrder(True, supplier.Id);

        // create Vehicle master2 
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, 'originalCommacase', 'systemCommcase');
		vm2.Vehicle_Purchase_Order__c = order.Id;
        vm2.ProductionMonth__c= Date.today().addDays(5);
        insert vm2;

        //create VPOLI
        Vehicle_Purchase_Order_Line_Items__c vpoli = Test_DataFactory.createVehiclePurchaseOrderedLineItems(true, order.Id, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelColorTrimMaster.Id, modelYearMaster.Id);

    }

    @IsTest
    private static void getVPOLIDetail_Test(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id, Vehicle_Purchase_Order__c, Units_Ordered__c FROM  Vehicle_Purchase_Order_Line_Items__c];
        List<Vehicle_Purchase_Order_Line_Items__c> test = VPO_VPOLIController.getVPOLIDetail(vpoli.Vehicle_Purchase_Order__c);
        System.assertEquals(5, test.get(0).Units_Ordered__c);
    }

    @IsTest
    private static void getVPOLIDetail_Error(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id, Vehicle_Purchase_Order__c, Units_Ordered__c FROM  Vehicle_Purchase_Order_Line_Items__c];
        try
        {
            List<Vehicle_Purchase_Order_Line_Items__c> test = VPO_VPOLIController.getVPOLIDetail('a');
        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());

        }

    }

    @IsTest
    private static void getColorMasters_Test(){
        Model_Color_Trim_Master__c mctm = [SELECT Id, Model_Code__c, Franchise_Code__c, Branch_Code__c  FROM Model_Color_Trim_Master__c];
        List<Model_Color_Trim_Master__c> test = VPO_VPOLIController.getColorMasters(mctm.Model_Code__c, mctm.Franchise_Code__c, mctm.Branch_Code__c );
        
        System.assertEquals(1, test.size());
        System.assertEquals('description',test.get(0).Color_Code__r.Color_Description__c);
    }

    @IsTest
    private static void getColorMasters_Error(){
        Model_Color_Trim_Master__c mctm = [SELECT Id, Franchise_Code__c FROM Model_Color_Trim_Master__c];
        try
        {
            List<Model_Color_Trim_Master__c> test = VPO_VPOLIController.getColorMasters('a',null,null);
        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());

        }

    }

    @IsTest
    private static void getTrimMasters_Test(){
        Model_Color_Trim_Master__c mctm = [SELECT Id, Model_Code__c,Color_Code__c FROM Model_Color_Trim_Master__c ];
        List<Model_Color_Trim_Master__c> test = VPO_VPOLIController.getTrimMasters(mctm.Model_Code__c, mctm.Color_Code__c);
        System.assertEquals(1, test.size());
    }

    @IsTest
    private static void getTrimMasters_Error(){
        Model_Color_Trim_Master__c mctm = [SELECT Id FROM Model_Color_Trim_Master__c ];
        try
        {
            List<Model_Color_Trim_Master__c> test = VPO_VPOLIController.getTrimMasters('a','a');
        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }

    }
    
    @IsTest
    private static void getModelYearMasters_Test(){
        Model_Year_Master__c mmy = [SELECT Id, Model_Master__c FROM Model_Year_Master__c ];
        List<Model_Year_Master__c> test = VPO_VPOLIController.getModelYearMasters(mmy.Model_Master__c);
        System.assertEquals(1, test.size());
    }

    @IsTest
    private static void getModelYearMasters_Error(){
        Model_Year_Master__c mmy = [SELECT Id FROM Model_Year_Master__c ];
        try
        {
            List<Model_Year_Master__c> test = VPO_VPOLIController.getModelYearMasters('a');
        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }

    }

    @IsTest 
    private static void getStockVehicelMasters_Test(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id, Vehicle_Purchase_Order__c  FROM  Vehicle_Purchase_Order_Line_Items__c];
        List<Vehicle_Master2__c> vm2 = VPO_VPOLIController.getStockVehicleMasters(vpoli.Vehicle_Purchase_Order__c);
        System.assertEquals(1, vm2.size());
    }

    @IsTest
    private static void getStockVehicelMasters_Error(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id  FROM  Vehicle_Purchase_Order_Line_Items__c];
        try
        {
            List<Vehicle_Master2__c> vm2 = VPO_VPOLIController.getStockVehicleMasters('a');

        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }

    }

    @IsTest
    private static void getVPOLI_Test(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id, Vehicle_Purchase_Order__c, Units_Ordered__c FROM  Vehicle_Purchase_Order_Line_Items__c];
        List<Vehicle_Purchase_Order_Line_Items__c> test = VPO_VPOLIController.getVPOLI(vpoli.Vehicle_Purchase_Order__c);
        System.assertEquals(5, test.get(0).Units_Ordered__c);
    }

    @IsTest
    private static void getVPOLI_Error(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id FROM  Vehicle_Purchase_Order_Line_Items__c];
        try
        {
            List<Vehicle_Purchase_Order_Line_Items__c> test = VPO_VPOLIController.getVPOLI('a');

        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }

    }
    
    @IsTest
    private static void upsertVPOLI_Test(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id FROM  Vehicle_Purchase_Order_Line_Items__c];
        Boolean vpoliTest = VPO_VPOLIController.upsertVPOLI(vpoli);
    }

    @IsTest
    private static void upsertVPOLI_Error(){
        Vehicle_Purchase_Order_Line_Items__c vpoli= [SELECT Id FROM  Vehicle_Purchase_Order_Line_Items__c];
        try
        {
            Boolean vpoliTest = VPO_VPOLIController.upsertVPOLI(null);

        }
        catch (Exception e) 
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    private static void getVPO_Test()
    {
       Vehicle_Purchase_Order__c vpo = [SELECT Id FROM Vehicle_Purchase_Order__c LIMIT 1];
       System.assertEquals(vpo.Id, VPO_VPOLIController.getVPO(vpo.Id).Id);
    }
}