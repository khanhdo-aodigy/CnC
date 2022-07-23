/** ******
 * Description : Batch Class to Link Contact's child objects' records to corresponding PA.PersonContactId
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20201012             khanh.do@aodigy             Created Initial Version
 * 
** ******/
global with sharing class PABatchLinkRecordToPersonContact implements Database.Batchable<sObject>, Database.Stateful{    
    
    List<Exception> lstException = new List<Exception>();
    Set<String> setRecordIds = new Set<String>();
    String childObject;

    public PABatchLinkRecordToPersonContact(Set<String> personAccIds, String childObject) {
        this.setRecordIds = personAccIds;
        this.childObject = childObject;
    }

    public PABatchLinkRecordToPersonContact() {
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {    

        String query = 'SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = true';
        if(setRecordIds != null && !setRecordIds.isEmpty()) {
            query += ' AND Id IN :setRecordIds';
        }

        System.debug('**** PABatchLinkRecordToPersonContact **** query = ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope = ' + scope);
        try {
            Set<String> personAccIds = new Set<String>();
            for(SObject pa: scope) {
                personAccIds.add(pa.Id);
            }

            List<String> childObjects = new List<String>{'Event_Registration__c','Share__c','ClashDeal__c','Opportunity','Invoice__c',
                                                         'Campaign_Member_Vehicle__c', 'Order__c', 'Registered_Vehicle__c',
                                                         'Sales_Agreement__c','CustomerAlerts__c', 'ContactHobby__c', 'Case',
                                                         'SMS_Reply__c', 'Service_Appointment__c',
                                                         'Custom_Quote__c','Customer_Detail__c','Test_Drive__c','Feedback__c'};
            Map<String, List<SObject>> sObjectContactMap = new Map<String, List<SObject>>();
            
            String contactFieldName;
            String strQuery;
            Set<String> conIds = new Set<String>();
            if(childObjects.contains(childObject)) {
                childObjects = new List<String>{childObject};
            }

            for(String sObjectName: childObjects) {
                switch on sObjectName {
                    when 'Event_Registration__c' {
                        contactFieldName = 'ContactId__c';
                    }
                    when 'Opportunity' {
                        contactFieldName = 'Contact_Person__c';
                    }
                    when 'Test_Drive__c' {
                        contactFieldName = 'Prospect__c';
                    }
                    when 'Case' {
                        contactFieldName = 'ContactId';
                    }
                    when else {
                        contactFieldName = 'Contact__c';
                    }
                }
                
                strQuery = ' SELECT Id, Account__c, Account__r.PersonContactId, ' + contactFieldName
                         + ' FROM ' + sObjectName 
                         + ' WHERE Account__c IN :personAccIds'; //AND contactFieldName !=null AND( contactFieldName + != Account__r.PersonContactId ';
                
                for( SObject record : Database.query(strQuery) ) {
                    String personContactId = (String)record.getsObject('Account__r').get('PersonContactId');
                    String contactIdString = (String)record.get(contactFieldName);
                    System.debug('record = ' + record);
                    conIds.add(personContactId);
                    if(personContactId != contactIdString) {
                        if( sObjectContactMap.containsKey( personContactId )) {
                            sObjectContactMap.get( personContactId).add(record);
                        } else {
                            sObjectContactMap.put( personContactId, new List<SObject>{record} );
                        }
                    }                    
                }
            }
            
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(
            new Schema.SObjectType[]{   Event_Registration__c.SObjectType,
                                        Share__c.SObjectType,
                                        ClashDeal__c.SObjectType,
                                        Opportunity.SObjectType,
                                        Invoice__c.SObjectType,
                                        Custom_Quote__c.SObjectType,
                                        Customer_Detail__c.SObjectType,
                                        Test_Drive__c.SObjectType,
                                        Feedback__c.SObjectType,
                                        Campaign_Member_Vehicle__c.SObjectType,
                                        Order__c.SObjectType,
                                        Registered_Vehicle__c.SObjectType,
                                        Sales_Agreement__c.SObjectType,
                                        CustomerAlerts__c.SObjectType,
                                        ContactHobby__c.SObjectType,
                                        Case.SObjectType,
                                        SMS_Reply__c.SObjectType,
                                        Service_Appointment__c.SObjectType
                                    }
            );
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :conIds];
            for(Contact cont: contacts) {
                List<SObject> childRecords = sObjectContactMap.get(cont.Id);
                System.debug('childRecords = ' + childRecords);
                linkToPersonContact(childRecords, uow, cont);
            }
            initTriggerExlusion(childObjects);
            uow.commitWork();
        } catch (Exception ex) {
            lstException.add(ex);
            System.debug('ex: ' + ex + ' .Cause: ' + ex.getCause() + ' .At line: ' + ex.getLineNumber());
            loggerDataPool.buildLogDataPool('== PABatchLinkRecordToPersonContact == ', ex);
        }
        
    }

    private static void initTriggerExlusion(List<String> childObjects){
        for( String strObject : childObjects ) 
        {
            TriggerExclusion.excludeTrigger( strObject , true );
        }
    }

    private static void linkToPersonContact (List<sObject> childRecords, ADGLIB_SObjectUnitOfWork uow, Contact personCon ){
        if( !childRecords.isEmpty() ){
            for( SObject sObj : childRecords ){
                if( sObj.getSObjectType().getDescribe().fields.getMap().containsKey('Contact__c') ){
                    uow.registerDirty( sobj, sObj.getSObjectType().getDescribe().fields.getMap().get('Contact__c'), personCon);
                } else if( sObj.getSObjectType().getDescribe().fields.getMap().containsKey('ContactId__c') ) {
                    uow.registerDirty( sobj, sObj.getSObjectType().getDescribe().fields.getMap().get('ContactId__c'), personCon);
                } else if( sObj.getSObjectType().getDescribe().fields.getMap().containsKey('Contact_Person__c') ) {
                    uow.registerDirty( sobj, sObj.getSObjectType().getDescribe().fields.getMap().get('Contact_Person__c'), personCon);
                } else if( sObj.getSObjectType().getDescribe().fields.getMap().containsKey('Prospect__c') ) {
                    uow.registerDirty( sobj, sObj.getSObjectType().getDescribe().fields.getMap().get('Prospect__c'), personCon);
                }
            }
        }
    }

    global void finish(Database.BatchableContext db){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'khanh.do@aodigy.com'};
        mail.setToAddresses(toAddresses);

        String body;
        if(!lstException.isEmpty()){
            for(Integer i=0; i<lstException.size(); i++){
                body += (String.valueof(i+1)+' '+lstException[i]+ '\r\n');
            }   
        }
        else{
            body = 'Sucess';
        }
        mail.setSubject('PABatchLinkRecordToPersonContact');
        mail.setPlainTextBody(body);

        System.debug('@@@@DEBUG RecordSharPABatchLinkRecordToPersonContactingBatch >> finish :: mail = ' + mail );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}