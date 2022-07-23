/** *****
 * Description : Batch class to create/Link PA based on the corresponding Contact's info
 *
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200219            AT          Created Initial Version.
 *
** *****/
global class PABatchContactWithoutPAConverter implements Database.Batchable<sObject>, Database.Stateful{

    private List<String> errMsgs = new List<String>();
    Set<Id> setContIdsWithoutPA = new Set<Id>();

    global PABatchContactWithoutPAConverter(){}

    global PABatchContactWithoutPAConverter( Set<Id> setOfContactIds ){
        this.setContIdsWithoutPA = setOfContactIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> setContIdsWithPA = new Set<String>();
        for(User us : [ SELECT ContactId__c
                        FROM User
                        WHERE Profile.Name = 'End User' AND IsPortalEnabled = true AND AccountId != null AND ContactId__c != null]) {
            setContIdsWithPA.add(us.ContactId__c);
        }

        ContactSelector selector = new ContactSelector();
        return Database.getQueryLocator( selector.selectContactWithoutPA( setContIdsWithPA, ( setContIdsWithoutPA<>null && !setContIdsWithoutPA.isEmpty() ? setContIdsWithoutPA : null ) ) );
    }


    global void execute(Database.BatchableContext bc, List<Contact> contacts){
        try{
            System.debug('@@@@DEBUG PABatchContactWithoutPAConverter >> execute >> contacts.size() = ' + contacts.size() );
            ContactSelector selector = new ContactSelector();
            List<String> childObjects = new List<String>{   'Registered_Vehicle__c', 'Campaign_Member_Vehicle__c', 'ContactHobby__c',
                                                            'CustomerAlerts__c', 'Sales_Agreement__c', 'Case', 'Feedback__c', 'SMS_Reply__c',
                                                            'Service_Appointment__c', 'Event_Registration__c', 'Share__c', 'ClashDeal__c',
                                                            'Opportunity', 'Invoice__c', 'Custom_Quote__c', 'Customer_Detail__c',
                                                            'Test_Drive__c', 'Order__c'};

            Set<String> contIds = new Set<String>();
            for(Contact con : contacts){
                contIds.Add(con.Id);
            }

            List<Map<String, List<SObject>>> childListMaps = new List<Map<String, List<SObject>>>();
            for(String childObject : childObjects) {
                childListMaps.add( selector.getSObjectContactMap( contIds, childObject ) );
            }

            if(!contacts.isEmpty()){
                PAMigrationService.processConversion( contacts, null, childListMaps );
            }

            System.debug('@@@@DEBUG PABatchContactWithoutPAConverter >> execute >>  Limits.getSoslQueries() = ' + Limits.getSoslQueries() );
            System.debug('@@@@DEBUG PABatchContactWithoutPAConverter >> execute >>  Limits.getDmlRows() = ' + Limits.getDmlRows() );
            System.debug('@@@@DEBUG PABatchContactWithoutPAConverter >> execute >>  Limits.getDmlStatements() = ' + Limits.getDmlStatements() );
        }
        catch(Exception ex){
            errMsgs.add(ex.getMessage());
        }
    }


    global void finish(Database.BatchableContext BC){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'hwanshyan.lim@aodigy.com'};
        mail.setToAddresses(toAddresses);
        // mail.setTargetObjectId( UserInfo.getUserId() );
    	// mail.setSaveAsActivity(false);
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i=0; i<errMsgs.size(); i++){
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