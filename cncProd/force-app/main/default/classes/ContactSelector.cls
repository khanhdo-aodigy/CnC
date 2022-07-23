/** *****
 * Description : Selector Class for Contact object
 * 
 * Change History
 * Date(YYYYMMDD)      Name                  Description
 * 20200219            AT                    Created Initial Version.
 * 20200923            Khanh Do              Added PA Migration Comments
 * 
** *****/
public class ContactSelector extends ADGLIB_SObjectSelector{

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Contact');
    }
    
    public Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }

    /** 
     *  PA Phase 2: This method is called from PABatchContactWithoutPAConverter
     *  TO-DO: Remove this once PABatchContactWithoutPAConverter is decommissioned
     */
    public String selectContactWithoutPA( Set<String> setContIdsWithPA, Set<Id> setContIdsWithoutPA ) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Owner.IsActive');
        if( setContIdsWithoutPA <> null && !setContIdsWithoutPA.isEmpty() ) {
            query.setCondition('Id NOT IN :setContIdsWithPA AND Id IN :setContIdsWithoutPA AND isPersonAccount = False AND Account__c = null AND is_Duplicated__c = false ');
        }
        else {
            query.setCondition('Id NOT IN :setContIdsWithPA AND isPersonAccount = False AND Account__c = null AND is_Duplicated__c = false ');
        }

        query.subselectQuery('Registered_Vehicles__r');
        query.subselectQuery('Orders__r');

        return query.toSOQL(); 
    }

    /** 
     *  PA Phase 2: This method is called from PABatchContactWithPAConverter
     *  TO-DO: Remove this once PABatchContactWithPAConverter is decommissioned
     */
    public List<Contact> selectContactWithPA(Set<String> contIds) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectFields(new List<String>{'Owner','Owner.IsActive'});
        query.setCondition('Id IN :contIds AND Account__c = null');
        query.subselectQuery('Registered_Vehicles__r');
        query.subselectQuery('Orders__r');

        return Database.query(query.toSOQL()); 
    }
    

    /* Get Map ContactId - List Chid Record */
    /** 
     *  PA Phase 2: This method is called from PABatchContactWithoutPAConverter and PABatchContactWithPAConverter
     *  TO-DO: Remove this once PABatchContactWithoutPAConverter and PABatchContactWithPAConverter are decommissioned
     */
    public Map<String, List<SObject>> getSObjectContactMap(Set<String> contIds, String sObjectName){

        Map<String, List<SObject>> sObjectContactMap = new Map<String, List<SObject>>();
        String fieldName = 'Contact__c';
        if(sObjectName == 'Case'){
            fieldName = 'ContactId';
        }
        else if(sObjectName == 'Event_Registration__c'){
            fieldName = 'ContactId__c';
        }
        else if(sObjectName == 'Opportunity'){
            fieldName = 'Contact_Person__c';
        }
        else if(sObjectName == 'Test_Drive__c'){
            fieldName = 'Prospect__c';
        }
        
        String query = 'SELECT '+fieldName+' FROM '+sObjectName+' WHERE '+fieldName+' IN :contIds';
        System.debug('aaa');
        for(SObject record : Database.query(query)){
            if( sObjectContactMap.containsKey( (String)record.get(fieldName) ) ){
                sObjectContactMap.get((String)record.get(fieldName)).add(record);
            }
            else{
                sObjectContactMap.put( (String)record.get(fieldName), new List<SObject>{record} );
            }
        }
        System.debug('bbb');
        return sObjectContactMap;
    }
    
    /** 
     *  PA Phase 2: This method is called from PAMigrationService and ContactBL
     *  TO-DO: Remove this once PAMigrationService and ContactBL are decommissioned
     */
    public List<String> getEditableContactFields() {
        List<String> contactFields = new List<String>();
        for(Schema.SObjectField field : getSObjectFieldList()) {
            if( field.getDescribe().isCreateable() && field.getDescribe().isUpdateable() ) {
                contactFields.add( String.valueOf(field) );
            }
        }
        return contactFields;
    }

    //PA Phase 2: Unused code?
    public List<Contact> getContactByIdentifier(Set<String> identifiers){
        adglib_QueryFactory query = newQueryFactory(false);
        query.selectField('Identifier__c');
        query.setCondition('IsPersonAccount = false AND Identifier__c IN :identifiers');
        return Database.query(query.toSOQL());
    }

    /**
     * @param setContactEmails : An unique list of Contact Email(s)
     * @param setAcctRecordTypeDeveloperNames : An unique list of Contact's Account Record Type(s)
     */
    public List<Contact> getPersonContactByContactEmails( Set<String> setContactEmails, Set<String> setAcctRecordTypeDeveloperNames ){
        adglib_QueryFactory query = newQueryFactory(true);
        query.selectField('Account.RecordType.DeveloperName');
        query.setCondition('IsPersonAccount = true AND Account.RecordType.DeveloperName IN :setAcctRecordTypeDeveloperNames AND Email IN :setContactEmails');
        return Database.query(query.toSOQL());
    }


    /**
     * @param accountIds : An unique list of Account Id(s)
     * @param setAcctRecordTypeDeveloperNames : An unique list of Contact's Account Record Type(s)
     */
    public List<Contact> getPersonContactByAccountIds( Set<Id> setAccountIds, Set<String> setAcctRecordTypeDeveloperNames ){
        adglib_QueryFactory query = newQueryFactory(true);
        query.selectField('Account.RecordType.DeveloperName');
        query.setCondition('IsPersonAccount = true AND AccountId IN :setAccountIds AND Account.RecordType.DeveloperName IN :setAcctRecordTypeDeveloperNames ');
        return Database.query(query.toSOQL());
    }

    public String getPersonContactIdByUserId(String userId) {
        String contactId = '';
        List<User> user = [ SELECT Account.PersonContactId FROM User WHERE Id = :userId LIMIT 1];
        if (user.size() > 0) {
            contactId = user[0].Account.PersonContactId;
        }
        return contactId;
    }
}