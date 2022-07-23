@isTest
public with sharing class DocusignMockHttpResponseGenerator implements HttpCalloutMock {
    public DocusignMockHttpResponseGenerator() {

    }

    // response for embedded signing URL request
    public HttpResponse respond(HttpRequest req) {
        HttpResponse respond = new HttpResponse();
        respond.setHeader('Content-Type', 'application/json');
        respond.setBody('{"users":[{"userName":"First Name Last Name","email":"test@heavenxxx.com"}]}');
        respond.setStatusCode(200);
        return respond;
    }

    // response for envelope creating
    public static HttpResponse envelopeCreateRespond(HTTPRequest req) {
        HttpResponse respond = new HttpResponse();
        respond.setHeader('Content-Type', 'application/json');
        respond.setBody('{"url" : "https://demo.docusign.net/Signing/MTRedeem/v1?slt=TEST"}');
        respond.setStatusCode(201);
        return respond;
    }
}