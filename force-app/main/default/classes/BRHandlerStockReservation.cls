/**************************************************
 * Class Name: BRHandlerStockReservation
 * Description: Business Rule Handler class for StockReservation Trigger
 * 
 * Revision History:
 * Developer Name		Date			Description
 * CGaylan				27-06-2019		Refactored.
 **************************************************/ 
public class BRHandlerStockReservation {
    
    //for storing Trigger Handler context
	TriggerHandlerStockReservation srev;
    
    //constructor
    public BRHandlerStockReservation(TriggerHandlerStockReservation srevTH){
        srev = srevTH;
    }
    
    /**************************************************
     * Method Name: srAfterUpdate
     * Description: Business Rule Handler for After Update logic
     * 
     * Revision History:
     * Developer Name		Date			Description
     * CGaylan				27-06-2019		Refactored.
     * Phap Mai             27-08-2020      Update srAfterUpdate method to notify financing company when vehicle master change (CHANGE-1). The new code is wrapped in try catch to not affect current process.
     **************************************************/ 
    public void srAfterUpdate(){

        // [CHANGE-1]
        try {
            List<Stock_Reservation__c> changedRecords = getChangedRecords(new Set<String> { 'Vehicle_Master__c' });

            // get Sales Agreement that look up to changed records
            Set<ID> srIDs = sliceID(changedRecords);
            List<Sales_Agreement__c> agreements = [SELECT EngineNo__c, Chassis_No__c, Finance_Company_In_House__c, Finance_Company_Lookup__c, 
                                                   Emailed_BAM__c, Registration_Type__c, Branch_Code__c
                                                   FROM Sales_Agreement__c
                                                   WHERE Stock_Reservation__c IN :srIDs];
            
            if (agreements.size() > 0) {

                List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();            // list of emails to be sent now
                EmailTemplate template = EmailNotificationsService.getTemplate('Finance_Email');                    // email template
                Set<ID> processedIDs = new Set<ID>();                                                               // store ID of processed records
                Set<String> otherErrors = new Set<String>();                                                        // store info of error records beside sending error

                for (Sales_Agreement__c record : agreements) {
                    try {

                        if (record.EngineNo__c ==  null || record.Chassis_No__c == null) continue;                  // dont send empty Engine/Chassis No
                        if (!record.Finance_Company_In_House__c) continue;                                          // dont send to non-inhouse BAM
                        if (record.Finance_Company_Lookup__c == null) continue;                                     // dont send if have no financing company
                        if (!record.Emailed_BAM__c) continue;                                                       // only send the update if FIRST email has been sent
                        
                        Messaging.SingleEmailMessage email = EmailNotificationsService.renderFinanceEmail(record, template.Id);     // render template
                        if (email == null) continue;
                        allEmails.add(email);                                                                       // add to emailing list
                        processedIDs.add(record.ID);                                                                // add processed ID for logging

                        // begin sending emails
                        if (allEmails.size() > 0) {
            
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(allEmails, false);
                
                            Set<String> sendingErrors = new Set<String>();
                
                            for (Messaging.SendEmailResult result : results) {
                                if (!result.isSuccess()) {
                                    for (Messaging.SendEmailError e : result.getErrors()) {
                                        sendingErrors.add(e.getMessage());
                                    }
                                }
                            }
                
                            if (sendingErrors.size() > 0) {
                                try {
                                    Logger_Data_Pool__c log = new Logger_Data_Pool__c();
                                    log.Instance__c = 'notifyBAM_SendingError';
                                    log.Message__c = JSON.serialize(sendingErrors) + ' <<<< |||| >>>> ' + JSON.serialize(processedIDs);
                                    insert log;
                                } catch (Exception e1) {
                                    // fail silent
                                }
                            }
                        }
                    } catch (Exception e2) {        // fail silent to make sure the rest of triggered record still process
                        System.debug('Error on process vMaster change (record) :: ' + JSON.serialize(record));
                        System.debug('Error on process vMaster change (message) :: ' + e2.getMessage());
                        System.debug('Error on process vMaster change (stack trace) :: ' + e2.getStackTraceString());
                        otherErrors.add('[ERROR] ID :: ' + record.ID + ', message ::' + e2.getMessage() + ', stack trace :: ' + e2.getStackTraceString());
                    }
                }

                // log other errors
                if (otherErrors.size() > 0) {
                    try {
                        Logger_Data_Pool__c log2 = new Logger_Data_Pool__c();
                        log2.Instance__c = 'notifyBAM_OtherError';
                        log2.Message__c = JSON.serialize(otherErrors);
                        insert log2;
                    } catch (Exception e3) {
                        // fail silent
                    }
                }
            }
        } catch (Exception e4) {
            System.debug('Error message on notify BAM :: ' + e4.getMessage());
            System.debug('Error stack on notify BAM :: ' + e4.getStackTraceString());
            try {
                loggerDataPool.buildLogDataPool('notifyBAM_OtherError', e4);
            } catch (Exception e5) {
                // fail silent to not affect current process
            }
        }
        // END [CHANGE-1]


        List<Vehicle_Master2__c> vmToUpdate = new List<Vehicle_Master2__c>();
        List<Opportunity> oppToUpdate = New List<Opportunity>();
        
        for (Stock_Reservation__c sr : srev.srTrigNew){
            
             if(sr.Reservation_Status__c == 'Print' && srev.srOldMap.get(sr.ID).Reservation_Status__c == 'Reserve'
               && (sr.Opportunity_Status__c == 'Open' || sr.Opportunity_Status__c == 'Contacted' || sr.Opportunity_Status__c == 'Test Driven')
               && sr.Opportunity_Status__c != 'Stock Reserved')
             {
                 oppToUpdate.add(New Opportunity(ID=sr.Opportunity__c, StageName='Stock Reserved', Date_of_Stock_Reservation__c=Date.Today()));
             }
             
             //get all cancelled stock reservations
             //consolidate all cancelled reservation
             //and update parent Vehicle Master
             if( sr.Vehicle_Master__c != null 
                && Constants.CANCEL == sr.Reservation_Status__c
                && srev.srOldMap.get(sr.Id).Reservation_Status__c != Constants.CANCEL)
             {
                 vmToUpdate.add( new Vehicle_Master2__c(Id=sr.Vehicle_Master__c, Reservation_No__c='') );
				 
				 //Code was modified for Oppty standardisation --> NSJ
				 Opportunity updateOppty = new Opportunity(Id = sr.Opportunity__c);
				 updateOppty.StageName = 'Open';
				 oppToUpdate.add(updateOppty);
             }
        }
        
        if(!vmToUpdate.isEmpty()){
            try{
                update vmToUpdate;
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('BRHandlerStockReservation.srAfterUpdate', e);
            }
        }
        
        if(!oppToUpdate.isEmpty()){
            try{
                update oppToUpdate;
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('BRHandlerStockReservation.srAfterUpdate', e);
            }
        }
    }

