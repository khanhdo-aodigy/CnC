@isTest(SeeAllData=false)
private class Test_send_PushMessage {

    @TestSetup
    static void makeData(){

        global_var__c gVar = new global_var__c( APIGateway_url__c='https://www.test.com', 
                                                APIGateway_key__c='testKey', 
                                                TriggeredPush__c = 'Testkeyword',
                                                TriggeredPush_MB__c = 'TestkeywordMB' );
        upsert gVar;
    }

    public static testmethod void Test_sendPUSH() 
    {      
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new PushMessageMocker( 'Testkeyword' ) );
            send_PushMessage.SENDAPPPUSH('PUSH_Body','SubscriberToken','Keyword');
            send_PushMessage.SENDAPPPUSH('PUSH_Body','SubscriberToken','Keyword','Test');
            send_PushMessage.SENDAPPPUSH_MultipleTokens('PUSH_BODY', '"ABC","DEF', '');
    	Test.stopTest();
        httpResponse resTest;
        send_PushMessage.res = resTest;
        send_PushMessage.resBody = '';
        send_PushMessage.endpoint = '';
    }
    
    public static testmethod void SendHttpPUSH_Test() 
    {   
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new PushMessageMocker( 'Testkeyword' ) );
            send_PushMessage.SendHttpPUSH('PUSH_Body','XYZ','Testkeyword','TEST_ACCESS_TOKEN' ,'Test');
            send_PushMessage.SendHttpPUSH('PUSH_Body','QWE','Testkeyword','TEST_ACCESS_TOKEN' );
    	Test.stopTest();
    }


    @isTest
    static void SendHttpPUSH_MultipleTokens_Test() 
    {   
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new PushMessageMocker( 'Testkeyword' ) );
            send_PushMessage.SendHttpPUSH_MultipleTokens( 'PUSH_BODY', '"ABC","DEF', 'Testkeyword', 'TEST_ACCESS_TOKEN','' );
    	Test.stopTest();
    }

	 
    @isTest
    static void SENDAPPPUSH_MultipleTokensForMB_Test() 
    {   
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new PushMessageMocker( 'TestkeywordMB' ) );
            send_PushMessage.SENDAPPPUSH_MultipleTokensForMB('PUSH_BODY', '"ABC","DEF','');
    	Test.stopTest();
    }


    public class PushMessageMocker implements HttpCalloutMock{
        private String keyword;

        public PushMessageMocker ( String param_keyword ){
            keyword = param_keyword;
        }

        public HTTPResponse respond(HTTPRequest req) {

            System.assertEquals('https://www.exacttargetapis.com/push/v1/messageContact/'+keyword+'/send', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=utf-8');
            res.setBody( 'VERYOK' );
            res.setStatusCode(200);
            return res;
        }
    }
}