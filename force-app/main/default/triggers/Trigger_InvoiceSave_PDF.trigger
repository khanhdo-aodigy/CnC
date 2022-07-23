trigger Trigger_InvoiceSave_PDF on Invoice__c (after update) {
	
	//Exclude this trigger
    if(TriggerExclusion.isTriggerExclude('Payment')){
        return;
    }
	
String  Invoice_Id_str;
    
if (Trigger.isAfter)
{
   for(Integer i=0; i<trigger.new.size(); i++)
    {
        if(trigger.old[i].TC_Val__c == null && trigger.new[i].TC_Val__c != null && trigger.new[i].Payment_Type__c != 'Receipt'){ 
            
            try 
            {  
               
                Invoice_Id_str =  trigger.new[i].Id;
                List<Invoice__c> Invoice_Lst = [Select Invoice_Number__c from Invoice__c where Id=:Invoice_Id_str];
                String IV_Number = '';
                If(Invoice_Lst.size()>=0)
                {
                    IV_Number=Invoice_Lst[0].Invoice_Number__c;
                }
                ID jobID = System.enqueueJob(new Invoice_Save_Copy_PDF_Future(Invoice_Id_str,IV_Number));
            }
            catch(exception ex1)
            {
                system.debug(ex1.getMessage());
            }
        }
    }
}
}