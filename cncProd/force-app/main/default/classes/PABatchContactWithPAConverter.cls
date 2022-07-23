/** *****
 * Description : Batch class to create/Link PA based on the corresponding Contact's info
 *
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200219            AT          Created Initial Version.
 *
** *****/
global class PABatchContactWithPAConverter implements Database.Batchable<sObject>, Database.Stateful{

    private List<String> errMsgs = new List<String>();
    private Set<String> setOfContactIds = new Set<String>();

    global PABatchContactWithPAConverter( Set<String> setOfContactIds ){
        this.setOfContactIds = setOfContactIds;
    }

    global PABatchContactWithPAConverter(){
    }

    global Database.QueryLocator start(Database.BatchableContext bc){

        String userProfile = 'End User';
        String strSOQL = ' SELECT AccountId, ContactId__c '+
                         '   FROM User '+
                         '   WHERE Profile.Name = :userProfile '+
                         '   AND IsPortalEnabled = true '+
                         '   AND ContactId != null '+
                         '   AND ContactId__c != null '+ 
                        //  '   AND isValid__c = true '+
                         '   AND isActive = true ';


        strSOQL += (setOfContactIds<>null && !setOfContactIds.isEmpty()) ? ' AND ContactId__c IN :setOfContactIds ' : '';

        return Database.getQueryLocator( strSOQL );
    }


    global void execute(Database.BatchableContext bc, List<User> users){
        try
        {
            System.debug('@@@ users: '+users);
            Map<String, String> contAccountMap = new Map<String, String>();
            for(User us : users){
                contAccountMap.put(us.ContactId__c, us.AccountId);
            }

            ContactSelector selector = new ContactSelector();
            List<String> childObjects = new List<String>{   'Registered_Vehicle__c', 'Campaign_Member_Vehicle__c', 'ContactHobby__c',
                                                            'CustomerAlerts__c', 'Sales_Agreement__c', 'Case', 'Feedback__c', 'SMS_Reply__c',
                                                            'Service_Appointment__c', 'Event_Registration__c', 'Share__c', 'ClashDeal__c',
                                                            'Opportunity', 'Invoice__c', 'Custom_Quote__c', 'Customer_Detail__c',
                                                            'Test_Drive__c', 'Order__c'};


            List<Contact> contacts = selector.selectContactWithPA( contAccountMap.keySet());
            List<Map<String, List<SObject>>> childListMaps = new List<Map<String, List<SObject>>>();
            for(String childObject : childObjects) {
                childListMaps.add(selector.getSObjectContactMap(contAccountMap.keySet(), childObject));
            }
            if(!contacts.isEmpty()){
                PAMigrationService.processConversion(contacts, contAccountMap, childListMaps);
            }
            
            System.debug('@@@@DEBUG PABatchContactWithPAConverter >> execute >>  Limits.getSoslQueries() = ' + Limits.getSoslQueries() );
            System.debug('@@@@DEBUG PABatchContactWithPAConverter >> execute >>  Limits.getDmlRows() = ' + Limits.getDmlRows() );
            System.debug('@@@@DEBUG PABatchContactWithPAConverter >> execute >>  Limits.getDmlStatements() = ' + Limits.getDmlStatements() );
        }
        catch(Exception ex){
            system.debug('@@@ ex: '+ex.getMessage());
            errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- ' + ex.getLineNumber() );
        }

    }

    global void finish(Database.BatchableContext BC){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'hwanshyan.lim@aodigy.com'};
        mail.setToAddresses(toAddresses);
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i = 0; i < errMsgs.size(); i++){
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }
        }
        else{
            body = 'Success';
        }
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}