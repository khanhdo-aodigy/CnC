import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';

import SVMMC_CHANNEL from '@salesforce/messageChannel/SVMMC__c'
import getStockVehicleMastersForDutyRequest from '@salesforce/apex/VS_VehicleShipmentLWCController.getStockVehicleMastersForDutyRequest';

const COLS = 
[
    { label: 'Sales Duty Request Date', fieldName: 'Duty_Request_Date__c', type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit"}},
    { label: 'RVH Name', fieldName: 'Name', editable: false },
    { label: 'Inward Declaration Invoice', fieldName: 'Manufacturer_Invoice_Name', editable: false },
    { label: 'Vessel Code', fieldName: 'Vessel_Code__c', editable: false },
    { label: 'Invoice No.', fieldName: 'Invoice_No__c', editable: false },
    { label: 'Vehicle Status', fieldName: 'Vehicle_Status__c', editable: false },
    { label: 'Reservation No.', fieldName: 'Reservation_No__c', editable: false },
    { label: 'Agreement No.', fieldName: 'Agreement_No__c', type: 'text', editable: false },
    { label: 'Chassis No.', fieldName: 'Chassis__c', type: 'text', editable: false },
    { label: 'Trim Code', fieldName: 'Trim_Code_Name', type: 'text', editable: false },
    { label: 'Color Code', fieldName: 'Color_Code_Name', type: 'text', editable: false },
    { label: 'Model Code', fieldName: 'Model_Code_Name', type: 'text', editable: false }
];

export default class Vs_getSVMforDutyRequest extends LightningElement 
{
    @track stockVehicleMasters = [];
    @track selectedRowIds      = [];
    @track selectedRows        = [];
    
    disableSelectBtn = true;
    isHidden         = false;
    columns          = COLS;
    rowOffset        = 0;
    wiredRecords;

    @wire (MessageContext)
    messageContext;
 
    subscription = null;
 
    subscribeToMessageChannel() 
    {
        if (this.subscription) return;
       
        this.subscription = subscribe(this.messageContext, SVMMC_CHANNEL, (message) => 
        {
            this.handleMessage(message);
        });
    }
 
    unsubscribeToMessageChannel() 
    {
       unsubscribe(this.subscription);
       this.subscription = null;
    }

    handleMessage(message) {}
 
    connectedCallback() 
    {
       this.subscribeToMessageChannel();
    }
 
    disconnectedCallback() 
    {
       this.unsubscribeToMessageChannel;
    }

    get showSubmitButton()
    {
        return !this.selectedRowIds.length > 0;
    }

    get showTable()
    {
        return this.stockVehicleMasters.length > 0
    }

    @wire (getStockVehicleMastersForDutyRequest)
    wiredSVM(result)
    {
        this.wiredRecords = result;

        if (result.data)
        {
            this.stockVehicleMasters = JSON.parse(JSON.stringify(result.data));
            this.stockVehicleMasters.length > 0 && this.stockVehicleMasters.forEach(el => {
                el.Manufacturer_Invoice_Name = el.Inward_Declaration_Invoice__r?.Name;
                el.Trim_Code_Name            = el.Trim_Code__r?.Name;
                el.Color_Code_Name           = el.Color_Code__r?.Name;
                el.Model_Code_Name           = el.Model_Code__r?.Name;
            });
        }
    }

    handledSelectedRows(e)
    {
        let selectedRows = e.detail.selectedRows;
        selectedRows.length > 0 && (selectedRows.forEach(el => {this.selectedRowIds.push(el.Id)}), this.disableSelectBtn = false);
    }

    onSelect()
    {
        this.disableSelectBtn = true;
        this.isHidden         = true;
        
        const payload = 
        {
            action : 'select',
            data   : this.selectedRowIds
        };

        publish(this.messageContext, SVMMC_CHANNEL, payload);
    }

    async onReset()
    {
        this.selectedRows   = [];
        this.selectedRowIds = [];
        this.isHidden       = false;
        await refreshApex(this.wiredRecords);

        const payload = 
        {
            action : 'reset',
            data   : ''
        };

        publish(this.messageContext, SVMMC_CHANNEL, payload);
    }
}