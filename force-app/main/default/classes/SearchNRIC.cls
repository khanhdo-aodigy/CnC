global class SearchNRIC 
{
    String msg;
    String verificationCode;
    public String errors {get;set;}
    List <Contact> con;
    List <Registered_Vehicle__c> regVeh;
    public List <User> user ;
    public Boolean isRegVehError{get;set;}
    public Boolean isDupRegVehError{get;set;}
    public Boolean isError{get;set;}
    public Boolean isMobileMismatchError{get;set;}
    public Boolean isMobileError{get;set;}
    public String email {get;set;}
    public String Inputvalue {get;set;}
    public String Inputvalue2 {get;set;}
    public string selectedValue{get;set;}
    public Boolean NRICNotFound {get;set;}
    public Boolean existingAccount {get;set;}
    public Boolean accountNotActivated {get;set;}
    public DateTime timestamp {get;set;}
    public Boolean globalHeader {get;set;}
    public Boolean mobileHeader {get;set;}
    public Boolean globalFooter {get;set;}
    public String PageUrl;
    public String ActivationLink;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
    public String  Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    public String  SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    public String  Profile_Id = (String)JCC_GlobalVar.Profile_Id__c;
    public String  Account_Activation_EmailId = (String)JCC_GlobalVar.Account_Activation_EmailId__c;
    public String  MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    public String  WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    public String  SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
    public String  TriggeredSmsIdSignUp= (String)JCC_GlobalVar.TriggeredSmsIdSignUp__c;
    
    public String  SF_Mobile_App_MYMB_ClientID = (String)JCC_GlobalVar.mymb_mobile_app__c; //MyMB Fix
    public String  MobileRedirect_URI_MB = (String)JCC_GlobalVar.MobileRedirect_URI_MB__c; //MyMb Fix
    public String  API_Gateway_URL = (String)JCC_GlobalVar.APIGateway_url__c; //MyMB Fix
    public string strBranch;
    
    public SearchNRIC(ApexPages.StandardController controller)
    {
        strBranch = '';
        timestamp = system.now();
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
    }

    public void setemail(String email)
    {
        this.email= email;
    }
    
    //Funtion for generating OTP
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
    
    public PageReference nricMatch()
    { 
        try
        {    
            Integer RegVehCount;         
            PageReference pageRef; 
            regVeh = [SELECT Id,
                      Contact__c, Branch__c,
                      Contact__r.MobilePhone
                      FROM Registered_Vehicle__c 
                      WHERE Registration_Number__c =: Inputvalue2.trim() 
                      LIMIT 2];  
            
            System.debug('@@@@DEBUG nricMatch :: regVeh = ' + regVeh );
            
            if(!regVeh.isEmpty())
            {
                con = [ SELECT Id, 
                            NRIC_Passport_No__c,
                            OTP__c,MobilePhone,
                            FirstName,
                            Email 
                        FROM Contact 
                        WHERE Id =: regVeh[0].Contact__c 
                        //AND Source__c = 'DWH'
                        AND IsPersonAccount = true
                        ]; 
                
                System.debug('@@@@DEBUG nricMatch :: con = ' + con );
        
                if(con.Size() > 0)
                {
                    user = [SELECT Id,
                            IsActive,
                            Email,
                            Name,
                            Account_Activation_Request__c,
                            Last_Forgot_Password_Request__c,
                            isValid__c 
                            FROM User 
                            WHERE Contact.NRIC_Passport_No__c =: con[0].NRIC_Passport_No__c 
                            AND Profile.Name = 'End User' LIMIT 2];
                }
                
                isRegVehError = false;
                RegVehCount = regVeh.size();
                
                if(RegVehCount == 1)
                {
                    strBranch = regVeh[0].Branch__c;
                    isDupRegVehError = false;
                    
                    if(user.size() == 0 && con.Size() > 0)              
                    {
                        String inputMobileNum = '65' + String.ValueOf(Inputvalue);
                        if(con[0].MobilePhone != '' && con[0].MobilePhone != null && con[0].MobilePhone == inputMobileNum)
                        {
                            System.debug('Loop1'+con);
                            verificationCode = generateOTP();
                            con[0].OTP__c = verificationCode;
                            con[0].Account_Activation_OTP__c = System.now();
                            update con[0];
                            
                            msg = 'Your verification code for sign up is ' + verificationCode;
                            Send_OTP_SMS.SENDSMS(msg, con[0].MobilePhone, con[0].MobilePhone, TriggeredSmsIdSignUp);
                            system.debug('OTP==========' + verificationCode);
                            
                            if(PageUrl.contains('channel=web'))
                            {
                                pageRef= new PageReference('/apex/OTPGeneration?event=Enter_OTP&id=' + con[0].Id + '&channel=web');
                                pageRef.setredirect(true);
                            }
                            else
                            {
                                pageRef= new PageReference('/apex/OTPGeneration?event=Enter_OTP&id=' + con[0].Id + '&branch=' + regVeh[0].Branch__c);
                                pageRef.setredirect(true);   
                            }

                            return pageRef;    
                        }
                        else
                        {
                            if(con[0].MobilePhone != '' && con[0].MobilePhone != null && con[0].MobilePhone != inputMobileNum)
                            {
                                System.debug('2::::: ' + con[0].MobilePhone);
                                System.debug('2::::: ' + inputMobileNum);
                                isMobileMismatchError = true;
                            }
                            else
                            {
                                System.debug('3' + con[0].MobilePhone);
                                isMobileError = true;
                            }
                            return null;
                        }             
                    }
                    else if(con.Size() == 0 && user.Size() == 0)
                    {
                        existingAccount = false;
                        accountNotActivated = false;
                    }
                    else if(user.size()>0)
                    {
                        if(user[0].isValid__c)
                        {
                            existingAccount = true;
                            accountNotActivated = false;
                            System.debug('exsisting acc'+user[0]);
                        }
                        else 
                        {
                            existingAccount = false;
                            accountNotActivated = true;
                            setemail(con[0].Email.replaceAll('(?<=.).(?=[^@]*?.@)', '*'));
                        }    
                    }   
                }
                else if(RegVehCount > 1)
                {
                    isDupRegVehError = true;   
                }     
            }          
            else
            {
                isRegVehError = true;   
            }          
            
            return null;
        }
        catch(Exception e)
        {
            isError = true;
            errors = e.getMessage();      
            System.debug('@@@error '+e+'line'+e.getLineNumber());
            return null;
        }   
    }
    
    public PageReference ResendActivation()
    {
        PageReference signupSuccessPageRef;       
        regVeh = [SELECT Id,Contact__c,Contact__r.MobilePhone
                  FROM Registered_Vehicle__c 
                  WHERE Registration_Number__c =: Inputvalue2.trim()
                   AND Contact__c!=null LIMIT 1];
        
        String inputMobileNum = '65' + String.ValueOf(Inputvalue); 
        if(!regVeh.isEmpty())
        {           
            con = [select Id, NRIC_Passport_No__c,OTP__c,MobilePhone,FirstName,Email 
                   from Contact where Id =: regVeh[0].Contact__c 
                   //AND Source__c = 'DWH'
                    AND IsPersonAccount = true LIMIT 1
                    ];
            
            if((con.Size()>0 && !con.isEmpty()) && con[0].NRIC_Passport_No__c!=null)
            {
                user = [select Id,Email,Account_Activation_Random_Number__c 
                        from User 
                        WHERE Contact.NRIC_Passport_No__c =: con[0].NRIC_Passport_No__c
                        LIMIT 1];
                
                if(!user.isEmpty())
                {
                    String Code = generateOTP(); //using generateOtp function for generating random number 
                    user[0].Account_Activation_Request__c = System.now();
                    user[0].Account_Activation_Random_Number__c = Code;
                    user[0].IsActivationLinkActive__c = 'Active';
                    Database.SaveResult[] results = Database.update(user, true);
                    
                    for(Database.SaveResult sr : results) 
                    {
                        if(sr.isSuccess()) 
                        {
                            System.debug('===== ' + user[0].Id + '==== ' + user[0].Account_Activation_Random_Number__c);
                            SendEmail(user[0].Id,user[0].Account_Activation_Random_Number__c);
                        }
                    }       
                    
                    Blob data = Blob.valueOf(user[0].Id);
                    String b64encryptedData = EncodingUtil.base64Encode(data);                   
                    if(PageUrl.contains('channel=web'))
                    {
                        signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation&channel=web');
                        signupSuccessPageRef.setredirect(true);   
                    }
                    else
                    {
                        signupSuccessPageRef= new PageReference('/SignupSuccess?id='+b64encryptedData+'&request=resendAccountActivation'+'&branch='+strBranch);
                        signupSuccessPageRef.setredirect(true);
                    }
                }
            }
        }        

        return signupSuccessPageRef;
    }
    
    public void SendEmail(String userId, String RandomCode)
    {
        EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Id =: Account_Activation_EmailId];
        user = [SELECT LastName FROM User where Id =: userId];
        // encryption
        Blob data = Blob.valueOf(userId);
        String b64encryptedData = EncodingUtil.base64Encode(data); 
        
        Blob randomdata = Blob.valueOf(RandomCode);
        String b64encryptedrandomData = EncodingUtil.base64Encode(randomdata); 
        if(PageUrl.contains('channel=web'))
        {
            ActivationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+'&channel=web ';
        }
        else
        {
            ActivationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+' ';
        }
        
        // process the merge fields
        String subject = emailTemplate.Subject;
        
        String htmlBody = emailTemplate.HtmlValue;
        System.debug('===== ' + ActivationLink);
        
        htmlBody = htmlBody.replace('{!Community_Url}', ActivationLink);
        htmlBody = htmlBody.replace('{!Receiving_User.LastName}', user[0].LastName);
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Community_Url}', activationLink);
        plainBody = plainBody.replace('{!Receiving_User.LastName}', user[0].LastName); 
        
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo('profile.sg@e.cyclecarriage.com');
        email.setSenderDisplayName('Your C&C Profile');
        email.setTargetObjectId(userId);
        email.setSaveAsActivity(false);
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
    
    
    public PageReference forwardRequest()
    {
        PageReference continuePageRef;
        regVeh = [SELECT Id,Contact__c,Contact__r.MobilePhone
                  FROM Registered_Vehicle__c 
                  WHERE Registration_Number__c =: Inputvalue2.trim()];
        
        String inputMobileNum = '65'+String.ValueOf(Inputvalue);      
        
        if(!regVeh.isEmpty())
        {
            con = [SELECT Id, NRIC_Passport_No__c,OTP__c,MobilePhone,FirstName,Email 
                   FROM Contact 
                   WHERE Id =: regVeh[0].Contact__c 
                   //AND Source__c = 'DWH' 
                   AND IsPersonAccount = true];
            
            if (Con.Size()>0 && !con.isEmpty())
            {
                if(con[0].MobilePhone!= inputMobileNum || (con[0].MobilePhone =='' && con[0].MobilePhone == null))
                {
                    if(con[0].MobilePhone !='' && con[0].MobilePhone != null && con[0].MobilePhone!= inputMobileNum)
                    {
                        isMobileMismatchError = true;
                    }
                    else
                    {
                        isMobileError = true;
                    }   

                    return null;
                }
                else 
                {                  
                    verificationCode = generateOTP();
                    con[0].OTP__c = verificationCode;
                    con[0].Account_Activation_OTP__c = System.now();
                    update con[0];
                    msg= 'Your verification code for sign up is '+verificationCode;
                    Send_OTP_SMS.SENDSMS(msg, con[0].MobilePhone, con[0].MobilePhone, TriggeredSmsIdSignUp);                  
                    if(PageUrl.contains('channel=web'))
                    {
                        continuePageRef= new PageReference('/apex/OTPGeneration?event=Enter_OTP&id='+con[0].Id+'&channel=web');
                        continuePageRef.setredirect(true);
                    }
                    else
                    {
                        continuePageRef= new PageReference('/apex/OTPGeneration?event=Enter_OTP&id='+con[0].Id);
                        continuePageRef.setredirect(true); 
                    }                       
                }
            }
        }

        return continuePageRef;
    }

    public PageReference forwardRequestToLogin()
    {
        PageReference loginPageRef;
        if(PageUrl.contains('channel=web'))
        {
            loginPageRef= new PageReference(Label.WebLogin);
            loginPageRef.setredirect(true); 
        }
        
        else if(strBranch == 'CCI')
        {
            //loginPageRef= new PageReference(Community_URL+'/mymb/services/oauth2/authorize?client_id='+SF_Mobile_App_MYMB_ClientID+'&redirect_uri='+MobileRedirect_URI_MB+'&branch='+strBranch);
            loginPageRef = new PageReference(API_Gateway_URL + '/auth/mymb/sf_authorize?client_id='+SF_Mobile_App_MYMB_ClientID+'&redirect_uri='+MobileRedirect_URI_MB+'&branch='+strBranch);
            System.debug('Redirect ++ ' + loginPageRef);
            loginPageRef.setredirect(true);
        }
        
        else
        {
            loginPageRef= new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
            loginPageRef.setredirect(true);
        }

        return loginPageRef;
    }
    
    public pageReference refreshPage() 
    {
        isRegVehError = false;
        isDupRegVehError = false;
        isError = false;
        isMobileMismatchError = false;
        isMobileError = false;
        existingAccount = false;
        accountNotActivated = false;
        
        return null;
    }
}