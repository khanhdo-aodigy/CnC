@isTest
private with sharing class DocusignAccountCustomFields_Test {

    @isTest
    private static void test() {
        DocusignAccountCustomFields cf = new DocusignAccountCustomFields();
        cf.addRecordAutoNumber('SA-0000308');
    }
}