/** ******
 * Description : Test Class for BroadcastController.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200402            HS         Created Initial Version
 * 
** ******/
@isTest(seeAllData=false)
private class CustomerAlertsTriggerHandlerTest 
{   
    @TestSetup
    static void makeData()
    {
        TriggerExclusion.excludeTrigger('Account',true);
        TriggerExclusion.excludeTrigger('Contact',true);
        TriggerExclusion.excludeTrigger('Registered_Vehicle__c',true);

        //Create Account
        List<Account> lstAccount = new List<Account>{Test_DataFactory.createAccount( false , 'Test Account' ) };
        insert lstAccount;

        //Create Contact
        List<Contact> lstContact = new List<Contact>();
        for( Account acct : lstAccount )
        {
            for( Integer count = 0 ; count < 10 ; count++ )
            {
                Contact tempCnt = Test_DataFactory.createContact( false, 'Test-'+count, 'Contact'+count, (String)acct.Id ); 
                tempCnt.Device__c = 'TESTDEVICETOKEN'+count;
                lstContact.add( tempCnt );
            }
        }
        if( !lstContact.isEmpty() )
        {
            insert lstContact;
        }

        //Create Model
        List<Model__c> lstModels = new List<Model__c>();
        for( Integer index = 0 ; index < lstContact.size() ; index++ )
        {
            lstModels.add( Test_DataFactory.createmodelId( false,'TEST-MODEL-'+index, 'CCK', 'KIAPC' ) );
        }

        if( !lstModels.isEmpty() )
        {
            insert lstModels;
        }

        //Create Variant
        List<Variant__c> lstVariants = new List<Variant__c>();
        for( Integer index = 0 ; index < lstModels.size() ; index++ )
        {
            lstVariants.add( Test_DataFactory.createVariant( false,'TEST-VARIANT-'+index, lstModels.get( index ).Id, 'CCK' ) );
        }

        if( !lstVariants.isEmpty() )
        {
            insert lstVariants;
        }

        //Create Registered Vehicle, Model, Variant
        List<Registered_Vehicle__c> lstRegVehicles = new List<Registered_Vehicle__c>();
        for( Integer index = 0 ; index < lstContact.size() ; index++ )
        {
            Registered_Vehicle__c rv = Test_DataFactory.createregVehicle( false, 'TEST-REGVHC-'+index, 'CCK', 'KIAPC', 'TESTREGNUM'+index, lstContact.get( index ).Id );
            rv.Variant__c = ( index < lstVariants.size() ) ? lstVariants.get( index ).Id : null;
            lstRegVehicles.add( rv );
        }
        if( !lstRegVehicles.isEmpty() )
        {
            insert lstRegVehicles;
        }
    }

    @isTest
    static void customerBroadcastInsert_Test()
    {
        List<Contact> lstContact = [SELECT Id, Name, IsPersonAccount FROM Contact];
        List<Registered_Vehicle__c> lstRegVehicle = [SELECT Id FROM Registered_Vehicle__c];
        System.debug('testing---lstContact = ' + lstContact.size() + ' --- ' + lstContact);
        System.debug('testing---lstRegVehicle = ' + lstRegVehicle.size() + ' --- ' + lstRegVehicle);
        List<CustomerAlerts__c> lstCustAlert = new List<CustomerAlerts__c>();
        for( Integer index = 0 ; index < lstContact.size() ; index++ )
        {
            CustomerAlerts__c custAlert = new CustomerAlerts__c();
            custAlert.RecordTypeId          = Schema.SObjectType.CustomerAlerts__c.getRecordTypeInfosByDeveloperName().get( 'Broadcast' ).getRecordTypeId(); 
            custAlert.Description__c        = 'Testing Broadcast Message';
            custAlert.Contact__c            = lstContact.get( index ).Id;
            custAlert.Registered_Vehicle__c = ( index < lstRegVehicle.size() ) ? lstRegVehicle.get( index ).Id : null;
            custAlert.is_Upload__c          = true;
            custAlert.Status__c             = 'unread';
            lstCustAlert.add( custAlert );
        }

        System.Test.startTest();
            //TriggerExclusion.excludeTrigger('CustomerAlerts__c',true);
            if( lstCustAlert.size() > 0 ) 
            {
                insert lstCustAlert;
            }
            //List<CustomerAlerts__c> lstCAlert = [SELECT ID FROM CustomerAlerts__c];

            //TriggerExclusion.excludeTrigger('CustomerAlerts__c',false);
            //Test_DataFactory.createCusAlert(true, 'Test', null );

        System.Test.stopTest();
        System.assert( ([SELECT ID FROM CustomerAlerts__c WHERE RecordType.DeveloperName = 'Broadcast']).size() == 10  );
    }
}