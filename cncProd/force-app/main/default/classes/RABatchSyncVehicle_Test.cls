/** *****
 * Description : Test Class for RASyncVehicleSch batch job
 * 
 * Change History
 * Date(YYYYMMDD)       Name                  Description
 * 20210205             huynh.hung@aodigy     Created Initial Version. 
 * 
** *****/
@isTest
private class RABatchSyncVehicle_Test {
    @testSetup
    private static void createData(){
        Account pa = Test_DataFactory.createPA(true, 'TestLastName','TestLastName@gmail.com', 'Customer');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, pa.ID, 'RA_Person_Account_Profiling_RT');
        
        Used_Car_Vehicle_Stock__c car = Test_DataFactory.createSoldUsedCar(true, pa.Id, 'VEHDOC0000000000061212','SG00KA3', 'MERCEDES-BENZ', 'SMK9420z');
        
        Sales_Opportunity__c opp = Test_DataFactory.createSalesOpp(false, pa.ID, 'Stock Reserve', 'HungSC', 'HungSC@gmail.com', '6512365478');
        opp.Close_Date__c = Date.today().addMonths(6);
        insert opp;
        Vehicle_Stock_Reservation__c stockReserv = Test_DataFactory.createReservation(false, pa.Id, Date.today(), 'vietnam', 500, opp.ID, car.ID);
        
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.APIGateway_URL__c = 'www.urlToTheNewHell.com';
        RA_GlobalVar.APIGateway_key__c = 'fakekey123';
        upsert RA_GlobalVar;
    }
    
    @isTest
    private static void testBatchSyncVehicle(){
        Test.startTest();
        String mockResponse = '[{"VEHDOCNO": "VEHDOC0000000000061212",'+
            '"VEHNO": "SMK9420z",'+
            '"MAKE": "MERCEDES-BENZ",'+
            '"MODEL": "C180 AVG (R17 LED)",'+
            '"LISTINGPRICE": "123800.00",'+
            '"COE": "123001.00",'+
            '"OMV": "123590.00",'+
            '"ARF": "12313.00",'+
            '"ENGINECAPACITY": "1235",'+
            '"REGDATE": "2016-02-29",'+
            '"MILAGE": "12338.00",'+
            '"NOOFOWNDER": "12",'+
            '"AGEOFVEHICLE": "12",'+
            '"SOLDDATE": "2016-02-29",'+
            '"CUSTOMERNAME": "HungTest04021 HungTest04021",'+
            '"MOBILE": "6501100402",'+
            '"EMAIL":"HungTest04021@ratest.com",'+
            '"CONSENT": "YES"}]';
        
        HttpResponse res = new HttpResponse();
        res.setBody(mockResponse);
        res.setStatusCode(200);

        RASyncVehicleService.syncVehicleFromUCS(res, mockResponse);
        
        Test.stopTest();
        System.assertNotEquals(null, [Select ID from Person_Account_Profiling__c WHERE Account__r.PersonEmail ='HungTest04021@ratest.com']);
    }
    
    @isTest
    private static void testBatchSyncVehicle_ExistingPAProfiling(){
        Test.startTest();
        String mockResponse = '[{"VEHDOCNO": "VEHDOC0000000000061212",'+
            '"VEHNO": "SMK9420z",'+
            '"MAKE": "MERCEDES-BENZ",'+
            '"MODEL": "C180 AVG (R17 LED)",'+
            '"LISTINGPRICE": "123800.00",'+
            '"COE": "123001.00",'+
            '"OMV": "123590.00",'+
            '"ARF": "12313.00",'+
            '"ENGINECAPACITY": "1235",'+
            '"REGDATE": "2016-02-29",'+
            '"MILAGE": "12338.00",'+
            '"NOOFOWNDER": "12",'+
            '"AGEOFVEHICLE": "12",'+
            '"SOLDDATE": "2016-02-29",'+
            '"CUSTOMERNAME": "HungTest04021 HungTest04021",'+
            '"MOBILE": "6501100402",'+
            '"EMAIL":"TestLastName@gmail.com",'+
            '"CONSENT": "YES"}]';
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        res.setBody(mockResponse);
        res.setStatusCode(200);
        RASyncVehicleService.syncVehicleFromUCS(res, '');

        Test.stopTest();
        System.assertNotEquals(null, [Select ID from Person_Account_Profiling__c WHERE Account__r.PersonEmail ='TestLastName@gmail.com']);
    }
    
    @isTest
    private static void testBatchSyncVehicle_NoCustomer(){
        Test.startTest();
        String mockResponse = '[{"VEHDOCNO": "VEHDOC0000000000061212",'+
            '"VEHNO": "SMK9420z",'+
            '"MAKE": "MERCEDES-BENZ",'+
            '"MODEL": "C180 AVG (R17 LED)",'+
            '"LISTINGPRICE": "123800.00",'+
            '"COE": "123001.00",'+
            '"OMV": "123590.00",'+
            '"ARF": "12313.00",'+
            '"ENGINECAPACITY": "1235",'+
            '"REGDATE": "2016-02-29",'+
            '"MILAGE": "12338.00",'+
            '"NOOFOWNDER": "12",'+
            '"AGEOFVEHICLE": "12",'+
            '"SOLDDATE": "2016-02-29",'+
            '"CUSTOMERNAME": "",'+
            '"MOBILE": "",'+
            '"EMAIL":"",'+
            '"CONSENT": ""}]';
        
        HttpResponse res = new HttpResponse();

        RASyncVehicleSch batch = new RASyncVehicleSch('eq 2020-02-21','eq 2020-02-21','eq 2020-02-21','eq 2020-02-21');
        Database.executeBatch(batch, 1);
        RASyncVehicleService.syncVehicleFromUCS(res, mockResponse);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testBatchSyncVehicle_Schedule(){
        Test.startTest();
        String mockResponse = '[{"VEHDOCNO": "VEHDOC0000000000061212",'+
            '"VEHNO": "SMK9420z",'+
            '"MAKE": "MERCEDES-BENZ",'+
            '"MODEL": "C180 AVG (R17 LED)",'+
            '"LISTINGPRICE": "123800.00",'+
            '"COE": "123001.00",'+
            '"OMV": "123590.00",'+
            '"ARF": "12313.00",'+
            '"ENGINECAPACITY": "1235",'+
            '"REGDATE": "2016-02-29",'+
            '"MILAGE": "12338.00",'+
            '"NOOFOWNDER": "12",'+
            '"AGEOFVEHICLE": "12",'+
            '"SOLDDATE": "2016-02-29",'+
            '"CUSTOMERNAME": "",'+
            '"MOBILE": "",'+
            '"EMAIL":"",'+
            '"CONSENT": ""}]';
        
        HttpResponse res = new HttpResponse();

        System.schedule('BatchAftersalesServiceHeader', '0 0 0 ? * * *', new RASyncVehicleSch());    
        RASyncVehicleService.syncVehicleFromUCS(res, mockResponse);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testBatchSyncVehicle_withFreeTextFilterInput(){
        Test.startTest();
        String mockResponse = '[{"VEHDOCNO": "VEHDOC0000000000061212",'+
            '"VEHNO": "SMK9420z",'+
            '"MAKE": "MERCEDES-BENZ",'+
            '"MODEL": "C180 AVG (R17 LED)",'+
            '"LISTINGPRICE": "123800.00",'+
            '"COE": "123001.00",'+
            '"OMV": "123590.00",'+
            '"ARF": "12313.00",'+
            '"ENGINECAPACITY": "1235",'+
            '"REGDATE": "2016-02-29",'+
            '"MILAGE": "12338.00",'+
            '"NOOFOWNDER": "12",'+
            '"AGEOFVEHICLE": "12",'+
            '"SOLDDATE": "2016-02-29",'+
            '"CUSTOMERNAME": "",'+
            '"MOBILE": "",'+
            '"EMAIL":"",'+
            '"CONSENT": ""}]';
        
        HttpResponse res = new HttpResponse();

        RASyncVehicleSch batch = new RASyncVehicleSch('LASTUPDATEDATE=eq 2021-03-02');
        Database.executeBatch(batch, 1);
        RASyncVehicleService.syncVehicleFromUCS(res, mockResponse);
        
        Test.stopTest();
    }
}