/** *****
 * Description : Selector Class for Payment (i.e. Invoice__c) object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200630            HS@aodigy            Created Initial Version 
 * 
** *****/
public class PaymentSelector extends ADGLIB_SObjectSelector{

    public Schema.SObjectType getSObjectType(){
        return Invoice__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Invoice__c');
    }

    public List<Invoice__c> selectPaymentsByIds( Set<Id> setPaymentIds ){
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition(' ID IN :setPaymentIds ');
        return (List<Invoice__c> )Database.query(query.toSOQL()); 
    }

    public List<Invoice__c> selectPaymentsByOrderId(String orderId ){
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition(' E_shop_OrderId__c =: orderId ');
        return (List<Invoice__c> )Database.query(query.toSOQL()); 
    }

    public List<Invoice__c> selectPaymentsByTypeAndDateFiters( Set<Id> setRecordTypeIds, Set<String> setPaymentTypes, Set<String> setTransactionTypes, Date dateFilter ){
        adglib_QueryFactory query = newQueryFactory();
        List<String> lstStrCondition = new List<String>();
        
        System.debug('@@@@DEBUG selectPaymentsByTypeFiters :: setRecordTypeIds = ' + setRecordTypeIds.size() + ' --- ' + setRecordTypeIds);
        System.debug('@@@@DEBUG selectPaymentsByTypeFiters :: setPaymentTypes = ' + setPaymentTypes.size() + ' --- ' + setPaymentTypes);
        System.debug('@@@@DEBUG selectPaymentsByTypeFiters :: setTransactionTypes = ' + setTransactionTypes.size() + ' --- ' + setTransactionTypes);
        System.debug('@@@@DEBUG selectPaymentsByTypeFiters :: dateFilter = ' + dateFilter);

        if( setRecordTypeIds <> null && !setRecordTypeIds.isEmpty() ){
            lstStrCondition.add('RecordTypeId IN : setRecordTypeIds ' );
        }
        if( setPaymentTypes <> null && !setPaymentTypes.isEmpty()  ){
            lstStrCondition.add('Payment_Type__c IN :setPaymentTypes ');
        }
        if( setTransactionTypes <> null && !setTransactionTypes.isEmpty()  ){
            lstStrCondition.add('Transaction_Type__c IN :setTransactionTypes ');
        }
        if( dateFilter <> null ){   
            if( dateFilter < Date.today().addDays( -7 ) ){
                dateFilter = Date.today().addDays( -7 );
            }
            lstStrCondition.add('CreatedDate >= :dateFilter ');
        }

        String strWhereClause = String.join(lstStrCondition, ' AND ');
        System.debug('@@@@DEBUG selectPaymentsByTypeFiters :: strWhereClause = ' + strWhereClause);

        query.setCondition(strWhereClause)
             .setOrdering('E_shop_Order__c', ADGLIB_QueryFactory.SortOrder.DESCENDING);     

        System.debug('@@@@DEBUG selectPaymentsByTypeFiters :: strWhereClause = ' + strWhereClause);
        return (List<Invoice__c> )Database.query(query.toSOQL()); 
    }

}