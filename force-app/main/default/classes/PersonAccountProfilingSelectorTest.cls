/** *****
 * Description : Test Class for PersonAccountProfilingSelector
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210118             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class PersonAccountProfilingSelectorTest {
    
    @isTest
    private static void testGetPAProfilingsAccountIds() {
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'ra@testing.com', 'Customer');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, personAcc.Id, 'RA_Person_Account_Profiling_RT');
    
        PersonAccountProfilingSelector selector = new PersonAccountProfilingSelector();
        List<Person_Account_Profiling__c> result = selector.getProfilingsAccountIds(new Set<Id>{personAcc.Id});
        System.assertNotEquals(null, result.size());
        
    }
}