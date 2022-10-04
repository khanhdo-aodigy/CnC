import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { deepClone } from 'c/util';

import SVMMC_CHANNEL from '@salesforce/messageChannel/SVMMC__c'
import getManufacturerInvoicesByIds from '@salesforce/apex/VS_VehicleShipmentLWCController.getManufacturerInvoicesByIds';

const COLS = 
[
    { label: 'Invoice Name', fieldName: 'Name', editable: false },
    { label: 'Invoice No.', fieldName: 'Invoice_No__c', editable: false },
    { label: 'Invoice Date', fieldName: 'Invoice_Date__c', editable: false, type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit"}},
];

export default class Vs_getInwardDeclarationInvoices extends LightningElement 
{
    @track invoices   = [];
    @track invoiceIds = [];
    
    columns   = COLS;
    rowOffset = 0;
    showCmp   = false;
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

    handleMessage(message) 
    {
        let _message = deepClone(message);
        let _action  = _message.action;

        switch (_action) 
        {
            case 'reset':
                this.invoiceIds = [];
                this.showCmp    = false;
                break; 
            case 'create':
                this.invoiceIds = _message.data
                this.showCmp    = true;       
                break;  
            default:
                break;
        }
    }
 
    connectedCallback() 
    {
       this.subscribeToMessageChannel();
    }
 
    disconnectedCallback() 
    {
       this.unsubscribeToMessageChannel;
    }

    @wire (getManufacturerInvoicesByIds, {invoiceIds: '$invoiceIds'}) 
    wiredInvoices(result)
    {
        if (result.data)
        {
            this.invoices = result.data;
            console.log(JSON.stringify(result.data));
        }

        if (result.error)
        {
            console.log(result.error);
        }
    }
}