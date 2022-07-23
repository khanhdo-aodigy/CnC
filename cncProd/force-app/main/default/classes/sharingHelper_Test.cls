@isTest
public class sharingHelper_Test {
    @isTest
    public static void test(){
        Test.startTest();
        
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAccount444');
        Account acc = Test_DataFactory.createPerson(true, 'PA', 'Prospect');
     
        Contact con = Test_DataFactory.createContact(false, 'FNPA',  'LNPA', jccAcct.Id);
        con.Account__c = acc.Id;
        insert con;
        
        Lead lead = Test_DataFactory.createLead(false, 'company',' lName');
        lead.Account__c = acc.Id;
        insert lead;
        
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'Opp for ' + UserInfo.getLastName(), jccAcct.Id);

        acc = [Select PersonContactId From Account Where Id = :acc.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'test@user.com',
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId
            //ContactId__c = con.Id
            );
        insert u;
        
        List<sharingHelper.generateShare> lstGenerateShare = new List<sharingHelper.generateShare>();
        lstGenerateShare.add(new sharingHelper.generateShare('Read', 'Contact', con.id, u.Id));
        lstGenerateShare.add(new sharingHelper.generateShare('Read', 'Account', jccAcct.Id, u.Id));
        lstGenerateShare.add(new sharingHelper.generateShare('Read', 'Lead', lead.id, u.Id));
        lstGenerateShare.add(new sharingHelper.generateShare('Read', 'Opportunity', opp.Id, u.Id));

        sharingHelper.creatShare(lstGenerateShare);
        Test.stopTest();
    }
}