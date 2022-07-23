@IsTest public with sharing class SignupSuccessControllerTest {

    @IsTest(SeeAllData=true) public static void testIsSignupSuccess() {
    	// Instantiate a new controller with all parameters in the page
    	
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        PageReference pref = Page.SignupSuccess;  
        Blob data = Blob.valueOf('0050K000008Y04U');
        String b64encryptedData = EncodingUtil.base64Encode(data);
        pref.getParameters().put('id',b64encryptedData);
        pref.getParameters().put('request','Signup');
        Test.setCurrentPage(pref);
        Test.startTest();
        
    	SignupSuccess controller = new SignupSuccess();
        PageReference PageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		controller.mapAccount();
        PageReference loginPageRef = controller.forwardRequestToLogin();
        //system.assertEquals(loginPageRef.getUrl(), PageRef.getUrl());
    }
    @IsTest(SeeAllData=true) public static void IsresendAccountActivation() {
    	// Instantiate a new controller with all parameters in the page
    	
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        PageReference pref = Page.SignupSuccess;  
        Blob data = Blob.valueOf('0050K000008Y04U');
        String b64encryptedData = EncodingUtil.base64Encode(data);
        pref.getParameters().put('id',b64encryptedData);
        pref.getParameters().put('request','resendAccountActivation');
        Test.setCurrentPage(pref);
        Test.startTest();
        
    	SignupSuccess controller = new SignupSuccess();
        PageReference PageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		controller.mapAccount();
        PageReference loginPageRef = controller.forwardRequestToLogin();
       // system.assertEquals(loginPageRef.getUrl(), PageRef.getUrl());
    }
}