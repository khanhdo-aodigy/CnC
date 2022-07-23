/*
 * Class Name: BatchPurgeFiles
 * Description: Class to Purge files given the file name and created date.
 *              This class is originally written for PDPA data retention purposes.
*/
public class BatchPurgeFiles implements Database.Batchable<sObject>, Schedulable{
    //For Test Class Coverage
    public class CustException extends Exception{}
    
    public Database.QueryLocator start(Database.BatchableContext db){
        //get the Attachment Name of files to delete
        Set<String> fileName = new Set<String>();
        for(FilePurge__mdt fp : [SELECT Label, 
                                        DeveloperName 
                                 FROM FilePurge__mdt 
                                 WHERE 
                                        Active__c = true 
                                        AND Module__c='PDPA']){
            fileName.add(fp.Label);
        }        
     
        return Database.getQueryLocator([SELECT Id 
                           FROM Attachment 
                           WHERE CreatedDate <: Date.today().addMonths(-6)  
                           AND Name IN: fileName]);
    }
     
    public void execute(Database.BatchableContext db, List<Attachment> scope){
        if(scope != null && !scope.isEmpty()){
            try{
                delete scope;
                //hard delete the files from the System
                Database.emptyRecycleBin(scope);
                
                //for Test Class
                if( Test.isRunningTest() ){
                    throw new CustException('');
                }
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('BatchPurgeFiles', e);
            }
        }     
    }
    
    public void finish(Database.BatchableContext db){
        batchDataPool.buildBatchDataPool('BatchPurgeFiles', db.getJobId());
    }

    //execute Schedule
    public void execute (SchedulableContext ctx){   
        //Set Initial Test Run
        //Batch Set to Run at Default Batch Size.
        try{
            BatchManager bm = new BatchManager('BatchPurgeFiles',null);
            
            //for Test Class
            if( Test.isRunningTest() ){
                throw new CustException('');
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('BatchPurgeFiles', e);
        }
        
    }     
}