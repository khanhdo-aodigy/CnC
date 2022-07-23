/** *****
 * Description : Test Class for CourtesyVehicleSelector
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211101           TPhan@aodigy        Created Initial Version. 
 * ** *****/

@isTest
private class CourtesyVehicleSelectorTest 
{
    @isTest
    static void test_SelectCourtesyVehiclesByStatusAndBranchCode()
    {
        Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(true, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
        CourtesyVehicleSelector sel = new CourtesyVehicleSelector();
        System.assertEquals(1, sel.selectCourtesyVehiclesByStatusAndBranchCode('MB_Test_Drive', 'Available', 'CCI', 'MBP').size());
    }
}