/** ******
 * Description: Controller classs for IDP_ForgotPasswordPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210624          TPhan@aodigy.com    Created Initial Version. 
 * 20211001          TPhan@aodigy.com    Added revokeRefreshToken method - IDP REVAMP PHASE 2
** ******/

global class IDPForgotPasswordController 
{
    Global_Var__c JCC_GlobalVar           = Global_Var__c.getOrgDefaults();      
    public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    public String  MobileRedirect_URI_MB  = (String)JCC_GlobalVar.MobileRedirect_URI_MB__c;
	public String  API_Gateway_URL        = (String)JCC_GlobalVar.APIGateway_url__c;
    public String  API_Gateway_Key        = (String)JCC_GlobalVar.APIGateway_key__c;

    public IDPForgotPasswordController() {}

    public Pagereference validateAndRedirect()
    {
        Boolean isExpired   = ApexPages.currentPage().getParameters().get('isForgot') == 'true' ? false : true;
        Pagereference pg;
        System.debug('@@@@DEBUG ForgotPasswordController :: isForgot = ' + ApexPages.currentPage());
        if (isExpired)
        {
            pg = new Pagereference('/ForgotPassword?event=Forgot_Password&isForgot=false&channel=web');
            System.debug('@@@@DEBUG ForgotPasswordController :: Page = ' + pg);
            pg.setRedirect(true);
        }  

        return pg;
    }

    public PageReference eventAction() 
    {
        String eventName = Apexpages.currentPage().getParameters().get('eventName');
        PageReference pg;
        
        switch on eventName {
            when 'backFromConfirmation' 
            {
                String eventValue = Apexpages.currentPage().getParameters().get('eventValue');
                IDPAppService.revokeRefreshToken(eventValue);
                pg = new PageReference(API_Gateway_URL+'/auth/sf_authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI_MB);
                pg.setRedirect(true);
                System.debug('@@@@DEBUG ForgotPasswordController :: backFromConfirmation =  '+ pg);
            }
        }        

        return pg;
    }
}