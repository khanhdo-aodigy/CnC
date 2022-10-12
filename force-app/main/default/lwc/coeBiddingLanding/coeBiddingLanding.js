import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import COEBIDMC_CHANNEL from '@salesforce/messageChannel/COEBIDMC__c';
import retrieveDSAsForBidding from '@salesforce/apex/COEBiddingController.retrieveDSAsForBidding';
import getNextCOE from '@salesforce/apex/COEBiddingController.getNextCOE';
import getLastCOE from '@salesforce/apex/COEBiddingController.getLastCOE';
import getFranchisePicklist from '@salesforce/apex/COEBiddingController.getFranchisePicklist';
import getExchangeRate from '@salesforce/apex/COEBiddingController.getExchangeRate';

export default class coeBiddingLanding extends LightningElement
{
    @track recordId;
    @track fromDate;
    @track toDate;
    @track spinner = false;
    @track franchiseChoices;
    dsaForCOEBidding;
    franchise;
    bidPeriodStartDate;
    bidPeriodEndDate;
    quotaA;
    quotaB;
    quotaC;
    quotaE;
    exchangeRateUSD;
    exchangeRateJPY;
    exchangeRateEUR;
    exchangeRateRMB;
    exchangeRateOther;
    directCost = 0;
    isKIA = false;
    isMIT = false;
    isCIT = false;
    isMAXUS = false;
    isFranchiseNull = true;
    reCalculate = false;;

    @wire (MessageContext)
    messageContext;
 
    subscription = null;
 
    subscribeToMessageChannel() {
       if (this.subscription) return;
       
       this.subscription = subscribe(this.messageContext, COEBIDMC_CHANNEL, (message) => {
             this.handleMessage(message);
          }
       );
    }
 
    unsubscribeToMessageChannel() {
       unsubscribe(this.subscription);
       this.subscription = null;
    }
 
    connectedCallback() {
       this.subscribeToMessageChannel();
    }
 
    disconnectedCallback() {
       this.unsubscribeToMessageChannel;
    }

    @wire(getNextCOE, {})
    wiredNextCOE({error,data}) {
        if (error)
        {
            console.error(error);
        }
        else if (data)
        {
            this.recordId = data.Id;
            const startDate = new Date(data.From_Date__c);
            this.fromDate = startDate.toLocaleDateString('en-GB');

            const endDate = new Date(data.To_Date__c);
            this.toDate = endDate.toLocaleDateString('en-GB');
        }
    }

    @wire(getLastCOE, {})
    wiredLastCOE({error,data}) {
        if (error)
        {
            console.error(error);
        }
        else if (data)
        {
            this.recordId = data.Id;
            this.quotaA = data.A__c;
            this.quotaB = data.B__c;
            this.quotaC = data.C__c;
            this.quotaE = data.E__c;
            console.log('***********' + data.A__c);
        }
    }

    handleInputChange(event){
        switch(event.target.name){
            case "JPY exchange rate":
                this.exchangeRateJPY = event.detail.value;
                break;
            case "RMB exchange rate":
                this.exchangeRateRMB = event.detail.value;
                break;
            case "USD exchange rate":
                this.exchangeRateUSD = event.detail.value;
                break;
            case "EUR exchange rate":
                this.exchangeRateEUR = event.detail.value;
                break;
            // case "other exchange rate":
            //     this.exchangeRateOther = event.detail.value;
            //     break;
            case "direct cost":
                this.directCost = event.detail.value;
                // var formatter = new Intl.NumberFormat('en-US', {
                //     style: 'currency'
                // });
                // formatter.format(this.directCost);
                break;
            case "using exchange rate":
                this.reCalculate = event.target.checked;
                break;
        }
    }

    @wire(getFranchisePicklist, {})
    wiredFranchiseChoices({error, data})
    {
        if (error)
        {
            console.error(error);
        }
        else if (data)
        {   
            let franchisePicklist= [];
            data.forEach(item => {
                if(item.label != 'DPS'){
                    franchisePicklist.push({value: item.value, label : item.label});
                }
            })
            this.franchiseChoices = franchisePicklist;
            console.log(JSON.stringify(this.franchiseChoices));
        }
    }

    handleFranchiseSelected(e)
    {
        this.franchise = e.currentTarget.value;
        this.spinner = true;
        if(this.franchise == 'MITCV' || this.franchise == 'MITPC'){
            getExchangeRate({
                currencyCode: 'JPY'
            }).then(result => {
                this.spinner = false;
                this.isMIT = true;
                this.isCIT = false;
                this.isKIA = false;
                this.isMAXUS = false;
                this.isFranchiseNull = false;
                this.exchangeRateJPY = result.Custom_Exchange_Rate__c;
                console.log('isMIT:' + this.isMIT + ' ' + 'value:' + this.exchangeRateJPY);
            })
        }
        else if(this.franchise == 'KIACV' || this.franchise == 'KIAPC'){
            getExchangeRate({
                currencyCode: 'USD'
            }).then(result => {
                this.spinner = false;
                this.isKIA = true;
                this.isCIT = false;
                this.isMIT = false;
                this.isMAXUS = false;
                this.isFranchiseNull = false;
                this.exchangeRateUSD = result.Custom_Exchange_Rate__c;
                console.log('isKIA:' + this.isKIA + ' ' + 'value:' + this.exchangeRateUSD);
            })
        }
        else if(this.franchise == 'MAXUSCV' || this.franchise == 'MAXUSPC'){
            getExchangeRate({
                currencyCode: 'RMB'
            }).then(result => {
                this.spinner = false;
                this.isMAXUS = true;
                this.isCIT = false;
                this.isMIT = false;
                this.isKIA = false;
                this.isFranchiseNull = false;
                this.exchangeRateRMB = result.Custom_Exchange_Rate__c;
                console.log('isMAXUS:' + this.isMAXUS + ' ' + 'value:' + this.exchangeRateRMB);
            })
        }
        else if(this.franchise == 'CITCV' || this.franchise == 'CITPC'){
            this.isKIA = false;
            this.isCIT = true;
            this.isMIT = false;
            this.isMAXUS = false;
            this.isFranchiseNull = false;
            getExchangeRate({
                currencyCode: 'USD'
            }).then(result => {
                this.spinner = false;
                this.exchangeRateUSD = result.Custom_Exchange_Rate__c;
            })

            getExchangeRate({
                currencyCode: 'EUR'
            }).then(result => {
                this.exchangeRateEUR = result.Custom_Exchange_Rate__c;
            })
            console.log('isCIT:' + this.isCIT + ' ' + 'value EUR:' + this.exchangeRateEUR + ' ' + 'value USD:' + this.exchangeRateUSD);
        }
        else{
            this.spinner = false;
            this.isFranchiseNull = true;
        }
    }

