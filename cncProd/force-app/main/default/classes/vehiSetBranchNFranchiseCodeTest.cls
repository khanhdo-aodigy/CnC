@isTest
private class vehiSetBranchNFranchiseCodeTest {
    
    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Vehicle_Master__c', true);
        Model__c TestMod = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,'testRun',TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(true,'test123',TestVar.id,TestMod.id);
    } 
    
	@isTest
    private static void testOnInsert() {
        Model__c TestMod = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');        
        Variant__c TestVar = Test_DataFactory.createVariant(true,'testRun',TestMod.Id,'CCA'); 
        Vehicle_Master__c testVh = Test_DataFactory.createVehicleMaster(true,'test123',TestVar.id,TestMod.id);
    }
}