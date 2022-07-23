@IsTest
public class UpdateCBSQueuable_Test {

    static testmethod void test3()    
	{
	
        List<Case> CasesForCBS = New List<Case>();
        Case c = New Case();
    	c.subject ='case 1';
        c.Case_Category__c = 'Booking List';
    	c.SMS_Status__c='Confirm Appointment';
    	c.Status='Open';
    	insert c;
        CasesForCBS.add(c);
     
        Case c1 = New Case();
    	c1.subject ='case 11';
        c1.Case_Category__c = 'Booking List';
    	c1.SMS_Status__c='Confirm Appointment';
    	c1.Status='Open';
    	insert c1;
        CasesForCBS.add(c1);
     
    Test.startTest();
              Test.setMock(HttpCalloutMock.class, new externalMock());
      
     ID jobId = System.enqueueJob(New UpdateCBSQueuable(CasesForCBS));
    Test.stopTest();
}
    
}