/** ******
 * Description : Batch Class to Patch PersonAccount manual sharing (i.e. Inheritted from the corresponding Lead or JCC Contact )
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20200511             khanh.do@aodigy             Created Initial Version
 * 
** ******/
global class RecordSharingBatch implements Database.Batchable<sobject>, Database.Stateful{

    private String sObjName;
    List<Exception> lstException = new List<Exception>();
    Set<String> setRecordIds = new Set<String>();

    global RecordSharingBatch(String sObjName, Set<String> setTargetedIds ) 
    {
        this.sObjName = sObjName;
        this.setRecordIds = setTargetedIds;
    }


    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String query = '';        
        if(sObjName == 'Contact') {
            query = 'SELECT Id, ContactAccessLevel, ContactId, RowCause, UserOrGroupId FROM ContactShare WHERE RowCause = \'Manual\'';

            if( setRecordIds != null && !setRecordIds.isEmpty() ){
                query += ' AND ContactId IN :setRecordIds';
            }
        } 
        else if (sObjName == 'Lead') {
            query = 'SELECT Id, LeadAccessLevel, LeadId, RowCause, UserOrGroupId FROM LeadShare WHERE RowCause = \'Manual\'';

            if( setRecordIds != null && !setRecordIds.isEmpty() ){
                query += ' AND LeadId IN :setRecordIds';
            }
        }
        System.debug('**** RecordSharingBatch **** query = ' + query);
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        
        System.debug('**** RecordSharingBatch **** scope.size = ' + scope.size());
        if(!scope.isEmpty()){            
            try
            {   
                Set<Id> recordIds = new Set<Id>();
                String fieldName = sObjName+'Id';
                for( SObject obj : scope ){
                    recordIds.add( (Id)obj.get( fieldName ) );
                }
                System.debug('@@@@DEBUG RecordSharingBatch >> execute :: recordIds = ' + recordIds.size() + ' --- ' + recordIds );

                List<sharingHelper.generateShare> recordsToShareList = new List<sharingHelper.generateShare>();

                String personAccQuery = 'SELECT Id, Account__c FROM ' + sObjName + ' WHERE Id IN :recordIds AND Account__r.IsPersonAccount = true';
                if(sObjName == 'Contact') {
                    List<Contact> contacts = Database.query(personAccQuery);
                    List<ContactShare> contactShares = scope;
                    for(Contact contact: contacts){
                        for(ContactShare shareObj: contactShares){
                            if(contact.Id == shareObj.ContactId){
                                recordsToShareList.add(new sharingHelper.generateShare(shareObj.ContactAccessLevel, 'Account', contact.Account__c, shareObj.UserOrGroupId));
                            }
                        }
                    }            
                } else if (sObjName == 'Lead') {
                    List<Lead> leads = Database.query(personAccQuery);
                    List<LeadShare> leadShares = scope;
                    for(Lead lead: leads){
                        for(LeadShare shareObj: leadShares){
                            if(lead.Id == shareObj.LeadId){
                                recordsToShareList.add(new sharingHelper.generateShare(shareObj.LeadAccessLevel, 'Account', lead.Account__c, shareObj.UserOrGroupId));
                            }
                        }
                    } 
                }            
                
                if(!recordsToShareList.isEmpty()){
                    sharingHelper.creatShare(recordsToShareList);
                    System.debug('Share successfully, recordsToShareList = ' +recordsToShareList);
                }   
            } 
            catch (Exception ex){
                lstException.add(ex);
                loggerDataPool.buildLogDataPool('== RecordSharingBatch == ', ex);
                System.debug('Ex: ' + ex.getMessage() + ' . Cause: ' + ex.getCause() + ' .At line: ' + ex.getLineNumber());
            }
        }
        else {
            System.debug('== No ' + sObjName + 'Share record by cause \'Manual\' exist');
        }
             
        
    }

    global void finish(Database.BatchableContext db){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'khanh.do@aodigy.com'};
        mail.setToAddresses(toAddresses);
        // mail.setTargetObjectId( UserInfo.getUserId() );
        // mail.setSaveAsActivity(false);

        String body;
        if(!lstException.isEmpty()){
            for(Integer i=0; i<lstException.size(); i++){
                body += (String.valueof(i+1)+' '+lstException[i]+ '\r\n');
            }   
        }
        else{
            body = 'Sucess';
        }
        mail.setSubject('RecordSharingBatch');
        mail.setPlainTextBody(body);

        System.debug('@@@@DEBUG RecordSharingBatch >> finish :: mail = ' + mail );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}