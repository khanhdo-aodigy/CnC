/* eslint-disable no-unused-expressions */
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import DSA_MileageIcon from '@salesforce/resourceUrl/DSA_MileageIcon';
import DSA_LocationIcon from '@salesforce/resourceUrl/DSA_LocationIcon';

import SALES_AGREEMENT_OBJECT from '@salesforce/schema/Sales_Agreement__c';
import REGISTRATION_NUMBER_METHOD_FIELD from '@salesforce/schema/Sales_Agreement__c.Registration_Number_Method__c';
import getAddonSAAcessories from '@salesforce/apex/DigitalSalesAgreementApplication.getAddonSAAcessories';
import getSAAccessories from '@salesforce/apex/DigitalSalesAgreementApplication.getSAAcessories';

import getNumberRetentionMaster from '@salesforce/apex/DigitalSalesAgreementApplication.getNumberRetentionAdditionalChargesMaster';
import deleteNumberRetention from '@salesforce/apex/DigitalSalesAgreementApplication.deleteNumberRetention';
import upsertNumberRentionMaster from '@salesforce/apex/DigitalSalesAgreementApplication.upsertNumberRetention';

import getSAAdditionalCharges from '@salesforce/apex/DigitalSalesAgreementApplication.getSAAdditionalCharges';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';
import deleteAddonSAAcessories from '@salesforce/apex/DigitalSalesAgreementApplication.deleteAddonSAAcessories';

import upsertOffpeak from '@salesforce/apex/DigitalSalesAgreementApplication.upsertOffPeakRecord';
import deleteOffpeakRecord from '@salesforce/apex/DigitalSalesAgreementApplication.deleteOffpeakRecord';

import {
    GET_ROADTAX_LABEL, FIELDS_TO_BE_DISABLED, CONFIGURATION_PICKLIST, VEH_FIELDS as FIELDS,
    VEHICLE_REQUIRED_FIELDS as requiredFieldCheck,
    SERVICE_CREDIT_WEF_DURATION as calculateServiceCreditWEF
} from 'c/dsp_vehiclePurchaseConfiguration'//'c/dsp_configurationCmp';

export default class Dsp_vehiclePurchase extends LightningElement {
    @api recordId;
    @api isModal = false;
    @api containerStyle = "padding-top: 55px;";

    @track salesRec;
    @track changeList = {};
    @track isPurchaseWithCOE = false;
    @track disabledCOESection = false;
    @track registrationMethodPickListValue = [];
    @track configPickList = [];
    @track error;
    @track isError;
    @track errorMsg;
    @track errorStyle = 'top: 120px; background:#fc6c6c';

    @track addOnMasterList;
    @track addOnList;
    @track packageAddOn;
    @track addOnTotalValue = 0;
    @track showAddOn = false;
    @track packageItemList;
    @track spinner = false;

    @track additionalCharges = [];
    @track roadTaxList = [];
    // @track saAdditionalCharges;
    @track roadTaxChargesAndOthers = 0;
    @track serviceCreditEffectiveYears = 1;
    @track hasUpgradeRoadTaxOption = true;
    @track roadTaxDisplayValue = 'Inclusive';

    @track numberRetentionList;
    @track numberRetentionInSA;
    @track offpeakRecord;

    @track vehicleTotalPrice = 0;
    @track salesAgreementTotal = {};
    currentPage = 'VehiclePurchase';

    hasNotProcessPickListForRegMethod = true;
    firstTimeDefaultRoadTaxOption = false;
    packageItemListValue;

    dsaMileageIcon = DSA_MileageIcon;
    dsaLocationIcon = DSA_LocationIcon;

    renderedCallback() {
        this.disabledCOESection && this.setDisableFieldsForCOE();
        this.firstTimeDefaultRoadTaxOption === true && this.setRoadTaxRadioBtn()
        this.hasNotProcessPickListForRegMethod && this.processRegMethodPicklist();
        const selectQueryHeader = this.template.querySelector(`div[data-name="vehicleHeaderOffset"]`);
        selectQueryHeader && this.bindWindowScroll(selectQueryHeader.offsetTop);
    }
    bindWindowScroll(stickyoffSetTop) {
        if (this.isModal === true) return;
        const actualStickOffset = stickyoffSetTop * (1.08);
        const stickyHeader = this.template.querySelector(`div[data-name="vehicleHeaderSticky"]`);
        window.onscroll = () => {
            window.pageYOffset > actualStickOffset ?
                (stickyHeader.classList.add('sticky'),
                    this.errorStyle = 'top: 125px; background:#fc6c6c') :
                (stickyHeader.classList.remove('sticky'),
                    this.errorStyle = 'top: 20px; background:#fc6c6c');
        };
    }

