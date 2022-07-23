public class StockReservationSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Stock_Reservation__c.Id,
            Stock_Reservation__c.Opportunity__c,
            Stock_Reservation__c.Customer_Email__c,
            Stock_Reservation__c.Customer_First_Name__c,
            Stock_Reservation__c.Customer_Last_Name__c,
            Stock_Reservation__c.Customer_Mobile_Number__c,
            Stock_Reservation__c.Customer_Name__c,
            Stock_Reservation__c.Customer_Social_ID__c,
            Stock_Reservation__c.Birthdate__c,
            Stock_Reservation__c.MaritalStatus__c,
            Stock_Reservation__c.Salutation__c,
            Stock_Reservation__c.Gender__c,
            Stock_Reservation__c.Branch_Code__c,
            Stock_Reservation__c.Model_Code__c,
            Stock_Reservation__c.Registration_Type__c,
            Stock_Reservation__c.Package_Header_From_PickList__c,
            Stock_Reservation__c.Reservation_Status__c
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Stock_Reservation__c.sObjectType;
    }
    
    public override String getOrderBy() {
        return 'Name';
    }
    
    public List<Stock_Reservation__c> selectStockReservationsAndVehicleMasters(Set<Id> recordIds) {
        ADGLIB_QueryFactory query = newQueryFactory();
        query.setCondition('Id In :recordIds')
            .selectFields(new Set<String>{'Vehicle_Master__r.System_Commcase__c'});
        
        return (List<Stock_Reservation__c>)Database.query(query.toSOQL());
    }
    
    public List<Stock_Reservation__c> selectById(Set<Id> recordIds){
        return (List<Stock_Reservation__c>) selectSObjectsById(recordIds);
    }
}