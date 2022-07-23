@isTest()
public class Test_restWarehouse{
    
    static testMethod void test_wareHouseDetails(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('Test');
        req.addParameter('source', 'democars');
        req.addParameter('branch', 'CCK');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(true,'test');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'Display';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Demo Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        restWarehouse.wareHouseDetails();
        Test.stopTest();
    }
    
    static testMethod void test_wareHouseDetails2(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('Test');
        req.addParameter('source', 'promocars');
        req.addParameter('branch', 'CCK');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(true,'test');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'New';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Promotional Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'New';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Promotional Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        restWarehouse.wareHouseDetails();
        Test.stopTest();
    }
    
    static testMethod void test_wareHouseDetails21(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('Test');
        req.addParameter('source', 'duplicate');
        req.addParameter('branch', 'CCK');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(true,'test');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'New';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Promotional Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'New';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Promotional Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        restWarehouse.wareHouseDetails();
        Test.stopTest();
    }
    
    static testMethod void test_wareHouseDetails3(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('Test');
        req.addParameter('source', 'demoandpromo');
        req.addParameter('branch', 'CCK');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(true,'test');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'Display';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Demo Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        restWarehouse.wareHouseDetails();
        Test.stopTest();
    }
    
    static testMethod void test_wareHouseDetails4(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('Test');
        req.addParameter('source', 'selectedcar');
        req.addParameter('branch', 'CCK');
        
        
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(true,'test');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'New';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Promotional Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;

        req.addParameter('stockId',  stprom.id );
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'New';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Promotional Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        restWarehouse.wareHouseDetails();
        Test.stopTest();
    }
    
