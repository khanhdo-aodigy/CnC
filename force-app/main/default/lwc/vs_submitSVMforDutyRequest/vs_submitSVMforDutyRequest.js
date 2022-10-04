import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { deepClone } from 'c/util';

import getGrouppedStockVehicleMastersByInwardDecId from '@salesforce/apex/VS_VehicleShipmentLWCController.getGrouppedStockVehicleMastersByInwardDecId';
import submitToGetsAsiaIPT from '@salesforce/apex/VS_VehicleShipmentLWCController.submitToGetsAsiaIPT';

const COLS =
[
    { label: 'RVH Name', fieldName: 'Name', type: 'text', editable: false },
    { label: 'Chassis No.', fieldName: 'Chassis__c', type: 'text', editable: false },
    { label: 'Engine No.', fieldName: 'Engine_No__c', type: 'text', editable: false },
    { label: 'Vehicle Type', fieldName: 'Vehicle_Type__c', type: 'text', editable: false }
];
export default class Vs_submitSVMforDutyRequest extends LightningElement 
{
    @api recordId;

    @track grouppedItems  = [];
    @track item           = {};
    @track columns        = COLS;

    rowOffset               = 0;
    currentItemNo           = 1;
    allItems                = {};
    itemGroupCodes          = [];
    currentItemIds          = [];
    grouppedItemIds         = {};
    isLastItem              = false;
    showSpinner             = false;

    @wire (getGrouppedStockVehicleMastersByInwardDecId, {inwardDeclarationId: '$recordId'}) 
    wiredSVMs(result)
    {
        if (result.data)
        { 
            result.data.vehicleMasters && (this.allItems = deepClone(result.data.vehicleMasters));
            Object.keys(this.allItems) && (this.itemGroupCodes = Object.keys(this.allItems));
            this.itemGroupCodes.length > 0 && (this.grouppedItems = this.allItems[this.itemGroupCodes[0]]);

            if (this.grouppedItems.length > 0)
            {
                this.populateItem(this.grouppedItems[0]);
                this.generateGrouppedItemIdMap(this.grouppedItems, this.itemGroupCodes[0]);

                let index = this.currentItemNo + 1;
                !this.allItems[this.itemGroupCodes[index]] && (this.isLastItem = true);
            } 
        }
    }

    populateItem(value)
    {
        this.item.TN_CASC_Product_Code__c = value.Product_Code__r?.Product_Code__c;
        this.item.Invoice_No__c           = value.Invoice_No__c;
        this.item.HS_Code__c              = value.TN_HS_Code__r?.Name;
    }

    generateGrouppedItemIdMap(grouppedItems, itemGroupCode)
    {
        grouppedItems.forEach(el => {this.currentItemIds.push(el.Id)});
        this.grouppedItemIds[itemGroupCode] = this.currentItemIds;
    }

    onNext()
    {
        this.grouppedItems = this.allItems[this.itemGroupCodes[this.currentItemNo]];      
        this.generateGrouppedItemIdMap(this.grouppedItems, this.itemGroupCodes[this.currentItemNo]);  
        this.currentItemNo++;
        this.grouppedItems && this.populateItem(this.grouppedItems[0]);
        !this.allItems[this.itemGroupCodes[this.currentItemNo]] && (this.isLastItem = true);
    }
    
    async onSubmit()
    {
        try 
        {
            this.showSpinner = true;
            
            const result = await submitToGetsAsiaIPT({inwardDeclarationId: this.recordId, grouppedItems: this.grouppedItemIds});

            if (result)
            {
                this.showNotification('SUCCESS', 'The submission for Duty Request is successful!', 'success', 'sticky');
            }
            else
            {
                this.showNotification('ERROR', 'The submission for Duty Request has failed! Please contact your Administrator.', 'error', 'sticky');
            }
        } 
        catch (error) 
        {
            this.showNotification('ERROR!', 'The submission for Duty Request has failed! Reason: ' + error.body.message + '. Please contact your Administrator.', 'error', 'sticky');
        }
        finally
        {
            this.showSpinner = false;
            this.onCancel();
        }
    }

    onCancel()
    {
        this.dispatchEvent(new CloseActionScreenEvent());
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