/**
 * @File Name          : RegisteredVehicleSelector.cls
 * @Description        : JIRA29
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/12/2020, 6:39:03 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      2/12/2020       jmt@aodigy.com          Initial Version
 * 1.1      2/24/2020       HS@aodigy.com           Added selectByChassisNumber
 * 1.2      6/22/2020       HS@aodigy.com           Added extra fields to retrieve in selectByChassisNumber, new method selectByIds
 *  		8/25/2020		Hung@aodigy.com			Added getChasisById
**/
public class RegisteredVehicleSelector extends ADGLIB_SObjectSelector{ 

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Registered_Vehicle__c');
    }
    
    public Schema.SObjectType getSObjectType() {
        return Registered_Vehicle__c.sObjectType;
    }

    public LIST<Registered_Vehicle__c> selectByMagicVehicle( SET<String> magicVehicleSet ){
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition( 'DWH_Vehicle_ID__c in :magicVehicleSet' ); 
        return (List<Registered_Vehicle__c> )Database.query(query.toSOQL()); 
    }

    public List<Registered_Vehicle__c> selectByChassisNumber( Set<String> setChassisNumber ){
        adglib_QueryFactory query = newQueryFactory();    
        query.selectFields(new Set<String>{ 'Contact__r.NRIC_Passport_No__c', 'Account__r.IsPersonAccount', 'Account__r.PersonContactId', 'Contact__r.IsPersonAccount', 'Model_Display_name__c'} );
        query.setCondition( 'Chasis_Number__c IN :setChassisNumber' ); 
        return (List<Registered_Vehicle__c> )Database.query(query.toSOQL()); 
    }
    
    public List<Registered_Vehicle__c> selectByChassisNumberAndMagicCustomer( Set<String> setChassisNumber ){
        adglib_QueryFactory query = newQueryFactory();    
        query.selectFields(new Set<String>{ 'Contact__r.NRIC_Passport_No__c', 'Account__r.IsPersonAccount', 'Account__r.PersonContactId', 'Contact__r.IsPersonAccount', 'Model_Display_name__c'} );
        query.setCondition( 'Chasis_Number__c IN :setChassisNumber AND MagicCustomer__c != null' ); 
        return (List<Registered_Vehicle__c> )Database.query(query.toSOQL()); 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Registered_Vehicle__c> getChasisById( String recordId ){
        return [SELECT Id, Chasis_Number__c FROM Registered_Vehicle__c WHERE Id = :recordId];
   	}

    public List<Registered_Vehicle__c> selectByIds( Set<Id> setRecordIds ){
        adglib_QueryFactory query = newQueryFactory();    
        query.selectFields(new Set<String>{ 'Contact__r.NRIC_Passport_No__c' , 'Contact__r.IsPersonAccount', 'Model_Display_name__c'} );
        query.setCondition( ' ID IN :setRecordIds' ); 
        return (List<Registered_Vehicle__c> )Database.query(query.toSOQL()); 
    }

    public String getIdByName(String vehNumber) {
        String regVehId = '';
        List<Registered_Vehicle__c> regVeh = [ SELECT Id FROM Registered_Vehicle__c WHERE Name = :vehNumber LIMIT 1];
        if (regVeh.size() > 0) {
            regVehId = regVeh[0].Id;
        }
        return regVehId;
    }

}