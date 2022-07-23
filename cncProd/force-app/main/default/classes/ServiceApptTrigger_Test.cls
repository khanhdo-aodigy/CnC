@isTest
public class ServiceApptTrigger_Test {
    @isTest
    public static void testTrigger(){
        Account acc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        acc.PersonMobilePhone = '84123498';
        acc.Device__pc = '123AVD';
        insert acc;
        
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAcount080');

        Contact con = Test_DataFactory.createContact(false, UserInfo.getFirstName(), UserInfo.getLastName(), jccAcct.Id);
        con.MobilePhone = '84123498';
        con.Email = null;
        con.Device__c = '123AVD';
        insert con;
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(true, 'SEBE', 'CCK', 'KIAPC', 'SEBE', con.Id);
              
        Service_Appointment__c sc = new Service_Appointment__c();
        DateTime nextTMR = Date.today().addDays(1);
        sc.Service_Appointment_Date_Time__c = nextTMR;
        sc.Car_Registration_No__c = '12345A';
        sc.Service_Centre_Name__c = 'TestCentre';
        sc.Service_Centre_Location__c = '123 Road, Singapore ';
        sc.Account__c = acc.Id;
        sc.Contact__c = con.Id;
        sc.Booking_ID__c = con.Id;
        sc.Registered_Vehicle__c = rv.Id;
        sc.Action__c = 'Create';
        sc.Is_Non_Owner__c = true;
        sc.Non_Owner_Email__c = null;
        sc.Non_Owner_Phone_Number__c = '84123122';

        sc.Brand__c = 'CCK';
        sc.Customer_Remarks__c = 'Customer_Remarks__c'; 
        sc.Service_Code__c = '123asdasdasd';
        sc.Mileage__c = 'Mileage__c';
        sc.Flag__c = false;
        insert sc;
        
        sc.Action__c = 'Edit';
        sc.Non_Owner_Email__c = 'test@test.com';
        update sc;
        
        sc.Action__c = 'Cancel';
        sc.Non_Owner_Email__c = 'test@test.com';
        
        update sc;
    }
    
    @isTest
    public static void testTrigger1(){
        Account acc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        acc.PersonMobilePhone = '84123498';
        acc.Device__pc = '123AVD';
        insert acc;

        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAcount070');
        
        Contact con = Test_DataFactory.createContact(false, UserInfo.getFirstName(), UserInfo.getLastName(), jccAcct.Id);
        con.MobilePhone = '84123498';
        con.Email = 'test@test.com';
        con.Device__c = '123AVD';
        insert con;
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(true, 'SEBE', 'CCK', 'KIAPC', 'SEBE', con.Id);
              
        Service_Appointment__c sc = new Service_Appointment__c();
        DateTime nextTMR = Date.today().addDays(1);
        sc.Service_Appointment_Date_Time__c = nextTMR;
        sc.Car_Registration_No__c = '12345A';
        sc.Service_Centre_Name__c = 'TestCentre';
        sc.Service_Centre_Location__c = 'Road,Singapore ';
        //sc.Account__c = acc.Id;
        sc.Contact__c = con.Id;
        sc.Booking_ID__c = con.Id;
        sc.Registered_Vehicle__c = rv.Id;
        sc.Action__c = 'Create';
        sc.Is_Non_Owner__c = false;
        sc.Non_Owner_Email__c = null;
        sc.Non_Owner_Phone_Number__c = '84123465';
        sc.Brand__c = 'CCI';
        sc.Customer_Remarks__c = 'Customer_Remarks__c'; 
        sc.Service_Code__c = '123asdasdasd';
        sc.Mileage__c = 'Mileage__c';
        sc.Flag__c = false;
        insert sc;
 
        sc.Is_Non_Owner__c = true;
        sc.Action__c = 'Edit';
        sc.Non_Owner_Email__c = 'test456@test.com';
        update sc;
        
        sc.Action__c = 'Cancel';
        sc.Is_Non_Owner__c = true;
        sc.Non_Owner_Email__c = 'test456@test.com';
        update sc;
        
        
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Service_Appointment__c', true);
        Account acc = Test_DataFactory.createPerson(false, UserInfo.getName(), 'Customer');
        acc.PersonMobilePhone = '84123498';
        acc.Device__pc = '123AVD';
        insert acc;
        
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAcount080');

        Contact con = Test_DataFactory.createContact(false, UserInfo.getFirstName(), UserInfo.getLastName(), jccAcct.Id);
        con.MobilePhone = '84123498';
        con.Email = null;
        con.Device__c = '123AVD';
        insert con;
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(true, 'SEBE', 'CCK', 'KIAPC', 'SEBE', con.Id);
              
        Service_Appointment__c sc = new Service_Appointment__c();
        DateTime nextTMR = Date.today().addDays(1);
        sc.Service_Appointment_Date_Time__c = nextTMR;
        sc.Car_Registration_No__c = '12345A';
        sc.Service_Centre_Name__c = 'TestCentre';
        sc.Service_Centre_Location__c = '123 Road, Singapore ';
        sc.Account__c = acc.Id;
        sc.Contact__c = con.Id;
        sc.Booking_ID__c = con.Id;
        sc.Registered_Vehicle__c = rv.Id;
        sc.Action__c = 'Create';
        sc.Is_Non_Owner__c = true;
        sc.Non_Owner_Email__c = null;
        sc.Non_Owner_Phone_Number__c = '84123122';

        sc.Brand__c = 'CCK';
        sc.Customer_Remarks__c = 'Customer_Remarks__c'; 
        sc.Service_Code__c = '123asdasdasd';
        sc.Mileage__c = 'Mileage__c';
        sc.Flag__c = false;
        insert sc;
        TriggerExclusion.excludeTrigger('Service_Appointment__c', false);
    }
}