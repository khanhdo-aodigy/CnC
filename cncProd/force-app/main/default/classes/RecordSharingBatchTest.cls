@isTest
private class RecordSharingBatchTest {
    private static String conAccess = 'Read';
    private static String leadAccess = 'Edit';
    
	@testSetup
    private static void setup() {       
        Account personAcc = Test_DataFactory.createPerson(true, 'lastName', 'Prospect');
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'record.sharing.batch@testuser.com',
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = profile.Id, 
            LanguageLocaleKey = 'en_US'
            );
        insert testUser;
    }
    
    @isTest
    private static void testSharingBatch_ContactShare() {
        Account personAcc = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];
        User testUser = [SELECT Id
                         FROM User
                         WHERE Username = 'record.sharing.batch@testuser.com'
                        ];
        
        Contact contact = Test_DataFactory.createContact(false, 'fname', 'lname', null);
		contact.Account__c = personAcc.Id;
		insert contact;
            
        ContactShare conShare = new ContactShare();
        conShare.ContactId = contact.Id;        
        conShare.UserOrGroupId = testUser.Id;
        conShare.ContactAccessLevel = conAccess;
        conShare.RowCause = 'Manual';
        insert conShare;
        
        RecordSharingBatch xJob = new RecordSharingBatch('Contact', new Set<String>{contact.Id});
        Database.executeBatch(xJob);
        
        List<AccountShare> result = [SELECT AccountId, UserOrGroupId, AccountAccessLevel
                               FROM AccountShare
                               WHERE AccountId = :personAcc.Id
                               AND UserOrGroupId = :testUser.Id
                              ];
         //System.assertEquals(1, result.size());
    }
    
    @isTest
    private static void testSharingBatch_LeadShare() {
        Account personAcc = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];
        User testUser = [SELECT Id
                         FROM User
                         WHERE Username = 'record.sharing.batch@testuser.com'
                        ];
        Lead lead = Test_DataFactory.createLead(false, 'C&C', 'DummyLead');
		lead.Account__c = personAcc.Id;
		insert lead;
        
        LeadShare leadShare = new LeadShare();
        leadShare.LeadId = lead.Id;        
        leadShare.UserOrGroupId = testUser.Id;
        leadShare.LeadAccessLevel = leadAccess;
        leadShare.RowCause = 'Manual';
        insert leadShare;
        
        RecordSharingBatch xJob = new RecordSharingBatch('Lead', new Set<String>{lead.Id});
        Database.executeBatch(xJob);
        
        List<AccountShare> result = [SELECT AccountId, UserOrGroupId, AccountAccessLevel
                               FROM AccountShare
                               WHERE AccountId = :personAcc.Id
                               AND UserOrGroupId = :testUser.Id
                              ];
        //System.assertEquals(1, result.size());
    }
}