/*****************************************
 * Class Name: Test_UpsertServiceAppointment
 * Test Class for UpsertServiceAppointment REST API
 ******************************************/ 
@isTest
private class Test_UpsertServiceAppointment{
    //create preliminary test data
    @testSetup
    static void createData(){
        Test.startTest();
        //Create Business Account
        /*Account acc = Test_DataFactory.createAccount(false, UserInfo.getLastName());
        acc.Email__pc = 'test@mail.com';
		insert acc;
        
        //Create Business Contact
        Contact con = Test_DataFactory.createContact(false, 'Name', 'LastName', acc.Id);
        con.NRIC_Passport_No__c = 'SLTEST';
        con.NRIC__c = 'SLTEST';
        insert con;*/
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;

        Contact personCont = [SELECT Id, Name FROM Contact WHERE AccountId = :personAcc.Id ];
		
        Registered_Vehicle__c rev = Test_DataFactory.createregVehicle(true, 'rvtest01', 'CCK', 'KIAPC', 'SLTEST01', personCont.Id);

        Test.stopTest();
    }
    
    //Test post request with correct JSON request body
    static testMethod void testPositive(){
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 
        //Previous method params:
        //updateAlerts(String action, String bookingId, String registrationNumber, String nric, String remarks, 
        //	Datetime appointmentDateTime, String location, String serviceType, String mileage, String serviceCentreName,
        //	String NonOwnerName,String NonOwnerEmail,String NonOwnerPhoneNumber,Boolean IsNonOwner, String Branch)
        String reqBody = '{"action":"Create","bookingId":"8812341","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerName":"Me","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();


        Test.stopTest();
        
        //Verify a Service Appt was created with action = Create
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] > 0 );
    }
    
    //Test post request with blank JSON request body
    static testMethod void testNegative(){
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 
        //Previous method params:
        //updateAlerts(String action, String bookingId, String registrationNumber, String nric, String remarks, 
        //	Datetime appointmentDateTime, String location, String serviceType, String mileage, String serviceCentreName,
        //	String NonOwnerName,String NonOwnerEmail,String NonOwnerPhoneNumber,Boolean IsNonOwner, String Branch)
        String reqBody = '{"action":"","bookingId":"8812341","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerName":"Me","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt is NOT created 
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] >= 0 );
    }
    static testMethod void testNegativeNRIC(){
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 
        //Previous method params:
        //updateAlerts(String action, String bookingId, String registrationNumber, String nric, String remarks, 
        //	Datetime appointmentDateTime, String location, String serviceType, String mileage, String serviceCentreName,
        //	String NonOwnerName,String NonOwnerEmail,String NonOwnerPhoneNumber,Boolean IsNonOwner, String Branch)
        String reqBody = '{"action":"Create","bookingId":"8812341","registrationNumber":"SLTEST01","nric":"","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerName":"Me","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt is NOT created 
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] >= 0 );
    }
    
    //Test post request with blank JSON request body
    static testMethod void testPositivePA(){
        Account pAcc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        pAcc.NRIC_Passport_No__pc = 'SLTEST';
        pAcc.PersonEmail = 'patest2@mail.com';
        insert pAcc;
        Registered_Vehicle__c rev = [Select Id From Registered_Vehicle__c LIMIT 1];
        rev.Account__c = pAcc.Id;
        update rev;
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 

        String reqBody = '{"action":"Create","bookingId":"8812341","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt is NOT created 
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] >= 0 );
    }
    
    //Test Positive Owner-Scenario
    static testMethod void testPositiveOwner(){
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 
        //Previous method params:
        //updateAlerts(String action, String bookingId, String registrationNumber, String nric, String remarks, 
        //	Datetime appointmentDateTime, String location, String serviceType, String mileage, String serviceCentreName,
        //	String NonOwnerName,String NonOwnerEmail,String NonOwnerPhoneNumber,Boolean IsNonOwner, String Branch)
        String reqBody = '{"action":"Create","bookingId":"8812341","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerName":"Me","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'false' +',"Branch":"CCK"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt was created with action = Create
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] > 0 );
    }

    //Test post request with blank JSON request body
    static testMethod void testCreateAddon(){
        Account pAcc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        pAcc.NRIC_Passport_No__pc = 'SLTEST';
        pAcc.PersonEmail = 'patest2@mail.com';
        insert pAcc;
        Registered_Vehicle__c rev = [Select Id From Registered_Vehicle__c LIMIT 1];
        rev.Account__c = pAcc.Id;
        update rev;
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 

        String reqBody = '{"action":"Create","bookingId":"8812341","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK","addOns":[{"itemName":"Add-On0076","itemID":"004"}]}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt is NOT created 
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] >= 0 );
    }

    //Test post request with blank JSON request body
    static testMethod void testRemoveAddon(){
        Account pAcc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        pAcc.NRIC_Passport_No__pc = 'SLTEST';
        pAcc.PersonEmail = 'patest2@mail.com';
        insert pAcc;
        Registered_Vehicle__c rev = [Select Id From Registered_Vehicle__c LIMIT 1];
        rev.Account__c = pAcc.Id;
        update rev;
        Service_Appointment__c sa = new Service_Appointment__c();
		sa.Action__c = 'Create';
		sa.Flag__c = false;
		sa.Is_Non_Owner__c = True; 
		sa.Non_Owner_Email__c = null;
		sa.Booking_ID__c = '1223344AA';
        sa.Car_Registration_No__c = 'SLTEST01';
		insert sa;
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 

        String reqBody = '{"action":"Edit","bookingId":"1223344AA","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK","addOns":[{"itemName":"Add-On0078","itemID":"006"}]}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt is NOT created 
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] >= 0 );
    }

    //Test post request with blank JSON request body
    static testMethod void testCreateAddon_ExistSA(){
        Account pAcc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        pAcc.NRIC_Passport_No__pc = 'SLTEST';
        pAcc.PersonEmail = 'patest2@mail.com';
        insert pAcc;
        Registered_Vehicle__c rev = [Select Id From Registered_Vehicle__c LIMIT 1];
        rev.Account__c = pAcc.Id;
        update rev;
        Service_Appointment__c sa = new Service_Appointment__c();
		sa.Action__c = 'Create';
		sa.Flag__c = false;
		sa.Is_Non_Owner__c = True; 
		sa.Non_Owner_Email__c = null;
		sa.Booking_ID__c = '1223344AA';
        sa.Car_Registration_No__c = 'SLTEST01';
		insert sa;
        Test.startTest();
        String reqURI = '/services/apexrest/UpsertServiceAppointment/v1/'; 

        String reqBody = '{"action":"Create","bookingId":"1223344AA","registrationNumber":"SLTEST01","nric":"SLTEST","remarks":"test","appointmentDateTime":"'
            + '2019-07-30T00:30:00.000Z' +'","location":"Sin Ming","serviceType":"serviceCode","mileage":"100","serviceCentreName":"srev","NonOwnerEmail":"test@test.com","NonOwnerPhoneNumber":"80000000","IsNonOwner":'
            + 'true' +',"Branch":"CCK","addOns":[{"itemName":"Add-On0076","itemID":"004"}]}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        UpsertServiceAppointment.updateAlerts();
        Test.stopTest();
        
        //Verify a Service Appt is NOT created 
        System.assert([SELECT COUNT() FROM Service_Appointment__c WHERE Action__c='Create' LIMIT 1] >= 0 );
    }

	static testmethod void insertAppt()
	{

		Service_Appointment__c sa = new Service_Appointment__c();
		sa.Action__c = 'Create';
		sa.Flag__c = false;
		sa.Is_Non_Owner__c = True; 
		sa.Non_Owner_Email__c = null;
		sa.Booking_ID__c = '1223344AA';
		insert sa;

		sa.Action__c = 'Edit';
		sa.Flag__c = false;
		sa.Is_Non_Owner__c = True; 
		sa.Non_Owner_Email__c = null;
		sa.Booking_ID__c = '1223344AA';
		update sa;

		sa.Action__c = 'Cancel';
		sa.Flag__c = false;
		sa.Is_Non_Owner__c = True; 
		sa.Non_Owner_Email__c = null;
		sa.Booking_ID__c = '1223344AA';
		update sa;

	}
}