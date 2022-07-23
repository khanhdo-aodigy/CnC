/** ******
 * Description : Test Class for TriggerExclusion.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        				Description
 * 20200417			    HS							Created Initial Version
 * 
** ******/
@isTest
private class Helper_Class_Test {
    private static String prospectEmail = 'prospect@hotmail.com';
    private static String customerEmail = 'customer@hotmail.com';
    
    @testSetup
    private static void setup() {
        Account prospect = Test_DataFactory.createPerson(true, 'Name', 'Prospect');
        prospect = [SELECT PersonContactId FROM Account WHERE Id = :prospect.Id];
        
        Contact prospectCon = new Contact(Id = prospect.PersonContactId);
        prospectCon.Email = prospectEmail;
        update prospectCon;
        
        Account customer = Test_DataFactory.createPerson(true, 'Name', 'Customer');
        customer = [SELECT PersonContactId FROM Account WHERE Id = :customer.Id];
        
        Contact customerCon = new Contact(Id = customer.PersonContactId);
        customerCon.Email = customerEmail;
        update customerCon;
    }
    
    @isTest
    private static void testAttachPDF_KIAPC() {
        Contact prospectCon = [SELECT Id FROM Contact WHERE Email = :prospectEmail];
        Contact customerCon = [SELECT Id FROM Contact WHERE Email = :customerEmail];
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        
        Test_Drive__c prospectTestDrive = Test_DataFactory.createTestDrive(false, null);
        prospectTestDrive.Prospect__c = prospectCon.Id;
        prospectTestDrive.Branch_Code__c = 'CCA';
        prospectTestDrive.Franchise_Code__c = 'KIAPC';
        prospectTestDrive.Receive_idemnity_form__c = 'Yes';
        testDrives.add(prospectTestDrive);
        
        Test_Drive__c customerTestDrive = Test_DataFactory.createTestDrive(false, null);
        customerTestDrive.Prospect__c = customerCon.Id;
        customerTestDrive.Branch_Code__c = 'CCA';
        customerTestDrive.Franchise_Code__c = 'KIAPC';
        customerTestDrive.Receive_idemnity_form__c = 'Yes';
        testDrives.add(customerTestDrive);
        
        insert testDrives;
        
        for(Test_Drive__c td: testDrives) {
            Helper_Class.AttachPDF(td.Id);
        }        
    }
    
    @isTest
    private static void testAttachPDF_MITPC() {
        Contact prospectCon = [SELECT Id FROM Contact WHERE Email = :prospectEmail];
        Contact customerCon = [SELECT Id FROM Contact WHERE Email = :customerEmail];
        
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        
        Test_Drive__c prospectTestDrive = Test_DataFactory.createTestDrive(false, null);
        prospectTestDrive.Prospect__c = prospectCon.Id;
        prospectTestDrive.Branch_Code__c = 'CCA';
        prospectTestDrive.Franchise_Code__c = 'MITPC';
        prospectTestDrive.Receive_idemnity_form__c = 'Yes';
        testDrives.add(prospectTestDrive);
        
        Test_Drive__c customerTestDrive = Test_DataFactory.createTestDrive(false, null);
        customerTestDrive.Prospect__c = customerCon.Id;
        customerTestDrive.Branch_Code__c = 'CCA';
        customerTestDrive.Franchise_Code__c = 'MITPC';
        customerTestDrive.Receive_idemnity_form__c = 'Yes';
        testDrives.add(customerTestDrive);
        
        insert testDrives;
        
        for(Test_Drive__c td: testDrives) {
            Helper_Class.AttachPDF(td.Id);
        }        
    }
    
    @isTest
    private static void testAttachPDF_CITPC() {
        Contact prospectCon = [SELECT Id FROM Contact WHERE Email = :prospectEmail];
        Contact customerCon = [SELECT Id FROM Contact WHERE Email = :customerEmail];
    
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        
        Test_Drive__c prospectTestDrive = Test_DataFactory.createTestDrive(false, null);
        prospectTestDrive.Prospect__c = prospectCon.Id;
        prospectTestDrive.Branch_Code__c = 'CCA';
        prospectTestDrive.Franchise_Code__c = 'CITPC';
        prospectTestDrive.Receive_idemnity_form__c = 'Yes';
        testDrives.add(prospectTestDrive);
        
        Test_Drive__c customerTestDrive = Test_DataFactory.createTestDrive(false, null);
        customerTestDrive.Prospect__c = customerCon.Id;
        customerTestDrive.Branch_Code__c = 'CCA';
        customerTestDrive.Franchise_Code__c = 'CITPC';
        customerTestDrive.Receive_idemnity_form__c = 'Yes';
        testDrives.add(customerTestDrive);
        
        insert testDrives;
        
        for(Test_Drive__c td: testDrives) {
            Helper_Class.AttachPDF(td.Id);
        }        
    }
}