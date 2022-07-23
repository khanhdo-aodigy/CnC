/**
 * An apex page controller that exposes the site login functionality
 *
 */
@IsTest global with sharing class SiteLoginControllerTest {

    @TestSetup
    static void makeData(){
        //UserRole r = new UserRole(name = 'TEST ROLE');
        //Database.insert(r);
    
        //User userWithRole = new User(alias = 'a9l9i9', email='dummyLoginCNC123@testuser.com', /*userroleid = r.id,*/
                                     //emailencodingkey='UTF-8', lastname='dummy', FirstName = 'LoginCNC123', languagelocalekey='en_US', 
                                     //localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                    // timezonesidkey='America/Los_Angeles', username='dummyLoginCNC123@testuser.com');
        
        List<Account> lstAccts = new List<Account>(); 
        //System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            lstAccts.add( new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccount1', LastName = 'Dummy', PersonEmail = 'test111cnc@user.com') );
            lstAccts.add( new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccount2', LastName = 'Dummy', PersonEmail = 'test222cnc@user.com') );
            lstAccts.add( new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccount3', LastName = 'Dummy', PersonEmail = 'test333cnc@user.com') );
            insert lstAccts;
        //}
        
        List<Account> lstAcc = [SELECT PersonContactId FROM Account WHERE Id IN: lstAccts];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User u = new User(
            FirstName = 'TestPersonAccount1',
            LastName = 'Dummy',
            Email = 'test111cnc@user.com',
            Username = 'test111cnc@user.com',
            Alias = 'TestPA1', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = lstAcc.get(0).PersonContactId,
            IsActive = true,
            isValid__c = true);
        insert u;

        User u2 = new User(
            FirstName = 'TestPersonAccount2',
            LastName = 'Dummy',
            Email = 'test222cnc@user.com',
            Username = 'test222cnc@user.com',
            Alias = 'TestPA2', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = lstAcc.get(1).PersonContactId,
            IsActive = true,
            isValid__c = false);
        insert u2;

        User u3 = new User(
            FirstName = 'TestPersonAccount3',
            LastName = 'Dummy',
            Email = 'test333cnc@user.com',
            Username = 'test333cnc@user.com',
            Alias = 'TestPA3', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = lstAcc.get(2).PersonContactId,
            IsActive = false,
            isValid__c = true);
        insert u3;
    }

    @IsTest//(SeeAllData=true) 
    global static void testSiteLoginController1 () {
        // Instantiate a new controller with all parameters in the page
            PageReference pref = Page.SiteLogin;      
            pref.getParameters().put('startURL','test.salesforce.com');    
            pref.getHeaders().put('USER-AGENT', 'Android');
            Test.setCurrentPage(pref);
            Test.startTest();
    
                SiteLoginController controller = new SiteLoginController ();
                controller.username = 'test111cnc@user.com';
                controller.password = 'Test@123'; 
                controller.login();
            Test.stopTest();   
            // System.assertEquals(controller.login(),null);                 
    }


    @IsTest
    static void testSiteLoginController2 () {

            PageReference pref = Page.SiteLogin;      
            pref.getParameters().put('startURL','test.salesforce.com');  
            pref.getHeaders().put('USER-AGENT', 'UNKNOWN');
            Test.setCurrentPage(pref);
            Test.startTest();
    
                SiteLoginController controller = new SiteLoginController ();
                controller.username = 'test222cnc@user.com';
                controller.password = 'Test@123'; 
                controller.login();    
            Test.stopTest();                 
    }


    @IsTest
    static void testSiteLoginController3 () {

            PageReference pref = Page.SiteLogin;      
            pref.getParameters().put('startURL','test.salesforce.com');  
            pref.getHeaders().put('USER-AGENT', 'ALIEN');
            Test.setCurrentPage(pref);
            Test.startTest();
                
                SiteLoginController controller = new SiteLoginController ();
                controller.username = 'test333cnc@user.com';
                controller.password = 'Test@123'; 
                controller.login();    
            Test.stopTest();                 
    }

	
     @IsTest//(SeeAllData=true) 
     global static void testSiteLoginControllerInActiveAccount()
     {
         	PageReference pref = Page.SiteLogin;      
            Test.setCurrentPage(pref);
            Test.startTest();
    
            SiteLoginController controller = new SiteLoginController ();
            controller.username = 'test111cnc@user.com';
            controller.password = 'Welcome@01'; 
         	List <User> us = [select Id, isValid__c, IsActive from user where Username =: controller.username];
         	PageReference pr = new PageReference('/loginResendActivation?id='+us[0].Id);
            PageReference login = controller.login();
            // System.assertEquals(login.getUrl(),pr.getUrl());         
     }
    @IsTest//(SeeAllData=true) 
    global static void testSiteLoginControllerForInvalidUserName()
     {
         	PageReference pref = Page.SiteLogin;      
            Test.setCurrentPage(pref);
            Test.startTest();
    
            SiteLoginController controller = new SiteLoginController ();
            controller.username = 'test000cnc@user.com';
            controller.password = 'Test@1234'; 
			controller.login();
            // System.assertEquals(controller.login(),null);         
     }
    @IsTest//(SeeAllData=true) 
    global static void testSiteLoginControllerForInactiveUser()
     {
         	PageReference pref = Page.SiteLogin;      
            Test.setCurrentPage(pref);
            Test.startTest();
    
            SiteLoginController controller = new SiteLoginController ();
            controller.username = 'test@user.com';
            controller.password = 'Test@1234'; 
			controller.login();
            // System.assertEquals(controller.login(),null);         
     }
}