@isTest
public class CMBatchCreateMasterApprovalTest {
    static Id debitUsageTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Debit').getRecordTypeId();
    static Reward_Profile__c rewardProfile;
    
    @isTest
    private static void setupData() {
        rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');        
    }
    
    @isTest
    private static void testHappyPath_NoMasterApprovalExist() {
        setupData();
        Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
        reward.Credit__c = 20000;
        insert reward;
        
        List<Reward_Usage__c> debitUsages = new List<Reward_Usage__c >();
        Double totalAmount = 0;
        for(Integer i=0; i< 5; i++) {
            Reward_Usage__c debitUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
            debitUsage.Credit_Amount__c = 1000 + 100*i;
            debitUsage.Status__c = 'Expired';
            debitUsage.Type__c = 'Expiry';
            debitUsages.add(debitUsage);
            totalAmount += debitUsage.Credit_Amount__c;
        }       
        insert debitUsages;
        
        //ListView listview = [SELECT Id FROM ListView WHERE SObjectType = 'Reward_Usage__c' LIMIT 1]; // AND Name = 'Expired Usages - KIA'
        String listViewId = '00xdummylistviewid';
        String query = 'SELECT Name, RecordType.Name, Reward__r.Name, Brand__c, Credit_Amount__c, toLabel(Status__c), toLabel(Channel__c), Source__c, Transaction_Date__c, CreatedBy.Name, COST__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Reward__c, CreatedBy.Id, CreatedById FROM Reward_Usage__c WHERE Status__c = \'Expired\' AND Type__c = \'Expiry\'';
        Test.startTest();
        Database.executeBatch(new CMBatchCreateMasterApproval(listViewId ,query));
    	Test.stopTest();
        List<Master_Approval__c> result = [SELECT Id, Request_Type__c, Total_Amount__c, Unique_Key__c FROM Master_Approval__c];
    	System.assertEquals(1, result.size());
        System.assertEquals('Writeback', result[0].Request_Type__c);
        System.assertEquals(totalAmount, result[0].Total_Amount__c);
        String expectedUniqueKey = String.valueOf(Date.today()) + '_' + listViewId + '_' + 'VehicleSales';        
        System.assertEquals(expectedUniqueKey, result[0].Unique_Key__c);
    }
    
    @isTest
    private static void testHappyPath_withExistingMasterApproval() {
        setupData();
        //ListView listview = [SELECT Id FROM ListView WHERE SObjectType = 'Reward_Usage__c' LIMIT 1]; //AND Name = 'Expired Usages - KIA'
        String listViewId = '00xdummylistviewid';
        String query = 'SELECT Name, RecordType.Name, Reward__r.Name, Brand__c, Credit_Amount__c, toLabel(Status__c), toLabel(Channel__c), Source__c, Transaction_Date__c, CreatedBy.Name, COST__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Reward__c, CreatedBy.Id, CreatedById FROM Reward_Usage__c AND Status__c = \'Expired\' AND Type__c = \'Expiry\'';
        
        Reward__c salesGoodWillReward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
        salesGoodWillReward.Credit__c = 20000;
        salesGoodWillReward.Source__c = 'Sales - Goodwill';
        insert salesGoodWillReward;
        
        String source = 'AfterSales';
        Double masterApprovalTotalAmount = 10000;
        Double expectedUpdatedTotalAmount = masterApprovalTotalAmount;
        Master_Approval__c masterApproval = Test_DataFactory.createMasterApproval(true, masterApprovalTotalAmount, String.valueOf(Date.today()) + '_' + listViewId + '_' + source);
        List<Reward_Usage__c> debitUsages = new List<Reward_Usage__c >();
        for(Integer i=0; i< 5; i++) {
            Reward_Usage__c debitUsage = Test_DataFactory.createRewardUsage(false, salesGoodWillReward.Id, 'Hold', 'Debit');
            debitUsage.Credit_Amount__c = 1000 + 100*i;
            debitUsage.Status__c = 'Expired';
            debitUsage.Type__c = 'Expiry';
            debitUsage.Master_Approval__c = masterApproval.Id;
            debitUsages.add(debitUsage);
            expectedUpdatedTotalAmount += debitUsage.Credit_Amount__c;
        }       
        insert debitUsages;
        Test.startTest();
        Database.executeBatch(new CMBatchCreateMasterApproval(listViewId ,query));
    	Test.stopTest();
        List<Master_Approval__c> result = [SELECT Id, Request_Type__c, Total_Amount__c, Unique_Key__c FROM Master_Approval__c];
        System.assertEquals(expectedUpdatedTotalAmount, result[0].Total_Amount__c);
    }

}