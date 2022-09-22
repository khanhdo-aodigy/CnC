import { LightningElement, track, wire, api } from 'lwc';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import COEBIDMC_CHANNEL from '@salesforce/messageChannel/COEBIDMC__c';
import saveDSA from '@salesforce/apex/COEBiddingController.saveInputData';
import submitForCOEBidding from '@salesforce/apex/COEBiddingController.submitForCOEBidding';
import retrieveDSAsForBidding from '@salesforce/apex/COEBiddingController.retrieveDSAsForBidding';
import calculateFieldsPresave from '@salesforce/apex/COEBiddingController.calculateFieldsPresave';
import sendEmailToBSD from '@salesforce/apex/COEBiddingController.sendEmailToBSD';
import getBidCategoryValue from '@salesforce/apex/COEBiddingController.getBidCategoryValue';
import { deepClone } from 'c/util';
import sendEmailToSC from '@salesforce/apex/COEBiddingController.sendEmailToSC';
import USER_ID from '@salesforce/user/Id';

export default class CoeBidCreation extends LightningElement {

    headers = [
        { 'key': 'Name', 'label': 'Agreement No.' },
        { 'key': 'Verified_by_Sales_Consultant__c', 'label': 'Verified by SC' },
        { 'key': 'Submit_COE_Bidding__c', 'label': 'Submitted for COE Bidding' },
        { 'key': 'COECategory__c', 'label': 'COE Category' },
        { 'key': 'Agreement_Date__c', 'label': 'Agreement Date' },
        { 'key': 'Sales_Consultant__c', 'label': 'Sales Consultant' },
        { 'key': 'Model__c', 'label': 'Car Model' },
        { 'key': 'JIT_Date__c', 'label': 'JIT Date' },
        { 'key': 'NRIC_Number__c', 'label': 'NRIC' },
        { 'key': 'Customer_Full_Name__c', 'label': 'Customer\'s Name' },
        { 'key': 'RSP_And_Paid_Accessories__c', 'label': 'RSP & Paid Accessories' },
        { 'key': 'Promo_Discount__c', 'label': 'Special Discount' },
        { 'key': 'Accessories_Discount__c', 'label': 'Accessories Discount' },
        { 'key': 'Net_Transaction_Price__c', 'label': 'Net Transaction Price' },
        { 'key': 'Stock_Reservation__r.Vehicle_Master__r.Vehicle_Type_For_Sale__c', 'label': 'Stock Status' },
        { 'key': 'ARF_Payable__c', 'label': 'ARF Payable' },
        { 'key': 'Vehicle_Cost__c', 'label': 'Vehicle Cost' },
        { 'key': 'GMS_Package__c', 'label': 'GMS' },
        { 'key': 'Additional_Charges__c', 'label': 'Additional Charges' },
        { 'key': 'Detail_Additional_Charges', 'label': 'Detail - Additional Charges' },
        { 'key': 'Cost_of_Standard_Accessories__c', 'label': 'Cost of Standard Accessories' },
        { 'key': 'Cost_of_Accessories_Traded_Sold__c', 'label': 'Cost of Accessories Traded/Sold' },
        { 'key': 'Detail_Cost_of_Accessories_Traded_Sold', 'label': 'Detail - Cost of Accessories Traded/Sold' },
        { 'key': 'GST_Charge__c', 'label': 'GST' },
        { 'key': 'Proposed_Commission__c', 'label': 'SC Comm' },
        { 'key': 'CPF_on_Comm_for_COE__c', 'label': 'CPF on Comm' },
        { 'key': 'COEThresHold__c', 'label': 'COE Threshold' },
        { 'key': 'Bid_Category__c', 'label': 'Category' },
        { 'key': 'Bid_Price__c', 'label': 'Bid Price' },
        { 'key': 'COE_Package__c', 'label': 'COE N/NG' },
        { 'key': 'Expected_Delivery_Month__c', 'label': 'Expected Delivery Month' },
        { 'key': 'COE_Charged_Rebate__c', 'label': 'COE Rebate' },
        { 'key': 'Amount_to_Finance__c', 'label': 'Finance Amount' },
        { 'key': 'Loan_Approval_Status__c', 'label': 'Loan Status' },
        { 'key': 'Finance_Company__c', 'label': 'Loan Approver Name' },
        { 'key': 'COE_Submission_Date__c', 'label': 'Submitted Date' },
        { 'key': 'Bid_1_Amount__c', 'label': '1ST' },
        { 'key': 'Bid_2_Amount__c', 'label': '2ND' },
        { 'key': 'Bid_3_Amount__c', 'label': '3RD' },
        { 'key': 'Bid_4_Amount__c', 'label': '4TH' },
        { 'key': 'Bid_5_Amount__c', 'label': '5TH' },
        { 'key': 'Bid_6_Amount__c', 'label': '6TH' },
        { 'key': 'Bid_7_Amount__c', 'label': '7TH' },
        { 'key': 'Bid_8_Amount__c', 'label': '8TH' },
        { 'key': 'Bid_9_Amount__c', 'label': '9TH' },
        { 'key': 'Bid_10_Amount__c', 'label': '10TH' },
        { 'key': 'Bid_11_Amount__c', 'label': '11TH' },
        { 'key': 'Bid_12_Amount__c', 'label': '12TH' }
    ]

