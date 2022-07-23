/*
	Author: Hari Panneerselvam
*/
public class batchDataPool {
	
	public static void buildBatchDataPool(String batchName, Id jobId){ 
        AsyncApexJob asyncApexjob = [Select Id, ApexClassID, CompletedDate, JobType, MethodName, Status, NumberOfErrors, JobItemsProcessed, 
                                        TotalJobItems, ExtendedStatus from AsyncApexJob where Id = :jobId];
        ApexClass apexClass = [select Id, Name from ApexClass where Id = :asyncApexjob.ApexClassID];
        
        BatchDataPool__c newBatchDataPool = new BatchDataPool__c();
        newBatchDataPool.Batch_Name__c = batchName;
        newBatchDataPool.Job_Id__c = String.valueOf(asyncApexjob.Id).subString(0, 15);
        newBatchDataPool.Job_Status__c = asyncApexjob.Status;
        newBatchDataPool.Job_Type__c = asyncApexjob.JobType;
        newBatchDataPool.Extended_Status__c = asyncApexjob.ExtendedStatus;
        newBatchDataPool.ApexClass__c = apexClass.Name;
        newBatchDataPool.Total_Batches__c = asyncApexjob.TotalJobItems;
        newBatchDataPool.Batches_Processed__c = asyncApexjob.JobItemsProcessed;
        newBatchDataPool.Failures__c = asyncApexjob.NumberOfErrors;
        insert newBatchDataPool;
    }
    
}