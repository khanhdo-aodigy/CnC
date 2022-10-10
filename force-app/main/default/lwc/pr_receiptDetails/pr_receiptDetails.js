import { LightningElement, api, track } from 'lwc';
import { deepClone } from 'c/util';

const columns = [
    { label: 'Sales Agreement', fieldName: 'salesAgreementName'},
    { label: 'Sales Invoice', fieldName: 'salesInvoiceName'},
    { label: 'Date', fieldName: 'invoiceDate', type: 'date' },
    // { label: 'Ref No', fieldName: 'refNo'  },
    { label: 'Document Amount', fieldName: 'documentAmount', type: 'currency' },
    { label: 'Outtanding Amount', fieldName: 'outstandingAmount', type: 'currency' },
    { label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency', editable: true },
];

const readOnlyColumns = [
    { label: 'Sales Agreement', fieldName: 'salesAgreementName'},
    { label: 'Sales Invoice', fieldName: 'salesInvoiceName'},
    { label: 'Date', fieldName: 'invoiceDate', type: 'date' },
    { label: 'Document Amount', fieldName: 'documentAmount', type: 'currency' },
    { label: 'Outtanding Amount', fieldName: 'outstandingAmount', type: 'currency'},
    { label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency'},
];

const customColumns = [
    { label: 'Sales Agreement', fieldName: 'salesAgreementName'},
    { label: 'Sales Invoice', fieldName: 'salesInvoiceName'},
    { label: 'Document Amount', fieldName: 'documentAmount'},
    { label: 'Outtanding Amount', fieldName: 'outstandingAmount' },
    { label: 'Payment Amount', fieldName: 'paymentAmount' },
];

const enterAlcAmtErrMsg = 'Please enter Allocated Amount for selected Debtor Ledger Line Item(s)';

export default class Pr_receiptDetails extends LightningElement {
    columns = readOnlyColumns;
    customColumns = customColumns;
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
        if(this.receiptAmt && this.receiptAmount> 0) {
            this.allowEdit = true;
        } else {
            this.allowEdit = false;
        }
    }
    

    tableData = [];
    @track customTableData = [];
    receiptDetails = [];
    allowEdit = false;

    @api receiptDate;
    @api
    get rawData() {
        return this.tableData;
    }

    set rawData(sa) {
        if(sa) {
            if(sa.Sales_Invoices__r) {

                sa.Sales_Invoices__r.forEach(si => {

                    const props = [
                        {
                            fieldName: 'salesAgreementName',
                            fieldValue: sa.Name,
                            editable: false
                        },
                        {
                            fieldName: 'salesInvoiceName',
                            fieldValue: si.Name,
                            editable: false
                        },
                        {
                            fieldName: 'documentAmount',
                            fieldValue: sa.Vehicle_Purchase_Price__c,
                            editable: false
                        },
                        {
                            fieldName: 'outstandingAmount',
                            fieldValue: si.Invoice_Value__c,
                            editable: false
                        }
                    ]

                                        
                    this.customTableData.push({
                        key: si.Id,
                        props: props
                    });
                })

                this.receiptDetails = sa.Sales_Invoices__r.map(si => (
                    
                    {
                        salesAgreementId   : sa.Id,
                        salesInvoiceId     : si.Id,
                        documentAmount     : sa.Vehicle_Purchase_Price__c,
                        outstandingAmount  : sa.BalancePayment__c,
                        key           : si.Id,
                    }
                ));
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
                this.customTableData = {
                    key: sa.Id,
                    props: [
                        {
                            fieldName: 'salesAgreementName',
                            fieldValue: sa.Name,
                            disabled: true
                        },
                        {
                            fieldName: 'documentAmount',
                            fieldValue: sa.Vehicle_Purchase_Price__c,
                            disabled: true
                        },
                        {
                            fieldName: 'outstandingAmount',
                            fieldValue: si.Invoice_Value__c,
                            disabled: true
                        }
                    ]
                };

                this.receiptDetails =  [{
                    salesAgreementId   : sa.Id,
                    documentAmount     : sa.Vehicle_Purchase_Price__c,
                    outstandingAmount  : sa.BalancePayment__c,
                    key           : sa.Id,
                }];

                const rowData = [{
                    salesAgreementId   : sa.Id,
                    salesAgreementName : sa.Name,
                    documentAmount     : sa.Vehicle_Purchase_Price__c,
                    outstandingAmount  : sa.BalancePayment__c,
                    receiptDate        : this.receiptDate,
                    keyField           : sa.Id,
                }]
                this.tableData = rowData;
            }
        }     
        console.log('tableData', this.tableData);        
    }

    renderedCallback() {        
        // this.template.querySelector('div[data-id="result"]').scrollIntoView();

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
        console.log(event);
        console.log(event.target.name);
        console.log(event.target.value);
        console.log(event.target.dataset.key);
        this.calculateAmounts();

        if(event.target.name == 'paymentAmt'){
            let recordKey = event.target.dataset.key;
            let recordIdx = this.receiptDetails.findIndex((obj => obj.key == recordKey));
            this.receiptDetails[recordIdx].paymentAmount = event.target.value
        }
        

        
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