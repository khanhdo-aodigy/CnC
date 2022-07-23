import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import MBSRMC_CHANNEL from '@salesforce/messageChannel/MBSRMC__c';

export default class Mb_SRContainer extends LightningElement {
    subscription = null;
    @api stockQuantity;

    @track stockInfo;
    @track indentInfo;
    @track isIndentStock;
    @track availableModelOptions;
    @track defaultModelOption = {};
    @track availableVariantOptions;
    @track defaultVariantOption = {};
    @track prevStockInfo;

    @wire( CurrentPageReference )
    currentPageReference;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
        if (Object.keys(this.currentPageReference.state).length !== 0) {
            this.prevStockInfo = {};
            this.prevStockInfo.prevSAId = this.currentPageReference.state.c__prevSA;
            this.prevStockInfo.prevStockNo = this.currentPageReference.state.c__prevStock;
        }
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
        
        this.subscription = subscribe(this.messageContext, MBSRMC_CHANNEL, (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        let message_ = JSON.parse(JSON.stringify(message));
        if (message_ != undefined && message_ != null) {
            let action = message_.action;
            switch(action) {
                case 'customer':
                    if (this.isIndentStock) {
                        this.isIndentStock = false;
                        this.stockInfo = {};
                    }
                    this.stockInfo = message_.data;

                    this.template.querySelector(`[data-id="sr-info"]`).style.display = 'none';
                    this.template.querySelector(`[data-id="customer-info"]`).style.display = 'inherit';
                    break;
                case 'indent':
                    this.isIndentStock = true;
                    this.indentInfo = JSON.parse(JSON.stringify(message_.data));
                    this.template.querySelector(`[data-id="sr-info"]`).style.display = 'none';
                    this.template.querySelector(`[data-id="customer-info"]`).style.display = 'inherit';
                    break;
                case 'model_list':
                    this.availableModelOptions = message_.data;
                    break;
                default:
                    break;
            }
        }
    }

    handleCancel() {
        this.template.querySelector(`[data-id="sr-info"]`).style.display = 'inherit';
        this.template.querySelector(`[data-id="customer-info"]`).style.display = 'none';
    }
}