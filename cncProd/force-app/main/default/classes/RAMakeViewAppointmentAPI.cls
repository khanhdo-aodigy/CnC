/** *****
 * Description : API class for schedule Viewing Appointment
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20201230             khanh.do@aodigy.com              Created Initial Version
 * 20210727             khanh.do@aodigy.com              Person Account Merging
 * 
** *****/

@RestResource (urlMapping = '/ViewAppointment/insert/*')
global with sharing class RAMakeViewAppointmentAPI {

    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
    private static Utility.httpErrorResponse errorResponse;
    private static String errMessage = '';
    private static String processedRecId; 

    @HttpPost
    global static void insertAppointment() 
    {
        try {
            processRequest();
        } 
        catch(Exception ex) {
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(ex.getMessage()));
            loggerDataPool.buildLogDataPool('RAMakeViewAppointmentAPI',ex);
            System.debug ('Exception: ' + ex.getMessage() + ' || .At line: ' + ex.getLineNumber());
        }

        if(errorResponse != null) {    
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('RAMakeViewAppointmentAPI', 'RAMakeViewAppointmentAPI', processedRecId, request, response);
    }

    private static void processRequest() 
    {
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        System.debug('Testing --- reqBody = ' + reqBody);
        String firstName = reqBody.FirstName;
        String lastName  = reqBody.LastName;
        String mobile    = reqBody.Mobile;
        String email     = reqBody.Email;
        Date appointment = String.isNotBlank(reqBody.Appointment) ? Date.Parse(reqBody.Appointment) : null;
        String location  = reqBody.Location;
        String docNo     = reqBody.DocNo;
        String scName    = reqBody.SCName;
        String scEmail   = reqBody.SCEmail;
        String scMobile  = reqBody.SCMobile;
        Boolean consentForMarketing = reqBody.ConsentForMarketingRA;

        /**Check Request Validity -- Start */
        if( String.isBlank(firstName) || String.isBlank(lastName)
            || String.isBlank(mobile) || String.isBlank(email) 
            || appointment == null || String.isBlank(location)
            || String.isBlank(docNo) || String.isBlank(scName)
            || String.isBlank(scEmail) || String.isBlank(scMobile) || consentForMarketing == null
        ) {
             errMessage += ' Mandatory field is missing, please refer API doc.';
        }
        else if( !mobile.startsWith('65') || !scMobile.startsWith('65') ) {
            errMessage += ' Invalid Mobile Phone, mobile must start with 65.';
        }
        else if( !mobile.isNumeric() || !scMobile.isNumeric() ) {
            errMessage += ' Invalid Mobile Phone, mobile must contain number only.';
            System.debug ('errorResponse: ' + errorResponse);
        }
        
        if( String.isNotBlank(errMessage) ) {
            errorResponse = new Utility.HttpErrorResponse('Failed', errMessage);
            System.debug ('errorResponse: ' + errorResponse);
            return;
        }
        /**Check Request Validity -- End*/

        //Check Vehicle Stock
        Used_Car_Vehicle_Stock__c vehStock = UsedCarVehicleStockService.getVehicleStockByStockNumber(docNo);
        if(vehStock == null) {
            errorResponse = new Utility.HttpErrorResponse('Failed', 'Invalid Used Car Vehicle Stock Number');
            return;
        }

        AccountUtil.RACustomerWrapper customerWrapper = new AccountUtil.RACustomerWrapper(firstName, lastName, email, mobile, consentForMarketing);

        Account personAcc = AccountUtil.upsertRACustomer(customerWrapper, 'Prospect');
        System.debug('@@@@DEBUG processRequest :: personAcc = ' + personAcc );

        Sales_Opportunity__c salesOpp = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, scEmail, scName, scMobile);
        
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Schedule_Viewing__c.SObjectType} );

        Schedule_Viewing__c viewAppt = new Schedule_Viewing__c();
        viewAppt.RecordTypeId = Schema.SObjectType.Schedule_Viewing__c.getRecordTypeInfosByDeveloperName().get('RA_Schedule_Viewing_RT').getRecordTypeId();
        viewAppt.Appointment_Date_Time__c    = appointment;
        viewAppt.Location__c                 = location;
        uow.registerNew(viewAppt);
        uow.registerRelationship(viewAppt, Schedule_Viewing__c.Sales_Opportunity__c, salesOpp);
        uow.registerRelationship(viewAppt, Schedule_Viewing__c.Account__c, personAcc);
        uow.registerRelationship(viewAppt, Schedule_Viewing__c.Contact__c, new Contact(Id = personAcc.PersonContactId));
        uow.registerRelationship(viewAppt, Schedule_Viewing__c.Used_Car_Vehicle_Stock__c, vehStock);

        uow.commitWork();
        viewAppt = [SELECT Name 
                    FROM Schedule_Viewing__c
                    WHERE Id = :viewAppt.Id];
        
        processedRecId = viewAppt.Id;
        response.addHeader('Content-Type', 'application/json');
        response.statusCode = 200;
        resBody.status      = 'Success';
        resBody.message     = 'Appointment Number: ' + viewAppt.Name;
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
        public String Appointment;
        public String Location;
        public String DocNo; //Vehicle Stock No
        public String SCName;
        public String SCEmail;
        public String SCMobile;
        public Boolean ConsentForMarketingRA;
    }
}