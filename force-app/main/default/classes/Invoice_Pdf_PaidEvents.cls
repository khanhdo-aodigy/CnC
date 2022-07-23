/** *******
 * Description : Controller class of VF page to generate Invoice PDF for Paid Events
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * 20190519             Savita Shetteppa            Created Initial version
 * 20200325             huynh.hung@aodigy           Added PA Migration Changes
 * 
 ******* **/
public class Invoice_Pdf_PaidEvents{

    public String Department {get;set;}
    public String Contact_Name {get;set;}
    public String Contact_Address_Line_1 {get;set;}
    public String Contact_Address_Line_2 {get;set;}
    public String Contact_Address_Line_3 {get;set;}
    public String Contact_Country {get;set;}
    public String Invoice_Number {get;set;}
    public String Date_Time_of_Purchase {get;set;}
    public String Product_Item {get;set;}
    public String Amout_Before_Dicount {get;set;}
    public String Discount {get;set;}
    public String Amount_With_GST {get;set;}
    public String CardType {get;set;}
    public String MaskedCCNo {get;set;}
    public String Net_Amount {get;set;}
    public String Amount_Without_GST {get;set;}
    public String GST {get;set;}
    public String TC_Val {get;set;} 
    public Decimal numberOfGuests {get;set;}  
    
    String evtRegId;   

    public List<Event_Registration__c> lstEventReg = new List<Event_Registration__c>();
    Map<Id,Invoice__c> evRegisToInvoiceMap = new Map<Id,Invoice__c>();
    
