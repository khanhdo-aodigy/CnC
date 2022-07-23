/** *****
 * Description : API Class to retrieve Refund Payment for eSHOP
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200630            HS@aodigy            Created Initial Version 
 * 
** *****/
@RestResource(urlMapping='/RefundCreditPayment/retrieve/*')
global class CMGetRefundCreditAPI {

    private static Map<String, List<Object>>  returnMapObject = new Map<String, List<Object>>();
    private static Map<String, String> errorResponseMap = new Map<String, String>();
    private static RestRequest req = RestContext.request;
    private static RestResponse res = RestContext.response;

    @HttpGet
    global static void getEShopRefundCredit(){
    
        try
        {
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            String startDate = req.params.get('startdate');
            
            System.debug('@@@@DEBUG CMGetRefundCreditAPI :: startDate = ' + startDate);
            Date date_start = String.isNotBlank(startDate) ? Date.valueOf(startDate) : Date.today().addDays(-1);
            Map<String,Invoice__c> mapCreditRefundPayments = PaymentService.getEshopRefundUsagePayments( date_start );
            List<PaymentWrapper> lstPayments = new List<PaymentWrapper>();

            for(String debitPaymentId : mapCreditRefundPayments.KeySet() ) 
            {
                Invoice__c creditPayment = mapCreditRefundPayments.get( debitPaymentId );
                
                PaymentWrapper pymt = new PaymentWrapper();
                pymt.PaymentId       = debitPaymentId;
                pymt.PaymentType     = creditPayment.Payment_Type__c;
                pymt.TransactionType = creditPayment.Transaction_Type__c;
                pymt.eInvoiceNumber  = creditPayment.eInvoice__c;
                pymt.OrderID         = creditPayment.E_shop_OrderId__c;
                pymt.Amount          = creditPayment.Net_Amount__c;
            
                lstPayments.add( pymt );
            }

            System.debug('@@@@DEBUG CMGetRefundCreditAPI :: lstPayments = ' + lstPayments.size() + ' --- ' + lstPayments);
            res.statusCode = 200;
            returnMapObject.put('Payments', (List<Object>)lstPayments);
            res.responseBody = Blob.valueOf(JSON.serialize(returnMapObject));
        }
        catch(Exception e){
            res.statusCode = 400;            
            errorResponseMap.put('Message', e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
            loggerDataPool.buildLogDataPool('getEShopRefundCredit', e);
        }
        //serviceDataPool.buildServiceDataPool('getEShopRefundCredit', 'CMGetRefundCreditAPI', '', request, res);
    }

    public class PaymentWrapper{
        public String PaymentId;
        public String PaymentType;
        public String TransactionType;
        public String eInvoiceNumber;
        public String OrderID;
        public Decimal Amount;
    }
}