@isTest
private class CCL_AppServiceTest {
	private static String email = 'patest@mail.com';
    private static String password = 'MyPassword123';
    
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
    
    //Test Login -- START
	 @isTest
     private static void test_Login() {
        CCL_AppService.LoginRequestWrapper request = new CCL_AppService.LoginRequestWrapper();
        request.email     = email;
        request.password  = password;
        request.startURL  = '/testing'; 
        CCL_AppService.doLogin(request);
    }
    
     @isTest
     private static void test_Login_InactiveUser() {
        User u = [SELECT Id, IsActive FROM User WHERE Email = :email];
        u.IsActive = false;
        update u;
        
        CCL_AppService.LoginRequestWrapper request = new CCL_AppService.LoginRequestWrapper();
        request.email     = email;
        request.password  = 'Testing1234';
        request.startURL  = '/testing';
        try {
            CCL_AppService.doLogin(request);
        } catch(Exception ex) {
            System.assertEquals('Inactive User', ex.getMessage());
        }
        
    }
    
     @isTest
     private static void test_Login_InvalidEmail() {
        
        CCL_AppService.LoginRequestWrapper request = new CCL_AppService.LoginRequestWrapper();
        request.email     = 'nonexist@mail.com';
        request.password  = 'Testing1234';
        request.startURL  = '/testing'; 
        
        try {
            CCL_AppService.doLogin(request);
        } catch(Exception ex) {
            System.assertEquals('Invalid Email', ex.getMessage());
        }
    }
    //Test Login -- END
    
    
   //Test ForgotPassword - START
    @isTest
    private static void test_ForgotPassword(){
       CCL_AppService.handleForgotPassword(email);        
   }
    
    @isTest
    private static void test_ForgotPassword_InvalidEmail(){
       try {
            CCL_AppService.handleForgotPassword('nonexist@mail.com');
        } catch(Exception ex) {
            System.assertEquals('Invalid', ex.getMessage());
        }               
   }
   
    @isTest
    private static void test_ForgotPassword_InactiveUser(){
        User u = [SELECT Id, IsActive FROM User WHERE Email = :email];
        u.IsActive = false;
        update u;
        try {
            CCL_AppService.handleForgotPassword(email);
        } catch(Exception ex) {
            //System.assertEquals('Inactive', ex.getMessage());
        }               
   }
   //Test ForgotPassword - END
    
    
    //Test Register - START
    @isTest
    private static void test_GetSalutationValues(){
        CCL_AppService.getSalutationValues();
    }
    
    @isTest
    private static void test_IsEmailExist(){
        CCL_AppService.isEmailExist(email);
    }
    
    @isTest
    private static void test_CreateUser_Individual(){
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'individual';
        request.salutation = 'Mr.';
        request.firstname = 'Mimi';
        request.lastname = 'Lee';
        request.email = 'mimilee@test.com';
        request.mobile = '92343343';  
        request.password = 'Testing01';   
        request.confirmPassword = 'Testing01';  
        request.individualPDPA = true;

        CCL_AppService.SignUpResponse response = CCL_AppService.createUser(request);  
        List<Account> prospect = [ SELECT Id, Salutation, FirstName, LastName, PersonEmail, PersonMobilePhone,
                                                    PDPA__pc, SMS__pc, Call__pc, Email__pc, Fax__pc, Source__pc
                                             FROM Account
                                        ];
        System.debug('result = ' + prospect);
    }
    
    @isTest
    private static void test_CreateUser_Corporate(){
        Account company = new Account();
        company.Name = 'My Carriage';
        company.Registration_No__c = 'MYCARRIAGE_UNIQUE_001';
        insert company;
        
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'corporate';
        request.companyName = 'My Carriage';
        request.companyReg = 'MYCARRIAGE_UNIQUE_001';
        request.conSalutation = 'Mr.';
        request.conFirstname = 'Mimi';
        request.conLastname = 'Lee';
        request.contactEmail = 'mimilee@test.com';
        request.contactMobile = '92343343';  
        request.contactDesignation = 'Marketing Manager';
        request.contactPwd = 'Testing01';   
        request.contactConfirmPwd = 'Testing01'; 
        request.contactPDPA = true;
        
        CCL_AppService.SignUpResponse response = CCL_AppService.createUser(request);
        List<Contact> contact =  [ SELECT Id, Salutation, FirstName, LastName, Email, MobilePhone,
                                                    PDPA__c, SMS__c, Call__c, Email__c, Fax__c, Source__c
                                             FROM Contact
                                  WHERE Id = :response.conId
                                        ];
        System.debug('result = ' + contact);
    }
    
