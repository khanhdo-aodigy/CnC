@IsTest public with sharing class LoginResendActivationControllerTest {

    @IsTest(SeeAllData=true) public static void testIsAccountActivated() {
    	// Instantiate a new controller with all parameters in the page
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        String  Account_Activation_EmailId = (String)JCC_GlobalVar.Account_Activation_EmailId__c;
        PageReference pref = Page.loginResendActivation;      
        pref.getParameters().put('id','0050K000008auY6QAI');
        Test.setCurrentPage(pref);
        Test.startTest();
        
    	LoginResendActivationController controller = new LoginResendActivationController();
        Blob data = Blob.valueOf('0050K000008auY6QAI');
        String b64encryptedData = EncodingUtil.base64Encode(data);
        Blob randomdata = Blob.valueOf('930807');
        String b64encryptedrandomData = EncodingUtil.base64Encode(randomdata);
        PageReference signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation');
		PageReference loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
        PageReference pr = controller.resendEmail();
        //PageReference pageRef = controller.forwardRequest();
        //system.assertEquals(pr.getUrl(), signupSuccessPageRef.getUrl());
	//	system.assertEquals(pageRef.getUrl(), loginPageRef.getUrl());
    }
}