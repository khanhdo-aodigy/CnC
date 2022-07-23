/** *****
 * Description : Batch for Person Account Merging
 * 
 * Change History
 * Date(YYYYMMDD)        Name       		             Description
 * 20210810              KD@aodigy.com                   Created Initial Version.
 * 
 * 
** *****/
global with sharing class PersonAccountMergingBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private final List<String> childObjects = new List<String>{'Registered_Vehicle__c', 'Campaign_Member_Vehicle__c',
                                                            'CustomerAlerts__c', 'MB_Sales_Agreement__c',
                                                            'Case', 'Feedback__c', 
                                                            'Service_Appointment__c', 'Event_Registration__c',
                                                            'ClashDeal__c', 'Opportunity', 'Invoice__c',
                                                            'Custom_Quote__c', 'Customer_Detail__c',
                                                            'Test_Drive__c', 'Order__c',
                                                            'Person_Account_Profiling__c', 'Post_Service_Header__c',
                                                            'Vehicle_Stock_Reservation__c', 'Used_Car_Vehicle_Stock__c',
                                                            'Defect_Header__c', 'Model_Alert_Subscription__c',
                                                            'Price_Alert_for_Non_MF__c', 'Purchase_Option__c',
                                                            'General_Enquiry__c',
                                                            'Sales_Opportunity__c', 'Schedule_Viewing__c',
                                                            'Sales_Agreement__c',
                                                            'Reward_Profile__c', 'Reward__c', 'Reward_Usage__c',
                                                            'Share__c', 'Transaction__c', 'Usage_Transaction__c',
                                                            'Referral__c'

                                                        }; //'Non_C_C_Vehicle__c',

    private String personEmail;
    private Set<String> setPersonEmails;
    private List<String> bigDataChildObjs = new List<String>();
    Boolean chainAnotherBatch = false;

    private Map<String, Integer> results = new Map<String, Integer>();
    private List<String> errMsgs = new List<String>();
    private List<Logger_Data_Pool__c> errorLogs = new List<Logger_Data_Pool__c>();
    private Map<Id, Account> mapDupAccById = new Map<Id, Account>();
    private Map<Id, Id> mapChildRecToOldParent = new Map<Id, Id>();

    global void execute (SchedulableContext ctx) {
        Database.executeBatch(new PersonAccountMergingBatch());
    }

    global PersonAccountMergingBatch() {
    }


    global PersonAccountMergingBatch(Set<String> setPersonEmails) {
        this.setPersonEmails = setPersonEmails;
    }

    global PersonAccountMergingBatch(String personEmail) {
        this.personEmail = personEmail;
    }

    global PersonAccountMergingBatch(String personEmail, String childObj) {
        this.personEmail = personEmail;
        this.childObjects = new List<String>{childObj};
    }
        

    global Database.QueryLocator start(Database.Batchablecontext bc)
    {
        PersonAccountMergingService.bypassAutomation(true); //Bypass all automations
        System.debug('childObjects :: ' + childObjects.size() + ' :: ' + childObjects);
        String queryString =  ' SELECT Id, PersonContactId, PersonEmail, IsCustomerPortal, DWH_Contact_ID__pc, '+
                             ' is_Duplicated__pc, Is_Primary_Account__c, Primary_Account_ID__c ';

        queryString += ' FROM Account '+
                       ' WHERE IsPersonAccount = true ' +
                       ' AND is_Duplicated__pc = true ' +
                       ' AND Primary_Account_ID__c != \'\' ' +
                       ' AND Is_Primary_Account__c = false ';
                       
        if(String.isNotBlank(personEmail)) {
            queryString += ' AND PersonEmail = :personEmail ';
        }

        if(setPersonEmails != null && setPersonEmails.size() > 0) {
            queryString += ' AND PersonEmail IN :setPersonEmails ';
        }

        queryString += ' ORDER BY PersonEmail NULLS LAST ' ;

        System.debug('@@@@DEBUG PersonAccountMergingBatch.start() queryString = ' + queryString);
        return Database.getQueryLocator( queryString );
    }

    global void execute(Database.BatchableContext jobId, List<Account> scope) {
        System.debug('scope size = ' + scope.size());
        
        if(scope != null && scope.size() > 0) {
            if(results.containsKey('Duplicated PAs')) {                        
                results.put('Duplicated PAs', results.get('Duplicated PAs') + scope.size());
            } else {
                results.put('Duplicated PAs', scope.size());
            }

            try {
                List<Account> portalDupPAs = new List<Account>();
                Set<Id> primaryAccIds = new Set<Id>();
                Map<Id, Id> mapDupConToDupAccIds = new Map<Id, Id>();
                Set<Id> dupAccIds = new Set<Id>();

                for(Account dupAcc: scope){
                    primaryAccIds.add(dupAcc.Primary_Account_ID__c);
                    mapDupAccById.put(dupAcc.Id, dupAcc); //global var
                    dupAccIds.add(dupAcc.Id); //local var
                    mapDupConToDupAccIds.put(dupAcc.PersonContactId, dupAcc.Id);
                    if(dupAcc.IsCustomerPortal) {
                        dupAcc.IsCustomerPortal = false;
                        portalDupPAs.add(dupAcc);
                    }
                }

                
                //Set<Id> dupConIds = mapDupConToDupAccIds.keySet();

                if(portalDupPAs.size() > 0) {
                    update portalDupPAs; //Update to Delete: Cannot delete Account whose IsCustomerPortal = true
                }
                
                if(results.containsKey('Duplicate PAs Have User Record')) {                        
                    results.put('Duplicate PAs Have User Record', results.get('Duplicate PAs Have User Record') + portalDupPAs.size());
                } else {
                    results.put('Duplicate PAs Have User Record', portalDupPAs.size());
                }

                List<Account> primaryPAs = [ SELECT Id, PersonContactId
                                            FROM Account
                                            WHERE Id IN :primaryAccIds
                                            ];

                Map<Id, Id> primaryAccAndContactIds = new Map<Id,Id>();
                for(Account primaryPA: primaryPAs) {
                    primaryAccAndContactIds.put(primaryPA.Id, primaryPA.PersonContactId);
                }                

                Set<String> childObjsToHandle = new Set<String>();

                //Count number records of each object
                for(String childObj: childObjects) {
                    List<String> listFieldNames = PersonAccountMergingService.getFieldNameOnChildObj(childObj);
                    String accFieldName = listFieldNames[0];
                    String conFieldName = listFieldNames[1];
                    String relateName = listFieldNames[2];

                    String countQuery = ' SELECT COUNT(Id) ';
                    countQuery += ' FROM ' + childObj;

                    if(childObj != 'Referral__c') {
                        if( String.isNotBlank(accFieldName)) {      

                            countQuery += ' WHERE Account__c IN :dupAccIds';
                            if( String.isNotBlank(conFieldName) ) {
                                countQuery += ' OR ' + relateName + ' IN :dupAccIds';
                            }

                        } else {
                            countQuery += ' WHERE ' + relateName + ' IN :dupAccIds';
                        }                       

                    } else {
                        countQuery += ' WHERE Referrer_Account__c IN :dupAccIds ';
                        countQuery += ' OR Referee_Account__c IN :dupAccIds ';
                    }
                    
                    List<AggregateResult> countResult = Database.query(countQuery);
                    Integer numOfRecords = (Integer)countResult[0].get('expr0');
                    System.debug('@@@ Count >>>' + childObj + ' :: ' + numOfRecords);
                    if( numOfRecords > 1000 && !bigDataChildObjs.contains(childObj)) {
                        bigDataChildObjs.add(childObj);
                    } else if(numOfRecords > 0 && !childObjsToHandle.contains(childObj)){
                        childObjsToHandle.add(childObj);
                    }

                    if( results.containsKey(childObj) ) {
                        results.put(childObj, results.get(childObj) + numOfRecords);
                    } else {
                        results.put(childObj, numOfRecords);
                    }
                    
                }
                System.debug('@@@@DEBUG PersonAccountMergingBatch >> count >> bigDataChildObjs: ' + bigDataChildObjs);
                System.debug('@@@@DEBUG PersonAccountMergingBatch >> count >> childObjsToHandle: ' + childObjsToHandle);
                System.debug('@@@@DEBUG PersonAccountMergingBatch >> count >> dupAccIds: ' + dupAccIds);

                Map<String, List<SObject>> mapChildRecordsByName = new Map<String, List<SObject>>();       

                
                //Query child Objects   
                for(String childObj: childObjsToHandle) {
                    if(childObj != 'Referral__c') {
                        List<String> listFieldNames = PersonAccountMergingService.getFieldNameOnChildObj(childObj);
                        String accFieldName = listFieldNames[0];
                        String conFieldName = listFieldNames[1];
                        String relateName   = listFieldNames[2];

                        String query = 'SELECT Id ';

                        if( childObj == 'Case'){
                            query += ', OwnerId, Owner.IsActive';
                        }

                        if(String.isNotBlank(accFieldName)){
                            query += ', ' +  accFieldName;
                        }

                        if(String.isNotBlank(conFieldName)){
                            query += ', ' + conFieldName;
                        }

                        query += ' FROM ' + childObj ;
                        if(childObj == 'Case')
                        {
                            query += ' WHERE Contact.AccountId IN :dupAccIds OR AccountId IN :dupAccIds ';
                        }
                        else if(String.isNotBlank(accFieldName))
                        {
                            query += ' WHERE ' +  accFieldName + ' IN :dupAccIds ';
                            if (String.isNotBlank(conFieldName)) {
                                //query += ' OR ' +  conFieldName + ' IN :dupConIds';     
                                query += ' OR ' +  relateName + ' IN :dupAccIds';                             
                            }
                            
                        } else if( String.isNotBlank(conFieldName) )
                        {
                            //query += ' WHERE ' +  conFieldName + ' IN :dupConIds'; 
                            query += ' WHERE ' +  relateName + ' IN :dupAccIds';                             

                        }
                        System.debug('query ::' + query);
                        List<SObject> childRecords = Database.query(query);
                        mapChildRecordsByName.put(childObj, childRecords);
                    } else if( childObj == 'Referral__c' )  //Referral__c is special, need to handle separately
                    { 
                        Map<Id, Referral__c> referralMap = new Map<Id, Referral__c>(
                                                        [ SELECT Id, Referrer_Account__c, Referee_Account__c
                                                          FROM Referral__c
                                                          WHERE Referrer_Account__c IN :mapDupAccById.keySet()
                                                          OR Referee_Account__c  IN :mapDupAccById.keySet()
                                                        ]);

                    
                        System.debug('referralMap ::' + referralMap.size() + ' :: ' + referralMap.values());

                        //Reparent
                        if(referralMap != null && referralMap.size() > 0) {
                            List<Referral__c> referrals = new List<Referral__c>();

                            for(Referral__c referral: referralMap.values()) {
                                if( mapDupAccById.containsKey(referral.Referrer_Account__c) ||  mapDupAccById.containsKey(referral.Referee_Account__c) ) {
                                    
                                    if( mapDupAccById.containsKey(referral.Referrer_Account__c) ) {
                                        Account dupAcc = mapDupAccById.get(referral.Referrer_Account__c);
                                        referral.Referrer_Account__c = dupAcc.Primary_Account_ID__c;
                                        mapChildRecToOldParent.put( referral.Id, dupAcc.Id ); 
                                    }
                                    
                                    if( mapDupAccById.containsKey(referral.Referee_Account__c) ) {
                                        Account dupAcc = mapDupAccById.get(referral.Referee_Account__c);
                                        referral.Referee_Account__c = dupAcc.Primary_Account_ID__c;
                                        mapChildRecToOldParent.put( referral.Id, dupAcc.Id ); 
                                    }
                                    referrals.add( referral );
                                }
            
                            }
                            
                            updateChildRecords(referrals);
                        } 
                    }                    

                }               
                               
                List<String> listFieldNames;
                String accFieldName;
                String conFieldName;
                List<SObject> childList;

                System.debug('@@@@DEBUG PersonAccountMergingBatch >> mapChildRecordsByName: ' + mapChildRecordsByName.size() + ' = ' + mapChildRecordsByName);
                if(mapChildRecordsByName != null && mapChildRecordsByName.size() > 0) {
                    for(String childObjName: mapChildRecordsByName.keySet()) {

                        childList = mapChildRecordsByName.get(childObjName);   
                        //reparent child records
                        if(childObjName != 'Referral__c') {
                            listFieldNames = PersonAccountMergingService.getFieldNameOnChildObj(childObjName);
                            accFieldName = listFieldNames[0];
                            conFieldName = listFieldNames[1];
    
                            if(childList != null && childList.size() > 0) {
                                                     
                            System.debug('Before reparent >>> ' + childObjName + ' = ' + childList.size());   
                                for(SObject childRecord: mapChildRecordsByName.get(childObjName)) {      
                                    System.debug(' childRecord :: ' + childRecord);                         
                                    Account dupAcc;
                                    Id dupAccId;
                                    Id dupConId;
                                    if(String.isNotBlank(accFieldName)) {
                                        dupAccId = (Id) childRecord.get(accFieldName);

                                        if( String.isNotBlank(dupAccId)) { //if account field has value
                                            mapChildRecToOldParent.put((Id)childRecord.get('Id'), dupAccId); 
                                            if(mapDupAccById.containsKey(dupAccId)) {                                            
                                                dupAcc = mapDupAccById.get(dupAccId);
                                                
                                                childRecord.put(accFieldName, dupAcc.Primary_Account_ID__c);
                                            }
                                        } else if(String.isNotBlank(conFieldName)){

                                            dupConId = (Id)childRecord.get(conFieldName);
                                            dupAccId = mapDupConToDupAccIds.get(dupConId);
                                            dupAcc   = mapDupAccById.get( dupAccId );
                                            mapChildRecToOldParent.put((Id)childRecord.get('Id'), dupAccId );
                                            childRecord.put(accFieldName, dupAcc.Primary_Account_ID__c);
                                            childRecord.put(conFieldName, primaryAccAndContactIds.get(dupAcc.Primary_Account_ID__c ));
                                        }    
                                                              
                                    } //END >> if(obj has account lookup field)

                                    System.debug('@@@ dupAcc =' + dupAcc);
                                    if(String.isNotBlank(conFieldName)){
                                        if(dupAcc == null) {
                                            dupConId = (Id)childRecord.get(conFieldName);
                                            dupAccId = mapDupConToDupAccIds.get(dupConId);
                                            dupAcc   = mapDupAccById.get( dupAccId );
                                            mapChildRecToOldParent.put((Id)childRecord.get('Id'), dupAccId ); 
                                            System.debug('@@@ dupAcc =' + dupAcc);
                                        }
                                        childRecord.put(conFieldName, primaryAccAndContactIds.get(dupAcc.Primary_Account_ID__c ));
                                    }            
                                    
                                }
                                //dml update
                                updateChildRecords(childList);
                            }
                        }                        
                    }
                }           
                
                System.debug('@@@@DEBUG PersonAccountMergingBatch >> bigDataChildObjs: ' + bigDataChildObjs);
                System.debug('@@@@DEBUG PersonAccountMergingBatch >> dupAccIds: ' + dupAccIds);
                if(bigDataChildObjs != null && bigDataChildObjs.size() > 0 && dupAccIds.size() > 0){
                    chainAnotherBatch = true; 
                }
                


            } catch(Exception ex){
                System.debug('@@@@DEBUG PersonAccountMergingBatch >> Exception: ' + ex);
                System.debug('Message: ' + ex.getMessage() + '. At line: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() );
                errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
                loggerDataPool.buildLogDataPool('PersonAccountMergingBatch', ex);
            }
        
        }        
        
    }

    global void finish(Database.BatchableContext bc){
        PersonAccountMergingService.bypassAutomation(false);
        System.debug('PersonAccountMergingBatch.finish() chainAnotherBatch = ' + chainAnotherBatch);
        if(chainAnotherBatch){
            Database.executeBatch(new PersonAccountChildMergingBatch(bigDataChildObjs, mapDupAccById.keySet()));        
                
        } else {
            System.debug('duplicated PAs to remove = ' + mapDupAccById.size() + ' = ' + mapDupAccById);                    
            Database.DeleteResult[] deleteResults = Database.delete(mapDupAccById.values(), false);
            for(Integer index = 0, size = deleteResults.size(); index < size; index++) {
                if(!deleteResults[index].isSuccess()) {
                    Database.Error[] errors = deleteResults[index].getErrors();
                    Id failedRecordId = deleteResults[index].getId();

                    Logger_Data_Pool__c log = new Logger_Data_Pool__c();
                    log.Instance__c = 'PersonAccountMergingBatch';
                    log.Name = (String)failedRecordId;
                    log.Type__c = 'System.DmlException';
                    log.Message__c     = errors[0].getMessage() + '. \n';
                    log.Stack_Trace__c = errors[0].getFields() + '. \n';
                    log.Cause__c       = errors[0].getStatusCode() + '. \n';
                    errorLogs.add(log);
                }
            }
            
            if(errorLogs.size() > 0 ) {
                insert errorLogs;
            }            
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'khanh.do@aodigy.com', 'thieudang.vu@aodigy.com'}; 
        mail.setToAddresses( toAddresses );
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.saveAsActivity = false;
        mail.setSubject('PersonAccountMergingBatch Run Result - ' + Datetime.now());
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i = 0; i < errMsgs.size(); i++){
                body = 'PersonAccountMergingBatch Got Exception !!!\n';
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }
        } 
        else{            
            body = 'PersonAccountMergingBatch Processed Successfully !!!\n';
        }

        if(results.size() > 0) {
            for(String obj: results.keySet()){                
                body += 'Number ' + obj + ' processed :: ' + results.get(obj) + '\r\n';
            }
            if(bigDataChildObjs.size() > 0) {
                body += 'System is processing child object(s) which have huge number of records. Please wait until it is finished \r\n';
            }
        }
            
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }

    private void updateChildRecords(List<SObject> childList) {
        if(childList != null && childList.size() > 0) {
            Database.SaveResult[] results = Database.update(childList, false); //allow partial update                

            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(!results[index].isSuccess()) {
                    Database.Error[] errors = results[index].getErrors();

                    SObject failedRecord = childList[index];                           
                    String failedAccId = mapChildRecToOldParent.get( (String)failedRecord.get('Id') );
                    if(String.isNotBlank(failedAccId) && mapDupAccById.containsKey(failedAccId)) {
                        mapDupAccById.remove(failedAccId); //If reparent child failed, NOT delete that duplicate parent Account
                    }                            
                    Logger_Data_Pool__c log = new Logger_Data_Pool__c();
                    log.Instance__c = 'PersonAccountMergingBatch';
                    log.Name = (String)failedRecord.get('Id');
                    log.Type__c = 'System.DmlException';
                    log.Message__c     = errors[0].getMessage() + '. \n';
                    log.Stack_Trace__c = errors[0].getFields() + '. \n';
                    log.Cause__c       = errors[0].getStatusCode() + '. \n';
                    errorLogs.add(log);                           
                    
                }
            }
        }
    }
}