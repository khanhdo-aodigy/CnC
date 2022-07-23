/****************************************************
* Class Name: BatchUpdateUserNRICTest
* Description: Test class for BatchUpdateUserNRIC
*
* Developer Name    Date      Description
* Savita          31-July-2019    Created.
****************************************************/ 
@isTest
private class BatchUpdateUserNRICTest {

    @testSetup
    static void createData(){
        Test.startTest();
        Account at = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        Contact cn = Test_DataFactory.createContact(false, 'FN',  'LN', at.Id);
        cn.LastNRICUpdated__c = Date.today();
        cn.NRIC_Passport_No__c = '123456ABCDEF';	
        insert cn;
        
        List<Registered_Vehicle__c> rvList = new List<Registered_Vehicle__c>();
        Date dt = System.today();
        Date twentytwoMonthsAgo = dt.addMonths(-22);
        Date twentythreeMonthsAgo = dt.addMonths(-23);
        
        for(Integer i=0; i<3; i++){
            Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false, 'SEBE'+i, 'CCK', 'KIAPC', 'SEBE'+i, cn.Id);
            rv.Last_Battery_Change__c = Math.mod(i, 2) == 0 ? twentytwoMonthsAgo : twentythreeMonthsAgo;
            rv.IsOwnerChanged__c = true;
            rv.OwnerChangeTimeStamp__c = Date.today();
            rvList.add(rv);
        }
        insert rvList;
        
        
        Service_Packages__c srev = new Service_Packages__c();
        srev.Registered_Vehicle__c = rvList.get(0).Id;
        srev.Status__c = 'Active';
        insert srev;
        
        
        Account pAcc = Test_DataFactory.createPerson(true, 'PA', 'Prospect');	 /** PA Migration : Newly Added */
        pAcc = [Select Id, PersonContactId, RecordType.Name From Account Where Id = :pAcc.Id];
        System.debug('testing---'+pAcc);

        Account jccAcc = Test_DataFactory.createAccount(true, 'JCCTestAccount999');
        Contact paCon = Test_DataFactory.createContact(false, 'FNPA',  'LNPA', jccAcc.Id);
        paCon.Account__c = pAcc.Id;	
        //paCon.NRIC_Passport_No__c = '12345ASDF';
        paCon.LastNRICUpdated__c = Date.today();
        insert paCon;

        Account acc = [Select PersonContactId From Account Where Id = :pAcc.Id];
        
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
            /*ContactId__c = cn.Id*/);
        insert u;
        Test.stopTest();
        
    }
    
    //Batch Test
    static testMethod void testBatch(){
        Test.startTest();
        TriggerExclusion.excludeTrigger('User', true);
        System.schedule('Schedule BatchNRIC', '0 0 0 ? * * *', new BatchUpdateUserNRIC() );
        Test.stopTest();
        //System.assertEquals(1 , [SELECT COUNT() FROM User WHERE NRIC__c = '123456ABCDEF']);

    }
    
    //Batch Test
    static testMethod void testBatteryBatch(){
        Set<String> setRegIds = new Set<String>();
        for(Registered_Vehicle__c rv : [Select Id From Registered_Vehicle__c]){
            setRegIds.add(rv.Id);
        }
        Test.startTest();
        System.schedule('Schedule BatchBattery', '0 0 0 ? * * *', new BatteryChange() );
        BatteryChange.customerAlertTest(setRegIds);
        Test.stopTest();
    }
    
    //Batch Test
    static testMethod void testAlerts(){
        Test.startTest();
        System.schedule('Schedule AlertsScheduler', '0 0 0 ? * * *', new AlertsScheduler() );
        AlertsScheduler.manualRunAlerts();
        Test.stopTest();
    }
    
    //Batch Test
    static testMethod void testInsertShare(){
        Test.startTest();
        Database.executeBatch( new InsertContactShareRecord() );
        Test.stopTest();
    }
    
    //Batch Test
    static testMethod void testDeactivateBatch(){
        Test.startTest();
        Database.executeBatch( new BatchDeactivateServicePackage() );
        Test.stopTest();
    }  
    
    //Batch Test
    static testMethod void testBatchSend(){
        Test.startTest();
        Account acc = [SELECT ID FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        Contact cn = [SELECT Id FROM Contact WHERE FirstName = 'FN' AND LastName='LN'];
        Opportunity opp = Test_DataFactory.createOpportunity(true, UserInfo.getLastName(), acc.Id);
        
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.Prospect__c = cn.Id;
        td.Status__c = 'Pending';
        td.Date__c =  date.today().addDays(-1);
        insert td;
        
        System.schedule('Schedule SendNoShow', '0 0 0 ? * * *', new SendTestDriveNoShowEmail() );
        Test.stopTest();
    }  
}