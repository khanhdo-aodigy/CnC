global class SendT3Email implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        getPendingDocuMBT3Cases();
        /* Commented this one due to duplicate logic */
        //getPendingDocuMFT3Cases();
    }
    

    //Creat future call out method for http call    
    @future (callout=true)
    public static void getPendingDocuMBT3Cases()            
    {    
        Contact dummyContact;

        try
        {
 			List<Case> casesToUpdate = New List<Case>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        	Date todaysdt = Date.today();                
            Map<ID, EmailTemplate> emMap = getServiceCloudEmailTemplates();

            if(!emMap.isEmpty())
            {       
                ID vrecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Request_Ownership_Particulars_Vehicle_Registration_Number').getRecordTypeId();
                List<Case> CasesList = [SELECT ID, Status, SuppliedEmail, OwnerId, Case_Category__c
                                        FROM Case 
                                        WHERE Status ='Pending for Documents' 
                                        AND CustomCreatedDate__c =: todaysdt
                                        AND RecordTypeId =: vrecordtypeid 
                                        /*AND Franchise__c IN ('MB', 'MBP','MBC')*/];
                //System.debug('Cases List->' + CasesList);
                System.debug('@@@@DEBUG getPendingDocuMBT3Cases :: CasesList = ' + CasesList);
                if(!CasesList.IsEmpty())
                {   
                    List<OrgWideEmailAddress> orgWideEmailAddress = [SELECT Id, Address from OrgWideEmailAddress WHERE DisplayName='C&C Customer Assistance'];
                    //System.debug('@@@@DEBUG getPendingDocuMBT3Cases :: orgWideEmailAddress = ' + orgWideEmailAddress);

                    dummyContact = new Contact (LastName = 'Send T3 Dummy');
                    insert dummyContact; 
                    
                	for (Case c : CasesList)
                    {
                        if(!String.IsEmpty(c.SuppliedEmail)) 
                        {             
                            EmailTemplate SelectedEmailTemplate = New EmailTemplate();
                        	for (ID idKey : emMap.keySet())
                        	{
                            	EmailTemplate em = emMap.get(idKey);
                                // Change of Particulars    
                                if(c.Case_Category__c=='Change of Particulars' && em.DeveloperName == /*'MB_Change_of_particulars_T_3'*/ 'T_3_Reminder_Email')
                                {
                                    SelectedEmailTemplate = em;   
                                    break;
                                }
                            
                                // Change of Ownership
                                if(c.Case_Category__c=='Change of Ownership' && em.DeveloperName == /*'MB_Change_of_ownership_reminder_T_3'*/ 'T_3_Reminder_Email')
                                {
                                    SelectedEmailTemplate = em;   
                                    break;       
                                }
                            
                                // Change of Vehicle Registration Number
                                if(c.Case_Category__c=='Change of Vehicle Registration Number' && em.DeveloperName == /*'MB_Change_of_vehicle_number_reminder_T_3'*/ 'T_3_Reminder_Email')
                                {                         
                                    SelectedEmailTemplate = em;   
                                    break;                            
                                }    
                            }
                    
                            if (SelectedEmailTemplate.ID != NULL)
                            {                                                          
                                mailList = addEmail(mailList, SelectedEmailTemplate.Id, orgWideEmailAddress[0].Id, c.Id, dummyContact.Id, c.suppliedEmail);
                        	}      
                        }
                    }
                    
                    System.debug('@@@@DEBUG getPendingDocuMBT3Cases :: mailList = ' + mailList);
                    if (mailList.size() > 0)
                    {
                        Messaging.sendEmail(mailList);
                    }
                }
            }          
        }
        catch(Exception e)
        {
            System.debug('ERROR :: err.cause = ' + e.getCause() + ' -- err.msg = ' + e.getMessage() + ' --- err.line = ' + e.getLineNumber() );
            loggerDataPool.buildLogDataPool('SendT3Email', e);
        }
        finally
        {
            if (dummyContact <> null) { delete dummyContact;}
        }
    }

    private static List<Messaging.SingleEmailMessage> addEmail(List<Messaging.SingleEmailMessage> mailList, String emTemplateId, String orgWideEmailAddressId, String caseId, String contactId, String suppliedEmail) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emTemplateId);
        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        mail.setReplyTo('customerassistancecentre@cyclecarriage.com.sg');
        mail.setSaveAsActivity(true);
        mail.setTargetObjectId(contactId);
        mail.setToAddresses(new List<String>{suppliedEmail});
        mail.setWhatId(caseId);
        mail.setTreatTargetObjectAsRecipient(false);
        
        mailList.add(mail);
        
        return mailList;
    }
    
    public static Map<ID, EmailTemplate> getServiceCloudEmailTemplates()
    {
        Folder ServiceCloudFolder = [select id, Name from Folder where Name = 'Service Cloud - Auto Replies' Limit 1];      
        Map<ID, EmailTemplate> emMap = New Map<ID, EmailTemplate> ([SELECT Id, Body, Subject, DeveloperName FROM EmailTemplate where FolderId =:ServiceCloudFolder.Id and IsActive=True]);
        
        return emMap;
    }

    /*@future (callout=true)
    public static void getPendingDocuMFT3Cases()            
    { 
        
        try{
            List<Case> casesToUpdate = New List<Case>();
            Date todaysdt = Date.today();  
            Map<ID, EmailTemplate> emMap = getServiceCloudEmailTemplates();
            if(!emMap.isEmpty()){       
                
                ID vrecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Request_Ownership_Particulars_Vehicle_Registration_Number').getRecordTypeId();
                List<Case> CasesList = [select id, status,CustomCreatedDate__c, SuppliedEmail, ContactId,Email_Sent_Date__c,  Franchise__c, Case_Category__c
                                        from Case where status='Pending for Documents' and CustomCreatedDate__c=:todaysdt
                                        and recordtypeid=:vrecordtypeid /*and Franchise__c IN ('CIT', 'CITPC','CITCV')*/
                                       /*];
                /*System.debug('Cases List->' + CasesList);
                
                if(CasesList.size()>0)
                {    
                    for(Case c:CasesList)
                    {
                        if(!string.IsEmpty(c.ContactId) && !string.IsEmpty(c.SuppliedEmail)){
                            
                            EmailTemplate SelectedEmailTemplate = New EmailTemplate();
                            for(ID idKey : emMap.keySet())
                            {
                                EmailTemplate em = emMap.get(idKey);
                                // Change of Particulars    
                                if(c.Case_Category__c=='Change of Particulars' && em.DeveloperName == /*'MF_Change_of_particulars_T_3'*/ /*'T_3_Reminder_Email'){
                                    SelectedEmailTemplate = em;   
                                    break;
                                }
                                
                                // Change of Ownership
                                if(c.Case_Category__c=='Change of Ownership' && em.DeveloperName == /*'MF_Change_of_ownership_reminder_T_3'*/ /*'T_3_Reminder_Email'){
                                    SelectedEmailTemplate = em;   
                                    break;       
                                }
                                
                                // Change of Vehicle Registration Number
                                if(c.Case_Category__c=='Change of Vehicle Registration Number' && em.DeveloperName == /*'MF_Change_of_vehicle_number_reminder_T_3'*/ /*'T_3_Reminder_Email'){                         
                                    /*SelectedEmailTemplate = em;   
                                    break;                            
                                }    
                            }
                            
                            if(SelectedEmailTemplate.ID!=NULL)
                            {                           
                                Messaging.SendEmailResult[] resultMail = sendEmailMethod(SelectedEmailTemplate, c.id, c.contactid, c.suppliedemail);    
                                system.debug(resultMail.get(0).isSuccess());   
                                // Success...	
                                if(resultMail.get(0).isSuccess()){
                                    c.Is_T_3_Email_Success__c = TRUE;
                                    casesToUpdate.add(c);
                                }
                                
                                // Not success...
                                if(!resultMail.get(0).isSuccess()){
                                    c.Is_T_3_Email_Success__c = FALSE;
                                    system.debug(resultMail.get(0).getErrors());
                                    System.StatusCode statusCode = resultMail.get(0).getErrors()[0].getStatusCode();
                                    c.T_3_Status_Code__c = string.valueof(statusCode);
                                    String errorMessage = resultMail.get(0).getErrors()[0].getMessage();       
                                    c.T_3_Error_Message__c = errorMessage;
                                    casesToUpdate.add(c);
                                }
                                
                            }      
                        }
                        
                    }
                    
                    if(casesToUpdate.size()>0){
                        Update casesToUpdate;
                        
                    }
                }
            }      
            
        }catch(CustomException e){
            system.debug(e.getMessage());
            loggerDataPool.buildLogDataPool('SendT3Email', e);
        }
    }*/
    
    
    /*public static Messaging.SendEmailResult[] sendEmailMethod(EmailTemplate emtemplate, string caseid, string contactid, string suppliedemail)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emtemplate.Id);
        List<OrgWideEmailAddress> orgWideEmailAddress = [Select Id, Address from OrgWideEmailAddress where 
                                                         DisplayName='Customer Assistance Centre'];
        mail.setOrgWideEmailAddressId(orgWideEmailAddress[0].id);
        mail.setReplyTo('customerassistancecentre@cyclecarriage.com.sg');
        mail.setSaveAsActivity(true);
        mail.setTargetObjectId(contactid);// Any contact or User id of your record
        mail.setToAddresses(new list<string>{SuppliedEmail});
        mail.setwhatid(caseid);
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //System.debug('Email Send Result->' + resultMail);
        
        return resultMail;
    } */
}