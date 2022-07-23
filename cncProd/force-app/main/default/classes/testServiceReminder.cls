@isTest
private class testServiceReminder {
    @testSetup
    private static void setup(){
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        
        Registered_Vehicle__c serRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', testCon.Id);
        serRegVehicle.Last_Service_Booking_Date__c = null;
        insert serRegVehicle;
        
        Service_Appointment__c serApp = new Service_Appointment__c(Name = 'SREVT1');
        serApp.Service_Appointment_Date_Time__c = Date.today().addDays(7);
        serApp.Contact__c = testCon.Id;
		serApp.Registered_Vehicle__c = serRegVehicle.Id;        
        serApp.Account__c = testAcc.Id;                               
        serApp.Branch__c = 'CCK';                               
        serApp.Action__c = 'Create';                              
        serApp.Booking_ID__c = 'SREVT1';
        serApp.Service_Code__c = 'Maintenance Service';
        insert serApp;
    }
    
    @isTest
    private static void testBookingDateWasYesterday(){
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        List<Registered_Vehicle__c> overdueRegVehs = new List<Registered_Vehicle__c>();
        
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCI', 'MBP', '74L1666', testCon.Id);
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-1);
        dummyRegVehicle.Last_Service_Booking_Date__c = null;
        overdueRegVehs.add(dummyRegVehicle);
        
        Registered_Vehicle__c dummyRegVehicle1 = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCK', 'KIAPC', '74L1667', testCon.Id);
        dummyRegVehicle1.Next_Service_Booking_Date__c = Date.today().addDays(-1);
        dummyRegVehicle1.Last_Service_Booking_Date__c = null;
        overdueRegVehs.add(dummyRegVehicle1);
        
        insert overdueRegVehs;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();        
        String jobId = System.schedule('TestServiceReminder',str, new serviceReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testBookingDateWas10DaysBefore(){
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCI', 'MBP', '74L1666', testCon.Id);
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-10);
        dummyRegVehicle.Last_Service_Booking_Date__c = null;
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();        
        String jobId = System.schedule('TestServiceReminder',str, new serviceReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testBookingDateWas30DaysBefore(){
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCK', 'KIAPC', '74L1666', testCon.Id);
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-30);
        dummyRegVehicle.Last_Service_Booking_Date__c = null;
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();        
        String jobId = System.schedule('TestServiceReminder',str, new serviceReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testBookingDateWas60DaysBefore(){
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCF', 'CITPC', '74L1666', testCon.Id);
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-60);
        dummyRegVehicle.Last_Service_Booking_Date__c = null;
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();        
        String jobId = System.schedule('TestServiceReminder',str, new serviceReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
    @isTest
    private static void testLastBookingDateNotNull(){
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);        
        List<Registered_Vehicle__c> overdueRegVehs = new List<Registered_Vehicle__c>();
        
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCI', 'MBP', '74L1666', testCon.Id);
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(7);
        dummyRegVehicle.Last_Service_Booking_Date__c = Date.today();
        overdueRegVehs.add(dummyRegVehicle);
        
        Registered_Vehicle__c dummyRegVehicle1 = Test_DataFactory.createregVehicle(false, 'Test Name1', 'CCK', 'KIAPC', '74L1667', testCon.Id);
        dummyRegVehicle1.Next_Service_Booking_Date__c = Date.today().addDays(14);
        dummyRegVehicle1.Last_Service_Booking_Date__c = Date.today();
        overdueRegVehs.add(dummyRegVehicle1);
        
        insert overdueRegVehs;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();        
        String jobId = System.schedule('TestServiceReminder',str, new serviceReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
    
	@isTest
    private static void testServiceReminder(){
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        
        String jobId = System.schedule('TestServiceReminder',str, new serviceReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
	}
}