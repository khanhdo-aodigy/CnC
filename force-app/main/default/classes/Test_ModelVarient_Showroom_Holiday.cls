@isTest(seeAllData=true)
public class Test_ModelVarient_Showroom_Holiday {
Public static testMethod void testGetData()
    {
        Test.startTest();
        Model__c TestMod =  new Model__c(Name='TestMod',Branch_Code__c='CCK',Franchise_Code__c='KIAPC',DWH_Model_ID__c='abc12345');
        insert TestMod;
        Variant__c TestVar =  new Variant__c(Name='TestVar',Branch__c='CCK',Franchise__c='KIAPC',Model_ID__c=TestMod.Id);
        insert TestVar;
        Showroom__c TestShow =  new Showroom__c(Name='TestShow',City__c='SG',Country__c='SG',Address_Line_1__c='TestAdd');
        insert TestShow;
        Vehicle_Master__c TestVm =  new Vehicle_Master__c(Name='TestVM',Model__c=TestMod.Id,Variant__c=TestVar.Id,Showroom__c=TestShow.Id);
        insert TestVm;
        /*Event TestEvent =  new Event(Type='ShowroomHoliday',WhatId=TestShow.Id);
        insert TestEvent;*/
 
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ShowroomHoliday/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        
        ModelVarient_Showroom_Holiday_Selector.getShowroombyVarient(TestVar.Id,'','SG','SG');
        ModelVarient_Showroom_Holiday_Selector.getShowroombyVarient('',TestMod.Id,'SG','SG');
        Test.stopTest();
    }
    
    Public static testMethod void testErrorData()
    {
        Test.startTest();             
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ShowroomHoliday/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        
        ModelVarient_Showroom_Holiday_Selector.getShowroombyVarient('','','SG','SG');
        Test.stopTest();
    }
    
    Public static testMethod void testNoData()
    {
        Test.startTest();              
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ShowroomHoliday/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        
        ModelVarient_Showroom_Holiday_Selector.getShowroombyVarient('abc','abc','SG','SG');
        Test.stopTest();
    }
    
}