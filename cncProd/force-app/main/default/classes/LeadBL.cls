/*******************************************
* Class Name: LeadBL
* Description: Business Logic class for Lead object.
*******************************************/ 
public without sharing class LeadBL {
    
    public static void leadChange(List<Lead> leadList, Map<Id,Lead> oldMap){
        List<Account> pAccList = new List<Account>();
        
        Map<String, String> leadAccountMap = new Map<String,String>();
        Map<String, Lead> leadMap = new Map<String, Lead>();
        Map<String, System.Address> leadHasAddressMap = new Map<String, System.Address>();
        
        AccountSelector accSelector = new AccountSelector();
        List<String> accFields = accSelector.getEditableAccountFields();
        
        LeadSelector leadSelector = new LeadSelector();
        List<String> leadFields = leadSelector.getEditableLeadFields();

        // for( String aField : accFields ){
        //     System.debug('accFields :: ACCT FIELD ---> '+ aField);
        // }
        // for( String lField : leadFields ){
        //     System.debug('leadFields :: Testing---> '+ lField);
        // }

        Set<Id> leadIds = new Set<Id>();
        try{ 
            for(Lead lead : leadList){
                System.debug('Testing--'+lead.get('Address'));
                if(lead.Account__c != null){
                    leadAccountMap.put(lead.Id, lead.Account__c);
                    leadMap.put(lead.Id, lead);
                    leadIds.add(lead.Id);
                }
            }
            List<Lead> addressLeads = [Select Id, Address From Lead Where Id IN :leadIds];
            for(Lead lead : addressLeads){
				if(lead.address != null)
				{
					leadHasAddressMap.put(lead.Id, lead.Address);
				}
            }
            for(String leadId : leadAccountMap.keySet()){
                Lead lead = leadMap.get(leadId);
                Account acc = new Account();
                acc.Id = leadAccountMap.get(leadId);
                for(String field : accFields){
                    String lField;

                    if(field == 'Account__pc'){
                        continue;
                    }
                    
                    if(field.endsWith('__pc')){
                        lField = field.replace('__pc', '__c');
                    }
                    else if(field.startsWith('Person')){
                        lField = field.remove('Person');
                    }
                    else {
                        lField = field;
                    }
                    if(lField.equalsIgnoreCase('BirthDate')){
                        lField = 'Birthdate__c';
                    }
                    
                    if(leadFields.contains(lField) && lead.get(lField) != oldMap.get(lead.Id).get(lField)){                        
                        acc.put(field, lead.get(lField));
                    }
                    else if(lField.startsWith('Mailing') && leadHasAddressMap.containsKey(lead.Id)){
                        Address add = new Address();
						add = leadHasAddressMap.get(lead.Id);
                        if(lField.equalsIgnoreCase('MailingStreet')){
                            acc.put(field, add.Street);
                        }
                        else if(lField.equalsIgnoreCase('MailingCity')){
                            acc.put(field, add.City);
                        }
                        else if(lField.equalsIgnoreCase('MailingState')){
                            acc.put(field, add.State);
                        }
                        else if(lField.equalsIgnoreCase('MailingPostalCode')){
                            acc.put(field, add.PostalCode);
                        }
                        else if(lField.equalsIgnoreCase('MailingCountry')){
                            acc.put(field, add.Country);
                        }
                        else if(lField.equalsIgnoreCase('MailingLatitude')){
                            acc.put(field, add.Latitude);
                        }
                        else if(lField.equalsIgnoreCase('MailingLongitude')){
                            acc.put(field, add.Longitude);
                        }
                        else if(lField.equalsIgnoreCase('MailingGeocodeAccuracy')){
                            acc.put(field, add.GeocodeAccuracy);
                        }
                    }
                }
                pAccList.add(acc);
            }
            System.debug('@@@@DEBUG contactChange :: pAccList = '+ pAccList.size() + ' --- ' + pAccList );
            if( !pAccList.isEmpty() ){
                TriggerExclusion.excludeTrigger('Account', true);
                update pAccList;
                TriggerExclusion.excludeTrigger('Account', false);
            }
            
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('LeadBL', e);
        }
    }


    public static void createProspectPersonAccount( List<Lead> lstLead ){

        AccountSelector accSelector = new AccountSelector();
        List<String> accFields = accSelector.getEditableAccountFields();

        LeadSelector leadSelector = new LeadSelector();
        List<String> leadFields = leadSelector.getEditableLeadFields();   

        List<Account> lstNewProspect = new List<Account>();
        Map<Id,Lead> mapLeads = new Map<Id,Lead>();
        Map<Id,Account> mapLeadIdToAccount = new Map<Id,Account>();

        System.debug('@@@@DEBUG createProspectPersonAccount :: lstLead = ' + lstLead.size() + ' --- ' + lstLead );
        
        Map<String, System.Address> leadHasAddressMap = new Map<String, System.Address>();
        List<Lead> addressLeads = [SELECT Id, Address FROM Lead WHERE Id IN :lstLead];
        for(Lead lead : addressLeads){
            if(lead.address != null)
            {
                leadHasAddressMap.put(lead.Id, lead.Address);
            }
        }
        
        for( Lead newLead : lstLead )
        {
            mapLeads.put( newLead.Id, newLead );

            if( String.isBlank( newLead.Identifier__c ) && newLead.Account__c == null )
            {
            
                Account newProspect = new Account();
                newProspect.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
                
                System.debug('@@@@DEBUG createProspectPersonAccount :: newLead = ' + newLead);

                for(String accField: accFields)
                {
                    String leadField;
                    if( accField == 'Account__pc' || accField == 'Identifier__c' || accField == 'Identifier__pc' ){
                        continue;
                    }
                    
                    if(accField.endsWith('__pc')){
                        leadField = accField.replace('__pc', '__c');
                    }
                    else if(accField.startsWith('Person')){
                        leadField = accField.remove('Person');
                    }
                    else {
                        leadField = accField;
                    }
                    if(leadField.equalsIgnoreCase('BirthDate')){
                        leadField = 'Birthdate__c';
                    }
        
                    if(leadFields.contains(leadField)){                        
                        newProspect.put(accField, newLead.get(leadField));
                    }
                    else if(leadField.startsWith('Mailing') && leadHasAddressMap.containsKey(newLead.Id)){
                        Address add = new Address();
						add = leadHasAddressMap.get(newLead.Id);
                        if(leadField.equalsIgnoreCase('MailingStreet')){
                            newProspect.put(accField, add.Street);
                        }
                        else if(leadField.equalsIgnoreCase('MailingCity')){
                            newProspect.put(accField, add.City);
                        }
                        else if(leadField.equalsIgnoreCase('MailingState')){
                            newProspect.put(accField, add.State);
                        }
                        else if(leadField.equalsIgnoreCase('MailingPostalCode')){
                            newProspect.put(accField, add.PostalCode);
                        }
                        else if(leadField.equalsIgnoreCase('MailingCountry')){
                            newProspect.put(accField, add.Country);
                        }
                        else if(leadField.equalsIgnoreCase('MailingLatitude')){
                            newProspect.put(accField, add.Latitude);
                        }
                        else if(leadField.equalsIgnoreCase('MailingLongitude')){
                            newProspect.put(accField, add.Longitude);
                        }
                        else if(leadField.equalsIgnoreCase('MailingGeocodeAccuracy')){
                            newProspect.put(accField, add.GeocodeAccuracy);
                        }
                    }
                }

                lstNewProspect.add( newProspect );
                mapLeadIdToAccount.put( newLead.Id, newProspect );
            }
        }

        System.debug('@@@@DEBUG createProspectPersonAccount :: lstNewProspect = ' + lstNewProspect.size() + ' --- ' + lstNewProspect );
        if( !lstNewProspect.isEmpty() ){
            TriggerExclusion.excludeTrigger('Account', true);
            insert lstNewProspect;
        }
        
        System.debug('@@@@DEBUG createProspectPersonAccount :: mapLeadIdToAccount = ' + mapLeadIdToAccount.size() + ' --- ' + mapLeadIdToAccount );
        if( !mapLeadIdToAccount.isEmpty() ){
            List<Lead> lstToUpdate = new List<Lead>();
            
            for( Lead ld : [SELECT Id, Account__c FROM Lead WHERE ID IN :mapLeadIdToAccount.keySet() ] )
            {
                ld.Account__c = mapLeadIdToAccount.get( ld.Id ).Id;
                lstToUpdate.add( ld );
            }

            if( !lstToUpdate.isEmpty() ){
                TriggerExclusion.excludeTrigger('Lead', true);
                update lstToUpdate;
            }
        }
    }
    
}