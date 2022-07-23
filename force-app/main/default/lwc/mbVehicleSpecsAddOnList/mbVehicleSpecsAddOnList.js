import { LightningElement, api, track, wire } from 'lwc';
import { createRecord, deleteRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBuildSpecRecords from '@salesforce/apex/mbVehicleSpecsCtl.doGetAvailableSpecs';
import MB_SPEC_OBJECT from '@salesforce/schema/MB_SA_Spec__c';
import MB_SPEC_SA_FIELD from '@salesforce/schema/MB_SA_Spec__c.MB_Sales_Agreement__c';
import MB_SPEC_FIT_TYPE_FIELD from '@salesforce/schema/MB_SA_Spec__c.Fit_Type__c';
import MB_SPEC_PRINT_FIELD from '@salesforce/schema/MB_SA_Spec__c.PRINT__c';
import MB_SPEC_DESCRIPTION_FIELD from '@salesforce/schema/MB_SA_Spec__c.Description__c';
import MB_SPEC_INVOICE_VALUE_FIELD from '@salesforce/schema/MB_SA_Spec__c.Invoice_Value__c';
import MB_SPEC_PRODUCT_CODE_FIELD from '@salesforce/schema/MB_SA_Spec__c.Product_Code__c';
import MB_SPEC_OTYPE_FIELD from '@salesforce/schema/MB_SA_Spec__c.OType__c';
import MB_SPEC_ID_FIELD from '@salesforce/schema/MB_SA_Spec__c.Id';

const InitialServiceCredit = [
    {
        'AVCODE__c': 'O', 
        'Label': 'Service Credit: 5 Years from Registration Date (Non-Transferable)', 
        'Description__c': ' SvcCredit-5yrsFromRegDate(Non-Transferable)', 
        'Invoice_Price__c': 0, 
        'Option_Code__c': 'SVC', 
        'Option_Type__c': 'D', 
        'Option_Group__c': 'Service Credit',
        'Id': 'SVC',
    },
    {
        'AVCODE__c': 'O', 
        'Label': 'Replacement Service Credit - Transfer: 5 Years from Registration Date (Non-Transferable)', 
        'Description__c': ' SvcCredit-5yrsFromRegDate(Non-Transferable)', 
        'Invoice_Price__c': 0, 
        'Option_Code__c': 'RSVC', 
        'Option_Type__c': 'D', 
        'Option_Group__c': 'Service Credit - Transfer',
        'Id': 'RSVC',
    }
];

const InitialBoutiqueVoucher = [
    {
        'AVCODE__c': 'O', 
        'Label': 'MB Boutique Voucher', 
        'Description__c': 'MB Boutique Voucher ', 
        'Invoice_Price__c': 0, 
        'Option_Code__c': 'BOUTVC', 
        'Option_Type__c': 'D', 
        'Option_Group__c': 'Boutique Voucher',
        'Id': 'BOUTVC',
    }
]

const allowDuplicate = false;

export default class MbVehicleSpecsAddOnList extends LightningElement {
    
    @api salesAgreement;                                        // current sales agreement record
    @api existingOptions = [];                                  // existing options of @salesAgreement

    // Apex callout related attributes
    @track masterBuildSpecs = [];                               // build specs master data for this variant & model
    @track init = true;                                         // flag to render only once
    @track spinner = false;                                     // flag for spinner

    // UI Chevron dropdown status
    @track sc_ = false;                                         // service credit dropdown status
    @track aa_ = false;                                         // additional accessories dropdown status
    @track bv_ = false;                                         // boutique voucher dropdown status
    @track odf_ = false;                                        // other dealer fitted dropdown status
    @track fo_ = false;                                         // factory option fitted dropdown status

    // count of records
    @track countSC = 0;                                         // total count of service credits
    @track countAA = 0;                                         // total count of available additional accessories
    @track countBV = 0;                                         // total count of available boutique voucher
    @track countODF = 0;                                        // total count of other dealer fitted
    @track countFO = 0;                                         // total count of factory option

    // count of exsiting options
    @track countSC_ = 0;                                        // total count of existing service credits
    @track countAA_ = 0;                                        // total count of existing additional accessories
    @track countBV_ = 0;                                        // total count of existing boutique voucher
    @track countODF_ = 0;                                       // total count of existing other dealer fitted
    @track countFO_ = 0;                                        // total count of existing factory option

    // UI template controller
    @track haveAA = false;                                      // flag for @countAA > 0
    @track haveBV = false;                                      // flag for @countBV > 0
    @track haveODF = false;                                     // flag for @countODF > 0
    @track haveFO = false;                                      // flag for @countFO > 0

    // Group of records
    @track SCs;                                                 // all service credit records
    @track AAs;                                                 // all additional accessories records
    @track BVs;                                                 // all boutique voucher records
    @track ODFs;                                                // all other dealer fitted records
    @track FOs;                                                 // all factory option records

    get specWatcher_() {
        return null;
    }

    set specWatcher_(val) {
        this.countSC_ = 0;
        this.countAA_ = 0;
        this.countBV_ = 0;
        this.countODF_ = 0;
        this.countFO_ = 0;

        this.SCs.forEach(spec => {
            spec.exist && this.countSC_++;
        })

        this.AAs.forEach(spec => {
            spec.exist && this.countAA_++;
        })

        this.BVs.forEach(spec => {
            spec.exist && this.countBV_++;
        })

        this.ODFs.forEach(spec => {
            spec.exist && this.countODF_++;
        })

        this.FOs.forEach(spec => {
            spec.exist && this.countFO_++;
        })

        console.log('countSC_ :: ', this.countSC_);
        console.log('countAA_ :: ', this.countAA_);
        console.log('countBV_ :: ', this.countBV_);
        console.log('countODF_ :: ', this.countODF_);
        console.log('countFO_ :: ', this.countFO_);
    }

    renderedCallback() {
        if (this.init) {
            this.getBuildSpecs();
            this.init = false;
        }
    }

    /**
     * get available build spec for this variant & model
     */
    getBuildSpecs() {
        this.spinner = true;
        getBuildSpecRecords({
            VariantId: this.salesAgreement.VariantId__c,
            ModelId: this.salesAgreement.ModelId__c,
            Keyword: ''
        })
        .then(result => {
            console.log('Get specs result :: ', result);
            this.processBuildSpecFound(result);
            this.spinner = false;
        })
        .catch(error => {
            this.toastApexError(error);
            this.spinner = false;
        });
    }

    /**
     * process returned build spec records
     * @param {*} data 
     */
    processBuildSpecFound(data) {
        this.masterBuildSpecs = this.deepClone(data);
        this.getServiceCreditGroup();                           // handle service credit group
        this.getBoutiqueVoucherGroup();                         // MODIFIED BY THIEU DANG VU - 8/12/2010 - handle boutique voucher group
        this.distributeBuildSpecIntoGroup();                    // handle other spec groups
        this.calculateUIProps();
        // this.toast('SUCCESS', 'Component is running with allowDuplicate mode: [' + allowDuplicate + ']', null, 'success', 'dissmissible');
    }

    /**
     * Since service credit do not have master data in build spec object, use InitialServiceCredit as master data instead
     */
    getServiceCreditGroup() {
        this.SCs = [];

        InitialServiceCredit.forEach(SC => {
            let initSC = {
                record : SC,
                changesDetected : false,
                exist : false,
                existingSpecsId : null,
            }

            // check spec already existing as SA spec
            for (let option of this.existingOptions) {
                if (option.record.Product_Code__c.substring(0,3) === SC.Option_Code__c.substring(0,3)) { // option code of service credit will be modified on updating therefore just compare first 3 letters
                    initSC['exist'] = true;
                    initSC['existingSpecsId'] = option.record['Id'];
                    SC['Invoice_Price__c'] = option.record['Invoice_Value__c'];
                    break;
                }
            }
            this.SCs.push(initSC);
        });
        console.log('SCs :: ', this.SCs);
    }

    /* -------- MODIFIED BY THIEU DANG VU - Tue 8th Dec 2020 - START --------*/
    getBoutiqueVoucherGroup() {
        this.BVs = [];

        InitialBoutiqueVoucher.forEach(BV => {
            let initBV = {
                            record : BV,
                            changesDetected : false,
                            exist : false,
                            existingSpecsId : null,
                         }
                    // check spec already existing as SA spec
            for (let option of this.existingOptions) {
                if (option.record.Product_Code__c.startsWith('BOUTVC') === BV.Option_Code__c.startsWith('BOUTVC')) {
                    initBV['exist'] = true;
                    initBV['existingSpecsId'] = option.record['Id'];
                    BV['Invoice_Price__c'] = option.record['Invoice_Value__c'];
                    break;
                }
            }
            this.BVs.push(initBV);
        })
        console.log('BVs :: ', this.BVs);

    }
    /* -------- MODIFIED BY THIEU DANG VU - Tue 8th Dec 2020 - END --------*/

    distributeBuildSpecIntoGroup() {
        this.AAs = [];
        // this.BVs = [];         //  MODIFIED BY THIEU DANG VU - 8/12/2020 - Comment this because Boutique Voucher not coming from Master data anymore
        this.ODFs = [];
        this.FOs = [];
        

        let processedProducts = [];

        this.masterBuildSpecs.forEach(spec => {

            // console.log('code :: ' + spec.Option_Code__c);

            spec = this.deepClone(spec);
            
            if(!allowDuplicate && processedProducts.includes(spec.Option_Code__c)) return;

            let initSpec = {
                record : spec,
                changesDetected : false,
                exist : false,
                existingSpecsId : null,
            }

            // check spec already existing as SA spec
            for (let option of this.existingOptions) {
                if (option.record.Product_Code__c === spec.Option_Code__c) {
                    initSpec['exist'] = true;
                    initSpec['existingSpecsId'] = option.record['Id'];
                    spec['Invoice_Price__c'] = option.record['Invoice_Value__c'];
                    break;
                }
            }
            
            spec.Option_Type__c === 'F' && this.FOs.push(initSpec);
            spec.Option_Type__c === 'D' && spec.Option_Group__c === 'Additional accessories' && this.AAs.push(initSpec);
            // spec.Option_Type__c === 'D' && spec.Option_Group__c === 'Boutique Voucher' && this.BVs.push(initSpec);               // Comment this because Boutique Voucher not coming from Master data anymore
            spec.Option_Type__c === 'D' && (spec.Option_Group__c === 'STANDARD' || spec.Option_Group__c === '') && this.ODFs.push(initSpec);

            !allowDuplicate && processedProducts.push(spec.Option_Code__c);
        });

        console.log('AAs :: ', this.AAs);
        // console.log('BVs :: ', this.BVs);
        console.log('ODFs :: ', this.ODFs);
        console.log('FOs :: ', this.FOs);
    }

    calculateUIProps() {
        this.countSC = this.SCs.length;
        this.countAA = this.AAs.length;
        this.countBV = this.BVs.length;
        this.countODF = this.ODFs.length;
        this.countFO = this.FOs.length;
        this.haveAA = this.countAA !== 0;
        this.haveBV = this.countBV !== 0;
        this.haveODF = this.countODF !== 0;
        this.haveFO = this.countFO !== 0;
        this.specWatcher_ = null;
    }

    onSpecValueChange(event) {
        let value = event.target.value;                         // invoice price
        let name = event.target.name;                           // option code
        let type = event.target.dataset.type;                   // option group
        let specID = event.target.dataset.sid;                  // build spec ID
        
        console.log(name + ' : ' + value + ' : ' + type + ' : ' + specID);
        let changedRecords;

        switch (type) {
            case 'AdditionalAccessories':
                changedRecords = this.AAs.filter(item => item.record['Id'] === specID);
                break;
            case 'BoutiqueVoucher':
                changedRecords = this.BVs.filter(item => item.record['Id'] === specID);
                break;
            case 'OtherDealerFitted':
                changedRecords = this.ODFs.filter(item => item.record['Id'] === specID);
                break;
            case 'FactoryOptions':
                changedRecords = this.FOs.filter(item => item.record['Id'] === specID);
                break;
            case 'ServiceCredits':
                changedRecords = this.SCs.filter(item => item.record['Id'] === specID);
                break;
            default:
                this.toast('WARNING', 'Unregconized option type: ' + type, null, 'warning', 'sticky');
                // console.log('Unregconized option type: ' + type);
                return;
        }

        if (changedRecords.length !== 1) {
            this.toast('WARNING', 'Found non-exist / non-unique option with selected ID', null, 'warning', 'sticky');
            return;
        }

        let recordChanged = changedRecords[0];

        recordChanged.record['Invoice_Price__c'] = value;

        recordChanged.exist === true && (recordChanged.changesDetected = true);         // enable edit button next to changed option

        console.log('record change :: ', recordChanged);

    }

    confirmedValueChanges(event) {
        let name = event.target.name;
        let type = event.target.dataset.type;
        let specID = event.target.dataset.sid;
        console.log(name + ' : ' + type + ' : ' + specID);

        let confirmedRecords;
        switch (type) {
            case 'AdditionalAccessories':
                confirmedRecords = this.AAs.filter(item => item.record['Id'] === specID);
                break;
            case 'BoutiqueVoucher':
                confirmedRecords = this.BVs.filter(item => item.record['Id'] === specID);
                break;
            case 'OtherDealerFitted':
                confirmedRecords = this.ODFs.filter(item => item.record['Id'] === specID);
                break;
            case 'FactoryOptions':
                confirmedRecords = this.FOs.filter(item => item.record['Id'] === specID);
                break;
            case 'ServiceCredits':
                confirmedRecords = this.SCs.filter(item => item.record['Id'] === specID);
                break;
            default:
                this.toast('WARNING', 'Unregconized option type: ' + type, null, 'warning', 'sticky');
                // console.log('Unregconized option type: ' + type);
                return;
        }

        if (confirmedRecords.length !== 1) {
            this.toast('WARNING', 'Found non-exist / non-unique options with selected ID', null, 'warning', 'sticky');
            return;
        }

        let confirmedRecord = confirmedRecords[0];

        confirmedRecord.changesDetected = false;

        console.log('confirmedRecord :: ', confirmedRecord);
        
        this.updateConfirmedRecord(confirmedRecord);
    }

    updateConfirmedRecord(spec) {
        let description = spec.record.Description__c;           // default value
        let optcode = spec.record.Option_Code__c;               // default value

        let isSVC = spec.record.Option_Code__c.startsWith('SVC');
        let isRSVC = spec.record.Option_Code__c.startsWith('RSVC');
        let isServiceCredit = isSVC || isRSVC;
        let isBoutiqueVoucher = spec.record.Option_Code__c.startsWith('BOUTVC');                      // MODIFIED BY THIEU DANG VU - 8/12/2020

        // if service credit add amount to option code
        optcode = isServiceCredit? optcode + (spec.record.Invoice_Price__c).toString() : optcode;
        // if boutique voucher add amount to option code
        optcode = isBoutiqueVoucher? optcode + (spec.record.Invoice_Price__c).toString() : optcode;     // MODIFIED BY THIEU DANG VU - 8/12/2020

        // if service credit add amount to description
        description = isSVC? '$' + (spec.record.Invoice_Price__c).toString() + description : description;
        description = isRSVC? 'R*$' + (spec.record.Invoice_Price__c).toString() + description : description;
        // If boutique voucher add amount to description
        description = isBoutiqueVoucher? description + '$' + (spec.record.Invoice_Price__c).toString() : description;       // MODIFIED BY THIEU DANG VU - 8/12/2020

        const fields = {};
        fields[MB_SPEC_ID_FIELD.fieldApiName] = spec.existingSpecsId;
        fields[MB_SPEC_DESCRIPTION_FIELD.fieldApiName] = description;
        fields[MB_SPEC_PRODUCT_CODE_FIELD.fieldApiName] = optcode;
        fields[MB_SPEC_INVOICE_VALUE_FIELD.fieldApiName] = spec.record.Invoice_Price__c;

        const recordInput = { fields };
        console.log('recordInput :: ', recordInput);

        updateRecord(recordInput)
        .then((success) => {
            console.log(success);
            this.specWatcher_ = null;
            this.toast('SUCCESS', 'Option update success', null, 'success', 'dissmissible');
        })
        .catch(error => {
            console.log(error);
            this.toastApexError(error);
        });
    }

    trackCheckbox(event) {
        let type = event.target.dataset.type;
        let specID = event.target.dataset.sid;
        let name = event.target.name;
        let isChecked = event.target.checked;
        let selectedSpecs = [];

        console.log(name + ' : ' + type + ' : ' + specID + ' :: ' + isChecked);

        switch (type) {
            case 'ServiceCredits':
                selectedSpecs = this.SCs.filter(item => item.record['Id'] === specID);
                break;
            case 'AdditionalAccessories':
                selectedSpecs = this.AAs.filter(item => item.record['Id'] === specID);
                break;
            case 'BoutiqueVoucher':
                selectedSpecs = this.BVs.filter(item => item.record['Id'] === specID);
                break;
            case 'OtherDealerFitted':
                selectedSpecs = this.ODFs.filter(item => item.record['Id'] === specID);
                break;
            case 'FactoryOptions':
                selectedSpecs = this.FOs.filter(item => item.record['Id'] === specID);
                break;
            default:
                this.toast('WARNING', 'Unregconized option type: ' + type, null, 'warning', 'sticky');
                return;
        }

        if (selectedSpecs.length !== 1) {
            this.toast('WARNING', 'Found non-exist / non-unique options with selected ID', null, 'warning', 'sticky');
            return;
        }

        let selectedSpec = selectedSpecs[0];

        isChecked && this.createSASPecsRecord(selectedSpec);
        !isChecked && this.deleteSASpecsRecord(selectedSpec, selectedSpec.existingSpecsId);

        // if (value === true) {
        //     this.createSASPecsRecord(selectedSpec)
        // } else {
        //     if (name === 'ServiceCredits') {
        //         selectedSpec.record.Invoice_Price__c = 0;
        //     }
        //     this.deleteSASpecsRecord(selectedSpec, selectedSpec.existingSpecsId);
        // }
    }

    createSASPecsRecord(spec) {
        console.log(spec + ' -- ' + spec.record.Invoice_Price__c);
        let description = spec.record.Description__c;           // default value
        let optcode = spec.record.Option_Code__c;               // default value

        let isSVC = spec.record.Option_Code__c.startsWith('SVC');
        let isRSVC = spec.record.Option_Code__c.startsWith('RSVC');
        let isServiceCredit = isSVC || isRSVC;
        let isBoutiqueVoucher = spec.record.Option_Code__c.startsWith('BOUTVC');                      // MODIFIED BY THIEU DANG VU - 8/12/2020

        // if service credit add amount to option code
        optcode = isServiceCredit? optcode + (spec.record.Invoice_Price__c).toString() : optcode;
        // if boutique voucher add amount to option code
        optcode = isBoutiqueVoucher? optcode + (spec.record.Invoice_Price__c).toString() : optcode;     // MODIFIED BY THIEU DANG VU - 8/12/2020

        // if service credit add amount to description
        description = isSVC? '$' + (spec.record.Invoice_Price__c).toString() + description : description;
        description = isRSVC? 'R*$' + (spec.record.Invoice_Price__c).toString() + description : description;
        // If boutique voucher add amount to description
        description = isBoutiqueVoucher? description + '$' + (spec.record.Invoice_Price__c).toString() : description;       // MODIFIED BY THIEU DANG VU - 8/12/2020

        const fields = {};
        fields[MB_SPEC_SA_FIELD.fieldApiName] = this.salesAgreement.Id;
        fields[MB_SPEC_FIT_TYPE_FIELD.fieldApiName] = 'O';
        fields[MB_SPEC_PRINT_FIELD.fieldApiName] = 'Y';
        fields[MB_SPEC_DESCRIPTION_FIELD.fieldApiName] = description;
        fields[MB_SPEC_PRODUCT_CODE_FIELD.fieldApiName] = optcode;
        fields[MB_SPEC_OTYPE_FIELD.fieldApiName] = spec.record.Option_Type__c;
        fields[MB_SPEC_INVOICE_VALUE_FIELD.fieldApiName] = spec.record.Invoice_Price__c;

        const recordInput = { apiName: MB_SPEC_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(success => {
            console.log(success);
            spec.exist = true;
            spec.existingSpecsId = success.id;
            this.specWatcher_ = null;
            this.toast('SUCCESS', 'Option create success', null, 'success', 'dissmissible');
        })
        .catch(error => {
            console.log(error);
            this.toastApexError(error);
            // console.log('Error: ' + error.body.message);
        });
    }

    deleteSASpecsRecord(selectedBuildSpec, recordId) {
        deleteRecord(recordId)
        .then((success) => {
            console.log(success);
            selectedBuildSpec.exist = false;
            this.resertInvoicePrice(selectedBuildSpec);
            this.specWatcher_ = null;
            this.toast('SUCCESS', 'Option delete success', null, 'success', 'dissmissible');
        })
        .catch(error => {
            console.log(error);
            this.toastApexError(error);
        });
    }

    /**
     * reset the invoice price of @spec back to default as in master data.
     * there is no direct link between SA spec & build spec therefore we must use option code to search for the price.
     * @param {*} spec 
     */
    resertInvoicePrice(spec) {

        // handle service credits & boutique voucher
        // MODIFIED BY THIEU DNAG VU - 8/12/2020 - Add reset Invoice Price when removing Boutique Voucher
        (spec.record.Option_Code__c.startsWith('SVC') || spec.record.Option_Code__c.startsWith('RSVC') || spec.record.Option_Code__c.startsWith('BOUTVC')) && (spec.record['Invoice_Price__c'] = 0);

        // handler other type of build spec
        let masterSpec = this.masterBuildSpecs.find(masterSpec => {
            return masterSpec.Option_Code__c === spec.record.Option_Code__c;
        });

        console.log('masterSpec :: ', masterSpec);

        masterSpec != undefined && (spec.record['Invoice_Price__c'] = masterSpec['Invoice_Price__c']);
    }

    closeModal(event) {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    collapseExpandSection(event) {
        //Open or close slds class
        if (event.currentTarget.getAttribute('aria-expanded') === "true") {
            event.currentTarget.setAttribute('aria-expanded', false);
            this.template.querySelector(`[data-id=${event.currentTarget.dataset.node}]`).classList.remove('slds-is-open');
        } else {
            event.currentTarget.setAttribute('aria-expanded', true);
            this.template.querySelector(`[data-id=${event.currentTarget.dataset.node}]`).classList.add('slds-is-open');
        }

        //Switch Chevron to up or down
        if (event.currentTarget.dataset.node === 'ServiceCredits') {
            this.sc_ = !this.sc_;
        } else if (event.currentTarget.dataset.node === 'AdditionalAccessories') {
            this.aa_ = !this.aa_;
        } else if (event.currentTarget.dataset.node === 'BoutiqueVoucher') {
            this.bv_ = !this.bv_;
        } else if (event.currentTarget.dataset.node === 'Others') {
            this.odf_ = !this.odf_;
        } else {
            this.fo_ = !this.fo_;
        }
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

    toastApexError(error) {
        console.log(error);
        let errMsg = error.statusText + ' :: ' + error.body.message;
        this.toast('ERROR', errMsg, null, 'error', 'sticky');
    }

    deepClone(data) {
        return JSON.parse(JSON.stringify(data));
    }
}