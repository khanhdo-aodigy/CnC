@isTest
public with sharing class vpo_StockVehicleMasterIOControllerTest {

    
    @TestSetup
    static void makeData(){
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

        //create PO
        Vehicle_Purchase_Order__c order = Test_DataFactory.createVehiclePurchaseOrder(true, supplier.Id);
    
                
        // create Vehicle master2 
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, 'originalCommacase', 'systemCommcase');
		vm2.Vehicle_Purchase_Order__c = order.Id;
        vm2.ProductionMonth__c= Date.today().addDays(5);

        Vehicle_Master2__c vm3 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, 'originalCommacase', 'systemCommcase');
		vm3.Vehicle_Purchase_Order__c = order.Id;
        vm3.ProductionMonth__c= Date.today().addDays(5);

        insert new List<Vehicle_Master2__c> { vm2, vm3 };

        // query static resource

         String csv = String.format('Id,Name,Model_Code__r.Name,Color_Code__r.ColorCode__c,Color_Description__c,Trim_Code__r.Name,Trim_Description__c,Manufacturer_Ref_No__c\n{0},RVH-202208-153643,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,888\n{1},RVH-202208-153644,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,999', 
                                            new List<String> { vm2.Id, vm3.Id });  

                                            System.debug('csv=' + JSON.serialize(csv));
       
              
        //create ContentVersion
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            // VersionData = Blob.valueOf('Id,Name,Model_Code__r.Name,Color_Code__r.ColorCode__c,Color_Description__c,Trim_Code__r.Name,Trim_Description__c,Manufacturer_Ref_No__c\na0K0T000005WOoPUAW,RVH-202208-153643,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,888\na0K0T000005WOoUUAW,RVH-202208-153644,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,999'),
            VersionData = Blob.valueOf(csv),
            IsMajorVersion = true
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_3 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink
        ContentDocumentLink contentlink = new ContentDocumentLink(
            contentdocumentid = contentVersion_3.contentdocumentid,
            ShareType = 'V',
            LinkedEntityId = order.Id
        );
        insert contentlink; 

    }

    @isTest
    public static void getStockVehicleMaster_success(){
        Vehicle_Master2__c vehicleMaster = [SELECT Id, Vehicle_Purchase_Order__c FROM Vehicle_Master2__c LIMIT 1];
        List<Vehicle_Master2__c> listVM = vpo_StockVehicleMasterIOController.getStockVehicleMaster(vehicleMaster.Vehicle_Purchase_Order__c);
        System.assertEquals(2,listVM.size());
    }

    @isTest
    public static void getStockVehicleMaster_error(){
        Vehicle_Master2__c vehicleMaster = [SELECT Id, CreatedById FROM Vehicle_Master2__c LIMIT 1];
        try {
            List<Vehicle_Master2__c> listVM = vpo_StockVehicleMasterIOController.getStockVehicleMaster('#');


        } catch (Exception e) {
              System.assertEquals('v', e.getMessage());
        }
    }

    @isTest
    public static void updateStockVehicleMaster_success(){
        ContentVersion contentVersion_2 = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion];

        Vehicle_Master2__c vehicleMaster = [SELECT Id, Vehicle_Purchase_Order__c FROM Vehicle_Master2__c LIMIT 1];

        vpo_StockVehicleMasterIOController.updateStockVehicleMaster(vehicleMaster.Vehicle_Purchase_Order__c, contentVersion_2.ContentDocumentId, contentVersion_2.Id);
    }


    @isTest
    static void updateStockVehicleMaster_error(){
        Vehicle_Master2__c[] vehicleMaster = [SELECT Id, Vehicle_Purchase_Order__c FROM Vehicle_Master2__c];

        String csv_1 = String.format('Id,Name,Model_Code__r.Name,Color_Code__r.ColorCode__c,Color_Description__c,Trim_Code__r.Name,Trim_Description__c,Manufacturer_Ref_No__c\n{0},RVH-202208-153643,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,999\n{1},RVH-202208-153644,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,999', 
        new List<String> { vehicleMaster.get(0).Id, vehicleMaster.get(1).Id });
        
        ContentDocument cd = [SELECT Id FROM ContentDocument];
        
        ContentVersion updateContentVersion = new ContentVersion(
            Title = 'Emperor Penguins',
            PathOnClient = 'Emperor Penguins.jpg',
            VersionData = Blob.valueOf(csv_1),
            IsMajorVersion = true,
            ContentDocumentId = cd.Id
        );
        insert updateContentVersion;

		try
        {
        	vpo_StockVehicleMasterIOController.updateStockVehicleMaster(vehicleMaster.get(0).Vehicle_Purchase_Order__c, updateContentVersion.ContentDocumentId, updateContentVersion.Id);    
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.assert(e.getMessage().contains('DUPLICATE_VALUE'), 'Actual message is: ' + e.getMessage());
        }
        
    }

    @isTest
    public static void deleteUploadedReport_success(){
        ContentVersion contentVersion_2 = [SELECT Id, ContentDocumentId FROM ContentVersion];
        vpo_StockVehicleMasterIOController.deleteUploadedReport(contentVersion_2.ContentDocumentId);
        System.assertNotEquals(null,  contentVersion_2.ContentDocumentId);
    }
}