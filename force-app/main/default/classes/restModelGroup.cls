/*******
 * Description : REST API to provide Model Group Details.
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200526             TP     Created Initial Version 
*******/

@RestResource (urlMapping = '/ModelGroup/*')
global class restModelGroup {
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;

    @HttpGet
    global static void doGet() {

        res.addHeader('Content-Type', 'application/json');

        try {

            getModelGroupDetails();

        } catch (Exception e) {

            loggerDataPool.buildLogDataPool('restCheckPromoCode', e);
            errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());

        }

        if(errorResponse != null && errorResponse.status == 'Failed') {    
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }

        serviceDataPool.buildServiceDataPool('modelGroupDetails', 'restModelGroup', '', req, res);
    }

    public static void getModelGroupDetails () {

        List<Model_Group__c> modelGroups = new List<Model_Group__c>();

        modelGroups = [SELECT ID, Name, Branch_Code__c, Brand_Code__c, Franchise_Code__c FROM Model_Group__c WHERE Branch_Code__c =: req.params.get('branch') AND Brand_Code__c =:  req.params.get('brand')];

        if (modelGroups.size() > 0) {

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(modelGroups));

        } else {

            errorResponse = new Utility.httpErrorResponse('Failed', 'There is no Model Group found.'); 

        }
    }
}