@isTest(seeAllData=true)
public class Test_PriceAlert_ConfirmationEmailSend {
Public static testMethod void testSendEmail()
    {
        Test.startTest(); 
        PriceAlert_ConfirmationEmailSend.SendEmail('ContactName','test@xyz.com','subcriberKey','8585','CCK','ModelName');
     
        PriceAlert_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCK','ModelName');
        PriceAlert_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCI','ModelName');
        PriceAlert_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCF','ModelName');
        PriceAlert_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCA','ModelName');
        Test.stopTest();
    }
}