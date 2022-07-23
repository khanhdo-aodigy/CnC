/**
 * @File Name          : RegisteredVehicleSelectorTest.cls
 * @Description        : JIRA29
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/22/2020, 2:42:54 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      2/12/2020       jmt@aodigy.com          Initial Version
 * 1.1      2/24/2020       HS@aodigy.com           Added selectByChassisNumberTest
 * 1.2      7/8/2020        TP@aodigy.com           Added selectByIdsTest and getIdByNameTest
**/
@isTest
private class RegisteredVehicleSelectorTest {
    @TestSetup
    static void makeData(){
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        Contact cnt = Test_DataFactory.createContact(true, '',  UserInfo.getLastName(), acc.Id);
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle(false, 'SEBE1', 'CCK', 'KIAPC', 'SEBE1', cnt.Id);
        regVeh.DWH_Vehicle_ID__c = 'SEBE1';
        regVeh.Chasis_Number__c  = 'CHASSICTEST1';
        insert regVeh;
       
    }
    @isTest
    static void selectByMagicVehicleTest() {
        RegisteredVehicleSelector sel = new RegisteredVehicleSelector();
        SET<String> magicIds = new SET<String> ();
        magicIds.add('SEBE1');
        system.assertEquals(1, sel.selectByMagicVehicle(magicIds).size());
    }

    @isTest
    static void selectByChassisNumberTest() {
        RegisteredVehicleSelector sel = new RegisteredVehicleSelector();
        Set<String> setChassisRef = new Set<String>{ 'CHASSICTEST1' , 'CHASSICTEST2' };
        System.assert( sel.selectByChassisNumber( setChassisRef ).size() == 1 );
    }
    
    @isTest
    static void selectByIdsTest() {
        RegisteredVehicleSelector sel = new RegisteredVehicleSelector();
        Registered_Vehicle__c regVeh = [SELECT Id FROM Registered_Vehicle__c];
        Set<Id> setIds = new Set<Id>{regVeh.Id};
        System.assert(sel.selectByIds(setIds).size() == 1);
    }
    
    @isTest
    static void getIdByNameTest() {
        RegisteredVehicleSelector sel = new RegisteredVehicleSelector();
        Registered_Vehicle__c regVeh = [SELECT Id, Name FROM Registered_Vehicle__c];
        System.assert(sel.getIdByName(regVeh.Name) == regVeh.Id);
    }
    
    @isTest
    static void selectByChassisNumberAndMagicCustomerTest() {
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName() + '1');
        Contact cnt = Test_DataFactory.createContact(true, '',  UserInfo.getLastName()  + '1', acc.Id);
        
        Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle(false, 'SEBE2', 'CCK', 'KIAPC', 'SEBE2', cnt.Id);
        regVeh.DWH_Vehicle_ID__c = 'SEBE2';
        regVeh.Chasis_Number__c  = 'CHASSICTEST3';
        regVeh.MagicCustomer__c  = 'Hung12342';
        insert regVeh;
        
        RegisteredVehicleSelector sel = new RegisteredVehicleSelector();
        Set<String> setChassisRef = new Set<String>{ 'CHASSICTEST3'};
        System.assert( sel.selectByChassisNumberAndMagicCustomer( setChassisRef ).size() == 1 );
    }
    @isTest
    static void getChasisByIdTest() {
        Test.startTest();
        List<Registered_Vehicle__c> regVeh = [SELECT Id, Name FROM Registered_Vehicle__c];
        Test.stopTest();
        System.assertNotEquals(null, RegisteredVehicleSelector.getChasisById((String)regVeh[0].Id));
    }

    
}