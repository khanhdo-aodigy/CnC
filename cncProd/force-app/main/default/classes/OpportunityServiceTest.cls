@isTest
private class OpportunityServiceTest 
{
    @TestSetup
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
        Models_Interested__c modelInterested = Test_DataFactory.createmodelsInterested(true, model.Id, opp.Id, 'Open', 'Quick contact');
    }

    @isTest
    static void test_activeOpportunityList()
    {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Opportunity> opps = OpportunityService.activeOpportunityList('CCK', c.Id);
        //System.assertEquals(1, opps.size());
    }
    
    @isTest
    static void test_newOpportunityObject()
    {
        Contact c = [SELECT Id, Account__c FROM Contact LIMIT 1];
        String recordTypeId = [SELECT Id FROM RecordType Where SobjectType = 'Opportunity' and Name = 'KIAPC'].Id;
        Opportunity opp = OpportunityService.newOpportunityObject(c.Id, c.Account__c, recordTypeId, 'CCK', 'KIAPC', 'TestDrive');
        System.assertNotEquals(null, opp);
    }   
    
    @isTest
    static void test_updateOpportunityObject()
    {
        Contact c = [SELECT Id, Account__c FROM Contact LIMIT 1];
        String recordTypeId = [SELECT Id FROM RecordType Where SobjectType = 'Opportunity' and Name = 'KIAPC'].Id;
        Opportunity opp = new Opportunity();
        opp = OpportunityService.updateOpportunity(opp, c.Id, c.Account__c, recordTypeId, 'CCK', 'KIAPC', 'TestDrive');
        System.assertNotEquals(null, opp);
    }
    
    @isTest
    static void test_getStrOpportunityName()
    {
        String name = OpportunityService.getStrOpportunityName('Test', 'KIAPC');
        System.assertNotEquals(null, name);
    }
    
    @isTest
    static void test_getStrOwnerAssignment()
    {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        String ownerId = OpportunityService.getStrOwnerAssignment(c.Id, 'CCK');
        System.assertNotEquals(null, ownerId);
    }
    
    @isTest
    static void test_getStrRecordTypeAssignment()
    {
        String recordTypeId = OpportunityService.getStrRecordTypeAssignment('CCK');
        System.assertNotEquals(null, recordTypeId);
    }
}