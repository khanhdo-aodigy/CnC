@IsTest(SeeAllData=true)
public class TestGetBranchCodeNameMapping {

 @isTest public static void testPositiveGetMethod() 
    {
       
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetBranchCodeNameMapping/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetBranchCodeNameMapping.getBranchCodeNameMapping();
        System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
   
   
}