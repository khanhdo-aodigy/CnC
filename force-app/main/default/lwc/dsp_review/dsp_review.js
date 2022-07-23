/* eslint-disable no-unused-expressions */
import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';
import getAddonSAAcessories from '@salesforce/apex/DigitalSalesAgreementApplication.getAddonSAAcessories';
import getSAAccessories from '@salesforce/apex/DigitalSalesAgreementApplication.getSAAcessories';

import getSAAdditionalCharges from '@salesforce/apex/DigitalSalesAgreementApplication.getSAAdditionalCharges';
import { MARKETING_CONTACTUS as contactUS, BRANCHCODE_NAME_MAPPING as entityName, REVIEW_FIELDS as FIELDS, REVIEW_REQUIRED_FIELDS as requiredFields, CREDIT_TC as CREDIT_TC } from 'c/dsp_configurationCmp';
import { GET_ROADTAX_LABEL as roadTaxLabel} from 'c/dsp_vehiclePurchaseConfiguration';

import sdpBootstrap from '@salesforce/resourceUrl/sdpBootstrap';
import { refreshApex } from '@salesforce/apex';


export default class Dsp_review extends LightningElement {
    @api recordId;
    @api isLocked = false;
    @track salesRec;
    @track error;
    @track isPrivateHire = false;
    @track isPromotionVehicle = false;
    @track addOnList;
    @track roadTaxList = [];
    @track additionalCharges = [];
    @track packageItemList;
    
    @track mustProcessAdditionalCharges=false;
    @track tempAdditionalCharges;
    @track acknowledgeList = {};
    @track isShowModal = false;
    @track editSection;
    @track isOffpeakCar = false;
    @track isCompany = false;
    @track isUsedCarAgrmnt = false;
    @track disabled = false;

    initialStyle = false;
    insurancePackageLabel = '';
    branchEntityName = '';
    marketingContactUs = '';
    recipientEmailForUCA;
    recipientEmail;

    // add by Phap on 09 Sep 2020
    creditTC = '';
    
    renderedCallback(){
        this.firstTimeDefaultRoadTaxOption === true && this.processRoadTax();
        this.mustProcessAdditionalCharges === true && this.processSAAdditionalCharges(this.tempAdditionalCharges);
        this.initialStyle === true && (this.initialStyleAcknowledgement(), this.changeNullValueToDash());
        
    }
    @wire(getSAAccessories, {
        recordId: '$recordId'
    }) returnItems({data, error}){
        this.packageItemList = data ? data : undefined;
        this.error = error ? undefined : error;
    }

    @wire(getAddonSAAcessories, {recordId: '$recordId' })
    addonListRefresh(result){
        this.wiredSAAccessoryRecords = result;
        this.addOnList = result.data  ? result.data : undefined;
        this.error = result.error ? result.error : undefined;
    }

    @wire(getRecord, { recordId : '$recordId', fields: FIELDS })
    salesAgreementObject(result) {
        this.wireSalesRec = result; //This is needed if you want to deliberately refresh it
        this.error = result.error ? ( result.error, result.data = undefined) : undefined;
        this.salesRec = result.data ? result.data.fields : undefined;
        //this.salesRec = this.salesRec && this.changeNullValueToDash(this.salesRec);
        this.salesRec && (this.checkAndProcessAcknowledgeFields(), this.enableDocuSignButton(), this.defaultBranchName(), this.changeFieldValue(), this.defaultCreditTC(), this.mustProcessAdditionalCharges=true);
        if (this.salesRec && this.salesRec.isSellerNotBuyer__c.value === false) {
            this.disabled = true;
        }
    }

    @wire(getSAAdditionalCharges, {recordId: '$recordId' })
    additionalChargesRefresh(result){
        this.wiredAdditionalChargesRecords = result;
        this.tempAdditionalCharges = result.data ? result.data : undefined;
        this.mustProcessAdditionalCharges = true;
        //result.data && this.processSAAdditionalCharges(result.data);
        this.error = result.error ? result.error : undefined;
    }

    changeFieldValue(){
        this.salesRec.Insurance_Package__c.value && (this.insurancePackageLabel = this.salesRec.Insurance_Package__c.value === '12' ? '1 Year Premium': '2 Year Premium');
    }
    defaultBranchName(){
        this.salesRec.Branch_Code__c.value && 
            (this.branchEntityName = entityName[`${this.salesRec.Branch_Code__c.value}`],
             this.marketingContactUs = contactUS[`${this.salesRec.Branch_Code__c.value}`]);
    }

