/** *****
 * Description : Test Class for updateAlternateEmailAddress.cls
 * 
 * Change History
 * Date(YYYYMMDD)       Name                        Description
 * 20180803             Cycle & Carriage            Created Initial Version. 
 * 20200505             HS                          PA Migration Phase 2 : Remove Contact Reference from the code
 *  
** *****/
@isTest
public class Test_UpdateAlternateEmailAddress
{
    @testSetup
    static void createData(){

        Account paCust = Test_DataFactory.createPerson(false,'TestPACustAccount', 'Customer');
        paCust.PersonMobilePhone = '84123498';
        insert paCust;

        Model__c testModel = Test_DataFactory.createmodelId(true,'TESTMODEL','CCK','KIAPC');
        Variant__c testVariant  = Test_DataFactory.createVariant(false,'TESTVARIANT', testModel.Id, 'CCK');
        testVariant.Branch__c         = 'CCK';
        testVariant.Franchise__c      = 'KIAPC';
        testVariant.DWH_Variant_ID__c = 'CCK,CITCV,TESTVARIANT';
        insert testVariant;

        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false, 'SEBE', 'CCK', 'KIAPC', 'SEBE', null);
        rv.Account__c = paCust.Id;
        rv.Variant__c = testVariant.Id;
        insert rv;
        
        Service_Appointment__c sc = new Service_Appointment__c();
        sc.Service_Appointment_Date_Time__c = Date.today().addDays(1);
        sc.Car_Registration_No__c       = '12345A';
        sc.Service_Centre_Name__c       = 'TestCentre';
        sc.Service_Centre_Location__c   = 'Singapore';
        sc.Non_Owner_Phone_Number__c    = '84123498';
        sc.Account__c                   = paCust.Id;
        sc.Booking_ID__c                = '320174';
        sc.Action__c                    = 'Create';
        sc.Is_Non_Owner__c              = true;
        sc.Service_Code__c              = '32017ABS';
        sc.Mileage__c                   = 'Mileage';
        sc.Registered_Vehicle__c        = rv.Id;
        sc.Customer_Remarks__c          = 'Custom remark';
        insert sc; 
    }

    
    static testMethod void testPositive()
    {
        String bookingID = '320174';
        String emailAddress = 'test@deploy.com';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();
        System.assert(response.statusCode == 200);  
    }


    static testMethod void testPositive1()
    {
        Service_Appointment__c sc = [SELECT Booking_ID__c, Action__c FROM Service_Appointment__c LIMIT 1];
        sc.Action__c = 'Edit';
        update sc;

        String bookingID = '320174';
        String emailAddress = 'test@deploy.com';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();   
        System.assert(response.statusCode == 200);  
    }


    static testMethod void testPositive2()
    {
        Service_Appointment__c sc = [SELECT Booking_ID__c, Action__c FROM Service_Appointment__c LIMIT 1];
        sc.Action__c = 'Cancel';
        update sc;

        String bookingID = '320174';
        String emailAddress = 'test@deploy.com';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();
        System.assert(response.statusCode == 200);  
    }


    static testMethod void testNegativeNoBookingID()
    {
        String bookingID = '';
        String emailAddress = 'test@deploy.com';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();

        Map<String,Object> mapResp = (Map<String,Object>)JSON.deserializeUntyped( response.responseBody.toString() );
        System.assert( mapResp.get('Message') == 'bookingID is blank' );
        System.assert(response.statusCode == 400);  
    }


    static testMethod void testNegativeNoEmail()
    {
        String bookingID = '320174';
        String emailAddress = '';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();

        Map<String,Object> mapResp = (Map<String,Object>)JSON.deserializeUntyped( response.responseBody.toString() );
        System.assert( mapResp.get('Message') == 'emailAddress is blank' );
        System.assert(response.statusCode == 400);
    }


    static testMethod void testNegativeNoData()
    {
        String bookingID = '';
        String emailAddress = '';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();

        Map<String,Object> mapResp = (Map<String,Object>)JSON.deserializeUntyped( response.responseBody.toString() );
        // System.assert( mapResp.get('Message') == 'bookingID and emailAddress is blank' );
        System.assert(response.statusCode == 400);
    }

    
    static testMethod void testNegativeWrongData()
    {
        String bookingID = '00000000';
        String emailAddress = 'test@deploy.com';
        System.Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri = 'updatealternateemailaddress/v1/';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response ;
            updateAlternateEmailAddress.updateAlerts(bookingID, emailAddress);
        System.Test.stopTest();
        
        Map<String,Object> mapResp = (Map<String,Object>)JSON.deserializeUntyped( response.responseBody.toString() );
        System.assert( mapResp.get('Message') == 'No record found against booking id' );
        System.assert(response.statusCode == 400);
    }

}