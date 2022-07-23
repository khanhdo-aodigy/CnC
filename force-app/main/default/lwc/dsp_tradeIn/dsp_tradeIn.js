import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import SALES_AGREEMENT_OBJECT from '@salesforce/schema/Sales_Agreement__c';
import USED_CAR_MAKE_FIELD from '@salesforce/schema/Sales_Agreement__c.Used_Car_Make__c';
import FINANCE_COMPANY_FIELD from '@salesforce/schema/Sales_Agreement__c.Used_Car_Vehicle_Finance_Company__c';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';
import { TRADEIN_FIELDS as FIELDS } from 'c/dsp_configurationCmp';
import { refreshApex } from '@salesforce/apex';


export default class Dsp_tradeIn extends LightningElement {
    @api recordId;
    @api isModal = false;
    @api containerStyle = "padding-top: 55px;";

    @track salesRec;
    @track changeList = {};
    @track carMakePickListValue;
    @track financeCompanyPickListValue;
    @track isSellerNotBuyer = false;
    @track isUsedCarCompanyOwned = false;
    @track error;
    @track errorMsg;
    @track isError;

    @track sellerType;

    @wire(getRecord, { recordId : '$recordId', fields: FIELDS })
    salesAgreementObject(result) {
        this.wireSalesRec = result; //This is needed if you want to deliberately refresh it
        this.salesRec = result.data ? result.data.fields : undefined;
        this.salesRec && (this.isSellerNotBuyer = this.salesRec.isSellerNotBuyer__c.value ? this.salesRec.isSellerNotBuyer__c.value: false,
                          this.isUsedCarCompanyOwned = this.salesRec.isUsedCarUnderCompany__c.value ? this.salesRec.isUsedCarUnderCompany__c.value  : false,
                          this.sellerType = this.salesRec.Seller_Type__c.value);
        this.error = result.error ? result.error : undefined;
    }


    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: USED_CAR_MAKE_FIELD
    }) carMakePickList({data, error}){
        this.carMakePickListValue = data ? data : undefined;
        this.error = error ? undefined : error;
    }
   

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FINANCE_COMPANY_FIELD
    }) financeCompanyPickList({data, error}){
        this.financeCompanyPickListValue = data ? data : undefined;
        this.error = error ? undefined : error;
    }


    @wire(getObjectInfo, { objectApiName: SALES_AGREEMENT_OBJECT })
        objectInfo;

    renderedCallback() {
        // Added by Phap on 17 April 2020
        // disable GMS validity date input field if GMS packge equal zero || null || undefined
        // try {
        //     if (this.salesRec != undefined) {
        //         let validityDateElem = this.template.querySelector(`[data-id="gms-validity-date"]`);
        //         if (this.salesRec.Trade_in_Value__c.value == undefined || this.salesRec.Trade_in_Value__c.value == null || this.salesRec.Trade_in_Value__c.value == 0) {
        //             validityDateElem.disableInput();
        //         }
        //     }
        // } catch (e) {console.log('[ERROR] Disable/Enable GMS validity date: ' + JSON.stringify(e))}
    }

    onValueChanged(event){
        this.isSellerNotBuyer = typeof event.detail.isSellerNotBuyer__c !== 'undefined' ? event.detail.isSellerNotBuyer__c : this.isSellerNotBuyer;
        this.isUsedCarCompanyOwned = typeof event.detail.isUsedCarUnderCompany__c !== 'undefined' ? event.detail.isUsedCarUnderCompany__c : this.isUsedCarCompanyOwned;
        // ADDED by VU - 24/02/2021
        // If the used car is not registered under COMPANY
        // Then set Seller Type's value to NORM
        this.sellerType = typeof event.detail.Seller_Type__c !== 'undefined' ? event.detail.Seller_Type__c : this.sellerType;
        if (Object.keys(event.detail)[0] === 'isUsedCarUnderCompany__c' && !event.detail.isUsedCarUnderCompany__c) {
            this.sellerType = 'NORM';
            this.changeList.Seller_Type__c = 'NORM';
        }
        Object.assign(this.changeList, event.detail);
        // Added by Phap on 17 April 2020
        // Reset the validity date to blank if GMS package is zero || null || undefined
        // try {
        //     if (Object.keys(event.detail)[0] === 'Trade_in_Value__c') {
        //         let validityDateElem = this.template.querySelector(`[data-id="gms-validity-date"]`);
        //         if (this.changeList.Trade_in_Value__c == 0 || this.changeList.Trade_in_Value__c == null || this.changeList.Trade_in_Value__c == undefined) {
        //             validityDateElem.disableInput();
        //             this.changeList.Validity_Date__c = null;
        //         } else validityDateElem.enableInput();
        //     }
        // } catch (e) {console.log('[ERROR] Disable/Enable GMS validity date on value change: ' + JSON.stringify(e));}
        // console.log(this.changeList.Validity_Date__c);
        // End of adding
        this.valueChangedDetected();
    }

    valueChangedDetected() {
        const selectEvent = new CustomEvent('change', {
            detail: this.changeList
        });
        this.dispatchEvent(selectEvent);
    }

    onConditionalCheckBoxForRegVehNo(event){
        //event.currentTarget.dataset.nameForField 
        //event.currentTarget.checked
        console.log(event);
        this.template.querySelectorAll('c-input-field-as-cmp').forEach(elem=>{
            event.currentTarget.dataset.nameForField === elem.fieldAPIName && 
                elem.changeDefaultValue(event.currentTarget.checked);
        });
    }

    onProcessStepChange(){
        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail:  { stage : this.changeList.Last_save_on_form__c}
        }));
    }

    onSaveRecordNext(){
        this.changeList.Last_save_on_form__c = 'Deposit'; 
        this.changeList.Id = this.recordId;

        updateSalesAgreement({
            salesAgreement : this.changeList
        }).then(result=>{
            refreshApex(this.wireSalesRec);
            this.onProcessStepChange();
        }).catch(error=>{
            this.isError = true;
            this.errorMsg = error.body.message;
            this.error = error;
        })
    }

    onNextWithoutSave(){
        const changeListWithoutContent = {};
        this.changeList.Last_save_on_form__c = changeListWithoutContent.Last_save_on_form__c = 'Deposit'; 
        changeListWithoutContent.Id = this.recordId;
        
        updateSalesAgreement({
            salesAgreement : changeListWithoutContent
        }).then(result=>{
            this.onProcessStepChange();
        }).catch(error=>{
            this.isError = true;
            this.errorMsg = error.body.message;
            this.error = error;
            
        })
    }
}