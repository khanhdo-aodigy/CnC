@isTest
public class EventTaskTriggerTest {

    public static testMethod void EventTaskTest() {
        Test.StartTest();
        //create account
        Account acc = new Account();
        acc.name='XYZ Organization';
        insert acc;
        
        //create contact
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        insert c1;
        //create event
        //create task
        //create event with sms reminder
        //create task with sms reminder
        //update the Send_SMS__c for event and task
        Event e1=new Event();
        e1.Subject='Test';
        e1.StartDateTime=Date.today().addDays(2);
        e1.EndDateTime=Date.today().addDays(3);
		insert e1;
		Event e2=new Event();
        e2.Subject='Test';
        e2.StartDateTime=Date.today().addDays(2);
        e2.EndDateTime=Date.today().addDays(3);
        e2.SMS_reminder__c=Date.today().addDays(2);
        e2.Send_SMS__c=false;
		insert e2;
		e2.Send_SMS__c=true;
		update e2;
		Task t1=new Task();
		t1.Subject='Test';
        t1.ActivityDate=Date.today().addDays(2);
		insert t1;
		Task t2=new Task();
		t2.Subject='Test';
        t2.ActivityDate=Date.today().addDays(2);
		t2.SMS_reminder__c=Date.today().addDays(2);
        t2.Send_SMS__c=false;
		insert t2;
		t2.Send_SMS__c=true;
		update t2;
        Test.StopTest();
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Event', true);
        TriggerExclusion.excludeTrigger('Task', true);
        Event e1=new Event();
        e1.Subject='Test';
        e1.StartDateTime=Date.today().addDays(2);
        e1.EndDateTime=Date.today().addDays(3);
		insert e1;
        Task t2=new Task();
		t2.Subject='Test';
        t2.ActivityDate=Date.today().addDays(2);
		t2.SMS_reminder__c=Date.today().addDays(2);
		insert t2;
		t2.Send_SMS__c=false;
		update t2;
        TriggerExclusion.excludeTrigger('Event', false);
        TriggerExclusion.excludeTrigger('Task', false);
    }
}