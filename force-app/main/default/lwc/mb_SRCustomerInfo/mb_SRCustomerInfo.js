import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import MBSRMC_CHANNEL from '@salesforce/messageChannel/MBSRMC__c';
import MB_SALESAGREEMENT_OBJECT from '@salesforce/schema/MB_Sales_Agreement__c';
import REGISTRATION_TYPE_FIELD from '@salesforce/schema/MB_Sales_Agreement__c.Registration_Type__c';
import createSalesAgreement from '@salesforce/apex/MB_StockReservationCtrl.createSalesAgreement';
import searchBusinessContact from '@salesforce/apex/MB_StockReservationCtrl.searchBusinessContact';
import searchPersonAccount from '@salesforce/apex/MB_StockReservationCtrl.searchPersonAccount';
import getRecords from '@salesforce/apex/MB_StockReservationCtrl.getRecords';

export default class Mb_SRCustomerInfo extends LightningElement {
    subscription = null;
    @api stockInfo;
    @api isIndentStock;
    @api prevStock;                                                          // ADDED BY THIEU DANG VU - 23/09/2021 - MB CR

    @track regisTypeVal     = '';
    @track c_details        =   {
                                    __matchPA : null,
                                    __matchBC : null,
                                };
    @track i_details        =   {};
    @track isPrivateRegisType;
    @track isCompanyPurchase;

    @track regisTypeOptions;
    @track salutationOptions;
    @track genderOptions;
    @track maritalStatusOptions;

    @track indentInfo;
    @track availableModelOptions;
    @track availableVariantOptions;
    @track defaultModelOption = {};
    @track defaultVariantOption = {};
    @track defaultColour;
    @track defaultTrim;

    @track spinner;
    @track validateErrorMsg = '';

    emailToSearch;
    mobileToSearch;
    isUnion = true;

    @wire(getObjectInfo, { objectApiName: MB_SALESAGREEMENT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REGISTRATION_TYPE_FIELD
    }) getRegistrationTypePicklist({ data, error }) {
        if (data) {
            this.regisTypeOptions = data.values;
        } else if (error) {
            this.regisTypeOptions = undefined;
        }
    }

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    subscribeToMessageChannel() {
        if (this.subscription) return;
        this.subscription = subscribe(this.messageContext, MBSRMC_CHANNEL, (message) => {
              this.handleMessage(message);
           }
        );
    }

    handleMessage(message) {
        console.log('---- message ---');
        console.log(message);
        let message_ = JSON.parse(JSON.stringify(message));
        let action = message_.action;
        switch(action) {
            case 'indent':
                // If event receieved with stock info then proceed to get default Variant
                // Else refresh all default values and input values
                if (message_.data != undefined && message_.data != null) {
                    this.indentInfo = JSON.parse(JSON.stringify(message_.data));
                    this.getRelatedVariants(this.indentInfo.modelId, true);
                } else {
                    this.defaultModelOption = {};
                    this.defaultVariantOption = {};
                    this.defaultColour = null;
                    this.defaultTrim = null;
                }
                break;
            case 'model_list':
                this.availableModelOptions = message_.data;
                break;
            default:
                break;
        }
    }

    handleCustomerInputChanged(event) {
        let apiFieldNm = event.target.name;
        let type = event.target.type;
        let val;
        if (type == "checkbox") {
            val = event.target.checked;
        } else {
            val = event.detail.value;
        }

        if (apiFieldNm == "Registration_Type__c") {
            this.resetPropsAndInputs();

            if (val == "P") {
                this.isPrivateRegisType = true;
                this.isCompanyPurchase = false;
            } else {
                this.isPrivateRegisType = false;
                this.isCompanyPurchase = true;
            }
            this.regisTypeVal = val;
        }

        if (apiFieldNm == '__isRegisterUnderCompany') {
            this.isCompanyPurchase = val;

            this.resetPropsAndInputs();
        }

        this.c_details[apiFieldNm] = val;
    }

    handleIndentInputChanged(event) {
        let apiFieldNm = event.target.name;
        let val = event.detail.value;

        if (apiFieldNm == "Model__c") {
            this.getRelatedVariants(val, false);
        }

        this.i_details[apiFieldNm] = val;
    }

    handleSearchByEmail() {
        let email = this.template.querySelector(`[data-id='CEmail_Address__c']`).value;
        if (email != '' && email != null && email != undefined) {
            if (this.isCompanyPurchase || !this.isPrivateRegisType) {
                this.searchBA(null, email);
            } else {
                this.searchPA(null, email);
            }
        }
    }

