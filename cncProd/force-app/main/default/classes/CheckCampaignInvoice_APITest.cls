@isTest
private class CheckCampaignInvoice_APITest {
    
    @isTest
    static void Test_doGet_VerificationPass() {
        Campaign camp = createCampaign('Promotions', 1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'AmountWithGST' => '400',
            'NetAmount' => '400',
            'Discount' => '600',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignInvoice_API.ResponseWrapper response = CheckCampaignInvoice_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(response.isVerified);
    }
    
    @isTest
    static void Test_doGet_VerificationFail_DiscountedPriceShouldBeZeroForEvents() {
        Campaign camp = createCampaign('Events', 1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'AmountWithGST' => '400',
            'NetAmount' => '400',
            'Discount' => '600',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignInvoice_API.ResponseWrapper response = CheckCampaignInvoice_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(false, response.isVerified);
        System.assert([Select Message__c From Logger_Data_Pool__c].Message__c.endsWith(
            'TotalPrice (API) calculation error, or Campaign Type is Events but DiscountedPrice (API) is not 0'
        )); 
    }

    @isTest
    static void Test_doGet_VerificationFail_DiscountedPriceShouldBeZeroIfEitherCostNull() {
        Campaign camp = createCampaign('Promotions', null, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'AmountWithGST' => '400',
            'NetAmount' => '400',
            'Discount' => '600',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignInvoice_API.ResponseWrapper response = CheckCampaignInvoice_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(false, response.isVerified);
        System.assert([Select Message__c From Logger_Data_Pool__c].Message__c.endsWith(
            'Campaign Actual Cost or Budgeted Cost is null, but DiscountedPrice (API) is not 0'
        )); 
    }
    
    @isTest
    static void Test_doGet_VerificationFail_DiscountedPriceDoesNotEqualDifferenceBetweenCosts() {
        Campaign camp = createCampaign('Promotions', 1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'AmountWithGST' => '400',
            'NetAmount' => '400',
            'Discount' => '999',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignInvoice_API.ResponseWrapper response = CheckCampaignInvoice_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(false, response.isVerified);
        System.assert([Select Message__c From Logger_Data_Pool__c].Message__c.endsWith(
            'DiscountedPrice (API) not equal to difference between Campaign Actual Cost and Campaign Budgeted Cost'
        )); 
    }    
    
    @isTest
    static void Test_doGet_VerificationFail_ParametersNotEqual() {
        Campaign camp = createCampaign('Promotions', 1000, 400);

        RestContext.request = buildRequest(new Map<String, String>{
            'AmountWithGST' => '999',
            'NetAmount' => '400',
            'Discount' => '600',
            'CampaignId' => camp.Id
        });
        RestContext.response = new RestResponse();
        CheckCampaignInvoice_API.ResponseWrapper response = CheckCampaignInvoice_API.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(false, response.isVerified);
        System.assert([Select Message__c From Logger_Data_Pool__c].Message__c.endsWith(
            'AmountWithGST not equal to NetAmount'
        )); 
    }        
    
    @isTest
    static void Test_doGet_SystemException() {
        RestContext.request = buildRequest(new Map<String, String>{
            'AmountWithGST' => null,
            'NetAmount' => null,
            'Discount' => null,
            'CampaignId' => null
        });
        RestContext.response = new RestResponse();
        CheckCampaignInvoice_API.ResponseWrapper response = CheckCampaignInvoice_API.doGet();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(null, response.isVerified);
        System.assert(String.isNotBlank([Select Stack_Trace__c From Logger_Data_Pool__c].Stack_Trace__c)); 
    }        
    
    private static Campaign createCampaign(String campaignType, Decimal actualCost, Decimal budgetedCost) {
        Campaign camp = Test_DataFactory.createCamp(false, 'test', campaignType, 'CCI');
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