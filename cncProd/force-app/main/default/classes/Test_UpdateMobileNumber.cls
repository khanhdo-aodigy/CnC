@isTest(seeAllData=true)
public class Test_UpdateMobileNumber {
Public static testMethod void testSendEmail()
    {
        Test.startTest(); 
        UpdateMobileNumber.sendEmail('name','phoneNumber','email@xyz.com');
     	Test.stopTest();
    }
}