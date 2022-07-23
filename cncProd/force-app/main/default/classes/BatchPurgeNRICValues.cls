/**************************************************
 * Class Name: BatchPurgeNRICValues
 * Description: Schduler class to Purge NRIC Values
 * 
 * Revision History:
 * Developer Name		Date			Description
 * CGaylan				28-06-2019		Created.
 * Khanh.Do				01-11-2021		Added Removing Files under Test drives.
 **************************************************/ 
public class BatchPurgeNRICValues implements Database.Batchable<sObject>, Database.Stateful {
    //For Test Class Coverage
    public class CustException extends Exception{}
    
    public List<String> sObjName;
	public Integer processRun = 0;
    public Id recordId;
    
    /*
     * Constructor
     * Parameters: 
     * 			List<String> sObjAPIName - List of SObj API Names to Process
     * 			Integer run - Index of the current SObject to process
     */ 
    public BatchPurgeNRICValues(List<String> sObjAPIName , Integer run){
        sObjName = new List<String>();
		sObjName = sObjAPIName;
        processRun = run; 
    }

    //For testing purpose
    public BatchPurgeNRICValues(String sObjAPIName , Id recordId){
        this.sObjName = new List<String>{sObjAPIName};
        this.recordId = recordId;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext db){
        Date endDate = Date.today().addMonths(-6);
        // Date endDate = Date.today(); //For testing
        String qStr = '';
        if(sObjName != null && !sObjName.isEmpty()){
            qStr = SchedulePurgeNRICValues.getQueryString(sObjName.get(processRun));
        }

        if(String.isNotBlank(recordId)) {
            qStr += ' AND Id = :recordId';
        }
        System.debug('qStr = ' + qStr);
        return Database.getQueryLocator( qStr );
    }
    
    public void execute(Database.BatchableContext db, List<SObject> scope){
        if( scope != null && !scope.isEmpty() ){
            String sType = String.valueOf( scope.get(0).getSObjectType() );

            Set<Id> recordIds = new Set<Id>();
            Map<Id, Attachment> attachments = new Map<Id, Attachment>();
            Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>();
            Map<Id, ContentDocumentLink> contentDocumentLinks = new Map<Id, ContentDocumentLink>(); 
            
            //CGaylan: Dynamic DML is not used due to run-time consideration
            //This batch runs on Stateful context which also eats up heap size
            try{
                switch on sType{
                    when 'Invoice__c'{
                        TriggerExclusion.excludeTrigger('Payment', true);
                        for( Invoice__c inv : (List<Invoice__c>) scope ){
                            inv.NRIC__c = '';
                        }
                    }
                    when 'Opportunity'{
                        TriggerExclusion.excludeTrigger('Opportunity', true);
                        for( Opportunity op : (List<Opportunity>) scope ){
                            op.NRIC__c = '';
                        }
                    }
                    when 'Test_Drive__c'{
                        TriggerExclusion.excludeTrigger('Test_Drive__c', true);
                        for( Test_Drive__c td : (List<Test_Drive__c>) scope ){
                            td.NRIC__c = '';
                            recordIds.add(td.Id);
                        }
                    }
                    when 'Stock_Reservation__c'{
                        TriggerExclusion.excludeTrigger('Stock_Reservation__c', true);
                        for( Stock_Reservation__c sr : (List<Stock_Reservation__c>)  scope){
                            sr.Customer_Social_ID__c = '';                        
                        }
                    }

                    // Vehicle_Request__c is new object. This portion will be uncommented and deploy later
                    // when 'SchedulePurgeNRICValues'{
                    //     TriggerExclusion.excludeTrigger('Vehicle_Request__c', true);
                    //     for( Vehicle_Request__c vehicleRequest : (List<Vehicle_Request__c>) scope ){
                    //         vehicleRequest.Customer_NRIC__c = '';
                    //         recordIds.add(vehicleRequest.Id);
                    //     }
                    // }
                }
                System.debug('scope = ' + scope);
                Database.update(scope, false);

                if(recordIds != null && recordIds.size() > 0){
                    purgeFiles(recordIds);
                }
                
                //Re-activate the trigger to fire
                TriggerExclusion.excludeTrigger('Payment', false);
                TriggerExclusion.excludeTrigger('Opportunity', false);
                TriggerExclusion.excludeTrigger('TestDrive', false);
                TriggerExclusion.excludeTrigger('Stock Reservation', false);
                // TriggerExclusion.excludeTrigger('Vehicle_Request__c', false); // Vehicle_Request__c is new object. This portion will be uncommented and deploy later
                
                //for Test Class
                if( Test.isRunningTest() ){
                    throw new CustException('');
                }
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('BatchPurgeNRICValues.'+ sType , e);
            }
        }
    }
    
    private static void purgeFiles(Set<Id> parentIds){
        try{
            Map<Id, Attachment> attachments = new Map<Id, Attachment>([ SELECT Id, ParentId
                                                                        FROM Attachment
                                                                        WHERE ParentId IN :parentIds
                                                                        AND (NOT Name LIKE '%IndemnityForm%')
                                                                    ]);

            Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([  SELECT Id, Title, ParentId
                                                                                        FROM ContentDocument
                                                                                        WHERE ParentId IN :parentIds
                                                                                        OR LatestPublishedVersion.FirstPublishLocationId IN :parentIds
                                                                                    ]);                                                                                   

            Map<Id, ContentDocumentLink> contentDocumentLinks = new Map<Id, ContentDocumentLink>([  SELECT Id
                                                                                                    FROM ContentDocumentLink
                                                                                                    WHERE LinkedEntityId IN :parentIds
                                                                                                ]);     
                                                                                            
                                                                                            
            System.debug('attachments = ' + attachments);
            if(attachments != null && attachments.size() > 0) {
                Database.delete(new List<Id>(attachments.keySet()), false);
            }

            System.debug('contentDocuments = ' + contentDocuments);
            if(contentDocuments != null && contentDocuments.size() > 0) {
                Database.delete(new List<Id>(contentDocuments.keySet()), false);
            }
                    
            System.debug('contentDocumentLinks = ' + contentDocumentLinks);
            if(contentDocumentLinks != null && contentDocumentLinks.size() > 0) {
                Database.delete(new List<Id>(contentDocumentLinks.keySet()), false);
            }
        } catch(Exception ex){            
            System.debug('BatchPurgeNRICValues.purgeFiles()' + ex);
            loggerDataPool.buildLogDataPool('BatchPurgeNRICValues.', ex);
        }



    }
    
    public void finish(Database.BatchableContext db){
        //increment List index
        processRun++;
        
        //log the Batch Execution
        batchDataPool.buildBatchDataPool('BatchPurgeNRICValues', db.getJobId());
        
        //process other SObjects
        if( processRun  < sObjName.size() ){
            Database.executeBatch( new BatchPurgeNRICValues( sObjName, processRun ) );
        }
        
    }
}