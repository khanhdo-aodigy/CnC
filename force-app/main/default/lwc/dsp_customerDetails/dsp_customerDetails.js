/* eslint-disable no-unused-expressions */
import { LightningElement, api, track, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';
import cancelSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.cancelSalesAgreement';
import { refreshApex } from '@salesforce/apex';
//import { CUSTOMER_FIELDS as FIELDS, CUSTOMER_REQUIRED_FIELDS as requiredFieldCheck } from 'c/dsp_configurationCmp';
import { CUSTOMER_FIELDS as FIELDS, CUSTOMER_REQUIRED_FIELDS as requiredFieldCheck, isEmptyValue as isEmptyValue} from 'c/dsp_customerConfiguration';

export default class dsp_customerDetails extends LightningElement {
    //@api salesAgreementObj;
    @api recordId;
    @api isModal = false;
    @api containerStyle = "padding-top: 55px;";
    @track changeList = {};
    @track disableButton = true;
    @track hasAdditionalAddress = false;
    @track error;
    @track salesRec;
    @track isCompany = false;
    initialRender = true;
    @track errorMsg;
    @track isError;
    @track isShowModal;
    @track isDraftStage;
    @track spinner;
    
    @wire(getRecord, { recordId : '$recordId', fields: FIELDS })
    salesAgreementObject(result) {
        this.wireSalesRec = result; //This is needed if you want to deliberately refresh it
        this.error = result.error ? result.error : undefined;
        this.salesRec = result.data ? result.data.fields : undefined;
        this.salesRec && this.processSalesRecData();
    }

    processSalesRecData(){
        this.salesRec.Postal_CodeMA__c.value ? this.onAddMailingAddress() : this.onRemoveMailingAddress();
        this.salesRec.Registration_Type__c.value && (this.isCompany = this.salesRec.Registration_Type__c.value === 'C' ? true : false);

        this.salesRec.Stage__c.value && (this.isDraftStage = this.salesRec.Stage__c.value === 'Draft' ? true : false);
        
        requiredFieldCheck.processRequireFieldsInitial(this.salesRec);

        /*
        this.requiredField.forEach(rowItem=>{
            rowItem.isFill = typeof this.salesRec[rowItem.apiName] !== 'undefined' ? true : false;
        })*/
        this.checkFieldsCompletion();
    }

    valueChangedDetected(event) {
        const dataChanged = event.detail;
        this.setRequiredFieldFilled( Object.keys(event.detail)[0], event.detail[Object.keys(event.detail)[0]]);
        event.detail.Salutation__c  && this.changePickListValue('Gender__c', event.detail.Salutation__c);
        

        for (let [key, value] of Object.entries(dataChanged)) { 
            this.changeList[key] = value;
        }

        this.checkFieldsCompletion();
        const selectEvent = new CustomEvent('change', {
            detail: this.changeList
        });
        this.dispatchEvent(selectEvent);

    }

 

    changePickListValue(pickListName, sourceSelection){
        const salautionSelection = { 'Mr' : 'M', 'Ms' : 'F', 'Mrs':'F'};
        const setValue = salautionSelection[sourceSelection];
        
        if(setValue === undefined) return;

        this.template.querySelectorAll('c-picklist-as-button-cmp').forEach(element => {
            element.picklistFieldApiName === pickListName && (element.changeValue(setValue),
            this.setRequiredFieldFilled(pickListName, setValue),
            this.changeList[pickListName] = setValue);
        });

    }


    onProcessStepChange(){
        const evtData = {};
        evtData.stage = this.changeList.Last_save_on_form__c;

        const selectEvent = new CustomEvent('activitychanged', {
            detail: {stage : this.changeList.Last_save_on_form__c}
        });
        this.dispatchEvent(selectEvent);
    }

    onSaveRecordNext(){
        this.isError = requiredFieldCheck.validationCheck(this);
        this.isError === false && this.saveRecord();
    }

    saveRecord(){
        this.changeList.Last_save_on_form__c = 'VehiclePurchase';
        this.changeList.Id = this.salesRec.Id.value;

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

    setRequiredFieldFilled(fieldApiName, value){
        const isFilled = isEmptyValue(value) ? false : true;
        requiredFieldCheck.setIsFilled(fieldApiName,isFilled);
    }

    checkFieldsCompletion(){
        this.disableButton =  requiredFieldCheck.isFormComplete(); //this.requiredField.every(rowItem => {return rowItem.isFill}) ? false : true;
    }

    onAddMailingAddress(){
        this.hasAdditionalAddress = true;
    }

    onRemoveMailingAddress(){
        this.hasAdditionalAddress = false;
    }

    openEmailModal()
    {
        this.isShowModal = true;
    }

    closeModal()
    {
        this.isShowModal = false;
    }

    cancelSA()
    {
        this.changeList.Id       = this.recordId;
        this.changeList.Stage__c = 'Cancelled';
        this.changeList.Stock_Reservation__c = this.salesRec.Stock_Reservation__c.value;
        this.spinner = true;
        cancelSalesAgreement({
            salesAgreement : this.changeList
        }).then(()=>{
            this.dispatchEvent(new CustomEvent('closewindow'));
            this.spinner = false;
        }).catch(error=>{
            this.isError = true;
            this.errorMsg = error.body.message;
            this.error = error;
            this.spinner = false;
        }) 
    }
/*
    setDefaultValues(){

        const dataChanged = {};
        for (let [key, value] of Object.entries(defaultValueFrom)) {
            dataChanged[key] = typeof this.salesAgreementObj[key] === 'undefined' ? this.salesAgreementObj[value] : this.salesAgreementObj[key];
            if(dataChanged[key] === '') delete dataChanged[key];
        }
        if(!dataChanged)return;
        this.valueChangedDetected({detail : dataChanged});
    }
*/

}