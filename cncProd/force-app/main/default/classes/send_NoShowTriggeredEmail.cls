/** *******
 * Class Name: send_NoShowTriggeredEmail
 * Description: Utility class for sending No Show Emails
 *              The email is sent via MC Triggered send.
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * 20180913             Cycle & Carriage            Created Initial version
 * 20200831             khanh.do@aodigy.com         Added PA Migration - Phase 2 Changes. Removed Lead reference
 * 
 ******* **/
public without sharing class send_NoShowTriggeredEmail {

    @future (callout=true)
    public static void sendNoShowEmail ( String emailAddr,
                                         String branchCode,
                                         String TVariant,
                                         String OwnerName,
                                         String OwnerPhone,
                                         String Contact_Id,
                                        //String Lead_Id,
                                        String ContactName)
    {   
        sendNoShowEmailOverride(emailAddr, branchCode, TVariant, OwnerName, OwnerPhone, Contact_Id, ContactName); //PA-Phase2: Removed param Lead_Id
    } 

    public static void sendNoShowEmailOverride (String emailAddr,
                                                String branchCode,
                                                String TVariant,
                                                String OwnerName,
                                                String OwnerPhone,
                                                String Contact_Id,
                                                //String Lead_Id,  //PA-Phase 2: Removed param Lead_Id
                                                String ContactName)
    {   
        HttpRequest reqPrimaryEmail;
        HTTPResponse resp;
        String tokenValue;
        try{
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
            String  triggeredSendMessageId = (String)JCC_GlobalVar.No_Show_Email_MC_TriggerId__c;
            if( !Test.isRunningTest() ){
                tokenValue = GenerateRequestToken.getRequestToken();
            }
            
            if((String.isNotBlank(emailAddr)))
            {         
                reqPrimaryEmail = new HttpRequest();
                reqPrimaryEmail.setMethod('POST');     
                
                //Seting HttpRequest Method
                reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
                reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
                reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
                /*
                if(branchCode=='CCK'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'","Lead_Id": "'+Lead_Id+'","Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                else if(branchCode=='CCA'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'","Lead_Id": "'+Lead_Id+'","Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                else if(branchCode=='CCF'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'","Lead_Id": "'+Lead_Id+'","Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');

					if(TVariant.contains('DS')) 
					{
						reqPrimaryEmail.setBody('{ "From": {"Address": "sales.DS.sg@e.cyclecarriage.com","Name": "C&C DS Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'","Lead_Id": "'+Lead_Id+'","Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
					}

                }
                else if(branchCode=='CCI'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'","Lead_Id": "'+Lead_Id+'","Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }*/

                if(branchCode=='CCK'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'", "Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                else if(branchCode=='CCA'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'", "Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                else if(branchCode=='CCF'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'", "Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');

					if(TVariant.contains('DS')) 
					{
						reqPrimaryEmail.setBody('{ "From": {"Address": "sales.DS.sg@e.cyclecarriage.com","Name": "C&C DS Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'", "Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
					}

                }
                else if(branchCode=='CCI'){
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes Sales"},"To":{"Address": "'+emailAddr+'","SubscriberKey": "'+emailAddr+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+ContactName+'", "Branch": "'+branchCode+'","VariantModelName": "'+TVariant+'","OwnerName": "'+OwnerName+'","OwnerPhone": "'+OwnerPhone+'","Contact_Id": "'+Contact_Id+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }

                 
                Http ht = new Http();
                System.debug('_____________req'+reqPrimaryEmail);
                resp = ht.send(reqPrimaryEmail); 
                System.debug('_____________res'+resp);                 
            }
        }
        catch(Exception e){       
            loggerDataPool.buildLogDataPool('send_NoShowTriggeredEmail', e);
            //Set mock status code as failed.\
            if(resp != null ){
                resp.setStatusCode(400);
            }
            else{
                resp = new HTTPResponse();
            }
            
            resp.setBodyAsBlob( 
                Blob.valueOf( 
                    JSON.Serialize( 
                        new Utility.httpErrorResponse('Failed', e.getMessage()) 
                    ) 
                )
            );
        }
        
        //Create a Service Data Pool
        serviceDataPool.buildServiceDataPoolHttp('send_NoShowTriggeredEmail', 'sendNoShowEmail', '', reqPrimaryEmail, resp);
    }    
}