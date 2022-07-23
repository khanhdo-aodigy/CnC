/*******
 * Description : Test class for restModelGroup.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200526             TP     Created Initial Version 
*******/
@isTest
private class Test_restModelGroup {
    
   @isTest
    static void test_restModelGroup_Success() {
        Model_Group__c modelGroup = new Model_Group__c(Name = 'TEST MODEL GROUP',
                                                       Branch_Code__c = 'CCA',
                                                       Brand_Code__c = 'MIT',
                                                       Franchise_Code__c = 'MITPC');
        insert modelGroup;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restModelGroup';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('brand', 'MIT');
        req.addParameter('branch', 'CCA');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        restModelGroup.doGet();
        Test.stopTest();
    }
    
    @isTest
    static void test_restModelGroup_Error() {
        Model_Group__c modelGroup = new Model_Group__c(Name = 'TEST MODEL GROUP 1',
                                                       Branch_Code__c = 'CCF',
                                                       Brand_Code__c = 'CIT',
                                                       Franchise_Code__c = 'CITPC');
        insert modelGroup;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restModelGroup';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('brand', 'MIT');
        req.addParameter('branch', 'CCA');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        restModelGroup.doGet();
        Test.stopTest();
    }
}