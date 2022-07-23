@isTest
public class SetDeferredCreatedDateTimeTest {
    
    @istest
    public static void testTriggerCaseInsert(){
        List<Case> cases = new list<Case>();
        List<String> caseIds = new List<String>();
        
        Case c = new Case(Status='New', Origin='Email', Deferred_Created_Date_Time__c = null, Is_Not_Business_Day_Created__c = true, Priority='P2');
        cases.add(c);
        caseIds.add(c.id);
        
        Case c1 = new Case(Status='New', Origin='Email', Deferred_Created_Date_Time__c = null, Is_Not_Business_Day_Created__c = false, Priority='P4');
        cases.add(c1);
        caseIds.add(c1.id);
        
        insert cases;
        
        system.debug('Print cases=>'+ cases);
        
        List<Case> casesList = [SELECT Id, Deferred_Created_Date_Time__c, CreatedDate , Origin, Deferred_Assigned_Date_Time__c, Is_Not_Business_Day_Created__c FROM Case WHERE Origin = 'Email'];
        system.debug('Print cases list=>'+ casesList);
        
        //SetDeferredAssignedDateTime.AssignDeferredAssignedDateTime(caseIds);
        
        
        for(Case c2: casesList){
            caseIds.add(c2.Id);
        }
        Test.startTest();
            SetDeferredCreatedDateTime.AssignDeferredCreatedDateTime(caseIds);
        Test.stopTest();
        
        List<Case> updatedCasesList = [SELECT Id, Deferred_Created_Date_Time__c, CreatedDate , Origin, Deferred_Assigned_Date_Time__c, Is_Not_Business_Day_Created__c FROM Case WHERE Id In: caseIds];
        for(Case c2: updatedCasesList){
        if(c2.Is_Not_Business_Day_Created__c == true){
                system.assertEquals(c2.Deferred_Created_Date_Time__c, c2.CreatedDate); 
                //system.assertEquals(c2.Deferred_Assigned_Date_Time__c, c2.CreatedDate);
            }   
        }
    }
}