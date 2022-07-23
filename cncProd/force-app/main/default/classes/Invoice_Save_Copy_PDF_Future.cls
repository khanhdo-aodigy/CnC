//Queable class to save duplicate copy of Invoice PDF into SF.

public class Invoice_Save_Copy_PDF_Future implements Queueable, Database.AllowsCallouts{
    public String Invoice_Id_str;
    public String IV_Number;
    
    public Invoice_Save_Copy_PDF_Future(String Invoice_Id_Input,String IV_Number_Input){
        this.Invoice_Id_str=Invoice_Id_Input;
        this.IV_Number=IV_Number_Input;
    } 
    
    public void execute(QueueableContext context){
        
        //Saving Invoice in Files
        pagereference Pg2 = Page.Invoice_Save_Copy_PDF;    
        Pg2.getParameters().put('Invoice_Id',Invoice_Id_str); 
        FileHelper.generateFile(Invoice_Id_str,IV_Number,pg2);
        
        /* This block is commented-out for reference
        * until we have CI-CD in place.
        Blob pdf1 = pg2.getcontentAsPdf();
        Document d = new Document();
        d.FolderId = '00lp0000000K1YC';
        d.Body = Pdf1;
        d.Name = 'Duplicate_Invoice_'+IV_Number+'.pdf';
        d.ContentType = 'application/pdf';
        d.Type = 'pdf';
        d.IsPublic = true;
        insert d;*/     
        
    }
}