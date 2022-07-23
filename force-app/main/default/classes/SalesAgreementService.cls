public inherited Sharing class SalesAgreementService {
    
    public static Sales_Agreement__c getSalesAgrmnt(Id saId) {
        SalesAgreementSelector salesAgreementSel = new SalesAgreementSelector();
        return salesAgreementSel.selectById(saId);
    }
     
    public static List<SA_Accessory__c> getSaAccs (Id saId) {
        SaAccsSelector saAccsSel = new SaAccsSelector();
        return saAccsSel.selectAccessoriesBySalesAgreementId(saId);
    }
    
    public static List<SA_Additional_Charge__c> getSaAddnlCharges (Id saId) {
        SaAddnlChargeSelector saAddnlChargeSel = new SaAddnlChargeSelector();
        return saAddnlChargeSel.selectAdditionalChargeBySalesAgreementId(saId);
    }
    
    public static List<Package_Additional_Charges__c> getPackageAddnlCharges (Id packageHeaderId) {
        PackageAdditionalChargesSelector packageAddnlChargesSel = new PackageAdditionalChargesSelector();
        return packageAddnlChargesSel.selectByPackageHeaderId(packageHeaderId);
    }
    
    public static List<Package_Accs__c> getPkgAccs (id packageHeaderId) {
        PackageAccsSelector pkgAccsSel = new PackageAccsSelector();
        return pkgAccsSel.selectByPackageHeaderId(packageHeaderId);
    }

    public static Accessories_Master__c getAccsMaster (id accessoriesMastersId){
        AccessoriesMasterSelector acsMasterSel = new AccessoriesMasterSelector();
        return acsMasterSel.selectAccsMasterById(AccessoriesMastersId);
    }
    public static List<Model_Rate_Master__c> getModelRateMaster (id modelCodeId){
        ModelRateMasterSelector modelRateSel = new ModelRateMasterSelector();
        return modelRateSel.selectModelRateMasterByModelMasterId(modelCodeId);
    }
    
    public static SA_Accessory__c getSaAccsBySaIdandAccCode(ID saId, String accCode) {
        SaAccsSelector sAAccSel = new SaAccsSelector();
        
        return sAAccSel.selectAccsBySaIdandAccCode(saId, accCode);
    }	
    
    public static Sales_Agreement__c processOffPeakCar(Sales_Agreement__c previous, Sales_Agreement__c current){
        if(previous.Registration_Number_Type__c != current.Registration_Number_Type__c)
        { 
            current.SOH_RTM_REGTYPECD__c = current.Registration_Number_Type__c == 'Off Peak Car' ? 'O' : current.SOH_RTM_REGTYPECD__c;
        }
        return current;
    }

    public static Map<id, Stock_Reservation__c> getStockReservationInformation(Set<ID> stockReservationIds){
        stockReservationSelector stockReservationSelector = new stockReservationSelector();
        return new Map<id, Stock_Reservation__c>(stockReservationSelector.selectById(stockReservationIds));
    }

    public static Map<String, Id> getPackageHeaderIdBasedOnModel(LIST<Stock_Reservation__c> stockReservationList){
        Map<Id, String> reservationAndModelMap = new Map<Id, String> ();
        Map<String, Id> returnPackageAndModelMap = new Map<String,id>();
        PackageHeaderSelector packageSelector = new PackageHeaderSelector();
        for(Stock_Reservation__c record: stockReservationList){
            reservationAndModelMap.put(record.id, record.Model_Code__c);
        }
        for(Package_Header__c record : packageSelector.selectByModelsAndStaus(new set<Id>((LIST<Id>)reservationAndModelMap.values()), 'A')){
            returnPackageAndModelMap.put(record.Model_Master__c, record.Id);
        }
        return returnPackageAndModelMap;
    }

    public static Map<Id, List<SA_Accessory__c>> retrieveDeleteAccessories(Map<Id, Id> salesAgreementAndPackageMap){
        SaAccsSelector saAccsSelector = new SaAccsSelector();
        Map<Id, List<SA_Accessory__c>> saAccsToBeDeleted = new Map<Id, List<SA_Accessory__c>>();
        for (SA_Accessory__c rec : saAccsSelector.selectAccBySalesAgreementId(salesAgreementAndPackageMap.keySet())) {
            if(saAccsToBeDeleted.containsKey(rec.Sales_Agreement__c)){
                saAccsToBeDeleted.get(rec.Sales_Agreement__c).add(rec);
                continue;
            }
            saAccsToBeDeleted.put(rec.Sales_Agreement__c, new List<SA_Accessory__c>{rec});
        }
        return saAccsToBeDeleted;
    }

    public static Map<Id, List<Package_Accs__c>> retrieveNewAccessories(Map<Id, Id> salesAgreementAndPackageMap){
        PackageAccsSelector packageAccsSelector = new PackageAccsSelector();
        Map<Id, List<Package_Accs__c>> pckAccMap = new Map<Id, List<Package_Accs__c>>();
        for (Package_Accs__c pckAcc : packageAccsSelector.selectByPackageHeaderIds(new Set<Id>(salesAgreementAndPackageMap.values()))) {
            if (pckAccMap.containsKey(pckAcc.Package_Header__c)) {
                pckAccMap.get(pckAcc.Package_Header__c).add(pckAcc);
                continue;
            }
            pckAccMap.put(pckAcc.Package_Header__c, new List<Package_Accs__c>{pckAcc});
        }
        return pckAccMap;
    }

    public static Map<Id, List<SA_Additional_Charge__c>> retrieveDeleteAdditionCharges(Map<Id, Id> salesAgreementAndPackageMap){
        SaAddnlChargeSelector saAddnlChargeSelector = new SaAddnlChargeSelector();
        Map<Id, List<SA_Additional_Charge__c>> saAddnlChargeToBeDeleted = new Map<Id, List<SA_Additional_Charge__c>>();
        for (SA_Additional_Charge__c rec : saAddnlChargeSelector.selectAddnlChargeBySalesAgreementIds((Set<Id>)salesAgreementAndPackageMap.keySet())) {
                if (saAddnlChargeToBeDeleted.containsKey(rec.Sales_Agreement__c)) {
                    saAddnlChargeToBeDeleted.get(rec.Sales_Agreement__c).add(rec);
                    continue;
                }
            saAddnlChargeToBeDeleted.put(rec.Sales_Agreement__c, new List<SA_Additional_Charge__c>{rec});
        }
        return saAddnlChargeToBeDeleted;
    }
    public static Map<Id, Id> findPackagesBasedOnSalesAgreement (Map<Id,SObject> existingRecords, List<Sales_Agreement__c> records) {
        Map<Id, Id> changedPackageHeader = new Map<Id, Id>();

        //Getting updated records' packageHeader
        for(Sales_Agreement__c record: records){

            if( record.Package_Header__c == null ||
                (existingRecords != null && ((Sales_Agreement__c)existingRecords.get(record.ID)).Package_Header__c == record.Package_Header__c)) {
                continue;
            }
            changedPackageHeader.put(record.Id, record.Package_Header__c);
        }
        return changedPackageHeader;
    }

    public static Map<Id, List<Package_Additional_Charges__c>> retrieveNewAdditionalCharges(Map<Id, Id> salesAgreementAndPackageMap){
        PackageAdditionalChargesSelector pckAddnlChargeSelector = new PackageAdditionalChargesSelector();
        Map<Id, List<Package_Additional_Charges__c>> pckAddnlChargeMap = new Map<Id, List<Package_Additional_Charges__c>>();

        //Preparing a list of package additional charge for insertion
        for (Package_Additional_Charges__c pckAddnlCharge : pckAddnlChargeSelector.selectByPackageHeaderIds(new Set<Id>(salesAgreementAndPackageMap.values()))) {
            if (pckAddnlChargeMap.containsKey(pckAddnlCharge.Package_Header__c)) {
                pckAddnlChargeMap.get(pckAddnlCharge.Package_Header__c).add(pckAddnlCharge);
                continue;
            }

            pckAddnlChargeMap.put(pckAddnlCharge.Package_Header__c, new List<Package_Additional_Charges__c>{pckAddnlCharge});
        }

        return pckAddnlChargeMap;
    }
    
    public static Accessories_Master__c getACMByBranchCodeandAccCode (String branchCode, String accCode) {
        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        
        return aCMSel.selectByBranchAndAccsCode(branchCode, accCode);
    }
    
    public static Accessories_Master__c getACMByVSMSCompoundPrimaryKey (String franchiseCode, String accCode, String uniqueBranchCode) {
        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        
        return aCMSel.selectByVSMSCompoundPrimaryKey(franchiseCode, accCode, uniqueBranchCode);
    }
    
    public static Map<String, Package_Header__c> getPackageHeaderBasedOnId(LIST<Stock_Reservation__c> stockReservationList){
        PackageHeaderSelector packageSelector = new PackageHeaderSelector();
        Map<Id, String> reservationAndModelMap = new Map<Id, String> ();
        Map<String, Package_Header__c> returnPackageAndModelMap = new Map<String, Package_Header__c>();
        
        for(Stock_Reservation__c record: stockReservationList){
            reservationAndModelMap.put(record.id, record.Package_Header_From_PickList__c);
        }
        
        for(Package_Header__c record : packageSelector.selectById(new set<Id>((LIST<Id>)reservationAndModelMap.values()), 'A')){
            returnPackageAndModelMap.put(record.Model_Master__c, record);
        }
        return returnPackageAndModelMap;
    }
    
    public static Map<Id, List<Package_Accs__c>> getPackageAcssByPackageHeader(Map<String, Package_Header__c> modeltAndPackageMap) {
        PackageAccsSelector packageAccsSelector = new PackageAccsSelector();
        Map<Id, List<Package_Accs__c>> pckAccMap = new Map<Id, List<Package_Accs__c>>();
        Set<ID> packageHeaderIds = new Set<ID> ();
        for (Package_Header__c packageHeader : modeltAndPackageMap.values()) {
            packageHeaderIds.add(PackageHeader.Id);
        }
        for (Package_Accs__c pckAcc : packageAccsSelector.selectByPackageHeaderIds(packageHeaderIds)) {
            if (pckAccMap.containsKey(pckAcc.Package_Header__c)) {
                pckAccMap.get(pckAcc.Package_Header__c).add(pckAcc);
                continue;
            }
            pckAccMap.put(pckAcc.Package_Header__c, new List<Package_Accs__c>{pckAcc});
        }
        return pckAccMap;
    }

    public static Map<Id, Opportunity> getOpportunitiesByIds (Set<Id> oppIds)
    {
        return new Map<Id, Opportunity>([SELECT Account__c, Contact_Person__c FROM Opportunity WHERE Id IN: oppIds]);
    }

    
//Start of RN2020Q1010 
    public static void processSalesAgreementForPriceChange(Set<id> packageIds){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType});
        SalesAgreementSelector salSelector = new SalesAgreementSelector();
        List<Sales_Agreement__c> salesAgreementList = salSelector.selectByPackageIdsWithNoSalesOrder(packageIds);
        //Process a list of SA which has package that package list price is not the same
        
        if(!salesAgreementList.isEmpty()){
            for(Sales_Agreement__c rec: salesAgreementList){
                uow.registerDirty( new Sales_Agreement__c ( id  = rec.Id,
                                                            Package_List_Price__c = rec.VehicleListPrice__c,
                                                            Package_List_Price_TimeStamp__c = DateTime.now()));
            }

            uow.commitWork();
        }

    }

    public static Sales_Agreement__c processCalculation(Sales_Agreement__c previous, Sales_Agreement__c current){
        if(previous.Package_List_Price__c != current.Package_List_Price__c || previous.Total_Addon_Price__c != current.Total_Addon_Price__c || 
           previous.Package_List_Price__c != current.Total_VES_Roadtax_and_fees__c || previous.Package_List_Price__c != current.Total_Discount_Price__c)
        { 
            current.Package_List_Price__c = current.Package_List_Price__c  == null ? 0 : current.Package_List_Price__c;
            current.Total_Addon_Price__c = current.Total_Addon_Price__c  == null ? 0 : current.Total_Addon_Price__c;
            current.Total_VES_Roadtax_and_fees__c = current.Total_VES_Roadtax_and_fees__c  == null ? 0 : current.Total_VES_Roadtax_and_fees__c;
          
            current.Vehicle_Purchase_Price__c = current.Package_List_Price__c  + current.Total_Addon_Price__c + current.Total_VES_Roadtax_and_fees__c + current.Total_Discount_Price__c;
        }
        return current;
    }

      public static Map<String, Package_Header__c> getPackageHeadersBasedOnModel(LIST<Stock_Reservation__c> stockReservationList){
        PackageHeaderSelector packageSelector = new PackageHeaderSelector();
        Map<Id, String> reservationAndModelMap = new Map<Id, String> ();
        Map<String, Package_Header__c> returnPackageAndModelMap = new Map<String, Package_Header__c>();
        
        for(Stock_Reservation__c record: stockReservationList){
            reservationAndModelMap.put(record.id, record.Model_Code__c);
        }

        for(Package_Header__c record : packageSelector.selectByModelsAndStaus(new set<Id>((LIST<Id>)reservationAndModelMap.values()), 'A')){
            returnPackageAndModelMap.put(record.Model_Master__c, record);
        }
        return returnPackageAndModelMap;
    }
//End of RN2020Q1010 
}