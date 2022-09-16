/** *****
 * Description : Controller class for COE_Bid_Period__c object
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                                 Description
 * 20220802             thieudang.vu@aodigy.com              Created Initial Version
 * 20220815             thanh.ly@aodigy.com                  Add method Get Last COE Record
 * 20220817             thanh.ly@aodigy.com                  Add method Get Franchise Picklist, Add method Get Custom Exchange Rate
 * 
** *****/
public without sharing class COEBiddingController {
    @AuraEnabled(cacheable=true)
    public static COE_Bid_Period__c getNextCOE()
    {
        return [SELECT Id, From_Date__c, To_Date__c FROM COE_Bid_Period__c WHERE From_Date__c >= :Date.today()
                ORDER BY From_Date__c ASC LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static COE_Bid_Period__c getLastCOE()
    {
        return [SELECT Id, From_Date__c, To_Date__c, A__c, B__c, C__c, E__c FROM COE_Bid_Period__c WHERE From_Date__c < :Date.today()
                ORDER BY From_Date__c DESC LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static List<FranchiseWrapper> getFranchisePicklist()
    {
        List<FranchiseWrapper> values = new List<FranchiseWrapper>();
        Schema.DescribeFieldResult result = Vehicle_Master2__c.Franchise_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = result.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            values.add(new FranchiseWrapper(pickListVal.getValue(), pickListVal.getLabel()));
        }   
        System.debug('picklist values = ' + values);
        return values;
    }

    @AuraEnabled(cacheable=true)
    public static Custom_Exchange_Rate__c getExchangeRate(String currencyCode){
       return [SELECT Id, Custom_Exchange_Rate__c, Valid_From__c FROM Custom_Exchange_Rate__c 
               WHERE Currency_Code__c = :currencyCode 
               AND Valid_From__c <= :Date.today()
               ORDER BY Valid_From__c DESC LIMIT 1];
    }

    public class FranchiseWrapper 
    {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }

        private FranchiseWrapper(String value, String label){
            this.value = value;
            this.label = label;
        }
    }

    @AuraEnabled
    public static List<Sales_Agreement__c> retrieveDSAsForBidding(String franchise, FilterWrapper filter)
    {
        System.debug('filter :: ' + filter);
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        String additionalCondition = '';
        if(filter != null) {
            additionalCondition = convertFilterWrapperToString(filter);
        }
        List<Sales_Agreement__c> salesAgrementList = saSelector.selectSAForCOEBiddingByFranchise(franchise, additionalCondition);
        return salesAgrementList;
    }

    public class FilterWrapper 
    {
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String guaranteeStatus { get; set; }
        @AuraEnabled public String svmStatus { get; set; } 
        @AuraEnabled public String approvalStatus { get; set; } 
        @AuraEnabled public String submitStatus { get; set; }
        @AuraEnabled public String bidCategory { get; set; } 
    }

    public static String convertFilterWrapperToString(FilterWrapper filterWrapper) {
        String queryCondition = '';
        if(String.isNotBlank(filterWrapper.category)) {
            queryCondition += ' AND COECategory__c = \'' + filterWrapper.category + '\'';
        }

        if(String.isNotBlank(filterWrapper.guaranteeStatus)) {
            queryCondition += ' AND COE_Package__c = \'' + filterWrapper.guaranteeStatus + '\'';
        }

        if(String.isNotBlank(filterWrapper.svmStatus)) {
            if(filterWrapper.svmStatus == 'Stock to Indent') {
                queryCondition += ' AND Stock_Reservation__r.Vehicle_Master__c = \'\'';
            } else {
                queryCondition += ' AND Stock_Reservation__r.Vehicle_Master__r.Vehicle_Type_For_Sale__c = \'' + filterWrapper.svmStatus + '\'';
            }
        }

        if(String.isNotBlank(filterWrapper.approvalStatus)) {
            queryCondition += ' AND Loan_Approval_Status__c = \'' + filterWrapper.approvalStatus + '\'';
        }

        if(String.isNotBlank(filterWrapper.submitStatus)) {
            queryCondition += ' AND Submit_COE_Bidding__c = ' + Boolean.valueOf(filterWrapper.submitStatus);
        }

        if(String.isNotBlank(filterWrapper.bidCategory)) {
            queryCondition += ' AND Bid_Category__c = \'' + filterWrapper.bidCategory + '\'';
        }

        return queryCondition;
    }

    @AuraEnabled
    public static List<Sales_Agreement__c> saveInputData(List<Map<String, String>> info)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType, SA_COE_Bid_Period__c.SObjectType});

        List<Sales_Agreement__c> records    = getSAList(info);
        List<SA_COE_Bid_Period__c> latestBids = getLatestSACOEBid(info);

        try
        {
            if (records != null)
            {
                uow.registerDirty(records);
                uow.registerDirty(latestBids);
            }

            uow.commitWork();
            
        } 
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }

        return records;
    }

    @AuraEnabled
    public static void submitForCOEBidding(List<Map<String, String>> info, String bidPeriodId)
    {
        ADGLIB_SObjectUnitOfWork uow        = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {SA_COE_Bid_Period__c.SObjectType, Sales_Agreement__c.SObjectType});

        Map<String, Schema.DescribeFieldResult> descriptions = getFieldDescription(getFieldTokens(getObjectToken('SA_COE_Bid_Period__c')));        

        List<SA_COE_Bid_Period__c> coeRecords = new List<SA_COE_Bid_Period__c>();
        Map<String, Double> bidPriceBySAIds   = new Map<String, Double>();
        List<Id> saIds                        = new List<Id>();
        for (Map<String, String> textValueMap : info)
        {
            SA_COE_Bid_Period__c rec = new SA_COE_Bid_Period__c();
            Id saId = Id.valueOf(textValueMap.get('Id'));
            rec.put('Sales_Agreement__c', saId);
            saIds.add(saId);
    
            rec.put('COE_Bid_Period__c', bidPeriodId);
            Decimal bidAmount = textValueMap.containsKey('Bid_Price__c') ? Decimal.valueOf(textValueMap.get('Bid_Price__c')) : 0;
            rec.put('Bid_Amount__c', bidAmount);
            rec.put('Bid_Category__c', String.valueOf(textValueMap.get('Bid_Category__c')));
            rec.put('Status__c', 'Pending');
    
            bidPriceBySAIds.put(saId, bidAmount);
    
            coeRecords.add(rec); 
        }

        // Find the latest null Bid_X_Amount field to save with Bid Price value
        // Clear Bid_Price__c field value for every SA after submitting for COE
        List<Sales_Agreement__c> dsas = new SalesAgreementSelector().selectByIds(bidPriceBySAIds.keySet());
        for (Sales_Agreement__c sa : dsas)
        {
            sa.Submit_COE_Bidding__c = true;
            sa.Verified_by_Sales_Consultant__c = true;
            sa.Bid_Price__c          = null;
            sa.Bid_Category__c       = null;

            Double bidPrice = bidPriceBySAIds.get(sa.Id);
            if (sa.Bid_1_Amount__c == null)
            {
                sa.Bid_1_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_2_Amount__c == null)
            {
                sa.Bid_2_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_3_Amount__c == null)
            {
                sa.Bid_3_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_4_Amount__c == null)
            {
                sa.Bid_4_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_5_Amount__c == null)
            {
                sa.Bid_5_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_6_Amount__c == null)
            {
                sa.Bid_6_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_7_Amount__c == null)
            {
                sa.Bid_7_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_8_Amount__c == null)
            {
                sa.Bid_8_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_9_Amount__c == null)
            {
                sa.Bid_9_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_10_Amount__c == null)
            {
                sa.Bid_10_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_11_Amount__c == null)
            {
                sa.Bid_11_Amount__c = bidPrice;
                continue;
            }
            else if (sa.Bid_12_Amount__c == null)
            {
                sa.Bid_12_Amount__c = bidPrice;
                continue;
            }
        }

        try 
        {   
            
            List<String> submittedDSAIds = getSubmittedDSA(saIds);
            if(submittedDSAIds.size() > 0) {
                AuraHandledException ex = new AuraHandledException('');
                ex.setMessage('Duplicate submission');
                throw ex;

            } else {
                uow.registerNew(coeRecords);
                uow.registerDirty(dsas);
                uow.commitWork();
            }            
                     
        } 
        catch (Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage() + '' + e.getCause() + '' + e.getLineNumber());            
            throw new AuraHandledException(e.getMessage() + ' At line: ' + e.getLineNumber());
        }
    }

    public static Map<Id, Map<String, Decimal>> getPreFields(List<Sales_Agreement__c> dsaList) {
        Map<Id, Map<String, Decimal>> dsaIdAndValues = new Map<Id, Map<String, Decimal>>();

        Map<String, String> dsaIdAndModelCodeMap = new Map<String, String>();
        for(Sales_Agreement__c dsa: dsaList) {
            Map<String, Decimal> mapFieldValues = new Map<String, Decimal>();
            Decimal fobAmount  = 0;
            Decimal insurance  = 0;
            Decimal freight    = 0;

            //String stockStatus = dsa.Stock_Reservation__r.Vehicle_Master__r.Stock_Vehicle_Status__c;
            // if(String.isNotBlank(stockStatus) && stockStatus.equalsIgnoreCase('I')) {
            if(dsa.Stock_Reservation__r.Vehicle_Master__c != null) {
                fobAmount  = dsa.Stock_Reservation__r.Vehicle_Master__r.FOB_Amount__c != null ? dsa.Stock_Reservation__r.Vehicle_Master__r.FOB_Amount__c : 0;
                insurance  = dsa.Stock_Reservation__r.Vehicle_Master__r.Insurance_Charges__c != null ? dsa.Stock_Reservation__r.Vehicle_Master__r.Insurance_Charges__c : 0;
                freight    = dsa.Stock_Reservation__r.Vehicle_Master__r.Freight_Charges__c  != null ? dsa.Stock_Reservation__r.Vehicle_Master__r.Freight_Charges__c : 0;
            } else {
                String modelCode = dsa.Stock_Reservation__r.Model_Code__c;
                if(String.isNotBlank(modelCode)) {
                    dsaIdAndModelCodeMap.put(dsa.Id, modelCode);
                }
                
            }
            mapFieldValues.put('fobAmount', fobAmount);
            mapFieldValues.put('insurance', insurance);
            mapFieldValues.put('freight', freight);    

            dsaIdAndValues.put(dsa.Id, mapFieldValues);
        }

        if(dsaIdAndModelCodeMap.size() > 0) {
            Map<String, Vehicle_Master2__c> mapModelCodeAndSVM = getModelCodeAndLastestSVM(dsaIdAndModelCodeMap.values());
            if(mapModelCodeAndSVM.size() > 0) {
                for(String dsaId: dsaIdAndModelCodeMap.keySet()) {
                    Map<String, Decimal> mapFieldValues = new Map<String, Decimal>();

                    Decimal fobAmount  = 0;
                    Decimal insurance  = 0;
                    Decimal freight    = 0;

                    String modelCode = dsaIdAndModelCodeMap.get(dsaId);
                    if(mapModelCodeAndSVM.containsKey(modelCode)) {
                        Vehicle_Master2__c svm = mapModelCodeAndSVM.get(modelCode);
                        fobAmount = svm.FOB_Amount__c != null ? svm.FOB_Amount__c : 0;
                        insurance = svm.Insurance_Charges__c != null ? svm.Insurance_Charges__c : 0;
                        freight   = svm.Freight_Charges__c != null ? svm.Freight_Charges__c : 0;
                    }

                    mapFieldValues.put('fobAmount', fobAmount);
                    mapFieldValues.put('insurance', insurance);
                    mapFieldValues.put('freight', freight);
                    dsaIdAndValues.put(dsaId, mapFieldValues);
                }
            }
        }
        
        return dsaIdAndValues;
    }

    public static Map<String, Vehicle_Master2__c> getModelCodeAndLastestSVM(List<String> modelCodeList) {
        Map<String, Vehicle_Master2__c> mapModelCodeAndSVM = new Map<String, Vehicle_Master2__c>();

        List<Model_Master__c> modelMasterList = getSVMHasLatestETA(modelCodeList);
        for(Model_Master__c model: modelMasterList) {
            if(model.Vehicle_Master__r != null && model.Vehicle_Master__r.size() > 0) {
                mapModelCodeAndSVM.put(model.Id, model.Vehicle_Master__r[0]);
            }
        }
        
        return mapModelCodeAndSVM;
    }

    private static List<Model_Master__c> getSVMHasLatestETA(List<String> modelCodes){
        List<Model_Master__c> listModelMaster  = [  SELECT Id, ( SELECT Id, Freight_Charges__c, FOB_Amount__c, Insurance_Charges__c
                                                                 FROM Vehicle_Master__r
                                                                 WHERE ETA_Date__c != null
                                                                 ORDER BY ETA_Date__c DESC
                                                                 LIMIT 1
                                                                )
                                                    FROM Model_Master__c
                                                    WHERE Id IN :modelCodes
                                                ];
             
        return listModelMaster;
    }

    @AuraEnabled
    public static Map<Id, Map<String, Decimal>> calculateFieldsPresave(List<Sales_Agreement__c> dsaList, String branch, Decimal otherDirectCost, Decimal exchangeRateUSD, Decimal exchangeRateEUR, Decimal exchangeRateJPY, Decimal exchangeRateRMB) {
        Map<Id, Map<String, Decimal>> dsaIdAndPreFields = getPreFields(dsaList);

        List<COE_Bidding__mdt> coeFixedValue = [ SELECT CVES_Amount__c, DeveloperName, Duty_Rate__c, EEAI_Cap__c, EEAI_Percentage__c, Label, SC_CPF_Comm_Rate__c
                                                 FROM COE_Bidding__mdt
                                                 WHERE Is_Active__c = TRUE
                                                 LIMIT 1
                                                ];
        Decimal dutyRate = 0;
        Decimal eeaiCap  = 0;
        Decimal eeaiPercentage  = 0;
        Decimal cvesAmount = 0;
        Decimal cpfCommRate = 0;
        if(coeFixedValue.size() > 0) {
            dutyRate = coeFixedValue[0].Duty_Rate__c != null ? coeFixedValue[0].Duty_Rate__c : 0;
            eeaiCap = coeFixedValue[0].EEAI_Cap__c != null ? coeFixedValue[0].EEAI_Cap__c : 0;
            eeaiPercentage = coeFixedValue[0].EEAI_Percentage__c != null ? coeFixedValue[0].EEAI_Percentage__c : 0;
            cvesAmount = coeFixedValue[0].CVES_Amount__c != null ? coeFixedValue[0].CVES_Amount__c : 0;
            cpfCommRate = coeFixedValue[0].SC_CPF_Comm_Rate__c != null ? coeFixedValue[0].SC_CPF_Comm_Rate__c : 0;
        }
                                                
        
        Map<Id, Map<String, Decimal>> dsaIdAndValues = new Map<Id, Map<String, Decimal>>();
        for(Sales_Agreement__c dsa: dsaList) {
            Map<String, Decimal> mapFieldValues = new Map<String, Decimal>();

            String vehicleType = dsa.FranchiseCode__c.endsWith('PC') ? 'PC' : (dsa.FranchiseCode__c.endsWith('CV') ? 'CV' : 'other');
            String modelFuelType  = dsa.Stock_Reservation__r.Vehicle_Master__r.Model_Code__r.Fuel_Type__c;

            //Calculate CIF_for_COE__c
            Decimal dsaCIF = 0;
            Decimal omv;
            if(dsa.Stock_Reservation__r.Vehicle_Master__c != null) {
                omv = dsa.Stock_Reservation__r.Vehicle_Master__r.OMV__c;
            }

            if(omv != null && omv > 0) {
                dsaCIF = omv;
            } else {
                Map<String, Decimal> mapPreFields = dsaIdAndPreFields.get(dsa.Id);
                Decimal fobAmount  = mapPreFields.get('fobAmount');
                Decimal insurance  = mapPreFields.get('insurance');
                Decimal freight    = mapPreFields.get('freight');
                dsaCIF = calculateCIF(fobAmount, insurance, freight, branch, exchangeRateUSD, exchangeRateEUR, exchangeRateJPY, exchangeRateRMB);
            }

            Decimal ves = dsa.VES__c != null ? dsa.VES__c : 0;
            Decimal cves = calculateCVES(vehicleType, cvesAmount);
            Decimal cpf = calculateCPF(cpfCommRate, dsa.Proposed_Commission__c);
            Decimal dsaARF = calculateARF(dsaCIF, vehicleType, dsa.Registration_Type__c);

            Decimal vehicleDuty = calculateVehicleDuty(dsa.Stock_Reservation__r.Vehicle_Master__r.Duty_Amount__c, dsaCIF, dutyRate);
            Decimal dsaEEAI = calculateEEAI(vehicleType, modelFuelType, dsaARF, eeaiPercentage, eeaiCap);
            Decimal arfPayable = calculateARFPayable(vehicleType, dsaARF, ves, dsaEEAI);
            Decimal vehicleCost = calculateVehicleCost(arfPayable, dsaCIF, vehicleDuty);
            Decimal coeThresHold = calculateCOEThresHold(dsa, vehicleType, vehicleCost, otherDirectCost, cves);

            mapFieldValues.put('CIF_for_COE__c', dsaCIF);
            mapFieldValues.put('ARF__c', dsaARF);
            mapFieldValues.put('Vehicle_Duty_for_COE__c', vehicleDuty);
            mapFieldValues.put('EEAI__c', dsaEEAI);
            mapFieldValues.put('ARF_Payable__c', arfPayable);
            mapFieldValues.put('Vehicle_Cost__c', vehicleCost);
            mapFieldValues.put('COEThresHold__c', coeThresHold);

            dsaIdAndValues.put(dsa.Id, mapFieldValues);
        }
        return dsaIdAndValues;
    }
    
    public static Vehicle_Master2__c getSVMHasLatestETA(String modelCode){
        List<Vehicle_Master2__c> vehicleMaster = [  SELECT Id, Freight_Charges__c, FOB_Amount__c, Insurance_Charges__c
                                                    FROM Vehicle_Master2__c
                                                    WHERE Model_Code__c =: modelCode
                                                    
                                                ];
        if(vehicleMaster.size() > 0 ) {
            return vehicleMaster[0];
        }       
        return null;
    }

    private static Decimal calculateCPF(Decimal cpfCommRate, Decimal proposedCommission) {
        return (cpfCommRate/100 * (proposedCommission != null ? proposedCommission : 0));        
    }

    private static Decimal calculateCVES(String vehicleType, Decimal cvesAmount) {
        return (vehicleType == 'CV' ? cvesAmount :  0);        
    }

    public static Decimal calculateCIF(Decimal fobAmount, Decimal insurance, Decimal freight, String branch, Decimal exchangeRateUSD, Decimal exchangeRateEUR, Decimal exchangeRateJPY, Decimal exchangeRateRMB){
        
        switch on branch {
            when 'KIA' {
                return (fobAmount + insurance + freight) * exchangeRateUSD;
            }
            when 'MIT' {
                return (1.000385 * fobAmount  * exchangeRateJPY);
            }
            when 'CIT' {
                return (1.000385 * fobAmount  * exchangeRateEUR) + (freight * exchangeRateUSD);
            }
            when 'MAXUS' {
                return (fobAmount + insurance + freight) * exchangeRateRMB;
            }
            when else {
                return 0;
            }
        }
}

    private static Decimal calculateARF(Decimal cif, String vehicleType, String regType) {
        Decimal arf = 0;
        if(vehicleType == 'PC') {
            if(cif <= 20000) {
                arf = cif;
            } else if (cif > 20000 && cif <= 50000) {
                arf = ( ( cif - 20000 )*140/100 ) + 20000;
            } else if (cif > 50000 && cif <= 80000) {
                arf = ( ( cif - 50000 )*180/100 ) + 62000;
            } else if (cif > 80000) {
                arf = ( ( cif - 80000 )*220/100 ) + 116000;
            }
        } else if(vehicleType == 'CV') {
            if( regType != 'CPV') {
                arf = cif * 5/100;
            }
        }
        return arf;
    }

    private static Decimal calculateEEAI(String vehicleType, String modelFuelType, Decimal dsaARF, Decimal eeaiPercentage, Decimal eeaiCap) {
        Decimal dsaEEAI = 0;
        if(vehicleType == 'PC' && modelFuelType == 'ELE') {               
            if( (dsaARF * eeaiPercentage/100) <= eeaiCap) {
                dsaEEAI = dsaARF * eeaiPercentage/100;
            } else {
                dsaEEAI = eeaiCap;
            }
        } else {
            dsaEEAI = 0;
        }
        return dsaEEAI;
    }

    private static Decimal calculateARFPayable(String vehicleType, Decimal arf, Decimal ves, Decimal eeai) {
        Decimal arfPayable = 0;
        if(vehicleType == 'PC') {
            arfPayable = (arf + ves) >= 5000 ? (arf + ves + eeai) : 5000 + eeai;
        } else if(vehicleType == 'CV') {
            arfPayable = arf + ves;
        }        
        return arfPayable;
    }

    private static Decimal calculateVehicleDuty(Decimal svmDutyAmount, Decimal cif, Decimal dutyRate) {
        return (svmDutyAmount != null && svmDutyAmount > 0) ? svmDutyAmount : cif * dutyRate/100 ;
        
    }

    private static Decimal calculateVehicleCost(Decimal arfPayable, Decimal cif, Decimal vehicleDuty) {
        return cif + arfPayable + vehicleDuty;        
    }

    private static Decimal calculateCOEThresHold(Sales_Agreement__c dsa, String vehicleType, Decimal vehicleCost, Decimal otherDirectCost, Decimal cves) {
        
        Decimal coeThresHold = 0;
        Decimal opcFee = dsa.Registration_Type__c == 'Off Peak Car' ? 17000 : 0;

        coeThresHold =  (dsa.Net_Transaction_Price__c != null ? dsa.Net_Transaction_Price__c : 0)
                        - (vehicleCost != null ? vehicleCost : 0)
                        - (dsa.GMS_Package__c != null ? dsa.GMS_Package__c : 0)
                        + (cves != null ? cves : 0)
                        + (dsa.Additional_Charges__c != null ? dsa.Additional_Charges__c : 0)
                        + (dsa.Cost_of_Standard_Accessories__c != null ? dsa.Cost_of_Standard_Accessories__c : 0)
                        + (dsa.Cost_of_Accessories_Traded_Sold__c != null ? dsa.Cost_of_Accessories_Traded_Sold__c : 0)
                        + (otherDirectCost != null ? otherDirectCost : 0)
                        + (dsa.GST_Charge__c != null ? dsa.GST_Charge__c : 0)
                        + (dsa.Proposed_Commission__c != null ? dsa.Proposed_Commission__c : 0)
                        + (dsa.CPF_on_Comm__c != null ? dsa.CPF_on_Comm__c : 0)
                    ;
        return coeThresHold;
    }

    private static List<Sales_Agreement__c> getSAList(List<Map<String, String>> info)
    {
        Map<String, Schema.DescribeFieldResult> descriptions = getFieldDescription(getFieldTokens(getObjectToken('Sales_Agreement__c')));

        List<Sales_Agreement__c> saList = new List<Sales_Agreement__c>();
        for (Map<String, String> textValueMap : info)
        {
            Sales_Agreement__c SA = new Sales_Agreement__c();
            SA.put('Id', Id.valueOf(textValueMap.get('saId')));
 
            for (String api : textValueMap.keySet()) {
                if (!descriptions.keySet().contains(api)) continue;
                if (!descriptions.get(api).isUpdateable()) continue;

                String valueAsText = textValueMap.get(api);
                Schema.DisplayType type = descriptions.get(api).getType();
                switch on type {
                    when BOOLEAN {
                        SA.put(api, Boolean.valueOf( valueAsText ));
                    }
                    when CURRENCY {
                        SA.put(api, Decimal.valueOf( valueAsText ));
                    }
                    when ID {
                        SA.put(api, ID.valueOf( valueAsText ));
                    }
                    when INTEGER {
                        SA.put(api, Integer.valueOf( valueAsText ));
                    }
                    when LONG {
                        SA.put(api, Long.valueOf( valueAsText ));
                    }
                    when PERCENT {
                        SA.put(api, Decimal.valueOf( valueAsText ));
                    }
                    when DOUBLE {
                        SA.put(api, Double.valueOf( valueAsText ));
                    }
                    // when DATE {
                    //     SA.put(api, getDate( valueAsText ));
                    // }
                    when else {
                        SA.put(api, valueAsText);
                    }
                }

                saList.add(SA);
            }
        }

        system.debug(saList);
        return saList;
    }

    private static List<SA_COE_Bid_Period__c> getLatestSACOEBid(List<Map<String, String>> info){
        Map<String, Double> mapSaIdAndLatestBidAmount = new Map<String, Double>();
        for (Map<String, String> textValueMap : info)
        {
            String saId = Id.valueOf(textValueMap.get('saId'));
            for (String api : textValueMap.keySet()){
                Matcher bidFieldMatcher = Pattern.compile('(Bid_([0-9]){1,2}_Amount__c)').matcher(api);
                if(bidFieldMatcher.find()) {
                    mapSaIdAndLatestBidAmount.put(saId, Double.valueOf( textValueMap.get(api) ));
                }
            }
            
        }
        List<SA_COE_Bid_Period__c> latestBidToUpdate = new List<SA_COE_Bid_Period__c>();
         
        if(mapSaIdAndLatestBidAmount.size() > 0) {
            List<Sales_Agreement__c> saList = [ SELECT Id, Name,
                                                        ( SELECT Id, Bid_Amount__c
                                                        FROM SA_COE_Bid_Periods__r
                                                        ORDER BY CreatedDate DESC
                                                        LIMIT 1
                                                        )
                                                FROM Sales_Agreement__c                                            
                                                WHERE Id IN :mapSaIdAndLatestBidAmount.keySet()
                                            ];
            
            if(saList.size() > 0) {
                for(Sales_Agreement__c sa: saList) {
                    if(sa.SA_COE_Bid_Periods__r.size() > 0) {
                        SA_COE_Bid_Period__c saCoeBid = sa.SA_COE_Bid_Periods__r[0];
                        saCoeBid.Bid_Amount__c = mapSaIdAndLatestBidAmount.get(sa.Id);
                        latestBidToUpdate.add(saCoeBid);
                    }
                }
            }
        }       
       
        return latestBidToUpdate;
    }

    private static Schema.SObjectType getObjectToken(String Name) 
    {
        return Schema.getGlobalDescribe().get(Name);
    }

    private static Map<String, Schema.SObjectField> getFieldTokens(Schema.SObjectType token) 
    {
        return token.getDescribe().fields.getMap();
    }

    private static Map<String, Schema.DescribeFieldResult> getFieldDescription(Map<String, Schema.SObjectField> fieldTokens)
    {
        Map<String, Schema.DescribeFieldResult> fieldDescription = new map<string, Schema.DescribeFieldResult>();

        for (String fieldName : fieldTokens.keySet())
        {
            fieldDescription.put(fieldTokens.get(fieldName).getDescribe().getName(), fieldTokens.get(fieldName).getDescribe());
        }

        return fieldDescription;
    }
    
    
    @AuraEnabled
    public static void sendEmailToBSD(String franchise, String bidPeriodStartDate, String bidPeriodEndDate, String remarks, List<Sales_Agreement__c> dsaList)
    {
        List<UserRole> userRoles = [ SELECT Id from UserRole 
                                   WHERE Name = 'BSD'];

        List<Id> userRoleIds = new List<Id>();

        for(UserRole ur : userRoles){
            userRoleIds.add(ur.Id);
        }

        List<User> bsdUser = [  SELECT Id, Email 
                                FROM User
                                WHERE UserRole.Id IN : userRoleIds
                                AND IsActive = true
                            ];

        List<String> emailAddress = new List<String>();
        if(bsdUser.size()>0){
            for(User us : bsdUser){
                emailAddress.add(us.Email);
            }
            emailAddress.add('thanh.ly@aodigy.com');
        }

        System.debug('dsaList: ' + dsaList);


        // Html Email Body
        String htmlBody = '';
        htmlBody = 'Dear User, <br> COE Bids have been created by SMs: <br> Franchise: ' + franchise + '<br> Bid Period Start Dates: ' + bidPeriodStartDate + '<br> Bid Period End Dates: ' + bidPeriodEndDate + '<br> Remarks :' + remarks + '<br><br>';
            
        //open table
        htmlBody += '<table border="1" cellpadding="5" cellspacing="5" style="border-collapse: collapse">';
        htmlBody += '<tr style="background:rgb(0, 112, 210); color:#fff;"><th>Agreement No.</th><th>Agreement Date</th><th>Sales Consultant</th><th>Customer Name</th><th>Category</th><th>Bid Price</th><th>Total Of Bids</th></tr>';

        for(Sales_Agreement__c sa : dsaList){
            String name = sa.Name;
            String agreementDate = String.valueOf(sa.Agreement_Date__c);
            String consultant = sa.Sales_Consultant__c;
            String customer = sa.Customer_Full_Name__c;
            String bidCategory = sa.Bid_Category__c;
            String bidPrice = String.valueOf(sa.Bid_Price__c);

            String totalOfBid = '';
            if(sa.Bid_2_Amount__c == null){
                totalOfBid = '1';
            }
            else if(sa.Bid_3_Amount__c == null){
                totalOfBid = '2';
            }
            else if(sa.Bid_4_Amount__c == null){
                totalOfBid = '3';
            }
            else if(sa.Bid_5_Amount__c == null){
                totalOfBid = '4';
            }
            else if(sa.Bid_6_Amount__c == null){
                totalOfBid = '5';   
            }
            else if(sa.Bid_7_Amount__c == null){
                totalOfBid = '6';
            }
            else if(sa.Bid_8_Amount__c == null){
                totalOfBid = '7';
            }
            else if(sa.Bid_9_Amount__c == null){
                totalOfBid = '8';
            }
            else if(sa.Bid_10_Amount__c == null){
                totalOfBid = '9';
            }
            else if(sa.Bid_11_Amount__c == null){
                totalOfBid = '10';
            }
            else if(sa.Bid_12_Amount__c == null){
                totalOfBid = '11';
            }

            htmlBody += '<tr><td>' + name + '</td><td>' + agreementDate + '</td><td>' + consultant + '</td><td>' + customer + '</td><td>' + bidCategory + '</td><td>' + bidPrice + '</td><td>' + totalOfBid + '</td></tr>';
        }
    
        htmlBody += '</table>';
        system.debug('Email Body: ' + htmlBody);  


        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailAddress);
        mail.setHtmlBody(htmlBody); 
        mail.setSubject('COE Biddings were created');
        mail.setSaveAsActivity(false);
       
        System.debug('Send to Email Address :' + mail.getToAddresses());
        System.debug('Mail ::' + mail.getHtmlBody());
        mails.add(mail);

        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false); 

            for (Messaging.SendEmailResult rs : results) 
            {
                if (!rs.isSuccess()) 
                {
                    for(Messaging.SendEmailError err : rs.getErrors()) 
                    {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
                else
                {
                    System.debug('The email was sent successfully.');  
                }
            }  
        }
    }

    private static List<String> getSubmittedDSA(List<Id> dsaIds){
        List<String> saIds = new List<String>();
        List<SA_COE_Bid_Period__c> saCOEs = [SELECT Id, Status__c, Sales_Agreement__c, Sales_Agreement__r.Name FROM SA_COE_Bid_Period__c WHERE Sales_Agreement__c IN: dsaIds];
        for(SA_COE_Bid_Period__c saCOE : saCOEs){
            if(saCOE.Status__c == 'Pending'){
                saIds.add(saCOE.Sales_Agreement__c);
            }
        }
        return saIds;
    }

    public class BidCategoryWrapper 
    {        
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        private BidCategoryWrapper(String value, String label){
            this.value = value;
            this.label = label;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<BidCategoryWrapper> getBidCategoryValue(){
        List<BidCategoryWrapper> values = new List<BidCategoryWrapper>();
        Schema.DescribeFieldResult fieldResult = Sales_Agreement__c.Bid_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
                values.add(new BidCategoryWrapper(pickListVal.getValue(), pickListVal.getLabel()));
        }   
        return values;   
    }

    /**
     * ==================================================================================================================
     * Add method: Send email to SCs when SM unchecks "Verified by SC" from COE Bidding
     * @param dsaList: Selected SA list
     * @param userId: Id of user is editting
     * Created By: thanh.ly@aodigy.com
     * Created Date: Sep 3 2022
     * ==================================================================================================================
     */
    @AuraEnabled
    public static void sendEmailToSC(List<Id> dsaIds, Id userId)
    {
        // Get information from user who is editting
        List<Profile> editProfiles = [SELECT Id FROM Profile WHERE Name = 'CITCV Sales Manager' OR Name = 'CITPC Sales Manager' OR Name = 'KIAPC Sales Manager' OR Name = 'MITPC Sales Manager' OR Name = 'System Administrator'];

        List<Id> editProfileIds = new List<Id>();
        for (Profile editProfile : editProfiles){
            editProfileIds.add(editProfile.Id);
        }

        List<User> users = [SELECT Id, Name FROM User WHERE ProfileId IN :editProfileIds AND isActive = true];

        Map<Id, User> userMap = new Map<Id, User>();
        if (users.size() > 0){
            for (User user : users){
                userMap.put(user.Id, user);
            }
        }

        // Get emails from SCs
        List<Profile> ownerProfiles = [SELECT Id FROM Profile WHERE Name = 'CITCV Sales' OR Name = 'CITPC Sales' OR Name = 'KIAPC Sales' OR Name = 'MITPC Sales' OR Name = 'System Administrator']; 
        
        List<Id> ownerProfileIds = new List<Id>();
        for (Profile ownerProfile : ownerProfiles){
            ownerProfileIds.add(ownerProfile.Id);
        }
        
        List<User> owners = [SELECT Id, Email FROM User WHERE ProfileId IN :ownerProfileIds AND isActive = true];

        Map<Id, User> ownerMap = new Map<Id, User>();
        if (owners.size() > 0){
            for (User owner : owners){
                ownerMap.put(owner.Id, owner);
            }
        }

        System.debug('List owner ::' + ownerMap);
        System.debug('dsaList: ' + dsaIds);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Sales_Agreement__c> dsaList = [SELECT Id, Verified_by_Sales_Consultant__c, Name, OwnerId FROM Sales_Agreement__c WHERE Id IN :dsaIds];
        for(Sales_Agreement__c sa : dsaList)
        {
            if(!sa.Verified_by_Sales_Consultant__c && userMap.containsKey(userId)){
                System.debug('Start here !');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
                mail.setToAddresses(new List<String>{ownerMap.get(sa.OwnerId).Email, 'thanh.ly@aodigy.com'});
                mail.setSubject('COE Bidding Rejection');
                mail.setHtmlBody(userMap.get(userId).Name + ' has rejected ' + sa.Name + ' from COE Bidding. Please contact them for more information.');
                System.debug('Send to Email Address :' + mail.getToAddresses());
                mails.add(mail);
            }
        } 
        
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false); 

            for (Messaging.SendEmailResult rs : results) 
            {
                if (!rs.isSuccess()) 
                {
                    for(Messaging.SendEmailError err : rs.getErrors()) 
                    {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
                else
                {
                    System.debug('The email was sent successfully.');  
                }
            }  
        }
    }
}