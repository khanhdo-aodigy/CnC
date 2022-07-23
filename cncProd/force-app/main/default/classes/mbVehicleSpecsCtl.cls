public with sharing class mbVehicleSpecsCtl {

    /**
     * wrapper class for spec data
     */
    public class SpecData {
        @AuraEnabled public SObject SA { get; set; }
        @AuraEnabled public List<SObject> specs { get; set; }
    }

    /**
     * get sales agreement together with its specs
     */
    @AuraEnabled(cacheable=true)
    public static SpecData getSpecData(String recordID) 
    {
        // throw new AuraHandledException('TEST');
        SpecData returnWrap = new SpecData();
        returnWrap.SA = getRecords('MB_Sales_Agreement__c', 'ID', recordID,  '')[0];
        returnWrap.specs = getRecords('MB_SA_Spec__c', 'MB_Sales_Agreement__c', recordID, ' AND PRINT__C = \'Y\'');
        return returnWrap;
    }

    /**
     * 
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> doGetAvailableSpecs(String VariantId, String ModelId, String Keyword) 
    {
        List<sObject> BuildSpecRecords = new List<sObject>();
        //Conditions: Only AVCODE O and S + Only Option Type D and F + Model and Variant of stock OR Model of stocks with empty variant OR both model and variant empty
        string AdditionalCondition = '(AVCODE__c =\'O\' OR AVCODE__c = \'S\') AND (Option_Type__c =\'D\' OR Option_Type__c = \'F\')';
        string ModelVariantCondition = '((Model__c =\'' + ModelId + '\' AND Variant__c =\'' + VariantId + '\') OR (Model__c =\'\' AND Variant__c =\'\') OR (Model__c =\'' + ModelId + '\' AND Variant__c =\'\'))';

        AdditionalCondition = AdditionalCondition + ' AND ' + ModelVariantCondition + ' ORDER BY Description__c ASC';
        //If there are keywords to search
        if(Keyword != ''){
            AdditionalCondition = AdditionalCondition + ' AND Description__c LIKE ' + '\'%' +  Keyword  + '%\'';
        }

        BuildSpecRecords = fetchRecordwithConditionOnly('MB_Build_Spec__c', AdditionalCondition);

        return BuildSpecRecords;
    }

    @AuraEnabled
    public static void deleteSpec(String saID, String specID) 
    {
        List<MB_SA_Spec__c> specs = [SELECT ID FROM MB_SA_Spec__c WHERE ID = :specID];

        if (specs.size() == 0) return;

        Savepoint sp = Database.setSavepoint();

        try {
            delete specs;
            updateTOEV(saID);
        } catch(Exception e) {
            Database.rollback(sp);
            throw e;
        }
        
    }

    /**
     * update total optional equipment value
     */
    @AuraEnabled
    public static void updateTOEV(String saID)
    {
        List<MB_SA_Spec__c> specs = [SELECT Invoice_Value__c, Product_Code__c FROM MB_SA_Spec__c 
                                    WHERE MB_Sales_Agreement__c = :saID 
                                    AND PRINT__C = 'Y'
                                    AND Fit_Type__c = 'O'];

        MB_Sales_Agreement__c SA = [SELECT Total_Optional_Equipment__c FROM MB_Sales_Agreement__c WHERE ID = :saID];

        Decimal total = 0;

        for (MB_SA_Spec__c spec : specs) {
            Boolean isSVCOrBoutique = false;
            if (String.isNotEmpty(spec.Product_Code__c)) {
                isSVCOrBoutique = spec.Product_Code__c.startsWith('SVC') || spec.Product_Code__c.startsWith('RSVC') ||
                                    spec.Product_Code__c.startsWith('BOUTVC');
            }
            if (!isSVCOrBoutique && spec.Invoice_Value__c != null) {
                total += spec.Invoice_Value__c;
            }
        }

        SA.Total_Optional_Equipment__c = total;

        update SA;
    }

    /**
     * get records that have @conditionField equal @conditionValue and met @additionalCondition
     */
    private static List<sObject> getRecords(String objectName, String conditionField, String conditionValue, String additionalCondition) 
    {
        String mainQueryCondition = conditionField + ' = ' + '\'' + conditionValue + '\'';

        if(additionalCondition != null && String.isNotBlank(additionalCondition)) 
        {
            mainQueryCondition += ' ' + additionalCondition;
        }

        List<SObject> result = ADGLIB_UtilityHelper.getSObjectRecords(objectName, mainQueryCondition, false); 
        return result;
    }

    public static List<SObject> fetchRecordwithConditionOnly(String ObjectName, String AdditionalCondition) 
    {
        List<sObject> results = ADGLIB_UtilityHelper.getSObjectRecords(ObjectName, AdditionalCondition, false); 
        return results;
    }

}