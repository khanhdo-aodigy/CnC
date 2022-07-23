@isTest
private class PersonAccountProfilingBLTest {
    @isTest
    private static void testUpdateFieldOnParentAccount() {
        TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', true);
        Account customer = Test_DataFactory.createPA(true, 'Bob', 'bob@gmail.com', 'Customer');
        List<Person_Account_Profiling__c> profilingList = new List<Person_Account_Profiling__c>();
        Person_Account_Profiling__c profilingMB = Test_DataFactory.createPAProfiling(false, customer.Id, 'MB_Person_Account_Profiling_RT');
        Person_Account_Profiling__c profilingRA = Test_DataFactory.createPAProfiling(false, customer.Id, 'RA_Person_Account_Profiling_RT');
        profilingList.add(profilingMB);
        profilingList.add(profilingRA);
        insert profilingList;
        PersonAccountProfilingBL.updateAccounts(profilingList);        
    }
    
    @isTest
    private static void testPreventDuplicateProfiling_OnInsert() {
        Account customer = Test_DataFactory.createPA(true, 'Bob', 'bob@gmail.com', 'Customer');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, customer.Id, 'MB_Person_Account_Profiling_RT');
        
        TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', true);
        Person_Account_Profiling__c dupProfiling = Test_DataFactory.createPAProfiling(false, customer.Id, 'MB_Person_Account_Profiling_RT');
        PersonAccountProfilingBL.preventDuplicateProfiling('insert', new List<Person_Account_Profiling__c>{dupProfiling});
        insert dupProfiling;
    }
    
    @isTest
   	private static void testPreventDuplicateProfiling_OnUpdate() {
        Account customer = Test_DataFactory.createPA(true, 'Bob', 'bob@gmail.com', 'Customer');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, customer.Id, 'MB_Person_Account_Profiling_RT');
        
        Account customer1 = Test_DataFactory.createPA(true, 'Anna', 'anna@gmail.com', 'Customer');
        Person_Account_Profiling__c dupProfiling = Test_DataFactory.createPAProfiling(true, customer1.Id, 'MB_Person_Account_Profiling_RT');
        
        TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', true);
        dupProfiling.Account__c = customer.Id;
        List<Id> profilingToDel = PersonAccountProfilingBL.preventDuplicateProfiling('update', new List<Person_Account_Profiling__c>{dupProfiling});
        update dupProfiling;
        PersonAccountProfilingBL.deleteDupProfiles(profilingToDel);
    }

}