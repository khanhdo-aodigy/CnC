/** *****
 * Class Name: Trigger_CustomQuote_ConfirmationEmail
 * Description : Trigger on Custom Quote object
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * YYYYMMDD            C&C                           Created Initial Version.
 * 20200921            Khanh Do                      Added PA Migration Changes
 * 20210706            Khanh Do                      Added bypass trigger via custom setting
 * 
** *****/ 
trigger Trigger_CustomQuote_ConfirmationEmail on Custom_Quote__c (after insert) {
    
    //Exclude this trigger
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Custom_Quote__c')
        || TriggerExclusion.isBypassTriggerExecution('Custom_Quote__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    String personName;
    String personEmail;
    String SubscriberKey;
    String VariantName;
    Decimal BasePrice;
    Decimal CustomizedPrice;
	
	String Trim;
	String Color;
	String TradeinModel;
	String TradeinBrand;
	String Tradeinregnumber;
	String TradeinMileage;
	String Lastfournric;
	String BankName;
	String LoanInterest;
	String LoanAmount;
	String LoanTerm;
	String MonthlyInstallment;
    
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String triggeredSendMessageId = (String)JCC_GlobalVar.CustomQuoteTriggeredId__c;
    String BranchCode;
    String ModelName;
    String SalesConsultant;
    String SalesConsultantMobileNumber;
    String MobilePhone;
    String Name;
    String relatedQuoteID;
    User[] SalesConsultantList = new List<User>();
      
    List <Custom_Quote__c> customQuoteList = new list <Custom_Quote__c>();
    List<Related_Custom_Quotes_List__c> relatedCustomQuotes =new List<Related_Custom_Quotes_List__c>();
    
    if (Trigger.isAfter)  {
        
       
        for(Custom_Quote__c customQuote : trigger.new)
        {
            try{

                customQuoteList = [SELECT Id, Opportunity__r.Contact_Person__r.FirstName, Opportunity__r.Contact_Person__r.LastName, Opportunity__r.Contact_Person__r.Name, 
                                    Opportunity__r.Contact_Person__r.Email, Opportunity__r.Contact_Person__r.Id, Opportunity__r.Contact_Person__r.IsPersonAccount,
                                    Model__r.Branch_Code__c, Model__r.Name, Variant__r.Name, Base_Price__c, Customized_quote__c, First_Name__c, Last_Name__c, OwnerID, Opportunity__r.OwnerID,
									Color_Desc__c, Trim_Desc__c, Vehicle_Model__c, Vehicle_Brand__c, Vehicle_registration_number__c, Mileage__c, Last_4_digits_of_NRIC_FIN_Passport_n__c,
									Bank_Name__c, Loan_Amount__c, Loan_Interest__c, Loan_Term__c, Monthly_Installment__c
                                   FROM Custom_Quote__c 
                                   WHERE Id =: customQuote.Id]; 

                if(customQuoteList.size()>0)
                {
                    relatedCustomQuotes = [SELECT Id FROM Related_Custom_Quotes_List__c WHERE Custom_Quote__c = :customQuote.Id];
                    SalesConsultantList = [SELECT MobilePhone, Name FROM User WHERE ID = :customQuoteList[0].Opportunity__r.OwnerID];
                    if(relatedCustomQuotes.size()>0)
                    {
                        relatedQuoteID = relatedCustomQuotes[0].Id;
                    }
                    if(SalesConsultantList.size()>0)
                    {
                        SalesConsultant = SalesConsultantList[0].Name;
                        if(SalesConsultantList[0].MobilePhone!=null)
                        {
                            SalesConsultantMobileNumber = SalesConsultantList[0].MobilePhone;
                        }
                    }

                    if(customQuoteList[0].Opportunity__r.Contact_Person__r.Id != null)
                    {
                        if(customQuoteList[0].Opportunity__r.Contact_Person__r.Name != null)
                        {
                            personName = customQuoteList[0].Opportunity__r.Contact_Person__r.Name;
                        }
                        personEmail     = customQuoteList[0].Opportunity__r.Contact_Person__r.Email;
                        SubscriberKey   = customQuoteList[0].Opportunity__r.Contact_Person__r.Id;
                        BranchCode      = customQuoteList[0].Model__r.Branch_Code__c;
                        ModelName       = customQuoteList[0].Model__r.Name;
                        VariantName     = customQuoteList[0].Variant__r.Name;
                        BasePrice       = customQuoteList[0].Base_Price__c;
                        CustomizedPrice = customQuoteList[0].Customized_quote__c;

						Trim				= customQuoteList[0].Trim_Desc__c;
						Color				= customQuoteList[0].Color_Desc__c;
						TradeinModel		= customQuoteList[0].Vehicle_Model__c;
						TradeinBrand		= customQuoteList[0].Vehicle_Brand__c;
						Tradeinregnumber	= customQuoteList[0].Vehicle_registration_number__c;
						TradeinMileage		= customQuoteList[0].Mileage__c;
						Lastfournric		= customQuoteList[0].Last_4_digits_of_NRIC_FIN_Passport_n__c;
						BankName			= customQuoteList[0].Bank_Name__c;
						LoanInterest		= String.valueOf(customQuoteList[0].Loan_Interest__c);
						LoanAmount			= String.valueOf(customQuoteList[0].Loan_Amount__c);
						LoanTerm			= String.valueOf(customQuoteList[0].Loan_Term__c);
                        MonthlyInstallment	= String.valueOf(customQuoteList[0].Monthly_Installment__c);
                        
                        //call sendEmail method from future class
                        CustomQuote_ConfirmationEmailSend.sendEmail(personName, personEmail, SubscriberKey, triggeredSendMessageId, BranchCode, 
                                                                    ModelName, VariantName, BasePrice, CustomizedPrice, customQuote.Id, 
                                                                    relatedQuoteID, SalesConsultant, SalesConsultantMobileNumber,
																	Trim, Color, TradeinModel, TradeinBrand, Tradeinregnumber, TradeinMileage,
																	Lastfournric, BankName, LoanInterest, LoanAmount, LoanTerm, MonthlyInstallment );
                    }
                }
                else
                {
                    System.debug('No Custom Quote found');
                }
                
            }
            catch (Exception e)
            {
                loggerDataPool.buildLogDataPool('Trigger_CustomQuote_ConfirmationEmail',e);
            }
            
        }
    }
    

}