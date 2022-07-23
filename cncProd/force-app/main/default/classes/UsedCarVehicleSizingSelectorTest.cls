/** *****
 * Description : Test Class for UsedCarVehicleSizingSelector.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20211015         TPhan@aodigy         Created Initial Version 
 * 
** *****/
@isTest
private class UsedCarVehicleSizingSelectorTest 
{
    @isTest 
    static void test_SelectUsedCarSizingsByNames()
    {        
        Used_Car_Vehicle_Sizing__c vehSizing = Test_DataFactory.createUCVehicleSizing(true, 'AUDI', 'A4', 'Compact');
        UsedCarVehicleSizingSelector sel = new UsedCarVehicleSizingSelector();
        System.assertEquals(sel.selectUsedCarSizingsByNames(new Set<String> {'AUDI A4'}).size(), 1);
    }
}