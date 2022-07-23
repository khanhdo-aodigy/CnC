/*
    Author: Hari Panneerselvam
*/
@RestResource (urlMapping = '/PaymentService/*')
global class restPaymentService {
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static map<String, Object> mapJSONBody = new map<String, Object>();
    private static map<String, Object> mapParams = new map<String, Object>();
    private static Utility.httpSuccessResponse successResponse;
    private static Utility.httpErrorResponse errorResponse;
    private static map<String, String> mapGenerateDE = new map<String, String>();
    
    @HttpPost
    global static void createPaymentDetails(){  
        res.addHeader('Content-Type', 'application/json');
        try{
            processPostRequest();
        }catch(Exception exce){
            loggerDataPool.buildLogDataPool('restPaymentService', exce);
            errorResponse = new Utility.httpErrorResponse('Failed', exce.getMessage());
        }
        if(successResponse != null){
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.Serialize(successResponse));
        }
        if(errorResponse != null){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        serviceDataPool.buildServiceDataPool('createPaymentDetails', 'restPaymentService', '', req, res);
    }
    
    public static void processPostRequest(){
        mapParams = req.params; 
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
       
        if(mapParams.get('transactiontype') == 'Purchase'){
            purchaseRequest();
        }else if(mapParams.get('transactiontype') == 'Refund'){
            refundRequest();
        }
    }
    
    public static void purchaseRequest(){
        list<Invoice__C> lstOpenInvoice = new list<Invoice__c>();
        map<String, Object> mapGenerateJSON = new map<String, Object>();
        String transactionId = (String)mapJSONBody.get('TransactionID');
        
        if((String)mapJSONBody.get('CustomerEmail') != '' && (transactionId == null || transactionId == '')){
            lstOpenInvoice = Utility.checkForOpenInvoice((String)mapJSONBody.get('CustomerEmail'));
        }
        if(lstOpenInvoice != null && lstOpenInvoice.size() > 0){
            mapGenerateJSON.put('InvoiceNo', lstOpenInvoice[0].Invoice_Number__c);
            mapGenerateJSON.put('PaymentId', lstOpenInvoice[0].Id);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(mapGenerateJSON));
        }else{
            Invoice__c invoiceInfo = createOrUpdateReceipt();
            if(invoiceInfo.Transaction_ID__c != null){
                //successResponse = new Utility.httpSuccessResponse('Success', 'Payment updated successfully.');
                list<Invoice__c> lstInvoice = [select Id,Invoice_Number__c from Invoice__c where id = :invoiceInfo.id];
                mapGenerateJSON.put('InvoiceNo', lstInvoice[0].Invoice_Number__c);
                mapGenerateJSON.put('PaymentId', lstInvoice[0].Id);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(mapGenerateJSON));
            }else{
                list<Invoice__c> lstInvoice = [select Id,Invoice_Number__c, SequenceIdentifier__c, Campaign__r.CampaignId__c, Campaign__c from Invoice__c where id = :invoiceInfo.id];
                
                
                System.debug('#### lstInvoice ---- ' + lstInvoice.get(0));
                System.debug('#### Campaign__c ---- ' + lstInvoice.get(0).Campaign__c);
                System.debug('#### Campaign__r.CampaignId__c ---- ' + lstInvoice.get(0));
                mapGenerateJSON.put('InvoiceNo', lstInvoice[0].Invoice_Number__c);
                mapGenerateJSON.put('PaymentId', lstInvoice[0].Id);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(mapGenerateJSON));
            }
        }
    }
    
    public static void refundRequest(){
        list<Invoice__c> lstInvoice = new list<Invoice__c>();
        lstInvoice = [select id, Transaction_Type__c from Invoice__c where StockReservation__r.Name = :(String)mapJSONBody.get('StockReservationNo')
                        and Payment_Type__c = 'Receipt' and StockReservation__r.Customer_Email__c = :(String)mapJSONBody.get('CustomerEmail') 
                        and Transaction_Type__c != 'Cancel' limit 1];
        if(lstInvoice != null && lstInvoice.size() > 0){
            if(lstInvoice[0].Transaction_Type__c == 'Purchase'){
                lstInvoice[0].Transaction_Type__c = (String)mapParams.get('transactiontype');
                lstInvoice[0].Refund_Reason__c = ((String)mapJSONBody.get('Reason')).left(250);
                TriggerExclusion.excludeTrigger('Payment', true);
                update lstInvoice;
                TriggerExclusion.excludeTrigger('Payment', false);
                releaseReservedStock((String)mapJSONBody.get('StockReservationNo'));
                successResponse = new Utility.httpSuccessResponse('Success', 'Refund request created.');
            }else if(lstInvoice[0].Transaction_Type__c == 'Refund'){
                errorResponse = new Utility.httpErrorResponse('Failed', 'You have already requested for refund.');
            }
        }else{
            errorResponse = new Utility.httpErrorResponse('Failed', 'There is no Stock Reservation found for this customer.');
        }
    }
    
    public static Invoice__c createOrUpdateReceipt(){
        Invoice__c invoiceInfo = new Invoice__c();
        list<Invoice__c> availableInvoice = new list<Invoice__c>();
        if((String)mapJSONBody.get('InvoiceNo') != null && (String)mapJSONBody.get('InvoiceNo') != ''){
            availableInvoice = [select id from Invoice__c where Invoice_Number__c = :(String)mapJSONBody.get('InvoiceNo')];
            invoiceInfo.id = availableInvoice[0].id;
            invoiceInfo.Net_Amount__c = mapJSONBody.get('PaymentAmount') != null ? Integer.valueOf((String)mapJSONBody.get('PaymentAmount')) : null;
            invoiceInfo.Transaction_ID__c = mapJSONBody.get('TransactionID') != null ? (String)mapJSONBody.get('TransactionID') : '';
            invoiceInfo.Transaction_Status__c = mapJSONBody.get('TransactionStatus') != null ? (String)mapJSONBody.get('TransactionStatus') : '';
            invoiceInfo.MaskedCCNo__c = mapJSONBody.get('MaskedCCNo') != null ? (String)mapJSONBody.get('MaskedCCNo') : '';
            invoiceInfo.CardType__c = mapJSONBody.get('CardType') != null ? (String)mapJSONBody.get('CardType') : '';
        }else{
            invoiceInfo.SeqNum__c = Utility.getSequenceNo((String)mapParams.get('branch'));
            invoiceInfo.Department__c = mapParams.get('branch') != null ? (String)mapParams.get('branch') : '';
            invoiceInfo.Payment_Type__c = mapParams.get('paymenttype') != null ? (String)mapParams.get('paymenttype') : '';
            invoiceInfo.Transaction_Type__c = mapParams.get('transactiontype') != null ? (String)mapParams.get('transactiontype') : ''; 
            invoiceInfo.Customer_Email__c = (String)mapJSONBody.get('CustomerEmail');
            
            //Different Invoice Number for Paid Events
            if( mapJSONBody.containsKey('EventID') ){
                String campId = (String) mapJSONBody.get('EventID');
                String ptEvt = 'Paid Event';
                if( String.isNotBlank(campId) ){
                    try{
                        //Update Sequence Number
                        invoiceInfo.SeqNum__c = Utility.getSequenceNoEvent((String)mapParams.get('branch'),campId);
                        invoiceInfo.SequenceIdentifier__c = ptEvt;
                        invoiceInfo.Campaign__c = campId; 
                    }catch(Exception e){
                        loggerDataPool.buildLogDataPool('restPaymentService', e);
                    }
                }
            }
        }
        upsert invoiceInfo;
        return invoiceInfo;
    }
    
    public static void releaseReservedStock(String stockReservationNo){
        Stock_Reservation__c stockToRelease = [select id, OwnerId, Model_Description__c, Reservation_Status__c, Cancellation_Reason__c, Opportunity__c, Stock_Source__c from Stock_Reservation__c where name = :stockReservationNo];
        stockToRelease.Reservation_Status__c = 'Cancel';
        stockToRelease.Cancellation_Reason__c = ((String)mapJSONBody.get('Reason')).left(250);
        Opportunity oppToClose = [select id, stagename, Owner.Username2__c from Opportunity where id = :stockToRelease.Opportunity__c];
        update stockToRelease;
        Utility.createToDoTask(stockToRelease, 'Refund');
        //BusinessRuleHandlerVSMS.updateStockInVSMS(stockToRelease.id, oppToClose.Owner.Username2__c);
        BusinessRuleHandlerVSMS.updateStockVSMS(stockToRelease.id, oppToClose.Owner.Username2__c, true);
        mapGenerateDE.put('brand', (String)mapParams.get('branch'));
        mapGenerateDE.put('stockReserveId', stockToRelease.id);
        mapGenerateDE.put('emailFor', 'Cust');
        mapGenerateDE.put('emailType', 'Refund');
        if(mapParams.get('branch') == 'CCK'){
            mapGenerateDE.put('fromAddress', 'sales.kia.sg@e.cyclecarriage.com');
            mapGenerateDE.put('fromName', 'C&C Kia Showroom');
        }else if(mapParams.get('branch') == 'CCA'){
            mapGenerateDE.put('fromAddress', 'sales.mitsubishi.sg@e.cyclecarriage.com');
            mapGenerateDE.put('fromName', 'C&C Mitsubishi Showroom');
        }else if(mapParams.get('branch') == 'CCF'){
            mapGenerateDE.put('fromAddress', 'sales.citroen.sg@e.cyclecarriage.com');
            mapGenerateDE.put('fromName', 'C&C Citroen Showroom');

			if(stockToRelease.Model_Description__c.contains('DS'))
			{
				mapGenerateDE.put('fromAddress', 'sales.DS.sg@e.cyclecarriage.com');
				mapGenerateDE.put('fromName', 'C&C DS Showroom');
			}

        }
        BusinessRuleHandlerSFMC.sendEmail(mapGenerateDE);
        mapGenerateDE.put('emailFor', 'SC');
        BusinessRuleHandlerSFMC.sendEmail(mapGenerateDE);
    }
    
}