    public Invoice_Pdf_PaidEvents()
    {
        try{
            evtRegId = ApexPages.currentPage().getParameters().get('EventRegistrationId');
            if(evtRegId!=null)
            {
                lstEventReg = [SELECT Id,
                                    PromoID__r.name,
                                    PromoID__r.UnitPrice__c,
                                    NumberOfGuests__c,
                                    // ContactId__c,
                                    // ContactId__r.Name,
                                    // ContactId__r.Address_Line_1__c,
                                    // ContactId__r.Address_Line_2__c,
                                    // ContactId__r.Address_Line_3__c,
                                    // ContactId__r.Country__c,
                                    payment__c,
                                    // LeadId__r.name,
                                    // LeadId__c,
                                    // LeadId__r.Address_Line_1__c,
                                    // LeadId__r.Address_Line_2__c,
                                    // LeadId__r.Address_Line_3__c,
                                    // LeadId__r.Country,
                                    Account__c,                         
                                    Account__r.Name,                    
                                    Account__r.Address_Line_1__pc,      
                                    Account__r.Address_Line_2__pc,      
                                    Account__r.Address_Line_3__pc,      
                                    Account__r.Country__pc,             
                                    Account__r.IsPersonAccount          
                                FROM Event_Registration__c 
                                WHERE Id = :evtRegId 
                                AND Payment__c != null];
                                
                if( !lstEventReg.isEmpty() && lstEventReg[0].payment__c != null ){                    
                    for(Invoice__c inv : [SELECT Id, Department__c, Invoice_Number__c, Date_Time_of_Purchase__c, CardType__c, MaskedCCNo__c, TC_Val__c
                                          FROM Invoice__c 
                                          WHERE Id = :lstEventReg[0].Payment__c] ) {
                        evRegisToInvoiceMap.put( inv.Id, inv );
                    }

                    if( !evRegisToInvoiceMap.isEmpty() )
                    {
                        for(Event_Registration__c er : lstEventReg){  
                            
                            if(er.Account__c != null && er.Account__r.IsPersonAccount){
                                Contact_Name = er.Account__r.Name.touppercase();
                                Contact_Address_Line_1 = String.IsBlank(er.Account__r.Address_Line_1__pc) ? '' : er.Account__r.Address_Line_1__pc.touppercase()+',';
                                Contact_Address_Line_2 = String.IsBlank(er.Account__r.Address_Line_2__pc) ? '' : er.Account__r.Address_Line_2__pc.touppercase()+',';
                                if(String.isNotBlank(er.Account__r.Address_Line_3__pc)){
                                    Contact_Address_Line_3 = er.Account__r.Address_Line_3__pc.toUppercase();
                                }                  
                                if(String.isNotBlank(Contact_Address_Line_1) || String.isNotBlank(Contact_Address_Line_2) || String.isNotBlank(Contact_Address_Line_3)){
                                    if(String.isNotBlank(er.Account__r.Country__pc)){
                                        Contact_Country = er.Account__r.Country__pc.toUppercase();}
                                    else{
                                        Contact_Country = 'SINGAPORE';
                                    }                       
                               }
                            }
                            /** PA Migration : To Remove */
                            // else if(er.ContactId__c!=null){
                            //     Contact_Name = er.ContactId__r.Name.touppercase();
                            //     Contact_Address_Line_1 = String.IsBlank(er.ContactId__r.Address_Line_1__c) ? '' :er.ContactId__r.Address_Line_1__c.touppercase()+',';
                            //     Contact_Address_Line_2 = String.IsBlank(er.ContactId__r.Address_Line_2__c) ? '' :er.ContactId__r.Address_Line_2__c.touppercase()+',';
                            //     if(String.isNotBlank(er.ContactId__r.Address_Line_3__c)){
                            //         Contact_Address_Line_3 = er.ContactId__r.Address_Line_3__c.toUppercase();
                            //     }                  
                            //     if(String.isNotBlank(Contact_Address_Line_1) || String.isNotBlank(Contact_Address_Line_2) || String.isNotBlank(Contact_Address_Line_3)){
                            //         if(String.isNotBlank(er.ContactId__r.Country__c)){
                            //             Contact_Country = er.ContactId__r.Country__c.toUppercase();}
                            //         else{
                            //             Contact_Country = 'SINGAPORE';
                            //         }                       
                            //    }
                            // }
                            // else if(er.LeadId__c!=null){
                            //     Contact_Name = er.LeadId__r.name.touppercase();
                            //     Contact_Address_Line_1 = String.IsBlank(er.LeadId__r.Address_Line_1__c) ? '' : er.LeadId__r.Address_Line_1__c.toUppercase()+',' ;
                            //     Contact_Address_Line_2 = String.IsBlank(er.LeadId__r.Address_Line_2__c) ? '' : er.LeadId__r.Address_Line_2__c.toUppercase()+',';
                            //     if(String.isNotBlank(er.LeadId__r.Address_Line_3__c)){
                            //         Contact_Address_Line_3 = er.LeadId__r.Address_Line_3__c.toUppercase(); 
                            //     } 
                            //     if(String.isNotBlank(Contact_Address_Line_1) || String.isNotBlank(Contact_Address_Line_2) || String.isNotBlank(Contact_Address_Line_3)){
                            //         if(String.IsNotBlank(er.LeadId__r.Country)){             
                            //             Contact_Country = er.LeadId__r.Country.toUppercase();}
                            //         else {
                            //             Contact_Country = 'SINGAPORE';
                            //         }    
                            //    }
                            // }

                            numberOfGuests       = Integer.valueOf(er.NumberOfGuests__c);                         
                            Product_Item         = er.PromoID__r.name;
                            Amout_Before_Dicount = String.valueOf(er.PromoID__r.UnitPrice__c);
                            Discount             = '0';
                            Decimal netamt       = er.PromoID__r.UnitPrice__c * er.NumberOfGuests__c; 
                            Net_Amount           = '$'+String.valueOf(netamt);
                            Decimal gstAmout     = (netamt * (0.07/1.07)).setScale(2);                        
                            Decimal withoutGST   = (netamt - gstAmout).setScale(2) ;
                            Amount_Without_GST   = '$'+String.valueOf(withoutGST);                   
                            GST                  = '$'+String.valueOf(gstAmout ) ;                                                                                
                            
                            if( evRegisToInvoiceMap.ContainsKey( er.Payment__c ) )
                            {
                                Department  = evRegisToInvoiceMap.get(er.Payment__c).Department__c;                          
                                CardType    = evRegisToInvoiceMap.get(er.Payment__c).CardType__c;
                                MaskedCCNo  = evRegisToInvoiceMap.get(er.Payment__c).MaskedCCNo__c;          
                                //Date_Time_of_Purchase = String.valueOf(evRegisToInvoiceMap.get(er.Payment__c).Date_Time_of_Purchase__c.date());
                                Datetime yourDate     = evRegisToInvoiceMap.get(er.Payment__c).Date_Time_of_Purchase__c;
                                String dateOutput     = yourDate.format('dd-MM-yyyy');
                                Date_Time_of_Purchase = ' '+dateOutput;
                                Invoice_Number        = evRegisToInvoiceMap.get(er.Payment__c).Invoice_Number__c;
                                TC_Val                = evRegisToInvoiceMap.get(er.Payment__c).TC_Val__c;  
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Exceptions Catched --- '+e);
        } 
    }
       
}