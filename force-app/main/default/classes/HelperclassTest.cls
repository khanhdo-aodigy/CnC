@isTest
private class HelperclassTest {
    @isTest
    private static void testSendSMSMarketing_happyPath() {
        test.startTest();
        Account personAcc = Test_DataFactory.createPerson(true, 'Test PA', 'Customer');
		personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Campaign cp = new Campaign(name='testCampaign', Campaign_Code_Key__c='101',IsActive = true, Marketing_Message__c='test test');
        cp.EndDate = Date.today().addDays(10);
        insert cp;
        CampaignMember cm = new CampaignMember();
        cm.CampaignId=cp.id;
        cm.SMS_Status__c='New';
        cm.ContactId = personAcc.PersonContactId;
        insert cm;
        helperClass.sendSMSMarketing(cp.id);
        test.stopTest();  
    }
    
    @isTest
    private static void testSendSMSMarketing_CampaignNotActive() {
        test.startTest();
        Account personAcc = Test_DataFactory.createPerson(true, 'Test PA', 'Customer');
		personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Campaign cp = new Campaign(name='testCampaign', Campaign_Code_Key__c='101',Marketing_Message__c='test test');
        cp.EndDate = Date.today().addDays(10);        
        cp.IsActive = false;
        insert cp;
        CampaignMember cm = new CampaignMember();
        cm.CampaignId=cp.id;
        cm.SMS_Status__c='New';
        cm.ContactId = personAcc.PersonContactId;
        insert cm;
        helperClass.sendSMSMarketing(cp.id);
        test.stopTest();  
    }
    
    static testMethod void testhelperclassNegative() {
        test.startTest(); 
        Account acc = new Account( Name='test');
        insert acc;
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.MobilePhone='81111111';
        c1.Device__c = '1234ASDF';
        insert c1;
        Campaign cp = new Campaign(name='testCampaign', Campaign_Code_Key__c='101',IsActive = true, Marketing_Message__c='test test');
        cp.EndDate = Date.today().addDays(10);
        insert cp;
        CampaignMember cm = new CampaignMember();
        cm.CampaignId=cp.id;
        cm.SMS_Status__c='';
        cm.ContactId=c1.id;
        insert cm;
        helperClass.sendSMSMarketing(cp.id);
        test.stopTest();  
    }
}