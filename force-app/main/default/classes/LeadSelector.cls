/** *****
 * Description : Selector Class for Lead object
 * 
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200224            AT          Created Initial Version. 
 * 
** *****/
public class LeadSelector extends ADGLIB_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Lead');
    }

    public Schema.SObjectType getSObjectType() {
        return Lead.sObjectType;
    }

    public String getUnconvertedLead( Set<Id> setTargetedLeadIds ) {
        adglib_QueryFactory query = newQueryFactory();
        
        // query.setLimit(1); //TO BE REMOVED
        // query.selectField('Owner.IsActive');
        query.setCondition('IsConverted = false AND Account__c = null');
        if( setTargetedLeadIds <> null && !setTargetedLeadIds.isEmpty() ) {
            query.setCondition( query.getCondition() + ' AND Id IN :setTargetedLeadIds ');
        }

        System.debug('@@@@DEBUG getUnconvertedLead :: soql = '+query.toSOQL());
        return query.toSOQL(); 
    }

    public Map<String, List<SObject>> getSObjectLeadMap(Set<String> leadIds, String childObjectName) {
        Map<String, List<SObject>> sObjectLeadMap = new Map<String, List<SObject>>();

        String field = childObjectName == 'Event_Registration__c' ? 'LeadId__c' : 'Lead__c';  
        String strQuery = 'SELECT '+field+' FROM '+childObjectName+' WHERE '+field+' =:leadIds';     
        for( SObject record : Database.query(strQuery) ) {
            if( sObjectLeadMap.containsKey( (String)record.get(field) ) ){
                sObjectLeadMap.get((String)record.get(field)).add(record);
            }
            else{
                sObjectLeadMap.put( (String)record.get(field) ,new List<SObject>{record} );
            }
        }
        return sObjectLeadMap;
    }
    
    public List<String> getEditableLeadFields() {
        List<String> leadFields = new List<String>();
        for( Schema.SObjectField field : getSObjectFieldList() ){
            if( field.getDescribe().isCreateable() && field.getDescribe().isUpdateable() ) {
                leadFields.add(String.valueOf(field));
            }
        }
        return leadFields;
    }
    //HH
    /*public String getSelectiveUnconvertedLead(Set<String> setLeadIds) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('IsConverted = false AND Account__c = null AND Id IN:setLeadIds ');
        //query.setLimit(1); //TO BE REMOVED
        System.debug('@@@ : '+query.toSOQL());
        return query.toSOQL(); 
    }*/

    public List<Lead> getLeadByIdentifier(Set<String> identifiers){
        adglib_QueryFactory query = newQueryFactory(false);
        query.selectField('Identifier__c');
        query.setCondition('Identifier__c IN :identifiers');
        return Database.query(query.toSOQL());
    }
}