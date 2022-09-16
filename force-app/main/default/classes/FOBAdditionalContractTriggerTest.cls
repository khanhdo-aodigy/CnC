@isTest(seeAllData=false)
private class FOBAdditionalContractTriggerTest {
	@testSetup
    static void setUp() {
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
                                                                         Purchase_Order__c = po.Id);
        insert fobContract;
    }

    @isTest
    static void Test_afterUpdate_Completed() {
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
        Vehicle_Master2__c vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
        FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                     Status__c = 'Forward Contract Sell');
        insert addnlFOBContract;

        Forward_FOB_Contract_Line_Item__c fobItem = new Forward_FOB_Contract_Line_Item__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                          FOB_Additional_Contract__c = addnlFOBContract.Id,
                                                                                          Stock_Vehicle_Master__c = vMaster.Id);
        insert fobItem;

        FOB_Additional_Contract__c addnlContract = [SELECT ID, Status__c FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        addnlContract.Status__c = 'Completed';
        update addnlContract;


        // Test.startTest();
        //fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
        //vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
        // System.assertEquals(true, vMaster.FOB_Done__c);
        //Test.stopTest(); 
    }

    @isTest
    static void Test_afterUpdate_Sold() {
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
        Vehicle_Master2__c vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
        FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                     Status__c = 'Forward Contract Sell');
        insert addnlFOBContract;

        Forward_FOB_Contract_Line_Item__c fobItem = new Forward_FOB_Contract_Line_Item__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                          FOB_Additional_Contract__c = addnlFOBContract.Id,
                                                                                          Stock_Vehicle_Master__c = vMaster.Id);
        insert fobItem;

        FOB_Additional_Contract__c addnlContract = [SELECT ID, Status__c FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        addnlContract.Status__c = 'Completed';
        update addnlContract;
        Test.startTest();
        fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
        vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
        System.assertEquals('Sold', fobContract.Status__c);
        Test.stopTest(); 
    }
}