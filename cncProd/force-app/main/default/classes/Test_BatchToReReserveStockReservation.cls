@isTest
public class Test_BatchToReReserveStockReservation{
    @TestSetup public static void testSetData(){
        user uc = Test_DataFactory.createUser(true, 'test', 'mykcc1');
        Account acc = Test_DataFactory.createAccount(true, 'test');
        Model_Master__c mc =  Test_DataFactory.createModelCode(true, 'testModel');
        Color_Master__c cm =  Test_DataFactory.createColorCode(true, 'testModelColor','KIAvs','CCF','CITCV'); 
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'testTrim');
        lead ld1 = Test_DataFactory.createLead(true, 'testJcc', 'MyJcc');
        Opportunity op1 = Test_DataFactory.createOpportunity(false, 'test', acc.id);
        op1.Lead__c = ld1.Id;
        op1.OwnerId = uc.Id;
        insert op1;
        
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, mc.id, cm.id, tm.id, null);
        sr1.Reservation_Status__c = 'Cancel';
        sr1.Cancellation_Reason__c = 'SYSTEM CANCEL DUE TO NO AGREEMENT';
        sr1.Stock_Source__c = 'KIA Warehouse';
        sr1.Franchise_Code__c = 'KIACV';
        sr1.Opportunity__c = op1.Id;
        sr1.OwnerId = uc.Id;
        insert sr1;
        Datetime yesterday1 = Datetime.now().addDays(-1);
        Test.setCreatedDate(sr1.Id, yesterday1);
        update sr1;
        
        
        
    }
    
    @istest public static void testbatch(){
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'[{"success Messaged": "Successful"}]'));
        BatchToReReserveStockReservation bc = new BatchToReReserveStockReservation('test');
        database.executebatch(bc);
        test.stopTest();
        
    }
}