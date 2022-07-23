global class BatchReferralProgram implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    
     
    global Database.QueryLocator start(Database.BatchableContext db){
        Date dt = Date.today() - 5;
        
        return Database.getQueryLocator([SELECT Id, Registered_Date__c, Reg_plus_5days__c FROM Registered_Vehicle__c WHERE Registered_Date__c =: dt ]);
                                         //LAST_N_DAYS:5]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Registered_Vehicle__c> scope)
    {
        for(Registered_Vehicle__c v: scope){
            v.Reg_plus_5days__c = true;
        }
        
        update scope;
        //Database.update(scope , false); 
        
        //DML
        /*
        try{
            Database.update(scope , false); 
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('BatchReferralProgram', e);
        }
*/
        
    }  
    
    global void finish(Database.BatchableContext BC)
    {
    }
}