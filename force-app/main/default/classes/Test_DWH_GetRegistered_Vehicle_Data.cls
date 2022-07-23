@isTest(SeeAllData=true)
public class Test_DWH_GetRegistered_Vehicle_Data 
{
    public static testmethod void test_CreateRegistered_Vehicle() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"RV":[{"FRANCHISECODE":"K","FRANCHISE":"KIAPC","REGNO":"SBB39E","COMM":"0416-03601292","ENGINE":"10JBHC3049702","CHASSIS":"VF7KFBHZTGS503641","REGDATE":"2016-06-29T00:00:00","COLLECTIONDATE":"2016-06-09T00:00:00","LASTSERV":"2018-07-19T00:00:00","IMILEAGEU":0,"NEXTSERV":"2019-01-05T00:00:00","NEXTSMIL":55607,"SECURENO":"1126410735","WAREXPDT":"2019-06-29T00:00:00","WAREXTDT":"2021-06-29T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"2021-01-01T00:00:00","MAGIC":"330960","IMMOBIL":"","MODELYR":2016,"COLCODE":"VLM0","VARIANT":"1CB8A5NKDQ","EXTContactID":143718,"DELDATE":"0001-01-01T00:00:00","CREATED":"2016-06-07T00:00:00","EDITED":"2018-08-01T00:00:00","LASTBATTERYCHANGEdate":"25/03/2019"}]}');
        res.setStatusCode(200);
        DWH_GetRegisteredVehicals_Data.UpdateData(res);   
        
        //JMT: This piece of code need to rewrite. This was written by previous developer. All data must be created at runtime when the test class is executing.
        //
        Registered_Vehicle__c CM_Test_Obj = [Select Name,Franchise__c,Registration_Number__c,Comm_No__c,Engine_Number__c,Chasis_Number__c,Next_Service_Booking_KM__c,
                                             IU__c,DWH_Vehicle_ID__c,Self_Import_Vehicle__c,Registered_Date__c,Last_Service_Booking_Date__c,Last_Battery_Change__c,
                                             Next_Service_Booking_Date__c,Manufacture_Warranty_End_Date__c,Extended_Warranty_End_Date__c,
                                             Service_Credits_Expiry_Date__c,Service_Credits__c,Model_Year__c,Last_Service_Booking_KM__c,Car_Collection_Date__c,Autoline_Franchise_Code__c
                                             From Registered_Vehicle__c where DWH_Vehicle_ID__c='130207'];//'330960']; //Production: 130207
        
        DWH_GetRegisteredVehicals_Data.Registered_Vehicle Var = new DWH_GetRegisteredVehicals_Data.Registered_Vehicle
            (/*CM_Test_Obj.Franchise__c,CM_Test_Obj.Autoline_Franchise_Code__c,CM_Test_Obj.Registration_Number__c,CM_Test_Obj.Comm_No__c,CM_Test_Obj.Engine_Number__c,
             CM_Test_Obj.Chasis_Number__c,CM_Test_Obj.Next_Service_Booking_KM__c,CM_Test_Obj.IU__c,CM_Test_Obj.DWH_Vehicle_ID__c,
             CM_Test_Obj.Self_Import_Vehicle__c,CM_Test_Obj.Registered_Date__c,CM_Test_Obj.Last_Service_Booking_Date__c,String.valueOf(CM_Test_Obj.Last_Battery_Change__c),
             CM_Test_Obj.Next_Service_Booking_Date__c,CM_Test_Obj.Manufacture_Warranty_End_Date__c,CM_Test_Obj.Extended_Warranty_End_Date__c,
             CM_Test_Obj.Service_Credits_Expiry_Date__c,CM_Test_Obj.Service_Credits__c,CM_Test_Obj.Model_Year__c,CM_Test_Obj.Last_Service_Booking_KM__c,
             '','','',CM_Test_Obj.Car_Collection_Date__c,''*/);
        Test.stopTest();    
        System.assertEquals('SDX2526M',CM_Test_Obj.Name);        //Production: SDX2526M //Test: SBB39E
    }
    
    public static testmethod void test_UpdateRegistered_Vehicle() {
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"RV":[{"FRANCHISECODE":"C","FRANCHISE":"CITPC","REGNO":"SBB39E","COMM":"0416-03601292","ENGINE":"10JBHC3049702","CHASSIS":"VF7KFBHZTGS503641","REGDATE":"2016-06-29T00:00:00","COLLECTIONDATE":"2016-06-09T00:00:00","LASTSERV":"2018-07-19T00:00:00","LASTBATTERYCHANGEdate":"test","IMILEAGEU":10,"NEXTSERV":"2019-01-05T00:00:00","NEXTSMIL":55607,"SECURENO":"1126410735","WAREXPDT":"2019-06-29T00:00:00","WAREXTDT":"2021-06-29T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"2021-01-01T00:00:00","MAGIC":"330960","IMMOBIL":"","MODELYR":2016,"COLCODE":"VLM0","VARIANT":"1CB8A5NKDQ","EXTContactID":143718,"DELDATE":"0001-01-01T00:00:00","CREATED":"2016-06-07T00:00:00","EDITED":"2018-08-01T00:00:00"}]}'));
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"RV":[{"FRANCHISECODE":"C","FRANCHISE":"CITPC","REGNO":"SBB39E","COMM":"0416-03601292","ENGINE":"10JBHC3049702","CHASSIS":"VF7KFBHZTGS503641","REGDATE":"2016-06-29T00:00:00","COLLECTIONDATE":"2016-06-09T00:00:00","LASTSERV":"2018-07-19T00:00:00","IMILEAGEU":10,"NEXTSERV":"2019-01-05T00:00:00","NEXTSMIL":55607,"SECURENO":"1126410735","WAREXPDT":"2019-06-29T00:00:00","WAREXTDT":"2021-06-29T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"2021-01-01T00:00:00","MAGIC":"330960","IMMOBIL":"","MODELYR":2016,"COLCODE":"VLM0","VARIANT":"1CB8A5NKDQ","EXTContactID":143718,"DELDATE":"0001-01-01T00:00:00","CREATED":"2016-06-07T00:00:00","EDITED":"2018-08-01T00:00:00","SCRBAL":"100"}]}');
        res.setStatusCode(200);
        DWH_GetRegisteredVehicals_Data.UpdateData(res);
        
        //Registered_Vehicle__c CM_Test_Obj = [Select Name,Last_Service_Booking_KM__c From Registered_Vehicle__c where DWH_Vehicle_ID__c='330960'];
        //System.assertEquals('SBB39E',CM_Test_Obj.Name);
        //System.assertEquals('10',CM_Test_Obj.Last_Service_Booking_KM__c);        
    }
    
    public static testmethod void test_ErrorRegistered_Vehicle() {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"RV":[{"FRANCHISECODE":"C","FRANCHISE":"CIPC","REGNO":"SBB39E","COMM":"0416-03601292","ENGINE":"10JBHC3049702","CHASSIS":"VF7KFBHZTGS503641","REGDATE":"2016-06-29T00:00:00","COLLECTIONDATE":"2016-06-09T00:00:00","LASTSERV":"2018-07-19T00:00:00",IMILEAGEU":10,"NEXTSERV":"2019-01-05T00:00:00","NEXTSMIL":55607,"SECURENO":"1126410735","WAREXPDT":"2019-06-29T00:00:00","WAREXTDT":"2021-06-29T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"2021-01-01T00:00:00","MAGIC":"330960","IMMOBIL":"","MODELYR":2016,"COLCODE":"VLM0","VARIANT":"1CB8A5NKDQ","EXTContactID":143718,"DELDATE":"0001-01-01T00:00:00","CREATED":"2016-06-07T00:00:00","EDITED":"2018-08-01T00:00:00"}]}');
        res.setStatusCode(200);
        DWH_GetRegisteredVehicals_Data.UpdateData(res);
        
        //JMT: This piece of code need to rewrite. This was written by previous developer. All data must be created at runtime when the test class is executing.
        //
        //
        Registered_Vehicle__c[] CM_Test_Obj_lst = [Select Name From Registered_Vehicle__c where DWH_Vehicle_ID__c='130207'];//'47547'];
        System.assertEquals(1,CM_Test_Obj_lst.size());
    }
    
    public static testmethod void test_AllRegistered_Vehicle() 
    {        
        DWH_GetRegisteredVehicals_Data.getRegistered_VehicleData(); 
    }
    public static testmethod void test_UpdateRegistered_Vehicle1() {
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"RV":[{"FRANCHISECODE":"C","FRANCHISE":"CITPC","REGNO":"SBB39E","COMM":"0416-03601292","ENGINE":"10JBHC3049702","CHASSIS":"VF7KFBHZTGS503641","REGDATE":"2016-06-29T00:00:00","COLLECTIONDATE":"2016-06-09T00:00:00","LASTSERV":"2018-07-19T00:00:00","LASTBATTERYCHANGEdate":"test","IMILEAGEU":10,"NEXTSERV":"2019-01-05T00:00:00","NEXTSMIL":55607,"SECURENO":"1126410735","WAREXPDT":"2019-06-29T00:00:00","WAREXTDT":"2021-06-29T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"2021-01-01T00:00:00","MAGIC":"330960","IMMOBIL":"","MODELYR":2016,"COLCODE":"VLM0","VARIANT":"1CB8A5NKDQ","EXTContactID":143718,"DELDATE":"0001-01-01T00:00:00","CREATED":"2016-06-07T00:00:00","EDITED":"2018-08-01T00:00:00"}]}'));
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"FRANCHISECODE":"C","FRANCHISE":"CITPC","REGNO":"SBB39E","COMM":"0416-03601292","ENGINE":"10JBHC3049702","CHASSIS":"VF7KFBHZTGS503641","REGDATE":"2016-06-29T00:00:00","COLLECTIONDATE":"2016-06-09T00:00:00","LASTSERV":"2018-07-19T00:00:00","IMILEAGEU":10,"LASTBATTERYCHANGEdate":"23/12/2019", "NEXTSERV":"2019-01-05T00:00:00","NEXTSMIL":55607,"SECURENO":"1126410735","WAREXPDT":"2019-06-29T00:00:00","WAREXTDT":"2021-06-29T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"2021-01-01T00:00:00","MAGIC":"330960","IMMOBIL":"","MODELYR":2016,"COLCODE":"VLM0","VARIANT":"1CB8A5NKDQ","EXTContactID":143718,"DELDATE":"0001-01-01T00:00:00","CREATED":"2016-06-07T00:00:00","EDITED":"2018-08-01T00:00:00, "SCRBAL":"100"}');
        res.setStatusCode(200);
        DWH_GetRegisteredVehicals_Data.UpdateData(res);
        
        //Registered_Vehicle__c CM_Test_Obj = [Select Name,Last_Service_Booking_KM__c From Registered_Vehicle__c where DWH_Vehicle_ID__c='330960'];
        //System.assertEquals('SBB39E',CM_Test_Obj.Name);
        //System.assertEquals('10',CM_Test_Obj.Last_Service_Booking_KM__c);        
    }
}