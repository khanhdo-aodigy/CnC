import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import constructWrapper from '@salesforce/apex/JITController.constructWrapper';
import cancelSlot from '@salesforce/apex/JITController.cancelSlot';
import bookSlot from '@salesforce/apex/JITController.lookUpJITDayRecord';

const currentTime  = new Date().getTime();
const timeToUpdate = new Date().setHours(12,0,0);

export default class JitSlotsBooking extends LightningElement {
    @api recordId;
    @api objectApiName;

    wiredRecs;
    selectedJITDay;
    jitDaysList;
    recInfo;
    bookedJIT;
    isSalesAdmin;
    isSalesConsultant;
    errMsg;
    isJITBooked    = false;
    isJITCancelled = false;
    spinner        = false;

    @wire(constructWrapper, {
        objAPINm : '$objectApiName',
        recordId : '$recordId'
    }) wiredProps(result) {
        this.wiredRecs = result;
        if (result.data)
        {
            this.isSalesAdmin      = result.data.isSalesAdmin;
            this.isSalesConsultant = result.data.isSalesConsultant;

            this.recInfo     = this.deepClone(result.data.curRecInfo);
            this.jitDaysList = this.deepClone(result.data.jitDaysList);
            this.bookedJIT   = /*this.jitDaysList.filter(rec => rec.Id === this.recInfo.JIT_Day__c)[0]*/ result.data.bookedJIT;

            this.jitDaysList.forEach(rec => {
                rec.disabled    = this.convertStringToDate(rec.JIT_Date__c).getTime() !== this.convertStringToDate(this.recInfo.JIT_Date__c).getTime();
                rec.JIT_Date__c = new Date(rec.JIT_Date__c).toLocaleDateString('en-SG');
            })

            this.isJITBooked    = this.bookedJIT || this.jitDaysList.length == 0 ? true : false;
            this.isJITCancelled = !this.isJITBooked || this.jitDaysList.length == 0;

            if (this.jitDaysList.length == 0)
            {
                this.errMsg = 'No JIT Slots are available for JIT Date';
                return;
            }

            if (this.isSalesConsultant)
            {
                let franchise    = this.objectApiName == 'Sales_Agreement__c' ? this.recInfo.FranchiseCode__c : this.recInfo.Franchise_Code__c;
                this.jitDaysList = this.jitDaysList.filter(rec => rec.Franchise__c == franchise);
            }
        }
        if (result.error)
        {
            this.errMsg = result.error.body.message;
        }
    }

    handleSelectSlots(event)
    {
        const radioBtns = this.template.querySelectorAll('input[type="radio"]');
        radioBtns.forEach(item => item.checked = event.target.name === item.name);

        this.selectedJITDay = this.jitDaysList.filter(rec => rec.Id === event.target.name)[0];
        console.log(this.selectedJITDay);
    }

    handleBookSlot(event)
    {
        if (this.validation())
        {
            this.spinner = true;

            bookSlot({
                sObjectName  : this.objectApiName,
                recordId     : this.recordId,
                JIT_recordId : this.selectedJITDay.Id
            }).then(result => {
                this.spinner = false;
                this.showNotification('Success!', 'JIT Slot has been booked', 'success', 'dissmissible');

                refreshApex(this.wiredRecs);
            }).catch(error => {
                // this.errMsg = error.body.message || 'An error occurred. Please contact your System Admin';

                this.showNotification('Error!', error.body.message, 'error', 'dissmissible');

                this.spinner = false;
            })
        }
    }

    handleCancelSlot(event)
    {
        this.spinner = true;

        cancelSlot({
            objAPINm : this.objectApiName,
            recordId : this.recordId
        }).then(result => {
            this.spinner = false;
            this.showNotification('Warning!', 'JIT Slot has been cancelled!', 'warning', 'dissmissible');

            refreshApex(this.wiredRecs);
        }).catch(error => {
            // this.errMsg = error.body.message || 'An error occurred. Please contact your System Admin';

            this.showNotification('Error!', error.body.message, 'error', 'dissmissible');

            this.spinner = false;
        })
    }

    validation()
    {
        if (!this.isSalesAdmin && !this.isSalesConsultant)
        {
            this.showNotification('Error!', 'You don\'t have permission to book JIT Slot. Please check with your System Admin!', 'error', 'dissmissible');

            return false; 
        }

        if (!this.selectedJITDay)
        {
            this.showNotification('Error!', 'Please choose JIT Slot!', 'error', 'dissmissible');

            return false;
        }

        if (this.selectedJITDay.Remaining_Slots__c == 0)
        {
            this.showNotification('Error!', 'Slot is fully booked. Please try another slot!', 'error', 'dissmissible');

            return false;
        }

        if (this.isSalesConsultant && currentTime > timeToUpdate)
        {
            this.showNotification('Error!', 'Sales Consultant are not allowed to book JIT Slot after 12 p.m!', 'error', 'dissmissible');

            return false;
        }

        return true;
    }

    showNotification(title, message, variant, mode)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    deepClone(data)
    {
        return JSON.parse(JSON.stringify(data));
    }

    convertStringToDate(dateStr)
    {
        let [year, month, day] = dateStr.split('-');

        return new Date(+year, month - 1, +day);
    }
}