    categories = [
        { label: 'A1', value: 'A1' },
        { label: 'A2', value: 'A2' },
        { label: 'A3', value: 'A3' },
        { label: 'A4', value: 'A4' },
        { label: 'B1', value: 'B1' },
        { label: 'B2', value: 'B2' },
        { label: 'B3', value: 'B3' },
        { label: 'B4', value: 'B4' },
        { label: 'C1', value: 'C1' },
        { label: 'C2', value: 'C2' },
        { label: 'C3', value: 'C3' },
        { label: 'C4', value: 'C4' },
        { label: 'E1', value: 'E1' },
        { label: 'E2', value: 'E2' },
        { label: 'E3', value: 'E3' },
        { label: 'E4', value: 'E4' }
    ];
    dataForTable = [];
    changedDSAs = [];
    dsaRecs = [];

    bidPeriodId;
    franchise;
    exchangeRateUSD;
    exchangeRateJPY;
    exchangeRateEUR;
    exchangeRateRMB;
    directCost;
    reCalculate = false;
    bidPeriodStartDate;
    bidPeriodEndDate
    remarks;
    branch;
    userId = USER_ID;

    @track filters = {
        category: null,
        guaranteeStatus: null,
        svmStatus: null,
        approvalStatus: null,
        submitStatus: null,
        bidCategory: null
    };

    @track disabledSubmitCOE = false;
    @track spinner = false;
    @track isReady = false;

    @track disableSave = false;
    @track disableSubmit = false;

    @wire(MessageContext)
    messageContext;


    selectedSAIds = [];

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    subscribeToMessageChannel() {
        if (this.subscription) return;

        this.subscription = subscribe(this.messageContext, COEBIDMC_CHANNEL, (message) => {
            this.handleMessage(message);
        }
        );
    }

    handleMessage(message) {
        let _message = deepClone(message);
        let action = _message.action;
        console.log(_message);
        switch (action) {
            case 'retrieve':
                this.clearSearchFilter();
                const {
                    coeBidPeriodId,
                    franchise,
                    reCalculate,
                    exchangeRateUSD,
                    exchangeRateJPY,
                    exchangeRateEUR,
                    exchangeRateRMB,
                    directCost,
                    bidPeriodStartDate,
                    bidPeriodEndDate,
                    dsaForCOEBidding
                } = _message.data

                this.bidPeriodId = coeBidPeriodId;
                this.franchise = franchise;
                this.reCalculate = reCalculate;
                this.exchangeRateUSD = exchangeRateUSD;
                this.exchangeRateJPY = exchangeRateJPY;
                this.exchangeRateEUR = exchangeRateEUR;
                this.exchangeRateRMB = exchangeRateRMB;
                this.directCost = directCost;
                this.bidPeriodStartDate = bidPeriodStartDate;
                this.bidPeriodEndDate = bidPeriodEndDate;
                this.dsaRecs = dsaForCOEBidding;

                if (this.franchise.startsWith('KIA')) {
                    this.branch = 'KIA';
                } else if (this.franchise.startsWith('CIT')) {
                    this.branch = 'CIT';
                } else if (this.franchise.startsWith('MIT')) {
                    this.branch = 'MIT';
                } else if (this.franchise.startsWith('MAXUS')) {
                    this.branch = 'MAXUS';
                }

                this.processDataForTable(this.dsaRecs);

                break;
            default:
                break;
        }
    }

