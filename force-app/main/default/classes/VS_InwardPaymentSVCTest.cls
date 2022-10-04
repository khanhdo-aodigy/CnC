/*==========================================================================================================================================================================
 * Test service class for Inward Payment
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           12 Sep 2022                       nam@aodigy.com                        US-Ship-000027                                            Init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class VS_InwardPaymentSVCTest {
    @TestSetup
    static void makeData(){
        
        // Create model master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        
        // create model year master
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        
        // create color master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        
        // create trim master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        // create stock vehicle master
        HS_Type__c hs = new HS_Type__c(
            Name = '12334'
        );
         insert hs;

        // create stock vehicle master
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            TN_HS_Code__c = hs.Id,
                                                            Duty_Payment_Date__c = Date.today());
        insert vMaster;
        
        // create manufacturer supplier
        Id principleOEMRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Principal')?.getRecordTypeId();
        Account supplier = Test_DataFactory.createAccount(false, 'Supplier Account');
        supplier.RecordTypeId = principleOEMRTId;
        insert supplier;

        //create vehicle shipment 
        Vehicle_Shipment__c VehicleShipment         = Test_DataFactory.createVehicleShipment(true, supplier.Id);

        // create manufacturer invoice
        Manufacturer_Invoice__c manufacturerInvoice = Test_DataFactory.createManufacturerInvoice(false);
        manufacturerInvoice.Invoice_No__c = 'INV56789';
        manufacturerInvoice.Vehicle_Shipment__c = VehicleShipment.Id;
        insert manufacturerInvoice;

        //create Inward Declaration
        Inward_Declaration__c inward = new Inward_Declaration__c
        (
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Inward_Payment' LIMIT 1].Id,
            Name = 'Inward Payment',
            Vehicle_Shipment__c = VehicleShipment.Id
        );
        insert inward;
    }

    @isTest
    public static void submitIPT_success() {
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock1());

        HS_Type__c hs  = [SELECT Id FROM HS_Type__c];  
        Inward_Declaration__c inw = [SELECT Id,RecordTypeId, Vehicle_Shipment__c FROM Inward_Declaration__c];
        List<Manufacturer_Invoice__c> mi = [SELECT Id,Invoice_No__c,Vehicle_Shipment__c FROM Manufacturer_Invoice__c];
        Vehicle_Master2__c svm = [SELECT Id,TN_HS_Code__c FROM Vehicle_Master2__c];
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c];
        List<String> b = new List<String>();
        b.add(svm.Id);

        // put data into maps.
        Map<String,List<String>> maps = new Map<String,List<String>>();
        maps.put(svm.TN_HS_Code__c,b); 

        Boolean res = VS_InwardPaymentSVC.submitIPT(shipment.Id, maps, true);
        System.assertNotEquals(null, shipment);
    }

    @isTest
    public static void testSubmitIPT_Record_Id_Is_Blank() {
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock1());

        HS_Type__c hs  = [SELECT Id FROM HS_Type__c];  
        Inward_Declaration__c inw = [SELECT Id,RecordTypeId, Vehicle_Shipment__c FROM Inward_Declaration__c];
        Manufacturer_Invoice__c mi = [SELECT Id,Invoice_No__c,Vehicle_Shipment__c FROM Manufacturer_Invoice__c];
        Vehicle_Master2__c svm = [SELECT Id,TN_HS_Code__c FROM Vehicle_Master2__c];
        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c];
    
        List<String> b = new List<String>();
        b.add(svm.Id);

        // put data into maps.
        Map<String,List<String>> maps = new Map<String,List<String>>();
        maps.put(svm.TN_HS_Code__c, b); 

        try {
            Boolean res = VS_InwardPaymentSVC.submitIPT('', maps,true);
        } catch (Exception e) {
            System.assertEquals('Empty Vehicle Shipment Id', e.getMessage());
        }
    }
}