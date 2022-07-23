@isTest(seeAllData=true)
public class Test_GetVariantPrice {
    
    static testMethod void testGetTrigger()
    {
        Test.startTest();
        Model__c TestMod =  new Model__c(Name='TestMod',Branch_Code__c='CCK',Franchise_Code__c='KIAPC',DWH_Model_ID__c='abc12345');
        insert TestMod;
        
        Variant__c TestVar =  new Variant__c(Name='TestVar',Branch__c='CCK',Franchise__c='KIAPC',Model_ID__c=TestMod.Id);
        insert TestVar;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVariantPrice/v1/'+TestVar.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        
        GetVariantPrice.getPriceMethod();
        System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
    static testMethod void testGetBlankTrigger()
    {
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVariantPrice/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        
        GetVariantPrice.getPriceMethod();
        System.assert(response.statusCode == 400);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
    static testMethod void testGetZeroTrigger()
    {
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVariantPrice/v1/abc123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        
        GetVariantPrice.getPriceMethod();
        System.assert(response.statusCode == 400);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
}