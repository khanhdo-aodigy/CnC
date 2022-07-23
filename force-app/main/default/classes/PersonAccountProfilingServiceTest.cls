/** *****
 * Description : Test Class for PersonAccountProfilingService
 * 
 * Change History
 * Date(YYYYMMDD)       Name                    Description
 * 20210118             khanh.do@aodigy         Created Initial Version.
 * 
** *****/
@isTest
private class PersonAccountProfilingServiceTest {    

    @isTest
    private static void testGetRecordTypeId() {                                                 
        Id result = PersonAccountProfilingService.getRecordTypeId('RA_Person_Account_Profiling_RT');
        System.assertNotEquals(null, result);
        
        Id result1 = PersonAccountProfilingService.getRecordTypeId('Non_Exist');
        System.assertEquals(null, result1);
        
    }
}