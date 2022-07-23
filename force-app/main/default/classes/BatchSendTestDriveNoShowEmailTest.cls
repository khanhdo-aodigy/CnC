/****************************************************
* Class Name: BatchSendTestDriveNoShowEmailTest
* Description: Test class for BatchSendTestDriveNoShowEmail
****************************************************/ 
@isTest
private class BatchSendTestDriveNoShowEmailTest {
    @testSetup
    static void createData(){
       
    }
    
    @isTest
    static void testSendTestDriveNoShowEmailWithCustomerAccount(){        
        // Account customerAcc = Test_DataFactory.createPerson(true, 'Test', 'Customer');
        Account customerAcc = Test_DataFactory.createAccount(true, 'TestingAccount123');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', customerAcc.Id); //PA MIGRATION: To Remove
                
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'oppName', customerAcc.Id);
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCK');
        Vehicle_Master__c vehicleMaster = Test_DataFactory.createVehicleMaster(true, 'name', variant.Id, model.Id);
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
		testDrive.Account__c = customerAcc.Id; 
        testDrive.Prospect__c = testCon.Id; //PA MIGRATION: To Remove
        testDrive.Date__c = Date.today().addDays(-1);
        testDrive.Status__c = 'Pending';
		testDrive.Model__c = vehicleMaster.Id;
        insert testDrive;
        
        Test.startTest();
        System.schedule('Rebook_Test_Drive02', '20 30 8 10 2 ? *', new BatchSendTestDriveNoShowEmail());
        Test.stopTest();
    }
    
    @isTest
    static void testSendTestDriveNoShowEmailWithProspectAccount(){        
        Account prospectAcc = Test_DataFactory.createPerson(true, 'Test', 'Prospect');
        //Lead testLead = Test_DataFactory.createLead(true, 'C&C', 'lName'); //PA MIGRATION: To Remove
        
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'oppName', prospectAcc.Id);
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCK');
        Vehicle_Master__c vehicleMaster = Test_DataFactory.createVehicleMaster(true, 'name', variant.Id, model.Id);
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
		testDrive.Account__c = prospectAcc.Id;
        //testDrive.Lead__c = testLead.Id; //PA MIGRATION: To Remove        
        testDrive.Date__c = Date.today().addDays(-1);
        testDrive.Status__c = 'Pending';
		testDrive.Model__c = vehicleMaster.Id;
        insert testDrive;
        
        Test.startTest();
        System.schedule('Rebook_Test_Drive02', '20 30 8 10 2 ? *', new BatchSendTestDriveNoShowEmail());
        Test.stopTest();
    }
}