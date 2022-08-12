import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getVPOLI from '@salesforce/apex/VPO_VPOLIController.getVPOLI';
import { updateRecord } from 'lightning/uiRecordApi';

export default class Vpo_editVPOLI extends LightningElement {
    cols = [
        { label: 'Vehicle Purchase Order Line Items Name', fieldName: 'Name', editable: false},
        { label: 'Model Master', fieldName: 'model_Master_Name_', editable: false },
        { label: 'Colour Description', fieldName: 'Colour_Description__c', editable: false},
        { label: 'Trim Master', fieldName: 'trim_Master_Name_', editable: false},
        { label: 'Units Ordered', fieldName: 'Units_Ordered__c', type: 'Number', editable: false},
        { label: 'Units Confirmed', fieldName: 'Units_Confirmed__c', editable: true},
        { label: 'Units Cancelled', fieldName: 'Units_Cancelled__c',type: 'Number', editable: true},
        { label: 'FOB Price', fieldName: 'Unit_Price__c', type: 'Number', editable: true},
    ];

    @api parentId;
    @track items;
    @api navigateToURL;
    draftValues =[];
    rowOffset = 0;
    wireRecords;
    message;
    showSuccessToast = false;
    showErrorToast   = false;


    @wire(getVPOLI, { parentId: '$parentId' })
    wiredProps(result) {
        this.wireRecords = result;
        if (result.data) {
            if (result.data.length > 0)
            this.items = JSON.parse(JSON.stringify(result.data));
            this.items && this.items.forEach(element => {
            element.model_Master_Name_ = element.Model_Master__r.Name;
            element.trim_Master_Name_ = element.Trim_Master__r.Name;
            });
        }
    }

    async saveHandleAction(event) 
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
            await refreshApex(this.wireRecords);
        } 
        catch (error) 
        {
            console.log(error);
            this.showErrorToast = true;
            error.body.output.errors.forEach(element =>
            {
                this.message += element.message + ' ';
                
            })
            setTimeout(() => {
                this.showErrorToast = false;
            }, 5000 );
        }
    }

    async onClose(){
        await this.navigateToURL('/' + this.parentId);
    }
}