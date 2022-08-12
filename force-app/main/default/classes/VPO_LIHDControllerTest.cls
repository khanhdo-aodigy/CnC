@isTest
public class VPO_LIHDControllerTest {
	@testSetup static void setUp(){
		// create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');
        
        // create model year master
        Model_Year_Master__c  modelYearCode = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');
               
        // create model color trim master
        Model_Color_Trim_Master__c modelColorTrimMaster = new Model_Color_Trim_Master__c(
            Name = 'Model Color Trim Master',
            Branch_Code__c = 'KIA',
            Franchise_Code__c = 'KIAPC',
            Model_Code__c = modelMaster.Id,
            Color_Code__c = colorMaster.Id,
            Trim_Code__c = trimMaster.Id
        );
        insert modelColorTrimMaster;

        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        // create PO
        Vehicle_Purchase_Order__c order = new Vehicle_Purchase_Order__c(
            Franchise_Code__c = 'KIAPC',
            Production_Month__c = Date.today(),
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD'
        );
        insert order;
        
        // create POLIs
        final Integer POLI_NO = 10;

        List<Vehicle_Purchase_Order_Line_Items__c> polis = new List<Vehicle_Purchase_Order_Line_Items__c>();

        for (Integer i = 0; i < POLI_NO; i++)
        {
            polis.add(new Vehicle_Purchase_Order_Line_Items__c(
                Vehicle_Purchase_Order__c = order.Id,
                Model_Master__c = modelMaster.Id,
                Color_Master__c = colorMaster.Id,
                Trim_Master__c = trimMaster.Id,
                Model_Color_Trim_Master__c = modelColorTrimMaster.Id,
                Model_Year_Master__c = modelYearMaster.Id,
                Units_Ordered__c = 5
            ));
        }

        insert polis;

        Attachment snapshot = new Attachment(
                Name = 'snapshot.txt',
                Description = '#snapshot',
                Body = Blob.valueOf('{"Color_Master__c": "a0C1e0000016xYZEAY"}'),
                ParentId = order.Id
            );
        insert snapshot;
        
    }

    /**
     *  test 
     *  expected: 
     */
    @isTest 
    private static void VehiclePurchaseOrderHistoryTest(){
       List<Vehicle_Purchase_Order__c> orders = [SELECT Id, Stage__c FROM Vehicle_Purchase_Order__c];
       List<Attachment> snapshots = [SELECT Id, Body, Description FROM Attachment];
       Test.startTest();
       VPO_LineItemsHistoryDashboardController.init(orders[0].Id);
       Test.stopTest();
       
    }
}