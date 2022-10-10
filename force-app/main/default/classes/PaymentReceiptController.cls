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
        List<Sales_Agreement__c> saList = [ SELECT  Id, Name, FranchiseCode__c,
                                                    Account__c, Account__r.Name, Account__r.RecordType.DeveloperName,
                                                    Vehicle_Purchase_Price__c, BalancePayment__c,
                                                    (
                                                        SELECT Id, Name, Invoice_Value__c, CreatedDate
                                                        FROM Sales_Invoices__r
                                                    )
                                            FROM Sales_Agreement__c
                                            WHERE Id = :saId
                                        ];
        return saList.size() > 0 ? saList[0] : null;
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
        @AuraEnabled public String keyField { get; set; }
        @AuraEnabled public String salesAgreementId { get; set; }
        @AuraEnabled public String salesAgreementName { get; set; }
        @AuraEnabled public String salesInvoiceId { get; set; }
        @AuraEnabled public String salesInvoiceName { get; set; }
        @AuraEnabled public Date receiptDate { get; set; }
        @AuraEnabled public Decimal documentAmount { get; set; }
        @AuraEnabled public Decimal outstandingAmount { get; set; }
        @AuraEnabled public Decimal paymentAmount { get; set; }

        public ReceiptDetail(){}
    }

    @AuraEnabled
    public static Map<String, List<SObject>> createPaymentReceipt(Payment_Receipt__c receipt, List<ReceiptDetail> receiptDetails){
        Savepoint sp = Database.setSavepoint();  
        try {
            Map<String, List<SObject>> mapResults = new Map<String, List<SObject>>();

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
            
            // List<Debtor_Ledger__c> debtorLedgers = [    SELECT Id, Name 
            //                                             FROM Debtor_Ledger__c
            //                                             WHERE Account__c = :paymentReceipt.Bill_To__c
            //                                             LIMIT 1
            //                                         ];
            // Debtor_Ledger__c debtorLedger;
            // if(debtorLedgers.size() < 1) {
            //     AuraHandledException ex =  new AuraHandledException('');
            //     ex.setMessage('No Debtor Ledger found for this Customer');
            //     throw ex;
            // } else {
            //     debtorLedger = debtorLedgers[0];
            // }

            System.debug('paymentReceipt = ' + paymentReceipt);
            
              
            paymentReceipt.Bypass_Status_Validation__c = true; 
            insert paymentReceipt;
            
            paymentReceipt = PaymentReceiptService.getPaymentReceiptsById(paymentReceipt.Id);

            List<Payment_Receipt_Line_Item__c> prliList = new List<Payment_Receipt_Line_Item__c>();
            List<Debtor_Transaction__c> debtorTransList = new List<Debtor_Transaction__c>();
            for(ReceiptDetail item: receiptDetails) {
                Payment_Receipt_Line_Item__c prli = new Payment_Receipt_Line_Item__c();
                prli.Payment_Receipt__c = paymentReceipt.Id;
                prli.Sales_Agreement__c = item.salesAgreementId;
                prli.Sales_Invoice__c   = item.salesInvoiceId;
                prli.Document_Type__c   = 'Credit';
                prli.DB_CR__c           = 'CR';
                prli.Document_Amount__c = item.documentAmount;
                prli.Payment_Type__c    = paymentReceipt.Type__c;
                prli.Status__c          = 'Posted';

                prliList.add(prli);

                Debtor_Transaction__c debtorTran  = new Debtor_Transaction__c();
                debtorTran.Billing_Account__c     = paymentReceipt.Bill_To__c;
                debtorTran.Credit_Debit__c        = 'Credit';
                debtorTran.Date__c                = item.receiptDate;
                debtorTran.Document_Amount__c     = item.documentAmount;
                debtorTran.Franchise_Code__c      = paymentReceipt.Franchise_Code__c;
                debtorTran.Matched_Amount__c      = item.paymentAmount;
                debtorTran.Transaction_Type__c    = 'Sales Agreement';
                debtorTran.Payment_Receipt__c     = paymentReceipt.Id;
                debtorTran.Sales_Agreement__c     = item.salesAgreementId;
                debtorTransList.add(debtorTran);
            }
  
            insert prliList;
            insert debtorTransList;

            prliList = [ SELECT Id, Document_Type__c, Sales_Agreement__c, Sales_Agreement__r.Name,
                                Payment_Receipt__r.Name, Document_Amount__c, DB_CR__c
                         FROM Payment_Receipt_Line_Item__c
                         WHERE Payment_Receipt__c = :paymentReceipt.Id
            ];

            debtorTransList = [ SELECT Id, Name, Billing_Account__c, Credit_Debit__c, Date__c,
                                        Document_Amount__c, Franchise_Code__c,
                                        Matched_Amount__c, Transaction_Type__c, Payment_Receipt__c,
                                        Sales_Agreement__c
                                FROM Debtor_Transaction__c
                                WHERE Payment_Receipt__c = :paymentReceipt.Id            
            ];

                      
            paymentReceipt.Bypass_Status_Validation__c = false;
            update paymentReceipt;
            System.debug('paymentReceipt'+ paymentReceipt);  
            System.debug('prliList'+ prliList);  
            System.debug('debtorTransList'+ debtorTransList);  
                        
            mapResults.put('Payment_Receipt__c', new List<SObject>{paymentReceipt});
            mapResults.put('Payment_Receipt_Line_Item__c', prliList);
            mapResults.put('Debtor_Transaction__c', debtorTransList);
            return mapResults;

            
        } catch (Exception e) {
            Database.rollback( sp );
            System.debug(e.getMessage()+ ', Cause: ' + e.getCause() + '. At line: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Account getAccountInfo(String accountId){
        try {
            List<Account> accList = [  SELECT Id, Name, RecordType.DeveloperName
                                        FROM Account
                                        WHERE Id = :accountId
                                    ];
            return accList.size() > 0 ? accList[0] : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Sales_Invoice__c> getRelatedSIs(String accountId){
        try {
            List<Sales_Invoice__c> siList = new List<Sales_Invoice__c>();
            if(String.isNotBlank(accountId)) {
                siList = [   SELECT Id, Name, Sales_Agreement__c, Bill_To__c,
                                    Sales_Agreement__r.Bill_To__c,
                                    Sales_Agreement__r.Name,
                                    // Sales_Agreement__r.Account__c, Sales_Agreement__r.Account__r.Name,
                                    Sales_Agreement__r.Vehicle_Purchase_Price__c, Sales_Agreement__r.Balance_Payment__c
                            FROM Sales_Invoice__c
                            WHERE Bill_To__c = :accountId
                        ];

                                            
            }
            return siList;
        } catch (Exception e) {
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