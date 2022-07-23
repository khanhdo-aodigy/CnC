@isTest
global class IDPRecaptchaMock implements HttpCalloutMock 
{
    public class CalloutException extends Exception {}
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getBody() != null ) 
        {    
            String resBody = '{"success": true,"challenge_ts":"0001-01-01T00:00:00","hostname": "www.testing.com","error-codes": []}';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(resBody);
            response.setStatusCode(200);
        } 
        else 
        {
            response.setStatusCode(400);
            throw new CalloutException('false--exception error');
        }

        return response; 
    }
}