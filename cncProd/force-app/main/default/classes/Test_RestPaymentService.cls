@isTest
public class Test_RestPaymentService {
    @TestSetup public static void testSetData(){
        user uc = Test_DataFactory.createUser(true, 'test', 'mykcc1');
        Account ac = Test_DataFactory.createAccount(true, 'test');
        Contact c = Test_DataFactory.createContact(true, 'test', 'payment', ac.id);
        Model_Master__c mc =  Test_DataFactory.createModelCode(true, 'testModel');
        Color_Master__c cm =  Test_DataFactory.createColorCode(true, 'testModelColor','KIAvs','CCF','CITCV'); 
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'testTrim');
        lead ld1 = Test_DataFactory.createLead(true, 'testJcc', 'MyJcc');
        Opportunity op1 = Test_DataFactory.createOpportunity(false, 'test', ac.id);
        op1.Lead__c = ld1.Id;
        insert op1;
        
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, mc.id, cm.id, tm.id, null);
        sr1.Stock_Source__c = 'KIA Warehouse';
        sr1.Franchise_Code__c = 'KIACV';
        sr1.Opportunity__c = op1.Id;
        sr1.Customer_Email__c = 'test@jcc.com';
        sr1.OwnerId = uc.Id;
        insert sr1;
        
        Test_Drive__c td = Test_DataFactory.createTestDrive(false,op1.Id);        
        td.Date__c = Date.today().addDays(-7);
        insert td;

        Campaign cp = Test_DataFactory.createCamp(true,'Test camp','Paid Events','CCK');
        
        Invoice__c nv = Test_DataFactory.createInvoice(false,c.id,null);       
        nv.Department__c = 'test';
        nv.Transaction_Type__c = 'Purchase';
        nv.Payment_Type__c = 'Receipt';
        nv.StockReservation__c = sr1.Id;
        nv.Campaign_ID__c = cp.id;
        insert nv;
 
        global_var__c gb = Test_DataFactory.createGlobalOrfDefaults(true); 
        
        
    }

    @istest public static void testbatch(){
        Invoice__c v= [select id,Invoice_Number__c from Invoice__c where Transaction_Type__c = 'Purchase' limit 1];
        Stock_Reservation__c sv = [select id,Name,Customer_Email__c from Stock_Reservation__c limit 1];
        Stock_Reservation__c stockToRelease = [select id, OwnerId, Reservation_Status__c, Cancellation_Reason__c, Opportunity__c from Stock_Reservation__c where name = :sv.Name];    
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.addParameter('paymenttype', 'cash');
        req.addParameter('branch', 'CCF');
        req.addParameter('transactiontype', 'Purchase');
        req.requestURI = 'test.salesforce.com';
        String vms1 = '{"TransactionID": "","CustomerEmail" : "'+sv.Customer_Email__c+'","PaymentAmount":"1234","Reason":"test","Body":"test", "InvoiceNo":"'+v.Invoice_Number__c+ '","StockReservationNo":"'+ sv.Name+'"}';
        req.requestBody = Blob.valueOf(vms1);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms1);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms1));
        Test.stopTest();
        restPaymentService.createPaymentDetails();
    
    } 

    @istest public static void testbatch1(){
        Contact c= [select id,Name from Contact limit 1]; 
        Stock_Reservation__c sv = [select id,Name,Customer_Email__c from Stock_Reservation__c limit 1];
        Stock_Reservation__c stockToRelease = [select id, OwnerId, Reservation_Status__c, Cancellation_Reason__c, Opportunity__c from Stock_Reservation__c where name = :sv.Name];
        
        Campaign cp = Test_DataFactory.createCamp(true,'Test camp','Paid Events','CCK');
        Invoice__c nv1 = Test_DataFactory.createInvoice(false,c.id,null);       
        nv1.Department__c = 'test';
        nv1.Transaction_Type__c = 'Cancel';
        nv1.Transaction_ID__c = 'test123';
        nv1.Payment_Type__c = 'Receipt';
        nv1.StockReservation__c = sv.Id;
        nv1.Campaign_ID__c = cp.id;
        insert nv1;       
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.addParameter('branch', 'CCA');
        req.addParameter('transactiontype', 'Refund');
        req.addParameter('paymenttype', 'cash');
        req.requestURI = 'test.salesforce.com';
        String vms1 = '{"TransactionID": "","CustomerEmail" : "'+sv.Customer_Email__c+'","PaymentAmount":"1234","Reason":"test","Body":"test", "InvoiceNo":"'+nv1.Invoice_Number__c+ '","StockReservationNo":"'+ sv.Name+'"}';
        req.requestBody = Blob.valueOf(vms1);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms1);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms1));      
        Test.stopTest();
        restPaymentService.createPaymentDetails();
        
        
    }

    @istest public static void testbatch2(){
        Invoice__c v = [select id,Invoice_Number__c from Invoice__c where Transaction_Type__c = 'Purchase' limit 1];
        Stock_Reservation__c sv = [select id,Name,Customer_Email__c from Stock_Reservation__c limit 1];
        Stock_Reservation__c stockToRelease = [select id, OwnerId, Reservation_Status__c, Cancellation_Reason__c, Opportunity__c from Stock_Reservation__c where name = :sv.Name];
               
        RestRequest req = new RestRequest();
        req.addParameter('branch', 'CCK');
        req.addParameter('paymenttype', 'cash');
        req.addParameter('transactiontype', 'Purchase');
        req.requestURI = 'test.salesforce.com';
        String vms1 = '{"TransactionID": "","CustomerEmail" : "'+sv.Customer_Email__c+'","PaymentAmount":"1234","Reason":"test", "InvoiceNo":"","StockReservationNo":"'+ sv.Name+'"}';
        req.requestBody = Blob.valueOf(vms1);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms1);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        restPaymentService.createPaymentDetails();
        Test.stopTest();
    }

    @istest public static void testbatch4(){
        Invoice__c v= [select id,Invoice_Number__c from Invoice__c limit 1];
        Stock_Reservation__c sv = [select id,Name,Customer_Email__c from Stock_Reservation__c limit 1];
        Stock_Reservation__c stockToRelease = [select id, OwnerId, Reservation_Status__c, Cancellation_Reason__c, Opportunity__c from Stock_Reservation__c where name = :sv.Name];
              
        RestRequest req = new RestRequest();
        req.addParameter('transactiontype', 'Refund');
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.addParameter('branch', 'CCF');
        req.addParameter('paymenttype', 'cash');
        req.requestURI = 'test.salesforce.com';
        String vms1 = '{"TransactionID": "","CustomerEmail" : "'+sv.Customer_Email__c+'","PaymentAmount":"1234","Reason":"test","Body":"test", "InvoiceNo":"'+v.Invoice_Number__c+ '","StockReservationNo":"'+ sv.Name+'"}';
        req.requestBody = Blob.valueOf(vms1);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms1);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms1)); 
        Test.stopTest();
        restPaymentService.createPaymentDetails();
        
        
    }
    
}