@isTest
public class Test_BatchScheduleRegVehicleNewOwner {

    @testSetup static void setupTestData() {       
       Account acc = new Account();
        acc = Test_DataFactory.createAccount(true,'test');
        Contact con = new Contact();
        con = Test_DataFactory.createContact(true,'test','test',acc.Id);
        Contact con2 = new Contact();
        con2 = Test_DataFactory.createContact(true,'test2','test2',acc.Id);
        Registered_Vehicle__c reg = new Registered_Vehicle__c();
        reg = Test_DataFactory.createregVehicle(false,'test123','CCK','KIAPC','test123',con.Id);
        Registered_Vehicle__c regCIT = new Registered_Vehicle__c();
        regCIT = Test_DataFactory.createregVehicle(false,'test123','CCF','CITPC','testCIT',con.Id);
        Registered_Vehicle__c regDS = new Registered_Vehicle__c();
        regDS = Test_DataFactory.createregVehicle(false,'test123','CCF','CITPC','testDS',con.Id);
        Registered_Vehicle__c regMIT = new Registered_Vehicle__c();
        regMIT = Test_DataFactory.createregVehicle(false,'testMIT','CCA','MITPC','testMIT',con.Id);
        Date myDate = Date.today().addmonths(-22);
        reg.Last_Battery_Change__c = myDate;
        insert reg;
        regMIT.Last_Battery_Change__c = myDate;
        insert regMIT;
          
    }
    static testMethod void testBatchScheduleRegVehicleNewOwner()
    {   
        Contact c2 = [select id from contact where firstname='test2' limit 1];
        Registered_Vehicle__c reg = [select id,name,contact__c from Registered_Vehicle__c  where name ='test123' limit 1];
        reg.contact__c = c2.id;
        update reg;
        String cronExpr = '0 0 0 15 3 ? 2022';
        Test.startTest();        
        String jobId = System.schedule('BatchScheduleRegVehicleNewOwner', cronExpr, new BatchScheduleRegVehicleNewOwner());
        Test.stopTest();
    }
    
    static testMethod void testBatchScheduleRegVehicleNewOwner2_kia()
    {   
        Registered_Vehicle__c reg = [select id,name,contact__c from Registered_Vehicle__c  where name ='test123' limit 1];
        Test.startTest();        
        database.executebatch(new BatchRegisteredVehicleNewOwner(new Set<id>{reg.id}));
        Test.stopTest();
    }
    static testMethod void testBatchScheduleRegVehicleNewOwner2_MIT()
    {   
        Registered_Vehicle__c regMIT = [select id,name,contact__c from Registered_Vehicle__c  where name ='testMIT' limit 1];
        Test.startTest();        
        database.executebatch(new BatchRegisteredVehicleNewOwner(new Set<id>{regMIT.id}));
        Test.stopTest();
    }
 }