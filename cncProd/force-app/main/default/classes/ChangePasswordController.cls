/**
 * An apex page controller that exposes the change password functionality
 */
public without sharing class ChangePasswordController 
{
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public String username {get;set;}
    public string isError {get;set;}
    public DateTime timestamp {get;set;}
    public Boolean globalHeader {get;set;}
    public Boolean mobileHeader {get;set;}
    public Boolean globalFooter {get;set;}
    public List <User> us;
    public String userAgent;
    User_Analytics__c analytics = new User_Analytics__c();
    Account pA;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
    Public String  Password_Reset_EmailId = (String)JCC_GlobalVar.Password_Reset_EmailId__c;
    
    public ChangePasswordController() 
    {
        System.debug('@@@@DEBUG ChangePasswordController !!!');
        timestamp = system.now();
        username= UserInfo.getUserId();
        us = [Select Id, FirstName,LastName,Username,channel__c, CustomerName__c, Email from User where Id=: username];
        System.debug('@@@@DEBUG ChangePasswordController :: username = '+ username);
        System.debug('@@@@DEBUG ChangePasswordController :: us = '+ us);
        System.debug('@@@@DEBUG ChangePasswordController :: oldPassword = '+ oldPassword);

        analytics.Name = us[0].Username;
        analytics.User__c = us[0].Id;
        analytics.Request_Type__c = 'Change Password';
        analytics.Timestamp__c = system.now();        
        String PageUrl = ApexPages.currentPage().getUrl();
        Cookie pId = new Cookie('sid', '',null,0,false); // Note the 0 to delete the cookie
		ApexPages.currentPage().setCookies(new Cookie[]{pId});

        /*if(us[0].channel__c == 'web')
        {
            globalHeader = true;
            mobileHeader = false;
        }*/
        userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent != null) {
        if(((userAgent.contains('Android')) && ((userAgent.contains('Mozilla')) || (userAgent.contains('Chrome')) ||(userAgent.contains('Safari')))) || ((userAgent.contains('IOS')) && ((userAgent.contains('Mozilla')) || (userAgent.contains('Chrome')) ||(userAgent.contains('Safari')))))
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

    public PageReference changePassword() 
    {
        analytics.Page_Name__c = 'Change Password';
        analytics.Page_Name_Action__c ='Clicked Save';
        PageReference pg;
        if(userAgent != null) 
        {
            if((userAgent.contains('Android')) || (userAgent.contains('IOS')))
            {
                pg = new PageReference ('/apex/ChangePasswordConfirmation');
            }
            else
            {
                pg = new PageReference ('/apex/ChangePasswordConfirmation?channel=web');
                
                pA = [SELECT Id, Account_Activation_OTP__pc, Is_First_Login__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail =: us[0].Email LIMIT 1];
                if (pA.Account_Activation_OTP__pc == null) { pA.Is_First_Login__pc = true; pA.Account_Activation_OTP__pc = System.now();}
            } 
        } 
        System.debug('@@@@DEBUG ChangePasswordController :: oldPassword = '+ oldPassword);   
        PageReference lg = !Test.isRunningTest() ? Site.changePassword(newPassword, verifyNewPassword, oldpassword) : new Pagereference('https://www.abc.com') ;   
        if(lg!=null)
        {
            try
            {
                pg.setRedirect(true);
                SendEmail(us);
                insert analytics;
                if (pA <> null) update pA;
                return pg;
            } 
            catch (Exception e)
            {
                    isError = e.getMessage();
                    return null;
            }     
        }
        else
        {
            for (ApexPages.Message m : ApexPages.getMessages()) 
            {
                
                isError=m.getSummary();
			}
            return null;
        }
    }     

    public void SendEmail(List <User> us)
    {        
        try 
        {    
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: Password_Reset_EmailId];
            
            // process the merge fields
            String subject = emailTemplate.Subject;
            isError = subject;
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!FirstName}', us[0].CustomerName__c);
            htmlBody = htmlBody.replace('{!Receiving_User.FirstName}', us[0].LastName);
            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!FirstName}', us[0].LastName);
            plainBody = plainBody.replace('{!Receiving_User.FirstName}', us[0].LastName);    

            //build the email message
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) 
            {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            email.setReplyTo('profile.sg@e.cyclecarriage.com');
            //email.setSenderDisplayName('Your C&C Profile');
            email.setTargetObjectId(us[0].Id);
            email.setSaveAsActivity(false);
            string [] arrStrBcc = new String []{};
            arrStrBcc.add('sfcomm@cyclecarriage.com.sg');
            email.setBccAddresses(arrStrBcc);
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);

            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
        } 
        catch (Exception e) 
        {
            isError = e.getMessage();
        }
    }
}