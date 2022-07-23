import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import MBSRMC_CHANNEL from '@salesforce/messageChannel/MBSRMC__c';
import getRecords from '@salesforce/apex/MB_StockReservationCtrl.getRecords';
import getAvailableTrimColour from '@salesforce/apex/MB_StockReservationCtrl.getAvailableTrimColour';
import getAvailableHighlightOptions from '@salesforce/apex/MB_StockReservationCtrl.getAvailableHighlightOptions';
// import getVariants from '@salesforce/apex/MB_StockReservationCtrl.getVariants';
import getPromotions from '@salesforce/apex/MB_StockReservationCtrl.getPromotion';                                  // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0192
import getVariantDescription from '@salesforce/apex/MB_StockReservationCtrl.getVariantDescription';                 // ADDED BY THIEU DANG VU - Wed 6th Jan 2021

export default class Mb_SRSearchPanel extends LightningElement {

    @track availableModelOptions        = [];
    @track availableVariantOptions      = [];
    @track availableColourOptions       = [];
    @track availableTrimOptions         = [];
    @track availableHighlightOptions    = [];
    @track availablePromoOptions        = [];
    @track availableEDDOptions          = [];
    eddOptions = [
                    // { label: "--------------- None ---------------", value: null},
                    { label: "January",   value: "01" },
                    { label: "February",  value: "02" },
                    { label: "March",     value: "03" },
                    { label: "April",     value: "04" },
                    { label: "May",       value: "05" },
                    { label: "June",      value: "06" },
                    { label: "July",      value: "07" },
                    { label: "August",    value: "08" },
                    { label: "September", value: "09" },
                    { label: "October",   value: "10" },
                    { label: "November",  value: "11" },
                    { label: "December",  value: "12" }
                ]
    // @track spinner = false;

    selectedVariant;                                                                                                // ADDED - Mon 16th Nov 2020 - UAT LOG-0191
    searchPayload = {
                        "action"    : "search",
                        "data"      : {}
                    }

    // For LMS
    @wire(MessageContext)
    messageContext;

    // Get all MB Models
    @wire(getRecords, {
        objNm: 'Model__c',
        fieldReference: 'Branch_Code__c',
        fieldValue: 'CCI',
        additionalConditions: ''
    })
    wiredProps(result) {
        result.error && console.log('ERROR IN RETRIEVING MODELS:: ' + JSON.stringify(result.error)) && this.toastApexErrorMessage(error);
        if (result.data) {
            // Construct to Model options
            let models = this.deepClone(result.data);
            let tmpModelOptions = [];
            models.forEach(model => {
                tmpModelOptions.push({
                                        label : model.Name,
                                        value : model.Id
                                    });
            })
            this.availableModelOptions = this.deepClone(tmpModelOptions);
            // Fire event for Indent Stock scenario
            let self = this;
            // set timeout to handle scenario when child component late to render
            window.setTimeout(() => {
                self.fireLMSEvent('model_list', self.availableModelOptions);
            }, 1000)
        }
    }

    /*getRelatedVariants(modelId) {
        getVariants({
            modelId: modelId
        }).then(result => {
            // Construct to Variant options
            let variants = this.deepClone(result);
            let tmpVariantOptions = [];
            variants.forEach(variant => {
                tmpVariantOptions.push({
                                        label : variant.Description__c,
                                        // value : variant.Id
                                        value : variant.Description__c,
                                        id    : variant.Id
                                    });
            })
            this.availableVariantOptions = this.deepClone(tmpVariantOptions);
        }).catch(error => {
            this.toastApexErrorMessage(error);
        })
    }*/

