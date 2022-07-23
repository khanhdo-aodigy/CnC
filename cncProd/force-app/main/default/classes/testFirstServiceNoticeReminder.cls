@IsTest
global  with sharing class testFirstServiceNoticeReminder 
{
    @testSetup
    global static void createData(){
        Account acc = Test_DataFactory.createPerson(true, UserInfo.getLastName(), 'Customer');
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAccount000');
        Contact cn = Test_DataFactory.createContact(false, '',  UserInfo.getLastName(), jccAcct.Id);
        cn.Account__c = acc.Id;
        insert cn;


        List<Registered_Vehicle__c> lstRVs = new List<Registered_Vehicle__c>();
        Date passedThreeDays  = Date.today().addDays(-3);
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false, 'SEBE1', 'CCK', 'KIAPC', 'SEBE1', cn.Id);
        rv.Registration_Number__c = '12343';
        rv.Registered_Date__c = passedThreeDays;
        rv.Next_Service_Booking_Date__c = Date.today().addDays(14);
        rv.Account__c = acc.Id;
        rv.Last_Service_Booking_Date__c = null;
        lstRVs.add( rv );
        
        Registered_Vehicle__c rv1 = Test_DataFactory.createregVehicle(false, 'SEBE2', 'CCK', 'KIAPC', 'SEBE2', cn.Id);
        rv1.Registration_Number__c = '123433';
        rv1.Next_Service_Booking_Date__c = Date.today().addDays(7);
        rv1.Account__c = acc.Id;
        rv1.Last_Service_Booking_Date__c = null;
        lstRVs.add( rv1 );
        
        Registered_Vehicle__c rv2 = Test_DataFactory.createregVehicle(false, 'TESTRV', 'CCK', 'KIAPC', 'TESTRV', cn.Id);
        rv2.Registration_Number__c = 'TESTRV';
        rv2.Registered_Date__c = passedThreeDays;
        rv2.Next_Service_Booking_Date__c = Date.today().addDays(7);
        rv2.Account__c = acc.Id;
        rv2.Last_Service_Booking_Date__c = null;
        lstRVs.add( rv2 );

        Registered_Vehicle__c rv3 = Test_DataFactory.createregVehicle(false, 'TESTRV', 'CCK', 'KIAPC', 'TESTRV', cn.Id);
        rv3.Registration_Number__c = 'TESTRV';
        rv3.Registered_Date__c = passedThreeDays;
        rv3.Next_Service_Booking_Date__c = Date.today().addDays(14);
        rv3.Account__c = acc.Id;
        rv3.Last_Service_Booking_Date__c = null;
        lstRVs.add( rv3 );

        if( !lstRVs.isEmpty() ){
          insert lstRVs;
        }

        Service_Appointment__c sc = new Service_Appointment__c();
        sc.Registered_Vehicle__c = rv.Id;
        sc.Service_Appointment_Date_Time__c = Date.today().addDays(1);
        sc.Service_Code__c = 'Full Maintenance Service';
        sc.Account__c = acc.Id;
        sc.Contact__c = cn.Id;
        sc.Booking_ID__c = 'RVBOOKINGIDTEST1';
        sc.Action__c = 'Create';
        insert sc;

        Service_Appointment__c sc2 = new Service_Appointment__c();
        DateTime nextTMR = Date.today().addDays(1);
        sc2.Registered_Vehicle__c = rv1.Id;
        sc2.Service_Appointment_Date_Time__c = nextTMR;
        sc2.Service_Code__c = 'Full Maintenance Service';
        sc2.Account__c = acc.Id;
        sc2.Contact__c = cn.Id;
        sc2.Booking_ID__c = 'RV1BOOKINGIDTEST2';
        sc2.Action__c = 'Create';
        insert sc2;

        
        
    }
    //Positive Test Scenario
    @isTest global static void testPositive(){
        String str = system.now().addSeconds(20).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testFirstServiceNoticeReminder',str, new firstServiceNoticeReminder() );
        //CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        //System.assertEquals(str, ctx.CronExpression);
        //System.assertEquals(0, ctx.TimesTriggered);
        
        //firstServiceNoticeReminder.firstServiceNoticeNReminderTEST();
        //firstServiceNoticeReminder.firstServiceSecondReminderTEST();
        Test.stopTest();
        
        
    }
    
}