@isTest
private class DeletePACleanUserDataBatchTest {
    @isTest
    static void test()
    {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u;
        User u1;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc.PersonEmail = 'patest@mail.com';
            insert personAcc;
            personAcc = [SELECT PersonContactId FROM Account WHERE PersonEmail = 'patest@mail.com'];

            u = new User(Alias = 'ksa2',
                          Email='patest@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest@mail.com', 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = true,
                          Deactivate_C_C_Account__c = true,
                          Deletion_Request_Date__c = System.today().addDays(-15));
          	insert u;

            Account personAcc1 = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc1.PersonEmail = 'patest1@mail.com';
            insert personAcc1;
            personAcc1 = [SELECT PersonContactId FROM Account WHERE PersonEmail = 'patest1@mail.com'];

            u1 = new User(Alias = 'ksa2',
                          Email='patest1@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest1@mail.com', 
                          ContactId= personAcc1.PersonContactId, 
                          isValid__c = true,
                          Deactivate_C_C_Account__c = true,
                          Deletion_Request_Date__c = System.today().addDays(-15));
          	insert u1;
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Ben-Dup', personAcc1.Id);
            insert opp;
        }

        Test.startTest();
        Database.executeBatch(new DeletePACleanUserDataBatch());
        Test.stopTest();
        // User to be deactivated
        // PA to be deleted
        u = [SELECT Id, isActive, Alias, Email, Username, LastName FROM User WHERE Id = :u.Id];
        System.assertEquals(true, u.Alias.contains('dummy'));
        System.assertEquals(true, u.Email.contains('dummy'));
        System.assertEquals(true, u.Username.contains('dummy'));
        System.assertEquals(true, u.LastName.contains('Dummy_'));

        // User to be restored
        u1 = [SELECT Id, isActive, Alias, Email, Username, LastName, Deletion_Request_Date__c, Deactivate_C_C_Account__c FROM User WHERE Id = :u1.Id];
        System.assertEquals(null, u1.Deletion_Request_Date__c);
        System.assertEquals(false, u1.Deactivate_C_C_Account__c);
	}

    @isTest
    static void test_ProspectPAConvertedToCustomer()
    {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
		  	personAcc.PersonEmail = 'patest@mail.com';
            insert personAcc;
            personAcc = [SELECT PersonContactId FROM Account WHERE PersonEmail = 'patest@mail.com'];

            u = new User(Alias = 'ksa2',
                          Email='patest@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest@mail.com', 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = true,
                          Deactivate_C_C_Account__c = true,
                          Deletion_Request_Date__c = System.today().addDays(-15));
          	insert u;
        }
        Test.startTest();
        Database.executeBatch(new DeletePACleanUserDataBatch());
        Test.stopTest();

        // User to be restored
        u = [SELECT Id, isActive, Alias, Email, Username, LastName, Deletion_Request_Date__c, Deactivate_C_C_Account__c FROM User WHERE Id = :u.Id];
        System.assertEquals(null, u.Deletion_Request_Date__c);
        System.assertEquals(false, u.Deactivate_C_C_Account__c);
    }

    @isTest
    static void test_Referral()
    {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc.PersonEmail = 'patest@mail.com';
            insert personAcc;
            personAcc = [SELECT PersonContactId FROM Account WHERE PersonEmail = 'patest@mail.com'];

            u = new User(Alias = 'ksa2',
                          Email='patest@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest@mail.com', 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = true,
                          Deactivate_C_C_Account__c = true,
                          Deletion_Request_Date__c = System.today().addDays(-15));
          	insert u;
            Referral__c ref = Test_DataFactory.createReferral(true, personAcc.Id, personAcc.Id);
        }
        Test.startTest();
        Database.executeBatch(new DeletePACleanUserDataBatch());
        Test.stopTest();

        // User to be restored
        u = [SELECT Id, isActive, Alias, Email, Username, LastName, Deletion_Request_Date__c, Deactivate_C_C_Account__c FROM User WHERE Id = :u.Id];
        System.assertEquals(null, u.Deletion_Request_Date__c);
        System.assertEquals(false, u.Deactivate_C_C_Account__c);
    }
}