/** *******
 * Description : Controller class of VF page to save duplcate copy of Invoice PDF into SF.
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * YYYYMMDD             aodigy                      Created Initial version
 * 20200831             khanh.do@aodigy.com         Added PA Migration - Phase 2 Changes
 * 20210409             tphung@aodigy.com           Modified Billing Address
 * 
 ******* **/
public class Invoice_Save_Copy_PDF_C 
{   
    String Invoice_Id;    
    public String Input_Id {get;set;}
    public String Department {get;set;}
    public String Brand {get;set;}
    public String Contact_Name {get;set;}
    public String Contact_Address_Line_1 {get;set;}
    public String Contact_Address_Line_2 {get;set;}
    public String Contact_Address_Line_3 {get;set;}
    public String Contact_Country {get;set;}
    public String Invoice_Number {get;set;}
    public String Date_Time_of_Purchase {get;set;}
    public String Product_Item {get;set;}
    public String Vehicle_Registration_Number {get;set;}
    public String Amout_Before_Dicount {get;set;}
    public String Discount {get;set;}
    public String Amount_With_GST {get;set;}
    public String CardType {get;set;}
    public String MaskedCCNo {get;set;}
    public String Net_Amount {get;set;}
    public String Amount_Without_GST {get;set;}
    public String GST {get;set;}
    public String TC_Val {get;set;}    
    public String First_Name {get;set;}
    public String Last_Name {get;set;}
    public String RecordType {get;set;}
    public String Sales_Agreement_Name {get;set;}
    public Decimal Total_Items_Quantity {get;set;}
    public String Campaign_Name {get;set;}
    public String Postal_Code_Name {get;set;}
    public List<Invoice_Promo_Line_Item__c> invoiceItems {get;set;}
   
