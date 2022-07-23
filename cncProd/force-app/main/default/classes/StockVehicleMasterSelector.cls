public inherited sharing class StockVehicleMasterSelector extends ADGLIB_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Vehicle_Master2__c.Id,
            Vehicle_Master2__c.System_Commcase__c
		};
    }    
    
    public Schema.SObjectType getSObjectType() {
        return Vehicle_Master2__c.sObjectType;
    }    
    
    public List<Vehicle_Master2__c> selectStockVehicleMastersBySystemCommcases(Set<String> systemCommcases) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('System_Commcase__c In :systemCommcases');
        
        return Database.query(query.toSOQL());
    }
}