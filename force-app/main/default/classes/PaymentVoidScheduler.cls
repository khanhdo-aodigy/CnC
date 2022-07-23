/******************************************************
 * Class Name: PaymentVoidScheduler
 * Description: Payment scheduler for updating Transaction Type to void.
 * 				For payment records associcated to Campaigns with Type = Promotions.
 * 			
 ******************************************************/
public class PaymentVoidScheduler implements Database.Batchable<sObject>, Schedulable{
    
    
    public void execute(SchedulableContext cx){
        //Get at least one Payment Records with Transaction Id is null and Campaign Id is present
        //This will determine if batch will run
        List<Invoice__c> invList = new List<Invoice__c>();
        invList = [SELECT Id, Remarks__c, Transaction_Type__c
                   FROM Invoice__c 
                   WHERE Transaction_ID__c = null 
                   AND Transaction_Type__c != 'Void'
                   AND Campaign__c != null
                   AND Campaign__r.Type = 'Promotions' 
                   LIMIT 1];
        
        if(invList!=null && !invList.isEmpty()){
            Database.executeBatch( new PaymentVoidScheduler() );
        }
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext db){
        return Database.getQueryLocator([SELECT Id, Remarks__c, Transaction_Type__c 
                                         FROM Invoice__c 
                                         WHERE Transaction_ID__c = null 
                                         AND Transaction_Type__c != 'Void'
                                         AND Campaign__c != null
                                         AND Campaign__r.Type = 'Promotions' 
                                        ]);
    }
    
    public void execute(Database.BatchableContext db, List<Invoice__c> scope){
        for(Invoice__c inv : scope){
            inv.Transaction_Type__c = Constants.STAT_VOID;
            inv.Remarks__c = Label.PaymentVoided;
        }
        Database.update (scope, false);
    }
	
    public void finish(Database.BatchableContext db){
		//Do not create logs for Batch data pool
    }
}