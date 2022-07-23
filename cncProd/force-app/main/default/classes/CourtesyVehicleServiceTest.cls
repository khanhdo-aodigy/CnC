/** *****
 * Description : Test Class for CourtesyVehicleService
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211101           TPhan@aodigy        Created Initial Version. 
 * ** *****/

@isTest
private class CourtesyVehicleServiceTest 
{
    @isTest
    static void test_GetCourtesyVehiclesByStatusAndBranchCode()
    {
        Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(true, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
        System.assertEquals(1, CourtesyVehicleService.getCourtesyVehiclesByStatusAndBranchCode('MB_Test_Drive', 'Available', 'CCI', 'MBP').size());
    }
}