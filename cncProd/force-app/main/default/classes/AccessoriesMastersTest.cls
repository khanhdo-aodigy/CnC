@isTest
private class AccessoriesMastersTest {
	@testSetup
    private static void setUp() {
        // create Accessory Master record
        Accessories_Master__c AM = new Accessories_Master__c();
        insert AM;
        // create severals Accessory Rate Master records
        Accs_Rate_Master__c[] ARMs = new Accs_Rate_Master__c[]{};
        for (integer i = 0; i < 10; i++) {
            Accs_Rate_Master__c tempARM = new Accs_Rate_Master__c(Accessories__c = AM.id, ARM_EFFDT__c = Date.today().addDays(i), ARM_SALEPRICE__c = i);
            ARMs.add(tempARM);
        }
        insert ARMs;
    }
    
    @isTest
    private static void updateRate_Test() {
        set<ID> accMasterIds = new set<ID> {[SELECT id, Rate__c FROM Accessories_Master__c].ID};
        list<Accessories_Master__c> AMs = new AccessoriesMasterSelector().selectAccsMastersWithRateMastersByIds(accMasterIds);
        system.debug(AMs);
        AccessoriesMasters domainInstance = new AccessoriesMasters(AMs);
        domainInstance.updateRate();
        Accessories_Master__c updatedAM = [SELECT id, Rate__c FROM Accessories_Master__c];
        system.assertEquals(9, updatedAM.Rate__c);
    }
}