    @isTest
    private static void test_CreateUser_Individual_ExistingAccount(){        
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'mimilee@test.com';
        insert personAcc;
        
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'individual';
        request.salutation = 'Mr.';
        request.firstname = 'Mimi';
        request.lastname = 'Lee';
        request.contactDesignation = 'Marketing Manager';
        request.email = 'mimilee@test.com';
        request.mobile = '92343343';  
        request.password = 'Testing01';   
        request.confirmPassword = 'Testing01';  
        request.individualPDPA = true;
        
        CCL_AppService.SignUpResponse response = CCL_AppService.createUser(request);    
    }
    
    @isTest
    private static void test_CreateUser_Corporate_ExistingAccount(){
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'corporate';
        request.companyName = 'My Carriage';
        request.companyReg = 'MYCARRIAGE_UNIQUE_001';
        request.conSalutation = 'Mr.';
        request.conFirstname = 'Mimi';
        request.conLastname = 'Lee';
        request.contactDesignation = 'Marketing Manager';
        request.contactEmail = 'mimilee@test.com';
        request.contactMobile = '92343343';  
        request.contactPwd = 'Testing01';   
        request.contactConfirmPwd = 'Testing01';
        request.contactPDPA = true;
        
        CCL_AppService.SignUpResponse response = CCL_AppService.createUser(request);
        try{
            CCL_AppService.resendOTP(request, response);
        } catch(Exception ex){
            System.debug(ex);
        } 
    }
    //Test Register - END
    
    //Test Verify - START    
    @isTest
    private static void test_VerifyUser_Individual(){
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'mimilee@test.com';
        insert personAcc;
        
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'individual';
        request.salutation = 'Mr.';
        request.firstname = 'Mimi';
        request.lastname = 'Lee';
        request.email = 'mimilee@test.com';
        request.mobile = '92343343';  
        request.password = 'Testing01';   
        request.confirmPassword = 'Testing01';
        request.individualPDPA = true;
        
        CCL_AppService.SignUpResponse response = CCL_AppService.createUser(request);
        try{
            CCL_AppService.verifyUser('234252', request, response, '/startURL');
        } catch(Exception ex){
            System.debug(ex);
        }        
        
    }
    //Test VerifyUser - END
    
    
    //Test update Prospect
    @isTest
    private static void test_UpdateProspect(){
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'individual';
        request.salutation = 'Mr.';
        request.firstname = 'Mimi';
        request.lastname = 'Lee';
        request.email = 'mimilee@test.com';
        request.mobile = '92343343';  
        request.password = 'Testing01';   
        request.confirmPassword = 'Testing01';
        request.individualPDPA = false;
        Account prospect = new Account();
        CCL_AppService.updateProspect(prospect, request);
    }
    
    //Test update Contact
    @isTest
    private static void test_UpdateContact(){
        CCL_AppService.SignUpRequest request = new CCL_AppService.SignUpRequest();
        request.customerType = 'corporate';
        request.companyName = 'My Carriage';
        request.companyReg = 'MYCARRIAGE_UNIQUE_001';
        request.conSalutation = 'Mr.';
        request.conFirstname = 'Mimi';
        request.conLastname = 'Lee';
        request.contactDesignation = 'Marketing Manager';
        request.contactEmail = 'mimilee@test.com';
        request.contactMobile = '92343343';  
        request.contactPwd = 'Testing01';   
        request.contactConfirmPwd = 'Testing01';  
        request.contactPDPA = false;
        
        Contact contact = new Contact();
        CCL_AppService.updateContact(contact, request);
      }
    
}