    defaultCreditTC() {
        let branchCode = this.salesRec.Branch_Code__c.value == 'CCF' && this.salesRec.DS_Model__c.value? this.salesRec.Branch_Code__c.value + 'DS' : this.salesRec.Branch_Code__c.value;
        this.salesRec.Branch_Code__c.value && (this.creditTC = CREDIT_TC[branchCode]);
    }

    processSAAdditionalCharges(data){
        if(data === undefined) return;
        this.additionalCharges = [];
        this.roadTaxList = [];
        data.forEach(elem=>{
            const record = {};
            record.chargeCode =  elem.SAD_ADM_CHRGCD__c;
            record.displayCharges = elem.SAD_ADDCHARGE__c.includes('INCLUSIVE') ? 'Inclusive' : '$'+ elem.SAD_CHARGES__c.toLocaleString('en');
            record.description = elem.ChargeCodeDescription__c;
            if(record.chargeCode === 'R004' || record.chargeCode==='R002'){

            record.chargeCode === 'R004' && ( record.description = roadTaxLabel.getRoadTaxLabel(record.chargeCode),
                                              record.displayCharges = this.salesRec.Road_Tax_Top_Up__c.value === false ? 'Inclusive' : '$' + Number(elem.SAD_CHARGES__c / 2 ).toLocaleString('en') + ' Top Up');
            record.chargeCode === 'R002' && (record.description = roadTaxLabel.getRoadTaxLabel(record.chargeCode));
            
            this.roadTaxList.push(record);
            }

            if(record.chargeCode === 'C002'){
                record.displayCharges = record.displayCharges.toLocaleString('en');

            }

            this.additionalCharges.push(record);
        })

        this.additionalCharges.sort((rowOne, rowTwo) => (rowOne.chargeCode > rowTwo.chargeCode) ? 1 : -1);
        this.firstTimeDefaultRoadTaxOption = true;
        this.mustProcessAdditionalCharges=false;

    }

    processRoadTax(){
        if(this.salesRec.Road_Tax_Top_Up__c.value === undefined) return;

        if(this.roadTaxList.length === 2){
            const removeRoadTaxType = this.salesRec.Road_Tax_Top_Up__c.value === true ? 'R002' : 'R004';
            const roadTaxRowIndex = this.additionalCharges.findIndex(row=>row.chargeCode === removeRoadTaxType);
            this.additionalCharges.splice(roadTaxRowIndex,1);
        }

        this.firstTimeDefaultRoadTaxOption = false;
    }
    checkAndProcessAcknowledgeFields(){
        Object.keys(requiredFields).forEach((key)=>{
            this.acknowledgeList[key] = typeof this.salesRec[key].value === 'undefined' ? false :
                                               this.salesRec[key].value === true ? true: false;
            
            key === 'AcknowledgementOffPeak__c' && ( 
                    this.acknowledgeList[key]  = this.salesRec.Registration_Number_Type__c.value === 'Off Peak Car' ? 
                        (this.salesRec.AcknowledgementOffPeak__c.value ? this.salesRec.AcknowledgementOffPeak__c.value : false) : 
                    true );
            key === 'AcknowledgementPersonalData__c' && (this.acknowledgeList[key] = true);
            //this.changeStyleAcknowledgementDiv(key,this.acknowledgeList[key]);
            
        })
        this.isPrivateHire = this.salesRec.PrivateHire__c.value ? this.salesRec.PrivateHire__c.value : this.isPrivateHire;
        this.isPromotionVehicle = this.salesRec.isPromotionVehicle__c.value ? this.salesRec.isPromotionVehicle__c.value : this.isPromotionVehicle;
        this.isOffpeakCar = this.salesRec.Registration_Number_Type__c.value === 'Off Peak Car' ? true : false;
        this.salesRec.Registration_Type__c.value && (this.isCompany = this.salesRec.Registration_Type__c.value === 'C' ? true : false);

        this.initialStyle = true;
    }

