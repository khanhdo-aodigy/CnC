import { LightningElement, track, wire } from 'lwc';
import getRunningUser from '@salesforce/apex/specialToolController.getRunningUser';
import getUserInfo from '@salesforce/apex/specialToolController.getUserInfo';
import getToolBooking from '@salesforce/apex/specialToolController.getToolBooking';
import returnTool from '@salesforce/apex/specialToolController.returnTool';
// import getPickListLocation from '@salesforce/apex/specialToolController.getPickListLocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SpecialToolReturn extends LightningElement {
    @track runningUser;
    @track userInfo_AccessCode;
    @track userInfo_Name;
    @track userInfo_Id;
    @track userInfo_Location;
    @track userInfo_Department;
    @track partNo;
    @track toolBookings = [];
    @track toolBookingIds = [];
    @track buttonDisable = true;
    @track toolsBorrowed;
    @track totalTool;
    @track spinner = false;
    // @track location;
    
    @track options= [];

    toolBookingOptions = [];
    toolBookingsByPartNo = [];
    displayToolList = false;
    toolBookingVal;

    // @wire(getPickListLocation)
    // wiredData({ error, data }) {
    //   if (data) {
    //     data.forEach(element => {
    //         this.options.push({label: element, value: element})
    //     });
    //   } else if (error) {
    //     console.error('Error:', error);
    //   }
    // }

    connectedCallback(){
        this.spinner = true;
        getRunningUser()
        .then(result => {
            if(result){
                this.runningUser = result;
            }
            this.spinner = false;
            
        })
        .catch(error => {
            console.log(error);
            this.spinner = false;
        });

    }

    scanBarCode(event){
        let value = event.currentTarget.value;
        switch (event.currentTarget.name) {
            case 'AccessCode':
                this.userInfo_AccessCode = value;
                // this.getUserInfo();
                break;
            case 'PartNo':
                this.partNo = value;
                // this.getToolBooking();
                break;
            }
    }

    handleKeyUp(event) {
        if (event.keyCode != 13) return;

        switch (event.currentTarget.name) {
            case 'AccessCode':
                this.getUserInfo();
                break;
            case 'PartNo':
                this.getToolBooking();
                break;
        }
    }

    getUserInfo(){
        console.log(this.userInfo_AccessCode);
        this.spinner = true;
        getUserInfo({accessCode : this.userInfo_AccessCode})
        .then(result => {
            if(result){
                this.userInfo_Name = result.Name;
                this.userInfo_Department = result.Department__c;
                this.userInfo_Id = result.Id;
                this.userInfo_Location = result.Location__c;
                // this.location = result.Location__c;
                console.log(result); 
            }else{
                this.clearUserInfo();
                this.toast('ERROR', 'Invalid User!', null, 'error', 'dissmissible');
            }
            this.clearInputVal("AccessCode");
            this.disableButton();
            this.spinner = false;
        })
        .catch(error => {
            this.clearUserInfo();
            this.disableButton();
            console.log(error);
            this.spinner = false;
        });
    }

    /*getToolBooking(){
        this.spinner = true;
        getToolBooking({partNo : this.partNo})
        .then(result => {
            if (result == 'Empty') {
              //  this.toolbooking = null;     
                this.toast('ERROR', 'Invalid Part Number!', null, 'error', 'dissmissible');
            } else if (result == 'ToolIsAvailable') {
             //   this.toolbooking = null;
                this.toast('ERROR', 'Tool not borrowed and cannot be returned', null, 'error', 'dissmissible');
            } else {
                if (!this.toolBookingIds.includes(result.Id)){
                    this.toolBookings.push(result);
                    this.toolBookingIds.push(result.Id);
                    this.partNo = '';
                } else {
                    this.toast('ERROR', 'Tool is already in the list', null, 'error', 'dissmissible');
                }
            }
            this.clearInputVal("PartNo");
            this.disableButton();
            this.spinner = false;
        })
        .catch(error => {
          //  this.toolbooking = null;
            console.log(error);
            this.disableButton();
            this.spinner = false;
        });
        
    }*/

    getToolBooking(){
        this.spinner = true;
        getToolBooking({partNo : this.partNo, userId: this.userInfo_Id})
        .then(result => {
            this.toolBookingOptions = [];
            if (result.length === 0) {
                this.displayToolList = false;
                this.toast('ERROR', 'Tools either can\'t be returned or not exist. Please check again!', null, 'error', 'dissmissible');
            } else {
                this.displayToolList = true;
                this.toolBookingsByPartNo = result;
                result.forEach(tool => {
                    this.toolBookingOptions.push({
                        label: tool.Special_Tool__r.Name,
                        value: tool.Id,
                    })
                });
                this.toolBookingVal = this.toolBookingOptions[0].value;
                if (!this.toolBookingIds.includes(this.toolBookingVal)){
                    this.toolBookings.push(this.toolBookingsByPartNo.filter(toolBooking => toolBooking.Id === this.toolBookingVal)[0]);
                    this.toolBookingIds.push(this.toolBookingVal);
                }
            }
            this.clearInputVal("PartNo");
            this.disableButton();
            this.spinner = false;
        })
        .catch(error => {
            console.log(error);
            this.disableButton();
            this.spinner = false;
        });
        
    }

    handleSelectTool(event) {
        this.toolBookingVal = event.currentTarget.value;
        if (!this.toolBookingIds.includes(this.toolBookingVal)){
            let toolBooking = this.toolBookingsByPartNo.filter(toolBooking => toolBooking.Id === this.toolBookingVal)[0];
            this.toolBookings.push(toolBooking);
            this.toolBookingIds.push(this.toolBookingVal);
            this.partNo = '';
        } else {
            this.toast('ERROR', 'Tool is already in the list', null, 'error', 'dissmissible');
        }
        this.disableButton();
    }

    handleDeleteTool(event){
        let index = event.currentTarget.dataset.rowIndex;
        this.toolBookings.splice(index, 1);
        this.toolBookingIds.splice(index, 1);
        this.disableButton();
    }

    disableButton(){
        if(this.toolBookings.length > 0 && this.userInfo_Name != null /*&& this.location != null*/){
            this.buttonDisable = false;
        } else {
            this.buttonDisable = true;
            let toolBookingOptionsEl = this.template.querySelector(`[data-id="tool_booking_options"]`)
            if (toolBookingOptionsEl) {
                toolBookingOptionsEl.value = null;
            }
        }
        
    }
    
    submitToReturn(){
        this.spinner = true;
        returnTool({userId : this.userInfo_Id, toolBookings: this.toolBookings, location: /*this.location*/ this.userInfo_Location})
        .then(result => {
            this.toast('SUCCESS', 'Tools are successfully returned', null, 'success', 'dissmissible');

            const fieldToClear = this.template.querySelector(".AccessCode");
            fieldToClear.value = '';
            this.clearInputVal("PartNo");
            this.userInfo_AccessCode = '';
            this.clearUserInfo();

            this.disableButton();
            this.spinner = false;
        })
        .catch(error => {
            console.log(error);
            this.spinner = false;
        });
    }

    showDetail(event){
        let index = event.currentTarget.dataset.index;
        let link = `${window.location.protocol}//${window.location.hostname}/${this.toolBookings[index].Special_Tool__r.Id}`;
        window.open(link, "_blank");   
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

    clearUserInfo(){
        this.userInfo_Name = null;
        this.userInfo_Id = null;
        this.userInfo_Location = null;
        this.userInfo_Department = null;
        // this.location = null;
        this.toolBookingOptions = [];
        this.toolBookings = [];
        this.toolBookingIds = [];
    }


    /*handleValue(event){
        let value = event.currentTarget.value;
        switch (event.currentTarget.name) {
            case 'Location':
                this.location = value;
                break;
            }
            this.disableButton();
    }*/

    clearInputVal(inputNm) {
        this.template.querySelector(`.${inputNm}`).value = null;
    }
}