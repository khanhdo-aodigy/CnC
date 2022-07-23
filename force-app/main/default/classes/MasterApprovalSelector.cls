/** ******
 * Description : Selector Class for Master Approval object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200729            TP@aodigy       Created Initial Version. 
 * 
** ******/
public inherited sharing class MasterApprovalSelector extends ADGLIB_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Master_Approval__c.Id,
            Master_Approval__c.Total_Amount__c    
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Master_Approval__c.sObjectType;
    }

    public Master_Approval__c selectMasterApprovalByUniqueKey(String uniqueKey) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Unique_Key__c =: uniqueKey');
        
        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null); 
    }
}