    initialStyleAcknowledgement(){
        if(this.initialStyle === false) return;
        Object.keys(requiredFields).forEach((key)=>{
            this.acknowledgeList[key] === false && this.changeStyleAcknowledgementDiv(key,this.acknowledgeList[key]);
        })

        this.isLocked === true && (this.template.querySelectorAll(`input[type="checkbox"]`).forEach(elem=>{elem.disabled = true;}));

        this.initialStyle = false;
    }
    changeStyleAcknowledgementDiv(key, value){
        value === true ? this.template.querySelector(`div[data-name=${key}]`).style="" : 
        this.template.querySelector(`div[data-name=${key}]`).style="border-width: thin; border-color: #00619e;border-style: solid;";
        key === 'AcknowledgementPersonalData__c' && (this.template.querySelector(`div[data-name=${key}]`).style="");
    }
    onChangeCheckBox(event){
        event.preventDefault();
        const detaillData = {};
        detaillData[event.target.name] = event.target.checked;
        this.acknowledgeList[event.target.name] = event.target.name === 'AcknowledgementPersonalData__c' ? true : event.target.checked;
        this.changeStyleAcknowledgementDiv(event.target.name,event.target.checked);
        detaillData.Last_save_on_form__c = 'Review';
        detaillData.Id = this.recordId;

        updateSalesAgreement({ salesAgreement : detaillData })
        .then(()=>{
            refreshApex(this.wireSalesRec);
            this.enableDocuSignButton();
        })
        .catch(error=>{
            this.error = error;
        })

    }

    onOptionChanged(event) {
        event.preventDefault();
        if (event.target.checked && event.target.value === 'usedCarAgrmnt') {
            this.isUsedCarAgrmnt = true;
            this.recipientEmailForUCA = this.salesRec ? this.salesRec.Seller_Email_Address__c.value : '';
            this.dispatchEventOut({isUsedCarAgrmnt:this.isUsedCarAgrmnt, recipientEmailForUCA: this.recipientEmailForUCA});
        } else if (event.target.checked && event.target.value === 'salesAgreement'){
            this.isUsedCarAgrmnt = false;
            this.recipientEmail = this.salesRec ? this.salesRec.emailaddress__c.value : '';
            this.dispatchEventOut({isUsedCarAgrmnt:this.isUsedCarAgrmnt, recipientEmail: this.recipientEmail});
        }  
    }

    enableDocuSignButton(){
        this.dispatchEventOut({enableDocuBtn : this.isLocked ? false : Object.values(this.acknowledgeList).every(item=> item===true) });
    }

    navigateOutFromEdit(event){
       const activityStage = event.target.className;
       this.isShowModal = true;
       this.editSection = activityStage.replace('edit ', '');
       this.template.querySelector(`main`).classList.add('lockScroll');
       //this.dispatchEventOut({stage : activityStage.replace('edit ', '')});
    }

    closeEditModal(event){
        this.template.querySelector(`main`).classList.remove('lockScroll');
        this.closeAddOn(event);
        refreshApex(this.wireSalesRec);
    }

    closeAddOn(){
        this.isShowModal = false;
    }

    dispatchEventOut(request){
        this.dispatchEvent(new CustomEvent('activitychanged', { detail: request }));
    }

    onExpand(event){
        const selector = this.template.querySelector(`div[data-name=${event.currentTarget.dataset.name}]`);
        selector.className.includes(' collapse') ?  selector.classList.remove('collapse'): selector.classList.add('collapse');
        this.rotateArrowImg(event.currentTarget.dataset.name);
    }

    rotateArrowImg(selection){
        this.template.querySelectorAll(`c-img-cmp`).forEach(elem=>{
            elem.dataset.name === selection && (elem.className.includes('rotate180') ? elem.classList.remove('rotate180') : elem.classList.add('rotate180'));
        })
    }

    get getConditionOfSales(){
        return `${sdpBootstrap}/${this.salesRec.Branch_Code__c.value}conditionOfSales.html`;
    }

    changeNullValueToDash(){
        this.template.querySelectorAll(`.review-value`).forEach(elem=>{
            elem.innerText = this.checkIsBlank(elem.innerText) === true ? '--' : elem.innerText 
        });
        this.template.querySelectorAll(`.checkisEmpty`).forEach(elem=>{
            elem.innerText = this.checkIsBlank(elem.innerText) === true ? '--' : elem.innerText 
        });
    }

    checkIsBlank(value){
        return value === '' ? true : (value === '   ' ? true : (value === '  ' ? true : false)); 
    }
}