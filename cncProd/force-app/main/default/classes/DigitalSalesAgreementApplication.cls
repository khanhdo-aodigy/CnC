public with sharing class DigitalSalesAgreementApplication {

    @AuraEnabled
    public static /*Sales_Agreement__c*/ sObject initializeSalesAgreement(Id recordId){
        Sales_Agreement__c returnSalesAgreement = new Sales_Agreement__c();
        Stock_Reservation__c returnStockRes = new Stock_Reservation__c();
        SalesAgreementSelector salesAgreementSel = new SalesAgreementSelector();
        StockReservationSelector stockResSel = new StockReservationSelector();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        try{

            if(objectName == 'Stock_Reservation__c'){
                try{
                    returnSalesAgreement = salesAgreementSel.selectByStockReservationId(recordId);
                }catch(System.ListException ex){
                    system.debug(ex.getMessage());
                    //returnSalesAgreement = DigitalSalesAgreementApplication.createInitialSalesAgreement(recordId);
                    returnStockRes = stockResSel.selectById(new Set<Id>{recordId})[0];

                    return returnStockRes;
                }

            }else if(objectName == 'Sales_Agreement__c'){
                returnSalesAgreement = (Sales_Agreement__c)(salesAgreementSel.selectSObjectsById(new Set<Id>{ recordId }))[0];
            }
        } catch (DMLException e){
            throw new AuraHandledException(e.getMessage());
        }   
        
        return returnSalesAgreement;
    }

    @AuraEnabled
    public static Id updateSalesAgreement (Sales_Agreement__c salesAgreement){

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType});
        system.debug(salesAgreement);
        try{
            uow.registerDirty(salesAgreement);
            uow.commitWork();
            
        } catch (DMLException e){
            String errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                system.debug(errorMsg);
            }
            throw new AuraHandledException(errorMsg);
        }
        
        return salesAgreement.Id;
    }

    @AuraEnabled
    public static Sales_Agreement__c createInitialSalesAgreement(Id recordId){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType});
        Sales_Agreement__c newSalesAgreementRec = new Sales_Agreement__c();
        newSalesAgreementRec.Stock_Reservation__c = recordId;
        uow.registerNew(newSalesAgreementRec);
        uow.commitWork();
        return newSalesAgreementRec;
    }

    @AuraEnabled(cacheable=true)
    public static LIST<SA_Accessory__c> getSAAcessories(Id recordId){
        SaAccsSelector saAccessoriesSelector = new SaAccsSelector();
        return saAccessoriesSelector.selectAccBySalesAgreementId(new Set<Id>{recordId});
    }

    @AuraEnabled(cacheable=true)
    public static LIST<Accessories_Master__c> getAccessoriesMaster(Id recordId){

        LIST<String> ascgroup = new list<string>();
        ascgroup.add('ADDITIONAL ACCESSORIES');
        ascgroup.add('MAIN ACCESSORIES');
        ascgroup.add('INSURANCE');
        ascgroup.add('SERVICE');
        ascgroup.add('WARRANTY');
        ascgroup.add('PROMOTIONS & DISCOUNTS');

        Sales_Agreement__c salesRec = new SalesAgreementSelector().selectById(recordId);
        return new AccessoriesMasterSelector().selectAccessoriesBasedOnGroup(ascgroup, salesRec.Branch_Code__c, salesRec.FranchiseCode__c, salesRec.ModelMajorGroupCode__c, 'A');
        //return new AccessoriesMasterSelector().selectAccessoriesBasedOnGroup(ascgroup, salesRec.Branch_Code__c, salesRec.ModelMajorGroupCode__c, 'A');

    }

    @AuraEnabled
    public static void deleteOffpeakRecord(SA_Accessory__c offPeakRecord){
        delete offPeakRecord;
    }
    
    @AuraEnabled
    public static SA_Accessory__c upsertOffPeakRecord(Id recordId, String branchCode){
        SA_Accessory__c saOffpeakRec = new SA_Accessory__c();
        Accessories_Master__c offPeakRecord = new AccessoriesMasterSelector().selectByBranchAndAccsCode(branchCode,'OFF PEAK');
        Integer count =  [SELECT count() FROM SA_Accessory__c where Sales_Agreement__c=:recordId];

        try{
            saOffpeakRec = new SaAccsSelector().selectOffpeakRecord(recordId, offPeakRecord.Id);
        } catch (Exception e) {
        
            saOffpeakRec = new SA_Accessory__c(Sales_Agreement__c = recordId, Accessories_Master__c = offPeakRecord.Id, SAC_LINENO__c = count += 1,
                    SAC_PACKAGE__c = 'N', SAC_ACCSTRADE__c = 'N', SACQTY__c = 1, SAC_ACCSVALUE__c = -17000);
            insert saOffpeakRec;
        }
        return saOffpeakRec; 
    }

    @AuraEnabled(cacheable=true)
    public static LIST<SA_Additional_Charge__c> getSAAdditionalCharges(Id recordId){

        LIST<String> chargeCodeList = new list<string>();
        chargeCodeList.add('R001'); //Registration Charges
        chargeCodeList.add('C001'); //Surcharges
        chargeCodeList.add('C002'); //Surcharges
        chargeCodeList.add('R015'); //Surcharges
        //R002 and R004 will only return 1 result
        chargeCodeList.add('R002'); //Road Tax 6months
        chargeCodeList.add('R004'); //Road Tax 1years

        return new SaAddnlChargeSelector().selectbySalesAgreementIdAndChargeCodes(recordId, chargeCodeList);
    }

    @AuraEnabled(cacheable=true)
    public static LIST<Package_Additional_Charges__c> getAdditionalCharges(Id recordId){

        LIST<String> chargeCodeList = new list<string>();
        chargeCodeList.add('R001'); //Registration Charges
        chargeCodeList.add('C002'); //Surcharges

        //R002 and R004 will only return 1 result
        chargeCodeList.add('R002'); //Road Tax 6months
        chargeCodeList.add('R004'); //Road Tax 1years

        Sales_Agreement__c salesRec = new SalesAgreementSelector().selectById(recordId);
        return new PackageAdditionalChargesSelector().selectByPackageHeaderAndChargeCode(salesRec.Package_Header__c, chargeCodeList);
    }

    @AuraEnabled
    public static LIST<SA_Accessory__c>  processSAAccessories (LIST<SA_Accessory__c> accessorylist, List<SA_Accessory__c> accessorylistToBeDeleted){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {SA_Accessory__c.SObjectType});
        SAAccesoriesUpsertUOW upsertSAAccessories = new SAAccesoriesUpsertUOW();
        uow.registerWork(upsertSAAccessories);
        upsertSAAccessories.registerSAAccessories(accessorylist);

        if(!accessorylistToBeDeleted.isEmpty()){
            uow.registerDeleted(accessorylistToBeDeleted);
        }
        uow.commitWork();
        return accessorylist;
    }

    @AuraEnabled(cacheable=true)
    public static LIST<SA_Accessory__c> getAddonSAAcessories(Id recordId){
        SaAccsSelector saAccessoriesSelector = new SaAccsSelector();
        return saAccessoriesSelector.selectAddonAccBySalesAgreementId(new Set<Id>{recordId});
    }

    @AuraEnabled
    public static void deleteAddonSAAcessories(LIST<SA_Accessory__c> accessorylist){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {SA_Accessory__c.SObjectType});
        uow.registerDeleted(accessorylist);
        uow.commitWork();
    }

    @AuraEnabled(cacheable=true)
    public static LIST<Business_Associate_Master__c>getBusinessAssociateMaster(LIST<String> typelist){
        BusinessAssociateMasterSelector bamSelector = new BusinessAssociateMasterSelector();
        return bamSelector.selectByType(typelist);
    }


    @AuraEnabled (cacheable=true)
    public static LIST<SA_Additional_Charge__c> getNumberRetentionAdditionalChargesMaster(){
        LIST<SA_Additional_Charge__c> numberRetentionSAList = new LIST<SA_Additional_Charge__c>();
        LIST<String> chargeCodeList = new list<string>();
        chargeCodeList.add('R015'); 
        //chargeCodeList.add('R022'); 
        LIST<Additional_Charges_Master__c> additionalChargeMasterList = new AdditionalChargesMasterSelector().selectBasedOnChargeCode(chargeCodeList);
        for(Additional_Charges_Master__c rec : additionalChargeMasterList){
            numberRetentionSAList.add(  new SA_Additional_Charge__c (
                                        SAD_CHARGES__c = 100,
                                        SAD_PACKAGE__c = 'N',
                                        SAD_ADM_CHARGTYPE__c = 'ADDNL',
                                        SAD_INCPRICE__c = 'WP',
                                        SAD_ADM_OTHERTYPE__c = 'FIN',
                                        AdditionalChargesMaster__c = rec.Id));

        }
        return numberRetentionSAList;
    }

    @AuraEnabled
    public static void deleteNumberRetention(SA_Additional_Charge__c numberRetentionRec){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {SA_Additional_Charge__c.SObjectType});
        uow.registerDeleted(numberRetentionRec);
        uow.commitWork();
    }

    @AuraEnabled
    public static SA_Additional_Charge__c upsertNumberRetention(Id salesAgreementId, SA_Additional_Charge__c updateRec){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {SA_Additional_Charge__c.SObjectType});
        SAAdditionalChargesUpsertUOW upsertSAAdditionalCharges = new SAAdditionalChargesUpsertUOW();
        uow.registerWork(upsertSAAdditionalCharges);
        updateRec.Sales_Agreement__c = salesAgreementId;
        upsertSAAdditionalCharges.registerSAAdditionalCharge(updateRec);
        uow.commitWork();
        return updateRec;
    }

    @AuraEnabled
    public static Id updateStockReservation (Stock_Reservation__c stockRes){

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Stock_Reservation__c.SObjectType});
        system.debug(stockRes);
        try{
            uow.registerDirty(stockRes);
            uow.commitWork();
            
        } catch (DMLException e){
            String errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                system.debug(errorMsg);
            }
            throw new AuraHandledException(errorMsg);
        }
        
        return stockRes.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<Package_Header__c> getPackage (string modelCodeId){

        List<Package_Header__c> returnedPackages = [SELECT Id, Name, PKH_PKGDESC__c FROM Package_Header__c WHERE Model_Master__c =: modelCodeId AND PKH_STATUS__c  = 'A'];
        
        return returnedPackages;
    }

    /** ADDED BY TPHAN ON 22/07/2021 - MYC&C LOGIN REVAMP */
    @AuraEnabled
    public static Id cancelSalesAgreement (Sales_Agreement__c salesAgreement)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType, Stock_Reservation__c.SObjectType});
        Stock_Reservation__c stockRes= new Stock_Reservation__c(Id = salesAgreement.Stock_Reservation__c, Reservation_Status__c = 'Cancel', Cancellation_Reason__c = 'Change of email address for MyC&C App');
        system.debug(salesAgreement);
        try
        {
            uow.registerDirty(stockRes);
            uow.registerDirty(salesAgreement);
            uow.commitWork();
            User u = [SELECT Username2__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
            if (!Test.isRunningTest())
            {
                 VSMSHelperClass.updateSR(salesAgreement.Stock_Reservation__c, u.Username2__c);
            }
        } 
        catch (DMLException e)
        {
            String errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                system.debug(errorMsg);
            }
            throw new AuraHandledException(errorMsg);
        }
        
        return salesAgreement.Id;
    }
    /** ADDED BY TPHAN ON 22/07/2021 - MYC&C LOGIN REVAMP */
    
    /** ADDED BY TPHAN ON 23/07/2021 - PA MERGING - INVOKED IN EnvelopSendController.cls */
    @future
    public static void updateRelatedPA (Id salesAgreementId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Account.SObjectType});

        try 
        {
            Sales_Agreement__c sA = [SELECT Stock_Reservation__r.Opportunity__r.Account__c, AcknowledgementPersonalData__c, Salutation__c,
                                            FirstName__c, Surname__c, Customer_Full_Name__c, NRIC_Number__c, MobileSA__c, Date_Of_Birth__c,
                                            Postal_CodeRA__c, Street_NameRA__c, Building_NameRA__c, Floor_UnitRA__c
                                     FROM Sales_Agreement__c 
                                     WHERE Id =: salesAgreementId LIMIT 1];

            String addLine4 = String.isNotBlank(sA.Postal_CodeRA__c) ? 'Singapore ' + sA.Postal_CodeRA__c : '';

            AccountUtil.PAWrapper pAWrapper = new AccountUtil.PAWrapper(sA.Salutation__c, sA.FirstName__c, sA.Surname__c, sA.Customer_Full_Name__c, sA.NRIC_Number__c, sA.MobileSA__c, sA.Date_Of_Birth__c,
                                                                        sA.Street_NameRA__c, sA.Floor_UnitRA__c, sA.Building_NameRA__c, addLine4, null, 'Singapore', 
                                                                        sA.AcknowledgementPersonalData__c, null, 'Customer', null, null, 'DWH');
    
            AccountUtil.updatePA(paWrapper, sA.Stock_Reservation__r.Opportunity__r.Account__c);
        }
        catch (Exception e)
        {
            System.debug('Update PA From Docusign Button: ' + e.getMessage());
            loggerDataPool.buildLogDataPool('MFUpdatePA', e);
        }
    }
    /** ADDED BY TPHAN ON 23/07/2021 - PA MERGING */

    // --------------------------- Start: This function is used for Defect Form ---------------------------
    // The purpose is just to get the list of records based on FieldValue, Object, FieldName, 'this is just an extra to trigger the search, can put it blank'
    /*
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRelatedRecords(String fieldReferenceValue, String objectName, String fieldName, Integer triggerSearch) {
        List<sObject> listofRecords = new List<sObject>();
        String mainQueryCondition = ' ' + fieldName + '=\'' + fieldReferenceValue + '\' ORDER BY Name' ;
        system.debug(mainQueryCondition);
        listofRecords = ADGLIB_UtilityHelper.getSObjectRecords(objectName, mainQueryCondition, false);
        return listofRecords;
    }
    */
    // --------------------------- End: This function is used for Defect Form ---------------------------

}