/** *****
 * Description : Batch for Person Account Merging
 *               Merge PA's child objects whose have more than 1000 records
 *               Due to tight schedule, this batch wont handle Referral__c obj. Cuz we've check that it has ~300 records only
 * 
 * Change History
 * Date(YYYYMMDD)        Name       		             Description
 * 20210810              KD@aodigy.com                   Created Initial Version.
 * 
 * 
** *****/
public with sharing class PersonAccountChildMergingBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private Map<String, Integer> results = new Map<String, Integer>();
    private List<String> errMsgs = new List<String>();
    private List<Logger_Data_Pool__c> errorLogs = new List<Logger_Data_Pool__c>();

    private String childObjName;
    List<String> listFieldNames;
    private String accFieldName;
    private String conFieldName;
    private String relateName;

    private Set<Id> dupAccIds;
    private Set<Id> primaryAccIds;
    private List<String> listChildObjs;

    private Boolean chainAnotherbatch = false;
    private Map<Id, Account> mapDupAccById = new Map<Id, Account>();

    public PersonAccountChildMergingBatch(List<String> listChildObjs, Set<Id> dupAccIds) {
        this.listChildObjs = listChildObjs;
        this.dupAccIds = dupAccIds;
    }

    private PersonAccountChildMergingBatch(List<String> listChildObjs, Set<Id> dupAccIds, Map<String, Integer> results) {
        this.listChildObjs = listChildObjs;
        this.dupAccIds = dupAccIds;
        this.results = results;
    }

    public Database.QueryLocator start(Database.Batchablecontext bc)
    {
        PersonAccountMergingService.bypassAutomation(true); //Bypass all automations
        System.debug('listChildObjs :: ' + listChildObjs.size() + ' :: ' + listChildObjs);
        if(listChildObjs != null && listChildObjs.size() > 0) {
            childObjName = listChildObjs[0];
            System.debug('chainAnotherbatch :: ' + chainAnotherbatch);
            System.debug('@@@ PersonAccountChildMergingBatch.start() childObjName ::' + childObjName);
                        
            listChildObjs.remove(0);
            chainAnotherbatch = listChildObjs.size() == 0 ? false : true;
            System.debug('@@@ PersonAccountChildMergingBatch.start() chainAnotherbatch :: ' + chainAnotherbatch);

            listFieldNames = PersonAccountMergingService.getFieldNameOnChildObj(childObjName);
            accFieldName = listFieldNames[0];
            conFieldName = listFieldNames[1];
            relateName   = listFieldNames[2];
            System.debug('@@@ PersonAccountChildMergingBatch.start() accFieldName :: ' + accFieldName);
            System.debug('@@@ PersonAccountChildMergingBatch.start() conFieldName :: ' + conFieldName);
            String queryString = '';
            if(childObjName != 'Referral__c') {
                if( childObjName == 'Case'){
                    queryString =  ' SELECT Id, AccountId, Account.PersonContactId, ContactId, OwnerId, Owner.IsActive ';
                    queryString += ' FROM Case ';
                    queryString += ' WHERE Contact.AccountId IN :dupAccIds OR AccountId IN :dupAccIds ';
                } else if( String.isNotBlank(accFieldName) ){
                    queryString =  ' SELECT Id, Account__c, Account__r.PersonContactId ';                            
                      
    
                    if( String.isNotBlank(conFieldName) ) {
                        queryString += ' , ' +  conFieldName;
                    }
    
                    queryString += ' FROM ' + childObjName;
                    queryString += ' WHERE Account__c IN :dupAccIds ';

                    if( String.isNotBlank(conFieldName) ) {
                        queryString += ' OR ' +  relateName + ' IN :dupAccIds';
                    }
                    
                } else if( String.isNotBlank(conFieldName) && String.isNotBlank(relateName) ) {
    
                    queryString =  ' SELECT Id, ' + conFieldName + ', ' + relateName;            
                    queryString += ' FROM ' + childObjName;
                    queryString += ' WHERE '+ relateName +' IN :dupAccIds ';
                }
            }
            

            System.debug('@@@@DEBUG PersonAccountChildMergingBatch.start() queryString = ' + queryString);
            return Database.getQueryLocator( queryString );
        } else {
            System.debug('invalid param');
        }
        return null;
        
    }

    public void execute(Database.BatchableContext jobId, List<SObject> scope) {
        System.debug('scope size = ' + scope.size());
        System.debug('@@@@DEBUG PersonAccountChildMergingBatch.execute() chainAnotherbatch :: ' + chainAnotherbatch);
        
        if(scope != null && scope.size() > 0) {                                                  
                                    
            if(results.containsKey(childObjName)) {
                results.put(childObjName, results.get(childObjName) + scope.size());    
            } else {
                results.put(childObjName, scope.size());   
            }  
            
            if(dupAccIds.size() > 0){
                mapDupAccById = new Map<Id, Account>([  SELECT Id, PersonContactId, Primary_Account_ID__c
                                                        FROM Account
                                                        WHERE Id IN :dupAccIds
                                                        AND Primary_Account_ID__c != ''
                                                    ]);

            }

            Set<Id> primaryAccIds = new Set<Id>();            
            Map<Id, Id> mapDupConToDupAccIds = new Map<Id, Id>();
            for(Account dupAcc: mapDupAccById.values()) {
                primaryAccIds.add(dupAcc.Primary_Account_ID__c);
                mapDupConToDupAccIds.put(dupAcc.PersonContactId, dupAcc.Id);
            }

            //get Primary Account: Map<AccountId, PersonContactId>
            Map<Id,Id> mapPrimaryAccToConId = new Map<Id, Id>();
            for(Account primaryAcc: [SELECT Id, PersonContactId FROM Account WHERE Id IN :primaryAccIds] ) {
                mapPrimaryAccToConId.put(primaryAcc.Id, primaryAcc.PersonContactId);
            }

            try {
                Map<Id, Id> mapChildRecToOldParent = new Map<Id, Id>(); //Map<childObj.Id, dupAccount.Id>                     
                Account dupAcc;
                Id dupAccId;
                Id dupConId;

                for(SObject childRecord: scope) {
                    System.debug(' childRecord :: ' + childRecord); 
                    if(String.isNotBlank(accFieldName)) {
                        dupAccId = (Id) childRecord.get(accFieldName);
                        if(String.isNotBlank(dupAccId)) {
                            mapChildRecToOldParent.put((Id)childRecord.get('Id'), dupAccId ); //save the old Account__c
                            if(mapDupAccById.containsKey(dupAccId)) {                                           
                                dupAcc = mapDupAccById.get(dupAccId);
                                 System.debug('dupAcc ::' + dupAcc);
                                                
                                childRecord.put(accFieldName, dupAcc.Primary_Account_ID__c);    
                                
                            }
                        } else if( String.isNotBlank(conFieldName) ) {
                            dupConId = (Id) childRecord.get(conFieldName);
                            dupAccId = mapDupConToDupAccIds.get(dupConId);
                            dupAcc = mapDupAccById.get( dupAccId );

                            childRecord.put(accFieldName, dupAcc.Primary_Account_ID__c);
                            childRecord.put(conFieldName, mapPrimaryAccToConId.get(dupAcc.Primary_Account_ID__c ));
                        }
                        
                        
                    }

                    if( String.isNotBlank(conFieldName) ){
                        if(dupAcc == null) {
                            dupConId = (Id)childRecord.get(conFieldName);
                            dupAccId = mapDupConToDupAccIds.get(dupConId);
                            dupAcc   = mapDupAccById.get( dupAccId );
                            mapChildRecToOldParent.put((Id)childRecord.get('Id'), dupAccId ); 
                            System.debug('@@@ dupAcc =' + dupAcc);
                        }
                        childRecord.put(conFieldName, mapPrimaryAccToConId.get(dupAcc.Primary_Account_ID__c )); 
                            
                    }                              

                }     
                System.debug('@@@ After update:: ' + scope.size() + ' :: ' + scope);
                System.debug('@@@ mapChildRecToOldParent :: ' + mapChildRecToOldParent);
                System.debug('@@@ chainAnotherbatch :: ' + chainAnotherbatch);

                Database.SaveResult[] updateResults = Database.update(scope, false); //allow partial update                

                for(Integer index = 0, size = updateResults.size(); index < size; index++) {
                    if(!updateResults[index].isSuccess()) {
                        Database.Error[] errors = updateResults[index].getErrors();

                        SObject failedRecord = scope[index];                           
                        String failedAccId = mapChildRecToOldParent.get( (String)failedRecord.get('Id') );
                        System.debug('failedRecord = ' + failedRecord);
                        System.debug('failedAccId = ' + failedAccId);
                        if(String.isNotBlank(failedAccId) && mapDupAccById.containsKey(failedAccId)) {
                             mapDupAccById.remove(failedAccId); //If reparent child failed, NOT delete that duplicate parent Account
                        }
                        Logger_Data_Pool__c log = new Logger_Data_Pool__c();
                        log.Instance__c = 'PersonAccountChildMergingBatch';
                        log.Name = (String)failedRecord.get('Id');
                        log.Type__c = 'System.DmlException';
                        log.Message__c     = errors[0].getMessage() + '. \n';
                        log.Stack_Trace__c = errors[0].getFields() + '. \n';
                        log.Cause__c       = errors[0].getStatusCode() + '. \n';
                        errorLogs.add(log);                           
                                
                    }
                }                  

            } catch(Exception ex){
                System.debug('@@@@DEBUG PersonAccountChildMergingBatch >> Exception: ' + ex);
                System.debug('Message: ' + ex.getMessage() + '. At line: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() );
                errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
                loggerDataPool.buildLogDataPool('PersonAccountChildMergingBatch', ex);
            }
        
        }        
        
    }

    public void finish(Database.BatchableContext bc){
        System.debug('@@@@DEBUG PersonAccountChildMergingBatch.finish() >> results: ' + results.size() + ' = ' + results);        PersonAccountMergingService.bypassAutomation(false);
        if(!chainAnotherbatch) {

            System.debug('duplicated PAs to remove = ' + dupAccIds.size() + ' = ' + dupAccIds);        
            List<Id> listDupAccIds = new List<Id>(dupAccIds);    
            Database.DeleteResult[] deleteResults = Database.delete(listDupAccIds, false);
            for(Integer index = 0, size = deleteResults.size(); index < size; index++) {
                if(!deleteResults[index].isSuccess()) {
                    Database.Error[] errors = deleteResults[index].getErrors();
                    Id failedRecordId = deleteResults[index].getId();

                    Logger_Data_Pool__c log = new Logger_Data_Pool__c();
                    log.Instance__c = 'PersonAccountChildMergingBatch';
                    log.Name = (String)failedRecordId;
                    log.Type__c = 'System.DmlException';
                    log.Message__c     = errors[0].getMessage() + '. \n';
                    log.Stack_Trace__c = errors[0].getFields() + '. \n';
                    log.Cause__c       = errors[0].getStatusCode() + '. \n';
                    errorLogs.add(log);
                }
            }

        }

        if(errorLogs.size() > 0 ) {
            insert errorLogs;
        }

        if(chainAnotherbatch && dupAccIds.size() > 0 && listChildObjs != null && listChildObjs.size() > 0){
            Database.executeBatch(new PersonAccountChildMergingBatch(listChildObjs, dupAccIds, results));            
            
        } else {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'khanh.do@aodigy.com', 'thieudang.vu@aodigy.com'};
            mail.setToAddresses( toAddresses );
            mail.setTargetObjectId( UserInfo.getUserId() );
            mail.saveAsActivity = false;
            mail.setSubject('PersonAccountChildMergingBatch Run Result - ' + Datetime.now());
            String body;
            if(!errMsgs.isEmpty()){
                for(Integer i = 0; i < errMsgs.size(); i++){
                    body = 'PersonAccountChildMergingBatch Got Exception !!!\n';
                    body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
                }
            } 
            else{            
                body = 'PersonAccountChildMergingBatch Processed Successfully !!!\n';
            }

            if(results.size() > 0) {
                for(String obj: results.keySet()){                
                    body += 'Number ' + obj + ' processed :: ' + results.get(obj) + '\r\n';
                }
            }
            
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}