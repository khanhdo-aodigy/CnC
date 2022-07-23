@isTest
private class OCcontTest {
   private static testMethod void OCcont(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
       
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c='12345678';
        c1.MobilePhone='81111111';
        c1.OwnerID = u2.Id;
        insert c1;
        Opportunity op = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        op.Contact_Person__c = c1.Id;
        op.OwnerId = u2.Id;
        op.StageName = 'Open';
        op.Opportunity_Score__c =10;
        insert op; 
        
        Opportunity op1 = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        op1.OwnerId = u1.Id;
        insert op1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
            c.fName = 'xyzFirst';
            c.lName = 'XyZLast';
            c.CustMobile  = '81111111';
            c.searchCustPhone();
            c.CustEmail = 'testnewtest.com';
            c.isCall = true;
            c.isEmail = false;
            c.isFax = false;
            c.isSMS = false;
            c.opp = op;
            c.callLookup();
            c.goBack();
            c.doSave();
            c.doClear();
            c.doCancel();
            
            c.cont.MobilePhone = '';
            c.searchCustPhone();
            c.doSave();
            c.CustMobile = '81111111';
            c.searchCustPhone();
            c.CustMobile = '911111111';
            c.CustEmail = 'xyzmail@mail.com';
            c.CustlastName = 'test123';
            c.CustMobile = '81111111';
            c.opp = op;
            c.ModId = m.Id;
            c.ModName = m.Name;
            c.doSave();
            c.searchCustPhone();
            c.callLookup();
            c.goBack();
            c.doSave();
            c.doClear();
            
            c.cont.MobilePhone = '81111111';
            c.searchCustPhone();
            c.opp.Model_Interested_In__c = 'Rio;Carrens';
            c.CustEmail = 'xyzmail@mail.com';
            c.cont.LastName = 'XyZLast';
            c.doSave();
            
            
        }
    }
    private static testMethod void OCcont2(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        Lead ld = Test_DataFactory.createLead(false,'test','Rio');
        ld.OwnerId = u2.Id;
        ld.Email = 'test@test.com';
        insert ld;
        
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c='12345678';
        c1.MobilePhone='6581111122';
        c1.OwnerID = u2.Id;
        insert c1;
        
        
        Opportunity op1 = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        op1.lead__c = ld.Id;
        op1.OwnerId = u2.Id;
        op1.Opportunity_Score__c = 10;
        op1.StageName = 'Open';
        insert op1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
           
            c.CustEmail = 'test@test.com';
            c.CustLastName = 'test123';
            c.CustMobile = '81111111';
            c.isCall = false;
            c.isEmail = true;
            c.isFax = false;
            c.isSMS = false;
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            c.searchCustPhone();
            c.goBack();
            c.doSave();  
        }
    }
    
    private static testMethod void OCcont3(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c='12345678';
        c1.MobilePhone='6581111111';
        c1.OwnerID = u2.Id;
        c1.Account__c = acc.Id;

        insert c1;
        
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
           	
            c.isCall = false;
            c.isEmail = false;
            c.isFax = true;
            c.isSMS = false;
            c.CustEmail = 'test@test.com';
            c.CustLastName = 'test123';
            c.CustMobile = '81111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            c.searchCustPhone();
            c.goBack();
            c.doSave();
            
        }
        
    }
    private static testMethod void OCcont4(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c='12345678';
        c1.MobilePhone='81111111';
        c1.OwnerID = u2.Id;
        insert c1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
            
            c.isCall = false;
            c.isEmail = false;
            c.isFax = false;
            c.isSMS = true;
            c.CustEmail = 'test3241@test.com';
            c.CustLastName = 'test12355';
            c.CustMobile = '81111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            c.doSave();           
        }
        
    }
    
    
     private static testMethod void OCcont6(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCF',Franchise_Code__c='MITPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCF',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCF',Franchise_Code__c='MITPC');
        insert b;
        
        Account acc = Test_DataFactory.createAccount(true, 'accName');
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c='12345678';
        c1.MobilePhone='81111111';
        c1.OwnerID = u2.Id;
        c1.Account__c = acc.Id;
        insert c1;
         
         
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
           
            c.isCall = false;
            c.isEmail = false;
            c.isFax = false;
            c.isSMS = false;
            c.CustEmail = 'test@test.com';
            c.CustLastName = 'test123';
            c.CustMobile = '81111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            c.searchCustPhone();
            c.goBack();
            c.doSave();

        }
    }
     private static testMethod void OCcont7(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCF',Franchise_Code__c='MITPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCF',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCF',Franchise_Code__c='MITPC');
        insert b;
        Account acc = Test_DataFactory.createPerson(false, UserInfo.getLastName(), 'Customer');
        acc.PersonMobilePhone = '81111111';
        acc.PersonEmail = 'cust1@test.com';
        acc.OwnerId = u2.Id;
        insert acc;
         
         
        Opportunity op1 = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        op1.OwnerId = u2.Id;
        op1.Opportunity_Score__c = 10;
        op1.StageName = 'Open';
        op1.Account__c = acc.Id;
        insert op1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
            c.isCall = true;
            c.isEmail = true;
            c.isFax = false;
            c.isSMS = false;
            c.CustEmail = 'test@test.com';
            c.CustLastName = 'test123';
            c.CustMobile = '81111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            c.searchCustPhone();
            c.goBack();
            c.doSave();

        }
    }
    private static testMethod void OCcont8(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCF',Franchise_Code__c='MITPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCF',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCF',Franchise_Code__c='MITPC');
        insert b;
        Account acc = Test_DataFactory.createPerson(false, UserInfo.getLastName(), 'Customer');
        acc.PersonMobilePhone = '81111111';
        acc.PersonEmail = 'cust2@test.com';
        acc.OwnerId = u2.Id;
        insert acc;
         
        Opportunity op1 = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        op1.OwnerId = u2.Id;
        op1.Opportunity_Score__c = 10;
        op1.StageName = 'Open';
        op1.Account__c = acc.Id;
        insert op1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(u2) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
           
            c.isCall = true;
            c.isEmail = false;
            c.isFax = true;
            c.isSMS = false;
            c.CustEmail = 'test@test.com';
            c.CustLastName = 'test123';
            c.CustMobile = '81111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            c.searchCustPhone();
            c.goBack();
            c.doSave();

        }
    }
    
    @isTest
    private static void testOCcont_InputNull(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;

        Logo__c logoA = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert logoA;
        Logo__c logoB = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert logoB;
        
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        
        Opportunity opp = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        opp.OwnerId = runningUser.Id;
        opp.StageName = 'Open';
        opp.Opportunity_Score__c =10;
        insert opp; 
        
        System.RunAs(runningUser) {
            PageReference page2nd = Page.QuickContact;
            OCCont c = new OCCont();
            Test.setCurrentPage(page2nd);
           
            ApexPages.currentPage().getParameters().put('ModName', null);
            ApexPages.currentPage().getParameters().put('ModId', null);
            c.fName = '';
            c.lName = '';
            c.CustMobile  = '';
            c.searchCustPhone();
            c.CustEmail = '';
            c.opp = opp;
            c.callLookup();
            c.goBack();
            c.doSave();
            c.doClear();
            c.doCancel();
            c.searchCustPhone();
            c.goBack();
            c.doSave();
        }
    }

    @isTest
    private static void testSave_caseContactAndOppExist(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        
        Account personAcc = Test_DataFactory.createPerson(false, 'lastName', 'Customer');
        personAcc.Branch_Code__c = 'CCK';
        personAcc.PersonEmail = 'cust3@test.com';
        personAcc.Franchise_Code__c = 'KIAPC';
        insert personAcc;
            
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.FirstName = 'xyzFirst';
        personCon.LastName = 'XyZLast';
        personCon.Email = 'xyzmail@mail.com';
        personCon.NRIC_Passport_No__c='12345678';
        personCon.MobilePhone='6581111111';
        personCon.OwnerID = runningUser.Id;
        update personCon;
        
        Opportunity op1 = Test_DataFactory.createOpportunity(false,'testOpp', personAcc.Id);
        op1.OwnerId = runningUser.Id;
        op1.Opportunity_Score__c = 10;
        op1.StageName = 'Open';
        op1.Contact_Person__c = personCon.Id;
        insert op1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(runningUser) {
            PageReference pageRef = Page.QuickContact;
            OCCont occontControler = new OCCont();
            Test.setCurrentPage(pageRef);
            occontControler.isCall = true;
            occontControler.isEmail = false;
            occontControler.isFax = false;
            occontControler.isSMS = true;
            occontControler.CustEmail = 'test@test.com';
            occontControler.CustLastName = 'test123';
            occontControler.CustMobile = '81111111';
            occontControler.CustPhone = '6581111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            occontControler.searchCustPhone();
            occontControler.goBack();
            occontControler.doSave();
        }
    }

