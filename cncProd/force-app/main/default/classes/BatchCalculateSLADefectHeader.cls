global class BatchCalculateSLADefectHeader implements Database.Batchable<sObject>{
    global static Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Customer_Acknowledgement_Date__c, SLA_Days__c, CreatedDate
                                         FROM Defect_Header__c
                                         WHERE Customer_Acknowledgement_Date__c = null]);
    }

    global void execute(Database.BatchableContext bc, List<Defect_Header__c> records) {
        system.debug('***** START EXECUTION *****');
        // Get NOW()
        datetime currentDateTime = datetime.now();
        List<Defect_Header__c> defectHeadersToBeUpdated = new List<Defect_Header__c>();
        for (Defect_Header__c dh : records) {
            // Calculate SLA (Days) based on business hours
            // Hours between 0 to 9.5 = 1 day
            // Hours between 9.5 to 19 = 2 day
            // So on...
            dh.SLA_Days__c = ((BusinessHoursUtility.GetBusinessHrs(dh.CreatedDate, currentDateTime) / 3600000) / 9.5).round(System.RoundingMode.CEILING);
            defectHeadersToBeUpdated.add(dh);
        }
        system.debug('DHs::' + defectHeadersToBeUpdated);
        try {
            Database.update(defectHeadersToBeUpdated, false);
        } catch(Exception e) {
            loggerDataPool.buildLogDataPool('BatchCalculateSLADefectHeader', e);
		}
    }

    global void finish(Database.BatchableContext bc) {
        batchDataPool.buildBatchDataPool('BatchCalculateSLADefectHeader', bc.getJobId());
    }
}