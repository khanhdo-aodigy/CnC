public with sharing class twoLevelRelatedListController {
    public class ResponseWrapper {
        @AuraEnabled public List<sObject> FirstLevelRelatedList { get; set; }
        @AuraEnabled public List<sObject> SecondLevelRelatedList { get; set; }
        @AuraEnabled public Map<String,String> FirstLevelFieldMapping { get; set; }
        @AuraEnabled public Map<String,String> SecondLevelFieldMapping { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static ResponseWrapper doGetInformation(String CurrentRecordId, String FirstLevelObject, String FirstLevelRelationshipField, String SecondLevelObject, String SecondLevelRelationshipField, String FirstLevelOrderBy, String SecondLevelOrderBy) {
        //system.debug('-----------------Constructing Initial Wrapper-----------------');
        ResponseWrapper returnWrap = new ResponseWrapper();

        //Get the related records
        returnWrap.FirstLevelRelatedList = fetchRecords(CurrentRecordId, FirstLevelObject, FirstLevelRelationshipField, FirstLevelOrderBy);
        
        //Get the second level related List
        Set<String> setIds = new Set<String>();
        if(returnWrap.FirstLevelRelatedList!=null && !returnWrap.FirstLevelRelatedList.isEmpty()){
            for(sObject eachrecord: returnWrap.FirstLevelRelatedList){
                setIds.add(eachrecord.Id);
            }
            returnWrap.SecondLevelRelatedList = getMultipleRecordInformation(setIds, SecondLevelObject, SecondLevelRelationshipField, SecondLevelOrderBy);
        }

        //Get the object field Names + Label
        returnWrap.FirstLevelFieldMapping = getObjectFieldsNameAndLabel(FirstLevelObject);
        returnWrap.SecondLevelFieldMapping = getObjectFieldsNameAndLabel(SecondLevelObject);
        return returnWrap;
    }

    public static List<sObject> fetchRecords(String RecordId, String ObjectName, String FieldName, String AdditionalCondition) {
        String MainQueryCondition = FieldName + ' = ' + '\'' + RecordId + '\'';
        if(String.isNotBlank(AdditionalCondition)) {
            MainQueryCondition += ' ORDER BY ' + AdditionalCondition;
        }

        List<sObject> ListofRecords = ADGLIB_UtilityHelper.getSObjectRecords(ObjectName, MainQueryCondition, false); 
        return ListofRecords;
    }

    public static List<sObject> getMultipleRecordInformation(SET<string> setInput, String ObjectName, String FieldName, String AdditionalCondition){
        String MainQueryCondition = FieldName + ' IN: setInput';
        if(String.isNotBlank(AdditionalCondition)) {
            MainQueryCondition += ' ORDER BY ' + AdditionalCondition;
        }
        List<sObject> RecordList = ADGLIB_UtilityHelper.getSObjectRecords(ObjectName, MainQueryCondition, setInput, false);    
        return RecordList;
    }

    public static Map<String,String> getObjectFieldsNameAndLabel(string selectedObject) 
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();

        Map<String,String> fieldNamesLabel = new Map<String,String>();
        for (String fieldName: fieldMap.keySet()) 
        {  
          String fName = fieldMap.get(fieldName).getDescribe().getLabel();
          fieldNamesLabel.put(fieldName, fName);
        }
        return fieldNamesLabel;
    }    
}