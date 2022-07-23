@isTest
private class InvoiceEmail_RV_VIN_Test 
{
    @isTest
    static void testInvoiceEmail_RV_VIN()
    {
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = '';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'Test Name', 'CCK', 'KIAPC', '74L1555', testCon.Id);

        InvoiceEmail_RV_VIN controller = new InvoiceEmail_RV_VIN();
        controller.rv_id = regVehicle.Registration_Number__c;
        controller.VIN_Val = '';
        
        String chasicNo = controller.VIN_Val;
    }
}