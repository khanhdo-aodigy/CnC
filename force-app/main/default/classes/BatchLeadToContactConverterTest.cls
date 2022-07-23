@isTest
public class BatchLeadToContactConverterTest {

    static testMethod void Test_OppWithContact()
    {
        Test.startTest();
        Lead TestLead =  new Lead(LastName='TestRunLtoC',NRIC__c='s90890y',Company='esgawegfawegast');
        insert TestLead;
        Account Acc = new Account(Name = 'test');
        Insert Acc;
        Contact TestCon =  new Contact(LastName='TestLeadToConRun',NRIC_Passport_No__c='TEST12345',accountid=acc.id);
        insert TestCon;
        Account person = Test_DataFactory.createPerson(true, 'name', 'Prospect');
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c v1 = Test_DataFactory.createVariant(true,'TestVariant',md1.id,'CCK');
        Registered_Vehicle__c rg = Test_DataFactory.createregVehicle(false,'Test','CCK','KIAPC','Test12',TestCon.Id);
        rg.Account__c = person.Id;
        rg.variant__c = v1.id;
        rg.Chasis_Number__c ='1234567';
        insert rg;
        Opportunity opp = Test_DataFactory.createOpportunity(false,'Test',acc.id);
        opp.Contact_Person__c = TestCon.id;
        opp.Account__c = person.Id;
        Insert opp;
        Opportunity opp2 = Test_DataFactory.createOpportunity(false,'Test2',acc.id);
        opp2.lead__c = TestLead.id;
        opp2.Account__c = person.Id;
        insert opp2;
        Event_Registration__c er = new Event_Registration__c(name='test', LeadId__c = TestLead.id);
        insert er;
        Custom_Quote__c cq = new Custom_Quote__c(name='Test',Lead__c = TestLead.id);
        insert cq;
        Test_Drive__c td = new Test_Drive__c( Lead__c = TestLead.id,Opportunity__c = opp2.id,Account__c = person.Id);
        insert td;
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCK','KIAPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Master__c mm = Test_DataFactory.createModelCode(false,'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'KIAPC';
        insert mm;
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id);
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.id,cm.id,tm.id,mym.id, 'originalCommacase', 'systemCommcase');
        vm.Chassis__c='1234567';
        vm.ProductionMonth__c= Date.today().addDays(5);
        insert vm;
        Stock_Reservation__c str = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        str.Opportunity__c = opp.Id;
        str.Agreement_No__c = '12345';
        str.Reservation_Status__c = 'Print';
        str.Vehicle_Master__c=vm.id;
        Insert str;
        update str;
        System.debug('@@@ Stock_Reservation__c'+str.Vehicle_Chassis_Number__c+'------'+str);
        Models_Interested__c mi = Test_DataFactory.createmodelsInterested(true,md1.Id,opp.Id,'Open','Test Drive (Web)');

