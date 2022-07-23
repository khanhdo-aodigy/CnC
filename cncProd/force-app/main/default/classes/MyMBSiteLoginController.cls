/**
 * An apex page controller that exposes the site login functionality
 */
global without sharing class MyMBSiteLoginController 
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

    global String userID {get;set;}
    global Boolean checkMBTrueOrFalse {get;set;}
    global Integer noOfVeh {get;set;}
    
    public PageReference login() 
	{
        try
		{
            List<User> us = [SELECT Id, ContactId, ContactId__c, Email, isValid__c, IsActive, Contact.AccountId, Contact_ID__c
                              FROM User 
                              WHERE Username =: username];
            if(us.size()!=0)
			{
				if( us[0].IsActive == false )
				{
					isError     = true;
					isNotActive = true;
					isNotValid  = false;
					return null;
				}
            
				if( us[0].isValid__c == true )
				{                
					userID = 'Login User: ' + us[0].Id + ' Associated Contact: ' + us[0].ContactId + ' ContactId__c: ' + us[0].ContactId__c;
                    /*
                    noOfVeh = [ SELECT name, Contact__c, Franchise__c 
								FROM Registered_Vehicle__c where Franchise__c IN ('MBP','MBC') 
                                AND Contact__c =: us[0].ContactId__c].size();
                    */					

                    checkMBTrueOrFalse = true;//checkOwnAnyMBCars(us[0].ContactId); 
                    System.debug('+++ checkMBTrueOrFalse = ' + checkMBTrueOrFalse);

					if( !checkMBTrueOrFalse )
					{
						isError     = true;
						isNotActive = true;
						isNotValid  = false;
						return null;  
					}				

					String startUrl = System.currentPageReference().getParameters().get('startURL');
					System.debug('StartURL ++ ' + startUrl);
					PageReference pg = !Test.isRunningTest() ? Site.login( username, password, startUrl ) : new System.Pagereference('/testing');

					if( pg == null )
					{
						isError     = true;
						isNotValid  = true;
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
						return pg;   
					}
				}
				else
				{
					String strBrunch = 'CCI';
                    PageReference pr = globalHeader ? 
                                        new PageReference('/loginResendActivation?id='+us[0].Id+'&channel=web') : 
                                            new PageReference('/loginResendActivation?id='+us[0].Id+'&branch='+strBrunch);

					pr.setRedirect(true);
					return pr;
				}
			} 
			else
			{
				isError     = true;
				isNotValid  = true;
				isNotActive = false;
				return null;
			}
        }
		catch (Exception e)
        {
			System.debug('++ error ' + e.getMessage());
            PageReference Error = new PageReference('/ExceptionHandlingForLogin');
            Error.setRedirect(true);
            return Error;   
        }
    }
	
	
    global MyMBSiteLoginController () 
	{
        timestamp = System.now();
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');

		System.debug('StartURLInit ++ ' + ApexPages.currentPage());
        
        System.debug('### This is the user agent--- ' + userAgent);
        
        if(Test.isRunningTest())
		{
    		userAgent = 'Android';
        }
        globalHeader = (userAgent.contains('Android')) || (userAgent.contains('iPhone')) ? false : true;
        mobileHeader = (userAgent.contains('Android')) || (userAgent.contains('iPhone')) ? true : false;                                             
        globalFooter = (userAgent.contains('Android')) || (userAgent.contains('iPhone')) ? false : true;                                             
	}
	
    
    /*private boolean checkOwnAnyMBCars(Id contactId)
	{
        Integer noOfVeh = [SELECT Name, Contact__c, Franchise__c 
                           FROM Registered_Vehicle__c 
                           WHERE Franchise__c IN ('MBP','MBC') 
                           AND Contact__c =: contactId].size(); 
        System.debug('+++ noOfVeh ' + noOfVeh);
		return noOfVeh > 0;
    }*/

}