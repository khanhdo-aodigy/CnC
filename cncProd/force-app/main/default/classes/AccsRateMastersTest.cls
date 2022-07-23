@isTest
private class AccsRateMastersTest {
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
    private static void onAfterInsert_Test() {
        // insert new accessory rate master
        Accessories_Master__c AM = [SELECT id, Rate__c FROM Accessories_Master__c];
        Accs_Rate_Master__c newARM = new Accs_Rate_Master__c(Accessories__c = AM.id, ARM_EFFDT__c = Date.today().addDays(10), ARM_SALEPRICE__c = 10);
        insert newARM;
        
        // revert the trigger affect
        AM.Rate__c = 9;
        update AM;
        
        // invoke the onAfterInsert method again to test
        AccsRateMasters domainInstance = new AccsRateMasters(new list<Accs_Rate_Master__c> {newARM});
        domainInstance.onAfterInsert();
        
        // assert
        Accessories_Master__c updatedAM = [SELECT id, Rate__c FROM Accessories_Master__c];
        system.assertEquals(10, updatedAM.Rate__c);
    }
    
    @isTest
    private static void onAfterDelete_Test() {
        // delete latest ARM
        Accessories_Master__c AM = [SELECT id, Rate__c FROM Accessories_Master__c];
        list<Accs_Rate_Master__c> ARMs = (list<Accs_Rate_Master__c>)[SELECT ID, ARM_EFFDT__c, Accessories__c, ARM_SALEPRICE__c FROM Accs_Rate_Master__c ORDER BY ARM_EFFDT__c ASC];
        delete ARMs[9];
        
        // revert the trigger affect
        AM.Rate__c = 9;
        update AM;
        
        // invoke the onAfterDelete method again to test
        AccsRateMasters domainInstance = new AccsRateMasters(ARMs);
        domainInstance.onAfterDelete();
        
        // assert
        Accessories_Master__c updatedAM = [SELECT id, Rate__c FROM Accessories_Master__c];
        system.assertEquals(8, updatedAM.Rate__c);
    }
    
    @isTest
    private static void onAfterUpdate_Test() {
        // update oldest ARM
        Accessories_Master__c AM = [SELECT id, Rate__c FROM Accessories_Master__c];
        list<Accs_Rate_Master__c> ARMs = (list<Accs_Rate_Master__c>)[SELECT ID, ARM_EFFDT__c, Accessories__c, ARM_SALEPRICE__c FROM Accs_Rate_Master__c ORDER BY ARM_EFFDT__c ASC];
        map<ID, Accs_Rate_Master__c> ARMsByID = new map<ID, Accs_Rate_Master__c> ([SELECT ID, ARM_EFFDT__c, Accessories__c, ARM_SALEPRICE__c FROM Accs_Rate_Master__c]);
        
        // cloning the old records
        map<ID, Accs_Rate_Master__c> existingRecords = new map<ID, Accs_Rate_Master__c>{};
        for (ID ARMID : ARMsByID.keyset()) {
			existingRecords.put(ARMID, ARMsByID.get(ARMID).clone());
        }
            
        // perform the update: increase the price of oldest ARM and make it the latest ARM
        ARMs[0].ARM_SALEPRICE__c = 999;
        ARMs[0].ARM_EFFDT__c = Date.today().addDays(30);
        update ARMs;
        
        // revert the trigger affect
        AM.Rate__c = 9;
        update AM;
        
        // invoke the onAfterDelete method again to test
        AccsRateMasters domainInstance = new AccsRateMasters(ARMs);
        domainInstance.onAfterUpdate(existingRecords);
        
        // assert
        Accessories_Master__c updatedAM = [SELECT id, Rate__c FROM Accessories_Master__c];
        system.assertEquals(999, updatedAM.Rate__c);
    }
}