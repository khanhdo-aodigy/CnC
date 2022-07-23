@isTest
public class Test_smsReminderTask {
	@isTest
    public static void testTrigger1(){
        // To test before update
        
        // Create a Task for the case..
        Task t = New Task(subject='',Status='Completed',Send_SMS__c=FALSE);
        insert t; 
        
        t.Send_SMS__c=true;
        update t;
        
    }
}