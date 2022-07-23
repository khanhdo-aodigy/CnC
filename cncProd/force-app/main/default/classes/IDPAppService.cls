/** ******
 * Description : Controller for Login/Forgot Password Pages 
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                               Description
 * 20210624            TPhan@aodigy.com               Created Initial Version. 
 * 20211001            TPhan@aodigy.com               Added revokeRefreshToken method - IDP REVAMP PHASE 2
 * 20211230            TPhan@aodigy.com               Added isNewUser method 
 * 20220420            thieudang.vu@aodigy.com        Modify doLogin method, add confirmDelete, confirmRestore method for Delete My Account
***** **/

global without sharing class IDPAppService 
{
    public class RequestWrapper 
    {
        @AuraEnabled public String email    { get; set; }
        @AuraEnabled public String password { get; set; }
        @AuraEnabled public String startURL { get; set; } 
    }

    @AuraEnabled
    public static Boolean isNewUser(RequestWrapper request)
    {
        try 
        {
            Account pA = [SELECT Account_Activation_OTP__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail =: request.email LIMIT 1];
            if (pA <> null)
            {
                if (pA.Account_Activation_OTP__pc == null)
                {
                   return true;
                }
                
                return false;
            }
        } 
        catch (Exception e) 
        {
            throwError(e.getMessage());
        }

        return false;
    }

    @AuraEnabled
    public static LoginResult doLogin(RequestWrapper request)
    {
        List<User> existingUsers  = [SELECT Id, IsActive, isValid__c, Deletion_Request_Date__c, Deactivate_C_C_Account__c, Email
                                     FROM User
                                     WHERE Username =: request.email LIMIT 1];

        if (existingUsers.isEmpty())
        {
            throwError('Invalid');
        }
        
        if (!existingUsers[0].isValid__c || !existingUsers[0].IsActive)
        {
            throwError('Inactive');
        }

        try
        {
            System.Pagereference page = !Test.isRunningTest() ? Site.login(request.email, request.password, request.startUrl)
                                                              : new System.Pagereference('/testing');
            LoginResult result;
            if (page <> null) 
            {
                result = new LoginResult();

                // Modified by [Vu] - 20/04/2022 - if user has been flagged then display restore page
                if (!existingUsers[0].Deactivate_C_C_Account__c)
                {
                    Account pA = [SELECT Account_Activation_OTP__pc, Is_First_Login__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail =: request.email LIMIT 1];

                    if (pA.Account_Activation_OTP__pc == null)
                    {
                        pA.Account_Activation_OTP__pc = System.now();
                    }
                    else
                    {
                        pA.Is_First_Login__pc = false;
                    }

                    update pA;

                    result.type = 'login';
                }
                else
                {
                    result.type = 'restore';
                }

                result.redirect_url = page.getURL();
                result.uInfo        = existingUsers[0];

                system.debug('result: ' + JSON.serialize(result));
                return result;
            }
        }
        catch(Exception e)
        {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
        
        return null;
    }

    @AuraEnabled
    public static Boolean doForgotPassword(String email)
    {
        try 
        {
            List<User> existingUsers  = [SELECT Id, IsActive, isValid__c, Username, Channel__c FROM User WHERE Username =: email LIMIT 1];
           
            if (existingUsers.isEmpty())
            {
                throwError('Invalid');
            }
            
            if (!existingUsers[0].isValid__c || !existingUsers[0].IsActive)
            {
                throwError('Inactive');
            }
          
            Boolean success = !Test.isRunningTest() ? Site.forgotPassword(email) : true;    
            System.debug('Success :: ' + success); 
            
            existingUsers[0].Channel__c = 'mobile'; 
            if (!Test.isRunningTest())
            {
                update existingUsers;
            }

            User_Analytics__c analytics = new User_Analytics__c();
            analytics.Request_Type__c = 'Forgot Password';
            analytics.Timestamp__c = system.now();    
            analytics.Name = email;
            analytics.User__c = existingUsers[0].Id;
            analytics.Page_Name__c = 'Forgot Password';
            analytics.Page_Name_Action__c = 'Clicked SUBMIT Button';
            insert analytics;

            if(success){return true;}    
        }
        catch(Exception e)
        {
           throwError(e.getMessage());
        }
        
        return false;
    }

    @future(callout=true)
    public static void revokeRefreshToken(String email)
    {
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  API_Gateway_URL     = (String)JCC_GlobalVar.APIGateway_url__c;
        String  API_Gateway_Key     = (String)JCC_GlobalVar.APIGateway_key__c;

        Http http        = new Http();
        HttpRequest req  = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Request request  = new Request();
        try 
        {  
            List<User> existingUsers  = [SELECT Contact_ID__c FROM User WHERE Username =: email LIMIT 1];
    
            if (existingUsers <> null && existingUsers.size() > 0)
            {
                request.ContactID = existingUsers[0].Contact_ID__c;
            }
    
            req.setMethod('POST');
            req.setTimeout(12000);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('apikey', API_Gateway_Key);
            req.setEndpoint(API_Gateway_URL + '/RefreshToken/RevokeRefreshToken');
            req.setBody(JSON.serialize(request));
      
            res = http.send(req);

            serviceDataPool.buildServiceDataPoolHttp('revokeRefreshToken', 'ForgotPasswordConfirmController', '', req, res);
        }  
        catch(Exception e)
        {
            System.debug('revokeRefreshToken: ' + e.getMessage() + ' ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('revokeRefreshToken', e);
        }    
    }

    /**
     * Added by [Vu] - 
     * Deleting My Account process
     * 1. Flag user for deactivation
     * 2. Update PA
     * 3. Revoke refresh token to be logged out from all devices
     * 4. Send email to notify user has been requested for deactivation
     */
    @AuraEnabled
    public static Boolean confirmDelete(RequestWrapper request)
    {
        List<User> existingUsers  = [SELECT Id, Username, FirstName, LastName, Email, IsActive, isValid__c, Deletion_Request_Date__c, Deactivate_C_C_Account__c, ContactId
                                     FROM User
                                     WHERE Username =: request.email
                                     LIMIT 1];

        if (String.isBlank(request.password))
        {
            throwError('Please enter your password for verification.');
        }

        List<Account> accs  = [SELECT Id, PersonEmail, PersonContactId, Signup_Channel__pc, RecordType.DeveloperName
                               FROM Account
                               WHERE IsPersonAccount = true 
                                 AND PersonEmail =: request.email
                               LIMIT 1];
       	system.debug(accs[0]);
        Boolean isValidUser = IDPAppService.checkUserForDeletion(accs[0]);
        if (!isValidUser)
        {
            throwError('We are not able to delete your account.');
        }

        try
        {
            System.Pagereference page = !Test.isRunningTest() ? Site.login(request.email, request.password, null)
                                                              : new System.Pagereference('/testing');
            if (page <> null)
            {
                try
                {
                    TriggerExclusion.excludeTrigger('User', true);

                    update deactivatedUser(existingUsers[0]);

                    TriggerExclusion.excludeTrigger('User', false);

                    updateDeactivatedPA(request.email);

                    IDPSignUpFormService.sendEmail(new List<User>{existingUsers[0]}, 'Deletion_C_C_Account_Request');

                    revokeRefreshToken(request.email);

                    return true;
                }
                catch (CalloutException e)
                {
                    loggerDataPool.buildLogDataPool('IDP_Call Revoke Refresh Token API', e);
                    throwError('Oops! Seems like there is a problem. Please contact our support!');
                }
                catch(DmlException e)
                {
                    loggerDataPool.buildLogDataPool('IDP_Update user and PA', e);
                    throwError('Oops! Seems like there is a problem. Please contact our support!');
                }
                catch(EmailException e)
                {
                    loggerDataPool.buildLogDataPool('IDP_Send Deletion Request Email notification', e);
                    throwError('Oops! Seems like there is a problem. Please contact our support!');
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Error: ' + e.getMessage());
            return false;
        }

        return false;
    }

    @AuraEnabled(cacheable=true)
    public static User getUserInfo(String userId)
    {
        return [SELECT Username, Email, FirstName, LastName FROM User WHERE Id = :userId];
    }

    /**
     * Added by [Vu]
     * Restore My Account process
     * Remove deactivation flags for user
     */
    @AuraEnabled
    public static void confirmRestore(String userEmail)
    {
        List<User> existingUsers  = [SELECT Id, Deactivate_C_C_Account__c FROM User WHERE Username = :userEmail LIMIT 1];

        try 
        {
            update reActivatedUser(existingUsers[0]);
        }
        catch (Exception e)
        {
           loggerDataPool.buildLogDataPool('IDP_Reactivate User', e);
        }
    }

    @future
   	public static void updateDeactivatedPA(String email)
    {
        TriggerExclusion.excludeTrigger('Account', true);

        Account pa = [SELECT Deletion_Request_Date__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail =: email LIMIT 1];
        pa.Deletion_Request_Date__pc = Date.today();

        update pa;

        TriggerExclusion.excludeTrigger('Account', false);
    }

    public static Boolean checkUserForDeletion(Account pa)
    {
        Boolean isValidUser = false;

        List<Sales_Agreement__c> sas                 = [SELECT Id FROM Sales_Agreement__c WHERE Account__c = :pa.Id AND Stage__c != 'Cancelled' LIMIT 1];
        List<Opportunity> opps                       = [SELECT Id FROM Opportunity WHERE Account__c = :pa.Id LIMIT 1];
        List<Person_Account_Profiling__c> profilings = [SELECT Id FROM Person_Account_Profiling__c WHERE Account__c = :pa.Id LIMIT 1];
        List<Invoice__c> invoices                    = [SELECT Id, Transaction_Status__c FROM Invoice__c WHERE Account__c = :pa.Id AND Transaction_Status__c != 'processor_declined' LIMIT 1];

        isValidUser = pa.Signup_Channel__pc == 'My C&C App' && pa.RecordType.DeveloperName == 'Prospect' &&
            		  sas.size() == 0 && opps.size() == 0 && profilings.size() == 0 && invoices.size() == 0;

        return isValidUser;
    }

    private static User deactivatedUser(User user) {
        user.Deletion_Request_Date__c  = Date.today();
        user.Deactivate_C_C_Account__c = true;

        return user;
    }

    public static User reActivatedUser(User user) {
        user.Deletion_Request_Date__c  = null;
        user.Deactivate_C_C_Account__c = false;

        return user;
    }

    public class Request
    {
        public String ContactID;
    }

    public class LoginResult
    {
        @AuraEnabled public String type;
        @AuraEnabled public String redirect_url;
        @AuraEnabled public User uInfo;
    }

    private static void throwError(String errorMsg)
    {
        AuraHandledException e = new AuraHandledException(errorMsg);
        e.setMessage(errorMsg);

        throw e;
    }
}