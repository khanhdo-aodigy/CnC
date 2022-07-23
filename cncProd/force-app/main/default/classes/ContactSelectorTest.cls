@isTest
private class ContactSelectorTest {
        
	@isTest
    private static void testSelectContactWithoutPA(){        
    	Set<String> setContIdsWithPA = new Set<String>();
    	Set<Id> setContIdsWithoutPA = new Set<Id>();
        
        Account acc = Test_DataFactory.createAccount(true, 'A Real Fake');
        Contact con = Test_DataFactory.createContact(true, 'fname', 'lname', acc.Id);
        setContIdsWithoutPA.add(con.Id);
        
        Account personAcc = Test_DataFactory.createPerson(true, 'A Cool Name', 'Prospect');
        Account insertedPersonAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        setContIdsWithPA.add(insertedPersonAcc.PersonContactId);
        
        ContactSelector conSelector = new ContactSelector();
        List<Contact> nonPersonContact = [SELECT Id FROM Contact WHERE isPersonAccount = false];
        String result = conSelector.selectContactWithoutPA(setContIdsWithPA, setContIdsWithoutPA);
    }
    
    @isTest
    private static void testSelectContactWithoutPA_NoContsWithoutPA(){
        Set<String> setContIdsWithPA = new Set<String>();
    	Set<Id> setContIdsWithoutPA = new Set<Id>();
        
        Account personAcc = Test_DataFactory.createPerson(true, 'A Cool Name', 'Prospect');
        Account insertedPersonAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        setContIdsWithPA.add(insertedPersonAcc.PersonContactId);
        
        ContactSelector conSelector = new ContactSelector();
        List<Contact> nonPersonContact = [SELECT Id FROM Contact WHERE isPersonAccount = false];
        String result = conSelector.selectContactWithoutPA(setContIdsWithPA, setContIdsWithoutPA);
    }
    
    @isTest
    private static void testSelectContactWithoutPA_NoContsWithPA(){
        Set<String> setContIdsWithPA = new Set<String>();
    	Set<Id> setContIdsWithoutPA = new Set<Id>();
        
        Account acc = Test_DataFactory.createAccount(true, 'A Real Fake');
        Contact con = Test_DataFactory.createContact(true, 'fname', 'lname', acc.Id);
        setContIdsWithoutPA.add(con.Id);
        
        ContactSelector conSelector = new ContactSelector();
        List<Contact> nonPersonContact = [SELECT Id FROM Contact WHERE isPersonAccount = false];
        String result = conSelector.selectContactWithoutPA(setContIdsWithPA, setContIdsWithoutPA);
    }
    
    @isTest
    private static void testSelectContactWithPA(){
        Set<String> setContIdsWithPA = new Set<String>();
        
        Account acc = Test_DataFactory.createAccount(true, 'A Real Fake');
        Contact con = Test_DataFactory.createContact(true, 'fname', 'lname', acc.Id);
        
        Account personAcc = Test_DataFactory.createPerson(true, 'A Cool Name', 'Prospect');
        Account insertedPersonAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        setContIdsWithPA.add(insertedPersonAcc.PersonContactId);
        
        ContactSelector conSelector = new ContactSelector();
        List<Contact> result = conSelector.selectContactWithPA(setContIdsWithPA);
        
        System.assertEquals(1, result.size());
    }
    
    @isTest
    private static void testGetSObjectContactMap(){
        Set<String> conIdSet = new Set<String>();
        
        Account acc = Test_DataFactory.createAccount(true, 'A Real Fake');
        Contact con = Test_DataFactory.createContact(true, 'fname', 'lname', acc.Id);
        conIdSet.add(con.Id);
        
		Case dummyCase = Test_DataFactory.createCase(true, con.Id);
        Event_Registration__c dummyEvtReg = Test_DataFactory.createEventReg(true, con.Id, null, null, null, null, null);
        Opportunity dummyOpp = Test_DataFactory.createOpportunity(true, 'oppName', acc.Id);
        Test_Drive__c dummyTestDrive = Test_DataFactory.createTestDrive(true, null);
        
        ContactSelector conSelector = new ContactSelector();
        Set<String> sObjects = new Set<String>{'Case', 'Event_Registration__c', 'Opportunity', 'Test_Drive__c'};
        for(String sObj: sObjects){
            Map<String, List<SObject>> result = conSelector.getSObjectContactMap(conIdSet, sObj);   
        }        
    }
    
    @isTest
    private static void testGetEditableContactFields(){
        ContactSelector conSelector = new ContactSelector();
        List<String> contactFields = conSelector.getEditableContactFields();        
        System.assert(contactFields.size() > 0);
    }
    
    @isTest
    private static void testGetContactByIdentifier(){
        Set<String> identifiers = new Set<String>{'Fake'};       
        Account acc = Test_DataFactory.createAccount(true, 'A Real Fake');
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', acc.Id);
        con.Identifier__c = 'Fake';
        insert con;
        
        ContactSelector conSelector = new ContactSelector();
        List<Contact> result = conSelector.getContactByIdentifier(identifiers);
        System.assertEquals(1, result.size());
    }
}