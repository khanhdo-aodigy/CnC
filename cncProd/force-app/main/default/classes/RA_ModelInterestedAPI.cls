/** *****
 * Description : API class for creating RA Model Interested
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20210305             HS@aodigy.com               Created Initial Version
 * 20210727             KD@aodigy.com               Person Account Merging: remove linkage to Profiling
 * 
** *****/
@RestResource (urlMapping = '/RA/ModelInterested/insert/*')
global with sharing class RA_ModelInterestedAPI {

    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
    private static Utility.httpErrorResponse errorResponse;
    private static String errMessage = '';
    private static String processedRecId; 

    @HttpPost
    global static void createRAModelInterested() 
    {   
        Savepoint sp = Database.setSavepoint();
        try {
            processRequest();
        } 
        catch(Exception ex) {
            errMessage = ex.getMessage();
            loggerDataPool.buildLogDataPool('createRAModelInterested',ex);
            System.debug ('@@@@DEBUG createRAModelInterested :: Exception :: err.msg = ' + ex.getMessage() + ' || err.cause = ' + ex.getCause() + ' || err.line : ' + ex.getLineNumber() );
            Database.rollback(sp);
        }

        if( String.isNotBlank( errMessage ) ){
            resBody.message = errMessage;
            resBody.status  = 'Failed';
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(resBody));
        }
        else{
            resBody.message = 'Model Alert Subscription Id : '+processedRecId;
            resBody.status  = 'Success';
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(resBody));  
        }
        serviceDataPool.buildServiceDataPool('createRAModelInterested', 'RA_ModelInterestedAPI', processedRecId, request, response);
    }

    private static void processRequest() 
    {
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        if( reqBody.useRegex == null ){
            reqBody.useRegex = true;
        }
        System.debug('@@@@DEBUG processRequest :: reqBody = ' + reqBody );

        //Check Required Fields
        if( checkRequiredFields() == false ){
            return;
        }

        //Check & Process PA Profiling at Generic Method
        AccountUtil.RACustomerWrapper customerWrapper = new AccountUtil.RACustomerWrapper(reqBody.FirstName, reqBody.LastName, reqBody.Email, reqBody.Mobile, reqBody.ConsentForMarketingRA);


        //Check & Process Sales Opportunity at Generic Method 
        Account personAcc = AccountUtil.upsertRACustomer(customerWrapper, 'Prospect');
        Sales_Opportunity__c salesOpp = SalesOpportunityService.upsertSalesOppByAccId( personAcc, null );


        //Process the Model Interested transaction data
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Model_Alert_Subscription__c.SObjectType, 
                                                                                              Model_Subscribed__c.SObjectType } );

        Id modelAlertSubRecTypeId   = Schema.SObjectType.Model_Alert_Subscription__c.getRecordTypeInfosByDeveloperName().get('RA_Model_Alert_Subcription_RT').getRecordTypeId();
        Id modelSubscribedRecTypeId = Schema.SObjectType.Model_Subscribed__c.getRecordTypeInfosByDeveloperName().get('RA_Model_Subscribed_RT').getRecordTypeId();

        Model_Alert_Subscription__c mAlertSubcription = new Model_Alert_Subscription__c( RecordTypeId = modelAlertSubRecTypeId , Subscription_Expiry_Date__c = Date.today().addDays(30) );
        uow.registerNew( mAlertSubcription ); 
        uow.registerRelationship( mAlertSubcription, Model_Alert_Subscription__c.Sales_Opportunity__c, salesOpp );    
        uow.registerRelationship( mAlertSubcription, Model_Alert_Subscription__c.Account__c, personAcc );    
        uow.registerRelationship( mAlertSubcription, Model_Alert_Subscription__c.Contact__c, new Contact( Id = personAcc.PersonContactId ) );    

        for( ModelSubscribed ms : reqBody.MakeModel ){
            Model_Subscribed__c mSubcribe = new Model_Subscribed__c( RecordTypeId = modelSubscribedRecTypeId, Make__c = ms.Make.trim() , Model_Name__c = ms.Model.trim() );
            uow.registerNew( mSubcribe, Model_Subscribed__c.Model_Alert_Subscription__c, mAlertSubcription );
        }
        uow.commitWork();

        processedRecId = mAlertSubcription.Id;         
    }    


    private static Boolean checkRequiredFields()
    {   
        errMessage = '';
        if( String.isBlank(reqBody.FirstName) ||
                String.isBlank(reqBody.LastName) ||
                    String.isBlank(reqBody.Mobile) ||
                        String.isBlank(reqBody.Email) ||
                            reqBody.ConsentForMarketingRA == null )
        {
            errMessage += 'Mandatory field is missing, please refer to API doc. ';        
        }
        else if( reqBody.useRegex && !RegexUtil.isValidMobileSG( reqBody.Mobile ) ) 
        {
            errMessage += 'Invalid Customer Mobile Phone, mobile must start with 65/+65, followed by 8 numeric numbers. ';
        }
        else if( reqBody.useRegex && !RegexUtil.isValidEmail( reqBody.Email ) ) {
            errMessage += 'Invalid Customer Email. ';
        }
        else if( reqBody.MakeModel == null || reqBody.MakeModel.isEmpty() ){
            errMessage += 'Model Subscribed Information is missing ';
        }
        else if( reqBody.MakeModel <> null && !reqBody.MakeModel.isEmpty() ){
            for( ModelSubscribed ms : reqBody.MakeModel ){
                if( String.isBlank( ms.Make ) ){
                    errMessage += 'Make information is missing ';
                }
                else if( String.isBlank( ms.Model )){
                    errMessage += 'Model information is missing ';
                }
            }
        }
        return (String.isBlank(errMessage));
    }


    public class ResponseBody 
    {
        public String status;
        public String message;
    }

    public class RequestBody 
    {
        public String FirstName; 
        public String LastName;
        public String Mobile;
        public String Email;
        public Boolean ConsentForMarketingRA;
        public Boolean useRegex;
        List<ModelSubscribed> MakeModel;
    }

    public class ModelSubscribed {
        public String Make;
        public String Model;
    }
}