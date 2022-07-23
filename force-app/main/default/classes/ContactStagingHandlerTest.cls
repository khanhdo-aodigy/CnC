@isTest
private class ContactStagingHandlerTest {
	
    @isTest
    private static void test() {
        Account account = Test_DataFactory.createAccount(true, 'accName');
        
        List<Contact> conList = new List<Contact>();
        Contact con1 = Test_DataFactory.createContact(false, 'fname1', 'lname1', account.Id);
        con1.Email = 'test1@gmail.com';
        con1.Email__c = true;
        conList.add(con1);
        
        Contact con2 = Test_DataFactory.createContact(false, 'fname2', 'lname2', account.Id);
        con2.Email = 'test2@gmail.com';
        con2.Email__c = true;
        conList.add(con2);
        
        insert conList;
        
        List<Contact_Staging__c> csList = new List<Contact_Staging__c>();
        
        Contact_Staging__c contactStaging1 = new Contact_Staging__c(Contact_Key__c = con1.Id);
        csList.add(contactStaging1);
        
        Contact_Staging__c contactStaging2 = new Contact_Staging__c(Contact_Key__c = con2.Email);
        csList.add(contactStaging2);
        
        insert csList;
        
        
        ContactStagingHandler.uncheckPDPA_email(csList);
        List<Contact> updatedResult = [SELECT Id, Email__c
                                       FROM Contact
                                      ];
        for(Contact con: updatedResult) {
            System.assertEquals(false, con.Email__c);
        }
    }

    @isTest
    private static void testTriggerExclusion() {
        Account account = Test_DataFactory.createAccount(true, 'accName');        
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', account.Id);
        con.Email = 'test@gmail.com';        
        insert con;
        
        TriggerExclusion.excludeTrigger('Contact_Staging__c', true);
        
        Contact_Staging__c contactStaging = new Contact_Staging__c(Contact_Key__c = con.Id);        
        insert contactStaging;
        
    }
}