import { LightningElement, track, wire } from 'lwc';
import getCommissionMap from '@salesforce/apex/PaymentReceiptController.getCommissionMap';
import getReceiptDetails from '@salesforce/apex/PaymentReceiptController.getReceiptDetails';
import getBillToInfo from '@salesforce/apex/PaymentReceiptController.getAccountInfo';
import createReceipt from '@salesforce/apex/PaymentReceiptController.createPaymentReceipt';

export default class Pr_newPaymentReceipt extends LightningElement {
    @track receipt = {};
    currentDatetime = new Date();
    today = this.currentDatetime.getFullYear() + '-' + ('0' + (this.currentDatetime.getMonth() + 1)).slice(-2) + '-' + ('0' + this.currentDatetime.getDate()).slice(-2);

    showReceiptDetails = false;
    postedSuccess = false;
    receiptDetails;


    commissionMap;
    spinner = false;

    paymentReceiptItem;


    @wire(getCommissionMap)
    wiredCommissionMap(result){
        if(result.data) {
            this.commissionMap = result.data;
        }
    }

    connectedCallback() {
        this.template.addEventListener('receiptDetailsReady', event => {
            this.createPaymentReceipt(event.detail)
        });

        this.template.addEventListener('cancelReceiptCreation', event => {
            this.cancelReceiptCreation(event.detail)
        });

        this.init();
    }

    init(){        
        this.receipt.Status__c = 'Posted';
        this.receipt.Type__c = 'Finance Settlement';
    }

    disconnectedCallback() {
        this.template.removeEventListener('receiptDetailsReady');
        this.template.removeEventListener('cancelReceiptCreation');
    }

    handleOnChange(event) {
        this.receipt[event.target.fieldName] = event.target.value;

        if(event.target.fieldName == 'Franchise_Code__c') {
            if(this.receipt.Bill_To__c) {
                this.getReceiptDetails();
            } else {
                this.receiptDetails = [];
            }
        }

        if(event.target.fieldName == 'Bill_To__c') {
            if(this.receipt.Bill_To__c) {
                this.getBillToType();
                this.getReceiptDetails();
            } else {
                this.receipt.Bill_To_Type__c = null;
                this.showReceiptDetails = false;
            }
        }

        if(event.target.fieldName == 'Credit_Card_Type__c') {
            this.receipt.CC_Commission__c = this.commissionMap[event.target.value];
        }

        if(event.target.fieldName == 'Receipt_Amount__c' || event.target.fieldName == 'Credit_Card_Type__c') {            
            this.calculateBTCC();
        }

        if(event.target.fieldName == 'Payment_Mode__c') {
            let chequeFields = this.template.querySelectorAll('[data-id="cheque"]');
            if(this.receipt.Payment_Mode__c != 'Cheque') {
                chequeFields.forEach(elem=>{
                    elem.value = '';
                    elem.disabled = true;
                    elem.style = 'display:none';
                })
            } else {
                chequeFields.forEach(elem=>{
                    elem.disabled = false;
                    elem.style = 'display:block';
                })
            }
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

    async getBillToType(){
        let accountInfo = await getBillToInfo({accountId: this.receipt.Bill_To__c});
        this.receipt.Bill_To_Type__c = accountInfo.RecordType.Name;

        let receiptDateElem = this.template.querySelector('lightning-input-field[data-id="receipt-date"]');
        if(this.receipt.Bill_To_Type__c == 'Finance Company'){
            receiptDateElem.disabled = false;
        } else {
            receiptDateElem.disabled = true;
        }
    }
    
    async getReceiptDetails() {
        try {
            const result = await getReceiptDetails({
                accountId: this.receipt.Bill_To__c, 
                franchiseCode: this.receipt.Franchise_Code__c
            });
            
            console.log('result', result);
            if(result.length > 0) {
                this.receiptDetails = result;
                this.showReceiptDetails = true;
            } else {
                this.receiptDetails = [];
                this.showReceiptDetails = false;
            }
        } catch(e) {
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
        }

    }

    isInputValid() {
        let allValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.reportValidity();
        }, true);
        return allValid;
    }

    saveAndPost() {
        // console.log('receipt', this.receipt);
        let saveButton = this.template.querySelector('button[name="save"]');
        this.spinner = true;
        saveButton.disabled = true;
        try {
            if(this.isInputValid()) {
                this.template.querySelector('c-pr_new-payment-receipt-details').createReceiptDetails();
            } else {
                this.showNotification('Error!', 'Please fill in all required fields', 'error', 'dismissable');      
                this.spinner = false;
                saveButton.disabled = false;
            }           
           
        } catch(e){
            console.error(e);
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');
            this.spinner = false;
            saveButton.disabled = false;
        }
    }

    async createPaymentReceipt(receiptDetails) {
        let saveButton = this.template.querySelector('button[name="save"]');
        this.spinner = true;
        saveButton.disabled = true;
        try{
            console.log('createPaymentReceipt.receiptDetails', receiptDetails);
            const result = await createReceipt({
                receipt: this.receipt,
                receiptDetails: receiptDetails,
                isFinanceSettlement: true
            });
            
            console.log('result', result);
            this.postedSuccess      = true;

            this.showNotification('Success!', 'Payment Receipt was created successfully', 'success', 'dismissable');
            setTimeout(() => { 
                window.history.back();
            }, 2000);
            
        } catch(e) {
            console.error(e);
            this.showNotification('Error!', e.body.message, 'error', 'dismissable');       
            this.spinner = false;     
            saveButton.disabled = false;
        }
        
    }

    cancelReceiptCreation() {
        let saveButton = this.template.querySelector('button[name="save"]');
        this.spinner = false;
        saveButton.disabled = false;
    }

    showNotification(title, message, variant, mode) {
        const _notiDetails = {
            title: title,
            message: message,
            type: variant,
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