    handleInputChanged(event) {
        let inputNm = event.target.name;
        let val = event.detail.value;

        if (inputNm == 'modelId') {
            // Get related Variants
            // this.getRelatedVariants(val);
            this.getVariantDesc(val);
            // Reset payload
            this.resetPayloadProps();
            // Reset all input values except for model & EDD
            let inputsToSkip = ['modelId', 'edd'];
            this.resetInputVals(inputsToSkip);
            // Reset dual list values
            this.resetPicklistValues();
            // Reset variable stores variant description
            this.selectedVariant = null;
            // Fire LMS event
            this.fireLMSEvent('reset', null);
        } else if (inputNm == 'variant') {
            this.selectedVariant = val;                                                 // ADDED - Mon 16th Nov 2020 - UAT LOG-0191
            console.log('selected variant:: ' + val);
            // Get related Trims, Colours
            this.getRelatedTrimColour(val);
            // Get related Highlight Options
            let variantId = this.availableVariantOptions.filter(variant => variant.value == val)[0].id;
            console.log('variant ID:: ' + variantId);
            this.getRelatedHighlightOptions(variantId);
            // Reset payload
            this.resetPayloadProps();
            // Get promotions
            this.getPromos();
            // Fire LMS event
            this.fireLMSEvent('reset', null);
        }
        // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 -- UAT LOG-0192
        // Reset payload whenever selecting Promo
        else if (inputNm == 'promo') {
            this.fireLMSEvent('reset', null);
        }

        this.searchPayload.data[inputNm] = val;
        console.log('Search payload:: ' + JSON.stringify(this.searchPayload));
    }

    /*-------------- ADDED BY THIEU DANG VU - 06/01/2021 - START --------------- */
    getVariantDesc(modelId) {
        getVariantDescription({
            modelId: modelId
        })
        .then(result => {
            let records = this.deepClone(result);
            let tmpVariantOptions = [];
            records.forEach(record => {
                tmpVariantOptions.push({
                                        label : record.VariantDescription__c,
                                        value : record.VariantDescription__c,
                                        id    : record.Variant__c
                                    });
            })
            this.availableVariantOptions = this.deepClone(tmpVariantOptions);
        }).catch(error => {
            this.toastApexErrorMessage(error);
        })
    }
    /*-------------- ADDED BY THIEU DANG VU - 06/01/2021 - END --------------- */

    getRelatedTrimColour(variantDesc) {
        getAvailableTrimColour({
            variantDesc: variantDesc
        }).then(result => {
            // Construct to Colour & Trim options
            let colours = this.deepClone(result.colours);
            let trims = this.deepClone(result.trims);
            let edds = this.deepClone(result.edds);                                                     // MB CR 24/03/2021 - EDD options
            let tmpColourOptions = [];
            let tmpTrimOptions = [];
            let tmpEDDOptions = [ { label: "--------------- None ---------------", value: null } ];     // MB CR 24/03/2021 - EDD options
            for (let colour of colours) {
                tmpColourOptions.push({
                                        label : colour,
                                        value : colour
                                    });
            }
            for (let trim of trims) {
                tmpTrimOptions.push({
                                        label : trim,
                                        value : trim
                                    });
            }
            for (let edd of edds) {
                tmpEDDOptions.push(this.eddOptions.filter(option => option.value === edd)[0]);
            }
            this.availableColourOptions = this.deepClone(tmpColourOptions);
            this.availableTrimOptions = this.deepClone(tmpTrimOptions);
            // If EDD data from DB is not correctly formatted (eg: Feb/Mar)
            // Then there might be NULL value appearing after filtering
            // We will filter to exclude those NULL value
            tmpEDDOptions = tmpEDDOptions.filter(Boolean);
            this.availableEDDOptions = [...tmpEDDOptions];
            // Sort by Month (eg: Jan, Feb,...)
            this.availableEDDOptions.sort(function (el1, el2) {
                return el1.value - el2.value;
            });
            console.log('edd:: ' + JSON.stringify(this.availableEDDOptions));
        }).catch(error => {
            this.toastApexErrorMessage(error);
        })
    }

    getRelatedHighlightOptions(variantId) {
        getAvailableHighlightOptions({
            variantId: variantId
        }).then(result => {
            // Construct to Variant options
            let highlightOptions = this.deepClone(result);
            let tmpAvailableHighlightOptions = [];
            highlightOptions.forEach(option => {
                tmpAvailableHighlightOptions.push({
                                                    label   : option.Description__c,
                                                    value   : option.Id,
                                                    code    : option.Option_Code__c,
                                                });
            })
            this.availableHighlightOptions = this.deepClone(tmpAvailableHighlightOptions);
        }).catch(error => {
            this.toastApexErrorMessage(error);
        })
    }

