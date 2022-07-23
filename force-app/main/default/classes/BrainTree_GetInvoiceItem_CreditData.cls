//Class for DWH service Package Items
Public class BrainTree_GetInvoiceItem_CreditData
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
        Datetime RunEndDatetime = today+1;
        
        String RunStartDatetimest = RunStartDatetime.format('dd-MM-yyyy')+' 00:00:00';   
        String RunEndDatetimest = RunEndDatetime.format('dd-MM-yyyy')+' 00:00:00';   
        //Set properties of the  http request
        req.setEndpoint(APIGateway_url+'/Payment/search');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('apikey', APIGateway_key);
        req.setBody('{"StartDateTime": "'+RunStartDatetimest+'","EndDateTime": "'+RunEndDatetimest+'","TransactionType": "credit","IsRefund": true,"Statuses": []}');
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
        list<Invoice__c> LstInvoiceItem = new list<Invoice__c>();
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
                            tempInvoice.Transaction_ID__c = sVar.RefundedTransactionId ;
                            tempInvoice.Transaction_Status__c = sVar.TransactionStatus; 
                            tempInvoice.Amount_With_GST__c = sVar.Amount ;
                            tempInvoice.Transaction_Type__c = 'Refund';
                            tempInvoice.Discount__c = sVar.DiscountAmount ;
                            String formattedDt = sVar.TransactionDate.substringBefore(' ');
                            String formattedTime = sVar.TransactionDate.substringAfter(' ');
                            String dt =formattedDt.substringAfterLast('-')+'-'+formattedDt.substringAfter('-').substringBefore('-')+'-'+formattedDt.substring(0,2);                           
                            tempInvoice.Date_Time_of_Purchase__c =  datetime.valueOf(dt+' '+formattedTime);
                            LstInvoiceItem.add(tempInvoice);
                        }
                    }
                }
            }            
            
            //Upsert the list of updated variants into SFSC.
            Database.UpsertResult[] results = Database.upsert(LstInvoiceItem,Invoice__c.Fields.Transaction_ID__c, False);       
            system.debug('invoices: '+LstInvoiceItem);
            
            //Verify and Log the records which were created, updated and threw an error.
            for(Integer index = 0, size = results.size(); index < size; index++) 
            {
                if(results[index].isSuccess()) 
                {  
                    System.debug(LstInvoiceItem[index].Transaction_ID__c+' was updated');
                }
                else
                {
                    system.debug(LstInvoiceItem[index].Transaction_ID__c +' had error '+results[index].getErrors());
                    
                }
            }
        } 
        catch(System.Exception e) 
        {
            isSuccess = False;
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