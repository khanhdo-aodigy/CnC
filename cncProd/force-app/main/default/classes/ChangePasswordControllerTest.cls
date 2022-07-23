/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest public with sharing class ChangePasswordControllerTest {
   	@IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
    	String  Password_Reset_EmailId = (String)JCC_GlobalVar.Password_Reset_EmailId__c;
        PageReference pref = Page.forgotpasswordconfirm;      
        pref.getParameters().put('isForgot=','true');
        pref.getParameters().put('channel=','web');
        pref.getHeaders().put('USER-AGENT',  'Android Chrome');
        Test.setCurrentPage(pref);
        Test.startTest();

        ChangePasswordController controller = new ChangePasswordController();
        PageReference pg = new PageReference ('/apex/ChangePasswordConfirmation?event=ChangePassword_Email_Sent');
        controller.username = 'dlamba@sapient.com';
        controller.oldPassword = 'Test@1234';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1'; 
        List <User> us = [Select Id, FirstName,LastName,Username,channel__c from User where Username=: controller.username];
        controller.changePassword();
        // System.assertEquals(controller.changePassword(),null);  
        controller.SendEmail(us);
    } 
 }