    static testMethod void test_reserveWarehouseStock(){
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(false,'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'CITCV';
        insert mm;
        Campaign cp = Test_DataFactory.createCamp(true,'Test camp','Paid Events','CCK');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        vm.Franchise_Code__c = 'KIAPC';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        vm2.Franchise_Code__c = 'KIAPC';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'Display';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Demo Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c createVariant  = Test_DataFactory.createVariant(false,'test',md1.id, 'CCF');
        createVariant.Branch__c = 'CCK';
        createVariant.Franchise__c = 'KIAPC';
        createVariant.DWH_Variant_ID__c = 'CCK,CITCV,test';
        insert createVariant;
             
        map<String, Object> mapJSONBody = new map<String, Object>();
        map<String, Object> mapParams = new map<String, Object>();
        map<String, Object> mapCustomerDetails = new map<String, Object>();
        Account ac = Test_DataFactory.createAccount(true, 'test');
        
        Account paCust = Test_DataFactory.createPA(true, 'Name1', 'name1@test.com', 'Customer');
        Account paPros = Test_DataFactory.createPA(true, 'Name2', 'name2@test.com', 'Prospect');

        Contact c = Test_DataFactory.createContact(false, 'test', 'test', ac.id);
        c.email = 'test@jcc.com';
        c.Account__c = paCust.Id;
        insert c;
        
        Invoice__c inv = Test_DataFactory.createInvoice(false,c.id,null);
        inv.NRIC__C='198400907Z';
        inv.Transaction_Status__c='settled';
        inv.Vehicle_Registration_Number__c='SGU4225Z';
        inv.Transaction_ID__c='3ex4b0ym';
        inv.Campaign_ID__c=cp.id;
        inv.TC_Val__c = 'TestVal';
        inv.Department__c = 'CCK';
        inv.SeqNum__c = 314 ;
        inv.Account__c = paCust.Id;

        Insert inv;       
        Lead ld = Test_DataFactory.createLead(false, 'jcc', 'test');
        ld.Email = 'test@jcc.com';
        ld.Account__c = paPros.Id;
        insert ld;
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', ac.Id);
        opp.Lead__c = ld.id;
        insert opp;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        Map<String, Contact> ab =  new Map<String, Contact>();
        ab.put('customerInfo', c);
        User crUser = Test_DataFactory.createUser(true,'test','tst');
        string invoiceNumber = 'SG-CCK-'+String.ValueOF(System.Today().month()).leftPad(2,'0')+string.valueof(System.Today().year()).substring(2,4)+'-00000314';
        String vms = '{"customerInfo":{"LastName":"'+c.LastName+'", "FirstName":"'+c.FirstName+'", "AccountId":"'+c.AccountId+'","Email":"'+c.email+'","Id":"'+c.Id+'"},"StockVehicleMasterId":\"'+vm.Id+ '","SalesConsultantId":\"'+crUser.Id+'","TestDriveDate":\"'+System.today()+'","InvoiceNo":\"'+invoiceNumber+'","StockPromotionId":\"'+stprom.Id+'"}';
        req.requestBody =Blob.valueof(vms);
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        mapCustomerDetails = (map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapJSONBody.get('customerInfo')));
        req.addParameter('source', 'selectedcar');
        req.addParameter('branch', 'CCK');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms));
        restWarehouse.reserveWarehouseStock();
        restWarehouse.isValidateParamPassed();
        Test.stopTest();
    }
    
    static testMethod void test_reserveWarehouseStock2(){
        Campaign cp = Test_DataFactory.createCamp(true,'Test camp','Paid Events','CCK');
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(false,'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'CITCV';
        insert mm;
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        vm.Franchise_Code__c = 'KIAPC';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        vm2.Franchise_Code__c = 'KIAPC';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'Display';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Demo Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c createVariant  = Test_DataFactory.createVariant(false,'test',md1.id, 'CCF');
        createVariant.Branch__c = 'CCK';
        createVariant.Franchise__c = 'KIAPC';
        createVariant.DWH_Variant_ID__c = 'CCK,CITCV,test';
        insert createVariant;
             
        map<String, Object> mapJSONBody = new map<String, Object>();
        map<String, Object> mapParams = new map<String, Object>();
        map<String, Object> mapCustomerDetails = new map<String, Object>();
        Account ac = Test_DataFactory.createAccount(true, 'test');
        Contact c = Test_DataFactory.createContact(false, 'test', 'test', ac.id);
        c.email = 'con@jcc.com';
        insert c;
        
        Account acc = Test_DataFactory.createPA(true, 'Name4', 'name4@test.com', 'Customer');
        Invoice__c inv = Test_DataFactory.createInvoice(false,c.id,null); 
         inv.NRIC__C='198400907Z';
        inv.Transaction_Status__c='settled';
        inv.Vehicle_Registration_Number__c='SGU4225Z';
        inv.Transaction_ID__c='3ex4b0ym';
        inv.Campaign_ID__c=cp.id;
        inv.TC_Val__c = 'TestVal';
        inv.Department__c = 'CCK';
        inv.SeqNum__c = 314 ;
        inv.Account__c = acc.Id;
        
        Insert inv;         
             
        Lead ld = Test_DataFactory.createLead(false, 'jcc', 'test');
        ld.Email = 'ld@jcc.com';
        insert ld;
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', ac.Id);
        opp.Lead__c = ld.id;
        insert opp;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        Map<String, Contact> ab =  new Map<String, Contact>();
        ab.put('customerInfo', c);
        User crUser = Test_DataFactory.createUser(true,'test','tst');
        string invoiceNumber = 'SG-CCK-'+String.ValueOF(System.Today().month()).leftPad(2,'0')+string.valueof(System.Today().year()).substring(2,4)+'-00000314';
        String vms = '{"customerInfo":{"LastName":"'+c.LastName+'", "FirstName":"'+c.FirstName+'", "AccountId":"'+c.AccountId+'","Email":"'+ld.email+'","Id":"'+c.Id+'"},"StockVehicleMasterId":\"'+vm.Id+ '","SalesConsultantId":\"'+crUser.Id+'","TestDriveDate":\"'+System.today()+'","InvoiceNo":\"'+invoiceNumber+'","StockPromotionId":\"'+stprom.Id+'"}';
        req.requestBody =Blob.valueof(vms);
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        mapCustomerDetails = (map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapJSONBody.get('customerInfo')));
        req.addParameter('source', 'promocars');
        req.addParameter('branch', 'CCA');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms));
        restWarehouse.reserveWarehouseStock();
        restWarehouse.isValidateParamPassed();
        Test.stopTest();
    }
    
    static testMethod void test_reserveWarehouseStock3(){
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(false,'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'CITCV';
        insert mm;
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        vm.Franchise_Code__c = 'KIAPC';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        vm2.Franchise_Code__c = 'KIAPC';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'Display';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Demo Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Campaign cp = Test_DataFactory.createCamp(true,'Test camp','Paid Events','CCK');
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c createVariant  = Test_DataFactory.createVariant(false,'test',md1.id, 'CCF');
        createVariant.Branch__c = 'CCK';
        createVariant.Franchise__c = 'KIAPC';
        createVariant.DWH_Variant_ID__c = 'CCK,CITCV,test';
        insert createVariant;
             
        map<String, Object> mapJSONBody = new map<String, Object>();
        map<String, Object> mapParams = new map<String, Object>();
        map<String, Object> mapCustomerDetails = new map<String, Object>();
        Account ac = Test_DataFactory.createAccount(true, 'test');
        Contact c = Test_DataFactory.createContact(false, 'test', 'test', ac.id);
        c.email = 'con@jcc.com';
        insert c;
        
        Account acc = Test_DataFactory.createPA(true, 'Name3', 'name3@test.com', 'Customer');
        
        Invoice__c inv = Test_DataFactory.createInvoice(false,c.id,null); 
        inv.NRIC__C='198400907Z';
        inv.Transaction_Status__c='settled';
        inv.Vehicle_Registration_Number__c='SGU4225Z';
        inv.Transaction_ID__c='3ex4b0ym';
        inv.Campaign_ID__c= cp.id;
        inv.TC_Val__c = 'TestVal';
        inv.Department__c = 'CCK';
        inv.SeqNum__c = 314 ;
        inv.Account__c = acc.Id;

        Insert inv;              
        Lead ld = Test_DataFactory.createLead(false, 'jcc', 'test');
        ld.Email = 'ld@jcc.com';
        insert ld;
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', ac.Id);
        opp.Contact_Person__c = c.id;
        insert opp;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        Map<String, Contact> ab =  new Map<String, Contact>();
        ab.put('customerInfo', c);
        User crUser = Test_DataFactory.createUser(true,'test','tst');
        string invoiceNumber = 'SG-CCK-'+String.ValueOF(System.Today().month()).leftPad(2,'0')+string.valueof(System.Today().year()).substring(2,4)+'-00000314';
        String vms = '{"customerInfo":{"LastName":"'+c.LastName+'", "FirstName":"'+c.FirstName+'", "AccountId":"'+c.AccountId+'","Email":"ldff@jcc.com","Id":"'+c.Id+'"},"StockVehicleMasterId":\"'+vm.Id+ '","SalesConsultantId":\"'+crUser.Id+'","TestDriveDate":\"'+System.today()+'","InvoiceNo":\"'+invoiceNumber+'","StockPromotionId":\"'+stprom.Id+'"}';
        req.requestBody =Blob.valueof(vms);
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        mapCustomerDetails = (map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapJSONBody.get('customerInfo')));
        req.addParameter('source', 'demoandpromo');
        req.addParameter('branch', 'CCF');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms));
        restWarehouse.reserveWarehouseStock();
        restWarehouse.isValidateParamPassed();
        Test.stopTest();
    }
    
     static testMethod void test_reserveWarehouseStock_PromoCar(){
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Model_Master__c mm = Test_DataFactory.createModelCode(false,'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'CITCV';
        insert mm;
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id); 
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        vm.Franchise_Code__c = 'KIAPC';
        insert vm;
        
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm2.ProductionMonth__c = System.today();
        vm2.Vehicle_Status__c = 'RESRV';
        vm2.Branch_Code__c = 'CCK';
        vm2.Franchise_Code__c = 'KIAPC';
        insert vm2;
        
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        
        Stock_Promotion__c stprom2 = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm2.Id);
        stprom2.Vehicle_Sub_Type__c = 'Display';
        stprom2.Stock_Promotion_Status__c = 'ADD';
        stprom2.Vehicle_Type__c = 'Demo Cars';
        stprom2.Showroom__c = sh.Id;
        stprom2.Actual_Price__c = 100;
        stprom2.Discounted_Price__c = 90;
        stprom2.Mileage__c = 15;
        insert stprom2;
        
        Campaign campaign = new Campaign(Name = 'Kia Special Discount Exclusive Promo 4',
                                         Promo_Code__c = 'ILYMA2008',
                                         Promo_Category__c = 'Exclusive',
                                         Branch_Code__c = 'CCK',
                                         Brand__c = 'KIA',
                                         //RecordTypeId = '012O0000000brQ0IAI',
                                         StartDate = Date.today().addDays(-3),
                                         EndDate = Date.today().addDays(5), 
                                         Promo_Code_Type__c = 'Fixture');
        insert campaign;

        Campaign_Invited_members__c member = new Campaign_Invited_members__c(First_Name__c = 'Tori',
                                                                             Last_Name__c = 'Phan',
                                                                             Email__c = 'phan.thu@aodigy.com',
                                                                             Redeem__c = 'Open',
                                                                             Campaign__c = campaign.Id);
        insert member;
        
        Stock_Reservation__c stReservation = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        stReservation.Vehicle_Master__c = vm.Id;
        stReservation.Reservation_Status__c = 'Reserve';
        insert stReservation;
        
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c createVariant  = Test_DataFactory.createVariant(false,'test',md1.id, 'CCF');
        createVariant.Branch__c = 'CCK';
        createVariant.Franchise__c = 'KIAPC';
        createVariant.DWH_Variant_ID__c = 'CCK,CITCV,test';
        insert createVariant;
             
        map<String, Object> mapJSONBody = new map<String, Object>();
        map<String, Object> mapParams = new map<String, Object>();
        map<String, Object> mapCustomerDetails = new map<String, Object>();
        Account ac = Test_DataFactory.createAccount(true, 'test');
        Contact c = Test_DataFactory.createContact(false, 'test', 'test', ac.id);
        c.email = 'con@jcc.com';
        insert c;
        
        Account acc = Test_DataFactory.createPA(true, 'Name3', 'name3@test.com', 'Customer');
        
        Invoice__c inv = Test_DataFactory.createInvoice(false,c.id,null); 
        inv.NRIC__C='198400907Z';
        inv.Transaction_Status__c='settled';
        inv.Vehicle_Registration_Number__c='SGU4225Z';
        inv.Transaction_ID__c='3ex4b0ym';
        inv.Campaign_ID__c= campaign.id;
        inv.TC_Val__c = 'TestVal';
        inv.Department__c = 'CCK';
        inv.SeqNum__c = 314 ;
        inv.Account__c = acc.Id;

        Insert inv;              
        Lead ld = Test_DataFactory.createLead(false, 'jcc', 'test');
        ld.Email = 'ld@jcc.com';
        insert ld;
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', ac.Id);
        opp.Contact_Person__c = c.id;
        insert opp;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restWarehouse';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        Map<String, Contact> ab =  new Map<String, Contact>();
        ab.put('customerInfo', c);
        User crUser = Test_DataFactory.createUser(true,'test','tst');
        string invoiceNumber = 'SG-CCK-'+String.ValueOF(System.Today().month()).leftPad(2,'0')+string.valueof(System.Today().year()).substring(2,4)+'-00000314';
        String vms = '{"customerInfo":{"LastName":"'+c.LastName+'", "FirstName":"'+c.FirstName+'", "AccountId":"'+c.AccountId+'","Email":"ldff@jcc.com","Id":"'+c.Id+'"},"StockVehicleMasterId":\"'+vm.Id+ '","SalesConsultantId":\"'+crUser.Id+'","TestDriveDate":\"'+System.today()+'","InvoiceNo":\"'+invoiceNumber+'","StockPromotionId":\"'+stprom.Id+'","IsPromo": true,"PriceAfterDiscount": 98000,"CampaignId":\"'+campaign.Id+'","InvitedMemberId":\"'+member.Id+'","Description":"Free Camera","GiftItems":[{"Value":"Camera","Type":"Gift"}]}';
        System.debug('***********DEBUG: ' + vms);
         req.requestBody =Blob.valueof(vms);
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        mapCustomerDetails = (map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapJSONBody.get('customerInfo')));
        req.addParameter('source', 'demoandpromo');
        req.addParameter('branch', 'CCF');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms));
        restWarehouse.reserveWarehouseStock();
        restWarehouse.isValidateParamPassed();
        Test.stopTest();
    }
}