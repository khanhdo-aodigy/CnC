import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processDataTable from '@salesforce/apex/TreasuryManagementController.construcDataTable';
import getRecordsByIds from '@salesforce/apex/TreasuryManagementController.getRecordsByIds';
import processAddnlContract from '@salesforce/apex/TreasuryManagementController.processAddnlContract';

var today               = new Date();
var date                = today.getFullYear() + '-' + (today.getMonth()+1) + '-' + today.getDate();
var addnlContractInputs =   [
                                { label: 'Status', api: 'Status__c', isPicklist: true, options: [
                                                                                                    { label: 'Forward Contract Execute', value: 'Forward Contract Execute' },
                                                                                                    { label: 'Forward Contract Sell', value: 'Forward Contract Sell' },
                                                                                                    { label: 'Forward Contract Duty Sale', value: 'Forward Contract Duty Sale' },
                                                                                                    { label: 'PO Cancellation', value: 'PO Cancellation' },
                                                                                                ], value: null, required: false },
                                { label: 'Bank Contract No (Sell/Execute)', api: 'Bank_Contract_No_Sell_Execute__c', type: 'text', isPicklist: false, value: null, required: false },
                                { label: 'Effective Date (Sell/Execute)', api: 'Effective_Date_Sell_Execute__c', type: 'date', isPicklist: false, value: null, required: false },
                                { label: 'Transaction Date (Sell/Execute)', api: 'Transaction_Date_Sell_Execute__c', type: 'date', isPicklist: false, value: date, required: false },
                                { label: 'Spot Rate (Sell/Execute)', api: 'Spot_Rate_Sell_Execute__c', type: 'text', isPicklist: false, value: null, required: false },
                            ];

var stageFilterOptions  =   [
                                { label: 'Forward Contract Buy', value: 'Forward Contract Buy' },
                                { label: 'Forward Contract Execute', value: 'Forward Contract Execute' },
                                { label: 'Forward Contract Sell', value: 'Forward Contract Sell' },
                                { label: 'Forward Contract Duty Sale', value: 'Forward Contract Duty Sale' },
                                { label: 'Spot Rate Contract', value: 'Spot Rate Contract' },
                                { label: 'Completed', value: 'Completed' },
                                { label: 'PO Cancellation', value: 'PO Cancellation' }
                            ];

var vehStatusFilterOptions  =   [
                                    { label: 'FREE', value: 'FREE' },
                                    { label: 'ORD', value: 'ORD' },
                                    { label: 'SCL', value: 'SCL' },
                                    { label: 'RESRV', value: 'RESRV' },
                                    { label: 'ALLOC', value: 'ALLOC' },
                                    { label: 'SOLD', value: 'SOLD' },
                                    { label: 'CONF', value: 'CONF' }
                                ];

export default class TreasuryManagement_FC extends LightningElement {
    @api objectApiName;
    @api recordId;                                                  // Id of current Forward FOB/Duty Contract record
    @api objNm;                                                     // Target object name to be queried
    @api fieldsToDisplay;                                           // Forward Contract Line Item fields
    @api limitRec;                                                  // Number of maximum records to display each scroll

    columns               = [];
    data                  = [];
    rowOffset             = 0;
    offSetCount           = 0;
    enableInfiniteLoading = true;
    tableLoading          = false;
    totalNumberOfRows;
    loadMoreStatus;

    showModal;
    spinner = false;

    recordInfo;                                                 // To store current record detail
    recordsCnt;                                                 // Number of current shown records in UI
    selectedLineItemsCnt;                                       // Number of selected Forward Contract Line Item records
    originalRecs        = [];                                   // To store original records of DataTable
    selectedLineItemIds = [];                                   // Selected Forward Contract Line Item record Ids
    selectedLineItems   = [];                                   // Selected Forward Contract Line Item records
    filterChanges       = {};
    changes             = {};                                   // To track changes input fields
    isDisabledModal     = false;
    isFOBContractPage   = false;
    isDutyContractPage  = false;

    addnlContractInputs    = addnlContractInputs;
    stageFilterOptions     = stageFilterOptions;
    vehStatusFilterOptions = vehStatusFilterOptions;

