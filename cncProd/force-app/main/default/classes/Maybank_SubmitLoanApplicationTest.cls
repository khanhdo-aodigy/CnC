/** *****
 * Description : Test Class for Maybank_SubmitLoanApplication.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201229            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class Maybank_SubmitLoanApplicationTest {
    
    @TestSetup
    static void makeData()
    {
        Test_DataFactory.createGlobalOrfDefaults(true);

        Model_Master__c modelMaster = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelMaster.Branch_Code__c = 'CCK';
        modelMaster.Franchise_Code__c = 'KIAPC';
        insert modelMaster;

        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode( false, modelMaster.Id);
        modelYearMaster.Branch_Code__c = 'CCK';
        modelYearMaster.Franchise_Code__c = 'KIAPC';
        insert modelYearMaster;

        Color_Master__c colorMaster = Test_DataFactory.createColorCode(false, 'Test Color Code', 'zCode', 'CCK', 'KIAPC');
        insert colorMaster;

        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(false, 'Test Trim Code');
        trimMaster.Branch_Code__c = 'CCK';
        trimMaster.Franchise_Code__c = 'KIAPC';
        insert trimMaster;

        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', Model_Master__c = modelMaster.Id, PKH_STATUS__c = 'A');
        insert pckHeader;

        Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test', ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'TR0507', stockReservation.Id, 'Test Customer');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.COE_Expiry_Date__c = Date.today().addDays(30);
        insert salesAgreement;

        Loan_Application__c loanAppl = Test_DataFactory.createLoanApplication(false, null, salesAgreement.Id);
        loanAppl.DealerID__c = 'testDealerId';
        insert loanAppl;
    }

    
    @isTest
    static void submitLoanApplicationTM() 
    {
        Sales_Agreement__c saObj = [SELECT Id, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'TR0507' ];
        System.assert( saObj <> null );

        List<Loan_Application__c> lstLoanAppl1 = [SELECT ID, Status__c, LOS_WAA_reference_number__c 
                                                 FROM Loan_Application__c 
                                                 WHERE Sales_Agreement__c =:saObj.ID 
                                                 AND LOS_WAA_reference_number__c = null LIMIT 10];
        System.assert( !lstLoanAppl1.isEmpty() );
        
        Test.setMock(HttpCalloutMock.class, new SubmitLoanApplicationMock());
        System.Test.startTest();
            Maybank_SubmitLoanApplication.FlowInputs fInput = new Maybank_SubmitLoanApplication.FlowInputs();
            fInput.salesAgreementNo   = saObj.SOH_SONO__c;
            fInput.salesAgrementId    = saObj.Id;
            fInput.amendmentIndicator = 'N';
            Maybank_SubmitLoanApplication.submitLoanApplication( new List<Maybank_SubmitLoanApplication.FlowInputs>{ fInput } );
        System.Test.stopTest();
    }


    public class SubmitLoanApplicationMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            string body = '{"Data":{"LOSRefNumber":"LWS090107010131","SalesAgreementNumber":"TR0507"},"Status":{"Code":"S","ErrorCode":"","ErrorDescription":""}}';
            HttpResponse respond = new HttpResponse();
            respond.setHeader('Content-Type', 'application/json');
            respond.setBody(body);
            respond.setStatusCode(200);
            respond.setStatus('200');
            return respond;
        }
    }
}