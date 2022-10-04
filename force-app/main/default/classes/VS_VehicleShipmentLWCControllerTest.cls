/*==========================================================================================================================================================================
 * Test class for VS_VehicleShipmentLWCController.cls
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           01 Sep 2022                       quy.nguyen@aodigy.com                 US-Ship-000027                                           Init
 * ========================================================================================================================================================================== 
 */

@IsTest
private with sharing class VS_VehicleShipmentLWCControllerTest
{
    static String invoiceNo = 'INV7007007';
    @TestSetup
    private static void setup()
    {
        Id principleOEMRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Principal')?.getRecordTypeId();
        Account supplier = Test_DataFactory.createAccount(false, 'Supplier Account');
        supplier.RecordTypeId = principleOEMRTId;
        insert supplier;

        // create HS HS_Type__c
        HS_Type__c hsCode = new HS_Type__c(Name='HS-123');
        insert hsCode;

        // create product code
        Product_Code__c proCode = new Product_Code__c(Name='PC Sun',Product_Code__c = 'PC-01');
        insert proCode;

        // create Vehicle_Shipment
        Vehicle_Shipment__c vs = new Vehicle_Shipment__c(
            Vessel_Name__c = 'vsnameso',
            Franchise_Code__c = 'KIAPC',
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD'
        );
        insert vs;
        
        //Create inwardDec
        Inward_Declaration__c inwardDec = new Inward_Declaration__c
        (
            Name = 'inwardDecTest',
            Vehicle_Shipment__c = vs.id,
            Transaction_ID__c='TS001'
        );
        insert inwardDec;  
        
        // create Inward Declaration Invoice
         Manufacturer_Invoice__c mInvoiceWithVs = new Manufacturer_Invoice__c(
            Vehicle_Shipment__c = vs.id,
            Name ='123test',
            Inward_Declaration__c = inwardDec.Id
        );
        insert mInvoiceWithVs;
        
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

        // create PO
        Vehicle_Purchase_Order__c order = new Vehicle_Purchase_Order__c(
            Franchise_Code__c = 'KIAPC',
            Production_Month__c = Date.today(),
            Supplier_Account__c = supplier.Id,
            Currency_Code__c = 'USD'
        );
        insert order;
        
        // create SVM
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearCode.Id, 'originalCommacase', 'systemCommcase');
		vm2.Vehicle_Shipment__c = vs.id;
        vm2.Vehicle_Purchase_Order__c = order.Id;
        vm2.Vehicle_Purchase_Status__c = 'In Shipment';
        vm2.Vehicle_Status__c = 'ORD';
        vm2.ProductionMonth__c= Date.today().addDays(5);
        vm2.Vehicle_Shipment__c =vs.id;
        vm2.Invoice_No__c= invoiceNo;
        vm2.Inward_Declaration_Invoice__c = mInvoiceWithVs.Id;
        vm2.Vessel_Name__c = 'vsnameso';
        vm2.TN_HS_Code__c = hsCode.id;
        vm2.Product_Code__c =proCode.id;
        insert vm2;

        // create SLI 
        Shipment_Line_Item__c sli = new Shipment_Line_Item__c(
            Vehicle_Shipment__c = vs.id,
            Production_Month__c = '7',
            Model__c = modelMaster.Id,
            Model_Year__c = modelYearCode.id, 
            Colour_Code__c= colorMaster.id,
            Trim__c = modelColorTrimMaster.id,
            Engine_No__c = 'ENGINE279831',
            Chassis_No__c = '12321'
        );
        insert sli;
    }

    @isTest
    private static void getUnmatchedLineItems_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id from Vehicle_Shipment__c LIMIT 1];
        String vsId = vs.id;
        Test.startTest();
        List<Shipment_Line_Item__c> sli = VS_VehicleShipmentLWCController.getUnmatchedLineItems(vsId);
        System.assert(sli.size()>0);    
        Test.stopTest();           
    }   

    @isTest
    private static void getManufacturerInvoices_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id from Vehicle_Shipment__c];
        Test.startTest();
        List<Manufacturer_Invoice__c> mInvoice = VS_VehicleShipmentLWCController.getManufacturerInvoices(vs.id);
        Test.stopTest();       
        System.assert(mInvoice.size() > 0);
    }

    @isTest
    private static void getStockVehicleMasters_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id from Vehicle_Shipment__c];
        Test.startTest();
        List<Vehicle_Master2__c> vm = VS_VehicleShipmentLWCController.getStockVehicleMasters(vs.id);
        Test.stopTest();       
        System.assert(vm.size() > 0);
    }

    @isTest
    private static void matchManufacturerInvoiceAndLineItem_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id FROM  Vehicle_Shipment__c Limit 1];
        Manufacturer_Invoice__c invoice = [SELECT id FROM 	Manufacturer_Invoice__c WHERE 	Vehicle_Shipment__c  =:vs.id ];
        List<Shipment_Line_Item__c> sli =[SELECT id FROM Shipment_Line_Item__c WHERE Vehicle_Shipment__c  =:vs.id ];
        list<string> sliId = new List<string>();
        for (Shipment_Line_Item__c sid : sli) 
        {
            sliId.add(sid.id);
        }
        Test.startTest();         
        System.assertEquals(true, VS_VehicleShipmentLWCController.matchManufacturerInvoiceAndLineItem(invoice.id ,sliId)  );
        Test.stopTest();         
    }

  
    @isTest
    private static void getVehicleShipmentWithInvoicesAndLineItems_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id FROM  Vehicle_Shipment__c Limit 1];     
        Test.startTest();     
        VS_VehicleShipmentLWCController.VehicleShipmentWrapper shipmentWrapperIPT =
        VS_VehicleShipmentLWCController.getVehicleShipmentWithInvoicesAndLineItems(vs.id , 'IPT'); 
        System.assert(shipmentWrapperIPT.vehicleMasters.size()>0);
        VS_VehicleShipmentLWCController.VehicleShipmentWrapper shipmentWrapperINP =
        VS_VehicleShipmentLWCController.getVehicleShipmentWithInvoicesAndLineItems(vs.id , 'INP'); 
        System.assert(shipmentWrapperINP.lineItems.size()>0);
        Test.stopTest();   
    }

    @isTest
    private static void getStockVehicleMastersForDutyRequest_Success ()
    { 
        Test.startTest();    
        List<Vehicle_Master2__c> vm = VS_VehicleShipmentLWCController.getStockVehicleMastersForDutyRequest();
        Test.stopTest();
    }

    @isTest
    private static void getGrouppedStockVehicleMasters_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id FROM  Vehicle_Shipment__c Limit 1];
        List<Vehicle_Master2__c>  svm = [SELECT id FROM Vehicle_Master2__c WHERE Vehicle_Shipment__c = :vs.id] ;
        list<string> svmId = new List<string>();
        for (Vehicle_Master2__c sid : svm) 
        {
            svmId.add(sid.id);
        }
        Test.startTest();       
        VS_VehicleShipmentLWCController.StockVehicleMasterWrapper StockVehicleMasterWrapper = VS_VehicleShipmentLWCController.getGrouppedStockVehicleMasters(svmId);
        System.assert(StockVehicleMasterWrapper.grouppedVehicles.size()>0);
        Test.stopTest();
    }

    @isTest
    private static void createInvoiceAndInwardDeclaration_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        String vesselName = vs.Vessel_Name__c;
        List<Vehicle_Master2__c>  svm = [SELECT id, Vessel_Name__c ,Invoice_No__c FROM Vehicle_Master2__c ] ;
        Map<string,List<Vehicle_Master2__c>> svmap = new Map<string,List<Vehicle_Master2__c>>{vesselName => svm};
        
        Test.startTest();
        system.assertNotEquals(null,VS_VehicleShipmentLWCController.createInvoiceAndInwardDeclaration(svmap));
        Test.stopTest();
    }

    @isTest
    private static void getGrouppedStockVehicleMastersByInwardDecId_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        Inward_Declaration__c inwardDec = [SELECT id FROM Inward_Declaration__c WHERE Vehicle_Shipment__c = :vs.id];
        String inwardDecId = inwardDec.id;
        Test.startTest();
        VS_VehicleShipmentLWCController.VehicleShipmentWrapper vehicleMasterWrapper= VS_VehicleShipmentLWCController.getGrouppedStockVehicleMastersByInwardDecId(inwardDecId);
        system.assert(vehicleMasterWrapper.vehicleMasters.size()>0);
        Test.stopTest();
    }


    @isTest
    private static void getManufacturerInvoicesByIds_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        List<Manufacturer_Invoice__c> inwardDecInvoice = [SELECT id FROM Manufacturer_Invoice__c WHERE 	Vehicle_Shipment__c = :vs.id];
        list<id> inwardDecInvoiceId = new list<id>();
        for (Manufacturer_Invoice__c mi : inwardDecInvoice) 
        {
            inwardDecInvoiceId.add(mi.id);
        }

        Test.startTest();
        List<Manufacturer_Invoice__c> inwardDecInvoiceNew = VS_VehicleShipmentLWCController.getManufacturerInvoicesByIds(inwardDecInvoiceId);
        system.assert(inwardDecInvoice.size()>0);
        Test.stopTest();
    }
    @isTest
    private static void submitToGetsAsiaIPT_success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        Inward_Declaration__c inwardDec = [SELECT id FROM Inward_Declaration__c WHERE Vehicle_Shipment__c = :vs.id];
        String inwardDecId = inwardDec.id;
        Vehicle_Master2__c svm = [SELECT id, TN_HS_Code__c FROM Vehicle_Master2__c WHERE Vehicle_Shipment__c = :vs.id ];
        String hsCode = svm.TN_HS_Code__c;
        List<Shipment_Line_Item__c> sli = new List<Shipment_Line_Item__c> ([SELECT id FROM Shipment_Line_Item__c WHERE TN_HS_Code__c  =:hsCode ]);
        List<string> sliId = new List<String>();
        for (Shipment_Line_Item__c si : sli) 
        {
            sliId.add(si.id);
        }
        Map<String, List<String>> grouppedItems = new Map<String, List<String>> {hsCode => sliId};
        Test.startTest();
        system.assertNotEquals(false, VS_VehicleShipmentLWCController.submitToGetsAsiaIPT(inwardDecId ,grouppedItems));
        Test.stopTest();
    }   

    @isTest
    private static void submitToGetsAsia_success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        Vehicle_Master2__c svm = [SELECT id, TN_HS_Code__c FROM Vehicle_Master2__c WHERE Vehicle_Shipment__c = :vs.id ];
        String hsCode = svm.TN_HS_Code__c;
        List<Shipment_Line_Item__c> sli = new List<Shipment_Line_Item__c> ([SELECT id FROM Shipment_Line_Item__c WHERE TN_HS_Code__c  =:hsCode ]);
        List<string> sliId = new List<String>();
        for (Shipment_Line_Item__c si : sli) 
        {
            sliId.add(si.id);
        }
        Map<String, List<String>> grouppedItems = new Map<String, List<String>> {hsCode => sliId};
        
        Test.startTest();
        system.assertNotEquals(false, VS_VehicleShipmentLWCController.submitToGetsAsia(vs.id , 'IPT',grouppedItems));
        Test.stopTest();
    }   
    @istest
    private static void submitToGetsAsiaINP_success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        Vehicle_Master2__c svm = [SELECT id, TN_HS_Code__c FROM Vehicle_Master2__c WHERE Vehicle_Shipment__c = :vs.id ];
        String hsCode = svm.TN_HS_Code__c;
        List<Shipment_Line_Item__c> sli = new List<Shipment_Line_Item__c> ([SELECT id FROM Shipment_Line_Item__c WHERE TN_HS_Code__c  =:hsCode ]);
        List<string> sliId = new List<String>();
        for (Shipment_Line_Item__c si : sli) 
        {
            sliId.add(si.id);
        }
        Map<String, List<String>> grouppedItems = new Map<String, List<String>> {hsCode => sliId};

        Test.startTest();
        system.assertNotEquals(false, VS_VehicleShipmentLWCController.submitToGetsAsia(vs.id , 'INP',grouppedItems));
        Test.stopTest();
    }  

    @isTest
    private static void retrievePermitNo_Success ()
    { 
        Test.setMock(HttpCalloutMock.class, new VS_VehicleShipmentCalloutMock());
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM Vehicle_Shipment__c Limit 1];
        Inward_Declaration__c inwardDec = [SELECT id FROM Inward_Declaration__c WHERE Vehicle_Shipment__c = :vs.id];
        String inwardDecId = inwardDec.id;
        ID id = inwardDecId;
        
        Test.startTest();
        system.assertNotEquals(false,VS_VehicleShipmentLWCController.retrievePermitNo(id));
        Test.stopTest();
    }

    @isTest
    private static void updatePermitNo_Success ()
    { 
        Vehicle_Shipment__c vs = [SELECT id, Vessel_Name__c FROM  Vehicle_Shipment__c Limit 1];
        Inward_Declaration__c inwardDec = [SELECT id FROM Inward_Declaration__c WHERE Vehicle_Shipment__c = :vs.id];
        String inwardDecId = inwardDec.id;
        ID idInward = inwardDecId;
        String vsId = vs.id;
        Id idVs =vsId ;
        string permitNo = 'PNO-2131234';
        
        Test.startTest();
        system.assertNotEquals(false,VS_VehicleShipmentLWCController.updatePermitNo(idInward,idVs,permitNo));
        Test.stopTest(); 
    }  
}