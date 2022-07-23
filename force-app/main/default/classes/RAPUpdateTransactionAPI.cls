/** *****
 * Description : API class called by UCS to update Transaction Price on Used_Car_Quote__c
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20220422             tan.nguyen@aodigy.com       Created Initial Version
 * 
** *****/

@RestResource (urlMapping = '/UsedCarQuote/updateTransaction/*')
global with sharing class RAPUpdateTransactionAPI {

    private static RestRequest req = RestContext.request;
    private static RestResponse res = RestContext.response;
    private static RequestBody reqBody = new RequestBody();
    private static ResponseBody resBody = new ResponseBody();
    private static String errMessage = '';
    private static String processedRecId;

    @HttpPost
    global static void doPost() {
        try {
            processPostRequest();
            
        } catch (Exception ex) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(ex.getMessage()));
            loggerDataPool.buildLogDataPool('RAPUpdateTransactionAPI', ex);
            System.debug ('Exception: ' + ex.getMessage() + ' || .At line ' + ex.getLineNumber() + ' || .Stack Trace ' + ex.getStackTraceString());
        }

        if (String.isNotBlank(errMessage)) {
            res.statusCode = 400;
            resBody.status = 'FAILED';
            resBody.message = errMessage;
            res.responseBody = Blob.valueOf(JSON.serialize(resBody));
            res.addHeader('Content-Type', 'application/json');
        }

        serviceDataPool.buildServiceDataPool('RAPUpdateTransactionAPI', 'RAPUpdateTransactionAPI', processedRecId, req, res);
    
    }

    private static void processPostRequest() {

        reqBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        String chassisNo = reqBody.ChassisNo;
        String vehicleNo = reqBody.VehicleNo;
        String purchaserCode = reqBody.PurchaserCode;
        TransactionWrapper transaction1 = reqBody.TransactionDetails;
        System.debug('Trans = ' + transaction1);
        Double purchasePrice = transaction1.PurchasePrice;
        String purchaseDate = transaction1.PurchaseDate;
        String carHandoverDate = transaction1.CarHandoverDate;
        String docNo = transaction1.DocNo;

        // Check Request Validity
        if (String.isBlank(chassisNo) || String.isBlank(vehicleNo) || String.isBlank(purchaserCode)
                || purchasePrice == null || String.isBlank(purchaseDate) || String.isBlank(carHandoverDate) || String.isBlank(docNo)) {

                errMessage = 'Missing mandatory field(s), please refer API doc.';
                return;
        }
        
        //Get User (ProfileId) by Purchaser Code
        List<User> purchaserList = [    SELECT Id, Purchaser_Code__c, ProfileId, Profile.Name
                                        FROM User
                                        WHERE Purchaser_Code__c = :purchaserCode
                                        AND IsActive = true
                                    ];
        System.debug('purchaserList = ' + purchaserList);                          
        if(purchaserList.isEmpty()) {
            errMessage = 'SF purchaser not found against Purchaser Code.';
            return;
        } else if(purchaserList.size() > 1){
            errMessage = 'More than one SF purchaser found against Purchaser Code.';
            return;
        }
        //Get Quote RecordTypeId by User Profile
        String recordTypeId = UsedCarQuoteService.getQuoteRecTypeIdByUserProfile(purchaserList[0].Profile.Name);
        System.debug('recordTypeId = ' + purchaserList);
        if(String.isBlank(recordTypeId)) {
            errMessage = 'SF purchaser was not associated to MF or MB Profile.';
            return;
        }

        List<Used_Car_Quote__c> existingQuotes = UsedCarQuoteService.getOpenQuotesByChassisNoAndVehicleNo(chassisNo, vehicleNo, ' AND RecordTypeId = \'' + recordTypeId + '\'');

        System.debug ('@@@@DEBUG processPostRequest :: existingQuotes = ' + existingQuotes);
        
        Used_Car_Quote__c existingQuote;
        if (existingQuotes.size() == 0) {
            errMessage = 'No active quotation found against Chassis/Vehicle No.';
            return;
        } else {
            existingQuote = existingQuotes[0];
        }

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{Used_Car_Quote__c.SObjectType});

        existingQuote.Chassis_No__c = chassisNo;
        existingQuote.Vehicle_No__c = vehicleNo;
        existingQuote.Purchase_Price__c = purchasePrice;
        existingQuote.Purchase_Date__c = Date.valueOf(purchaseDate);
        existingQuote.Car_Handover_Date__c = Date.valueOf(carHandoverDate);
        existingQuote.Doc_No__c = docNo;
        existingQuote.Status__c = 'Closed';
        System.debug('existingQuote = ' + existingQuote);

        uow.registerDirty(existingQuote);
        uow.commitWork();
        
        processedRecId = existingQuote.Id;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;
        resBody.status = 'SUCCESS';
        resBody.message = 'Updated Successfully';
        res.responseBody = Blob.valueOf(JSON.serialize(resBody));
        
    }

    public class RequestBody {
        public String ChassisNo;
        public String VehicleNo;
        public String PurchaserCode;
        public TransactionWrapper TransactionDetails;
    }

    public class TransactionWrapper {
        public Double PurchasePrice;
        public String PurchaseDate;
        public String CarHandoverDate;
        public String DocNo;
    }

    public class ResponseBody {
        public String status;
        public String message;
    }
}