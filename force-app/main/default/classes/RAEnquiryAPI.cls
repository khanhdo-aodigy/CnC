/** *****
 * Description : API class for create General Enquiry
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20201230             khanh.do@aodigy.com              Created Initial Version
 * 20210727             khanh.do@aodigy.com              PA Merging
 * 
** *****/

@RestResource (urlMapping = '/Enquiry/insert/*')
global with sharing class RAEnquiryAPI {
    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
    private static Utility.httpErrorResponse errorResponse;
    private static String errMessage = '';

    private static String processedRecId; 

    @HttpPost
    global static void doPost() 
    {
        try {
            processRequest();
        } 
        catch(Exception ex) {
            response.statusCode = 400;            
            response.responseBody = Blob.valueOf(JSON.Serialize(ex.getMessage()));
            loggerDataPool.buildLogDataPool('RAEnquiryAPI',ex);
            System.debug ('Exception: ' + ex.getMessage() + ' || .At line: ' + ex.getLineNumber());
        }

        if(errorResponse != null) {    
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('RAEnquiryAPI', 'RAEnquiryAPI', processedRecId, request, response);
    }

    private static void processRequest() 
    {
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        String firstName = reqBody.FirstName;
        String lastName  = reqBody.LastName;
        String mobile    = reqBody.Mobile;
        String email     = reqBody.Email;
        String subject   = reqBody.Subject;
        String enquiry   = reqBody.Enquiry;
        Boolean consentForMarketing = reqBody.ConsentForMarketingRA;
        
        /**Check Request Validity -- Start */
        if( String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(mobile) || 
                String.isBlank(email) || String.isBlank(subject) || String.isBlank(enquiry) || consentForMarketing == null) 
        {
            errMessage += ' Mandatory field is missing, please refer API doc.';
        }
        else if( !mobile.startsWith('65') ) 
        {
            errMessage += ' Invalid Mobile Phone, mobile must start with 65.';
        }
        else if( !mobile.isNumeric() ) 
        {
            errMessage += ' Invalid Mobile Phone, mobile must contain number only.';
        }
        
        if( String.isNotBlank(errMessage) ) {
            errorResponse = new Utility.HttpErrorResponse('Failed', errMessage);
            System.debug ('errorResponse: ' + errorResponse);
            return;
        }

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ General_Enquiry__c.SObjectType} );
        AccountUtil.RACustomerWrapper customerWrapper = new AccountUtil.RACustomerWrapper(firstName, lastName, email, mobile, consentForMarketing);

        Account personAcc = AccountUtil.upsertRACustomer(customerWrapper, 'Prospect');
        System.debug('@@@@DEBUG processRequest :: personAcc = ' + personAcc );

        General_Enquiry__c generalEnquiry = new General_Enquiry__c();
        generalEnquiry.RecordTypeId   = Schema.SObjectType.General_Enquiry__c.getRecordTypeInfosByDeveloperName().get('RA_General_Enquiry_RT').getRecordTypeId();
        generalEnquiry.Subject__c     = subject;
        generalEnquiry.Description__c = enquiry;
        uow.registerNew(generalEnquiry);

        uow.registerRelationship(generalEnquiry, General_Enquiry__c.Account__c, personAcc);
        uow.registerRelationship(generalEnquiry, General_Enquiry__c.Contact__c, new Contact(Id = personAcc.PersonContactId));

        uow.commitWork();
        processedRecId = generalEnquiry.Id;
        response.addHeader('Content-Type', 'application/json');
        response.statusCode   = 200;
        resBody.status        = 'Success';
        resBody.message       = 'Enquiry Id: ' + processedRecId;
        response.responseBody = Blob.valueOf(JSON.serialize(resBody));
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
        public String Subject;
        public String Enquiry;
        public Boolean ConsentForMarketingRA;
    }
}