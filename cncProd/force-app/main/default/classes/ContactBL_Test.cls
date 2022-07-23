@isTest(seeAllData=false)
private class ContactBL_Test {
    @TestSetup
    static void makeData(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
    
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        Account a;
        Contact pCon;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
            insert a;
        }
        
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'test@user.com',
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId);
        insert u;
    }

    @isTest
    static void testContactChange(){
        
        List<Account> lstPA = [SELECT ID FROM Account WHERE IsPersonAccount = true];
        System.assert( lstPA.size() == 1 );

        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAcct123');
        Contact jCnt = Test_DataFactory.createContact(false, 'testFn', 'testln', jccAcct.Id );
        jCnt.Account__c = lstPA.get(0).Id;
        insert jCnt;

        Test.startTest();	

            jCnt.Email = 'helloworld@email.com';
            update jCnt;        
        Test.stopTest();

    }
}