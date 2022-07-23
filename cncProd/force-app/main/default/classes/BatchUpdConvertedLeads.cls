/****************************************************
* Class Name: BatchUpdConvertedLeads 
* Description: Populates newly converted contact on open opps upon lead conversion
*
* Developer Name    Date      Description
* Savita          24-May-2019    Created.
****************************************************/ 

global class BatchUpdConvertedLeads implements Database.Batchable<sObject>,Schedulable
{
    public String queryString = '';
    public String batchForDataPool = '';
  
    public BatchUpdConvertedLeads(){
        batchForDataPool = 'BatchUpdConvertedLeads';
        queryString = Queries.OppforConQuery ;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    return database.getQueryLocator(queryString);
    }
    
    global void Execute(Database.BatchableContext bc, List<Opportunity> oppList){
        List<Opportunity> oppUpdList = new List<Opportunity>();
        for(Opportunity opp : oppList){
            if(opp.lead__r.isConverted == true && opp.lead__r.convertedContactId!=null){
                opp.Contact_Person__c = opp.lead__r.convertedContactId;
                oppUpdList.add(opp);
            }
        }
        if(!oppUpdList.IsEmpty()){
            TriggerExclusion.excludeTrigger('Opportunity', true);
            update oppUpdList;
            TriggerExclusion.excludeTrigger('Opportunity', false);
        }
    }
    
    global void finish(Database.BatchableContext bc){
       batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());
    }
    
    global void execute(SchedulableContext sc){
        new BatchManager('BatchUpdConvertedLeads', null);
    }
}