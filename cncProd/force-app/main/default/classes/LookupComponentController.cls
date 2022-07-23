public inherited sharing class LookupComponentController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String sObjName, String searchKeyword, String Id, String fieldName) {
        searchKeyWord = '%' + searchKeyWord + '%';
        
        return Database.query('Select Id, Name From ' + sObjName + ' Where Name Like :searchKeyWord Order By CreatedDate Desc Limit 10');         
    }      
}