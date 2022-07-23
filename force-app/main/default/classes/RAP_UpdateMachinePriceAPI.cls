/** *****
 * Description : API class called by Machine Learning System (Databricks) to update Machine Price on Used_Car_Quote__c
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20220421             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/

@RestResource (urlMapping = '/UsedCarQuote/updateMachinePrice/*')
global with sharing class RAP_UpdateMachinePriceAPI {
    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
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
            loggerDataPool.buildLogDataPool('RAP_UpdateMachinePriceAPI',ex);
            System.debug ('Exception: ' + ex.getMessage() + ' || .At line: ' + ex.getLineNumber());
        }

        if( String.isNotBlank(errMessage) ) {    
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            resBody.status = 'FAILED';
            resBody.message = errMessage;
            response.responseBody = Blob.valueOf(JSON.Serialize(resBody));
        }
        
        serviceDataPool.buildServiceDataPool('RAP_UpdateMachinePriceAPI', 'RAP_UpdateMachinePriceAPI', processedRecId, request, response);
    }

    private static void processRequest() 
    {
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);        
        
        if( String.isBlank(reqBody.QuoteID) || String.isBlank(reqBody.MachineQuote) || String.isBlank(reqBody.Depreciation) )
        {
            errMessage += ' Mandatory field is missing, please refer API doc.';
            return;
        }

        String quoteId       = reqBody.QuoteID;
        Double machineQuote  = Double.valueOf(reqBody.MachineQuote);
        Double depreciation  = Double.valueOf(reqBody.Depreciation);    
        String error = reqBody.MachineError;

        Used_Car_Quote__c existingQuote = UsedCarQuoteService.getUsedCarQuoteById(quoteId);
        
        
        System.debug('@@@@DEBUG processRequest :: existingQuote = ' + existingQuote );
        if( existingQuote == null) {
            errMessage += ' Invalid Quote ID.';
            return;
        }

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Used_Car_Quote__c.SObjectType} );

        existingQuote.Machine_Quote__c        = machineQuote; 
        existingQuote.Machine_Depreciation__c = depreciation;
        existingQuote.Machine_Error__c        = error;
        uow.registerDirty(existingQuote);
        uow.commitWork();
        
        processedRecId = existingQuote.Id;
        response.addHeader('Content-Type', 'application/json');
        response.statusCode   = 200;
        resBody.status        = 'SUCCESS';
        resBody.message       = 'Updated successfuly';
        response.responseBody = Blob.valueOf(JSON.serialize(resBody));
    }

    public class RequestBody 
    {
        public String QuoteID; 
        public String MachineQuote;
        public String Depreciation;
        public String MachineError;
    }

    public class ResponseBody 
    {
        public String status;
        public String message;
    }
}