        Database.executeBatch(new BatchLeadToContactConverter());
        Test.stopTest();
    }

    static testMethod void Test_OppWithLead()
    {
        Test.startTest();
        Account person = Test_DataFactory.createPerson(true, 'name1', 'Prospect');
        Lead TestLead =  new Lead(LastName='TestRunLtoC',NRIC__c='s90890y',Company='esgawegfawegast');
        TestLead.Account__c = person.Id;
        insert TestLead;
        Account acc = Test_DataFactory.createAccount(true,'ComplexTest');
        global_var__c JCC_GlobalVar = new global_var__c(JCC_Accound_ID__c=acc.Id);
        upsert JCC_GlobalVar;

        Contact TestCon = Test_DataFactory.createContact(True,'fytdytdr','cycycrt',acc.Id);
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c v1 = Test_DataFactory.createVariant(true,'TestVariant',md1.id,'CCK');
        Registered_Vehicle__c rg = Test_DataFactory.createregVehicle(true,'Test','CCK','KIAPC','Test12',TestCon.Id);
        rg.variant__c = v1.id;
        rg.Account__c = person.Id;
        rg.Chasis_Number__c ='1234567';
        update rg;
        
        Opportunity opp = Test_DataFactory.createOpportunity(false,'Test',Acc.id);
        opp.Account__c = person.Id;
        opp.Lead__c = TestLead.Id;
        //opp.Contact_Person__c = TestCon.id;
        Insert opp;
        Test_Drive__c td = new Test_Drive__c( Lead__c = TestLead.id,Opportunity__c = opp.id,Account__c = person.Id);
        insert td;
        
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCK','KIAPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Master__c mm = Test_DataFactory.createModelCode(false,'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'KIAPC';
        insert mm;
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id);
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.id,cm.id,tm.id,mym.id, 'originalCommacase', 'systemCommcase');
        vm.Chassis__c='1234567';
        vm.ProductionMonth__c= Date.today().addDays(5);
        insert vm;
        Stock_Reservation__c str = Test_DataFactory.StockReservation(false,mm.Id,cm.Id,tm.Id,mym.Id);
        str.Opportunity__c = opp.Id;
        str.Agreement_No__c = '12345';
        str.Reservation_Status__c = 'Print';
        str.Vehicle_Master__c=vm.id;
        Insert str;
        update str;
        System.debug('@@@ Stock_Reservation__c'+str.Vehicle_Chassis_Number__c+'------'+str);
        Models_Interested__c mi = Test_DataFactory.createmodelsInterested(true,md1.Id,opp.Id,'Open','Test Drive (Web)');

        Database.executeBatch(new BatchLeadToContactConverter());
        Test.stopTest();
    }
    static testMethod void Test_shareDelBatch()
    {
        String otherOwner = [SELECT Id
                             FROM User
                             WHERE isActive=true
                             AND Profile.Name='System Administrator'
                             ORDER BY CreatedDate DESC
                             LIMIT 1].Id;
        Lead TestLead =  new Lead(LastName='TestRunLtoC',NRIC__c='s90890y',Company='esgawegfawegast');
        Test.startTest();
        insert TestLead;
        list<sharingHelper.generateShare> lstToCreateShare = new list<sharingHelper.generateShare>();
        lstToCreateShare.add(new sharingHelper.generateShare('Edit', 'Lead', TestLead.id,otherOwner ));
        sharingHelper.creatShare(lstToCreateShare);
        Account acc = Test_DataFactory.createAccount(true,'ComplexTest');
        global_var__c JCC_GlobalVar = new global_var__c(JCC_Accound_ID__c=acc.Id);
        upsert JCC_GlobalVar;
        Contact TestCon = Test_DataFactory.createContact(True,'fytdytdr','cycycrt',acc.Id);
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(TestLead.Id);
        lc.ConvertedStatus = 'Qualified';
        lc.setContactId(TestCon.id);
        lc.setAccountId(acc.id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Database.ExecuteBatch(new BatchDeleteLeadShareRecord());
        Test.stopTest();
    }

    static testmethod void Test_BatchUpdConvertedLeads(){
        String otherOwner = [SELECT Id
                             FROM User
                             WHERE isActive=true
                             AND Profile.Name='System Administrator'
                             ORDER BY CreatedDate DESC
                             LIMIT 1].Id;
        Lead TestLead =  new Lead(LastName='TestRunLtoC',NRIC__c='s90890y',Company='esgawegfawegast');
        Test.startTest();
        insert TestLead;
        Account person = Test_DataFactory.createPerson(true, 'Name3', 'Prospect');
        Account acc = Test_DataFactory.createAccount(true,'ComplexTest');
        Opportunity opp = Test_DataFactory.createOpportunity(false,'Test',Acc.id);
        opp.Lead__c = TestLead.Id;
        opp.Account__c = person.Id;
        insert opp;
        global_var__c JCC_GlobalVar = new global_var__c(JCC_Accound_ID__c=acc.Id);
        upsert JCC_GlobalVar;
        Contact TestCon = Test_DataFactory.createContact(True,'fytdytdr','cycycrt',acc.Id);
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(TestLead.Id);
        lc.ConvertedStatus = 'Qualified';
        lc.setContactId(TestCon.id);
        lc.setAccountId(acc.id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Database.ExecuteBatch(new BatchUpdConvertedLeads());
        Test.stopTest();
    }
}