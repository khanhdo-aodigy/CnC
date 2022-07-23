/** *****
 * Description : Test Class for MBTestDriveDailyLogService
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211101           TPhan@aodigy        Created Initial Version. 
 * ** *****/

@isTest
private class MBTestDriveDailyLogServiceTest 
{
    @isTest
    static void test_GetMBTDDailyLogsByCreatedDateAndStatusAndVehicles()
    {
        Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(true, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
        MB_Test_Drive_Daily_Log__c log = Test_DataFactory.createMBTestDriveDailyLog(true, 1000, 1050, 'Closed', veh.Id);
        System.assertEquals(1, MBTestDriveDailyLogService.getMBTDDailyLogsByCreatedDateAndStatusAndVehicles(String.valueOfGmt(Date.today()), 'Closed', new Set<Id>{veh.Id}, '=', null, null).size());
    }  
}