    handleSearchByPhone() {
        let mobile = this.template.querySelector(`[data-id='CMobile__c']`).value;
        if (mobile != '' && mobile != null && mobile != undefined) {
            if (this.isCompanyPurchase || !this.isPrivateRegisType) {
                this.searchBA(mobile, null);
            } else {
                this.searchPA(mobile, null);
            }
        }
    }

    searchBA(mobile, email) {
        if (mobile == null && email == null) {
            return;
        }

        this.spinner = true;
        searchBusinessContact({
            Mobile: mobile,
            Email: email,
            moreConditions: 'AND isPersonAccount = false',
        }).then(result => {
            if (result != null && result.length > 0) {
                this.c_details['Customer_Full_Name__c']   = result[0]['Full_Name__c'];
                this.c_details['CNRIC_Number__c']         = result[0]['NRIC_Passport_No__c'];
                this.c_details['CMobile__c']              = result[0]['MobilePhone'];
                this.c_details['CEmail_Address__c']       = result[0]['Email'];
                this.c_details['CFirst_Name__c']          = result[0]['FirstName'];
                this.c_details['CSurname__c']             = result[0]['LastName'];
                this.c_details['__matchBC']               = result[0]['Id'];

                let c_inputs = this.template.querySelectorAll(`[data-type="c_input"]`);
                c_inputs.forEach(input => {
                    if (input.name == 'CSalutation__c') {
                        // Salutation value from Business Contact is different
                        // Handle special case for display value in input
                        input.value = this.c_details[input.name].replace('\.','');
                    } else {
                        input.value = this.c_details[input.name];
                    }
                })
            } else {
                this.c_details['__matchBC'] = null;
            }

            this.spinner = false;
        }).catch(error => {
            this.spinner = false;
        })
    }

    searchPA(mobile, email) {
        if (mobile == null && email == null) {
            return;
        }

        this.spinner = true;
        searchPersonAccount({
            Mobile: mobile,
            Email: email,
            moreConditions: 'AND isPersonAccount = true',
        }).then(result => {
            if (result != null && result.length > 0) {
                this.c_details['Customer_Full_Name__c']   = result[0]['Full_Name__pc'];
                this.c_details['CNRIC_Number__c']         = result[0]['NRIC_Passport_No__pc'];
                this.c_details['CMobile__c']              = result[0]['PersonMobilePhone'];
                this.c_details['CEmail_Address__c']       = result[0]['PersonEmail'];
                this.c_details['CFirst_Name__c']          = result[0]['FirstName'];
                this.c_details['CSurname__c']             = result[0]['LastName'];
                this.c_details['__matchPA']               = result[0]['Id'];

                let c_inputs = this.template.querySelectorAll(`[data-type="c_input"]`);
                c_inputs.forEach(input => {
                    input.value = this.c_details[input.name];
                })
            } else {
                if (!this.c_details['__matchPA']) {
                    this.c_details['__matchPA'] = null;
                }
            }
            console.log(this.c_details);
            this.spinner = false;
        }).catch(error => {
            this.spinner = false;
        })
    }

