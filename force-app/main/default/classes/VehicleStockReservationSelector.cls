/** *****
 * Description : Service class for Vehicle Stock Reservation object
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20210105             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/
public with sharing class VehicleStockReservationSelector extends ADGLIB_SObjectSelector {
    public Schema.SObjectType getSObjectType() {
        return Vehicle_Stock_Reservation__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Vehicle_Stock_Reservation__c');
    }

    public List<Vehicle_Stock_Reservation__c> getReservationsByNumbers( Set<String> reservationNumbers ){
        List<Vehicle_Stock_Reservation__c> resList = new List<Vehicle_Stock_Reservation__c>();

        if( !reservationNumbers.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Name IN :reservationNumbers '; 
            query.setCondition( str_filter );
            resList = Database.query( query.toSOQL() );
        }
        return resList;
    }

    public List<Vehicle_Stock_Reservation__c> getReservationsByIds( Set<Id> reservationIds ){
        List<Vehicle_Stock_Reservation__c> resList = new List<Vehicle_Stock_Reservation__c>();

        if( !reservationIds.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Id IN :reservationIds '; 
            query.setCondition( str_filter );
            resList = Database.query( query.toSOQL() );
        }
        return resList;
    }
    
    public List<Vehicle_Stock_Reservation__c> getReservationByStockNo( Set<String> stockNumbers){
        List<Vehicle_Stock_Reservation__c> resList = new List<Vehicle_Stock_Reservation__c>();

        if( !stockNumbers.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();   
            query.selectFields(new Set<String>{ 'Used_Car_Vehicle_Stock__r.Stock_Number__c' , 'Used_Car_Vehicle_Stock__c' , 'Account__c',
            'Account__r.PersonEmail', 'Sales_Opportunity__c', 'Sales_Opportunity__r.Status__c', 'Sales_Opportunity__r.Close_Date__c' });
 
            String str_filter = ' Used_Car_Vehicle_Stock__r.Stock_Number__c IN :stockNumbers'; 
            query.setCondition( str_filter );
            query.setOrdering('CREATEDDATE', adglib_QueryFactory.SortOrder.DESCENDING, false);
            resList = Database.query( query.toSOQL() );
        }
        return resList;
    }
  
}