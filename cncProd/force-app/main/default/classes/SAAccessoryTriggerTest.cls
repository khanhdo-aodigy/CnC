@isTest
private class SAAccessoryTriggerTest {
    
	@isTest
    static void Test_bypassTrigger() {
        TriggerExclusion.excludeTrigger('SA_Accessory__c', true);
        Sales_Agreement__c salesAgreement = createSalesAgreement('CCK', 'KIAPC', '1234');
        SA_Accessory__c accessory = createSalesAccessory(salesAgreement.Id);      
    }
    
	@isTest
    static void Test_clearServiceCreditPackageField() {
        Sales_Agreement__c salesAgreement = createSalesAgreement('CCK', 'KIAPC', '1234');
        SA_Accessory__c accessory = createSalesAccessory(salesAgreement.Id);

        accessory = [Select SAC_PACKAGE__c From SA_Accessory__c Where Id = :accessory.Id];
        
        accessory.SAC_PACKAGE__c = 'Y';
        update accessory;
        accessory = [Select SAC_PACKAGE__c From SA_Accessory__c Where Id = :accessory.Id];
	}    

    private static Sales_Agreement__c createSalesAgreement(String branchCode, String franchiseCode, String agreementNo) {
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

        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode);
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode, ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode);
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode, Model_Master__c = modelMaster.Id);
        insert modelYearMaster;
        insert new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                ADM_CHRGCD__c = 'R004');      
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = franchiseCode,
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;

        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Opportunity__c = oppt.Id;
        insert stockReservation;

        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.Id, 'test customer');
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;      
        
        return salesAgreement;
	}     
    
    private static SA_Accessory__c createSalesAccessory(Id agreementId) {
        Accessories_Master__c accessoryMaster = Test_DataFactory.createAccessoriesMaster(false);
        accessoryMaster.ACM_MNM_MAJGROUPCD__c = 'SVC_CREDIT';
        insert accessoryMaster;
        
        SA_Accessory__c accessory = new SA_Accessory__c(
        	Accessories_Master__c = accessoryMaster.Id,
            SAC_PACKAGE__c = 'Y',
            Sales_Agreement__c = agreementId
        );
        
        insert accessory;     
        
        return accessory;
    }
    
}