/*****************************************
 * Class Name: WarehousePaymentWithoutInfo
 * Description: WAREHOUSE PAYMENT MONITORING
 * 				for Failed and Invalid payment
 * 
 *****************************************/
public class WarehousePaymentWithoutInfo implements Schedulable{

    public void execute(SchedulableContext sc){
        List<Invoice__c> invList = new List<Invoice__c>();
        invList = [SELECT Id
                   FROM Invoice__c 
                   WHERE PaymentSource__c NOT IN ('AfterSales','Event') 
                   AND (Product_Name__c = null OR StockReservation__c = NULL) 
                   AND Transaction_Status__c != 'voided' 
                   AND CreatedDate > :DateTime.now().addMinutes(-30) LIMIT 1 ];
        
        if(invList!=null && !invList.isEmpty()){
            //Email Report
            fetchData();
        }
    }    
    
    public static void fetchData(){
        try{
            
            String header = 'RecordId,CustomerName, CustomerEmail, NRIC, VehicleNumber, BrainTreeTransacDate, Invoice No, TransactionID, PaymentSource, TransactionStatus,'
                +
                'BranchCode, ProductItemQuantity, ProductName,Amount wGST,Amount withoutGST, CommissionRateFixedCharge, NetAmount(After Commission),Sales Agreement Number \n';
            
            
            String bodyContent = header ;
            List<Invoice__c> invList = new List<Invoice__c>();
            invList = [SELECT Id, Customer_Name__c, Customer_Email__c, NRIC__c, 
                       Vehicle_Registration_Number__c, Date_Time_of_Purchase__c, Invoice_Number__c,
                       Transaction_ID__c, PaymentSource__c, Transaction_Status__c, Department__c, 
                       Product_Item_Quantity__c, Product_Name__c, Amount_With_GST_For_Report__c, 
                       Amount_Without_GST__c, Commission_Rate__c, Net_Amount_After_Commission__c, 
                       AK_Number__c
                       FROM Invoice__c 
                       WHERE PaymentSource__c NOT IN ('AfterSales','Event') 
                       AND (Product_Name__c = null OR StockReservation__c = NULL)
                       AND CreatedDate > :DateTime.now().addMinutes(-30) 
                       AND Transaction_Status__c != 'voided' 
                       ORDER BY Department__c, CreatedDate ASC ];
            
            if( invList!=null && !invList.isEmpty()){
                for(Invoice__c a: invList)
                {
                    String recStr = '"'+a.id+'","'+a.Customer_Name__c+'","'+a.Customer_Email__c+'","'+ a.NRIC__c+'","' + a.Vehicle_Registration_Number__c+'","'
                        + a.Date_Time_of_Purchase__c+'","' + a.Invoice_Number__c+'","'  + a.Transaction_ID__c+'","' + a.PaymentSource__c+'","' + a.Transaction_Status__c+'","'
                        + a.Department__c+'","' + a.Product_Item_Quantity__c+'","'  + a.Product_Name__c+'","' + a.Amount_With_GST_For_Report__c+'","' + a.Amount_Without_GST__c+'","'
                        + a.Commission_Rate__c+'","' + a.Net_Amount_After_Commission__c+'","' + a.AK_Number__c +'"\n';
                    bodyContent = bodyContent + recStr;
                }
                
                //Send Email
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                blob csvBlob = Blob.valueOf(bodyContent);
                string csvname= 'Payment_Records_without_Product_Name.csv';
                csvAttc.setFileName(csvname);
                csvAttc.setBody(csvBlob);
                
                
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                
                List<String> toAddresses = new List<String>();
               
                for(EmailRecipient__mdt em: [SELECT ID, RecipientEmailAddress__c 
                                             FROM EmailRecipient__mdt 
                                             WHERE EventType__c='WarehousePaymentMonitor'
                                             AND IsRecipient__c=true])
                {
                    toAddresses.add(em.RecipientEmailAddress__c);
                }
                
                
                String subject = 'Total: ' + invList.size() + ' Warehouse - Payment without ProductName';
                email.setSubject(subject);
                email.setToAddresses( toAddresses );
                email.setPlainTextBody('Warehouse Payments without Product Name run at ' + DateTime.now() + '\n Total Records : ' + invList.size());
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('WarehousePaymentWithoutInfo', e);
        }
    }
}