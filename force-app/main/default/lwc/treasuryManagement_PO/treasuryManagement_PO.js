import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORWARD_FOB_CONTRACT_OBJECT from '@salesforce/schema/Forward_FOB_Contract__c';
import CURRENCY_CODE_FIELD from '@salesforce/schema/Forward_FOB_Contract__c.Currency_Code__c';
import BANK_FIELD from '@salesforce/schema/Forward_FOB_Contract__c.Bank__c';
import processDataTable from '@salesforce/apex/TreasuryManagementController.construcDataTable';
import validateBuyContract from '@salesforce/apex/TreasuryManagementController.validateBuyContract';
import processBuyContract from '@salesforce/apex/TreasuryManagementController.processBuyContract';
import getRecordsByIds from '@salesforce/apex/TreasuryManagementController.getRecordsByIds';

var buyContractInputs = [
                            { label: 'Bank Contract No (Buy)', api: 'Bank_Contract_No__c', type: 'text', required: false },
                            { label: 'Currency Code', api: 'Currency_Code__c', options: [], isPicklist: true, required: false },
                            { label: 'Bank', api: 'Bank__c', options: [], isPicklist: true, required: false },
                            { label: 'Maturity Date', api: 'Maturity_Date__c', type: 'date', required: false },
                            { label: 'Effective Date (Buy)', api: 'Effective_Date__c', type: 'date', required: false },
                            { label: 'Bank Contract Amount', api: 'Bank_Contract_Amount__c', type: 'text', isNum: true, required: false },
                            { label: 'Spot Rate', api: 'Spot_Rate__c', type: 'text', isNum: true, required: false},
                            { label: 'Premium(+) / Discount(-)', api: 'Premium_Discount__c', type: 'text', isNum: true, required: false },
                            { label: 'Remarks', api: 'Remarks__c', isTextArea: true, required: false }
                        ];

export default class TreasuryManagement_PO extends LightningElement {
    @api objectApiName
    @api recordId;
    @api stocksDisplayFields;
    @api limitRec;
    @api
    get insertedFieldsFC() {
        return this.forwardContractFields;
    }
    set insertedFieldsFC(value) {
        this.forwardContractFields = value.split(',');
    }

    data                  = [];                             // Data to display in DataTable
    columns               = [];                             // Columns to display in DataTable
    rowOffset             = 0;
    enableInfiniteLoading = true;                           // To enable/disable infinite loading
    tableLoading          = false;                          // To determine DataTable is loading when infinite loading
    totalNumberOfRows;                                      // Total number of original records
    loadMoreStatus;                                         // Show loading status during infinite loading

    showModal;                                              // To show/hide modal
    spinner = false;
    showForwardContractDuty = true;

    recordInfo;                                             // To store current record info
    buyContractObjAPI;                                      // Name of Forward Contract object
    lineItemObjAPI;                                         // Name of Forward Contract Line Item object
    recordsCnt;                                             // Number of current records shown in UI
    selectedStocksCnt;                                      // Number of selected stocks in UI
    originalRecs          = [];                             // To store original data
    forwardContractFields = [];                             // Fields for new Forward Contract
    selectedStockIds      = [];                             // Selected Vehicle Stock Master record Ids
    selectedStocks        = [];                             // Selected Vehicle Stock Master records
    filterChanges         = {};
    changes               = {};                             // To track changes input fields

    buyContractInputs = buyContractInputs;

