/** *****
 * Description : Test Class for RAEnquiryAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class RAEnquiryAPITest {
    @testSetup
    private static void createTestData(){
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.Default_RA_OwnerId__c = UserInfo.getUserId();        
        RA_GlobalVar.APIGateway_URL__c     = 'www.urltothehell.com';
        RA_GlobalVar.APIGateway_Key__c     = 'myKey';
        upsert RA_GlobalVar;
    }
    
   @isTest
    private static void testCreateEnquiry_newProspect_Success() {
        String reqBody = '{"FirstName":"Khanh","LastName":"Do","Mobile":"6535401666","Email":"test@cnc.com","Subject":"Follow-up","Enquiry":"I want to know more about c-class","ConsentForMarketingRA":true}';
        Test.startTest();
        String reqURI = '/Enquiry/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAEnquiryAPI.doPost();
        Test.stopTest();
    } 

    @isTest
    private static void testCreate_CustomerExists_Success() {
        String firstName = 'Dog';
        String lastName = 'RA-Testing';
        String email = 'test@cnc.com';
        String mobile = '6525401666';
        Boolean consentForMarketingRA = true;
        
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'test@cnc.com', 'Prospect');
        String reqBody = '{"FirstName":"Khanh","LastName":"Do","Mobile":6535401666,"Email":"' + email + '","Subject":"Follow-up","Enquiry":"I want to know more about c-class","ConsentForMarketingRA":true}';
        
        Test.startTest();
        String reqURI = '/Enquiry/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAEnquiryAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_missingRequiredField_errorReturned() {
        String reqBody = '{"FirstName":"Khanh","LastName":"Do","Mobile":"6535401666","Email":"","Subject":"Follow-up","Enquiry":"I want to know more about c-class","ConsentForMarketingRA":true}';
        Test.startTest();
        String reqURI = '/Enquiry/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAEnquiryAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidMobile_errorReturned() {
        String reqBody = '{"FirstName":"Khanh","LastName":"Do","Mobile":"aB54d01666","Email":"ra@test.com","Subject":"Follow-up","Enquiry":"I want to know more about c-class","ConsentForMarketingRA":true}';
        Test.startTest();
        String reqURI = '/Enquiry/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAEnquiryAPI.doPost();
        Test.stopTest();
    }
}