/***************************************************
* Class Name: DWH_GetCustomer_DataTest
* Description: Test class for Vehicle Full and Partial sync.
* 			   Refactored previous class due to seeAllData = true
***************************************************/ 
@isTest
private class DWH_GetRegisteredVehicles_DataTest{
    
    //Custom Setting data prep.
    @testSetUp
    static void createData(){

        Account act = Test_DataFactory.createAccount(true, 'testAccountDWH');
        Contact cnt = Test_DataFactory.createContact(false, 'testContact9', 'DWH', String.valueOf(act.Id));
        cnt.DWH_Contact_ID__c = '191791';
        insert cnt;

        Account paCustomer = Test_DataFactory.createPA(false, 'testPACustomer9', 'testPA@customer.com', 'Customer');
        paCustomer.DWH_Contact_ID__c  = '191791';
        paCustomer.DWH_Contact_ID__pc = '191791';
        paCustomer.NRIC_Passport_No__pc = '282830011990';
        insert paCustomer;


        Model__c tempModel = Test_DataFactory.createmodelId( true, 'TestModelLLL', 'CCA', 'MITPC' );
        Variant__c  tempVariant = Test_DataFactory.createVariant ( false, 'L-Serie99', tempModel.Id, 'CCA');
        tempVariant.DWH_Variant_ID__c = 'DWHL99';
        tempVariant.source__c = 'DWH';
        insert tempVariant;

        Color_Master__c tempColorMaster = Test_DataFactory.createColorCode( false, 'PC099', 'AC088', 'CCA', 'MITPC');
        tempColorMaster.DWH_Color_ID__c = 'P026';
        tempColorMaster.Source__c = 'DWH';
        insert tempColorMaster;

        Branch_Code_Name_Mapping__c tempBranchColor = new Branch_Code_Name_Mapping__c();
        tempBranchColor.Branch_Code__c = 'CCA';
        tempBranchColor.CV_Code__c = 'MITPC';
        tempBranchColor.PC_Code__c = 'PCCode';
        insert tempBranchColor;
        
        Registered_Vehicle__c rv = Test_DataFactory.createRegVehicle(false, 'Test RV' ,'CCA', 'MITPC', '74L1' , cnt.Id);
        rv.Chasis_Number__c = 'KNAFJ411MJ5761385';
        insert rv;


            //API Gateway Settings
            global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com',
                                                APIGateway_key__c='testKey');
            upsert gVar;
            
            //DWH Last Run date
            DWH_last_run_date__c sv = new DWH_last_run_date__c();
            sv.DWH_import_date__c = Date.today();
            sv.RegVehicle_StartPage__c  = 1;
            sv.RegVehicle_NumberOfPage__c = 25;
            sv.RegVehicle_NumRecords__c = 50;
            upsert sv;
    }
    
    /***********************************************
     * Method Name: testPositiveFullSync
     * Description: Full Sync Positive Test Run
     ***********************************************/
    static testMethod void testPositiveFullSync(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetRegisteredVehicals_Data', true));
        String body = '{"totalNumberOfRecords": 5000}';
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,body));
        //System.schedule('TestGet_VehicleFullSync', '0 0 0 ? * * *', new DWH_GetRegisteredVehicals_Data());
        
        DWH_GetRegisteredVehicals_Data sJob = new DWH_GetRegisteredVehicals_Data();
        sJob.execute(null);
        Test.stopTest();        
       
    }
    
    /***********************************************
     * Method Name: testPositivePartialSync
     * Description: Partial Sync Positive Test Run
     ***********************************************/
    static testMethod void testPositivePartialSync(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetRegisteredVehicals_Data', true));
        // System.schedule('TestGet_VehiclePartialSync', '0 0 0 ? * * *', new DWH_GetRegisteredVehicals_Data());
        DWH_GetRegisteredVehicals_Data sJob = new DWH_GetRegisteredVehicals_Data();
        sJob.execute(null);       
        Test.stopTest();
        List<Registered_Vehicle__c> lstRV = [SELECT Id FROM Registered_Vehicle__c];
    }
    

    @isTest
    static void exeTestRunTM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetRegisteredVehicals_Data', true));
        DWH_GetRegisteredVehicals_Data.exeTestRun(null);
        Test.stopTest();        
    }
    
    @isTest
    static void testBatchJobWithoutSetupHttpCalloutMock_ExceptionThrown(){
        Test.startTest();
        try{
            DWH_GetRegisteredVehicals_Data sJob = new DWH_GetRegisteredVehicals_Data();
        	sJob.execute(null);
        } catch (Exception ex) {
        	System.assertEquals('Methods defined as TestMethod do not support Web service callouts', ex.getMessage());           
        }
         
        Test.stopTest();
    }
    
    @isTest
    private static void testTagVehicleToAccount() {
        String resBody = '{"RV":[{"MAGIC_VEHICLE":128171,"VEHICLE_DATASOURCE":"CCS","MAGIC_MBPC":0,"MAGIC_MBCV":0,"MAGIC_MF":359066,"MAGIC_FUL":297804,"MAGIC_CUSTOMER":188584,"FRANCHISECODE":"K","FRANCHISE":"KIAPC","REGNO":"SKJ6266C","COMM":"1217-5761385","ENGINE":"G4FGHH691472","CHASSIS":"KNAFJ411MJ5761385","REGDATE":"2018-05-17T00:00:00","COLLECTIONDATE":"0001-01-01T00:00:00","LASTSERV":"2020-08-04T00:00:00","IMILEAGEU":0,"NEXTSERV":"2021-02-03T00:00:00","NEXTSMIL":57160,"LASTSMILE":47160,"SECURENO":"1128444823","WAREXPDT":"2023-05-17T00:00:00","WAREXTDT":"0001-01-01T00:00:00","SVCCRDBAL":0,"SVCCRDEXPDT":"0001-01-01T00:00:00","MAGIC":"128171","IMMOBIL":"","MODELYR":2017,"COLCODE":"MST","VARIANT":"FK31.6AL189","EXTContactID":274484,"DELDATE":"0001-01-01T00:00:00","CREATED":"2018-04-25T00:00:00","EDITED":"2020-09-21T00:00:00","LASTBATTERYCHANGEdate":"04/08/2020","NXTRECOMNDSVC":"INFOA","SCRBAL":0,"EMAIL":"testPA@customer.com|282830011990"}],"Message":"The operation is completed successfully. 965 Registered vehicles are retrieved"}';
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatus('200');
        mockResponse.setBody( resBody );
        DWH_GetRegisteredVehicals_Data.updateData( mockResponse );
    }
    
}