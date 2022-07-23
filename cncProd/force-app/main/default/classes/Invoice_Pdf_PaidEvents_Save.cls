//Queable class to upload invoice PDF to files
public class Invoice_Pdf_PaidEvents_Save implements Queueable, Database.AllowsCallouts{
    List<Event_Registration__c> paidEvents;
    Map<String, String> campIdList;

    public Invoice_Pdf_PaidEvents_Save (List<Event_Registration__c> paidEventList, Map<String, String> campIdWithER){
        this.paidEvents = paidEventList;
        this.campIdList = campIdWithER ;
    }    
    public void execute(QueueableContext context){
        try {  
    //calling VF Page to generate PDF here.
        
            Map<String,String> erWithPublicURL = new Map<String, String>();
            Map<String, Campaign> camps =  new Map<String, Campaign>([Select Id,Name,Description,UnitPrice__c,Type, Branch_Code__c from Campaign where Id IN :campIdList.values()]);
            if(!camps.isEmpty()) {
                Map<Id,String> eventIdToInvoiceNum = new Map<Id,String>(); 
                for(Event_Registration__c er : paidEvents){
                    if(camps.get(er.PromoID__c).Type=='Paid Event'){
                        eventIdToInvoiceNum.put(er.payment__c,er.id);
                    }
                }
                List<ContentVersion> conVerList = new List<ContentVersion>();
                Map<String,String> cvWithER = new Map<String,String>();
                for(Invoice__c inv : [Select Id,Invoice_Number__c from Invoice__c where Id=:eventIdToInvoiceNum.KeySet()]){
                    if(eventIdToInvoiceNum.ContainsKey(inv.id) && eventIdToInvoiceNum.get(inv.id) != null && inv.Invoice_Number__c != null){
                        String EventRegisId = eventIdToInvoiceNum.get(inv.id);
                        String invoiceNumber = inv.Invoice_Number__c ;
                        pagereference Pg = Page.Invoice_Pdf_PaidEvents;
                        Pg.getParameters().put('EventRegistrationId',eventIdToInvoiceNum.get(inv.id)); 
                        
                        //Using utility class to generate file
                        erWithPublicURL = FileHelper.generateFile(EventRegisId,invoiceNumber,pg);                
                    }  
            
                    EventRegistration_ConfirmationEmail.sendEmail(campIdList,erWithPublicURL,false);               
                }  
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('Invoice_Pdf_PaidEvents_Save',e); 
        }
    }
}