    async handleCalculation(recs) {
        console.log('*** handleCalculation');
        return calculateFieldsPresave({
            dsaList: recs,
            branch: this.branch,
            otherDirectCost: this.otherDirectCost,
            exchangeRateUSD: this.exchangeRateUSD,
            exchangeRateEUR: this.exchangeRateEUR,
            exchangeRateJPY: this.exchangeRateJPY,
            exchangeRateRMB: this.exchangeRateRMB
        })
    }

    sortDSA(calculatedValues) {
        let temp = [];
        for (let [saId, fieldValue] of Object.entries(calculatedValues)) {
            temp.push({ 'Id': saId, 'COEThresHold__c': fieldValue['COEThresHold__c'] });
        }
        return temp.sort((a, b) => b['COEThresHold__c'] - a['COEThresHold__c']).map(rec => rec.id)
    }

    async processDataForTable(result) {
        this.changedDSAs = [];
        this.selectedSAIds = [];
        let _calculatedValues;
        if (this.reCalculate) {
            _calculatedValues = await this.handleCalculation(result);
            console.log('_calculatedValues', _calculatedValues);

            let _orderredSAIds = this.sortDSA(_calculatedValues);
            console.log(_orderredSAIds);

            result.sort((a, b) => {
                const aId = a.Id;
                const bId = b.Id;
                return _orderredSAIds.indexOf(aId) - _orderredSAIds.indexOf(bId);
            })

        }
        let cnt = 0;
        let _dataForTable = [];
        for (let data of result) {
            cnt++;
            let saId = data['Id'];
            let records_ = [];

            let _mapFieldValue = new Map();
            if (this.reCalculate) {
                _mapFieldValue = _calculatedValues[saId];
            }
            _mapFieldValue['Other_Direct_Cost__c'] = this.directCost;
            this.updateChangedDSAs(saId, _mapFieldValue);

            for (let meta of this.headers) {
                let rec_ = {};
                rec_.api = meta.key;
                if(meta.key == 'Stock_Reservation__r.Vehicle_Master__r.Vehicle_Type_For_Sale__c' && 'Stock_Reservation__r' in data && 'Vehicle_Master__r' in data['Stock_Reservation__r']) {
                    rec_.value = data['Stock_Reservation__r']['Vehicle_Master__r']['Vehicle_Type_For_Sale__c'];
                }
                // else if(meta.key.includes('.')) {
                //     let path = meta.key.split('.');
                //     let endValue = data;
                //     for(let i=0; i++; i< path.length()){
                //         endValue = endValue[path[i]];
                //     }
                //     rec_.value = endValue;
                // }
                 else {
                    rec_.value = data[meta.key];
                }

                switch (meta.key) {
                    case 'Bid_Category__c':
                        rec_.isPLInput = true;
                        rec_.options = this.categories;

                        break;
                    case 'StageReceipt__c':
                    case 'Verified_by_Sales_Consultant__c':
                        rec_.isCheckbox = true;
                        rec_.checked = data[meta.key];
                        rec_.disabled = data.Submit_COE_Bidding__c;
                        break;
                    case 'Bid_1_Amount__c':
                    case 'Bid_2_Amount__c':
                    case 'Bid_3_Amount__c':
                    case 'Bid_4_Amount__c':
                    case 'Bid_5_Amount__c':
                    case 'Bid_6_Amount__c':
                    case 'Bid_7_Amount__c':
                    case 'Bid_8_Amount__c':
                    case 'Bid_9_Amount__c':
                    case 'Bid_10_Amount__c':
                    case 'Bid_11_Amount__c':
                    case 'Bid_12_Amount__c':
                    case 'Bid_Price__c':
                        rec_.isNumInput = true;
                        break;
                    case 'Detail_Additional_Charges':
                    case 'Detail_Cost_of_Accessories_Traded_Sold':
                        rec_.isTextArea = true;
                        break;
                    default:
                        rec_.isOutput = true;
                        break;
                }

                if (meta.key === 'Detail_Additional_Charges') {
                    if (data.SA_Additional_Charges__r) {
                        let _detailAddCharges = '';
                        data.SA_Additional_Charges__r.forEach(elem => _detailAddCharges += (elem.ChargeCodeDescription__c == 'VES SURCHARGE' ? 'VES REBATE' : elem.ChargeCodeDescription__c) + ": $" + elem.SAD_CHARGES__c + "\n");
                        rec_.value = _detailAddCharges;
                    }
                }

                if (meta.key === 'Detail_Cost_of_Accessories_Traded_Sold') {
                    if (data.SA_Accessories__r) {
                        let _detailCostAccTradedSold = '';
                        data.SA_Accessories__r.forEach(elem => _detailCostAccTradedSold += elem.SA_ACM_ACCSDESC__c + ': $' + elem.SAC_ACCSCOST__c + '\n');
                        rec_.value = _detailCostAccTradedSold;
                    }
                }

                if (this.reCalculate) {
                    if (['ARF_Payable__c', 'Vehicle_Cost__c', 'COEThresHold__c'].includes(meta.key)) {
                        rec_.value = _calculatedValues[saId][meta.key];
                    }
                }

                if(typeof rec_.value === 'number') {
                    rec_.isNumber = true;
                } else {                    
                    rec_.isNumber = false;
                }
                records_.push(rec_);
            }

            _dataForTable.push(
                {
                    idx: cnt,
                    Id: data.Id,
                    props: records_
                });
        }
        this.dataForTable = _dataForTable;
        console.log('this.dataForTable', this.dataForTable);
        this.isReady = true;
    }

