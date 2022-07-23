//Write by HH 12 Mar 2020
@isTest
public class ClashOpportunityController_Test {
    
    @testSetup
    public static void createData(){
        
               
    }
    
	@isTest
    public static void testClashOpportunityController(){
         Account personAcc = Test_DataFactory.createPerson(true, 'Matthew', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];

        Opportunity opp = Test_DataFactory.createOpportunity(false, 'MatthewOpp', personAcc.Id);
        opp.Account__c = personAcc.Id;
        //opp.Contact_Person__c = personAcc.PersonContactId;
        insert opp;
        
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCI', 'MBP');
        Models_Interested__c mi = Test_DataFactory.createmodelsInterested(true, model.Id, opp.Id, '', 'tp'); 
        Test.startTest();
        List<Opportunity> opps = [Select Id From Opportunity Limit 1];
        if(opps.size() > 0){
            ClashOpportunityController controller = new ClashOpportunityController();
            controller.oppId = opps[0].Id;
            Opportunity oppo = controller.getoppfield();
            Test.stopTest();
            System.assertNotEquals(controller.getoppList(), null);
            System.assertNotEquals(oppo, null);
        }
    }
    
    @isTest
    public static void testGetOppList_OppAccNotNull(){
         Account personAcc = Test_DataFactory.createPerson(true, 'Matthew', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];

        Opportunity opp = Test_DataFactory.createOpportunity(false, 'MatthewOpp', personAcc.Id);
        opp.Account__c = personAcc.Id;
        insert opp;
        
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCI', 'MBP');
        Models_Interested__c mi = Test_DataFactory.createmodelsInterested(true, model.Id, opp.Id, '', 'tp'); 
        Test.startTest();
        List<Opportunity> opps = [Select Id From Opportunity Limit 1];
        if(opps.size() > 0){
            ClashOpportunityController controller = new ClashOpportunityController();
            controller.oppId = opps[0].Id;
            controller.getoppList();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetOppList_OppAccNull(){
         Account personAcc = Test_DataFactory.createPerson(true, 'Matthew', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];

        Opportunity opp = Test_DataFactory.createOpportunity(false, 'MatthewOpp', personAcc.Id);
        opp.Contact_Person__c = personAcc.PersonContactId;
        insert opp;
        
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCI', 'MBP');
        Models_Interested__c mi = Test_DataFactory.createmodelsInterested(true, model.Id, opp.Id, '', 'tp'); 
        Test.startTest();
        List<Opportunity> opps = [Select Id From Opportunity Limit 1];
        if(opps.size() > 0){
            ClashOpportunityController controller = new ClashOpportunityController();
            controller.oppId = opps[0].Id;
            controller.getoppList();
            Test.stopTest();
        }
    }
}