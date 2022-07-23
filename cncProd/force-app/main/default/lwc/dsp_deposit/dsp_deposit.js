/* eslint-disable no-unused-expressions */
import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';
import { DEPOSIT_FIELDS as FIELDS, DEPOSIT_REQUIRED_FIELDS as requiredFieldCheck } from 'c/dsp_configurationCmp';
import { refreshApex } from '@salesforce/apex';

export default class Dsp_deposit extends LightningElement {
    @api recordId;
    @api isModal = false;
    @api containerStyle = "padding-top: 55px;";

    @track salesRec;
    @track error;
    @track isError = false;
    @track errorMsg;
    @track changeList = {};

    @wire(getRecord, { recordId : '$recordId', fields: FIELDS })
    salesAgreementObject(result) {
        this.wireSalesRec = result; //This is needed if you want to deliberately refresh it
        this.error = result.error ? result.error : undefined;
        this.isError = this.error ? true : false;
        this.salesRec = result.data ? result.data.fields : undefined
        this.salesRec && requiredFieldCheck.processRequiredFieldsFirstTimeLoad(this.salesRec);
    }


    valueChangedDetected(event) {
        const dataChanged = event.detail;
        this.setRequiredFieldFilled( Object.keys(event.detail)[0]);

        this.changeList.Id = this.recordId;

        for (let [key, value] of Object.entries(dataChanged)) {
            this.changeList[key] = value;
        }

        this.dispatchEvent(new CustomEvent('change', {
            detail: this.changeList
        }));
    }
/*
    onValueChanged(event){
        const checkValue = {};
        checkValue.detail[event.target.name] = event.target.value;
        this.valueChangedDetected(checkValue);
    }
*/

    onProcessStepChange(){
        const evtData = {};
        evtData.stage = this.changeList.Last_save_on_form__c;

        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail: evtData
        }));
    }

    onSaveRecordNext(){
        this.isError = requiredFieldCheck.validationCheck(this);
        this.isError === false && this.saveRecord();
    }

    saveRecord(){

        this.changeList.Last_save_on_form__c = 'Review';
        this.changeList.Id = this.recordId;

        updateSalesAgreement({
            salesAgreement : this.changeList
        }).then(()=>{
            refreshApex(this.wireSalesRec);
            this.onProcessStepChange();
        }).catch(error=>{
            this.isError = true;
            this.errorMsg = error.body.message;
            this.error = error;
        })
    }

    setRequiredFieldFilled(fieldApiName){
        requiredFieldCheck.setIsFilled(fieldApiName);
    }

}