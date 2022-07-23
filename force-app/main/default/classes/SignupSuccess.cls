public class SignupSuccess {

    Public String email {get;set;}
    Public List<Contact> con;
    Public User user;
    Public List<Account> account;
    Public Boolean isResendActivation {get;set;}
    Public Boolean isSignup {get;set;}
    Public DateTime timestamp {get;set;}
    Public Boolean globalHeader {get;set;}
    Public Boolean mobileHeader {get;set;}
    Public Boolean globalFooter {get;set;}
    public String id;
    public String encodedId;
    public string requestType;
    public String action;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    Public String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    Public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    Public String  MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    Public String  WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    Public String  SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
    Public String PageUrl;
    
    Public String  SF_Mobile_App_MYMB_ClientID = (String)JCC_GlobalVar.mymb_mobile_app__c; //MyMB Fix
	Public String  MobileRedirect_URI_MB = (String)JCC_GlobalVar.MobileRedirect_URI_MB__c; //MyMb Fix
	Public String  API_Gateway_URL = (String)JCC_GlobalVar.APIGateway_url__c; //MyMB Fix
    //public channel;
    
    Public void setemail(String email){
     
        this.email= email;
    }
    
    public SignupSuccess()
    {   
        timestamp = system.now();
        PageUrl = ApexPages.currentPage().getUrl();

		System.debug('++ Get page URL ' + ApexPages.currentPage());

        if(PageUrl.contains('channel=web'))
        {
            globalHeader = true;
            mobileHeader = false;
            globalFooter = true;
        }
        else
        {
            globalHeader = false;
            mobileHeader = true;
            globalFooter = false;
        }
    }
    public void mapAccount()
    {
        encodedId = ApexPages.currentPage().getParameters().get('id');
       	Blob b64decodedId = EncodingUtil.base64Decode(encodedId);
       	id = b64decodedId.toString();
        requestType = ApexPages.currentPage().getParameters().get('request');
        user = [Select Name,Email,NRIC__c from User where Id=: id];

        if(requestType == 'Signup')
        {
            isResendActivation = false;
            isSignup = true;
            email= user.Email;
            //setemail(email.replaceAll('(?<=.).(?=[^@]*?.@)', '*'));
        }
        else if(requestType == 'resendAccountActivation')
        {
            isSignup = false;
            isResendActivation = true;
            email= user.Email;
            //setemail(email.replaceAll('(?<=.).(?=[^@]*?.@)', '*'));
        }
    }
    public PageReference forwardRequestToLogin()
    {
       if(PageUrl.contains('channel=web'))
        {
            //PageReference loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Web_App_ClientID+'&redirect_uri='+WebRedirect_URI);
            PageReference loginPageRef= new PageReference(Label.WebLogin);
            loginPageRef.setredirect(true);
            return loginPageRef;
        }else
        {
            PageReference loginPageRef; 

			string strBranch = '';
			strBranch= ApexPages.currentPage().getParameters().get('branch');

            //if(PageUrl.contains('mobileApp=mymb')){ //MyMB Fix
			if(PageUrl.contains('branch=CCI')){ //MyMB Fix
				
				loginPageRef = new PageReference(API_Gateway_URL + '/auth/mymb/sf_authorize?client_id='+SF_Mobile_App_MYMB_ClientID+'&redirect_uri='+MobileRedirect_URI_MB+'&branch='+strBranch);

            }else{
                loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
            }
    
            loginPageRef.setredirect(true);
            return loginPageRef;
        }

    }
}