public class PriceAlert_ConfirmationEmailSend {
    public static HTTPResponse res{get; set;}
public static String resBody{get; set;}
    
@future (callout=true)
    public static void sendEmail(String personName,String personEmail,String SubscriberKey, String triggeredSendMessageId,String BranchCode, String ModelName)
    {
        String tokenValue = '';
    If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!='')
        {
            SendHttpEmail(personName,personEmail,SubscriberKey, triggeredSendMessageId,tokenValue,BranchCode,ModelName);
        }
        
    }

}
    public static void SendHttpEmail(String personName,String personEmail,String SubscriberKey, String triggeredSendMessageId,String tokenValue,String BranchCode,String ModelName)
    {
        if(String.isNotBlank(personEmail))
        {
            try
            {
                HttpRequest reqPrimaryEmail = new HttpRequest();
            	reqPrimaryEmail.setMethod('POST');
                reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
            	reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
                reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
                
                if(BranchCode=='CCK'){
                
                reqPrimaryEmail.setBody('{ "From": {"Address": "sales.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Sales"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                Else If(BranchCode=='CCA')
                {
                  reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Sales"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'"}}},"Options": {"RequestType": "ASYNC"}}');  
                }
                Else If(BranchCode=='CCF')
                {
                   reqPrimaryEmail.setBody('{ "From": {"Address": "sales.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Sales"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'"}}},"Options": {"RequestType": "ASYNC"}}');  
					if(ModelName.contains('DS')) 
					{
						reqPrimaryEmail.setBody('{ "From": {"Address": "sales.ds.sg@e.cyclecarriage.com","Name": "C&C DS Sales"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'"}}},"Options": {"RequestType": "ASYNC"}}');  
					}
                }
                Else If(BranchCode=='CCI')
                {
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes Sales"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                
                
                
                Http http1 = new Http(); 
            	System.debug('body==='+reqPrimaryEmail.getBody());
                    If(Test.isRunningTest()==False)
                    {
                        HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                        resBody=res1.getBody();       
                        system.debug('responseBody::::' +resBody);
                    }
            }
            catch(Exception e)
            {
                System.debug('An Error Occured: ' + e.getMessage());
            }
        }
    }
}