    connectedCallback() {
        getRecordsByIds({
            objNm: this.objectApiName,
            selectFields: ['Forward_Contract_Buy_Approved__c','Spot_Rate__c','Status__c'],
            fieldRef: 'Id',
            recIds: [this.recordId]
        }).then(result => {
            this.recordInfo      = result[0];

            this.isDisabledModal = this.recordInfo.Status__c == 'Annulled';

            this.defaultInputValues(this.recordInfo, this.addnlContractInputs);

            let tmpInputOptions = [];
    
            switch (this.objectApiName)
            {
                case 'Forward_Duty_Contract__c':
                    this.isDutyContractPage = true;

                    tmpInputOptions = this.removeByAttr(this.addnlContractInputs.find(input => input.api == 'Status__c').options, 'value', ['Forward Contract Execute']);

                    this.stageFilterOptions = this.removeByAttr(this.stageFilterOptions, 'value', ['Forward Contract Execute', 'Spot Rate Contract']);

                    break;
                case 'Forward_FOB_Contract__c':
                    this.isFOBContractPage = true;

                    tmpInputOptions = this.removeByAttr(this.addnlContractInputs.find(input => input.api == 'Status__c').options, 'value', ['Forward Contract Duty Sale']);

                    this.stageFilterOptions = this.removeByAttr(this.stageFilterOptions, 'value', ['Forward Contract Duty Sale']);

                    break;
                default:
                    break;
            }

            this.addnlContractInputs.find(input => input.api == 'Status__c').options = tmpInputOptions;
        }).catch(error => {
            this.toast('ERROR!', 'Error occured: ' + error.body.message, null, 'sticky');
        })
    }


    @wire(processDataTable, {
        parentRecId: '$recordId',
        targetObjNm: '$objNm',
        selectFieldsNm: '$fieldsToDisplay',
        currentRecId: null,
        addnlCondition: ''
    })wiredResult(result) {
        result.error && this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + result.error.body.message, null, 'error', 'sticky');
 
