import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import COE_OBJECT from '@salesforce/schema/COE__c';
import FRANCHISE_FIELD from '@salesforce/schema/COE__c.Franchise__c';
import strUserId from '@salesforce/user/Id';
import readCSV from '@salesforce/apex/COEBiddingUploadCtrl.readCSVFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoeBiddingUploadContainer extends LightningElement {
    @api recordId;

    @track disabledUploadInput = true;
    @track spinner = false;
    @track franchiseOptions;

    userId = strUserId; 
    // franchises = [
    //                 // { label: "--------------- None ---------------", value: null},
    //                 { label: "KIAPC",  value: "KIAPC" },
    //                 { label: "MITPC",  value: "MITPC" },
    //                 { label: "CITPC",  value: "CITPC" },
    //                 { label: "MBP",  value: "MBP" },
    //              ]
    selectedFranchise;

    get acceptedFormats() {
        return ['.csv'];
    }

    @wire(getObjectInfo, { objectApiName: COE_OBJECT })
    objectInfo;

    // Get picklist values for Franchise
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FRANCHISE_FIELD
    }) getFranchisePicklist({ data, error }) {
        if (data) {
            this.franchiseOptions = data.values;
        } else if (error) {
            this.franchiseOptions = undefined;
        }
    }

    connectedCallback() {
        console.log('COE Bid Period Id::  ' + this.recordId);
        console.log('User Id:: ' + this.userId);
    }

    handleUploadFinished(event) {
        this.spinner = true;
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        readCSV({
            contentDocumentId : uploadedFiles[0].documentId,
            coeBidPeriodId : this.recordId,
            franchise : this.selectedFranchise
        })
        .then(result => {
            this.spinner = false;
            console.log('result ===> '+ JSON.stringify(result));
            // this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Uploaded file successfully. Please refresh the page!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.spinner = false;
            console.log(error);
            // this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                }),
            )
        })
    }

    handleInputChanged(event) {
        let inputNm = event.target.name;
        let val = event.detail.value;
        if (inputNm == 'franchise') {
            this.selectedFranchise = val;
            if (this.selectedFranchise != null) {
                this.disabledUploadInput = false;
            }
            console.log('selected franchise:: ' + this.selectedFranchise);
        }
    }
}