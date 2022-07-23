@isTest
public class DocusignJWTMockResponse implements HttpCalloutMock {
    
	public HttpResponse respond(HttpRequest req) {
        HttpResponse respond = new HttpResponse();
        respond.setHeader('Content-Type', 'application/json');
        respond.setBody('{"access_token":"MOCK_ACCESS_TOKEN"}');
        respond.setStatusCode(200);
        return respond;
    }
    
}