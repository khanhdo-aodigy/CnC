import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getVPOLI from '@salesforce/apex/VPO_VPOLIController.getVPOLI';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import STAGE from '@salesforce/schema/Vehicle_Purchase_Order__c.Stage__c';

export default class Vpo_editVPOLI extends LightningElement {
    cols = [
        { label: 'Vehicle Purchase Order Line Items Name', fieldName: 'Name', editable: false},
        { label: 'Model Master', fieldName: 'model_Master_Name_', editable: false },
        { label: 'Colour Description', fieldName: 'Colour_Description__c', editable: false},
        { label: 'Trim Master', fieldName: 'trim_Master_Description_', editable: false},
        { label: 'Units Ordered', fieldName: 'Units_Ordered__c', type: 'Number', editable: false},
        { label: 'Units Confirmed', fieldName: 'Units_Confirmed__c', editable: true},
        { label: 'Units Cancelled', fieldName: 'Units_Cancelled__c',type: 'Number', editable: true},
        { label: 'FOB Price', fieldName: 'Unit_Price__c', type: 'Number', editable: true},
    ];

    @api parentId;
    @track items;
    @api navigateToURL;
    @api showToastNotification;

    draftValues =[];
    rowOffset = 0;
    wireRecords;
    message      = '';
    isError      = false;
    stage        = '';
    errorMessage = '';

    
    @wire(getRecord, {recordId: '$parentId', fields: [STAGE]})
    wiredVPO({error, data})
    {
        if (data)
        {
            this.stage = data.fields.Stage__c.value;

            if (this.stage === 'Closed' || this.stage === 'Cancelled')
            {
                this.isError = true,
                this.showNotification('Sorry!', 'You cannot edit Vehicle Purchase Order Line Items when Vehicle Purchase Order Stage is Closed or Cancelled! Please contact your Administrator.', 'warning');
                this.onClose();
            }
        }
    }

    @wire(getVPOLI, { parentId: '$parentId' })
    wiredProps(result) {
        this.wireRecords = result;
        if (result.data) {
            if (result.data.length > 0)
            this.items = JSON.parse(JSON.stringify(result.data));
            this.items[0].Vehicle_Purchase_Order__r.Stage__c === 'Draft' && this.cols.forEach(el => {if (el.label === 'Units Ordered') el.editable = true, this.showData = true});
            this.items && this.items.forEach(element => {
                element.model_Master_Name_ = element.Model_Master__r.Name;
                element.trim_Master_Description_ = element.Trim_Master__r.Trim_Description__c;              
            } );
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
            this.isError = false;
            this.showNotification('Success!', 'Vehicle Purchase Order Line Items have been successfully updated!', 'success');

            // Display fresh data in the datatable
            await refreshApex(this.wireRecords);
        } 
        catch (error) 
        {
            console.log(error);
            error.body.output.errors.forEach(element =>
            {
                this.message += element.message + ' ';
            })
            console.log('Error: ', error.body.message);
            this.showNotification('Error!', this.message, 'error');

            // Display fresh data in the datatable
            await refreshApex(this.wireRecords);
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