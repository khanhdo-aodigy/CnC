//Schedulable class to import Data from BrainTree to Invoice object.
global class BrainTree_Scheduler implements Schedulable
{
    global void execute (SchedulableContext ctx)
    {   
        BrainTree_GetInvoiceItem_PurchaseData.getInvoiceData(); 
        BrainTree_GetInvoiceItem_CreditData.getInvoiceData(); 
        BrainTree_GetInvoiceItem_CancelData.getInvoiceData(); 
    }  
}