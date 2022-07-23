/** ******
 * Description : Test Class for VSMSHelperClass.cls
 * 
 * Change History:
 * Date(YYYYMMDD)        Name        Description
 * 202004010             HS          Created Initial Version. 
 * 
** ******/
@isTest(seeAllData=false)
private class VSMSHelperClass_Test {
    
    @TestSetup
    static void makeData(){

        global_var__c jjcVal = Test_DataFactory.createGlobalOrfDefaults(false);
        jjcVal.APIGateway_key__c = '731837873';
        insert jjcVal;

        Postal_Code__c postcode = Test_DataFactory.createPostalCode(true, '123456');
        Account act = Test_DataFactory.createAccount(true, 'VSMS_AccountTest1');
        
        //Insert Contacts
        List<Contact> lstCnts = new List<Contact>();
        Contact cnt1 = Test_DataFactory.createContact(false, 'ContactTest1', 'VSMS', String.valueOf(act.Id) );
        cnt1.Postal_Code__c = postcode.Id;
        cnt1.Birthdate      = null;
        cnt1.Gender__c      = 'Male';
        lstCnts.add( cnt1 );

        Contact cnt2 = Test_DataFactory.createContact(false, 'ContactTest2', 'VSMS', String.valueOf(act.Id) );
        cnt2.Unit_No_Floor__c    = '99';
        cnt2.Address_Line_1__c   = 'Address 1';
        cnt2.Address_Line_2__c   = 'Address 2';
        cnt2.Address_Line_3__c   = 'Address 3';
        lstCnts.add( cnt2 );

        if(!lstCnts.isEmpty()){
            insert lstCnts;
        }

        //Insert Person Accounts
        List<Account> lstPA = new List<Account>();
        Account pa1 = Test_DataFactory.createPerson(false, 'VSMS_PA1', 'Customer');
        pa1.Postal_Code__pc = postcode.Id;
        pa1.PersonBirthdate = null;
        pa1.Gender__pc      = 'Male';
        pa1.PersonEmail     = 'patest@gmail.com';
        lstPA.add( pa1 );

        Account pa2 = Test_DataFactory.createPerson(false, 'VSMS_PA2', 'Customer');
        pa1.Gender__pc           = 'Female';
        pa2.Unit_No_Floor__pc    = '88';
        pa2.Address_Line_1__pc   = 'Address 4';
        pa2.Address_Line_2__pc   = 'Address 5';
        pa2.Address_Line_3__pc   = 'Address 6';
        pa2.PersonEmail          = 'mailtest38473@gmail.com';
        lstPA.add( pa2 );

        if(!lstPA.isEmpty()){
            insert lstPA;
        }

        //Insert Oopportunity
        Opportunity oppo = Test_DataFactory.createOpportunity(false, 'TestOppoStockRESV-1', String.valueOf(act.Id));
        oppo.Account__c        = pa2.Id;
        oppo.Contact_Person__c = cnt2.Id;
        insert oppo;

        //Insert User
        User testUsr = Test_DataFactory.createUser(true, 'TestUser', 'Jaslyn');

        //Create Stock Reservation
        String branchCode = 'CCK';
        String franchiseCode = 'KIAPC';
        Model__c model       = Test_DataFactory.createmodelId(true, 'test', branchCode, franchiseCode);
        Variant__c variant   = Test_DataFactory.createVariant(true, 'test', model.Id, branchCode);        
        Vehicle_Master__c vehicleMaster = Test_DataFactory.createVehicleMaster(false, 'test', variant.Id, model.Id);
        
        Model_Master__c modelMaster = new Model_Master__c(Name='TestModelMaster', Branch_Code__c=branchCode, Franchise_Code__c=franchiseCode);
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name='TestColorMaster', Branch_Code__c=branchCode, Franchise_Code__c=franchiseCode, ColorCode__c='Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name='TestTrimMaster', Branch_Code__c=branchCode, Franchise_Code__c=franchiseCode);
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'TestModelYearMaster', Branch_Code__c=branchCode, Franchise_Code__c=franchiseCode, Model_Master__c=modelMaster.Id);
        modelYearMaster.VSMS_Compound_Primary_Key__c = 'KIAPC47284ADF';
        insert modelYearMaster;
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c=franchiseCode, Model_Master__c=modelMaster.Id, PKH_STATUS__c = 'A');
        pckHeader.VSMS_Compound_Primary_Key__c = 'KIAPC83473847EDC';
        insert pckHeader;
        
        Stock_Reservation__c stockResv = Test_DataFactory.StockReservation(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id);
        stockResv.Package_Header_From_PickList__c = pckHeader.Id;
        stockResv.Vehicle_Master__c = vehicleMaster.Id;
        stockResv.Opportunity__c = oppo.Id;
        stockResv.OwnerId        = testUsr.Id;
        insert stockResv;

    }


    @isTest
    static void pushDataContactTM(){
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new VSMSHelperClassMock( Label.VSMS_Webservice ) );
            for( Contact cnt : [SELECT Id, CreatedBy.Name FROM Contact WHERE IsPersonAccount = false])
            {
                VSMSHelperClass.pushData( String.valueOf(cnt.Id), cnt.CreatedBy.Name, String.valueOf(Math.random()).substring(2, 6) );
            }

            VSMSHelperClass.testSend( '', '', '' );
        System.Test.stopTest();
    }

    
    /*@isTest
    static void pushDataByPATM(){
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new VSMSHelperClassMock( Label.VSMS_Webservice ) );
            for( Account act : [SELECT Id, CreatedBy.Name FROM Account WHERE IsPersonAccount = true ])
            {
                VSMSHelperClass.pushDataByPA( String.valueOf(act.Id), act.CreatedBy.Name, String.valueOf(Math.random()).substring(2, 6) );
            }
        System.Test.stopTest();
    }*/


    @isTest
    static void insertSRTM(){
        List<Stock_Reservation__c> lstStkResv = [SELECT Id, CreatedBy.Name, Owner.name FROM Stock_Reservation__c];
        System.debug('jilaka---lstStkResv = ' + lstStkResv);
        System.assert( lstStkResv.size() == 1 );
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new VSMSHelperClassMock( Label.VSMSSRInsert ) );
            VSMSHelperClass.insertSR( String.valueOf(lstStkResv.get(0).Id), lstStkResv.get(0).CreatedBy.Name );
        System.Test.stopTest();
    }


    @isTest
    static void updateSRTM(){
        List<Stock_Reservation__c> lstStkResv = [SELECT Id, CreatedBy.Name, Owner.name FROM Stock_Reservation__c];
        System.assert( lstStkResv.size() == 1 );
        System.Test.startTest();
            Test.setMock( HttpCalloutMock.class, new VSMSHelperClassMock( Label.VSMSSRUpdate ) );
            VSMSHelperClass.updateSR( String.valueOf(lstStkResv.get(0).Id), lstStkResv.get(0).CreatedBy.Name );
        System.Test.stopTest();
    }


    public class VSMSHelperClassMock implements HttpCalloutMock{
        
        String strEndPoint = '';
        public VSMSHelperClassMock( String endpointRef ){
            strEndPoint = endpointRef;
        }
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals(strEndPoint, req.getEndpoint());

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody( 'Testing' );
            res.setStatusCode(200);
            return res;
        }
    }
}