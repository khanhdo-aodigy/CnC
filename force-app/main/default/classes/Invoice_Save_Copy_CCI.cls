public class Invoice_Save_Copy_CCI implements Queueable, Database.AllowsCallouts{
    public String Invoice_Id_str;
    public String IV_Number;
    
    public Invoice_Save_Copy_CCI(String Invoice_Id_Input,String IV_Number_Input){
        this.Invoice_Id_str=Invoice_Id_Input;
        this.IV_Number=IV_Number_Input;
    } 
    
    public void execute(QueueableContext context){
        //Saving Invoice in Files
        pagereference Pg2 = Page.Invoice_CCI;    
        Pg2.getParameters().put('Invoice_Id',Invoice_Id_str); 
        FileHelper.generateFile(Invoice_Id_str,IV_Number,pg2);
    }
}