/*==========================================================================================================================================================================
 * Selector class for Payment Receipt Line Item Entity
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            14 Sep 2022                       phan.thu@aodigy.com                    US-PR-000022                                            Init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class PaymentReceiptLineItemSelector extends ADGLIB_SObjectSelector 
{
    public Schema.SObjectType getSObjectType()
    {
        return Payment_Receipt_Line_Item__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }
}