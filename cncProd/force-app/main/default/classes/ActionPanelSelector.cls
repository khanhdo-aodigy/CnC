public class ActionPanelSelector extends ADGLIB_SObjectSelector {
    

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Action_Panel__mdt');
    }
    
    public Schema.SObjectType getSObjectType() {
        return Action_Panel__mdt.sObjectType;
    }
    
    public override String getOrderBy() {
    	return 'Position__c';
    }
    
    public LIST<Action_Panel__mdt> getButtonsByPage(String objName){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Object__c =: objName AND Visible__c = true');
        return (List<Action_Panel__mdt>) Database.query(query.toSOQL());
    }
            
}