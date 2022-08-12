import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';

import getStockVehicleMasters from '@salesforce/apex/VPO_VPOLIController.getStockVehicleMasters';

import STAGE from '@salesforce/schema/Vehicle_Purchase_Order__c.Stage__c';

const columns = 
[
    { label: 'RVH Name', fieldName: 'Name', editable: false },
    { label: 'Vehicle Purchase Status', fieldName: 'Vehicle_Purchase_Status__c', editable: false },
    { label: 'Vehicle Status', fieldName: 'Vehicle_Status__c', editable: false },
    { label: 'Model Description', fieldName: 'Model_Description__c', editable: false },
    { label: 'Color Description', fieldName: 'Color_Description__c', editable: false },
    { label: 'Trim Description', fieldName: 'Trim_Description__c', editable: false },
    { label: 'Manufacturer Ref. No.', fieldName: 'Manufacturer_Ref_No__c', type: 'text', editable: true },
];

export default class Vpo_massEditSVM extends LightningElement 
{
    @api parentId;
    @api navigateToURL;
    @api showToastNotification;

    draftValues  = [];
    columns      = columns;
    rowOffset    = 0;
    isError      = false;
    errorMessage = '';
    stage        = '';

    @wire(getRecord, {recordId: '$parentId', fields: [STAGE]})
    wiredVPO({error, data})
    {
        if (data)
        {
            this.stage = data.fields.Stage__c.value;

            if (this.stage === 'Closed' || this.stage === 'Cancelled')
            {
                this.isError = true,
                this.showNotification('Sorry!', 'You cannot edit Stock Vehicle Master when Vehicle Purchase Order Stage is Closed or Cancelled! Please contact your Administrator.', 'warning');
                this.onClose();
            }
        }
    }

    @wire (getStockVehicleMasters, {parentId: '$parentId'}) stockVehicleMasters;

    async handleSave(event) 
    {
        // Convert datatable draft values into record objects
        const records = event.detail.draftValues.slice().map((draftValue) => {
            const fields = Object.assign({}, draftValue);
            return { fields };
        });

        // Clear all datatable draft values
        this.draftValues = [];

        try 
        {
            // Update all records in parallel thanks to the UI API
            const recordUpdatePromises = records.map((record) =>
                updateRecord(record)
            );
            await Promise.all(recordUpdatePromises);

            // Report success with a toast
            this.isError = false;
            this.showNotification('Success!', 'Stock Vehicle Masters have been successfully updated!', 'success');

            // Display fresh data in the datatable
            await refreshApex(this.stockVehicleMasters);
        } 
        catch (error) 
        {
            console.log(error.body.message);
            this.isError      = true;
            this.errorMessage = error.body.message;
            this.showNotification('Error!', 'An error has occurred! Please contact your Administrator.', 'error');
        }
    }

    async onClose()
    {
        await this.navigateToURL('/' + this.parentId);
    }

    async showNotification(title, message, variant)
    {
        await this.showToastNotification(title, message, variant);
    }
}