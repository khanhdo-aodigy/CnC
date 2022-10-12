/*==========================================================================================================================================================================
 * Selector class for Payment Receipt Entity
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            14 Sep 2022                       phan.thu@aodigy.com                    US-PR-000022                                            Init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class PaymentReceiptSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType()
    {
        return Payment_Receipt__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public Payment_Receipt__c getPaymentReceiptByIdWithLineItems(Id recordId, Boolean withLineItems)
    {
        Boolean assertCRUD = false;             // by pass CRUD
        Boolean enforceFLS = false;             // by pass FLS
        Boolean includeSelectorFields = true;   // include fields from getSObjectFieldList()

        ADGLIB_QueryFactory paymentReceiptQueryFactory = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Id =: recordId');


        if(withLineItems)
        {
            ADGLIB_QueryFactory lineItemsQueryFactory = paymentReceiptQueryFactory.subselectQuery(Payment_Receipt_Line_Item__c.sObjectType);
            lineItemsQueryFactory.selectFields(new PaymentReceiptLineItemSelector().getSObjectFieldList());
            lineItemsQueryFactory.selectField('Sales_Agreement__r.Name');
        }
        
        return Database.query(paymentReceiptQueryFactory.toSOQL());
    }
}