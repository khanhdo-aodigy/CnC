/****************************************************
* Class Name: Batch_MITSTOCKReservationToSold
* Description: Initial class. run for one month VSMS.
****************************************************/ 
public without sharing class Batch_MITSTOCKReservationToSold implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext db){
        List<String> comCases = new List<String>();
        
        for(MIT_ComCaseToPatch__c mc : [SELECT Id, Name FROM MIT_ComCaseToPatch__c]){
        	comCases.add(mc.Name);
        }
        return Database.getQueryLocator([SELECT Id, Vehicle_Status__c FROM Vehicle_Master2__c WHERE System_Commcase__c IN: comCases]);
    }
    
    public void execute(Database.BatchableContext db, List<Vehicle_Master2__c> scope){
        if(scope != null && !scope.isEmpty()){
            try{
                for(Vehicle_Master2__c vStat : scope){
                    vStat.Vehicle_Status__c = 'SOLD';
                }
                update scope;
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('Batch_MITSTOCKReservationToSold', e);
            }

        }     
    }
    
    public void finish(Database.BatchableContext db){
        batchDataPool.buildBatchDataPool('Batch_MITSTOCKReservationToSold', db.getJobId());
    }
    

    //execute Schedule
    public void execute (SchedulableContext ctx){   
      Database.executeBatch(new Batch_MITSTOCKReservationToSold());
    }
}