import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/mbVehicleSpecsCtl.getSpecData';
import deleteRecord from '@salesforce/apex/mbVehicleSpecsCtl.deleteSpec';
import updateTOEV from '@salesforce/apex/mbVehicleSpecsCtl.updateTOEV';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
// import { deleteRecord } from 'lightning/uiRecordApi';

var ICONS = [
    'action:add_contact', 'action:add_file', 'action:add_photo_video', 'action:add_relationship', 'action:announcement', 'action:apex',
    'action:approval', 'action:back', 'action:bug', 'action:call', 'action:canvas', 'action:change_owner',
    'action:freeze_user', 'action:goal', 'action:google_news', 'action:info', 'action:join_group', 'action:lead_convert',
]

export default class MbVehicleSpecs extends LightningElement {

    @api recordId;
    @track SA;                                                  // current sales agreement
    @track MA = [];                                             // main accessories
    @track AA = [];                                             // additional accessories
    @track haveAA = false;                                      // boolean to enable AA section
    @track haveMA = false;                                      // boolean to enable MA section
    @track sepBar = false;                                      // flag for separator bar between MA & AA
    @track AATotal = 0;                                         // total additional accessories values
    @track wiredRecords;
    @track spinner;
    @track modal = false;
    
    /**
     * get sales agreement data and spec data
     * @param {*} result 
     */
    @wire(getRecords, {
        recordID: '$recordId',
    })
    wiredProps(result) {
        this.spinner = true;
        this.wiredRecords = result;
        result.error && this.toastApexError(result.error);
        result.data && this.processData(this.deepClone(result.data));
        this.spinner = false;
    }

    /**
     * process data from @wire result
     * @param {*} response 
     */
    processData(response) {
        this.SA = response.SA;
        this.MA = [];
        this.AA = [];

        this.AATotal = 0;
        let MA_ = 0;

        response.specs.forEach(spec => {
            /* -------- MODIFIED BY THIEU DANG VU - Fri 22th Nov 2020 - START --------*/
            // If spec's price is $0 OR null OR
            // spec is either Service Credit or Boutique Voucher
            // then display 'INCLUSIVE'
            let isSVCOrBoutique = false;
            if (spec.Product_Code__c != null && spec.Product_Code__c != '') {
                isSVCOrBoutique = spec.Product_Code__c.startsWith('SVC') || spec.Product_Code__c.startsWith('RSVC') ||
                                    spec.Product_Code__c.startsWith('BOUTVC');
            }
            let isToDisplayInc = isSVCOrBoutique || spec.Invoice_Value__c == 0 || spec.Invoice_Value__c == null;
            let specValue = spec.Invoice_Value__c || 0;
            /* -------- MODIFIED BY THIEU DANG VU - Fri 22th Nov 2020 - END --------*/
            switch (spec.Fit_Type__c) {
                case 'S':
                    // let isDisplayedInc = spec.Invoice_Value__c == 0 || spec.Invoice_Value__c == null;
                    this.MA.push({
                        record: spec,
                        id: spec.Id,
                        description: spec.Description__c,
                        value: specValue,
                        count : ++MA_,
                        isToDisplayInc: isToDisplayInc
                    })
                    break;
                case 'O':
                    /* -------- MODIFIED BY THIEU DANG VU - Fri 22th Nov 2020 - START --------*/
                    if (!isSVCOrBoutique) {
                        this.AATotal += specValue;
                    }
                    /* -------- MODIFIED BY THIEU DANG VU - Fri 22th Nov 2020 - END --------*/
                    this.AA.push({
                        record: spec,
                        id: spec.Id,
                        description: spec.Description__c,
                        value: specValue,
                        isToDisplayInc: isToDisplayInc
                    })
                    // this.AATotal += specValue;
                    break;
                default:
                    console.log('SPEC WITH NON S/O FIT TYPE :: ', spec);
                    break;
            }
        })
        console.log(JSON.stringify(this.AA));
        this.haveAA = this.AA.length !== 0;
        this.haveMA = this.MA.length !== 0;
        this.sepBar = this.haveMA && this.haveAA;
    }

    openModal(event) {
        this.modal = true;
    }

    closeModal(event) {
        updateTOEV({
            saID : this.recordId,
        })
        .then(success => {
            getRecordNotifyChange([{
                recordId : this.recordId,
            }]);
            refreshApex(this.wiredRecords);
            this.modal = false;
        })
        .catch(error => {
            this.toastApexError(error);
        })
        
    }

    /**
     * on delete additional spec record
     * @param {*} event 
     */
    onRecordDelete(event) {
        let confirm = window.confirm('Delete spec?');
        confirm && this.deleteSpec(event.target.value);
    }

    /**
     * call Apex method to delete spec record
     * @param {*} recordId 
     */
    deleteSpec(specID) {
        console.log('Deleting Record :: ' + specID);
        this.spinner = true;
        deleteRecord({
            saID : this.recordId,
            specID : specID,
        })
        .then(() => {
            getRecordNotifyChange([{
                recordId : this.recordId,
            }]);
            refreshApex(this.wiredRecords);
            this.spinner = false;
            this.toast('SUCCESS', 'Delete success', null, 'success', 'dissmissible');
            // window.opener.
            
        })
        .catch(error => {
            this.toastApexError(error);
        });
    }

    deepClone(data) {
        return JSON.parse(JSON.stringify(data));
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

    bugging(event) {
        // window.alert('Hello Bitches, want some bugs?');
        // event.target.classList.remove('bug-around');
        // event.target.classList.add('bug-move');
        
        let randomIcon = ICONS[Math.floor(Math.random() * (ICONS.length - 1))];
        event.target.iconName = randomIcon;
        console.log(event.target);
    }
}