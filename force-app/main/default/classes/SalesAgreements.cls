public class SalesAgreements extends ADGLIB_SObjectDomain {
    
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();

    public class CalloutException extends Exception {}    
       
    public SalesAgreements(List<Sales_Agreement__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new SalesAgreements(sObjectList);
		}
	}

    public override void onApplyDefaults() {
        Set<ID> stockReservationIds = new Set<ID> ();
        //Start of RN2020Q1010 
        //Map<String, Id> modelAndPackageMap = new Map<String, Id>();
        Map<String, Package_Header__c> modelAndPackageMap = new Map<String, Package_Header__c>();
        //End of RN2020Q1010 

        Map<id, Stock_Reservation__c> stockReservationMap = new Map<id, Stock_Reservation__c>();
        Map<Id, List<Package_Accs__c>> pckAccMap  = new Map<Id, List<Package_Accs__c>>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();

        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>) Records) 
        {
            stockReservationIds.add(salesAgreement.Stock_Reservation__c);
        }

        stockReservationMap = SalesAgreementService.getStockReservationInformation(stockReservationIds);
        system.debug('SR INFO:' + stockReservationMap);
         //Start of RN2020Q1010 
         //modelAndPackageMap = SalesAgreementService.getPackageHeaderIdBasedOnModel(stockReservationMap.values());
         /*modelAndPackageMap = SalesAgreementService.getPackageHeadersBasedOnModel(stockReservationMap.values()); ---currently used---- */
        //End of RN2020Q1010 
           
        // Added by TPhan
        modelAndPackageMap = SalesAgreementService.getPackageHeaderBasedOnId(stockReservationMap.values());
        pckAccMap = SalesAgreementService.getPackageAcssByPackageHeader(modelAndPackageMap);

        for (Stock_Reservation__c sR : stockReservationMap.values())
        {
            oppIds.add(sR.Opportunity__c);
        }

        oppMap = SalesAgreementService.getOpportunitiesByIds(oppIds);
		// End
        
        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>) Records) {
          
            Stock_Reservation__c stockReservationRec = stockReservationMap.get(salesAgreement.Stock_Reservation__c);
            salesAgreement.uniqueIdentifier__c = salesAgreement.Stock_Reservation__c;
            salesAgreement.Stage__c = 'Draft';
            salesAgreement.Last_save_on_form__c = 'Customer';
            if(stockReservationRec.Registration_Type__c == 'C'){
                salesAgreement.Company_Name__c = stockReservationRec.Customer_Name__c;//stockReservationRec.tNRIC__c;
                salesAgreement.ARCA_Number__c = stockReservationRec.Customer_Social_ID__c;//stockReservationRec.tNRIC__c;

            }else{
                salesAgreement.NRIC_Number__c = stockReservationRec.Customer_Social_ID__c;//stockReservationRec.tNRIC__c;
                salesAgreement.Customer_Full_Name__c = stockReservationRec.Customer_Name__c;
            }
            salesAgreement.Registration_Type__c = stockReservationRec.Registration_Type__c;
            salesAgreement.SOH_RTM_REGTYPECD__c = stockReservationRec.Registration_Type__c;
            //salesAgreement.Service_Credit__c = 2000;
            salesAgreement.service_credit_effective_years__c = 2;

            salesAgreement.Opportunity__c =  stockReservationRec.Opportunity__c;
            salesAgreement.emailaddress__c = stockReservationRec.Customer_Email__c;
            salesAgreement.FirstName__c = stockReservationRec.Customer_First_Name__c;
            salesAgreement.Surname__c= stockReservationRec.Customer_Last_Name__c;

            if (stockReservationRec.Customer_Mobile_Number__c != null) {
                if (stockReservationRec.Customer_Mobile_Number__c.left(2) != '65') {
                    salesAgreement.MobileSA__c = '65' + stockReservationRec.Customer_Mobile_Number__c;
                } else {
                    salesAgreement.MobileSA__c = stockReservationRec.Customer_Mobile_Number__c;
                }
            }
            
            salesAgreement.Date_Of_Birth__c = stockReservationRec.Birthdate__c;
            //Start of RN2020Q1010 
            //salesAgreement.Package_Header__c = modelAndPackageMap.get(stockReservationRec.Model_Code__c);
            salesAgreement.Package_Header__c = modelAndPackageMap.get(stockReservationRec.Model_Code__c).Id == null ? '' : modelAndPackageMap.get(stockReservationRec.Model_Code__c).Id;           
            salesAgreement.Package_List_Price__c = modelAndPackageMap.get(stockReservationRec.Model_Code__c).PKH_PKGPRICE__c;
            salesAgreement.Package_List_Price_TimeStamp__c = DateTime.now();
            //End of RN2020Q1010 
            
            salesAgreement.Marital_Status__c = stockReservationRec.MaritalStatus__c;
            salesAgreement.Gender__c = stockReservationRec.Gender__c; 
            //salesAgreement.Salutation__c = stockReservationRec.Salutation__c; //Disabled this due to unclean data from stock reservation
            salesAgreement.Branch_Code__c = stockReservationRec.Branch_Code__c;
            salesAgreement.Number_of_COE_Bids__c = '6';
            salesAgreement.PurchasewithCOE__c = 'Yes';
            salesAgreement.Registration_Number_Type__c = 'Normal';
            salesAgreement.COE_Package__c = 'Non-Guaranteed COE';
            salesAgreement.Service_Credit__c = 0;
			salesAgreement.Accessories_Credit__c = 0;   
            salesAgreement.Package_Service_Credit__c = 0;
            salesAgreement.Package_Accessories_Credit__c = 0;

            // Added on 27/07/2021 - My C&C IDP Revamp by TPhan
            salesAgreement.Account__c = oppMap.get(stockReservationRec.Opportunity__c).Account__c;
            salesAgreement.Contact__c = oppMap.get(stockReservationRec.Opportunity__c).Contact_Person__c;
            // END
            
            if (!pckAccMap.isEmpty()) {
                for (Package_Accs__c rec : pckAccMap.get(salesAgreement.Package_Header__c)) {
                    if (rec.Accessories_Master__r.ACM_ACCSCD__c.contains('SVC')) {     
                        salesAgreement.Service_Credit__c = rec.PKA_VALUE__c;
                        salesAgreement.Package_Service_Credit__c = rec.PKA_VALUE__c;
                    } else if (rec.Accessories_Master__r.ACM_ACCSCD__c.contains('ACC')) {
						 salesAgreement.Accessories_Credit__c = rec.PKA_VALUE__c;
                         salesAgreement.Package_Accessories_Credit__c = rec.PKA_VALUE__c;
                    }
                }
            }
        }
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> previousMap) {
        for(Sales_Agreement__c record : (List<Sales_Agreement__c>) records) {
            SalesAgreementService.processOffPeakCar((Sales_Agreement__c) previousMap.get(record.Id), record);
            SalesAgreementService.processCalculation((Sales_Agreement__c) previousMap.get(record.Id), record);
            // Added on 07/03/2021
            // Check duplicate COE lookup field
            /*Sales_Agreement__c oldSA = (Sales_Agreement__c)previousMap.get(record.Id);
            if (record.COE__c != oldSA.COE__c) {
                record.COE_Unique_ID__c = record.COE__c;
            }*/
        }

        try {
            notifyBAM(previousMap);                     // add on 25 Aug 2020 [PHAP]
        } catch (Exception e) {
            loggerDataPool.buildLogDataPool('notifyBAM_OtherError', e);
        }
        
    }

    
    public override void onAfterInsert() {
        
        defaultAccessoriesRelatedList(null);
        updateStockReservationVehicleMaster(null);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        defaultAccessoriesRelatedList(existingRecords);
        updateStockReservationVehicleMaster(existingRecords);
        setVSMSKeyOfAdditionalCharges(existingRecords);
        createCOESAAcc(existingRecords);
        createGMSSAAcc(existingRecords);
        createSVCSAAcc(existingRecords);
        createACCSAAcc(existingRecords);
        //updateVsmsSOStatus(existingRecords);

        // Added on 08/03/2021
        // If there's a change on COE lookup field
        // Then find correposding COE to update to be de-linked to SA
        // updateCOEToSA(existingRecords);

        // Added on 07/06/2021 - My C&C IDP Revamp by TPhan
        createUser(existingRecords);
        
        //Added on 13/07/2021 - DeliveryBay [Thang]
        updateDeliveryBayBooking(existingRecords);
        sendEmailForBookingDeliveryBaySlot(existingRecords);
        createVehicleMovementTracker(existingRecords); //Added on 24/08/2021

        //Added on 30/07/2021 [Vu] - Convert Prospect PA to Customer when Car Collected
        convertPA(existingRecords);
    }
    
    private void updateStockReservationVehicleMaster(Map<Id, SObject> existingRecords) {
        Map<Id, String> commcaseNoByStockReservationId = new Map<Id, String>();
        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {
            if(salesAgreement.Stock_Reservation__c == null) {
                continue;
            }
            
            if(existingRecords != null) {
                Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
                if(salesAgreement.CommcaseNo__c != oldSalesAgreement.CommcaseNo__c ||
                   salesAgreement.Stock_Reservation__c != oldSalesAgreement.Stock_Reservation__c)
                {  
                    commcaseNoByStockReservationId.put(salesAgreement.Stock_Reservation__c, salesAgreement.CommcaseNo__c);
                }
            } else {
                commcaseNoByStockReservationId.put(salesAgreement.Stock_Reservation__c, salesAgreement.CommcaseNo__c);
            }
        }
   
        CommcaseService.updateVehicleMaster(commcaseNoByStockReservationId);
    }

    private void defaultAccessoriesRelatedList(Map<Id,SObject> existingRecords){
        Map<Id, Id> changedPackageHeader = SalesAgreementService.findPackagesBasedOnSalesAgreement(existingRecords, Records);
        if(changedPackageHeader.isEmpty()){
            return; //Nothing to process
        }

        this.upsertRelatedAccessories(changedPackageHeader, existingRecords);
    }
    
    private void upsertRelatedAccessories(Map<Id, Id> salesAgreementAndPackageIdMap, Map<Id,SObject> existingRecords){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {SA_Accessory__c.SObjectType,
                                                                                              SA_Additional_Charge__c.SObjectType,
            																				  Sales_Agreement__c.SObjectType});

        Map<Id, List<SA_Accessory__c>> saAccsToBeDeleted = SalesAgreementService.retrieveDeleteAccessories(salesAgreementAndPackageIdMap);
        Map<Id, List<SA_Additional_Charge__c>> saAddnlChargeToBeDeleted = SalesAgreementService.retrieveDeleteAdditionCharges(salesAgreementAndPackageIdMap);
        Map<Id, List<Package_Accs__c>> pckAccMap = SalesAgreementService.retrieveNewAccessories(salesAgreementAndPackageIdMap);
        Map<Id, List<Package_Additional_Charges__c>> pckAddnlChargeMap  = SalesAgreementService.retrieveNewAdditionalCharges(salesAgreementAndPackageIdMap);
        Additional_Charges_Master__c  roadTax1year = new AdditionalChargesMasterSelector().selectBasedOnChargeCode(new LIST<String>{'R004'})[0];
        
        //Processing insert and delete of package accessories
        //Processing DML
        for (Id recordId : salesAgreementAndPackageIdMap.keySet()) {
            if (!saAccsToBeDeleted.isEmpty()) {
                uow.registerDeleted(saAccsToBeDeleted.get(recordId));
            }

            if (!saAddnlChargeToBeDeleted.isEmpty()) {
                uow.registerDeleted(saAddnlChargeToBeDeleted.get(recordId));
            }
            
            if (!pckAccMap.isEmpty()) {
                for (Package_Accs__c rec : pckAccMap.get(salesAgreementAndPackageIdMap.get(recordId))) {
                    uow.registerNew(new SA_Accessory__c(Sales_Agreement__c = recordId,
                                    Accessories_Master__c = rec.Accessories_Master__c,
                                    SAC_PACKAGE__c = 'Y',
                                    SAC_INCPRICE__c = rec.PKA_INCPRICE__c,
                                    DisplayOrder__c = rec.DisplayOrder__c,
                                    SAC_PACKAGE_TRADE_REBATE__c = rec.PKA_REBATE__c,
                                    PKA_VALUE__c = rec.PKA_VALUE__c));
                }
            }

            if (!pckAddnlChargeMap.isEmpty()) {
                
                system.debug('PackageSize '+ pckAddnlChargeMap.get(salesAgreementAndPackageIdMap.get(recordId)).size());
                for (Package_Additional_Charges__c rec : pckAddnlChargeMap.get(salesAgreementAndPackageIdMap.get(recordId))) {
                    
                    String isIncludedInPackage = rec.PKC_INCPRICE__c == 'INC' ? 'Y' : 'N';

                    uow.registerNew(new SA_Additional_Charge__c(Sales_Agreement__c = recordId,
                                                                AdditionalChargesMaster__c = rec.Additional_Charges_Master__c,
                                                                SAD_PACKAGE__c = isIncludedInPackage,
                                                                SAD_INCPRICE__c = rec.PKC_INCPRICE__c,
                                                                SAD_CHARGES__c = rec.PKC_CHARGES__c));

                                                                //DisplayOrder__c = getDisplaySequence(rec.PKC_ADM_CHRGCD__c)));
                    if(rec.PKC_ADM_CHRGCD__c == 'R002'){
                         uow.registerNew(new SA_Additional_Charge__c(Sales_Agreement__c = recordId,
                                                                AdditionalChargesMaster__c = roadTax1year.Id,
                                                                SAD_PACKAGE__c = 'N',
                                                                //SAD_INCPRICE__c = rec.PKC_INCPRICE__c,
                                                                SAD_CHARGES__c = rec.PKC_CHARGES__c * 2));
                                                                //DisplayOrder__c = getDisplaySequence(rec.PKC_ADM_CHRGCD__c)));
                    }
                }
            }
        }
        uow.commitWork();
    }
    
    private void setVSMSKeyOfAdditionalCharges(Map<Id, SObject> existingRecords) {
        Set<Id> changedAgreementIds = new Set<Id>();
        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {
            Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
            if(String.isBlank(oldSalesAgreement.SOH_SONO__c) && String.isNotBlank(salesAgreement.SOH_SONO__c)) {
                changedAgreementIds.add(salesAgreement.Id);
            }
        }
        
        List<SA_Additional_Charge__c> additionalCharges = new SaAddnlChargeSelector().selectAddnlChargeBySalesAgreementIds(changedAgreementIds);
        new SAAdditionalCharges(additionalCharges).setVSMSCompoundPrimaryKey();
    }    
    
    private void createCOESAAcc (Map<Id, SObject> existingRecords) {
        SA_Accessory__c rcdToCreate;
        SA_Accessory__c rcdToDelete = new SA_Accessory__c();

        for (Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {
            Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
            // From blank to having some value
            if (salesAgreement.COE_Refund__c != null && salesAgreement.COE_Refund__c != 0 && oldSalesAgreement.COE_Refund__c == null) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.COE_Refund__c;
                rcdToCreate.Acc_Code_Trigger__c = 'COE' + String.valueOf(Math.abs(salesAgreement.COE_Refund__c));
                insert rcdToCreate;

                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }       
            }
            // From having some value to blank
            if (salesAgreement.COE_Refund__c == null && oldSalesAgreement.COE_Refund__c != null && oldSalesAgreement.COE_Refund__c != 0) {
                String accCode = 'COE' + String.valueOf(Math.abs(oldSalesAgreement.COE_Refund__c));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From having some value to 0
            if (salesAgreement.COE_Refund__c == 0 && oldSalesAgreement.COE_Refund__c != null && oldSalesAgreement.COE_Refund__c != 0) {
                String accCode = 'COE' + String.valueOf(Math.abs(oldSalesAgreement.COE_Refund__c));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From 0 to having some value
            if (salesAgreement.COE_Refund__c != 0 && salesAgreement.COE_Refund__c != null && oldSalesAgreement.COE_Refund__c == 0) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.COE_Refund__c;
                rcdToCreate.Acc_Code_Trigger__c = 'COE' + String.valueOf(Math.abs(salesAgreement.COE_Refund__c));       
                insert rcdToCreate;
                
                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }
            }
            // From one value to another value
            if (salesAgreement.COE_Refund__c != null && salesAgreement.COE_Refund__c != 0 && salesAgreement.COE_Refund__c != oldSalesAgreement.COE_Refund__c && oldSalesAgreement.COE_Refund__c != 0 && oldSalesAgreement.COE_Refund__c != null ) {
                String accCode = 'COE' + String.valueOf(Math.abs(oldSalesAgreement.COE_Refund__c));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);              
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                } 
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
                
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.COE_Refund__c;
                rcdToCreate.Acc_Code_Trigger__c = 'COE' + String.valueOf(Math.abs(salesAgreement.COE_Refund__c));
                insert rcdToCreate;   

                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }  
            }
        }  
    }
    
    private void createGMSSAAcc (Map<Id, SObject> existingRecords) {
        SA_Accessory__c rcdToCreate;
        SA_Accessory__c rcdToDelete = new SA_Accessory__c();

        for (Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {
            Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
            // From blank to having some value
            if (salesAgreement.GMS_Package__c != null && salesAgreement.GMS_Package__c != 0 && oldSalesAgreement.GMS_Package__c == null) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.GMS_Package__c;
                rcdToCreate.Acc_Code_Trigger__c = 'GMS' + String.valueOf(Math.abs(salesAgreement.GMS_Package__c));
                insert rcdToCreate;

                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }       
            }
            // From having some value to blank
            if (salesAgreement.GMS_Package__c == null && oldSalesAgreement.GMS_Package__c != null && oldSalesAgreement.GMS_Package__c != 0) {
                String accCode = 'GMS' + String.valueOf(Math.abs(oldSalesAgreement.GMS_Package__c));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From one value to another value
            if (salesAgreement.GMS_Package__c != null && salesAgreement.GMS_Package__c != 0 && salesAgreement.GMS_Package__c != oldSalesAgreement.GMS_Package__c && oldSalesAgreement.GMS_Package__c != 0 && oldSalesAgreement.GMS_Package__c != null) {
                String accCode = 'GMS' + String.valueOf(Math.abs(oldSalesAgreement.GMS_Package__c));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);              
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                } 
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
                
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.GMS_Package__c;
                rcdToCreate.Acc_Code_Trigger__c = 'GMS' + String.valueOf(Math.abs(salesAgreement.GMS_Package__c));
                insert rcdToCreate;   

                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }  
            }
            // From having some value to 0
            if (salesAgreement.GMS_Package__c == 0 && oldSalesAgreement.GMS_Package__c != null && oldSalesAgreement.GMS_Package__c != 0) {
                String accCode = 'GMS' + String.valueOf(Math.abs(oldSalesAgreement.GMS_Package__c));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From 0 to having some value
            if (salesAgreement.GMS_Package__c != 0 && salesAgreement.GMS_Package__c != null && oldSalesAgreement.GMS_Package__c == 0) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.GMS_Package__c;
                rcdToCreate.Acc_Code_Trigger__c = 'GMS' + String.valueOf(Math.abs(salesAgreement.GMS_Package__c));       
                insert rcdToCreate;
                
                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }
            }                    
        }  
    }
    
    private void createSVCSAAcc (Map<Id, SObject> existingRecords) {
        SA_Accessory__c rcdToCreate;
        SA_Accessory__c rcdToDelete = new SA_Accessory__c();
        
        for (Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>) Records) {
            Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
            // From blank to having some value
            if (salesAgreement.Service_Credit__c != null && salesAgreement.Service_Credit__c != 0 && oldSalesAgreement.Service_Credit__c == null) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.Service_Credit__c;
                //rcdToCreate.SAC_PACKAGE__c = 'Y';
                rcdToCreate.Acc_Code_Trigger__c = 'SVC' + String.valueOf(Math.round(Math.abs(salesAgreement.Service_Credit__c)));
                insert rcdToCreate;

                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }       
            }
            // From having some value to blank
            if (salesAgreement.Service_Credit__c == null && oldSalesAgreement.Service_Credit__c != null && oldSalesAgreement.Service_Credit__c != 0) {
                String accCode = 'SVC' + String.valueOf(Math.round(Math.abs(oldSalesAgreement.Service_Credit__c)));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From one value to another value
            if (salesAgreement.Service_Credit__c != null && salesAgreement.Service_Credit__c != 0 && salesAgreement.Service_Credit__c != oldSalesAgreement.Service_Credit__c && oldSalesAgreement.Service_Credit__c != 0 && oldSalesAgreement.Service_Credit__c != null ) {
                String accCode = 'SVC' + String.valueOf(Math.round(Math.abs(oldSalesAgreement.Service_Credit__c)));
                System.debug('TEST BUG: ' + accCode);
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);              
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                } 
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
                
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.Service_Credit__c;
                //rcdToCreate.SAC_PACKAGE__c = 'Y';
                rcdToCreate.Acc_Code_Trigger__c = 'SVC' + String.valueOf(Math.round(Math.abs(salesAgreement.Service_Credit__c)));
                insert rcdToCreate;   

                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }  
            }
            // From having some value to 0
            if (salesAgreement.Service_Credit__c == 0 && oldSalesAgreement.Service_Credit__c != null && oldSalesAgreement.Service_Credit__c != 0) {
                String accCode = 'SVC' + String.valueOf(Math.round(Math.abs(oldSalesAgreement.Service_Credit__c)));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From 0 to having some value
            if (salesAgreement.Service_Credit__c != 0 && salesAgreement.Service_Credit__c != null && oldSalesAgreement.Service_Credit__c == 0) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.Service_Credit__c;
                //rcdToCreate.SAC_PACKAGE__c = 'Y';
                rcdToCreate.Acc_Code_Trigger__c = 'SVC' + String.valueOf(Math.round(Math.abs(salesAgreement.Service_Credit__c))); 
                insert rcdToCreate;
                
                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }
            } 
            
        }  
    }
    
    private void createACCSAAcc (Map<Id, SObject> existingRecords) {
        SA_Accessory__c rcdToCreate;
        SA_Accessory__c rcdToDelete = new SA_Accessory__c();
        
        for (Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>) Records) {
            Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
            // From blank to having some value
            if (salesAgreement.Accessories_Credit__c != null && salesAgreement.Accessories_Credit__c != 0 && oldSalesAgreement.Accessories_Credit__c == null) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.Accessories_Credit__c;
                //rcdToCreate.SAC_PACKAGE__c = 'Y';
                rcdToCreate.Acc_Code_Trigger__c = 'ACC' + String.valueOf(Math.round(Math.abs(salesAgreement.Accessories_Credit__c)));
                insert rcdToCreate;
                
                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }       
            }
            // From having some value to blank
            if (salesAgreement.Accessories_Credit__c == null && oldSalesAgreement.Accessories_Credit__c != null && oldSalesAgreement.Accessories_Credit__c != 0) {
                String accCode = 'ACC' + String.valueOf(Math.round(Math.abs(oldSalesAgreement.Accessories_Credit__c)));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From one value to another value
            if (salesAgreement.Accessories_Credit__c != null && salesAgreement.Accessories_Credit__c != 0 && salesAgreement.Accessories_Credit__c != oldSalesAgreement.Accessories_Credit__c && oldSalesAgreement.Accessories_Credit__c != 0 && oldSalesAgreement.Accessories_Credit__c != null ) {
                String accCode = 'ACC' + String.valueOf(Math.round(Math.abs(oldSalesAgreement.Accessories_Credit__c)));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);              
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                } 
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
                
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.Accessories_Credit__c;
                //rcdToCreate.SAC_PACKAGE__c = 'Y';
                rcdToCreate.Acc_Code_Trigger__c = 'ACC' + String.valueOf(Math.round(Math.abs(salesAgreement.Accessories_Credit__c)));
                insert rcdToCreate;   
                
                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }  
            }
            // From having some value to 0
            if (salesAgreement.Accessories_Credit__c == 0 && oldSalesAgreement.Accessories_Credit__c != null && oldSalesAgreement.Accessories_Credit__c != 0) {
                String accCode = 'ACC' + String.valueOf(Math.round(Math.abs(oldSalesAgreement.Accessories_Credit__c)));
                rcdToDelete = SalesAgreementService.getSaAccsBySaIdandAccCode(oldSalesAgreement.Id, accCode);
                if (rcdToDelete != null) {
                    delete rcdToDelete;
                }
                if (salesAgreement.SOH_SONO__c != null && rcdToDelete != null) {
                    VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc(rcdToDelete.Sales_Agreement__r.UniqueBranchCode__c, rcdToDelete.Sales_Agreement__r.FranchiseCode__c, rcdToDelete.SAD_SOH_SONO__c, String.valueOf(rcdToDelete.SAC_LINENO__c));
                }
            }
            // From 0 to having some value
            if (salesAgreement.Accessories_Credit__c != 0 && salesAgreement.Accessories_Credit__c != null && oldSalesAgreement.Accessories_Credit__c == 0) {
                rcdToCreate = new SA_Accessory__c();
                rcdToCreate.Sales_Agreement__c = salesAgreement.Id;
                rcdToCreate.Price_Trigger__c = salesAgreement.Accessories_Credit__c;
                //rcdToCreate.SAC_PACKAGE__c = 'Y';
                rcdToCreate.Acc_Code_Trigger__c = 'ACC' +  String.valueOf(Math.round(Math.abs(salesAgreement.Accessories_Credit__c)));       
                insert rcdToCreate;
                
                if (salesAgreement.Stage__c != 'Draft') {
                    VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c, rcdToCreate.Acc_Code_Trigger__c, salesAgreement.UniqueBranchCode__c);
                }
            }               
        }  
    }
    
    //This method is used to update SO_STATUS in VSMS when Approval Status is Approved
    // comment out and move to Envelope Status trigger
    // private void updateVsmsSOStatus (Map<Id, SObject> existingRecords) {  
    //     for (Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>) Records) {
    //         Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
    //         if (salesAgreement.ApprovalStatus__c == 'Approved' && oldSalesAgreement.ApprovalStatus__c == 'Not Approved') {
    //             VSMS_CallOutToUpdateStatus.callOutToUpdateStatus(salesAgreement.Id);
    //         }
    //     }
    // }
    
