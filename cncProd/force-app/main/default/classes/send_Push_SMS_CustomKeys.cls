public  with sharing class send_Push_SMS_CustomKeys {

public static HTTPResponse res{get; set;}
public static String resBody{get; set;}
public static String endpoint{get; set;}
    
@future (callout=true)
public static void SENDAPP_PUSH_SMS(String ContactKey, String mobilenumber, String SubscriberToken, String Keyword, String Type_val, String Id_val, String PUSH_txt, String PUSH_Title, String PUSH_Subtitle,  String SMS_txt, String End_Date, String openDirect)
{             
     String tokenValue = '';
    If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!='')
        {
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String  QA_Domain_URL = (String)JCC_GlobalVar.QA_Domain_URL__c; 
            String SMS_link = GetPromoLink(Id_val);
            If(SMS_link!=''){
                SMS_link = QA_Domain_URL + SMS_link + '&enddate='+End_Date+'&Type='+Type_val+'&Id='+Id_val;}
            SendHttpSMSPUSH(ContactKey,mobilenumber,SubscriberToken,Keyword,Type_val,Id_val,PUSH_txt, PUSH_Title, PUSH_Subtitle, SMS_txt,SMS_link,tokenValue,End_Date,openDirect);}
    }    
}
    
public static void SendHttpSMSPUSH(String ContactKey, String mobilenumber, String SubscriberToken, String Keyword, String Type_val, String Id_val, String PUSH_txt, String PUSH_Title, String PUSH_Subtitle, String SMS_txt, String SMS_link, String tokenValue, String End_Date, String openDirect)
{
    try
    {   
        If (SubscriberToken.trim()!='')
        {           
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('POST');                                    
            //Seting HttpRequest Method
            req1.setHeader('content-type', 'application/json;charset=utf-8');    
            req1.setHeader('Authorization', 'Bearer '+tokenValue);
            req1.setEndpoint('https://www.exacttargetapis.com/push/v1/messageContact/'+Keyword+'/send');
            req1.setBody('{"DeviceTokens":["'+SubscriberToken+'"], "Override": 1, "MessageText": "'+PUSH_txt+'", "alert": "Push Alert","title": "'+PUSH_Title+'", "subtitle": "'+PUSH_Subtitle+'" ,"MessageCategory": { "Name": "ApiTriggeredMessage"}, "OpenDirect": "'+openDirect+'", "mutable-content": 0,"CustomKeys": {"Type": "'+Type_val+'", "Id": "'+Id_Val+'"}}'); 
            Http http1 = new Http(); 
            If(Test.isRunningTest()==False){HTTPResponse res1 = http1.send(req1); 
                                            resBody=res1.getBody();}
        }
        
        If (mobilenumber.trim()!='')
        {
            mobileNumber=mobileNumber.trim().deleteWhitespace();
            HttpRequest req2 = new HttpRequest();
            req2.setMethod('POST');                                    
            //Seting HttpRequest Method
            req2.setHeader('content-type', 'application/json;charset=utf-8');    
            req2.setHeader('Authorization', 'Bearer '+tokenValue);
            req2.setEndpoint('https://www.exacttargetapis.com/sms/v1/messageContact/'+Keyword+'/send');
            req2.setBody('{"Subscribers": [ { "mobileNumber":"'+mobileNumber+'" ,"SubscriberKey":"'+ContactKey+'", "Attributes":{"Id_Val":"'+Id_Val+'"}}], "Subscribe": "true","Resubscribe": "true", "Keyword": "JCCL", "Override": "true", "messageText":"'+SMS_txt+'%%=char(10,2)=%%'+SMS_link+'"}');             
            Http http2 = new Http(); 
            If(Test.isRunningTest()==False){HTTPResponse res2 = http2.send(req2); 
                                            resBody=res2.getBody();}
        }

		System.debug('Push Campg call success ++ ' + resBody);
        
    }
    catch(System.CalloutException e)
    {
        //Exception handling goes here..
        resBody=e.getMessage();
		System.debug('Push Campg call error ++ ' + resBody);
    }
}
    
    
//Code to get Promolink from CMS based upon Promo Id
public static String GetPromoLink(String promoid)
{
        
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
    String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;  
    
    HttpRequest req = new HttpRequest();
    HttpResponse resInput = new HttpResponse();
    Http http = new Http();
    String PromoLink;
    //Rest call to CMS for getting the T&C data.
    req.setEndpoint(APIGateway_url+'/CmsAPI/GetPromos');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
    req.setHeader('apikey', APIGateway_key);       
    req.setBody('{"PromoIDs": ["'+promoid+'"], "CountryName": "SG"}');
    req.setTimeout(120000);  
    try 
    {   
        //Send http request, capture response and pass the response to mothod       
        resInput = http.send(req); 
    }
    catch(exception ex1)
    {
        system.debug(ex1.getMessage());
    }
	 PromoLink='';
    if(resInput.getBody()!=null && resInput.getBody().trim()!='')
    {
        // Parse entire JSON response.        
        Invoice_TC_JSON2Apex sVar = Invoice_TC_JSON2Apex.parse(resInput.getBody());  
        If(sVar.Result.Promo.size()>0)
        {
            PromoLink=sVar.Result.Promo[0].PromoUrl;
        }
    }
    return PromoLink;
}
    
}