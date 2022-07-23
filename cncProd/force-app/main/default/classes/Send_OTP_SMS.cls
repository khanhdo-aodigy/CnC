public  with sharing class Send_OTP_SMS {

    public static HTTPResponse res{get; set;}
    public static String resBody{get; set;}
    public static String resBody1{get; set;}
    public static String endpoint{get; set;}
    
    @future (callout=true)
    public static void SENDSMS(String SMS_Body, String mobileNumber, String SubscriberKey, String Keyword)
    {     
        try
        {
            String tokenValue = GenerateRequestToken.getRequestToken(); 
        	//String tokenValue = GenerateRequestToken_Temp.getRequestToken(); 
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('POST');                                    
            //Seting HttpRequest Method
            req1.setHeader('content-type', 'application/json;charset=utf-8');    
            req1.setHeader('Authorization', 'Bearer '+tokenValue);
            req1.setEndpoint('https://www.exacttargetapis.com/sms/v1/messageContact/'+Keyword+'/send');
            req1.setBody('{"Subscribers": [ { "mobileNumber":"'+mobileNumber+'" ,"SubscriberKey":"'+SubscriberKey+'" }], "Subscribe": "true","Resubscribe": "true", "Keyword": "JCCL", "Override": "true", "messageText":"'+SMS_Body+'"}');
            Http http1 = new Http(); 
            System.debug('1==='+req1.getBody());            
            If(Test.isRunningTest()==False){
            HTTPResponse res1 = http1.send(req1); 
            resBody=res1.getBody();
            System.debug('1==='+ resBody);
             
             }
        }
        catch(System.CalloutException e)
        {
            //Exception handling goes here..
            resBody=e.getMessage();
            System.debug('exception==='+ resBody);
        }
       } 
    }