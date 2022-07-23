/** ******
 * Description : Test Class for ContactService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20201207            HS@aodigy                Created Initial Version
 * 
** ******/
@isTest(seeAllData=false)
private class ContactServiceTest {
    
    @TestSetup
    static void makeData(){

        Account customer1 = Test_DataFactory.createPerson(false, 'CNC-Customer1', 'Customer');
        customer1.PersonEmail = 'cnc-customer1@testing.com';

        Account customer2 = Test_DataFactory.createPerson(false, 'CNC-Customer2', 'Customer');
        customer2.PersonEmail = 'cnc-customer2@testing.com';

        Account prospect1 = Test_DataFactory.createPerson(false, 'CNC-Prospect1', 'Prospect');
        prospect1.PersonEmail = 'cnc-prospect1@testing.com';
        
        insert ( new List<Account>{ customer1, customer2, prospect1 } );
    }


    @isTest
    static void getCustomerContactsByEmailTM(){
        System.Test.startTest();
            System.assert( !ContactService.getCustomerContactsByEmail('cnc-customer1@testing.com').isEmpty() );
            System.assert( ContactService.getCustomerContactsByEmail('cnc-customer3@testing.com').isEmpty() );
            System.assert( ContactService.getCustomerContactsByEmail('cnc-prospect1@testing.com').isEmpty() );
        System.Test.stopTest();
    }

    @isTest
    static void getProspectContactsByEmailTM(){
        System.Test.startTest();
            System.assert( ContactService.getProspectContactsByEmail('cnc-customer1@testing.com').isEmpty() );
            System.assert( ContactService.getProspectContactsByEmail('cnc-customer2@testing.com').isEmpty() );
            System.assert( !ContactService.getProspectContactsByEmail('cnc-prospect1@testing.com').isEmpty() );
        System.Test.stopTest();
    }

    @isTest
    static void getProspectContactsByAccountIdTM(){
        List<Account> lstProspect = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Prospect'];
        System.assert( lstProspect.size() == 1 );
        System.Test.startTest();
            System.assert( !ContactService.getProspectContactsByAccountId( lstProspect.get(0).Id).isEmpty() );
        System.Test.stopTest();
    }
    @isTest
    static void getProspectContactsBySetEmail(){
        List<Account> lstProspect = [SELECT Id, Name, PersonEmail FROM Account WHERE RecordType.DeveloperName = 'Prospect'];
        System.assert( lstProspect.size() == 1 );
        System.Test.startTest();
        System.assert( !ContactService.getProspectContactsBySetEmail( new Set<String>{lstProspect.get(0).PersonEmail}).isEmpty() );
        System.Test.stopTest();
    }
}