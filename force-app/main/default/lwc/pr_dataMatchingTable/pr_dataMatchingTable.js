import { LightningElement, api } from 'lwc';
import { deepClone } from 'c/util';

const columns = [
    { label: 'Sales Agreement', fieldName: 'saName'},
    { label: 'Sales Invoice', fieldName: 'siName'},
    { label: 'Date', fieldName: 'salesInvoiceDate', type: 'date' },
    { label: 'Document Amount', fieldName: 'Document_Amount__c', type: 'currency' },
    { label: 'Outstanding Amount', fieldName: 'outstandingAmount', type: 'currency' },
    { label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency' },
];
export default class Pr_dataMatchingTable extends LightningElement {
    columns = columns;

    prliList
    @api
    get tableData() {
        return this.prliList;
    }
    
    set tableData(value) {
        this.prliList = value.map(si => ({
            saName: si.Sales_Agreement__r ? si.Sales_Agreement__r.Name : null,
            siName: si.Name,
            receiptDate: null,
            Sales_Agreement__c: si.Sales_Agreement__c,
            Sales_Invoice__c: si.Id,
            Document_Amount__c: 1000
        }))
    }
}