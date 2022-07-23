/** *****
 * Description : Test Class for UsedCarVehicleSizingService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20211015         TPhan@aodigy         Created Initial Version 
 * 
** *****/
@isTest
private class UsedCarVehicleSizingServiceTest 
{
    @isTest 
    static void test_GetUsedCarSizingsByNames()
    {        
        Used_Car_Vehicle_Sizing__c vehSizing = Test_DataFactory.createUCVehicleSizing(true, 'AUDI', 'A4', 'Compact');
        System.assertEquals(UsedCarVehicleSizingService.getUsedCarSizingsByNames(new Set<String> {'AUDI A4'}).size(), 1);
    }
  
    @isTest 
    static void test_CheckAndCreateNewUCSizing()
    {        
        Used_Car_Vehicle_Sizing__c vehSizing = Test_DataFactory.createUCVehicleSizing(true, 'AUDI', 'A4', 'Compact');
        Map<String, UsedCarVehicleSizingService.ModelGroup> groupMap = new Map<String, UsedCarVehicleSizingService.ModelGroup>();
        groupMap.put('AUDI A4', new UsedCarVehicleSizingService.ModelGroup('AUDI', 'A4'));
        groupMap.put('BMW B5', new UsedCarVehicleSizingService.ModelGroup('BMW', 'B5'));
        UsedCarVehicleSizingService.checkAndCreateNewUCSizing(groupMap);
    }
}