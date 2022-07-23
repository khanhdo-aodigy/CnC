@isTest
private class testValidateOTP {
    private static String nric = 'S2080013E';
    private static String otpString = 'A120y6';
    private static String updatedMobileNumber = '9654013399';
    
    @testSetup
    private static void createData(){
        Account personAcc = Test_DataFactory.createPerson(false, 'Last Name', 'Customer');
        personAcc.PersonEmail = 'patest@gmail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.NRIC_Passport_No__c = nric;
        personCon.Source__c = 'DWH';
        personCon.OTP__c = otpString;
        update personCon;
    }
    
    @isTest
    private static void testValidateOTP_caseOTPIsExpired() {
        Contact con = [SELECT Id, OTP_Timestamp__c FROM Contact LIMIT 1];
        con.OTP_Timestamp__c = DateTime.now().addMinutes(-31);
        update con;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ValidateOTP/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"otp":"' + otpString + '","nric": "' + con.Id+ '","updatedMobileNumber":"' + updatedMobileNumber + '"}');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        ValidateOTP.ValidateOTP(otpString, con.Id, updatedMobileNumber);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    @isTest
    private static void testCaseIsOTPNotExpired() {
        Contact con = [SELECT id, OTP_Timestamp__c, OTP__c, IsPersonAccount FROM Contact LIMIT 1];
        con.OTP_Timestamp__c = DateTime.now().addMinutes(-20);
        con.OTP__c = otpString;
        update con;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ValidateOTP/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"otp":"'+ otpString +'","nric": "'+con.id+'","updatedMobileNumber":"'+updatedMobileNumber+'"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        ValidateOTP.ValidateOTP(otpString, con.Id, updatedMobileNumber);
        System.assert(response.statusCode == 200);
        Test.stopTest();
    }    
    
    @isTest
    private static void InvalidOTP() {
        String invalidOTP = 'INVALID001';
		Contact con = [SELECT id, OTP_Timestamp__c, OTP__c FROM Contact LIMIT 1];
        con.OTP_Timestamp__c = DateTime.now().addMinutes(-20);
        con.OTP__c = invalidOTP;
        update con;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ValidateOTP/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"otp":"'+otpString+'","nric": "'+con.id+'","updatedMobileNumber":"'+updatedMobileNumber+'"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        ValidateOTP.ValidateOTP(otpString, con.Id, updatedMobileNumber);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    @isTest
    private static void InValidNRIC() {
        String invalidNRIC = '01HIHI';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ValidateOTP/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"otp":"'+otpString+'","nric": "'+invalidNRIC+'","updatedMobileNumber":"'+updatedMobileNumber+'"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        ValidateOTP.ValidateOTP(otpString, invalidNRIC, updatedMobileNumber);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    @isTest
    private static void testCaseMissingRequiredField() {        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/ValidateOTP/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"otp":"556209","nric": "S260296D","updatedMobileNumber":""}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        ValidateOTP.ValidateOTP('556209','S260296D','');
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }

}