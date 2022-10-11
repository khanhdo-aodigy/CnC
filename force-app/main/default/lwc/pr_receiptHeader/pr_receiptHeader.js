import { LightningElement, track, api, wire } from 'lwc';
import getReceiptHeader from '@salesforce/apex/PaymentReceiptController.getReceiptHeader';
import getCommissionMap from '@salesforce/apex/PaymentReceiptController.getCommissionMap';
import getGstRate from '@salesforce/apex/PaymentReceiptController.getGstRate';
import createReceipt from '@salesforce/apex/PaymentReceiptController.createPaymentReceipt';
import { deepClone } from 'c/util';

export default class Pr_receiptHeader extends LightningElement {
    @api recordId;
    @track receipt = {};

    commissionMap;
    spinner = false;

    salesAgreement;


    @wire(getCommissionMap)
    wiredCommissionMap(result) {
        if (result.data) {
            this.commissionMap = result.data;
        }
    }

    async connectedCallback() {
        if (this.recordId) {
            await this.getReceiptHeader();
        }

        this.template.addEventListener('receiptDetailsReady', event => {
            this.createPaymentReceipt(event.detail)
        });

        this.template.addEventListener('cancelReceiptCreation', event => {
            this.cancelReceiptCreation(event.detail)
        });
    }

    disconnectedCallback() {
        this.template.removeEventListener('receiptDetailsReady');
        this.template.removeEventListener('cancelReceiptCreation');
    }

    async getReceiptHeader() {
        const result = await getReceiptHeader({ recordId: this.recordId });
        // console.log('result', result);

        // this.objectApiName = result.sObjName;
        this.salesAgreement = result.record;
        console.log('salesAgreement', this.salesAgreement);
        this.init(this.salesAgreement);
    }

    init(sa) {
        const _receipt = {};
        _receipt.Sales_Agreement__c = sa.Id;
        _receipt.Status__c = 'Posted';
        _receipt.Bill_To__c = sa.Account__c;
        _receipt.Registered_Party__c = sa.Account__c;
        _receipt.Received_From__c = sa.Account__r.Name;
        _receipt.Franchise_Code__c = sa.FranchiseCode__c;
        _receipt.Bill_To_Type__c = sa.Account__r.RecordType.DeveloperName;
        this.receipt = _receipt;
        // console.log('receipt', this.receipt);

        if (this.receipt.Bill_To_Type__c == 'Financiers') {
            this.template.querySelector('lightning-input-field[data-id="receipt-date"]').disabled = false;
        }

    }

    handleOnChange(event) {
        this.receipt[event.target.fieldName] = event.target.value;
        if (event.target.fieldName == 'Credit_Card_Type__c') {
            this.receipt.CC_Commission__c = this.commissionMap[event.target.value];
        }

        if (event.target.fieldName == 'Receipt_Amount__c' || event.target.fieldName == 'Credit_Card_Type__c') {
            this.calculateBTCC();
            if (this.receipt.Type__c == 'Vehicle Deposit') {
                this.calculateGST();
            }
        }

        if (event.target.fieldName == 'Payment_Mode__c') {
            let chequeFields = this.template.querySelectorAll('lightning-input-field[data-id="cheque"]');
            if (this.receipt.Payment_Mode__c != 'Cheque') {
                chequeFields.forEach(elem => {
                    elem.value = '';
                    elem.disabled = true;
                })
            } else {
                chequeFields.forEach(elem => {
                    elem.disabled = false;
                })
            }
        }

        if (event.target.fieldName == 'Type__c') {
            let gstFields = this.template.querySelectorAll('lightning-input-field[data-id="gst"]');
            if (this.receipt.Type__c != 'Vehicle Deposit') {
                this.receipt.GST_Percentage__c = null;
                this.receipt.Receipt_GST_Amount__c = null;
                this.receipt.Receipt_Amount_excl_GST__c = null;
                gstFields.forEach(elem => {
                    elem.value = '';
                    elem.disabled = true;
                })
            } else {
                this.calculateGST();
            }
        }

        // console.log('receipt', this.receipt);
    }

    async calculateGST() {
        try {
            let receiptDateElem = this.template.querySelector('lightning-input-field[data-id="receipt-date"]');
            let receiptDate = receiptDateElem.value;
            this.receipt['Receipt_Date__c'] = receiptDate;
            let gstRate = await getGstRate({ receiptDate: receiptDate });
            console.log('gstRate', gstRate);
            this.receipt.GST_Percentage__c = gstRate;

            if (!isNaN(this.receipt.Receipt_Amount__c)) {

                if (!isNaN(this.receipt.GST_Percentage__c)) {
                    this.receipt.Receipt_GST_Amount__c = this.receipt.Receipt_Amount__c * this.receipt.GST_Percentage__c / 100;
                }

                if (!isNaN(this.receipt.Receipt_GST_Amount__c)) {
                    this.receipt.Receipt_Amount_excl_GST__c = this.receipt.Receipt_Amount__c - this.receipt.Receipt_GST_Amount__c;
                }
            }

        } catch (e) {
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
        }
    }

    calculateBTCC() {
        if (!isNaN(this.receipt.Receipt_Amount__c) && !isNaN(this.receipt.CC_Commission__c)) {
            this.receipt.CC_Commission_Amount__c = this.receipt.Receipt_Amount__c * this.receipt.CC_Commission__c / 100;
        }
    }

    cancel() {
        window.history.back();
    }

    isInputValid() {
        let allValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.reportValidity();
        }, true);
        return allValid;
    }

    saveAndPost() {
        console.log('receipt', this.receipt);
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        let buttons = this.template.querySelectorAll('button');
        try {
            if (this.isInputValid()) {
                inputFields.forEach(input => {
                    input.disabled = true;
                });

                buttons.forEach(button => {
                    button.disabled = true;
                });

                
                this.template.querySelector('c-pr_receipt-details').createReceiptDetails();
                
            }
        } catch (e) {
            console.error(e);
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
            buttons.forEach(button => {
                button.disabled = false;
            });

            // inputFields.forEach(input => {
            //     input.disabled = false;
            // });
        }
    }

    async createPaymentReceipt(receiptDetails) {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        let saveButton = this.template.querySelector('button[name="save"]');
        this.spinner = true;
        try{
            
            saveButton.disabled = true;
            console.log('createPaymentReceipt.receiptDetails', receiptDetails);
            const result = await createReceipt({
                receipt: this.receipt,
                receiptDetails: receiptDetails
            });
            console.log('result', result);

            this.showNotification('Success!', 'Payment Receipt was created successfully', 'success', 'dismissable');
            setTimeout(() => { 
                window.history.back();
            }, 2000);
            
        } catch(e) {
            console.error(e);
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
            
            saveButton.disabled = false;
        }
        this.spinner = false;
        
    }

    cancelReceiptCreation() {
        let saveButton = this.template.querySelector('button[name="save"]');
        saveButton.disabled = false;
    }

    showNotification(title, message, type, mode) {
        const _notiDetails = {
            title: title,
            message: message,
            type: type,
            mode: mode
        };

        this.bubbleEvent('showNotification', _notiDetails);
    }

    bubbleEvent(evtName, evtDetail) {
        this.dispatchEvent(new CustomEvent(evtName, {
            detail: evtDetail,
            bubbles: true,
            composed: true
        }));
    }
}