    /**************************************************
     * Method Name: getChangedRecords
     * Description: get list of trigger records that have track fields change
     * 
     * Revision History:
     * Developer Name		Date			Description
     * Phap Mai             27-08-2020      Init
     **************************************************/ 
    private List<Stock_Reservation__c> getChangedRecords(Set<String> trackFields) {
        
        List<Stock_Reservation__c> changedRecords = new List<Stock_Reservation__c>();

        List<Stock_Reservation__c> newRecords = srev.srTrigNew;
        Map<Id, Stock_Reservation__c> oldRecords = srev.srOldMap;
        
        for(Stock_Reservation__c newRecord : newRecords) {

			Id recordId = (Id) newRecord.get('Id');
            
            if(oldRecords == null || !oldRecords.containsKey(recordId)) continue;
            
            Stock_Reservation__c oldRecord = oldRecords.get(recordId);
            
            for(String fieldName : trackFields) {
				if(oldRecord.get(fieldName) != newRecord.get(fieldName)) changedRecords.add(newRecord);
			}
        }
        System.debug('[BRHandlerStockReservation] [getChangedRecords] changedRecords :: ' + JSON.serialize(changedRecords));
		return changedRecords;
    }

    /**************************************************
     * Method Name: sliceID
     * Description: get all IDs
     * 
     * Revision History:
     * Developer Name		Date			Description
     * Phap Mai             27-08-2020      Init
     **************************************************/ 
    private Set<Id> sliceID(List<SObject> records) {
        Set<Id> result = new Set<Id>();

        for (SObject record : records) result.add(record.ID);

        return result;
    }
}