    handleConfirm() {
        if (this.validateRequiredInputs()) {
            if (this.validateFormatInputs()) {
                if (this.stockInfo != undefined && this.stockInfo != null) {
                    this.c_details["MB_Stock_Vehicle_Master__c"] = this.stockInfo.vid;
                    // ADDED BY THIEU DANG VU - 23/09/2021 - MB CR
                    if (this.prevStock) this.c_details["Previous_Stock_Number__c"] = this.prevStock.prevStockNo;
                }
                this.createSA(JSON.stringify(this.c_details), JSON.stringify(this.i_details));
            }
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    createSA(c_details, i_details) {
        this.spinner = true;
        createSalesAgreement({
            c_input: c_details,
            i_input: i_details
        }).then(result => {
            this.spinner = false;
            let saId = result;
            let baseURL = 'https://' + window.location.host;
            window.open(baseURL + '/' + saId, '_self');
        }).catch(error => {
            console.log('CREATE SA ERROR:: ' + error.body.message);
            this.toastApexErrorMessage(error);
        })
    }

    getRelatedVariants(modelId, isDefault) {
        getRecords({
            objNm: 'Variant__c',
            fieldReference: 'Model_ID__c',
            fieldValue: modelId,
            additionalConditions: 'AND Allow_Indent__c = true AND Active__c = true'
        }).then(result => {
            let tmpVariantOptions = [];
            let variants = JSON.parse(JSON.stringify(result));
            variants.forEach(variant => {
                tmpVariantOptions.push({
                                        label : variant.Name,
                                        value : variant.Id
                                      });
            })

            this.availableVariantOptions = JSON.parse(JSON.stringify(tmpVariantOptions));

            if (isDefault) {
                let defaultModel = this.availableModelOptions.filter(model => {
                    return model.value == this.indentInfo.modelId;
                })
                this.defaultModelOption.label = defaultModel[0].label;
                this.defaultModelOption.value = defaultModel[0].value;

                let defaultVariant = this.availableVariantOptions.filter(variant => {
                    return variant.value == this.indentInfo.variantId;
                })
                this.defaultVariantOption.label = defaultVariant[0].label;
                this.defaultVariantOption.value = defaultVariant[0].value;

                this.defaultColour = this.indentInfo.color;

                this.defaultTrim = this.indentInfo.trim;

                this.i_details.Model__c = this.defaultModelOption.value;
                this.i_details.Variant__c = this.defaultVariantOption.value;
                this.i_details.Colour__c = this.defaultColour;
                this.i_details.Trim__c = this.defaultTrim;
            }
        }).catch(error => {
            this.toastApexErrorMessage(error);
        })
    }

    validateRequiredInputs() {
        let passed = true;
        let allInputValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, input) => {
                    input.reportValidity();
                    return validSoFar && input.checkValidity();
        }, true);
        let allCbbValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, input) => {
                        input.reportValidity();
                        return validSoFar && input.checkValidity();
            }, true);
        let radioGroupValid = [...this.template.querySelectorAll('lightning-radio-group')]
        .reduce((validSoFar, input) => {
                    input.reportValidity();
                    return validSoFar && input.checkValidity();
        }, true);

        if (!allInputValid || !allCbbValid || !radioGroupValid) {
            passed = false;
        }

        return passed;
    }

    validateFormatInputs() {
        let passed = true;
        let inputs = this.template.querySelectorAll("lightning-input");
        let msg = '';

        inputs.forEach(input => {
            if (input.value != '') {
                if (input.name == "CNRIC_Number__c") {
                    if (input.value.length != 9) {
                        msg += 'NRIC must be 9 alpha-numerics!\n';
                        passed = false;
                    }
                    if (!this.validNRIC(input.value)) {
                        msg += 'Invalid NRIC!\n';
                        passed = false;
                    }
                }
            }
        })
        !passed && this.toast('WARNING!', msg, null, 'warning', 'sticky');

        return passed;
    }

    validNRIC(nric) {
        nric = nric.toUpperCase();

        var i, 
        icArray = [];
        for (i = 0; i < 9; i++) {
            icArray[i] = nric.charAt(i);
        }

        icArray[1] = parseInt(icArray[1], 10) * 2;
        icArray[2] = parseInt(icArray[2], 10) * 7;
        icArray[3] = parseInt(icArray[3], 10) * 6;
        icArray[4] = parseInt(icArray[4], 10) * 5;
        icArray[5] = parseInt(icArray[5], 10) * 4;
        icArray[6] = parseInt(icArray[6], 10) * 3;
        icArray[7] = parseInt(icArray[7], 10) * 2;

        var weight = 0;
        for (i = 1; i < 8; i++) {
            weight += icArray[i];
        }

        var offset = (icArray[0] == "T" || icArray[0] == "G") ? 4 : (icArray[0] == "M") ? 3 : 0;
        var temp = (offset + weight) % 11;
        if (icArray[0] == "M") temp = 10 - temp;

        var st = ["J","Z","I","H","G","F","E","D","C","B","A"];
        var fg = ["X","W","U","T","R","Q","P","N","M","L","K"];
        var m  = ["K", "L", "J", "N", "P", "Q", "R", "T", "U", "W", "X"];

        var theAlpha;
        if (icArray[0] == "S" || icArray[0] == "T") { theAlpha = st[temp]; }
        else if (icArray[0] == "F" || icArray[0] == "G") { theAlpha = fg[temp]; }
        else if (icArray[0] == "M") { theAlpha = m[temp]; }

        return (icArray[8] === theAlpha);
    }

    resetPropsAndInputs() {
        for (let prop of Object.keys(this.c_details)) {
            if (prop == 'Registration_Type__c') continue;

            this.c_details[prop] = null;
        }

        let c_inputs = this.template.querySelectorAll(`[data-type="c_input"]`);
        for (let input of c_inputs) {
            if (input.name == 'Registration_Type__c') continue;

            input.value = null;
        }
    }

    toastApexErrorMessage(error) {
        let errMsg = 'unknow error';
        if (error != undefined && error != null) errMsg = error.body.message || error[0].body.message || JSON.stringify(error);
        this.toast('ERROR', errMsg, null, 'error', 'sticky');
    }

    toast(title, message, msgData, variant, mode) {
        const toastEvent = new ShowToastEvent({
           'title' : title,
           'message' : message,
           'messageData' : msgData,
           'variant' : variant,
           'mode' : mode
        });
        this.dispatchEvent(toastEvent);
    }
}