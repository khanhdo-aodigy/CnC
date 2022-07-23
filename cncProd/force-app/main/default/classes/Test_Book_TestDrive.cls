@isTest
private class Test_Book_TestDrive {
    static String name = 'dummyData';
    static String testRun = 'dummyData';
    
    @isTest
    private static void testBookTestDrive_withMITFranchiseCode() {
        String franchiseCode = 'MITPC';
        String branchCode = 'CCA';
        Model__c model = Test_DataFactory.createmodelId(true, name, branchCode, franchiseCode);
        Variant__c variant = Test_DataFactory.createVariant(true, name, model.Id, branchCode);
        Showroom__c showroom = Test_DataFactory.createShowroom(true); 
        Vehicle_Master__c vehMaster = Test_DataFactory.createVehicleMaster(false, 'test123', null, model.Id);
        vehMaster.Type__c = 'Test Drive';
        insert vehMaster;

        Account personAcc = Test_DataFactory.createPA(true, name, name + '@test.com', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Opportunity opp = Test_DataFactory.createOpportunity(false, name, personAcc.Id);
        opp.Contact_Person__c = personAcc.PersonContactId;
        opp.StageName = 'New';
        opp.Branch_Code__c = branchCode;
        insert opp;
        
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd', UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+ personAcc.PersonContactId+'","Type" : "Contact","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+ model.Id+'","Showroom" : "'+ showroom.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testBookTestDrive_withKIAFranchiseCode(){
        Account personAcc = Test_DataFactory.createPA(true, 'LastName', 'lastname1@test.com', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        String branchCode = 'CCK';
        String franchiseCode = 'KIAPC';
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', branchCode, franchiseCode); 
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, branchCode); 
        Showroom__c showroom = Test_DataFactory.createShowroom(true);
        
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+ personAcc.PersonContactId +'","Type" : "Account","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+ model.Id +'","TVariant" : "'+ variant.Id+'","Showroom" : "'+ showroom.Id+'"}';
        
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testBlankFieldsBook() {
        Test.startTest();
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "","Type" : "Contact","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'"}';
        
        Test_DataFactory.createReq('CreateTestDrive',json);       
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
	    
    /*@isTest
    private static void testBookTestDrive() {
        Account acc = Test_DataFactory.createPerson(true, testRun, 'Customer');
        Lead TestLead = Test_DataFactory.createLead(true,testRun,testRun);        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);  
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);        
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',null,TestMod.id);
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestLead.id+'","Type" : "Lead","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testLeadBook() {
        Account acc = Test_DataFactory.createPerson(true, testRun, 'Customer');
        Lead TestLead = Test_DataFactory.createLead(true,testRun,testRun);        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);  
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);        
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',null,TestMod.id);
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestLead.id+'","Type" : "Lead","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testLeadBook1() {
        //Account acct = Test_DataFactory.createAccount(true,testRun);
        Account acct = Test_DataFactory.createPerson(true, testRun, 'Customer');

        Lead TestLead = Test_DataFactory.createLead(true,testRun,testRun);        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCK','KIAPC');  
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCK');        
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',null,TestMod.id);
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Lead__c = TestLead.id;
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 28;
        insert oppt;
        
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestLead.id+'","Type" : "Lead","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testLeadBook2() {
        //Account acct = Test_DataFactory.createAccount(true,testRun);
        Account acct = Test_DataFactory.createPerson(true, testRun, 'Customer');

        Lead TestLead = Test_DataFactory.createLead(true,testRun,testRun);
		TestLead.Account__c = acct.Id;
		update TestLead;        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCF','CITPC');  
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCF');        
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',null,TestMod.id);
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Lead__c = TestLead.id;
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 80;
        insert oppt;
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(false,TestMod.id, oppt.id, 'Open','Warehouse');
        insert mInt;
        
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestLead.id+'","Type" : "Lead","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testContactBook() {
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Contact TestCon =  Test_DataFactory.createContact(true,testRun,testRun,acct.Id);    
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCK','KIAPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCK'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 40;
        insert oppt;
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(true,TestMod.id, oppt.id, 'Open','Warehouse');
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestCon.id+'","Type" : "Contact","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","TVariant" : "'+TestVar.Id+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testContactBookCCA() {
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Contact TestCon =  Test_DataFactory.createContact(true,testRun,testRun,acct.Id);         
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Contact_Person__c = TestCon.id;
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 10;
        insert oppt;
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(false,TestMod.id, oppt.id, 'Open','');
        insert mInt;
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestCon.id+'","Type" : "Contact","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","TVariant" : "'+TestVar.Id+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void testContactBookPA() {
        Account acct = Test_DataFactory.createAccount(true,testRun);
        Account pAcc = Test_DataFactory.createPerson(true, testRun, 'Customer');

        Contact TestCon =  Test_DataFactory.createContact(true,testRun,testRun,acct.Id);      
        TestCon.Account__c = pAcc.Id;
        update TestCon;
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,'CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(false,'test123',TestVar.id,TestMod.id);
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
        oppt.Contact_Person__c = TestCon.id;
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 10;
        insert oppt;
        Models_Interested__c mInt = Test_DataFactory.createmodelsInterested(false,TestMod.id, oppt.id, 'Open','');
        insert mInt;
        testVh.Type__c = 'Test Drive';
        insert testVh;
        Showroom__c TestShow = Test_DataFactory.createShowroom(true);                
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+TestCon.id+'","Type" : "Contact","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+TestMod.ID+'","TVariant" : "'+TestVar.Id+'","Showroom" : "'+TestShow.Id+'"}';
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    
    //Test method for Blank Fields
    @isTest
    private static void testBlankFieldsBook() {
        Test.startTest();
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "","Type" : "Contact","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'"}';
        
        Test_DataFactory.createReq('CreateTestDrive',json);       
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    //PA MIGRATION: Newly Added - Start
    @isTest
    private static void createTestDriveWithPA_withKIAFranchiseCode(){
        Account personAcc = Test_DataFactory.createPerson(true, 'LastName', 'PersonAccount');
        
        String franchiseCode = 'KIAPC';
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCK', franchiseCode); 
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCK'); 
        Showroom__c showroom = Test_DataFactory.createShowroom(true);
        
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+ personAcc.Id +'","Type" : "Account","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+ model.Id +'","TVariant" : "'+ variant.Id+'","Showroom" : "'+ showroom.Id+'"}';
        
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();
    }
    
    @isTest
    private static void createTestDriveWithPA_withMITFranchiseCode(){
        Account personAcc = Test_DataFactory.createPerson(true, 'LastName', 'PersonAccount');
        String franchiseCode = 'MITPC';
        Model__c model = Test_DataFactory.createmodelId(true,'modelName','CCA', franchiseCode); 
        
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCA'); 
        Showroom__c showroom = Test_DataFactory.createShowroom(true);
        
        Datetime YESTERDAYD = datetime.now();
        String formattedDate = YESTERDAYD.format('yyyy-MM-dd',  UserInfo.getTimeZone().toString());
        String json = '{"PersonId" : "'+ personAcc.Id +'","Type" : "Account","Status" : "Queue","source" : "Website","BookingDate" : "'+formattedDate+'","TModel" : "'+ model.Id +'","TVariant" : "'+ variant.Id+'","Showroom" : "'+ showroom.Id+'"}';
        
        Test.startTest();
        Test_DataFactory.createReq('CreateTestDrive',json);         
        Book_TestDrive.CreateTestDrive();
        Test.stopTest();        
    }*/

    /** PA MIGRATION: Newly Added - End */
    
}