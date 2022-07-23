@isTest
global class VSMS_CalloutToDeleteSoAccMock implements HttpCalloutMock {
    public class CalloutException extends Exception {}    
    
    global HTTPResponse respond(HTTPRequest request) {
        if (request.getEndpoint().endsWith('1')) {
            String resBody = 'SUCCESS';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(resBody);
            response.setStatusCode(200);
            return response; 
        } else {
            throw new CalloutException ('false');
        }
    }
}