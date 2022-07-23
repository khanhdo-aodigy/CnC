@isTest
private class ModelsInterestedServiceTest 
{
    @testSetup
    static void setUp()
    {
        Account acct = Test_DataFactory.createAccount(true, 'Test Account');
        Contact cont = Test_DataFactory.createContact(true, 'Test', 'Contact', acct.id);    
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Testing Opportunity', acct.Id);
        opp.Branch_Code__c = 'CCK';
        opp.StageName = 'Open';
        opp.Contact_Person__c = cont.Id;
        opp.CloseDate = Date.today() + 15;
        opp.OwnerId = UserInfo.getUserId();
        insert opp;
        Model__c model = Test_DataFactory.createmodelId(true,'Test Model', 'CCK', 'KIAPC');
    }
    
	@isTest
    static void test_newModelInterestedObject()
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Model__c model = [SELECT Id FROM Model__c LIMIT 1];
        Models_Interested__c modelInterested = ModelsInterestedService.newModelInterestedObject(opp.Id, model.Id, 'Online', 'Quick contact');
        System.assertNotEquals(null, modelInterested);
    }
}