/*==========================================================================================================================================================================
 * Selector class for Payment Receipt Entity
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 * DATE::                   BY::                                TICKET::                      CHANGELOG
 * 14 Sep 2022              phan.thu@aodigy.com                 US-PR-000022                  Init
 * 03 Oct 2022              HS@aodigy                           DSA-US-0048                   Added getPaymentReceiptBySalesAgreementIds method         
 *        
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

    /*
    to remove
    public List<Payment_Receipt__c> getPaymentReceiptBySalesAgreementIds(Set<Id> setSAIds , Set<String> setStatuses )
    {
        Boolean assertCRUD = false;             // by pass CRUD
        Boolean enforceFLS = false;             // by pass FLS
        Boolean includeSelectorFields = true;   // include fields from getSObjectFieldList()

        ADGLIB_QueryFactory paymentReceiptQueryFactory = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Sales_Agreement__c IN : setSAIds AND Status__c IN: setStatuses');
        return Database.query(paymentReceiptQueryFactory.toSOQL());
    }
    */
}