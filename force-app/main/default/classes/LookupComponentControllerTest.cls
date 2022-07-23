/** ******
 * Description : Test class for LookupComponentController.cls
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200908             TP@aodigy.com                   Created Initial Version. 
 * 
***** **/

@isTest
private class LookupComponentControllerTest 
{
    @isTest
    static void Test_getLookupRecords()
    {
        User u = Test_DataFactory.createUser(true, 'TEST', 'test1');    
        
        System.assertEquals(u.Id, LookupComponentController.getLookupRecords('User', 'TEST', '', '').get(0).Id);
    }
}