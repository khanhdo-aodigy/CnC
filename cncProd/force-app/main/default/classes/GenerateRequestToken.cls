//Calss to generate marketiing cloud Access token to send Transactional messages.
public class GenerateRequestToken
{
    public static HTTPResponse res{get; set;}
    public static String resBody{get; set;}
    public static String tokenValue{get; set;}
    public static String endpoint{get; set;}
    
    public static  String getRequestToken()
        
    {
        try
        {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');                                    
            //Seting HttpRequest Method
            req.setHeader('content-type', 'application/json');            
            //req.setHeader('Content-Length', '2000');
            req.setEndpoint('https://auth.exacttargetapis.com/v1/requestToken' );
            
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String  MC_clientId = (String)JCC_GlobalVar.MC_ClientId__c;
            String  MC_clientSecret = (String)JCC_GlobalVar.MC_ClientSecret__c;        
            req.setBody('{"clientId": "'+MC_clientId+'","clientSecret": "'+MC_clientSecret+'"}');
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            
            If(Test.isRunningTest()==True)
            {
                res.setBody('{"accessToken": "test_token","expiresIn": 123}'); 
            }
            else
            {
                res = http.send(req);  
            }
            JSONParser parser = JSON.createParser(res.getBody());  
            resBody=res.getBody();
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'accessToken')) {
                        parser.nextValue();
                        tokenValue=parser.getText();                    
                    }
            }
            
        }
        //Catch system exception if any.
        catch(Exception e)
        {
            system.debug('Error'+e.getMessage());
            
        }
        return  tokenValue;
    }
}