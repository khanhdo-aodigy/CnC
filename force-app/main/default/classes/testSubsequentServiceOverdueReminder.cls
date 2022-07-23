@isTest
private class testSubsequentServiceOverdueReminder {
    @testSetup
    private static void setup(){        
        Account testAcc = Test_DataFactory.createPA(true, 'Test', 'email@test.com', 'Customer');
        testAcc = [Select Id, PersonContactId From Account LIMIT 1];
        
        Registered_Vehicle__c serRegVehicle = Test_DataFactory.createregVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', testAcc.PersonContactId);
        serRegVehicle.Last_Service_Booking_Date__c = null;
        insert serRegVehicle;
        
        Service_Appointment__c serApp = new Service_Appointment__c(Name = 'SREVT1');
        serApp.Service_Appointment_Date_Time__c = Date.today().addDays(7);
        serApp.Contact__c = testAcc.PersonContactId;
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
        Account testAcc = [Select Id, PersonContactId From Account LIMIT 1];

        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test', 'CCI', 'MBP', '74L1666', testAcc.PersonContactId);
        dummyRegVehicle.Last_Service_Booking_Date__c = Date.today();
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-1);
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testSubsequentServiceOverdueReminder',str, new subsequentServiceOverdueReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
    
    @isTest
    private static void testBookingDateWasLast30Days(){   
        Account testAcc = [Select Id, PersonContactId From Account LIMIT 1];
        
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test', 'CCK', 'KIAPC', '74L1666', testAcc.PersonContactId);
        dummyRegVehicle.Last_Service_Booking_Date__c = Date.today();
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-30);
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testSubsequentServiceOverdueReminder',str, new subsequentServiceOverdueReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
    
    @isTest
    private static void testBookingDateWasLast10Days(){   
        Account testAcc = [Select Id, PersonContactId From Account LIMIT 1];
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test', 'CCI', 'MBP', '74L1666', testAcc.PersonContactId);
        dummyRegVehicle.Last_Service_Booking_Date__c = Date.today();
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-10);
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testSubsequentServiceOverdueReminder',str, new subsequentServiceOverdueReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }

    @isTest
    private static void testBookingDateWasLast120Days(){   
        Account testAcc = [Select Id, PersonContactId From Account LIMIT 1];
        Registered_Vehicle__c dummyRegVehicle = Test_DataFactory.createregVehicle(false, 'Test', 'CCK', 'KIAPC', '74L1666', testAcc.PersonContactId);
        dummyRegVehicle.Last_Service_Booking_Date__c = Date.today();
        dummyRegVehicle.Next_Service_Booking_Date__c = Date.today().addDays(-120);
        insert dummyRegVehicle;
        
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testSubsequentServiceOverdueReminder',str, new subsequentServiceOverdueReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
}