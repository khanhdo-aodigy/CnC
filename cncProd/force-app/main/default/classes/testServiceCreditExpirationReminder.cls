@isTest
private class testServiceCreditExpirationReminder {
    @isTest
    private static void testCreditExpireInSixMonths(){
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = 'test123@gmail.com';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];

        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);
		regVehicle.Service_Credits_Expiry_Date__c = Date.today().addMonths(6);
        regVehicle.Service_Credits__c = '10000';
        insert regVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testServiceCreditExpirationReminder',str, new serviceCreditExpirationReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testCreditExpireInThreeMonths(){
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = 'pa4924@hotmail.com';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);
		regVehicle.Service_Credits_Expiry_Date__c = Date.today().addMonths(3);
        regVehicle.Service_Credits__c = '10000';
        insert regVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testServiceCreditExpirationReminder',str, new serviceCreditExpirationReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testCreditExpireInNextMonth(){
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = 'testpa9428@gmail.com';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);
		regVehicle.Service_Credits_Expiry_Date__c = Date.today().addMonths(1);
        regVehicle.Service_Credits__c = '10000';
        insert regVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testServiceCreditExpirationReminder',str, new serviceCreditExpirationReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
}