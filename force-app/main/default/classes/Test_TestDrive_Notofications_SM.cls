@isTest
public class Test_TestDrive_Notofications_SM {
    @testSetup
    public static void createData(){
        Account acc = Test_DataFactory.createPerson(true, UserInfo.getName(), 'Customer');
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'Opp Name', acc.Id);
        Datetime next3Days = Date.today().addDays(3);
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.Date__c = next3Days;
        td.Status__c = 'Pending';
        td.Account__c = acc.Id;
        
        insert td;
        Test_Drive__c td1 = Test_DataFactory.createTestDrive(false, opp.Id);
        td1.Date__c = Date.today().addDays(2);
        td1.Status__c = 'Pending';
        td1.Account__c = acc.Id;
        insert td1;
    }
    @isTest
    Public static void testSendEmail()
    {        
        Test.startTest();
        System.schedule('Test_TestDrive_Notofications_SM', '0 0 0 ? * * *', new TestDrive_Notofications_SalesManager());
        Test.stopTest();
        System.assertNotEquals(0, [Select COUNT() FROM Task ]);
    }
}