    updateChangedDSAs(saId, fieldValueMap) {
        let index = this.changedDSAs.findIndex(x => x.saId == saId);
        if (index === -1) {
            let changedDSA = { saId: saId };

            for (let fieldName in fieldValueMap) {
                changedDSA[fieldName] = fieldValueMap[fieldName];
            }
            this.changedDSAs.push(changedDSA);
        }
        else {
            this.changedDSAs = this.changedDSAs.map(obj => {
                if (obj.saId === saId) {
                    let clonedObj = {
                        ...obj,
                    };
                    for (let fieldName in fieldValueMap) {
                        clonedObj[fieldName] = fieldValueMap[fieldName]
                    }
                    return clonedObj;
                }
                return obj;
            });
        }
    }

    handleAction(event) {
        let action = event.target.name;
        switch (action) {
            case 'save':
                this.saveDSAs();
                break;
            case 'submit_coe':
                this.submitForCOEBidding();
                break;
            case 'search':
                this.refreshTableData('');
                break;
            case 'reset':
                this.resetFilter();
                break;
            default:
                break;
        }
    }

    clearSearchFilter() {
        this.filters = {
            category: null,
            guaranteeStatus: null,
            svmStatus: null,
            approvalStatus: null,
            submitStatus: null,
            bidCategory: null
        };

        this.template.querySelectorAll('lightning-combobox[data-id="filter"]').forEach(each => {
            each.value = 'None';
        });
    }

    resetFilter() {
        this.spinner = true;
        this.clearSearchFilter();
        this.refreshTableData('');
        setTimeout(() => {
            this.spinner = false;
        }, 50);
    }

    async saveDSAs() {
        try {
            console.log('changedDSAs', this.changedDSAs);
            this.spinner = true;
            await saveDSA({
                info: this.changedDSAs
            });
            await sendEmailToSC({
                dsaIds: this.selectedSAIds,
                userId: this.userId
            });
            await this.refreshTableData('Save successfully!');
        } catch (error) {
            this.spinner = false;
            this.showNotification('Error!', 'An error occurred. Please contact your System Admin', 'error', 'dissmissible');
            console.log(error);
        }
    }

