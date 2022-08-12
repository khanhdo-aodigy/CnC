/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Line Items Entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      27 July 2022                        dangphap.mai@aodigy.com                 US-VPO-000016                                              init
 * ========================================================================================================================================================================== 
 */
public inherited sharing class VPOLineItemsSelector extends ADGLIB_SObjectSelector
{
    public VPOLineItemsSelector() {

    }

    public Schema.SObjectType getSObjectType()
    {
        return Vehicle_Purchase_Order_Line_Items__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        // return new List<Schema.SObjectField>
        // {
        //     Vehicle_Purchase_Order_Line_Items__c.Color_Master__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Colour_Description__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Currency_Code__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Model_Color_Trim_Master__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Model_Master__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Remarks__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Total_Price__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Trim_Master__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Unit_Price__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Units_Cancelled__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Units_Confirmed__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Units_Ordered__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Units_Pending__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Vehicle_Purchase_Order__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Model_Year_Master__c,
        //     Vehicle_Purchase_Order_Line_Items__c.Name,
        //     Vehicle_Purchase_Order_Line_Items__c.LastModifiedById,
        //     Vehicle_Purchase_Order_Line_Items__c.CreatedById
        // };

        return getSObjectType().getDescribe().fields.getMap().values();
    }
}