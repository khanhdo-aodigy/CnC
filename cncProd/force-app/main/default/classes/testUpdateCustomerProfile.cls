@IsTest
private class testUpdateCustomerProfile {
    private static String nric = 'S7042453C';
    
    @testSetup
    private static void createData(){        
        Account personAcc = Test_DataFactory.createPerson(false, 'lastName', 'Customer');
        personAcc.PersonEmail = 'patest@gmail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.NRIC_Passport_No__c = nric;
        personCon.Source__c = 'DWH';
        update personCon;   
    }
    
    @isTest
    private static void testPositive() {      
        List<Contact> lstContact = [SELECT Id, IsPersonAccount FROM Contact WHERE NRIC_Passport_No__c =:nric ];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerProfile/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"nric":"'+lstContact.get(0).Id+'","email":"rashmibudakoti071@gmail.com","addressLine1":"Singapore","addressLine2":"Singapore","addressLine3":"Singapore","addressLine4":"Singapore","addressLine5":"Singapore","phone":"83580841","deviceId":"83580841","CommunityNickname":"Matthew"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        UpdateCustomerProfile.UpdateCustomerProfile(lstContact.get(0).Id,'rashmibudakoti071@gmail.com','Singapore','Singapore','Singapore','Singapore','Singapore','83580841','83580841','MAtthew');
        Test.stopTest();
    }
    
    @isTest
    private static void testPositivePA() {
        User user = Test_DataFactory.createUser(true, UserInfo.getLastName(), 'alias');
        Account pa = Test_DataFactory.createPerson(false, 'PA', 'Customer');
        pa.NRIC_Passport_No__pc = 'S7042453C';
        pa.Source__pc = 'DWH';
        pa.PersonEmail = 'patest9875@gmail.com';
        insert pa;
        List<Contact> lstContact = [SELECT Id, IsPersonAccount FROM Contact WHERE NRIC_Passport_No__c =:nric ];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerProfile/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"nric":"'+lstContact.get(0).Id+'","email":"rashmibudakoti071@gmail.com","addressLine1":"Singapore","addressLine2":"Singapore","addressLine3":"Singapore","addressLine4":"Singapore","addressLine5":"Singapore","phone":"83580841","deviceId":"83580841","CommunityNickname":"Matthew"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        UpdateCustomerProfile.UpdateCustomerProfile(lstContact.get(0).Id,'rashmibudakoti071@gmail.com','Singapore','Singapore','Singapore','Singapore','Singapore','83580841','83580841','MAtthew');
        // System.assert(response.statusCode == 200);
        Test.stopTest();
    }
    
    @isTest
    private static void testMissingRequiredFields() {
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE NRIC_Passport_No__c =:nric ];
        String email = '';
        String phone = '';
        String addressLine1 = '';
        String deviceId = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerProfile/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"nric":"'+lstContact.get(0).Id+'","email":"'+ email +'","addressLine1":"'+addressLine1+'","addressLine2":"Singapore","addressLine3":"Singapore","addressLine4":"Singapore","addressLine5":"Singapore","phone":"'+phone+'","deviceId":"'+deviceId+'","CommunityNickname":"Matthew"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        UpdateCustomerProfile.UpdateCustomerProfile(lstContact.get(0).Id,email,addressLine1,'Singapore','Singapore','Singapore','Singapore',phone,deviceId,'MAtthew');
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }

    @isTest
    private static void testBlankNRIC() {
        String nric = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerProfile/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"nric":"'+nric+'","email":"rashmibudakoti071@gmail.com","addressLine1":"Singapore","addressLine2":"Singapore","addressLine3":"Singapore","addressLine4":"Singapore","addressLine5":"Singapore","phone":"83580841","deviceId":"83580841","CommunityNickname":"Matthew"}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        UpdateCustomerProfile.UpdateCustomerProfile(nric,'rashmibudakoti071@gmail.com','Singapore','Singapore','Singapore','Singapore','Singapore','83580841','83580841','MAtthew');
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    @isTest
    private static void inValidNRIC() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerProfile/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"nric":"S8474161B","email":"","addressLine1":"","addressLine2":"","addressLine3":"","addressLine4":"","addressLine5":"","phone":"83580841","deviceId":"","CommunityNickname":""}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        UpdateCustomerProfile.UpdateCustomerProfile('00000000','','','','','','','83580841','','');
        System.assert(response.statusCode == 400);               
        Test.stopTest();
    }
    
    @isTest
    private static void isFieldUpdateRequest() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerProfile/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"nric":"S8113909A","email":"","addressLine1":"","addressLine2":"","addressLine3":"","addressLine4":"","addressLine5":"","phone":"+65-83580841","deviceId":"","CommunityNickname":""}');
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        UpdateCustomerProfile.UpdateCustomerProfile('S8113909A','rashmibudakoti071@gmail.com','abc','','','','','','','');
        System.assertEquals(response.statusCode , 400);
        Test.stopTest();
    }
}