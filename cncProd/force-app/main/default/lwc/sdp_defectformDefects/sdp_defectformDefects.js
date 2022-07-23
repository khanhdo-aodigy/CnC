import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import DEFECT_OBJECT from '@salesforce/schema/Defect__c';
import TYPE_FIELD from '@salesforce/schema/Defect__c.Type_of_Defect__c';
import SA_FIELD from '@salesforce/schema/Defect__c.Sales_Agreement__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Defect__c.Description_of_Defect__c';
import ID_FIELD from '@salesforce/schema/Defect__c.Id';
import { createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import getRecords from '@salesforce/apex/SDP_DefectFormController.getRelatedRecords';
import createDefect from '@salesforce/apex/SDP_DefectFormController.createDefect';
import { refreshApex } from '@salesforce/apex';

export default class Sdp_defectformDefects extends LightningElement {
    @api editMode = false;
    @api salesAgreementId;
    @api deviceType;

    @track changeList = {};
    @track recordDetected = false;
    @track modalActivated = false;
    @track newlyCreatedRecord = false;
    @track recordStorage = [];
    @track DefectPicklistValue;
    @track CurrentRecordId;
    @track CurrentName = 0;
    @track CurrentDescription = '';
    @track CurrentSelectedPicklist = '';
    @track triggerSearchWire = 0;
    @track spinner;
    @track initialRender = true;
    @track wiredRecords;
    @track screenheight = 'height:550px';
    @track containerstyle = 'position:relative;padding-left:3%;padding-right:3%;';

    @wire(getObjectInfo, { objectApiName: DEFECT_OBJECT })
    objectInfo;

    renderedCallback() {
        if (this.initialRender) {
            if (this.editMode === true) {
                this.checkDeviceType();
            }
            window.addEventListener('orientationchange', this.checkDeviceType.bind(this));
            this.initialRender = false;
        }
        if (this.modalActivated) {
            this.template.querySelector('[data-id="DefectsModal"]').classList.add('modal-backdrop');
        }
    }

    /*
    scrollHandler() {
        if (this.modalActivated) {
            console.log('disable scroll at: ' + this.pageYAxis);
            window.scrollTo(0, this.pageYAxis);
        }
    }
    */

    checkDeviceType() {
        //console.log('Checking device type: ' + this.deviceType);
        console.log('Screen width: ' + window.screen.width);
        console.log('Screen Height: ' + window.screen.height);
        //console.log('Calculation Height: ' + document.body.offsetHeight);
        if (window.screen.width > window.screen.height) {
            this.screenheight = 'height:' + (window.screen.height * 0.48).toString() + 'px';
        } else {
            this.screenheight = 'height:' + (window.screen.height * 0.6).toString() + 'px';
        }

        this.containerstyle = this.containerstyle + 'height:' + (window.screen.height).toString() + 'px';
    }

    //Get all defect records related to the sales agreement
    @wire(getRecords, {
        fieldReferenceValue: '$salesAgreementId',
        objectName: 'Defect__c',
        fieldName: 'Sales_Agreement__c',
        triggerSearch: '$triggerSearchWire'
    })
    wiredProps(result) {
        this.wiredRecords = result;
        result.error && console.log(result.error);
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

    //Get picklist values for defect object
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TYPE_FIELD
    }) defectMakePickList({ data, error }) {
        if (data) {
            this.CurrentSelectedPicklist = '';
            //this.CurrentSelectedPicklist = data.values[0].value
            this.DefectPicklistValue = data.values;
        } else if (error) {
            this.DefectPicklistValue = undefined;
        }
    }

    onValueChangedDetected(event) {
        Object.assign(this.changeList, event.detail);
    }

    onProcessStepChange() {
        const selectEvent = new CustomEvent('changestage', {
            detail: { stage: 'SelectServiceCenter' }
        });
        this.dispatchEvent(selectEvent);
        console.log('CURRENT DEFECTS:: ' + JSON.stringify(this.recordStorage));
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

    //Record details onclick
    SelectedRecordDetails(event) {
        this.CurrentRecordId = event.target.getAttribute("data-id");
        this.newlyCreatedRecord = false;

        //Assign the corresponding default value
        let SelectedRecord = this.recordStorage.find(EachRecord => EachRecord.Id === this.CurrentRecordId);
        this.CurrentDescription = SelectedRecord.Description_of_Defect__c;
        console.log('mac is testing here');
        this.CurrentSelectedPicklist = SelectedRecord.Type_of_Defect__c;
        console.log(this.CurrentSelectedPicklist);
        this.CurrentName = SelectedRecord.sNo;
        this.OpenPopUp();
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
        this.spinner = true;
        let fields = {};
        fields[TYPE_FIELD.fieldApiName] = this.changeList.Type_of_Defect__c;
        fields[DESCRIPTION_FIELD.fieldApiName] = this.changeList.Description_of_Defect__c;
        fields[ID_FIELD.fieldApiName] = this.CurrentRecordId;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                console.log('Update Successful!');
                this.newlyCreatedRecord = true;
                this.spinner = false;

                //Check changes on review page
                if (this.editMode === false) {
                    this.dispatchEvent(new CustomEvent('recordchange'));
                }

                refreshApex(this.wiredRecords);
            })
            .catch(error => {
                console.log('Error: ' + error.body.message);
            });
    }

    //Create record
    CreateRecord() {
        //Initialise default value to blank
        // this.CurrentDescription = '';
        // this.CurrentSelectedPicklist = '';
        // this.newlyCreatedRecord = true;
        // this.spinner = true;

        // //Create record
        // const fields = {};
        // fields[SA_FIELD.fieldApiName] = this.salesAgreementId;
        // // fields[NAME_FIELD.fieldApiName] = 'Defect ' + (this.recordStorage.length + 1).toString();

        // const recordInput = { apiName: DEFECT_OBJECT.objectApiName, fields };
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
        createDefect({
            salesAgreementID : this.salesAgreementId,
        })
        .then(result => {
            console.log(result);
            this.CurrentRecordId = result.Id;
            console.log('success: ' + this.CurrentRecordId);
            this.spinner = false;
        })
        .catch(error => {
            console.log('error on creating defect record :: ', error);
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
        this.UpdateRecord();
        this.ClosePopUp();
    }

    SaveAndContinue() {
        this.UpdateRecord();
        this.ClosePopUp();
        this.AddDefect();
    }

    AddDefect() {
        this.CurrentName = this.CurrentName + 1;
        this.CreateRecord();
        this.OpenPopUp();
    }
}