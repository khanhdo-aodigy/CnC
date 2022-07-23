@isTest(seeAllData=true)
public class Test_SendFeedBackEmail {
Public static testMethod void testSendEmail()
    {
        Test.startTest(); 
        SendFeedBackEmail.SendEmail('name','phoneNumber','category','message','regNumber','lastVisitedCenter','triggeredSendMessageId','emailaddr');
     
        SendFeedBackEmail.SendHttpEmail('name','phoneNumber','category','message','regNumber','lastVisitedCenter','tokenValue','triggeredSendMessageId','abc@xyz.com');
        Test.stopTest();
    }
}