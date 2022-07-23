/*
Author: Hari Panneerselvam
*/
public class BusinessRuleHandlerSFMC {
    
    public static String getMCAccessToken(){
        map<String, Object> mapJSONBody = new map<String, Object>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String mcClientId = (String)JCC_GlobalVar.MC_ClientId__c;
        String mcClientSceret = (String)JCC_GlobalVar.MC_ClientSecret__c;      
        
        req.setMethod('POST');                  
        req.setHeader('content-type', 'application/json');  
        req.setEndpoint('https://auth.exacttargetapis.com/v1/requestToken' );
        req.setBody('{"clientId": "'+mcClientId+'","clientSecret": "'+mcClientSceret+'"}');
        if(!Test.isRunningTest()){
            res = http.send(req);  
            mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(res.getBody());  
            return (String)mapJSONBody.get('accessToken');
        }else{
            return 'TestToken';
        }
    }
    
    @future(callout=true)
    public static void sendEmail(map<String, String> mapObject){
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
        list<Stock_Reservation__c> lstSR = new list<Stock_Reservation__c>();
        list<Stock_Promotion__c> lstPromo = new list<Stock_Promotion__c>();
        list<Test_Drive__c> lstTD = new list<Test_Drive__c>();
        Http http = new Http(); 
        HttpRequest httpReq = new HttpRequest(); 
        HTTPResponse httpRes = new HttpResponse();
        httpReq.setMethod('POST');
        httpReq.setHeader('content-type', 'application/json;charset=utf-8');    
        httpReq.setHeader('Authorization', 'Bearer '+BusinessRuleHandlerSFMC.getMCAccessToken());
        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+(String)JCC_GlobalVar.Warehouse_Trigger_Send_key__c+'/send');
        lstSR = [select id, CreatedDate, Name, Cancellation_Reason__c, Customer_Name__c, Customer_Mobile_Number__c, Customer_Email__c, Branch_Code__c, Color_Description__c, Model_Description__c,
                 Opportunity__c, Opportunity__r.Owner.name, Opportunity__r.Owner.MobilePhone, Opportunity__r.Owner.Email, 
				 Promo_Gifts_Descriptions__c, Campaign__r.Promo_Code__c
				 from Stock_Reservation__c where id = :mapObject.get('stockReserveId')];
        String emailAddress = mapObject.get('emailFor') == 'Cust' ? lstSR[0].Customer_Email__c : lstSR[0].Opportunity__r.Owner.Email;
        
