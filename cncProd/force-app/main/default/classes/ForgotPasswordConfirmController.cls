public class ForgotPasswordConfirmController 
{   
    User_Analytics__c analytics = new User_Analytics__c();
    Public String username;
    Public User[] user;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    Public String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    Public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    Public String  MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    Public String  WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    Public String  SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
    Public DateTime timestamp {get;set;}
    Public Boolean globalHeader {get;set;}
    Public Boolean mobileHeader {get;set;}
    Public Boolean globalFooter {get;set;}
    Public String PageUrl;

    Public String  SF_Mobile_App_MYMB_ClientID = (String)JCC_GlobalVar.mymb_mobile_app__c; //MyMB Fix
	Public String  MobileRedirect_URI_MB = (String)JCC_GlobalVar.MobileRedirect_URI_MB__c; //MyMb Fix
	Public String  API_Gateway_URL = (String)JCC_GlobalVar.APIGateway_url__c; //MyMB Fix
    
    public ForgotPasswordConfirmController()
    {
        timestamp = system.now();
        username= ApexPages.currentPage().getParameters().get('username');
        PageUrl = ApexPages.currentPage().getUrl();
       
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

    public void updateUserAnalytics()
    {
        user = [select Id from User where Username =: username];
        analytics.Request_Type__c = 'Forgot Password';
        analytics.Page_Name__c = 'Forgot Password Confirmation Page';
        analytics.Timestamp__c = system.now();
        analytics.Name = username;
        //analytics.User__c = user[0].Id;
        //insert analytics;
    }

    public PageReference returnToLogin()
    {
		string strBranch = '';
		strBranch= ApexPages.currentPage().getParameters().get('branch');

        analytics.Page_Name__c = 'Forgot Password Confirmation Page';
        analytics.Page_Name_Action__c = 'Clicked BACK TO LOGIN';
        
        if(PageUrl.contains('channel=web'))
        {
            /* ADDED BY TPHAN - IDP REVAMP PHASE 2 */
            IDPAppService.revokeRefreshToken(username);
            /** END */
            PageReference pr = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Web_App_ClientID+'&redirect_uri='+WebRedirect_URI);
            
			System.debug('++ AA ++ '+ pr);

			pr.setRedirect(true);
            //update analytics;
            return pr;
        }
		else if(strBranch == 'CCI')
		{
			PageReference pr = new PageReference(API_Gateway_URL + '/auth/mymb/sf_authorize?client_id='+SF_Mobile_App_MYMB_ClientID+'&redirect_uri='+MobileRedirect_URI_MB+'&branch='+strBranch);
			
			System.debug('++ BB ++ '+ pr);

			pr.setRedirect(true);
			return pr;
		}
        else
        {
            //PageReference pf = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
            PageReference pf = new PageReference(API_Gateway_URL+'/auth/sf_authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI_MB);
            pf.setRedirect(true);
            //upsert analytics;

            System.debug('++ CC ++ '+ pf);

            return pf;
        }       
    }
}