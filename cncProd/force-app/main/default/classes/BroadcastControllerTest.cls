/** ******
 * Description : Test Class for BroadcastController.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200402            HS         Created Initial Version
 * 20210917            TP         Modified to cater RA & Non C&C Vehicles
** ******/
@isTest(seeAllData=false)
private class BroadcastControllerTest 
{
    @TestSetup
    static void makeData()
    {
        //Create Account
        List<Account> lstAccount = new List<Account>{Test_DataFactory.createPerson( false , 'Test Account', 'Prospect' ) };
        for (Integer i = 0; i < lstAccount.size(); i++)
        {
            lstAccount[i].PersonEmail = 'patest' + i + '@hotmail.com';
        }
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

        //Create Used Car
        Used_Car_Vehicle_Stock__c usedCar = Test_DataFactory.createSoldUsedCar(true, lstAccount[0].Id, 'STOCK-001', 'OIYG1','AUDI' ,'F1');

        //Create NonC&C Car
        Non_C_C_Vehicle__c nonCCCar = new Non_C_C_Vehicle__c(Account__c = lstAccount[0].Id, Registration_Number__c = 'S1234', Current_Mileage__c = 10000, Registered_Date__c = Date.valueOf('2020-04-01'));
        insert nonCCCar;
    }

    @isTest
    static void getFilteredRegVehicles_Test()
    {

        BroadcastFilterWrapper filters = new BroadcastFilterWrapper();
        filters.vehicleType = 'Registered_Vehicle__c';
        Integer pageNumber = 1;

        List<String> tempModels = new List<String>();
        List<String> tempVariants = new List<String>();
        for( Model__c md : [SELECT Id FROM Model__c ])
        {
            tempModels.add( (String)md.Id );
        }

        for( Variant__c vr : [SELECT Id FROM Variant__c ])
        {
            tempVariants.add( (String)vr.Id );
        }

        System.Test.startTest();

            PagedResult pgResult = BroadcastController.getFilteredRegVehicles(filters, pageNumber);
            System.assert( pgResult <> null );
            System.assert( pgResult.totalItemCount == 0 );
            System.assert( pgResult.records <> null && pgResult.records.isEmpty() );

            filters.branches = new List<String>{ 'CCK' };
            pgResult = BroadcastController.getFilteredRegVehicles(filters, pageNumber);
            System.assert( pgResult <> null );
            System.assert( pgResult.totalItemCount == 10 );
            System.assert( pgResult.records <> null && !pgResult.records.isEmpty() && pgResult.records.size() == 10 );

            filters.models   = tempModels;
            filters.variants = tempVariants;
            pgResult = BroadcastController.getFilteredRegVehicles(filters, pageNumber);
            System.assert( pgResult <> null );
            System.assert( pgResult.totalItemCount == 10 );
            System.assert( pgResult.records <> null && !pgResult.records.isEmpty() && pgResult.records.size() == 10 );

            filters.branches        = new List<String>{};
            filters.bdayMonthFrom   = '1';
            filters.bdayMonthTo     = '12';
            filters.lastLoginFrom   = '1';
            filters.lastLoginTo     = '12';
            filters.carAgeFrom      = '1';
            filters.carAgeTo        = '15';
            filters.upcomingServiceDateFrom = '2020-04-01';
            filters.upcomingServiceDateTo = '2200-04-01';
            filters.lastServiceDateFrom = '2020-04-01';   
            filters.lastServiceDateTo = '2200-04-01';
            pgResult = BroadcastController.getFilteredRegVehicles(filters, pageNumber);
            System.assert( pgResult <> null );

            filters = new BroadcastFilterWrapper();
            filters.vehicleType = 'Used_Car_Vehicle_Stock__c';
            filters.registrationDateFrom = '2020-04-01';
            filters.registrationDateTo = '2020-04-01';
            filters.MileageFrom = '1000';
            filters.MileageTo   = '1000';
            pgResult = BroadcastController.getFilteredRegVehicles(filters, pageNumber);
            System.assert( pgResult <> null );

            filters.vehicleType = 'Non_C_C_Vehicle__c';
            pgResult = BroadcastController.getFilteredRegVehicles(filters, pageNumber);
            System.assert( pgResult <> null );

        System.Test.stopTest();
    }


    @isTest
    static void createBroadcastAlert_Test()
    {

        System.Test.startTest();
            BroadcastFilterWrapper filters = new BroadcastFilterWrapper();
            filters.vehicleType = 'Registered_Vehicle__c';
            filters.branches    = new List<String>{ 'CCK' };
            String resultStr = BroadcastController.createBroadcastAlert( filters, 'Testing Broadcast Alert Msg', 'E-Shop', '', 'https://google.com', 'My Alert' );
            System.debug('@@@@DEBUG createBroadcastAlert_Test :: resultStr = ' +resultStr );
        System.Test.stopTest();

        System.assert( ([SELECT Id FROM CustomerAlerts__c WHERE RecordType.DeveloperName = 'Broadcast']).size() == 10 );
    }

    @isTest
    static void getModelAsSelectOptions_Test()
    {
        
        System.Test.startTest();
        System.assert( !BroadcastController.getModelAsSelectOptions( new List<String>{'CCK'}).isEmpty() 
                            && BroadcastController.getModelAsSelectOptions( new List<String>{'CCK'}).size() == 10 );
        System.Test.stopTest();
    }


    @isTest
    static void getVariantAsSelectOptions_Test()
    {
        
        List<String> tempModels = new List<String>();
        for( Model__c md : [SELECT Id FROM Model__c ]){
            tempModels.add( (String)md.Id );
        }

        System.Test.startTest();
            System.assert( !BroadcastController.getVariantAsSelectOptions(new List<String>{'CCK'}, tempModels).isEmpty() &&  
                                BroadcastController.getVariantAsSelectOptions( new List<String>{'CCK'}, tempModels ).size() == 10 );
        System.Test.stopTest();
    } 
}