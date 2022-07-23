@isTest
private class Test_InsertFeedbackMB {
   @isTest
   private static void testInsertFeedbackMB_PossitiveCase() {       
       String nric = 'S9100860B';
       Account personAcc = Test_DataFactory.createPerson(true, 'Test PA', 'Customer');
       personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
       Contact personCon = new Contact(Id = personAcc.PersonContactId);
       personCon.NRIC_Passport_No__c = nric;
       update personCon;
       Test.startTest();
       RestRequest request = new RestRequest();
       RestResponse response = new RestResponse();
       request.requestUri ='InsertFeedback/v1/';
       request.httpMethod = 'POST';
       RestContext.request = request;
       RestContext.response = response ;
       String email = 'et.sapient@gmail.com';
       String lastVisitedServiceCenter = 'Singapore';
       String message = 'Mock message';
       String mobile = '123344343' ;
       String name = 'Mock Name';
       String registrationNumber = '1324423xx';
       String category = 'Sales';
       InsertFeedbackMB.InsertFeedbackMB(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
       Test.stopTest();
    }
    
    private static testMethod void testNoNric()
    {
        
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='InsertFeedback/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        String nric = '';
        String email = 'et.sapient@gmail.com';
        String lastVisitedServiceCenter = 'Singapore';
        String message = 'Mock message';
        String mobile = '123344343' ;
        String name = 'Mock Name';
        String registrationNumber = '1324423xx';
        String category = 'Sales';
        InsertFeedbackMB.InsertFeedbackMB(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
        Test.stopTest();
     
    }
    
    private static testMethod void testNoRequiredData()
    {
        
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='InsertFeedback/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        String nric = '132214xxx';
        String email = 'et.sapient@gmail.com';
        String lastVisitedServiceCenter = 'Singapore';
        String message = '';
        String mobile = '' ;
        String name = 'Mock Name';
        String registrationNumber = '1324423xx';
        String category = '';
        InsertFeedbackMB.InsertFeedbackMB(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
        Test.stopTest();
     
    }
}