/** *****
 * Description : Selector Class for Account object
 * 
 * Change History
 * Date(YYYYMMDD)       Name        Description
 * 20200219             AT          Created Initial Version. 
 * 20200310             HS          Added getPersonAccountListByIds method
** *****/
public class AccountSelector extends ADGLIB_SObjectSelector{

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Account');
    }

    public List<String> getEditableAccountFields() {
        List<String> accountFields = new List<String>();
        for(Schema.SObjectField field : getSObjectFieldList()) {
            if( field.getDescribe().isCreateable() && field.getDescribe().isUpdateable() ) {
                accountFields.add( String.valueOf(field) );
            }
        }
        return accountFields;
    }

    public Map<String,RecordType> getAccountRecordTypeMap() {
        Map<String,RecordType> mapAccountRecordType = new Map<String,RecordType>();
        for( RecordType rt : [SELECT Id, Name, DeveloperName 
                              FROM RecordType
                              WHERE sObjectType = 'Account'] ) {
            
            mapAccountRecordType.put( rt.DeveloperName, rt );
        }
        return mapAccountRecordType;
    }
    
    public List<Account> getPersonAccountListByIds( Set<String> setOfPAIds , Set<String> setOfPAContactIds, String strRecordTypeAPIName ){
        List<Account> lstAccounts = new List<Account>();
        adglib_QueryFactory query = newQueryFactory();    
        query.selectFields(new Set<String>{ 'RecordType.DeveloperName' , 'Postal_Code__pc.Name' });

        String str_filter = ' IsPersonAccount = true ';
        
        if( setOfPAIds <> null && !setOfPAIds.isEmpty() ) {
            setOfPAIds.remove( null );
            str_filter += ' AND Id IN :setOfPAIds '; 
        }

        if( setOfPAContactIds <> null && !setOfPAContactIds.isEmpty() ) {
            setOfPAContactIds.remove( null );
            str_filter += ' AND PersonContactId IN :setOfPAContactIds ';
        }

        if( !String.isBlank( strRecordTypeAPIName ) ) {
            str_filter += ' AND RecordType.DeveloperName = :strRecordTypeAPIName ';
        }

        query.setCondition( str_filter );
        System.debug('@@@@DEBUG getPersonAccountListByIds :: soql = ' + query.toSOQL() );
        lstAccounts = Database.query( query.toSOQL() );
        return lstAccounts;
    }


    /**
     * @param setOfPAIds            : A set of Ids of Person Account
     * @param setOfPAContactIds     : A set of Id pf Person Account Contact
     * @param setOfPAEmails         : A set of String of Person Account Email
     * @param strRecordTypeAPIName  : String of Person Account Record Type DeveloperName
     **/
    public List<Account> getPersonAccountListByIdsOrEmails( Set<String> setOfPAIds , Set<String> setOfPAContactIds, Set<String> setOfPAEmails, String strRecordTypeAPIName ){
        List<Account> lstAccounts = new List<Account>();
        adglib_QueryFactory query = newQueryFactory();    
        query.selectFields(new Set<String>{ 'RecordType.DeveloperName' , 'Postal_Code__pc.Name' });

        String str_filter = ' IsPersonAccount = true ';
        
        if( setOfPAIds <> null && !setOfPAIds.isEmpty() ) {
            setOfPAIds.remove( null );
            str_filter += ' AND Id IN :setOfPAIds '; 
        }

        if( setOfPAContactIds <> null && !setOfPAContactIds.isEmpty() ) {
            setOfPAContactIds.remove( null );
            str_filter += ' AND PersonContactId IN :setOfPAContactIds ';
        }

        if( setOfPAEmails <> null && !setOfPAEmails.isEmpty() ) {
            setOfPAEmails.remove( null );
            str_filter += ' AND PersonEmail IN :setOfPAEmails ';
        }

        if( !String.isBlank( strRecordTypeAPIName ) ) {
            str_filter += ' AND RecordType.DeveloperName = :strRecordTypeAPIName ';
        }

        query.setCondition( str_filter );
        query.setOrdering('CreatedDate', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
        System.debug('@@@@DEBUG getPersonAccountListByIds :: soql = ' + query.toSOQL() );
        lstAccounts = Database.query( query.toSOQL() );
        return lstAccounts;
    }

    
}