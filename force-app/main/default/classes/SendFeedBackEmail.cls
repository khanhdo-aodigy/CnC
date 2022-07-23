public without sharing class SendFeedBackEmail{   
    
    public static HTTPResponse res{get; set;}
    public static String resBody{get; set;}
    public static String tokenValue = '';

    @future (callout=true)
    public static void sendEmail(String name,String phoneNumber,String category,String message,String regNumber,String lastVisitedCenter,String triggeredSendMessageId,String emailaddr)
        
    {
        
        
        If(Test.isRunningTest()==False)
        {
            tokenValue = GenerateRequestToken.getRequestToken();
            If(tokenValue!='')
            {
                sendHttpEmail(name,phoneNumber,category,message,regNumber,lastVisitedCenter,tokenValue,triggeredSendMessageId,emailaddr) ;
            }
            
        }
        
    }
    
    public static void sendHttpEmail(String name,String phoneNumber,String category,String message,String regNumber,String lastVisitedCenter,String tokenValue ,String triggeredSendMessageId,String emailaddr)
    {
        if((String.isNotBlank(emailaddr)))
        {  
            try
            {
                HttpRequest reqPrimaryEmail = new HttpRequest();
                reqPrimaryEmail.setMethod('POST');                                    
                //Seting HttpRequest Method
                reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
                reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
                reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
                
                String msg = formattedString(message);
                reqPrimaryEmail.setBody('{ "From": {"Address": "custcare.sg@e.cyclecarriage.com","Name": "C&C Customer Care "},"To":{"Address": "'+emailaddr+'","SubscriberKey": "'+emailaddr+'","ContactAttributes": {"SubscriberAttributes":{"name": "'+name+'","phoneNumber" : "'+phoneNumber+'","category" : "'+category+'","message":"'+ msg +'","regNumber": "'+regNumber+'","lastVisitedCenter": "'+lastVisitedCenter+'","emailaddr": "'+emailaddr+'", "custEmail": "'+emailaddr+'","subjLine":""}}},"Options": {"RequestType": "ASYNC"}}');
                system.debug('test==='+reqPrimaryEmail.getBody());
                
                Http http1 = new Http(); 
                If(Test.isRunningTest()==False){
                    HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                    
                    //Customer Care Email
                    global_var__c br = global_var__c.getOrgDefaults();

                    reqPrimaryEmail.setBody('{ "From": {"Address": "custcare.sg@e.cyclecarriage.com","Name": "C&C Customer Care "},"To":{"Address": "'+br.CustomerCareEmail__c+'","SubscriberKey": "'+br.CustomerCareEmail__c+'","ContactAttributes": {"SubscriberAttributes":{"name": "'+name+'","phoneNumber" : "'+phoneNumber+'","category" : "'+category+'","message":"'+ msg +'","regNumber": "'+regNumber+'","lastVisitedCenter": "'+lastVisitedCenter+'","emailaddr": "'+br.CustomerCareEmail__c+'", "custEmail": "'+emailaddr+'","subjLine":"[CAC Copy]"}}},"Options": {"RequestType": "ASYNC"}}');
                    res1 = http1.send(reqPrimaryEmail); 
                 }
            }
            catch(Exception e)       
            {
                loggerDataPool.buildLogDataPool('Feedback.sendHttpEmail',e);
            }
        }
    }
    
    //Removes line breaks and carriage return
    //Long Term Solution: Encoding in Apex but there is no urldecode 
    //						in Marketing Cloud as of the moment (2019-Mar)
    public static String formattedString(String inputMsg){
        String retStr = null;
        if(String.isNotBlank(inputMsg)){
            retStr = inputMsg.replace('\r',' ');
            retStr = retStr.replace('\n',' ');
            retStr = retStr.replace('\r\n',' ');
        }
        return retStr;
    }
}