/** ******
 * Description: Test class for IDPSignUpFormService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210809          TPhan@aodigy.com    Created Initial Version. 
** ******/

@isTest
private class IDPSignUpFormServiceTest
{
    @isTest
    static void test_CheckEmail()
    {
        IDPSignUpFormService.checkEmail('patest@mail.com');
    }
    
    @isTest
    static void test_CreateUser_NoExistingPA()
    {
        IDPSignUpFormService.RequestWrapper request = new IDPSignUpFormService.RequestWrapper();
        request.email = 'patest@mail.com';
        request.firstName = 'John';
        request.lastName  = 'Doe';
        request.password  = 'Testing1234';
        request.pdpa      = true;     
        IDPSignUpFormService.createUser(request);
    }
    
    @isTest
    static void test_CreateUser_ExistingPA()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        
        IDPSignUpFormService.RequestWrapper request = new IDPSignUpFormService.RequestWrapper();
        request.email = 'patest@mail.com';
        request.firstName = 'John';
        request.lastName  = 'Doe';
        request.password  = 'Testing1234';
        request.pdpa      = true;     
        IDPSignUpFormService.createUser(request);
    }
    
    @isTest
    static void test_CreateUser_UnactivatedAccount()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId FROM Account];
        
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
        
        IDPSignUpFormService.RequestWrapper request = new IDPSignUpFormService.RequestWrapper();
        request.email = 'patest@mail.com';
        request.firstName = 'John';
        request.lastName  = 'Doe';
        request.password  = 'Testing1234';
        request.pdpa      = true;     
        try 
        {
            IDPSignUpFormService.createUser(request);
        }
        catch (Exception e)
        {
            System.assertEquals('Unactivated Account', e.getMessage());
        }
        
    }
    
    @isTest
    static void test_VerifyUser_And_ResendOTP()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId FROM Account];
        
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
                          ContactId= personAcc.PersonContactId);
        insert u;
        System.debug('Test: ' + [select iscustomerportal from account].iscustomerportal);      
        IDPSignUpFormService.RequestWrapper request = new IDPSignUpFormService.RequestWrapper();
        request.email = 'patest@mail.com';
        request.firstName = 'John';
        request.lastName  = 'Doe';
        request.password  = 'Testing1234';
        request.pdpa      = true;   
        
        IDPSignUpFormService.ResponseWrapper response = new IDPSignUpFormService.ResponseWrapper();
        response.isNewPA = false;
        response.pAId = personAcc.Id;
        response.registrationId = 'id12345';
        
        IDPSignUpFormService.verifyUser('12345', request, response, '/startURL');
        IDPSignUpFormService.resendOTP(request, response);
    }
    
    @isTest
    static void test_verifyCaptcha()
    {
     	Test.setMock(HttpCalloutMock.class, new IDPRecaptchaMock());
        Test.startTest();
        IDPSignUpFormService.verifyCaptcha('123affgf', 'token12345');
        Test.stopTest();
    }
  
    @isTest
    static void test_sendEmail()
    {
		User u;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
            personAcc.PersonEmail = 'patest@mail.com';
            insert personAcc;
            personAcc = [SELECT PersonContactId FROM Account];
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
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
                              Deactivate_C_C_Account__c = true,
                              Deletion_Request_Date__c = System.today());
            insert u; 
        }

        Test.startTest();
        IDPSignUpFormService.sendEmail(new List<User>{u}, 'Deletion_C_C_Account_Request');
        Test.stopTest();
    }
}