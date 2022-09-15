@isTest(seeAllData=false)
private class TreasuryManagementServiceTest {
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

        FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                     Status__c = 'Forward Contract Sell');
        insert addnlFOBContract;

        Forward_FOB_Contract_Line_Item__c fobItem = new Forward_FOB_Contract_Line_Item__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                          FOB_Additional_Contract__c = addnlFOBContract.Id,
                                                                                          Stock_Vehicle_Master__c = vMaster.Id);
        insert fobItem;

        Forward_Duty_Contract__c dutyContract = new Forward_Duty_Contract__c(Status__c = 'Active',
                                                                             Cover_Percentage__c = 75,
                                                                             Spot_Rate__c = 1.2345663,
                                                                             Premium_Discount__c = 1.1,
                                                                             Purchase_Order__c = po.Id);
        insert dutyContract;

        Duty_Additional_Contract__c addnlDutyContract = new Duty_Additional_Contract__c(Forward_Duty_Contract__c = dutyContract.Id,
                                                                                        Status__c = 'Forward Contract Sell');
        insert addnlDutyContract;
        Forward_Duty_Contract_Line_Item__c dutyItem = new Forward_Duty_Contract_Line_Item__c(Forward_Duty_Contract__c = dutyContract.Id,
                                                                                         	Duty_Additional_Contract__c = addnlDutyContract.Id,
                                                                                            Stock_Vehicle_Master__c = vMaster.Id);
        insert dutyItem;		
    }

    @isTest
    static void Test_getRecordsByIds() {
        Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
        Test.startTest();
        List<sObject> result = TreasuryManagementService.getRecordsByIds('Purchase_Order__c', new List<String>{'Id'}, 'Id', new List<String>{po.Id});
        System.assertNotEquals(0, result.size());
        Test.stopTest();
    }

    @isTest
    static void Test_getFieldDescription() {
        Test.startTest();
        Map<String, Schema.DescribeFieldResult> result = TreasuryManagementService.getFieldDescription('Purchase_Order__c');
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    static void Test_calculateContractAmounts_ForwardFOBContract() {
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c LIMIT 1];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];
        
        Test.startTest();
        TreasuryManagementService.calculateContractAmounts(new List<sObject>{fobItem}, 'Forward_FOB_Contract__c', fobContract);
        Test.stopTest();
    }
    
    @isTest
    static void Test_calculateContractAmounts_ForwardDutyContract() {
        Forward_Duty_Contract__c dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c LIMIT 1];
        //FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        Forward_Duty_Contract_Line_Item__c dutyItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c
                                                     FROM Forward_Duty_Contract_Line_Item__c 
                                                     WHERE Forward_Duty_Contract__c =: dutyContract.Id];
        
        Test.startTest();
        TreasuryManagementService.calculateContractAmounts(new List<sObject>{dutyItem}, 'Forward_Duty_Contract__c', dutyContract);
        Test.stopTest();
    }

    @isTest
    static void Test_calculateContractAmounts_FOBAdditionalContract() {
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c LIMIT 1];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Spot_Contract_Amount__c,Cover_Amount_Foreign__c
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE FOB_Additional_Contract__c =: addnlContract.Id];
        
        Test.startTest();
        TreasuryManagementService.calculateContractAmounts(new List<sObject>{fobItem}, 'FOB_Additional_Contract__c', addnlContract);
        Test.stopTest();
    }
    
    static void Test_calculateContractAmounts_DutyAdditionalContract() {
        Forward_Duty_Contract__c dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c LIMIT 1];
        Duty_Additional_Contract__c addnlDutyContract = [SELECT ID FROM Duty_Additional_Contract__c WHERE Forward_Duty_Contract__c = :dutyContract.Id];
        Forward_Duty_Contract_Line_Item__c dutyItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c
                                                     FROM Forward_Duty_Contract_Line_Item__c 
                                                     WHERE Forward_Duty_Contract__c =: dutyContract.Id];
        
        Test.startTest();
        TreasuryManagementService.calculateContractAmounts(new List<sObject>{dutyContract}, 'Duty_Additional_Contract__c', addnlDutyContract);
        Test.stopTest();
    }
    
    @isTest
    static void Test_processSoldContract(){
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c LIMIT 1];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];
        
        Test.startTest();
        TreasuryManagementService.processSoldContract('Forward_FOB_Contract_Line_Item__c', 'Forward_FOB_Contract__c', new Set<String>{fobContract.Id});
        Test.stopTest();
    }
    
    @isTest
    static void Test_processCompletedContract(){
        Vehicle_Master2__c vMaster = [SELECT Id FROM Vehicle_Master2__c LIMIT 1];
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c LIMIT 1];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        Forward_FOB_Contract_Line_Item__c fobItem = [SELECT ID, Cover_Amount__c,Execution_Amount__c,Cover_Amount_Spot_Rate__c,Cover_Amount_Contract_Rate__c,Cover_Amount_Foreign__c,Stock_Vehicle_Master__c
                                                     FROM Forward_FOB_Contract_Line_Item__c 
                                                     WHERE Forward_FOB_Contract__c =: fobContract.Id];
        
        Test.startTest();
        TreasuryManagementService.processCompletedContract(new List<sObject>{fobItem}, true);
        Test.stopTest();
    }

    // @isTest
    // static void Test_processFOBContract() {
    //     Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
    //     Vehicle_Master2__c vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
    //     Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     FOB_Additional_Contract__c addnlContract = [SELECT ID, Status__c FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
    //     addnlContract.Status__c = 'Completed';
    //     update addnlContract;

    //     Test.startTest();
    //     TreasuryManagementService.processFOBContract(new Set<Id>{fobContract.Id});
    //     fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
    //     System.assertEquals(true, vMaster.FOB_Done__c);
    //     System.assertEquals('Sold', fobContract.Status__c);
    //     Test.stopTest();        
    // }

    // @isTest
    // static void Test_processDutyContract() {
    //     Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
    //     Forward_Duty_Contract__c dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     Vehicle_Master2__c vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
    //     Duty_Additional_Contract__c addnlContract = [SELECT ID, Status__c FROM Duty_Additional_Contract__c WHERE Forward_Duty_Contract__c = :dutyContract.Id];
    //     addnlContract.Status__c = 'Completed';
    //     update addnlContract;

    //     Test.startTest();
    //     TreasuryManagementService.processDutyContract(new Set<Id>{dutyContract.Id});
    //     dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     vMaster =  [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
    //     System.assertEquals(true, vMaster.Duty_Done__c);
    //     System.assertEquals('Sold', dutyContract.Status__c);
    //     Test.stopTest();
    // }

    // @isTest
    // static void Test_processDutyContract_Sell_on_Maturity() {
    //     Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
    //     Forward_Duty_Contract__c dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     Duty_Additional_Contract__c addnlContract = [SELECT ID, Status__c FROM Duty_Additional_Contract__c WHERE Forward_Duty_Contract__c = :dutyContract.Id];
    //     addnlContract.Status__c = 'Forward Contract Sell on Maturity';
    //     update addnlContract;

    //     Test.startTest();
    //     TreasuryManagementService.processDutyContract(new Set<Id>{dutyContract.Id});
    //     dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     System.assertEquals('Sold', dutyContract.Status__c);
    //     Test.stopTest();
    // }

    // @isTest
    // static void Test_processDutyContract_Invalid() {
    //     Purchase_Order__c po = [SELECT ID FROM Purchase_Order__c];
    //     Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     Vehicle_Master2__c vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
    //     FOB_Additional_Contract__c addnlContract = [SELECT ID, Status__c FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
    //     addnlContract.Status__c = 'Forward Contract Execute';
    //     update addnlContract;

    //     Test.startTest();
    //     TreasuryManagementService.processFOBContract(new Set<Id>{fobContract.Id});
    //     fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c WHERE Purchase_Order__c = :po.Id];
    //     vMaster = [SELECT ID, FOB_Done__c, Duty_Done__c FROM Vehicle_Master2__c WHERE Purchase_Order__c = :po.Id];
    //     System.assertEquals(false, vMaster.FOB_Done__c);
    //     System.assertEquals('Active', fobContract.Status__c);
    //     Test.stopTest();          
    // }
}