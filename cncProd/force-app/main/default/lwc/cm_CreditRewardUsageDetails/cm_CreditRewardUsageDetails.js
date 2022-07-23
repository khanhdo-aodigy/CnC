import { LightningElement, api, track } from "lwc";
import createRewardCreditUsage from "@salesforce/apex/CMCreditRewardUsageController.createRewardCreditUsage";
import retrieveAttachment from '@salesforce/apex/CMCreditUsageService.retrieveAttachment';

export default class Cm_CreditUsageDetails extends LightningElement {
    @api recordId;
    @track creditUsageList;
    @track wiredRewardProfile;

    @track invoiceNumber;
    @track creditNote;
    @track refundAmount;
    @track refundReason;
    today = new Date();
    @track issuedDate = this.today.toISOString();
    @track isDateChanged = false;

    @track errorMessage = false;
    @track isSuccess = false;
    isScanning = false;

    @track initialRender = true;
    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = false;
            this.template.querySelector(`[data-id='invoice-number']`).focus();
        }
    }

    onValueChanged(event) {
        this[event.target.name] = event.target.value;
        if (event.target.name == "invoiceNumber" && !this.isScanning) {
            let self = this;
            this.isScanning = true;
            window.setTimeout(() => {
                let elem = self.template.querySelector(`[data-id='invoice-number']`);
                let scannedValue = elem.value; //7222527009072020396.81
                console.log(" invoiceNumber =" + scannedValue);
                console.log(" scannedValue.length =" + scannedValue.length);

                if (scannedValue.length > 8) {
                    self.invoiceNumber = scannedValue.substring(0, 8);
                }
                self.isScanning = false;

                if (self.invoiceNumber.length >= 8) {
                    self.template.querySelector(`[data-id='credit-note']`).focus();
                }

            }, 500);
        }

        if (event.target.name == "creditNote" && !this.isScanning) {
            let self = this;
            this.isScanning = true;
            window.setTimeout(() => {
                let elem = self.template.querySelector(`[data-id='credit-note']`);
                let scannedValue = elem.value; //8291148114072020-1645.00
                console.log(" creditNote =" + scannedValue);
                let dateString = scannedValue.substring(8, 16);

                let issueDateCastVal;
                if (
                    dateString != undefined &&
                    dateString.length == 8 &&
                    dateString.match(/^\d+$/)
                ) {
                    let year = parseInt(dateString.substring(4, 8));
                    let month = parseInt(dateString.substring(4, 2)) - 1;
                    let day = parseInt(dateString.substring(2, 0)) + 1;
                    console.log(year);
                    console.log(month);
                    console.log(day);
                    console.log("*** Handled dateString ****");
                    issueDateCastVal = new Date(year, month, day);
                    self.issuedDate = issueDateCastVal.toISOString();
                }

                console.log(" scannedValue.length =" + scannedValue.length);
                if (scannedValue.length > 16) {
                    self.refundAmount = scannedValue.substring(16);
                    self.refundAmount =
                        self.refundAmount < 0 ? self.refundAmount * -1 : self.refundAmount;
                }

                if (scannedValue.length > 8) {
                    self.creditNote = scannedValue.substring(0, 8);
                }

                console.log(" issuedDate =" + self.issuedDate);
                console.log(" refundAmount =" + self.refundAmount);
                console.log(" creditNote =" + self.creditNote);
                self.isScanning = false;
            }, 500);
        }
    }

    @api
    validateInput() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            this.errorMessage = true;
            const turnOffLoader = new CustomEvent("turnoffloader", {});
            this.dispatchEvent(turnOffLoader);
        }
    }

    @api
    onSubmit() {
        this.validateInput();
        if (!this.errorMessage) {
            createRewardCreditUsage({
                rewardProfileId: this.recordId,
                invoiceNumber: this.invoiceNumber,
                creditNote: this.creditNote,
                refundAmount: this.refundAmount,
                refundReason: this.refundReason,
                issuedDate: this.issuedDate
            })
                .then(result => {
                    console.log("result === " + JSON.stringify(result));
                    setTimeout(() => this.retrieveAttachmentId() , 1000);
                    // const saveEvent = new CustomEvent("submitrecord", {
                    //     detail: { message: "SUCCESS" }
                    // });
                    // this.dispatchEvent(saveEvent);
                    // this.isSuccess = true;
                    // console.log("Ok la");
                })
                .catch(error => {
                    const saveEvent = new CustomEvent("submitrecord", {
                        detail: { message: error.body.message }
                    });
                    this.dispatchEvent(saveEvent);
                    console.log("Bug, bug, fix bug");
                });
        }
    }

    retrieveAttachmentId()
    {
        retrieveAttachment({
            rewardProfileId: this.recordId,
            creditNote: this.creditNote,
            issuedDate: this.issuedDate
        }).then((result) => {
            const saveEvent = new CustomEvent('submitrecord', {
                detail: { 'message': 'SUCCESS',
                          'attachmentId' : result.Id },
            });
            this.dispatchEvent(saveEvent);
            this.isSuccess = true;
            console.log("Ok la");
        }).catch(error =>{
            const saveEvent = new CustomEvent('submitrecord', {                
                detail: { 'message': error.body.message },
            });
            this.dispatchEvent(saveEvent);
        })            
    }
}