@isTest
    private static void testSave_caseNoOpenOppExist(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        
        Account personAcc = Test_DataFactory.createPerson(false, 'lastName', 'Customer');
        personAcc.PersonEmail = 'cust4@test.com';
        personAcc.Branch_Code__c = 'CCK';
        personAcc.Franchise_Code__c = 'KIAPC';
        insert personAcc;
            
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.FirstName = 'xyzFirst';
        personCon.LastName = 'XyZLast';
        personCon.Email = 'xyzmail@mail.com';
        personCon.NRIC_Passport_No__c='12345678';
        personCon.MobilePhone='6581111111';
        personCon.OwnerID = runningUser.Id;
        update personCon;
        
        Opportunity op1 = Test_DataFactory.createOpportunity(false,'testOpp', personAcc.Id);
        op1.OwnerId = runningUser.Id;
        op1.Opportunity_Score__c = 10;
        op1.StageName = 'Booked';
        op1.Contact_Person__c = personCon.Id;
        insert op1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(runningUser) {
            PageReference pageRef = Page.QuickContact;
            OCCont occontControler = new OCCont();
            Test.setCurrentPage(pageRef);
           
            occontControler.CustEmail = 'test@test.com';
            occontControler.CustLastName = 'test123';
            occontControler.CustMobile = '81111111';
            occontControler.CustPhone = '6581111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            occontControler.searchCustPhone();
            occontControler.goBack();
            occontControler.doSave();
        }
    }
    
    @isTest
    private static void testSave_NoExistingContactWithInputMobile_ExistLeadWithInputEmail_ExistOpportunity(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'xyzFirst';
        testCon.LastName = 'XyZLast';
        testCon.Email = 'xyzmail@mail.com';
        testCon.AccountId = acc.id;
        testCon.NRIC_Passport_No__c = '12345678';
        testCon.MobilePhone = '658122222';
        testCon.OwnerID = runningUser.Id;
        testCon.Account__c = acc.Id;
        insert testCon;
		
        
        
        Opportunity testOpp = Test_DataFactory.createOpportunity(false,'testOpp', acc.Id);
        testOpp.OwnerId = runningUser.Id;
        testOpp.Opportunity_Score__c = 10;
        testOpp.StageName = 'Open';
        testOpp.Contact_Person__c = testCon.Id;
        insert testOpp;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(runningUser) {
            PageReference pageRef = Page.QuickContact;
            OCCont occont = new OCCont();
            Test.setCurrentPage(pageRef);
           
            occont.CustEmail = 'test@test.com';
            occont.CustFirstName = 'Fake';
            occont.CustLastName = 'test123';
            occont.CustMobile = '81111111';
            occont.CustPhone = '6581111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);

            occont.callLookup();
            occont.goBack();
            occont.doSave();
        }
    }
    
    @isTest
    private static void testSave_NoExistingContactWithInputMobile_ExistLeadWithInputEmail_NoExistingOpportunity(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c = '12345678';
        c1.MobilePhone = '658122222';
        c1.OwnerID = runningUser.Id;
        c1.Account__c = acc.Id;
        insert c1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(runningUser) {
            PageReference pageRef = Page.QuickContact;
            OCCont occont = new OCCont();
            Test.setCurrentPage(pageRef);
           
            occont.CustEmail = 'test@test.com';
            occont.CustFirstName = 'Fake';
            occont.CustLastName = 'test123';
            occont.CustMobile = '81111111';
            occont.CustPhone = '6581111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);

            occont.callLookup();
            occont.goBack();
            occont.doSave();
        }
    }
    
    @isTest
    private static void testOCcont_NoExistingContactWithInputMobile_NoExistingLeadWithInputEmail(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Account acc = new Account(Branch_Code__c='CCK',Franchise_Code__c='KIAPC', Name='KIAPC');
        insert acc;
        
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c = '12345678';
        c1.MobilePhone = '658122222';
        c1.OwnerID = runningUser.Id;
        c1.Account__c = acc.Id;
        insert c1;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(runningUser) {
            PageReference pageRef = Page.QuickContact;
            OCCont occont = new OCCont();
            Test.setCurrentPage(pageRef);
           
            occont.CustEmail = 'test@test.com';
            occont.CustFirstName = 'Fake';
            occont.CustLastName = 'test123';
            occont.CustMobile = '81111111';
            occont.CustPhone = '6581111111';
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);

            occont.callLookup();
            occont.goBack();
            occont.doSave();
        }
    }
    
    @isTest
    private static void testSearchCustPhone_ExistingPersonAccWithInputMobile(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        User u1 = new User(Alias = 'ksa21', Branch_Code__c='CCA',Franchise_Code__c='MITPC',Email='demo21@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo21@andomdemodomain.com');
        insert u1;
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        
        
        String inputMobile = '111222333';
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'Prospect');
        personAcc.OwnerId = runningUser.Id;
        personAcc.PersonMobilePhone = '65' + inputMobile;
        insert personAcc;
        
        Model__c m  = Test_DataFactory.createmodelId(true,'test-Model1','CCK','KIAPC');
        System.RunAs(runningUser) {
            PageReference pageRef = Page.QuickContact;
            OCCont occont = new OCCont();
            Test.setCurrentPage(pageRef);
           
            occont.CustEmail = 'test@test.com';
            occont.CustLastName = 'test123';
            occont.CustMobile = inputMobile;
            occont.CustPhone = inputMobile;
            ApexPages.currentPage().getParameters().put('ModName', m.Name);
            ApexPages.currentPage().getParameters().put('ModId', m.Id);
            
            occont.searchCustPhone();
        }
    }
}