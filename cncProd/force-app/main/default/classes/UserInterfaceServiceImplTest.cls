@isTest
private class UserInterfaceServiceImplTest {
	
    @isTest
    private static void test() {
        list<map<string, string>> results = UserInterfaceServiceImpl.getPickListValueOfObject('Sales_Agreement__c', 'Branch_Code__c');
        system.assertEquals(3, results.size());
    }
}