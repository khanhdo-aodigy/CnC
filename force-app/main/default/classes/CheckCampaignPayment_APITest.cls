@isTest
private class CheckCampaignPayment_APITest {
    
    @isTest
    static void Test_doGet_VerificationPass() {
        Campaign camp = createCampaign(1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'Amount' => '400',
            'TaxAmount' => '0',
            'DiscountAmount' => '600',
            'UnitAmount' => '1000',
            'Quantity' => '1',    
            'UnitTaxAmount' => '0',
            'TotalAmount' => '400',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignPayment_API.ResponseWrapper response = CheckCampaignPayment_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(response.isVerified);
    }
    
    @isTest
    static void Test_doGet_VerificationFail_ActualCostWrong() {
        Campaign camp = createCampaign(1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'Amount' => '400',
            'TaxAmount' => '0',
            'DiscountAmount' => '600',
            'UnitAmount' => '9999',
            'Quantity' => '1',    
            'UnitTaxAmount' => '0',
            'TotalAmount' => '400',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignPayment_API.ResponseWrapper response = CheckCampaignPayment_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(false, response.isVerified);
        System.assert([Select Message__c From Logger_Data_Pool__c].Message__c.endsWith(
            'ActualCost (API) not equal to Campaign Actual Cost'
        ));
    }    
    
    @isTest
    static void Test_doGet_VerificationFail_ParametersNotEqual() {
        Campaign camp = createCampaign(1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'Amount' => '400',
            'TaxAmount' => '0',
            'DiscountAmount' => '600',
            'UnitAmount' => '1000',
            'Quantity' => '999',    
            'UnitTaxAmount' => '0',
            'TotalAmount' => '400',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignPayment_API.ResponseWrapper response = CheckCampaignPayment_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(false, response.isVerified);
        System.assert([Select Message__c From Logger_Data_Pool__c].Message__c.endsWith(
            'Invalid request body data'
        ));        
    }    
    
    @isTest
    static void Test_doGet_SystemException() {
        RestContext.request = buildRequest(new Map<String, String>{
            'Amount' => null,
            'TaxAmount' => null,
            'DiscountAmount' => null,
            'UnitAmount' => null,
            'Quantity' => null,    
            'UnitTaxAmount' => null,
            'TotalAmount' => null,
            'CampaignId' => null
        });
        RestContext.response = new RestResponse();
        CheckCampaignPayment_API.ResponseWrapper response = CheckCampaignPayment_API.doGet();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(null, response.isVerified);
        System.assert(String.isNotBlank([Select Stack_Trace__c From Logger_Data_Pool__c].Stack_Trace__c));     
    }    
    
    private static Campaign createCampaign(Decimal actualCost, Decimal budgetedCost) {
        Campaign camp = Test_DataFactory.createCamp(false, 'test', 'Promotions', 'CCI');
        camp.Actual_Cost_in_Campaign__c = actualCost;
        camp.Budgeted_Cost_in_Campaign__c = budgetedCost;
        insert camp;        
        
        return camp;
    }    
    
    private static RestRequest buildRequest(Map<String, String> params) {
        RestRequest req = new RestRequest(); 
        req.addHeader('httpMethod', 'GET');
        
        for(String key : params.keySet()) {
            req.addParameter(key, params.get(key));   
        }
        
        return req;
    }

}