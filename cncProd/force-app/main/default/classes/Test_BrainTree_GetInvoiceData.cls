@isTest(SeeAllData=true)
public class Test_BrainTree_GetInvoiceData {

public static testmethod void test_GetData() 
{    
    BrainTree_GetInvoiceItem_PurchaseData.getInvoiceData();
    BrainTree_GetInvoiceItem_CreditData.getInvoiceData();
    BrainTree_GetInvoiceItem_CancelData.getInvoiceData();
}

public static testmethod void test_PurchaseData() 
{  
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('[{"TransactionId":"nzpe9g9m","TransactionStatus":"settled","TransactionType":"sale","RefundedTransactionId":null,"InvoiceNo":"SG-CCK-1807-00016313","CustomerId":"S7531525B","Department":"KIA-LK","TransactionDate":"20-07-2018 11:55:29","Amount":1000,"TaxAmount":null,"DiscountAmount":null}]');
    res.setStatusCode(200);
    BrainTree_GetInvoiceItem_PurchaseData.UpdateData(res);
    
    BrainTree_GetInvoiceItem_PurchaseData.Invoice BTObj = new BrainTree_GetInvoiceItem_PurchaseData.Invoice('','','','','',0.0,'','','',0.0,0.0);
}

public static testmethod void test_CreditData() 
{  
      HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('[{"TransactionId":"m8j8qvkk","TransactionStatus":"settled","TransactionType":"credit","RefundedTransactionId":"9e9emhja","InvoiceNo":"SG-CCK-1807-00005044","CustomerId":"S7531525B","Department":"","TransactionDate":"21-07-2018 06:58:43","Amount":1000,"TaxAmount":null,"DiscountAmount":null}]');
    res.setStatusCode(200);
    BrainTree_GetInvoiceItem_CreditData.UpdateData(res);
    
    BrainTree_GetInvoiceItem_CreditData.Invoice BTObj = new BrainTree_GetInvoiceItem_CreditData.Invoice('','','','','',0.0,'','','',0.0,0.0);
}
    
public static testmethod void test_CancelData() 
{  
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('[{"TransactionId": "145zht6n","TransactionStatus": "voided","TransactionType": "sale","RefundedTransactionId": null,"InvoiceNo": "JCC-0001","CustomerId": "C12345","Department": "KIA - LK","TransactionDate": "28-06-2018 10:18:33","Amount": 10,"TaxAmount": null,"DiscountAmount": null}]');
    res.setStatusCode(200);
    BrainTree_GetInvoiceItem_CancelData.UpdateData(res);
    
    BrainTree_GetInvoiceItem_CancelData.Invoice BTObj = new BrainTree_GetInvoiceItem_CancelData.Invoice('','','','','',0.0,'','','',0.0,0.0);
}
}