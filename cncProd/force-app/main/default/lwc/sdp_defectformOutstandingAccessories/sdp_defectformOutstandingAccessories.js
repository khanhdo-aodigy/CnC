import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/SDP_DefectFormController.getRelatedRecords';
import OA_OBJECT from '@salesforce/schema/Outstanding_Accessory__c';
import SA_FIELD from '@salesforce/schema/Outstanding_Accessory__c.Sales_Agreement__c';
import ACCESSORY_FIELD from '@salesforce/schema/Outstanding_Accessory__c.SAAccessory__c';
import ID_FIELD from '@salesforce/schema/Outstanding_Accessory__c.Id';
import { createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import createOA from '@salesforce/apex/SDP_DefectFormController.createOA';

export default class Sdp_defectformOutstandingAccessories extends LightningElement {
    @api editMode = false;
    @api salesAgreementId;
    @api deviceType;

    @track accessoriesPicklistValue = [];
    @track recordStorage = [];
    @track changeList = {};
    @track recordDetected = false;
    @track modalActivated = false;
    @track newlyCreatedRecord = false;
    @track CurrentRecordId;
    @track CurrentName = 0;
    @track CurrentSelectedAccessory = '';
    @track triggerSearchWire = 0;
    @track spinner;
    @track initialRender = true;
    @track wiredRecords;
    @track screenheight = 'height:550px';
    @track containerstyle = 'position:relative;padding-left:3%;padding-right:3%;';
    @track emptyValue = true;
    @track isError = false;
    @track errorMsg = '';

    renderedCallback() {
        if (this.initialRender) {
            this.initialiseAccesoriesPicklist();
            if (this.editMode === true) {
                this.checkDeviceType();
            }
            window.addEventListener('orientationchange', this.checkDeviceType.bind(this));
            this.initialRender = false;
        }

        if (this.modalActivated) {
            this.template.querySelector('[data-id="OutstandingAccessoriesModal"]').classList.add('modal-backdrop');
        }
    }

    checkDeviceType() {
        if (window.screen.width > window.screen.height) {
            this.screenheight = 'height:' + (window.screen.height * 0.48).toString() + 'px';
        } else {
            this.screenheight = 'height:' + (window.screen.height * 0.6).toString() + 'px';
        }

        this.containerstyle = this.containerstyle + 'height:' + (window.screen.height).toString() + 'px';
    }

    @api
    refreshComponentRecords() {
        refreshApex(this.wiredRecords);
    }

    //Get all defect records related to the sales agreement
    @wire(getRecords, {
        fieldReferenceValue: '$salesAgreementId',
        objectName: 'Outstanding_Accessory__c',
        fieldName: 'Sales_Agreement__c',
        triggerSearch: '$triggerSearchWire'
    })
    wiredProps(result) {
        this.wiredRecords = result;
        result.error && console.log('Error! ' + result.error);
        if (result.data) {
            if (result.data.length !== 0) {
                this.recordDetected = true;
                this.CurrentName = result.data.length;
            } else {
                this.recordDetected = false;
                this.CurrentName = 0;
            }
            this.recordStorage = result.data;
            this.recordStorage = this.recordStorage.map((record, index) => ({ ...record, sNo: index + 1 }));
        }
    }

    onValueChangedDetected(event) {
        Object.assign(this.changeList, event.detail);
        this.emptyValue = false;
    }

    onProcessStepChange() {
        const selectEvent = new CustomEvent('changestage', {
            detail: { stage: 'SelectServiceCenter' }
        });
        this.dispatchEvent(selectEvent);
        console.log('CURRENT OUTSTANDING ACCS:: ' + JSON.stringify(this.recordStorage));
    }

    OpenPopUp() {
        this.modalActivated = true;
        this.dispatchEvent(new CustomEvent('scrollstatus', {
            detail: { status: 'Disable' }
        }));
    }

    ClosePopUp() {
        this.modalActivated = false;
        this.changeList = {};
        this.dispatchEvent(new CustomEvent('scrollstatus', {
            detail: { status: 'Enable' }
        }));
    }

    initialiseAccesoriesPicklist() {
        getRecords({
            fieldReferenceValue: this.salesAgreementId,
            objectName: 'SA_Accessory__c',
            fieldName: 'Sales_Agreement__c'
        })
            .then(result => {
                this.processPicklisttoDisplay(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    processPicklisttoDisplay(Records) {
        let temporarystorage = [];
        for (let x = 0; x < Records.length; x++) {
            //console.log('Blank ++ ' + Records[x].Description__c);
            if (Records[x].Description__c != null) {
                temporarystorage.push({
                    label: Records[x].Description__c,
                    value: Records[x].Id

                });
            }
        }

        this.accessoriesPicklistValue = temporarystorage;
        //this.CurrentSelectedAccessory = this.accessoriesPicklistValue[0].value;
    }

    //Record details onclick
    SelectedRecordDetails(event) {
        this.CurrentRecordId = event.target.getAttribute("data-id");
        this.newlyCreatedRecord = false;
        this.emptyValue = false;

        //Assign the corresponding default value
        let SelectedRecord = this.recordStorage.find(EachRecord => EachRecord.Id === this.CurrentRecordId);
        this.CurrentSelectedAccessory = SelectedRecord.SAAccessory__c;
        this.CurrentName = SelectedRecord.sNo;
        this.OpenPopUp();
    }

    //Record delete onclick
    SelectedRecordDelete(event) {
        this.DeleteRecord(event.target.getAttribute("data-id"));
    }

    //Cancel any update
    DeleteRecord(recordId) {
        console.log('Deleting Record: ' + recordId);
        this.spinner = true;
        deleteRecord(recordId)
            .then(() => {
                console.log('Record Deleted');
                this.newlyCreatedRecord = true;
                this.spinner = false;
                refreshApex(this.wiredRecords);
            })
            .catch(error => {
                console.log('Error: ' + error.body.message);
            });
    }

    //Update record
    UpdateRecord() {
        this.isError = false;
        this.spinner = true;
        let fields = {};
        fields[ACCESSORY_FIELD.fieldApiName] = this.changeList.SAAccessory__c;
        fields[ID_FIELD.fieldApiName] = this.CurrentRecordId;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                console.log('Update Successful!');
                this.newlyCreatedRecord = true;
                this.spinner = false;
                refreshApex(this.wiredRecords);
            })
            .catch(error => {
                console.log('Error: Update Outstanding Accessories record: ' + error.body.message);
                this.errorMsg = 'Duplicate accessories detected';
                this.isError = true;
                this.spinner = false;
                this.OpenPopUp();
                console.log('Error2: ' + this.isError);
            });
    }

    //Get record
    CreateRecord() {
        //Initialise default value to blank
        // this.CurrentSelectedAccessory = '';
        // //this.CurrentSelectedAccessory = this.accessoriesPicklistValue[0].value;
        // this.newlyCreatedRecord = true;
        // this.emptyValue = true;
        // this.spinner = true;

        // //Create record
        // const fields = {};
        // fields[SA_FIELD.fieldApiName] = this.salesAgreementId;

        // const recordInput = { apiName: OA_OBJECT.objectApiName, fields };
        // createRecord(recordInput)
        //     .then(result => {
        //         this.CurrentRecordId = result.id;
        //         console.log('success: ' + this.CurrentRecordId);
        //         this.spinner = false;
        //     })
        //     .catch(error => {
        //         console.log('Error: ' + error.body.message);
        //     });

        // replaced above block code to serve Defect Header CR [Phap]
        this.spinner = true;
        createOA({
            salesAgreementID : this.salesAgreementId,
        })
        .then(result => {
            console.log(result);
            this.CurrentRecordId = result.Id;
            console.log('success: ' + this.CurrentRecordId);
            this.spinner = false;
        })
        .catch(error => {
            console.log('error on creating outstanding accessories record :: ', error);
        });
        // end of replacing

    }

    CancelButton() {
        if (this.newlyCreatedRecord === true) {
            this.DeleteRecord(this.CurrentRecordId);
        }
        this.ClosePopUp();
    }

    SaveAndClose() {
        if (this.emptyValue === false) {
            this.UpdateRecord();
            this.ClosePopUp();
        } else {
            this.errorMsg = 'Please select an accessory before saving';
            this.isError = true;
        }
    }

    SaveAndContinue() {
        if (this.emptyValue === false) {
            this.UpdateRecord();
            this.ClosePopUp();
            this.AddOustandingAccessories();
        } else {
            this.errorMsg = 'Please select an accessory before saving';
            this.isError = true;
        }
    }

    AddOustandingAccessories() {
        this.isError = false;
        this.CurrentName = this.CurrentName + 1;
        this.CreateRecord();
        this.OpenPopUp();
    }
}