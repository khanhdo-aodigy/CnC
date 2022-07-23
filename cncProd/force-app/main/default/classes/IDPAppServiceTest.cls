/** ******
 * Description: Test class for IDPAppService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)    Name                		Description
 * 20210810          TPhan@aodigy.com    		Created Initial Version. 
 * 20220515		 	 ThieuDang.Vu@aodigy.com	Modified.
** ******/
@isTest
private class IDPAppServiceTest 
{
    @isTest
    static void test_DoLogin_ValidUser()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          isValid__c = true);
        insert u;

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing'; 
        IDPAppService.doLogin(request);
    }
    
    @isTest
    static void test_DoLogin_InvalidEmail()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          isValid__c = true);
        insert u;

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest123@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing'; 
        try
        {
            IDPAppService.doLogin(request);
        }
        catch(Exception e)
        {
            System.assertEquals('Invalid', e.getMessage());
        }
    }
    
    @isTest
    static void test_DoLogin_InactiveUser()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          isValid__c = false);
        insert u;

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing'; 
        try
        {
            IDPAppService.doLogin(request);
        }
        catch(Exception e)
        {
            System.assertEquals('Inactive', e.getMessage());
        }
    }

   	@isTest
    static void test_DoLogin_RestoreUser()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        personAcc.Signup_Channel__pc = 'My C&C App';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          Deletion_Request_Date__c = System.Today(),
                          Deactivate_C_C_Account__c = true);
        insert u;

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing'; 
        try
        {
            IDPAppService.doLogin(request);
        }
        catch(Exception e)
        {
            System.assertEquals('Inactive', e.getMessage());
        }
    }
   
    @isTest
    static void test_DoForgotPassword()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          isValid__c = true);
        insert u;

        IDPAppService.doForgotPassword('patest@mail.com');
    }
    
    @isTest
    static void test_DoForgotPassword_InvalidEmail()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          isValid__c = true);
        insert u;

        try 
        {
            IDPAppService.doForgotPassword('patest123@mail.com');
        }
        catch(Exception e)
        {
            System.assertEquals('Invalid', e.getMessage());
        }
    }
    
    @isTest
    static void test_DoForgotPassword_InActiveUser()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
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
                          isValid__c = false);
        insert u;

        try 
        {
            IDPAppService.doForgotPassword('patest@mail.com');
        }
        catch(Exception e)
        {
            System.assertEquals('Inactive', e.getMessage());
        }
    }

    @isTest
    static void test_revokeRefreshToken()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest123@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
                          Email='patest123@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest123@mail.com', 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = false);
        insert u;

        global_var__c JCC_GlobalVar = new global_var__c();
        JCC_GlobalVar.APIGateway_url__c = 'https://www.test.com';
        JCC_GlobalVar.APIGateway_key__c = '1213109skfjskjf';
        insert JCC_GlobalVar;

        Test.setMock(HttpCalloutMock.class, new IDPRevokeRefreshTokenMock());
        Test.startTest();
        IDPAppService.revokeRefreshToken('patest123@mail.com');
        Test.stopTest();
    }

    @isTest
    static void test_isNewUser()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Testing', 'Prospect');
        personAcc.PersonEmail = 'testtest467346@mail.com';
        insert personAcc;

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'testtest467346@mail.com';
        request.password  = '';
        request.startURL  = ''; 
        
        IDPAppService.isNewUser(request);
    }

    @isTest
    static void test_confirmDelete()
    {   
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u;

        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
            personAcc.PersonEmail = 'patest1@mail.com';
            insert personAcc;

            personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];

            u = new User(Alias = 'ksa2',
                          Email='patest1@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest1@mail.com', 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = true);
          	insert u;

            personAcc.Signup_Channel__pc = 'My C&C App';
            update personAcc;
            system.debug('personAcc :: ' + personAcc);
        }

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest1@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing';

        Test.startTest();
        Boolean isSuccess = IDPAppService.confirmDelete(request);
        Test.stopTest();
        system.assertEquals(true, isSuccess);
    }

    @isTest
    static void test_confirmDelete_EmptyPwd()
    {   
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc.PersonEmail = 'patest@mail.com';
            personAcc.Signup_Channel__pc = 'My C&C App';
            insert personAcc;
            personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];

            User u = new User(Alias = 'ksa2',
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
                          isValid__c = true);
          	insert u;

            personAcc.Signup_Channel__pc = 'My C&C App';
            update personAcc;
        }

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest@mail.com';
        request.password  = null;
        request.startURL  = '/testing'; 

        try
        {
			Boolean isSuccess = IDPAppService.confirmDelete(request);
        }
        catch (Exception e)
        {
            System.assertEquals(true, e.getMessage().contains('Please enter your password for verification.'));
        }
    }

    @isTest
    static void test_confirmDelete_InvalidUser()
    {   
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc.PersonEmail = 'patest@mail.com';
            personAcc.Signup_Channel__pc = 'My C&C App';
            insert personAcc;
            personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];

            User u = new User(Alias = 'ksa2',
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
                          isValid__c = true);
          	insert u;

            personAcc.Signup_Channel__pc = 'DSA';
            update personAcc;
        }

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing'; 

        try
        {
			Boolean isSuccess = IDPAppService.confirmDelete(request);
        }
        catch (Exception e)
        {
            System.assertEquals(true, e.getMessage().contains('We are not able to delete your account.'));
        }
    }

    @isTest
    static void test_getUserInfo()
    {
    	User u = new User(Id = UserInfo.getUserId());
        Test.startTest();
        User u1 = IDPAppService.getUserInfo(u.Id);
        System.assertNotEquals(null, u1);
        Test.stopTest();
    }

    @isTest
    static void test_confirmRestore()
    {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc.PersonEmail = 'patest@mail.com';
            personAcc.Signup_Channel__pc = 'My C&C App';
            insert personAcc;
            personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];

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
                          isValid__c = true);
          	insert u;

            personAcc.Signup_Channel__pc = 'My C&C App';
            update personAcc;
        }

        IDPAppService.RequestWrapper request = new IDPAppService.RequestWrapper();
        request.email     = 'patest@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing';
        
        Test.startTest();
        IDPAppService.confirmRestore(request.email);
        u = [SELECT Id, Deletion_Request_Date__c, Deactivate_C_C_Account__c FROM User where Id = :u.Id];
        System.assertEquals(null, u.Deletion_Request_Date__c);
        System.assertEquals(false, u.Deactivate_C_C_Account__c);
        Test.stopTest();
    }

    @isTest
    static void test_checkUserForDeletion()
    {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u;
        Account personAcc;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
		  	personAcc.PersonEmail = 'patest@mail.com';
            personAcc.Signup_Channel__pc = 'My C&C App';
            insert personAcc;
            personAcc = [SELECT PersonContactId, Signup_Channel__pc, RecordType.DeveloperName FROM Account];

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
                          isValid__c = true);
          	insert u;

            personAcc.Signup_Channel__pc = 'My C&C App';
            update personAcc;
        }

        Test.startTest();
        Boolean isValidUser = IDPAppService.checkUserForDeletion(personAcc);
        System.assertEquals(true, isValidUser);
        Test.stopTest();
    }
}