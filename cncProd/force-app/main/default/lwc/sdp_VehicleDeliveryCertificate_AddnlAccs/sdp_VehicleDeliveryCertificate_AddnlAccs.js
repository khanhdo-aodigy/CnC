/* eslint-disable no-console */
/* eslint-disable no-unused-expressions */
import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.getRecords';

export default class Sdp_VehicleDeliveryCertificate_AddnlAccs extends LightningElement {
    @api recordId;

    @track haveMain = false;
    @track haveAdditional = false;
    @track haveOutstanding = false;

    @track wiredMain;
    @track wiredAdditional;
    @track wiredOutstanding;

    @track mainGroup = [];
    @track additionalGroup = [];
    @track outstandingGroup = [];

    mainCart = [];
    additionalCart = [];
    outstandingCart = [];

    // get main accessories
    @wire(getRecords, {
        objectName: 'SA_Accessory__c',
        filter: 'Sales_Agreement__c',
        value: '$recordId',
        moreConditions: 'AND Accessories_Master__r.AccessoriesGroup__c = \'MAIN ACCESSORIES\''
    })
    mainStream(result) {
        this.wiredMain = result;
        if (result.data) {
            this.haveMain = result.data.length > 0 ? true : false;
            this.mainGroup = result.data;
        }
    }

    // get additional accessories
    @wire(getRecords, {
        objectName: 'SA_Accessory__c',
        filter: 'Sales_Agreement__c',
        value: '$recordId',
        moreConditions: 'AND Accessories_Master__r.AccessoriesGroup__c = \'ADDITIONAL ACCESSORIES\''
    })
    additionalStream(result) {
        this.wiredAdditional = result;
        if (result.data) {
            this.haveAdditional = result.data.length > 0 ? true : false;
            this.additionalGroup = result.data;
        }
    }

    // get outstanding accessories
    @wire(getRecords, {
        objectName: 'Outstanding_Accessory__c',
        filter: 'Sales_Agreement__c',
        value: '$recordId',
        moreConditions: ''
    })outstandingStream(result) {
        this.wiredOutstanding = result;
        if (result.data) {
            this.haveOutstanding = result.data.length > 0 ? true : false;
            this.outstandingGroup = result.data;
            
            // pre-populate outstanding cart and fire event to parent to keep track of record
            if (this.haveOutstanding) this.outstandingCart = this.outstandingGroup.map(item => {
                return {
                    Id: item.Id,
                    SA_Accessory: item.SAAccessory__c,
                    Name: item.AccessoryName__c,
                }
            })
            this.dispatchEvent(new CustomEvent('outstanding_cart', {detail: this.outstandingCart, bubbles: true, composed: true}));
        }
    }

    itemCheck(event) {
        const selectionStatus = event.currentTarget.className;
        selectionStatus.includes('active') ? this.removeItemFromCart(event) : this.addItemToCart(event);
    }

    addItemToCart(event) {
        // update cart
        event.currentTarget.classList.remove('deal');
        event.currentTarget.classList.add('active');
        let selectedID = event.currentTarget.dataset.itemid;
        event.currentTarget.dataset.category === 'main' && this.mainCart.push(selectedID);
        event.currentTarget.dataset.category === 'additional' && this.additionalCart.push(selectedID);

        // fire event to store new cart info in parent
        let checkoutCart = {main: this.mainCart, additional: this.additionalCart};
        this.dispatchEvent(new CustomEvent('cart_update', {detail: checkoutCart, bubbles: true, composed: true}));
    }

    removeItemFromCart(event) {
        // update cart
        event.currentTarget.classList.remove('active');
        event.currentTarget.classList.add('deal');
        let deselectedID = event.currentTarget.dataset.itemid;

        if (event.currentTarget.dataset.category === 'main') {
            let itemIndex = this.mainCart.indexOf(deselectedID);
            itemIndex !== -1 && this.mainCart.splice(itemIndex, 1);
        }
        
        if (event.currentTarget.dataset.category === 'additional') {
            let itemIndex = this.additionalCart.indexOf(deselectedID);
            itemIndex !== -1 && this.additionalCart.splice(itemIndex, 1);
        }

        // fire event to store new cart info in parent
        let checkoutCart = {main: this.mainCart, additional: this.additionalCart};
        this.dispatchEvent(new CustomEvent('cart_update', {detail: checkoutCart, bubbles: true, composed: true}));
    }
}