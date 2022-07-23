/** ******
 * Description: Controller class for CCL_ChangePasswordPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                   Description
 * 20210923             khanh.do@aodigy.com    Created Initial Version. 
** ******/
public without sharing class CCL_ChangePasswordController {
    public String password {get;set;}
    public String verifyPassword {get;set;}
    public String username {get;set;}
    public String errMsg {get;set;}
    public List <User> us;
    public String userAgent;
    User_Analytics__c analytics = new User_Analytics__c();
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
    String  Password_Reset_EmailId = (String)JCC_GlobalVar.Password_Reset_EmailId__c;
    
    public CCL_ChangePasswordController() {
        System.debug('@@@@DEBUG ChangePasswordController !!!');
        username= UserInfo.getUserId();
        us = [Select Id, FirstName,LastName,Username,channel__c, CustomerName__c from User where Id=: username];
        System.debug('@@@@DEBUG ChangePasswordController :: username = '+ username);
        System.debug('@@@@DEBUG ChangePasswordController :: us = '+ us);

        
    
        analytics.Name = us[0].Username;
        analytics.User__c = us[0].Id;
        analytics.Request_Type__c = 'Change Password';
        String PageUrl = ApexPages.currentPage().getUrl();
        Cookie pId = new Cookie('sid', '',null,0,false); // Note the 0 to delete the cookie
        ApexPages.currentPage().setCookies(new Cookie[]{pId});
    }

    public PageReference changePassword() {
        try {
            PageReference pg = new PageReference ('/CCL_ChangePasswordSuccess');
            String pwd = Apexpages.currentPage().getParameters().get('password');
            String verifyPwd = Apexpages.currentPage().getParameters().get('verifyPassword');
            if(!Test.isRunningTest()){
                Site.validatePassword(us[0], pwd, verifyPwd);
            }
            PageReference lg = Site.changePassword(pwd, verifyPwd, null);   
            System.debug('lg =' + lg);
            if(lg!=null) {
                pg.setRedirect(true);
                sendEmail(us);              
                errMsg = '';
                insert analytics;                 
                return pg;                
            } else{
                for (ApexPages.Message m : ApexPages.getMessages()) {                
                    errMsg = m.getSummary();
                }
            }
        } catch(Exception ex) {
            errMsg = ex.getMessage();
        }        
        return null;
        
    }     

public void sendEmail(List<User> users){
        
try {    
        
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: Password_Reset_EmailId];
        
        // process the merge fields
    String subject = emailTemplate.Subject;
    errMsg = subject;
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
    if ( owea.size() > 0 ) {
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
            } catch (Exception e) {
                errMsg = e.getMessage();
            }
    }
}