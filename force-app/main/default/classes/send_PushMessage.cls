public without sharing class send_PushMessage 
{
    public static HTTPResponse res{get; set;}
    public static String resBody{get; set;}
    public static String endpoint{get; set;}
    
    @future (callout=true)
    public static void SENDAPPPUSH(String PUSH_Body, String SubscriberToken, String Keyword, String apptType)
    {         
        String tokenValue = '';
        if(Test.isRunningTest() == false)
        {
            tokenValue = GenerateRequestToken.getRequestToken();
        }
        
        if(tokenValue!='')
        {
            SendHttpPUSH(PUSH_Body,SubscriberToken,Keyword,tokenValue, apptType);
        }    
    }
        
    public static void SendHttpPUSH(String PUSH_Body, String SubscriberToken, String Keyword, String tokenValue, String apptType)
    {
        try
        {    
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('POST');                                    
            //Seting HttpRequest Method
            req1.setHeader('content-type', 'application/json;charset=utf-8');    
            req1.setHeader('Authorization', 'Bearer '+tokenValue);
            req1.setEndpoint('https://www.exacttargetapis.com/push/v1/messageContact/'+Keyword+'/send');
            //req1.setEndpoint('https://mcf81mjmhlj0b3t706c8ywng1zn1.rest.marketingcloudapis.com/push/v1/messageContact/'+Keyword+'/send');
            req1.setBody('{"deviceTokens":["'+SubscriberToken+'"], "Override": 1, "MessageText": "'+PUSH_Body+'","alert": "Push Alert","title":"'+apptType+'", "subtitle": "" ,"MessageCategory": { "Name": "ApiTriggeredMessage"},"mutable-content": 0}'); 
            Http http1 = new Http(); 
            if(Test.isRunningTest()==False)
            {
                HTTPResponse res1 = http1.send(req1); 
                resBody=res1.getBody();
                System.debug('++ ' + resBody);
            }
        }
        catch(Exception e)
        {
            loggerdatapool.buildLogDataPool('send_PushMessage', e);
        }
    }


    @future (callout=true)
    public static void SENDAPPPUSH(String PUSH_Body, String SubscriberToken, String Keyword)
    {         
        String tokenValue = '';
        if(Test.isRunningTest() == false)
        {
            tokenValue = GenerateRequestToken.getRequestToken();
        }
        
        if(tokenValue!='')
        {
            SendHttpPUSH(PUSH_Body,SubscriberToken,Keyword,tokenValue);
        }    
    }
        
    public static void SendHttpPUSH(String PUSH_Body, String SubscriberToken, String Keyword, String tokenValue)
    {
        try
        {    
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('POST');                                    
            //Seting HttpRequest Method
            req1.setHeader('content-type', 'application/json;charset=utf-8');    
            req1.setHeader('Authorization', 'Bearer '+tokenValue);
            req1.setEndpoint('https://www.exacttargetapis.com/push/v1/messageContact/'+Keyword+'/send');
            req1.setBody('{"deviceTokens":["'+SubscriberToken+'"], "Override": 1, "MessageText": "'+PUSH_Body+'","alert": "Push Alert","title": "PushMessage", "subtitle": "Subtitle" ,"MessageCategory": { "Name": "ApiTriggeredMessage"},"mutable-content": 0}'); 
            Http http1 = new Http(); 
            if(Test.isRunningTest()==false){
                HTTPResponse res1 = http1.send(req1); 
                resBody=res1.getBody();
            }
        }
        catch(System.CalloutException e)
        {
            //Exception handling goes here..
            resBody=e.getMessage();
        }
    }

    @future (callout=true)
	public static void SENDAPPPUSH_MultipleTokens( String push_body, String openDirect, String subscriber_tokens )
	{         
		global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
		String keyword = (String)JCC_GlobalVar.TriggeredPush__c;
		String token_value = '';
        // if( System.Test.isRunningTest() == false ) {
            token_value = GenerateRequestToken.getRequestToken();
        // }
        if( String.isNotBlank( token_value ) ) 
        {
            SendHttpPUSH_MultipleTokens( push_body , subscriber_tokens, keyword, token_value, openDirect );
        }    
    }

    public static void SendHttpPUSH_MultipleTokens( String push_body, String subscriber_tokens, String keyword, String token_value, String openDirect)
	{
		//string openDirect = 'https://qa-eshop-mitsubishi.cyclecarriage.com/Catalogs/MIT/MIT-Lifestyle-Collection/WMITQDULJ';

		try
		{    
			HttpRequest req = new HttpRequest();
			req.setMethod('POST');                                    
			req.setHeader('content-type', 'application/json;charset=utf-8');    
			req.setHeader('Authorization', 'Bearer '+token_value);
            req.setEndpoint('https://www.exacttargetapis.com/push/v1/messageContact/'+keyword+'/send');
			req.setBody('{"deviceTokens":['+subscriber_tokens+'], "Override": 1, "MessageText": "'+push_body+'","alert": "Push Alert","title":"", "subtitle": "" ,"MessageCategory": { "Name": "ApiTriggeredMessage"}, "OpenDirect": "'+openDirect+'", "mutable-content": 0}'); 
			Http http1 = new Http(); 
            // if( System.Test.isRunningTest() == false ) {
                HTTPResponse res = http1.send( req ); 
                String resBody = res.getBody();
                System.debug('@@@@DEBUG SendHttpPUSH_MultipleTokens :: resBody = ' + resBody);
			// }
		}
		catch(Exception e)
        {
			loggerdatapool.buildLogDataPool('send_PushMessage', e);
		}
	}


    @future (callout=true)
	public static void SENDAPPPUSH_MultipleTokensForMB( String push_body, String openDirect, String subscriber_tokens )
	{   
		global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
		String keyword = (String)JCC_GlobalVar.TriggeredPush_MB__c;
		String token_value = '';
        token_value = GenerateRequestToken.getRequestToken();

        if( String.isNotBlank( token_value ) )
        {
            SendHttpPUSH_MultipleTokensForMB( push_body , subscriber_tokens, keyword, token_value, openDirect);
        }    
    }


    public static void SendHttpPUSH_MultipleTokensForMB( String push_body, String subscriber_tokens, String keyword, String token_value, String openDirect )
	{
		try
		{
			HttpRequest req = new HttpRequest();
			req.setMethod('POST');                                    
			req.setHeader('content-type', 'application/json;charset=utf-8');    
			req.setHeader('Authorization', 'Bearer '+token_value);
            req.setEndpoint('https://www.exacttargetapis.com/push/v1/messageContact/'+keyword+'/send');
			req.setBody('{"deviceTokens":['+subscriber_tokens+'], "Override": 1, "MessageText": "'+push_body+'","alert": "Push Alert","title":"", "subtitle": "" ,"MessageCategory": { "Name": "ApiTriggeredMessage"}, "OpenDirect": "'+openDirect+'", "mutable-content": 0}'); 
			Http http1 = new Http(); 
            HTTPResponse res = http1.send( req ); 
            String resBody = res.getBody();
            System.debug('@@@@DEBUG SendHttpPUSH_MultipleTokensForMB :: resBody = ' + resBody);
		}
		catch(Exception e)
        {
			loggerdatapool.buildLogDataPool('SendHttpPUSH_MultipleTokensForMB', e);
		}
	}
}