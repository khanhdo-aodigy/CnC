/*
    Author: Hari Panneerselvam
    Description: This is a master class used to decide which batch to execute. *****All batch jobs should fire only from this class.*****
*/
public class BatchManager {
    
    public BatchManager(String batchName, JSONGenerator jsonParameter){
        list<BatchRegistry__mdt> batchRegistry = new list<BatchRegistry__mdt>();
        batchRegistry = [select DeveloperName, BatchSize__c from BatchRegistry__mdt where DeveloperName = :batchName and IsActive__c = true];
        map<String, Object> mapBatchParameter = new map<String, Object>();
        
        if(jsonParameter != null && jsonParameter.getAsString() != null && jsonParameter.getAsString() != ''){
            mapBatchParameter = (map<String, Object>)JSON.deserializeUntyped(jsonParameter.getAsString());
        }
        
        if(batchRegistry != null && batchRegistry.size() > 0){                     
            
            if(batchRegistry[0].DeveloperName == 'BatchToReReserveStockReservation'){ 
                Database.executeBatch(new BatchToReReserveStockReservation('BatchToReReserveStockReservation'));
            }
            if(batchRegistry[0].DeveloperName == 'BatchToUpdateSRToVSMS'){
                Database.executeBatch(new BatchToUpdateSRToVSMS('BatchToUpdateSRToVSMS'));
                //system.enqueueJob(new BatchToUpdateSRToVSMS('BatchToUpdateSRToVSMS'));
            }
            
            if(batchRegistry[0].DeveloperName == 'BatchSendTestDriveNoShowEmail'){
                Database.executeBatch( new BatchSendTestDriveNoShowEmail(), Integer.valueOf(batchRegistry.get(0).BatchSize__c) );
            }
            
            if(batchRegistry[0].DeveloperName == 'BatchDeactivateServicePackage'){
                Database.executeBatch( new BatchDeactivateServicePackage(), Integer.valueOf(batchRegistry.get(0).BatchSize__c) );
            }  
            
            if(batchRegistry[0].DeveloperName == 'BatchLeadToContactConverter'){ 
               Database.executeBatch(new BatchLeadToContactConverter(),Integer.valueOf(batchRegistry.get(0).BatchSize__c));
            }             
            
            if(batchRegistry[0].DeveloperName == 'Opportunity_Closed_6Month_Scheduler'){ 
               Database.executeBatch(new Opportunity_Closed_6Month_Scheduler(),Integer.valueOf(batchRegistry.get(0).BatchSize__c));
            }  
            
            if(batchRegistry[0].DeveloperName == 'BatchPurgeFiles'){ 
                Database.executeBatch(new BatchPurgeFiles(),Integer.valueOf(batchRegistry.get(0).BatchSize__c));
            }  
            
            if(batchRegistry[0].DeveloperName == 'BatchUpdateUserNRIC'){ 
                Database.executeBatch(new BatchUpdateUserNRIC(),Integer.valueOf(batchRegistry.get(0).BatchSize__c));
            }    
        }
    }
    
}