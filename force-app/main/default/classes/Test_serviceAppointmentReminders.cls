@isTest
private class Test_serviceAppointmentReminders{
    @testSetup
    static void makeData()
	{

		Contact c = new Contact();
		c.Email = '123@123.com';
		c.LastName = 'Lee';
		insert c;

        String testEmail = 'test@fakedomain.com';
 		//PA MIGRATION: Newly Added
 		Account personAcc = Test_DataFactory.createPerson(false, 'Dummy', 'Prospect');
        personAcc.PersonEmail = testEmail;
        insert personAcc;

		Service_Appointment__c sa1 = new Service_Appointment__c();
		sa1.Is_Non_Owner__c = false;
		sa1.Service_Appointment_Date_Time__c = Date.today() + 3;
		sa1.Action__c = 'Create';
		sa1.Car_Registration_No__c = 'ABC';
		sa1.Booking_ID__c = '12345';
		insert sa1;
		
        Service_Appointment__c sa2 = new Service_Appointment__c();
		sa2.Is_Non_Owner__c = true;
		sa2.Service_Appointment_Date_Time__c = Date.today() + 3;
		sa2.Action__c = 'Create';
		sa2.Car_Registration_No__c= 'ABCDF';
		sa2.Booking_ID__c = '87654';
		sa2.Non_Owner_Email__c = 'othermail@fakedomain.fake';
		sa2.Contact__c = c.Id;
        sa2.Account__c = personAcc.Id;
		insert sa2;
        
		Service_Appointment__c sa3 = new Service_Appointment__c();
		sa3.Is_Non_Owner__c = true;
		sa3.Service_Appointment_Date_Time__c = Date.today() + 3;
		sa3.Action__c = 'Create';
		sa3.Car_Registration_No__c= 'ABCDF';
		sa3.Booking_ID__c = '1234537';
		sa3.Non_Owner_Email__c = testEmail;
		sa3.Contact__c = c.Id;
        sa3.Account__c = personAcc.Id;
		insert sa3;
	}

	@isTest
	static void testPositive()
	{
		Test.startTest();
		ServiceAppointmentReminders.ServiceAppointmentReminder();
		ServiceAppointmentReminders.ServiceAppointmentReminderTEST();
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');

        String jobId = System.schedule('Test_serviceAppointmentReminders',str, new ServiceAppointmentReminders() );
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
		
		Test.stopTest();
	}

}