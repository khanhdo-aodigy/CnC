/****************************************************
* Class Name: BatchDeleteLeadShareRecord 
* Description: Deletes share record for converted leads
*
* Developer Name    Date      Description
* Savita          24-May-2019    Created.
****************************************************/ 

global class BatchDeleteLeadShareRecord implements Database.Batchable<sObject>,Schedulable
{
    public String queryString = '';
    public String batchForDataPool = '';
  
    public BatchDeleteLeadShareRecord(){
        batchForDataPool = 'BatchDeleteLeadShareRecord';
        queryString = Queries.delShareRecQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator(queryString);
    }
    
    global void Execute(Database.BatchableContext bc, list<Share__c> delShareList){
        delete delShareList;
    }
    
    global void finish(Database.BatchableContext bc){
       batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());
    }
    
    global void execute(SchedulableContext sc){
        new BatchManager('BatchDeleteLeadShareRecord', null);
    }
}