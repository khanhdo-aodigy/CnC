/** *****
 * Description : Test Class for DWH_CreditTransactionService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200707            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class DWH_CreditTransactionServiceTest {
    
    static String strMockResult = '{"VCT":[{"P":"M","SRC":"ANC","FRAN":"K","VEHMAGIC":"07010901888","REGN":"LLL779911","CHASSIS":"DUMMYCHASSIS12345","SEQ":1,"TARMAGIC":"999000111","FLEET":"N","NRIC":"LLLNRICTEST","CR_AMT":4000,"MISC_REF":"CPO-009001001","EXPIRY":"2021-09-01T03:40:07.717","COST":"2000","NLCODE":"NL1199111999000","CUSTOMER_NAME":"Loh LL"},{"P":"M","SRC":"AGS","FRAN":"K","VEHMAGIC":"07010901888","REGN":"LLL779911","CHASSIS":"DUMMYCHASSIS12345","SEQ":1,"TARMAGIC":"777000111","FLEET":"N","NRIC":"LLLNRICTEST","CR_AMT":4000,"MISC_REF":"CPO-007001001","EXPIRY":"2021-07-01T03:40:07.717","COST":"1000","NLCODE":"NL1177111777000","CUSTOMER_NAME":"Loh LL"}]}';
    

    @TestSetup
    static void makeData()
    {
        Account personAcct = Test_DataFactory.createPerson(false, 'TestUser', 'Customer');
        personAcct.NRIC_Passport_No__pc = 'LLLNRICTEST';
        insert personAcct;

        Contact personCont = [SELECT Id, Name FROM Contact WHERE AccountId = :personAcct.Id ];

        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle( false, 'LLL779911', 'CCK', 'KIAPC', 'LLL779911', personCont.Id);
        regVeh.Account__c = personAcct.Id;
        regVeh.DWH_Vehicle_ID__c = '07010901888';
        regVeh.Chasis_Number__c  = 'DUMMYCHASSIS12345';
        insert regVeh;

        global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com', APIGateway_key__c='testKey');
        upsert gVar;

        //DWH Last Run date
        DWH_last_run_date__c sv = new DWH_last_run_date__c();
        sv.Vehicle_Credit_Sync_Success__c      = false;
        sv.Credit_Transaction_Sync_From__c     = Date.today().addDays(-1);
        sv.Credit_Transaction_Sync_To__c       = Date.today().addDays(-1);
        sv.Credit_Transaction_NumberOfPages__c = 1; 
        sv.Credit_Transaction_NumRecords__c    = 1000;
        upsert sv;
    }
    
    @isTest
    static void getCreditTransactionCountAPIcall() {
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new CreditTransactionCountMocker(false) );
            DWH_CreditTransactionService.getVSMSCreditTransactionDataCount(Date.today(), Date.today());
        System.Test.stopTest();  
    }


    @isTest
    static void getCreditTransactionFromAPIcall() {
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new CreditTransactionMocker(true) );
            // HttpResponse res = DWH_CreditTransactionService.getVehicleCreditDataFromDWH( Date.today(), Date.today() );
            //DWH_CreditTransactionService.getVSMSCreditTransactionData();
            DWH_CreditTransactionService.syncVehicleCreditDataFromDWH( DWH_CreditTransactionService.getVehicleCreditDataFromDWH( 1, null, null ) ); 
        System.Test.stopTest();  
        
        // String actualBody = res.getBody();
        // System.debug('actualBody: '  + actualBody);  
        // String expectedBody = strMockResult;
        // System.assertEquals( res.getBody(), expectedBody );
        // System.assertEquals( res.getStatusCode(), 200 ); 
    }


    @isTest
    static void getCreditTransactionFromDWHSchBatch() {
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new CreditTransactionMocker(true) );
            System.schedule('DWH_GetCreditTransaction_Sch', '0 0 0 ? * * *', new DWH_GetCreditTransaction_Sch());    
        System.Test.stopTest();

    }


    public class CreditTransactionCountMocker implements HttpCalloutMock{

        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        String numRecs = lastRunDateVar.Credit_Transaction_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Credit_Transaction_NumRecords__c.intValue()): '2000';

        private boolean isBatchRun;

        public CreditTransactionCountMocker (Boolean fromBatch){
            isBatchRun = fromBatch;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            Datetime today = isBatchRun ? date.today().addDays(-1) : date.today();
            System.assertEquals('https://www.test.com/vSMS/Credit/Count?from='+today.format('yyyy-MM-dd')+'&to='+today.format('yyyy-MM-dd'), req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody( strMockResult );
            res.setStatusCode(200);
            return res;
        }
    }


    public class CreditTransactionMocker implements HttpCalloutMock{
        private boolean isBatchRun;
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        String numRecs = lastRunDateVar.Credit_Transaction_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Credit_Transaction_NumRecords__c.intValue()): '2000';

        public CreditTransactionMocker (Boolean fromBatch){
            isBatchRun = fromBatch;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            Datetime today = isBatchRun ? date.today().addDays(-1) : date.today();
            // System.assertEquals('https://www.test.com/vSMS/Credit?from='+today.format('yyyy-MM-dd')+'&to='+today.format('yyyy-MM-dd')+'&noOfRecords='+numRecs+'&pageNo=1', req.getEndpoint());
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