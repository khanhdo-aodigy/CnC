@isTest
private with sharing class DocusignTextCustomField_Test {

    @isTest
    private static void test() {
        DocusignTextCustomField tcf = new DocusignTextCustomField('SA-000038');
        system.assertEquals('SA-000038', tcf.value);
    }
}