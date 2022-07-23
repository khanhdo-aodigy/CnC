/** ******
 * Description: Test class for PersonAccountProfilingTrigger
 *                         and PersonAccountProfilingTriggerHandler
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		      Description
 * 20210810             khanh.do@aodigy.com       Created Initial Version. 
** ******/
@isTest
private class PersonAccountProfilingTriggerTest {
	@isTest
    private static void testBypassTrigger(){
        TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', true);
        Account customer = Test_DataFactory.createPA(true, 'Bonchon', 'bonchon@test.com', 'Customer');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, customer.Id, 'MB_Person_Account_Profiling_RT');
        TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', false);
    }
    
    @isTest
    private static void testTriggerOnCreateAndUpdate(){
		Account customer = Test_DataFactory.createPA(true, 'Bonchon', 'bonchon@test.com', 'Customer');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, customer.Id, 'MB_Person_Account_Profiling_RT');
        
        Account newCustomer = Test_DataFactory.createPA(true, 'Bonbon', 'bonbon@test.com', 'Customer');
        Person_Account_Profiling__c dupProfiling = Test_DataFactory.createPAProfiling(true, newCustomer.Id, 'MB_Person_Account_Profiling_RT');
        
        profiling = [SELECT Id, Account__c FROM Person_Account_Profiling__c WHERE Id = :profiling.Id];
        profiling.Account__c = newCustomer.Id;
       	update profiling;
    }
}