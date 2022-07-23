/*******************************************************
 * Class Name: CustomerServiceReportSchedulerTest
 * Description: Test class for CustomerServiceReportScheduler
 *******************************************************/ 
@isTest
private class CustomerServiceReportSchedulerTest {
    
    @testSetUp
    static void createTestData(){
        Test.startTest();
        //Create Account
        Account jccAcct = Test_DataFactory.createAccount(true, 'jccTestAccount555');
        //added by HH to update PA
        Account acc = Test_DataFactory.createPerson(true, UserInfo.getName(), 'Customer');
        //Create contact
        Contact con = Test_DataFactory.createContact(false, UserInfo.getFirstName(), UserInfo.getLastName(), jccAcct.Id);
        con.Account__c = acc.Id;
        insert con;
        //Create Registered Vehicle
        Registered_Vehicle__c rev = Test_DataFactory.createregVehicle(true, 'SKTEST01', 'CCK', 'KIAPC', 'SKTEST01', con.Id);
        rev.Account__c = acc.Id;
        update rev;
        //Create Customer Alert
        CustomerAlerts__c csAlert = new CustomerAlerts__c(Name='Subsequent Service Due 2nd Reminder', 
                                                          Contact__c=con.Id, 
                                                          //added by HH to update PA
                                                          Account__c = acc.Id,
                                                          Status__c='unread',
                                                          Type__c='Subsequent Service',
                                                          SubType__c='Due 2nd Reminder');
        insert csAlert;
        
        //Create Service Appointment
        List<Service_Appointment__c> srev = new List<Service_Appointment__c>{
            new Service_Appointment__c(Name='SREVT1', 
                                       Contact__c=con.Id, 
                                       Registered_Vehicle__c=rev.Id,
                                       //added by HH to update PA
                                       Account__c = acc.Id,
                                       Branch__c='CCK',
                                       Action__c = 'Create',
                                       Booking_ID__c = 'SREVT1') };
        insert srev;

        Test.stopTest();
    }
    
    //verify queue of Payments Scheduler 
    static testMethod void testSched(){
        Test.startTest();
        CustomerServiceReportScheduler sc = new CustomerServiceReportScheduler();
        Id sysJobId = System.schedule('TEST Sched Cust ' + UserInfo.getUserId(), '1 2 3 4 5 ?', sc);
        Test.stopTest();
        
        //Verify job is submitted
        System.assert( sysJobId != null );
    }
    
    //verify Has Serv Appt Checkbox is ticked
    static testMethod void testAppt(){
        Test.startTest();
        //get Service Appt
        /*Service_Appointment__c srev = [SELECT Id, Contact__c, Account__c
                                         FROM Service_Appointment__c 
                                         WHERE Contact__c!=null 
                                         ORDER BY CREATEDDATE DESC 
                                         LIMIT 1];*/
        //added by HH to update PA
        Service_Appointment__c srevPA = [SELECT Id, Account__c
                                         FROM Service_Appointment__c 
                                         WHERE Account__c!=null 
                                         ORDER BY CREATEDDATE DESC 
                                         LIMIT 1];
        /*if(srevPA != null ){
            CustomerServiceReportScheduler.updateCustomerAlerts( new List<Id>{ srevPA.Id } );            
        }
        else {
            CustomerServiceReportScheduler.updateCustomerAlerts( new List<Id>{ srevPA.Id } );
        }*/
        
        CustomerServiceReportScheduler.updateCustomerAlerts( new List<Id>{ srevPA.Id } );            

        Test.stopTest();
        
        //Verify the Customer Alert 'Subsequent Service Due 2nd Reminder' is tagged as Has Serv App.
        /*CustomerAlerts__c cn = [SELECT Id, HasServiceAppointment__c
                                FROM CustomerAlerts__c 
                                WHERE Contact__c =: srev.Contact__c 
                                ORDER BY CREATEDDATE DESC 
                                LIMIT 1];
        System.assertEquals(true, cn.HasServiceAppointment__c);
        */
        CustomerAlerts__c cnPA = [SELECT Id, HasServiceAppointment__c
                                FROM CustomerAlerts__c 
                                WHERE Account__c =: srevPA.Account__c 
                                ORDER BY CREATEDDATE DESC 
                                LIMIT 1];
        System.assertEquals(true, cnPA.HasServiceAppointment__c);
        
    }
}