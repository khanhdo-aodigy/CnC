@isTest
private class FOBAddtionalContractSelectorTest {
    @TestSetup
    static void setUp(){
        Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC');
        insert po;

        Forward_FOB_Contract__c fobContract = new Forward_FOB_Contract__c(Status__c = 'Active',
                                                                         Cover_Percentage__c = 75,
                                                                         Spot_Rate__c = 1.2345663,
                                                                         Premium_Discount__c = 1.1,
                                                                         Purchase_Order__c = po.Id);
        insert fobContract;

        FOB_Additional_Contract__c addnlFOBContract = new FOB_Additional_Contract__c(Forward_FOB_Contract__c = fobContract.Id,
                                                                                     Status__c = 'Forward Contract Sell');
        insert addnlFOBContract;
    }

    @isTest
    static void getRecordsByFFOBContractds_Test(){
        Forward_FOB_Contract__c fobContract = [SELECT ID, Status__c FROM Forward_FOB_Contract__c];
        FOB_Additional_Contract__c addnlContract = [SELECT ID FROM FOB_Additional_Contract__c WHERE Forward_FOB_Contract__c = :fobContract.Id];
        FOBAddtionalContractSelector fac = new FOBAddtionalContractSelector();
        fac.getRecordsByFFOBContractds(new List<Id>{addnlContract.Id});
    }
}