@isTest
public class TestDriveController_ipad_Test {
    
    @isTest
    public static void testTestDriveController_ipad() {
        Test.StartTest();
        
        String testRun = 'dummyData';
        String branchCode     = 'CCK';
        String franchiseCode  = 'KIAPC';
        
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
        pc1.Name = pc1.id;
        update pc1;
        
        Postal_Code__c pc2 = new Postal_Code__c();
        pc2.Address_Line_1__c='test 1';
        pc2.Address_Line_2__c='test 2';
        pc2.Address_Line_3__c='test 3';
        pc2.Country__c='test c';
        insert pc2;
        pc2.Name = pc2.id;
        update pc2;
        
        Account acc = Test_DataFactory.createAccount(true,testRun);
        Account acct = Test_DataFactory.createPA(true,testRun, testRun+'@test.com','Customer');
        
        Contact con =  Test_DataFactory.createContact(false,testRun,testRun,acc.Id);
        con.MobilePhone = '6591111111';
        con.Postal_Code__c = pc1.id;
        con.Birthdate = System.today() -1;
        con.PDPA__c = 'SMS';
        insert con;
        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCK','KIAPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCK'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        testVh.Status__c = 'Available';
        testVh.Type__c = 'Test Drive';
        testVh.Branch_Code__c = branchCode;
        testVh.Franchise_Code__c = franchiseCode;
        insert testVh;
        
        Trade_Plate__c testTradePl = new Trade_Plate__c(Name='testTradePlate' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Active__c=true);
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(true,'test','CCK','KIAPC','Res-12345',con.id);
                
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Opp for ' + UserInfo.getLastName(), acct.Id);
        opp.Opportunity_Score__c = 10;
        insert opp;
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.status__c = 'Pending';
        td.Check_In__c = Datetime.now();
        td.Branch_Code__c = branchCode;
        td.Franchise_Code__c = franchiseCode;
        insert td;
  
        acct= [Select PersonContactId From Account Where Id = :acct.Id];
        
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
            ContactId = acct.PersonContactId,
            Branch_Code__c = branchCode,
            Franchise_Code__c = franchiseCode
            //ContactId__c = con.Id
        );
        insert u;
        System.runAs(u){
            ApexPages.currentPage().getParameters().put('contactId', con.id);
            ApexPages.currentPage().getParameters().put('testdrive_id', td.Id);
            ApexPages.currentPage().getParameters().put('accountId', acct.id); 
            
            TestDriveController_ipad test1= new TestDriveController_ipad();
            test1.testId = td.Id;
            test1.bookClick();
            test1.inClick();
            test1.outClick();
        }

        Test.stopTest();
        
    }
}