/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SA_OBJECT from '@salesforce/schema/Sales_Agreement__c';
import PROPOSEDCOMMISSION_FIELD from '@salesforce/schema/Sales_Agreement__c.Proposed_Commission__c';
import REASON_FIELD from '@salesforce/schema/Sales_Agreement__c.Proposed_Commission_Reason__c';
import ID_FIELD from '@salesforce/schema/Sales_Agreement__c.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import commissionCustomLabel from '@salesforce/label/c.Default_Commission_Description';

export default class Dsp_CommissionPopUp extends LightningElement {
    @api CurrentRecordId;
    @api coeCategory;
    @api defaultCommission;
    @track spinner = true;
    @track commissionStatus = false;
    @track initialRender = true;
    @track changeList = {};
    @track commissionDescription = '';
    @track defaultCommissionValue = 0;

    @wire(getObjectInfo, { objectApiName: SA_OBJECT })
    objectInfo;

    renderedCallback() {
        if (this.initialRender) {
            this.initialiseData();
            this.initialRender = false;
            this.spinner= false;
        }
    }

    onValueChanged(event) {
        Object.assign(this.changeList, event.detail);
    }

    initialiseData() {
        this.commissionDescription = commissionCustomLabel;
        this.defaultCommissionValue = Number(this.defaultCommission);
    }

    //Update record
    submitCommission() {
        this.spinner = true;
        let fields = {};
        fields[PROPOSEDCOMMISSION_FIELD.fieldApiName] = this.changeList.Proposed_Commission__c;
        fields[REASON_FIELD.fieldApiName] = this.changeList.Proposed_Commission_Reason__c;
        fields[ID_FIELD.fieldApiName] = this.CurrentRecordId;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.spinner = false;
                this.commissionStatus = true;

                //Proceed with event after 3 seconds
                setTimeout(() => {
                    this.dispatchEvent(new CustomEvent('submitcommission'));
                }, 2000);
            })
            .catch(error => {
                console.log('Error: ' + error.body.message);
            });
    }

    cancelSubmission(){
        this.dispatchEvent(new CustomEvent('cancelSubmission'));
    }
}