public class SalesAgreementSelector extends ADGLIB_SObjectSelector {


    public List<Schema.SObjectField> getSObjectFieldList() {
      //return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Sales_Agreement__c');
        return new List<Schema.SObjectField> {
            Sales_Agreement__c.SA_Accessories_Discount__c,
            Sales_Agreement__c.Accessories_Discount__c,
            Sales_Agreement__c.AcknowledgementAgreement__c,
            Sales_Agreement__c.AcknowledgementCOE__c,
            Sales_Agreement__c.AcknowledgementDeposits__c,
            Sales_Agreement__c.AcknowledgementInsurance__c,
            Sales_Agreement__c.AcknowledgementPersonalData__c,
            Sales_Agreement__c.AcknowledgementTradeIn__c,
            Sales_Agreement__c.AcknowledgementVehiclePrices__c,
            Sales_Agreement__c.AcknowledgementOffPeak__c,
            Sales_Agreement__c.Agreement_Date__c,
            Sales_Agreement__c.Amount_to_Finance__c,
            Sales_Agreement__c.SA_Amount_to_Finance__c,
            Sales_Agreement__c.ApprovalStatus__c,
            Sales_Agreement__c.ARCA_Number__c,
            Sales_Agreement__c.DocStatusAuthoriseLetter__c,
            Sales_Agreement__c.BalancePayment__c,
            Sales_Agreement__c.BankLoan__c,
            Sales_Agreement__c.Bid_Number__c,
            Sales_Agreement__c.Birthdate__c,
            Sales_Agreement__c.SOH_BRM_BRCD__c,
            Sales_Agreement__c.Branch_Code__c,
            Sales_Agreement__c.Building_NameMA__c,
            Sales_Agreement__c.Building_NameRA__c,
            Sales_Agreement__c.SOH_CANREMARKS__c,
            Sales_Agreement__c.SOH_CANCELDT__c,
            Sales_Agreement__c.Chassis_No__c,
            Sales_Agreement__c.COECategory__c,
            Sales_Agreement__c.COE_Charged_Rebate__c,
            Sales_Agreement__c.SA_COE_Charged_Rebate__c,
            Sales_Agreement__c.COE_Deposit__c,
            Sales_Agreement__c.SOH_COH_DOCNO__c,
            Sales_Agreement__c.COE_Package__c,
            Sales_Agreement__c.SA_COE_Refund__c,
            Sales_Agreement__c.COE_Refund__c,
            Sales_Agreement__c.SOH_COESUCCESSNOTIFY__c,
            Sales_Agreement__c.Color__c,
            Sales_Agreement__c.ColorCode__c,
            Sales_Agreement__c.SOH_COMMADJUST_REMARK__c,
            Sales_Agreement__c.SOH_COMMVERIFIEDBY__c,
            Sales_Agreement__c.SOH_COMMVERIFIEDDT__c,
            Sales_Agreement__c.SOH_COMMVERIFIEDFLG__c,
            Sales_Agreement__c.Original_Commcase_No__c,
            Sales_Agreement__c.CommcaseNo__c,
            Sales_Agreement__c.CompanyCode__c,
            Sales_Agreement__c.Company_Name__c,
            Sales_Agreement__c.Contact__c,
            Sales_Agreement__c.SOH_COSTTOFULCO__c,
            Sales_Agreement__c.DocStatusCoverNote__c,
            Sales_Agreement__c.SOH_CREATEDBY__c,
            Sales_Agreement__c.CreatedById,
            Sales_Agreement__c.SOH_CRNAMT__c,
            Sales_Agreement__c.SOH_CUM_CUSTCD__c,
            Sales_Agreement__c.CUM_REALFIRSTNAME__c,
            Sales_Agreement__c.CUM_FIRSTNAME__c,
            Sales_Agreement__c.Customer_Full_Name__c,
            Sales_Agreement__c.CUM_LASTNAME__c,
            Sales_Agreement__c.Customer_Purchased_COE__c,
            Sales_Agreement__c.SOH_CUSTRECDAMT__c,
            Sales_Agreement__c.Date_Of_Birth__c,
            Sales_Agreement__c.SOH_DEALERCOMM__c,
            Sales_Agreement__c.SOH_DEALERCOMMPAID__c,
            Sales_Agreement__c.SOH_DBNAMT__c,
            Sales_Agreement__c.DeliveryDate__c,
            Sales_Agreement__c.DeliveryFrom__c,
            Sales_Agreement__c.DeliveryTo__c,
            Sales_Agreement__c.Deposit__c,
            Sales_Agreement__c.DocuSign_Envelope_ID__c,
            Sales_Agreement__c.DownPayment__c,
            Sales_Agreement__c.DS_Model__c,
            Sales_Agreement__c.DSA_Registration_Number__c,
            Sales_Agreement__c.DSA_Version__c,
            Sales_Agreement__c.Email__c,
            Sales_Agreement__c.emailaddress__c,
            Sales_Agreement__c.SOH_EMM_CODE__c,
            Sales_Agreement__c.EngineNo__c,
            Sales_Agreement__c.Expected_Delivery_From__c,
            Sales_Agreement__c.Expected_Delivery_To__c,
            Sales_Agreement__c.SOH_EXPIRYMONTH__c,
            Sales_Agreement__c.Finance_Company__c,
            Sales_Agreement__c.Finance_Company_In_House__c,
            Sales_Agreement__c.Finance_Company_Lookup__c,
            Sales_Agreement__c.SOH_FINRECDAMT__c,
            Sales_Agreement__c.SFD_FIRSTINSTDT__c,
            Sales_Agreement__c.FirstName__c,
            Sales_Agreement__c.Floor_UnitMA__c,
            Sales_Agreement__c.Floor_UnitRA__c,
            Sales_Agreement__c.FranchiseCode__c,
            Sales_Agreement__c.Full_Settlement_Amount__c,
            Sales_Agreement__c.Gender__c,
            Sales_Agreement__c.SOH_GMT_PURAGGNO__c,
            Sales_Agreement__c.DocStatusGMSCreditNote__c,
            Sales_Agreement__c.DocStatusGMSDebitNote__c,
            Sales_Agreement__c.GMS_Package__c,
            Sales_Agreement__c.DocStatusGSTTaxInvoice__c,
            Sales_Agreement__c.Insurance_Company_In_House__c,
            Sales_Agreement__c.Insurance_Company_Lookup__c,
            Sales_Agreement__c.Insurance_Package__c,
            Sales_Agreement__c.InsurancePremiumConfirmed__c,
            Sales_Agreement__c.Insurance_Register_Vehicle__c,
            Sales_Agreement__c.SOH_INVDT__c,
            Sales_Agreement__c.SOH_INVNO__c,
            Sales_Agreement__c.isChangePackagePrice__c,
            Sales_Agreement__c.isSellerNotBuyer__c,
            Sales_Agreement__c.isUsedCarUnderCompany__c,
            Sales_Agreement__c.SOH_IUD_IUDOCNO__c,
            Sales_Agreement__c.SOH_CUSTPDDDT__c,
            Sales_Agreement__c.LastModifiedById,
            Sales_Agreement__c.Last_save_on_form__c,
            Sales_Agreement__c.SOH_LASTUPDBY__c,
            Sales_Agreement__c.SFD_LOANEXPDT__c,
            Sales_Agreement__c.Lock__c,
            Sales_Agreement__c.Marital_Status__c,
            Sales_Agreement__c.MobileSA__c,
            Sales_Agreement__c.Mobile__c,
            Sales_Agreement__c.Model__c,
            Sales_Agreement__c.ModelCode__c,
            Sales_Agreement__c.Model_Color_Trim__c,
            Sales_Agreement__c.ModelMajorGroupCode__c,
            Sales_Agreement__c.ModelYear__c,
            Sales_Agreement__c.Model_Year__c,
            Sales_Agreement__c.MonthlyInstalment__c,
            Sales_Agreement__c.SA_Monthly_Instalment__c,
            Sales_Agreement__c.NCD__c,
            Sales_Agreement__c.New_Insurance_Company__c,
            Sales_Agreement__c.NRIC__c,
            Sales_Agreement__c.NRIC_Number__c,
            Sales_Agreement__c.Number_of_COE_Bids__c,
            Sales_Agreement__c.Old_Insurance_Company__c,
            Sales_Agreement__c.Open_Category_CatE__c,
            Sales_Agreement__c.Open_Category_COE_Option__c,
            Sales_Agreement__c.Open_COE_Quota_Premium__c,
            Sales_Agreement__c.Opportunity__c,
            Sales_Agreement__c.Other_Finance__c,
            Sales_Agreement__c.OwnerId,
            Sales_Agreement__c.Package_Header__c,
            Sales_Agreement__c.Package_List_Price__c,
            Sales_Agreement__c.Package_List_Price_TimeStamp__c,
            Sales_Agreement__c.Payment__c,
            Sales_Agreement__c.Phone__c,
            Sales_Agreement__c.Postal_CodeMA__c,
            Sales_Agreement__c.Postal_CodeRA__c,
            Sales_Agreement__c.PreferredServiceCenter__c,
            Sales_Agreement__c.Premium_Payable__c,
            Sales_Agreement__c.SA_Premium_Payable__c,
            Sales_Agreement__c.PrivateHire__c,
            Sales_Agreement__c.SA_Promo_Discount__c,
            Sales_Agreement__c.Promo_Discount__c,
            Sales_Agreement__c.isPromotionVehicle__c,
            Sales_Agreement__c.DocStatusProofOfRelationship__c,
            Sales_Agreement__c.Default_Commission__c,
            Sales_Agreement__c.Proposed_Commission__c,
            Sales_Agreement__c.Proposed_Commission_Approval_Status__c,
            Sales_Agreement__c.Proposed_Commission_Reason__c,
            Sales_Agreement__c.PurchasewithCOE__c,
            Sales_Agreement__c.SOH_QP__c,
            Sales_Agreement__c.SOH_USQ_QUOTENO__c,
            Sales_Agreement__c.DocStatusRAPurchaseGST__c,
            Sales_Agreement__c.Rate_p_a__c,
            Sales_Agreement__c.SOH_READYFORPDINOTIFY__c,
            Sales_Agreement__c.SOH_RECDAMT__c,
            Sales_Agreement__c.SOH_RECDGSTAMT__c,
            Sales_Agreement__c.SOH_REFUNDAMT__c,
            Sales_Agreement__c.RegisteredVehicle__c,
            Sales_Agreement__c.RegistrationInstruction__c,
            Sales_Agreement__c.SOH_REGNO__c,
            Sales_Agreement__c.SOH_REGNOTYPE__c,
            Sales_Agreement__c.SOH_REGISTRATIONNOTIFY__c,
            Sales_Agreement__c.Registration_Number_Method__c,
            Sales_Agreement__c.Registration_Number_Type__c,
            Sales_Agreement__c.Registration_Type__c,
            Sales_Agreement__c.SOH_RTM_REGTYPECD__c,
            Sales_Agreement__c.DocStatusReleaseLetter__c,
            Sales_Agreement__c.Road_Tax_Top_Up__c,
            Sales_Agreement__c.SOH_SONO__c,
            Sales_Agreement__c.Sales_Consultant__c,
            Sales_Agreement__c.Salutation__c,
            Sales_Agreement__c.Secondary_Contact_No__c,
            Sales_Agreement__c.SOH_SECOMM__c,
            Sales_Agreement__c.SOH_SECOMMPAID__c,
            Sales_Agreement__c.Seller_Company_Name__c,
            Sales_Agreement__c.Seller_Email_Address__c,
            Sales_Agreement__c.Seller_First_Name__c,
            Sales_Agreement__c.Seller_Last_Name__c,
            Sales_Agreement__c.Seller_Mobile_Number__c,
            Sales_Agreement__c.ServiceCenterAddress__c,
            Sales_Agreement__c.ServiceCenterContact__c,
            Sales_Agreement__c.ServiceCenterDescription__c,
            Sales_Agreement__c.Service_Center_Email__c,
            Sales_Agreement__c.ServiceCenterPostalCode__c,
            Sales_Agreement__c.Service_Credit__c,
            Sales_Agreement__c.service_credit_effective_years__c,
            Sales_Agreement__c.Name,
            Sales_Agreement__c.SFD_STATUS__c,
            Sales_Agreement__c.SOH_STATUS__c,
            Sales_Agreement__c.Stage__c,
            //Sales_Agreement__c.StageBalancePayment__c,
            //Sales_Agreement__c.StageBankLoanApplication__c,
            Sales_Agreement__c.StageBooking__c,
            Sales_Agreement__c.StageCancelled__c,
            //Sales_Agreement__c.StageCarAllocation__c,
            Sales_Agreement__c.StageCarCollection__c,
            //Sales_Agreement__c.StageCOEBidding__c,
            //Sales_Agreement__c.StageFinanceInsurance__c,
            Sales_Agreement__c.StageReadyforRegistration__c,
            Sales_Agreement__c.StageReceipt__c,
            Sales_Agreement__c.Stock_Reservation__c,
            Sales_Agreement__c.Street_NameMA__c,
            Sales_Agreement__c.Street_NameRA__c,
            Sales_Agreement__c.SOH_SUCCESSMONTH__c,
            Sales_Agreement__c.Surname__c,
            Sales_Agreement__c.Term_Period__c,
            Sales_Agreement__c.Terms_months__c,
            Sales_Agreement__c.Terms_Years__c,
            Sales_Agreement__c.Total_Addon_Price__c,
            Sales_Agreement__c.Total_Discount_Price__c,
            Sales_Agreement__c.Total_VES_Roadtax_and_fees__c,
            Sales_Agreement__c.Trade_In_Used_Car_Registration_Number__c,
            Sales_Agreement__c.TradeInBalance__c,
            Sales_Agreement__c.SA_Trade_in_Value__c,
            Sales_Agreement__c.Trade_in_Value__c,
            Sales_Agreement__c.Trim__c,
            Sales_Agreement__c.TrimCode__c,
            Sales_Agreement__c.UniqueBranchCode__c,
            Sales_Agreement__c.uniqueIdentifier__c,
            Sales_Agreement__c.Unsigned_DSA_Id__c,
            Sales_Agreement__c.DocStatusUsedCarAGT__c,
            Sales_Agreement__c.SOH_USEDCARCOMM__c,
            Sales_Agreement__c.Used_Car_Make__c,
            Sales_Agreement__c.Used_Car_Registration_Number__c,
            Sales_Agreement__c.DocStatusUsedCarSettlementLetter__c,
            Sales_Agreement__c.Used_Car_Vehicle_Finance_Company__c,
            Sales_Agreement__c.User_Car_Model__c,
            Sales_Agreement__c.SOH_VEHALLOCDT__c,
            Sales_Agreement__c.DocStatusVehicleDeliveryCertificate__c,
            Sales_Agreement__c.Vehicle_Deposit__c,
            Sales_Agreement__c.SA_Vehicle_List_Price__c,
            Sales_Agreement__c.VehicleListPrice__c,
            Sales_Agreement__c.VehicleNumber__c,
            Sales_Agreement__c.SA_Vehicle_Purchase_Price__c,
            Sales_Agreement__c.Vehicle_Purchase_Price__c,
            Sales_Agreement__c.CreatedDate,
            Sales_Agreement__c.LastModifiedDate,
            Sales_Agreement__c.Accessories_Credit__c,
            Sales_Agreement__c.Package_Service_Credit__c,
            Sales_Agreement__c.Package_Accessories_Credit__c,
            Sales_Agreement__c.Owner_Username__c,
            //Sales_Agreement__c.Seller_Company_Address__c,
            //Sales_Agreement__c.Seller_Mailing_Address__c,
            Sales_Agreement__c.Seller_NRIC__c,
            Sales_Agreement__c.Seller_Company_UEN__c,
            Sales_Agreement__c.Seller_GST_Registration_No__c,
            Sales_Agreement__c.Seller_Date_Of_Birth__c,
            Sales_Agreement__c.Seller_Full_Name__c,
            Sales_Agreement__c.Seller_Street_Name__c,
            Sales_Agreement__c.Seller_Floor_Unit__c,
            Sales_Agreement__c.Seller_Building_Name__c,
            Sales_Agreement__c.Seller_Postal_Code__c,
            Sales_Agreement__c.Seller_Account_No__c,
            Sales_Agreement__c.Vehicle_Condition__c,
            Sales_Agreement__c.Vehicle_Mileage__c,
            Sales_Agreement__c.Vehicle_Location__c,
            Sales_Agreement__c.Customer_Type__c,
            Sales_Agreement__c.Seller_Type__c, 
            Sales_Agreement__c.Bid_1_Amount__c,
            Sales_Agreement__c.Bid_2_Amount__c,
            Sales_Agreement__c.Bid_3_Amount__c, 
            Sales_Agreement__c.Bid_4_Amount__c, 
            Sales_Agreement__c.Bid_5_Amount__c, 
            Sales_Agreement__c.Bid_6_Amount__c,
            Sales_Agreement__c.Bid_7_Amount__c,
            Sales_Agreement__c.Bid_8_Amount__c,
            Sales_Agreement__c.Bid_9_Amount__c,
            Sales_Agreement__c.Bid_10_Amount__c,
            Sales_Agreement__c.Bid_11_Amount__c,
            Sales_Agreement__c.Bid_12_Amount__c,
            Sales_Agreement__c.Bid_Price__c,
            Sales_Agreement__c.COEThresHold__c, 
            Sales_Agreement__c.COECategory__c, 
            Sales_Agreement__c.Bid_Category__c,
            Sales_Agreement__c.ARF__c,
            Sales_Agreement__c.Net_Transaction_Price__c,
            Sales_Agreement__c.Vehicle_Cost__c,
            Sales_Agreement__c.Additional_Charges__c,
            Sales_Agreement__c.Cost_of_Standard_Accessories__c,
            Sales_Agreement__c.Cost_of_Accessories_Traded_Sold__c,
            Sales_Agreement__c.Other_Direct_Cost__c,
            Sales_Agreement__c.GST_Charge__c,
            Sales_Agreement__c.CPF_on_Comm_for_COE__c,
            Sales_Agreement__c.VES__c,
            Sales_Agreement__c.JIT_Status__c,
            Sales_Agreement__c.Verified_by_Sales_Consultant__c,
            Sales_Agreement__c.JIT_Date__c,
            Sales_Agreement__c.Expected_Delivery_Month__c,
            Sales_Agreement__c.Loan_Approval_Status__c,
            Sales_Agreement__c.COE_Submission_Date__c,
            Sales_Agreement__c.Paid_Accessories__c,
            Sales_Agreement__c.RSP_and_Paid_Accessories__c,
            Sales_Agreement__c.ARF_Payable__c,
            Sales_Agreement__c.CIF_for_COE__c,
            Sales_Agreement__c.CIF_for_COE__c,            
            Sales_Agreement__c.Submit_COE_Bidding__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Sales_Agreement__c.sObjectType;
    }
    
    //It is 1-to-1 with stock reservation. It should alway return 1 record.
    public Sales_Agreement__c selectByStockReservationId(Id recordId){
        adglib_QueryFactory query = newQueryFactory();      
        query.setCondition('Stock_Reservation__c = :recordId'); 
        return (Sales_Agreement__c)(Database.query(query.toSOQL()))[0];
    }

    public Sales_Agreement__c selectById(Id recordId){
        List<String> queryFields = new List<String> {'Package_Header__r.PKH_PKGNO__c', 'Finance_Company_Lookup__r.BAM_ASSOCIATECD__c',
                                                     'Stock_Reservation__r.Model_Code__c', 'Insurance_Company_Lookup__r.BAM_ASSOCIATECD__c',
                                                     'Stock_Reservation__r.Vehicle_Master__r.Id', 'Verified_by_Sales_Consultant__c',
                                                     'Name', 'Agreement_Date__c', 'Sales_Consultant__c', 'Customer_Full_Name__c', 'Bid_Category__c', 
                                                     'Bid_Price__c', 'Bid_1_Amount__c', 'Bid_2_Amount__c', 'Bid_3_Amount__c', 'Bid_4_Amount__c',
                                                     'Bid_5_Amount__c', 'Bid_6_Amount__c', 'Bid_7_Amount__c', 'Bid_8_Amount__c', 'Bid_9_Amount__c',
                                                     'Bid_10_Amount__c', 'Bid_11_Amount__c', 'Bid_12_Amount__c'};
        adglib_QueryFactory query = newQueryFactory();  
        query.setCondition('Id = :recordId'); 
        query.selectFields(queryFields);
        return (Sales_Agreement__c)(Database.query(query.toSOQL()))[0];
    }

    public LIST<Sales_Agreement__c> selectByIdWithAdditionalCharges(Set<Id> recordIds){
     
        adglib_QueryFactory SAqueryFactory = ADGLIB_UtilityHelper.getQueryFactoryByObject('Sales_Agreement__c', false);
        SAqueryFactory.selectField('Id');
        SAqueryFactory.selectField('Road_Tax_Top_Up__c');
        SAqueryFactory.selectField('Total_VES_Roadtax_and_fees__c');
        SAqueryFactory.selectField('Vehicle_Purchase_Price__c');

        SAqueryFactory.setCondition('Id = :recordIds'); 
        
        SaAddnlChargeSelector additionChargesQuery = new SaAddnlChargeSelector();

        adglib_QueryFactory additionChargesQueryFactory = additionChargesQuery.newQueryFactory(false);
        additionChargesQueryFactory.setCondition('SAD_INCPRICE__c !=\'INC\'');

        additionChargesQuery.addQueryFactorySubselect(SAqueryFactory, 'SA_Additional_Charges__r'); 
        system.debug('SAqueryFactory.toSOQL() ' + SAqueryFactory.toSOQL());
        return Database.query(SAqueryFactory.toSOQL());
    }
    //Start of RN2020Q1010 
    //This selector will select SalesAgreement which has no Sales Order and package price is different from vehicle list price
    public LIST<Sales_Agreement__c> selectByPackageIdsWithNoSalesOrder(Set<Id> packageIds){
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Package_Header__c IN: packageIds AND SOH_SONO__c = null AND isChangePackagePrice__c = true');
        return (LIST<Sales_Agreement__c>)(Database.query(query.toSOQL()));
    }
    //End of RN2020Q1010 
    
    public List<Sales_Agreement__c> selectSAForCOEBiddingByFranchise(String franchise, String additionalConditions) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Finance_Company_Lookup__r.Name');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.Vehicle_Type_For_Sale__c');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.OMV__c');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.FOB_Amount__c');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.Freight_Charges__c');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.Insurance_Charges__c');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.Model_Code__c');  
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.Model_Code__r.Fuel_Type__c');
        query.selectField('Stock_Reservation__r.Vehicle_Master__r.Duty_Amount__c');
        query.selectField('Stock_Reservation__r.Model_Code__c');
        String strFilter = 'FranchiseCode__c = :franchise' 
                        + ' AND COE__c = null'
                        + ' AND Vehicle_Deposit__c != 0'
                        + ' AND COE_Deposit__c != 0'
                        + ' AND Verified_by_Sales_Consultant__c = true'
                        + ' AND Stage__c = \'Confirmation of Sale\''
                        + ' AND Expected_Delivery_Month__c != null'
                        ;

        query.subselectQuery(SA_Additional_Charge__c.SObjectType)
             .selectField('ChargeCodeDescription__c')
             .selectField('SAD_ADM_CHRGCD__c')
             .selectField('SAD_CHARGES__c');

        query.subselectQuery(SA_Accessory__c.SObjectType)
             .selectField('Accessories_Master__r.ACM_MNM_MAJGROUPCD__c')
             .selectField('SA_ACM_ACCSDESC__c')
             .selectField('SAC_ACCSCOST__c')
             .setCondition( 'SAC_PACKAGE__c != \'Y\' AND Accessories_Master__r.ACM_MNM_MAJGROUPCD__c != \'USED_CAR\'');

        query.setOrdering('COEThresHold__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true); 
        if( String.isNotBlank(additionalConditions.trim())) {            
            strFilter += additionalConditions; 
        }
        query.setCondition(strFilter);
        System.debug('query.toSOQL()' + query.toSOQL());
        return Database.query(query.toSOQL());
    }

    public List<Sales_Agreement__c> selectSalesAgreementForThresholdCalculation(List<Id> saIds) {

        adglib_QueryFactory saQueryFactory = newQueryFactory();
        saQueryFactory.setCondition('Id IN :saIds');

        saQueryFactory.subselectQuery(SA_Accessory__c.SObjectType)
                      .selectFields(new SaAccsSelector().getSObjectFieldList())
                      .selectField('Accessories_Master__r.ACM_MNM_MAJGROUPCD__c'); 

        saQueryFactory.subselectQuery(SA_Additional_Charge__c.SObjectType)
                      .selectFields(new SaAddnlChargeSelector().getSObjectFieldList());


        return Database.query(saQueryFactory.toSOQL());
    }

    public List<Sales_Agreement__c> selectByIds(Set<String> saIds) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :saIds');

        return (List<Sales_Agreement__c> )Database.query(query.toSOQL()); 
    }
}