@isTest
private with sharing class VSMS_VDCUpdate_Test {

    @testSetup
    private static void prepare() {
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';

        //* create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        //* create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        //* success SA
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        
        salesAgreement.emailaddress__c = 'test@aodigy.com';
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Branch_Code__c = branchCode;
        salesAgreement.CommcaseNo__c = 'VEMCCNO_SUCCESS';
        salesAgreement.Car_Collection_Date__c = Date.newInstance(2020, 03, 18);
        salesAgreement.DocStatusVehicleDeliveryCertificate__c = true;
        insert salesAgreement;
    }

    @isTest
    private static void testCalloutSuccess() {
        
        Sales_Agreement__c sa = [SELECT ID, CommcaseNo__c, Car_Collection_Date__c, DocStatusVehicleDeliveryCertificate__c FROM Sales_Agreement__c WHERE CommcaseNo__c = 'VEMCCNO_SUCCESS'];
        
        Test.setMock(HttpCalloutMock.class, new VSMS_VDCUpdate_MockResponse());
        Test.startTest();
        string result = VSMS_VDCUpdate.updateVSMS(sa.ID);
        Test.stopTest();
        system.assertEquals('success', jsonRead('status', result));
        system.assertEquals('2020-03-18T00:00:00', jsonRead('message', result));

        list<Service_Data_Pool__c> sdp = [SELECT ID FROM Service_Data_Pool__c];
        system.assertEquals(1, sdp.size());
    }

    @isTest
    private static void testCalloutFail() {
        
        Sales_Agreement__c sa = [SELECT ID, CommcaseNo__c, Car_Collection_Date__c, DocStatusVehicleDeliveryCertificate__c FROM Sales_Agreement__c WHERE CommcaseNo__c = 'VEMCCNO_SUCCESS'];
        sa.CommcaseNo__c = 'VEMCCNO_FAIL';
        update sa;

        Test.setMock(HttpCalloutMock.class, new VSMS_VDCUpdate_MockResponse());
        Test.startTest();
        string result = VSMS_VDCUpdate.updateVSMS(sa.ID);
        Test.stopTest();
        
        system.assertEquals('error', jsonRead('status', result));
        system.assert(jsonRead('message', result).contains('error'));

        list<Service_Data_Pool__c> sdp = [SELECT ID FROM Service_Data_Pool__c];
        system.assertEquals(1, sdp.size());
    }

    @isTest
    private static void testVehicleConditionUpdate() {
        
        Sales_Agreement__c sa = [SELECT ID, CommcaseNo__c, Car_Collection_Date__c, DocStatusVehicleDeliveryCertificate__c FROM Sales_Agreement__c WHERE CommcaseNo__c = 'VEMCCNO_SUCCESS'];
        
        Test.setMock(HttpCalloutMock.class, new VSMS_VDCUpdate_MockResponse());
        Test.startTest();
        VSMS_VDCUpdate.updateVehicleCondition('VEM_CCNO', 'Test Drive', 5000, 'Showroom');
        Test.stopTest();
    }

    @isTest
    private static void testHandleException() {
        Sales_Agreement__c sa = [SELECT ID, CommcaseNo__c, Car_Collection_Date__c, DocStatusVehicleDeliveryCertificate__c FROM Sales_Agreement__c WHERE CommcaseNo__c = 'VEMCCNO_SUCCESS'];
        sa.CommcaseNo__c = 'VEMCCNO_NONE';
        update sa;

        Test.setMock(HttpCalloutMock.class, new VSMS_VDCUpdate_MockResponse());
        Test.startTest();
        string result = VSMS_VDCUpdate.updateVSMS(sa.ID);
        Test.stopTest();

        list<Logger_Data_Pool__c> ldp = [SELECT ID, Message__c FROM Logger_Data_Pool__c];
        system.debug(ldp);
        system.assert(ldp.size() > 0);
    }

    private static string jsonRead(string fieldName, string jsonString) {
        JSONParser jsonReader = JSON.createParser(jsonString);
        string fieldValue = '';
        while (jsonReader.nextToken() != null) {
            if (jsonReader.getCurrentToken() == JSONToken.FIELD_NAME && jsonReader.getText() == fieldName) {
                    jsonReader.nextToken();
                    fieldValue = jsonReader.getText();
                    break;
            }
        }
        return fieldValue;
    }
}