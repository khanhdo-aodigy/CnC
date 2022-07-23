@isTest(SeeAllData=true)
public class Test_send_Push_SMS_CustomKeys {
    public static testmethod void Test_sendPUSHSMS() 
    {      
        Test.startTest();
        send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('ContactKey','mobilenumber','SubscriberToken','Keyword','Type_val','Id_val','PUSH_txt','SMS_txt','End_Date', '', '', '');
        Test.stopTest();
        httpResponse resTest;
        send_Push_SMS_CustomKeys.res = resTest;
        send_Push_SMS_CustomKeys.resBody = '';
        send_Push_SMS_CustomKeys.endpoint = '';
    }
    
    public static testmethod void Test_sendHttpPUSHSMS() 
    {      
        Test.startTest();
        send_Push_SMS_CustomKeys.SendHttpSMSPUSH('ContactKey','mobilenumber','SubscriberToken','Keyword','Type_val','Id_val','PUSH_txt','SMS_txt','SMS_link','tokenValue','End_Date', '', '', '');
        send_Push_SMS_CustomKeys.GetPromoLink('');
		Test.stopTest(); 
    }
}