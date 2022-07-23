/** *****
 * Description : API used to update Invoice informaton
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer               Details
 * 20180620             Jacob Khouli            Created initial version
 * 20200326             HS                      Added PA Migration changes
 * 20200424             HS                      Added InvokeManagerRequestWrapper to capture the request
 * 20200910			    TP                      Added logic for PA Phase 2
 * 20210408             TP                      Added logic for Generic Aftersales Promotions
 * 20212405             TP                      Added logic to populate Brand on Payment (Sitecore is passing Brand as null)
 ** *****/
@RestResource(urlMapping='/Invoice/v1/*')
global with sharing class InvoiceManager {
    
    @HttpPost
    global static void upsertInvoice(String InvoiceNumber,Decimal AmountWithGST,Decimal AmountWithoutGST, Decimal CommissionRateTransactionFee, 
                                     DateTime DateTimeOfPurchase, String Department, Decimal GST, String Mobile, Decimal NetAmount, String ContactId, String NRIC, 
                                     String ProductCategory, String ProductItem, Decimal ProductItemQuantity, String TransactionID, 
                                     String TransactionStatus, String VehicleRegistrationNumber, Decimal Discount, String CardType,
                                     String MaskedCCNo, String Brand, String CountryCode, String CampaignId, String Email, String FirstName, String LastName,
                                     String BillingStreet, String FloorUnit, String BuildingName,
                                     String BillingPostalCode, String BillingCountry, String PromoCode) 
    {

        InvokeManagerRequestWrapper reqWrap = new InvokeManagerRequestWrapper( InvoiceNumber, AmountWithGST, AmountWithoutGST, CommissionRateTransactionFee, 
                                                                                DateTimeOfPurchase, Department, GST, Mobile, NetAmount, ContactId, NRIC, 
                                                                                ProductCategory, ProductItem, ProductItemQuantity, TransactionID, 
                                                                                TransactionStatus, VehicleRegistrationNumber, Discount, CardType,
                                                                                MaskedCCNo, Brand, CountryCode, CampaignId, Email, FirstName, LastName,
                                                                                BillingStreet, FloorUnit, BuildingName,
                                                                                BillingPostalCode, BillingCountry, PromoCode);

        Boolean isError = false;
        Invoice__c invoice = new Invoice__c();
        List<Invoice__c> existingInvoice = new List<Invoice__c>();
        Map<String, String>  returnMapObject = new Map<String, String>();
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        try 
        {   
            //System.debug('@@@@DEBUG InvoiceManager :: reqWrap = ' + reqWrap);
            //System.debug('@@@@DEBUG InvoiceManager :: req.requestBody = ' + req.requestBody);
            if( req.requestBody == null )
            {
                req.requestBody = Blob.valueOf(JSON.serialize(reqWrap));
            }

            Long TimeStartObj = 0;
            if( InvoiceNumber!=null && InvoiceNumber.trim() != '' ) 
            {
                existingInvoice = [SELECT ID FROM Invoice__c WHERE Invoice_Number__c = :InvoiceNumber];
                if(existingInvoice.size() <= 0) 
                {
                    //throw error;
                    returnMapObject.put('ErrorCode', 'Err03-SF');
                    returnMapObject.put('ErrorMessage', 'Invalid Invoice Number: ' + InvoiceNumber);
                    res.statusCode = 400;
                    isError = true;                
                } 
                else 
                {
                    invoice.Id = existingInvoice[0].Id;
                }
            }
            
            Integer kiaSeqNum;
            Integer mitSeqNum;
            Integer citSeqNum;
            Integer mbSeqNum;
            Integer seqNum;
            List<Contact> contactLst = new List<Contact>();
            List<Campaign> campaignList = new List<Campaign>();
            Contact cont;
            Boolean isPublicCampaign = false;
            
            if(InvoiceNumber == null || InvoiceNumber.trim() == '') 
            {
                if(Department != null && Department.trim() != '') 
                {
                    if( String.isNotBlank(CampaignId) )
                    {
                        try
                        {
                            String invEvt = 'AfterSales';
                            //Update Sequence Number
                            invoice.SeqNum__c = Utility.getSequenceNoEvent( Department , CampaignId );
                            invoice.SequenceIdentifier__c = invEvt;
                        }
                        catch(Exception e)
                        {
                            loggerDataPool.buildLogDataPool('upsertInvoice', e);
                        }
                    }
                }

                if (String.isNotBlank(CampaignId))
                {
                    campaignList = [SELECT Target_Audience__c, Brand__c FROM Campaign WHERE ID =: CampaignId];
                    
                    if (campaignList.size() > 0 && campaignList[0].Target_Audience__c != 'Public and Targeted')
                    {
                        if(String.isNotBlank(NRIC) )
                        {
                            contactLst = [SELECT Id, AccountId FROM Contact WHERE id =: NRIC]; /** PA MIGRATION Phase 2 : Newly Added */      
                            invoice.NRIC__c = NRIC;
                        }    
                        else 
                        {
                            returnMapObject.put('ErrorCode', 'Err02-SF');
                            returnMapObject.put('ErrorMessage', 'Required fields not supplied. Fields: NRIC');
                            res.statusCode = 400;
                            isError = true;
                        }
                    }
                    else if (campaignList.size() > 0 && campaignList[0].Target_Audience__c == 'Public and Targeted')
                    {
                        isPublicCampaign = true;

                        if (String.isNotBlank(ContactId))
                        {
                            contactLst = [SELECT Id, AccountId FROM Contact WHERE Id =: ContactId];
                        }
                        else 
                        {

                            List<Registered_Vehicle__c> registeredVehs = new List<Registered_Vehicle__c>();
                            Boolean isEmailBlank = true;

                            if (String.isNotBlank(VehicleRegistrationNumber))
                            {
                                if (String.isNotBlank(Email))
                                {
                                    registeredVehs = [SELECT Id, Contact__c FROM Registered_Vehicle__c WHERE Registration_Number__c =: VehicleRegistrationNumber AND Contact__r.Email =: Email]; 
                                    isEmailBlank = false;
                                }

                                if (registeredVehs.size() <= 0)
                                {
                                    if (String.isNotBlank(Mobile))
                                    {
                                        if (!Mobile.startsWith('65')) { Mobile = '65' + Mobile; }
                                        
                                        registeredVehs = [SELECT Id, Contact__c FROM Registered_Vehicle__c WHERE Registration_Number__c =: VehicleRegistrationNumber AND Contact__r.MobilePhone =: Mobile]; 
                                        
                                        if (registeredVehs.size() <= 0 && isEmailBlank)
                                        {
                                            returnMapObject.put('ErrorCode', 'Err02-SF');
                                            returnMapObject.put('ErrorMessage', 'Required fields not supplied. Fields: Email');
                                            res.statusCode = 400;
                                            isError = true;
                                        }
                                    }
                                    else 
                                    {
                                        returnMapObject.put('ErrorCode', 'Err02-SF');
                                        returnMapObject.put('ErrorMessage', 'Required fields not supplied. Fields: Mobile');
                                        res.statusCode = 400;
                                        isError = true;
                                    }
                                }
                            }

                            if (!isError)
                            {
                                if (registeredVehs.size() > 0 && registeredVehs[0].Contact__c <> null)
                                {
                                    contactLst = [SELECT Id, AccountId FROM Contact WHERE Id =: registeredVehs[0].Contact__c];
                                }
                            }
                        }
                    }

                    if (!isError)
                    {
                        if (contactLst.size() > 0)
                        {
                            cont = contactLst[0];
                        }

                        if (contactLst.size() <= 0 && isPublicCampaign)
                        {
                            List<Account> existingPAs = [SELECT Id FROM Account WHERE PersonEmail =: Email AND IsPersonAccount = true];
                            
                            if (existingPAs.size() > 0)
                            {
                                cont = [SELECT Id, AccountId FROM Contact WHERE AccountId =: existingPAs[0].Id];  
                            }
                            else 
                            {
                                Account newProspect = new Account (FirstName = FirstName, 
                                                                   LastName = LastName, 
                                                                   PersonMobilePhone = Mobile,
                                                                   PersonEmail = Email);
                                
                                AccountUtil.createProspect(newProspect);
                                
                                cont = [SELECT Id, AccountId FROM Contact WHERE AccountId =: newProspect.Id];                                                  
                            }
                        }
                    }              
                }
                else 
                {
                    returnMapObject.put('ErrorCode', 'Err02-SF');
                    returnMapObject.put('ErrorMessage', 'Required fields not supplied. Fields: CampaignId');
                    res.statusCode = 400;
                    isError = true;
                }
            }        
            
            if(!isError) 
            {
                if(AmountWithGST != null) 
                {
                    invoice.Amount_With_GST__c = AmountWithGST;
                }
                
                if(DateTimeOfPurchase!=null) 
                {
                    invoice.Date_Time_of_Purchase__c = DateTimeOfPurchase;
                }

                if(Department!=null) 
                {
                    invoice.Department__c = Department;
                }

                if(Mobile!=null) 
                {
                    invoice.Mobile__c = Mobile;
                }

                if(NetAmount!=null) 
                {
                    invoice.Net_Amount__c = NetAmount;
                }

                if(TransactionStatus!=null) 
                {
                    invoice.Transaction_Status__c = TransactionStatus;
                }  

                if(VehicleRegistrationNumber!=null) 
                {
                    invoice.Vehicle_Registration_Number__c = VehicleRegistrationNumber;
                }  

                if(MaskedCCNo!=null) 
                {
                    invoice.MaskedCCNo__c = MaskedCCNo;
                }

                if(TransactionID!=null) 
                {
                    invoice.Transaction_ID__c = TransactionID;
                }

                if(ProductItemQuantity!=null) 
                {
                    invoice.Product_Item_Quantity__c = ProductItemQuantity;
                }

                if(ProductItem!=null) 
                {
                    invoice.Product_Item__c = ProductItem;
                }

                if(ProductCategory!=null) 
                {
                    invoice.Product_Category__c = ProductCategory;
                } 

                if(CardType!=null) 
                {
                    invoice.CardType__c = CardType;
                } 

                if(Discount!=null) 
                {
                    invoice.Discount__c = Discount;
                } 

                /*if(Brand!=null) 
                {
                    invoice.Brand__c = Brand;
                }*/

                if (campaignList.size() > 0) 
                {
                    invoice.Brand__c = campaignList[0].Brand__c;
                }

                if(CampaignId!=null) 
                {
                    invoice.Campaign_ID__c = CampaignId;
                }

                if(CountryCode!=null) 
                {
                    invoice.CountryCode__c = CountryCode;
                } 
                else 
                {
                    invoice.CountryCode__c = 'SG';
                }

                if  (String.isNotBlank(PromoCode) && String.isNotBlank(CampaignId))
                {
                    Promo_Code_Master__c promo = PromoCodeMasterService.getPromoByNameAndCampaignId(PromoCode, CampaignId);
                    if (promo <> null) { invoice.Promo_Code_Master__c = promo.Id;  }   
                }
                
                if (FirstName <> null) { invoice.First_Name__c = FirstName; }
                if (LastName <> null)  { invoice.Last_Name__c = LastName; }
                if (Email <> null)     { invoice.Customer_Email__c = Email; }
                if (BillingStreet <> null) { invoice.Billing_Street__c = BillingStreet; }
                if (FloorUnit <> null) { invoice.Floor_Unit__c = FloorUnit; }
                if (BuildingName <> null) { invoice.Building_Name__c = BuildingName; }
                if (BillingPostalCode <> null) { invoice.Billing_Postal_Code__c = BillingPostalCode; }
                if (BillingCountry <> null) { invoice.Billing_Country__c = BillingCountry; }
            }

            if(!isError) 
            {
                if (cont <> null)
                {
                    invoice.Account__c = cont.AccountId;
                    invoice.Contact__c = cont.Id;
                    invoice.NRIC__c    = cont.Id;
                }              

                upsert invoice;
                invoice = [SELECT Invoice_Number__c, Department__c, Campaign__r.id, Campaign__r.Type, CreatedDate FROM Invoice__c WHERE Id = :invoice.Id];
                returnMapObject.put('InvoiceNumber', invoice.Invoice_Number__c);
                returnMapObject.put('createdDate', String.valueof(invoice.CreatedDate));

                if(TransactionStatus ==	'processor_declined')
                {
                    String invEvt = invoice.Campaign__r.Type == 'Sales Targeted Promo' ? 'Sales Targeted Promo' : 'AfterSales';
                    invoice.SeqNum__c = getMinusSequenceNoEvent( invoice.Department__c , invoice.Campaign__r.id);
                    invoice.SequenceIdentifier__c = invEvt;
                    update invoice;
                }
            }
        }
        catch(Exception e) 
        {
            returnMapObject.put('ErrorCode', 'Err04-SF');
            returnMapObject.put('Message', 'A system exception has occurred, Please contact your administrator.');
            res.statusCode = 400;
            loggerDataPool.buildLogDataPool('upsertInvoice', e);
        }
        
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(returnMapObject));
        //res.statusCode = 200;
        serviceDataPool.buildServiceDataPool('upsertInvoice', 'InvoiceManager','', req, res);
        
    }


    private void compileRequestBody( String InvoiceNumber, Decimal AmountWithGST, Decimal AmountWithoutGST, Decimal CommissionRateTransactionFee, 
                                    DateTime DateTimeOfPurchase, String Department, Decimal GST, String Mobile, Decimal NetAmount, String NRIC, 
                                    String ProductCategory, String ProductItem, Decimal ProductItemQuantity, String TransactionID, 
                                    String TransactionStatus, String VehicleRegistrationNumber, Decimal Discount, String CardType,
                                    String MaskedCCNo, String Brand, String CountryCode, String CampaignId, String Email, String FirstName, String LastName,
                                    String BillingStreet, String FloorUnit, String BuildingName, String BillingPostalCode, String BillingCountry, String PromoCode){
        
        
    }

    public class InvokeManagerRequestWrapper{
        public String InvoiceNumber;
        public Decimal AmountWithGST;
        public Decimal AmountWithoutGST;
        public Decimal CommissionRateTransactionFee;
        public DateTime DateTimeOfPurchase;
        public String Department;
        public Decimal GST;
        public String Mobile;
        public Decimal NetAmount;
        public String ContactId;
        public String NRIC;
        public String ProductCategory;
        public String ProductItem;
        public Decimal ProductItemQuantity;
        public String TransactionID;
        public String TransactionStatus;
        public String VehicleRegistrationNumber;
        public Decimal Discount;
        public String CardType;
        public String MaskedCCNo;
        public String Brand;
        public String CountryCode;
        public String CampaignId;
        public String Email;
        public String FirstName;
        public String LastName;
        public String BillingStreet;
        public String FloorUnit;
        public String BuildingName;
        public String BillingPostalCode;
        public String BillingCountry;
        public String PromoCode;

        public InvokeManagerRequestWrapper( String InvoiceNumber, Decimal AmountWithGST, Decimal AmountWithoutGST, Decimal CommissionRateTransactionFee, 
                                            DateTime DateTimeOfPurchase, String Department, Decimal GST, String Mobile, Decimal NetAmount, String ContactId, String NRIC, 
                                            String ProductCategory, String ProductItem, Decimal ProductItemQuantity, String TransactionID, 
                                            String TransactionStatus, String VehicleRegistrationNumber, Decimal Discount, String CardType,
                                            String MaskedCCNo, String Brand, String CountryCode, String CampaignId, String Email, String FirstName, String LastName,
                                            String BillingStreet, String FloorUnit, String BuildingName,
                                            String BillingPostalCode, String BillingCountry, String PromoCode){
            
            //System.debug('testing InvoiceNumber = ' + InvoiceNumber);
            this.InvoiceNumber       = InvoiceNumber;
            this.AmountWithGST       = AmountWithGST;
            this.AmountWithoutGST    = AmountWithoutGST;
            this.CommissionRateTransactionFee = CommissionRateTransactionFee;
            this.DateTimeOfPurchase  = DateTimeOfPurchase;
            this.Department          = Department;
            this.GST                 = GST;
            this.Mobile              = Mobile;
            this.NetAmount           = NetAmount;
            this.ContactId           = ContactId;
            this.NRIC                = NRIC;
            this.ProductCategory     = ProductCategory;
            this.ProductItem         = ProductItem;
            this.ProductItemQuantity = ProductItemQuantity;
            this.TransactionID       = TransactionID;
            this.TransactionStatus   = TransactionStatus;
            this.VehicleRegistrationNumber = VehicleRegistrationNumber;
            this.Discount            = Discount;
            this.CardType            = CardType;
            this.MaskedCCNo          = MaskedCCNo;
            this.Brand               = Brand;
            this.CountryCode         = CountryCode;
            this.CampaignId          = CampaignId;
            this.Email               = Email;
            this.FirstName           = FirstName;
            this.LastName            = LastName;
            this.BillingStreet       = BillingStreet;
            this.FloorUnit           = FloorUnit;
            this.BuildingName        = BuildingName;
            this.BillingCountry      = BillingCountry;
            this.BillingPostalCode   = BillingPostalCode;
            this.PromoCode           = PromoCode;
        }
    }


	//NSJ --> repeat method of Utility.getSequenceNoEvent
    public static Integer getMinusSequenceNoEvent(String branch, String campId)
    {
        InvoiceSeqNum__c runNum = [SELECT Id, MITSeqNum__c, KIASeqNum__c, CitroenSeqNum__c, MBSeqNum__c,
                                   MerchandiseSeqNum__c, OneTimePurchaseSeqNum__c, ServicePackageSeqNum__c
                                   FROM InvoiceSeqNum__c
                                   WHERE Campaign__c=:campId
                                   ORDER BY CreatedDate
                                   LIMIT 1];
        Integer sequenceNo = 0;
        if(branch == 'CCK')
        {
            sequenceNo = (Integer)runNum.KIASeqNum__c - 1;
            runNum.KIASeqNum__c = sequenceNo;
        }
        else if(branch == 'CCA')
        {
            sequenceNo = (Integer)runNum.MITSeqNum__c - 1;
            runNum.MITSeqNum__c = sequenceNo;
        }
        else if(branch == 'CCF')
        {
            sequenceNo = (Integer)runNum.CitroenSeqNum__c - 1;
            runNum.CitroenSeqNum__c = sequenceNo;
        }
        else if(branch == 'CCI')
        {
            Campaign campaign = [Select Promotion_Type__c, Type From Campaign Where Id = :campId];
            System.debug('@@@@DEBUG getSequenceNoEvent :: campaign = ' + campaign );
            if(campaign.Type == 'Promotions') 
            {
                switch on campaign.Promotion_Type__c 
                {
                    when 'One Time Purchase' 
                    {
                        sequenceNo = (Integer)runNum.OneTimePurchaseSeqNum__c - 1;
                        runNum.OneTimePurchaseSeqNum__c = sequenceNo;
                    }
                    when 'Service Package' 
                    {
                        sequenceNo = (Integer)runNum.ServicePackageSeqNum__c - 1;
                        runNum.ServicePackageSeqNum__c = sequenceNo;
                    }
                    when 'Merchandise' 
                    {
                        sequenceNo = (Integer)runNum.MerchandiseSeqNum__c - 1;
                        runNum.MerchandiseSeqNum__c = sequenceNo;
                    }
                }
            } 
            else 
            {
                sequenceNo = (Integer)runNum.MBSeqNum__c - 1;
                runNum.MBSeqNum__c = sequenceNo;
            }
        }
        update runNum;

        return sequenceNo;
    }
}