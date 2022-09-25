@isTest
private class ForwardDutyContractSelectorTest {
    @TestSetup
    static void setUp(){
        Purchase_Order__c po = new Purchase_Order__c(Franchise__c = 'KIAPC');
        insert po;

        Forward_Duty_Contract__c dutyContract = new Forward_Duty_Contract__c(Status__c = 'Active',
                                                                             Cover_Percentage__c = 75,
                                                                             Spot_Rate__c = 1.2345663,
                                                                             Premium_Discount__c = 1.1,
                                                                             Purchase_Order__c = po.Id);
        insert dutyContract;

    }

    @isTest
    static void getRecordsByPOIds_Test(){
        Forward_Duty_Contract__c dutyContract = [SELECT ID, Status__c FROM Forward_Duty_Contract__c];
        ForwardDutyContractSelector fdc = new ForwardDutyContractSelector();
        fdc.getRecordsByPOIds(new List<Id>{dutyContract.Id});
    }
}