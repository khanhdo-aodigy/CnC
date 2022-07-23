/**
 * An apex page controller that exposes the site forgot password functionality
 */
global without sharing class ForgotPasswordController {
    global String username {get; set;}   
    global boolean isError {get; set;}  
    global boolean isExpired {get;set;}
    global boolean isForgotPassword {get;set;}
    global DateTime timestamp {get;set;}
    global Boolean globalHeader {get;set;}
    global Boolean globalFooter {get;set;}
    global Boolean mobileHeader {get;set;}
    global String PageUrl;
    User_Analytics__c analytics = new User_Analytics__c();
    
    public ForgotPasswordController() {
        timestamp = system.now();
        isForgotPassword = false;
        String isForgot = ApexPages.currentPage().getParameters().get('isForgot');
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
        
        if(isForgot=='true')
        {
            isExpired = false;
            isForgotPassword = true;
            
        }
        else
        {
            isExpired = true;
            isForgotPassword = false;
            globalHeader = true;
            mobileHeader = false;
            globalFooter = true;
        }
    }
    
    public PageReference forgotPassword() {
        
        List <User> theUser = [Select Id,Email,FirstName,channel__c from User where Username =:username];
        // Analytics
        analytics.Request_Type__c = 'Forgot Password';
        analytics.Timestamp__c = system.now();
        
        
        if(theUser.size()==0)
        {
            isError = true;
            //return null;
           
        }
        else{
            
            analytics.Name = username;
            analytics.User__c = theUser[0].Id;
            boolean success = Site.forgotPassword(username);
            if(PageUrl.contains('channel=web'))
            {
                theUser[0].channel__c = 'web';
            }
            else
            {
                theUser[0].channel__c = 'mobile';
            }
            update theUser[0];
            if(isExpired){
                    analytics.Page_Name__c = 'Forgot Password Link Expired';
                    analytics.Page_Name_Action__c = 'Clicked RESEND Button';
                    insert analytics;
                    PageReference ps = Page.ForgotPasswordConfirmationExpired;
                    ps.setRedirect(true);
                if(success){
                    return ps;
                }
                
            }
            else{
                    analytics.Page_Name__c = 'Forgot Password';
                    analytics.Page_Name_Action__c = 'Clicked SUBMIT Button';
                    insert analytics;
                    PageReference pr;
                   if(PageUrl.contains('channel=web'))
                    {
                        pr = new PageReference('/forgotpasswordconfirm?event=ChangePassword_Email_Sent&username='+username+'&channel=web');
                        pr.setRedirect(true);
                    }
                    else
                    {
						string strBranch = '';
						strBranch= ApexPages.currentPage().getParameters().get('branch');

                        pr = new PageReference('/forgotpasswordconfirm?event=ChangePassword_Email_Sent&username='+username+'&branch='+strBranch);
                        pr.setRedirect(true);
                    }
                    
                   if(success){return pr;}
            }
                                    
        }
        return null;
    }
    
    
}