@isTest
public class MasterApprovalServiceTest {
	@isTest
    private static void testGetMasterApprovalByUniqueKey() {
        ListView listview = [SELECT Id FROM ListView WHERE SObjectType = 'Reward_Usage__c' LIMIT 1]; // AND Name = 'Expired Usages - KIA'
        String listViewId = listview.Id;        
        String source = 'AfterSales';
        String uniqueKey =  String.valueOf(Date.today()) + '_' + listViewId + '_' + source;
        Master_Approval__c masterApproval = Test_DataFactory.createMasterApproval(true, 10000, uniqueKey);
    	
        Test.startTest();
        Master_Approval__c result = MasterApprovalService.getMasterApprovalByUniqueKey(uniqueKey);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}