        if (result.data)
        {
            this.originalRecs    = this.deepClone(result.data.sobList);
            let fieldDescWrapper = this.deepClone(result.data.fdwList);
 
            for (let fdw of fieldDescWrapper)
            {
                let typeAttributes = {};
                let cellAttributes = {};

                if (fdw.fieldName == 'Name')
                {
                    fdw.type = 'url';
                }

                if (fdw.type == 'url')
                {
                    let tmpLabel  = fdw.label.replace(/ /g,'');
                    fdw.fieldName = tmpLabel + 'Url';

                    typeAttributes.label  = { fieldName: tmpLabel };
                    typeAttributes.target = '_blank';
 
                    fdw.typeAttributes = typeAttributes;
                }
 
                if (fdw.type == 'number')
                {
                    typeAttributes.minimumFractionDigits = 2;
                    typeAttributes.maximumFractionDigits = 2;

                    cellAttributes.alignment = 'left';

                    fdw.typeAttributes = typeAttributes;
                    fdw.cellAttributes = cellAttributes;
                }
            }
 
            this.columns = fieldDescWrapper;
            this.data    = this.originalRecs.slice(0, this.limitRec);

            this.flattenData(this.data, this.columns);

            if (this.originalRecs.length > this.limitRec)
            {
                this.recordsCnt = this.limitRec + '+';
            }
            else
            {
                this.recordsCnt            = this.originalRecs.length;
                this.enableInfiniteLoading = false;
                this.loadMoreStatus        = 'No more data to load';
            }
 
            this.totalNumberOfRows = result.data.totalCount;
        }
    }

    loadMoreData()
    {
        this.tableLoading  = true;
        let addnlCondition = '';

        if (Object.keys(this.filterChanges).length != 0)
        {
            for (const [key, value] of Object.entries(this.filterChanges))
            {
                addnlCondition += ' OR '  + `${key} = ${value}`;
            }
        }

        let currentRecord = Array.from(this.data);
        let lastRecId     = currentRecord[currentRecord.length - 1].Id;

        processDataTable({
            parentRecId: this.recordId,
            targetObjNm: this.objNm,
            selectFieldsNm: this.fieldsToDisplay,
            limitSize: this.limitRec,
            currentRecId: lastRecId,
            addnlCondition: addnlCondition
        }).then(result => {
            if (this.data.length >= this.totalNumberOfRows || this.data.length >= result.totalCount)
            {
                this.recordsCnt            = this.recordsCnt.replace('+' , '');
                this.enableInfiniteLoading = false;
                this.loadMoreStatus        = 'No more data to load';
            }
            else
            {
                let loadMoreRecs    = this.deepClone(result.sobList);
                let newRecs         = currentRecord.concat(loadMoreRecs);
                this.data           = newRecs;
                this.recordsCnt     = this.data.length + '+';
                this.loadMoreStatus = '';

                this.flattenData(this.data, this.columns);
            }

            this.tableLoading = false;
        }).catch(error => {
            this.toast('ERROR', 'Error occured. Please contact your Administrator! Error details: ' + result.error.body.message, null, 'error', 'sticky');
        })
    }
   
    handleFilter(event)
    {
        let apiFieldNm = event.target.name;
        let val        = event.target.checked || event.target.value;

        this.filterChanges[apiFieldNm] = val;

        let addnlFilters = this.template.querySelectorAll("[data-id='filters']");
 
        for (let filter of addnlFilters)
        {
            this.filterChanges[filter.name] = filter.value || filter.checked;
        }

        let filteredRecs = this.originalRecs.filter(rec => {
            for (let key in this.filterChanges)
            {
                if (key == 'ETA_Date__c' && (this.filterChanges[key] == Boolean(rec.ETA_Date__c)))
                {
                    return true;
                }
                if (key == 'Duty_Payment_Date__c' && (this.filterChanges[key] == Boolean(rec.Duty_Payment_Date__c)))
                {
                    return true;
                }
                if ((key != 'ETA_Date__c' && key != 'Duty_Payment_Date__c') &&
                    (rec[key] === undefined || rec[key] == this.filterChanges[key]))
                {
                    return true;
                }
            }

            return false;
        });

        this.data = filteredRecs.slice(0, this.limitRec);

        this.flattenData(this.data, this.columns);

        this.setAttributesAfterFilter(filteredRecs.length, this.limitRec);
    }

    handleResetFilter()
    {
        this.selectedLineItemIds  = [];
        this.selectedLineItems    = [];
        this.filterChanges        = {};
        this.selectedLineItemsCnt = null;

        let filters = this.template.querySelectorAll('[data-id="filters"]');
 
        for (let filter of filters)
        {
            filter.checked = false;
            filter.value   = null;
        }

        this.data = this.originalRecs.slice(0, this.limitRec);

        this.flattenData(this.data, this.columns);

        if (this.data.length >= this.originalRecs.length)
        {
            this.recordsCnt            = this.data.length;
            this.enableInfiniteLoading = false;
            this.loadMoreStatus        = 'No more data to load';
        }
        else
        {
            this.recordsCnt            = this.data.length + '+';
            this.enableInfiniteLoading = true;
            this.loadMoreStatus        = '';
        }
    }

    getSelectedRow(event)
    {
        let lineItemIds  = [];
        let selectedRows = event.detail.selectedRows;
 
        if (selectedRows.length > 0)
        {
            selectedRows.forEach(row => {
                lineItemIds.push(row.Id);
            })
 
            this.selectedLineItems   = selectedRows;
            this.selectedLineItemIds = lineItemIds;
        }
 
        this.selectedLineItemsCnt = selectedRows.length;
    }

    openModal()
    {
        if (this.validateBeforeSubmit())
        {
            this.showModal = true;
        }
    }

    closeModal()
    {
        this.showModal = false;
    }

    validateBeforeSubmit()
    {
        let isValidated = true;

        if (this.selectedLineItemsCnt == 0 || this.selectedLineItemsCnt == undefined  || this.selectedLineItemsCnt == null)
        {
            this.toast('WARNING', 'Please choose Forward Contract Line Items!', null, 'warning', 'dismissible');

            isValidated = false;

            return isValidated;
        }

        if (!this.recordInfo.Forward_Contract_Buy_Approved__c)
        {
            this.toast('WARNING', 'Forward Contract Buy has not been approved. Please check again!', null, 'warning', 'dismissible');

            isValidated = false;

            return isValidated;
        }

        this.selectedLineItems.forEach(item => {
            if (item.FOB_Additional_Contract__c || item.Duty_Additional_Contract__c)
            {
                this.toast('WARNING', 'Line Items has been processed. Please remove before proceeding!', null, 'warning', 'dismissible');

                isValidated = false;

                return isValidated;
            }
        })

        return isValidated;
    }

    validateSubmit(contractStatus, selectedLineItems)
    {
        let isValidated = true;

        selectedLineItems.forEach(item => {
            if (contractStatus == 'Forward Contract Execute' && !item.ETA_Date__c)
            {
                this.toast('WARNING', 'Items must have ETA Date for Execute Contract. Please check again!', null, 'warning', 'dismissible');

                isValidated = false;

                return isValidated;
            }
            else if (contractStatus == 'PO Cancellation' && item.Vehicle_Status__c != 'SCL')
            {
                this.toast('WARNING', 'Items must have SCL Vehicle Status for PO Cancellation Contract. Please check again!', null, 'warning', 'dismissible');

                isValidated = false;

                return isValidated;
            }
            else if (contractStatus == 'Forward Contract Duty Sale' && !item.Duty_Payment_Date__c)
            {
                this.toast('WARNING', 'Items must have Duty Payment Date for Duty Sale Contract. Please check again!', null, 'warning', 'dismissible');

                isValidated = false;

                return isValidated;
            }
        })

        return isValidated;
    }

    handleChange(event)
    {
        let apiFieldNm = event.target.name;
        let fieldVal   = event.target.value;
 
        this.changes[apiFieldNm] = fieldVal;
    }

    handleSubmit()
    {
        if (this.changes && this.validateSubmit(this.changes['Status__c'], this.selectedLineItems))
        {
            this.spinner = true;

            processAddnlContract({
                addnlContractInfo: this.changes,
                lineItemIds: this.selectedLineItemIds,
                lineItemObjAPI: this.objNm, 
                contractId: this.recordId
            }).then(result => {
                this.spinner   = false;
                this.showModal = false;

                this.toast('SUCCESS!', 'Updated successfully. Refreshing...', null, 'success', 'dismissible');

                window.setTimeout(() => { window.location.reload(); }, 2000)                
            }).catch(error => {
                this.spinner = false;

                this.toast('ERROR', 'Error occured during Sell/Execute Forward Contract: ' + error.body.message, null, 'error', 'dismissible')
            })
        }
    }

    flattenData(records, columns)
    {
        records.forEach(rec => {
            columns.forEach(column => {
                if (column.type == 'url')
                {
                    let fieldNm = column.typeAttributes.label.fieldName;

                    if (!column.isReferencedField)
                    {
                        rec[fieldNm]          = rec.Name;
                        rec[column.fieldName] = '/' + rec.Id;
                    }
                    else
                    {
                        let fieldRefNm = column.label.replace(/ /g,'_') + '__r';
                        let tmpRefObj  = Object.assign({}, rec[fieldRefNm]);

                        if (Object.keys(tmpRefObj).length != 0)
                        {
                            rec[fieldNm]          = tmpRefObj.Name;
                            rec[column.fieldName] = '/' + tmpRefObj.Id;
                        }
                    }
                }
                else if (column.isReferencedField)
                {
                    let relNm            = column.fieldName.split('.')[0];
                    let lookupFieldAPINm = column.fieldName.split('.')[1];
                    let tmpRefObj        = Object.assign({}, rec[relNm]);

                    if (Object.keys(tmpRefObj).length != 0)
                    {
                        rec[column.fieldName] = tmpRefObj[lookupFieldAPINm];
                    }
                }
            })
        })
    }

    setAttributesAfterFilter(filteredRecsLength, maxNumOfRecDisplay)
    {
        if (filteredRecsLength <= maxNumOfRecDisplay)
        {
            this.recordsCnt            = this.data.length;
            this.enableInfiniteLoading = false;
            this.loadMoreStatus        = 'No more data to load';
        }
        else
        {
            this.recordsCnt            = this.data.length + '+';
            this.enableInfiniteLoading = true;
            this.loadMoreStatus        = '';
        }
    }

    defaultInputValues(record, inputs)
    {
        inputs.forEach(input => {
            if (input.api !== 'Spot_Rate_Sell_Execute__c' && input.api !== 'Transaction_Date_Sell_Execute__c')
            {
                return;
            }

            if (input.api == 'Spot_Rate_Sell_Execute__c')
            {
                input.value = record.Spot_Rate__c;
            }

            this.changes[input.api] = input.value;
        });
    }

    removeByAttr(arr, attr, values)
    {
        for (let i = 0; i < arr.length; i++)
        {
            for (let val of values)
            {
                if (arr[i][attr] == val) arr.splice(i, 1);
            }
        }

        return this.deepClone(arr);
    }

    toast(title, message, msgData, variant, mode)
    {
        const toastEvent = new ShowToastEvent({
           'title' : title,
           'message' : message,
           'messageData' : msgData,
           'variant' : variant,
           'mode' : mode
        });
        this.dispatchEvent(toastEvent);
    }

    deepClone(data)
    {
        return JSON.parse(JSON.stringify(data));
    }
}