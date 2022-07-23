@isTest
private class RegisteredVehicleBL_Test {
    
    @testSetup
    private static void createData()
    {    
        Account acct1 = Test_DataFactory.createPerson(false, 'TestPA123', 'Customer');
        acct1.PersonEmail        = 'testPA123@testing.com';
        acct1.DWH_Contact_ID__pc = '123456789';

        Account acct2 = Test_DataFactory.createPerson(false, 'TestPA456', 'Customer');
        acct2.PersonEmail        = 'testPA456@testing.com';
        acct2.DWH_Contact_ID__pc = '987654321';
        
        insert (new List<Account>{ acct1, acct2 });

        acct1 = [SELECT ID, PersonContactId FROM Account WHERE Id =: acct1.Id];
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false, 'SEBE1', 'CCK', 'KIAPC', 'SEBE1', acct1.PersonContactId);
		rv.Account__c = acct1.Id;
        rv.Contact__c = acct1.PersonContactId;
        rv.MagicCustomer__c = '123456789';
        insert rv;

        /** == MASTER TEST DATA - BEGIN == */

        // Model Master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelCode.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode.BHP__c = 130;                 // To test COE Category
        modelCode.Franchise_Code__c = 'KIAPC';
        insert modelCode;
        // Model Year Master
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(false, modelCode.Id);
        modelYearCode.VSMS_Compound_Primary_Key__c = '1';
        insert modelYearCode;
        // Color Master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        // Trim Master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            KCL_Module_ID__c = '123', 
                                                            KCL_Module_Installation_Date_Time__c = DateTime.now(), 
                                                            Subscription_Start_Date__c = Date.today(), 
                                                            Subscription_End_Date__c = Date.today() + 2);
        insert vMaster;
    }
    

    @isTest
    private static void testOwnerShipChange()
    {
        List<Account> lstAcct = [SELECT ID, PersonContactId, DWH_Contact_ID__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail = 'testPA456@testing.com'];
        System.assert( lstAcct.size() == 1 );

        List<Registered_Vehicle__c> lstRV = [SELECT Id, Account__c, Contact__c, MagicCustomer__c, IsOwnerChanged__c, OwnerChangeTimeStamp__c 
                                             FROM Registered_Vehicle__c 
                                             WHERE Account__r.DWH_Contact_ID__pc = '123456789' ];
        System.assert( lstRV.size() == 1 );
        System.assert( lstRV.get(0).IsOwnerChanged__c == false );
        System.assert( lstRV.get(0).OwnerChangeTimeStamp__c == null );

        System.Test.startTest();    
            lstRV.get(0).Account__c       = lstAcct.get(0).Id;
            lstRV.get(0).Contact__c       = lstAcct.get(0).PersonContactId;
            lstRV.get(0).MagicCustomer__c = lstAcct.get(0).DWH_Contact_ID__pc;
            update lstRV; 
        System.Test.stopTest();
        
        List<Registered_Vehicle__c> lstRVCheck = [SELECT Id, Account__c, Contact__c, MagicCustomer__c, IsOwnerChanged__c, OwnerChangeTimeStamp__c 
                                                  FROM Registered_Vehicle__c ];
        System.assert( lstRVCheck.size() == 1 );
        System.assert( lstRVCheck.get(0).MagicCustomer__c == '987654321' );
        System.assert( lstRVCheck.get(0).IsOwnerChanged__c == true );
        System.assert( lstRVCheck.get(0).OwnerChangeTimeStamp__c <> null );
    }

    //Thanh added 10-May-2022
    @isTest
    private static void testGetKCLRecords(){
        List<Vehicle_Master2__c> vehicleMaster = [SELECT Chassis__c, KCL_Module_ID__c, KCL_Module_Installation_Date_Time__c, Subscription_Start_Date__c, Subscription_End_Date__c
                                                  FROM Vehicle_Master2__c
                                                  LIMIT 1];

        Registered_Vehicle__c regVehicle = Test_DataFactory.createRegVehicle(false, 'SC123', 'CCK', 'KIAPC', 'SC123', null);
        regVehicle.Chasis_Number__c = 'CHAS279831';
        insert regVehicle;

        RegisteredVehicleBL.getKCLRecords(new List<Registered_Vehicle__c>{regVehicle});

        Registered_Vehicle__c regVehicle1 = [SELECT Chasis_Number__c, KCL_Module_ID__c, KCL_Module_Installation_Date_Time__c, Subscription_Start_Date__c, Subscription_End_Date__c
                                            FROM Registered_Vehicle__c
                                            WHERE Chasis_Number__c = 'CHAS279831'];

        System.assertEquals(vehicleMaster[0].KCL_Module_ID__c, regVehicle1.KCL_Module_ID__c);
        System.assertEquals(vehicleMaster[0].KCL_Module_Installation_Date_Time__c, regVehicle1.KCL_Module_Installation_Date_Time__c);
        System.assertEquals(vehicleMaster[0].Subscription_Start_Date__c, regVehicle1.Subscription_Start_Date__c);
        System.assertEquals(vehicleMaster[0].Subscription_End_Date__c, regVehicle1.Subscription_End_Date__c);
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Registered_Vehicle__c', true);
        List<Account> lstAcct = [SELECT ID, PersonContactId, DWH_Contact_ID__pc FROM Account WHERE IsPersonAccount = true AND PersonEmail = 'testPA456@testing.com'];

        List<Registered_Vehicle__c> lstRV = [SELECT Id, Account__c, Contact__c, MagicCustomer__c, IsOwnerChanged__c, OwnerChangeTimeStamp__c 
                                             FROM Registered_Vehicle__c 
                                             WHERE Account__r.DWH_Contact_ID__pc = '123456789' ];

        lstRV.get(0).Account__c       = lstAcct.get(0).Id;
        lstRV.get(0).Contact__c       = lstAcct.get(0).PersonContactId;
        lstRV.get(0).MagicCustomer__c = lstAcct.get(0).DWH_Contact_ID__pc;
        update lstRV; 

        TriggerExclusion.excludeTrigger('Registered_Vehicle__c', false);
    }

    
}