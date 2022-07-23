public class forgotPasswordConfirmExpiredController {

    User_Analytics__c analytics = new User_Analytics__c();
    Public String username;
    Public User[] user;
    Public String PageUrl;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    Public String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    Public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    Public String  MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    Public String  SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
    Public String  WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    Public DateTime timestamp {get;set;}
    Public Boolean globalHeader {get;set;}
    Public Boolean mobileHeader {get;set;}
    Public Boolean globalFooter {get;set;}
    
    public forgotPasswordConfirmExpiredController()
    {
        timestamp = system.now();
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
    public void updateUserAnalytics(){
        user = [select Id from User where Username =: username];
        analytics.Request_Type__c = 'Forgot Password';
        analytics.Page_Name__c = 'Forgot Password Confirmation Page';
        analytics.Timestamp__c = system.now();
        analytics.Name = username;
        analytics.User__c = user[0].Id;
        insert analytics;
    }
    public PageReference returnToLogin()
    {

        analytics.Page_Name__c = 'Forgot Password Confirmation Expired Page';
        analytics.Page_Name_Action__c = 'Clicked BACK TO LOGIN';
       if(PageUrl.contains('channel=web'))
        {
            PageReference pr = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Web_App_ClientID+'&redirect_uri='+WebRedirect_URI);
            pr.setRedirect(true);
            //update analytics;
            return pr;
        }
        else{
        PageReference pf = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
        pf.setRedirect(true);
        //update analytics;
        return pf;
        }
    }
}