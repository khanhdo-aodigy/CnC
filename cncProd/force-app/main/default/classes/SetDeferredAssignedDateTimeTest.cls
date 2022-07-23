@isTest
public class SetDeferredAssignedDateTimeTest {
    
    @istest
    public static void testTriggerCaseInsert(){
        List<Case> cases = new list<Case>();
        List<String> caseIds = new List<String>();
        
        Case c = new Case(Status='New', Origin='Email', Deferred_Created_Date_Time__c = system.now(), Deferred_Assigned_Date_Time__c = null, Assigned_Date_Time__c = system.now(), Priority='P2', Is_Case_Assigned_to_SA__c = true);
        cases.add(c);
        caseIds.add(c.id);
        
        Case c1 = new Case(Status='New', Origin='Email', Deferred_Created_Date_Time__c = system.now(),Deferred_Assigned_Date_Time__c = null, Assigned_Date_Time__c = system.now(), Priority='P4', Is_Case_Assigned_to_SA__c = true);
        cases.add(c1);
        caseIds.add(c1.id);
        
        insert cases;
        
        system.debug('Print cases=>'+ cases);
        
        List<Case> casesList = [SELECT Id, Deferred_Created_Date_Time__c, CreatedDate , Origin, Deferred_Assigned_Date_Time__c, Is_Not_Business_Day_Created__c FROM Case WHERE Origin = 'Email'];
        system.debug('Print cases list=>'+ casesList);
        
        for(Case c2: casesList){
            caseIds.add(c2.Id);
        }
        Test.startTest();
            SetDeferredAssignedDateTime.AssignDeferredAssignedDateTime(caseIds);
        Test.stopTest();
        
        List<Case> updatedCasesList = [SELECT Id, CreatedDate , Origin, Deferred_Assigned_Date_Time__c, Assigned_Date_Time__c, Is_Not_Business_Day_Assigned__c FROM Case WHERE Id In: caseIds];
        for(Case c2: updatedCasesList){
        if(c2.Is_Not_Business_Day_Assigned__c == true){
                system.assertEquals(c2.Deferred_Assigned_Date_Time__c, c2.Assigned_Date_Time__c); 
            }   
        }
    }
}