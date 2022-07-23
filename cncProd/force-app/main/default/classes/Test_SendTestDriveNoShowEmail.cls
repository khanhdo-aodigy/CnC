@isTest
private class Test_SendTestDriveNoShowEmail {
    @isTest
    private static void testScheduleExecute(){
        Test.startTest();
        System.schedule('SendTestDriveNoShowEmail', '20 30 8 10 2 ? *', new SendTestDriveNoShowEmail());
        Test.stopTest();
    }

    @isTest
    private static void testSendEmailAccount()
    {
        Account customerAcc = Test_DataFactory.createPerson(true, 'Test', 'Customer');
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'oppName', customerAcc.Id);
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCK');
        Vehicle_Master__c vehicleMaster = Test_DataFactory.createVehicleMaster(true, 'name', variant.Id, model.Id);
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
		testDrive.Account__c = customerAcc.Id; 
        testDrive.Date__c = Date.today().addDays(-1);
        testDrive.Status__c = 'Pending';
		testDrive.Model__c = vehicleMaster.Id;
        insert testDrive;
        
        SendTestDriveNoShowEmail.sendTestDriveNoShowEmail();
    }
    
    @isTest
    private static void testSendEmailContact()
    {
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAccount222');
        Account customerAcc = Test_DataFactory.createPerson(true, 'Test', 'Customer');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', jccAcct.Id); //PA MIGRATION: To Remove
        testCon.Account__c = jccAcct.Id;
                
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'oppName', jccAcct.Id);
        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCK');
        Vehicle_Master__c vehicleMaster = Test_DataFactory.createVehicleMaster(true, 'name', variant.Id, model.Id);
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
        testDrive.Prospect__c = testCon.Id; //PA MIGRATION: To Remove
        testDrive.Date__c = Date.today().addDays(-1);
        testDrive.Status__c = 'Pending';
		testDrive.Model__c = vehicleMaster.Id;
        insert testDrive;
        
        SendTestDriveNoShowEmail.sendTestDriveNoShowEmail();
    }
    
}