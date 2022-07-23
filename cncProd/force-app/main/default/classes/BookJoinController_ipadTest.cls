@isTest
private class BookJoinController_ipadTest {
    Static String testRun = 'dummyData';
    Static String branchCode     = 'CCK';
    Static String franchiseCode  = 'KIAPC';
    
    @isTest    
    private static void testSearchCustNric() {
        String mobilePhone = '91111111';
        String email = 'test@hotmail.com';
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='KIAPC Sales'];
            User testUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = profile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
            insert testUser;
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKE '%Profiling%'];
        	User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        	System.runAs(admin) {
            	PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = testUser.Id;
                psa.PermissionSetId = ps.Id;
                insert psa;
        	}           
            
            Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
            insert a;
            Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
            insert d;
            Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
            insert b;
            Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
            insert c;
            
            Trade_Plate__c tradePlate = new Trade_Plate__c();
            tradePlate.Active__c = true;
            tradePlate.Branch_Code__c = 'CCK';
            tradePlate.Franchise_Code__c = 'KIAPC';
            insert tradePlate;        
            
            Postal_Code__c postalCode = new Postal_Code__c();
            postalCode.Address_Line_1__c='test 1';
            postalCode.Address_Line_2__c='test 2';
            postalCode.Address_Line_3__c='test 3';
            postalCode.Country__c='test c';
            insert postalCode;
            postalCode.Name = postalCode.Id;
            update postalCode;
            
            Account personAcc = Test_DataFactory.createPA(true, 'Test', 'test@cust.com', 'Customer');
            personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
            
            Contact personCon = new Contact(Id = personAcc.PersonContactId);
            personCon.Birthdate = Date.today().addYears(-20);
            personCon.MobilePhone = '65' + mobilePhone;
            personCon.Postal_Code__c = postalCode.Id;
            personCon.Email = email;
            update personCon;
           
            Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
            Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
            Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
            testVh.Type__c = 'Test Drive';
            insert testVh;
            
            Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
            oppt.Branch_Code__c = 'CCA';
            oppt.Opportunity_Score__c = 40;
            insert oppt;
            
            Test_Drive__c testDrive = Test_DataFactory.createTestDrive(true, oppt.Id);
                
            Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');
    
            Showroom__c TestShow = Test_DataFactory.createShowroom(true);
        
        System.runAs(testUser){
            //Case Search type and Search value are bank
            PageReference pageRef = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', testDrive.Id);
            ApexPages.currentPage().getParameters().put('id', testVh.Id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.Id);
            
            BookJoinController_ipad controller = new BookJoinController_ipad();
            Test.setCurrentPage(pageRef);
            controller.searchCustNric();
            
            //Case Search type and Search value are NOT bank
            pageRef = Page.BookJoinQueuePage_ipad;            
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('testdrive_id', testDrive.Id);
            ApexPages.currentPage().getParameters().put('id', testVh.Id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.Id);                
            ApexPages.currentPage().getParameters().put('searchType', 'mobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', mobilePhone);
            controller = new BookJoinController_ipad();
            
            controller.searchCustNric();
        }        
    }
        
    @isTest    
    private static void testPostalChange() {
        String mobilePhone = '91111111';
        String email = 'test@hotmail.com';       
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='KIAPC Sales'];
        User testUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = profile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert testUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1]; 
        System.runAs(admin) {            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = testUser.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
        
        Trade_Plate__c tradePlate = new Trade_Plate__c();
        tradePlate.Active__c = true;
        tradePlate.Branch_Code__c = 'CCK';
        tradePlate.Franchise_Code__c = 'KIAPC';
        insert tradePlate;        
        
        Postal_Code__c postalCode = new Postal_Code__c();
        postalCode.Address_Line_1__c='test 1';
        postalCode.Address_Line_2__c='test 2';
        postalCode.Address_Line_3__c='test 3';
        postalCode.Country__c='test c';
        insert postalCode;
        postalCode.Name = postalCode.Id;
        update postalCode;
        
        Account personAcc = Test_DataFactory.createPA(true, 'Test', 'cust01@test.com', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.Birthdate = Date.today().addYears(-20);
        personCon.MobilePhone = '65' + mobilePhone;
        personCon.Postal_Code__c = postalCode.Id;
        personCon.Email = email;
        update personCon;
        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        testVh.Type__c = 'Test Drive';
        insert testVh;
        
        System.runAs(testUser){
            PageReference pageRef = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('id', testVh.Id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.Id);
            ApexPages.currentPage().getParameters().put('custPost', postalCode.Id);
            
            BookJoinController_ipad controller = new BookJoinController_ipad();
            Test.setCurrentPage(pageRef);
            controller.postalChange();
        }
            postalCode = [SELECT Id FROM Postal_Code__c WHERE Id = :postalCode.Id];
            delete postalCode;
        
        System.runAs(testUser) {
            //Case no existing Portal Code with requested custPost
            PageReference pageRef = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('id', testVh.Id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.Id);
            ApexPages.currentPage().getParameters().put('custPost', null);
            
            BookJoinController_ipad controller = new BookJoinController_ipad();
            Test.setCurrentPage(pageRef);
            controller.postalChange();
        }
    }
    
    @isTest    
    private static void testAll() {
        String mobilePhone = '91111111';
        String email = 'test@hotmail.com';
        String nric = 'YH001998';
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='KIAPC Sales'];
        User testUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = profile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert testUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        System.runAs(admin){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = testUser.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }        
        
        Trade_Plate__c tradePlate = new Trade_Plate__c();
        tradePlate.Active__c = true;
        tradePlate.Branch_Code__c = 'CCK';
        tradePlate.Franchise_Code__c = 'KIAPC';
        insert tradePlate;        
        
        Postal_Code__c postalCode = new Postal_Code__c();
        postalCode.Address_Line_1__c='test 1';
        postalCode.Address_Line_2__c='test 2';
        postalCode.Address_Line_3__c='test 3';
        postalCode.Country__c='test c';
        insert postalCode;
        postalCode.Name = postalCode.Id;
        update postalCode;
        
        Account personAcc = Test_DataFactory.createPA(true, 'Test', 'cust03@test.com', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.Birthdate = Date.today().addYears(-20);
        personCon.MobilePhone = '65' + mobilePhone;
        personCon.Postal_Code__c = postalCode.Id;
        personCon.NRIC_Passport_No__c = nric;
        personCon.Email = email;
        personCon.SMS__c = true;
        update personCon;
       
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        testVh.Type__c = 'Test Drive';
        testVh.Registration_No__c = '74L1009';
        insert testVh;
        
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 25;
        oppt.CloseDate = Date.today() + 15;
        oppt.OwnerId = testUser.Id;
        oppt.StageName = 'Open';
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, null);
        // testDrive.Status__c = 'Queue';
        testDrive.Date__c = Date.today();
        testDrive.Trade_Plate__c = tradePlate.Id;
        testDrive.Franchise_Code__c = 'KIAPC';
        testDrive.Branch_Code__c = 'CCK';
        testDrive.OwnerId = testUser.Id;
        testDrive.Model__c = testVh.Id;   
        //insert testDrive;
            
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');

        Showroom__c TestShow = Test_DataFactory.createShowroom(true);
        
        System.runAs(testUser){
            PageReference pageRef = Page.BookJoinQueuePage_ipad;            
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('testdrive_id', testDrive.Id);
            ApexPages.currentPage().getParameters().put('id', testVh.Id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.Id);                
            ApexPages.currentPage().getParameters().put('searchType', 'mobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', mobilePhone);
            ApexPages.currentPage().getParameters().put('custNric', nric);
            ApexPages.currentPage().getParameters().put('photoUrl1', 'http//google.com/98765456789');            
            ApexPages.currentPage().getParameters().put('photoUrl2', 'http//google.com/fghjkl');
            BookJoinController_ipad controller = new BookJoinController_ipad();
            controller.customerSearch = true;
            
            controller.getItems();
            controller.getContactLess();
            controller.getRecEmail();
            controller.getOps();
            controller.searchCustNric();
            controller.postalChange();
            controller.getIagree();
            controller.cancel();
            controller.oppSearch();
            controller.save();
            controller.afterSave();
        }       
    }
    
    public static testMethod void TriggerAttachPDFClass() {
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='KIAPC Sales'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        System.runAs(admin) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u2.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
        
        system.runAs(u2){
            Account acc = new Account();
            acc.name='XYZ Organization';
            insert acc;
            Contact c1 = new Contact();
            c1.FirstName = 'xyzFirst';
            c1.LastName = 'XyZLast';
            c1.Email = 'xyzmail@mail.com';
            c1.AccountId = acc.id;
            c1.NRIC_Passport_No__c='12345678';
            c1.MobilePhone='8234567';
            insert c1;
            Vehicle_Master__c v2=new Vehicle_Master__c(Name='Test v2',Comm_No__c='5678',Status__c='Available',Type__c='Test Drive');
            insert v2;
            Opportunity opp = new Opportunity(Name='Test_opp',CloseDate=date.today(),StageName='Open');
            insert opp;   
            Test_Drive__c td = new Test_Drive__c();
            td.Model__c=v2.id;
            td.Prospect__c=c1.id;
            td.Opportunity__c=opp.Id;   
            Date today=date.today();
            td.Date__c=today;
            td.Franchise_Code__c='KIAPC';
            td.receive_idemnity_form__c = 'Yes';
            td.contactless_test_drive__c = 'Yes';
            insert td;
        }
        //Test.StopTest();
    }
    public static testMethod void TestDriveNBookJoinTest() {
        //Test.StartTest();
        User testUser = Test_DataFactory.createUser(true,'KIAPC Sales', 'ksa2');
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1]; 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        System.runAs(admin) {            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = testUser.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
        Postal_Code__c pc1 = new Postal_Code__c();
        pc1.Name ='test123';
        pc1.Address_Line_1__c='test 1';
        pc1.Address_Line_2__c='test 2';
        pc1.Address_Line_3__c='test 3';
        pc1.Country__c='test c';
        insert pc1;
        pc1.Name = pc1.Id;
        update pc1;
        
        
        Postal_Code__c pc2 = new Postal_Code__c();
        pc2.Address_Line_1__c='test 1';
        pc2.Address_Line_2__c='test 2';
        pc2.Address_Line_3__c='test 3';
        pc2.Country__c='test c';
        insert pc2;
        pc2.Name = pc2.id;
        update pc2;
        
        Account person =  Test_DataFactory.createPA(true,'testing', 'cust04@test.com', 'Customer');
        
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Contact con =  Test_DataFactory.createContact(false,testRun,testRun,acct.Id);
        con.MobilePhone = '6591111111';
        con.Postal_Code__c = pc1.id;
        con.Birthdate = System.today() -1;
        con.PDPA__c = 'SMS';
        con.SMS__c = false;
        con.Fax__c = false;
        con.Call__c = false;
        con.Email__c = false;
        insert con;
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCK','KIAPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCK'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        Trade_Plate__c testTradePl = new Trade_Plate__c(Name='testTradePlate' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Active__c=true);
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(true,'test','CCK','KIAPC','Res-12345',con.id);
        //rv.Model_Year__c
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 40;
        oppt.Contact_Person__c =  con.id;
        insert oppt;
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Showroom__c TestShow = Test_DataFactory.createShowroom(true); 
        System.runAs(testUser)
        {
            PageReference page2nd = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', 'null');
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            ApexPages.currentPage().getParameters().put('contactId', con.id);
                    
            BookJoinController_ipad test1 = new BookJoinController_ipad();
            Test.setCurrentPage(page2nd);        
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', '91111111');
            
            ApexPages.currentPage().getParameters().put('photoUrl1', 'http//google.com/98765456789');            
            ApexPages.currentPage().getParameters().put('photoUrl2', 'http//google.com/fghjkl');
    
            test1.custNric='12345678';
            test1.custPhone='91111111';
            test1.searchCustNric();
            test1.getItems();
            test1.getRecEmail();
            test1.vehicle.Registration_No__c = rv.id;
            test1.setRecEmail('Yes');
            test1.getOps();
            test1.getIagree();
            test1.setIagree('Yes');
            test1.postalChange();
            test1.oppSearch();
            test1.save();
            
            PageReference page1st = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', 'null');
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            ApexPages.currentPage().getParameters().put('personAccountId', person.id); 
            
            BookJoinController_ipad test2 = new BookJoinController_ipad();
            Test.setCurrentPage(page1st);        
            ApexPages.currentPage().getParameters().put('searchType', 'Email');
            ApexPages.currentPage().getParameters().put('typeVal', 'test@test.com');
            
            test2.custNric='12345678';
            test2.custPhone='91111111';
            test2.contactId= con.Id;
            test2.searchCustNric();
            test2.getItems();
            test2.getRecEmail();
            test2.setRecEmail('Yes');
            test2.getOps();
            test2.getIagree();
            test2.setIagree('Yes');
            test2.postalChange();
            test2.oppSearch();
            test2.save();
            test2.cancel();
            test2.afterSave();
        }
    }
        
    @isTest    
    private static void testBookJoinControllerIpad() {
        String mobilePhone = '91111111';

        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
                 
            Trade_Plate__c tradePlate = new Trade_Plate__c(Name='testTradePlate' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Active__c=true);
            insert tradePlate;
        
        User testUser = Test_DataFactory.createUser(true,'KIAPC Sales', 'ksa2');
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1]; 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        System.runAs(admin) {            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = testUser.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }

        Postal_Code__c postalCode = new Postal_Code__c();
        postalCode.Address_Line_1__c='test 1';
        postalCode.Address_Line_2__c='test 2';
        postalCode.Address_Line_3__c='test 3';
        postalCode.Country__c='test c';
        insert postalCode;
        
        Account personAcc = Test_DataFactory.createPA(true, 'Test', 'cust05@test.com', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.Birthdate = Date.today().addYears(-20);
        personCon.MobilePhone = '65' + mobilePhone;
        personCon.Postal_Code__c = postalCode.Id;
        update personCon;
        
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        insert oppt;
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(true, oppt.Id);
            
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Showroom__c TestShow = Test_DataFactory.createShowroom(true); 
        System.runAs(testUser){
            PageReference page2nd = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', testDrive.Id);
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.id); 
            
            BookJoinController_ipad controller1 = new BookJoinController_ipad();
            Test.setCurrentPage(page2nd);        
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', mobilePhone);
            controller1.save();
            
            PageReference page1st = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', 'null');
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            ApexPages.currentPage().getParameters().put('selectedTouchPoints', 'Email Offline,Facebook,Youtube');
            
            BookJoinController_ipad controller2 = new BookJoinController_ipad();
            Test.setCurrentPage(page1st);        
            ApexPages.currentPage().getParameters().put('searchType', 'Email');
            ApexPages.currentPage().getParameters().put('typeVal', 'noemail@noemail.com');            
            
            controller2.custNric='12345678';
            controller2.custPhone='91111111';
            controller2.customer.Lastname='';
            controller2.searchCustNric();
            controller2.postalChange();
            controller2.getContactLess();
            controller2.setContactLess('Yes');
            controller2.save();
            controller2.afterSave();
            
            
            PageReference page3st = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', 'null');
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            
            BookJoinController_ipad test2N = new BookJoinController_ipad();
            Test.setCurrentPage(page3st);        
            ApexPages.currentPage().getParameters().put('searchType', 'Email');
            ApexPages.currentPage().getParameters().put('typeVal', 'noemail@noemail.com');
            
            test2N.custNric='';
            test2N.custPhone='';
            //test2N.customer.Lastname='';
            test2N.save();
            
            PageReference page4th = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', 'null'); 
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            BookJoinController_ipad test4N = new BookJoinController_ipad();
            Test.setCurrentPage(page4th);
            test4N.custNric='12345678';
            test4N.custPhone='91112351';
            test4N.tpSelected=tradePlate.Id;
            test4N.customer.Birthdate=date.today();
            test4N.customer.Lastname='testingLead';
            test4N.custEmail='t@gmail.com';
            test4N.save(); 
        }
    }
    
    
    @isTest    
    private static void testBookJoinControllerIpad1() {
        String mobilePhone = '91111111';
        String branchCode = 'CCK';
        String franchise = 'KIAPC';
		
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
        
        Trade_Plate__c tradePlate = new Trade_Plate__c();
        tradePlate.Name='testTradePlate';
        tradePlate.Active__c = true;
        tradePlate.Branch_Code__c = branchCode;
        tradePlate.Franchise_Code__c = franchise;
        insert tradePlate;   
        
        User salesRep = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        salesRep.Branch_Code__c = branchCode;
        salesRep.Franchise_Code__c = franchise;
        insert salesRep;
        
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1]; 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        System.runAs(admin) {            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = salesRep.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }

        
        Postal_Code__c postalCode = new Postal_Code__c();
        postalCode.Address_Line_1__c='test 1';
        postalCode.Address_Line_2__c='test 2';
        postalCode.Address_Line_3__c='test 3';
        postalCode.Country__c='test c';
        insert postalCode;
        postalCode.Name = postalCode.Id;
        update postalCode;
        
        Account personAcc = Test_DataFactory.createPA(true, 'Test', 'cust@test.com', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.Birthdate = Date.today().addYears(-20);
        personCon.MobilePhone = '65' + mobilePhone;
        personCon.Postal_Code__c = postalCode.Id;
        personCon.NRIC_Passport_No__c = 'NCV357G';
        personCon.Email = 'test@domain.com';
        update personCon;
        
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        testVh.Registration_No__c = '74L1dfghg';
        testVh.Type__c = 'Test Drive';
        insert testVh;
        
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = branchCode;
        oppt.Opportunity_Score__c = 40;
        oppt.StageName = 'Open';
        oppt.Contact_Person__c = personCon.Id;
        oppt.CloseDate = Date.today().addMonths(3);
        insert oppt;
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(true, oppt.Id);

        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');
        
        Showroom__c TestShow = Test_DataFactory.createShowroom(true); 
        System.runAs(salesRep){
            PageReference pageRef = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', testDrive.Id);
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.id); 
            ApexPages.currentPage().getParameters().put('tpSelected', tradePlate.Id);
            ApexPages.currentPage().getParameters().put('Iagree', 'Yes');
            ApexPages.currentPage().getParameters().put('selectedTouchPoints', 'Email Offline,Facebook,Youtube');
            
            BookJoinController_ipad controller = new BookJoinController_ipad();
            Test.setCurrentPage(pageRef);        
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', mobilePhone);
            
            controller.searchCustNric();
            controller.postalChange();
            
            controller.customerSearch = true;
            controller.save(); //To call oppSearch
            controller.afterSave();
        }
    }

    @isTest    
    private static void testBookJoinControllerIpad2() {
        String mobilePhone = '91111111';
        String branchCode = 'CCK';
        String franchise = 'KIAPC';
		
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
        
        Trade_Plate__c tradePlate = new Trade_Plate__c();
        tradePlate.Name='testTradePlate';
        tradePlate.Active__c = true;
        tradePlate.Branch_Code__c = branchCode;
        tradePlate.Franchise_Code__c = franchise;
        insert tradePlate;   
        
        User salesRep = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        salesRep.Branch_Code__c = branchCode;
        salesRep.Franchise_Code__c = franchise;
        insert salesRep;
        
        User admin = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1]; 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKe '%Profiling%'];
        System.runAs(admin) {            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = salesRep.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }

        
        Postal_Code__c postalCode = new Postal_Code__c();
        postalCode.Address_Line_1__c='test 1';
        postalCode.Address_Line_2__c='test 2';
        postalCode.Address_Line_3__c='test 3';
        postalCode.Country__c='test c';
        insert postalCode;
        postalCode.Name = postalCode.Id;
        update postalCode;
        
        Account personAcc = Test_DataFactory.createPA(true, 'Test', 'cust@test.com', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.Birthdate = Date.today().addYears(-20);
        personCon.MobilePhone = '65' + mobilePhone;
        personCon.Postal_Code__c = postalCode.Id;
        personCon.NRIC_Passport_No__c = 'NCV357G';
        personCon.Email = 'test@domain.com';
        update personCon;
        
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        testVh.Registration_No__c = '74L1dfghg';
        testVh.Type__c = 'Test Drive';
        insert testVh;
        
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = branchCode;
        oppt.Opportunity_Score__c = 40;
        oppt.StageName = 'Open';
        oppt.Contact_Person__c = personCon.Id;
        oppt.CloseDate = Date.today().addMonths(3);
        insert oppt;
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, oppt.Id);
        testDrive.Account__c = personAcc.Id;
        insert testDrive;
        Test_Drive__c testDrive2 = Test_DataFactory.createTestDrive(false, oppt.Id);
        testDrive2.Account__c = personAcc.Id;
        testDrive2.Send_Survey_SMS__c = true;
        insert testDrive2;

        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');
        
        Showroom__c TestShow = Test_DataFactory.createShowroom(true); 
        System.runAs(salesRep){
            PageReference pageRef = Page.BookJoinQueuePage_ipad;
            ApexPages.currentPage().getParameters().put('testdrive_id', testDrive.Id);
            ApexPages.currentPage().getParameters().put('id', testVh.id);
            ApexPages.currentPage().getParameters().put('contactId', personCon.id); 
            ApexPages.currentPage().getParameters().put('tpSelected', tradePlate.Id);
            ApexPages.currentPage().getParameters().put('Iagree', 'Yes');
            ApexPages.currentPage().getParameters().put('selectedTouchPoints', 'Email Offline,Facebook,Youtube');
            
            BookJoinController_ipad controller = new BookJoinController_ipad();
            Test.setCurrentPage(pageRef);        
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', mobilePhone);
            
            controller.searchCustNric();
            controller.postalChange();
            
            controller.customerSearch = true;
            controller.save(); //To call oppSearch
            controller.afterSave();
        }
    }

}