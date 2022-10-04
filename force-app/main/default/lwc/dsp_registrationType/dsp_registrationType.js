/* eslint-disable no-unused-expressions */
import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import STOCK_RESERVATION_OBJECT from '@salesforce/schema/Stock_Reservation__c';
import REGISTRATION_TYPE_FIELD from '@salesforce/schema/Stock_Reservation__c.Registration_Type__c';
import { STOCK_RESERVATION_FIELDS as FIELDS, REGISTRATION_TYPE_REQUIRED_FIELDS as requiredFieldCheck} from 'c/dsp_configurationCmp';
import getPackage from '@salesforce/apex/DigitalSalesAgreementApplication.getPackage';
import { refreshApex } from '@salesforce/apex';
import updateStockReservation from '@salesforce/apex/DigitalSalesAgreementApplication.updateStockReservation';
import CNC_LOGO from '@salesforce/resourceUrl/CnCLogoHorizontal';

export default class Dsp_registrationType extends LightningElement {
    @api recordId;
    @api isModal = false;
    @api containerStyle = "padding-top: 15px;";

    @track stockReservationRec;
    @track error;
    @track isError = false;
    @track errorMsg;
    @track changeList = {'Registration_Type__c' : 'P', 'Package_Header_From_PickList__c':''};
    @track packageOptions = [];
    @track registrationTypeOptions = [];
    
    modelCodeId;
    packageList;
    registrationTypePicklistValue;

    cncLogoUrl = CNC_LOGO;

    @track ulClass = 'd-none select-list picklistUL';

    @wire(getRecord, { recordId : '$recordId', fields: FIELDS })
    stockReservationObject(result) {
        this.wireStockReservationRec = result; //This is needed if you want to deliberately refresh it
        this.error = result.error ? result.error : undefined;
        this.isError = this.error ? true : false;
        this.stockReservationRec = result.data ? result.data.fields : undefined;
        this.modelCodeId = this.stockReservationRec && this.stockReservationRec.Model_Code__r.value.fields.Id.value;
        this.getPkg(this.modelCodeId);   
        this.stockReservationRec && requiredFieldCheck.processRequiredFieldsFirstTimeLoad(this.stockReservationRec);    
    }   

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REGISTRATION_TYPE_FIELD
    }) registrationTypePicklist({data, error}){
        this.registrationTypePicklistValue = data ? data.values : undefined;     
        this.error = error ? undefined : error;
        this.isError = this.error ? true : false;
        if (this.registrationTypePicklistValue) {
            for (let i = 0; i <this.registrationTypePicklistValue.length; i++) {
                this.registrationTypeOptions = [...this.registrationTypeOptions, {label : this.registrationTypePicklistValue[i].label, value : this.registrationTypePicklistValue[i].value}];
            }
        }
    }

    getPkg(modelId) {
        getPackage({
            modelCodeId : modelId
        }).then(data => {   
            this.packageList = data;
            this.packageOptionsHandle();
        }).catch(error => {
            this.error = error;
            this.isError = this.error ? true : false;
        })
    }
    

    packageOptionsHandle() {      
        if (this.packageList) {
            for (let i = 0; i <this.packageList.length; i++) {
                this.packageOptions = [...this.packageOptions, {label : this.packageList[i].PKH_PKGDESC__c, value : this.packageList[i].Id}];
            }
        }
    }

    @wire(getObjectInfo, { objectApiName: STOCK_RESERVATION_OBJECT})
    objectInfo;
 
    onValueChanged(event){
        const dataChanged = event.detail;
        this.setRequiredFieldFilled( Object.keys(event.detail)[0]);

        for (let [key, value] of Object.entries(dataChanged)) { 
            this.changeList[key] = value;
        }

        if(this.changeList.Package_Header_From_PickList__c){
            this.template.querySelectorAll('button').forEach(elem=>{
                elem.removeAttribute('disabled');
            })
        }

        this.valueChangedDetected();
        //console.log('TEST BUG: ' + JSON.stringify(this.changeList));
    }

    valueChangedDetected() {
        const selectEvent = new CustomEvent('changepage0', {
            detail: this.changeList
        });
        this.dispatchEvent(selectEvent);
    }

    onSaveRecordNext(){
        this.isError = requiredFieldCheck.validationCheck(this);
        this.isError === false && this.saveRecord();
    }

    saveRecord(){

        this.changeList.Id = this.recordId;

        updateStockReservation({
            stockRes : this.changeList
        }).then(()=>{
             
            this.changeList.Last_save_on_form = 'RegistrationType';
            //console.log('TEST 2: ' + JSON.stringify(this.changeList));
            const saveEvent = new CustomEvent('activitychanged', {
                detail: {stage: this.changeList.Last_save_on_form,
                         Id: this.changeList.Id}
            });
            this.dispatchEvent(saveEvent);        
            refreshApex(this.wireStockReservationRec);
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