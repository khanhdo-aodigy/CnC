import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deepClone } from 'c/util';

import SVMMC_CHANNEL from '@salesforce/messageChannel/SVMMC__c'
import getGrouppedStockVehicleMasters from '@salesforce/apex/VS_VehicleShipmentLWCController.getGrouppedStockVehicleMasters';
import createInvoiceAndInwardDeclaration from '@salesforce/apex/VS_VehicleShipmentLWCController.createInvoiceAndInwardDeclaration';

const COLS = 
[
    { label: 'RVH Name', fieldName: 'Name', type: 'text', editable: false },
    { label: 'Chassis No.', fieldName: 'Chassis__c', type: 'text', editable: false },
    { label: 'Engine No.', fieldName: 'Engine_No__c', type: 'text', editable: false },
    { label: 'Vehicle Type', fieldName: 'Vehicle_Status__c', type: 'text', editable: false }
];

export default class Vs_groupSVMforDutyRequest extends LightningElement 
{
    columns                    = COLS;
    rowOffset                  = 0;
    currentItemNo              = 1;
    currentInvoiceNo           = 1;
    vesselCode                 = '';
    createdInvVesselCodes      = [];
    createdInvIds              = [];
    showCmp                    = false;
    showItemButton             = true;
    showNextItemButton         = true;
    showInvoiceButton          = true;
    showNextInvoiceButton      = true;
    showCreateInvoiceButton    = true;

    @track item                            = {};
    @track currentVehiclesByHSAndProdCodes = [];
    @track allVehicleMasters               = {};
    @track vesselCodes                     = [];
    @track vehicleMastersByVesselCode      = {};
    @track currentItemGroupCodes           = [];

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
 
    connectedCallback() 
    {
       this.subscribeToMessageChannel();
    }
 
    disconnectedCallback() 
    {
       this.unsubscribeToMessageChannel;
    }

    handleMessage(message) 
    {
        let _message = deepClone(message);
        let _action  = _message.action;

        switch (_action) 
        {
            case 'select':
                this.getStockVehicleMaster(_message.data);
                break;  
            case 'reset':
                this.resetAllValues();
                break;  
            default:
                break;
        }
    }

    async getStockVehicleMaster(data)
    {
        try 
        {
            const result = await getGrouppedStockVehicleMasters({stockVehicleMasterIds: data})
            result.grouppedVehicles && (this.allVehicleMasters = deepClone(result.grouppedVehicles), this.showCmp = true);
            Object.keys(this.allVehicleMasters) && (this.vesselCodes = Object.keys(this.allVehicleMasters));
            this.vesselCodes.length > 0 && this.generateValues(0);    
        } 
        catch (error) 
        {
            console.log(error.body.message);
        }
    }

    generateValues(index)
    {
        this.vesselCodes.length === 1 && (this.showInvoiceButton = false)
        this.vesselCode = this.vesselCodes[index];
        this.vesselCode && (this.vehicleMastersByVesselCode = this.allVehicleMasters[this.vesselCode]);
        this.createdInvVesselCodes.indexOf(this.vesselCode) !== -1 && (this.showCreateInvoiceButton = false);
        Object.keys(this.vehicleMastersByVesselCode) && (this.currentItemGroupCodes = Object.keys(this.vehicleMastersByVesselCode));
        this.currentItemGroupCodes.length > 0 && (this.currentVehiclesByHSAndProdCodes = this.vehicleMastersByVesselCode[this.currentItemGroupCodes[0]]);   

        if (this.currentVehiclesByHSAndProdCodes.length > 0)
        {
            this.showItemButton     = true;
            this.showNextItemButton = true;
            this.populateItem(this.currentVehiclesByHSAndProdCodes[0]);
            !this.vehicleMastersByVesselCode[this.currentItemGroupCodes[this.currentItemNo]] && (this.showItemButton = false)
        }  
    }

    populateItem(value)
    {
        this.item.TN_CASC_Product_Code__c = value.Product_Code__r?.Product_Code__c;
        this.item.Invoice_No__c           = value.Invoice_No__c;
        this.item.HS_Code__c              = value.TN_HS_Code__r?.Name;
    }

    onNextItem()
    {
        this.currentVehiclesByHSAndProdCodes = this.vehicleMastersByVesselCode[this.currentItemGroupCodes[this.currentItemNo]];   
        this.currentItemNo++;
        this.currentVehiclesByHSAndProdCodes && this.populateItem(this.currentVehiclesByHSAndProdCodes[0]);
        !this.vehicleMastersByVesselCode[this.currentItemGroupCodes[this.currentItemNo]] && (this.showNextItemButton = false)
    }

    onPreviousItem()
    {
        this.currentItemNo = this.currentItemNo - 2;
        this.currentVehiclesByHSAndProdCodes = this.vehicleMastersByVesselCode[this.currentItemGroupCodes[this.currentItemNo]];   
        this.currentVehiclesByHSAndProdCodes && this.populateItem(this.currentVehiclesByHSAndProdCodes[0]);
        !this.vehicleMastersByVesselCode[this.currentItemGroupCodes[this.currentItemNo - 1]] && (this.showNextItemButton = true)
        this.currentItemNo++;
    }

    onNextInvoice()
    {
        this.currentItemNo           = 1;
        this.showCreateInvoiceButton = true;
        this.showNextInvoiceButton   = true;
        this.generateValues(this.currentInvoiceNo); 
        this.currentInvoiceNo++;  
        !this.vesselCodes[this.currentInvoiceNo] && (this.showNextInvoiceButton = false);   
    }

    onPreviousInvoice()
    {
        this.currentInvoiceNo        = this.currentInvoiceNo - 2;
        this.currentItemNo           = 1;
        this.showCreateInvoiceButton = true;
        this.generateValues(this.currentInvoiceNo);  
        !this.vesselCodes[this.currentInvoiceNo - 1] && (this.showNextInvoiceButton = true)
        this.currentInvoiceNo++;    
    }

    async onCreate()
    {
        try 
        {
            const result = await createInvoiceAndInwardDeclaration({vehicleMastersByVessel: this.vehicleMastersByVesselCode});
            this.showCreateInvoiceButton = false;
            this.createdInvVesselCodes.push(this.vesselCode);

            if (result)
            {
                this.showNotification('SUCCESS!', 'Duty Payment Invoice - Vessel Code ' + this.vesselCode + ' has been successully created.', 'success', 'sticky');
            }

            this.createdInvIds.push(result);
            const payload = 
            {
                action : 'create',
                data   : this.createdInvIds
            };
    
            publish(this.messageContext, SVMMC_CHANNEL, payload);
        } 
        catch (error) 
        {
            this.showNotification('ERROR!', 'Duty Payment Invoice cann\'t be successully created. Reason: ' + error.body.message + '. Please contact your Administrator.', 'error', 'sticky');
        }
    }

    resetAllValues()
    {
        this.showCmp                 = false;
        this.showItemButton          = true;
        this.showNextItemButton      = true;
        this.showInvoiceButton       = true;
        this.showNextInvoiceButton   = true;
        this.showCreateInvoiceButton = true;

        this.currentItemNo              = 1;
        this.currentInvoiceNo           = 1;
        this.vesselCode                 = '';

        this.createdInvVesselCodes           = [];
        this.item                            = {};
        this.currentVehiclesByHSAndProdCodes = [];
        this.allVehicleMasters               = {};
        this.vesselCodes                     = [];
        this.vehicleMastersByVesselCode      = {};
        this.currentItemGroupCodes           = []; 
        this.createdInvIds                   = [];
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