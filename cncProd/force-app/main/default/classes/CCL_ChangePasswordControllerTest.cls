@isTest
private class CCL_ChangePasswordControllerTest {    
     static String email = 'patest@mail.com';
     @TestSetup
     static void setup() {
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
    static void test_ChangePasswordController() {
        PageReference pref = Page.CCL_RegistrationPage;      
        pref.getParameters().put('eventName','redirectPage');
        pref.getParameters().put('pageRef', '/startURL');
        Test.setCurrentPage(pref);
        
        User u = [SELECT Id, IsActive FROM User WHERE Email = :email];
        Site.forgotPassword(email);
        Test.startTest();
        System.runAs(u) {
            CCL_ChangePasswordController controller = new CCL_ChangePasswordController();
            controller.username = email;
            controller.password = 'Qwerty001'; 
            controller.verifyPassword = 'Qwerty001'; 
            
            controller.changePassword();        
        }
        Test.stopTest();        
    }
    
    @isTest
    static void test_SendEmail(){
        EmailTemplate e = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'JCC_Forgot_Password'];
        global_var__c globalVar = new global_var__c();
        globalVar.Password_Reset_EmailId__c = e.Id;
        insert globalVar;
        
        User u = [SELECT Id, IsActive FROM User WHERE Email = :email];
        CCL_ChangePasswordController controller = new CCL_ChangePasswordController();
        controller.sendEmail(new List<User>{u});
    }
}