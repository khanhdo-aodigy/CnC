/**************************************************************
 * Class Name: GetCustomerProfileBySFUserIDTest
 * Description: Test class for GetCustomerProfileBySFUserID api
 * 
 * Revision History
 * Developer Name			Date			Description
 * CGaylan					23-07-2019		Created.
 **************************************************************/
@isTest
private class GetCustomerProfileBySFUserIDTest {
    @testSetup
    static void createData(){
        Account testAccount = Test_DataFactory.createAccount(true, 'TestAccount');
        Contact testContact = Test_DataFactory.createContact(false, 'testContact', 'testLastName', testAccount.Id);
        testContact.email = 'testMail@test.com';
        insert testContact;        
        
        Account testPA = Test_DataFactory.createPerson(false, 'TestAccount', 'Customer');
        testPA.PersonEmail = 'test34374@gmail.com';
        insert testPA;
        testPA = [SELECT PersonContactId FROM Account WHERE Id = :testPA.Id];
        Contact personCon = new Contact(Id = testPA.PersonContactId);
        personCon.MobilePhone = '9023434543';
        update personCon;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User testUser = Test_DataFactory.createUserWithProfileID(false, 'actiFN', 'UniqueName', testContact.email, p.Id);
        testUser.ContactId = testPA.PersonContactId;
        testUser.username = testContact.email;
        testUser.isActive = true;
        testUser.isValid__c = true;
        insert testUser;        
    }
    
    
    /************************************************
     * Method Name: testGetProfileWithoutNRIC
     * Description: Test method for verifying scenario 
     * 				when User record does not have NRIC field value
     * 				and Contact record cannot be found.
     ************************************************/ 
    static testMethod void testGetProfileWithoutNRIC(){ 
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerProfileBySFUserID/v1/' + UserInfo.getUserId(); 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 400);
        GetCustomerProfileBySFUserID.getCustomerProfileBySFUserID();
        Test.stopTest();
        RestResponse res = RestContext.response;
   }
    
    
    /************************************************
     * Method Name: testGetProfileWithNRIC
     * Description: Test method for verifying scenario 
     * 				when User record has NRIC field value
     * 				and Contact record is found.
     ************************************************/ 
    static testMethod void testGetProfileWithNRIC(){ 
    	User testUser = [SELECT Id FROM User WHERE LastName = 'UniqueName' LIMIT 1];
        Test.startTest();
        String nricVal = 'TESTNR1';
        String reqURI = '/services/apexrest/GetCustomerProfileBySFUserID/v1/' + testUser.Id;

        //Update User records NRIC value
        //Database.update( new User(Id=UserInfo.getUserId(), NRIC__c=nricVal));

        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 200 );
        GetCustomerProfileBySFUserID.getCustomerProfileBySFUserID();
        Test.stopTest();
        
        RestResponse res = RestContext.response;
        //System.assertNotEquals(Blob.valueOf(JSON.serialize(new Map<String, String>{'ErrorCode'=>'Err03-SF','Message'=>'There is no contact for this User Id: ' + UserInfo.getUserId()})), res.responseBody);

    }

    /************************************************
     * Method Name: testGetWithoutUserId
     * Description: Test method for verifying scenario 
     * 				when User Id is not passed 
     * 				in the Req URI
     ************************************************/ 
    static testMethod void testGetWithoutUserId(){ 
        Test.startTest();
        String nricVal = 'TESTNR1';
        String reqURI = '/services/apexrest/GetCustomerProfileBySFUserID/v1/';

        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 400 );
        GetCustomerProfileBySFUserID.getCustomerProfileBySFUserID();
        Test.stopTest();
        RestResponse res = RestContext.response;
        System.assertEquals(Blob.valueOf(JSON.serialize(new Map<String, String>{'ErrorCode'=>'Err02-SF','Message'=>'Required fields not supplied. Fields: UserId'})), res.responseBody);


    }
    
    /************************************************
     * Method Name: testGetWithoutMatchingContact
     * Description: Test method for verifying scenario 
     * 				when User Id is present
     * 				and Contact record is missing
     ************************************************/ 
    static testMethod void testGetWithoutMatchingContact(){ 
        Test.startTest();
        String nricVal = 'TESTNR1';
        String reqURI = '/services/apexrest/GetCustomerProfileBySFUserID/v1/' + UserInfo.getUserId();

        //Delete Contact
        //DELETE [SELECT Id FROM Contact WHERE AccountId!=null LIMIT 1];
        //Contact con = [SELECT Id, NRIC_Passport_No__c FROM Contact WHERE MobilePhone='6580000000'];
        //con.NRIC_Passport_No__c = '';
        //update con;

        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 400 );
        GetCustomerProfileBySFUserID.getCustomerProfileBySFUserID();
        Test.stopTest();
        RestResponse res = RestContext.response;
    }
    
}