@isTest
public class CaseAutoAssignmentBatchTest {
    static testmethod void test() {
    
        Test.startTest();
    // Create test accounts to be updated
    // by the batch job.
    
    List<Case> caseList = new List<Case>();
    Group unassignedEmailQueue = [Select Id, DeveloperName, Name from Group where Type = 'Queue' AND DeveloperName = 'Unassigned_Email_Queue'];
  //  for (Integer i=0;i<200;i++) {
        Case c = new Case(Status='New', Origin='Email', OwnerId = unassignedEmailQueue.Id, Priority='P2');
        caseList.add(c);
        
        Case c1 = new Case(Status='New', Origin='Email', OwnerId = unassignedEmailQueue.Id, Priority='P2');
        caseList.add(c1);
        
        
        Case c2 = new Case(Status='New', Origin='Email', OwnerId = unassignedEmailQueue.Id, Priority='P2');
        caseList.add(c2);
        
        
        Case c3 = new Case(Status='New', Origin='Email', OwnerId = unassignedEmailQueue.Id, Priority='P2');
        caseList.add(c3);
        
        
 //  }
        system.debug('****caselist' + caselist);
    insert caseList;
    
    Database.BatchableContext BC;
       
        CaseAutoAssignmentBatch caab = new CaseAutoAssignmentBatch();
        caab.start(BC);
       caab.updateCases(caseList);
       
        
    Test.stopTest();
    
    
    }

}