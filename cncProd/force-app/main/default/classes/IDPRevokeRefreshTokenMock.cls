@isTest
global class IDPRevokeRefreshTokenMock implements HttpCalloutMock 
{
    public class CalloutException extends Exception {}
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getBody() != null ) 
        {    
            String resBody = '{"code":"OK","message":"refresh token revoked"}';
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