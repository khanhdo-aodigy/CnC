/** ******
 * Description : Utility Class
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20181226             Hari Panneerselvam          Created initial version
 * 20200312             HS                          Added PA Migration Phase 1 changes
 * 20200921             KD                          Added PA Migration Phase 2 changes
 * 
** ******/
public without sharing class Utility {

    public static Boolean isWebTestDrive = false;
    public static String isWebTestDriveBrand = '';

    public static String getFields(String objectName) {
        Map<String, Schema.SObjectType> mapSchema = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> mapField = mapSchema.get(objectName).getDescribe().fields.getMap();
        String stringField = '';
        for(String itrField : mapField.keySet()){
            stringField = (stringField == '') ? itrField : stringField + ', ' +itrField;
        }
        return stringField;
    }
    
    /** PA MIGRATION : REFER TO AccountUtil.getCustomerListByEmails( Set<String> param_customerEmails ) !!! */
    public static List<Contact> checkForContact( String stringEmail ) {
        return Database.query('SELECT ' +getFields('Contact')+ ' FROM Contact WHERE ispersonaccount = false and Email = :stringEmail');
    }

    /** PA MIGRATION : REFER TO AccountUtil.getProspectListByEmails( Set<String> param_customerEmails ) !!! */
    //PA Phase 2: To Remove
    /** 
     public static List<Lead> checkForLead( String stringEmail ) {
        return Database.query('SELECT ' +getFields('Lead')+ ' FROM Lead WHERE Email = :stringEmail');
    }
    */

    public static List<Variant__c> getVariantFromStockVehicleMaster(Vehicle_Master2__c vehMaster) {
        String uniqueIdForVariant = vehMaster.Model_Code__r.Branch_Code__c + ',' +vehMaster.Model_Code__r.Franchise_Code__c +',' +vehMaster.Model_Code__r.Name;
        return Database.query('SELECT ' +getFields('Variant__c') +', Model_ID__r.Name' +' FROM Variant__c WHERE DWH_Variant_ID__c = \'' +uniqueIdForVariant +'\'');
    }

    /*
    public static List<Opportunity> checkForExistingOpportunity(List<Contact> lstContact, List<Lead> lstLead, List<Variant__c> lstVariantFromModelMaster){
        String stringQuery = '';
        String modelId = lstVariantFromModelMaster[0].Model_ID__c;
        if(lstContact != null && lstContact.size() > 0){
            String contactEmail = lstContact[0].Email;
            stringQuery = 'SELECT ' +getFields('Opportunity')+ ' from Opportunity WHERE Contact_Person__r.Email = :contactEmail and Model_c__c = :modelId order by CreatedDate DESC  limit 1';
        }else if(lstLead != null && lstLead.size() > 0){
            String leadEmail = lstLead[0].Email;
            stringQuery = 'SELECT ' +getFields('Opportunity')+ ' from Opportunity WHERE Lead__r.Email = :leadEmail and Model_c__c = :modelId order by CreatedDate DESC  limit 1';
        }
        system.debug('stringQuery::' +stringQuery);
        if(stringQuery != ''){
            return Database.query(stringQuery);
        }else{
            return new List<Opportunity>();
        }
    }
    */

    /** PA MIGRATION : Added Account__c ; Customer_Email__c formula field need to changed */
    public static List<Opportunity> checkForExistingOpportunity(String custEmail, List<Variant__c> lstVariantFromModelMaster) {
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp = [SELECT Id, Name, RecordTypeId, Contact_Person__c,
                         Account__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c,
                         StageName, Branch_Code__c, Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c,
                         TotalOpportunityQuantity, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                        ( SELECT id, Model__c, Touch_Points__c 
                          FROM Models_Interested__r 
                          WHERE Model__c = :lstVariantFromModelMaster[0].Model_ID__c
                        )
                  FROM Opportunity 
                  WHERE Customer_Email__c = :custEmail
                  AND StageName NOT IN ('Booked', 'Lost') 
                  AND CreatedDate > :Date.today().addMonths(-3) 
                  ORDER BY CreatedDate DESC LIMIT 1];

        if(lstOpp != null && lstOpp.size() > 0 && lstOpp[0].Models_Interested__r != null && lstOpp[0].Models_Interested__r.size() > 0) {
            return lstOpp;
        }
        return new List<Opportunity>();
    }

    /** PA MIGRATION : Added Account__c ; Customer_Email__c formula field need to changed */
    public static List<Opportunity> checkOppExistsForThisConsultant(String consultantId, String custEmail){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, RecordTypeId, Contact_Person__c,
                                 Account__c, Old_Car_No__c,Date_of_Registration__c,Make_Model__c,
                                 StageName, Branch_Code__c, Franchise_Code__c,
                                 Model_c__c, Opportunity_Score__c, PriceAlert__c,
                                 TotalOpportunityQuantity, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                (SELECT Id, Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE OwnerId = :consultantId 
                          AND Customer_Email__c = :custEmail
                          AND StageName NOT IN ('Booked', 'Lost') 
                          AND CreatedDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }



    /* NOTE 
    # checkOpenOppExistsForTheContact
    # checkOppExistsForTheLead
    # checkOpenOppExistsForTheAccount
    ---> checkOpenOppExistsForThisContact

    # checkBookedOppExistsForTheLead
    ---> checkOppExistsForTheProspect

    # checkOppExistsForTheContact 
    ---> checkOppExistsForTheCustomer
    */
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ CHECK OPEN OPPO - START ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    public static List<Opportunity> checkOpenOppExistsForTheContact(String branchCode, String contactId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, Rating__c, RecordTypeId, Custom_Quote__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, Test_Drive__c, Preferred_Model__c , Contact_Person__c, Lead__c, Account__c, StageName, 
                                Branch_Code__c, Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                (SELECT id, Name,Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Contact_Person__c = :contactId 
                          AND StageName not in ('Booked', 'Lost')
                          AND CreatedDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }

    /** PA MIGRATION : To Remove Part-1.2 Start ; Refer checkOpenOppExistsForTheProspect */
    public static List<Opportunity> checkOppExistsForTheLead(String branchCode, String leadId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT id, name, Rating__c, RecordTypeId, Custom_Quote__c, Test_Drive__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, Preferred_Model__c, Contact_Person__c, Lead__c, StageName, Branch_Code__c, 
                            Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, Account__c,
                            (SELECT id, Model__c, Touch_Points__c from Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND lead__c = :leadId
                          AND StageName NOT IN ('Booked', 'Lost')
                          AND CreatedDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }
    /** PA MIGRATION : To Remove Part-1.2 end */

    /** PA MIGRATION : Newly Added Part-1.1.1 Start ; Tho ; To replace checkOpenOppExistsForTheContact */
    public static List<Opportunity> checkOpenOppExistsForTheAccount(String branchCode, String accountId) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, Rating__c, RecordTypeId, Custom_Quote__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, Test_Drive__c, Preferred_Model__c , Contact_Person__c, Lead__c, Account__c , StageName, 
                            Branch_Code__c, Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                            (SELECT Id, Name,Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Account__c = :accountId 
                          AND StageName NOT IN ('Booked', 'Lost')
                          AND CreatedDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }
    /** PA MIGRATION : Newly Added Part-1.1.1 End ; Tho */

    /**
     * @param branchCode : Brand Code value     
     * @param contactId : Contact Id (Person Account ContactId / Business Account ContactId)
     * @param acctRecordTypeDeveloperName : Account Record Type Developer Name (ex: Customer, Prospect, Business_Account, etc.)
     */
    public static List<Opportunity> checkOpenOppExistsForThisContact( String branchCode, String contactId/*, String acctRecordTypeDeveloperName*/ ) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, Rating__c, RecordTypeId, Custom_Quote__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, Test_Drive__c, Preferred_Model__c , Contact_Person__c, Lead__c, Account__c , StageName, 
                            Branch_Code__c, Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                            (SELECT Id, Name,Model__c, Touch_Points__c 
                             FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Contact_Person__c = :contactId 
                          //AND Contact_Person__r.Account.RecordType.DeveloperName = :acctRecordTypeDeveloperName
                          AND StageName NOT IN ('Booked', 'Lost')
                          AND CreatedDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ CHECK OPEN OPPO - END ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


    //******************************************************************************************************************* 
    //**************************************** CHECK BOOKED OPPO - START ************************************************
    //*******************************************************************************************************************
    /** PA MIGRATION : To Remove Part-2.1 Start ; Refer checkOppExistsForTheCustomer */
    public static List<Opportunity> checkOppExistsForTheContact(String branchCode, String contactId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, name,RecordtypeId, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, Contact_Person__c, Lead__c, Account__c, StageName, Branch_Code__c, Franchise_Code__c, Model_c__c, 
                                Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                (SELECT Id, Name, Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Contact_Person__c = :contactId 
                          AND Owner.isActive = true 
                          AND StageName IN ('Booked') 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }
    /** PA MIGRATION : To Remove Part-2.1 End */

    /** PA MIGRATION : Newly Added Part-2.1 Start ; To replace checkOppExistsForTheContact */
    public static List<Opportunity> checkOppExistsForTheCustomer( String branchCode, String paCustomerContactId ){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, RecordtypeId, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, Contact_Person__c, Lead__c, Account__c, StageName, Branch_Code__c, Franchise_Code__c, Model_c__c, 
                                Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                (SELECT Id, Name, Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Contact_Person__c = :paCustomerContactId 
                          AND Contact_Person__r.Account.RecordType.DeveloperName = 'Customer'
                          AND Owner.isActive = true 
                          AND StageName IN ('Booked') 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    } 
    /** PA MIGRATION : Newly Added Part-2.1 End */

    /** PA MIGRATION : To Remove Part-2.2 Start ; Refer checkOppExistsForTheProspect */
    public static List<Opportunity> checkBookedOppExistsForTheLead(String branchCode, String leadId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, RecordTypeId,Contact_Person__c, Lead__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, StageName, Branch_Code__c, Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c,
                            TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, Account__c,
                            (SELECT Id, Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Lead__c = :leadId  
                          AND StageName in ('Booked')
                          AND createdDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }
    /** PA MIGRATION : To Remove Part-2.2 End */

    /** PA MIGRATION : Newly Added Part-2.2 Start ; To replace checkBookedOppExistsForTheLead */
    public static List<Opportunity> checkOppExistsForTheProspect(String branchCode, String paProspectContactId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id, Name, RecordTypeId,Contact_Person__c, Lead__c, Old_Car_No__c, Date_of_Registration__c, Make_Model__c, StageName, Branch_Code__c, Franchise_Code__c, Model_c__c, Opportunity_Score__c, PriceAlert__c,
                            TotalOpportunityQuantity, EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, Account__c,
                            (SELECT Id, Model__c, Touch_Points__c FROM Models_Interested__r)
                          FROM Opportunity 
                          WHERE Branch_Code__c = :branchCode 
                          AND Contact_Person__c = :paProspectContactId  
                          AND Contact_Person__r.Account.RecordType.Name = 'Prospect'
                          AND StageName in ('Booked')
                          AND createdDate > :Date.today().addMonths(-6) 
                          ORDER BY CreatedDate DESC LIMIT 1];
        return lstOpportunity;
    }
    /** PA MIGRATION : Newly Added Part-2.2 End */
    //******************************************************************************************************************* 
    //***************************************** CHECK BOOKED OPPO - END *************************************************
    //*******************************************************************************************************************


    public static List<Vehicle_Master__c> getModelForTestDrive(Variant__c variant){
        return Database.query('SELECT ' +getFields('Vehicle_Master__c') +' FROM Vehicle_Master__c WHERE Variant__c = \'' +variant.Id +'\' AND Type__c = \'Test Drive\' ORDER BY CreatedDate DESC limit 1');
    }
    
    /*
    public static List<Stock_Promotion__c> getStockPromotions(set<String> setVehicleType, String branch){
        return Database.query('SELECT ' +getFields('Stock_Promotion__c')+ 'Stock_Vehicle_Master__r.Model_Description__c, Stock_Vehicle_Master__r.Model_Code__r.name,'
                        + ' Stock_Vehicle_Master__r.Color_Code__r.Name, Stock_Vehicle_Master__r.Chassis__c, Stock_Vehicle_Master__r.Model_Year_Code__r.name'
                        + ' from Stock_Promotion__c WHERE Stock_Promotion_Status__c = \'ADD\' and'
                        + ' Stock_Vehicle_Master__r.Vehicle_Status__c = \'RESRV\' and Stock_Vehicle_Master__r.Branch_Code__c = :branch'
                        + ' and Vehicle_Type__c IN :setVehicleType');
    }
    */

    public static Integer getSequenceNo(String branch) {
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
        Integer sequenceNo;
        if(branch == 'CCK'){
            sequenceNo = (Integer)JCC_GlobalVar.KIASeqNumGV__c + 1;
            JCC_GlobalVar.KIASeqNumGV__c = sequenceNo;
        }
        else if(branch == 'CCA'){
            sequenceNo = (Integer)JCC_GlobalVar.MITSeqNumGV__c + 1;
            JCC_GlobalVar.MITSeqNumGV__c = sequenceNo;
        }
        else if(branch == 'CCF'){
            sequenceNo = (Integer)JCC_GlobalVar.CITSeqNumGV__c + 1;
            JCC_GlobalVar.CITSeqNumGV__c = sequenceNo;
        }
        update JCC_GlobalVar;
        return sequenceNo;
    }


    //For Paid Events and AfterSales Promotion,
    //this can be consolidated to a new method with params: branch + module
    public static Integer getSequenceNoEvent(String branch, String campId){
        InvoiceSeqNum__c runNum = [SELECT Id, MITSeqNum__c, KIASeqNum__c, CitroenSeqNum__c, MBSeqNum__c,
                                   MerchandiseSeqNum__c, OneTimePurchaseSeqNum__c, ServicePackageSeqNum__c
                                   FROM InvoiceSeqNum__c
                                   WHERE Campaign__c=:campId
                                   ORDER BY CreatedDate
                                   LIMIT 1];
        Integer sequenceNo = 0;
        if(branch == 'CCK'){
            sequenceNo = (Integer)runNum.KIASeqNum__c + 1;
            runNum.KIASeqNum__c = sequenceNo;
        }
        else if(branch == 'CCA'){
            sequenceNo = (Integer)runNum.MITSeqNum__c + 1;
            runNum.MITSeqNum__c = sequenceNo;
        }
        else if(branch == 'CCF'){
            sequenceNo = (Integer)runNum.CitroenSeqNum__c + 1;
            runNum.CitroenSeqNum__c = sequenceNo;
        }
        else if(branch == 'CCI'){
            Campaign campaign = [Select Promotion_Type__c, Type From Campaign Where Id = :campId];
            System.debug('@@@@DEBUG getSequenceNoEvent :: campaign = ' + campaign );
            if(campaign.Type == 'Promotions') {
                switch on campaign.Promotion_Type__c {
                    when 'One Time Purchase' {
                        sequenceNo = (Integer)runNum.OneTimePurchaseSeqNum__c + 1;
                        runNum.OneTimePurchaseSeqNum__c = sequenceNo;
                    }
                    when 'Service Package' {
                        sequenceNo = (Integer)runNum.ServicePackageSeqNum__c + 1;
                        runNum.ServicePackageSeqNum__c = sequenceNo;
                    }
                    when 'Merchandise' {
                        sequenceNo = (Integer)runNum.MerchandiseSeqNum__c + 1;
                        runNum.MerchandiseSeqNum__c = sequenceNo;
                    }
                }
            } 
            else {
                sequenceNo = (Integer)runNum.MBSeqNum__c + 1;
                runNum.MBSeqNum__c = sequenceNo;
            }
        }
        update runNum;
        return sequenceNo;
    }


    public static List<Invoice__c> checkForOpenInvoice(String custEmail){
        List<Invoice__c> lstInvoice = [SELECT Id, Invoice_Number__c, Customer_Email__c from Invoice__c WHERE Customer_Email__c = :custEmail and Transaction_ID__c = null];
        return lstInvoice;
    }


    public class httpErrorResponse{
        public String status;
        public String message;

        public httpErrorResponse(String stausValue, String messageValue){
            status = stausValue;
            message = messageValue;
        }
    }


    public class httpSuccessResponse{
        public String status;
        public String message;

        public httpSuccessResponse(String stausValue, String messageValue){
            status = stausValue;
            message = messageValue;
        }
    }


    public static void createToDoTask(Stock_Reservation__c stockReservation, String toDoFor){
        Task newTask = new Task();
        if(toDoFor == 'Confirmation'){
            newTask.Subject = stockReservation.Stock_Source__c +' - Confirmation';
            newTask.ActivityDate = Date.today().addDays(2);
        }
        else if(toDoFor == 'Refund'){
            newTask.Subject = stockReservation.Stock_Source__c +' - Refund Request';
            newTask.ActivityDate = Date.today().addDays(7);
        }
        newTask.OwnerId  = stockReservation.ownerid;
        newTask.WhatId   = stockReservation.Opportunity__c;
        newTask.Status   = 'Open';
        newTask.Priority = 'Normal';
        insert newTask;
    }


    /*****************************************************
    * Method Name: createTask
    * Description: Method to create a Task
    *               to related to a parent object
    *               and assign to a User.
    * Parameters:
    *           String relatedTo - Parent SObject Id (Related To)
    *           String userId - User Id (Assigned To)
    *           String subj - Subject
    * Revision History
    * Developer Name        Date            Description
    * Christian Gaylan      22-Mar-2019     Created.
    *****************************************************/
    public static Task createTask(String relatedTo, String userId, String subj){
        Map<String, Branch_Configuration__mdt> mapBatchConfiguration = new Map<String, Branch_Configuration__mdt>();
        List<Task> lstTask = new List<Task>();
        Task tsk = new Task();
        List <sharingHelper.generateShare> lstToCreateShare = new List <sharingHelper.generateShare> ();
        if(String.isNotBlank(relatedTo) && String.isNotBlank(userId) && String.isNotBlank(subj)){
            try{
                tsk.Subject = subj;
                tsk.OwnerId = userId;
                tsk.WhatId = relatedTo;
                tsk.ActivityDate = Date.today().addDays(1);
                tsk.Status = 'Open';
                tsk.Priority = 'Normal';
                tsk.Send_SMS__c  = false;
                tsk.sms_date_trigger__c  = null;
                tsk.SMS_reminder__c  = null;
                tsk.IsReminderSet = true;
                tsk.ReminderDateTime = DateTime.now();

                if(isWebTestDrive){
                    mapBatchConfiguration = getBatchConfiguration();
                    if(mapBatchConfiguration != null && mapBatchConfiguration.size() > 0 && mapBatchConfiguration.get(isWebTestDriveBrand) != null){
                        if(mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c != null && mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c != ''){
                            List<String> lstToDoUser = mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c.replace(' ','').split(',');
                            for(String itr : lstToDoUser){
                                Task tempTask = new Task();
                                tempTask.Subject = subj;
                                tempTask.OwnerId = itr;
                                tempTask.WhatId = relatedTo;
                                tempTask.ActivityDate = Date.today().addDays(1);
                                tempTask.Status = 'Open';
                                tempTask.Priority = 'Normal';
                                tempTask.Send_SMS__c  = false;
                                tempTask.sms_date_trigger__c  = null;
                                tempTask.SMS_reminder__c  = null;
                                tempTask.IsReminderSet = true;
                                tempTask.ReminderDateTime = DateTime.now();
                                lstTask.add(tempTask);
                                lstToCreateShare.add(new sharingHelper.generateShare('Edit', 'Opportunity', relatedTo, tempTask.OwnerId));
                            }
                            if(lstTask != null && lstTask.size() > 0){
                                Database.insert(lstTask, false);
                            }
                            if(lstToCreateShare != null && lstToCreateShare.size() > 0){
                                system.debug('lstToCreateShare::' +lstToCreateShare);
                                sharingHelper.creatShare(lstToCreateShare);
                            }
                        }
                    }
                }
            }catch(Exception e){
                loggerDataPool.buildLogDataPool('Utility',e);
            }
        }
        return tsk;
    }

    /** PA MIGRATION : To Remove Part-3 start ; refer webTDManagerAccessToProspectRecords; this method has been referred from Book_TestDrive.cls */
    /*
    public static List<sharingHelper.generateShare> webTDManagerAccess(String parentId){
        Map<String, Branch_Configuration__mdt> mapBatchConfiguration = new Map<String, Branch_Configuration__mdt>();
        List <sharingHelper.generateShare> lstToCreateShare = new List <sharingHelper.generateShare> ();
        mapBatchConfiguration = getBatchConfiguration();
        if(mapBatchConfiguration != null && mapBatchConfiguration.size() > 0 && mapBatchConfiguration.get(isWebTestDriveBrand) != null){
            if(mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c != null && mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c != ''){
                List<User> lstToDoUser = [SELECT Id FROM User WHERE id in :mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c.replace(' ','').split(',')];
                for(User itr : lstToDoUser){
                    lstToCreateShare.add(new sharingHelper.generateShare('Edit', 'Lead', parentId, itr.id));
                }
            }
        }
        return lstToCreateShare;
    }
    */
    /** PA MIGRATION : To Remove Part-3 end */

    /** PA MIGRATION : Newly Added Part-3 start */
    /** Grant Record Access to PersonAccount (i.e. Prospect ) */
    public static List<sharingHelper.generateShare> webTDManagerAccessToProspectRecords(String paRecordId){
        Map<String, Branch_Configuration__mdt> mapBatchConfiguration = new Map<String, Branch_Configuration__mdt>();
        List <sharingHelper.generateShare> lstToCreateShare = new List <sharingHelper.generateShare> ();
        mapBatchConfiguration = getBatchConfiguration();
        if(mapBatchConfiguration != null && mapBatchConfiguration.size() > 0 && mapBatchConfiguration.get(isWebTestDriveBrand) != null){
            if(mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c != null && mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c != ''){
                List<User> lstToDoUser = [SELECT Id FROM User WHERE ID IN :mapBatchConfiguration.get(isWebTestDriveBrand).To_Do_List_Managers__c.replace(' ','').split(',')];
                for(User usr : lstToDoUser){
                    lstToCreateShare.add(new sharingHelper.generateShare('Edit', 'Account', paRecordId, usr.id));
                }
            }
        }
        return lstToCreateShare;
    }
    /** PA MIGRATION : Newly Added Part-3 end */
    

    public static Map<String, Branch_Configuration__mdt> getBatchConfiguration(){
        Map<String, Branch_Configuration__mdt> mapBranchConfig = new Map<String, Branch_Configuration__mdt>();
        List<Branch_Configuration__mdt> lstBranchConfig = new List<Branch_Configuration__mdt>();
        lstBranchConfig = [ SELECT Branch_Code__c, Branch_Name__c, Warehouse_Name__c, Opp_RT__c, Default_OwnerId__c, To_Do_List_Managers__c 
                            FROM Branch_Configuration__mdt ];
        for(Branch_Configuration__mdt itr : lstBranchConfig){
            mapBranchConfig.put(itr.Branch_Code__c, itr);
        }
        return mapBranchConfig;
    }

    //Check for sandbox
    public static Boolean isSandbox
    {
        get
        {
            return [select IsSandbox from Organization limit 1].IsSandbox;
        }
    }

}