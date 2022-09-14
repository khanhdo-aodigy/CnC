import { LightningElement, api, track, wire } from 'lwc';
import { deepClone } from 'c/util';

import getVehicleShipmentWithInvoicesAndLineItems from '@salesforce/apex/VS_VehicleShipmentLWCController.getVehicleShipmentWithInvoicesAndLineItems';

const SLI_COLS = 
[
    { label: 'Shipment Line Item', fieldName: 'Name', type: 'text', editable: false },
    { label: 'Chassis No.', fieldName: 'Chassis_No__c', type: 'text', editable: false },
    { label: 'Engine No.', fieldName: 'Engine_No__c', type: 'text', editable: false },
    { label: 'Vehicle Type', fieldName: 'TN_Vehicle_Type__c', type: 'text', editable: false }
];

const SVM_COLS =
[
    { label: 'RVH Name', fieldName: 'Name', type: 'text', editable: false },
    { label: 'Chassis No.', fieldName: 'Chassis__c', type: 'text', editable: false },
    { label: 'Engine No.', fieldName: 'Engine_No__c', type: 'text', editable: false },
    { label: 'Vehicle Type', fieldName: 'Vehicle_Type__c', type: 'text', editable: false }
];

export default class Vs_getsAsiaItemDetails extends LightningElement 
{
    @api vehicleShipmentId;
    @api transactionType;

    @track grouppedItems = [];
    @track item          = {};
    @track columns       = SLI_COLS;

    rowOffset               = 0;
    currentItemNo           = 1;
    allItems                = {};
    itemGroupCodes          = [];
    currentItemIds          = [];
    grouppedItemIds         = {};

    @wire (getVehicleShipmentWithInvoicesAndLineItems, {vehicleShipmentId: '$vehicleShipmentId', transactionType: '$transactionType'}) 
    wiredShipment(result)
    {
        if (result.data)
        {
            this.transactionType === 'IPT' && (this.columns = SVM_COLS);   
            this.transactionType === 'INP' && result.data.lineItems && (this.allItems = deepClone(result.data.lineItems));
            this.transactionType === 'IPT' && result.data.vehicleMasters && (this.allItems = deepClone(result.data.vehicleMasters));
            Object.keys(this.allItems) && (this.itemGroupCodes = Object.keys(this.allItems));
            this.itemGroupCodes.length > 0 && (this.grouppedItems = this.allItems[this.itemGroupCodes[0]]);

            if (this.grouppedItems.length > 0)
            {
                this.populateItem(this.grouppedItems[0]);
                this.generateGrouppedItemIdMap(this.grouppedItems, this.itemGroupCodes[0]);

                let index = this.currentItemNo + 1;
                !this.allItems[this.itemGroupCodes[index]] && this.dispatchEvent(new CustomEvent('lastitem', {}));
            }
            else
            {
                this.dispatchEvent(new CustomEvent('noItem', {}));
            }    
        }
    }

    populateItem(value)
    {
        this.item.TN_CASC_Product_Code__c = this.transactionType === 'INP' ? value.TN_CASC_Product_Code__c : value.Product_Code__r?.Product_Code__c;
        this.item.Invoice_No__c           = this.transactionType === 'INP' ? value.Invoice_No__r?.Invoice_No__c : value.Invoice_No__c;
        this.item.HS_Code__c              = value.TN_HS_Code__r?.Name;
    }

    generateGrouppedItemIdMap(grouppedItems, itemGroupCode)
    {
        grouppedItems.forEach(el => {this.currentItemIds.push(el.Id)});
        this.grouppedItemIds[itemGroupCode] = this.currentItemIds;
    }

    @api handleNext()
    {
        this.grouppedItems = this.allItems[this.itemGroupCodes[this.currentItemNo]];    
        this.generateGrouppedItemIdMap(this.grouppedItems, this.itemGroupCodes[this.currentItemNo]);  
        this.currentItemNo++;
        this.grouppedItems && this.populateItem(this.grouppedItems[0]);
        !this.allItems[this.itemGroupCodes[this.currentItemNo]] && this.dispatchEvent(new CustomEvent('lastitem', {}));
    }
    
    @api handleSubmit()
    {
        this.dispatchEvent(new CustomEvent('submititems', { detail : {value: this.grouppedItemIds}}));
    }
}