    isValidToSubmit(infoToSubmit) {
        let _incompletedSAs = [];
        console.log('infoToSubmit', infoToSubmit)
        if (!infoToSubmit.length) {
            this.showNotification('Error!', 'Please select record(s) to be submitted ', 'error', 'dissmissible');
            return false;
        } else {
            for (let sa of infoToSubmit) {
                if (!(sa.Bid_Category__c && sa.Bid_Price__c)) {
                    _incompletedSAs.push(sa.Name);
                }
            }

            if (_incompletedSAs.length > 0) {
                for (let saName of _incompletedSAs) {
                    this.showNotification('Error!', 'Please enter Bid Price and Bid Category for ' + saName, 'error', 'dissmissible');
                }
                return false;
            }
        }

        return true;
    }

    async sendMailToBSD(infoToSubmit) {
        await sendEmailToBSD({
            franchise: this.franchise,
            bidPeriodStartDate: this.bidPeriodStartDate,
            bidPeriodEndDate: this.bidPeriodEndDate,
            remarks: this.remarks,
            dsaList: infoToSubmit
        });
    }

    async submitForCOEBidding() {
        let infoToSubmit = [];
        if (this.selectedSAIds.length > 0) {
            infoToSubmit = this.dsaRecs.filter(sa => {
                return this.selectedSAIds.includes(sa.Id);
            }).map(originalSA => {
                const filteredSA = {};
                filteredSA['Id'] = originalSA.Id;
                filteredSA['Name'] = originalSA.Name;
                filteredSA['Agreement_Date__c'] = originalSA.Agreement_Date__c;
                filteredSA['Bid_Price__c'] = originalSA.Bid_Price__c;
                filteredSA['Bid_Category__c'] = originalSA.Bid_Category__c;
                filteredSA['Sales_Consultant__c'] = originalSA.Sales_Consultant__c;
                filteredSA['Customer_Full_Name__c'] = originalSA.Customer_Full_Name__c;
                filteredSA['Bid_1_Amount__c'] = originalSA.Bid_1_Amount__c;
                filteredSA['Bid_2_Amount__c'] = originalSA.Bid_2_Amount__c;
                filteredSA['Bid_3_Amount__c'] = originalSA.Bid_3_Amount__c;
                filteredSA['Bid_4_Amount__c'] = originalSA.Bid_4_Amount__c;
                filteredSA['Bid_5_Amount__c'] = originalSA.Bid_5_Amount__c;
                filteredSA['Bid_7_Amount__c'] = originalSA.Bid_7_Amount__c;
                filteredSA['Bid_8_Amount__c'] = originalSA.Bid_8_Amount__c;
                filteredSA['Bid_9_Amount__c'] = originalSA.Bid_9_Amount__c;
                filteredSA['Bid_6_Amount__c'] = originalSA.Bid_6_Amount__c;
                filteredSA['Bid_10_Amount__c'] = originalSA.Bid_10_Amount__c;
                filteredSA['Bid_11_Amount__c'] = originalSA.Bid_11_Amount__c;
                filteredSA['Bid_12_Amount__c'] = originalSA.Bid_12_Amount__c;
                return filteredSA;
            });
        }

        let _readyToSubmit = this.isValidToSubmit(infoToSubmit);
        if (!_readyToSubmit) {
            return;
        }
        this.spinner = true;

        try {
            const result = await submitForCOEBidding({
                info: infoToSubmit,
                bidPeriodId: this.bidPeriodId
            });
            console.log(result);
            await this.refreshTableData('DSA has been submitted for COE Bidding');
            await this.sendMailToBSD(infoToSubmit);
        } catch (error) {
            this.spinner = false;
            console.log(error);
            if (error.body.message.includes('Duplicate submission')) {
                this.showNotification('Error!', 'Sales Agreement(s) have been already submitted before. Please exclude the submited SAs from the selection', 'error', 'dissmissible');
            } else {
                this.showNotification('Error!', 'An error occurred. Please contact your System Admin', 'error', 'dissmissible');
            }
        }
    }

