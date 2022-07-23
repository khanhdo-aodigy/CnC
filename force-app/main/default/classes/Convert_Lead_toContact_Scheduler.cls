global class Convert_Lead_toContact_Scheduler implements Schedulable{
  
global void execute(SchedulableContext ctx)
{ConvertLeads();}

public static void ConvertLeads()            
{    
    
    list<Contact> LstContact = new list<Contact>();
    list<Lead> LstLead = new list<Lead>();
    list<Opportunity> oppList = new list<Opportunity>();
    Date today = date.today();
    Date before1days = today.addDays(-1);
    try 
    {   
        //Get List of contacts created today
        LstContact = [Select Id, NRIC_Passport_No__c, AccountId From Contact where NRIC_Passport_No__c!=null
                     AND CreatedDate >=:before1days];
        List<String> strContactList = new List<String>();
        List<String> strLeadList = new List<String>();
        List<String> strContact_LeadList = new List<String>();
        
        Map<String,Id> MapContactNric = new Map<String,Id>();
        Map<String,Id> MapContactAccount = new Map<String,Id>();
       
        If(LstContact.size()>0)
        {
            Account Acc = [Select Id, name from Account where Name = 'JCC' and isPersonAccount=False limit 1];
            
            list<Contact> LstContactAccout_Update = new list<Contact>();
            for(Contact TempCon : LstContact)
            {         
                strContactList.add(TempCon.NRIC_Passport_No__c);
                MapContactNric.put(TempCon.NRIC_Passport_No__c, TempCon.Id);
            }
            
            LstLead = [Select Id, NRIC__c From Lead where isconverted= False and NRIC__c != null 
                       and NRIC__c IN : strContactList];
            for(Lead TempLead : LstLead)
            {         
                strLeadList.add(TempLead.Id);    
                strContact_LeadList.add(TempLead.NRIC__c.toUpperCase());
            }
            
            for(Contact TempCon : [Select Id, NRIC_Passport_No__c, AccountId From Contact where NRIC_Passport_No__c!=null
                     AND NRIC_Passport_No__c IN : strContact_LeadList])
            {         
                If(TempCon.AccountId!=null)
                {
                	MapContactAccount.put(TempCon.NRIC_Passport_No__c, TempCon.AccountId);
                }
                else
                {
                    TempCon.AccountId = Acc.Id;
                    LstContactAccout_Update.add(TempCon);
                    MapContactAccount.put(TempCon.NRIC_Passport_No__c, Acc.Id);
                }                
                
            }
            If(LstContactAccout_Update.size()>0)
            {
                update LstContactAccout_Update;
            }
			
            map<String,Set<Id>> LstNric_RVModels = new map<String,Set<Id>>();                        
            for(Registered_Vehicle__c TempRV : [Select Variant__r.Model_ID__r.Id,Contact__r.NRIC_Passport_No__c from Registered_Vehicle__c where Contact__r.NRIC_Passport_No__c In : strContact_LeadList])
            {   
                if(LstNric_RVModels.containsKey(TempRV.Contact__r.NRIC_Passport_No__c)) 
                {
                    Set<Id> VariantId = LstNric_RVModels.get(TempRV.Contact__r.NRIC_Passport_No__c);
                    VariantId.add(TempRV.Variant__r.Model_ID__r.Id);
                    LstNric_RVModels.put(TempRV.Contact__r.NRIC_Passport_No__c, VariantId);
                }
                else
                {
                    LstNric_RVModels.put(TempRV.Contact__r.NRIC_Passport_No__c, new Set<Id> { TempRV.Variant__r.Model_ID__r.Id });
                }                
                 //LstNric_RVModels.put(TempRV.Contact__r.NRIC_Passport_No__c,);            
            }    
           
                
            oppList = [Select Id, Lead__c, Contact_Person__c,Model_c__r.Id from Opportunity where Lead__r.Id IN : strLeadList];
            
            list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();	
            If(LstLead.size()>0)
            {
                for (Lead currentLead : LstLead)
                {
                    list<Opportunity> oppListtoUpdate = new list<Opportunity>();
                    Database.LeadConvert lc = new database.LeadConvert();
                    lc.setLeadId(currentLead.Id);
                    lc.convertedStatus = 'Qualified';
                    lc.setDoNotCreateOpportunity(true);
                    lc.setContactId(MapContactNric.get(currentLead.NRIC__c.toUpperCase()));
                    lc.setAccountId(MapContactAccount.get(currentLead.NRIC__c.toUpperCase()));    
                    lc.bypassaccountdedupecheck = false;
                    lc.bypasscontactdedupecheck = true;
                    for (Opportunity currentOpportunity : oppList)
                    {
                        If(currentOpportunity.Lead__c==currentLead.Id)
                        { 
                            //System.debug('Model==='+currentOpportunity.Model_c__r.Id);
                            If (LstNric_RVModels.get(currentLead.NRIC__c.toUpperCase())!=null){
                            If(LstNric_RVModels.get(currentLead.NRIC__c.toUpperCase()).contains(currentOpportunity.Model_c__r.Id))
                            {                                
                                currentOpportunity.StageName = 'Booked';
                            }}
                            currentOpportunity.Contact_Person__c = MapContactNric.get(currentLead.NRIC__c.toUpperCase());
                            currentOpportunity.Lead__c = null;
                            oppListtoUpdate.add(currentOpportunity);
                        }
                    }
                    leadConverts.add(lc);
                    update oppListtoUpdate; 
                }   
                Database.LeadConvertResult[] lcrList = Database.convertLead(leadConverts, false);
            }
            
        }
    }
    catch(System.Exception e) 
    {           
        System.debug('System_error: '+ e);           
    }
   
       
}

}