@isTest(seeAllData=false)
public class Test_priceAlerts {
    Static String testRun = 'dummyData';
    Static String branchCode = 'CCK';
    Static String franchiseCode = 'KIAPC';
    
    /*static testMethod void testLead()
    {
        Test.startTest();    
        Lead TestLead = Test_DataFactory.createLead(true,testRun,testRun);        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);                                              
        String json = '{"PersonId" : "'+TestLead.Id+'","Type" : "Lead","PDPAText" : "yes","Model" : "'+TestMod.Id+'","Variant" : "'+TestVar.Id+'"}';        
        Test_DataFactory.createReq('priceAlerts',json);         
        priceAlerts.createPriceAlerts();
        //System.assert(response.statusCode == 200);
        Test.stopTest();
    }*/

    static testMethod void testContact()
    {
        Test.startTest();
        Account ac = Test_DataFactory.createAccount(true,'testRun');
        Contact TestCon= Test_DataFactory.createContact(true,TestRun,TestRun,ac.id);        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);                           
        Opportunity oppCon = Test_DataFactory.createOpportunity(false,testRun, ac.Id);
        oppCon.Contact_Person__c = TestCon.id;
        oppCon.Stagename = 'Booked';
        Insert oppCon;                
        String json = '{"PersonId" : "'+TestCon.Id+'","Type" : "Contact","PDPAText" : "yes","Model" : "'+TestMod.Id+'","Variant" : "'+TestVar.Id+'"}';
        Test_DataFactory.createReq('priceAlerts',json);                         
        priceAlerts.createPriceAlerts();
        //System.assert(response.statusCode == 200);
        Test.stopTest();
    }
    
    /** PA MIGRATION: Newly Added -- Start */
    @isTest
    private static void testCreatePersonAccPriceAlert(){
		String accName = 'Fake Name';      
		Account personAccToInsert = Test_DataFactory.createPerson(true, accName, 'Customer');
		Account personAcc = [SELECT Id, PersonContactId FROM Account WHERE Name = :accName];        
        Contact personCon = [SELECT Id FROM Contact WHERE ID = :personAcc.PersonContactId];
        
        Model__c testModel = Test_DataFactory.createmodelId(true, 'Model Name', branchCode, franchiseCode);        
        Variant__c testVariant = Test_DataFactory.createVariant(true, 'Variant Name', testModel.Id, branchCode);                           
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Fake Opp', personAcc.Id);
        opp.Stagename = 'Booked';
        insert opp;
        
        String json = '{"PersonId" : "' + personCon.Id + '","Type" : "Contact","PDPAText" : "yes","Model" : "'+ testModel.Id + '","Variant" : "'+ testVariant.Id +'"}';
        Test_DataFactory.createReq('priceAlerts',json);  
        Test.startTest();
        priceAlerts.createPriceAlerts();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateContactPriceAlert(){
		Account testAcc = Test_DataFactory.createAccount(true, 'accName');      
        Contact testCon = Test_DataFactory.createContact(false, 'fname', 'lname', testAcc.Id);
        testCon.Account__c = testAcc.Id;
        insert testCon;
        
        Model__c testModel = Test_DataFactory.createmodelId(true, 'Model Name', branchCode, franchiseCode);        
        Variant__c testVariant = Test_DataFactory.createVariant(true, 'Variant Name', testModel.Id, branchCode);                           
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Fake Opp', testAcc.Id);
        opp.Stagename = 'Booked';
        insert opp;
        
        String json = '{"PersonId" : "' + testCon.Id + '","Type" : "Contact","PDPAText" : "yes","Model" : "'+ testModel.Id + '","Variant" : "'+ testVariant.Id +'"}';
        Test_DataFactory.createReq('priceAlerts',json);  
        Test.startTest();
        priceAlerts.createPriceAlerts();
        Test.stopTest();
    }
	/** PA MIGRATION: Newly Added -- End */
    
    //Test method for not supplying Required fields
    static testMethod void testBlankFields()
    {
        Test.startTest();
        String json = '{"PersonId" : "","Type" : "Contact","PDPAText" : "yes","Model" : "","Variant" : ""}';        
        Test_DataFactory.createReq('priceAlerts',json);                                 
        priceAlerts.createPriceAlerts();
        Test.stopTest();
    }
}