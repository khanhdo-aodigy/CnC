/** ******
 * Description : Controller for MB Stock Reservation page
 * 
 * Change History:
 * Date(YYYY-MM-DD)  	 	Name        				Description
 * 2020-09-01          	    Phap & Vu                   Created Initial Version.
 * 2021-07-15               khanh.do@aodigy.com         Added Person Account Profiling creation
 * 
** ******/
public with sharing class MB_StockReservationCtrl {

    private final static String CONST_PA_PROFILING_MB = 'MB_Person_Account_Profiling_RT';

    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecords(String objNm, String fieldReference, String fieldValue, String additionalConditions) 
    {
        String mainQueryCondition = fieldReference + ' = ' + '\'' + fieldValue + '\'';
        
        if (additionalConditions != null && String.isNotBlank(additionalConditions)) {
            mainQueryCondition = mainQueryCondition + ' ' + additionalConditions;
        }

        List<sObject> records = ADGLIB_UtilityHelper.getSObjectRecords(objNm, mainQueryCondition, false); 
        return records;
    }

    @AuraEnabled(cacheable=true)
    public static TrimColourWrapper getAvailableTrimColour(String variantDesc) 
    {
        String mainCondition = 'VariantDescription__c = \'' + variantDesc + '\' AND Status__c = \'Open\' AND RecordType.Name = \'Existing Stock\' AND Variant__r.Active__c = true';
 
        ADGLIB_QueryFactory factory;
        factory = new ADGLIB_QueryFactory(getObjectToken('MB_Stock_Vehicle_Master__c'));
        factory.selectFields(getFieldTokens(getObjectToken('MB_Stock_Vehicle_Master__c')).values());
        factory.setCondition(mainCondition);

        List<MB_Stock_Vehicle_Master__c> records = (List<MB_Stock_Vehicle_Master__c>) Database.query(factory.toSOQL());

        if (records.size() == 0) return null;

        TrimColourWrapper wrapper = new TrimColourWrapper();
        for (MB_Stock_Vehicle_Master__c record : records) {
            if (String.isNotBlank(record.Colour__c)) {
                wrapper.colours.add(record.Colour__c.substring(0,3));
            }

            if (String.isNotBlank(record.Trim__c)) {
                wrapper.trims.add(record.Trim__c.substring(0,3));
            }

            /* ------------------------ MB CR 20/09/2021 - EDD options - START ---------------------- */
            if (String.isNotBlank(record.Estimated_Delivery_Date__c)) {
                wrapper.edds.add(record.Estimated_Delivery_Date__c.left(2));
            }
            /* ------------------------ MB CR 20/09/2021 - EDD options - END ---------------------- */
        }

        system.debug('result wrapper:: ' + wrapper);
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<MB_Build_Spec__c> getAvailableHighlightOptions(String variantId) 
    {
        List<MB_Build_Spec__c> records = getRecords('MB_Build_Spec__c', 'Variant__c', variantId, 'AND Highlight_Option__c = true AND Variant__r.Active__c = true');

        return records;
    }

    /* -------- ADDED BY THIEU DANG VU - Mon 16th Nov 2020 -- START --------*/
    @AuraEnabled(cacheable=true)
    public static List<MB_Promotion__c> getPromotion()
    {
        String mainCondition = 'Active__c = true';

        ADGLIB_QueryFactory factory;
        factory = new ADGLIB_QueryFactory(getObjectToken('MB_Promotion__c'));
        factory.selectFields(getFieldTokens(getObjectToken('MB_Promotion__c')).values());
        factory.setCondition(mainCondition);
        factory.setOrdering('Start_Date__c', ADGLIB_QueryFactory.SortOrder.ASCENDING, true);

        List<MB_Promotion__c> records = (List<MB_Promotion__c>) Database.query(factory.toSOQL());

        return records;
    }
    /* -------- ADDED BY THIEU DANG VU - Mon 16th Nov 2020 -- END --------*/

    /**
     * check if a variant is indentable
     */
    @AuraEnabled
    public static boolean checkIndentable(String variantID) 
    {

        List<Variant__c> variants = [SELECT Allow_Indent__c FROM Variant__c WHERE ID = :variantID];

        if (variants.size() < 1) {
            throw new AuraHandledException('Found no variant');
        } else if (variants.size() > 1) {
            throw new AuraHandledException('Non-unique variant');
        } else {
            return variants[0].Allow_Indent__c;
        }
    }

    /**
     * get available stock with certain variant, colors and trims
     * @param HLOs: selected hightlight options
     */
    @AuraEnabled(cacheable = true)
    public static List<MB_Stock_Vehicle_Master__c> getStock(String variantDesc, List<String> colors, List<String> trims, List<String> HLO, String promoId, String edd) 
    {
        System.debug('variant desc :: ' + variantDesc);
        System.debug('colors :: ' + colors);
        System.debug('trims :: ' + trims);
        System.debug('HLOs :: ' + HLO);
        System.debug('Promo :: ' + promoId);
        System.debug('EDD :: ' + edd);

        String mainCondition = 'VariantDescription__c = \'' + variantDesc + '\' AND Status__c = \'Open\' AND RecordType.Name = \'Existing Stock\' AND Variant__r.Active__c = true';

        ADGLIB_QueryFactory factory;
        factory = new ADGLIB_QueryFactory(getObjectToken('MB_Stock_Vehicle_Master__c'));
        factory.selectFields(getFieldTokens(getObjectToken('MB_Stock_Vehicle_Master__c')).values());
        factory.setCondition(mainCondition);
        factory.setOrdering('Production_Month__c', ADGLIB_QueryFactory.SortOrder.ASCENDING, true);

        ADGLIB_QueryFactory promotionFactory;
        promotionFactory = factory.subselectQuery(getObjectToken('MB_Promotion_Stock__c'));
        promotionFactory.selectFields(getFieldTokens(getObjectToken('MB_Promotion_Stock__c')).values());
        promotionFactory.setCondition('Active__c = true');
        promotionFactory.selectFields(new Set<String>{'MB_Promotion__r.Start_Date__c', 'MB_Promotion__r.End_Date__c', 'MB_Promotion__r.Description__c', 'MB_Promotion__r.Name'});


        ADGLIB_QueryFactory svmSpecFactory;
        svmSpecFactory = factory.subselectQuery(getObjectToken('MB_SVM_Spec__c'));
        svmSpecFactory.selectFields(new Set<String>{'Description__c', 'Product__c', 'Sequence__c'});
        svmSpecFactory.setOrdering('Sequence__c', ADGLIB_QueryFactory.SortOrder.ASCENDING, true);

        /* -------- ADDED BY THIEU DANG VU - 20/09/2021 -- MB CR - START --------*/
        ADGLIB_QueryFactory mbSAFactory;
        mbSAFactory = factory.subselectQuery(getObjectToken('MB_Sales_Agreement__c'));
        mbSAFactory.selectFields(new Set<String>{'Id','Status__c'});
        /* -------- ADDED BY THIEU DANG VU - 20/09/2021 -- MB CR - END --------*/

        List<MB_Stock_Vehicle_Master__c> records = (List<MB_Stock_Vehicle_Master__c>) Database.query(factory.toSOQL());

        List<MB_Build_Spec__c> buildSpecs = new List<MB_Build_Spec__c>();
        ADGLIB_QueryFactory buildSpecFactory = new ADGLIB_QueryFactory(getObjectToken('MB_Build_Spec__c'));
        buildSpecFactory.selectFields(new Set<String>{'Option_Code__c'});
        if (HLO != null && HLO.size() > 0) {
            buildSpecFactory.setCondition('ID IN (' + String.join(addQuotationMark(HLO), ',') + ')');
        } else {
            buildSpecFactory.setCondition('Highlight_Option__c = true AND Variant__r.Description__c = \'' + variantDesc + '\'');
        }
        buildSpecs = (List<MB_Build_Spec__c>) Database.query(buildSpecFactory.toSOQL());

        Set<String> optionCodes = slice(buildSpecs, 'Option_Code__c');

        List<MB_Stock_Vehicle_Master__c> result = new List<MB_Stock_Vehicle_Master__c>();
        Set<String> tmpProductCodes;
		Set<String> productCodes;
        Set<String> promoIds;
        for (MB_Stock_Vehicle_Master__c record : records) {
            Boolean matchColor = false;
            Boolean matchTrim = false;
            Boolean matchHLO = false;
            Boolean matchPromo = false;                     // ADDED BY THIEU DANG VU - 17/11/2020 - UAT LOG-0192
            Boolean matchEDD = false;                       // ADDED BY THIEU DANG VU - 02/12/2020 - UAT LOG-0193
            Boolean matchMBSA = true;                       // ADDED BY THIEU DANG VU - 20/09/2021 - MB CR

            for (String color : colors) {
                if (String.isNotEmpty(record.Colour__c) && record.Colour__c.startsWith(color)) {
                    matchColor = true;
                    break;
                }
            }

            for (String trim : trims) {
                if (String.isNotEmpty(record.Trim__c) && record.Trim__c.startsWith(trim)) {
                    matchTrim = true;
                    break;
                }
            }

            productCodes = new Set<String>();
            for (MB_SVM_Spec__c svmSpec : record.MB_SVM_Specs__r) {
                if (String.isNotBlank(svmSpec.Product__c)) productCodes.add(svmSpec.Product__c);
            }
            system.debug('productCodes:: ' + productCodes);
            if (productCodes.size() > 0) {
                // If selected HLOs empty then only return Stocks with no highlight options
                // If selected HLOs not empty then return Stocks has selected HLOs
                if (!HLO.isEmpty()) {
                    if (productCodes.containsAll(optionCodes)) matchHLO = true;
                } else {
                    // Have a temporary set to contains any overlapping values
                    // If temporary set not empty then Stock has at least 1 highlight options
                    // If temporary set empty then Stock has no highlight options
                    tmpProductCodes = new Set<String>();
                    tmpProductCodes.addAll(productCodes);
                    tmpProductCodes.retainAll(optionCodes);
                    system.debug('product codes are hlos :: ' + tmpProductCodes);

                    if (tmpProductCodes.isEmpty()) matchHLO = true; 
                }
            }

            /*-------------- ADDED BY THIEU DANG VU - 17/11/2020 - UAT LOG-0192 - START --------------- */
            if (promoId == null) {
                matchPromo = true;
            } else /*if (record.MB_Promotions__r != null && record.MB_Promotions__r.size() > 0)*/ {
                // Set<String> promoIds = slice(record.MB_Promotions__r, 'MB_Promotion__c');
                promoIds = new Set<String>();
                for (MB_Promotion_Stock__c promotion : record.MB_Promotions__r) {
                    promoIds.add(promotion.MB_Promotion__c);
                }
                if (promoIds.contains(promoId)) matchPromo = true;
            }
            /*-------------- ADDED BY THIEU DANG VU - 17/11/2020 - UAT LOG-0192 - END --------------- */

            /*-------------- ADDED BY THIEU DANG VU - 02/12/2020 - UAT LOG-0193 - START --------------- */
            if (edd == null) {
                matchEDD = true;
            } else {
                // MODIFIED BY THIEU DANG VU - 16/09/2021 - MB CR
                if (String.isNotEmpty(record.Estimated_Delivery_Date__c) && record.Estimated_Delivery_Date__c.left(2).equals(edd)) matchEDD = true;
            }
            /*-------------- ADDED BY THIEU DANG VU - 02/12/2020 - UAT LOG-0193 - END --------------- */

            /* -------- ADDED BY THIEU DANG VU - 20/09/2021 -- MB CR - START --------*/
            for (MB_Sales_Agreement__c mbSA : record.MB_Sales_Agreements__r) {
                if (!mbSA.Status__c.equals('Cancelled')) {
                    matchMBSA = false;
                    break;
                }
            }
            /* -------- ADDED BY THIEU DANG VU - 20/09/2021 -- MB CR - END --------*/

            system.debug(record.Name + ' Color:: ' + record.Colour__c);
            system.debug(record.Name + ' Trim:: ' + record.Trim__c);
            system.debug(record.Name + ' MATCH PROMO:: ' + matchPromo);
            system.debug(record.Name + ' MATCH HLO:: ' + matchHLO);
            system.debug(record.Name + ' MATCH EDD:: ' + matchEDD);
            system.debug(record.Name + ' MATCH MBSA:: ' + matchMBSA);

            if (matchColor && matchTrim && matchHLO && matchPromo && matchEDD && matchMBSA) result.add(record);
        }

        return result;
    }

    /*-------------- ADDED BY THIEU DANG VU - 06/01/2021 - START --------------- */
    @AuraEnabled
    public static List<MB_Stock_Vehicle_Master__c> getVariantDescription(String modelId) {
        try {
            String mainCondition = 'Status__c = \'Open\' AND RecordType.Name = \'Existing Stock\' AND Variant__r.Active__c = true AND Variant__r.Model_ID__c = \'' + modelId + '\'';

            ADGLIB_QueryFactory factory;
            factory = new ADGLIB_QueryFactory(getObjectToken('MB_Stock_Vehicle_Master__c'));
            factory.selectFields(getFieldTokens(getObjectToken('MB_Stock_Vehicle_Master__c')).values());
            factory.setCondition(mainCondition);
            factory.setOrdering('VariantDescription__c', ADGLIB_QueryFactory.SortOrder.ASCENDING, true);

            List<MB_Stock_Vehicle_Master__c> records = (List<MB_Stock_Vehicle_Master__c>) Database.query(factory.toSOQL());

            Map<String, MB_Stock_Vehicle_Master__c> stockMap = new Map<String, MB_Stock_Vehicle_Master__c>();
            for (MB_Stock_Vehicle_Master__c stock : records) {
                stockMap.put(stock.VariantDescription__c, stock);
            }

            return stockMap.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*-------------- ADDED BY THIEU DANG VU - 06/01/2021 - END --------------- */

    /**
     * search business contact by phone and email
     * @param isUnion: true equal OR operator, false equal AND operator
     * @param Mobile: searched mobile number
     * @param Email: searched email
     * @param moreConditions: more condition to SOQL
     */
    @AuraEnabled
    public static List<Contact> searchBusinessContact(String Mobile, String Email, String moreConditions, Boolean isUnion)
    {
        Boolean haveMobile = Mobile != null && String.isNotBlank(Mobile) && String.isNotEmpty(Mobile);
        Boolean haveEmail = Email != null && String.isNotBlank(Email) && String.isNotEmpty(Email);

        isUnion = isUnion == null? false : isUnion;

        if (!haveMobile && !haveEmail) return null;

        String mobileCondition = haveMobile? 'MobilePhone = ' + '\'' + Mobile + '\'' : '';
        String emailCondition = haveEmail? 'Email = ' + '\'' + Email + '\'' : '';

        String OR_CLAUSE = (haveMobile && haveEmail)? ' OR ' : '';
        String AND_CLAUSE = (haveMobile && haveEmail)? ' AND ' : '';

        String condition = isUnion? '(' + mobileCondition + OR_CLAUSE + emailCondition + ')' : '(' + mobileCondition + AND_CLAUSE + emailCondition + ')';
        if (moreConditions != null && String.isNotBlank(moreConditions)) condition += ' ' + moreConditions;
        condition += ' ORDER BY CreatedDate DESC';

        List<Contact> results = (List<Contact>) ADGLIB_UtilityHelper.getSObjectRecords('Contact', condition, true); 

        return results;
    }

    /**
     * search person account by phone and email
     * @param isUnion: true equal OR operator, false equal AND operator
     * @param Mobile: searched mobile number
     * @param Email: searched email
     * @param moreConditions: more condition to SOQL
     */
    @AuraEnabled
    public static List<Account> searchPersonAccount(String Mobile, String Email, String moreConditions, Boolean isUnion)
    {
        Boolean haveMobile = Mobile != null && String.isNotBlank(Mobile) && String.isNotEmpty(Mobile);
        Boolean haveEmail = Email != null && String.isNotBlank(Email) && String.isNotEmpty(Email);

        isUnion = isUnion == null? false : isUnion;

        if (!haveMobile && !haveEmail) return null;

        String mobileCondition = haveMobile? 'PersonMobilePhone = ' + '\'' + Mobile + '\'' : '';
        String emailCondition = haveEmail? 'PersonEmail = ' + '\'' + Email + '\'' : '';

        String OR_CLAUSE = (haveMobile && haveEmail)? ' OR ' : '';
        String AND_CLAUSE = (haveMobile && haveEmail)? ' AND ' : '';

        String condition = isUnion? '(' + mobileCondition + OR_CLAUSE + emailCondition + ')' : '(' + mobileCondition + AND_CLAUSE + emailCondition + ')';
        if (moreConditions != null && String.isNotBlank(moreConditions)) condition += ' ' + moreConditions;
        condition += ' ORDER BY CreatedDate DESC';

        List<Account> results = (List<Account>) ADGLIB_UtilityHelper.getSObjectRecords('Account', condition, true); 

        return results;
    }

    /**
     * create new sales agreement
     * @param c_input: map of customer infomation from UI in stringify format (to avoid error with Date type)
     * @param i_input: map of indent vehicle infomation from UI in stringify format (to avoid error with Date type)
     */
    @AuraEnabled
    public static ID createSalesAgreement(String c_input, String i_input) 
    {
        Savepoint sp = Database.setSavepoint();
        Boolean isExistStock = i_input == '{}';

        Map<String, String> c_configuration = toMap(c_input);
        Map<String, String> i_configuration = isExistStock? null : toMap(i_input);

        try {
            return createSalesAgreement(isExistStock, c_configuration, i_configuration);
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }

    /**
     * ADDED BY THIEU DANG VU - 27/09/2021 - MB CR
     * Process pending stock
     * @param curMBSAId: record id of current new MB Sales Agreement
     */
    @AuraEnabled
    public static void processPrevPendingStock(Id curMBSAId) {
        List<MB_Sales_Agreement__c> curMBSAs = getRecords('MB_Sales_Agreement__c', 'Id', curMBSAId, null);

        List<MB_Stock_Vehicle_Master__c> prevStocks = getRecords('MB_Stock_Vehicle_Master__c', 'Vehicle_Id__c', curMBSAs[0].Previous_Stock_Number__c, 'AND Status__c = \'Pending\'');

        if (prevStocks.size() == 0) {
            throw new AuraHandledException('No stock with Vehicle Id ' + curMBSAs[0].Previous_Stock_Number__c + ' found.');
        } else if (prevStocks.size() > 1) {
            throw new AuraHandledException('Many stocks with Vehicle Id ' + curMBSAs[0].Previous_Stock_Number__c + ' found.');
        }

        // Update previous stock
        prevStocks[0].Autoline_Sales_Order__c = null;
        prevStocks[0].Autoline_Order_Date__c = null;
        prevStocks[0].Status__c = 'Open';

        // Update latest Cancelled MBSA from previous stock
        List<MB_Sales_Agreement__c> cancelledMBSAs = getRecords('MB_Sales_Agreement__c', 'MB_Stock_Vehicle_Master__c', prevStocks[0].Id, 'AND Status__c = \'Cancelled\' ORDER BY CreatedDate DESC');
        cancelledMBSAs[0].Status_Autoline__c = null;

        // Update current new MB Sales Agreement
        curMBSAs[0].Previous_Stock_Number__c = null;

        List<sObject> updatedRecords = new List<sObject>{prevStocks[0],cancelledMBSAs[0],curMBSAs[0]};
        try {
            update updatedRecords;
        } catch (DMLException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * create new sales agreement
     */
    private static ID createSalesAgreement(Boolean isExistStock, Map<String, String> c_configuration, Map<String, String> i_configuration)
    {
        System.debug(c_configuration);
        MB_Sales_Agreement__c SA = newSalesAgreement(c_configuration);
        MB_Stock_Vehicle_Master__c SVM = isExistStock? updateStockStatus(SA.MB_Stock_Vehicle_Master__c) : createIndentStock(i_configuration);

        Boolean isRegisterUnderCompany = c_configuration.get('__isRegisterUnderCompany') == 'true'? true : false;

        String BCID = c_configuration.get('__matchBC');                             // matching business contact from UI searching
        String PAID = c_configuration.get('__matchPA');                             // matching person account from UI searching
        
        Boolean isNewBC = BCID == null? true : false;
        Boolean isNewPA = PAID == null? true : false;

        ID AID;                                                                     // ID of Sales Agreement's account
        ID CID;                                                                     // ID of Sales Agreement's business contact

        switch on c_configuration.get('Registration_Type__c') {
            when 'P' {
                if (isRegisterUnderCompany)
                {
                    if (isNewBC) {
                        Account BA = newBusinessAccount(c_configuration);
                        insert BA;
                        Contact BC = newBusinessContact(c_configuration);
                        BC.Account__c = BA.ID;
                        insert BC;
                        AID = BA.ID;
                        CID = BC.ID;
                    }

                    if (!isNewBC) {
                        Account BA = getParentAccount(BCID);
                        AID = BA != null? BA.ID : AID;
                        CID = BCID;
                    }
                }

                if (!isRegisterUnderCompany)
                {
                    if (isNewPA) {
                        Account PA = newPersonAccount(c_configuration);
                        insert PA;
                        //Added by Khanh: create PA Profiling
                        AccountUtil.createProfiling(CONST_PA_PROFILING_MB, pa);

                        AID = PA.ID;
                    }

                    if (!isNewPA) {
                        AID = PAID;
                    }
                }
            }

            when 'C' {
                if (isNewBC) {
                    Account BA = newBusinessAccount(c_configuration);
                    insert BA;
                    Contact BC = newBusinessContact(c_configuration);
                    BC.Account__c = BA.ID;
                    insert BC;

                    AID = BA.ID;
                    CID = BC.ID;
                }

                if (!isNewBC) {
                    Account BA = getParentAccount(BCID);
                    AID = BA != null? BA.ID : AID;
                }
            }
            when else {
                throw new AuraHandledException('Unknow Registration Type: ' + c_configuration.get('Registration_Type__c'));
            }

        }
        if (AID != null ) SA.put('Account__c', AID);
        if (CID != null) SA.put('Contact__c', CID);

        try {
            upsert SVM;

            SA.MB_Stock_Vehicle_Master__c = SVM.ID;
            /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- START --------*/
            Date currentDate = System.today();
            SA.Booking_Date__c = currentDate;
            SA.Modified_Date__c = currentDate;
            /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- END --------*/

            insert SA;
        } catch (Exception e) {
            throw new AuraHandledException('Error on committing sales agreement: ' + e.getMessage());
        }
        
        List<MB_SA_Spec__c> nSpecs = convertSpec(SA.MB_Stock_Vehicle_Master__c, SA.ID);
        try {
            insert nSpecs;
        } catch (Exception e) {
            throw new AuraHandledException('Error on committing SA Specs: ' + e.getMessage());
        }

        return sa.ID;
    }

    private static Date getDate(String dateLiteral) 
    {
        if (dateLiteral == null) return null;
        List<String> dateComponents = dateLiteral.split('-');
        Integer yyyy = Integer.valueOf(dateComponents[0]);
        Integer mm = Integer.valueOf(dateComponents[1]);
        Integer dd = Integer.valueOf(dateComponents[2]);
        return Date.newInstance(yyyy, mm, dd);
    }

    private static Map<String, String> toMap(String input)
    {
        return (Map<String, String>) JSON.deserialize(input, Map<String, String>.class);
    }

    private static MB_Sales_Agreement__c newSalesAgreement(Map<String, String> configuration) 
    {
        Map<String, Schema.DescribeFieldResult> descriptions = getFieldDescription(getFieldTokens(getObjectToken('MB_Sales_Agreement__c')));
        
        MB_Sales_Agreement__c SA = new MB_Sales_Agreement__c();

        for (String api : configuration.keySet()) {

            if (!descriptions.keySet().contains(api)) continue;
            if (!descriptions.get(api).isUpdateable()) continue;

            String valueAsText = configuration.get(api);
            System.debug(api + ' -- ' + valueAsText);
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
                when DATE {
                    SA.put(api, getDate( valueAsText ));
                }
                when else {
                    SA.put(api, valueAsText);
                }
            }
        }

        return SA;
    }

    private static MB_Stock_Vehicle_Master__c updateStockStatus(ID stockID) 
    {
        
        List<MB_Stock_Vehicle_Master__c> stocks = [SELECT Status__c FROM MB_Stock_Vehicle_Master__c WHERE ID = :stockID AND Status__c = 'Open'];

        if (stocks.size() < 1) {
            throw new AuraHandledException('This vehicle is no longer open.');
        } else if (stocks.size() > 1) {
            throw new AuraHandledException('Found more than one stock with this stock ID.');
        } else {
            stocks[0].Status__c = 'Reserved';
        }

        return stocks[0];
    }

    private static Account newPersonAccount(Map<String, String> configuration) 
    {
        Account pa = new Account();
        pa.Full_Name__pc            = configuration.get('Customer_Full_Name__c');
        pa.PersonMobilePhone        = configuration.get('CMobile__c');
        pa.PersonEmail              = configuration.get('CEmail_Address__c');
        pa.FirstName                = configuration.get('CFirst_Name__c');
        pa.LastName                 = configuration.get('CSurname__c');
        pa.RecordTypeId             = AccountUtil.getProspectRecordTypeId();

        Id defaultAcctID            = AccountUtil.getDefaultAccountOwnerId();

        if (defaultAcctID != null) pa.OwnerId = defaultAcctID;
        return pa;
    }

    private static Account newBusinessAccount(Map<String, String> configuration)
    {
        Id BUSINESS_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        Account ba = new Account();
        ba.RecordTypeId             = BUSINESS_ACCOUNT;
        ba.Name                     = configuration.get('Company_Name__c');
        ba.Type                     = 'Prospect';

        return ba;
    }

    private static Contact newBusinessContact(Map<String, String> configuration)
    {
        Contact bc = new Contact();
        bc.Full_Name__c             = configuration.get('Customer_Full_Name__c');
        bc.MobilePhone              = configuration.get('CMobile__c');
        bc.Email                    = configuration.get('CEmail_Address__c');
        bc.FirstName                = configuration.get('CFirst_Name__c');
        bc.LastName                 = configuration.get('CSurname__c');

        return bc;
    }

    /**
     * from business contact ID get parent business account
     */
    private static Account getParentAccount(String BCID)
    {
        List<Contact> BC = [SELECT Account__c FROM Contact WHERE ID = :BCID];

        if (BC.size() > 0) {
            List<Account> accounts = [SELECT ID FROM Account WHERE ID = :BC[0].Account__c];

            if (accounts.size() > 0) return accounts[0];
        }
        
        return null;
    }

    private static MB_Stock_Vehicle_Master__c createIndentStock(Map<String, String> configuration) 
    {
        Map<String, Schema.DescribeFieldResult> descriptions = getFieldDescription(getFieldTokens(getObjectToken('MB_Stock_Vehicle_Master__c')));
        
        MB_Stock_Vehicle_Master__c indentStock = new MB_Stock_Vehicle_Master__c();

        for (String api : configuration.keySet()) {

            if (!descriptions.keySet().contains(api)) continue;
            if (!descriptions.get(api).isUpdateable()) continue;

            String valueAsText = configuration.get(api);
            Schema.DisplayType type = descriptions.get(api).getType();
            switch on type {
                when BOOLEAN {
                    indentStock.put(api, Boolean.valueOf( valueAsText ));
                }
                when CURRENCY {
                    indentStock.put(api, Decimal.valueOf( valueAsText ));
                }
                when ID {
                    indentStock.put(api, ID.valueOf( valueAsText ));
                }
                when INTEGER {
                    indentStock.put(api, Integer.valueOf( valueAsText ));
                }
                when LONG {
                    indentStock.put(api, Long.valueOf( valueAsText ));
                }
                when PERCENT {
                    indentStock.put(api, Decimal.valueOf( valueAsText ));
                }
                when DATE {
                    indentStock.put(api, getDate( valueAsText ));
                }
                when else {
                    indentStock.put(api, valueAsText);
                }
            }
        }

        Id recordTypeID = Schema.SObjectType.MB_Stock_Vehicle_Master__c.getRecordTypeInfosByDeveloperName().get('Indent_Stock').getRecordTypeId(); 
        indentStock.RecordTypeId = recordTypeID;

        return indentStock;
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

        for (String fieldName : fieldTokens.keySet()) {
            fieldDescription.put(fieldTokens.get(fieldName).getDescribe().getName(), fieldTokens.get(fieldName).getDescribe());
        }

        return fieldDescription;
    }

    /**
     * convert SVM Spec into SA Spec
     */
    private static List<MB_SA_Spec__c> convertSpec(ID stockID, ID SAID)
    {
        String variantID = [SELECT VariantId__c FROM MB_Sales_Agreement__c WHERE ID = :SAID].VariantId__c;     // cross object formula field
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT Id, Variant__r.Model_Id__c FROM MB_Stock_Vehicle_Master__c WHERE ID = :stockID];
        String modelId;
        if (mbSVM != null) {
            modelId = mbSVM.Variant__r.Model_Id__c;
        }

        List<MB_SVM_Spec__c> oSpecs = getRecords('MB_SVM_Spec__c', 'MB_Stock_Vehicle_Master__c', stockID, null);

        List<MB_Build_Spec__c> hlSpecs = getRecords('MB_Build_Spec__c', 'Variant__c', variantID, 'AND Highlight_Option__c = true');

        /* ------------------------ ADDED BY THIEU DANG VU 20/01/2020 - START ---------------------- */
        String defaultGroupSpecConditions = 'Option_Group__c = \'DEFAULT\' AND ' + 
                                            '((Model__c =\'' + modelId + '\' AND Variant__c =\'' + variantID + '\') OR (Model__c =\'\' AND Variant__c =\'\') OR (Model__c =\'' + modelId + '\' AND Variant__c =\'\'))';

        List<MB_Build_Spec__c> defaultOptionGroupSpecs = (List<MB_Build_Spec__c>) ADGLIB_UtilityHelper.getSObjectRecords('MB_Build_Spec__c', defaultGroupSpecConditions, false); 
        /* ------------------------ ADDED BY THIEU DANG VU 20/01/2020 - END ---------------------- */

        Set<String> hlSpecCodes = slice(hlSpecs, 'Option_Code__c');

        List<MB_SA_Spec__c> nSpecs = new List<MB_SA_Spec__c>();

        for (MB_SVM_Spec__c oSpec : oSpecs) 
        {
            MB_SA_Spec__c nSpec = new MB_SA_Spec__c();
            nSpec.MB_Sales_Agreement__c = SAID;
            nSpec.Description__c = oSpec.Description__c;
            nSpec.Fit_Type__c = 'S';
            nSpec.Invoice_Value__c = oSpec.Invoice_Value__c;
            nSpec.OptKey__c = oSpec.Optkey__c;
            nSpec.OType__c = oSpec.OType__c;
            nSpec.Product_Code__c = oSpec.Product__c;
            nSpec.Sequence__c = oSpec.Sequence__c;
            nSpec.PRINT__c = hlSpecCodes.contains(oSpec.Product__c)? 'Y' : 'N';
            nSpecs.add(nSpec);
        }

        /* ------------------------ ADDED BY THIEU DANG VU 20/01/2020 - START ---------------------- */
        if (defaultOptionGroupSpecs.size() > 0) {
            Set<String> oSpecCodes = slice(oSpecs, 'Product__c');
            for (MB_Build_Spec__c buildSpec : defaultOptionGroupSpecs) {
                if (oSpecCodes.contains(buildSpec.Option_Code__c)) continue;

                MB_SA_Spec__c nSpec = new MB_SA_Spec__c();
                nSpec.MB_Sales_Agreement__c = SAID;
                nSpec.Description__c = buildSpec.Description__c;
                nSpec.Fit_Type__c = 'S';
                nSpec.Invoice_Value__c = buildSpec.Invoice_Price__c;
                nSpec.Product_Code__c = buildSpec.Option_Code__c;
                nSpec.PRINT__c = 'Y';
                nSpecs.add(nSpec);
            }
        }
        /* ------------------------ ADDED BY THIEU DANG VU 20/01/2020 - END ---------------------- */

        return nSpecs;
    }

    private static List<String> addQuotationMark(List<String> lstr)
    {
        List<String> results = new List<String>();
        for (String str : lstr) {
            results.add('\'' + str + '\'');
        }
        return results;
    }

    private static Set<String> slice(List<SObject> records, String API)
    {
        Set<String> result = new Set<String>();

        for (SObject record : records) {
            if (record.get(API) != null) result.add((String)record.get(API));
        }

        return result;
    }

    public class TrimColourWrapper 
    {
        @AuraEnabled public Set<String> colours {get;set;}
        @AuraEnabled public Set<String> trims {get;set;}
        @AuraEnabled public Set<String> edds {get;set;}                    // MB CR 24/03/2021 - EDD options

        public TrimColourWrapper() {
            colours = new Set<String>();
            trims = new Set<String>();
            edds = new Set<String>();                                      // MB CR 24/03/2021 - EDD options
        }
    }
}