        If (mapObject.get('brand') == 'CCK' || mapObject.get('brand') == 'CCA' || mapObject.get('brand') == 'CCF'){
            string ccEmailAdd='';
            if(mapObject.get('emailFor')=='SC'){
                List<EmailRecipient__mdt> ccEmailrecord=[SELECT Id, EventType__c, Label, DeveloperName, RecipientEmailAddress__c  FROM EmailRecipient__mdt WHERE EventType__c=: mapObject.get('brand')];
                if (ccEmailrecord != null && !ccEmailrecord.isEmpty()) {
                    for(EmailRecipient__mdt emlData: ccEmailrecord){
                        if(String.isNotBlank(emlData.RecipientEmailAddress__c)){
                            ccEmailAdd += ccEmailAdd=='' ? emlData.RecipientEmailAddress__c : ';' + emlData.RecipientEmailAddress__c;
                        }
                    }
                }
            }       
            if(mapObject.get('emailType') == 'Confirmation'){
                
                lstTD = [select id, Date__c from Test_Drive__c where Opportunity__c = :lstSR[0].Opportunity__c];
                String price = '';
                String address = '';
                String testDriveDate = '';
                if(String.isNotBlank(mapObject.get('stockPromoId'))){
                    lstPromo = [select id, Discounted_Price__c, Address__c from Stock_Promotion__c where id = : mapObject.get('stockPromoId')]; 
                    price = String.format(lstPromo[0].Discounted_Price__c.format(), new String[]{'0','string','###,###,##0.00'});
                    address = lstPromo[0].Address__c;
                }
                if(!lstTD.isEmpty())
                {
                    testDriveDate = lstTD[0].Date__c.format('dd MMM yy, EEE');
                }
                httpReq.setBody('{ "From": {"Address": "'+mapObject.get('fromAddress')+'","Name": "'+mapObject.get('fromName')+'"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"CCAddress": "'+ ccEmailAdd +'","Brand":"'+mapObject.get('brand')+'", "SCName" : "'+lstSR[0].Opportunity__r.Owner.name+'", "CustName" : "'+lstSR[0].Customer_Name__c+'", "EmailAddress":"'+lstSR[0].Customer_Email__c+'", "SubscriberKey":"'+lstSR[0].Customer_Email__c+'", "SCMobile" : "'+lstSR[0].Opportunity__r.Owner.MobilePhone+'", "CustPhoneNo" : "'+lstSR[0].Customer_Mobile_Number__c+'", "ResNo" : "'+lstSR[0].Name+'", "ModelName" : "'+lstSR[0].Model_Description__c+'", "ColorName" : "'+lstSR[0].Color_Description__c+'", "Price" : "'+price+'", "Deposit" : "500", "PromoDesc" : "'+lstSR[0].Promo_Gifts_Descriptions__c+'","PromoCode" : "'+lstSR[0].Campaign__r.Promo_Code__c+'","TestDriveDate" : "'+testDriveDate+'", "Location" : "'+address+'", "EmailFor" : "'+mapObject.get('emailFor')+'", "EmailType" : "'+mapObject.get('emailType')+'", "RefundReason" : "'+lstSR[0].Cancellation_Reason__c+'", "ResDate" : "'+lstSR[0].CreatedDate+'"}}},"Options": {"RequestType": "ASYNC"}}');
            
            }else if(mapObject.get('emailType') == 'Refund'){
                httpReq.setBody('{ "From": {"Address": "'+mapObject.get('fromAddress')+'","Name": "'+mapObject.get('fromName')+'"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Brand":"'+mapObject.get('brand')+'", "SCName" : "'+lstSR[0].Opportunity__r.Owner.name+'", "CustName" : "'+lstSR[0].Customer_Name__c+'", "EmailAddress":"'+lstSR[0].Customer_Email__c+'", "SubscriberKey":"'+lstSR[0].Customer_Email__c+'", "SCMobile" : "'+lstSR[0].Opportunity__r.Owner.MobilePhone+'", "CustPhoneNo" : "'+lstSR[0].Customer_Mobile_Number__c+'", "ResNo" : "'+lstSR[0].Name+'", "ModelName" : "'+lstSR[0].Model_Description__c+'", "ColorName" : "'+lstSR[0].Color_Description__c+'", "EmailFor" : "'+mapObject.get('emailFor')+'", "EmailType" : "'+mapObject.get('emailType')+'", "RefundReason" : "'+lstSR[0].Cancellation_Reason__c+'", "PromoDesc" : "'+lstSR[0].Promo_Gifts_Descriptions__c+'","PromoCode" : "'+lstSR[0].Campaign__r.Promo_Code__c+'", "ResDate" : "'+lstSR[0].CreatedDate+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            
        }
        if(!Test.isRunningTest()){
            httpRes = http.send(httpReq);
            serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
        }
    }
    @future(callout=true)
    public static void sendEventEmail(map<String, String> mapObject){
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();  
        Http http = new Http(); 
        HttpRequest httpReq = new HttpRequest(); 
        HTTPResponse httpRes = new HttpResponse();
        httpReq.setMethod('POST');
        httpReq.setHeader('content-type', 'application/json;charset=utf-8');    
        httpReq.setHeader('Authorization', 'Bearer '+BusinessRuleHandlerSFMC.getMCAccessToken());
        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+(String)JCC_GlobalVar.EventConfirmationTriggeredID__c+'/send');
        If (mapObject.get('Brand') == 'CCK' || mapObject.get('Brand') == 'CCA' || mapObject.get('Brand') == 'CCF'){
            httpReq.setBody('{ "From": {"Address": "'+mapObject.get('fromAddress')+'","Name": "'+mapObject.get('fromName')+'"},"To":{"Address": "'+mapObject.get('EmailAddress')+'","SubscriberKey": "'+mapObject.get('EmailAddress')+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+mapObject.get('ContactName')+'","EventName" : "'+mapObject.get('EventName')+'","Location" : "'+mapObject.get('Location')+'","Attendies":"'+mapObject.get('Attendies')+'","ModelName": "'+mapObject.get('ModelName')+'","SCName": "'+mapObject.get('SCName')+'","SCPhone": "'+mapObject.get('SCPhone')+'","Brand" : "'+mapObject.get('Brand')+'","dateValue": "'+mapObject.get('DateValue')+'","timeSlot":"'+mapObject.get('TimeSlot')+'","eventID":"'+mapObject.get('EventId')+'","DateRange":"'+mapObject.get('DateRange')+'","ImageURL":"'+mapObject.get('ImageURL')+'","LocationName":"'+mapObject.get('LocationName')+'","TemplateName":"'+mapObject.get('TemplateName')+'","PrefferedDate":"'+mapObject.get('PrefferedDate')+'","PrefferedTime":"'+mapObject.get('PrefferedTime')+'","EventText":"'+mapObject.get('EventText')+'","Invoice":"'+mapObject.get('Invoice')+'","EventDescp":"'+mapObject.get('EventDescp')+'","Waitlist":"'+mapObject.get('Waitlist')+'","UnitPrice":"'+mapObject.get('UnitPrice')+'","Type":"'+mapObject.get('Type')+'","Remarks":"'+MapObject.get('Remarks')+'","Subject":"'+MapObject.get('Subject')+'","Reminder":"'+MapObject.get('Reminder')+'"}}},"Options": {"RequestType": "ASYNC"}}');
            
        }
        if(!Test.isRunningTest()){
            httpRes = http.send(httpReq);
            serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
        }
    }
    @future(callout=true)
    public static void sendReminderEventEmail(map<String, String> mapObject){
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();  
        Http http = new Http(); 
        HttpRequest httpReq = new HttpRequest(); 
        HTTPResponse httpRes = new HttpResponse();
        httpReq.setMethod('POST');
        httpReq.setHeader('content-type', 'application/json;charset=utf-8');    
        httpReq.setHeader('Authorization', 'Bearer '+BusinessRuleHandlerSFMC.getMCAccessToken());
        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+(String)JCC_GlobalVar.EventConfirmationTriggeredID__c+'/send');
        If (mapObject.get('Brand') == 'CCK' || mapObject.get('Brand') == 'CCA' || mapObject.get('Brand') == 'CCF'){
            httpReq.setBody('{ "From": {"Address": "'+mapObject.get('fromAddress')+'","Name": "'+mapObject.get('fromName')+'"},"To":{"Address": "'+mapObject.get('EmailAddress')+'","SubscriberKey": "'+mapObject.get('EmailAddress')+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+mapObject.get('ContactName')+'","EventName" : "'+mapObject.get('EventName')+'","Location" : "'+mapObject.get('Location')+'","Attendies":"'+mapObject.get('Attendies')+'","ModelName": "'+mapObject.get('ModelName')+'","SCName": "'+mapObject.get('SCName')+'","SCPhone": "'+mapObject.get('SCPhone')+'","Brand" : "'+mapObject.get('Brand')+'","dateValue": "'+mapObject.get('DateValue')+'","timeSlot":"'+mapObject.get('TimeSlot')+'","eventID":"'+mapObject.get('EventId')+'","DateRange":"'+mapObject.get('DateRange')+'","ImageURL":"'+mapObject.get('ImageURL')+'","LocationName":"'+mapObject.get('LocationName')+'","TemplateName":"'+mapObject.get('TemplateName')+'","PrefferedDate":"'+mapObject.get('PrefferedDate')+'","PrefferedTime":"'+mapObject.get('PrefferedTime')+'","EventText":"'+mapObject.get('EventText')+'","Invoice":"'+mapObject.get('Invoice')+'","EventDescp":"'+mapObject.get('EventDescp')+'","Waitlist":"'+mapObject.get('Waitlist')+'","UnitPrice":"'+mapObject.get('UnitPrice')+'","Type":"'+mapObject.get('Type')+'","Remarks":"'+MapObject.get('Remarks')+'","Subject":"'+MapObject.get('Subject')+'","Reminder":"'+MapObject.get('Reminder')+'"}}},"Options": {"RequestType": "ASYNC"}}');
            
        }
        if(!Test.isRunningTest()){
            httpRes = http.send(httpReq);
            serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
        }
    }
    @future(callout=true)
    public static void sendPostTDFeedbackEmail(map<String, String> mapObject){
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();  
        Http http = new Http(); 
        HttpRequest httpReq = new HttpRequest(); 
        HTTPResponse httpRes = new HttpResponse();
        httpReq.setMethod('POST');
        httpReq.setHeader('content-type', 'application/json;charset=utf-8');    
        httpReq.setHeader('Authorization', 'Bearer '+BusinessRuleHandlerSFMC.getMCAccessToken());
        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+(String)JCC_GlobalVar.PostTestDrivefeedbackTriggeredId__c+'/send');
        If (mapObject.get('Brand') == 'CCK' || mapObject.get('Brand') == 'CCA' || mapObject.get('Brand') == 'CCF' || mapObject.get('Brand') == 'DS'){
            httpReq.setBody('{ "From": {"Address": "'+mapObject.get('fromAddress')+'","Name": "'+mapObject.get('fromName')+'"},"To":{"Address": "'+mapObject.get('EmailAddress')+'","SubscriberKey": "'+mapObject.get('EmailAddress')+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+mapObject.get('ContactName')+'","ContactId" : "'+mapObject.get('ContactId')+'","LeadId" : "'+mapObject.get('LeadId')+'","ModelName": "'+mapObject.get('ModelName')+'","Brand" : "'+mapObject.get('Brand')+'","Type":"'+mapObject.get('Type')+'","OpportunityId":"'+mapObject.get('OpportunityId')+'"}}},"Options": {"RequestType": "ASYNC"}}');
            
        }
        if(!Test.isRunningTest()){
            httpRes = http.send(httpReq);
           
            serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
        }
    }
    @future(callout=true)
    public static void sendEmailPreferredModel(map<String, String> mapObject){
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
        Http http = new Http(); 
        HttpRequest httpReq = new HttpRequest(); 
        HTTPResponse httpRes = new HttpResponse();
        httpReq.setMethod('POST');
        httpReq.setHeader('content-type', 'application/json;charset=utf-8');    
        httpReq.setHeader('Authorization', 'Bearer '+BusinessRuleHandlerSFMC.getMCAccessToken());
        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+(String)JCC_GlobalVar.PreferredModelTriggeredId__c+'/send');
      
        If (mapObject.get('brand') == 'CCK' || mapObject.get('brand') == 'CCA' || mapObject.get('brand') == 'CCF'){
            httpReq.setBody('{ "From": {"Address": "'+mapObject.get('fromAddress')+'","Name": "'+mapObject.get('fromName')+'"},"To":{"Address": "'+mapObject.get('personEmail')+'","SubscriberKey": "'+mapObject.get('personEmail')+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+mapObject.get('personName')+'","Brand": "'+mapObject.get('brand')+'","source": "'+mapObject.get('source')+'"}}},"Options": {"RequestType": "ASYNC"}}');
            
        }
        if(!Test.isRunningTest()){
            httpRes = http.send(httpReq);
            
            serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
        }
    }    
}