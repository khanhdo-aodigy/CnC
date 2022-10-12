import { LightningElement, api, track } from 'lwc';
import { deepClone } from 'c/util';

const columns = [
    { label: 'Sales Agreement', fieldName: 'salesAgreementName'},
    { label: 'Sales Invoice', fieldName: 'salesInvoiceName'},
    { label: 'Document Amount', fieldName: 'documentAmount'},
    { label: 'Outtanding Amount', fieldName: 'outstandingAmount' },
    { label: 'Payment Amount', fieldName: 'paymentAmount' },
];

const enterAlcAmtErrMsg = 'Please enter Allocated Amount for selected Debtor Ledger Line Item(s)';

export default class Pr_receiptDetails extends LightningElement {
    columns = columns;
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
        if(this.receiptAmt && this.receiptAmount > 0) {
            this.allowEdit = true;
        } else {
            this.allowEdit = false;
        }
    }
    

    @track tableData = [];
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

                                        
                    this.tableData.push({
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
                this.receiptDetails.push(
                    {
                        key: "unallocated",
                        salesAgreementId   : null,
                        salesInvoiceId     : null
                    }
                )
            } else {
                this.tableData.push({
                    key: sa.Id,
                    props: [
                        {
                            fieldName: 'salesAgreementName',
                            fieldValue: sa.Name,
                            editable: false
                        },
                        {
                            fieldName: 'salesInvoiceName',
                            fieldValue: '',
                            editable: false
                        },
                        {
                            fieldName: 'documentAmount',
                            fieldValue: sa.Vehicle_Purchase_Price__c,
                            editable: false
                        },
                        {
                            fieldName: 'outstandingAmount',
                            fieldValue: sa.BalancePayment__c,
                            editable: false
                        }
                    ]
                });

                this.receiptDetails =  [
                    {
                        salesAgreementId   : sa.Id,
                        documentAmount     : sa.Vehicle_Purchase_Price__c,
                        outstandingAmount  : sa.BalancePayment__c,
                        key                : sa.Id,
                    },
                    {
                        key: "unallocated",
                        salesAgreementId   : null,
                        salesInvoiceId     : null
                    }
                ];

            }
        }     
    }

    renderedCallback() {        
        // this.template.querySelector('div[data-id="result"]').scrollIntoView();

        
    }

    onValueChanged(event){
        if(parseFloat(event.target.value) > parseFloat(this.receiptAmount)) {
            this.showErrorNotification('Allocated Amount should not be greater than Receipt Amount');
        }

        if(event.target.name == 'paymentAmt' || event.target.name == 'unallocatedAmt'){
            let recordKey = event.target.dataset.key;
            let recordIdx = this.receiptDetails.findIndex((obj => obj.key == recordKey));
            this.receiptDetails[recordIdx].paymentAmount = event.target.value;
        }

        console.log(deepClone(this.receiptDetails));
        
        this.calculateAmounts();
        
    }

    calculateAmounts() {
        let allocatedAmtArray = []; 
        this.receiptDetails.forEach(record => {
            let allocatedAmt = parseFloat(record.paymentAmount);
            if(!isNaN(allocatedAmt) && allocatedAmt) {
                if(allocatedAmt > parseFloat(record.outstandingAmount)) {
                    this.showErrorNotification('Allocated Amount should not be greater than Outstanding Amount');
                }
                allocatedAmtArray.push(allocatedAmt);
            }
        });

        this.totalAmt = allocatedAmtArray.reduce((accumulator, value) => {
            return accumulator + value;
        }, 0);

        if(this.totalAmt > this.receiptAmt) {
            this.showErrorNotification('Total Payment Amount is exceeded Receipt Amount');
        }

        this.balanceAmt = this.receiptAmt - this.totalAmt;
        
    }

    @api
    createReceiptDetails() { 
        this.isError = false;
        
        let unallocatedAmount = parseFloat(this.receiptDetails[this.receiptDetails.length - 1].paymentAmount);
        if(isNaN(unallocatedAmount)) {
            this.receiptDetails.pop();
        };

        if(this.totalAmt === 0) {
            this.showErrorNotification('Please enter Payment Amount to be allocated');
        } else if(parseFloat(this.totalAmt) > parseFloat(this.receiptAmt)) {
            this.showErrorNotification('Total Payment Amount is exceeded Receipt Amount');
        } else if(parseFloat(this.totalAmt) < parseFloat(this.receiptAmt)) {
            this.showErrorNotification('Total Payment Amount must be equal to Receipt Amount');
        }

        if(!this.isError) {
            console.log('before submit', this.receiptDetails);
            this.bubbleEvent('receiptDetailsReady', this.receiptDetails);
        }
    }
    
    showErrorNotification(errorMessage){
        this.isError = true;
        this.showNotification('Error!', errorMessage, 'error', 'dissmissible');
        this.bubbleEvent('cancelReceiptCreation');
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