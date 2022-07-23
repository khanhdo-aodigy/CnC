/**
 * An apex page controller that exposes the site login functionality
 *
 *
 */
global without sharing class SiteLoginController 
{
    global String username {get; set;}
    global String password {get; set;}
    global boolean isError {get; set;}
    global boolean isNotActive {get;set;}
    global boolean isNotValid {get;set;}
    global DateTime timestamp {get;set;}
    global Boolean globalHeader {get;set;}
    global Boolean globalFooter {get;set;}
    global Boolean mobileHeader {get;set;}
    
    public PageReference login() 
    {
        try
        {
            List <User> us = [select Id, isValid__c, IsActive, Contact_ID__c from user where Username =: username];
            if(us.size()!=0)
            {
                if (us[0].IsActive==false)
                {
                    isError = true;
                    isNotActive = true;
                    isNotValid = false;
                    return null;
                }
            
                if(us[0].isValid__c==true){
                    String startUrl = System.currentPageReference().getParameters().get('startURL');
                    System.debug('startUrl ' + startUrl);
                    PageReference pg = Site.login(username, password, startUrl);

                    if(pg==null)
                    {
                        isError = true;
                        isNotValid = true;
                        isNotActive = false;
                        return null;
                    }
                    else
                    {
                        // ADDED BY TPHAN - 20/02/2022 - MARK/UNMARK FIRST LOGIN
                        Contact con = [SELECT Account_Activation_OTP__c, Is_First_Login__c FROM Contact WHERE Id =: us[0].Contact_ID__c LIMIT 1];
                        if (con <> null)
                        {
                            if (con.Account_Activation_OTP__c <> null)
                            {
                                con.Is_First_Login__c = false;
                            }
                            else 
                            {
                                con.Account_Activation_OTP__c = System.now();
                                con.Is_First_Login__c         = true;
                            }
                            
                            update con;
                        }
                        isError = false;
                        System.debug('PAGE::::::::::: ' + pg);
                        return pg;         
                    }
                    
                }
                else
                {
                    PageReference pr;
                	if(globalHeader)
                    {
                        pr = new PageReference('/loginResendActivation?id='+us[0].Id+'&channel=web');
                    }
                	else
                    {
                       pr = new PageReference('/loginResendActivation?id='+us[0].Id);
                    }
                    pr.setRedirect(true);
                    return pr;
            	}
        } else
            {
                isError = true;
                isNotValid = true;
                isNotActive = false;
                return null;
            
            }
        
        }
        
    catch (Exception e)
        {
            PageReference Error = new PageReference('/ExceptionHandlingForLogin');
            Error.setRedirect(true);
            return Error;
            
        }
    }
    
    global SiteLoginController () {
        timestamp = system.now();
        String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        System.debug('SiteLoginController :: ApexPages.currentPage().getHeaders() = ' + ApexPages.currentPage().getHeaders());
        if(userAgent != null) {
        if((userAgent.contains('Android')) || (userAgent.contains('iPhone')))
        {
            globalHeader = false;
            mobileHeader = true;
            globalFooter = false;
        }
        else
        {
              globalHeader = true;
              mobileHeader = false;
              globalFooter = true;
        }}
    }
}