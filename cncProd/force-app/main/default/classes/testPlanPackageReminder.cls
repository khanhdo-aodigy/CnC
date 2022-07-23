@IsTest
global  with sharing class testPlanPackageReminder {
    @testSetup
    global static void createData(){
        Date nextThreeMonth = Date.today().addMonths(3);
        Account acct = Test_DataFactory.createAccount(true, 'nameA');
        
        Account pAcc = Test_DataFactory.createPerson(true, UserInfo.getLastName(), 'PersonAccount');	 /** PA Migration : Newly Added */
        
        Contact paCon = Test_DataFactory.createContact(false, '',  UserInfo.getLastName(), acct.Id);
        //paCon.Account__c = pAcc.Id;	
        paCon.NRIC_Passport_No__c = pAcc.Id;
        paCon.Email = '';
        insert paCon;
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false, 'SEBE', 'CCK', 'KIAPC', 'SEBE', paCon.Id);
        rv.Account__c = pAcc.Id;
        rv.Contact__c = paCon.Id;
        insert rv;
        Service_Packages__c sp = new Service_Packages__c();
        sp.Registered_Vehicle__c = rv.Id;
        sp.Status__c = 'Active';
        insert sp;
        
        
    }
    //Positive Test Scenario
    @isTest global static void testPositiveSP3Month(){
        Date nextThreeMonth = Date.today().addMonths(3);
        Service_Packages__c sp = [Select ITEM_EXPIRY_DATE__c From Service_Packages__c LIMIT 1];
        sp.ITEM_EXPIRY_DATE__c = nextThreeMonth;
        update sp;
        String str = system.now().addSeconds(20).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testPlanPackageReminder',str, new planPackageReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
    
    //Positive Test Scenario
    @isTest global static void testPositiveSP1Month(){
        Date nextOneMonth   = Date.today().addMonths(1);
        Service_Packages__c sp = [Select ITEM_EXPIRY_DATE__c From Service_Packages__c LIMIT 1];
        sp.ITEM_EXPIRY_DATE__c = nextOneMonth;
        update sp;
        String str = system.now().addSeconds(20).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testPlanPackageReminder',str, new planPackageReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
    
    //Positive Test Scenario
    @isTest global static void testPositiveSP6Month(){
        Date nextSixMonth   = Date.today().addMonths(6);
        Service_Packages__c sp = [Select ITEM_EXPIRY_DATE__c From Service_Packages__c LIMIT 1];
        sp.ITEM_EXPIRY_DATE__c = nextSixMonth;
        update sp;
        String str = system.now().addSeconds(20).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        String jobId = System.schedule('testPlanPackageReminder',str, new planPackageReminder() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
    
}