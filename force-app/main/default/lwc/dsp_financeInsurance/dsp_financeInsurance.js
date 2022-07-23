/* eslint-disable no-unused-expressions */
import { LightningElement,wire,track,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import SALES_AGREEMENT_OBJECT from '@salesforce/schema/Sales_Agreement__c';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';
import getBusinessAssociateMaster from '@salesforce/apex/DigitalSalesAgreementApplication.getBusinessAssociateMaster';
import { FIELDS_TO_BE_DISABLED, MONTHLY_INSTALLMENT_FIELDS, getMonthlyInstalment, FINANCE_FIELDS as FIELDS, FINANCE_REQUIRED_FIELDS as requiredFieldCheck, isEmptyValue } from 'c/dsp_financeInsuranceConfiguration';
//import { FIELDS_TO_BE_DISABLED, MONTHLY_INSTALLMENT_FIELDS, getMonthlyInstalment, FINANCE_FIELDS as FIELDS, FINANCE_REQUIRED_FIELDS as requiredFieldCheck } from 'c/dsp_configurationCmp';
import { refreshApex } from '@salesforce/apex';


export default class Dsp_financeInsurance extends LightningElement {
    @api recordId;
    @api isModal = false;
    @api containerStyle = "padding-top: 55px;";

    @track salesRec;
    @track changeList = {};
    @track error;
    @track isError;
    @track errorMsg;

    @track changeList = {};
    @track disableFinanceInfoSection = false;
    @track showInhouseFinance = false;
    @track showInhouseInsurance = false;

    @track finaceList = [];
    @track insuranceList = []

    @track selectedFinance = '';
    @track selectedInsurance = '';
    @track isSetPickListValues = false; 
    

    @track businessAssociateMasterGroup;

    @track monthlyInstallment = 0;
    initialRender = true;
    requiredProcess = false;
    renderedCallback(){
        this.disableFinanceInfoSection && this.processEnableDisableFields();
        this.checkMonthlyInstallmentFee();
        this.requiredProcess && this.processEnableDisableFields();
        //this.isSetPickListValues && this.processRecordListToPickList();
        
    }


    @wire(getBusinessAssociateMaster,{typelist:['INS','FIN']})
    businessAssociateMasterList(result){
        this.error = result.error ? result.error : undefined;
        result.data && (this.businessAssociateMasterGroup = result.data, this.processRecordListToPickList());
    }

    @wire(getObjectInfo, { objectApiName: SALES_AGREEMENT_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId : '$recordId', fields: FIELDS })
    salesAgreementObject(result) {
        this.wireSalesRec = result; //This is needed if you want to deliberately refresh it
        if(result.data){
            this.salesRec = result.data.fields;
            this.selectedFinance = this.salesRec.Finance_Company_In_House__c.value !== undefined ? this.salesRec.Finance_Company_Lookup__c.value : '';
            this.selectedInsurance = this.salesRec.Insurance_Company_In_House__c.value !== undefined ? this.salesRec.Insurance_Company_Lookup__c.value : '';

            this.disableFinanceInfoSection = this.salesRec.Payment__c.value === 'Car Loan' ? false : true;
            this.showInhouseFinance = this.salesRec.Finance_Company_In_House__c.value === true ? true : false;
            this.showInhouseInsurance = this.salesRec.Insurance_Company_In_House__c.value === true ? true : false;
            requiredFieldCheck.processRequiredFieldsFirstTimeLoad(this.salesRec);

            MONTHLY_INSTALLMENT_FIELDS.Amount_to_Finance__c = this.salesRec.Amount_to_Finance__c ? this.salesRec.Amount_to_Finance__c.value : 0;
            MONTHLY_INSTALLMENT_FIELDS.Rate_p_a__c = this.salesRec.Rate_p_a__c ? this.salesRec.Rate_p_a__c.value : 0;
            MONTHLY_INSTALLMENT_FIELDS.Terms_Years__c = this.salesRec.Terms_Years__c ? this.salesRec.Terms_Years__c.value : 0;
            this.requiredProcess = true;
            this.calculateMonthlyInstalment();
        }

        this.error = result.error ? result.error : undefined;
    }

    processRecordListToPickList(){

        const financelist = this.businessAssociateMasterGroup.filter(item => item.BAM_TYPE__c === 'FIN');
        const insuranceList = this.businessAssociateMasterGroup.filter(item => item.BAM_TYPE__c === 'INS');

        financelist.forEach(rowData=>{
            this.finaceList.push({key : rowData.Id, value : rowData.Id, label: rowData.Name,
                                 isInHouse : rowData.BAM_INHOUSE__c === 'Y' ? true : false, displayUI : true});
        })

        insuranceList.forEach(rowData=>{
            this.insuranceList.push({key : rowData.Id, value : rowData.Id, label: rowData.Name,
                                    isInHouse : rowData.BAM_INHOUSE__c === 'Y' ? true : false, displayUI : true});
        })
        this.isSetPickListValues = true;
    }

    onValueChanged(event){
        this.isError = false;
        this.setRequiredFieldFilled( Object.keys(event.detail)[0], Object.values(event.detail)[0]);

        this.processFinanceInsurancePickListSelection(event);
        typeof event.detail.Term_Period__c !== 'undefined' && (MONTHLY_INSTALLMENT_FIELDS.Terms_Years__c = event.detail.Term_Period__c, this.changeList.Terms_Years__c = event.detail.Term_Period__c);
        typeof event.detail.Payment__c !== 'undefined' && (this.disableFinanceInfoSection = event.detail.Payment__c === 'Car Loan' ? false : true, 
                                                           this.processEnableDisableFields());

        Object.assign(this.changeList, event.detail);
        this.processmonthlyInstFields(event.detail);
        this.valueChangedDetected();
    }


    processFinanceInsurancePickListSelection(event){
        let componentName;
        typeof event.detail.Finance_Company_In_House__c !== 'undefined' && (
            componentName = 'Finance_Company_Lookup__c',
            this.showInhouseFinance = event.detail.Finance_Company_In_House__c === true ? true : false,
            this.showInhouseFinance === false && (MONTHLY_INSTALLMENT_FIELDS.Terms_Years__c = 0,
                                                  this.changeList.Terms_Years__c = 0,
                                                  event.detail.Term_Period__c = 0),
            this.requiredProcess = true,
            this.selectedInsurance = this.changeList.Finance_Company_Lookup__c = '',
            this.setRequiredFieldFilled(componentName, this.selectedFinance),
            this.setChildComponentPickList(componentName, this.showInhouseFinance ? true : false)
            );

        typeof event.detail.Insurance_Company_In_House__c !== 'undefined' && (
            componentName = 'Insurance_Company_Lookup__c',
            this.showInhouseInsurance = event.detail.Insurance_Company_In_House__c === true ? true : false,
            this.selectedInsurance = this.changeList.Insurance_Company_Lookup__c = '',
            this.setRequiredFieldFilled(componentName, this.selectedInsurance),
            this.setChildComponentPickList(componentName, this.showInhouseInsurance ? true : false)); 
    }

    setChildComponentPickList(apiName, isInhouse){
        this.template.querySelectorAll('c-lookup-field-as-pick-list-cmp').forEach(elem=>{
            elem.apiFieldName === apiName && (elem.setPickListValueSet(isInhouse));
        })
    }
 
    valueChangedDetected() {
        const selectEvent = new CustomEvent('change', {
            detail: this.changeList
        });
        this.dispatchEvent(selectEvent);
    }

    onProcessStepChange(){
        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail:  { stage : this.changeList.Last_save_on_form__c}
        }));
    }

    setRequiredFieldFilled(fieldApiName, value){
        let isFilled = isEmptyValue(value) ? false : true;
        
        fieldApiName === 'Payment__c' && (value === 'Full Payment' && (requiredFieldCheck.setIsFilled('Finance_Company_Lookup__c',true)));

        requiredFieldCheck.setIsFilled(fieldApiName,isFilled);
    }

    

    onSaveRecordNext(){
        //this.requiredFieldValidation(this, this.changeList);
        this.isError = requiredFieldCheck.validationCheck(this);
        this.isError === false && this.saveRecord();
    }

    saveRecord(){
        this.changeList.Last_save_on_form__c = 'Trade-In';
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

    processmonthlyInstFields(field){ // {fieldAPIName : value}
        if(Object.keys(field)[0] === 'Amount_to_Finance__c' || Object.keys(field)[0] === 'Rate_p_a__c' || Object.keys(field)[0] === 'Term_Period__c'){
            Object.keys(field)[0] === 'Term_Period__c' ?  MONTHLY_INSTALLMENT_FIELDS.Terms_Years__c = Number(field.Term_Period__c) : MONTHLY_INSTALLMENT_FIELDS[Object.keys(field)[0]] = Number(field[Object.keys(field)[0]]);
            this.calculateMonthlyInstalment();
        }
    }

    calculateMonthlyInstalment(){
        this.monthlyInstallment = getMonthlyInstalment(MONTHLY_INSTALLMENT_FIELDS.Amount_to_Finance__c, MONTHLY_INSTALLMENT_FIELDS.Rate_p_a__c, MONTHLY_INSTALLMENT_FIELDS.Terms_Years__c);
    }

    processEnableDisableFields(){
        FIELDS_TO_BE_DISABLED.Finance.inputField.length >= 0 && this.processEnableDisableInputFields();
        FIELDS_TO_BE_DISABLED.Finance.pickListAsButton.length >= 0 && this.processEnableDisablePickListFields();
        FIELDS_TO_BE_DISABLED.Finance.pickListAsList.length >= 0 && this.processEnableDisableInputPickListFields();
        FIELDS_TO_BE_DISABLED.Finance.checkbox.length >= 0 && this.processEnableDisableCheckboxFields();
        //this.monthlyInstallment = 0;
    }
    processEnableDisableInputFields(){
        this.requiredProcess = false;
        this.template.querySelectorAll('c-input-field-as-cmp').forEach(element => {
            if(FIELDS_TO_BE_DISABLED.Finance.inputField.find(field=> field.apiName === element.fieldAPIName)){
                const currentField = FIELDS_TO_BE_DISABLED.Finance.inputField.find(field=> field.apiName === element.fieldAPIName);
                const checkDisplay = this.showInhouseFinance ? true : currentField.enableForNotInhouse;

                this.disableFinanceInfoSection ? (  element.disableInput(),
                                                    this.template.querySelector(`div[data-name="${element.fieldAPIName}"]`).classList.add('is-disabled'),
                                                    this.changeList[`${currentField.apiName}`] = '') 
                                                : ( checkDisplay ?  
                                                        (   element.enableInput(), 
                                                            this.template.querySelector(`div[data-name="${element.fieldAPIName}"]`).classList.remove('is-disabled'))
                                                    :   (   element.disableInput(),
                                                            this.template.querySelector(`div[data-name="${element.fieldAPIName}"]`).classList.add('is-disabled'),
                                                            this.changeList[`${currentField.apiName}`] = '') 
                                                );
                /*
                this.disableFinanceInfoSection ? element.disableInput() : element.enableInput();
                this.disableFinanceInfoSection ? this.template.querySelector(`div[data-name="${element.fieldAPIName}"]`).classList.add('is-disabled') :
                                                    this.template.querySelector(`div[data-name="${element.fieldAPIName}"]`).classList.remove('is-disabled') ;
                this.disableFinanceInfoSection && (this.changeList[`${currentField.apiName}`] = '');
                */

            }
        });
    }
    processEnableDisablePickListFields(){

        this.template.querySelectorAll('c-picklist-as-button-cmp').forEach(element => {
            if(FIELDS_TO_BE_DISABLED.Finance.pickListAsButton.find(field=> field.apiName === element.picklistFieldApiName)){
                const currentField = FIELDS_TO_BE_DISABLED.Finance.pickListAsButton.find(field=> field.apiName === element.picklistFieldApiName);
                const checkDisplay = this.showInhouseFinance ? true : currentField.enableForNotInhouse;
                this.disableFinanceInfoSection ? (  element.disableInput(),
                                                    (currentField.apiName === 'Term_Period__c' && (this.changeList.Terms_Years__c = 0)),
                                                    this.changeList[`${currentField.apiName}`] = '') 
                                                : ( checkDisplay ?  
                                                            element.enableInput() 
                                                    :   (   element.disableInput(),
                                                            (currentField.apiName === 'Term_Period__c' && (this.changeList.Terms_Years__c = 0)),
                                                            this.changeList[`${currentField.apiName}`] = '') 
                                                );
                /*
                this.disableFinanceInfoSection ? element.disableInput() : element.enableInput();
                this.disableFinanceInfoSection && (this.changeList[`${currentField.apiName}`] = '',
                                                  (currentField.apiName === 'Term_Period__c' && (this.changeList.Terms_Years__c = 0))
               );*/
            }
        });
    }
    processEnableDisableInputPickListFields(){
        
        //c-picklist-as-button-cmp
        //c-lookup-field-as-pick-list-cmp
        this.template.querySelectorAll('c-lookup-field-as-pick-list-cmp').forEach(element => {
            if(FIELDS_TO_BE_DISABLED.Finance.pickListAsList.find(field=> field.apiName === element.apiFieldName)){
                const currentField = FIELDS_TO_BE_DISABLED.Finance.pickListAsList.find(field=> field.apiName === element.apiFieldName);
                const checkDisplay = this.showInhouseFinance ? true : currentField.enableForNotInhouse;

                this.disableFinanceInfoSection ? (  element.disableInput(),
                                                    this.changeList[`${currentField.apiName}`] = '') 
                                                : ( checkDisplay ?  
                                                        (   element.enableInput() )
                                                    :   (   element.disableInput(),
                                                            this.changeList[`${currentField.apiName}`] = '') 
                                                );
                                                
                //this.disableFinanceInfoSection ? element.disableInput() : element.enableInput();
                //this.disableFinanceInfoSection && (this.changeList[`${currentField.apiName}`] = '');

            } 
        });
    }
    processEnableDisableCheckboxFields(){
        this.template.querySelectorAll('c-checkbox-as-cmp').forEach(element => {
            if(FIELDS_TO_BE_DISABLED.Finance.checkbox.find(field=> field.apiName === element.apiFieldName)){
                const currentField = FIELDS_TO_BE_DISABLED.Finance.checkbox.find(field=> field.apiName === element.apiFieldName);
                const checkDisplay = this.showInhouseFinance ? true : currentField.enableForNotInhouse;
                this.disableFinanceInfoSection ? (  element.disableInput(),
                                                    this.changeList[`${currentField.apiName}`] = '') 
                                                : ( checkDisplay ?  
                                                        (   element.enableInput() )
                                                    :   (   element.disableInput(),
                                                            this.changeList[`${currentField.apiName}`] = '') 
                                                );
                //this.disableFinanceInfoSection ? element.disableInput() : element.enableInput();
                //this.disableFinanceInfoSection && (this.changeList[`${currentField.apiName}`] = '');

            }
        });
    }

    checkMonthlyInstallmentFee(){
        if(this.disableFinanceInfoSection || this.showInhouseFinance === false || this.monthlyInstallment === '-NaN' || this.monthlyInstallment === '∞'){
            this.monthlyInstallment  = 0;
        }
    }
}