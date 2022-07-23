/** *****
 * Description : Test Class for DWH_GetCustomerData_PersonAccount.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20201120            Khanh@aodigy            Created Initial Version 
 * 
** *****/
@isTest
private class DWH_GetCustomerData_PersonAccount_Test {
    private static String chassisNo = 'KNAFZ411MF5404311999'; 
    private static String magicCustomer = '971091';
    private static String socialId = 'SI01';
       
    @TestSetup
    static void createData() {       
        
        Account paCustomer = Test_DataFactory.createPerson(false, 'testPACustomer', 'Customer');
        //paCustomer.DWH_Contact_ID__c  = magicCustomer;
        //paCustomer.DWH_Contact_ID__pc = magicCustomer;
        insert paCustomer;

        paCustomer = [SELECT Id, Name, PersonContactId, DWH_Contact_ID__pc FROM Account WHERE Id =: paCustomer.Id];
        
        List<String> objList = new List<String>{'Stock_Reservation__c','Opportunity','Model_Master__c','Vehicle_Master2__c'
                                                ,'MB_Stock_Vehicle_Master__c','MB_Sales_Agreement__c','Color_Master__c'
                                                ,'Trim_Master__c','MB_Stock_Vehicle_Master__c','Model_Year_Master__c'};
        for(String obj: objList){
            TriggerExclusion.excludeTrigger(obj, true);
        }
        
        //Insert Model
        Model__c model1 = Test_DataFactory.createmodelId(false, 'DummyModelKIA', 'CCK', 'KIAPC');
        Model__c model2 = Test_DataFactory.createmodelId(false, 'DummyModelMB', 'CCI', 'MBP');
        insert (new List<Model__c>{ model1, model2 });
        
        //Insert Variant
        Variant__c variant1 = Test_DataFactory.createVariant(false, 'DummyVariantKIA', model1.Id, 'CCK');
        Variant__c variant2 = Test_DataFactory.createVariant(false, 'DummyVariantMB', model2.Id, 'CCI');
        insert (new List<Variant__c>{ variant1, variant2 });
        
        //Insert Vehicle
        Registered_Vehicle__c regVeh1 = Test_DataFactory.createregVehicle(false, 'Dummy Veh1', 'CCK', 'KIAPC', 'KIA0001', paCustomer.PersonContactId);
        regVeh1.LeadBatchProcessed__c = false;
        regVeh1.Chasis_Number__c      = chassisNo;
        regVeh1.Variant__c            = variant1.Id;

        Registered_Vehicle__c regVeh2 = Test_DataFactory.createregVehicle(false, 'Dummy Veh2', 'CCI', 'MBP', 'MB0001', paCustomer.PersonContactId);
        regVeh2.LeadBatchProcessed__c = false;
        regVeh2.Chasis_Number__c      = 'MBCHASSISDUMMY00001';
        regVeh2.Variant__c            = variant2.Id;
        insert (new List<Registered_Vehicle__c>{ regVeh1, regVeh2 } );

        //For Vehicle_Master2__c creation
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true,'test','T69','CCK','KIAPC');
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true,'test');
        
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(false,'test');
        modelMaster.Branch_Code__c = 'CCK';
        modelMaster.Franchise_Code__c = 'KIAPC';
        insert modelMaster;
        
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);
        Vehicle_Master2__c vehMaster = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, 'originalCommacase', 'systemCommcase');
        vehMaster.Chassis__c = chassisNo;
        vehMaster.ProductionMonth__c= Date.today().addDays(5);
        insert vehMaster;
        
        Stock_Reservation__c sr = new Stock_Reservation__c();
        sr.Agreement_No__c = 'AGR001';
        sr.Reservation_Status__c = 'Print';
        sr.Vehicle_Master__c = vehMaster.Id; //to get Vehicle_Chassis_Number__c = vehMaster.Chassis__c
        sr.Model_Code__c = modelMaster.Id;
        sr.Color_Code__c = colorMaster.Id;
        sr.Trim_Code__c = trimMaster.Id;
        sr.Model_Year_Code__c = modelYearMaster.Id;
        sr.Franchise_Code__c = 'KIAPC';
        insert sr;

        MB_Stock_Vehicle_Master__c stockVehMaster = new MB_Stock_Vehicle_Master__c();
        stockVehMaster.Status__c = 'Open';
        stockVehMaster.Status_Autoline__c = 'O';
        stockVehMaster.Chassis__c = 'MBCHASSISDUMMY00001';
        insert stockVehMaster;
        
        MB_Sales_Agreement__c mbSA = new MB_Sales_Agreement__c();
        mbSA.Account__c = paCustomer.Id;
        mbSA.MB_Stock_Vehicle_Master__c = stockVehMaster.Id;
        mbSA.Status__c = 'Car Collected';
        insert mbSA;
        
        global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com',
                                               APIGateway_key__c='testKey');
        upsert gVar;
        
        DWH_last_run_date__c sv = new DWH_last_run_date__c();
        sv.DWH_import_date__c = Date.today();
        sv.Customer_StartPage__c = 1;
        sv.Customer_NumberOfPages__c = 25;
        upsert sv;
    }
    
    @isTest
    static void testDWH_GetCustomerData_PersonAccount() {
        Test.startTest();
            String body = '{"Customers":[{"MAGIC_CUSTOMER": 9999111,"CUSTOMER_DATASOURCE": "CCS","MAGIC_MBPC": 0, "MAGIC_MBCV": 0,"MAGIC_MF": 33330001,"MAGIC_FUL": 44440001,"CUSTOMER_TYPE": null,"SALUTE": "TEST-PA CUSTOMER-1","SOCIALID": "A12345990001","MAGIC": 9999111,"TITLE": "Mr","SURNAME": "Test","FIRSTNAME": "TestingTestingTestingTestingTestingCustomer-1","LASTNAME": "Test","DOB": "1989-07-01T00:00:00","SEX": "M","PHONE005": "99900099","PHONE002": null,"EMAIL": "testcustomer1@mailinator.com","ADDRESS001": "99 Jalan Heaven","ADDRESS002": "Singapore 345000","ADDRESS003": null,"ADDRESS004": null,"ADDRESS005": "Singapore","CITY": "Singapore","STATE": null,"COUNTRY": "Singapore","POSTCODE": 0,"PDPA": null,"Preferred_Mode_Of_Contact": null,"CREATED": "4/4/2020 12:00:00 AM","EDITED": "1/5/2020 12:00:00 AM","LATEST_CHASSIS": "KNAFZ411MF5404311999","BRAND": "KIA"},{"MAGIC_CUSTOMER": 9999111,"CUSTOMER_DATASOURCE": "CCS","MAGIC_MBPC": 0, "MAGIC_MBCV": 0,"MAGIC_MF": 33330001,"MAGIC_FUL": 44440001,"CUSTOMER_TYPE": null,"SALUTE": "TEST-PA CUSTOMER-1","SOCIALID": "A12345990001","MAGIC": 9999111,"TITLE": "Mr","SURNAME": "Test","FIRSTNAME": "Customer-1","LASTNAME": "Test","DOB": "1989-07-01T00:00:00","SEX": "M","PHONE005": "99900099","PHONE002": null,"EMAIL": "testcustomer1@mailinator.com","ADDRESS001": "99 Jalan Heaven","ADDRESS002": "Singapore 345000","ADDRESS003": null,"ADDRESS004": null,"ADDRESS005": "Singapore","CITY": "Singapore","STATE": null,"COUNTRY": "Singapore","POSTCODE": 0,"PDPA": null,"Preferred_Mode_Of_Contact": null,"CREATED": "4/4/2020 12:00:00 AM","EDITED": "1/5/2020 12:00:00 AM","LATEST_CHASSIS": "MBCHASSISDUMMY00001","BRAND": "MB"}]}';
            Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,body));
            //Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetCustomerData_PersonAccount', true));
            DWH_GetCustomerData_PersonAccount sJob = new DWH_GetCustomerData_PersonAccount();
            sJob.execute(null);
        Test.stopTest();
    }


    @isTest
    static void testDWH_GetCustomerData_PersonAccount_withoutCalloutMock(){
        Test.startTest();
            try {
                DWH_GetCustomerData_PersonAccount sJob = new DWH_GetCustomerData_PersonAccount();
                sJob.execute(null);
            } 
            catch (Exception ex) {
                System.assertEquals('Methods defined as TestMethod do not support Web service callouts', ex.getMessage());           
            }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateData() {
        Account paCustomer = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = true LIMIT 1];
        
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Test Opp', null);
        opp.Account__c = paCustomer.Id;
        opp.Contact_Person__c = paCustomer.PersonContactId;
        insert opp;
        
        Model__c model = [SELECT Id FROM Model__c LIMIT 1];
            
        Models_Interested__c modelInterested = Test_DataFactory.createmodelsInterested(true, model.Id, opp.Id, 'Open', 'Price Alert');
        
        Stock_Reservation__c reservation = [SELECT Id, Opportunity__c FROM Stock_Reservation__c LIMIT 1];
        reservation.Opportunity__c = opp.Id;
        update reservation;
        
        Test.startTest();
            String body = '{"Customers":[{"MAGIC_CUSTOMER": '+magicCustomer+',"CUSTOMER_DATASOURCE": "CCS","MAGIC_MBPC": 0, "MAGIC_MBCV": 0,"MAGIC_MF": 33330001,"MAGIC_FUL": 44440001,"CUSTOMER_TYPE": null,"SALUTE": "TEST-PA CUSTOMER-1","SOCIALID": "'+socialId+'","MAGIC": 9999111,"TITLE": "Mr","SURNAME": "Test","FIRSTNAME": "Customer-1","LASTNAME": "Test","DOB": "1989-07-01T00:00:00","SEX": "M","PHONE005": "99900099","PHONE002": null,"EMAIL": "testcustomer1@mailinator.com","ADDRESS001": "99 Jalan Heaven","ADDRESS002": "Singapore 345000","ADDRESS003": null,"ADDRESS004": null,"ADDRESS005": "Singapore","CITY": "Singapore","STATE": null,"COUNTRY": "Singapore","POSTCODE": 0,"PDPA": null,"Preferred_Mode_Of_Contact": null,"CREATED": "4/4/2020 12:00:00 AM","EDITED": "1/5/2020 12:00:00 AM","LATEST_CHASSIS": "'+chassisNo+'","BRAND": "KIA"}]}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatus('200');
            response.setBody(body);
            DWH_GetCustomerData_PersonAccount.updateData(response);
        Test.stopTest();
    }

}