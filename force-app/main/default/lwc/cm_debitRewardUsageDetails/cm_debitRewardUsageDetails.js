import { LightningElement, api, track, wire } from 'lwc';
import createDebitRewardUsages from '@salesforce/apex/CMDebitUsageService.createDebitRewardUsages';
import retrieveRewardProfile from '@salesforce/apex/CMDebitUsageService.retrieveRewardProfile';
import { refreshApex } from '@salesforce/apex';

export default class Cm_debitRewardUsageDetails extends LightningElement {
    @api recordId;

    @track invoiceNumber;
    @track invoiceAmount = 0;
    @track creditAmount;
    today = new Date();
    @track invoiceDate = this.today.getFullYear() + '-' + ('0' + (this.today.getMonth() + 1)).slice(-2) + '-' + ('0' + this.today.getDate()).slice(-2);
    @track rewardProfileRec;
    //@track usageDate;
    @track paymentType;
    @track outStandingAmount = 0;
    @track isDisabled = true;
    @track contactName;
    @track initialRender = true;
    @track totalRemainderBefore;

    isEdit = true;
    scanningTimeOut = 0;
    @track isError = false;

    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = false;
            this.template.querySelector(`[data-id='invoice-number']`).focus();
        }
    }

    @wire(retrieveRewardProfile, { rewardProfileId: '$recordId' })
    rewardProfileObject(result) {
        this.wireRewardProfileRec = result; //This is needed if you want to deliberately refresh it
        this.rewardProfileRec = result ? result.data : undefined;
        this.rewardProfileRec && (this.contactName = this.rewardProfileRec.Contact__r ? this.rewardProfileRec.Contact__r.Name : '');
    }

    get options() {
        return [
            { label: 'Cash', value: 'Cash' },
            { label: 'Credit Card', value: 'Credit Card' },
        ];
    }

    finishScanning = () => {
        let scannedValue = this.invoiceNumber;  //7222527009072020396.81
        console.log(' ***** ' + scannedValue);
        let dateString = scannedValue.substring(8, 16);
        let issueDateCastVal;
        if (dateString != undefined && dateString.length == 8 && dateString.match(/^\d+$/)) {
            let year = parseInt(dateString.substring(4, 8));
            let month = parseInt(dateString.substring(4, 2)) - 1;
            let day = parseInt(dateString.substring(2, 0)) + 1;
            console.log(year);
            console.log(month);
            console.log(day);
            issueDateCastVal = new Date(year, month, day);
            this.invoiceDate = issueDateCastVal.toISOString();
        }

        this.invoiceAmount = scannedValue.substring(16);
        this.invoiceNumber = scannedValue.substring(0, 8);
        this.isScanning = false;
        this.handleInvoiceAmountChange();
        this.scanningTimeOut = 0;
    }

    resetScanningTimeOut = () => {
        window.clearTimeout(this.scanningTimeOut);
        this.scanningTimeOut = window.setTimeout(this.finishScanning, 500);
    }

    handleScannedInput({ target: { name: inputName, value }, keyCode}) {
        console.log("onKeyDown");
        this[inputName] = value;
        if(keyCode != 9 && keyCode != 17 && keyCode != 18 && keyCode != 20 && keyCode != 8 && !(keyCode >= 112 && keyCode<= 123)) { //Tab - Ctrl - Alt - Caps Lock - F1 to F12
            if (inputName === 'invoiceNumber' && keyCode && value.length >= 8) {
                if (!this.scanningTimeOut) {                    
                    this.invoiceNumber = "";
                    this.resetScanningTimeOut();
                } else {
                   this.resetScanningTimeOut();
                }
            }
        }
        
    }

    onValueChanged({ target: { name: inputName, value }}) {
        console.log("changed");
        if (inputName === 'invoiceNumber') {
            this.invoiceNumber = value;
            this.resetScanningTimeOut();
            return this.handleInvoiceAmountChange();
        }  

        this[inputName] = value;
        console.log('Invoice date: ' + this.invoiceDate);

        if (inputName === 'invoiceAmount') {
            return this.handleInvoiceAmountChange();
        }

        if (inputName === 'creditAmount') {
            return this.handleCreditAmountChange(value);
        }
    }

    handleInvoiceAmountChange() {
        if (this.invoiceAmount > this.rewardProfileRec.Total_Remainder__c) {
            this.creditAmount = this.rewardProfileRec.Total_Remainder__c;
            this.outStandingAmount = this.invoiceAmount - this.rewardProfileRec.Total_Remainder__c;
            // this.isDisabled = false;
        }
        else {
            this.creditAmount = this.invoiceAmount;
            this.outStandingAmount = 0;
            // this.isDisabled = true;
        }
        this.getIsDisableSubmit();
    }

    handleCreditAmountChange(value) {
        if (parseFloat( this.rewardProfileRec.Total_Remainder__c) == 0) {
            this.creditAmount = 0;
            value = "";
        }
        if (parseFloat(this.creditAmount) > parseFloat(this.invoiceAmount)) {
            this.creditAmount = this.invoiceAmount;
            if(parseFloat(this.invoiceAmount) <= parseFloat(this.rewardProfileRec.Total_Remainder__c)) {
                this.outStandingAmount = 0;
            } else {
                this.creditAmount = this.rewardProfileRec.Total_Remainder__c;
                this.outStandingAmount = this.invoiceAmount - this.creditAmount;
            }
            
        }

        if (parseFloat(this.creditAmount) <= parseFloat(this.invoiceAmount)) {
            if(parseFloat(this.creditAmount) <= parseFloat(this.rewardProfileRec.Total_Remainder__c)) {                
                this.outStandingAmount = this.invoiceAmount - this.creditAmount;
            } else {
                this.creditAmount = this.rewardProfileRec.Total_Remainder__c;                
                this.outStandingAmount = this.invoiceAmount - this.creditAmount;
            }
        }


        this.getIsDisableSubmit();
    }

    getIsDisableSubmit(){
        if(this.outStandingAmount > 0){
            this.isDisabled = false;
        }
        else{
            this.isDisabled = true;
        }
    }

    @api
    validateData(){
        const allValid = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            this.isError = true;
            const turnOffLoader = new CustomEvent("turnoffloader", {});
            this.dispatchEvent(turnOffLoader);
        }

        let errorMsg = "";

        if(this.creditAmount <= 0){
            errorMsg += "Insuffcient Credit\n";
        }

        if(parseFloat(this.creditAmount) > parseFloat(this.invoiceAmount)){
            errorMsg += "Credit Amount Cannot Greater Than Invoice Amount \n";
        }

        if(parseFloat(this.creditAmount) > parseFloat(this.rewardProfileRec.Total_Remainder__c)) {
            errorMsg += "Credit Amount Cannot Greater Than Total Remainder \n";
        }

        if(this.outStandingAmount > 0 && !this.paymentType){
            errorMsg += "Payment Type is Required for Non-credit Amount \n";
        }

        if(parseFloat(this.rewardProfileRec.Total_Remainder__c) >= 0 && parseFloat(this.creditAmount) == 0) {
            errorMsg += "Credit Deduction Is Not Required \n";
        }

        // if (new Date(this.invoiceDate) > new Date())
        // {
        //     errorMsg += "Invoice Date Cannot Be Greater Than Today \n";
        // }

        if(!!errorMsg) {
            this.isError = true;
            const saveEvent = new CustomEvent("submitrecord", {
                detail: { 'message': errorMsg}
            });
            this.dispatchEvent(saveEvent);
        }
    }

    @api
    onCreate() {
        this.validateData();
        console.log("Credit Amount = " + this.creditAmount);
        console.log("Invoice Amount = " + this.invoiceAmount);
        console.log("Total_Remainder__c = " + this.rewardProfileRec.Total_Remainder__c);        
        this.totalRemainderBefore = this.rewardProfileRec.Total_Remainder__c;        
        console.log(this.totalRemainderBefore);
        
        if (!this.isError) {
            createDebitRewardUsages({
                invoiceNumber: this.invoiceNumber,
                invoiceDate: this.invoiceDate,
                invoiceAmount: this.invoiceAmount,
                creditAmount: this.creditAmount,
                rewardProfileId: this.recordId,
                paymentType: this.paymentType,
                outStandingAmount: this.outStandingAmount,
                totalRemainderBefore: this.totalRemainderBefore
            }).then((result) => {
                console.log('result = ' + result);
                //this.usageDate = result[0].Transaction_Date__c;
                const saveEvent = new CustomEvent('submitrecord', {
                    detail: { 'message': 'SUCCESS',
                              'attachmentId' : result.Id },
                });
                this.dispatchEvent(saveEvent);
                refreshApex(this.wireRewardProfileRec);
                this.isEdit = false;
                //this.isError = false;
            }).catch(error => {
                console.log('error = ' + error);
                console.log('error.body = ' + error.body);                
                console.log('error.body.message = ' + error.body.message);
                const saveEvent = new CustomEvent('submitrecord', {                
                    detail: { 'message': error.body.message },
                });
                this.dispatchEvent(saveEvent);
            })
        }

        this.isError = false;
    }
}