@isTest(SeeAllData=true)
public class testSend_OTP_SMS {	
    public static testmethod void Test_OTPSMS() 
    {      
        Test.startTest();
        String SMS_Body = 'Your verification code is 123456';
        String mobileNumber = '6588776655';
        Send_OTP_SMS.SENDSMS(SMS_Body,'mobileNumber', 'mobileNumber', 'NzM6Nzg6MA');
		Send_OTP_SMS.resBody1 = '';
        Test.stopTest();
        httpResponse resTest;
        Send_OTP_SMS.res = resTest;
        Send_OTP_SMS.resBody = '';
        Send_OTP_SMS.endpoint = '';
    }

}