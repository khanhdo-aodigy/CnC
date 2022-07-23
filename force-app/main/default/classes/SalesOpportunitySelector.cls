/** *****
 * Description : Selector Class for Sales Opportunity object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                Description
 * 20210104             HS@aodigy           Created Initial Version. 
 * 20210309             HS@aodigy           Set the getSalesOpportunitiesByAccountIds's SOQL ordering by CreatedDate, Salesman_Email__c
 * 
** *****/
public with sharing class SalesOpportunitySelector extends ADGLIB_SObjectSelector{
    
    public Schema.SObjectType getSObjectType() {
        return Sales_Opportunity__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Sales_Opportunity__c');
    }

    public List<Sales_Opportunity__c> getSalesOpportunitiesByIds( Set<Id> setRecordIds ){
        ADGLIB_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :setRecordIds')
             .setOrdering('Salesman_Email__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
        return Database.query( query.toSOQL() );
    }

    public List<Sales_Opportunity__c> getSalesOpportunitiesByAccountIds( Set<Id> setAccountIds , Set<String> setScEmails, Set<String> setStages ){
        List<Sales_Opportunity__c> lstSalesOppo = new List<Sales_Opportunity__c>();

        if( !setAccountIds.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Account__c IN :setAccountIds '; 
            
            if( setScEmails<> null && !setScEmails.isEmpty() ){ 
                str_filter += ' AND ( Salesman_Email__c IN :setScEmails OR Salesman_Email__c = null )'; 
            }

            if( setStages<> null && !setStages.isEmpty() ){
                str_filter += ' AND Status__c IN :setStages '; 
            }

            System.debug('@@@@DEBUG getSalesOpportunitiesByAccountIds :: setAccountIds = ' + setAccountIds);
            System.debug('@@@@DEBUG getSalesOpportunitiesByAccountIds :: setScEmails = ' + setScEmails);
            System.debug('@@@@DEBUG getSalesOpportunitiesByAccountIds :: setStages = ' + setStages);

            query.setCondition( str_filter );
            // query.setOrdering('Salesman_Email__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
            query.setOrdering('CreatedDate', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
            query.addOrdering('Salesman_Email__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
            System.debug('@@@@DEBUG getSalesOpportunitiesByAccountIds :: query.toSOQL() = ' + query.toSOQL() );
            lstSalesOppo = Database.query( query.toSOQL() );
        }
        return lstSalesOppo;
    }
   
    public void updateSalesOpptListByIdsAndStatus(Set<Id> setOpptIds, String oppStatus){
        List<Sales_Opportunity__c> lstSalesOppo = new List<Sales_Opportunity__c>();
        List<Sales_Opportunity__c> updatedlstSalesOppo = new List<Sales_Opportunity__c>();
        if( !setOpptIds.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' ID IN :setOpptIds '; 
            query.setCondition( str_filter );
            query.setOrdering('Salesman_Email__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
            lstSalesOppo = Database.query( query.toSOQL() );

            if(lstSalesOppo.size() > 0){
                for(Sales_Opportunity__c opp : lstSalesOppo){
                    opp.Status__c = oppStatus;
                    updatedlstSalesOppo.add(opp);
                }
            }
            update updatedlstSalesOppo;
        }
    }

    
}