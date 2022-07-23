import { LightningElement, api, track, wire } from 'lwc';
import getRecords from '@salesforce/apex/SDP_DefectFormController.getRelatedRecords';
import updateServiceCenter from '@salesforce/apex/SDP_DefectFormController.updateServiceCenter';
import ID_FIELD from '@salesforce/schema/Sales_Agreement__c.Id';
import SERVICECENTER_FIELD from '@salesforce/schema/Sales_Agreement__c.PreferredServiceCenter__c';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

export default class Sdp_defectformSelectServiceCenter extends LightningElement {
    @api recordId;
    @api editMode;
    @api franchise;         //this.franchise = record.FranchiseCode__c;
    @track CurrentSelectedPicklist;
    @track changeList = {};
    @track triggerSearchWire = 0;
    @track disablePicklist = false;
    @track wiredRecords;
    @track wiredSARecord;
    @track initialRender = true;
    @track spinner = false;
    @track loading = false;
    @track nextbutton = false;

    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = false;
        }
    }

    @api
    refreshComponentRecords() {
        this.spinner = true;
        refreshApex(this.wiredRecords);
    }

    //Get the most updated SalesAgreement Record
    @wire(getRecords, {
        fieldReferenceValue: '$recordId',
        objectName: 'Sales_Agreement__c',
        fieldName: 'Id',
        triggerSearch: '$triggerSearchWire'
    })
    wiredCurrentSARecord(result) {
        this.wiredSARecord = result;
        result.error && console.log('Error! ' + result.error);

        if (result.data) {
            this.ProcessCurrentSalesAgreement(result.data[0]);
        }
    }

    //Get all defect records related to the sales agreement
    @wire(getRecords, {
        fieldReferenceValue: '$recordId',
        objectName: 'Defect__c',
        fieldName: 'Sales_Agreement__c',
        triggerSearch: '$triggerSearchWire'
    })
    wiredProps(result) {
        this.wiredRecords = result;
        result.error && console.log('Error! ' + result.error);

        if (result.data) {
            this.ProcessExistingDefectRecords(result.data);
        }
    }

    ProcessCurrentSalesAgreement(record) {
        if (record.PreferredServiceCenter__c !== undefined) {
            this.CurrentSelectedPicklist = record.PreferredServiceCenter__c;
            this.template.querySelector('c-picklist-as-button-cmp').refreshComponent(this.CurrentSelectedPicklist);
        }
    }

    ProcessExistingDefectRecords(recordStorage) {
        this.disablePicklist = false;

        //Citroen do not have any service centre at Pandan Garden, so open all options
        if (this.franchise === 'CITPC' || this.franchise === 'CITCV') {
            this.disablePicklist = true;
            this.CurrentSelectedPicklist = 'Alexandra';
            Object.assign(this.changeList, { ['PreferredServiceCenter__c']: this.CurrentSelectedPicklist });
            this.UpdateRecord();
        } else {
            recordStorage.forEach(eachRecord => {
                if (eachRecord.Type_of_Defect__c === 'Paint and Body') {
                    this.disablePicklist = true;
                    this.CurrentSelectedPicklist = 'Pandan Gardens';
                    Object.assign(this.changeList, { ['PreferredServiceCenter__c']: this.CurrentSelectedPicklist });
                    this.UpdateRecord();
                }
            });
        }

        //triggerrefresh here if the disable = false, since there will not be any update to the SA and ProcessCurrentSalesAgreement will not be called
        if (this.disablePicklist === false && this.CurrentSelectedPicklist !== undefined) {
            this.spinner = false;
            this.template.querySelector('c-picklist-as-button-cmp').refreshComponent(this.CurrentSelectedPicklist);
        }
    }

    onValueChangedDetected(event) {
        if (this.disablePicklist === false) {
            Object.assign(this.changeList, event.detail);
        }

        this.UpdateRecord();
    }

    UpdateRecord() {
        // this.loading = true;
        // let fields = {};
        // fields[SERVICECENTER_FIELD.fieldApiName] = this.changeList.PreferredServiceCenter__c;
        // fields[ID_FIELD.fieldApiName] = this.recordId;

        // const recordInput = { fields };
        // updateRecord(recordInput)
        //     .then(() => {
        //         console.log('Update Successful!');
        //         refreshApex(this.wiredSARecord);
        //         this.loading = false;
        //         if (this.nextbutton === true) {
        //             this.NextPage();
        //         }
        //         this.spinner = false;
        //     })
        //     .catch(error => {
        //         console.log('Error: ' + error.body.message);
        //     });

        // replace aboved code to cater for Defect Header CR
        this.loading = true;
        let sCenter = this.changeList.PreferredServiceCenter__c;
        updateServiceCenter({
            salesAgreementID : this.recordId,
            sCenter : sCenter,
        }).then(result => {
            console.log('Service center update successful');
            refreshApex(this.wiredSARecord);
            this.loading = false;
            this.nextbutton === true && this.NextPage();
            this.spinner = false;
        }).catch(error => {
            console.log('Error on updating service center ::  ' + error.body.message);
        });
    }

    PreviousPage() {
        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail: { stage: 'AddDefectAndAccessories' }
        }));
    }

    NextPage() {
        if (this.loading === true) {
            this.spinner = true;
            this.nextbutton = true;
        } else {
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('activitychanged', {
                detail: { stage: 'ReviewForm' }
            }));
        }
    }

    CancelCommit() {
        window.close()
    }
}