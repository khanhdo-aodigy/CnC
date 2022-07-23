@isTest
private class PackageAccsSelectorTest {
    @testSetup
    static void setUp() {
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A',PKH_PKGPRICE__c=1000000);
        insert pckHeader;
        
        Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id);
        insert pckAcc;
    }
    
    @isTest
    static void testSelectByPackageHeaderId() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        PackageAccsSelector pckAccsSel = new PackageAccsSelector();
        List<Package_Accs__c> pckAcc = pckAccsSel.selectByPackageHeaderId(pckHeader.Id);
        System.assertEquals(1, pckAcc.size());
    }
    
    @isTest
    static void testSelectByPackageHeaderIds() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Set<Id> ids = new Set<Id>();
        ids.add(pckHeader.Id);
        PackageAccsSelector pckAccsSel = new PackageAccsSelector();
        List<Package_Accs__c> pckAcc = pckAccsSel.selectByPackageHeaderIds(ids);
        System.assertEquals(1, pckAcc.size());
    }
}