/*******
 * Description : Test Class for VehicleCreditService.cls service class
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name        Description
 * 20200217             HS          Created Initial Version 
 * 20200828             HS          Updated Code Coverage
 * 
*******/
@isTest(seeAllData=false)
private class VehicleCreditServiceTest {
   
    static String strMockResult = '{"CA":[{"ACCNO":"KAC00000","MAGIC":123456,"MAGIC_VEHICLE":12345,"DATASOURCE":"CCS","MODULE_ID":"MK","COMPANY_ID":"03","ACCOUNT_TYPE":"Accessories","CREDIT_BALANCE":100,"EXPIRYDATE":"2020-12-31T00:00:00","STOPFLAG":false,"EDITED":"2020-02-16T00:00:00","CHASSIS":"CHS12345TEST","STATUS":"ACTIVE","dss_update_time":"2020-02-17T03:40:07.717"},{"ACCNO":"KAC000001","MAGIC":234567,"MAGIC_VEHICLE":23456,"DATASOURCE":"CCS","MODULE_ID":"MK","COMPANY_ID":"03","ACCOUNT_TYPE":"Service","CREDIT_BALANCE":200,"EXPIRYDATE":"2020-12-31T00:00:00","STOPFLAG":false,"EDITED":"2020-02-16T00:00:00","CHASSIS":"CHS12345TEST","STATUS":"ACTIVE","dss_update_time":"2020-02-17T03:40:07.717"},{"ACCNO":"KAC000002","MAGIC":345678,"MAGIC_VEHICLE":34567,"DATASOURCE":"CCS","MODULE_ID":"MK","COMPANY_ID":"03","ACCOUNT_TYPE":"Accessories","CREDIT_BALANCE":300,"EXPIRYDATE":"2020-12-31T00:00:00","STOPFLAG":false,"EDITED":"2020-02-16T00:00:00","CHASSIS":"CHS34567TEST","STATUS":"ACTIVE","dss_update_time":"2020-02-17T03:40:07.717"}]}';

    @TestSetup
    static void makeData()
    {
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        Contact cnt = Test_DataFactory.createContact(true, '',  UserInfo.getLastName(), acc.Id);
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle( false, 'TESTREGNO', 'CCK', 'KIAPC', 'TESTREGNO', cnt.Id);
        regVeh.DWH_Vehicle_ID__c = '12345';
        regVeh.Chasis_Number__c  = 'CHS12345TEST';
        insert regVeh;

        Vehicle_Credit__c vc = new Vehicle_Credit__c();
        vc.Registered_Vehicle__c = regVeh.Id;
        insert vc;

        global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com', APIGateway_key__c='testKey');
        upsert gVar;

        //DWH Last Run date
        DWH_last_run_date__c sv = new DWH_last_run_date__c();
        sv.Vehicle_Credit_Sync_Success__c = false;
        sv.Vehicle_Credit_Sync_From__c    = Date.today().addDays(-1);
        sv.Vehicle_Credit_Sync_To__c      = Date.today().addDays(-1);
        upsert sv;
    }
    

    @isTest
    static void getVehicleCreditDataFromDWHTest() {
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new VehicleCreditMocker(false) );
            // HttpResponse res = VehicleCreditService.getVehicleCreditDataFromDWH( 1, Date.today(), Date.today() );
            VehicleCreditService.getVehicleCreditDataFromDWH( 0, Date.today(), Date.today() );
        System.Test.stopTest();  
        
        // String actualBody = res.getBody();
        // System.debug('actualBody: '  + actualBody);  
        // String expectedBody = strMockResult;

        // System.assertEquals( res.getBody(), expectedBody );
        // System.assertEquals( res.getStatusCode(), 200 ); 
    }


    @isTest
    static void syncVehicleCreditDataFromDWHTest() {
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new VehicleCreditMocker(true) );
            System.schedule('DWH_GetVehicleCreditData_Sch', '0 0 0 ? * * *', new DWH_GetVehicleCreditData_Sch());    
        System.Test.stopTest();

    }

    public class VehicleCreditMocker implements HttpCalloutMock{
        private boolean isBatchRun;

        public VehicleCreditMocker (Boolean fromBatch){
            isBatchRun = fromBatch;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            Datetime today = isBatchRun ? date.today().addDays(-1) : date.today();
            // System.assertEquals('https://www.test.com/DWHAPI/GetCreditAccount_DWH?fromDate='+today.format('MM/dd/yyyy')+'&toDate='+today.format('MM/dd/yyyy')+'&noOfRecords=0&pageNo=0', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody( strMockResult );
            res.setStatusCode(200);
            return res;
        }
    }
}