    /* -------- ADDED BY THIEU DANG VU - Mon 16th Nov 2020 -- START - UAT LOG-0192 --------*/
    getPromos() {
        getPromotions({}).then(result => {
            let promos = this.deepClone(result);
            let tmpAvailablePromos = [ { label: '--------------- None ---------------', value: null } ];
            promos.forEach(promo => {
                tmpAvailablePromos.push({
                                            label: promo.Name,
                                            value: promo.Id
                                        });
            })
            this.availablePromoOptions = this.deepClone(tmpAvailablePromos);
        })
    }
    /* -------- ADDED BY THIEU DANG VU - Mon 16th Nov 2020 -- END --------*/

    handleSearch() {
        console.log(JSON.stringify(this.searchPayload));
        // Handle in case users not select any trims or colours
        if (Object.keys(this.searchPayload.data).length !== 0) {
            // If no Colours selected
            // Search with all available Colours
            if (this.searchPayload.data.colours && this.searchPayload.data.colours.length == 0) {
                this.availableColourOptions.forEach(colour => {
                    this.searchPayload.data.colours.push(colour.value);
                })
            }
            // If no Trims selected
            // Search with all available Trims
            if (this.searchPayload.data.trims && this.searchPayload.data.trims.length == 0) {
                this.availableTrimOptions.forEach(trim => {
                    this.searchPayload.data.trims.push(trim.value);
                })
            }
            // This is for displaying Highlight Options list for SR Stock Details
            if (this.searchPayload.data.availableHLO && this.searchPayload.data.availableHLO.length == 0) {
                this.searchPayload.data.availableHLO = [...this.availableHighlightOptions];
            }

            // Assign variant Id for check Indentable && do Indent Stock purpose
            if (this.selectedVariant) {
                this.searchPayload.data.selectedVariantId = this.availableVariantOptions.filter(variant => variant.value == this.selectedVariant)[0].id;
            }
        } else {
            // DO NOTHING
        }
        // Publish event to mb_SRStockSummary to get Stocks
        publish(this.messageContext, MBSRMC_CHANNEL, this.searchPayload);
    }

    handleClearAll() {
        // Refresh search payload
        this.searchPayload.data = {};
        console.log('refreshed payload :: ' + JSON.stringify(this.searchPayload));
        // Refresh input values
        this.resetInputVals();
        // Reset dual list values
        this.resetPicklistValues();
        // Reset for Variant picklist
        this.availableVariantOptions = [];

        this.fireLMSEvent('reset', null);
    }

    resetPayloadProps() {
        this.searchPayload.data.variant = null;
        this.searchPayload.data.colours = [];
        this.searchPayload.data.trims = [];
        this.searchPayload.data.highlightOptions = [];
        this.searchPayload.data.availableHLO = [];
        this.searchPayload.data.selectedVariantId = null;                               // ADDED - Mon 16th Nov 2020 - UAT LOG-0191
    }

    resetInputVals(inputToBeSkipped) {
        let inputs = this.template.querySelectorAll(`[data-type="sr-inputs"]`);
        for (let input of inputs) {
            if (inputToBeSkipped && inputToBeSkipped.length > 0 && inputToBeSkipped.includes(input.name)) {
                continue;
            }
            input.value = null;
        }
    }

    resetPicklistValues() {
        this.availableColourOptions = [];
        this.availableTrimOptions = [];
        this.availableHighlightOptions = [];
        this.availablePromoOptions = [];
    }

    handleIndent() {
        this.fireLMSEvent('indent', null);
    }

    fireLMSEvent(action, data) {
        const payload = {
            action : action,
            data : data
        };
        if (this.messageContext == null) {
            return;
        }
        publish(this.messageContext, MBSRMC_CHANNEL, payload);
    }

    deepClone(data) {
        return JSON.parse(JSON.stringify(data));
    }

    toastApexErrorMessage(error) {
        let errMsg = 'unknow error';
        if (error != undefined && error != null) errMsg = error.body.message || JSON.stringify(error);
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