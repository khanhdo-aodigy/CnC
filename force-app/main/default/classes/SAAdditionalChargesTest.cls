@isTest
private class SAAdditionalChargesTest {

    @testSetup
    static void setUp() {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        
        // Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id); 
        // Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(true, 'CCK', 'NO9999', stockReservation.Id, 'test customer');

        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Test Customer';

        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                        ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        //* create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Opportunity__c = oppt.Id;
        insert stockReservation;

        //* sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        
        salesAgreement.emailaddress__c = 'test@aodigy.com';
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        salesAgreement.Branch_Code__c = branchCode;
        update salesAgreement;

        Additional_Charges_Master__c additionalChargesMaster = Test_DataFactory.createAdditionalChargesMaster(true, 'TestChCode');
        
        SA_Additional_Charge__c saAdditionalCharge = Test_DataFactory.createSAAdditionalCharge(true, additionalChargesMaster.Id, salesAgreement.Id);    
    }    
    
    @isTest
    static void Test_setVSMSCompoundPrimaryKey() {
        Map<Id, Sales_Agreement__c> salesAgreementById = new Map<Id, Sales_Agreement__c>([Select Id From Sales_Agreement__c]);
        List<SA_Additional_Charge__c> additionalCharges = new SaAddnlChargeSelector().selectAddnlChargeBySalesAgreementIds(salesAgreementById.keySet());
        new SAAdditionalCharges(additionalCharges).setVSMSCompoundPrimaryKey();
        
        SA_Additional_Charge__c saAdditionalCharge = [Select Sales_Agreement__r.UniqueBranchCode__c, Sales_Agreement__r.FranchiseCode__c,
                                                      SAD_SOH_SONO__c, SAD_ADM_CHRGCD__c, VSMS_Compound_Primary_Key__c From SA_Additional_Charge__c];   
        System.assertEquals(concatIfNotNull(
            new Set<String>{saAdditionalCharge.Sales_Agreement__r.UniqueBranchCode__c,
                saAdditionalCharge.Sales_Agreement__r.FranchiseCode__c,
                saAdditionalCharge.SAD_SOH_SONO__c,
                saAdditionalCharge.SAD_ADM_CHRGCD__c}
        ), saAdditionalCharge.VSMS_Compound_Primary_Key__c);
    }
    
   /*
    @isTest 
 
    static void updateSalesAgreementOnChangesSAAdditonalCharges(){
        Map<Id, Sales_Agreement__c> salesAgreementById = new Map<Id, Sales_Agreement__c>([Select Id From Sales_Agreement__c]);
        List<SA_Additional_Charge__c> additionalCharges = new SaAddnlChargeSelector().selectAddnlChargeBySalesAgreementIds(salesAgreementById.keySet());
       
    }
    */
    private static String concatIfNotNull(Set<String> strs) {
        String retStr = '';
        for(String str : strs) {
            if(str != null) {
                retStr += str;
            }
        }
        
        return retStr;
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('SA_Additional_Charge__c', true);
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c LIMIT 1];
        Additional_Charges_Master__c additionalChargesMaster = [SELECT ID FROM Additional_Charges_Master__c LIMIT 1];
		SA_Additional_Charge__c saAdditionalCharge = Test_DataFactory.createSAAdditionalCharge(true, additionalChargesMaster.Id, salesAgreement.Id);    
        TriggerExclusion.excludeTrigger('SA_Additional_Charge__c', false);
    }
}