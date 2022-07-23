@isTest
private class Trigger_TestDrive_Lead_OwnerUpdate_Test {
   
    @testSetup
    static void createData(){
        
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'KIAPC Sales Consultant'];   

        List<User> lstUser = new List<User>();
        User testUsr1 =  Test_DataFactory.createUser(false, 'testUsr1LN', 'usrtst1');
        testUsr1.UserRoleId = role.Id;
        lstUser.add( testUsr1 );

        User testUsr2 =  Test_DataFactory.createUser(false, 'testUsr2LN', 'usrtst2');
        testUsr2.UserRoleId = role.Id;
        lstUser.add( testUsr2 );

        if( !lstUser.isEmpty() ){
            insert lstUser;
        }  
    }

    @isTest
    static void testAfterUpdateTrigger(){

        List<User> lstUser = [SELECT Id FROM User WHERE LastName IN ('testUsr1LN','testUsr2LN')  ];

        Account acc = Test_DataFactory.createAccount(true, 'Name');

        Lead templead = Test_DataFactory.createLead( false, null, 'leadLN');
        templead.OwnerId = lstUser.get(0).Id;
        insert templead;

        Opportunity opp = Test_DataFactory.createOpportunity(true, 'oppName', acc.Id);
        opp.Lead__c = templead.Id;
        
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.Status__c = 'Pending';
        td.Lead__c   = templead.Id;
        td.Date__c   = Date.today();
        insert td;


        List<Lead> lstLead = [SELECT Id, OwnerId FROM Lead];
        System.assert( lstLead.size() == 1 );
        System.assert( lstUser.size() == 2 );

        System.Test.startTest();
            lstLead.get(0).OwnerId = lstUser.get(1).Id;
            update lstLead;
        System.Test.stopTest();

        System.assert( !([SELECT Id FROM Lead WHERE Assignment_Date__c != null AND Id =: lstLead.get(0).Id]).isEmpty() );
        
    }

}