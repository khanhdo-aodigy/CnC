global class CaseAutoAssignmentBatch implements Database.Batchable<sObject>, schedulable {
    
   global CaseAutoAssignmentBatch() {
   }
    
   global Database.QueryLocator start(Database.BatchableContext BC)  {
       Group unassignedEmailQueue = [Select Id, DeveloperName, Name from Group where Type = 'Queue' AND DeveloperName = 'Unassigned_Email_Queue'];
       
       String query = 'Select Id, Assigned_Date_Time__c, EntitlementId, OwnerId, Status FROM Case WHERE OwnerId = \'' + String.escapeSingleQuotes(unassignedEmailQueue.Id) + '\'';
       system.debug('****query' + Database.getQueryLocator(query));
       system.debug('***Print query result' + Database.getQueryLocator(query));
       return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> unassignedCases){
        updateCases(unassignedCases);
    }  
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
    
    global void execute(SchedulableContext SC) {
 		database.executebatch(new CaseAutoAssignmentBatch());
    }

    public void updateCases(List<Case> unassignedCases){
           
        system.debug('%%%unassignedCases' + unassignedCases);
        // process each batch of records
        List<Case> casesList = new List<Case>();
        List<String> caseIds = new List<String>();
        
        
        Group unassignedEmailQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Unassigned_Email_Queue'];
        Group routingQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Email_Auto_Assignment_Queue'];
        
        for(Case c: unassignedCases){
            c.OwnerId = routingQueue.Id;
            c.Status = 'Open';
            c.Auto_assigned_case__c = true;
            casesList.add(c);  
            system.debug('****INSIDE Batch class' + casesList);
        }
            
              /*for(Case c: unassignedCases){
                  
                  casesList.add(c);  
                  caseIds.add(c.Id);
             }*/
        
            if(!casesList.isEmpty()){
                update casesList;
            }
    }
}