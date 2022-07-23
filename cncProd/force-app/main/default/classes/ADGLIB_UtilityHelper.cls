public class ADGLIB_UtilityHelper {
public static Boolean isSandbox() {
        return [select Id, IsSandbox from Organization limit 1].IsSandbox;
    }    


    public static ADGLIB_QueryFactory getQueryFactoryByObject(String objectName, boolean isAllField){
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
        ADGLIB_QueryFactory qf = new ADGLIB_QueryFactory(sobjectType);
        
        if(isAllField){
            List<Schema.SObjectField> sObjectFieldList = getSObjectFieldListByObj(objectName);
            qf.selectFields(sObjectFieldList);
        }
        return qf;
     }


    public static List<Schema.SObjectField> getSObjectFieldListByObj(String objectName) {
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> ();
        
        for(Schema.SObjectField sfield : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()){        
                if(sfield.getDescribe().isAccessible() && sfield.getDescribe().getname() != 'isDeleted'){
                    fieldList.add(sfield);
                }
            }
        
        return fieldList;
    }

    
     public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                //if (!sObj.contains('__')) to exclude managed package objects

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }

        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

    
    public static String generateAllFieldStr(String SObject_API_Name)
    {
        String query = '';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(SObject_API_Name).getDescribe().fields.getMap();
        Set<String> fieldsSet = new Set<String> ();

        for (Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            if (dfield.isAccessible() && dfield.getname() != 'isDeleted') fieldsSet.add(dfield.getname());
            
        }
        if (fieldsSet.size() > 0)
        {
            query = String.join(new List<String> (fieldsSet), ',');
            if (!fieldsSet.contains('Id')) query += ',Id';
        }
        return query;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getSObjectRecords(String SObject_API_Name, String condition, Boolean onlyOne) {
        String query = generateAllFieldSOQL(SObject_API_Name);
        system.debug(condition);
        if (!String.isEmpty(condition))
        {
            query += ' where ' + condition;
        }
        if (onlyOne)
        {
            query += ' limit 1';
        }
        return Database.query(query);
        
    }

    public static List<sObject> getSObjectRecords(String SObject_API_Name, String condition, set<string> setInput, Boolean onlyOne) {
        String query = generateAllFieldSOQL(SObject_API_Name);
        system.debug(condition);
        if (!String.isEmpty(condition))
        {
            query += ' where ' + condition;
        }
        if (onlyOne)
        {
            query += ' limit 1';
        }
        
        System.debug('@@@@DBEUG getSObjectRecords :: query = ' + query );
        return Database.query(query);
        
    }
    
    /* Not in use for now. If needed, please uncomment this.
    public static List<sObject> getSObjectRecords(String SObject_API_Name, String condition, Boolean onlyOne, String additionalColFromRelationship) {
        String query = generateAllFieldSOQL(SObject_API_Name, additionalColFromRelationship);
        system.debug(condition);
        if (!String.isEmpty(condition))
        {
            query += ' where ' + condition;
        }
        if (onlyOne)
        {
            query += ' limit 1';
        }
        return Database.query(query);
        
    }
    */

    public static String generateAllFieldSOQL(String SObject_API_Name)
    {
        
        String query = 'Select ' + generateAllFieldStr(SObject_API_Name) + ' From ' + SObject_API_Name;
        return query;
    }
    
    /* Not in use for now. If needed, please uncomment this.

    public static String generateAllFieldSOQL(String SObject_API_Name, String additionalColFromRelationship)
    {
        
        String query = 'Select ' + generateAllFieldStr(SObject_API_Name) + ', ' + additionalColFromRelationship + ' From ' + SObject_API_Name;
        return query;
    }
    */
    
}