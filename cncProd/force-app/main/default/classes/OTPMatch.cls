public class OTPMatch 
{   
    public Boolean OTPExpired {get;set;}
    public Boolean invalidOTP {get;set;}
    public String OTP {get;set;}
    public String mobile {get;set;}
    public DateTime timestamp {get;set;}
    public Boolean globalHeader {get;set;}
    public Boolean mobileHeader {get;set;}
    public Boolean globalFooter {get;set;}
    public String PageUrl;
    Contact con;
    Long elapsedMinute;
    Long currentTime;
    Long otpTimestampMinute;
    String id;
    String resendOTP;
    String msg;
    
    public OTPMatch()
    {
        timestamp  = System.now();
        invalidOTP = false;
        OTPExpired = false;
        id         = ApexPages.currentPage().getParameters().get('id');
        con        = [SELECT Account_Activation_OTP__c, MobilePhone, OTP__c FROM Contact WHERE Id =: id];
        mobile     = con.MobilePhone;
        setmobile(mobile.replace(con.MobilePhone.substring(4,8),'** **'));
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

    public void setmobile(String mobile)
    {
        String mobileToFormat = mobile;
        if(String.isNotBlank(mobile) && mobile.startsWith('65'))
        {
            mobileToFormat = mobile.remove('65');
            this.mobile= '+65 ' + mobileToFormat;
        }
        else
        {
            this.mobile= '+65 ' + mobile;
        }
    }

    public PageReference OTPMatched()
    {        
   
        /* ----- OTP Time Difference Calculation ----- */
        currentTime = ((DateTime.now().getTime())/1000/60);
        otpTimestampMinute = ((con.Account_Activation_OTP__c).getTime()/1000/60);
        elapsedMinute = currentTime - otpTimestampMinute;
        /* ------------------- End --------------------*/
        
        if(elapsedMinute > 30)
        {
            OTPExpired = true;
            invalidOTP = false;
        }
        else if(con.OTP__c == OTP)
        {
            invalidOTP = false;
            OTPExpired = false;
            PageReference pageRef;
            if(PageUrl.contains('channel=web'))
            {
              	pageRef = new PageReference('/apex/CreateAccount?event=Enter_Personal_Details&id='+id+'&channel=web');
            	pageRef.setredirect(true);          
            }
            else
            {
				string strBrunch = '';
				strBrunch = ApexPages.currentPage().getParameters().get('branch');
                pageRef = new PageReference('/apex/CreateAccount?event=Enter_Personal_Details&id='+id+'&branch='+strBrunch);
            	pageRef.setredirect(true);
            }

            return pageRef;
        }
        else if( String.isNotBlank( OTP ) )
        {
            invalidOTP = true;
            OTPExpired = false;
        }

        return null;
    }
    
    public void ResendOTP()
    {
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
        String strMobileConnectAPIkeyword = JCC_GlobalVar.MobileConnect_API_Keyword__c;

        invalidOTP = false;
        OTPExpired = false;
        OTP = '';
        Contact contact= new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SearchNRIC snric = new SearchNRIC(sc);
        resendOTP = snric.generateOTP();
        msg = 'Your verification code for sign up is '+resendOTP;
        Send_OTP_SMS.SENDSMS(msg, con.MobilePhone, con.MobilePhone, strMobileConnectAPIkeyword );
        con.OTP__c = resendOTP;
        con.Account_Activation_OTP__c = System.now();
        update con;
    }
}