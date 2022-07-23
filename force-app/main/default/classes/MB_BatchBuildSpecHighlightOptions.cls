global with sharing class MB_BatchBuildSpecHighlightOptions implements Database.Batchable<sObject> {
    global static Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([   // query MB Build Spec
                                            SELECT ID, Build_Spec_Compared_ID__c, Highlight_Option__c, Batch_Processed__c, MB_Build_Spec_ID__c
                                            FROM MB_Build_Spec__c
                                            WHERE Batch_Processed__c = false
                                        ]);
    }

    global void execute(Database.BatchableContext bc, List<MB_Build_Spec__c> records) {
        Map<String, Boolean> comparedBuildSpecIds = new Map<String, Boolean>();
        for (MB_Build_Spec__c spec : records) {
            comparedBuildSpecIds.put(spec.MB_Build_Spec_ID__c, spec.Highlight_Option__c);
        }
        // Call service method to update MB SVMs accordingly
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MBHighlightOptionsService.getStocksForBatchBuildSpec(comparedBuildSpecIds);
        try {
            Database.update(mbSVMs, false);
        } catch(Exception e) {
            loggerDataPool.buildLogDataPool('MBBatchBuildSpecHighlightOptions', e);
		}
    }

    global void finish(Database.BatchableContext bc) {
        // After finishing batch, query all MB Build Spec that has been processed
        // Set Batch_Processed__c checkbox field to false again for the next time to process
        List<MB_Build_Spec__c> specs = new List<MB_Build_Spec__c>();
        for (MB_Build_Spec__c spec : [SELECT ID, MB_Build_Spec_ID__c, Highlight_Option__c, Batch_Processed__c
                                      FROM MB_Build_Spec__c
                                      WHERE Batch_Processed__c = false]) {
                                        spec.Batch_Processed__c = true;
                                        specs.add(spec);
        }
        try {
            update specs;
        } catch (Exception e) {
            loggerDataPool.buildLogDataPool('MBBatchBuildSpecHighlightOptions', e);
        }
        batchDataPool.buildBatchDataPool('MBBatchBuildSpecHighlightOptions', bc.getJobId());
    }
}