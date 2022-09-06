/*==========================================================================================================================================================================
 * Selector class for Vehicle Shipment entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *              21 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000008                                      init
 *              27 Aug 2022                         phan.thu@aodigy.com                 US-Ship-000035                                      Added selectByIdWithInvoicesAndLineItems
 * ========================================================================================================================================================================== 
 */
public with sharing class VehicleShipmentSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType()
    {
        return Vehicle_Shipment__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    /**
     * Select vehicle shipments by record @withLineItems and @withMatchedVehicle as optional
     * @param orderIds: vehicle shipment ids
     * @param withLineItems: include shipment line items
     * @param withMatchedVehicle: include matched stock vehicle master
     */
    public List<Vehicle_Shipment__c> selectByIds(Set<Id> orderIds, Boolean withLineItems, Boolean withMatchedVehicle)
    {
        Boolean assertCRUD = false;             // by pass CRUD
        Boolean enforceFLS = false;             // by pass FLS
        Boolean includeSelectorFields = true;   // include fields from getSObjectFieldList()

        ADGLIB_QueryFactory shipmentQueryFactory = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Id IN :orderIds');

        shipmentQueryFactory.selectField('Release_Loc_loc_code__r.Name');
        shipmentQueryFactory.selectField('receipt_loc_loc_code__r.Name');
        shipmentQueryFactory.selectField('Declarant_Person_Name__r.Name');
        shipmentQueryFactory.selectField('Inward_Carrier__r.Name');
        shipmentQueryFactory.selectField('Declarant_Name__r.Name');
        shipmentQueryFactory.selectField('Importer_Name__r.Name');
        shipmentQueryFactory.selectField('Port_of_Loading__r.Name');

        if(withLineItems)
        {
            ADGLIB_QueryFactory lineItemsQueryFactory = shipmentQueryFactory.subselectQuery(Shipment_Line_Item__c.sObjectType);
            lineItemsQueryFactory.selectFields(new VehicleShipmentLineItemSelector().getSObjectFieldList());
        }
        
        if(withMatchedVehicle)
        {
            ADGLIB_QueryFactory stockVehicleMasterQueryFactory  = shipmentQueryFactory.subselectQuery(Vehicle_Master2__c.sObjectType);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Id);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Model_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Color_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Trim_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Production_Month__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Shipment_Line_Item__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Vehicle_Shipment__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Vehicle_Purchase_Status__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Purchase_Order_Status__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Vehicle_Status__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.CreatedDate);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Reservation_Start_Date__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Manufacturer_Ref_No__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.FOB_Amount__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.FOB_Amount_Currency_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Franchise_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Freight_Charges__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Freight_Charges_Currency_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Insurance_Charges__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Insurance_Charges_Currency_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Ex_Factory_Charges__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Ex_Factory_Charges_Currency_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Transport_Charges__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Transport_Charges_Currency_Code__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Other_Charges__c);
            stockVehicleMasterQueryFactory.selectField(Vehicle_Master2__c.Other_Charges_Currency_Code__c);
            // get SVM parent Color code
            stockVehicleMasterQueryFactory.selectField('Color_Code__r.ColorCode__c');
            stockVehicleMasterQueryFactory.selectField('Model_Code__r.Name');
            stockVehicleMasterQueryFactory.selectField('Trim_Code__r.Name');
        }
        
        return Database.query(shipmentQueryFactory.toSOQL());
    }

    /**
     * Select Vehicle Shipment by Id with @withInvoices and @withLineItems as optional
     * @param Id: Vehicle Shipment Id
     * @param withLineItems: include Shipment Line Items
     * @param withInvoices: include Manufacturer Invoices
    */
    public Vehicle_Shipment__c selectByIdWithInvoicesAndLineItems(String Id, Boolean withInvoices, Boolean withLineItems)
    {
        Boolean assertCRUD = false;              // by pass CRUD
        Boolean enforceFLS = false;              // by pass FLS
        Boolean includeSelectorFields = true;   // include fields from getSObjectFieldList()
        ADGLIB_QueryFactory shipmentQueryFactory = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Id =: Id');

        if(withLineItems)
        {
            ADGLIB_QueryFactory lineItemsQueryFactory = shipmentQueryFactory.subselectQuery(Shipment_Line_Item__c.sObjectType);
            lineItemsQueryFactory.selectField('Id');
            lineItemsQueryFactory.selectField('Name');
            lineItemsQueryFactory.selectField('Chassis_No__c');
            lineItemsQueryFactory.selectField('Engine_No__c');
            lineItemsQueryFactory.selectField('TN_Vehicle_Type__c');
            lineItemsQueryFactory.selectField('Invoice_No__r.Invoice_No__c');
            lineItemsQueryFactory.selectField('TN_HS_Code__r.Name');
            lineItemsQueryFactory.selectField('TN_CASC_Product_Code__c');
            lineItemsQueryFactory.selectField('Item_Group_Code__c');
        }
        
        if(withInvoices)
        {
            ADGLIB_QueryFactory manufacturerInvoiceQueryFactory  = shipmentQueryFactory.subselectQuery(Manufacturer_Invoice__c.sObjectType);
            manufacturerInvoiceQueryFactory.selectFields(new ManufacturerInvoiceSelector().getSObjectFieldList());           
        }

        return Database.query(shipmentQueryFactory.toSOQL());
    }
}