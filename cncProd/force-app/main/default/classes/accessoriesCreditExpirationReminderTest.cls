@isTest
private class accessoriesCreditExpirationReminderTest 
{
    @isTest
    private static void testCreditExpireInSixMonths()
    {
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = 'test123@gmail.com';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];

        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);

        ID vrecordTypeID = Schema.SObjectType.Vehicle_Credit__c.getRecordTypeInfosByDeveloperName().get('Accessories_Credit').getRecordTypeId();
        Vehicle_Credit__c vehCredit = new Vehicle_Credit__c (Type__c = 'Accessories', 
                                                            Expiry_Date__c = Date.today().addMonths(6),
                                                            RecordTypeId = vrecordTypeID,
                                                            Status__c = 'Active',
                                                            Credit_Balance__c = 100,
                                                            Registered_Vehicle__c = regVehicle.Id);
        insert vehCredit;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
          TriggerExclusion.excludeTrigger('CustomerAlerts__c',true);
        String jobId = System.schedule('accessoriesCreditExpirationReminderTest',str, new accessoriesCreditExpirationReminder());
          TriggerExclusion.excludeTrigger('CustomerAlerts__c',false);
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testCreditExpireInThreeMonths()
    {
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = 'test456@gmail.com';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);

        ID vrecordTypeID = Schema.SObjectType.Vehicle_Credit__c.getRecordTypeInfosByDeveloperName().get('Accessories_Credit').getRecordTypeId();
        Vehicle_Credit__c vehCredit = new Vehicle_Credit__c (Type__c = 'Accessories', 
                                                            Expiry_Date__c = Date.today().addMonths(3),
                                                            RecordTypeId = vrecordTypeID,
                                                            Status__c = 'Active',
                                                            Credit_Balance__c = 100,
                                                            Registered_Vehicle__c = regVehicle.Id);
        insert vehCredit;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('accessoriesCreditExpirationReminderTest',str, new accessoriesCreditExpirationReminder());
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testCreditExpireInNextMonth()
    {
        Account testAcc = Test_DataFactory.createPerson(false, 'Test', 'Customer');
        testAcc.PersonEmail = 'test3857@hotmail.com';
		insert testAcc;
        
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :testAcc.Id LIMIT 1];
        Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :personAcc.PersonContactId LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);

        ID vrecordTypeID = Schema.SObjectType.Vehicle_Credit__c.getRecordTypeInfosByDeveloperName().get('Accessories_Credit').getRecordTypeId();
        Vehicle_Credit__c vehCredit = new Vehicle_Credit__c (Type__c = 'Accessories', 
                                                            Expiry_Date__c = Date.today().addMonths(1),
                                                            RecordTypeId = vrecordTypeID,
                                                            Status__c = 'Active',
                                                            Credit_Balance__c = 100,
                                                            Registered_Vehicle__c = regVehicle.Id);
        insert vehCredit;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('accessoriesCreditExpirationReminderTest',str, new accessoriesCreditExpirationReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
}