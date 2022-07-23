@isTest
private class CampaignMember_Promo_Push_SMS_Test {

    @isTest
    private static void testOnInsert() {
        Account acc = Test_DataFactory.createAccount(true, 'Bob');
        Contact con = Test_DataFactory.createContact(true, 'Bob', 'Lee', acc.Id);
        
        Campaign camp = Test_DataFactory.createCamp(false, 'Paid Event', 'type', 'CCK');
        camp.Promo_PUSH_Text__c = 'Hi there';
        camp.Promo_SMS_Text__c = 'Hello';
        camp.EndDate = Date.today().addDays(30);
        insert camp;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = camp.Id;
        cm.ContactId = con.Id;
        insert cm;
        
        cm.SMS_Status__c = 'Sent';
        update cm;
    }
    
}