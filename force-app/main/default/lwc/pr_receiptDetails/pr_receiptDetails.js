import { LightningElement, api, track } from 'lwc';
import { deepClone } from 'c/util';

const columns = [
    { label: 'Sales Agreement', fieldName: 'salesAgreementName'},
    { label: 'Sales Invoice', fieldName: 'salesInvoiceName'},
    // { label: 'Date', fieldName: 'invoiceDate', type: 'date' },
    // { label: 'Ref No', fieldName: 'refNo'  },
    { label: 'Document Amount', fieldName: 'documentAmount', type: 'currency' },
    { label: 'Outtanding Amount', fieldName: 'outstandingAmount', type: 'currency' },
    { label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency', editable: true },
];

const readOnlyColumns = [
    { label: 'Sales Agreement', fieldName: 'salesAgreementName'},
    { label: 'Sales Invoice', fieldName: 'salesInvoiceName'},
    { label: 'Document Amount', fieldName: 'documentAmount', type: 'currency' },
    { label: 'Outtanding Amount', fieldName: 'outstandingAmount', type: 'currency' },
    { label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency'},
];


const enterAlcAmtErrMsg = 'Please enter Allocated Amount for selected Debtor Ledger Line Item(s)';

export default class Pr_receiptDetails extends LightningElement {
    columns = readOnlyColumns;

    receiptAmt = 0;
    balanceAmt = 0;
    totalAmt = 0;

    @api 
    get receiptAmount() {
        return this.receiptAmt;
    }

    set receiptAmount(value) {
        this.receiptAmt = value;        
        this.balanceAmt = this.receiptAmt - this.totalAmt;
    }
    

    tableData = [];

    @api receiptDate;
    @api
    get receiptDetails() {
        return this.tableData;
    }

    set receiptDetails(sa) {
        if(sa) {
            if(sa.Sales_Invoices__r) {

                this.tableData = sa.Sales_Invoices__r.map(si => (
                    {
                        salesAgreementId   : sa.Id,
                        salesAgreementName : sa.Name,
                        salesInvoiceId     : si.Id,
                        salesInvoiceName   : si.Name,
                        documentAmount     : sa.Vehicle_Purchase_Price__c,
                        outstandingAmount  : sa.BalancePayment__c,
                        receiptDate        : this.receiptDate,
                        keyField           : si.Id,
                    }
                ));
            } else {
                const rowData = {
                    salesAgreementId   : sa.Id,
                    salesAgreementName : sa.Name,
                    documentAmount     : sa.Vehicle_Purchase_Price__c,
                    outstandingAmount  : sa.BalancePayment__c,
                    receiptDate        : this.receiptDate,
                    keyField           : sa.Id,
                }
                this.tableData.push(rowData);
            }
        }             
    }

    renderedCallback() {        
        this.template.querySelector('div[data-id="result"]').scrollIntoView();

        //Only allow allocating amount when Receipt Amount is not blank
        if(this.receiptAmt) {            
            let table = this.template.querySelector('lightning-datatable');
            let draftValues = table.draftValues;
            table.columns = columns;
            table.draftValues = draftValues;
        } else {
            this.totalAmt = 0;
            this.balanceAmt = 0;
            this.template.querySelector('lightning-datatable').columns = readOnlyColumns;
        }
    }

    onValueChanged(event){
        this.calculateAmounts();
    }

    calculateAmounts() {
        let draftValues = this.template.querySelector('lightning-datatable').draftValues;
        
        let allocatedAmtArray = [];        
        draftValues.forEach(draftValue => {
            const rowData = this.tableData.find( originalRow => originalRow.keyField == draftValue.keyField);

            let allocatedAmt = draftValue.paymentAmount;
            if(!isNaN(allocatedAmt) && allocatedAmt) {
                if(allocatedAmt > rowData.outstandingAmount) {
                    this.showErrorNotification('Allocated Amount should not be greater than Outstanding Amount');
                }
                allocatedAmtArray.push(allocatedAmt);
            }
        })
       

        this.totalAmt = allocatedAmtArray.reduce((accumulator, value) => {
            return accumulator + parseFloat(value);
        }, 0);

        if(this.totalAmt > this.receiptAmt) {
            this.showErrorNotification('Total Payment Amount is exceeded Receipt Amount');
        }

        if(!isNaN(this.receiptAmt) && this.receiptAmt) {
            this.balanceAmt = this.receiptAmt - this.totalAmt;
        }
    }

    @api
    createReceiptDetails() { 
        this.isError = false;
        let table = this.template.querySelector('lightning-datatable');
        let draftValues = table.draftValues;
        // console.log('draftValues', draftValues);
        // console.log('tableData', deepClone(this.tableData));
        // console.log('totalAmt', this.totalAmt);
        // console.log('receiptAmt', this.receiptAmt);

        let infoToSubmit = []; 

        if(draftValues === undefined || draftValues.length < 1 || this.totalAmt === 0) {
            this.showErrorNotification('Please enter Payment Amount to be allocated');
        } else if(parseFloat(this.totalAmt) > parseFloat(this.receiptAmt)) {
            this.showErrorNotification('Total Payment Amount is exceeded Receipt Amount');
        } else {
            draftValues.forEach(draftValue => {
                let rowData = this.tableData.find(rowData => draftValue.keyField == rowData.keyField);
                let paymentAmount = draftValue.paymentAmount;
                if(!isNaN(paymentAmount) && paymentAmount) {

                    for(let [key, value] of Object.entries(draftValue)) {
                        rowData[key] = value;
                    }
                    
                    infoToSubmit.push(rowData);
                }

            });
            console.log('infoToSubmit', infoToSubmit);
        }

        if(!this.isError) {
            this.bubbleEvent('receiptDetailsReady', infoToSubmit);
        }
    }
    
    showErrorNotification(errorMessage){
        this.isError = true;
        this.showNotification('Error!', errorMessage, 'error', 'dissmissible');
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