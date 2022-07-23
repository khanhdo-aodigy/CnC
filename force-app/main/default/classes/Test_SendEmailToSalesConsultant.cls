@isTest(seeAllData=true)
public class Test_SendEmailToSalesConsultant {
Public static testMethod void testSendEmail()
    {
        Test.startTest();
        Model__c TestMod =  new Model__c(Name='TestMod',Branch_Code__c='CCK',Franchise_Code__c='KIAPC',DWH_Model_ID__c='abc12345');
        insert TestMod;        
        Variant__c TestVar =  new Variant__c(Name='TestVar',Branch__c='CCK',Franchise__c='KIAPC',Model_ID__c=TestMod.Id);
        insert TestVar;
        Showroom__c TestShow =  new Showroom__c(Name='TestShow',Address_Line_1__c='Address',City__c='SG',Country__c='SG');
        insert TestShow;
        User Testuser =  new User(Username='test_old@abc.com',LastName='test', Email='test_old@abc.com', Alias='testrun', TimeZoneSidKey='America/Denver', LocaleSidKey='en_GB', 
                                  EmailEncodingKey='UTF-8', ProfileId='00e28000000s2hr', LanguageLocaleKey='en_US');
        insert Testuser;
        
        SendEmailToSalesConsultant.sendEmail(Testuser.Id,TestMod.ID,TestVar.Id,TestShow.Id,'Bookdate');        
        
        Test.stopTest();
    }
}