//Class for DWH service Package Items
Public class BrainTree_GetInvoiceItem_PurchaseData
{
    Public static Integer count=0;
    Public static Invoice__c tempInvoice;
    Public Static Boolean isSuccess  = True;
    
    //Create future call out method for http call    
    @future (callout=true)
    public static void getInvoiceData()            
    {
        
        //create http request, response objects here
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        
        Date today = Date.today();
         
        Datetime RunStartDatetime =  today-6;
        Datetime RunEndDatetime = today;
        
        String RunStartDatetimest = RunStartDatetime.format('dd-MM-yyyy')+' 00:00:00';   
        String RunEndDatetimest = RunEndDatetime.format('dd-MM-yyyy')+' 00:00:00'; 
        //Set properties of the  http request
        req.setEndpoint(APIGateway_url+'/Payment/search');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('apikey', APIGateway_key);
        req.setBody('{"StartDateTime": "'+RunStartDatetimest+'","EndDateTime": "'+RunEndDatetimest+'","TransactionType": "sale","IsRefund": false,"Statuses": [  "authorized",  "authorizing",  "settled",  "settling",  "settlement_confirmed",  "settlement_pending",  "submitted_for_settlement"]}');
        req.setTimeout(40000);
        try 
        {   
            //Send http request, capture response and pass the response to mothod which 
            //will then process the same and update the SFSC object
            resInput = http.send(req);         
            UpdateData(resInput);
        }
        catch(exception ex1)
        {
        }
    }
    //read json response
    public static void UpdateData(HttpResponse res)            
    {
        //List of objects with updated response
        Map<String, Invoice__c> LstInvoiceItem = new Map<String, Invoice__c>();
        try 
        {        
            // Parse entire JSON response.        
            JSONParser parser = JSON.createParser(res.getBody());
            
            while (parser.nextToken() != null) {
                // Start at the array of Variants.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        //  find next varient object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire variant object, including its array of line items.
                            Invoice sVar = (Invoice)parser.readValueAs(Invoice.class);
                            tempInvoice = New Invoice__c ();  
                            tempInvoice.Transaction_ID__c = sVar.TransactionId ;
                            tempInvoice.Transaction_Status__c = sVar.TransactionStatus; 
                            tempInvoice.Amount_With_GST__c = sVar.Amount ;
                            tempInvoice.Transaction_Type__c = 'Purchase';
                            tempInvoice.Discount__c = sVar.DiscountAmount ;
                            String formattedDt = sVar.TransactionDate.substringBefore(' ');
                            String formattedTime = sVar.TransactionDate.substringAfter(' ');
                            String dt =formattedDt.substringAfterLast('-')+'-'+formattedDt.substringAfter('-').substringBefore('-')+'-'+formattedDt.substring(0,2);                           
                            tempInvoice.Date_Time_of_Purchase__c =  datetime.valueOf(dt+' '+formattedTime);
                            LstInvoiceItem.put(tempInvoice.Transaction_ID__c, tempInvoice);
                        }
                    }
                }
            }
            
            /* added by grazitti for Transaction_Type__c = refund starts */
            for(Invoice__c ic : [SELECT Id,Transaction_ID__c, Transaction_Type__c FROM Invoice__c WHERE Transaction_ID__c IN:LstInvoiceItem.keySet()  AND Transaction_Type__c= 'Refund']){
                if(LstInvoiceItem.ContainsKey(ic.Transaction_ID__c)){
                    Invoice__c tempInvoice = LstInvoiceItem.get(ic.Transaction_ID__c);
                    tempInvoice.Transaction_Type__c = 'Refund';
                    LstInvoiceItem.put(tempInvoice.Transaction_ID__c, tempInvoice);
                }

            }
            /* added by grazitti for Transaction_Type__c = refund ends*/          
            
            //Upsert the list of updated variants into SFSC.
            Database.UpsertResult[] results = Database.upsert(LstInvoiceItem.values(),Invoice__c.Fields.Transaction_ID__c, False);       
            system.debug('invoices: '+LstInvoiceItem);
            List<Invoice__c> lst = LstInvoiceItem.values();
            //Verify and Log the records which were created, updated and threw an error.
            for(Integer index = 0, size = results.size(); index < size; index++) 
            {
                if(results[index].isSuccess()) 
                {  
                    System.debug(lst[index].Transaction_ID__c+' was updated');
                }
                else
                {
                    system.debug(lst[index].Transaction_ID__c +' had error '+results[index].getErrors());
                    
                }
            }
        } 
        catch(System.Exception e) 
        {
            isSuccess = False;
            System.debug('Error: '+ e);
        }
    }
    //Define Variant parser class here to parse JSON values to variant fields.
    public class Invoice {
        
        public String TransactionId;
        public String TransactionStatus;
        public String TransactionType;
        public String RefundedTransactionId;
        public String  TransactionDate;
        public Decimal Amount;
        public String InvoiceNo;
        public String CustomerId;
        public String Department;
        public Decimal TaxAmount;
        public Decimal DiscountAmount;
        
        
        public Invoice(String TransactionIdstr, String TransactionStatusstr, String TransactionTypestr, String RefundedTransactionIdstr, 
                       String  TransactionDatestr , Decimal Amountstr,String InvoiceNostr, 
                       String CustomerIdstr, String Departmentstr, Decimal TaxAmountstr, Decimal DiscountAmountstr) 
        {
            TransactionId = TransactionIdstr;
            TransactionStatus = TransactionStatusstr;
            TransactionType = TransactionTypestr;
            RefundedTransactionId = RefundedTransactionIdstr;
            TransactionDate = TransactionDatestr;
            Amount = Amountstr;
            InvoiceNo = InvoiceNostr;
            CustomerId = CustomerIdstr;
            Department = Departmentstr;
            TaxAmount = TaxAmountstr;
            DiscountAmount = DiscountAmountstr;
            
        }
    } 
    
}