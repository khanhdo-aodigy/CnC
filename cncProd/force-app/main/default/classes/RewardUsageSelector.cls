/** ******
 * Description : Selector Class for Reward Usage object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200617             TP@aodigy       Created Initial Version. 
 * 
** ******/
public inherited sharing class RewardUsageSelector extends ADGLIB_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Reward_Usage__c.Id,
            Reward_Usage__c.RecordTypeId,
            Reward_Usage__c.Type__c,
            Reward_Usage__c.Status__c,
            Reward_Usage__c.Credit_Amount__c,
            Reward_Usage__c.Reward__c,
            Reward_Usage__c.Autoline_Invoice_Date__c,
            Reward_Usage__c.Autoline_Invoice_Number__c,
            Reward_Usage__c.e_Invoice__c,
            Reward_Usage__c.e_Invoice_Date__c,
            Reward_Usage__c.Order__c,
            Reward_Usage__c.Order_Number__c,
            Reward_Usage__c.Channel__c,
            Reward_Usage__c.Transaction_Date__c,
            Reward_Usage__c.Payment__c,
            Reward_Usage__c.Credit_Note__c,
            Reward_Usage__c.Reward_Usage__c,
            Reward_Usage__c.Refund_Reason__c,
            Reward_Usage__c.CreatedDate,
            Reward_Usage__c.Contact__c,
            Reward_Usage__c.Invoice_Amount__c,
            Reward_Usage__c.Reward_Expiry__c,
            Reward_Usage__c.Outstanding_Payment_Amount__c,
            Reward_Usage__c.Payment_Type__c,
            Reward_Usage__c.COST__c,
            Reward_Usage__c.Location__c,
            Reward_Usage__c.Source__c,
            Reward_Usage__c.NLCODE__c
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Reward_Usage__c.sObjectType;
    }

    public String getRecordTypeNameById(String recordTypeId)
    {
        return Schema.getGlobalDescribe().get('Reward_Usage__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    } 

    public List<Reward_Usage__c> selectRewardUsagesByOrderId(String orderId, String condition){
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Order__c =: orderId');
        if(String.isNotEmpty(condition)) {
            query.setCondition('Order__c =: orderId AND ' + condition );
        }
        
        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null); 
    }


    public List<Reward_Usage__c> selectRewardUsagesByInvoiceNo(String invoiceNo, String rewardProfileId) {
        adglib_QueryFactory query = newQueryFactory();
        List<String> queryFields = new List<String> {'Reward__r.Expiry__c','Reward__r.Status__c','Reward__r.Credit__c','Reward__r.Credited_Usage__c','Reward__r.Debited_Usage__c', 'Invoice_Amount__c', 'Autoline_Invoice_Date__c'};
        // query.setCondition('Autoline_Invoice_Number__c =: invoiceNo AND (Reward__r.Status__c = \'Valid\' OR Reward__r.Status__c = \'Consumed\')')
        System.debug('testing - invoiceNo = ' + invoiceNo);
        System.debug('testing - rewardProfileId = ' + rewardProfileId);
        query.subselectQuery('Refunds__r')
             .selectFields(new RewardUsageSelector().getSObjectFieldList())
             .setOrdering('CreatedDate', ADGLIB_QueryFactory.SortOrder.DESCENDING);
             
        // query.setCondition('Autoline_Invoice_Number__c =: invoiceNo AND (Reward__r.Status__c = \'Valid\' OR Reward__r.Status__c = \'Consumed\') AND Reward__r.Reward_Profile__c =:rewardProfileId ')
        query.setCondition('Autoline_Invoice_Number__c =: invoiceNo AND (Reward__r.Status__c != \'Provisioning\' ) AND Reward__r.Reward_Profile__c =:rewardProfileId ')
             .selectFields(queryFields)
             .setOrdering('Reward__r.Expiry__c', ADGLIB_QueryFactory.SortOrder.DESCENDING);

        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null);            
    }

    public List<Reward_Usage__c> selectRewardUsagesByPaymentIds(Set<Id> setPaymentIds) {
        adglib_QueryFactory query = newQueryFactory();
        List<String> queryFields = new List<String> {'Reward_Usage__r.Payment__c'};
        query.setCondition('Payment__c IN :setPaymentIds ')
             .selectFields(queryFields)
             .setOrdering('Reward__c', ADGLIB_QueryFactory.SortOrder.DESCENDING);   
        return (List<Reward_Usage__c> )Database.query(query.toSOQL());       
    }


    public List<Reward_Usage__c> selectRewardUsagesByIds( Set<Id> setRewardUsageIds, Set<Id> setRecordTypeIds ) {
        adglib_QueryFactory query = newQueryFactory();
        List<String> lstStrCondition = new List<String>();
        List<String> queryFields = new List<String> {'Reward__r.Type__c','Reward__r.Status__c','Order__r.OrderID__c','Order__r.Contact__c','Order__r.Account__c',
                                                        'Reward__r.Branch__c','Reward__r.Brand__c','Reward__r.Reward_Profile__c','Reward_Usage__r.Payment__c', 'Reward__r.Reward_Profile__r.Total_Remainder__c'};

        if( setRewardUsageIds <> null && !setRewardUsageIds.isEmpty() ){
            lstStrCondition.add('Id IN : setRewardUsageIds ' );
        }
        if( setRecordTypeIds <> null && !setRecordTypeIds.isEmpty()  ){
            lstStrCondition.add('RecordTypeId IN :setRecordTypeIds ');
        }

        String strWhereClause = String.join(lstStrCondition, ' AND ');
        query.setCondition(strWhereClause)
            .selectFields(queryFields)
            .setOrdering('Reward__c', ADGLIB_QueryFactory.SortOrder.DESCENDING);    

        return (List<Reward_Usage__c> )Database.query(query.toSOQL()); 
    }


    public List<Reward_Usage__c> selectUsagesByRewardIds( Set<Id> setRewardIds, Set<String> setStatuses, Set<String> setChannels, Set<Id> setRecordTypeIds ){
        adglib_QueryFactory query = newQueryFactory();
        List<String> lstStrCondition = new List<String>();
        List<String> queryFields = new List<String> {'Reward__r.Type__c','Reward__r.Status__c'};

        if( setRewardIds <> null && !setRewardIds.isEmpty() ){
            lstStrCondition.add('Reward__c IN : setRewardIds ' );
        }
        if( setStatuses <> null && !setStatuses.isEmpty()  ){
            lstStrCondition.add('Status__c IN :setStatuses ');
        }
        if( setChannels <> null && !setChannels.isEmpty()  ){
            lstStrCondition.add('Channel__c IN :setChannels ');
        }
        if( setRecordTypeIds <> null && !setRecordTypeIds.isEmpty()  ){
            lstStrCondition.add('RecordTypeId IN :setRecordTypeIds ');
        }

        String strWhereClause = String.join(lstStrCondition, ' AND ');
        query.setCondition(strWhereClause)
             .selectFields(queryFields)
             .setOrdering('Reward__c', ADGLIB_QueryFactory.SortOrder.DESCENDING);     
        return (List<Reward_Usage__c> )Database.query(query.toSOQL()); 
    }

    public List<Reward_Usage__c> selectRewardUsageHistory(String recordTypeId, String contactId, String regVehId, String brand, Integer previousMonth) {
        System.debug('*************************');
        System.debug('recordTypeId = ' + recordTypeId);
        System.debug('contactId = ' + contactId);
        System.debug('regVehId = ' + regVehId);
        System.debug('brand = ' + brand);
        System.debug('previousMonth = ' + previousMonth);
        adglib_QueryFactory query = newQueryFactory();
        Integer queryMonth;
        if(previousMonth != null) {
            queryMonth = Date.today().addMonths(-previousMonth).month();
        }

        List<String> conditions = new List<String>();
        List<String> queryFields = new List<String> {'Id', 'RecordTypeId', 'Channel__c', 'Type__c', 'Credit_Amount__c', 'Status__c', 'Transaction_Date__c', 'e_Invoice__c', 'e_Invoice_Date__c', 'Autoline_Invoice_Number__c', 'Autoline_Invoice_Date__c', 'Reward__r.Type__c', 'Reward__c', 'Reward__r.Brand__c'};
        if(String.isNotBlank(recordTypeId)){
            conditions.add('Reward__r.Reward_Profile__r.RecordTypeId = :recordTypeId');
        }
        if(String.isNotBlank(contactId)){
            conditions.add('Reward__r.Contact__c = :contactId');
        }
        if(String.isNotBlank(regVehId)){
            conditions.add('Reward__r.Registered_Vehicle__c = :regVehId');
        }
        if(String.isNotBlank(brand)){
            conditions.add('Reward__r.Brand__c = :brand');
        }
        
        if(queryMonth != null) {            
            conditions.add('CALENDAR_MONTH(Transaction_Date__c) = :queryMonth');
        }
        
        System.debug('queryMonth = ' + queryMonth);
        
        String strWhereClause = String.join(conditions, ' AND ');
        query.selectFields(queryFields)
             .setCondition(strWhereClause);
        System.debug('query = ' + query);
        return (List<Reward_Usage__c> )Database.query(query.toSOQL());    
    }

    public List<Reward_Usage__c> selectRewardUsagesByCreditNote (String creditNote, String recordTypeId)
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Credit_Note__c =: creditNote AND recordTypeId =: recordTypeId');
        
        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null); 
    }

    public List<Reward_Usage__c> selectDebitRewardUsagesByInvoiceNo (String invoiceNo, String recordTypeId)
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Autoline_Invoice_Number__c =: invoiceNo AND recordTypeId =: recordTypeId');
        
        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null); 
    }

    public List<Reward_Usage__c> selectRewardUsagesByIds(Set<Id> usageIdSet) {
        adglib_QueryFactory query = newQueryFactory();
        List<String> queryFields = new List<String> {'Reward__r.Reward_Profile__c', 'Reward__r.Registered_Vehicle__c'};
        query.selectFields(queryFields)
             .setCondition('Id IN :usageIdSet ');   
        return (List<Reward_Usage__c> )Database.query(query.toSOQL());       
    }
}