    //Get picklistvalue for registration number
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REGISTRATION_NUMBER_METHOD_FIELD
    }) registrationMethod(result) {
        this.error = result.error ? result.error : undefined;

        result.data &&
            result.data.values.forEach(record => {
                const configIndex = CONFIGURATION_PICKLIST.findIndex(field => field.listItem === record.value);

                this.configPickList.push({
                    label: record.label, value: record.value,
                    collapsible: CONFIGURATION_PICKLIST[configIndex].collapsible,
                    picklistField: CONFIGURATION_PICKLIST[configIndex].picklistField,
                    inputFields: CONFIGURATION_PICKLIST[configIndex].inputFields,
                    messageToDisplay: CONFIGURATION_PICKLIST[configIndex].messageToDisplay,
                    selected: false
                });
            });

    }

    @wire(getSAAccessories, {
        recordId: '$recordId'
    }) returnItems({ data, error }) {
        this.packageItemListValue = data ? data : undefined;
        this.packageItemList = this.packageItemListValue ? this.packageItemListValue.filter(packageItem => packageItem.SAC_ACM_ACCSCD__c !== undefined && (packageItem.SAC_ACM_ACCSCD__c.includes('SVC') === false && packageItem.SAC_ACM_ACCSCD__c.includes('ACC') === false)) : undefined;
        this.error = error ? undefined : error;
    }

    //Get sales agreement record
    @wire(getObjectInfo, { objectApiName: SALES_AGREEMENT_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    salesAgreementObject(result) {
        this.wireSalesRec = result; //This is needed if you want to deliberately refresh it

        this.error = result.error ? result.error : undefined;
        this.salesRec = result.data ? result.data.fields : undefined;

        if (this.salesRec) {
            console.log('SALESREC: ' + JSON.stringify(this.salesRec));
            this.isPurchaseWithCOE = this.salesRec.PurchasewithCOE__c.value === 'Yes' ? true : false;
            this.salesRec.Registration_Number_Type__c.value === 'Off Peak Car' && this.upsertOffpeakRecord();
            //this.salesAgreementTotal.COE_Charged_Rebate__c = this.isPurchaseWithCOE === true ? this.salesRec.COE_Charged_Rebate__c.value : 0;
            //Start of RN2020Q1010
            //this.salesAgreementTotal.VehicleListPrice__c = this.salesRec.VehicleListPrice__c.value;
            this.salesAgreementTotal.Package_List_Price__c = this.salesRec.Package_List_Price__c.value;
            //End of RN2020Q1010

            this.salesAgreementTotal.Accessories_Discount__c = this.salesRec.Accessories_Discount__c.value;
            this.salesAgreementTotal.Promo_Discount__c = this.salesRec.Promo_Discount__c.value;
            this.salesAgreementTotal.COE_Refund__c = this.salesRec.COE_Refund__c.value;
            this.salesAgreementTotal.Total_VES_Roadtax_and_fees__c = this.salesRec.Total_VES_Roadtax_and_fees__c.value;
            this.serviceCreditEffectiveYears = this.salesRec.service_credit_effective_years__c.value === 0 ? 1 : this.salesRec.service_credit_effective_years__c.value;
            requiredFieldCheck.processRequiredFieldsFirstTimeLoad(this.salesRec);

            this.calculateSalesAgreementTotal();
            this.hasNotProcessPickListForRegMethod = true;
            this.disabledCOESection = this.isPurchaseWithCOE === true ? false : true;
        }
    }

    @wire(getAddonSAAcessories, { recordId: '$recordId' })
    addonListRefresh(result) {
        this.wiredSAAccessoryRecords = result;

        this.addOnMasterList = result.data ? result.data : undefined;
        this.addOnMasterList && this.processAddonTotalValues();
        this.error = result.error ? result.error : undefined;
    }

    @wire(getSAAdditionalCharges, { recordId: '$recordId' })
    additionalChargesRefresh(result) {
        this.wiredAdditionalChargesRecords = result;
        result.data && this.processSAAdditionalCharges(result.data);
        this.error = result.error ? result.error : undefined;
    }

    @wire(getNumberRetentionMaster)
    numberRetentionListRefresh(result) {
        this.wiredNumberRetentionList = result;
        this.numberRetentionList = result.data;
        this.error = result.error ? result.error : undefined;
    }

    processSAAdditionalCharges(data) {
        if (!data) return;
        this.roadTaxList = [];
        this.additionalCharges = [];
        data.forEach(elem => {
            const record = {};
            record.chargeCode = elem.SAD_ADM_CHRGCD__c;
            record.charges = elem.SAD_CHARGES__c;
            record.description = elem.ChargeCodeDescription__c;
            record.defaultCharges = elem.SAD_CHARGES__c;
            record.isRoadTax = false;
            elem.SAD_ADDCHARGE__c.includes('INCLUSIVE') ?
                (record.actualCharges = 0,
                    record.displayCharges = 'Inclusive') :
                (record.actualCharges = elem.SAD_CHARGES__c,
                    record.displayCharges = '$' + elem.SAD_CHARGES__c.toLocaleString('en'));

            if (elem.SAD_ADM_CHRGCD__c === 'R004' || elem.SAD_ADM_CHRGCD__c === 'R002') {
                record.isRoadTax = true;
                record.roadTaxDescription = GET_ROADTAX_LABEL.getRoadTaxLabel(elem.SAD_ADM_CHRGCD__c);
                elem.SAD_ADM_CHRGCD__c === 'R004' && (record.actualCharges = elem.SAD_CHARGES__c / 2,
                    record.defaultCharges = elem.SAD_CHARGES__c / 2,
                    record.displayCharges = elem.SAD_CHARGES__c / 2);

                this.roadTaxList.push(record);
            }

            //Assign number retention
            record.chargeCode === 'R015' && (this.numberRetentionInSA = elem);
            /*
                        if(record.chargeCode === 'C002'){
                            record.displayCharges = '$'+record.actualCharges.toLocaleString('en');
                            record.actualCharges = 0;
                        }
            */

            //this.additionalCharges.push(record);
            this.additionalCharges.push(record);
        })

        this.additionalCharges.sort((rowOne, rowTwo) => (rowOne.chargeCode > rowTwo.chargeCode) ? 1 : -1);
        this.roadTaxList.sort((rowOne, rowTwo) => (rowOne.chargeCode > rowTwo.chargeCode) ? 1 : -1);

        this.calculateTotalVESRoadTaxFees(false);
        this.firstTimeDefaultRoadTaxOption = true;

    }

    processRegMethodPicklist() {
        if (this.salesRec && this.configPickList.length >= 0) {
            const foundIndex = this.configPickList.findIndex(itemFound => itemFound.value === this.salesRec.Registration_Number_Method__c.value);
            foundIndex >= 0 && (this.configPickList[foundIndex].selected = true,
                this.defaultRegMethodInputFields(this.configPickList[foundIndex]));

            this.registrationMethodPickListValue = this.configPickList;
            this.hasNotProcessPickListForRegMethod = false;
        }
    }

    defaultRegMethodInputFields(configRow) {
        typeof configRow.inputFields !== 'undefined'
            && configRow.inputFields.forEach(item => {
                item.existingValue = this.salesRec[`${item.apiName}`].value;
            });

    }
    calculateTotalVESRoadTaxFees(addUpgrade) {

        this.roadTaxChargesAndOthers = this.additionalCharges.reduce((total, currentRow) => {
            addUpgrade === true ? (total += currentRow.actualCharges) :
                (currentRow.chargeCode === 'R004' ?
                    (total += 0) : (total += currentRow.actualCharges));

            return total;
        }, 0);
        this.changeList.Total_VES_Roadtax_and_fees__c = this.salesAgreementTotal.Total_VES_Roadtax_and_fees__c
            = this.roadTaxChargesAndOthers;
        this.calculateSalesAgreementTotal();
    }

    calculateSalesAgreementTotal() {
        this.vehicleTotalPrice = 0;
        for (let value of Object.values(this.salesAgreementTotal)) {
            this.vehicleTotalPrice = typeof value === 'undefined' ? Number(this.vehicleTotalPrice) + 0 : Number(this.vehicleTotalPrice) + Number(value);
        }
        this.changeList.Vehicle_Purchase_Price__c = this.vehicleTotalPrice;
        this.vehicleTotalPrice = Number(this.vehicleTotalPrice).toLocaleString('en');
    }

    onValueChanged(event) {
        this.isError = false;
        Object.assign(this.changeList, event.detail);
        this.setRequiredFieldFilled(Object.keys(event.detail)[0]);
        event.detail.PurchasewithCOE__c &&
            (event.detail.PurchasewithCOE__c === 'Yes' ?
                (this.isPurchaseWithCOE = true,
                    this.disabledCOESection = false) :
                (this.isPurchaseWithCOE = false,
                    this.disabledCOESection = true),
                this.setDisableFieldsForCOE()
            );

        event.detail.Service_Credit__c && (this.changeList.service_credit_effective_years__c = this.serviceCreditEffectiveYears = calculateServiceCreditWEF.getWEFYears(event.detail.Service_Credit__c));
        event.detail.Registration_Number_Method__c && (this.changeSelectionStyle(event.detail.Registration_Number_Method__c), this.processNumberRetention(event.detail.Registration_Number_Method__c));
        event.detail.Registration_Number_Type__c && this.processOffpeak(event.detail.Registration_Number_Type__c);
        this.processDiscountFields();
        this.calculateSalesAgreementTotal();
        this.valueChangedDetected();
    }

    valueChangedDetected() {
        /* const selectEvent = new CustomEvent('change', { detail: this.changeList});*/
        this.dispatchEvent(new CustomEvent('change', { detail: this.changeList }));
    }
    /************************************************************************* */
    /** Number Retention Methods*/

    processNumberRetention(RegMethod) {
        let newNumberRetention = {};

        if (RegMethod === 'Number Retention (for new car) & Acceptance of Random Number (for used car)'
            || RegMethod === 'Number Retention (for new car) & Use of Purchase-Bid Number (for used car)') {

            newNumberRetention = this.numberRetentionInSA === undefined ? this.numberRetentionList[0] : this.numberRetentionInSA;
            this.addNumberRetentionFees(newNumberRetention);
        } else {
            this.numberRetentionInSA !== undefined && this.removeNumberRetentionFees();
        }
    }

    addNumberRetentionFees(newEntry) {
        upsertNumberRentionMaster({
            salesAgreementId: this.salesRec.Id.value,
            updateRec: newEntry
        }).then(result => {
            refreshApex(this.wiredAdditionalChargesRecords);
            this.numberRetentionInSA = result;

        }).catch(error => {
            this.isError = true;
            this.errorMsg = error;
            this.error = error;
        })
    }

    removeNumberRetentionFees() {
        deleteNumberRetention({
            numberRetentionRec: this.numberRetentionInSA
        }).then(result => {
            refreshApex(this.wiredAdditionalChargesRecords);
            this.numberRetentionInSA = undefined;
            console.log(result);
        }).catch(error => {

            this.isError = true;
            this.errorMsg = error;
            this.error = error;
        })
    }

    /*************************************************************************
    /************************************************************************* */
    /** Offpeak Methods*/
    processOffpeak(RegType) {
        RegType === 'Off Peak Car' ? this.upsertOffpeakRecord() : this.removeOffpeakRecord();
    }

    upsertOffpeakRecord() {
        upsertOffpeak({
            recordId: this.salesRec.Id.value,
            branchCode: this.salesRec.Branch_Code__c.value
        }).then(result => {
            this.offpeakRecord = result;
            this.salesAgreementTotal.OffPeak = result.SAC_ACCSVALUE__c;
            this.calculateSalesAgreementTotal();
        }).catch(error => {

            this.error = error;
        })
    }

    removeOffpeakRecord() {

        deleteOffpeakRecord({
            offPeakRecord: this.offpeakRecord
        }).then(result => {
            this.offpeakRecord = result;
            this.salesAgreementTotal.OffPeak = 0;
            this.calculateSalesAgreementTotal();
        }).catch(error => {
            this.error = error;
        })
    }
    /** Offpeak Methods*/
    /************************************************************************* */
    /**  Road Tax methods*/
    roadTaxSelection(event) {
        this.processRoadTaxUpgrade(event.currentTarget.value);
    }
    processRoadTaxUpgrade(roadTaxUpgrade) {
        const roadTaxRowIndex = this.additionalCharges.findIndex(row => row.chargeCode === roadTaxUpgrade);//row=>row.chargeCode === 'R002');
        this.roadTaxList.length === 2 ?
            (roadTaxUpgrade === 'R002' ?
                (this.changeList.Road_Tax_Top_Up__c = false,
                    this.additionalCharges[roadTaxRowIndex].actualCharges = 0,
                    this.roadTaxDisplayValue = 'Inclusive') :
                (this.changeList.Road_Tax_Top_Up__c = true,
                    this.additionalCharges[roadTaxRowIndex].actualCharges = this.additionalCharges[roadTaxRowIndex].defaultCharges,
                    this.roadTaxDisplayValue = '$' + Number(this.additionalCharges[roadTaxRowIndex].actualCharges).toLocaleString('en') + ' Top Up')
                //this.roadTaxDisplayValue = '$' + Number(this.additionalCharges[roadTaxRowIndex].actualCharges / 2).toLocaleString('en') + ' Top Up')
                //this.roadTaxDisplayValue = '$' + Number(this.additionalCharges[roadTaxRowIndex].defaultCharges).toLocaleString('en') + ' Top Up')
            ) :
            (this.changeList.Road_Tax_Top_Up__c = false,
                this.additionalCharges[roadTaxRowIndex].actualCharges = 0,
                this.roadTaxDisplayValue = 'Inclusive');

        this.calculateTotalVESRoadTaxFees(this.changeList.Road_Tax_Top_Up__c);
        this.valueChangedDetected();
    }
    setRoadTaxRadioBtn() {
        if (this.salesRec.Road_Tax_Top_Up__c.value === undefined) return;
        //const isUpgrade = this.salesRec.Road_Tax_Top_Up__c.value === null ? false : true;
        let roadTaxType = null;
        this.roadTaxList.length === 1 ?
            (roadTaxType = this.roadTaxList[0].chargeCode) :
            (roadTaxType = this.salesRec.Road_Tax_Top_Up__c.value === true ? 'R004' : 'R002');

        //Default checkbox
        //this.template.querySelector(`input[data-id=${roadTaxType}]`) && (this.template.querySelector(`input[data-id=${roadTaxType}]`).checked = true);
        this.template.querySelector(`input[data-id=${roadTaxType}]`).checked = true;
        this.processRoadTaxUpgrade(roadTaxType);
        this.firstTimeDefaultRoadTaxOption = false;
    }
    /**  Road Tax methods*/

    setDisableFieldsForCOE() {
        this.disablePickListFields();
        this.disableInputFields();
        this.valueChangedDetected();
    }

    processDiscountFields() {
        let totalDiscountValue = 0;
        for (let [key, value] of Object.entries(this.changeList)) {
            if (key === 'Accessories_Discount__c' || key === 'Promo_Discount__c' || key === 'COE_Refund__c') {
                totalDiscountValue += Number(value);
                this.changeList[key] = value > 0 ? 0 - Number(value) : value; //this.convertPositveToNegative(value);
                this.salesAgreementTotal[key] = value > 0 ? 0 - Number(value) : value; //this.convertPositveToNegative(value);
            }
        }
        this.changeList.Total_Discount_Price__c = 0 - totalDiscountValue;
    }

    disableInputFields() {
        this.disabledCOESection ? this.template.querySelector('div[data-name="COE_Charged_Rebate__c"]').classList.add('is-disabled') : this.template.querySelector('div[data-name="COE_Charged_Rebate__c"]').classList.remove('is-disabled');
        this.template.querySelectorAll('c-input-field-as-cmp').forEach(element => {
            if (FIELDS_TO_BE_DISABLED.COE.inputField.find(field => field.apiName === element.fieldAPIName)) {
                this.disabledCOESection ? element.disableInput() : element.enableInput();
                this.disabledCOESection === true && (this.changeList.COE_Charged_Rebate__c = null);
            }
        });
    }

    disablePickListFields() {
        this.template.querySelectorAll('c-picklist-as-button-cmp').forEach(element => {
            if (FIELDS_TO_BE_DISABLED.COE.pickListAsButton.find(field => field.apiName === element.picklistFieldApiName)) {
                const currentField = FIELDS_TO_BE_DISABLED.COE.pickListAsButton.find(field => field.apiName === element.picklistFieldApiName);
                this.disabledCOESection ? element.disableInput() : element.enableInput();
                this.disabledCOESection && (this.changeList[`${currentField.apiName}`] = null);
            }
        });
    }

    onProcessStepChange() {
        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail: { stage: this.changeList.Last_save_on_form__c }
        }));
    }

    onSaveRecordNext() {
        //this.requiredFieldValidation(this, this.changeList);
        this.changeList.Last_save_on_form__c = 'Finance';
        this.changeList.Id = this.recordId;

        this.isError = requiredFieldCheck.validationCheck(this);
        //this.isError === false && this.saveRecord(this.changeList);
        this.isError === false &&
            this.saveRecord(this.changeList).then(() => {
                this.onProcessStepChange();
            }).catch(error => {
                this.isError = true;
                this.errorMsg = error.body.message;
                this.error = error;
            });
    }

    saveRecord(changeList) {

        return new Promise((resolve, reject) => {
            updateSalesAgreement({
                salesAgreement: changeList
            }).then(result => {
                refreshApex(this.wireSalesRec);
                resolve(result);
            }).catch(error => {
                reject(error);
            })
        })

    }


    setRequiredFieldFilled(fieldApiName) {
        requiredFieldCheck.setIsFilled(fieldApiName);
    }



    processAddonTotalValues() {
        this.addOnTotalValue = 0;
        this.packageAddOn = this.addOnMasterList.filter(item => item.SAC_PACKAGE__c === 'Y');
        this.addOnList = this.addOnMasterList.filter(item => item.SAC_PACKAGE__c === 'N');
        this.addOnList.forEach(elem => {
            this.addOnTotalValue = Number(this.addOnTotalValue) + Number(elem.SAC_ACCSVALUE__c);
        });

        this.changeList.Total_Addon_Price__c = this.salesAgreementTotal.addOnTotalValue
            = this.addOnTotalValue;

        this.calculateSalesAgreementTotal();

    }
    deleteAddOnItem(event) {
        const recordToDel = [{ Id: event.currentTarget.dataset.itemid }];
        const delItem = this.addOnList.find(elem => {
            return elem.Id === recordToDel[0].Id;
        });

        deleteAddonSAAcessories({
            accessorylist: recordToDel
        }).then(() => {

            const changeList = {};
            delItem.Id !== undefined && (
                changeList.Id = this.recordId,
                changeList.Total_Addon_Price__c = Number(this.changeList.Total_Addon_Price__c) - Number(delItem.SAC_ACCSVALUE__c),
                this.salesAgreementTotal.addOnTotalValue = Number(changeList.Total_Addon_Price__c),
                this.calculateSalesAgreementTotal(),

                changeList.Vehicle_Purchase_Price__c = this.changeList.Vehicle_Purchase_Price__c,
                this.saveRecord(changeList).then(() => {
                    refreshApex(this.wiredSAAccessoryRecords);
                }).catch(error => {
                    this.isError = true;
                    this.errorMsg = error.body.message;
                    this.error = error;
                    refreshApex(this.wiredSAAccessoryRecords);
                })
            );



        }).catch(error => {
            this.error = error;
        })
    }
    changeSelectionStyle(text) {
        if (text !== 'To be decided') return;
        this.template.querySelector('c-picklist-as-accordion-cmp').changeSelectedStyle(text);
    }

    doneSavingAddOn(event) {
        this.spinner = true;
        this.closeAddOn(event);
        const changeList = {};
        event.detail.cartTotalValue !== undefined & (changeList.Total_Addon_Price__c = Number(event.detail.cartTotalValue),
            this.salesAgreementTotal.addOnTotalValue = Number(event.detail.cartTotalValue),
            this.calculateSalesAgreementTotal());
        Number(changeList.Total_Addon_Price__c) !== Number(this.changeList.Total_Addon_Price__c) && (changeList.Vehicle_Purchase_Price__c = this.changeList.Vehicle_Purchase_Price__c,
            changeList.Id = this.recordId,
            this.saveRecord(changeList).then(() => {
            }).catch(error => {
                this.isError = true;
                this.errorMsg = error.body.message;
                this.error = error;
            }));
        refreshApex(this.wiredSAAccessoryRecords);
        this.spinner = false;
    }
    openAddOn() {
        this.showAddOn = true;
    }
    closeAddOn() {
        this.showAddOn = false;
    }

}