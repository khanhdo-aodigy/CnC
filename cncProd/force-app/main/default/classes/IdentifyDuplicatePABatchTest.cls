@isTest
private class IdentifyDuplicatePABatchTest {
    @isTest
    private static void testIdentifyPrimary_BasicCases() {
        // 2 Customers same email, only one has DWH
        Account primaryBen = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        primaryBen.DWH_Contact_ID__pc = '1000907';
        insert primaryBen;        
        Account dupBen = Test_DataFactory.createPA(true, 'Benjamin','ben@test.com', 'Customer');
        
        // Unique email and have DWH
        Account uniqueTom = Test_DataFactory.createPA(false, 'Tom','tom@test.com', 'Customer');
        uniqueTom.DWH_Contact_ID__pc = '2300907';
        insert uniqueTom;
        
        //Unique email but no DWH
        Account uniqueJerry = Test_DataFactory.createPA(true, 'Jerry','jerry@test.com', 'Customer');
        
        Database.executeBatch(new IdentifyDuplicatePABatch());
    }
    
    @isTest
    private static void testPAHaveUserRecord() {
        Account primaryBen = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        primaryBen.DWH_Contact_ID__pc = '1000907';
        insert primaryBen;
        
        primaryBen = [ SELECT Id, PersonContactId FROM Account WHERE Id = :primaryBen.Id];
        
        Profile endUserProfile = [ SELECT Id FROM Profile WHERE Name = 'End User'];
        User portalUser = new User(
            ProfileId = endUserProfile.Id,
            Username = 'beh@test.com',
            Alias = 'ben',
            Email ='ben@test.com',
            ContactId = primaryBen.PersonContactId,
            EmailEncodingKey ='UTF-8',
            Firstname ='Bruce',
            Lastname ='Benjamin',
            LanguageLocaleKey ='en_US',
            LocaleSidKey ='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert portalUser;
        Account dupBen = Test_DataFactory.createPA(true, 'Benjamin','ben@test.com', 'Customer');
        Database.executeBatch(new IdentifyDuplicatePABatch('ben@test.com'));
    }
    
    @isTest
    private static void testMultiplePAsHaveUserRecord_PrimaryIsDetermined() {
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Account dup1 = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        dup1.Is_Primary_Account__c = true;
        insert dup1;
        dup1 = [ SELECT Id, PersonContactId FROM Account WHERE Id = :dup1.Id];
        
        Profile endUserProfile = [ SELECT Id FROM Profile WHERE Name = 'End User'];
        User portalUser1 = new User(
            ProfileId = endUserProfile.Id,
            Username = 'ben1@test.com',
            Alias = 'ben1',
            Email ='ben@test.com',
            ContactId = dup1.PersonContactId,
            EmailEncodingKey ='UTF-8',
            Firstname ='Bruce',
            Lastname ='Benjamin',
            LanguageLocaleKey ='en_US',
            LocaleSidKey ='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        System.runAs(admin) {
            insert portalUser1;
        }
        
        Account dup2 = Test_DataFactory.createPA(true, 'Benjamin','beh@test.com', 'Customer'); //email diff from user email
        dup2 = [ SELECT Id, PersonContactId FROM Account WHERE Id = :dup2.Id];
        User portalUser2 = new User(
            ProfileId = endUserProfile.Id,
            Username = 'ben2@test.com',
            Alias = 'ben2',
            Email ='ben@test.com',
            ContactId = dup2.PersonContactId,
            EmailEncodingKey ='UTF-8',
            Firstname ='Bruce',
            Lastname ='Benjamin',
            LanguageLocaleKey ='en_US',
            LocaleSidKey ='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        System.runAs(admin) {
            insert portalUser2;
        }
        Database.executeBatch(new IdentifyDuplicatePABatch());
    }
    
    @isTest
    private static void testPAHaveUserButNoEmail() {        
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
       
        Account primaryBen = Test_DataFactory.createPA(false, 'Benjamin','', 'Customer');              
		primaryBen.DWH_Contact_ID__pc = '1000907';
        insert primaryBen;        
        primaryBen = [ SELECT Id, PersonContactId FROM Account WHERE Id = :primaryBen.Id];

        Profile endUserProfile = [ SELECT Id FROM Profile WHERE Name = 'End User'];
        User portalUser = new User(
            ProfileId = endUserProfile.Id,
            Username = 'beh@test.com',
            Alias = 'ben',
            Email ='ben@test.com',
            ContactId = primaryBen.PersonContactId,
            EmailEncodingKey ='UTF-8',
            Firstname ='Bruce',
            Lastname ='Benjamin',
            LanguageLocaleKey ='en_US',
            LocaleSidKey ='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        System.runAs(admin) {
            insert portalUser;
        }  
        primaryBen = [ SELECT Id, PersonContactId, IsCustomerPortal FROM Account WHERE Id = :primaryBen.Id];
        System.debug('primaryBen :: '+ primaryBen);
        Account dupBen = Test_DataFactory.createPA(true, 'Benjamin','ben@test.com', 'Customer');
        Database.executeBatch(new IdentifyDuplicatePABatch());
    }
    
    @isTest
    private static void testHandleProspectsWithoutEmail() {
        Account expiredPros = Test_DataFactory.createPerson(true, 'Tom', 'Prospect');
        Test.setCreatedDate(expiredPros.Id, Date.today().addMonths(-20));
        
        Account prosToBlank = Test_DataFactory.createPerson(true, 'Jerry', 'Prospect');
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'Jerry Opp', prosToBlank.Id);
        Test.setCreatedDate(prosToBlank.Id, Date.today().addMonths(-20));
        Test.setCreatedDate(opp.Id, Date.today().addMonths(-19));
        
        Database.executeBatch(new IdentifyDuplicatePABatch());
    }
    
    @isTest
    private static void testConflictDWHContactId() {
        Account dup1 = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        dup1.DWH_Contact_ID__pc = '1000907';
        insert dup1;
        
        Account dup2 = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        dup2.DWH_Contact_ID__pc = '1000908';
        insert dup2;
        Database.executeBatch(new IdentifyDuplicatePABatch('ben@test.com'));
    }
    
    @isTest
    private static void testPrimaryIsDetermined() {
        Account dup1 = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        dup1.DWH_Contact_ID__pc = '1000907';
        dup1.Is_Primary_Account__c = true;
        insert dup1;
        
        Account dup2 = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        dup2.DWH_Contact_ID__pc = '1000908';
        insert dup2;
        Database.executeBatch(new IdentifyDuplicatePABatch('ben@test.com'));
    }
}