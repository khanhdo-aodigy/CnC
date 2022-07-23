/** ******
 * Description : Controller for IDP Sign Up Form
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20210615            TPhan@aodigy.com               Created Initial Version. 
***** **/
global without sharing class IDPSignUpFormService 
{       
    public class RequestWrapper 
    {
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String password { get; set; }   
        @AuraEnabled public Boolean pdpa { get; set; }    
    }

    public class ResponseWrapper
    {
        @AuraEnabled public String registrationId { get; set; }
        @AuraEnabled public String pAId { get; set; }
        @AuraEnabled public Boolean isNewPA { get; set; }
    }

    @AuraEnabled
    public static Boolean checkEmail(String email)
    {
        try 
        {
            List<User> existingUsers  = [SELECT Id, isValid__c FROM User WHERE Email =: email OR CommunityNickName =: email LIMIT 1];

            if (existingUsers.size() > 0)
            {
                return false;
            }

            return true;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean verifyCaptcha(String secretKey, String reCaptchaResponse)
    {
        try 
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
            request.setMethod('POST');
            request.setBody('secret=' + secretKey + '&response=' + reCaptchaResponse);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) 
            {
                System.debug(response.getBody());
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    
                if (result.containsKey('success') && result.get('success') == true) 
                {
                   return true;
                } 
                else 
                {
                   return false;
                }
            }

            return false;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ResponseWrapper createUser(RequestWrapper request)
    {
        ResponseWrapper response;
        String registrationId;
        List<Account> existingPAs = [SELECT Id, PersonContactId FROM Account WHERE PersonEmail =: request.email AND IsPersonAccount = true];
        List<User> existingUsers  = [SELECT Id, isValid__c FROM User WHERE Email =: request.email LIMIT 1];

        System.debug('existingPAs: ' + existingPAs);
        System.debug('existingUsers' + existingUsers);

        if(existingUsers.size() > 0 && !existingUsers[0].IsValid__c)
        {
            throwError('Unactivated Account');
        }
        else if(existingPAs.size() > 0 && (existingUsers.size() > 0 && existingUsers[0].isValid__c))
        {
            throwError('Existing User Account');
        }
        else if (existingPAs.size() > 0 && existingUsers.size() == 0)
        {
            response = processFurther(request, existingPAs[0].PersonContactId, existingPAs[0].Id, false);         
        }
        else if (existingPAs.size() == 0 && existingUsers.size() == 0)
        {
            Account newProspect     = new Account ();
            newProspect.FirstName   = request.firstName;
            newProspect.LastName    = request.lastName;
            newProspect.PersonEmail = request.email;
            newProspect.PDPA__pc    = request.pdpa ? 'SMS;Call;Email' : '';
            newProspect.SMS__pc     = request.pdpa ? true : false;
            newProspect.Call__pc    = request.pdpa ? true : false;
            newProspect.Fax__pc     = request.pdpa ? true : false;
            newProspect.Email__pc   = request.pdpa ? true : false;

            createProspect(newProspect);

            newProspect = [SELECT Id, PersonContactId FROM Account WHERE ID =: newProspect.Id];

            response = processFurther(request, newProspect.PersonContactId, newProspect.Id, true);
        }

        return response;
    }

    @AuraEnabled
    public static String verifyUser(String verificationCode, RequestWrapper request, ResponseWrapper response, String startURL)
    {
        try 
        {
            System.debug('registrationId: ' + response.registrationId);
            System.debug('verificationCode: ' + verificationCode);
            System.debug('startURL: ' + startURL);
            Auth.VerificationResult res = !Test.isRunningTest() ? System.UserManagement.verifySelfRegistration(Auth.VerificationMethod.EMAIL, response.registrationId, verificationCode, startURL) 
                												: new Auth.VerificationResult(new System.PageReference('https://www.abc.com'), true, 'success');
            System.debug('Result: ' + res);
            if(res.success == true)
            {
                User u = [SELECT Id, LastName, FirstName, Email, Deletion_Request_Date__c, Deactivate_C_C_Account__c FROM User WHERE Email =: request.email];
                if (!Test.isRunningTest())
                {
                    System.setPassword(u.Id, request.password);
                }              
                
                Account pA = new Account();
                if (!response.isNewPA)
                {
                    pA           = [SELECT FirstName, LastName, PDPA__pc, SMS__pc, Call__pc, Fax__pc, Email__pc, Account_Activation_OTP__pc, Is_First_Login__pc FROM Account WHERE IsPersonAccount = true AND Id =: response.pAId LIMIT 1];
                    pA.FirstName = request.firstName;
                    pA.LastName  = request.lastName;
                    pA.PDPA__pc  = request.pdpa ? 'SMS;Call;Email' : '';
                    pA.SMS__pc   = request.pdpa ? true : false;
                    pA.Call__pc  = request.pdpa ? true : false;
                    pA.Fax__pc   = request.pdpa ? true : false;
                    pA.Email__pc = request.pdpa ? true : false;
                }
                else 
                {
                    pA = [SELECT Account_Activation_OTP__pc, Is_First_Login__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail =: request.email LIMIT 1];
                }

                pA.Account_Activation_OTP__pc = System.now();
                pA.Is_First_Login__pc         = true;              
                update pA;

                sendEmail(new List<User>{u}, 'JCC_Account_Created_Notification');
                System.debug('Result URL: ' + res.redirect.getURL());

                return res.redirect.getURl();
            } 
        }
        catch(Exception e) 
        {
            throwError(e.getMessage() + ' ' + e.getLineNumber());
        }

        return null;
    }

    @AuraEnabled
    public static ResponseWrapper resendOTP(RequestWrapper request, ResponseWrapper response)
    {
        ResponseWrapper res;
        try 
        {   
            Account pA = [SELECT PersonContactId FROM Account WHERE IsPersonAccount = true AND Id =: response.pAId LIMIT 1];
            res        = processFurther(request, pA.PersonContactId, response.pAId, response.isNewPA);          
        }
        catch (Exception e) 
        {
            throwError(e.getMessage());
        }

        return res;
    }

    private static ResponseWrapper processFurther(RequestWrapper request, String contactId, String accountId, Boolean isNewPA)
    {
        ResponseWrapper response;
        User u = initExternalUser(request, contactId);
        if (u <> null)
        {
            String registrationId = registerWithEmail(u);
            
            if (registrationId <> null)
            {
                response = generateResponse(registrationId, accountId, isNewPA);
            }
        }

        return response;
    }

    private static User initExternalUser(RequestWrapper request, String contactId)
    {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];

        User u              = new User();                             
        u.Username          = request.email;
        u.Email             = request.email;
        u.FirstName         = request.firstName;
        u.LastName          = request.lastName;
        u.CommunityNickname = request.email;
        u.Display_Name__c   = request.firstName + ' ' + request.lastName;
        u.ProfileId         = portalProfile.Id;
        u.ContactId         = contactId;
        u.TimeZoneSidKey    = 'Asia/Singapore';
        u.LocaleSidKey      = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.isValid__c        = true;

        String alias        = String.isNotBlank(request.firstName) ? request.firstName.substring(0,1) + request.lastName : request.lastName;
        u.Alias             = alias.length() > 8 ? alias.substring(0,8).toLowerCase() : alias.toLowerCase();
        
        return u;
    }

    private static String registerWithEmail(User u)
    { 
        String registrationId;

        try 
        {            
            registrationId = !Test.isRunningTest() ? System.UserManagement.initSelfRegistration(Auth.VerificationMethod.EMAIL, u) : 'Testing';      
        } 
        catch (Exception e) 
        {
            throwError(e.getMessage());
        }

        return registrationId;
    }

    public static void sendEmail(List<User> users, String emailTemplateName)
    {
        List<Messaging.SingleEmailmessage> emails = new List<Messaging.SingleEmailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: emailTemplateName];
        OrgWideEmailAddress add     = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];

        for (User user : users)
        {
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = String.isNotBlank(user.FirstName) ? htmlBody.replace('{!Receiving_User.CustomerName__c}', user.FirstName)
                                                         : htmlBody.replace('{!Receiving_User.CustomerName__c}', user.LastName);
                
            String plainBody = emailTemplate.Body;
            plainBody = String.isNotBlank(user.FirstName) ? plainBody.replace('{!Receiving_User.CustomerName__c}', user.FirstName)
                                                          : plainBody.replace('{!Receiving_User.CustomerName__c}', user.LastName); 

            if (emailTemplateName == 'JCC_Account_Created_Notification')
            {
                htmlBody = htmlBody.replace('{!Receiving_User.Email__c}', user.Email);
                plainBody = plainBody.replace('{!Receiving_User.Email__c}', user.Email); 
            }
            // Modified by [Vu] - 24/04/2022 - Email template for Delete C&C Account modification
            if (emailTemplateName == 'Deletion_C_C_Account_Request')
            {
                Integer day   = user.Deletion_Request_Date__c.day();
                Integer month = user.Deletion_Request_Date__c.month();
                Integer year  = user.Deletion_Request_Date__c.year();
                Datetime deletionRequestDdt = Datetime.newInstance(year, month, day);

                htmlBody = htmlBody.replace('{!Receiving_User.Deletion_Request_Date__c}', deletionRequestDdt.addDays(13).format('d MMM yyyy'));
                plainBody = plainBody.replace('{!Receiving_User.Deletion_Request_Date__c}', deletionRequestDdt.addDays(13).format('d MMM yyyy')); 
            }
            
            //build the email message
            Messaging.SingleEmailmessage email = new Messaging.SingleEmailmessage();
            email.setReplyTo('profile.sg@e.cyclecarriage.com');
            email.setOrgWideEmailAddressId(add.Id);
            // email.setSenderDisplayName('Your C&C Profile');
            email.setTargetObjectId(user.Id);
            email.setSaveAsActivity(false);
            email.setSubject(emailTemplate.Subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);

            emails.add(email);
        }
        
        try 
        {
            Messaging.sendEmail(emails);
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
        }    
    }

    private static Account createProspect( Account prospect_Object )
    {
        Account newProspect = new Account();
        try
        {
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Account.SObjectType} );
            Id defaultAcctID = getDefaultAccountOwnerId();

            newProspect              = prospect_Object;
            newProspect.RecordTypeId = AccountUtil.getProspectRecordTypeId();
            if(defaultAcctID <> null)
            {
                newProspect.OwnerId = defaultAcctID;
            }
            uow.registerNew(newProspect);
            uow.commitWork();
        }
        catch( Exception ex )
        {
            System.debug('@@@@DEBUG createProspect ERROR :: err.msg = ' + ex.getMessage() );
        }
        
        return newProspect;
    }

    private static ResponseWrapper generateResponse(String registrationId, String pAId, Boolean isNewPA)
    {
        ResponseWrapper res = new ResponseWrapper();
        res.registrationId  = registrationId;
        res.pAId            = pAId;
        res.isNewPA         = isNewPA;

        return res;
    }

    private static Id getDefaultAccountOwnerId()
    {
        global_var__c jccCusSetting = global_var__c.getOrgDefaults();
        if(String.isNotBlank( jccCusSetting.Default_Owner_C_C__c ))
        {
            return (Id)jccCusSetting.Default_Owner_C_C__c;
        }
        return null;
    }

    private static void throwError (String errorMsg)
    {
        AuraHandledException e = new AuraHandledException(errorMsg);
        e.setMessage(errorMsg);
        throw e;
    }
}