/* eslint-disable no-new-func */
/* eslint-disable no-console */
/* eslint-disable no-unused-expressions */
import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.getRecords';
import VDC_BoxIcon from '@salesforce/resourceUrl/VDC_BoxIcon';

export default class Sdp_VehicleDeliveryCertificate_HandoverItems extends LightningElement {
    @track wiredRecords;
    @track handoverItems = [];
    @track totalCheckedHandoverItems = 0;
    @track haveItemRecords = false;
    @track allCheckedItems = false;
    @track itemSectionOpened = false;
    vdcBoxIcon = VDC_BoxIcon;

    renderedCallback() {
        //console.log('SA HANDOVER ITEMS');
        //console.log(JSON.stringify(this.handoverItems));
        //console.log('TOTAL ITEM: ' + this.totalCheckedHandoverItems);

        //this.checkTickedHandoverItems();
    }

    // Get all SA Vehicle Checklist records with Handover Items type
    @wire(getRecords, {
        objectName: 'SA_Vehicle_Checklist__c',
        filter: 'Checklist_Type__c',
        value: 'Handover Items',
        moreConditions: 'ORDER BY Position__c'
    })
    wireProps(result) {
        this.wiredRecords = result;
        if (result.data) {
            //console.log('-----WIRED HAND OVER ITEMS----');
            if (result.data.length > 0) {
                this.haveItemRecords = true;
            } else {
                this.haveItemRecords = false;
                this.allCheckedItems = true;
                this.dispatchEvent(new CustomEvent('none_detected_items', { detail: this.allCheckedItems, bubbles: true, composed: true }));
                //this.dispatchEvent(new CustomEvent('toast', { details: {variant: 'error', message: 'No record found in Handover Items!'}, bubbles: true, composed: true }));
                
            }
            this.handoverItems = result.data;
            //this.totalCheckedHandoverItems = this.handoverItems.length;
        }
    }

    onSelected(event) {
        this.template.querySelectorAll(`button[data-itemid=${event.currentTarget.dataset.itemid}]`).forEach(elem=>{
            elem.className.includes('active') ? (elem.classList.remove('active'), this.totalCheckedHandoverItems -= 1) :
                                                (elem.classList.add('active'), this.totalCheckedHandoverItems += 1);
            console.log(this.totalCheckedHandoverItems);
        })
        this.checkTickedHandoverItems();
        this.dispatchEvent(new CustomEvent('handoveritem_selected', { detail: this.allCheckedItems, bubbles: true, composed: true }));
        console.log('========EVENT==========');
    }

    collapseExpandSection(event){
        event.currentTarget.getAttribute('aria-expanded') === "true" ? this.template.querySelector(`div[data-node=${event.currentTarget.dataset.node}]`).classList.remove('show') : 
                                                                        this.template.querySelector(`div[data-node=${event.currentTarget.dataset.node}]`).classList.add('show');
        event.currentTarget.getAttribute('aria-expanded') === "true" ? event.currentTarget.classList.remove('show') : 
                                                                        event.currentTarget.classList.add('show');
        event.currentTarget.getAttribute('aria-expanded') === "true" ? (this.itemSectionOpened = false, event.currentTarget.setAttribute('aria-expanded', false)) :  
                                                                        (this.itemSectionOpened = true, event.currentTarget.setAttribute('aria-expanded', true));
        console.log('ITEM SECTION OPENED: ' + this.itemSectionOpened);
        console.log('aaaaaaaaaaaa')
        this.dispatchEvent(new CustomEvent('item_section_selected', { detail: this.itemSectionOpened, bubbles: true, composed: true }));
        console.log('bbbbbbbb')
    }

    checkTickedHandoverItems() {
        this.allCheckedItems = this.totalCheckedHandoverItems === this.handoverItems.length ? true : false;

        console.log('==== ERROR IN SELECTED HANDOVER ITEMS ====');
        console.log(this.allCheckedItems);
    }
}