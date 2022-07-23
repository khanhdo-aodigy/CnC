@isTest
private class PersonAccountMergingServiceTest {
	@isTest
    private static void testBypassAutomation(){
        PersonAccountMergingService.bypassAutomation(true);
        PersonAccountMergingService.bypassAutomation(false);
    }
    
    @isTest
    private static void testGetFields(){
        List<String> objList = new List<String>{'Person_Account_Profiling__c', 'Registered_Vehicle__c', 'Opportunity', 'Test_Drive__c', 'Case', 'Feedback__c', 'Reward__c', 'Event_Registration__c'};
        for(String objectName: objList) {
        	PersonAccountMergingService.getFieldNameOnChildObj(objectName);
        }
    }
}