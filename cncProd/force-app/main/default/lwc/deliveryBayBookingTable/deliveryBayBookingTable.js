import { LightningElement, api, wire, track } from 'lwc';
import getRelatedRecords from '@salesforce/apex/deliveryBayBookingCtl.doSearchRecords';
import updateRecord from '@salesforce/apex/deliveryBayBookingCtl.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeliveryBayBookingTable extends LightningElement {
    @api serviceCategoryRecord;
    @api deliveryBayRecordId;
    @api estimatedDate;
    @api currentRecordId;
    @track spinner = true;
    @track initialRender = true;
    @track startDate;
    @track endDate;
    @track offDaysList = [];
    @track offDeliverySlots = [];
    @track timeSlotsMatrix = [];
    @track selectedTimeSlot;
    @track timeslotFormat = [];
    @track durationSlot;
    @track modalPopup = false;
    @track modalTitle = '';
    @track finalTime;
    @track finalDate;
    @track selectedTimeslotMatrix = [];

    renderedCallback() {
        if (this.initialRender) {
            let chosenDate = new Date(this.estimatedDate);
            let days = 2 * 60 * 60 * 24 * 1000;

            this.endDate = new Date(chosenDate.getTime() + days);
            this.startDate = new Date(chosenDate.getTime() - days);

            this.getRecords();
            this.initialRender = false;
        }
    }

    getRecords() {
        this.spinner = true;

        getRelatedRecords({
            recordId: this.serviceCategoryRecord.Service_Centre__c,
            startDate: this.endDate,
            endDate: this.startDate
        })
            .then(result => {
                this.processSearchRecords(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    processSearchRecords(searchResult) {
        this.offDaysList = searchResult.offDays;
        this.offDeliverySlots = searchResult.otherDeliverySlots;

        //Processing the table
        let openingTime = this.serviceCategoryRecord.Service_Centre_Opening__c;
        let closingTime = this.serviceCategoryRecord.Service_Centre_Closing__c;
        let intervalDuration = this.serviceCategoryRecord.Interval_Minutes__c;
        let intervalSlot = this.serviceCategoryRecord.Slots_per_Interval__c;
        this.durationSlot = intervalDuration * 60 * 1000;
        let fullMatrix = [];
        let roomMatrix = [];

        /*
        console.log('--------------- Master Data ---------------');
        console.log(this.offDaysList);
        console.log(this.offDeliverySlots);
        console.log('openingTime: ' + this.msToTime(openingTime));
        console.log('closingTime: ' + this.msToTime(closingTime));
        console.log('intervalDuration: ' + intervalDuration);
        console.log('intervalSlot: ' + intervalSlot);
        console.log('startDate: ' + this.startDate);
        console.log('endDate: ' + this.endDate);
        console.log('--------------- Master Data ---------------');
        */

        //Create room matrix for each day
        for (let slot = 1; slot <= intervalSlot; slot++) {
            roomMatrix.push({
                roomNo: slot,
                quantity: false,
            });
        }

        //Create matrix consisting of all days
        for (let day = 0; day < 5; day++) {
            let counter = 0;
            let currentTime = openingTime;
            let temptimeslot = [];
            let currentDate = new Date(this.startDate.getTime() + (day * 60 * 60 * 24 * 1000));
            let slotQuantity = intervalSlot;

            //Check whether currentDate is Off Days
            this.offDaysList.forEach(eachRecord => {
                let tempOffDate = new Date(eachRecord.Date__c);
                if (currentDate - tempOffDate === 0) {
                    slotQuantity = 0;
                }
            })

            while (currentTime < closingTime) {
                let disableButton = false;
                let temporaryQuantity = slotQuantity;
                let dailyMatrix = JSON.parse(JSON.stringify(roomMatrix));
                counter = counter + 1;

                //Comparing with existing delivery slots
                this.offDeliverySlots.forEach(eachBooking => {
                    let tempBookingDate = new Date(eachBooking.Delivery_Date__c);
                    if (currentDate - tempBookingDate === 0) {
                        if (currentTime >= eachBooking.Start_Time__c) {
                            if (currentTime < eachBooking.End_Time__c) {
                                temporaryQuantity = temporaryQuantity - 1;
                                let SelectedRecord = dailyMatrix.find(eachRoom => eachRoom.roomNo === eachBooking.Room_No__c);
                                SelectedRecord.quantity = true;
                            }
                        } else {
                            if (eachBooking.Start_Time__c - currentTime < this.durationSlot) {
                                temporaryQuantity = temporaryQuantity - 1;
                                let SelectedRecord = dailyMatrix.find(eachRoom => eachRoom.roomNo === eachBooking.Room_No__c);
                                SelectedRecord.quantity = true;
                            }
                        }
                    }
                })

                //Control Button UI
                if (temporaryQuantity === 0) {
                    disableButton = true;
                }

                //Inputting daily slots into the matrix
                temptimeslot.push({
                    startTime: this.msToTime(currentTime),
                    duration: intervalDuration,
                    slotAvailable: temporaryQuantity,
                    counter: counter,
                    disableButton: disableButton,
                    room: dailyMatrix
                    //    variant : 'Neutral'
                });

                currentTime = currentTime + (60 * 1000 * intervalDuration)
            }

            fullMatrix.push({
                timeSlot: temptimeslot,
                date: currentDate
            });
        }

        this.timeslotFormat = fullMatrix[0].timeSlot;
        this.timeSlotsMatrix = fullMatrix;
        this.spinner = false;

        /*
        console.log('--------------- Final Data ---------------');
        console.log(this.timeSlotsMatrix);
        console.log('--------------- Final Data ---------------');
        */
    }


    handleClosePopup() {
        this.modalPopup = false;
    }

    handleConfirmBooking(event){
        console.log(this.finalTime);
        console.log(this.finalDate);
        console.log(event.target.value);

       let confirm = window.confirm('Please confirm that you are booking Room: ' + event.target.value);
       confirm && this.updateDeliverySlot(event.target.value);
    }

    handleOnClick(event) {
        let days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        let months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

        let day = days[event.target.name.getDay()];
        let date = event.target.name.getDate();
        let month = months[event.target.name.getMonth()];

        this.modalTitle = day + ', ' + date + ' ' + month + ' @ ' + event.target.value;
        this.finalTime = event.target.value;
        this.finalDate = event.target.name;

        let temporaryMatrix = this.timeSlotsMatrix.find(eachDay => eachDay.date === event.target.name);
        this.selectedTimeslotMatrix= temporaryMatrix.timeSlot.find(eachTimeslot => eachTimeslot.startTime === event.target.value);
        console.log(this.selectedTimeslotMatrix.room);

        this.modalPopup = true;
        // const dataAttributes = event.currentTarget.dataset;
        // const _index = dataAttributes.index;
        // const _rowindex = dataAttributes.rowIndex; 
        // if(this.dateChose == date || this.dateChose == null){
        //     if((this.rowChose.length != 0 && !this.isSeamless(_rowindex)) || this.rowChose.includes(_rowindex)){
        //         this.resetChose();
        //     }
        // }
        // else{
        //     this.resetChose();

        // }
        // this.rowChose.push(_rowindex);
        // this.timeSlotsMatrix[_index].timeSlot[_rowindex].variant = 'brand';
        // this.startTimeChose.push( this.timeSlotsMatrix[_index].timeSlot[_rowindex].startTime);
        // this.dateChose = date;
    }

    // isSeamless(startTime){
    //     let result = false;
    //     this.rowChose.forEach(row =>{
    //         if(((parseInt(row) + 1) == startTime) || ((parseInt(row) - 1) == startTime)){
    //             result = true;
    //         }
    //     });
    //     return result;
    // }

    // resetChose(){
    //     this.startTimeChose = [];
    //     this.rowChose = [];
    //     this.timeSlotsMatrix.forEach(timeSlotsMatrix =>{
    //         timeSlotsMatrix.timeSlot.forEach(timeSlot =>{
    //             timeSlot.variant = 'Neutral';
    //         })
    //     })
    // }



    updateDeliverySlot(roomNo) {
        //updateRecord(String recordId, string selectedDate, string timeslot) 
        console.log('Booking: ' + this.finalTime + ' @ ' + this.finalDate);
        console.log('Record ID: ' + this.currentRecordId);
        console.log('Duration: ' + this.durationSlot);
        this.spinner = true;

        updateRecord({
            recordId: this.currentRecordId,
            selectedDate: this.finalDate,
            timeslot: this.finalTime,
            duration: this.durationSlot,
            serviceCenterId: this.serviceCategoryRecord.Service_Centre__c,
            roomNo: roomNo
        })
            .then(result => {
                this.toast('SUCCESS', 'Delivery slot has been booked successfully! Refreshing the page...', null, 'success', 'dissmissible');
                setTimeout(() => {
                    window.location.reload();
                }, 2000);
            })
            .catch(error => {
                //  this.toastApexError(error);
                this.toast('ERROR', 'An active Delivery Slot record found. Please access this record if you need to make any changes', null, 'error', 'sticky')
            });
    }

    msToTime(s) {
        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
        return hrs + ':' + mins; // + ':00.000Z' <- if necessary
    }

    toastApexError(error) {
        console.log(error);
        let errMsg = error.statusText + ' :: ' + error.body.message;
        this.toast('ERROR', errMsg, null, 'error', 'sticky');
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
}