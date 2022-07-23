@isTest
private class CampaignSMSGetWayTest {
    static testMethod void testCampaignSMSgetWay() {
        test.startTest(); 
        Account acc = Test_DataFactory.createPerson(true, 'TEstPA', 'Customer');
        acc = [Select Id, PersonContactId From Account Where Name = 'TEstPA' LIMIT 1];

        Contact c1 = [Select Id, Email, MobilePhone From Contact Where Id =: acc.PersonContactId Limit 1];
        c1.Email = 'xyzmail@mail.com';
        //c1.Account__c = acc.Id;
        c1.MobilePhone='81111111';
        update c1;
        
        date today = date.today();
        date nextDay = today.addDays(10);
        Campaign cp = new Campaign(name='testCampaign', Campaign_Code_Key__c='101', IsActive = true, startDate=today, endDate=nextDay);
        insert cp;
        CampaignMember cm = new CampaignMember();
        cm.CampaignId=cp.id;
        cm.ContactId=c1.Id;
        insert cm;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addParameter('Mobile', '81111111');
        req.addParameter('Type', 'new');
        req.addParameter('Message', '101 test');
        req.addParameter('Timestamp', '1390296387');
        req.addParameter('ServiceNum', '11111');
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        CampaignSMSGetWay.getPost();
        test.stopTest();
    }
}