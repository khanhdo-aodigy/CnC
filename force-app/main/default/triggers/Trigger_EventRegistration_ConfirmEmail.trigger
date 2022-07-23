trigger Trigger_EventRegistration_ConfirmEmail on Event_Registration__c (after insert) {
    
String ContactName;
    String EventName;
    String Location;
    String Attendies;
    String ModelName;
    String SCName = null;
    String SCPhone;
    String TimeSlot;
    String Brand;
    String DateRange;
    String ImageURL;
    String LocationName;
    String TemplateName;
    String PrefferedDate;
    String PrefferedTime;
    String dateValue;
    String emailAddress;
    String subcriberKey;
    String eventID ;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String triggeredSendMessageId = (String)JCC_GlobalVar.EventConfirmationTriggeredID__c;
    list <Event_Registration__c> Event_RegistrationInfo  =  new list<Event_Registration__c>();
    Opportunity [] opp;    
    
    //Exclude this trigger
    if(TriggerExclusion.isTriggerExclude('Event_Registration__c')){
        return;
    }
    
    If (Trigger.isAfter && Trigger.isInsert)    
    {
    	Set<String> cmpToExclude = new Set<String>();
    	
    	//get the List of events to Exclude sending Confirmation Email
    	try{
    		for(EventRegistrationUtil__mdt md : [SELECT Id, DeveloperName, CampaignToExclude__c FROM EventRegistrationUtil__mdt]){
    			
    			if(String.isNotBlank(md.CampaignToExclude__c)){
    				cmpToExclude.add(md.CampaignToExclude__c);
    			}
    		}
    	}catch(Exception e){
    		loggerDataPool.buildLogDataPool('Event Registration',e);
    	}
    	
    	
        for(Event_Registration__c eReg : trigger.new)
        {
            try{
                Event_RegistrationInfo = [Select ContactId__r.Email,ContactId__r.Name, ModelCode__c , PromoID__c, PromoID__r.Branch_Code__c,LeadId__r.Email,LeadId__r.Name,ModelCode__r.Branch_Code__c,
                                          ModelCode__r.name,Opportunity__r.Owner.FirstName,Opportunity__r.Owner.LastName,Opportunity__r.Owner.MobilePhone,TimeSlot__c,FirstName__c,Email__c,DateRange__c,ImageURL__c,Location_Name__c,TemplateName__c,Preffered_Date__c,Preffered_Time__c from Event_Registration__c where Id =: eReg.Id];
                if (Event_RegistrationInfo != null  && Event_RegistrationInfo.size()>0)
                {
                    //select email and phone from contact  
                    if(Event_RegistrationInfo[0].FirstName__c !=null || Event_RegistrationInfo[0].FirstName__c !='')
                    {
                        ContactName = Event_RegistrationInfo[0].FirstName__c;
                    }
                    if(Event_RegistrationInfo[0].Email__c !=null || Event_RegistrationInfo[0].Email__c !='')
                    {
                        emailAddress = Event_RegistrationInfo[0].Email__c;
                        subcriberKey = emailAddress;
                    }
                    if (Event_RegistrationInfo[0].ContactId__c != null)
                    {
                        if(ContactName =='' || ContactName == null)
                        {
                            ContactName = Event_RegistrationInfo[0].ContactId__r.Name;
                        }
                        if(emailAddress =='' || emailAddress == null)
                        {
                            emailAddress = Event_RegistrationInfo[0].ContactId__r.Email;
                            subcriberKey = emailAddress;                         
                        }
                        
                    }
                    else
                    {
                        if (eReg.LeadId__c != null)
                        {
                            if(ContactName =='' || ContactName ==null)
                            {
                                ContactName = Event_RegistrationInfo[0].LeadId__r.Name;
                            }
                            if(emailAddress =='' || emailAddress ==null)
                            {
                                emailAddress = Event_RegistrationInfo[0].LeadId__r.Email;
                                subcriberKey = emailAddress;                         
                            }
                            
                            
                        }
                    }
                    
                    EventName = (String.isNotBlank(eReg.Name) ) ? eReg.Name : null;
                    DateRange = (String.isNotBlank(Event_RegistrationInfo[0].DateRange__c) ) ? Event_RegistrationInfo[0].DateRange__c: null;
                    ImageURL = (String.isNotBlank(Event_RegistrationInfo[0].ImageURL__c) ) ? Event_RegistrationInfo[0].ImageURL__c: null;
                    LocationName = (String.isNotBlank(Event_RegistrationInfo[0].Location_Name__c) ) ? Event_RegistrationInfo[0].Location_Name__c: null;
                    TemplateName = (String.isNotBlank(Event_RegistrationInfo[0].TemplateName__c) ) ? Event_RegistrationInfo[0].TemplateName__c : null;
                    PrefferedDate = (String.isNotBlank(String.valueOf(Event_RegistrationInfo[0].Preffered_Date__c)) ) ? String.valueOf(Event_RegistrationInfo[0].Preffered_Date__c) : null;
                    PrefferedTime = (String.isNotBlank(Event_RegistrationInfo[0].Preffered_Time__c) ) ? Event_RegistrationInfo[0].Preffered_Time__c : null;
                    
                    //04-June-2019 Check if Model is passed
                    if(String.isNotBlank(Event_RegistrationInfo[0].PromoID__c) && String.isNotBlank(Event_RegistrationInfo[0].PromoID__r.Branch_Code__c)){
                    	Brand = Event_RegistrationInfo[0].PromoID__r.Branch_Code__c;
                    }
                    
                    if(String.isBlank(Event_RegistrationInfo[0].PromoID__c) && String.isNotBlank(Event_RegistrationInfo[0].ModelCode__c) && String.isNotBlank(Event_RegistrationInfo[0].ModelCode__r.Branch_Code__c)){
                    	Brand = Event_RegistrationInfo[0].ModelCode__r.Branch_Code__c;
                    }
                    
                    
                    ModelName = (String.isNotBlank(Event_RegistrationInfo[0].ModelCode__r.name) ) ? Event_RegistrationInfo[0].ModelCode__r.name: null;
                    Location = (String.isNotBlank(eReg.Location__c) ) ? eReg.Location__c : null;
                    Attendies = (String.isNotBlank(String.valueof(eReg.NumberOfGuests__c)) ) ? String.valueof(eReg.NumberOfGuests__c) : null;
                    dateValue = (String.isNotBlank(String.valueOf(eReg.Event_Date__c)) ) ? String.valueOf(eReg.Event_Date__c) : null;
                    if(Event_RegistrationInfo[0].Opportunity__r.Owner.FirstName == null)
                    {
                        SCName = Event_RegistrationInfo[0].Opportunity__r.Owner.LastName;
                    }
                    if(Event_RegistrationInfo[0].Opportunity__r.Owner.LastName == null)
                    {
                        SCName = Event_RegistrationInfo[0].Opportunity__r.Owner.FirstName ;
                    }
                    if(Event_RegistrationInfo[0].Opportunity__r.Owner.FirstName != null  && Event_RegistrationInfo[0].Opportunity__r.Owner.LastName != null )
                    {
                        SCName = Event_RegistrationInfo[0].Opportunity__r.Owner.FirstName+' '+Event_RegistrationInfo[0].Opportunity__r.Owner.LastName;
                    }                 
                    
                    SCPhone = (String.isNotBlank(Event_RegistrationInfo[0].Opportunity__r.Owner.MobilePhone) ) ? Event_RegistrationInfo[0].Opportunity__r.Owner.MobilePhone : null;
                    TimeSlot = (String.isNotBlank(Event_RegistrationInfo[0].TimeSlot__c) ) ? Event_RegistrationInfo[0].TimeSlot__c : null;
                    eventID  =  (String.isNotBlank(eReg.Id) ) ? eReg.Id : null;
                    
                    //Flag to tell if email should be sent for the specific event
                    Boolean sendEmail = true;
                    if( !cmpToExclude.isEmpty() && String.isNotBlank( Event_RegistrationInfo.get(0).PromoID__c ) ){
                    	String evtId = Event_RegistrationInfo.get(0).PromoID__c;
                    	String parsedStr = evtId.length() > 15 ? evtId.subString(0,15) : evtId;

            			if(cmpToExclude.contains(parsedStr)){
            				sendEmail = false;
            			}
                    }
                    
                    //some Campaigns need to be exluded, e.g. Toy Story
                    /*if(sendEmail){
                    	EventRegistration_ConfirmationEmail.sendEmail(ContactName,EventName,Location,Attendies,ModelName,SCName,SCPhone,Brand,dateValue,emailAddress,subcriberKey,triggeredSendMessageId,TimeSlot,eventID,DateRange,ImageURL,LocationName,TemplateName,PrefferedDate,PrefferedTime);
                    }*/
                    
                }
            }
            /******* Email  End********/
            /****Loop end****/ 
            catch(Exception e)
            {
                loggerDataPool.buildLogDataPool('Event Registration',e);
            }
        }
        
        
        
    }
    else if (Trigger.isAfter && Trigger.isUpdate){
        
        for(Event_Registration__c eReg : trigger.new)
        {
            try
            {
                Event_RegistrationInfo =[select Id, Opportunity__c from Event_Registration__c where Id =: eReg.Id];
                if(Event_RegistrationInfo.size()>0)
                {
                    opp = [select Id, Opportunity_Score__c from Opportunity where Id =:Event_RegistrationInfo[0].Opportunity__c];
                    Decimal oppScore = opp[0].Opportunity_Score__c;
                    Integer oppoScore;
                    if (eReg.Event_Status__c =='Attended' || eReg.Event_Status__c =='Attend and Test Driven' || eReg.Event_Status__c == 'Attended but Model Not Final')
                    {
                        if (oppScore != null)
                        {
                            oppoScore = oppScore.intValue() + 5;                       
                            
                        }
                        else
                        {
                            oppoScore = 5;
                        }
                        opp[0].Opportunity_Score__c = oppoScore;
                        Database.DMLOptions dmlOptions = new Database.DMLOptions();
                        dmlOptions.assignmentRuleHeader.useDefaultRule = true;
                        Database.update(opp, dmlOptions);
                        update opp;
                    }
                } 
            }
            catch (Exception e)
            {
                loggerDataPool.buildLogDataPool('Trigger_CustomQuote_ConfirmationEmail',e);
            }
            
        }
        
        
    } 
}