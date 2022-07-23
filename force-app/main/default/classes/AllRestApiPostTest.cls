@isTest
public class AllRestApiPostTest {
    
    static testMethod void testColorMasterPost(){
        test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        req.requestURI = sfdcBaseURL + '/services/apexrest/ColorMaster';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('Code', 'Blue');
        RestContext.request = req;
        RestContext.response = res;
        ColorMasterPost.getPost();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/ColorMaster';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Insert');
        req2.addParameter('Code', 'Blue');
        RestContext.request = req2;
        RestContext.response = res2;
        ColorMasterPost.getPost();
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = sfdcBaseURL + '/services/apexrest/ColorMaster';  
        req1.httpMethod = 'POST';
        req1.addParameter('Action', 'Update');
        req1.addParameter('Code', 'Blue');
        RestContext.request = req1;
        RestContext.response = res1;
        ColorMasterPost.getPost();
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/ColorMaster';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Update');
        req3.addParameter('Code', 'Red');
        RestContext.request = req3;
        RestContext.response = res3;
        ColorMasterPost.getPost();
        test.stopTest();
    }
    static testMethod void testModelMasterPost(){
        test.startTest();
        //case insert failed throw eror
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        req.requestURI = sfdcBaseURL + '/services/apexrest/ModelMaster';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('Code', 'Carnival');
        req.addParameter('BHP', '321');
        req.addParameter('BodyStyle', '321');
        RestContext.request = req;
        RestContext.response = res;
        ModelMasterPost.getPost();
        
        //case insert success
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = sfdcBaseURL + '/services/apexrest/ModelMaster';  
        req1.httpMethod = 'POST';
        req1.addParameter('Action', 'Insert');
        req1.addParameter('Code', 'Carnival');
        req1.addParameter('BHP', '321');
        req1.addParameter('BodyStyle', '321');
        req1.addParameter('BranchCode', 'CCK');
        req1.addParameter('COECategory', '321');
        req1.addParameter('Commission', '321');
        req1.addParameter('Decomission', '321');
        req1.addParameter('EngineCapacity', '1500');
        req1.addParameter('FranchiseCode', 'KIAPC');
        req1.addParameter('FuelCapacity', '20');
        req1.addParameter('FuelType', '321');
        req1.addParameter('GMDiscountLimit', '10');
        req1.addParameter('GSTCode', '321');
        req1.addParameter('LaunchDate', '12:03:2012');
        req1.addParameter('MajorGroupCode', '321');
        req1.addParameter('ManufactureCode', '321');
        req1.addParameter('MinimunDepositAmount', '2000');
        req1.addParameter('MinorGroupCode', '321');
        req1.addParameter('ModelDescription', '321');
        req1.addParameter('ModelShortDescription', '321');
        req1.addParameter('ModelStatus', 'A');
        req1.addParameter('ModelType', '321');
        req1.addParameter('NEACNGCorNo', '321');
        req1.addParameter('NEACorNo', '321');
        req1.addParameter('NEAFuelConsumption', '123');
        req1.addParameter('NEAModelCode', 'NEAModelCode Sample');
        req1.addParameter('NEAModelDescription', 'NEAModelDescription Sample');
        req1.addParameter('NoOfDoors', '4');
        req1.addParameter('NoOfGears', '6');
        req1.addParameter('NoOfWeeksDelivery', '2');
        req1.addParameter('OutOfProductionDate', '20:09:2015');
        req1.addParameter('SalesManagerDiscountLimit', '5');
        req1.addParameter('SalesRepDiscountLimit', '3');
        req1.addParameter('Transmission', '3');
        req1.addParameter('VITASCode', '321');
        req1.addParameter('WarrantyMileage', '2');
        req1.addParameter('WarrantyMonths', '24');
        RestContext.request = req1;
        RestContext.response = res1;
        ModelMasterPost.getPost();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/ModelMaster';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Update');
        req2.addParameter('Code', 'Carnival');
        req2.addParameter('BHP', '321');
        req2.addParameter('BodyStyle', '321');
        req2.addParameter('BranchCode', 'CCK');
        req2.addParameter('COECategory', '321');
        req2.addParameter('Commission', '321');
        req2.addParameter('Decomission', '321');
        req2.addParameter('EngineCapacity', '1500');
        req2.addParameter('FranchiseCode', 'KIAPC');
        req2.addParameter('FuelCapacity', '20');
        req2.addParameter('FuelType', '1500');
        req2.addParameter('GMDiscountLimit', '10');
        req2.addParameter('GSTCode', '321');
        req2.addParameter('LaunchDate', '12:03:2012');
        req2.addParameter('MajorGroupCode', '321');
        req2.addParameter('ManufactureCode', '321');
        req2.addParameter('MinimunDepositAmount', '2000');
        req2.addParameter('MinorGroupCode', '321');
        req2.addParameter('ModelDescription', '321');
        req2.addParameter('ModelShortDescription', '321');
        req2.addParameter('ModelStatus', 'A');
        req2.addParameter('ModelType', '321');
        req2.addParameter('NEACNGCorNo', '321');
        req2.addParameter('NEACorNo', '321');
        req2.addParameter('NEAFuelConsumption', '321');
        req2.addParameter('NEAModelCode', 'NEAModelCode Sample');
        req2.addParameter('NEAModelDescription', 'NEAModelDescription Sample');
        req2.addParameter('NoOfDoors', '4');
        req2.addParameter('NoOfGears', '6');
        req2.addParameter('NoOfWeeksDelivery', '2');
        req2.addParameter('OutOfProductionDate', '20:09:2015');
        req2.addParameter('SalesManagerDiscountLimit', '5');
        req2.addParameter('SalesRepDiscountLimit', '3');
        req2.addParameter('Transmission', '3');
        req2.addParameter('VITASCode', '321');
        req2.addParameter('WarrantyMileage', '2');
        req2.addParameter('WarrantyMonths', '24');
        RestContext.request = req2;
        RestContext.response = res2;
        ModelMasterPost.getPost();
        
        //case insert failed duplicate record
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/ModelMaster';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Insert');
        req3.addParameter('Code', 'Carnival');
        req3.addParameter('BHP', '321');
        req3.addParameter('BodyStyle', '321');
        req3.addParameter('BranchCode', 'CCK');
        req3.addParameter('COECategory', '321');
        req3.addParameter('Commission', '321');
        req3.addParameter('Decomission', '321');
        req3.addParameter('EngineCapacity', '1500');
        req3.addParameter('FranchiseCode', 'KIAPC');
        req3.addParameter('FuelCapacity', '20');
        req3.addParameter('FuelType', '321');
        req3.addParameter('GMDiscountLimit', '10');
        req3.addParameter('GSTCode', '321');
        req3.addParameter('LaunchDate', '12:03:2012');
        req3.addParameter('MajorGroupCode', '321');
        req3.addParameter('ManufactureCode', '321');
        req3.addParameter('MinimunDepositAmount', '2000');
        req3.addParameter('MinorGroupCode', '321');
        req3.addParameter('ModelDescription', '321');
        req3.addParameter('ModelShortDescription', '321');
        req3.addParameter('ModelStatus', 'A');
        req3.addParameter('ModelType', '321');
        req3.addParameter('NEACNGCorNo', '321');
        req3.addParameter('NEACorNo', '321');
        req3.addParameter('NEAFuelConsumption', '123');
        req3.addParameter('NEAModelCode', 'NEAModelCode Sample');
        req3.addParameter('NEAModelDescription', 'NEAModelDescription Sample');
        req3.addParameter('NoOfDoors', '4');
        req3.addParameter('NoOfGears', '6');
        req3.addParameter('NoOfWeeksDelivery', '2');
        req3.addParameter('OutOfProductionDate', '20:09:2015');
        req3.addParameter('SalesManagerDiscountLimit', '5');
        req3.addParameter('SalesRepDiscountLimit', '3');
        req3.addParameter('Transmission', '3');
        req3.addParameter('VITASCode', '321');
        req3.addParameter('WarrantyMileage', '2');
        req3.addParameter('WarrantyMonths', '24');
        RestContext.request = req3;
        RestContext.response = res3;
        ModelMasterPost.getPost();
        
        test.stopTest();
    }
    static testMethod void testModelYearMasterPost(){
        test.startTest();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Model_Master__c mm=new Model_Master__c();
        mm.Name='Carnival1';
        mm.Branch_Code__c='CCK';
        mm.Franchise_Code__c='KIAPC';
        insert mm;
        
        //case insert throw eror
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = sfdcBaseURL + '/services/apexrest/ModelYearMaster';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('ModelCode', 'Carnival1');
        req.addParameter('FOBAmount', '321');
        req.addParameter('DutyAmount', '321');
        req.addParameter('FranchiseCode', 'KIAPC');
        req.addParameter('BranchCode', 'CCK');
        req.addParameter('LaunchDate', '03:10:2014');
        req.addParameter('ModelYear', '2014'); //eror value to throw eror
        req.addParameter('Status', 'A');
        req.addParameter('OutOfProductionDate', '03:10:2016');
        RestContext.request = req;
        RestContext.response = res;
        ModelYearMasterPost.getPost();
        
        //case insert succes
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = sfdcBaseURL + '/services/apexrest/ModelYearMaster';  
        req1.httpMethod = 'POST';
        req1.addParameter('Action', 'Insert');
        req1.addParameter('ModelCode', 'Carnival1');
        req1.addParameter('FOBAmount', '321');
        req1.addParameter('DutyAmount', '321');
        req1.addParameter('FranchiseCode', 'KIAPC');
        req1.addParameter('BranchCode', 'CCK');
        req1.addParameter('LaunchDate', '03:10:2014');
        req1.addParameter('ModelYear', '03:10:2014');
        req1.addParameter('Status', 'A');
        req1.addParameter('OutOfProductionDate', '03:10:2016');
        RestContext.request = req1;
        RestContext.response = res1;
        ModelYearMasterPost.getPost();
        
        //case update succes
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/ModelYearMaster';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Update');
        req2.addParameter('ModelCode', 'Carnival1');
        req2.addParameter('FOBAmount', '321');
        req2.addParameter('DutyAmount', '321');
        req2.addParameter('FranchiseCode', 'KIAPC');
        req2.addParameter('BranchCode', 'CCK');
        req2.addParameter('LaunchDate', '03:10:2014');
        req2.addParameter('ModelYear', '03:10:2014');
        req2.addParameter('Status', 'A');
        req2.addParameter('OutOfProductionDate', '03:10:2016');
        RestContext.request = req2;
        RestContext.response = res2;
        ModelYearMasterPost.getPost();
        
        //case insert duplicate record
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/ModelYearMaster';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Insert');
        req3.addParameter('ModelCode', 'Carnival1');
        req3.addParameter('FOBAmount', '321');
        req3.addParameter('DutyAmount', '321');
        req3.addParameter('FranchiseCode', 'KIAPC');
        req3.addParameter('BranchCode', 'CCK');
        req3.addParameter('LaunchDate', '03:10:2014');
        req3.addParameter('ModelYear', '03:10:2014');
        req3.addParameter('Status', 'A');
        req3.addParameter('OutOfProductionDate', '03:10:2016');
        RestContext.request = req3;
        RestContext.response = res3;
        ModelYearMasterPost.getPost();
        
        test.stopTest();
    }
    static testMethod void testMtcMasterPost(){
        test.startTest();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Model_Master__c mm=new Model_Master__c();
            mm.Name='Carnival';
            mm.Branch_Code__c='CCK';
            mm.Franchise_Code__c='KIAPC';
        insert mm;
        Color_Master__c cm=new Color_Master__c();
            cm.Name='Blue';
            cm.Branch_Code__c='CCK';
            cm.Franchise_Code__c='KIAPC';
        insert cm;
        Trim_Master__c tm=new Trim_Master__c();
            tm.Name='BB';
            tm.Branch_Code__c='CCK';
            tm.Franchise_Code__c='KIAPC';
        insert tm;
        //case insert Success
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = sfdcBaseURL + '/services/apexrest/MTCMaster';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('Status', 'A');
        req.addParameter('FranchiseCode', 'KIAPC');
        req.addParameter('BranchCode', 'CCK');
        req.addParameter('ColorCode', 'Blue');
        req.addParameter('ModelCode', 'Carnival');
        req.addParameter('TrimCode', 'BB');
        RestContext.request = req;
        RestContext.response = res;
        MTCMasterPost.getPost();
        
        //case duplicate record
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = sfdcBaseURL + '/services/apexrest/MTCMaster';  
        req1.httpMethod = 'POST';
        req1.addParameter('Action', 'Insert');
        req1.addParameter('Status', 'A');
        req1.addParameter('FranchiseCode', 'KIAPC');
        req1.addParameter('BranchCode', 'CCK');
        req1.addParameter('ColorCode', 'Blue');
        req1.addParameter('ModelCode', 'Carnival');
        req1.addParameter('TrimCode', 'BB');
        RestContext.request = req1;
        RestContext.response = res1;
        MTCMasterPost.getPost();
        
        //case update succes
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/MTCMaster';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Update');
        req2.addParameter('Status', 'A');
        req2.addParameter('FranchiseCode', 'KIAPC');
        req2.addParameter('BranchCode', 'CCK');
        req2.addParameter('ColorCode', 'Blue');
        req2.addParameter('ModelCode', 'Carnival');
        req2.addParameter('TrimCode', 'BB');
        RestContext.request = req2;
        RestContext.response = res2;
        MTCMasterPost.getPost();
        
        //update throw eror
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/MTCMaster';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Update');
        req3.addParameter('Status', 'A');
        req3.addParameter('FranchiseCode', 'KIAPC');
        req3.addParameter('BranchCode', 'CCK');
        req3.addParameter('ColorCode', 'Blue1');
        req3.addParameter('ModelCode', 'Carnival1');
        req3.addParameter('TrimCode', 'BB1');
        RestContext.request = req3;
        RestContext.response = res3;
        MTCMasterPost.getPost();
        
        test.stopTest();
    }
    static testMethod void testStockPromoPost(){
        test.startTest();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Model_Master__c mm=new Model_Master__c();
            mm.Name='Carnival';
            mm.Branch_Code__c='CCK';
            mm.Franchise_Code__c='KIAPC';
        insert mm;
        Color_Master__c cm=new Color_Master__c();
            cm.Name='Blue';
            cm.Branch_Code__c='CCK';
            cm.Franchise_Code__c='KIAPC';
        insert cm;
        Trim_Master__c tm=new Trim_Master__c();
            tm.Name='BB';
            tm.Branch_Code__c='CCK';
            tm.Franchise_Code__c='KIAPC';
        insert tm;
        Model_Year_Master__c mym = new Model_Year_Master__c();
            mym.Model_Master__c=mm.id;
            mym.Branch_Code__c='CCK';
            mym.Franchise_Code__c='KIAPC';
        insert mym;
        Vehicle_Master2__c vm = new Vehicle_Master2__c();
            vm.System_Commcase__c='TEXT20';
            vm.Original_Commcase__c='test';
            vm.Branch_Code__c='CCK';
            vm.Franchise_Code__c='KIAPC';
            vm.Model_Code__c=mm.id;
            vm.Color_Code__c=cm.id;
            vm.Trim_Code__c=tm.id;
            vm.Model_Year_Code__c=mym.id;
            vm.ProductionMonth__c=system.today();
        insert vm;
        
        //case insert succes
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = sfdcBaseURL + '/services/apexrest/StockPromo';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('SystemCommcase', 'TEXT20');
        req.addParameter('Comment', 'Long Text Area 500');
        req.addParameter('Status', 'Active');
        RestContext.request = req;
        RestContext.response = res;
        StockPromoPost.getPost();
        
        //case insert duplicate record
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = sfdcBaseURL + '/services/apexrest/StockPromo';  
        req1.httpMethod = 'POST';
        req1.addParameter('Action', 'Insert');
        req1.addParameter('SystemCommcase', 'TEXT20');
        req1.addParameter('Comment', 'Long Text Area 500');
        req1.addParameter('Status', 'Active');
        RestContext.request = req1;
        RestContext.response = res1;
        StockPromoPost.getPost();
        
        //case update
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/StockPromo';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Update');
        req2.addParameter('SystemCommcase', 'TEXT20');
        req2.addParameter('Comment', 'Long Text Area 500');
        req2.addParameter('Status', 'Active');
        RestContext.request = req2;
        RestContext.response = res2;
        StockPromoPost.getPost();
        
        //case throw eror
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/StockPromo';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Update');
        req3.addParameter('SystemCommcase', 'TEXT201');
        req3.addParameter('Comment', 'Long Text Area 500');
        req3.addParameter('Status', 'Active');
        RestContext.request = req3;
        RestContext.response = res3;
        StockPromoPost.getPost();
        
        test.stopTest();
    }
    static testMethod void testStockReservationPost(){
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='KIA Sales'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        system.runAs(u2){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Model_Master__c mm=new Model_Master__c();
            mm.Name='Carnival';
            mm.Branch_Code__c='CCK';
            mm.Franchise_Code__c='KIAPC';
        insert mm;
        Color_Master__c cm=new Color_Master__c();
            cm.Name='Blue';
            cm.Branch_Code__c='CCK';
            cm.Franchise_Code__c='KIAPC';
        insert cm;
        Trim_Master__c tm=new Trim_Master__c();
            tm.Name='BB';
            tm.Branch_Code__c='CCK';
            tm.Franchise_Code__c='KIAPC';
        insert tm;
        Model_Year_Master__c mym = new Model_Year_Master__c();
            mym.Model_Master__c=mm.id;
            mym.Branch_Code__c='CCK';
            mym.Franchise_Code__c='KIAPC';
        insert mym;
        Vehicle_Master2__c vm = new Vehicle_Master2__c();
            VM.Trim_Code__c = tm.Id;
            VM.Color_Code__c = CM.Id;
            VM.Model_Code__c = MM.Id;
            VM.Model_Year_Code__c = MYM.Id;
            VM.Original_Commcase__c = '12345';
            VM.System_Commcase__c = '12345';
            VM.ProductionMonth__c=system.today();
        insert vm;
        Contact c = new Contact();
            c.lastname='test';
            c.NRIC_Passport_No__c='12345';
        insert c;
        Opportunity opp= new Opportunity();
            opp.Contact_Person__c=c.id;
            opp.Name='Test';
            opp.StageName='Open';
            opp.closeDate=system.today().addDays(2);
        insert opp;
        Stock_Reservation__c sr=new Stock_Reservation__c();
            sr.Model_Code__c=mm.id;
            sr.Model_Year_Code__c=mym.id;
            sr.Color_Code__c=cm.id;
            sr.Trim_Code__c=tm.id;
            sr.Vehicle_Master__c=vm.id;
            sr.Franchise_Code__c='KIAPC';
            sr.Customer_Social_ID__c='1234';
            sr.Customer_Name__c='test';
            sr.Customer_Mobile_Number__c='89898989';
            sr.Opportunity__c=opp.id;
            sr.Downpayment_No__c='100';
        insert sr;
        
        //case success update
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = sfdcBaseURL + '/services/apexrest/StockReservation';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Update');
        req.addParameter('ID', sr.id);
        req.addParameter('Status', 'Reserved');
        req.addParameter('AgreementNo', '123');
        req.addParameter('CommCase', '123');
        RestContext.request = req;
        RestContext.response = res;
        StockReservationPost.getPost();
        
        //case failed update
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/StockReservation';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Update');
        req2.addParameter('ID', '1234');
        req2.addParameter('Status', 'Reserved');
        req2.addParameter('AgreementNo', '123');
        req2.addParameter('CommCase', '123');
        RestContext.request = req2;
        RestContext.response = res2;
        StockReservationPost.getPost();
        
        //case change
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/StockReservation';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Change');
        req3.addParameter('ID', sr.id);
        req3.addParameter('Status', 'Reserved');
        req3.addParameter('AgreementNo', '123');
        req3.addParameter('CommCase', '123');
        RestContext.request = req3;
        RestContext.response = res3;
        StockReservationPost.getPost();
        }
        test.stopTest();
    }
    static testMethod void testTrimMasterPost(){
        test.startTest();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        //case insert succes
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = sfdcBaseURL + '/services/apexrest/TrimMaster';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('Code', 'Carnival');
        req.addParameter('Status', 'A');
        req.addParameter('Description', 'Description');
        req.addParameter('FranchiseCode', 'KIAPC');
        req.addParameter('BranchCode', 'CCK');
        RestContext.request = req;
        RestContext.response = res;
        TrimMasterPost.getPost();
        
        //insert Duplicate record
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = sfdcBaseURL + '/services/apexrest/TrimMaster';  
        req1.httpMethod = 'POST';
        req1.addParameter('Action', 'Insert');
        req1.addParameter('Code', 'Carnival');
        req1.addParameter('Status', 'A');
        req1.addParameter('Description', 'Description');
        req1.addParameter('FranchiseCode', 'KIAPC');
        req1.addParameter('BranchCode', 'CCK');
        RestContext.request = req1;
        RestContext.response = res1;
        TrimMasterPost.getPost();
        
        //case update
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/TrimMaster';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Update');
        req2.addParameter('Code', 'Carnival');
        req2.addParameter('Status', 'A');
        req2.addParameter('Description', 'Description');
        req2.addParameter('FranchiseCode', 'KIAPC');
        req2.addParameter('BranchCode', 'CCK');
        RestContext.request = req2;
        RestContext.response = res2;
        TrimMasterPost.getPost();
        
        //throw eror
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/TrimMaster';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Update');
        req3.addParameter('Code', 'Carnival1');
        req3.addParameter('Status', 'A');
        req3.addParameter('Description', 'Description');
        req3.addParameter('FranchiseCode', 'KIAPC');
        req3.addParameter('BranchCode', 'CCK');
        RestContext.request = req3;
        RestContext.response = res3;
        TrimMasterPost.getPost();
        
        test.stopTest();
    }
    static testMethod void testStockVehicleMasterPost(){
        test.startTest();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
         Model_Master__c mm=new Model_Master__c();
            mm.Name='Carnival';
            mm.Branch_Code__c='CCK';
            mm.Franchise_Code__c='KIAPC';
        insert mm;
        Color_Master__c cm=new Color_Master__c();
            cm.Name='Blue';
            cm.Branch_Code__c='CCK';
            cm.Franchise_Code__c='KIAPC';
        insert cm;
        Trim_Master__c tm=new Trim_Master__c();
            tm.Name='BB';
            tm.Branch_Code__c='CCK';
            tm.Franchise_Code__c='KIAPC';
        insert tm;
        Model_Year_Master__c mym = new Model_Year_Master__c();
            mym.Model_Master__c=mm.id;
            mym.Branch_Code__c='CCK';
            mym.Franchise_Code__c='KIAPC';
            mym.Name='test';
        insert mym;
        //case insert succes
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = sfdcBaseURL + '/services/apexrest/StockVehicleMaster';  
        req.httpMethod = 'POST';
        req.addParameter('Action', 'Insert');
        req.addParameter('ColorCode', 'Blue');
        req.addParameter('ModelCode', 'Carnival');
        req.addParameter('ModelYearCode', 'test');
        req.addParameter('TrimCode', 'BB');
        req.addParameter('FranchiseCode', 'KIAPC');
        req.addParameter('BranchCode', 'CCK');
        req.addParameter('AgreementDate', '13:03:2016');
        req.addParameter('AgreementNo', '239874');
        req.addParameter('AllocationDate', '13:03:2016');
        req.addParameter('ARF', '12345');
        req.addParameter('ARFBeforeRebate', '12345');
        req.addParameter('BranchLocationCode', '237SDF');
        req.addParameter('BranchUniqueCode', '23SDF23423');
        req.addParameter('Chassis', 'CHASSIS');
        req.addParameter('COEDocumentNo', 'SDFJ234');
        req.addParameter('COEReabteUsedCar', '2349879');
        req.addParameter('COERebateCNC', '3498734');
        req.addParameter('ConfirmationDate', '13:03:2016');
        req.addParameter('ConfirmationNo', '2389SDFS');
        req.addParameter('ConversionRate', '23897');
        req.addParameter('CurrencyCode', 'SGD');
        req.addParameter('Customercode', 'SDF234');
        req.addParameter('DeallocationReason', 'BLABLABLA');
        req.addParameter('DeliveryCertificate', 'A');
        req.addParameter('DeliveryDate', '13:03:2016');
        req.addParameter('DeliveryRequestBy', 'TEXT');
        req.addParameter('DeliveryRequestDate', '13:03:2016');
        req.addParameter('DeliveryRequestNo', 'SDF234');
        req.addParameter('DeliverySMSSentDate', '13:03:2016');
        req.addParameter('DemoCar','1');
        req.addParameter('DutyAmount','50000');
        req.addParameter('DutyExempted','A');
        req.addParameter('DutyGainLoss','20000');
        req.addParameter('DutyPaymentDocumentNo','TEXT10');
        req.addParameter('DutyRequestBy','TEXT20');
        req.addParameter('DutyRequestDate','13:03:2016');
        req.addParameter('DutySaleDate','13:03:2016');
        req.addParameter('DutyStatus','TEXT5');
        req.addParameter('EngineNo','TEXT25');
        req.addParameter('ETADate','13:03:2016');
        req.addParameter('FOBAmount','123124');
        req.addParameter('FOBdate','13:03:2016');
        req.addParameter('FOBGainLoss','123214');
        req.addParameter('FOBSaleDate','13:03:2016');
        req.addParameter('FreightCharges','20000');
        req.addParameter('FulcoStock','TEXT10');
        req.addParameter('GoodReceiveDate','13:03:2016');
        req.addParameter('GoodReceiveNote','TEXT10');
        req.addParameter('HandlingCharges','5000');
        req.addParameter('InsuranceCharges','2000');
        req.addParameter('InvoiceDate','13:03:2016');
        req.addParameter('InvoiceNo','TEXT10');
        req.addParameter('InwardCostType','T3');
        req.addParameter('IUDocumentNo','TEXT10');
        req.addParameter('KeyNo','TEXT20');
        req.addParameter('ManufacturePrice','20000');
        req.addParameter('OMV','124345');
        req.addParameter('OriginalCommcase','TEXT20');
        req.addParameter('PARFBenefitCNC','123234');
        req.addParameter('PARFBenefitUsedCar','234234');
        req.addParameter('PDI','A');
        req.addParameter('PDICompletionDate','13:03:2016');
        req.addParameter('ProductionMonth','13:03:2016');
        req.addParameter('PurchaseOrderNo','TEXT20');
        req.addParameter('RegistrationCharges','2000');
        req.addParameter('RegistrationDate','13:03:2016');
        req.addParameter('RegistrationNo','TEXT20');
        req.addParameter('Remarks','LONG TEXT 500');
        req.addParameter('RequestRegistrationBy','TEXT20');
        req.addParameter('RequestRegistrationDate','13:03:2016'); 
        req.addParameter('RequestRegistrationNo','TEXT10');
        req.addParameter('ReservationNo','TEXT10');
        req.addParameter('SalePrice','1000');
        req.addParameter('StandardAccural','500');
        req.addParameter('StockExclude','TEXT5');
        req.addParameter('SupplementaryInvoiceDate','13:03:2016');
        req.addParameter('SupplementaryInvoiceNo','TEXT10');
        req.addParameter('SystemCommcase','TEXT20');
        req.addParameter('TMSFinalSaleDate','13:03:2016');
        req.addParameter('UpLiftCharges','2500');
        req.addParameter('UpLiftPer','3');
        req.addParameter('VehcileBayNo','TEXT5');
        req.addParameter('VehicleBayLocationCode','TEXT15');
        req.addParameter('VehicleCost','2000');
        req.addParameter('VehicleStatus','SOLD');
        req.addParameter('SupplementaryInvoiceNo','TEXT10');
        req.addParameter('VehicleType','TXT');
        req.addParameter('YearOfManufacture','2014');
        RestContext.request = req;
        RestContext.response = res;
        StockVehicleMasterPost.getPost();
        
        //case insert duplicate record
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = sfdcBaseURL + '/services/apexrest/StockVehicleMaster';  
        req2.httpMethod = 'POST';
        req2.addParameter('Action', 'Insert');
        req2.addParameter('ColorCode', 'Blue');
        req2.addParameter('ModelCode', 'Carnival');
        req2.addParameter('ModelYearCode', 'test');
        req2.addParameter('TrimCode', 'BB');
        req2.addParameter('FranchiseCode', 'KIAPC');
        req2.addParameter('BranchCode', 'CCK');
        req2.addParameter('AgreementDate', '13:03:2016');
        req2.addParameter('AgreementNo', '239874');
        req2.addParameter('AllocationDate', '13:03:2016');
        req2.addParameter('ARF', '12345');
        req2.addParameter('ARFBeforeRebate', '12345');
        req2.addParameter('BranchLocationCode', '237SDF');
        req2.addParameter('BranchUniqueCode', '23SDF23423');
        req2.addParameter('Chassis', 'CHASSIS');
        req2.addParameter('COEDocumentNo', 'SDFJ234');
        req2.addParameter('COEReabteUsedCar', '2349879');
        req2.addParameter('COERebateCNC', '3498734');
        req2.addParameter('ConfirmationDate', '13:03:2016');
        req2.addParameter('ConfirmationNo', '2389SDFS');
        req2.addParameter('ConversionRate', '23897');
        req2.addParameter('CurrencyCode', 'SGD');
        req2.addParameter('Customercode', 'SDF234');
        req2.addParameter('DeallocationReason', 'BLABLABLA');
        req2.addParameter('DeliveryCertificate', 'A');
        req2.addParameter('DeliveryDate', '13:03:2016');
        req2.addParameter('DeliveryRequestBy', 'TEXT');
        req2.addParameter('DeliveryRequestDate', '13:03:2016');
        req2.addParameter('DeliveryRequestNo', 'SDF234');
        req2.addParameter('DeliverySMSSentDate', '13:03:2016');
        req2.addParameter('DemoCar','1');
        req2.addParameter('DutyAmount','50000');
        req2.addParameter('DutyExempted','A');
        req2.addParameter('DutyGainLoss','20000');
        req2.addParameter('DutyPaymentDocumentNo','TEXT10');
        req2.addParameter('DutyRequestBy','TEXT20');
        req2.addParameter('DutyRequestDate','13:03:2016');
        req2.addParameter('DutySaleDate','13:03:2016');
        req2.addParameter('DutyStatus','TEXT5');
        req2.addParameter('EngineNo','TEXT25');
        req2.addParameter('ETADate','13:03:2016');
        req2.addParameter('FOBAmount','123124');
        req2.addParameter('FOBdate','13:03:2016');
        req2.addParameter('FOBGainLoss','123214');
        req2.addParameter('FOBSaleDate','13:03:2016');
        req2.addParameter('FreightCharges','20000');
        req2.addParameter('FulcoStock','TEXT10');
        req2.addParameter('GoodReceiveDate','13:03:2016');
        req2.addParameter('GoodReceiveNote','TEXT10');
        req2.addParameter('HandlingCharges','5000');
        req2.addParameter('InsuranceCharges','2000');
        req2.addParameter('InvoiceDate','13:03:2016');
        req2.addParameter('InvoiceNo','TEXT10');
        req2.addParameter('InwardCostType','T3');
        req2.addParameter('IUDocumentNo','TEXT10');
        req2.addParameter('KeyNo','TEXT20');
        req2.addParameter('ManufacturePrice','20000');
        req2.addParameter('OMV','124345');
        req2.addParameter('OriginalCommcase','TEXT20');
        req2.addParameter('PARFBenefitCNC','123234');
        req2.addParameter('PARFBenefitUsedCar','234234');
        req2.addParameter('PDI','A');
        req2.addParameter('PDICompletionDate','13:03:2016');
        req2.addParameter('ProductionMonth','13:03:2016');
        req2.addParameter('PurchaseOrderNo','TEXT20');
        req2.addParameter('RegistrationCharges','2000');
        req2.addParameter('RegistrationDate','13:03:2016');
        req2.addParameter('RegistrationNo','TEXT20');
        req2.addParameter('Remarks','LONG TEXT 500');
        req2.addParameter('RequestRegistrationBy','TEXT20');
        req2.addParameter('RequestRegistrationDate','13:03:2016'); 
        req2.addParameter('RequestRegistrationNo','TEXT10');
        req2.addParameter('ReservationNo','TEXT10');
        req2.addParameter('SalePrice','1000');
        req2.addParameter('StandardAccural','500');
        req2.addParameter('StockExclude','TEXT5');
        req2.addParameter('SupplementaryInvoiceDate','13:03:2016');
        req2.addParameter('SupplementaryInvoiceNo','TEXT10');
        req2.addParameter('SystemCommcase','TEXT20');
        req2.addParameter('TMSFinalSaleDate','13:03:2016');
        req2.addParameter('UpLiftCharges','2500');
        req2.addParameter('UpLiftPer','3');
        req2.addParameter('VehcileBayNo','TEXT5');
        req2.addParameter('VehicleBayLocationCode','TEXT15');
        req2.addParameter('VehicleCost','2000');
        req2.addParameter('VehicleStatus','SOLD');
        req2.addParameter('SupplementaryInvoiceNo','TEXT10');
        req2.addParameter('VehicleType','TXT');
        req2.addParameter('YearOfManufacture','2014');
        RestContext.request = req2;
        RestContext.response = res2;
        StockVehicleMasterPost.getPost();
        
        //case update
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = sfdcBaseURL + '/services/apexrest/StockVehicleMaster';  
        req3.httpMethod = 'POST';
        req3.addParameter('Action', 'Update');
        req3.addParameter('ColorCode', 'Blue');
        req3.addParameter('ModelCode', 'Carnival');
        req3.addParameter('ModelYearCode', 'test');
        req3.addParameter('TrimCode', 'BB');
        req3.addParameter('FranchiseCode', 'KIAPC');
        req3.addParameter('BranchCode', 'CCK');
        req3.addParameter('AgreementDate', '13:03:2016');
        req3.addParameter('AgreementNo', '239874');
        req3.addParameter('AllocationDate', '13:03:2016');
        req3.addParameter('ARF', '12345');
        req3.addParameter('ARFBeforeRebate', '12345');
        req3.addParameter('BranchLocationCode', '237SDF');
        req3.addParameter('BranchUniqueCode', '23SDF23423');
        req3.addParameter('Chassis', 'CHASSIS');
        req3.addParameter('COEDocumentNo', 'SDFJ234');
        req3.addParameter('COEReabteUsedCar', '2349879');
        req3.addParameter('COERebateCNC', '3498734');
        req3.addParameter('ConfirmationDate', '13:03:2016');
        req3.addParameter('ConfirmationNo', '2389SDFS');
        req3.addParameter('ConversionRate', '23897');
        req3.addParameter('CurrencyCode', 'SGD');
        req3.addParameter('Customercode', 'SDF234');
        req3.addParameter('DeallocationReason', 'BLABLABLA');
        req3.addParameter('DeliveryCertificate', 'A');
        req3.addParameter('DeliveryDate', '13:03:2016');
        req3.addParameter('DeliveryRequestBy', 'TEXT');
        req3.addParameter('DeliveryRequestDate', '13:03:2016');
        req3.addParameter('DeliveryRequestNo', 'SDF234');
        req3.addParameter('DeliverySMSSentDate', '13:03:2016');
        req3.addParameter('DemoCar','1');
        req3.addParameter('DutyAmount','50000');
        req3.addParameter('DutyExempted','A');
        req3.addParameter('DutyGainLoss','20000');
        req3.addParameter('DutyPaymentDocumentNo','TEXT10');
        req3.addParameter('DutyRequestBy','TEXT20');
        req3.addParameter('DutyRequestDate','13:03:2016');
        req3.addParameter('DutySaleDate','13:03:2016');
        req3.addParameter('DutyStatus','TEXT5');
        req3.addParameter('EngineNo','TEXT25');
        req3.addParameter('ETADate','13:03:2016');
        req3.addParameter('FOBAmount','123124');
        req3.addParameter('FOBdate','13:03:2016');
        req3.addParameter('FOBGainLoss','123214');
        req3.addParameter('FOBSaleDate','13:03:2016');
        req3.addParameter('FreightCharges','20000');
        req3.addParameter('FulcoStock','TEXT10');
        req3.addParameter('GoodReceiveDate','13:03:2016');
        req3.addParameter('GoodReceiveNote','TEXT10');
        req3.addParameter('HandlingCharges','5000');
        req3.addParameter('InsuranceCharges','2000');
        req3.addParameter('InvoiceDate','13:03:2016');
        req3.addParameter('InvoiceNo','TEXT10');
        req3.addParameter('InwardCostType','T3');
        req3.addParameter('IUDocumentNo','TEXT10');
        req3.addParameter('KeyNo','TEXT20');
        req3.addParameter('ManufacturePrice','20000');
        req3.addParameter('OMV','124345');
        req3.addParameter('OriginalCommcase','TEXT20');
        req3.addParameter('PARFBenefitCNC','123234');
        req3.addParameter('PARFBenefitUsedCar','234234');
        req3.addParameter('PDI','A');
        req3.addParameter('PDICompletionDate','13:03:2016');
        req3.addParameter('ProductionMonth','13:03:2016');
        req3.addParameter('PurchaseOrderNo','TEXT20');
        req3.addParameter('RegistrationCharges','2000');
        req3.addParameter('RegistrationDate','13:03:2016');
        req3.addParameter('RegistrationNo','TEXT20');
        req3.addParameter('Remarks','LONG TEXT 500');
        req3.addParameter('RequestRegistrationBy','TEXT20');
        req3.addParameter('RequestRegistrationDate','13:03:2016'); 
        req3.addParameter('RequestRegistrationNo','TEXT10');
        req3.addParameter('ReservationNo','TEXT10');
        req3.addParameter('SalePrice','1000');
        req3.addParameter('StandardAccural','500');
        req3.addParameter('StockExclude','TEXT5');
        req3.addParameter('SupplementaryInvoiceDate','13:03:2016');
        req3.addParameter('SupplementaryInvoiceNo','TEXT10');
        req3.addParameter('SystemCommcase','TEXT20');
        req3.addParameter('TMSFinalSaleDate','13:03:2016');
        req3.addParameter('UpLiftCharges','2500');
        req3.addParameter('UpLiftPer','3');
        req3.addParameter('VehcileBayNo','TEXT5');
        req3.addParameter('VehicleBayLocationCode','TEXT15');
        req3.addParameter('VehicleCost','2000');
        req3.addParameter('VehicleStatus','SOLD');
        req3.addParameter('SupplementaryInvoiceNo','TEXT10');
        req3.addParameter('VehicleType','TXT');
        req3.addParameter('YearOfManufacture','2014');
        RestContext.request = req3;
        RestContext.response = res3;
        StockVehicleMasterPost.getPost();
        
        //Update throw eror
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        
        req4.requestURI = sfdcBaseURL + '/services/apexrest/StockVehicleMaster';  
        req4.httpMethod = 'POST';
        req4.addParameter('Action', 'Update');
        req4.addParameter('ColorCode', 'Blue');
        req4.addParameter('ModelCode', 'Carnival');
        
        RestContext.request = req4;
        RestContext.response = res4;
        StockVehicleMasterPost.getPost();
        
        test.stopTest();
    }
}