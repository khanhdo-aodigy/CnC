/*******
 * Description : API class for Digital Payment
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20200608            thu.phan@aodigy.com     Created Initial Version 
 * 20210205            khanh.do@aodigy.com     Updated RA changes
*******/

@RestResource (urlMapping = '/DigitalPayment/*')
global class restDigitalPayment 
{
    private static RestResponse response = RestContext.response;
    private static RestRequest request = RestContext.request;
    private static DigitalPaymentWrapper reqBody = new DigitalPaymentWrapper();
    private static Order__c order = new Order__c();
    private static Map<String, Object> resBody = new Map<String, Object>();

    private static String errMessage = '';
    private static String processedRecId;

    @HttpPost
    global static void doPost() 
    {
        response.addHeader('Content-Type', 'application/json');
        
        try 
        {   
            createNewPayment();                
        }
        catch(Exception ex) 
        {
            loggerDataPool.buildLogDataPool('restDigitalPayment', ex);
            errMessage = ex.getMessage();
            loggerDataPool.buildLogDataPool('restDigitalPayment',ex);
            System.debug ('@@@@DEBUG restDigitalPayment :: Exception :: err.msg = ' + ex.getMessage() + ' || err.cause = ' + ex.getCause() + ' || err.line : ' + ex.getLineNumber() );

        }
        
        if( String.isNotBlank( errMessage ) ){
            resBody.put('status', 'Failed');
            resBody.put('message', errMessage);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(resBody));
        }
        else{
            resBody.put('status', 'Success');
            resBody.put('Payment Id', processedRecId);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(resBody));  
        }
        serviceDataPool.buildServiceDataPool('createNewPayment', 'restDigitalPayment', processedRecId, request, response);
    }

    public static void createNewPayment() 
    {
        reqBody = (DigitalPaymentWrapper)JSON.deserialize(request.requestBody.toString(), DigitalPaymentWrapper.class);        

        if(String.isBlank(reqBody.Event)) {
            errMessage += 'Missing Event. Please specify an Event Type. ';
            return;
        } else if( reqBody.Event != 'E-Shop' && reqBody.Event != 'RA') {
            errMessage += 'This Event Type is not supported. Please try again. ';
            return;
        }

        Invoice__c newPayment = new Invoice__c();        

        if (reqBody.Event == 'E-Shop') 
        {
            newPayment.RecordTypeId        = OrderService.getRecordTypeId('E_Shop_Payment_RT');
            newPayment.Transaction_Type__c = 'Purchase';
            newPayment.Payment_Type__c     = 'Receipt';

            order = OrderService.getOrder(reqBody.EshopOrderId);
            
            if (order <> null) {
                newPayment.Account__c                 = order.Account__c;
                newPayment.Contact__c                 = order.Contact__c;
                newPayment.E_shop_OrderId__c          = order.OrderID__c;
                newPayment.E_shop_Order__c            = order.Id;
                newPayment.E_shop_order_number__c     = order.E_shop_Order_Number__c;
                newPayment.E_shop_transaction_date__c = order.Transaction_Date__c;
                newPayment.eInvoice__c                = order.eInvoice__c;
                newPayment.eInvoice_Url__c            = order.eInvoice_URL__c;
                newPayment.eInvoice_Date__c           = order.eInvoice_Date__c;
            }
        }

        if (reqBody.Event == 'RA') {
            if( checkRARequiredFields() == false ){
                return;
            }

            newPayment.RecordTypeId  = OrderService.getRecordTypeId('RA_Payment_RT');                    
            newPayment.Net_Amount__c = reqBody.NetAmount;
            
            if(String.isNotBlank(reqBody.ReservationNumber)) {
                Vehicle_Stock_Reservation__c reservation = VehicleStockReservationService.getReservationByResevationNo(reqBody.ReservationNumber);
                if(reservation == null) {
                    errMessage += 'Invalid Reservation number';
                    return;
                } else {                    
                    newPayment.Used_Car_Stock_Reservation__c  = reservation.Id;
                    newPayment.Account__c = reservation.Account__c;
					newPayment.Used_Car_Vehicle_Stock__c = reservation.Used_Car_Vehicle_Stock__c;
					newPayment.Contact__c = reservation.Contact__c;
                }
            }
        }

        newPayment.Vehicle_Registration_Number__c = reqBody.VehicleRegistrationNumber;
        newPayment.Event__c                       = reqBody.Event;
        newPayment.CardType__c                    = reqBody.CardType;
        newPayment.MaskedCCNo__c                  = reqBody.MaskedCCNo;
        newPayment.Net_Amount__c                  = reqBody.TransactionAmountBySource;
        newPayment.Amount_With_GST__c             = reqBody.TransactionAmountBySource;
        newPayment.Transaction_ID__c              = reqBody.TransactionID;
        newPayment.Transaction_Status__c          = reqBody.TransactionStatus;
        newPayment.Brand__c                       = reqBody.SiteName;
        newPayment.Department__c                  = reqBody.Branch;

        

		//Below is a logic check for Transaction_ID__c, if record found than update else it will insert
		//Upsert somehow is not working via single record level. 
		//Next enhancement should include SOW framework for CRUD 
		List<Invoice__c> listInv = new List<Invoice__c>();
		if(String.isNotEmpty(reqBody.TransactionID))
		{
			listInv = [SELECT Id FROM Invoice__c WHERE Transaction_ID__c =: reqBody.TransactionID 
											     AND Transaction_Type__c = 'Purchase'
												 AND Payment_Type__c     = 'Receipt'];
		}

		if(listInv.size() > 0)
		{
			newPayment.Id = listInv[0].Id;
			update newPayment;
		} 
		else
		{
			insert newPayment;
		}

        processedRecId = newPayment.Id;
        resBody.put('status', 'Success');
        resBody.put('PaymentId', newPayment.Id);

        response.statusCode = 200;
        response.responseBody = Blob.valueOf(JSON.serialize(resBody));
    }

    private static Boolean checkRARequiredFields()
    {
        if( String.isBlank(reqBody.ReservationNumber) ||
                String.isBlank(reqBody.CardType) ||
                    String.isBlank(reqBody.MaskedCCNo) ||
                        reqBody.NetAmount == null ||
                            String.isBlank(reqBody.TransactionID) ||
                                String.isBlank(reqBody.TransactionStatus) ||
                                    String.isBlank(reqBody.SiteName) ||
                                        String.isBlank(reqBody.Branch))
        {
            errMessage += 'Mandatory field is missing, please refer to API doc. ';        
        }
        return (String.isBlank(errMessage));
    }
}