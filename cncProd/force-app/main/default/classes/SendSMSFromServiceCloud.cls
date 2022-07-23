global class SendSMSFromServiceCloud {
  
    global static String resBody;
    
    @InvocableMethod(label='Method called From Flow')
    public static void SendSMSNow(List<FlowInputs> request)
    {
        try
        {
            String tokenValue = GenerateRequestToken.getRequestToken(); 
            system.debug('token value..' + tokenValue);
            
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('POST');                                    
            //Seting HttpRequest Method
            req1.setHeader('content-type', 'application/json;charset=utf-8');    
            req1.setHeader('Authorization', 'Bearer '+tokenValue);
            req1.setEndpoint('https://www.exacttargetapis.com/sms/v1/messageContact/'+request[0].Keyword+'/send');
            req1.setBody('{"Subscribers": [ { "mobileNumber":"'+request[0].mobileNumber+'" ,"SubscriberKey":"'+request[0].SubscriberKey+'" }], "Subscribe": "true","Resubscribe": "true", "Keyword": "JCCL", "Override": "true", "messageText":"'+request[0].SMS_Body+'"}');
            Http http1 = new Http(); 
            HTTPResponse res1 = http1.send(req1); 
            resBody=res1.getBody();
            system.debug('resBody...' + resBody); 
        }
        catch(System.CalloutException e)
        {
            //Exception handling goes here..
            resBody=e.getMessage();
        }
        
    }    
    
    public class FlowInputs{
        
        @InvocableVariable
        public String Keyword;
        
        @InvocableVariable
        public String mobileNumber;
        
        @InvocableVariable
        public String SMS_Body;     
        
        @InvocableVariable
        public String SubscriberKey;
        
    }
    
}