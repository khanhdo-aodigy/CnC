public with sharing class termsAndConditionsCtl {
    
    public class ResponseWrapper {
        @AuraEnabled public Term_and_Condition__mdt metadataRecord { get; set; }
        @AuraEnabled public sObject currentRecord { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static ResponseWrapper doGetInformation(String CurrentRecordId, String FieldValue,  String ObjectName, String FieldName) {
        ResponseWrapper returnWrap = new ResponseWrapper();

        returnWrap.metadataRecord = (Term_and_Condition__mdt)fetchRecords(FieldValue, ObjectName, FieldName, '')[0];
 
        if(String.isBlank(returnWrap.metadataRecord.Associated_Checkbox_Field_API_Name__c) == false && returnWrap.metadataRecord.Associated_Checkbox_Field_API_Name__c != ''){
            returnWrap.currentRecord = fetchRecords(CurrentRecordId, returnWrap.metadataRecord.Object_API_Name__c, 'Id', '')[0];
        }
        return returnWrap;
    }


    @AuraEnabled
    public static string updateInformation(String ObjectName, String FieldName, String FieldValue, Id RecordId){
        Boolean value = Boolean.valueOf(FieldValue);
        List<SObject> sObjectsToUpdate = new List<SObject>();

        SObject currentRecord = RecordId.getSObjectType().newSObject(RecordId);
        currentRecord.put(FieldName, value);
        sObjectsToUpdate.add(currentRecord);
        update sObjectsToUpdate;

        return 'updated';
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> fetchRecords(String RecordId, String ObjectName, String FieldName, String AdditionalCondition) {
        String MainQueryCondition = FieldName + ' = ' + '\'' + RecordId + '\'';
        if(String.isNotBlank(AdditionalCondition)) {
            MainQueryCondition += ' ORDER BY ' + AdditionalCondition;
        }

        List<sObject> ListofRecords = ADGLIB_UtilityHelper.getSObjectRecords(ObjectName, MainQueryCondition, false); 
        return ListofRecords;
    }
}