    //Constructor to set values from SF Invoice object to VF page Controller variables.    
    public Invoice_Save_Copy_PDF_C()
    {
        Input_Id=ApexPages.currentPage().getParameters().get('Invoice_Id');
        System.debug('@@@@DEBUG Invoice_Save_Copy_PDF_C :: Input_Id = ' + Input_Id );
          
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        
        if( String.isNotBlank( Input_Id ) )
        {
            lstInvoice = [SELECT RecordType.DeveloperName FROM Invoice__c WHERE Id =: Input_Id];

            if( lstInvoice <> null && !lstInvoice.isEmpty() )
            {
                if (lstInvoice[0].RecordType.DeveloperName != 'Sales_Targeted_Promo_Payment_RT')
                {
                    lstInvoice = [SELECT Brand__c, Department__c, Contact__r.Name, Contact__r.Address_Line_1__c, Contact__r.Address_Line_2__c, Contact__r.Address_Line_3__c, Contact__r.Country__c, 
                                        Invoice_Number__c, Date_Time_of_Purchase__c, Product_Item__c, Vehicle_Registration_Number__c, Amout_Before_Dicount__c, Discount__c, 
                                        Amount_With_GST__c, CardType__c, MaskedCCNo__c, Net_Amount__c, Amount_wo_GST__c, GST_Value__c, TC_Val__c,
                                        Account__c, Account__r.Name, Account__r.IsPersonAccount, Account__r.RecordTypeId, Account__r.RecordType.DeveloperName,   
                                        Account__r.Address_Line_1__pc, Account__r.Address_Line_2__pc, Account__r.Address_Line_3__pc, Account__r.Country__pc,
                                        Billing_Street__c,Billing_Country__c,Billing_Postal_Code__c,Floor_Unit__c, Building_Name__c, Campaign__r.Name,
                                        Promo_Code_Master__r.Amount__c, Campaign__r.Target_Audience__c  ,First_Name__c,Last_Name__c, RecordType.DeveloperName, Sales_Agreement_Name__c, Total_Items_Quantity__c,
                                        Contact__r.Postal_Code__r.Name    
                                FROM Invoice__c 
                                WHERE Id =:Input_Id];

                    Product_Item = lstInvoice[0].Product_Item__c;
                }
                else 
                {
                    lstInvoice = [SELECT Brand__c, Department__c, Contact__r.Name, Contact__r.Address_Line_1__c, Contact__r.Address_Line_2__c, Contact__r.Address_Line_3__c, Contact__r.Country__c, 
                                        Invoice_Number__c, Date_Time_of_Purchase__c, Product_Item__c, Vehicle_Registration_Number__c, Amout_Before_Dicount__c, Discount__c, 
                                        Amount_With_GST__c, CardType__c, MaskedCCNo__c, Net_Amount__c, Amount_wo_GST__c, GST_Value__c, TC_Val__c,
                                        Account__c, Account__r.Name, Account__r.IsPersonAccount, Account__r.RecordTypeId, Account__r.RecordType.DeveloperName,   
                                        Account__r.Address_Line_1__pc, Account__r.Address_Line_2__pc, Account__r.Address_Line_3__pc, Account__r.Country__pc,
                                        Billing_Street__c,Billing_Country__c,Billing_Postal_Code__c,Floor_Unit__c, Building_Name__c, Campaign__r.Name,
                                        Promo_Code_Master__r.Amount__c, Campaign__r.Target_Audience__c, First_Name__c,Last_Name__c, RecordType.DeveloperName, Total_Items_Quantity__c, Sales_Agreement_Name__c,
                                        Contact__r.Postal_Code__r.Name,
                                        (SELECT Id, Promo_Line_Item__c, Usual_Price__c, Promo_Price__c, Variant_Display_Name__c , Quantity__c, Item_Display_Name__c, Discount__c FROM Invoice_Promo_Line_Items__r)    
                                FROM Invoice__c 
                                WHERE Id =:Input_Id];

                    invoiceItems = lstInvoice.get(0).Invoice_Promo_Line_Items__r;
                }
                
                System.debug('@@@@DEBUG Invoice_Save_Copy_PDF_C :: lstInvoice = ' + lstInvoice );
                    
                Contact_Name           = lstInvoice[0].Contact__r.Name;
                First_Name             = lstInvoice[0].First_Name__c;
                Last_Name              = lstInvoice[0].Last_Name__c;

                // Get Payment Address, else get Contact Address
                if (!String.isBlank(lstInvoice[0].Billing_Street__c) /*  
                !String.isBlank(lstInvoice[0].Billing_Postal_Code__c) || !String.isBlank(lstInvoice[0].Billing_Country__c) */) 
                {
                    Contact_Address_Line_1 = lstInvoice[0].Billing_Street__c <> null ? lstInvoice[0].Billing_Street__c  :'' ;
                    Contact_Address_Line_2 = lstInvoice[0].Floor_Unit__c <> null ? lstInvoice[0].Floor_Unit__c + ', ' : '' ;
                    Contact_Address_Line_3 = lstInvoice[0].Building_Name__c  <> null ? lstInvoice[0].Building_Name__c  : '';   
                    Contact_Country        = lstInvoice[0].Billing_Country__c + ' ' + lstInvoice[0].Billing_Postal_Code__c <> null ? lstInvoice[0].Billing_Country__c + ' ' + lstInvoice[0].Billing_Postal_Code__c:  '';               
                }
                else if (!String.isBlank(lstInvoice[0].Contact__r.Address_Line_1__c) /*|| !String.isBlank(lstInvoice[0].Contact__r.Address_Line_2__c)  || 
                !String.isBlank(lstInvoice[0].Contact__r.Address_Line_3__c) ||!String.isBlank(lstInvoice[0].Contact__r.Country__c) */) 
                {
                    Contact_Address_Line_1 = lstInvoice[0].Contact__r.Address_Line_1__c <> null ? lstInvoice[0].Contact__r.Address_Line_1__c + ', ' : '' ;
                    Contact_Address_Line_2 = lstInvoice[0].Contact__r.Address_Line_2__c <> null ? lstInvoice[0].Contact__r.Address_Line_2__c + ', ' : '' ;
                    Contact_Address_Line_3 = lstInvoice[0].Contact__r.Address_Line_3__c <> null ? lstInvoice[0].Contact__r.Address_Line_3__c : '';                  
                    Contact_Country        = lstInvoice[0].Contact__r.Country__c <> null ? lstInvoice[0].Contact__r.Country__c : '';
                    Postal_Code_Name       = lstInvoice[0].Contact__r.Postal_Code__r.Name <> null ? lstInvoice[0].Contact__r.Postal_Code__r.Name : '';
                } 
                else
                {
                    Contact_Address_Line_1 = '';
                    Contact_Address_Line_2 = '';
                    Contact_Address_Line_3 = '';                  
                    Contact_Country        = '';
                    Postal_Code_Name       = '';
                }

                Brand                       = lstInvoice[0].Brand__c; 
                Department                  = lstInvoice[0].Department__c;
                Invoice_Number              = lstInvoice[0].Invoice_Number__c;
                Date_Time_of_Purchase       = String.valueOf(lstInvoice[0].Date_Time_of_Purchase__c.date());
                Vehicle_Registration_Number = lstInvoice[0].Vehicle_Registration_Number__c;                   
                Amout_Before_Dicount        = String.valueOf(lstInvoice[0].Amout_Before_Dicount__c);
                Discount                    = lstInvoice[0].Discount__c <> null ? String.valueOf(lstInvoice[0].Discount__c) : '0.00';  
                Amount_With_GST             = String.valueOf(lstInvoice[0].Amount_With_GST__c);
                CardType                    = lstInvoice[0].CardType__c;
                MaskedCCNo                  = lstInvoice[0].MaskedCCNo__c;
                Net_Amount                  = String.valueOf(lstInvoice[0].Net_Amount__c);
                Amount_Without_GST          = lstInvoice[0].Amount_wo_GST__c <> null ? String.valueOf(lstInvoice[0].Amount_wo_GST__c.setScale(2)) : '';                   
                GST                         = lstInvoice[0].GST_Value__c <> null ? String.valueOf(lstInvoice[0].GST_Value__c.setScale(2)) : '';
                TC_Val                      = lstInvoice[0].TC_Val__c;
                RecordType                  = lstInvoice[0].RecordType.DeveloperName;
                Sales_Agreement_Name        = lstInvoice[0].Sales_Agreement_Name__c;
                Total_Items_Quantity        = lstInvoice[0].Total_Items_Quantity__c;
                Campaign_Name               = lstInvoice[0].Campaign__r.Name;             
            }     
        }    
    }   
}