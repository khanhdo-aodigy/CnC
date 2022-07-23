/****************************************************
* Class Name: BatchDeactivateServicePackage
* Description: Batch class to set the 
*			   Service Package Status__c to Inactive
* 
****************************************************/ 
public class BatchDeactivateServicePackage implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{

    //
    public Database.QueryLocator start(Database.BatchableContext db){
        return Database.getQueryLocator([SELECT 
        									Id, 
                                         	Status__c
                                         FROM Service_Packages__c
                                         WHERE Registered_Vehicle__c != null
                                         AND Registered_Vehicle__r.IsOwnerChanged__c = true
                                         AND Registered_Vehicle__r.OwnerChangeTimeStamp__c = TODAY 
                                         ]);
    }
    
    public void execute(Database.BatchableContext db, List<Service_Packages__c> scope){
        if(scope != null && !scope.isEmpty()){
            try{
                for(Service_Packages__c sPack : scope){
                    sPack.Status__c = 'Inactive';
                }
                
                update scope;
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('BatchDeactivateServicePackage', e);
            }

        }     
    }
    
    public void finish(Database.BatchableContext db){
        batchDataPool.buildBatchDataPool('BatchDeactivateServicePackage', db.getJobId());
    }
    
    
    //execute Schedule
    public void execute (SchedulableContext ctx){   
        //Set Initial Test Run
        //Batch Set to Run at Default Batch Size.
        try{
            BatchManager bm = new BatchManager('BatchDeactivateServicePackage',null);
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('BatchDeactivateServicePackage', e);
        }
        
    }     
}