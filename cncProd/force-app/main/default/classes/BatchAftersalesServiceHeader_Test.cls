@isTest	
public class BatchAftersalesServiceHeader_Test {
    
    static String strMockResult = '{"SH":[{"MAGIC_CUSTOMER": "17763","WDATEOUT": "2020-09-09T00:00:00","CHASSIS": "DUMMYCHASSIS12345","REGNO": "SLM586R","OPCREATE": "306","OPERATOR_NAME": "GuanHorng","INVNO": 77522131.0,"VALUE_": 0.00,"COMPANY_ID": "1"},{"MAGIC_CUSTOMER": "34547","WDATEOUT": "2020-09-09T00:00:00","CHASSIS": "KNAF3416MK5026971","REGNO": "SMH3254T","OPCREATE": "Mycn","OPERATOR_NAME": "","INVNO": 81443775.0,"VALUE_": 108.00,"COMPANY_ID": "81"}]}';
    
    @testSetup
    public static void createData(){
        Account personAcct = Test_DataFactory.createPerson(false, 'TestUser', 'Customer');
        personAcct.NRIC_Passport_No__pc = 'LLLNRICTEST';
        personAcct.PDPA__pc = 'SMS';
        insert personAcct;
        
        Contact personCont = [SELECT Id, Name FROM Contact WHERE AccountId = :personAcct.Id ];
        
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle( false, 'LLL779911', 'CCK', 'KIAPC', 'LLL779911', personCont.Id);
        regVeh.Account__c = personAcct.Id;
        regVeh.DWH_Vehicle_ID__c = '07010901888';
        regVeh.Chasis_Number__c  = 'DUMMYCHASSIS12345';
        regVeh.MagicCustomer__c = '17763';
        insert regVeh;
        
        global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com', APIGateway_key__c='testKey');
        upsert gVar;
        
        //DWH Last Run date
        DWH_last_run_date__c sv = new DWH_last_run_date__c();
        sv.Post_Service_Sync_From__c     = Date.today();
        sv.Post_Service_Sync_To__c     = Date.today();
        
        sv.Post_Service_NumberOfPages__c = 1; 
        sv.Post_Service_NumRecords__c = 1000;
        upsert sv;
    }
    
    @isTest
    static void getPostServiceHeaderDataFromDWHCountTest() {
        System.Test.startTest();
        Test.setMock( HttpCalloutMock.class, new PostServiceHeaderCountMocker(false) );
        DWH_AftersalesServiceHeader.getPostServiceHeaderDataFromDWHCount(null, null);
        System.Test.stopTest();  
    }
    
    @isTest
    static void getPostServiceHeaderDataFromDWHTest() {
        System.Test.startTest();
        Test.setMock( HttpCalloutMock.class, new PostServiceHeaderMocker(false) );
        DWH_AftersalesServiceHeader.syncPostServiceHeaderDataFromDWH( DWH_AftersalesServiceHeader.getPostServiceHeaderDataFromDWH( 1, null, null ) ); 
        System.Test.stopTest();  
    }
    
   
    @isTest
    static void BatchAftersalesServiceHeaderTest() {
        System.Test.startTest();
        Test.setMock( HttpCalloutMock.class, new PostServiceHeaderMocker(true) );
        System.schedule('BatchAftersalesServiceHeader', '0 0 0 ? * * *', new BatchAftersalesServiceHeader());    
        System.Test.stopTest();
    }
    
    @isTest
    static void getSyncAPIAgainTest() {
        System.Test.startTest();
        Test.setMock( HttpCalloutMock.class, new PostServiceHeaderMocker(true) );
        DWH_AftersalesAPIResyncController.getSyncAPIAgain(Date.today(), Date.today());
        System.Test.stopTest();
    }
    
    public class PostServiceHeaderCountMocker implements HttpCalloutMock{
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        String numRecs = lastRunDateVar.Post_Service_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Post_Service_NumRecords__c.intValue()): '2000';
        
        private boolean isBatchRun;
        
        public PostServiceHeaderCountMocker (Boolean fromBatch){
            isBatchRun = fromBatch;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            Datetime today = date.today();
            System.assertEquals('https://www.test.com/DWHAPI/GetServiceHistory_DWH_Count?fromDate='+today.format('yyyy-MM-dd')+'&toDate='+today.format('yyyy-MM-dd'), req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody( strMockResult );
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class PostServiceHeaderMocker implements HttpCalloutMock{
        private boolean isBatchRun;
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        String numRecs = lastRunDateVar.Post_Service_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Post_Service_NumRecords__c.intValue()): '2000';
        
        public PostServiceHeaderMocker (Boolean fromBatch){
            isBatchRun = fromBatch;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            Datetime today = date.today();
            //System.assertEquals('https://www.test.com/DWHAPI/GetServiceHistory_DWH?fromDate='+today.format('yyyy-MM-dd')+'&toDate='+today.format('yyyy-MM-dd')+'&noOfRecords='+numRecs+'&pageNo=1', req.getEndpoint());
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