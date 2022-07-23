/** *****
 * Description : API class for creating RA Price Alert
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20210305             HS@aodigy.com               Created Initial Version
 * 20210727             KD@aodigy.com               Person Account Merging
 * 
** *****/
@RestResource (urlMapping = '/RA/PriceAlert/insert/*')
global with sharing class RA_PriceAlertAPI {

    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
    private static String errMessage = '';
    private static String processedRecId; 

    @HttpPost
    global static void createRAPriceAlert() 
    {   
        Savepoint sp = Database.setSavepoint();
        try {
            processRequest();
        } 
        catch(Exception ex) {
            errMessage = ex.getMessage();
            loggerDataPool.buildLogDataPool('createRAPriceAlert',ex);
            System.debug ('@@@@DEBUG createRAPriceAlert :: Exception :: err.msg = ' + ex.getMessage() + ' || err.cause = ' + ex.getCause() + ' || err.line : ' + ex.getLineNumber() );
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
            resBody.message = 'Price Alert Id : '+processedRecId;
            resBody.status  = 'Success';
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(resBody));  
        }
        serviceDataPool.buildServiceDataPool('createRAPriceAlert', 'RA_PriceAlertAPI', processedRecId, request, response);
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

        //Check Vehicle DocNo
        Used_Car_Vehicle_Stock__c usedCarStock = UsedCarVehicleStockService.getVehicleStockByStockNumber(reqBody.DocNo);
        if( checkVehicleDocNo( usedCarStock ) == false ){
            return;
        }

        //Check & Process PA Profiling at Generic Method
        AccountUtil.RACustomerWrapper customerWrapper = new AccountUtil.RACustomerWrapper(reqBody.FirstName, reqBody.LastName, reqBody.Email, reqBody.Mobile, reqBody.ConsentForMarketingRA);


        //Check & Process Sales Opportunity at Generic Method     
        Account personAcc = AccountUtil.upsertRACustomer(customerWrapper, 'Prospect');
        Sales_Opportunity__c salesOpp = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, reqBody.SCEmail, reqBody.SCName, reqBody.SCMobile);

        //Process the price alert transaction data
        Id raPriceAlertRecTypeId = Schema.SObjectType.Price_Alert_for_Non_MF__c.getRecordTypeInfosByDeveloperName().get('RA_Price_Alert_RT').getRecordTypeId();
        Price_Alert_for_Non_MF__c raPriceAlert  = new Price_Alert_for_Non_MF__c();
        raPriceAlert.RecordTypeId                = raPriceAlertRecTypeId;
        raPriceAlert.Sales_Opportunity__c        = salesOpp.Id;
        raPriceAlert.Account__c                  = personAcc.Id;
        raPriceAlert.Contact__c                  = personAcc.PersonContactId;
        raPriceAlert.Used_Car_Vehicle_Stock__c   = usedCarStock.Id;
        raPriceAlert.Latest_Price__c             = usedCarStock.Listing_Price__c;
        raPriceAlert.Vehicle_Stock_Status__c     = usedCarStock.Vehicle_Status__c;
        insert raPriceAlert;

        processedRecId = raPriceAlert.Id;        
    }


    private static Boolean checkVehicleDocNo( Used_Car_Vehicle_Stock__c usedCarStock )
    {
        errMessage = '';
        if( usedCarStock == null ) {
            errMessage += 'Invalid Used Car Vehicle Stock Number ';  
        }
        return String.isBlank( errMessage );
    }


    private static Boolean checkRequiredFields()
    {   
        errMessage = '';
        if( String.isBlank(reqBody.FirstName) ||
                String.isBlank(reqBody.LastName) ||
                    String.isBlank(reqBody.Mobile) ||
                        String.isBlank(reqBody.Email) ||
                            String.isBlank(reqBody.DocNo) ||
                                String.isBlank(reqBody.SCName) ||
                                    String.isBlank(reqBody.SCEmail) ||
                                        String.isBlank(reqBody.SCMobile) ||
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
        else if( reqBody.useRegex && !RegexUtil.isValidMobileSG( reqBody.SCMobile ) ) 
        {
            errMessage += 'Invalid Sales Consultant Mobile Phone, mobile must start with 65/+65, followed by 8 numeric numbers. ';
        }
        else if( reqBody.useRegex && !RegexUtil.isValidEmail( reqBody.SCEmail ) ) {
            errMessage += 'Invalid Sales Consultant Email. ';
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
        public String DocNo;
        public String SCName;
        public String SCEmail;
        public String SCMobile;
        public Boolean ConsentForMarketingRA;
        public Boolean useRegex = true;
    }
}