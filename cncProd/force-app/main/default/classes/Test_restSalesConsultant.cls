@isTest
private class Test_restSalesConsultant {
    static String branch = 'CCF';
    @testSetup
    private static void testSetData(){
        User testUser = new User();
        User currentUser = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
        System.RunAs(currentUser) {
            UserRole role = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%Sales Consultant%' LIMIT 1];
            testUser = Test_DataFactory.createUser(false, 'Dummy User', 'test');
            testUser.Branch_Code__c = branch;
            testUser.email = 'test@jcc.com';
            testUser.UserRoleId = role.Id;
            testUser.ExcludeFromWarehouse__c = false;
            testUser.IsActive = true;
            insert testUser;
        }    
        
        Account personAcc = Test_DataFactory.createPerson(true, 'Test', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.Email = 'test@pa.com';
        
        Account ac = Test_DataFactory.createAccount(true, 'test');
        Contact c = Test_DataFactory.createContact(false, 'test', 'payment', ac.id);
        c.Email = 'test@jcc.com';
        insert c;
        
        Model_Master__c mc =  Test_DataFactory.createModelCode(true, 'testModel');
        Color_Master__c cm =  Test_DataFactory.createColorCode(true, 'testModelColor','KIAvs','CCF','CITCV'); 
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'testTrim');
        lead ld1 = Test_DataFactory.createLead(true, 'testJcc', 'MyJcc');
        
        Opportunity op1 = Test_DataFactory.createOpportunity(false, 'test', ac.id);
        op1.OwnerId = testUser.Id;
        op1.Contact_Person__c = c.Id;
        insert op1;
        
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, mc.id, cm.id, tm.id, null);
        sr1.Stock_Source__c = 'KIA Warehouse';
        sr1.Franchise_Code__c = 'KIACV';
        sr1.Opportunity__c = op1.Id;
        sr1.Customer_Email__c = 'test@jcc.com';
        sr1.OwnerId = testUser.Id;
        insert sr1;
        
        Test_Drive__c td = new Test_Drive__c();
        td.Opportunity__c = op1.Id;
        td.Date__c = Date.today().addDays(-7);
        insert td;
        
        
    }
    
    // this method is for purshase request
    @istest private static void testbatch(){
        
        Contact c = [select id,Email from Contact limit 1];
        User uc = [select id,Branch_Code__c,UserRoleId from User WHERE email = 'test@jcc.com' limit 1];
        Opportunity op1 = [SELECT ID, OwnerId,Contact_Person__c FROM Opportunity LIMIT 1];
        op1.OwnerID = uc.ID;
        Update op1;
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.addParameter('email', 'test@jcc.com');
        req.addParameter('branch', branch);
        req.addParameter('transactiontype', 'Purchase');
        req.requestURI = 'test.salesforce.com';
        String vms =  '{"TransactionID": "","CustomerEmail" : "'+c.email+'","PaymentAmount":"1234", "InvoiceNo":"123"}';
        req.requestBody = Blob.valueOf(vms);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        restSalesConsultant.salesConsultantInfo();
        restSalesConsultant.isValidateParamPassed();
        Test.stopTest();
        
        
    }
    
    @istest private static void testbatch2(){
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        //req.addParameter('email', 'test@jcc.com');
        req.addParameter('branch', branch);
        req.addParameter('transactiontype', 'Purchase');
        req.requestURI = 'test.salesforce.com';
        String vms =  '{"TransactionID": "","CustomerEmail" : "test@test.com","PaymentAmount":"1234", "InvoiceNo":"123"}';
        req.requestBody = Blob.valueOf(vms);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        restSalesConsultant.salesConsultantInfo();
        restSalesConsultant.isValidateParamPassed();
        Test.stopTest();
    }
    
    @isTest
    private static void testGetSalesConsultantInfo(){
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.addParameter('transactiontype', 'Purchase');
        req.requestURI = 'test.salesforce.com';
        String vms =  '{"TransactionID": "","CustomerEmail" : "test@test.com","PaymentAmount":"1234", "InvoiceNo":"123"}';
        req.requestBody = Blob.valueOf(vms);
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf(vms);
        res.statusCode = 200;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        restSalesConsultant.salesConsultantInfo();
        restSalesConsultant.isValidateParamPassed();
        Test.stopTest();
   }
    
}