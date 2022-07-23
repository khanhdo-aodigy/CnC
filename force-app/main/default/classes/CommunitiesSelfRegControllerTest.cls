/**
* An apex page controller that supports self registration of users in communities that allow self registration
*/
@IsTest(seeAllData=false)
private class CommunitiesSelfRegControllerTest 
{    
    @testSetUp
    static void createData()
    {  
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'End User' limit 1];       
        account acc = Test_DataFactory.createAccount(True,'fefwef');       
        Contact con = Test_DataFactory.createContact(True,'testxxx','test2',acc.id);
        con.NRIC_Passport_No__c = 'S12315031993';  
        con.mobilePhone = String.valueOf('6584636');
        con.Source__c = 'DWH';
        update con;           
        user uc = Test_DataFactory.createUserWithProfileID(false,'re','re','test@force.com',userProfile.id);
        //uc.nric__c = 'zsdfzsdd';   
        uc.contactId = con.id;    
        uc.Account_Activation_Random_Number__c = '504503';
        uc.isValid__c = false;
        //insert uc; 
        
        account acc2 = Test_DataFactory.createAccount(True,'JCC2333');        
        Contact con2 = Test_DataFactory.createContact(True,'aweawe','afawefw',acc2.id);
        con2.NRIC_Passport_No__c = 'S12315031993';  
        con2.mobilePhone = String.valueOf('6584636');
        con2.Source__c = 'DWH';
        update con2; 
        user u2= Test_DataFactory.createUserWithProfileID(false,'ycvyt','ytcxr','test@gmail.com',userProfile.id);  
        u2.contactId = con2.id;
        //insert u2;
        global_var__c jjcVal = new global_var__c ();
        jjcVal.Account_Activation_EmailId__c = String.valueOf(System.url.getsalesforcebaseurl()).contains('pa') ? '00X0K000001XGGH' : (ADGLIB_UtilityHelper.isSandbox() ? '00Xp0000000I2bZ' : '00X0K000001XGGH');
        jjcVal.TriggeredSmsIdSignUp__c = 'zzzxxxccc';
        insert jjcVal;         
    }
      
    private static testmethod void testCommunitiesSelfRegController() 
    {            
        //Contact contact = [Select id,lastname from contact where lastname ='afawefw'];
        //user u2 = [select id from user where contactid=: contact.id];
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        Contact contact = [SELECT Id FROM Contact WHERE AccountId =: personAcc.Id];
        
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
                          ContactId= contact.Id, 
                          isValid__c = true);
        insert u;
        PageReference pref = Page.OTPGeneration;      
        pref.getParameters().put('id',contact.Id);
        Test.setCurrentPage(pref);
        Test.startTest();  
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'zsdfs@force.com';           
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        controller.registerNewUser();
        controller.ResendActivation(u.id,'a234234');
        controller.forwardRequestToLogin();
        Test.stopTest();  
    } 
    
    private static testmethod void testCommunitiesSelfRegController2()
    {                  
        PageReference pref = Page.OTPGeneration;  
        Account personAcc = Test_DataFactory.createPerson(false, 'Test2', 'Prospect');
        personAcc.PersonEmail = 'patest123@hotmail.com';
        insert personAcc;
        Contact contact = [SELECT Id FROM Contact WHERE AccountId =: personAcc.Id];       
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa23',
                          Email='patest123@hotmail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Test2', 
                          FirstName= 'Secord',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest123@hotmail.com', 
                          ContactId= contact.Id, 
                          isValid__c = true);
        insert u; 
        pref.getParameters().put('id',contact.Id);
        Test.setCurrentPage(pref);
        Test.startTest();  
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'patest123@hotmail.com';           
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        controller.registerNewUser();
        controller.forwardRequestLink();
        controller.ResendActivationLink(); 
        controller.refreshPage();
        Test.stopTest();  
    } 
    
    /*
    private static testmethod void testCommunitiesSelfRegController3() {                   
        Contact contact = [Select id,lastname from contact where lastname ='test2'];   
        PageReference pref = Page.CreateAccount; 
        pref.getParameters().put('id',contact.Id);     
        Test.setCurrentPage(pref);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);      
        controller.email = 'dfgxdfg@gmail.com';           
        controller.password = '';
        controller.confirmPassword = 'abcd1234';
        controller.registerNewUser();
        Test.stopTest();  
    } 
    
    private static testmethod void testCommunitiesSelfRegController4() {                   
        
        Contact contact = [Select id,lastname from contact where lastname ='test2'];   
        
        PageReference pref = Page.CreateAccount; 
        pref.getParameters().put('id',contact.Id);     
        Test.setCurrentPage(pref);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);      
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = '';           
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        controller.registerNewUser();
        Test.stopTest();  
    } 
    private static testmethod void testCommunitiesSelfRegController5() {  
        Profile userProfile = [select id from profile where name like '%End User%' limit 1];     
        Account pa = Test_DataFactory.createPerson(false, 'name2', 'Customer');
        pa.PersonEmail = 'abc@123.com';  
        insert pa;
        
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccAccount090');

        Contact con = Test_DataFactory.createContact(false,'321','123',jccAcct.id);
        con.NRIC_Passport_No__c = 'S12315031993';  
        con.mobilePhone = String.valueOf('6584636');
        con.Source__c = 'DWH';
        con.Account__c = pa.Id;
        insert con; 
        
        pa = [Select PersonContactId From Account WHERE Id = :pa.Id ];
        
        user u2= Test_DataFactory.createUserWithProfileID(false,'ycvyt','ytcxr','test@gmail.com',userProfile.id);  
        u2.contactId = pa.PersonContactId;
        u2.Email = 'abc@12.com';
        u2.IsValid__c = true;
        insert u2;
        
        PageReference pref = Page.CreateAccount; 
        pref.getParameters().put('id',con.Id);   
        Test.setCurrentPage(pref);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);      
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'abc@12.com';           
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        controller.registerNewUser();
        controller.registerNewUser();
        controller.forwardRequestLink();
        controller.refreshPage();
        Test.stopTest();  
    }*/ 
    
    // @isTest
    static void paTMWeb(){
        
        List<Folder>lstFolders = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public'];

        String eVar = '{!Community_Url}{!Receiving_User.LastName}';
        EmailTemplate et = new EmailTemplate (DeveloperName = 'Test', FolderId= lstFolders.get(0).Id, TemplateType= 'custom', HtmlValue = eVar , Body=eVar, Name = 'Test', Subject = 'testSubject', IsActive = true); 
        insert et;

        String xxx = global_var__c.getOrgDefaults().Account_Activation_EmailId__c;
        System.debug('testing---xxx='+ xxx);

        //Create Portal User
        UserRole role = new UserRole(name = 'TEST ROLE');
        Database.insert(role);
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole1@roletest.com', /*userroleid = role.Id,*/
                                     emailencodingkey='UTF-8', lastname='TestingPU1', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileId = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole1@testorg.com');
        
        Account personAcct;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            personAcct = new Account( RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'portalTestUser@email.com');
            Database.insert(personAcct);

            
            global_var__c setting = new global_var__c();
            setting.Account_Activation_EmailId__c = et.Id;
            setting.TriggeredSmsIdSignUp__c = 'zzzz12345';
            //insert setting;
        }


        personAcct = [SELECT ID, FirstName, LastName, PersonEmail, PersonContactId FROM Account WHERE ID =: personAcct.Id];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='End User' Limit 1];
        User user1 = new User(
            UserName    = 'portalTestUser@email.com',
            FirstName   = personAcct.FirstName,
            LastName    = personAcct.LastName,
            Alias       = 'test123',
            email       = personAcct.PersonEmail,
            ContactId   = personAcct.PersonContactId,
            ProfileId   = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);
        
        
        Contact paContact = [SELECT ID FROM Contact WHERE IsPersonAccount = true AND AccountId =:personAcct.Id ];
        
        List<User> lstUser = [SELECT Id, IsValid__c, IsPortalEnabled, Email FROM USER WHERE IsPortalEnabled = true AND Email = 'portalTestUser@email.com' ];
        System.debug('@@@@DEBUG paTM :: lstUser = ' +lstUser.size() + ' --- ' + lstUser);
        
        PageReference pref = Page.OTPGeneration;      
        pref.getParameters().put('id',paContact.Id);
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        System.Test.startTest();  
            
            
            String yyy = global_var__c.getOrgDefaults().Account_Activation_EmailId__c;
            System.debug('testing---yyy='+ yyy);
            ApexPages.StandardController sc = new ApexPages.StandardController(paContact);
            CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);
            //controller.getPersonAccount();
            controller.setemail('portalTestUser@email.com');
            controller.setemail2('portalTestUser@email.com');
            controller.ResendActivationLink();
            
            controller.firstName        = 'FirstName';
            controller.lastName         = 'LastName';        
            controller.password         = 'xyz12345';
            controller.confirmPassword  = 'xyz12345';
            controller.registerNewUser();
            
            
            controller.setemail('portalTestUser2@email.com');
            controller.setemail2('portalTestUser2@email.com');
            controller.password         = 'xyz12346';
            controller.confirmPassword  = 'xyz12345';
            controller.registerNewUser();
            
            controller.password         = 'xyz12345';
            controller.confirmPassword  = 'xyz12345';
            controller.registerNewUser();

            controller.forwardRequestToLogin();
            // controller.forwardRequestLink();
            controller.refreshPage();
        System.Test.stopTest();
    }
    
    
    //@isTest
    static void paTMNonWeb(){
        
        List<Folder>lstFolders = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public'];

        String eVar = '{!Community_Url}{!Receiving_User.LastName}';
        EmailTemplate et = new EmailTemplate (DeveloperName = 'Test', FolderId= lstFolders.get(0).Id, TemplateType= 'custom', HtmlValue = eVar , Body=eVar, Name = 'Test', Subject = 'testSubject', IsActive = true); 
        insert et;

        String xxx = global_var__c.getOrgDefaults().Account_Activation_EmailId__c;
        System.debug('testing---xxx='+ xxx);

        //Create Portal User
        UserRole role = new UserRole(name = 'TEST ROLE');
        Database.insert(role);
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole1@roletest.com', userroleid = role.Id,
                                     emailencodingkey='UTF-8', lastname='TestingPU2', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileId = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole2@testorg.com');
        
        Account personAcct;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            personAcct = new Account( RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'portalTestUser@email.com');
            Database.insert(personAcct);

            
            global_var__c setting = new global_var__c();
            setting.Account_Activation_EmailId__c = et.Id;
            setting.TriggeredSmsIdSignUp__c = 'zzzz12345';
            //insert setting;
        }


        personAcct = [SELECT ID, FirstName, LastName, PersonEmail, PersonContactId FROM Account WHERE ID =: personAcct.Id];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='End User' Limit 1];
        User user1 = new User(
            UserName    = 'portalTestUser@email.com',
            FirstName   = personAcct.FirstName,
            LastName    = personAcct.LastName,
            Alias       = 'test123',
            email       = personAcct.PersonEmail,
            ContactId   = personAcct.PersonContactId,
            ProfileId   = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);
        
        
        Contact paContact = [SELECT ID FROM Contact WHERE IsPersonAccount = true AND AccountId =:personAcct.Id ];
        
        List<User> lstUser = [SELECT Id, IsValid__c, IsPortalEnabled, Email FROM USER WHERE IsPortalEnabled = true AND Email = 'portalTestUser@email.com' ];
        System.debug('@@@@DEBUG paTM :: lstUser = ' +lstUser.size() + ' --- ' + lstUser);
        
        PageReference pref = Page.OTPGeneration;      
        pref.getParameters().put('id',paContact.Id);
        Test.setCurrentPage(pref);
        System.Test.startTest();  
            
            String yyy = global_var__c.getOrgDefaults().Account_Activation_EmailId__c;
            System.debug('testing---yyy='+ yyy);
            ApexPages.StandardController sc = new ApexPages.StandardController(paContact);
            CommunitiesSelfRegController controller = new CommunitiesSelfRegController(sc);
            //controller.getPersonAccount();
            controller.setemail('portalTestUser@email.com');
            controller.setemail2('portalTestUser@email.com');
            controller.generateOTP();
            controller.ResendActivationLink();
            
            controller.firstName        = 'FirstName';
            controller.lastName         = 'LastName';        
            controller.password         = 'xyz12345';
            controller.confirmPassword  = 'xyz12345';
            controller.registerNewUser();
            
            
            controller.setemail('portalTestUser2@email.com');
            controller.setemail2('portalTestUser2@email.com');
            controller.password         = 'xyz12346';
            controller.confirmPassword  = 'xyz12345';
            controller.registerNewUser();
            
            controller.password         = 'xyz12345';
            controller.confirmPassword  = 'xyz12345';
            controller.registerNewUser();

            controller.forwardRequestToLogin();
            //controller.forwardRequestLink();
            //controller.refreshPage();
        System.Test.stopTest();
    }
}