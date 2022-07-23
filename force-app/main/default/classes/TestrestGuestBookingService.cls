@IsTest
public class TestrestGuestBookingService {
    
    @testSetUp
    static void createData(){  
        test.StartTest();
        Account acc = Test_DataFactory.createAccount(True,'TestAccountxx');
        Contact con = Test_DataFactory.createContact(True,'testxxx','test2',acc.id);
        con.NRIC_Passport_No__c = 'S12315031993';  
        con.mobilePhone = String.valueOf('6584636');
        con.Source__c = 'DWH';
        update con;     
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(True,'TestVehicle','CCA','MITPC','Reg1234',con.id); 
        test.StopTest();
        
    }
    public static testmethod void testGuestBooking_NoVehicle() {       
        String JSONMsg = '{"VehicleNumber" : "13245","MobileNumber":"12340000"}';        
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest();     
    }
    
    public static testmethod void testGuestBooking_withVehicle() {      
        String JSONMsg = '{"VehicleNumber" : "Reg1234","MobileNumber":"84636"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest(); 
    }
    
    public static testmethod void testGuestBooking_NoPhone() {       
        Contact con = [select id,NRIC_Passport_No__c from contact where NRIC_Passport_No__c ='S12315031993'];
        con.mobilephone = '';
        update con;
        String JSONMsg = '{"VehicleNumber" : "Reg1234","MobileNumber":"23545"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest();  
    }
    
    public static testmethod void testGuestBooking_WrongPhone() {
        
        String JSONMsg = '{"VehicleNumber" : "Reg1234","MobileNumber":"452352"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest();     
    }
    
    public static testmethod void testGuestBooking_NoInput() {            
        String JSONMsg = '{"VehicleNumber" : "","MobileNumber":""}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest();     
    }
    
    public static testmethod void testGuestBooking_DupeVehicle() {       
        id conId = [select id from contact where NRIC_Passport_No__c ='S12315031993'].id;
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(True,'TestVehicle','CCA','MITPC','Reg1234',conId); 
        String JSONMsg = '{"VehicleNumber" : "Reg1234","MobileNumber":"34234"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest();
    }
    
    @isTest
    private static void testGuestBooking_NoReq() {       
        String JSONMsg = '';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest();  
    }
    
    @isTest
    private static void testGuestBooking_PAMatchingPhoneNumber() {  
        String regNum = 'Unique1';
        String mobilePhone = '864567';
        Account personAcc = Test_DataFactory.createPerson(false, 'Testname', 'Customer');
        personAcc.PersonEmail = 'test@gmail.com';
        personAcc.NRIC_Passport_No__pc = '12345432';
        personAcc.PersonMobilePhone = '65' + mobilePhone;
        personAcc.Source__pc = 'DWH';
        insert personAcc;
        
        personAcc = [Select Id, PersonContactId From Account Where PersonEmail = 'test@gmail.com' LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(false,'TestVehicle','CCA','MITPC',regNum,personAcc.PersonContactId);
        regVehicle.Account__c = personAcc.Id;
        insert regVehicle;
        
        String JSONMsg = '{"VehicleNumber" : "' + regNum + '","MobileNumber":"' + mobilePhone + '"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest(); 
    }
    
    @isTest
    private static void testGuestBooking_PAPhoneNumberNotMatchInput() {  
        String regNum = 'Unique1';
        String mobilePhone = '864567';
        Account personAcc = Test_DataFactory.createPerson(false, 'Testname', 'Customer');
        personAcc.PersonEmail = 'test@gmail.com';
        personAcc.NRIC_Passport_No__pc = '12345432';
        personAcc.PersonMobilePhone = mobilePhone;
        personAcc.Source__pc = 'DWH';
        insert personAcc;
        
        personAcc = [Select Id, PersonContactId From Account Where PersonEmail = 'test@gmail.com' LIMIT 1];
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(false,'TestVehicle','CCA','MITPC',regNum,personAcc.PersonContactId);
        regVehicle.Account__c = personAcc.Id;
        insert regVehicle;
        
        String JSONMsg = '{"VehicleNumber" : "' + regNum + '","MobileNumber":"' + mobilePhone + '"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest(); 
    }
    
    @isTest
    private static void testGuestBooking_PAHasNoPhoneNumber() {  
        String regNum = 'Unique1';
        String mobilePhone = '864567';
        Account personAcc = Test_DataFactory.createPerson(false, 'Testname', 'Customer');
        personAcc.PersonEmail = 'test@gmail.com';
        personAcc.NRIC_Passport_No__pc = '12345432';
        personAcc.PersonMobilePhone = '';
        personAcc.Source__pc = 'DWH';
        insert personAcc;
        personAcc = [Select PersonContactId From Account Where PersonEmail = 'test@gmail.com' LIMIT 1];
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAccount111');
        Contact cnt = Test_DataFactory.createContact(false, 'fname', 'lname', jccAcct.Id);
        cnt.Account__c = jccAcct.Id;
        insert cnt;

        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(false,'TestVehicle','CCA','MITPC',regNum,cnt.Id);
        regVehicle.Account__c = personAcc.Id;
        insert regVehicle;
        
        String JSONMsg = '{"VehicleNumber" : "' + regNum + '","MobileNumber":"' + mobilePhone + '"}';
        Test_DataFactory.createReq('GuestBookingService/v1',JSONMsg);
        Test.startTest();
        restGuestBookingService.validateGuestBooking();  
        Test.StopTest(); 
    }
}