//Invocable class to update T&C from CSM used in Process builder to send Invoice PDF.
public class InvoiceEmail_ProcessbuilderTC 
{

	@InvocableMethod
	public static void InsertRecords(List<Id> Invoice_Id) 
	{
		String TC_Val = '';
		List<Invoice__c> cmv = [Select Id, Campaign_ID__c, Campaign__r.TC_Val__c from Invoice__c where Id in :Invoice_Id];
    
		for(Invoice__c TempInvoice : cmv)
		{  
			String promoid = TempInvoice.Campaign_ID__c;
			TC_Val = TempInvoice.Campaign__r.TC_Val__c;
			//InvoiceEmail_ProcessBuilder_RestTC.apexcallout(promoid,TempInvoice.Id);       
			updateTnC_Invoice(TC_Val, TempInvoice.Id);
		}      
    
	}

	@future(Callout=true)
	public static void updateTnC_Invoice(string TC_Val, Id Invoice_Id)
	{
        //Update T&C into SF Invoice object.
        Invoice__c TempInvoice  = new Invoice__c();
        TempInvoice.Id = Invoice_Id;
        TempInvoice.TC_Val__c = TC_Val;

        Update TempInvoice;
	}

}