import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMainRecords from '@salesforce/apex/deliveryBayBookingCtl.doGetInformation';
import cancelRecord from '@salesforce/apex/deliveryBayBookingCtl.cancelRecord';
import rebookRecord from '@salesforce/apex/deliveryBayBookingCtl.rebookRecord';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class DeliveryBayBooking extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api recordId;
    @track spinner = true;
    @track initialRender = true;
    @track disableChanges = true;
    @track completedRecord = false;
    @track wiredRecords;
    @track currentSlotRecord;
    @track availableServiceCentre = [];
    @track todayDate;
    @track selectedServiceCentre;
    @track selectedDate;
    @track disableButton = true;
    @track openChildComponent = false;

    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = false;
        }
    }

    @wire(getMainRecords, {
        recordId: '$recordId',
    })
    wiredProps(result) {
        this.spinner = true;
        this.wiredRecords = result;
        result.data && this.processBaseData(result.data);
    }

    processBaseData(response) {
        this.currentSlotRecord = response.currentDeliverySlot;

        //Control UI for different scenarios
        switch (response.currentDeliverySlot.Status__c) {
            case undefined:
                this.disableChanges = false;
                this.completedRecord = false;
                break;
            case 'Booked':
                this.disableChanges = true;
                this.completedRecord = false;
                break;
            default:
                this.disableChanges = true;
                this.completedRecord = true;
                break;
        }

        //Service Category Selections
        let serviceCategoryFound = response.availableServiceCategory;
        let tempServiceCentre = [];
        serviceCategoryFound.forEach(serviceCategoryFound => {
            tempServiceCentre.push({
                label: serviceCategoryFound.Service_Centre_Description__c,
                value: serviceCategoryFound.Service_Centre__c
            });
        })
        this.availableServiceCentre = tempServiceCentre;

        // Get the current date/time in UTC
        let rightNow = new Date();

        // Adjust for the user's time zone
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );

        // Return the date in "YYYY-MM-DD" format
        let yyyyMmDd = rightNow.toISOString().slice(0, 10);
        this.todayDate = yyyyMmDd;

        //Turn off spinner after processing
        this.spinner = false;
    }

    handleChanges(event) {
        let selectedName = event.target.name;
        let selectedValue = event.detail.value;

        //Service Centre selection
        if (selectedName == 'serviceCentre') {
            let selectedRecord = this.wiredRecords.data.availableServiceCategory.find(EachRecord => EachRecord.Service_Centre__c === event.detail.value);
            this.selectedServiceCentre = selectedRecord;
        }

        //Date selection
        if (selectedName == 'selectedDate') {
            if (selectedValue >= this.todayDate && selectedValue != null) {
                this.selectedDate = selectedValue;
            } else {
                this.selectedDate = null;
            }
        }

        if (this.selectedServiceCentre != undefined && this.selectedDate != undefined && this.selectedDate != null) {
            this.disableButton = false;
        } else {
            this.disableButton = true;
        }

        //Close child components
        this.openChildComponent = false;
    }

    onFindSlot() {
        this.openChildComponent = true;
    }

    onCancelled(event) {
        let confirm = window.confirm('Cancel Current Delivery Bay Slot?');
        confirm && this.cancelSlot(event.target.value);
    }

    onRebook(event) {
        let confirm = window.confirm('Cancel Current Delivery Bay Slot and Rebook New Slot?');
        confirm && this.cancelAndRebookSlot(event.target.value);
    }

    cancelSlot(currentRecordId) {
        console.log('Cancelling Record :: ' + currentRecordId);
        this.spinner = true;
        cancelRecord({
            recordId: this.recordId
        })
            .then(() => {
                refreshApex(this.wiredRecords);
                this.toast('SUCCESS', 'Slot has been cancelled! Refreshing the page!', null, 'success', 'dissmissible');
                setTimeout(() => {
                    window.location.reload();
                }, 2000);

            })
            .catch(error => {
                this.toastApexError(error);
            });
    }

    cancelAndRebookSlot(currentRecordId) {
        console.log('Rebooking Record :: ' + currentRecordId);
        this.spinner = true;
        rebookRecord({
            recordId: this.recordId
        })
            .then(result => {
                this.toast('SUCCESS', 'New Slot has been booked! Redirecting to new record.', null, 'success', 'dissmissible');
                setTimeout(() => {
                    this.navigateToRecord(result);
                }, 2000);
            })
            .catch(error => {
                this.toastApexError(error);
            });
    }

    toast(title, message, msgData, variant, mode) {
        const toastEvent = new ShowToastEvent({
            'title': title,
            'message': message,
            'messageData': msgData,
            'variant': variant,
            'mode': mode
        });
        this.dispatchEvent(toastEvent);
    }

    toastApexError(error) {
        console.log(error);
        let errMsg = error.statusText + ' :: ' + error.body.message;
        this.toast('ERROR', errMsg, null, 'error', 'sticky');
    }

    navigateToRecord(selectedRecordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                actionName: 'view',
            },
        });
    }

}