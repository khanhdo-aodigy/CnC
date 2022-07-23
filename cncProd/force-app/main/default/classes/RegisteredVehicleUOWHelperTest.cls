/**
 * @File Name          : RegisteredVehicleUOWHelperTest.cls
 * @Description        : 
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/24/2020, 11:24:20 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/24/2020   jmt@aodigy.com     Initial Version
**/
@isTest

private class RegisteredVehicleUOWHelperTest {
    @TestSetup
    static void makeData(){
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        Contact cnt = Test_DataFactory.createContact(true, '',  UserInfo.getLastName(), acc.Id);
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle(true, 'SEBE1', 'CCK', 'KIAPC', 'SEBE1', cnt.Id);

    }
    
    @isTest
    static void registerRegVehicleTestPostive(){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Registered_Vehicle__c.SObjectType});
        RegisteredVehicleUOWHelper updateUOW = new RegisteredVehicleUOWHelper();
        uow.registerWork(updateUOW);
        
        LIST<Registered_Vehicle__c> regVehicleList = new LIST<Registered_Vehicle__c>();
        Registered_Vehicle__c updateVeh= [SELECT Id, DWH_Vehicle_ID__c, last_battery_change__c from Registered_Vehicle__c];
        updateVeh.DWH_Vehicle_ID__c = 'TestABC';
        regVehicleList.add(updateVeh);
        updateUOW.registerRegVehicle(regVehicleList);
        uow.commitWork();
        
        updateVeh= [SELECT Id, DWH_Vehicle_ID__c, last_battery_change__c from Registered_Vehicle__c];
        system.assertEquals(updateVeh.DWH_Vehicle_ID__c, 'TestABC');
    }
    
    @isTest
    static void registerRegVehicleTestNegative(){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Registered_Vehicle__c.SObjectType});
        RegisteredVehicleUOWHelper updateUOW = new RegisteredVehicleUOWHelper();
        uow.registerWork(updateUOW);
        
        LIST<Registered_Vehicle__c> regVehicleList = new LIST<Registered_Vehicle__c>();
        Registered_Vehicle__c updateVeh= [SELECT Id, Registration_Number__c, DWH_Vehicle_ID__c, last_battery_change__c from Registered_Vehicle__c];
        updateVeh.Registration_Number__c = null;
        regVehicleList.add(updateVeh);
        updateUOW.registerRegVehicle(regVehicleList);
        uow.commitWork();
        updateUOW.logServiceDataPool();
        LIST<Logger_Data_Pool__c> dataPoolList= [SELECT Id from Logger_Data_Pool__c];
        system.assertEquals(dataPoolList.size(), 1);
   
    }
}