/**
 * @File Name          : PackageHeaderTest.cls
 * @Description        : 
 * @Author             : Joseph Tey
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/21/2020, 11:01:33 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/21/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
//Start of RN2020Q1010
@isTest
private class PackageHeaderSelectorTest {

    @TestSetup
    static void makeData(){
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        insert stockReservation;
        // Create Package Header
		//Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC');
        Package_Header__c pckHeader = new Package_Header__c(Model_Master__c = modelCode.Id, PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A', PKH_PKGPRICE__c=1000000);
        insert pckHeader;
        
    }

    @isTest
    static void Test_selectByModelsAndStaus(){
        Model_Master__c modelMaster = [Select Id from Model_Master__c limit 1];
        set <id> ids = new set<id>();
        ids.add(modelMaster.Id);
        PackageHeaderSelector pkHdrSelector = new PackageHeaderSelector();
        LIST<Package_Header__c> pkHdrList = pkHdrSelector.selectByModelsAndStaus(ids, 'A');
        System.assertNotEquals(null, pkHdrSelector);
        
    }
}
//End of RN2020Q1010