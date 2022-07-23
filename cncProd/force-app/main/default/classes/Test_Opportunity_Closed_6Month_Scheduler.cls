@isTest
public class Test_Opportunity_Closed_6Month_Scheduler {

    static testMethod void testInsertTrigger()
    {
        Test.startTest();
        Account Acc = new Account(Name = 'test');
        Insert Acc;
        List<Opportunity> oppList = new List<Opportunity>();  
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Opportunity opp = Test_DataFactory.createOpportunity(true,'Test',acc.id);
        Opportunity opp2 = Test_DataFactory.createOpportunity(true,'Test2',acc.id); 
        oppList.add(opp);
        oppList.add(opp2);
        Test_DataFactory.createEventReg(true,null,null,null,opp.id,null,null);
        Test_DataFactory.createmodelsInterested(true,md1.Id,opp.Id,'Open','Test Drive (Web)');
        Opportunity_Closed_6Month_Scheduler oppBatch = new Opportunity_Closed_6Month_Scheduler();
        oppBatch.execute(null,oppList);
        BatchManager batchM= new BatchManager('Opportunity_Closed_6Month_Scheduler', null);
        Test.stopTest();
    }
}