global without sharing class LoginResendActivationController {
    global String email {get; set;}
    global String id {get;set;}
    global DateTime timestamp {get;set;}
    global Boolean globalHeader {get;set;}
    global Boolean mobileHeader {get;set;}
    Public Boolean globalFooter {get;set;}
    public String randStr;
    public String PageUrl;
    //public channel;
    User_Analytics__c analytics = new User_Analytics__c();
   	global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    Public String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    Public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    Public String  Account_Activation_EmailId = (String)JCC_GlobalVar.Account_Activation_EmailId__c;
    Public String  MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    Public String  WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    Public String  SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
	Public String  SF_Mobile_App_MYMB_ClientID = (String)JCC_GlobalVar.mymb_mobile_app__c; //MyMB Fix
	Public String  MobileRedirect_URI_MB = (String)JCC_GlobalVar.MobileRedirect_URI_MB__c; //MyMb Fix
	Public String  API_Gateway_URL = (String)JCC_GlobalVar.APIGateway_url__c; //MyMB Fix
    
    public PageReference resendEmail(){
        
        List <User> us =[Select Id,Email,Name,Account_Activation_Request__c,Account_Activation_Random_Number__c,IsActivationLinkActive__c,LastName from User where Username =:email];
        analytics.Page_Name__c = 'Pending Account Activation';
        analytics.Page_Name_Action__c = 'Clicked Resend Account Activation CTA';
        final String chars = '0123456789';
    	String randStr = '';
    	while (randStr.length() < 6) {
       	Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()*999999), chars.length());
       	randStr += chars.substring(idx, idx+1);
    	}
        
    
   // encryption
        Blob data = Blob.valueOf(us[0].Id);
        String b64encryptedData = EncodingUtil.base64Encode(data); 
        
        Blob randomdata = Blob.valueOf(randStr);
        String b64encryptedrandomData = EncodingUtil.base64Encode(randomdata);
        us[0].Account_Activation_Request__c = System.now();
        us[0].Account_Activation_Random_Number__c = randStr;
        us[0].IsActivationLinkActive__c = 'Active';
        update us;
        PageReference signupSuccessPageRef;
        String ActivationLink;
        if(globalHeader)
        {
            signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation&channel=web');
			ActivationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+'&channel=web';        
        }
        else
        {
			string strBrunch = '';
			strBrunch= ApexPages.currentPage().getParameters().get('branch');
            signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation'+'&branch='+strBrunch);
            ActivationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+' ';
        }
        
       	signupSuccessPageRef.setredirect(true);
        
     	EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Id =: Account_Activation_EmailId];
        
        // process the merge fields
    	String subject = emailTemplate.Subject;
    

    	String htmlBody = emailTemplate.HtmlValue;
    
    	htmlBody = htmlBody.replace('{!Community_Url}', ActivationLink);
				htmlBody = htmlBody.replace('{!Receiving_User.LastName}', us[0].LastName);
                String plainBody = emailTemplate.Body;
       			plainBody = plainBody.replace('{!Community_Url}', ActivationLink);
    			plainBody = plainBody.replace('{!Receiving_User.LastName}', us[0].LastName);
       
   		//build the email message
    	Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo('profile.sg@e.cyclecarriage.com');
    	
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if ( owea.size() > 0 ) {
			email.setOrgWideEmailAddressId(owea.get(0).Id);
		}
		
		//email.setSenderDisplayName('Your C&C Profile');
    	email.setTargetObjectId(us[0].Id);
    	email.setSaveAsActivity(false);
    	email.setSubject(subject);
    	email.setHtmlBody(htmlBody);
		string [] arrStrBcc = new String []{};
		arrStrBcc.add('sfcomm@cyclecarriage.com.sg');
		email.setBccAddresses(arrStrBcc);
    	email.setPlainTextBody(plainBody);
		try {
    			Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
            system.debug('Email send');
			} catch (Exception e) {
    			System.debug(e.getMessage());
			}
		insert analytics;
        return signupSuccessPageRef;
        
    }
     public PageReference forwardRequest()
     {
        analytics.Page_Name__c = 'Pending Account Activation';
        analytics.Page_Name_Action__c = 'Clicked RETURN TO LOGIN SCREEN CTA';
        insert analytics;
        if(PageUrl.contains('channel=web'))
         {
             	PageReference loginPageRef= new PageReference(Label.WebLogin);
         		loginPageRef.setredirect(true);
             	return loginPageRef;
         }
         else
         {        
			PageReference loginPageRef;
					string strBranch = '';
					strBranch= ApexPages.currentPage().getParameters().get('branch');
            //if(PageUrl.contains('mobileApp=mymb')){ //MyMB Fix
			if(PageUrl.contains('branch=CCI')){ //MyMB Fix
                loginPageRef= new PageReference(API_Gateway_URL + '/auth/mymb/sf_authorize?client_id='+SF_Mobile_App_MYMB_ClientID+'&redirect_uri='+MobileRedirect_URI_MB+'&branch='+strBranch);
            }else{
                loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
            }


         		//PageReference loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
        		loginPageRef.setredirect(true);
             	return loginPageRef;
         }

        
     }
    
    
    global LoginResendActivationController(){
        timestamp = system.now();
        id=ApexPages.currentPage().getParameters().get('id');
        //channel=ApexPages.currentPage().getParameters().get('channel');
        PageUrl = ApexPages.currentPage().getUrl();
        if(PageUrl.contains('channel=web'))
        {
            system.debug('Entered Web');
            globalHeader = true;
            mobileHeader = false;
            globalFooter = true;
        }
        else
        {
            system.debug('Entered Mobile');
            globalHeader = false;
            mobileHeader = true;
            globalFooter = false;
        }
        List <User> theuser = [Select Id,Email,Username from User where Id =:id];
        email = theuser[0].Email;
       	// Analytics
       	analytics.Request_Type__c = 'Account activation';
        analytics.Timestamp__c = system.now();
        analytics.Name = theuser[0].Username;
        analytics.User__c = theuser[0].Id;
        
    }

}