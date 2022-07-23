@isTest
public class Test_BatchToUpdateSRToVSMS {
        @TestSetup public static void testSetData(){
        user uc = Test_DataFactory.createUser(false, 'test', 'mykcc1');
        uc.Username = 'JccUser@jcc.com';
        insert uc;
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
        sr1.Opportunity__c = op1.Id;
        sr1.OwnerId = uc.Id;
        sr1.Re_Reserve_To_VSMS__c = true;
        insert sr1;
        //Datetime yesterday1 = Datetime.now().addDays(-1);
        //Test.setCreatedDate(sr1.Id, yesterday1);
        //update sr1;*/
            
        
        
        
    }
     @istest public static void testbatch(){
        Stock_Reservation__c sv = [select id,Name,Customer_Email__c from Stock_Reservation__c];
        //String vms1 = '{"TransactionID": "","PaymentAmount":"1234","Reason":"test","Body":"test", "InvoiceNo":"12345","StockReservationNo":"'+sv.id+'"}';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'[]'));
        BatchToUpdateSRToVSMS bc = new BatchToUpdateSRToVSMS('BatchToReReserveStockReservation');
        database.executebatch(bc);
        test.stopTest();
        
    }

}