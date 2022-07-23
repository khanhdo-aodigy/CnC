/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunitiesSelfRegController 
{	
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String name {get;set;}
    public String Email2{get;set;}
    public String nric {get;set;}
    public String ContactId {get;set;}
    public String displayName {get;set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public Contact contact {get; set;}
	public Account personAccount {get; set;} //PA MIGRATION
    public Boolean isError {get; set;}
    public DateTime timestamp {get;set;}
    public Boolean globalHeader {get;set;}
    public Boolean mobileHeader {get;set;}
    public Boolean globalFooter {get;set;}
    public String errorMessage {get; set;}
    public String existingAccount {get;set;}
    public Boolean accountNotActivated {get;set;}
    public String pageUrl;
    public String activationLink;
    String id;
    List<Account> account;
    List<User> user;
    public String email;
    public User externalUser;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    public String Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    public String SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
	public String Profile_Id = (String)JCC_GlobalVar.Profile_Id__c;
    public String Account_Activation_EmailId = (String)JCC_GlobalVar.Account_Activation_EmailId__c;
    public String MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    public String WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    public String SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
    public String TriggeredSmsIdSignUp= (String)JCC_GlobalVar.TriggeredSmsIdSignUp__c;
    
/*------------Getter and Setter---------------*/    
    public Contact getcontact()
	{
        id = ApexPages.currentPage().getParameters().get('id');
        contact = [SELECT Email, /*Account__c, Account__r.id,*/ AccountId, Name, Full_Name__c, FirstName, LastName, NRIC_Passport_No__c FROM Contact WHERE Id=: id];
        return contact;
    }

    public String getemail()
    {
        return email;
    }
    
    public void setemail(String email)
    {
        this.email=email;    
    }
    
    public void setemail2(String email)
    {
        this.email2=email;    
    }
     
    
/*------------Getter and Setter Ends---------------*/  
    
    private boolean isValidPassword() 
	{
        return password == confirmPassword;
    }

    /*-----------------Constructor-------------------*/
    public CommunitiesSelfRegController(ApexPages.StandardController controller) 
	{
		timestamp = system.now();
        pageUrl = ApexPages.currentPage().getUrl();
		    
		if(pageUrl.contains('channel=web'))
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

        String expid = ApexPages.currentPage().getParameters().get('expid');            
        if (expId != null) 
		{
            Site.setExperienceId(expId); 
        } 

        contact = getcontact();
        name = contact.Name;
        email = contact.Email;
        firstName = contact.FirstName;
        lastName = contact.LastName;
        nric= contact.NRIC_Passport_No__c; 
        isError = false;
        contactId = contact.Id;

        System.debug(' -- Contact'+Contact);
        System.debug(' -- expid '+expid );
    }
    /*-----------------Constructor Ends-------------------*/
    
    public PageReference registerNewUser() 
	{	       
        String inputEmail = getemail();   
        account = [SELECT Id FROM Account WHERE PersonEmail =: inputEmail];
        contact = getcontact();

        List<User> usr = [SELECT id from User WHERE ContactId =: contact.Id];

        System.debug('@@@@DEBUG registerNewUser :: inputEmail = ' + inputEmail );
        System.debug('@@@@DEBUG registerNewUser :: account = ' + account );
        System.debug('@@@@DEBUG registerNewUser :: contact = ' + contact );
        System.debug('@@@@DEBUG registerNewUser :: usr = ' + usr );

		List<user> exsisUser = new List<User>([SELECT Id, IsValid__c FROM USER WHERE IsPortalEnabled = true AND Email =: inputEmail LIMIT 1]);     
        if(!exsisUser.isEmpty() && (!exsisUser[0].IsValid__c))
		{
			accountNotActivated = true;
            isError = true;
            setemail2(inputEmail.replaceAll('(?<=.).(?=[^@]*?.@)', '*'));
            errorMessage = Label.ErrorExsistingAccount;
            existingAccount = Label.ErrorExsistingAccountNoActivation + ' ' + Label.C_CHelpNumber;
        }
        else if(!(account.isEmpty()) && !(usr.isEmpty()))
        {
            isError = true;
            errorMessage ='This email is already linked to an existing account. Please log in or enter another email address.';
        }
        else if (!isValidPassword()) // it's okay if password is null - we'll send the user a random password in that case
        {
            isError = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
        }
        else
        {
			String profileId = Profile_Id; // To be filled in by customer.
			String roleEnum = null; // To be filled in by customer.
			String accountId = ''; // To be filled in by customer.

			if(String.isNotEmpty(contact.AccountId))
			{
                accountId = contact.AccountId;
                personAccount = [SELECT Id, PersonEmail, Account_Activation_OTP__pc  FROM Account WHERE Id =: contact.AccountId];
			}

			String userName = inputEmail;

			User u = new User();
                                
			ApexPages.StandardController sc = new ApexPages.StandardController(u);
			SearchNRIC snric =new SearchNRIC(sc);
			String randomNumber = snric.generateOTP();
			u.Username          = userName;
			u.Email             = inputEmail;
			u.FirstName         = firstName;
			u.LastName          = lastName;
			u.CommunityNickname = userName;
			u.Display_Name__c   = displayName;
			u.ProfileId         = profileId;
			//u.NRIC__c           = nric;
			u.Account_Activation_Request__c = System.now();
			u.Account_Activation_Random_Number__c = randomNumber;
			u.IsActivationLinkActive__c = 'Active';
            //u.ContactId__c      = contactId;
            u.ContactId         = contactId;
			
			//PA MIGRATION			
			personAccount.PersonEmail                = inputEmail;
            personAccount.Account_Activation_OTP__pc = null;
			
			   
			String userId;       
			try
			{           
				userId = Site.createExternalUser(u, accountId, password);
				System.debug('@@@@ userId '+userId );
				if(String.isNotBlank(userId))
				{
					//PA MIGRATION					
					update personAccount;	
				}

			}
			catch(Site.ExternalUserCreateException ex) 
			{
				
                List<String> errors = ex.getDisplayMessages();
                for (String error : errors)  
				{
					
                    isError = true;
                    String errorMessagestr = ex.getMessage();
                    System.debug('@@@@DEBUG registerNewUser :: errorMessagestr = '+errorMessagestr );
                    if(errorMessagestr.startsWithIgnoreCase('[That Display'))
                    {
                        errorMessage = 'That Display Name already exists. Enter a unique Display Name.';                       
                    }                  
                    else if(errorMessagestr.startsWithIgnoreCase('[That nickname'))
                    {
                        errorMessage = Label.ErrorExsistingAccount;
                        existingAccount = Label.ErrorExsistingAccountBody;
                    }
                    else
                    {
                        errorMessage = ex.getMessage();
						System.debug('iserror ++ ' + isError + ' ++ ' + errorMessage + ' ++AccId ' + accountId);
                    }
				}	
				// This message is used for debugging. Do not display this in the UI to the end user.
				// It has the information around why the user creation failed.
			}
        
			if (userId != null) 
			{ 
                resendActivation(userId,randomNumber);
                Blob data = Blob.valueOf(userId);
                String b64encryptedData = EncodingUtil.base64Encode(data); 
				PageReference page;

				if(pageUrl.contains('channel=web'))
                {
					
                    page = new PageReference('/apex/SignupSuccess?event=AccountActivation_Email_Sent&id='+b64encryptedData+'&request=Signup&channel=web');
                }
                else
                {
					string strBrunch = '';
					strBrunch= ApexPages.currentPage().getParameters().get('branch');
                    page = new PageReference('/apex/SignupSuccess?event=AccountActivation_Email_Sent&id='+b64encryptedData+'&request=Signup'+'&branch='+strBrunch);
					System.debug('Final Url passing ++ ' + page);
				}
                
                return page;
			}
		}
	
		return null;
    }
    
    public void resendActivation(String userId, String randomNumber)
    {      

		externalUser= [Select Id,Email,LastName from User where Id=: userId];
        System.debug('testing---zzz---'+ Account_Activation_EmailId);
        EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Id =: Account_Activation_EmailId];   
        Blob data = Blob.valueOf(userId);
        String b64encryptedData = EncodingUtil.base64Encode(data); 
        
        Blob randomdata = Blob.valueOf(randomNumber);
        String b64encryptedrandomData = EncodingUtil.base64Encode(randomdata);

        if(pageUrl.contains('channel=web'))
        {
            activationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+'&channel=web';
        }
        else
        {
            activationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData;
        }
                
        
        // process the merge fields
        String subject = emailTemplate.Subject;
    
        String htmlBody = emailTemplate.HtmlValue;
    
        htmlBody = htmlBody.replace('{!Community_Url}', activationLink);
        htmlBody = htmlBody.replace('{!Receiving_User.LastName}', externalUser.LastName);
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Community_Url}', activationLink);
        plainBody = plainBody.replace('{!Receiving_User.LastName}', externalUser.LastName); 
        
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo('profile.sg@e.cyclecarriage.com');
            
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if ( owea.size() > 0 ) 
        {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
            
        //email.setSenderDisplayName('Your C&C Profile');
        email.setTargetObjectId(userId);
        email.setSaveAsActivity(false);
        string [] arrStrBcc = new String []{};
        arrStrBcc.add('sfcomm@cyclecarriage.com.sg');
        email.setBccAddresses(arrStrBcc);
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);
        
        try 
        {
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
        }
    }

	public PageReference forwardRequestToLogin()
    {
		PageReference loginPageRef;
        if(pageUrl.contains('channel=web'))
        {
			loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Web_App_ClientID+'&redirect_uri='+WebRedirect_URI);
            loginPageRef.setredirect(true);
        }
        else
        {
			loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
            loginPageRef.setredirect(true);
        }
    
        return loginPageRef;
    }
     
    public PageReference ResendActivationLink()
    {		
        PageReference signupSuccessPageRef;   
        String inputEmail = getemail();     
        if(String.IsNotBlank(inputEmail))
		{           
			List<user> usr = new List<User>();
			usr = [SELECT Id, Email, Account_Activation_Random_Number__c FROM User WHERE IsPortalEnabled = true AND Email =: inputEmail LIMIT 1];
            if(!usr.isEmpty())
			{
                System.debug('sign up'+usr );
                String Code = generateOTP(); //using generateOtp function for generating random number 
                usr[0].Account_Activation_Request__c = System.now();
                usr[0].Account_Activation_Random_Number__c = Code;
                usr[0].IsActivationLinkActive__c = 'Active';
                
                if (!Test.isRunningTest())
                {
                    Database.SaveResult[] results = Database.update(usr, true);

                    for(Database.SaveResult sr : results) 
                    {
                        if(sr.isSuccess()) 
                        {
                            resendActivation(usr[0].Id,usr[0].Account_Activation_Random_Number__c );
                        }
                    }       
                }
                       
				Blob data = Blob.valueOf(usr[0].Id);
                String b64encryptedData = EncodingUtil.base64Encode(data);                   
                
				if(PageUrl.contains('channel=web'))
                {
                    signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation&channel=web');
                    signupSuccessPageRef.setredirect(true);   
                }
				else
                {
                    signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation');
                    signupSuccessPageRef.setredirect(true);
                }                   
                
				return signupSuccessPageRef;
			}
		}
                                       
		return signupSuccessPageRef;
    }    
   
    public String generateOTP()
    {
        final String chars = '0123456789';
        String randStr = '';
        while (randStr.length() < 6) 
		{
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()*999999), chars.length());
			randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    } 

    public PageReference forwardRequestLink()
    {
		
        PageReference continuePageRef;
        Contact con = new Contact();
        con = [SELECT Id, Name, NRIC_Passport_No__c, OTP__c, Account_Activation_OTP__c, MobilePhone, FirstName, Email FROM Contact where Id =: ContactID];

        if (con != null )
		{                           
			String verificationCode = generateOTP();
			con.OTP__c = verificationCode;
			con.Account_Activation_OTP__c = System.now();
            update con;
            
			String msg = 'Your verification code for sign up is '+verificationCode;
			Send_OTP_SMS.SENDSMS(msg, con.MobilePhone, con.MobilePhone, TriggeredSmsIdSignUp);               
            if(PageUrl.contains('channel=web'))
            {
                continuePageRef= new PageReference('/apex/OTPGeneration?event=Enter_OTP&id='+con.Id+'&channel=web');
                continuePageRef.setredirect(true);
            }
            else
            {
                continuePageRef= new PageReference('/apex/OTPGeneration?event=Enter_OTP&id='+con.Id);
                continuePageRef.setredirect(true); 
            }   						                    
        }
        
        return continuePageRef;
	}   
      
	public pageReference refreshPage() 
	{      
        isError = false;
        return null;
	}           
}