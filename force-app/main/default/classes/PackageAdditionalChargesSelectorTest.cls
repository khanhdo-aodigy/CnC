@isTest
private class PackageAdditionalChargesSelectorTest {
    @testSetup
    static void setUp() {
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC');
        insert pckHeader;
        Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test');
        insert addnlChargeMaster;   
        Package_Additional_Charges__c pckAddnlCharge = new Package_Additional_Charges__c(Package_Header__c = pckHeader.Id,
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         PKC_ADM_CHRGCD__c = 'ABC');
        insert pckAddnlCharge;
    }
    
    @isTest
    static void testSelectByPackageHeaderId() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        PackageAdditionalChargesSelector pckAddnlChargeSel = new PackageAdditionalChargesSelector();
        List<Package_Additional_Charges__c> pckAcc = pckAddnlChargeSel.selectByPackageHeaderId(pckHeader.Id);
        System.assertEquals(1, pckAcc.size());
    }
    
    @isTest
    static void testSelectByPackageHeaderIds() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Set<Id> ids = new Set<Id>();
        ids.add(pckHeader.Id);
        PackageAdditionalChargesSelector pckAddnlChargeSel = new PackageAdditionalChargesSelector();
        List<Package_Additional_Charges__c> pckAcc = pckAddnlChargeSel.selectByPackageHeaderIds(ids);
        System.assertEquals(1, pckAcc.size());
    }
    
    @isTest
    static void testSelectByPackageHeaderAndChargeCode() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        List<String> chargeCodeList = new List<String>{'ABC'};
        PackageAdditionalChargesSelector pckAddnlChargeSel = new PackageAdditionalChargesSelector();
        List<Package_Additional_Charges__c> pckAcc = pckAddnlChargeSel.selectByPackageHeaderAndChargeCode(pckHeader.Id, chargeCodeList);
        System.assertEquals(1, pckAcc.size());
    }
        

}