/** *****
 * Description : Controller for Payment Receipt creation component
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20220912            khanh.do@aodigy.com           Created Initial Version. 
 * 
** *****/
public without sharing class PaymentReceiptController {

    public class ReceiptHeader
    {
        @AuraEnabled public String sObjName { get; set; }
        @AuraEnabled public SObject record { get; set; }

        private ReceiptHeader(){}
    }

    @AuraEnabled(cacheable=true)
    public static ReceiptHeader getReceiptHeader(Id recordId){
        try {
            ReceiptHeader result = new ReceiptHeader();

            String sObjName = recordId.getSObjectType().getDescribe().getName();
            switch on sObjName {
                when 'Sales_Agreement__c' {
                    Sales_Agreement__c dsa = getSAById(recordId);
                    result.sObjName  = 'Sales_Agreement__c';
                    result.record    = dsa;
                }
                when else {
                    AuraHandledException ex =  new AuraHandledException('');
                    ex.setMessage('Unsupported sObject');
                    throw ex;
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Sales_Agreement__c getSAById(String saId) {
        Set<String> excludingInvoiceStatus = new Set<String>{'Draft', 'Cancelled', 'Reversed'};
        List<Sales_Agreement__c> saList = [ SELECT  Id, Name, FranchiseCode__c,
                                                    Account__c, Bill_To__c, Bill_To__r.Name, Bill_To__r.RecordType.Name,
                                                    Vehicle_Purchase_Price__c, BalancePayment__c,
                                                    (
                                                        SELECT Id, Name, Invoice_Value__c, CreatedDate
                                                        FROM Sales_Invoices__r
                                                        WHERE Status__c NOT IN :excludingInvoiceStatus
                                                    )
                                            FROM Sales_Agreement__c
                                            WHERE Id = :saId
                                        ];
        return saList.size() > 0 ? saList[0] : null;
    }

    @AuraEnabled
    public static Account getAccountInfo(String accountId){
        try {
            List<Account> accList = [  SELECT Id, Name, RecordType.Name
                                        FROM Account
                                        WHERE Id = :accountId
                                    ];
            return accList.size() > 0 ? accList[0] : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Double> getCommissionMap(){
        try {
            List<Credit_Card_Type_and_Commission__mdt> creditCardtypeAndCommission = [  SELECT Id, Label, DeveloperName, CC_Commission__c
                                                                                        FROM Credit_Card_Type_and_Commission__mdt ];

            Map<String, Double> values = new Map<String, Double>();
            for(Credit_Card_Type_and_Commission__mdt creditCard:  creditCardtypeAndCommission) {
                values.put(creditCard.Label, creditCard.CC_Commission__c);
            }
            System.debug('getCommissionMap = ' + values);
            return values;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getGstRate(Date receiptDate){
        try {
            List<GST_Rate__mdt> gstRates= [ SELECT Id, GST__c, Star_Date__c, End_Date__c
                                            FROM GST_Rate__mdt
                                            WHERE Star_Date__c <= :receiptDate
                                            ORDER BY Star_Date__c DESC, End_Date__c NULLS LAST
                                            LIMIT 1
                                        ];

            return gstRates.size() > 0 ? gstRates[0].GST__c : 0;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ReceiptDetail
    {
        @AuraEnabled public String key { get; set; }
        @AuraEnabled public String salesAgreementId { get; set; }
        @AuraEnabled public String salesAgreementName { get; set; }
        @AuraEnabled public String salesInvoiceId { get; set; }
        @AuraEnabled public String salesInvoiceName { get; set; }
        @AuraEnabled public Decimal documentAmount { get; set; }
        @AuraEnabled public Decimal outstandingAmount { get; set; }
        @AuraEnabled public Decimal paymentAmount { get; set; }

        public ReceiptDetail(){}
    }

    @AuraEnabled
    public static List<ReceiptDetail> getReceiptDetails(String accountId, String franchiseCode){
        try {
                List<ReceiptDetail> receiptDetails = new List<ReceiptDetail>();
                if(String.isNotBlank(accountId)) {
                    DebtorTxnSelector dtSelector = new DebtorTxnSelector();
                    List<Debtor_Transaction__c> debtorTrans = dtSelector.selectByBillToAndFranchise(
                                                                    new Set<Id>{accountId},
                                                                    new Set<String>{franchiseCode},
                                                                    new Set<String>{'Debit'},
                                                                    null,
                                                                    true,
                                                                    true
                                                                );
                    
                    System.debug('debtorTrans = ' + debtorTrans);
                    for(Debtor_Transaction__c dt: debtorTrans) {
                        ReceiptDetail detailRow      = new ReceiptDetail();
                        detailRow.salesAgreementId   = dt.Sales_Agreement__c;
                        detailRow.salesAgreementName = dt.Sales_Agreement__r.Name;
                        detailRow.salesInvoiceId     = dt.Sales_Invoice__c;
                        detailRow.salesInvoiceName   = dt.Sales_Invoice__r.Name;
                        detailRow.documentAmount     = dt.Document_Amount__c;
                        detailRow.outstandingAmount  = dt.Outstanding_Amount__c;
                        detailRow.key                = dt.Id;

                        receiptDetails.add(detailRow);
                    }
                }
            
                return receiptDetails;
                                            
        } catch (Exception e) {
            System.debug('exception = ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }



    @AuraEnabled
    public static void createPaymentReceipt(Payment_Receipt__c receipt, List<ReceiptDetail> receiptDetails, Boolean isFinanceSettlement){
        Savepoint sp = Database.setSavepoint();  
        try {
            System.debug('receipt = ' + receipt);
            Map<String, Object> fieldsToValue = receipt.getPopulatedFieldsAsMap();
            System.debug('fieldsToValue = ' + fieldsToValue);
            Payment_Receipt__c paymentReceipt = new Payment_Receipt__c();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Payment_Receipt__c.fields.getMap();
            for(String fieldName : fieldsToValue.keySet()) {
                DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                Schema.DisplayType fieldType = fieldDescribe.getType();
                if(fieldDescribe.isUpdateable()) {
                    if(String.valueOf(fieldType) == 'PICKLIST'){
                        paymentReceipt.put(fieldName , String.valueOf( fieldsToValue.get(fieldName) ));
                    } else {
                        paymentReceipt.put(fieldName , fieldsToValue.get(fieldName));
                    }
                    
                }
            }
            
            System.debug('paymentReceipt = ' + paymentReceipt);
            
              
            paymentReceipt.Bypass_Status_Validation__c = true; 
            insert paymentReceipt;
            
            paymentReceipt = PaymentReceiptService.getPaymentReceiptsById(paymentReceipt.Id);

            List<Payment_Receipt_Line_Item__c> prliList = new List<Payment_Receipt_Line_Item__c>();
            List<Debtor_Transaction__c> debtorTransList = new List<Debtor_Transaction__c>();
            Set<String> setCompositeKey = new Set<String>();

            for(ReceiptDetail item: receiptDetails) {
                Payment_Receipt_Line_Item__c prli = new Payment_Receipt_Line_Item__c();
                prli.Payment_Receipt__c = paymentReceipt.Id;
                prli.Sales_Agreement__c = item.salesAgreementId;
                prli.Sales_Invoice__c   = item.salesInvoiceId;
                prli.Document_Type__c   = 'Credit';
                prli.DB_CR__c           = 'CR';
                prli.Document_Amount__c = paymentReceipt.Receipt_Amount__c;
                prli.Payment_Type__c    = paymentReceipt.Type__c;
                prli.Status__c          = 'Posted';
                prli.GST_Percentage__c  = paymentReceipt.GST_Percentage__c;

                prliList.add(prli);

                Debtor_Transaction__c debtorTran  = new Debtor_Transaction__c();
                debtorTran.Franchise_Code__c      = paymentReceipt.Franchise_Code__c;
                debtorTran.Billing_Account__c     = paymentReceipt.Bill_To__c;
                debtorTran.Transaction_Type__c    = paymentReceipt.Type__c;
                debtorTran.Date__c                = paymentReceipt.Receipt_Date__c;
                debtorTran.Due_Date__c            = null;
                debtorTran.Credit_Debit__c        = 'Credit';
                debtorTran.Document_Amount__c     = item.paymentAmount;
                debtorTran.Amount__c              = item.paymentAmount;
                debtorTran.Payment_Receipt__c     = paymentReceipt.Id;
                debtorTran.Sales_Agreement__c     = item.salesAgreementId;
                debtorTran.Sales_Invoice__c       = item.salesInvoiceId;
                debtorTransList.add(debtorTran);

                if(isFinanceSettlement) {
                    setCompositeKey.add(debtorTran.Billing_Account__c + '-' + debtorTran.Franchise_Code__c + '-' + debtorTran.Sales_Invoice__c); //Account Id (18chars) + '-' + Franchise Code + '-' + Sales Invoice Id (18chars)
                }
            }
  
            insert prliList;
            insert debtorTransList;
                      
            paymentReceipt.Bypass_Status_Validation__c = false;
            update paymentReceipt;

            if(isFinanceSettlement) {
                Date matchDate = Date.Today();
                DebtorTxnMatchService.doAutoMatch( setCompositeKey, matchDate, true );
            }
            
        } catch (Exception e) {
            Database.rollback( sp );
            System.debug(e.getMessage()+ ', Cause: ' + e.getCause() + '. At line: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }    
    

    /*@testVisible
    private static Boolean isDuplicatedPR(String saId) {
        List<Payment_Receipt__c> receiptList = [ SELECT Id, Sales_Agreement__c
                                                 FROM Payment_Receipt__c
                                                 WHERE Sales_Agreement__c = :saId
                                                ];
        if(receiptList.size() > 0) {
            return true;
        }
        return false;
    }*/

}