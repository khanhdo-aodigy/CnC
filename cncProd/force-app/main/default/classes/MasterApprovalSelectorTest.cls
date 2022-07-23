@isTest
private class MasterApprovalSelectorTest {
    
    @isTest
    private static void testSelectMasterApprovalByUniqueKey() {
        ListView listview = [SELECT Id FROM ListView WHERE SObjectType = 'Reward_Usage__c' LIMIT 1]; // AND Name = 'Expired Usages - KIA'
        String listViewId = listview.Id;        
        String source = 'AfterSales';
        String uniqueKey =  String.valueOf(Date.today()) + '_' + listViewId + '_' + source;
        Master_Approval__c masterApproval = Test_DataFactory.createMasterApproval(true, 10000, uniqueKey);
    	
        Test.startTest();
        MasterApprovalSelector masterApprovalSel = new MasterApprovalSelector();
        Master_Approval__c result = masterApprovalSel.selectMasterApprovalByUniqueKey(uniqueKey);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

}