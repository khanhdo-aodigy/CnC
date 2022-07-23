/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest public with sharing class ForgotPasswordControllerTest {
  	 @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page

        PageReference prefForgotPassword = Page.forgotpasswordconfirm;
        PageReference pref = Page.ForgotPassword;      
        pref.getParameters().put('isForgot=','true');
        pref.getParameters().put('channel=','web');
        Test.setCurrentPage(pref);
        Test.startTest();

    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@gmail.com'; 
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}