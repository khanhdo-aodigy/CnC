/**
 * @File Name          : RegisteredVehicleService.cls
 * @Description        : JIRA29
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/22/2020, 2:42:54 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/12/2020   jmt@aodigy.com     Initial Version
**/
@isTest
private class RegisteredVehicleServiceTest {
    @TestSetup
    static void makeData(){
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        Contact cnt = Test_DataFactory.createContact(true, '',  UserInfo.getLastName(), acc.Id);
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle(false, 'TESTREGNO', 'CCK', 'KIAPC', 'TESTREGNO', cnt.Id);
        regVeh.DWH_Vehicle_ID__c = '10334';
        insert regVeh;

        global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com',
        APIGateway_key__c='testKey');
        upsert gVar;

        //DWH Last Run date
        DWH_last_run_date__c sv = new DWH_last_run_date__c();
        sv.DWH_import_date__c = Date.today();
        sv.RegVehicle_StartPage__c    = 0;
        sv.RegVehicle_NumberOfPage__c = 25;
        sv.RegVehicle_NumRecords__c   = 100;
        upsert sv;
    }
    @isTest
    static void getDataFromDWHTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RegVehicleDWHMocker(false));
        HttpResponse res = RegisteredVehicleService.getDataFromDWH(0, Date.today());
        Test.stopTest();  
        String actualBody = res.getBody();
        system.debug('Acutal Body: '  + actualBody);  
        String expectedBody = '{"RV":[{"MAGIC_VEHICLE":10334,"VEHICLE_DATASOURCE":"CCS03","MAGIC_MBPC":0,"MAGIC_MBCV":0,"MAGIC_MF":376589,"MAGIC_FUL":309661,"MAGIC_CUSTOMER":149171,"FRANCHISECODE":"J","FRANCHISE":"MITPC","REGNO":"TESTREGNO","COMM":"09-0318 18","ENGINE":"4J11AC5258","CHASSIS":"GF7W0600657","REGDATE":"2019-05-31T00:00:00","COLLECTIONDATE":"0001-01-01T00:00:00","LASTSERV":"0001-01-01T00:00:00","IMILEAGEU":0,"NEXTSERV":"2019-06-28T00:00:00","NEXTSMIL":1000,"LASTSMILE":0,"SECURENO":"1129362727","WAREXPDT":"2018-01-01T00:00:00","WAREXTDT":"2024-05-31T00:00:00","SVCCRDBAL":0.0,"SVCCRDEXPDT":"2088-01-01T00:00:00","MAGIC":"10334","IMMOBIL":"","MODELYR":2018,"COLCODE":"P026","VARIANT":"","EXTContactID":286880,"DELDATE":"0001-01-01T00:00:00","CREATED":"2019-05-09T00:00:00","EDITED":"2019-07-22T00:00:00","SCRBAL":0.0,"LASTBATTERYCHANGEdate":"01/02/2022"}]}';

        System.assertEquals(res.getBody(), expectedBody);
        System.assertEquals(res.getStatusCode(), 200); 
    }


    @isTest
    static void DWHUpdateRegisterVehSchedulerTest(){
        //Testing DWH_RegisteredVehiclesUpdate_Sch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RegVehicleDWHMocker(true));
        System.schedule('DWH_RegisteredVehiclesUpdate_Sch', '0 0 0 ? * * *', new DWH_RegisteredVehiclesUpdate_Sch());    
        Test.stopTest();

    }

    public class RegVehicleDWHMocker implements HttpCalloutMock{
        private boolean isBatchRun;

        public RegVehicleDWHMocker (Boolean fromBatch){
            isBatchRun = fromBatch;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            datetime today = isBatchRun ? date.today()-1 : date.today();
            // System.assertEquals('https://www.test.com/DWHAPI/GetRegVehicle_DWH?syncDate='+today.format('MM/dd/yyyy')+'&noOfRecords=0&pageNo=0', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"RV":[{"MAGIC_VEHICLE":10334,"VEHICLE_DATASOURCE":"CCS03","MAGIC_MBPC":0,"MAGIC_MBCV":0,"MAGIC_MF":376589,"MAGIC_FUL":309661,"MAGIC_CUSTOMER":149171,"FRANCHISECODE":"J","FRANCHISE":"MITPC","REGNO":"TESTREGNO","COMM":"09-0318 18","ENGINE":"4J11AC5258","CHASSIS":"GF7W0600657","REGDATE":"2019-05-31T00:00:00","COLLECTIONDATE":"0001-01-01T00:00:00","LASTSERV":"0001-01-01T00:00:00","IMILEAGEU":0,"NEXTSERV":"2019-06-28T00:00:00","NEXTSMIL":1000,"LASTSMILE":0,"SECURENO":"1129362727","WAREXPDT":"2018-01-01T00:00:00","WAREXTDT":"2024-05-31T00:00:00","SVCCRDBAL":0.0,"SVCCRDEXPDT":"2088-01-01T00:00:00","MAGIC":"10334","IMMOBIL":"","MODELYR":2018,"COLCODE":"P026","VARIANT":"","EXTContactID":286880,"DELDATE":"0001-01-01T00:00:00","CREATED":"2019-05-09T00:00:00","EDITED":"2019-07-22T00:00:00","SCRBAL":0.0,"LASTBATTERYCHANGEdate":"01/02/2022"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
}