/** ******
 * Description: this class is used in the trigger - smsAfterTestDrive 
 *              this class if for sending the feedback email to the lead or customer 1 day after test drive
 *              test class - Test_Post_Test_Drive_Feedback using a trigger send method
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * 20190611            Varinder Kaur        Created Initial Version. 
 * 20200311            HS                   Refactored the code; Added PA Migration (Phase 1) Changes
 * 20200908            khanh.do             Added PA Migration Phase 2 Changes
 * 
** ******/
public without sharing class Post_Test_Drive_Feedback {

    public static void hanldeAfterUpdate(List<Test_Drive__c> lstUpdatedTDs, Map<Id, Test_Drive__c> mapOldTDs) {
        Set<String> setTDIds = new Set<String>();
        try {
            
            for(Test_Drive__c tds : lstUpdatedTDs) {
                if( tds.SendPostTestDrive__c != mapOldTDs.get(tds.Id).SendPostTestDrive__c && tds.SendPostTestDrive__c ==  true ) {    
                    setTDIds.add( tds.Id );
                }
            }

            if( setTDIds <> null && !setTDIds.isEmpty() ) {
                sendPostTDEmail( setTDIds );
            }
        }
        catch (Exception e) {
            System.debug('@@@@DEBUG hanldeAfterUpdate :: Error = ' + e + ' --- ' + e.getMessage() );
        }       
    }


    public static void sendPostTDEmail( Set<String> setTDIds ) {
        
        try
        {
            String contactName, brand, emailAddress, type, contactId, leadId, model, oppId, variant;
            Map<String, String> mapGenerateDE = new Map<String, String>();
            for( Test_Drive__c tds :[SELECT Id, Name, Opportunity__c, Branch_Code__c, Model__c, Model__r.Name, TVariant__c, TVariant__r.Name, 
                                            Prospect__c, Prospect__r.Email, Prospect__r.Name, Prospect__r.Account.RecordTypeId, Prospect__r.Account.RecordType.DeveloperName
                                     FROM Test_Drive__c
                                     WHERE Id IN : setTDIds ] )
            {             
                if(String.isNotBlank(tds.Prospect__c) && String.isNotBlank(tds.Prospect__r.Email) && String.isNotBlank(tds.Prospect__r.Name)){
                    emailAddress = tds.Prospect__r.Email;
                    contactName  = tds.Prospect__r.Name;
                    type         = 'Contact';
                    contactId    = tds.Prospect__c; 
                }
                else
                {
                    emailAddress =  null;
                }

                if(String.isNotBlank(tds.Branch_Code__c))
                {
                    brand = tds.Branch_Code__c;
                }

                if(String.isNotBlank(tds.Opportunity__c))
                {
                    oppId = tds.Opportunity__c;
                }

                if(String.isNotBlank(tds.Model__c) && String.isNotBlank(tds.Model__r.name))
                {
                    model = tds.Model__r.name;
                    if(model.startsWith('DS'))
                    {
                      variant = model;
                    }
                }

                if(String.isNotBlank(tds.TVariant__c) && String.isNotBlank(tds.TVariant__c))
                {
                    variant = tds.TVariant__r.Name;    
                }

                if(String.isNotBlank(variant) && variant.startsWith('DS'))
                {
                    brand = 'DS';
                }

                if(brand == 'CCK' )
                {
                    mapGenerateDE.put('fromAddress', 'sales.kia.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Kia Sales');                  
                }
                else if(brand == 'CCA')
                {
                    mapGenerateDE.put('fromAddress', 'sales.mitsubishi.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Mitsubishi Sales');
                }
                else if(brand == 'CCF')
                {
                    mapGenerateDE.put('fromAddress', 'sales.citroen.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Citroën Sales');
                }
                else if(brand == 'DS')
                {
                    mapGenerateDE.put('fromAddress', 'sales.ds.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'DS Automobiles');
                }

                mapGenerateDE.put('ContactId', (String.isNotBlank(contactId) ) ? contactId: null );
                mapGenerateDE.put('OpportunityId', (String.isNotBlank(oppId) ) ? oppId: null );
                mapGenerateDE.put('Type', (String.isNotBlank(type) ) ? type: null );
                mapGenerateDE.put('brand', (String.isNotBlank(brand) ) ? brand: null );
                mapGenerateDE.put('ContactName', (String.isNotBlank(contactName) ) ? contactName: null);
                mapGenerateDE.put('EmailAddress', (String.isNotBlank(emailAddress) ) ? emailAddress: null);
                mapGenerateDE.put('ModelName', (String.isNotBlank(model) ) ? model: null);
                mapGenerateDE.put('variant', (String.isNotBlank(variant) ) ? variant: null);

                /* Note -- If email and model is null we will not fire the email */
                System.debug('@@@@DEBUG sendPostTDEmail :: mapGenerateDE = ' + mapGenerateDE );
                System.debug('@@@@DEBUG sendPostTDEmail :: emailAddress = ' + emailAddress + ' --- brand = ' +brand);
                if(emailAddress != null && model != null)
                {   
                    BusinessRuleHandlerSFMC.sendPostTDFeedbackEmail(mapGenerateDE);
                } 
            }
        }
        catch(Exception e)
        {
            System.debug('@@@@DEBUG sendPostTDEmail :: Error = ' + e + ' --- ' + e.getMessage() );
            loggerDataPool.buildLogDataPool('EventRegistration_ConfirmationEmail.sendEmail',e);
        }
    }  
}