    moveToCOECreation()
    {
        this.spinner = true;
        if(!this.isValidateFranchise()){
            this.spinner = false;
        }

        if(!this.isCIT && !this.isFranchiseNull){
            if(!this.isValidateExchangeRate1())
            {
                this.spinner = false;
            }
            if(!this.isValidateDirectCost())
            {
                this.spinner = false;
            }
            else
            {
                this.retrieveDSAs();
            }
        }

        if(this.isCIT){
            if(!this.isValidateExchangeRate1())
            {
                this.spinner = false;
            }
            
            if(!this.isValidateExchangeRate2())
            {
                this.spinner = false;
            }
            if(!this.isValidateDirectCost())
            {
                this.spinner = false;
            }
            else
            {
                this.retrieveDSAs();
            }
        }
    }

    retrieveDSAs(){
        retrieveDSAsForBidding({
            franchise: this.franchise
        }).then(result => {
            this.spinner          = false;
            this.dsaForCOEBidding = result;
            console.log(this.dsaForCOEBidding);

            const payload = {
                action : 'retrieve',
                data   : {
                    coeBidPeriodId: this.recordId, 
                    dsaForCOEBidding: this.dsaForCOEBidding, 
                    franchise: this.franchise, 
                    directCost: this.directCost,
                    bidPeriodStartDate: this.fromDate,
                    bidPeriodEndDate: this.toDate,
                    exchangeRateEUR: this.exchangeRateEUR, 
                    exchangeRateRMB: this.exchangeRateRMB,
                    exchangeRateUSD: this.exchangeRateUSD, 
                    exchangeRateJNY: this.exchangeRateJNY,
                    reCalculate: this.reCalculate
                }
            };

            console.log('reCalculate: ' + this.reCalculate);
            publish(this.messageContext, COEBIDMC_CHANNEL, payload);
        }).catch(error => {
            this.spinner = false;
            console.log(error);
        })
    }
    // Validate Exchange Rate
    isValidateExchangeRate1(){
        var isValid = true;
        var inputCmp1 = this.template.querySelector('.validate1');
        if(inputCmp1.value < 0 && !isNaN(inputCmp1.value)) 
        {
            inputCmp1.setCustomValidity('Exchange Rate must be greater than 0.');
            isValid = false;
        } 
        else if(isNaN(inputCmp1.value)) 
        {
            inputCmp1.setCustomValidity('Exchange Rate must be number.');
            isValid = false;
        }
        else if(inputCmp1.value === null || inputCmp1.value === '' || inputCmp1.value === undefined){
            inputCmp1.setCustomValidity('Please complete this field.');
            isValid = false;
        }
        else{
            inputCmp1.setCustomValidity('');
        }
        inputCmp1.reportValidity();
        
        return isValid;
    }

    isValidateExchangeRate2(){
        var isValid = true; 
        var inputCmp3 = this.template.querySelector('.validate3');
        if(inputCmp3.value < 0 && !isNaN(inputCmp3.value)) 
        {
            inputCmp3.setCustomValidity('Exchange Rate must be greater than 0.');
            isValid = false;
        } 
        else if(isNaN(inputCmp3.value)) 
        {
            inputCmp3.setCustomValidity('Exchange Rate must be number.');
            isValid = false;
        }
        else if(inputCmp3.value === null || inputCmp3.value === '' || inputCmp3.value === undefined){
            inputCmp3.setCustomValidity('Please complete this field.');
            isValid = false;
        }
        else{
            inputCmp3.setCustomValidity('');
        }
        inputCmp3.reportValidity();

        return isValid;
    }

    // Validate Direct Cost
    isValidateDirectCost(){
        var isValid = true; 
        var inputCmp2 = this.template.querySelector('.validate2');
        if(inputCmp2.value < 0 && !isNaN(inputCmp2.value)) 
        {
            inputCmp2.setCustomValidity('Direct Cost must be greater than 0.');
            isValid = false;
        } 
        else if(isNaN(inputCmp2.value)) 
        {
            inputCmp2.setCustomValidity('Direct Cost must be number.');
            isValid = false;
        }
        else{
            inputCmp2.setCustomValidity('');
        }
        inputCmp2.reportValidity();

        return isValid;
    }

    // Validate Franchise Code
    isValidateFranchise(){
        var isValid = true; 
        var inputCmp4 = this.template.querySelector('.validate4');
        if(inputCmp4.value === '' || inputCmp4.value === null || inputCmp4.value === undefined) 
        {
            inputCmp4.setCustomValidity('Please complete this field.');
            isValid = false;
        } 
        else{
            inputCmp4.setCustomValidity('');
        }
        inputCmp4.reportValidity();

        return isValid;
    }

    handleMessage(message) {

    }
}