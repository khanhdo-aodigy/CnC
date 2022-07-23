public class MobileHeader {

    Public String title {get;set;}
    Public Boolean LoginPage {get;set;}
    Public Boolean otherPages {get;set;}
    Public Boolean forgotPasswordPage {get;set;}
    Public Boolean mobilePage {get;set;}
    public MobileHeader()
    {
        
      title  = ApexPages.currentPage().getUrl().split('apex/')[1];
        if(title.containsIgnoreCase('SiteLogin'))
        {
            title = 'LOG IN';
            LoginPage = true;
        }
        else if(title.contains('resendAccountActivation'))
        {
            title = 'LOG IN';
            otherPages = true;
        }
        else if(title.equalsIgnoreCase('NRICMatch?event=Enter_NRIC&previousPage=Login'))
        {
            title = 'SIGN UP FOR A C&C ACCOUNT';
            mobilePage = false;
            otherPages = true;
        }
        else if(title.containsIgnoreCase('NRICMatch'))
        {
            title = 'SIGN UP FOR A C&C ACCOUNT';
            otherPages = false;
            mobilePage = true;
        }  
        else if(title.contains('ChnagePasswordConfirmation'))
        {
            title = 'PASSWORD CHANGED';
            forgotPasswordPage = true;
        }
        else if(title.containsIgnoreCase('Confirm'))
        {
            title = 'RESET PASSWORD SENT';
            forgotPasswordPage = true;
            
        }
        else if(title.containsIgnoreCase('ForgotPassword'))
        {
            title = 'FORGOT PASSWORD';
            otherPages = true;
        }
        else if(title.contains('Change'))
        {
            title = 'CHANGE PASSWORD';
            otherPages = true;
        }
        else if(title.contains('OTP'))
        {
            title = 'VERIFY YOUR MOBILE NUMBER';
            otherPages = true;
        }
        else if(title.contains('CreateAccount'))
        {
            title = 'YOUR DETAILS';
            otherPages = true;
        }
        else if(title.containsIgnoreCase('request=resendAccountActivation'))
        {
            title = 'ACCOUNT ACTIVATE';
            otherPages = true;
        }
        else if(title.contains('Signup'))
        {
            title = 'SIGN UP';
            otherPages = true;
        }
        else if(title.contains('Account'))
        {
            title = 'ACCOUNT ACTIVATE';
            otherPages = true;
        }
        else if(title.contains('loginResendActivation'))
        {
            title = 'LOG IN';
            otherPages = true;
        }
        
    }  
   
}