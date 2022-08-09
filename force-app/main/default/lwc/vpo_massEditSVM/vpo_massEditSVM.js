import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import getStockVehicleMasters from '@salesforce/apex/VPO_VPOLIController.getStockVehicleMasters';

const columns = [
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

    draftValues      = [];
    columns          = columns;
    rowOffset        = 0;
    showSuccessToast = false;
    showErrorToast   = false;

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
            this.showSuccessToast = true;

            setTimeout(() => {
                this.showSuccessToast = false;
            }, 5000 );

            // Display fresh data in the datatable
            await refreshApex(this.stockVehicleMasters);
        } 
        catch (error) 
        {
            console.log(error);
            this.showErrorToast = true;

            setTimeout(() => {
                this.showErrorToast = false;
            }, 5000 );
        }
    }

    async onClose()
    {
        await this.navigateToURL('/' + this.parentId);
    }
}