public  with sharing class send_APP_Confirmation_SMS 
{
public static HTTPResponse res{get; set;}
public static String resBody{get; set;}
public static String endpoint{get; set;}
    
@future (callout=true)
public static void SENDAPPSMS(String SMS_Body, String mobileNumber, String SubscriberKey, String Keyword)
{     
    String tokenValue = '';
    If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!=''){
            SendHttpSMS(SMS_Body,mobileNumber,SubscriberKey,Keyword,tokenValue);}
    }    
}
    
public static void SendHttpSMS(String SMS_Body, String mobileNumber, String SubscriberKey, String Keyword, String tokenValue)
{
    try
    {
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');                                    
        //Seting HttpRequest Method
        req1.setHeader('content-type', 'application/json;charset=utf-8');    
        req1.setHeader('Authorization', 'Bearer '+tokenValue);
        req1.setEndpoint('https://www.exacttargetapis.com/sms/v1/messageContact/'+Keyword+'/send');
        req1.setBody('{"Subscribers": [ { "mobileNumber":"'+mobileNumber+'" ,"SubscriberKey":"'+SubscriberKey+'"}], "Subscribe": "true","Resubscribe": "true", "Keyword": "JCCL", "Override": "true", "messageText":"'+SMS_Body+'"}'); 
        Http http1 = new Http(); 
        If(Test.isRunningTest()==False){HTTPResponse res1 = http1.send(req1); 
                                         resBody=res1.getBody();}
    }
    catch(System.CalloutException e){
        //Exception handling goes here..
        resBody=e.getMessage();
    }
}    
}