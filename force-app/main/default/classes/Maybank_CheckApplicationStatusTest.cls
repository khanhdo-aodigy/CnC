/** *****
 * Description : Test Class for Maybank_CheckApplicationStatus.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201229            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class Maybank_CheckApplicationStatusTest {
    
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
        loanAppl.LOS_WAA_reference_number__c = 'MayBankLOSWAA013109010701';
        loanAppl.DealerID__c = UserInfo.getUserId();
        insert loanAppl;
    }   

    
    @isTest
    static void checkApplicationStatusTM()
    {
        List<Loan_Application__c> lstLoanAppls1 = [SELECT Id, Sales_Agreement_No__c, DealerID__c, DealerEmpNo__c, LOS_WAA_reference_number__c, AmtIndicator__c 
                                                  FROM Loan_Application__c 
                                                  WHERE LOS_WAA_reference_number__c = 'MayBankLOSWAA013109010701'
                                                  AND Status__c = 'Draft'];
        System.assert( lstLoanAppls1.size() == 1 );                                                
        Test.setMock(HttpCalloutMock.class, new CheckApplicationStatusSuccessMock());
        System.Test.startTest();
            Maybank_CheckApplicationStatus.FlowInputs fInput = new Maybank_CheckApplicationStatus.FlowInputs();
            fInput.salesAgreementNo = lstLoanAppls1.get(0).Sales_Agreement_No__c;
            fInput.dealerID         = lstLoanAppls1.get(0).DealerID__c;
            fInput.losWaaNumber     = lstLoanAppls1.get(0).LOS_WAA_reference_number__c;
            fInput.amendmentInd     = lstLoanAppls1.get(0).AmtIndicator__c;
            List<Maybank_CheckApplicationStatus.FlowOutputs> lstFlwOutputs = new List<Maybank_CheckApplicationStatus.FlowOutputs>();
            lstFlwOutputs = Maybank_CheckApplicationStatus.checkApplicationStatus( new List<Maybank_CheckApplicationStatus.FlowInputs>{ fInput } );
            System.assert( !lstFlwOutputs.isEmpty());
            System.assert( lstFlwOutputs.get(0).api_returned_code == 'S' );
        System.Test.stopTest();

        List<Loan_Application__c> lstLoanAppls2 = [SELECT Id, Sales_Agreement_No__c, DealerID__c, DealerEmpNo__c, LOS_WAA_reference_number__c, AmtIndicator__c 
                                                  FROM Loan_Application__c 
                                                  WHERE LOS_WAA_reference_number__c = 'MayBankLOSWAA013109010701'
                                                  AND Status__c = 'AP'];
        System.assert( lstLoanAppls2.size() == 1 );        
    }


    public class CheckApplicationStatusSuccessMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            string body = '{"Status":{"Code":"S","ErrorCode":"","ErrorDescription":""},"Data":{"Status":"AP","SalesAgreementNumber":"SA0001","DealerID":"CA5656","LOSWaaNumber":"LWAA0000002"}}';
            HttpResponse respond = new HttpResponse();
            respond.setHeader('Content-Type', 'application/json');
            respond.setBody(body);
            respond.setStatusCode(200);
            respond.setStatus('200');
            return respond;
        }
    }

}