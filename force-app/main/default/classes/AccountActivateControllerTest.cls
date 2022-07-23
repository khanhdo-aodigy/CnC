@isTest
private class AccountActivateControllerTest {
    @testSetup
    private static void setup() {
        EmailTemplate e = [SELECT Id FROM EmailTemplate WHERE Name = 'JCC Account Activation'];
        global_var__c globalVar = new global_var__c();
        globalVar.Account_Activation_EmailId__c = e.Id;
        insert globalVar;
        System.debug('globalVar = ' + globalVar);
    }

    @isTest
    private static void testIsAccountActivate_ActivationLinkIsActive() {
        String codeString = '930807';
        
        User testUser = Test_DataFactory.createUser(false, 'Account Activate', 'aaTest');
        testUser.IsActivationLinkActive__c = 'Active';
        testUser.Account_Activation_Random_Number__c = codeString;
        testUser.Account_Activation_Request__c = Datetime.now();
        insert testUser;
    	
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        
        PageReference pref = Page.AccountActivationRequest;  
        
        Blob data = Blob.valueOf(testUser.Id);
        String b64encryptedData = EncodingUtil.base64Encode(data);
        Blob code = Blob.valueOf(codeString);
        String b64encryptedCode = EncodingUtil.base64Encode(code);
        
        pref.getParameters().put('identity',b64encryptedData);
        pref.getParameters().put('code',b64encryptedCode);
        Test.setCurrentPage(pref);
        Test.startTest();
       
    	AccountActivate controller = new AccountActivate();
        PageReference PageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		PageReference accountPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation');
        controller.userIsActive();
        controller.activationLinkValidity();
        controller.InvalidAppRequest();
        PageReference loginPageRef = controller.forwardRequest();
        
        
        PageReference ActivationPageRef = controller.resendActivationLink();
    }
    
    @isTest
    private static void testIsAccountActivate_ActivationLinkIsInactive() {
        String codeString = '930807';
        
        User testUser = Test_DataFactory.createUser(false, 'Account Activate', 'aaTest');
        testUser.IsActivationLinkActive__c = 'Inactive';
        testUser.Account_Activation_Random_Number__c = codeString;
        testUser.Account_Activation_Request__c = Datetime.now();
        insert testUser;
    	
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        
        PageReference pref = Page.AccountActivationRequest;  
        
        Blob data = Blob.valueOf(testUser.Id);
        String b64encryptedData = EncodingUtil.base64Encode(data);
        Blob code = Blob.valueOf(codeString);
        String b64encryptedCode = EncodingUtil.base64Encode(code);
        
        pref.getParameters().put('identity',b64encryptedData);
        pref.getParameters().put('code',b64encryptedCode);
        Test.setCurrentPage(pref);
        Test.startTest();
       
    	AccountActivate controller = new AccountActivate();
        PageReference PageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		PageReference accountPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation');
        controller.activationLinkValidity();
        PageReference loginPageRef = controller.forwardRequest();
        PageReference ActivationPageRef = controller.resendActivationLink();
    }
    
    @isTest
    private static void testIsAccountActivate_ActivationEnlapseBefore72h_ActivationLinkExpired() {
        User testUser = Test_DataFactory.createUser(false, 'Account Activate', 'aaTest');
        testUser.Account_Activation_Request__c = Datetime.now().addHours(-80);
        insert testUser;
    	
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        
        
        
        
        PageReference pref = Page.AccountActivationRequest;  
        
        Blob data = Blob.valueOf(testUser.Id);
        String b64encryptedData = EncodingUtil.base64Encode(data);
        Blob code = Blob.valueOf('930807');
        String b64encryptedCode = EncodingUtil.base64Encode(code);
        
        pref.getParameters().put('identity',b64encryptedData);
        pref.getParameters().put('code',b64encryptedCode);
        Test.setCurrentPage(pref);
        Test.startTest();
       
    	AccountActivate controller = new AccountActivate();
        PageReference PageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		PageReference accountPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation');
        controller.activationLinkValidity();
        PageReference loginPageRef = controller.forwardRequest();
        PageReference ActivationPageRef = controller.resendActivationLink();
    }
    
    @isTest
    private static void testIsAccountActivate_CodeNotMatch() {
        String codeString = '930807';
        
        User testUser = Test_DataFactory.createUser(false, 'Account Activate', 'aaTest');
        testUser.IsActivationLinkActive__c = 'Active';
        testUser.Account_Activation_Random_Number__c = codeString;
        testUser.Account_Activation_Request__c = Datetime.now();
        insert testUser;
    	
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
        String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
        
        PageReference pref = Page.AccountActivationRequest;  
        
        Blob data = Blob.valueOf(testUser.Id);
        String b64encryptedData = EncodingUtil.base64Encode(data);
        Blob code = Blob.valueOf('986878');
        String b64encryptedCode = EncodingUtil.base64Encode(code);
        
        pref.getParameters().put('identity',b64encryptedData);
        pref.getParameters().put('code',b64encryptedCode);
        Test.setCurrentPage(pref);
        Test.startTest();
       
    	AccountActivate controller = new AccountActivate();
        PageReference PageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&response_type=token');
		PageReference accountPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation');
        controller.activationLinkValidity();
        PageReference loginPageRef = controller.forwardRequest();
        PageReference ActivationPageRef = controller.resendActivationLink();
    }
}