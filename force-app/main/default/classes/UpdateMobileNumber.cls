public class UpdateMobileNumber {

    public static HTTPResponse res{get; set;}
    public static String resBody{get; set;}
    public static String tokenValue{get; set;}
    public static String endpoint{get; set;}
    
    @future (callout=true)
    public static void sendEmail(String Name,string MobileNumber,String Email)
    {     
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
        String  triggeredSendMessageId = (String)JCC_GlobalVar.Update_Mobile_Number__c;
        
        try{
        If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
    	}

            
            if((String.isNotBlank(Email)))
            {         
                HttpRequest reqPrimaryEmail = new HttpRequest();
                reqPrimaryEmail.setMethod('POST');                                    
                //Seting HttpRequest Method
                reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
                reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
                reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
                reqPrimaryEmail.setBody('{ "From": {"Address": "profile.sg@e.cyclecarriage.com","Name": "Your C&C Profile"},"To":{"Address": "'+Email+'","SubscriberKey": "'+Email+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+Name+'","MobileNumber": "'+MobileNumber+'"}}},"Options": {"RequestType": "ASYNC"}}');
                Http http1 = new Http(); 
                If(Test.isRunningTest()==False){
                HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                    resBody=res1.getBody();}
                System.debug('SMS Response: ' + resBody);
            }
            
            
        }
        catch(System.CalloutException e){       
            {
                //Exception handling goes here..
                system.debug(e);
                resBody=e.getMessage();
            }
        }
        
        
    }
}