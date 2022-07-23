/** *****
 * Description : Batch class to move Child record(s) from one Contact to another one
 * 
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200401            HS          Created Initial Version. 
 * 
** *****/
global class ContactDedupBatch implements Database.Batchable<sObject>, Database.Stateful{

    public String masterObject = 'Contact';
    public List<String> errMsgs = new List<String>();
    private Set<String> setCntIdToProcess = new Set<String>();
    private Set<String> setObjectToExclude = new Set<String>();
    private Set<String> setCntIdToExclude = new Set<String>();
    private Map<String, Set<String>> mapParentToChildObjName = new Map<String,Set<String>>();   
    private Map<String, Set<String>> mapChildObjFieldName = new Map<String, Set<String>>();

    private Set<String> setOfStandardObject = new Set<String>{
        'Tasks', 'NotesAndAttachments', 'Notes', 'Events', 'Cases', 'CampaignMembers', 'Histories'
    };

    global ContactDedupBatch() {}

    global ContactDedupBatch( Set<String> setContIds, Set<String> setObjToExclude, Set<String> setIdsToExclude ) {
        if( setContIds <> null && !setContIds.isEmpty() ) {
            this.setCntIdToProcess = setContIds;
        }

        if( setObjToExclude <> null && !setObjToExclude.isEmpty() ) {
            this.setObjectToExclude = setObjToExclude;
        }

        if( setIdsToExclude <> null && !setIdsToExclude.isEmpty() ) {
            this.setCntIdToExclude = setIdsToExclude;
        }
    }

    public String setupQueryStatement() {
        getChildObjectAndFields( masterObject );

        String queryStatement = ' SELECT Id, Primary_Contact_Id__c, is_Duplicated__c, NRIC__c, NRIC_Passport_No__c, Device__c FROM ' + masterObject + ' WHERE is_Duplicated__c = true AND Primary_Contact_Id__c != null AND IsPersonAccount = false ';
        return queryStatement;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = setupQueryStatement();
        if( setCntIdToProcess <> null && !setCntIdToProcess.isEmpty() ) {
            query = query + ' AND Id IN:setCntIdToProcess ';
        }

        if( setCntIdToExclude <> null && !setCntIdToExclude.isEmpty() ) {
            query = query + ' AND Id NOT IN:setCntIdToExclude ';
        }
        System.debug('@@@@DEBUG ContactDedupBatch >> execute >> setCntIdToExclude.size() = ' + setCntIdToExclude.size()  );
        
        return Database.getQueryLocator( query );
    }


    global void execute(Database.BatchableContext bc, List<Contact> lstContacts){
        try{
            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> lstContacts.size() = ' + lstContacts.size()  );
            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> mapParentToChildObjName.size() = ' + mapParentToChildObjName.size() + ' --- ' + mapParentToChildObjName );
            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> mapChildObjFieldName.size() = ' + mapChildObjFieldName.size() + ' --- ' + mapChildObjFieldName );

            Map<String,Contact> mapIdContacts = new Map<String,Contact>();
            for(Contact cnt : lstContacts) {
                mapIdContacts.put( (String)cnt.Id , cnt );
            }

            if( mapParentToChildObjName.containsKey( masterObject ) ){
                Set<String> tempChildList = mapParentToChildObjName.get( masterObject );
                for( String obj_to_excl : setObjectToExclude ){
                    if( tempChildList.contains( obj_to_excl ) ) {
                        tempChildList.remove( obj_to_excl );
                    }
                }
                mapParentToChildObjName.put( masterObject, tempChildList );
            }


            List<Map<String, List<SObject>>> childListMaps = new List<Map<String, List<SObject>>>();
            if( mapParentToChildObjName.containsKey( masterObject ) ) {
                for(String childObject : mapParentToChildObjName.get( masterObject ) ) {
                    System.debug('--------- ' + childObject + ' ---------' );
                    if( String.isNotBlank( childObject ) )
                    {
                        childListMaps.add( getChildSObjectList( childObject, mapIdContacts, mapChildObjFieldName ) );
                    }
                }     
            }


            Map<String, List<SObject>> mapSObjectToUpdate = new Map<String, List<SObject>>();
            for( Map<String, List<SObject>> sObjectMap : childListMaps ) {
                for( String key : sObjectMap.keySet() ) {
                    for( SObject sOBJ : sObjectMap.get(key) ) 
                    {
                        String str_sobjType = String.valueOf(sOBJ.getSObjectType());

                        if( mapSObjectToUpdate.containsKey( str_sobjType ) ) {
                            mapSObjectToUpdate.get( str_sobjType ).add( sOBJ );
                        }
                        else {
                            mapSObjectToUpdate.put( str_sobjType , new List<SObject>{ sOBJ } );
                        }
                    }
                }
                System.debug('@@@@CHECK ---> ' + sObjectMap );
            }


            TriggerExclusion.excludeTrigger( masterObject , true );
            for( String strObject : mapSObjectToUpdate.keySet() ) {
                TriggerExclusion.excludeTrigger( strObject , true );
            }


            for( String strObject : mapSObjectToUpdate.keySet() ) {
                update ( mapSObjectToUpdate.get( strObject ) );
            }
            
            updateUserContactId( lstContacts );

            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> childListMaps.size() = ' + childListMaps.size() + ' --- ' + childListMaps );
            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> mapSObjectToUpdate.size() = ' + mapSObjectToUpdate.size() + ' --- ' + mapSObjectToUpdate );
            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> Limits.getDMLStatements = ' + Limits.getDMLStatements() );
            System.debug('@@@@DEBUG ContactDedupBatch >> execute >> Limits.getQueries() = ' + Limits.getQueries() );

        }
        catch(Exception ex){
            System.debug('@@@@DEBUG ContactDedupBatch :: ERROR :: err.cause' + ex.getCause()+' --- err.msg = '+ex.getMessage()+' --- err.line = '+ex.getLineNumber());
            errMsgs.add('err.cause' + ex.getCause()+' --- err.msg = '+ex.getMessage()+' --- err.line = '+ex.getLineNumber());
        }
    }


    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'hwanshyan.lim@aodigy.com'};
        mail.setToAddresses(toAddresses);
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i=0; i<errMsgs.size(); i++){
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }   
        }
        else{
            body = 'Sucess';
        }
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    

    public Map<String, List<SObject>> getChildSObjectList(String sObjectName, Map<String,Contact> mapIdContacts, Map<String, Set<String>> mapSObjectLKFields ){

        Map<String, List<SObject>> mapCntChildObjectList = new Map<String, List<SObject>>();
        Set<String> setContactIds = new Set<String>();
        setContactIds.addAll( mapIdContacts.keySet() );

        List<String> lstFieldNames = new List<String>();
        String fieldName = '';
        if( mapSObjectLKFields.containsKey( sObjectName ) ){
            lstFieldNames.addAll( mapSObjectLKFields.get( sObjectName ) );
        }

        String fieldsToQuery   = '';
        String fieldsToFilter  = '';
        if( lstFieldNames<>null && !lstFieldNames.isEmpty() ){
            fieldsToQuery = String.join( lstFieldNames, ', ' );
            for(String fldName : lstFieldNames ){
                fieldsToFilter += fldName+' IN :setContactIds OR';
            }
            fieldsToFilter = fieldsToFilter.removeEnd('OR');
        }

        System.debug('@@@@DEBUG getChildSObjectList :: sObjectName = ' + sObjectName +' --- lstFieldNames = ' + lstFieldNames );
        System.debug('@@@@DEBUG getChildSObjectList :: mapSObjectLKFields = ' + mapSObjectLKFields );
        if( String.isNotBlank( fieldsToFilter )  ) 
        {   
            
            String eachObjQuery  = ' SELECT ' + fieldsToQuery + ' FROM ' + sObjectName + ' WHERE ' + fieldsToFilter;
            System.debug('@@@@DEBUG getChildSObjectList :: eachObjQuery = ' + eachObjQuery);

            for(SObject record : Database.query(eachObjQuery))
            {   
                String sObjType = String.valueOf( record.getSObjectType() );
                if( mapSObjectLKFields.containsKey( sObjType ))
                {
                    for( String fldName : mapSObjectLKFields.get(sObjType) )
                    {   
                        record.put( fldName, mapIdContacts.get( (String)record.get(fldName) ).Primary_Contact_Id__c );

                        if( mapCntChildObjectList.containsKey( (String)record.get(fldName) ) ) {   
                            mapCntChildObjectList.get( (String)record.get(fldName) ).add( record );
                        }
                        else {
                            mapCntChildObjectList.put( (String)record.get(fldName), new List<SObject>{record} );
                        }
                        
                    }
                } 
            }
        }
        return mapCntChildObjectList;
    }

    
    private void getChildObjectAndFields( String masterObject )
    {  
        Set<String> childRelationships = new Set<String>(); 
        
        SObjectType masterObjType = Schema.getGlobalDescribe().get(masterObject);
        Schema.DescribeSObjectResult masterObjResult = masterObjType.getDescribe();

        mapParentToChildObjName.put( masterObject , new Set<String>() );

        for ( Schema.ChildRelationship cr: masterObjResult.getChildRelationships() ) 
        {    
            if( cr.getRelationshipName() != null && ( cr.getRelationshipName().endsWith('__r') || ( !setOfStandardObject.isEmpty() && setOfStandardObject.contains(cr.getRelationshipName()) ) )
                    && cr.getChildSObject() != null && !childRelationships.contains(cr.getRelationshipName()) ) {                
                
                childRelationships.add( cr.getRelationshipName() );             
                
                Schema.DescribeSObjectResult sChildObjResult = cr.getChildSObject().getDescribe();  
                String strChildObjName = String.valueOf( sChildObjResult.getSObjectType() );
                mapParentToChildObjName.get( masterObject ).add( strChildObjName );
                mapChildObjFieldName.put( strChildObjName  , new Set<String>() );

                Map<String, Schema.SObjectField> mapChildFieldList = sChildObjResult.fields.getMap();    

                for ( Schema.SObjectField field : mapChildFieldList.values()) 
                {                   
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();            
 
                    if( fieldResult.isUpdateable() && !fieldResult.getReferenceTo().isEmpty() )
                    {   
                        for(Schema.SObjectType reference : fieldResult.getReferenceTo()) 
                        {
                            if( reference.getDescribe().getName() == masterObject ) 
                            {
                                mapChildObjFieldName.get( strChildObjName ).add( fieldResult.getName() );
                            }
                        } 
                    }
                }
            }    
                    
        }
        
        System.debug('@@@@DEBUG getChildObjectAndFields :: childRelationships = ' + childRelationships.size() + ' --- ' + childRelationships );
    }

    
    private void updateUserContactId( List<Contact> lstContact ){

        Set<String> setNRICs =  new Set<String>();
        List<Contact> lstContactToUpdate = new List<Contact>();
        Map<String,List<Contact>> mapRightKeyWithWrongContact = new Map<String,List<Contact>>();
        Map<String,Contact> mapWrongContacts = new Map<String,Contact>();
        Map<String,Contact> mapRightContacts = new Map<String,Contact>();
        Map<String,User> mapUsers = new Map<String,User>();

        for( Contact cnt : lstContact ){
            if( !String.isBlank( cnt.NRIC_Passport_No__c ) )
            {
                setNRICs.add( cnt.NRIC_Passport_No__c );
                mapWrongContacts.put( cnt.Id , cnt );
            }

            if( mapRightKeyWithWrongContact.containsKey( cnt.Primary_Contact_Id__c ) ){
                mapRightKeyWithWrongContact.get( cnt.Primary_Contact_Id__c ).add( cnt );
            }
            else{
                mapRightKeyWithWrongContact.put( cnt.Primary_Contact_Id__c, new List<Contact>{ cnt } );
            }
            mapRightContacts.put( cnt.Primary_Contact_Id__c, null );
        }

        if( !mapRightContacts.isEmpty() )
        {
            for( Contact cnt : [SELECT Id, NRIC_Passport_No__c, Device__c FROM Contact WHERE IsPersonAccount = false AND Id IN :mapRightContacts.keySet() ]){
                
                for( Contact cTM : mapRightKeyWithWrongContact.get( String.valueOf(cnt.Id) ) )
                {
                    if( !String.isBlank(cTM.Device__c) && cTM.is_Duplicated__c && cTM.Primary_Contact_Id__c == cnt.Id  && String.isBlank(cnt.Device__c) ){
                        cnt.Device__c = cTM.Device__c;
                        lstContactToUpdate.add( cnt );
                    }
                }
                mapRightContacts.put( cnt.Id, cnt );
            }
        }

        if( !mapWrongContacts.isEmpty() && !mapRightContacts.isEmpty() )
        {
            for( User usr : [SELECT Id, ContactId__c, NRIC__c 
                             FROM User 
                             WHERE Profile.Name = 'End User' AND IsPortalEnabled = true AND ContactId != null AND ContactId__c != null AND isActive = true AND isValid__c = true
                             AND ContactId__c IN :mapWrongContacts.keySet() 
                             ORDER BY LastLoginDate DESC ]){
                
                String strWrongCntId = usr.ContactId__c;
                if( !mapUsers.containsKey( strWrongCntId ) && mapWrongContacts.containsKey( strWrongCntId ))
                {
                    if( usr.ContactId__c <> mapWrongContacts.get( usr.ContactId__c ).Primary_Contact_Id__c
                            && mapRightContacts.containsKey( mapWrongContacts.get( usr.ContactId__c ).Primary_Contact_Id__c )
                                && mapRightContacts.get( mapWrongContacts.get( usr.ContactId__c ).Primary_Contact_Id__c ).NRIC_Passport_No__c == usr.NRIC__c )
                    {
                        //Assign the Right Contact Id
                        usr.ContactId__c = (Id)mapWrongContacts.get( usr.ContactId__c ).Primary_Contact_Id__c;
                        mapUsers.put( strWrongCntId , usr);

                        // lstContactToUpdate.add( mapRightContacts.get( usr.ContactId__c ) );
                    }
                }
            }
        }

        if( !mapUsers.isEmpty() ){
            update ( mapUsers.values() );
        }

        System.debug('@@@@DEBUG updateUserContactId :: lstContactToUpdate = ' + lstContactToUpdate.size() + ' --- ' + lstContactToUpdate);
        if( !lstContactToUpdate.isEmpty() ){
            update lstContactToUpdate;
        }
    }

}