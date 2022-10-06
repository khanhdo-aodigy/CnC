import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCommissionMap from '@salesforce/apex/PaymentReceiptController.getCommissionMap';
import getGstRate from '@salesforce/apex/PaymentReceiptController.getGstRate';
import getRelatedSASIs from '@salesforce/apex/PaymentReceiptController.getRelatedSASIs';
import getBillToInfo from '@salesforce/apex/PaymentReceiptController.getAccountInfo';
import createReceiptForMultipleSA from '@salesforce/apex/PaymentReceiptController.createReceiptForMultipleSA';

export default class Pr_newPaymentReceipt extends LightningElement {
    @track receipt = {};
    currentDatetime = new Date();
    today = this.currentDatetime.getFullYear() + '-' + ('0' + (this.currentDatetime.getMonth() + 1)).slice(-2) + '-' + ('0' + this.currentDatetime.getDate()).slice(-2);

    showMatchingTable = false;
    matchingData;
    postedSuccess = false;
    saIds = [];
    siIds = [];


    commissionMap;
    spinner = false;

    paymentReceiptItem;
    debtorLedgerItem;


    @wire(getCommissionMap)
    wiredCommissionMap(result){
        if(result.data) {
            this.commissionMap = result.data;
        }
    }

    handleOnChange(event) {
        this.receipt[event.target.fieldName] = event.target.value;

        if(event.target.fieldName == 'Bill_To__c') {
            this.getBillToType();
            this.getRelatedSASIs();
        }

        if(event.target.fieldName == 'Credit_Card_Type__c') {
            this.receipt.CC_Commission__c = this.commissionMap[event.target.value];
        }

        if(event.target.fieldName == 'Receipt_Amount__c' || event.target.fieldName == 'Credit_Card_Type__c') {            
            this.calculateBTCC();
            if(this.receipt.Type__c == 'Vehicle Deposit'){
                this.calculateGST();
            }
        }

        if(event.target.fieldName == 'Payment_Mode__c') {
            let chequeFields = this.template.querySelectorAll('[data-id="cheque"]');
            if(this.receipt.Payment_Mode__c != 'Cheque') {
                chequeFields.forEach(elem=>{
                    elem.value = '';
                    elem.disabled = true;
                })
            } else {
                chequeFields.forEach(elem=>{
                    elem.disabled = false;
                })
            }
        }
        
        if(event.target.fieldName == 'Type__c') {
            let gstFields = this.template.querySelectorAll('lightning-input-field[data-id="gst"]');
            if(this.receipt.Type__c != 'Vehicle Deposit') {
                this.receipt.GST_Percentage__c          = null;
                this.receipt.Receipt_GST_Amount__c      = null;
                this.receipt.Receipt_Amount_excl_GST__c = null;
                gstFields.forEach(elem=>{
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
            let gstRate = await getGstRate({receiptDate: receiptDate});
            console.log('gstRate', gstRate);
            this.receipt.GST_Percentage__c = gstRate;
            
            if(!isNaN(this.receipt.Receipt_Amount__c)) {
    
                if(!isNaN(this.receipt.GST_Percentage__c)){
                    this.receipt.Receipt_GST_Amount__c = this.receipt.Receipt_Amount__c * this.receipt.GST_Percentage__c/100;
                }
    
                if(!isNaN(this.receipt.Receipt_GST_Amount__c)){
                    this.receipt.Receipt_Amount_excl_GST__c = this.receipt.Receipt_Amount__c - this.receipt.Receipt_GST_Amount__c;
                }
            }

        } catch (e) {
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
        }
    }

    calculateBTCC() {
        if(!isNaN(this.receipt.Receipt_Amount__c) && !isNaN(this.receipt.CC_Commission__c)){
            this.receipt.CC_Commission_Amount__c = this.receipt.Receipt_Amount__c * this.receipt.CC_Commission__c/100;
        }
    }

    cancel(){
        window.history.back();
    }

    isInputValid() {
        let allValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.reportValidity();
        }, true);
        return allValid;
    }

    async getBillToType(){
        let accountInfo = await getBillToInfo({accountId: this.receipt.Bill_To__c});
        this.receipt.Bill_To_Type__c = accountInfo.RecordType.DeveloperName;

        let receiptDateElem = this.template.querySelector('lightning-input-field[data-id="receipt-date"]');
        if(this.receipt.Bill_To_Type__c == 'Financiers'){
            receiptDateElem.disabled = false;
        } else {
            receiptDateElem.disabled = true;
        }
    }
    
    async getRelatedSASIs() {
        try {
            let relatedSASIs = await getRelatedSASIs({accountId: this.receipt.Bill_To__c});
            this.matchingData = relatedSASIs;
            this.matchingData.forEach(record => {
                if(record.sObjectName == 'Sales_Agreement__c') {
                    this.saIds.push(record.Id);
                }
                if(record.sObjectName == 'Sales_Invoice__c') {
                    this.siIds.push(record.Id);
                }
            })
            console.log('relatedSASIs', relatedSASIs);
            this.showMatchingTable = true;
        } catch(e) {
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
        }

    }

    async saveAndPost() {
        this.receipt.Status__c = 'Posted';
        console.log('receipt', this.receipt);
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        let buttons = this.template.querySelectorAll('button');
        try {
            if(this.isInputValid()) {
                this.spinner = true;
                inputFields.forEach(input => {
                    input.disabled = true;
                });
    
                buttons.forEach(button => {
                   button.disabled = true;
                });
    
                const result = await createReceiptForMultipleSA({
                    receipt: this.receipt,
                    saIds: this.saIds,
                    siIds: this.siIds
                });

                console.log('result', result);
                this.showNotification('Success!', 'Payment Receipt was created successfully', 'success', 'dismissable');
                this.postedSuccess      = true;
                this.paymentReceiptItem = result.Payment_Receipt_Line_Item__c;
                this.debtorLedgerItem   = result.Debtor_Ledger_Line_Item__c;
                this.spinner = false;
            }
            
           
        } catch(e){
            console.error(e);
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
            buttons.forEach(button => {
                button.disabled = false;
            });

            inputFields.forEach(input => {
                input.disabled = false;
            });
            this.spinner = false;
        }
    }

    showNotification(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        }));
    }

}