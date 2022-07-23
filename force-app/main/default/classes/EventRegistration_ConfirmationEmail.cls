public class EventRegistration_ConfirmationEmail 
{
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String triggeredSendMessageId = (String)JCC_GlobalVar.EventConfirmationTriggeredID__c;
    
    public static void hanldeAfterInsert(List<Event_Registration__c> evtInsert)
    {  
        try{
            List<Event_Registration__c> paidEvents = new List<Event_Registration__c>();
            Map<String, String> campIdList = new Map<String, String>();
            Map<String, String> freecampIdList = new Map<String, String>();
            
            //For Bypassing Confirmation Email
            Set<String> cmpToExclude = new Set<String>();
            try{
                for(EventRegistrationUtil__mdt md : [SELECT Id, DeveloperName, CampaignToExclude__c FROM EventRegistrationUtil__mdt]){
                    
                    if(String.isNotBlank(md.CampaignToExclude__c)){
                        cmpToExclude.add(md.CampaignToExclude__c);
                    }
                }
            }
            catch(Exception e){
                loggerDataPool.buildLogDataPool('Event Registration',e);
            }
            
            
            for(Event_Registration__c eReg : evtInsert){
                if(String.isNotBlank(eReg.PromoID__c)){
                    if(eReg.Payment__c != null){
                        campIdList.put(eReg.Id, eReg.PromoID__c);
                        paidEvents.add(eReg); 
                    }
                    else{
                        //Flag to tell if email should be sent for the specific event
                        Boolean validToSend = true;
                        if( !cmpToExclude.isEmpty() && String.isNotBlank( eReg.PromoID__c ) ){
                            String evtId = eReg.PromoID__c;
                            String parsedStr = evtId.length() > 15 ? evtId.subString(0,15) : evtId;
                            
                            if(cmpToExclude.contains(parsedStr)){
                                validToSend = false;
                            }
                        }
                        
                        //some Campaigns need to be exluded from sending confirmation Email, e.g. Toy Story
                        if( validToSend){
                            freecampIdList.put(eReg.Id, null); 
                        }
                    } 
                }
            }
            
            if(!campIdList.isEmpty()){
                ID jobID = System.enqueueJob(new Invoice_Pdf_PaidEvents_Save(paidEvents,campIdList));
            }
            if(!freecampIdList.isEmpty()){
                sendEmail(freecampIdList,null,false);
            }
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('EventRegistration_ConfirmationEmail.hanldeAfterInsert',e);
        }
        
    }

    public static void sendEmail( Map<String,String> ERWithCamp, Map<String,String> publicURLWithER, Boolean ReminderEmail ){
        try{
            String ContactName;
            String SCName;
            String Brand;
            String emailAddress;
            String EventDescp, Subject, PreviewText, EventName,BrandName;
            Decimal UnitPrice = 0;
            Map<String, String> mapGenerateDE = new Map<String, String>();
            mapGenerateDE.put('Reminder', String.valueOf(ReminderEmail));
            
            for(Event_Registration__c ers :[SELECT Id, Name, Event_Date__c, Location__c, PromoID__c, PromoID__r.Name, PromoID__r.Description, PromoID__r.UnitPrice__c, PromoID__r.Type,  
                                                PromoID__r.Branch_Code__c, PromoID__r.brand__c, NumberOfGuests__c, Remarks__c, ModelCode__r.Branch_Code__c, ModelCode__r.name, 
                                                Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName, Opportunity__r.Owner.MobilePhone, TimeSlot__c, 
                                                FirstName__c, Email__c, DateRange__c, ImageURL__c, Location_Name__c, TemplateName__c, Preffered_Date__c, Preffered_Time__c, Waitlist__c, 
                                                //LeadId__c, LeadId__r.Email, LeadId__r.Name, ContactId__c, ContactId__r.Email, ContactId__r.Name, 
                                                Account__c, Account__r.PersonEmail, Account__r.Name, Account__r.RecordTypeId   
                                            FROM Event_Registration__c 
                                            WHERE Id IN : ERWithCamp.keySet()])
            {
                
                EventDescp =  ers.PromoID__r.Description; 
                if(String.isNotBlank(EventDescp)){
                    String retStr = null;
                    retStr = EventDescp.replace('\r',' ');
                    retStr = retStr.replace('\n',' ');
                    retStr = retStr.replace('\r\n',' ');
                    EventDescp = retStr;
                }
               
                Subject = 'Thank you for your registration!';
                EventName =  ers.PromoID__r.Name;
                mapGenerateDE.put('EventText', ers.PromoID__r.Name);
                /*added by varinder-grazitti if not model is there */
                if(String.isNotBlank(ers.PromoID__c) && String.isNotBlank(ers.PromoID__r.Branch_Code__c)){
                    Brand = ers.PromoID__r.Branch_Code__c;
                }
                
                Boolean waitlist = ers.Waitlist__c;
                if(waitlist == null)
                {
                    waitlist = false; 
                }
                
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

                if( ers.Account__c <> null ) {
                    if( String.isBlank( ContactName ) ) {
                        ContactName = ers.Account__r.Name;
                    }  
                    if( String.isBlank( emailAddress ) ){
                        emailAddress = ers.Account__r.PersonEmail;
                    }
                    String custType = '';
                    if( AccountUtil.isCustomer( ers.Account__r.RecordTypeId, null )  ){
                        custType = 'Contact';
                    }
                    else {
                        custType = 'Lead';
                    }
                    mapGenerateDE.put('Type', custType);  
                }

                /** PA MIGRATION : To Remove Part-1 Start */
                // if (ers.ContactId__c != null)
                // {
                //     if(ContactName =='' || ContactName == null)
                //     {
                //         ContactName = ers.ContactId__r.Name;
                //     }
                //     if(emailAddress =='' || emailAddress == null)
                //     {
                //         emailAddress = ers.ContactId__r.Email;
                //     }
                //     mapGenerateDE.put('Type', 'Contact');  
                // }
                // else
                // {
                //     if (ers.LeadId__c != null)
                //     {
                //         if(ContactName =='' || ContactName ==null)
                //         {
                //             ContactName = ers.LeadId__r.Name;
                //         }
                //         if(emailAddress =='' || emailAddress ==null)
                //         {
                //             emailAddress = ers.LeadId__r.Email;
                //         }
                //         mapGenerateDE.put('Type', 'Lead'); 
                //     }
                // }
                /** PA MIGRATION : To Remove Part-1 End */

                if(publicURLWithER != null && publicURLWithER.containsKey(ers.Id) && ers.Waitlist__c == false && ReminderEmail == false){
                    mapGenerateDE.put('Invoice', publicURLWithER.get(ers.Id));
                }
                else{
                    mapGenerateDE.put('Invoice', 'null');
                }
                
                if(ers.PromoID__r.Type == 'Paid Event' && ers.PromoID__r.UnitPrice__c > 0 && waitlist == false && ReminderEmail == false){
                    if(ers.NumberOfGuests__c != null){
                        UnitPrice = ers.PromoID__r.UnitPrice__c * ers.NumberOfGuests__c;
                    }                
                }

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

					if(ers.PromoID__r.brand__c != null)
					{
						if(ers.PromoID__r.brand__c.contains('DS'))
						{
								mapGenerateDE.put('fromAddress', 'marketing.ds.sg@e.cyclecarriage.com');
								mapGenerateDE.put('fromName', 'DS Marketing');
								BrandName = 'DS';
						}
					}
                } 

                if(!ReminderEmail && waitlist){
                    EventDescp = Label.Events_Waitlist;
                    Subject = 'Thank you for registering and you are on the waiting list';      
                }

                mapGenerateDE.put('Brand', (String.isNotBlank(Brand) ) ? Brand: null );
                mapGenerateDE.put('UnitPrice',(UnitPrice > 0 ) ? String.valueOf(UnitPrice): null);
                mapGenerateDE.put('Waitlist', String.valueOf(waitlist));
                mapGenerateDE.put('Remarks', (String.isNotBlank(ers.Remarks__c) ) ? String.valueOf(ers.Remarks__c): null);
                mapGenerateDE.put('ContactName', (String.isNotBlank(ContactName) ) ? ContactName: null);
                mapGenerateDE.put('EmailAddress', (String.isNotBlank(emailAddress) ) ? emailAddress: null);
                mapGenerateDE.put('EventDescp', (String.isNotBlank(EventDescp) ) ? EventDescp: null);
                mapGenerateDE.put('EventName', (String.isNotBlank(ers.Name) ) ? ers.Name: null);
                mapGenerateDE.put('DateRange', (ers.DateRange__c != null ) ? ers.DateRange__c : null );
                mapGenerateDE.put('ImageURL', (String.isNotBlank(ers.ImageURL__c) ) ? ers.ImageURL__c: null);
                mapGenerateDE.put('LocationName', (String.isNotBlank(ers.Location_Name__c) ) ? ers.Location_Name__c: null);
                mapGenerateDE.put('TemplateName', (String.isNotBlank(ers.TemplateName__c) ) ? ers.TemplateName__c: null );
                //mapGenerateDE.put('PrefferedDate', String.valueOf(Event_RegistrationInfo[0].Preffered_Date__c));
                mapGenerateDE.put('PrefferedTime', (ers.Preffered_Time__c != null ) ? ers.Preffered_Time__c : null );
                
                
                // mapGenerateDE.put('Account__c', (ers.Account__c != null ) ? ers.Account__c : null);
                
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


                mapGenerateDE.put('ModelName', (String.isNotBlank(ers.ModelCode__r.name) ) ? ers.ModelCode__r.name: null);
                mapGenerateDE.put('Attendies', String.valueof(ers.NumberOfGuests__c));
				if(BrandName == 'DS')
				{
					mapGenerateDE.put('ModelName', ers.PromoID__r.brand__c);
				}
                System.debug('Event date = ' + ers.Event_Date__c);
                if(ers.Event_Date__c != null){
                    Date eventDate = ers.Event_Date__c;
                    String EventdateNew = DateTime.newInstance(eventDate.year(),eventDate.month(),eventDate.day()).format('d/MM/YYYY');
                    mapGenerateDE.put('DateValue', EventdateNew);
                }
                else{
                    mapGenerateDE.put('DateValue', 'null');
                }
                
                mapGenerateDE.put('Reminder', String.valueOf(false));
                mapGenerateDE.put('Subject', String.isNotBlank(Subject) ? Subject : null);           
                mapGenerateDE.put('Location', String.isNotBlank(ers.Location__c) ? ers.Location__c : null);
                mapGenerateDE.put('SCName', String.isNotBlank(SCName) ? SCName : null);
                if(ers.Opportunity__r.Owner.MobilePhone != null){
                    mapGenerateDE.put('SCPhone',ers.Opportunity__r.Owner.MobilePhone);
                }
                else{
                    mapGenerateDE.put('SCPhone',null);
                }
                mapGenerateDE.put('TimeSlot', String.isNotBlank(ers.TimeSlot__c) ? ers.TimeSlot__c : null );
                mapGenerateDE.put('EventId',  String.isNotBlank(ers.Id) ?  ers.Id : null);
               
                //EventRegistration_ConfirmationEmail.sendEmail(ContactName,EventName,Location,Attendies,ModelName,SCName,SCPhone,Brand,dateValue,emailAddress,subcriberKey,triggeredSendMessageId,TimeSlot,eventID,DateRange,ImageURL,LocationName,TemplateName,PrefferedDate,PrefferedTime);
                BusinessRuleHandlerSFMC.sendEventEmail(mapGenerateDE);
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('EventRegistration_ConfirmationEmail.sendEmail',e);
        }
    }
}