    async refreshTableData(message) {
        try {
            this.spinner = true;
            console.log('*** refreshTableData')
            this.dsaRecs = await retrieveDSAsForBidding({
                franchise: this.franchise,
                filter: this.filters
            });
            await this.processDataForTable(this.dsaRecs);
            this.spinner = false;
            if (message) {
                this.showNotification('Success!', message, 'success', 'dissmissible');
            }

        } catch (error) {
            this.showNotification('Error!', 'An error occurred. Please contact your System Admin', 'error', 'dissmissible');
            console.error(JSON.stringify(error));
        }
    }

    handleFilterChange(event) {
        this.filters[event.target.name] = event.target.value !== 'None' ? event.target.value : null;
    }

    handleSelectAll(event) {
        let _checkboxes = this.template.querySelectorAll('lightning-input[data-id="select-row"]');
        for (let i = 0; i < _checkboxes.length; i++) {
            _checkboxes[i].checked = event.target.checked;
        }

        this.selectedSAIds = [..._checkboxes]
            .filter(checkbox => checkbox.checked)
            .map(checkbox => checkbox.dataset.saId);
        console.log('selectedSAIds', this.selectedSAIds);
    }

    handleRowSelect(event) {
        let saId = event.target.dataset.saId;
        if (event.target.checked) {
            this.selectedSAIds.push(saId);
        } else {
            this.selectedSAIds = this.arrayRemove(this.selectedSAIds, saId);
        }
        console.log('selectedSAIds', this.selectedSAIds);

        let _checkboxAll = this.template.querySelector('lightning-input[data-id="select-all"]');
        if (this.selectedSAIds.length > 0 && this.selectedSAIds.length === this.dsaRecs.length) {
            _checkboxAll.checked = true;
        } else {
            _checkboxAll.checked = false;
        }
    }

    //Remove elem from array by value
    arrayRemove(arr, value) {
        return arr.filter(function (ele) {
            return ele != value;
        });
    }

    handleChange(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        let saId = event.target.dataset.saId;

        let index = this.changedDSAs.findIndex(x => x.saId == saId);
        if (fieldName === 'Remarks__c') {
            this.remarks = value;
            console.log(this.remarks);
        }
        else if (index === -1) {
            this.changedDSAs.push({ saId: saId, [fieldName]: value });
        }
        else {
            ;
            this.changedDSAs = this.changedDSAs.map(obj => {
                if (obj.saId === saId) { return { ...obj, [fieldName]: value }; }
                return obj;
            });
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


    get coeCategoryOpt() {
        return [
            { label: 'Select', value: 'None' },
            { label: 'A', value: 'A' },
            { label: 'B', value: 'B' },
            { label: 'C', value: 'C' },
            { label: 'E', value: 'E' },
        ];
    }


    get coeGuaranteeOpt() {
        return [
            { label: 'Select', value: 'None' },
            { label: 'Non-Guaranteed COE', value: 'Non-Guaranteed COE' },
            { label: 'Guaranteed COE', value: 'Guaranteed COE' },
        ];
    }


    get svmStatusOpt() {
        return [
            { label: 'Select', value: 'None' },
            { label: 'Stock to Indent', value: 'Stock to Indent' },
            { label: 'Existing Stock', value: 'Existing Stock' },
            { label: 'Incoming Stock', value: 'Incoming Stock' },
            { label: 'Promotional Stock', value: 'Promotional Stock' },
        ];
    }


    get loanApprovalOpt() {
        return [
            { label: 'Select', value: 'None' },
            { label: 'Not Approved', value: 'Not Approved' },
            { label: 'Approved', value: 'Approved' },
        ];
    }

    get submittedOpt() {
        return [
            { label: 'Select', value: 'None' },
            { label: 'Submitted', value: 'true' },
            { label: 'Not Submitted', value: 'false' },
        ];
    }

    @track bidCategoryOpt = [{ label: 'Select', value: 'None' }];
    @wire(getBidCategoryValue) 
    wiredData({data, error}) {
        if(data) {
            Array.prototype.push.apply(this.bidCategoryOpt, data);
        }
    }
    

}