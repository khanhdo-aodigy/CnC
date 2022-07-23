public with sharing class WMFormCtrl {
    @AuraEnabled
    public static List<WM_Form__mdt> getForms(Id recordId) {
        String objApiName = recordId.getSObjectType().getDescribe().getName();
        String mainQueryCondition = 'Object_API_Name__c = \'' + objApiName + '\'' + ' AND Active__c = true ORDER BY Position__c';
        List<WM_Form__mdt> records = ADGLIB_UtilityHelper.getSObjectRecords('WM_Form__mdt', mainQueryCondition, false);

        return records;
    }

    @AuraEnabled
    public static Boolean generateForm(Id recordId, String mappingId) {
        Boolean mergeSuccess;
        String objApiName = recordId.getSObjectType().getDescribe().getName();
        if (!Test.isRunningTest()) {
            mergeSuccess = webm.WebmergeGenerator.generateDocument(mappingId, recordId, objApiName);
        } else {
            mergeSuccess = true;
        }

        return mergeSuccess;
    }
}