/** ******
 * Description : Selector Class for Referral object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20200211             HS@aodigy           Created Initial Version. 
 * 20200311             HS@aodigy           Added selectByReferrerPersonAccountIdsAndStages & selectByReferrerContactIdsAndStages
 * 20200923             Thu@aodigy          PA Phase 2 : Changed the Referee email checking from Lead to PersonAccount(Prospect)
 * 
** ******/
public class ReferralSelector extends ADGLIB_SObjectSelector{
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Referral__c');
    }
    
    public Schema.SObjectType getSObjectType() {
        return Referral__c.sObjectType;
    }
    
    /** PA MIGRATION : To Remove part-1 start */
    public List<Referral__c> selectByReferrerContactIdsAndStages( Set<String> setReferrerCntIds, Set<String> setStages ){
        adglib_QueryFactory query = newQueryFactory(false);
        query.selectFields(new Set<String>{ 'Referrer_Account__c', 
                                            'Referee_Account__c' , 'Referee_Account__r.PersonMobilePhone',  'Referee_Account__r.PersonEmail',
                                            'Referrer__c','Brand_Picklist__c',
                                            'Referee__c', 'Referee__r.Name' , 'Referee__r.Email', 'Referee__r.MobilePhone' , 
                                            'CreatedDate'} );
        String str_filter = ' Referrer__r.IsPersonAccount = false ';
        if( setReferrerCntIds <> null && !setReferrerCntIds.isEmpty() ) {
            setReferrerCntIds.remove( null );
            str_filter += ' AND Referrer__c IN :setReferrerCntIds ';
        }
        if( setStages <> null && !setStages.isEmpty() ){
            setStages.remove( null );
            str_filter += ' AND Stage__c IN :setStages ';
        }
        
        str_filter = str_filter.trim().removeStart('AND');
        query.setCondition( str_filter );
        System.debug('@@@@DEBUG selectByReferrerIdsAndStages :: soql = ' + query.toSOQL() );
        return Database.query(query.toSOQL());
    }
    /** PA MIGRATION : To Remove part-1 end */


    /** PA MIGRATION : Newly Added */
    public List<Referral__c> selectByReferrerPersonAccountIdsAndStages( Set<String> setReferrerPAIds, Set<String> setStages ) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectFields(new Set<String>{ 'Referee_Account__r.Name' , 'Referee_Account__r.PersonEmail', 'Referee_Account__r.PersonMobilePhone' } );
        String str_filter = ' Referrer_Account__r.isPersonAccount = true AND Referee_Account__r.isPersonAccount = true ';

        if( setReferrerPAIds <> null && !setReferrerPAIds.isEmpty() ) {
            setReferrerPAIds.remove( null );
            str_filter += ' AND Referrer_Account__c IN :setReferrerPAIds ';
        }
        if( setStages <> null && !setStages.isEmpty() ) {
            setStages.remove( null );
            str_filter += ' AND Stage__c IN :setStages ';
        }
        query.setCondition( str_filter );
        System.debug('@@@@DEBUG selectByReferrerPersonAccountIdsAndStages :: soql = ' + query.toSOQL() );
        return Database.query(query.toSOQL()); 
    }


    public List<Referral__c> selectByRefereeEmails( Set<String> setRefereeEmails , Set<string> setStrBrands){
        adglib_QueryFactory query = newQueryFactory(false);
        query.selectFields( new List<String>{ 'Referee__r.Email', 'Referee__c', 'Brand_Picklist__c' ,'Referrer__c', 'Stage__c', 'Referee_Account__r.PersonEmail'  } );
        //query.setCondition( 'Referee__r.Email IN :setRefereeEmails AND Brand_Picklist__c IN:setStrBrands AND Stage__c IN (\'Opened\', \'Successfully Referred\' )' );
        query.setCondition('Referee_Account__r.PersonEmail IN :setRefereeEmails AND Brand_Picklist__c IN:setStrBrands AND Stage__c IN (\'Opened\', \'Successfully Referred\' )');
        return Database.query(query.toSOQL());
    }

}