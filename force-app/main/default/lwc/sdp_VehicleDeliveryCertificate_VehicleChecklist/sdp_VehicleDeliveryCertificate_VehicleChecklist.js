/* eslint-disable no-console */
/* eslint-disable no-unused-expressions */
import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.getRecords';
const appWording = 'C&C App';

export default class Sdp_VehicleDeliveryCertificate_VehicleChecklist extends LightningElement {
    @api franchiseCode;
    @track wiredRecords;
    @track vehicleChecklist = [];
    @track haveChecklistRecords = false;
    @track showAppScreen = false;
    @track checklistSectionOpened = false;

    renderedCallback() {
        console.log('GET FRANCHISE CODE FROM DETAILS cmp');
        console.log(this.franchiseCode);
        //console.log('SA VEHICLE CHECKLIST');
        //console.log(JSON.stringify(this.vehicleChecklist));
    }

    // Get all SA Vehicle Checklist records with Handover Items type
    @wire(getRecords, {
        objectName: 'SA_Vehicle_Checklist__c',
        filter: 'Franchise_Code__c',
        value: '$franchiseCode',
        moreConditions: 'AND Checklist_Type__c = \'Vehicle Checklist\' ORDER BY Position__c'
    })
    wireProps(result) {
        this.wiredRecords = result;
        if (result.data) {
            console.log('-----WIRED VEHICLE CHECKLIST----');
            if (result.data.length > 0) {
                this.haveChecklistRecords = true;
            } else {
                this.haveChecklistRecords = false;
                //this.dispatchEvent(new CustomEvent('toast', { details: {variant: 'error', message: 'No record found in Vehicle Checklist!'}, bubbles: true, composed: true }));
            }
            this.vehicleChecklist = result.data;
            this.vehicleChecklist = this.vehicleChecklist.map((record, index) => ({...record,
                                                                                    _haveAppWording : record.Details__c.includes(appWording) ? true  : false,
                                                                                    Details__c : record.Details__c.includes(appWording) ? record.Details__c.substring(0, 66) : record.Details__c,
                                                                                    sNo: (index + 1).toString().length < 2 ? '0' + (index + 1) : index + 1}));
        } else {
           console.log(result.error);
        }
    }

    collapseExpandSection(event){
        event.currentTarget.getAttribute('aria-expanded') === "true" ? this.template.querySelector(`div[data-node=${event.currentTarget.dataset.node}]`).classList.remove('show') : 
                                                                        this.template.querySelector(`div[data-node=${event.currentTarget.dataset.node}]`).classList.add('show');
        event.currentTarget.getAttribute('aria-expanded') === "true" ? event.currentTarget.classList.remove('show') : 
                                                                        event.currentTarget.classList.add('show');
        event.currentTarget.getAttribute('aria-expanded') === "true" ? (this.checklistSectionOpened = false, event.currentTarget.setAttribute('aria-expanded', false)) :  
                                                                        (this.checklistSectionOpened = true, event.currentTarget.setAttribute('aria-expanded', true));
        console.log('CHECKLIST SECTION OPENED: ' + this.checklistSectionOpened);
        this.dispatchEvent(new CustomEvent('checklist_section_selected', { detail: this.checklistSectionOpened, bubbles: true, composed: true }));
    }

    openAppScreen() {
        this.dispatchEvent(new CustomEvent('modal_clicked', { details: this.showAppScreen, bubbles: true, composed: true }));
        this.showAppScreen = true;
    }

    closeAppScreen() {
        this.dispatchEvent(new CustomEvent('modal_clicked', { details: this.showAppScreen, bubbles: true, composed: true }));
        this.showAppScreen = false;
    }
}