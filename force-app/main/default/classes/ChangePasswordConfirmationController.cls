public class ChangePasswordConfirmationController 
{
    Public Boolean inValidApp {get;set;}
    Public Boolean inValid {get;set;}
    Public DateTime timestamp {get;set;}
    Public Boolean globalHeader {get;set;}
    Public Boolean mobileHeader {get;set;}
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    Public String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    Public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    Public String  MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    Public String  WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    Public String  SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;

    public ChangePasswordConfirmationController()
    {
        timestamp = system.now();
        String PageUrl = ApexPages.currentPage().getUrl();
        if(PageUrl.contains('channel=web'))
        {
            globalHeader = true;
            mobileHeader = false;
        }
        else
        {
            globalHeader = false;
            mobileHeader = true;
        }
    }

    Public void InvalidAppRequest() 
    {
        inValidApp = true;
        inValid = true;
    }

    public PageReference returnToLogin()
    {
       String PageUrl = ApexPages.currentPage().getUrl();
       if(PageUrl.contains('channel=web'))
        {
            //PageReference pr = new PageReference('https://partcopy-digitalmvp-digmvpuat-devjcc.cs5.force.com/'+'/endusers/services/oauth2/authorize?response_type=code&client_id='+SF_Web_App_ClientID+'&redirect_uri='+WebRedirect_URI);
            PageReference pr = new PageReference(Label.WebLogin);
            // pr.setRedirect(false);
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            PageReference pf = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
            pf.setRedirect(true);
            return pf;
        }  
    }
}