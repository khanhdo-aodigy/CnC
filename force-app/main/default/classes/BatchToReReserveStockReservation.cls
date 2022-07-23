/*
	Author: Hari Panneerselvam
*/
global class BatchToReReserveStockReservation implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
	
	public String queryString = '';
	public String batchForDataPool = '';
	
	public BatchToReReserveStockReservation(String batchFor){
		batchForDataPool = batchFor;
		queryString = Queries.reReserveStockReservation;
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc){
		return database.getQueryLocator(queryString);
	}
	 
	global void execute(Database.BatchableContext bc, list<Stock_Reservation__c> lstStockReservation){ 
		for(Stock_Reservation__c itr : lstStockReservation){
			itr.Reservation_Status__c = 'Reserve';
			itr.Cancellation_Reason__c = '';
			itr.Re_Reserve_To_VSMS__c = true;
		}
		update lstStockReservation; 
	}
	
	global void finish(Database.BatchableContext bc){
		JSONGenerator jsonGen = JSON.createGenerator(true);//Pass empty JSON if parameter is not required.
		new BatchManager('BatchToUpdateSRToVSMS', jsonGen);
    	batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());
    }
    
    global void execute(SchedulableContext sc){
	 	JSONGenerator jsonGen = JSON.createGenerator(true);//Pass empty JSON if parameter is not required.
        new BatchManager('BatchToReReserveStockReservation', jsonGen);
	}
    
}