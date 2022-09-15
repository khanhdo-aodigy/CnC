@isTest
private class ForwardFOBContractSelectorTest {
    @TestSetup
    static void setUp(){
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        // Create Purchase Order
		Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC');
        insert po;
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID,
                                                            Purchase_Order__c = po.Id);
        insert vMaster;
        Forward_FOB_Contract__c fobContract = new Forward_FOB_Contract__c(Status__c = 'Active',
                                                                         Cover_Percentage__c = 75,
                                                                         Spot_Rate__c = 1.2345663,
                                                                         Premium_Discount__c = 1.1,
                                                                         Forward_Contract_Buy_Approved__c = false,
                                                                         Purchase_Order__c = po.Id);
        insert fobContract;

        FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                      Status__c = 'Forward Contract Sell');
        insert addnlFOBContract;
    }

    @isTest
    static void getRecordsByPOIds_Test(){
        Forward_FOB_Contract__c fobContract = [SELECT ID, Forward_Contract_Buy_Approved__c, Cover_Percentage__c FROM Forward_FOB_Contract__c];
        ForwardFOBContractSelector fob = new ForwardFOBContractSelector();
        fob.getRecordsByPOIds(new List<Id>{fobContract.Id});
    }

    @isTest
    static void selectFOBAddContract_Test(){
        Forward_FOB_Contract__c fobContract = [SELECT ID, Forward_Contract_Buy_Approved__c, Cover_Percentage__c FROM Forward_FOB_Contract__c];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        ForwardFOBContractSelector fob = new ForwardFOBContractSelector();
        fob.selectFOBAddContract(new List<Id>{addnlContract.Id});
    }
}