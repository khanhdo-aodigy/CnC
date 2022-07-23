/*
	Author: Hari Panneerselvam
*/
global class BatchToUpdateSRToVSMS implements Database.Batchable<sObject>, Database.AllowsCallouts{
	 
	public String queryString = '';
	public String batchForDataPool = '';
	
	public BatchToUpdateSRToVSMS(String batchFor){
		batchForDataPool = batchFor;
		queryString = Queries.updateSRToVSMS;
	}
	 
	global Database.QueryLocator start(Database.BatchableContext bc){
		return database.getQueryLocator(queryString);
	}
	
	global void execute(Database.BatchableContext bc, list<Stock_Reservation__c> lstStockReservation){
		for(Stock_Reservation__c itr : lstStockReservation){
			itr.Re_Reserve_To_VSMS__c = false;
			BusinessRuleHandlerVSMS.isBatchCall = true;
			BusinessRuleHandlerVSMS.updateStockVSMS(itr.Id, itr.Opportunity__r.Owner.Username2__c, false); 
		}
		update lstStockReservation;
	}
	 
	global void finish(Database.BatchableContext bc){
    	batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());
    }
    
}