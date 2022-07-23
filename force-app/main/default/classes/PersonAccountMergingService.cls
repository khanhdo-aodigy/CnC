/** *****
 * Description : Batch for Person Account Merging
 * 
 * Change History
 * Date(YYYYMMDD)        Name       		             Description
 * 20210810              KD@aodigy.com                   Created Initial Version.
 * 
 * 
** *****/
public with sharing class PersonAccountMergingService {

    public static List<String> getFieldNameOnChildObj(String objectName) {
        String accFieldName = 'Account__c';
        String conFieldName = 'Contact__c';
        String conRelateName = 'Contact__r.AccountId';
        List<String> accAndConFields = new List<String>();
        switch on objectName {
            when 'Case' {
                accFieldName = 'AccountId';
                conFieldName = 'ContactId';
                conRelateName = 'Contact.AccountId';
            }
            when 'Event_Registration__c' {
                conFieldName = 'ContactId__c';
                conRelateName = 'ContactId__r.AccountId';
            }
            when 'Opportunity' {
                conFieldName = 'Contact_Person__c';
                conRelateName = 'Contact_Person__r.AccountId';
            }
            when 'Test_Drive__c' {
                conFieldName = 'Prospect__c';
                conRelateName = 'Prospect__r.AccountId';
            }
            when 'Person_Account_Profiling__c', 'Post_Service_Header__c'{
                conFieldName = '';
                conRelateName = '';
            }
            when 'Reward__c', 'Reward_Usage__c', 'Usage_Transaction__c'{
                accFieldName = '';
            }
        }
        
        accAndConFields.add(accFieldName);
        accAndConFields.add(conFieldName); 
        accAndConFields.add(conRelateName);
        return accAndConFields;
    }

    public static void bypassAutomation(Boolean isBypass) {
        Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        automationSetting.Bypass_Flows__c            = isBypass;
        automationSetting.Bypass_Processes__c        = isBypass;
        automationSetting.Bypass_Triggers__c         = isBypass;
        automationSetting.Bypass_Workflows__c        = isBypass;
        automationSetting.Bypass_Validation_Rules__c = isBypass;
        upsert automationSetting;
        if(isBypass){
            System.debug('Bypassed Automations!!!');
        } else {
            System.debug('Turned off bypass Automations!!!');
        }
    }
}