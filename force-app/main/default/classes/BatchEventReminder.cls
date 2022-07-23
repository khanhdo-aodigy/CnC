/** *******
 * Description : Batch Job to update Event_Registration__c
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * 20190524             Varinder Kaur               Created Initial version
 * 20200831             khanh.do@aodigy.com         Added PA Migration - Phase 2 Changes
 * 
 ******* **/
global class BatchEventReminder implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public class CustBatchException extends Exception{}

    global final List<Event_Registration__c> erList;

    global BatchEventReminder(List<Event_Registration__c> evtReminder)
    {
        System.debug('evtReminder---->'+evtReminder);
        erList = evtReminder;
    }

    global List<SObject> start(Database.BatchableContext BC)
    {
        return erList;
    }

    global void execute(Database.BatchableContext BC, List<Event_Registration__c> scope)
    {
        System.debug('BC---->'+BC);
        System.debug('scope---->'+scope);
        try{
            if(!scope.isEmpty()){
                String ContactName,SCName,Brand,emailAddress,EventDescp,Subject,PreviewText,EventName,BrandName;
                Decimal UnitPrice = 0;
                map<String, String> mapGenerateDE = new map<String, String>();

                Event_Registration__c ers  = [  SELECT Id, Name, Event_Date__c, Location__c,PromoID__r.Name, PromoID__r.Description,
                                                PromoID__r.UnitPrice__c, PromoID__r.Type,  PromoID__r.Branch_Code__c, NumberOfGuests__c,Remarks__c,
                                                ContactId__c, ContactId__r.Email, ContactId__r.Name,                          
                                                //LeadId__c,LeadId__r.Email,LeadId__r.Name,                                   
                                                //Account__c, Account__r.PersonEmail, Account__r.Name,  
                                                //Account__r.RecordTypeId, Account__r.RecordType.DeveloperName, 
                                                ModelCode__r.Branch_Code__c, ModelCode__r.name,
                                                Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName,
                                                Opportunity__r.Owner.MobilePhone, TimeSlot__c, FirstName__c, Email__c, DateRange__c,
                                                ImageURL__c, Location_Name__c, TemplateName__c, Preffered_Date__c, Preffered_Time__c, Waitlist__c 
                                                FROM Event_Registration__c 
                                                WHERE Id =:scope[0].Id ];

                if(ers.Waitlist__c){
                    return;
                }
                mapGenerateDE.put('Reminder', String.valueOf(true));
                EventName =  ers.PromoID__r.Name;
                mapGenerateDE.put('EventText', ers.PromoID__r.Name);
                if(String.isNotBlank(ers.PromoID__r.Branch_Code__c)){
                    Brand = ers.PromoID__r.Branch_Code__c;
                }

                Boolean waitlist = false;
                /*added by varinder-grazitti if not model is there */
                if(String.isBlank(ers.PromoID__r.Branch_Code__c) && String.isNotBlank(ers.ModelCode__r.Branch_Code__c))
                {
                    Brand = ers.ModelCode__r.Branch_Code__c;
                }

                if(ers.FirstName__c !=null ||ers.FirstName__c !='')
                {
                    ContactName = ers.FirstName__c;
                }
                if(ers.Email__c !=null || ers.Email__c !='')
                {
                    emailAddress = ers.Email__c;
                }

                /** PA MIGRATION : Newly Added Part 1 START 
                if( ers.Account__c != null ) 
                {
                    if(ContactName =='' || ContactName == null)
                    {
                        ContactName = ers.Account__r.Name;
                    }
                    if(emailAddress =='' || emailAddress == null)
                    {
                        emailAddress = ers.Account__r.PersonEmail;
                    }

                    String cust_type = '';
                    if( ers.Account__r.RecordType.DeveloperName == 'Customer' ) {
                        cust_type = 'Contact';
                    }
                    else if( ers.Account__r.RecordType.DeveloperName == 'Prospect' ) {
                        cust_type = 'Lead';
                    } 

                    mapGenerateDE.put('Type', cust_type ); 
                }
                /** PA MIGRATION : Newly Added Part 1 END */


                if (ers.ContactId__c != null)
                {
                    if(ContactName =='' || ContactName == null)
                    {
                        ContactName = ers.ContactId__r.Name;
                    }
                    if(emailAddress =='' || emailAddress == null)
                    {
                        emailAddress = ers.ContactId__r.Email;

                    }
                    mapGenerateDE.put('Type', 'Contact');
                }

                /* PA MIGRATION : To Remove - START 
                else
                {
                    if (ers.LeadId__c != null)
                    {
                        if(ContactName =='' || ContactName ==null)
                        {
                            ContactName = ers.LeadId__r.Name;
                        }
                        if(emailAddress =='' || emailAddress ==null)
                        {
                            emailAddress = ers.LeadId__r.Email;

                        }
                        mapGenerateDE.put('Type', 'Lead');
                    }
                }
                /** PA MIGRATION : To Remove Part 1 END */

                mapGenerateDE.put('Invoice', 'null');
                if(brand == 'CCK'){
                    mapGenerateDE.put('fromAddress', 'marketing.kia.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Kia Marketing');
                    BrandName = 'KIA';
                }
                else if(brand == 'CCA'){
                    mapGenerateDE.put('fromAddress', 'marketing.mitsubishi.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Mitsubishi Marketing');
                    BrandName = 'Mitsubishi';
                }
                else if(brand == 'CCF'){
                    mapGenerateDE.put('fromAddress', 'marketing.citroen.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Citroën Marketing');
                    BrandName = 'Citroen';

					if(ers.ModelCode__r.name.contains('DS'))
					{
                        mapGenerateDE.put('fromAddress', 'marketing.ds.sg@e.cyclecarriage.com');
                        mapGenerateDE.put('fromName', 'DS Marketing');
                        BrandName = 'DS';
					}
                }
                EventName = (ers.PromoID__r.Name != null) ?  EventName : 'event';
                EventDescp = 'This is a quick reminder that our ' + EventName +  ' is two days away. Here the event details below in case you forgot.';
                BrandName = (BrandName != null ) ? BrandName + ': ' : '';
                Subject = BrandName  + 'Event Reminder : ' + EventName;
                mapGenerateDE.put('Brand', (String.isNotBlank(Brand) ) ? Brand: null );
                mapGenerateDE.put('UnitPrice',(UnitPrice > 0 ) ? String.valueOf(UnitPrice): null);
                mapGenerateDE.put('Waitlist', String.valueOf(waitlist));
                mapGenerateDE.put('Remarks', String.valueOf(ers.Remarks__c));
                mapGenerateDE.put('ContactName', ContactName);
                mapGenerateDE.put('EmailAddress', emailAddress);
                mapGenerateDE.put('EventDescp', EventDescp);
                mapGenerateDE.put('EventName', ers.Name);
                mapGenerateDE.put('DateRange', ers.DateRange__c);
                mapGenerateDE.put('ImageURL', ers.ImageURL__c);
                mapGenerateDE.put('LocationName', ers.Location_Name__c);
                mapGenerateDE.put('TemplateName', ers.TemplateName__c);
                //mapGenerateDE.put('PrefferedDate', String.valueOf(Event_RegistrationInfo[0].Preffered_Date__c));
                mapGenerateDE.put('PrefferedTime', (ers.Preffered_Time__c != null ) ? ers.Preffered_Time__c : null );

                if(ers.Opportunity__r.Owner.FirstName == null)
                {
                    SCName = ers.Opportunity__r.Owner.LastName;
                }
                if(ers.Opportunity__r.Owner.LastName == null)
                {
                    SCName = ers.Opportunity__r.Owner.FirstName ;
                }
                if(ers.Opportunity__r.Owner.FirstName != null  && ers.Opportunity__r.Owner.LastName != null )
                {
                    SCName = ers.Opportunity__r.Owner.FirstName+' '+ers.Opportunity__r.Owner.LastName;
                }
                mapGenerateDE.put('ModelName', ers.ModelCode__r.name);
                mapGenerateDE.put('Attendies', String.valueof(ers.NumberOfGuests__c));
                //////////if(String.isNotBlank(String.valueOf(ers.Event_Date__c))){


                //System.debug('##### ers.Event_Date__c ======= ' + ers.Event_Date__c);
                //System.assertEquals(null, ers.Event_Date__c);
                Date eventDate = ers.Event_Date__c;
                String EventdateNew = DateTime.newInstance(eventDate.year(),eventDate.month(),eventDate.day()).format('d/MM/YYYY');
                mapGenerateDE.put('DateValue', EventdateNew);
                System.debug('EventdateNew'+EventdateNew);


                ///////}
                System.debug('Subject-----'+Subject);
                mapGenerateDE.put('Subject', Subject);
                mapGenerateDE.put('Location', ers.Location__c);
                mapGenerateDE.put('SCName', SCName);
                if(ers.Opportunity__r.Owner.MobilePhone != null){
                    mapGenerateDE.put('SCPhone',ers.Opportunity__r.Owner.MobilePhone);
                }
                mapGenerateDE.put('TimeSlot', ers.TimeSlot__c);
                mapGenerateDE.put('EventId',  ers.Id);
                System.debug('mapGenerateDE' + mapGenerateDE);
                //}
                //
                String tokenValue = '';
                if(Test.isRunningTest()==False){
                    tokenValue = GenerateRequestToken.getRequestToken();
                    if(tokenValue!='')
                    {
                        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
                        Http http = new Http();
                        HttpRequest httpReq = new HttpRequest();
                        HTTPResponse httpRes = new HttpResponse();
                        httpReq.setMethod('POST');
                        httpReq.setHeader('content-type', 'application/json;charset=utf-8');
                        httpReq.setHeader('Authorization', 'Bearer '+tokenValue);
                        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:36330/send');
                        if (mapGenerateDE.get('Brand') == 'CCK' || mapGenerateDE.get('Brand') == 'CCA' || mapGenerateDE.get('Brand') == 'CCF')
                        {
                            httpReq.setBody('{ "From": {"Address": "'+mapGenerateDE.get('fromAddress')+'","Name": "'+mapGenerateDE.get('fromName')+'"},"To":{"Address": "'+mapGenerateDE.get('EmailAddress')+'","SubscriberKey": "'+mapGenerateDE.get('EmailAddress')+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+mapGenerateDE.get('ContactName')+'","EventName" : "'+mapGenerateDE.get('EventName')+'","Location" : "'+mapGenerateDE.get('Location')+'","Attendies":"'+mapGenerateDE.get('Attendies')+'","ModelName": "'+mapGenerateDE.get('ModelName')+'","SCName": "'+mapGenerateDE.get('SCName')+'","SCPhone": "'+mapGenerateDE.get('SCPhone')+'","Brand" : "'+mapGenerateDE.get('Brand')+'","DateValue": "'+mapGenerateDE.get('DateValue')+'","TimeSlot":"'+mapGenerateDE.get('TimeSlot')+'","EventId":"'+mapGenerateDE.get('EventId')+'","DateRange":"'+mapGenerateDE.get('DateRange')+'","ImageURL":"'+mapGenerateDE.get('ImageURL')+'","LocationName":"'+mapGenerateDE.get('LocationName')+'","TemplateName":"'+mapGenerateDE.get('TemplateName')+'","PrefferedDate":"'+mapGenerateDE.get('PrefferedDate')+'","PrefferedTime":"'+mapGenerateDE.get('PrefferedTime')+'","EventText":"'+mapGenerateDE.get('EventText')+'","Invoice":"'+mapGenerateDE.get('Invoice')+'","EventDescp":"'+mapGenerateDE.get('EventDescp')+'","Waitlist":"'+mapGenerateDE.get('Waitlist')+'","UnitPrice":"'+mapGenerateDE.get('UnitPrice')+'","Type":"'+mapGenerateDE.get('Type')+'","Remarks":"'+mapGenerateDE.get('Remarks')+'","Subject":"'+mapGenerateDE.get('Subject')+'","Reminder":"'+mapGenerateDE.get('Reminder')+'"}}},"Options": {"RequestType": "ASYNC"}}');
                            System.debug('httpReq.setBody::' +httpReq.getBody());
                        }
                        httpRes = http.send(httpReq);
                        System.debug('Email Response::' +httpRes.getBody());
                        serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
                    }

                }

                ers.Event_Reminder_Status__c = true;
                update ers;

            }
        }
        catch (Exception e)
        {
            System.debug('Error'+e.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC)
    {
    }
}