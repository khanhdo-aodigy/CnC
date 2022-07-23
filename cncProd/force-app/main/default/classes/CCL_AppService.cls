/** ******
 * Description : Controller for CCL Login Page 
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                              Description
 * 20210921             khanh.do@aodigy.com               Created Initial Version. 
***** **/

public without sharing class CCL_AppService 
{
    private static Exception ex;
    public class LoginRequestWrapper 
    {
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String password { get; set; }
        @AuraEnabled public String startURL { get; set; } 
    }

    public class SignUpRequest 
    {
        
        @AuraEnabled public String customerType { get; set; }
        
        @AuraEnabled public String salutation { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String mobile { get; set; }
        @AuraEnabled public String password { get; set; }        
        @AuraEnabled public String confirmPassword { get; set; }
        @AuraEnabled public Boolean individualPDPA { get; set; }

        @AuraEnabled public String companyName { get; set; }       
        @AuraEnabled public String companyReg { get; set; }
        @AuraEnabled public String conSalutation { get; set; }
        @AuraEnabled public String conFirstname { get; set; }
        @AuraEnabled public String conLastname { get; set; }
        @AuraEnabled public String contactDesignation { get; set; }
        @AuraEnabled public String contactEmail { get; set; }
        @AuraEnabled public String contactMobile { get; set; }
        @AuraEnabled public String contactPwd { get; set; }        
        @AuraEnabled public String contactConfirmPwd { get; set; }
        @AuraEnabled public Boolean contactPDPA { get; set; }
    }

    public class SignUpResponse
    {
        @AuraEnabled public String registrationId { get; set; }
        @AuraEnabled public String accId { get; set; }
        @AuraEnabled public String conId { get; set; }
        @AuraEnabled public Boolean isNewContact { get; set; }
    }

    @AuraEnabled
    public static String doLogin(LoginRequestWrapper request)
    {
        List<User> existingUsers  = [   SELECT Id, IsActive, Username, Email, isValid__c
                                        FROM User
                                        WHERE Username =: request.email
                                        LIMIT 1
                                    ];

        if (existingUsers.isEmpty())
        {
            throwError('Invalid Email' );
        }
        
        if ( !existingUsers[0].IsActive)
        {
            throwError('Inactive User');
        }

        try {            
            System.Pagereference page = !Test.isRunningTest() ? Site.login(request.email, request.password, request.startUrl)
                                                              : new System.Pagereference('/testing');
            System.debug('@@ DEBUG ==' + page);
            if (page <> null) { 
                return page.getURL(); 
            }
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            throwError(e.getMessage());
        }

        return null;
    }

    @AuraEnabled
    public static Boolean handleForgotPassword(String email)
    {
        try 
        {
            List<User> existingUsers  = [SELECT Id, IsActive, Email, Username, Channel__c, isValid__c FROM User WHERE Username =:email LIMIT 1];
           
            if (existingUsers.isEmpty()) {
                throwError('Invalid');
            }
            
            if (!existingUsers[0].IsActive || !existingUsers[0].isValid__c) {
                throwError('Inactive');
            }
          
            Boolean success = !Test.isRunningTest() ? Site.forgotPassword(email) : true; 
            if (!Test.isRunningTest()) {
                update existingUsers;
            }

            User_Analytics__c analytics = new User_Analytics__c();
            analytics.Request_Type__c = 'CCL Forgot Password';
            analytics.Timestamp__c = System.now();    
            analytics.Name = email;
            analytics.User__c = existingUsers[0].Id;
            analytics.Page_Name__c = 'CCL Forgot Password';
            analytics.Page_Name_Action__c = 'Clicked SUBMIT Button';
            insert analytics;

            if(success){
                return true;
            }    
        }
        catch(Exception e)
        {
            System.debug('Error: ' + e.getMessage());
            throwError(e.getMessage());
        }
        
        return false;
    }

    public class SalutationWrapper 
    {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }

        private SalutationWrapper(String value, String label){
            this.value = value;
            this.label = label;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SalutationWrapper> getSalutationValues(){
        List<SalutationWrapper> values = new List<SalutationWrapper>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
            values.add(new SalutationWrapper(pickListVal.getValue(), pickListVal.getLabel()));
    }   
        System.debug('picklist values = ' + values);
        return values;
   
    }

    @AuraEnabled
    public static Boolean isEmailExist(String email){
        try {
            
            List<User> userList = [ SELECT Id, Name 
                                    FROM User
                                    WHERE Username = :email
                                    OR Email = :email
                                ];
            return !userList.isEmpty();

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throwError(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static SignUpResponse createUser(SignUpRequest request)
    {
        SignUpResponse response;
        try{
            String customerType = request.customerType;
            if(customerType.equalsIgnoreCase('individual')) {
                if(isValidRequest(request, 'individual')) {
                    response = registerIndividual(request);
                }                    
            } else if(customerType.equalsIgnoreCase('corporate')) {
                if(isValidRequest(request, 'corporate')) {
                    response = registerCorporate(request);
                }                    
            }        
        } catch(Exception ex) {
            System.debug(ex.getMessage() + '. At line: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause());
            throwError(ex.getMessage());
        }
        System.debug('createUser(): response = ' + response);
        return response;                
    }

    private static SignUpResponse registerIndividual(SignUpRequest request){
        SignUpResponse response;
        List<Account> existingPAs = [   SELECT Id, PersonContactId 
                                        FROM Account
                                        WHERE PersonEmail =: request.email 
                                        AND IsPersonAccount = true
                                        LIMIT 1
                                    ];

        List<User> existingUsers  = [   SELECT Id, IsActive
                                        FROM User
                                        WHERE Username =: request.email
                                        LIMIT 1
                                    ];

        System.debug('existingPAs: ' + existingPAs);
        System.debug('existingUsers' + existingUsers);

        if(existingUsers.size() > 0 && !existingUsers[0].IsActive)
        {
            throwError('Unactivated Account');
        }
        else if(existingPAs.size() > 0 && (existingUsers.size() > 0 && existingUsers[0].IsActive))
        {
            throwError('Existing User Account');
        }
        else if (existingPAs.size() > 0 && existingUsers.size() == 0)
        {
            response = processFurther(request, existingPAs[0].PersonContactId, existingPAs[0].Id, false);         
        }
        else if (existingPAs.size() == 0 && existingUsers.size() == 0)
        {           
            Account newProspect = createProspect(request) ;
            newProspect = [SELECT Id, PersonContactId FROM Account WHERE ID = :newProspect.Id];
            response = processFurther(request, newProspect.PersonContactId, newProspect.Id, true);
        }
        System.debug('registerIndividual: response = ' + response);
        return response;
    }
    

    private static SignUpResponse registerCorporate(SignUpRequest request) {
        SignUpResponse response;
        List<Account> existingCompanies = [ SELECT Id, Registration_No__c, OwnerId
                                            FROM Account
                                            WHERE Registration_No__c = :request.companyReg
                                            AND IsPersonAccount = false
                                        ];
        
        List<User> existingUsers  = [   SELECT Id, IsActive
                                        FROM User
                                        WHERE Username =: request.contactEmail
                                        LIMIT 1
                                    ];

        System.debug('existingUsers' + existingUsers);

        Id defaultAcctID = getDefaultAccountOwnerId();
        
        if(existingUsers.size() > 0 && !existingUsers[0].IsActive)
        {
                throwError('Unactivated Account');
        }
        else if(existingUsers.size() > 0 && existingUsers[0].IsActive)
        {
            throwError('Existing User Account');
        }
        else if(existingCompanies != null && existingCompanies.size() > 0) {  
            List<Contact> contacts = [  SELECT Id, AccountId, Email, FirstName, LastName
                                        FROM Contact
                                        WHERE Email = :request.contactEmail
                                        AND AccountId = :existingCompanies[0].Id
                                        AND IsPersonAccount = false
                                    ];        

            if (contacts.size() > 0)
            {       
                response = processFurther(request, contacts[0].Id, existingCompanies[0].Id, false);        
            }
            else if (contacts.size() == 0)
            {                
                Contact newContact = createContact(existingCompanies[0].Id , request);            
                newContact = [SELECT Id, AccountId FROM Contact WHERE ID =: newContact.Id];    
                response = processFurther(request, newContact.Id, newContact.AccountId, true);
            }

        } else {
            Account company            = new Account();
            company.RecordTypeId       = AccountUtil.getBusinessAccountRecordTypeId();
            company.Name               = request.companyName;
            company.Registration_No__c = request.companyReg;            
            if(defaultAcctID <> null)
            {
                company.OwnerId = defaultAcctID;
            }
            insert company;
                        
            Contact newContact = createContact(company.Id, request);             
            response = processFurther(request, newContact.Id, newContact.AccountId, true);
            System.debug('processFurther() response = ' + response);            
        }

        return response;
    }

    private static Account createProspect( SignUpRequest request )
    {
        Account newProspect = new Account();
        try {
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Account.SObjectType} );
            Id defaultAcctID = getDefaultAccountOwnerId();

            newProspect.RecordTypeId = AccountUtil.getProspectRecordTypeId();
            newProspect = updateProspect(newProspect, request);            
            newProspect.Signup_Channel__pc = 'myCarriage';
            newProspect.Signup_Date__pc    = Date.today();
            if(defaultAcctID <> null) {
                newProspect.OwnerId = defaultAcctID;
            }
            uow.registerNew(newProspect);
            uow.commitWork();
        }
        catch( Exception ex ) {
            System.debug('@@@@DEBUG createProspect ERROR :: err.msg = ' + ex.getMessage() );
            throwError(ex.getMessage());
        }
        System.debug('newProspect =' + newProspect);
        return newProspect;
    }


    private static Contact createContact( String accountId, SignUpRequest request )
    {
        Contact newContact = new Contact();
        try
        {
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Contact.SObjectType} );
           
            newContact.AccountId         = accountId;
            newContact.Signup_Channel__c = 'myCarriage';
            newContact.Signup_Date__c    = Date.today();
            newContact = updateContact(newContact, request);
            Id defaultAcctID = getDefaultAccountOwnerId();
            if(defaultAcctID <> null)
            {
                newContact.OwnerId = defaultAcctID;
            }
            uow.registerNew(newContact);
            uow.commitWork();
        }
        catch( Exception ex ) {
            System.debug('@@@@DEBUG createContact ERROR :: err.msg = ' + ex.getMessage() + '. At line: ' + ex.getLineNumber() + ' . Cause: ' + ex.getCause());
            throwError(ex.getMessage());
        }
        
        return newContact;
    }

    private static Id getDefaultAccountOwnerId() {
        global_var__c jccCusSetting = global_var__c.getOrgDefaults();
        if(String.isNotBlank( jccCusSetting.Default_Owner_C_C__c )) {
            return (Id)jccCusSetting.Default_Owner_C_C__c;
        }
        return null;
    }

    private static SignUpResponse processFurther(SignUpRequest request, String contactId, String accountId, Boolean isNewContact) {
        SignUpResponse response;
        User u = initExternalUser(request, contactId);
        
        Boolean isIndividual = request.customerType == 'individual';
        String password = isIndividual ? request.password : request.contactPwd;
        String confirmPassword = isIndividual ? request.confirmPassword : request.contactConfirmPwd;
        if(!Test.isRunningTest()){
            Site.validatePassword(u, password, confirmPassword);
        }
        
        if (u <> null) {
            System.debug('processFurther() user = ' + u);
            String registrationId = registerWithEmail(u);            
            if (registrationId <> null) {
                response = new SignUpResponse();
                response.registrationId = registrationId;
                response.accId          = accountId;
                response.conId          = contactId;
                response.isNewContact   = isNewContact;
            }
        }
        System.debug('processFurther() response = ' + response);
        return response;
    }

    private static String registerWithEmail(User u) { 
        String registrationId;
        System.debug('registerWithEmail() user = ' + u);
        try {            
            registrationId = !Test.isRunningTest() ? System.UserManagement.initSelfRegistration(Auth.VerificationMethod.EMAIL, u) : 'Testing';      
        } catch (Exception ex) {
            System.debug('@@@@DEBUG registerWithEmail ERROR :: err.msg = ' + ex.getMessage() );
            throwError(ex.getMessage());
        }

        return registrationId;
    }

    private static User initExternalUser(SignUpRequest request, String contactId) {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u              = new User(); 
        String alias;
        String email;
        String mobilePhone;
        if(request.customerType == 'individual') {
            email               = request.email.trim().toLowerCase();
            mobilePhone         = request.mobile.length() == 8 ? '65' + request.mobile : request.mobile;           
            u.FirstName         = request.firstName;
            u.LastName          = request.lastName;
            u.Display_Name__c   = request.firstName + ' ' + request.lastName;
            u.Salutation__c     = request.salutation;
            alias               = email.substringBefore('@') + 'ccl' ;
        } else {
            email               = request.contactEmail.trim().toLowerCase();
            mobilePhone         = request.contactMobile.length() == 8 ? '65' + request.contactMobile : request.contactMobile;
            u.FirstName         = request.conFirstname;
            u.LastName          = request.conLastname;
            u.Display_Name__c   = request.conFirstname + ' ' + request.conLastname;       
            u.CompanyName       = request.companyName;
            u.Company_Registration_No__c = request.companyReg;
            u.Title             = request.contactDesignation;
            u.Salutation__c     = request.conSalutation;
            alias               = email.substringBefore('@') + 'ccl' ;
        }
        u.Username          = email;
        u.Email             = email;
        u.CommunityNickname = email.length() <= 40  ? email : email.substring(0, 39);
        u.MobilePhone       = mobilePhone;
        u.ProfileId         = portalProfile.Id;
        u.ContactId         = contactId;
        u.TimeZoneSidKey    = 'Asia/Singapore';
        u.LocaleSidKey      = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.isValid__c        = true;
        u.Channel__c       = 'CCL'; 
        u.Alias             = alias.length() > 8 ? alias.substring(0,8).toLowerCase() : alias.toLowerCase();
        System.debug('initExternalUser() user = ' + u);
        return u;
    }



    @AuraEnabled
    public static String verifyUser(String verificationCode, SignUpRequest request, SignUpResponse response, String startURL) {
        try {
            System.debug('registrationId: ' + response.registrationId);
            System.debug('verificationCode: ' + verificationCode);
            System.debug('startURL: ' + startURL);
            System.debug('currentUser: ' + UserInfo.getUserId());
            Auth.VerificationResult res = !Test.isRunningTest() ? System.UserManagement.verifySelfRegistration(Auth.VerificationMethod.EMAIL, response.registrationId, verificationCode, startURL) 
                                        : new Auth.VerificationResult(new System.PageReference('https://www.abc.com'), true, 'success');
            System.debug('Result: ' + res);
            if(res.success == true) {
                Boolean isIndividual = request.customerType == 'individual';
                String email = isIndividual ? request.email : request.contactEmail;
                String password = isIndividual ? request.password : request.contactPwd;

                User u = [SELECT Id, LastName, FirstName, Email, Username FROM User WHERE Username = :email];
                if (!Test.isRunningTest()) {
                    System.setPassword(u.Id, password);
                }                

                //Update existing Prospect/Contact
                if(!response.isNewContact) {
                    if(isIndividual) {
                        Account prospect = [ SELECT Id, Salutation, FirstName, LastName, PersonEmail, PersonMobilePhone,
                                                    PDPA__pc, SMS__pc, Call__pc, Email__pc, Fax__pc, Source__pc
                                             FROM Account
                                             WHERE Id = :response.accId
                                        ];
                        prospect = updateProspect(prospect, request);
                        update prospect;
                    } else {
                        Contact contact =  [ SELECT Id, Salutation, FirstName, LastName, Email, MobilePhone,
                                                    PDPA__c, SMS__c, Call__c, Email__c, Fax__c, Source__c
                                             FROM Contact
                                             WHERE Id = :response.conId
                                        ];
                        contact = updateContact(contact, request);
                        update contact;
                    }                    
                }
                System.debug('Result URL: ' + res.redirect.getURL());
                return res.redirect.getURL();
            } else {
                throwError(res.message);
            }
        }
        catch(Exception e) {
            System.debug('verifyUser() ex = ' + e);
            throwError(e.getMessage());
        }
        return null;        
    }

    public static Account updateProspect(Account prospect, SignUpRequest request) {
        prospect.Salutation = request.salutation;
        prospect.FirstName  = request.firstName;
        prospect.LastName   = request.lastName;
        prospect.Full_Name__pc     = prospect.FirstName + ' ' + prospect.LastName;
        prospect.PersonEmail       = request.email;
        prospect.PersonMobilePhone = request.mobile.length() == 8 ? '65' + request.mobile : request.mobile;
        prospect.Source__pc        = String.isNotBlank(prospect.Source__pc) ? prospect.Source__pc : 'CCL';
        prospect.SignUp_Channel__pc = 'myCarriage';
        prospect.SignUp_Date__pc = Date.today();
        if(request.individualPDPA){
            prospect.PDPA__pc  = 'SMS;Call;Email';
            prospect.SMS__pc   = true;
            prospect.Call__pc  = true;
            prospect.Fax__pc   = true;
            prospect.Email__pc = true;
        } else {
            prospect.PDPA__pc  = '';
            prospect.SMS__pc   = false;
            prospect.Call__pc  = false;
            prospect.Fax__pc   = false;
            prospect.Email__pc = false;
        }

        System.debug('updateProspect() prospect = ' + prospect);
        return prospect;        
    }

    public static Contact updateContact(Contact contact, SignUpRequest request) {
        contact.Salutation   = request.conSalutation;
        contact.FirstName    = request.conFirstname;
        contact.LastName     = request.conLastname;
        contact.Full_Name__c = contact.FirstName + ' ' + contact.LastName;
        contact.MobilePhone  = request.contactMobile.length() == 8 ? '65' + request.contactMobile : request.contactMobile;
        contact.Email        = request.contactEmail;
        contact.Title        = request.contactDesignation;
        contact.Source__c    = String.isNotBlank(contact.Source__c) ? contact.Source__c :'CCL';
        contact.SignUp_Channel__c = 'myCarriage';
        contact.SignUp_Date__c = Date.today();
        if(request.contactPDPA){
            contact.PDPA__c  = 'SMS;Call;Email';
            contact.SMS__c   = true;
            contact.Call__c  = true;
            contact.Fax__c   = true;
            contact.Email__c = true;
        } else {
            contact.PDPA__c  = '';
            contact.SMS__c   = false;
            contact.Call__c  = false;
            contact.Fax__c   = false;
            contact.Email__c = false;
        } 
        System.debug('updateContact() contact = ' + contact);
        return contact;    
    }

    @AuraEnabled
    public static SignUpResponse resendOTP(SignUpRequest request, SignUpResponse response)
    {
        SignUpResponse res;
        try 
        {   
            Contact con = [ SELECT Id, AccountId
                            FROM Contact
                            WHERE Id = :response.conId
                            ];
            res = processFurther(request, con.Id, con.AccountId, response.isNewContact);
        }
        catch (Exception e) 
        {
            System.debug('resendOTP() ex = ' + e);
            throwError(e.getMessage());
        }

        return res;
    }

    private static void throwError (String errorMsg)
    {
        AuraHandledException e = new AuraHandledException(errorMsg);
        e.setMessage(errorMsg);
        throw e;
    }

    private static Boolean isValidRequest(SignUpRequest request, String customerType) {

        if(customerType == 'individual') {            
            if( String.isBlank(request.salutation)
                || String.isBlank(request.firstName)
                    || String.isBlank(request.lastName)
                        || String.isBlank(request.email)
                            || String.isBlank(request.mobile)
                        || String.isBlank(request.password)
                    || String.isBlank(request.confirmPassword)
                || request.individualPDPA == null
            ) {
                throwError('Individual SignUp. Missing required field(s)');
                return false;
            }                

            if(request.password != request.confirmPassword) {
                throwError('Passwords do not matched');
                return false;
            }
                
        } else {                
            if( String.isBlank(request.companyName)
                    || String.isBlank(request.companyReg)
                        || String.isBlank(request.conSalutation) 
                            || String.isBlank(request.conFirstname)
                                || String.isBlank(request.conLastname)     
                                    || String.isBlank(request.contactMobile)
                                || String.isBlank(request.contactEmail)                                  
                        || String.isBlank(request.contactPwd)
                    || String.isBlank(request.contactConfirmPwd)
                || request.contactPDPA == null
                ||String.isBlank(request.contactDesignation)
            ) {
                throwError('Company SignUp. Missing required field(s)');
                return false;
            }

            if(request.contactPwd != request.contactConfirmPwd) {
                throwError('Passwords do not matched');
                return false;
            }                
        }      
        return true;
    }

}