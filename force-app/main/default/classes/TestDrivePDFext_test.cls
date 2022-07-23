@isTest
private class TestDrivePDFext_test {
    Static String testRun = 'dummyData1';
    Static Account acc = Test_DataFactory.createAccount(true,testRun);   
    
    @isTest
    private static void TestDrivePDFext() {
        Test.StartTest();
        Date today=date.today();

        User u2 = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        u2.Branch_Code__c='CCK';
		u2.Franchise_Code__c='KIAPC';        
        insert u2;
        
        List<Logo__c> logolst =new List<Logo__c>();
        logolst.Add(new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c=''));
        logolst.Add(new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC'));
        logolst.Add(new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC'));
        logolst.Add(new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c=''));
        insert logolst;
                        
        Contact c1 = Test_DataFactory.createContact(false,'testcont','testcont',acc.id);
        c1.PDPA__c='SMS';
        c1.NRIC_Passport_No__c='12345678';
        c1.MobilePhone='1234567';
        c1.Franchise_Code__c=u2.Franchise_Code__c;
        c1.Branch_Code__c=u2.Branch_Code__c;
        c1.Address_Line_1__c='add1';
        c1.Address_Line_2__c='add2';
        c1.Address_Line_3__c='add3';
        c1.Unit_No_Floor__c='unitf';
        c1.Country__c='cont';
        c1.Birthdate=Date.today();
        
        Contact c2 = Test_DataFactory.createContact(false,'testcont2','testcont2',acc.id);
        c2.PDPA__c='SMS';
        c2.NRIC_Passport_No__c='12345678';
        c2.MobilePhone='1234567';
        c2.Franchise_Code__c=u2.Franchise_Code__c;
        c2.Branch_Code__c=u2.Branch_Code__c;
        c2.Address_Line_2__c='add2';
        c2.Address_Line_3__c='add3';
        c2.Unit_No_Floor__c='unitf';
        c2.Country__c='cont';
        c2.Birthdate=Date.today();
        
        List<Contact> contactList =new List<Contact>();
        contactList.add(c1);
        contactList.add(c2);
        insert contactList;
        
        Account customerAcc = Test_DataFactory.createPerson(false, 'name', 'Customer');
        customerAcc.Address_Line_1__pc = 'fake address 1';
        customerAcc.Address_Line_2__pc = 'fake address 2';
        insert customerAcc;
        customerAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :customerAcc.Id];
        
        Account prospectAcc = Test_DataFactory.createPerson(false, 'name', 'Prospect');
        prospectAcc.Address_Line_1__pc = 'fake address 1';
        prospectAcc.Address_Line_2__pc = 'fake address 2';
        insert prospectAcc;
        prospectAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :prospectAcc.Id];
        
        Vehicle_Master__c v2=new Vehicle_Master__c(Name='Test v2',Comm_No__c='5678',Status__c='Available',Type__c='Test Drive');
        insert v2;        
        
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        testDrives.add(new Test_Drive__c(Model__c=v2.id,Prospect__c=c1.id,Date__c=today,NRIC__c='12345678',Branch_Code__c='CCK', Agree__c='Yes'));        
        testDrives.add(new Test_Drive__c(Model__c=v2.id,Prospect__c=customerAcc.PersonContactId,Date__c=today,NRIC__c='12345678',Branch_Code__c='CCK',Account__c = customerAcc.Id,Agree__c='Yes'));
        testDrives.add(new Test_Drive__c(Model__c=v2.id,Prospect__c=prospectAcc.PersonContactId,Date__c=today,NRIC__c='12345678',Branch_Code__c='CCK',Account__c = prospectAcc.Id,Agree__c='Yes'));
        
        insert testDrives;

        for(Test_Drive__c td : testDrives){
            ApexPages.currentPage().getParameters().put('id',td.id);
        	TestDrivePDFext tddd  = new TestDrivePDFext(new ApexPages.StandardController(td));
        }
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Test_Drive__c', true);
        Vehicle_Master__c v2=new Vehicle_Master__c(Name='Test v2',Comm_No__c='5678',Status__c='Available',Type__c='Test Drive');
        insert v2;
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        testDrives.add(new Test_Drive__c(Model__c=v2.id,Date__c=date.today(),NRIC__c='12345678',Branch_Code__c='CCK', Agree__c='Yes'));        
        insert testDrives;
        TriggerExclusion.excludeTrigger('Test_Drive__c', false);
    }    
}