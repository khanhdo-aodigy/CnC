@isTest
public class Test_InsertFeedback 
{
   static testMethod void testPositive()
    {
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='InsertFeedback/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        String nric = '12233xx';
        String email = 'et.sapient@gmail.com';
        String lastVisitedServiceCenter = 'Singapore';
        String message = 'Mock message';
        String mobile = '123344343' ;
        String name = 'Mock Name';
        String registrationNumber = '1324423xx';
        String category = 'Sales';
        InsertFeedback.insertFeedback(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
        Test.stopTest();
     
    }
       static testMethod void testNoNric()
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
        InsertFeedback.insertFeedback(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
        Test.stopTest();
     
    }
        static testMethod void testNoRequiredData()
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
        InsertFeedback.insertFeedback(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
        Test.stopTest();     
    }
     
   //PA MIGRATION: Newly Added -- Start 
    @isTest
    private static void testInsertFeedbackWithPA(){
        Test.startTest();
        String nric = '12233xx';
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'PersonAccount');
        personAcc.NRIC_Passport_No__pc = nric;
        insert personAcc;
        
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
        InsertFeedback.insertFeedback(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);
        Test.stopTest();
    } 
    
    @isTest
    private static void testWithWrongEmailFormat_ExceptionThrown(){
        
        String nric = '12233xx';
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'PersonAccount');
        personAcc.NRIC_Passport_No__pc = nric;
        insert personAcc;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='InsertFeedback/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        
        String email = 'wrongEmailFormat';
        String lastVisitedServiceCenter = 'Singapore';
        String message = 'Mock message';
        String mobile = '123344343' ;
        String name = 'Mock Name';
        String registrationNumber = '1324423xx';
        String category = 'Sales';
        Test.startTest();
        try{
        	InsertFeedback.insertFeedback(nric,email,lastVisitedServiceCenter,message,mobile,name,registrationNumber,category);         
        } catch (Exception e){
            System.debug('@@@ e.getMessage() = ' + e.getMessage());
        }
        Test.stopTest();
    }
     //PA MIGRATION: Newly Added -- End 
}