@isTest
private class Test_myMBSiteLoginControllerTest {
    
    @TestSetup
    static void createData(){        
        Account testAccount = Test_DataFactory.createAccount(true, 'TestAccount');
        Account testPA = Test_DataFactory.createPerson(false, 'TestAccount', 'Customer');
        testPA.PersonEmail = 'pa2837@gmail.com';
        insert testPA;
        //Active Contact without Vehicle
        Contact testContact = Test_DataFactory.createContact(false, 'testContact', 'testLastName', testAccount.Id);
        testContact.email = 'testLogin@testLogin.com.cnc.testProd';
        testContact.Account__c = testPA.Id;
        insert testContact;
        testPA = [Select PersonContactId From Account WHERE ID = :testPA.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User activeUser = Test_DataFactory.createUserWithProfileID(false, 'actiFN', 'actiLN', testContact.email, p.Id);
        activeUser.ContactId = testPA.PersonContactId;
        activeUser.username = testContact.email;
        activeUser.isActive = true;
        activeUser.isValid__c = true;
        insert activeUser;
        
        Contact testInactiveContact = Test_DataFactory.createContact(false, 'testContact', 'testLastName', testAccount.Id);
        testInactiveContact.email = 'testLoginInactive@testLogin.com.cnc.testProd';
        insert testInactiveContact;
        
        User inaactiveUser = Test_DataFactory.createUser(false, 'activeTestUser', 'inann');
        inaactiveUser.username = testInactiveContact.email;
        inaactiveUser.isActive = false;
        inaactiveUser.isValid__c = false;
        insert inaactiveUser;
        
        Contact validContact = Test_DataFactory.createContact(false, 'validaContact', 'testLastName', testAccount.Id);
        validContact.email = 'validContact@testLogin.com.cnc.testProd';
        insert validContact;
        
        User validUser = Test_DataFactory.createUser(false, 'validUser', 'ann');        validUser.username = validContact.email;
        validUser.isActive = true;
        validUser.isValid__c = true;
        insert validUser;
        
        Registered_Vehicle__c testVehicle = Test_DataFactory.createregVehicle(true, 'testV123', 'CCI', 'MBP','testV123',validContact.id);
        testVehicle.Account__c = testAccount.Id;
        update testVehicle; 
    }
    
    @isTest
    private static void testActiveUserWithMBCar () {
        String email ='testLogin@test.com.cnc.testProd';
        Account testAccount = Test_DataFactory.createAccount(true, 'TestAccount');        
        Contact testContact = Test_DataFactory.createContact(true, 'testContact', 'testLastName', testAccount.Id);
                
        Account personAcc = Test_DataFactory.createPerson(false, 'TestAccount', 'Customer');
        personAcc.PersonEmail = 'test3726@hotmail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId FROM Account WHERE ID = :personAcc.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User activeUser = Test_DataFactory.createUserWithProfileID(false, 'actiFN', 'actiLN', testContact.Id, p.Id);
        activeUser.ContactId = personAcc.PersonContactId;
        activeUser.username = email;
        activeUser.isActive = true;
        activeUser.isValid__c = true;
        insert activeUser;
        
        Registered_Vehicle__c testVehicle = Test_DataFactory.createregVehicle(true, 'testV123', 'CCI', 'MBP','testV123', personAcc.PersonContactId);
        
        PageReference pref = new PageReference('MyMBSiteLogin');
        
        Test.setCurrentPage(pref);
        Test.startTest();
        
        MyMBSiteLoginController controller = new MyMBSiteLoginController ();
        controller.username = email;
        controller.password = 'Test@123'; 
        controller.login();
        
        //System.assertEquals(controller.login(),null);     
        Test.stopTest();                      
    }
    
    @isTest
    private static void testActiveUserWithoutMBCar () {
        PageReference pref = new PageReference('MyMBSiteLogin');
        
        Test.setCurrentPage(pref);
        Test.startTest();
        
        MyMBSiteLoginController controller = new MyMBSiteLoginController ();
        controller.username = 'validContact@testLogin.com.cnc.testProd';
        controller.password = 'Test@123'; 
        //System.assertEquals(controller.login(),null);
        Test.stopTest();                      
    }
    
    
    @isTest
    private static void testInactiveUser()
    {
        PageReference pref = Page.MyMBSiteLogin;      
        Test.setCurrentPage(pref);
        Test.startTest();
        
        MyMBSiteLoginController controller = new MyMBSiteLoginController ();
        
        controller.username = 'testLoginInactive@testLogin.com.cnc.testProd';
        controller.password = 'Welcome@01'; 
        controller.login();
        System.assertEquals(controller.login(),null);
        
        User activeButInvalidUser = [select Id, isValid__c, IsActive from user where Username =: controller.username limit 1];
        activeButInvalidUser.isActive = true;
        update activeButInvalidUser;
        
        controller.username = 'testLoginInactive@testLogin.com.cnc.testProd';
        controller.password = 'Welcome@01'; 
        PageReference pr = new PageReference('/loginResendActivation?id='+activeButInvalidUser.Id);
        
        Test.stopTest();            
    }
    
    @isTest
    private static void testInValidUser()
    {
        User user = [Select isValid__c From User WHERE FirstName = 'actiFN' AND LastName =  'actiLN'] ;
        user.isValid__c = false;
        update user;
        PageReference pref = Page.MyMBSiteLogin;      
        Test.setCurrentPage(pref);
        Test.startTest();
        
        MyMBSiteLoginController controller = new MyMBSiteLoginController ();
        
        controller.username = 'testLogin@testLogin.com.cnc.testProd';
        controller.password = 'Test@123'; 
        controller.login();
        System.assertNotEquals(controller.login(),null);
        Test.stopTest();            
    }
    
    @isTest
    private static void testNoUser()
    {
        
        PageReference pref = Page.MyMBSiteLogin;      
        Test.setCurrentPage(pref);
        Test.startTest();
        
        MyMBSiteLoginController controller = new MyMBSiteLoginController ();
        
        controller.username = 'abc@testLogin.com';
        controller.password = 'Welcome@01'; 
        controller.login();
        System.assertEquals(controller.login(),null);
        Test.stopTest();            
    }

    
}