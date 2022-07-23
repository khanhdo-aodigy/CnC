@isTest(seeAllData=true)
 global  class Test_callUpdateNricAutomation implements  HttpCalloutMock 
{
     global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
}

  static testMethod  void testCalloutWithStaticResources() 
	{
        
   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_callUpdateNricAutomation());
		String reqTokenEndPoint = 'https://auth.exacttargetapis.com/v1/requestToken' ;
        String webserviceEndPoint = 'https://webservice.s10.exacttarget.com/Service.asmx';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://webservice.s10.exacttarget.com/Service.asmx';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        
        // Call the method that performs the callout
            CallUpdateNricAutomation.makeHTTPXMLPost();
        Test.stopTest(); 
      

    }
}