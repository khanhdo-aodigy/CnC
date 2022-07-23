@isTest(SeeAllData=true)
public class Test_send_APP_Confirmation_SMS 
{
	public static testmethod void Test_sendSMS() 
    {      
        Test.startTest();
        send_APP_Confirmation_SMS.SENDAPPSMS('SMS_Body','mobileNumber','SubscriberKey','Keyword');
    	Test.stopTest();
        httpResponse resTest;
        send_APP_Confirmation_SMS.res = resTest;
        send_APP_Confirmation_SMS.resBody = '';
        send_APP_Confirmation_SMS.endpoint = '';
    }
    
    public static testmethod void Test_sendHttpSMS() 
    {      
        Test.startTest();
        send_APP_Confirmation_SMS.SendHttpSMS('SMS_Body','mobileNumber','SubscriberKey','Keyword','Token');
    	Test.stopTest();
    }
}