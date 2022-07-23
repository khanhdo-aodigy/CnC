public class AccountActivate {

    public String id;
    public String code;
    public String randomNumber;
    public String encodedId;
    public String encodedCode;
    Long activationElapsedHour;
    Long currentTime;
    Long accountActivationRequest;
    public Boolean elapsedHourExceeded {get;set;}
    public Boolean inValidApp {get;set;}
    public Boolean unauthorized {get;set;}
    public Boolean IsLinkActive {get;set;}
    public Boolean IsLinkInActive {get;set;}
    public Boolean isError {get;set;}
    public String email {get;set;}
    public User user {get;set;}
    public DateTime timestamp {get;set;}
    public Boolean globalHeader {get;set;}
    public Boolean mobileHeader {get;set;}
    User_Analytics__c analytics = new User_Analytics__c();
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    public String Community_URL = (String)JCC_GlobalVar.Community_URL__c;
    public String SF_Mobile_App_ClientID = (String)JCC_GlobalVar.SF_Mobile_App_ClientID__c;
    public String account_activation_emailID = (String)JCC_GlobalVar.Account_Activation_EmailId__c;
    public String WebRedirect_URI = (String)JCC_GlobalVar.WebRedirect_URI__c;
    public String SF_Web_App_ClientID = (String)JCC_GlobalVar.SF_Web_App_ClientID__c;
    public String MobileRedirect_URI = (String)JCC_GlobalVar.MobileRedirect_URI__c;
    public String PageUrl;
    public String header { get;set;}
    public String footer{get;set;}
    
    public AccountActivate()
    {
        timestamp = System.now();
        PageUrl = ApexPages.currentPage().getUrl();
        if(PageUrl.contains('channel=web'))
        {
            System.debug('Entered Web');
            globalHeader = true;
            mobileHeader = false;
        }
        else
        {
            System.debug('Entered Mobile');
            globalHeader = false;
            mobileHeader = true;
        }

        // Decrypt
        encodedId = ApexPages.currentPage().getParameters().get('identity');
        Blob b64decodedId = EncodingUtil.base64Decode(encodedId);
        id = b64decodedId.toString();
        
        encodedCode = ApexPages.currentPage().getParameters().get('code');
        Blob b64decodedCode = EncodingUtil.base64Decode(encodedCode);
        code = b64decodedCode.toString();
        
        // Analytics
        analytics.Request_Type__c = 'Account activation';
        analytics.Timestamp__c = System.now();
    }
    
    public Void activationLinkValidity()
    {
        //HTTP call for Header
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        try {        
            // req.setEndpoint('https://scsit.cyclecarriage.com/sg/sf-headerweb');
            req.setEndpoint('https://www.cyclecarriage.com/sg/sf-headerweb');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');      
            req.setMethod('GET');                
            res = http.send(req);                
            header = res.getBody();
        } 
        catch (Exception e) {
            System.debug('Error'+e);
        }

        // HTTP call for footer
        Http httpFooter = new Http();
        HttpRequest reqFooter = new HttpRequest();
        HttpResponse resFooter;
        try {        
            // reqFooter.setEndpoint('https://scsit.cyclecarriage.com/sg/sf-footerweb');
            reqFooter.setEndpoint('https://www.cyclecarriage.com/sg/sf-footerweb');
            reqFooter.setHeader('Content-Type', 'application/x-www-form-urlencoded');      
            reqFooter.setMethod('GET');                
            resFooter = http.send(reqFooter);                
            footer = resFooter.getBody();
        } 
        catch (Exception e) {
            System.debug('Error'+e);
        }

        user = [SELECT isValid__c, Username, Account_Activation_Request__c, Account_Activation_Random_Number__c, IsActivationLinkActive__c 
                FROM User
                WHERE Id=: id];
                
        currentTime = ((DateTime.now().getTime())/1000/60/60); 
        accountActivationRequest = ((user.Account_Activation_Request__c).getTime()/1000/60/60);
        activationElapsedHour = currentTime - accountActivationRequest;
        System.debug('elapsedHour='+activationElapsedHour);
        analytics.Name = user.Username;
        analytics.User__c = user.Id;
        if(activationElapsedHour >= 72)
        {
            elapsedHourExceeded    = true;
            IsLinkActive           = false;
            IsLinkInActive         = false;
            analytics.Page_Name__c = 'Activation Link Expired';
        }
        else if(user.Account_Activation_Random_Number__c == code)
        {
            if(user.IsActivationLinkActive__c == 'Active')
            {
                user.IsActivationLinkActive__c = 'Inactive';
                user.isValid__c = true;
                update user;

                elapsedHourExceeded    = false;
                IsLinkActive           = true;
                IsLinkInActive         = false;
                analytics.Page_Name__c = 'Account Activation Confirmation Page';
            }
            else
            {
                elapsedHourExceeded    = false;
                IsLinkActive           = false;
                IsLinkInActive         = true;
                analytics.Page_Name__c = 'Account Already Activated';
            }
        }
        else
        {
            elapsedHourExceeded = false;
            IsLinkActive        = false;
            IsLinkInActive      = false;
            unauthorized        = true;
        }
        insert analytics;
    }


    public PageReference userIsActive()
    {
        analytics.Page_Name_Action__c = 'Clicked C&C app Button';
        PageReference loginPageRef = new PageReference(Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI);
        loginPageRef.setredirect(true);
        return loginPageRef;   
    }


    public void InvalidAppRequest() 
    {
        inValidApp = true;
    }


    public PageReference forwardRequest()
    {
        analytics.Page_Name_Action__c = 'Clicked CONTINUE TO LOGIN';
        if(PageUrl.contains('channel=web'))
        {
            PageReference loginPageRef= new PageReference(Label.WebLogin);
         	loginPageRef.setredirect(true);
            return loginPageRef;
        }
        else
        {      
            //Community_URL+'/endusers/services/oauth2/authorize?client_id='+SF_Mobile_App_ClientID+'&redirect_uri='+MobileRedirect_URI
         	//PageReference loginPageRef= new PageReference('https://scsit.cyclecarriage.com/sg/launchapp');
			PageReference loginPageRef = new PageReference(Label.WebLogin);
        	loginPageRef.setredirect(true);
            return loginPageRef;
        }
    }

    
    public PageReference resendActivationLink()
    {
        PageReference accountPageRef;
        encodedId = ApexPages.currentPage().getParameters().get('identity');
        Blob b64decodedId = EncodingUtil.base64Decode(encodedId);
        id = b64decodedId.toString();
        user = [SELECT Email,Account_Activation_Random_Number__c FROM User WHERE Id=: id];
        
        //analytics
        analytics.Page_Name_Action__c = 'Clicked Resend Activation Link Button';
        
        Contact cntObj = new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController( cntObj );
        SearchNRIC snric = new SearchNRIC(sc);
        randomNumber     = snric.generateOTP();
        user.Account_Activation_Request__c       = System.now();
        user.Account_Activation_Random_Number__c = randomNumber;
        user.IsActivationLinkActive__c           = 'Active';
        update user;

        SendEmail(id, user.Account_Activation_Random_Number__c);
        
        if(globalHeader) {
            accountPageRef= new PageReference('/SignupSuccess?id='+encodedId+'&request=resendAccountActivation&channel=web');
        }
        else {
            accountPageRef= new PageReference('/SignupSuccess?id='+encodedId+'&request=resendAccountActivation');
        }
        accountPageRef.setredirect(true);
        return accountPageRef;  
    }
    

    public void SendEmail(String userId, String RandomCode)
    {
        String ActivationLink;
        List<EmailTemplate> lstEmailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id =: account_activation_emailID];
        EmailTemplate eTemplate = !lstEmailTemplate.isEmpty() ? lstEmailTemplate.get(0) : null;

        System.debug('@@@@DEBUG SendEmail :: eTemplate = ' + eTemplate );
        if( eTemplate <> null)
        {
            // encryption
            Blob data = Blob.valueOf(userId);
            String b64encryptedData = EncodingUtil.base64Encode(data); 
            
            Blob randomdata = Blob.valueOf(RandomCode);
            String b64encryptedrandomData = EncodingUtil.base64Encode(randomdata);
            if(globalHeader){
                ActivationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+'&channel=web';
            }
            else{
                ActivationLink = Community_URL+'/endusers/AccountActivationRequest?identity='+b64encryptedData+'&code='+b64encryptedrandomData+' ';
            }
        
            // process the merge fields
            String subject  = eTemplate.Subject;
            String htmlBody = eTemplate.HtmlValue;
            String plainBody = eTemplate.Body;

            htmlBody = htmlBody.replace('{!Community_Url}', ActivationLink);
        
            //build the email message
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            email.setReplyTo('profile.sg@e.cyclecarriage.com');
            string [] arrStrBcc = new String []{};
            arrStrBcc.add('sfcomm@cyclecarriage.com.sg');
            email.setBccAddresses(arrStrBcc);
            //email.setSenderDisplayName('Your C&C Profile');
            email.setTargetObjectId(userId);
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
            try {
                Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
            } 
            catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
       
    }
    
}