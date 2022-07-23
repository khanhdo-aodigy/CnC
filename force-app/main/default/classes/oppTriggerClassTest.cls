@isTest
private class oppTriggerClassTest {

    static testMethod void oppTriggerTest() {
        Test.StartTest();
        
        Contact cp=new Contact();
        cp.lastname='Test';
        insert cp;
        
        Opportunity op=new Opportunity();
        op.name='op1';
        op.Contact_person__c=cp.id;
        op.Rating__c='Hot';
        op.CloseDate=Date.today().addDays(2);
        op.StageName='Open';
        insert op;
        
        Opportunity op2=new Opportunity();
        op2.name='op2';
        op2.Contact_person__c=cp.id;
        op2.Rating__c='Hot';
        op2.CloseDate=Date.today().addDays(2);
        op2.StageName='Open';
        insert op2;
        
        //sendSmsClass.testSend();
        
        Event e=new Event();
		e.subject='test event';
		e.StartDateTime=Date.today().addDays(2);
		e.EndDateTime=Date.today().addDays(3);
		e.Description='test desc';
		insert e;
		
		e.Send_SMS__c=true;
		update e;
		
		Task t=new Task();
		t.subject='test event';
		t.Description='test desc';
		insert t;
		
		t.Send_SMS__c=true;
		update t;
        
        Test.StopTest();
    }
}