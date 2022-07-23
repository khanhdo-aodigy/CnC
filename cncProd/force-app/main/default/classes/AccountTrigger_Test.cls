@isTest
private class AccountTrigger_Test {
    private static String email = 'patest@mail.com';
    
    @TestSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = email;
        insert personAcc;
        personAcc = [SELECT PersonContactId FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
                          Email= email,
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName= email, 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = true);
        insert u;
    }
    
    @isTest
    private static void testBypassTrigger(){
		TriggerExclusion.excludeTrigger('Account', true);
        Account person = Test_DataFactory.createPA(true, 'lastName', 'portalAcc@test.com', 'Customer');
		TriggerExclusion.excludeTrigger('Account', false);
    }
    
    
    @isTest
    private static void testUpdatePortalUser_NormalAccount(){
        Account personAcc = Test_DataFactory.createPA(true, 'lastName', 'portalAcc@test.com', 'Customer');       
    }
    
    @isTest
    private static void testUpdatePortalUser_PortalAccount(){
        Account personAcc = [  SELECT Id, PersonEmail, PersonMobilePhone, Salutation
                               FROM Account
                               WHERE PersonEmail = :email
                            ];
        
        personAcc.PersonMobilePhone = '91111222';
        personAcc.Salutation = 'Mr.';
        //update personAcc;
    }
}