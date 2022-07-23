@isTest
private class DWH_QueueDeLinkVehiclesTest {
    @testSetUp
    static void createData(){
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getName());
        Contact con = Test_DataFactory.createContact(true, 'FName','LName', acc.Id);
        Contact con2 = Test_DataFactory.createContact(true, 'firstCon','SecondContact', acc.Id);
        
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle(false, 'NameVehicle', 'CCA', 'MITPC', 'SM123', con2.Id);
        regVeh.DWH_Vehicle_ID__c = '3454';
        insert regVeh;
            
        global_var__c gv = new global_var__c();
        gv.APIGateway_url__c = 'test';
        gv.APIGateway_key__c = 'key';
        gv.DWHDelinkedVehicleOwner__c = con.Id;
        upsert gv;
    }
    
    //test if Queueable will invoke batch job
    static testMethod void testDeLinkQueue(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_DelinkVehicles', true));
        
        System.enqueueJob( new DWH_QueueDeLinkVehicles() );
        DWH_QueueDeLinkVehicles.DeLinkWrapper deLink = new DWH_QueueDeLinkVehicles.DeLinkWrapper('', '', '', '', 
                             '', '', '','');
        Test.stopTest();
    }
    
    //test if Registered Vehicle Owner will be deleted.
    static testMethod void testDelinkBatch(){
        Test.startTest();
        Map<String, String> mp = new Map<String, String>();
        mp.put('3454','UNKNOWN');
        
        Database.executeBatch( new DWH_BatchDeLinkVehicles( mp ) );
        Test.stopTest();
        //Verify the Contact is updated
        Contact con = [SELECT Id FROM Contact WHERE LastName='LName' LIMIT 1];
        Registered_Vehicle__c reg = [SELECT Id, Contact__c FROM Registered_Vehicle__c WHERE DWH_Vehicle_ID__c = '3454'];
        
    }
    
    //Test schedule
    static testMethod void testDelinkSchedule(){
        Test.startTest();
        System.schedule('Sched Delink Job01', '0 0 0 ? * * *', new DWH_BatchDeLinkVehicles(new Set<String>{'3454'}));
        Test.stopTest();
    }    
}