    connectedCallback()
    {
        getRecordsByIds({
            objNm: this.objectApiName,
            selectFields: ['Franchise__c'],
            fieldRef: 'Id',
            recIds: [this.recordId]
        }).then(result => {
            this.recordInfo     = result[0];

            let franchise       = this.recordInfo.Franchise__c;
            let defaultCoverPer = (franchise.startsWith('MIT') || franchise.startsWith('MAXUS')) ? 100 : 75;

            if (franchise.slice(-2) == 'CV')
            {
                this.showForwardContractDuty = false;
            }

            this.changes['Cover_Percentage__c'] = defaultCoverPer;
            this.changes['Purchase_Order__c']   = this.recordId;

        }).catch(error => {
            this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + error.body.message, null, 'error', 'sticky');
        })
    }

    @wire(getObjectInfo, { objectApiName: FORWARD_FOB_CONTRACT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: CURRENCY_CODE_FIELD
    }) getCurrencyCodePL({ data, error }) {
        if (data)
        {
            this.buyContractInputs.find(input => input.api == 'Currency_Code__c').options = data.values;
        }
        else if (error)
        {
            this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + error, null, 'error', 'sticky');
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: BANK_FIELD
    }) getBankPL({ data, error }) {
        if (data)
        {
            this.buyContractInputs.find(input => input.api == 'Bank__c').options = data.values;
        }
        else if (error)
        {
            this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + error, null, 'error', 'sticky');
        }
    }

    @wire(processDataTable, {
        parentRecId: '$recordId',
        targetObjNm: 'Vehicle_Master2__c',
        selectFieldsNm: '$stocksDisplayFields',
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
                else if (fdw.type == 'number')
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
            targetObjNm: 'Vehicle_Master2__c',
            selectFieldsNm: this.stocksDisplayFields,
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
            this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + error.body.message, null, 'error', 'sticky');
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
                if (rec[key] === undefined || rec[key] == this.filterChanges[key]) return true;
            }

            return true;
        });

        this.data = filteredRecs.slice(0, this.limitRec);

        this.flattenData(this.data, this.columns);

        this.setAttributesAfterFilter(filteredRecs.length, this.limitRec);
    }

    handleResetFilter()
    {
        this.selectedStockIds  = [];
        this.selectedStocks    = [];
        this.selectedStocksCnt = null;
        this.filterChanges     = {};

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
        let stockIds     = [];
        let selectedRows = event.detail.selectedRows;

        if (selectedRows.length > 0)
        {
            selectedRows.forEach(row => {
                stockIds.push(row.Id);
            })

            this.selectedStocks   = selectedRows;
            this.selectedStockIds = stockIds;
        }

        this.selectedStocksCnt = selectedRows.length;
    }

    openModal(event)
    {
        this.buyContractObjAPI = event.target.dataset.obj;
        this.lineItemObjAPI    = event.target.dataset.objLineItem;

        this.validate(this.buyContractObjAPI);
    }

    closeModal()
    {
        this.showModal = false;
    }

    validate(buyContractObjAPI)
    {
        if (!this.selectedStocksCnt)
        {
            this.toast('WARNING!', 'Please select Stocks!', null, 'warning', 'dismissible');

            return;
        }

        validateBuyContract({
            poId: this.recordId,
            buyContractObjAPI: buyContractObjAPI
        }).then(result => {
            if (result)
            {
                if (this.validateStocks(this.selectedStocks))
                {
                    this.showModal = true;
                }
            }
            else
            {
                this.toast('WARNING!', 'Active Forward Contract found. Please check again!', null, 'warning', 'dismissible');
            }
        }).catch(error => {
            this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + error.body.message, null, 'error', 'sticky');
        })
    }

    validateStocks(selectedStocks) {
        let msg        = '';
        let validStock = true;

        for (let stock of selectedStocks)
        {
            if (stock.Purchase_Order_Status__c && stock.Purchase_Order_Status__c == 'Completed')
            {
                msg        = 'Vehicles with Completed Purchase Order Status found. Please remove before proceeding!';
                validStock = false;

                break;
            }
            else if (this.buyContractObjAPI == 'Forward_FOB_Contract__c' && stock.FOB_Done__c)
            {
                msg        = 'Vehicles with Completed FOB Contract found. Please remove before proceeding!';
                validStock = false;

                break;
            }
            else if (this.buyContractObjAPI == 'Forward_Duty_Contract__c' && stock.Duty_Done__c)
            {
                msg        = 'Vehicles with Completed Duty Contract found. Please remove before proceeding!';
                validStock = false;
 
                break;
            }
            else if (this.buyContractObjAPI == 'Forward_Duty_Contract__c' && stock.Duty_Not_Covered__c == true && stock.Duty_Payment_Date__c !== null)
            {
                msg        = 'Can not Create Forward Contract Duty. Please check Duty Not Covered and Duty Payment Date';
                validStock = false;
 
                break;
            }
        }

        if (!validStock)
        {
            this.toast('WARNING!', msg, null, 'warning', 'dismissible');
        }

        return validStock;
    }

    validateInput()
    {
        let errMsg = '';

        for (let [key, value] of Object.entries(this.changes))
        {
            let inputEl = this.buyContractInputs.find(input => input.api == key);
 
            if (!inputEl)
            {
                continue;
            }

            if (inputEl.isNum && !this.isValidNum(value))
            {
                errMsg = inputEl.label + ' is not valid data. Please check again!';

                this.toast('WARNING!', errMsg, null, 'warning', 'sticky');

                return false;
            }

            if (inputEl.api == 'Spot_Rate__c' && Number(value) < 0)
            {
                errMsg = inputEl.label + ' must be greater and equal than 0. Please check again!';

                this.toast('WARNING!', errMsg, null, 'warning', 'sticky');

                return false;
            }
        }

        return true;
    }

    isValidNum(value) {
        const numRegex = /^-?\d+\.\d{0,7}$/;

        return (numRegex.test(Number(value)));
    }

    handleChange(event)
    {
        let apiFieldNm = event.target.name;
        let fieldVal   = event.target.value;

        this.changes[apiFieldNm] = fieldVal;
    }

    handleSubmit()
    {
        if (this.validateInput())
        {
            this.spinner = true;

            processBuyContract({
                buyContractInfo: this.changes,
                stockIds: this.selectedStockIds,
                buyContractObjAPI: this.buyContractObjAPI,
                lineItemObjAPI: this.lineItemObjAPI
            }).then(result => {
                this.spinner   = false;
                this.showModal = false;
    
                this.toast('SUCCESS!', 'Buy Forward Contract created successfully. Refreshing...', null, 'success', 'dismissible');

                window.setTimeout(() => { window.location.reload(); }, 2000)
            }).catch(error => {
                this.spinner = false;

                this.toast('ERROR!', 'Error occured. Please contact your Administrator! Error details: ' + error.body.message, null, 'error', 'sticky');
            })
        }
    }

    flattenData(records, columns) {
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

    toast(title, message, msgData, variant, mode)
    {
        const toastEvent = new ShowToastEvent({
           'title'       : title,
           'message'     : message,
           'messageData' : msgData,
           'variant'     : variant,
           'mode'        : mode
        });

        this.dispatchEvent(toastEvent);
    }

    deepClone(data)
    {
        return JSON.parse(JSON.stringify(data));
    }
}