/*
    private Decimal getDisplaySequence(String chargeCode){
        Decimal sequenceNo; //The current data model is using double. hence it flows
        if(chargeCode == '1000'){
            sequenceNo = 10;
        }else if(chargeCode == 'R001'){
            sequenceNo = 20;
        }else if(chargeCode == 'C001'){
            sequenceNo = 30;
        }else if(chargeCode == 'C002'){
            sequenceNo = 40;
        }else if(chargeCode == 'R015'){
            sequenceNo = 50;
        }else if(chargeCode == 'R002'){
            sequenceNo = 60;
        }else if(chargeCode == 'R004'){
            sequenceNo = 70;
        }
        return sequenceNo;
    }
*/

    //This method is used on additional SA_Addtional_Charges trigger. 
    public static void updateSalesAgreementTotalFees (Set<Id> salesAgreementId){ //Field to be updated Total_VES_Roadtax_and_fees__c and SA_Vehicle_Purchase_Price__c
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType});
        SalesAgreementSelector salesAgreementSel = new SalesAgreementSelector();

        for(Sales_Agreement__c rec : salesAgreementSel.selectByIdWithAdditionalCharges(salesAgreementId)){ 
                Decimal newTotalVESRoadtaxfees = 0;
                Decimal roadTax6months = 0;
                
                system.debug(rec.SA_Additional_Charges__r.size());
                for(SA_Additional_Charge__c childRec : rec.SA_Additional_Charges__r){
                    //Capture the 6months road value
                    if(childRec.SAD_ADM_CHRGCD__c == 'R002'){
                        roadTax6months = childRec.SAD_CHARGES__c;
                    }
                    //No calcuation required for inclusive. Roadtax 6 or 12 months will be calculated based on top up flag on sales agreement
                    if(childRec.SAD_INCPRICE__c == 'INC' || childRec.SAD_ADM_CHRGCD__c == 'R002' || childRec.SAD_ADM_CHRGCD__c == 'R004'){
                        continue;
                    }
                    //Sum up the values
                    newTotalVESRoadtaxfees += childRec.SAD_CHARGES__c;
                    system.debug('newTotalVESRoadtaxfees ' +newTotalVESRoadtaxfees);
                }

                //If roadtax is upgraded, it is multiply by 2 based on existing business logic
                newTotalVESRoadtaxfees = rec.Road_Tax_Top_Up__c == true ? (newTotalVESRoadtaxfees + (roadTax6months * 2)) : newTotalVESRoadtaxfees;
                system.debug('newTotalVESRoadtaxfeesWithRoadTaxUpgrade:  ' +newTotalVESRoadtaxfees);

                if(rec.Total_VES_Roadtax_and_fees__c <> newTotalVESRoadtaxfees){
                    //Update the new calculated values
                    decimal newTotalVehPurchasePrice = (rec.Vehicle_Purchase_Price__c - rec.Total_VES_Roadtax_and_fees__c) + newTotalVESRoadtaxfees;
                    uow.registerDirty(new Sales_Agreement__c (Id = rec.Id, 
                                                            Total_VES_Roadtax_and_fees__c = newTotalVESRoadtaxfees,
                                                            Vehicle_Purchase_Price__c = newTotalVehPurchasePrice));
                     system.debug('SalesAgreementToBeUpdated:  ' + rec.Id);                                       
                }
        }

        uow.commitWork();
    }

    /**
     * Email in-house financing BAM when BPE checkbox FIRST check
     */
    private void notifyBAM(Map<Id, SObject> existingRecords) {

        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();            // list of emails to be sent now
        List<Sales_Agreement__c> scheduleRecords = new List<Sales_Agreement__c>();                          // list of records to be scheduled *DEPRECIATED*
        EmailTemplate template = EmailNotificationsService.getTemplate('Finance_Email');                    // email template
        Set<ID> processedIDs = new Set<ID>();                                                               // store ID of processed records
        Set<String> otherErrors = new Set<String>();                                                        // store info of error records beside sending error
        
        List<Sales_Agreement__c> bpeChangedRecords = (List<Sales_Agreement__c>) getChangedRecords(new Set<String> { 'Balance_Payment_Email__c' });
        log('bpeChangedRecords', bpeChangedRecords, true);

        for (Sales_Agreement__c record : bpeChangedRecords) {

            try {
                if (record.EngineNo__c ==  null || record.Chassis_No__c == null) continue;                  // dont send empty Engine/Chassis No
                if (!record.Finance_Company_In_House__c) continue;                                          // dont send to non-inhouse BAM
                if (record.Finance_Company_Lookup__c == null) continue;                                     // dont send if have no financing company
                
                if (!record.Balance_Payment_Email__c || record.Emailed_BAM__c) {                            
                    continue;
                } else {
                    Messaging.SingleEmailMessage email = EmailNotificationsService.renderFinanceEmail(record, template.Id);     // render template
                    if (email == null) continue;
                    allEmails.add(email);                                                                   // add to emailing list                                                                        
                    processedIDs.add(record.ID);                                                            // store ID of processed records
                    record.Emailed_BAM__c = true;                                                           // update the checkbox
                }
            } catch (Exception e) {                                                                         // fail silent to make sure the rest of triggered record still process
                System.debug('Error on process bpeChangedRecords (record) :: ' + JSON.serialize(record));
                System.debug('Error on process bpeChangedRecords (message) :: ' + e.getMessage());
                System.debug('Error on process bpeChangedRecords (stack trace) :: ' + e.getStackTraceString());
                otherErrors.add('[bpeChangedRecords] ID :: ' + record.ID + ', message ::' + e.getMessage() + ', stack trace :: ' + e.getStackTraceString());
            }
        }
        
        // process the changing in Commcase No    
        // List<Sales_Agreement__c> commcaseChangedRecords = (List<Sales_Agreement__c>) getChangedRecords(new Set<String> { 'CommcaseNo__c' });
        // log('commcaseChangedRecords', commcaseChangedRecords , true);

        // for (Sales_Agreement__c record : commcaseChangedRecords) {
        //     try {
        //         if (record.EngineNo__c ==  null || record.Chassis_No__c == null) continue;                  // dont send empty Engine/Chassis No
        //         if (!record.Finance_Company_In_House__c) continue;                                          // dont send to non-inhouse BAM
        //         if (record.Finance_Company_Lookup__c == null) continue;                                     // dont send if have no financing company
        //         if (!record.Emailed_BAM__c) continue;                                                       // only send the update if FIRST email has been sent
        //         if (processedIDs.contains(record.ID)) continue;                                             // avoid sending duplicate record
        //         scheduleRecords.add(record);                                                                // add to schedule list
        //         processedIDs.add(record.ID);                                                                // add processed ID for logging
        //     } catch (Exception e) {                                                                         // fail silent to make sure the rest of triggered record still process
        //         System.debug('Error on process commcaseChangedRecords (record) :: ' + JSON.serialize(record));
        //         System.debug('Error on process commcaseChangedRecords (message) :: ' + e.getMessage());
        //         System.debug('Error on process commcaseChangedRecords (stack trace) :: ' + e.getStackTraceString());
        //         otherErrors.add('[commcaseChangedRecords] ID :: ' + record.ID + ', message ::' + e.getMessage() + ', stack trace :: ' + e.getStackTraceString());
        //     }
        // }

        log('processedIDs', processedIDs, true);
        // log('scheduleRecords', scheduleRecords, true);

        if (allEmails.size() > 0) {
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allEmails, false);

            Set<String> sendingErrors = new Set<String>();

            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    for (Messaging.SendEmailError e : result.getErrors()) {
                        sendingErrors.add(e.getMessage());
                    }
                }
            }

            if (sendingErrors.size() > 0) {
                try {
                    Logger_Data_Pool__c log = new Logger_Data_Pool__c();
                    log.Instance__c = 'notifyBAM_SendingError';
                    log.Message__c = JSON.serialize(sendingErrors) + ' <<<< |||| >>>> ' + JSON.serialize(processedIDs);
                    insert log;
                } catch (Exception e ) {
                    // fail silent
                }
                
            }
        }

        // if (scheduleRecords.size() > 0) {
        //     ScheduleSendFinanceEmail scheduleInstance = new ScheduleSendFinanceEmail(scheduleRecords);

        //     DateTime now = DateTime.now();
        //     String Seconds = '0';
        //     String Minutes = String.valueOf(now.minute() + 1);            // delay x minute(s)
        //     String Hours = String.valueOf(now.hour());
        //     String Day_of_month = String.valueOf(now.day());
        //     String Month = String.valueOf(now.month());
        //     String Day_of_week = '?';
        //     String optional_year = String.valueOf(now.year());
        //     String scheduleTime = Seconds + ' ' + Minutes + ' ' + Hours + ' ' + Day_of_month + ' ' + Month + ' ' + Day_of_week + ' ' + optional_year;
        //     String jobName = 'Send BAM Email_' + now.format();
        //     log('scheduleTime', scheduleTime, false);
        //     System.schedule(jobName, scheduleTime, scheduleInstance);
        // }

        if (otherErrors.size() > 0) {
            try {
                Logger_Data_Pool__c log2 = new Logger_Data_Pool__c();
                log2.Instance__c = 'notifyBAM_OtherError';
                log2.Message__c = JSON.serialize(otherErrors);
                insert log2;
            } catch (Exception e) {
                // fail silent
            }
        }
    }

    /**
     * This method to update corresponding COE to be de-linked back to SA
     */
    /*private void updateCOEToSA(Map<Id, sObject> existingRecords) {
        Map<Id, String> changedSAByCOEId = new Map<Id, String>();
        for (Sales_Agreement__c sa : (List<Sales_Agreement__c>)Records) {
            if (existingRecords.get(sa.Id).get('COE__c') != sa.COE__c) {
                changedSAByCOEId.put(sa.Id, sa.COE__c);
            }
        }

        if (changedSAByCOEId.isEmpty()) {
            return;
        }

        Map<Id, COE__c> coeById =  new Map<Id, COE__c>([SELECT Id, Sales_Agreement__c
                                                        FROM COE__c
                                                        WHERE Id IN :changedSAByCOEId.values()]);
        Map<Id, Sales_Agreement__c> sas = new Map<Id, Sales_Agreement__c>((List<Sales_Agreement__c>)Records);
        for (Id saId : changedSAByCOEId.keySet()) {
            Sales_Agreement__c sa = sas.get(saId);
            COE__c coe = coeById.get(sa.COE__c);
            if (coe != null) {
                coe.Sales_Agreement__c = sa.Id;
            }
        }
        Database.SaveResult[] srList = Database.update(coeById.values(), false);
        for (Integer i = 0; i < srList.size(); i++) {
            Id saId = coeById.values().get(i).Sales_Agreement__c;
            if (!srList[i].isSuccess()) {
                Sales_Agreement__c sa = sas.get(saId);
                String errorMsg = '';
                for (Database.Error err : srList[i].getErrors()) {
                    errorMsg += err.getMessage();
                    sa.addError(errorMsg);
                }
                // sa.addError('Current COE has been linked to this Sales Agreement. Please remove Sales Agreement from current COE and update again!');
            }
        }
    }*/

    /**
    * This method to check for existing User record and insert a new User if no existing one
    */
    private void createUser(Map<Id, SObject> existingRecords)
    {
        Map<String, Set<Id>> emailMap          = new Map<String, Set<Id>>();
        List<Sales_Agreement__c> updatedSAList = new List<Sales_Agreement__c>();
        List<User> newUsers                    = new List<User>();
        Set<String> emails                     = new Set<String>();
        Set<Id> userIds                        = new Set<Id>();

        for (Sales_Agreement__c newSA : (List<Sales_Agreement__c>) Records)
        {
            Sales_Agreement__c oldSA = (Sales_Agreement__c) existingRecords.get(newSA.Id);

            if (oldSA.Stage__c <> newSA.Stage__c && newSA.Stage__c == 'Confirmation of Sale')
            {
                emails.add(newSA.Email__c);
                
                Set<Id> tempIds;
                if (emailMap.containsKey(newSA.Email__c) && String.isNotBlank(newSA.Email__c))
                {
                    tempIds = emailMap.get(newSA.Email__c);
                    tempIds.add(newSA.Id);
                }
                else if (!emailMap.containsKey(newSA.Email__c) && String.isNotBlank(newSA.Email__c))
                {
                    tempIds = new Set<Id>{newSA.Id};  
                }   

                emailMap.put(newSA.Email__c, tempIds);    
            }
        }

        Map<Id, Sales_Agreement__c> newSAMap = new Map<Id, Sales_Agreement__c>((List<Sales_Agreement__c>)Records);

        if (!emails.isEmpty())
        {
            List<User> usersWithNoEmail = new List<User>();
            List<User> users            = [SELECT Id, Email, FirstName, LastName FROM User WHERE Email IN: emails AND Profile.Name = 'End User'];
           
            if (users.size() > 0)
            {
                for (User u : users)
                {
                    emails.remove(u.Email);
                    for(Id sAId : emailMap.get(u.Email))
                    {
                        Sales_Agreement__c tempSA = newSAMap.get(sAId);
                        if (!tempSA.New_Car_Added_Email_Sent__c)
                        {
                            usersWithNoEmail.add(u);
                            Sales_Agreement__c updatedSA = new Sales_Agreement__c(Id = sAId, New_Car_Added_Email_Sent__c = true);
                            updatedSAList.add(updatedSA);
                        }
                    }
                }

                if (usersWithNoEmail.size() > 0)
                {
                    IDPSignUpFormService.sendEmail(usersWithNoEmail, 'DSA_New_Car_Added_Notification');

                    if (updatedSAList.size() > 0)
                    {
                        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
                        update updatedSAList;
                        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
                    }
                }              
            }
        }

        if (!emails.isEmpty())
        {
            List<Account> accounts = AccountUtil.getPersonAccountsByEmails(emails);
            if (accounts.size() > 0)
            {
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];

                Map<String, Account> acctMap = new Map<String,Account>();
                User u;
                Account personAcct;

                for (Account a : accounts)
                {
                    acctMap.put(a.PersonEmail, a);
                }

                for (String email : emails)
                {
                    if (emailMap.containsKey(email))
                    {
                        for (Id saId : emailMap.get(email))
                        {
                            personAcct          = acctMap.get(email);
                            u                   = new User();
                            u.Username          = email;
                            u.Email             = email;
                            u.FirstName         = personAcct.FirstName;
                            u.LastName          = personAcct.LastName;
                            u.CommunityNickname = email;
                            u.Display_Name__c   = personAcct.FirstName + ' ' + personAcct.LastName;
                            u.ProfileId         = portalProfile.Id;
                            u.ContactId         = personAcct.PersonContactId;
                            u.TimeZoneSidKey    = 'Asia/Singapore';
                            u.LocaleSidKey      = 'en_US';
                            u.LanguageLocaleKey = 'en_US';
                            u.EmailEncodingKey  = 'UTF-8';
                            u.isValid__c        = true;

                            String alias        = String.isNotBlank(personAcct.FirstName) ? personAcct.FirstName.substring(0,1) + personAcct.LastName : personAcct.LastName;
                            u.Alias             = alias.length() > 8 ? alias.substring(0,8).toLowerCase() : alias.toLowerCase();
                            
                            newUsers.add(u);

                            Sales_Agreement__c updatedSA = new Sales_Agreement__c(Id = saId, New_Car_Added_Email_Sent__c = true);
                            updatedSAList.add(updatedSA);
                        }
                    }
                }            
            }    

            if (newUsers.size() > 0)
            {
                
                // This operation is only allowed from within an active site.     
                //String userId = Site.createExternalUser(newUsers[0], accounts[0].Id);
                
                Database.SaveResult[] results = Database.insert(newUsers, false);
                for(Database.SaveResult sr : results)
                {
                    if (sr.isSuccess()) 
                    {    
                        System.debug('Successfully inserted user. User ID: ' + sr.getId());
                        userIds.add(sr.getId());
                    }
                    else 
                    {             
                        for(Database.Error err : sr.getErrors())
                        {                
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }

            if (!userIds.isEmpty())
            {
                for (Id rcd : userIds)
                {
                    System.resetPasswordWithEmailTemplate(rcd, true, 'DSA_Account_Created_Notification');
                }

                if (updatedSAList.size() > 0)
                {
                    TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
                    update updatedSAList;
                    TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
                }
            }
        }
    }

    /**
    * This method to update DeliveryBayBooking when stage = 'Car Collected'
    */
    private void updateDeliveryBayBooking(Map<Id, SObject> existingRecords){  
        Set<Id> salesAgreements = new Set<Id>();
        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {
                Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
                if(salesAgreement.Stage__c != oldSalesAgreement.Stage__c && salesAgreement.Stage__c == 'Car Collected'){  
					salesAgreements.add(salesAgreement.Id);
                }
        }
        
        List<Delivery_Bay_Booking__c > dbbs = [Select Id, Status__c, Sales_Agreement__c from Delivery_Bay_Booking__c where Sales_Agreement__c IN: salesAgreements And Status__c ='Booked'];
        for(Delivery_Bay_Booking__c dbb: dbbs){
            dbb.Status__c = 'Completed';
        }
        if(!dbbs.isEmpty()){
            update dbbs;
        }
    }

    /**
    * This method to create Vehicle Movement Tracker when stage = 'Car Collected'
    */
    private void createVehicleMovementTracker(Map<Id, SObject> existingRecords){  
        Set<Id> salesAgreements = new Set<Id>();
        Set<Id> vehicleMasters = new Set<Id>();

        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {
            Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
            if(salesAgreement.Stage__c != oldSalesAgreement.Stage__c && salesAgreement.Stage__c == 'Car Collected'){  
                salesAgreements.add(salesAgreement.Id);
            }
        }

        for(Sales_Agreement__c newSA: [SELECT id, Stock_Reservation__r.Vehicle_Master__c from Sales_Agreement__c WHERE Id IN: salesAgreements]){
            vehicleMasters.add(newSA.Stock_Reservation__r.Vehicle_Master__c);
        }

        Delivery_Bay_Configuration__c dbbCf = Delivery_Bay_Configuration__c.getValues('Delivery Bay Booking Config');
        //get Location Delivery Complete from Custom Setting
        String nameLocation = '';
        if(dbbCf != Null){
            nameLocation = dbbCf.Location_Delivery_Complete__c;
        }
        if(String.isNotBlank(nameLocation) && !vehicleMasters.isEmpty()){
            
            List<Location__c> locations = [SELECT ID FROM Location__c Where Name = :nameLocation LIMIT 1];
            List<Vehicle_Movement_Tracker__c> vehicleMovementTrackers = new List<Vehicle_Movement_Tracker__c>();
            if(!locations.isEmpty()){
            for(Id vehicleMasterId: vehicleMasters){
                Vehicle_Movement_Tracker__c vmt = new Vehicle_Movement_Tracker__c(Stock_Vehicle_Master__c = vehicleMasterId, Location__c = locations[0].Id, Action_Taken_Time__c = System.now());
                vehicleMovementTrackers.add(vmt);
            }
            if(!vehicleMovementTrackers.isEmpty()){
                insert vehicleMovementTrackers;
            }
            }    
        }
    }

    
    /**
    * This method to send email to book DeliveryBay when stage = 'Ready for Delivery'
    */
    private void sendEmailForBookingDeliveryBaySlot(Map<Id, SObject> existingRecords){  
        Set<Id> salesAgreements = new Set<Id>();
        List<Delivery_Bay_Booking__c> dbbListToInsert = new List<Delivery_Bay_Booking__c> ();
        for(Sales_Agreement__c salesAgreement : (List<Sales_Agreement__c>)Records) {  
                Sales_Agreement__c oldSalesAgreement = (Sales_Agreement__c)existingRecords.get(salesAgreement.Id);
                if((salesAgreement.Stage__c != oldSalesAgreement.Stage__c && salesAgreement.Stage__c == 'Ready for Registration' && salesAgreement.Vehicle_Movement_Completed__c == true) ||
                   (salesAgreement.Stage__c == 'Ready for Registration' && salesAgreement.Vehicle_Movement_Completed__c == true && salesAgreement.Vehicle_Movement_Completed__c != oldSalesAgreement.Vehicle_Movement_Completed__c)){  
					salesAgreements.add(salesAgreement.Id);
                }
        }
        try {
            DeliveryBayBookings.sendingEmailForBookingNewSlot(salesAgreements, null);
        } catch (EmailException e) {
            loggerDataPool.buildLogDataPool('SalesAgreements.sendEmailForBookingDeliveryBaySlot', e);
        }
        
    }

    /**
     * This method to convert Prospect PA to Customer PA when Car Collected
     */
    private void convertPA(Map<Id, SObject> existingRecords) {
        Id prosRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        Set<Id> paIds = new Set<Id>();
        for (Sales_Agreement__c sa : (List<Sales_Agreement__c>)Records) {  
            Sales_Agreement__c oldSA = (Sales_Agreement__c)existingRecords.get(sa.Id);
            if (sa.Stage__c != oldSA.Stage__c && sa.Stage__c == 'Car Collected' && String.isNotBlank(sa.Account__c)) {
                paIds.add(sa.Account__c);
            }
        }

        if (paIds.size() == 0) return;

        // Get PA
        List<Account> pas = [ SELECT Id, PersonEmail, RecordTypeId, Type__pc
                              FROM Account 
                              WHERE IsPersonAccount = true 
                              AND Id IN :paIds ];
        for (Account pa : pas) {
            if (pa.RecordTypeId != prosRecTypeId) continue;

            pa.RecordTypeId = custRecTypeId;
            pa.Type__pc = 'Customer';
        }

        System.debug('-------- Begin Update PA --------- ' + pas);
        TriggerExclusion.excludeTrigger('Account', true);
        Database.update(pas, false);
        System.debug('-------- End Update PA --------- ');
    }

    /**
     * Safely log
     */
    private void log(String tag, Object value, Boolean stringify) {
        try {
            value = stringify? JSON.serialize(value) : value;
            System.debug(tag + ' :: ' + value);
        } catch (Exception e) {
            System.debug('Error Message on logging :: ' + e.getMessage());
            System.debug('Error Stack Trace on logging :: ' + e.getStackTraceString());
        }
    }
}