@IsTest public with sharing class forgotPasswordExpiredControllerTest {
	@IsTest(SeeAllData=true) public static void testforgotPasswordExpiredController() {
    	// Instantiate a new controller with all parameters in the page
		
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        PageReference pref = Page.forgotpasswordconfirm;      
        pref.getParameters().put('isForgot=','true');
        pref.getParameters().put('channel=','web');
        Test.setCurrentPage(pref);
        Test.startTest();

    	forgotPasswordConfirmExpiredController controller = new forgotPasswordConfirmExpiredController();
        controller.username = 'sapientuser@sapient.com';
        PageReference returnToLogin = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		PageReference pr = controller.returnToLogin();
    	//System.assertEquals(pr.getUrl(),returnToLogin.getUrl()); 
    }
	@IsTest(SeeAllData=true) public static void testupdateUserAnalytics() {
    	// Instantiate a new controller with all parameters in the page
		
        PageReference pref = Page.forgotpasswordconfirm;      
        pref.getParameters().put('isForgot=','true');
        pref.getParameters().put('channel=','web');
        Test.setCurrentPage(pref);
        Test.startTest();
    	forgotPasswordConfirmExpiredController controller = new forgotPasswordConfirmExpiredController();
        controller.username = 'sapientadmin@sapient.com';
		controller.updateUserAnalytics();
    	//System.assertEquals(controller.updateUserAnalytics()); 
    }
}