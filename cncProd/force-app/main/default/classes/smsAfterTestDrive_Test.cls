@isTest
public class smsAfterTestDrive_Test {
	@isTest
    public static void testTrigger(){
        Test.startTest();

        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAccount060');

        Account acc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        acc.PersonEmail = 'abc@test.com';
        acc.PersonMobilePhone = '1234554321';
        insert acc;
        
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', jccAcct.Id);
        con.Account__c = acc.Id;
        con.MobilePhone = '123459786';

        insert con;
        
        User user = Test_DataFactory.createUser(false, 'UserLN', 'userln');
		user.MobilePhone = '1234534567';
		insert user;
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'Opp Name', jccAcct.Id);
        
        Model__c model = new Model__c(Name='TestMod', Branch_Code__c='CCK', Franchise_Code__c = 'KIAPC', DWH_Model_ID__c='abc12345');
        insert model;
        Model_Group__c modelGroup = new Model_Group__c(Name='DS', Branch_Code__c='CCK', Franchise_Code__c = 'KIAPC');
        insert modelGroup;
        Vehicle_Master__c vehMaster = Test_DataFactory.createVehicleMaster(false, 'Test', null, model.Id);
        vehMaster.Model_Group__c = modelGroup.Id;
        insert vehMaster;
        
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.Date__c = Date.today().addDays(3);
        td.Status__c = 'In';
        td.Account__c = acc.Id;
        td.OwnerId = user.Id;
        td.Franchise_Code__c='MITPC';
        td.Check_In__c = Date.today();
        insert td;
        
        td.send_Sms__c = true; 
        update td;
        
        Account acc1 = Test_DataFactory.createPerson(false, UserInfo.getLastName(), 'Prospect');
        acc1.PersonEmail = 'abc@test.com';
        acc1.PersonMobilePhone = '65123456';
        insert acc1;
        
        Test_Drive__c td1 = Test_DataFactory.createTestDrive(false, opp.Id);
        td1.Date__c = Date.today().addDays(2);
        td1.Status__c = 'In';
        td1.Prospect__c = con.Id;
        td1.Franchise_Code__c = 'KIAPC';
        td1.send_Sms__c = false; 
        td1.OwnerId = user.Id;
        td1.Check_In__c = Date.today().addDays(2);
        td1.Model__c = vehMaster.Id;

        insert td1;
        
        td1.send_Sms__c = true; 
        update td1;
        
        Test_Drive__c td2 = Test_DataFactory.createTestDrive(false, opp.Id);
        td2.Status__c = 'In';
        td2.Franchise_Code__c = 'CITPC';
        td2.send_Sms__c = false; 
        td2.OwnerId = user.Id;
        td2.Check_In__c = Date.today().addDays(2);
        insert td2;
        
        td2.send_Sms__c = true; 
        update td2;

        
        Test.stopTest();
    }
    
    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Test_Drive__c', true);
        Test_Drive__c td = Test_DataFactory.createTestDrive(true, null);
        TriggerExclusion.excludeTrigger('Test_Drive__c', false);
    }   
}