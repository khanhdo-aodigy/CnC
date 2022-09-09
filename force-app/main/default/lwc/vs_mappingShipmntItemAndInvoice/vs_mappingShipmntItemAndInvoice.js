import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getUnmatchedLineItems from '@salesforce/apex/VS_VehicleShipmentLWCController.getUnmatchedLineItems';
import getManufacturerInvoices from '@salesforce/apex/VS_VehicleShipmentLWCController.getManufacturerInvoices';
import matchManufacturerInvoiceAndLineItem from '@salesforce/apex/VS_VehicleShipmentLWCController.matchManufacturerInvoiceAndLineItem';

const COLS = 
[
    { label: 'Shipment Line Item Name', fieldName: 'Name', type: 'text', editable: false },
    { label: 'Production Month', fieldName: 'Production_Month__c', type: 'text', editable: false },
    { label: 'Model', fieldName: 'Model__c', type: 'text', editable: false },
    { label: 'Colour Code', fieldName: 'Colour_Code__c', type: 'text', editable: false },
    { label: 'Trim', fieldName: 'Trim__c', type: 'text', editable: false },
    { label: 'Manufacturer Ref. No.', fieldName: 'Manufacturer_Ref_No__c', type: 'text', editable: false },
    { label: 'Chassis No.', fieldName: 'Chassis_No__c', type: 'text', editable: false },
    { label: 'Engine No.', fieldName: 'Engine_No__c', type: 'text', editable: false }
];

export default class Vs_mappingShipmntItemAndInvoice extends LightningElement 
{
    @api recordId;
    @track selectedRowIds = [];
    @track unmatchedLineItems = [];

    columns          = COLS;
    rowOffset        = 0;
    selectedInvoice  = '';
    spinner          = false;
    manufacturerInvoices;
    wiredRecords;

    @wire (getManufacturerInvoices, {vehicleShipmentId: '$recordId'}) 
    wiredInvoices(result)
    {
        if (result.data)
        {
            result.data.length > 0 && (this.manufacturerInvoices = result.data);
        }
    }

    @wire (getUnmatchedLineItems, {vehicleShipmentId: '$recordId'}) 
    wiredLineItems(result)
    {
        this.wiredRecords = result;
        if (result.data)
        {
            result.data.length > 0 && (this.unmatchedLineItems = result.data);
            result.data.length == 0 && (this.unmatchedLineItems = []);
        }
    }

    get invoices()
    {
        let invoiceOptions = [];
        this.manufacturerInvoices && this.manufacturerInvoices.forEach(el => invoiceOptions.push({label: el.Invoice_No__c, value: el.Id}));

        return invoiceOptions;
    }

    get hasData()
    {
        return this.manufacturerInvoices && this.unmatchedLineItems.length > 0;
    }

    set hasData(_hasData)
    {
        return false;
    }

    get isDisabled()
    {
        return this.selectedInvoice === '' || this.selectedRowIds.length == 0;
    }

    set isDisabled(_isDisabled)
    {
        return true;
    }

    handleChange(e)
    {
        this.selectedInvoice = e.currentTarget.value;
    }

    handledSelectedRows(e) 
    {
        let selectedRows    = e.detail.selectedRows;
        this.selectedRowIds = [];
        selectedRows.length > 0 && selectedRows.forEach(el => {this.selectedRowIds.push(el.Id)});
    }

    async onMatch()
    {
        try
        {
            this.spinner = true;
            const result = await matchManufacturerInvoiceAndLineItem({
                                    invoiceId: this.selectedInvoice,
                                    lineItemIds: this.selectedRowIds
                                })

            if (result)
            {
                this.refreshValues();
                await refreshApex(this.wiredRecords);
                this.showNotification('SUCCESS!', 'Manufacturer Invoice and Shipment Line Items have been successfully matched!', 'success', 'dismissible');
            }
        }
        catch (error)
        {
            this.refreshValues();
            await refreshApex(this.wiredRecords);
            this.showNotification('ERROR!', 'An error has occurred - ' + error.body.message + '. Please try again or contact your Administrator.', 'error', 'sticky');
        }
    }

    refreshValues()
    {
        this.selectedInvoice = '';
        this.selectedRowIds  = [];
        this.spinner         = false;
    }

    onCancel()
    {
        this.dispatchEvent(new CustomEvent ('close', {}));
    }

    showNotification(title, message, variant, mode) 
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }
}