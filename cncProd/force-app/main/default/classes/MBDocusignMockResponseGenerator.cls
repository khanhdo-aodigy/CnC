@isTest
public class MBDocusignMockResponseGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"envelopeId":"2a71d779-ced8-4bb1-9f3b-723d8873da53","uri":"/envelopes/2a71d779-ced8-4bb1-9f3b-723d8873da53","statusDateTime":"2020-11-24T07:09:19.7160348Z","status":"sent","url":"https://demo.docusign.net/Signing/MTRedeem/v1?slt=TEST"}');
        response.setStatusCode(201);
        response.setStatus('Created');
        return response;
    }
}