global with sharing class MB_BatchSVMSpecHighlightOptions implements Database.Batchable<sObject> {
    global static Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([   // query
                                            SELECT ID, MB_Stock_Vehicle_Master__c, SVM_Spec_Compared_ID__c, Description__c, Build_Spec_Comparison__c
                                            FROM MB_SVM_Spec__c
                                            WHERE MB_Stock_Vehicle_Master__c != null AND MB_Stock_Vehicle_Master__r.Batch_Processed__c = false 
            									  AND MB_Stock_Vehicle_Master__r.hasHighlightOptions__c = false
                                        ]);
    }

    global void execute(Database.BatchableContext bc, List<MB_SVM_Spec__c> records) {
        // Call service method to update MB SVMs accordingly
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MBHighlightOptionsService.getStocksForBatchSVMSpec(records);
        try {
            Database.update(mbSVMs, false);
        } catch(Exception e) {
            loggerDataPool.buildLogDataPool('MBBatchSVMSpecHighlightOptions', e);
		}
    }

    global void finish(Database.BatchableContext bc) {
        batchDataPool.buildBatchDataPool('MBBatchSVMSpecHighlightOptions', bc.getJobId());
    }
}