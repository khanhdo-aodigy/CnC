@IsTest
public class REFFPostCreateReferralRecordAPI_Test {
 
    static testMethod void testcreateReferral()
    {
        Test.startTest();
        String reqURI = '/services/apexrest/PostCreateReferralRecord/v1'; 
        String reqBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "ZZZtestLead2@mailintor.com","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        REFFPostCreateReferralRecordAPI.createReferral();
        Test.stopTest();
        RestResponse res = RestContext.response;
        System.assertEquals(Blob.valueOf(JSON.serialize(new Map<String, String>{'Status'=>'Success','Message'=>''})), res.responseBody);
    }
    static testMethod void testCreateReferralFailed()
    {
        Test.startTest();
        String reqURI = '/services/apexrest/PostCreateReferralRecord/v1'; 
        String reqBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "ZZZtestLead2@mailintor.com","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        REFFPostCreateReferralRecordAPI.createReferral();
        String reqBodyDupl = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "ZZZtestLead2@mailintor.com","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBodyDupl, null, 200);
        RestResponse res = RestContext.response;
        Test.stopTest();

        System.assertNotEquals(Blob.valueOf(JSON.serialize(new Map<String, String>{'Status'=>'Success','Message'=>''})), res.responseBody);
    }
    static testMethod void testDuplicateReferral()
    {
        Account acc = Test_DataFactory.createAccount(true, 'Name');
    	Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', acc.Id);
        con.Email = 'ZZZtestLead2@mailintor.com';
        insert con;
        Lead lead = Test_DataFactory.createLead(false, 'company',' lName');
        lead.Email = 'ZZZtestLead2@mailintor.com';
        insert lead;
        Test.startTest();
        String reqURI = '/services/apexrest/PostCreateReferralRecord/v1'; 
        String reqBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "ZZZtestLead2@mailintor.com","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        REFFPostCreateReferralRecordAPI.createReferral();
        Test.stopTest();
        RestResponse res = RestContext.response;
        //System.assertEquals(Blob.valueOf(JSON.serialize(new Map<String, String>{'Status'=>'Success','Message'=>''})), res.responseBody);
    }
}