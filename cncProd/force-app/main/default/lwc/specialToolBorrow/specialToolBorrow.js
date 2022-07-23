import { LightningElement, track } from 'lwc';
import getRunningUser from '@salesforce/apex/specialToolController.getRunningUser';
import getUserInfo from '@salesforce/apex/specialToolController.getUserInfo';
import getTool from '@salesforce/apex/specialToolController.getTool';
import borrowTools from '@salesforce/apex/specialToolController.borrowTools';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class SpecialToolBorrow extends LightningElement {

    @track runningUser;
    @track userInfo_AccessCode;
    @track userInfo_Name;
    @track userInfo_Id;
    @track userInfo_Location;
    @track userInfo_Department;
    @track partNo;
    @track tools = [];
    @track toolIds = [];
    @track buttonDisable = true;
    @track toolsBorrowed;
    @track totalTool;
    @track spinner = false;

    toolOptions = [];
    toolsByPartNo = [];
    displayToolList = false;
    toolVal;

    connectedCallback(){
        this.spinner = true;
        getRunningUser()
        .then(result => {
            if(result){
                this.runningUser = result;
                console.log(result);
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
                // this.getTool();
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
                this.getTool();
                break;
        }
    }

    getUserInfo(){
        console.log(this.userInfo_AccessCode);
        this.spinner = true;
        getUserInfo({accessCode : this.userInfo_AccessCode})
        .then(result => {
            if (result) {
                this.userInfo_Name = result.Name;
                this.userInfo_Department = result.Department__c;
                this.userInfo_Id = result.Id;
                this.userInfo_Location = result.Location__c;
                console.log(result); 
            } else {
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

    /*getTool(){
        this.spinner = true;
        getTool({partNo : this.partNo})
        .then(result => {
            if (result == 'ToolNotAvailable') {
                this.toast('ERROR', 'Tool is unavailable for borrowing by another user', null, 'error', 'dissmissible');
            } else if (result == 'Empty') {
                this.toast('ERROR', 'Invalid Part Number!', null, 'error', 'dissmissible');
            } else {
                this.displayToolList = true;
                if (!this.toolIds.includes(result.Id)) {
                    this.tools.push(result);
                    this.toolIds.push(result.Id);
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
            console.log(error);
            this.disableButton();
            this.spinner = false;
        });
    }*/

    getTool() {
        this.spinner = true;
        getTool({partNo : this.partNo})
        .then(result => {
            this.toolOptions = [];
            if (result.length === 0) {
                this.displayToolList = false;
                this.toast('ERROR', 'Tools either being borrowed or not exist. Please check again!', null, 'error', 'dissmissible');
            } else {
                this.displayToolList = true;
                this.toolsByPartNo = result;
                result.forEach(tool => {
                    this.toolOptions.push({
                        label: tool.Name,
                        value: tool.Id,
                    })
                });
                this.toolVal = this.toolOptions[0].value;
                if (!this.toolIds.includes(this.toolVal)) {
                    this.tools.push(this.toolsByPartNo.filter(tool => tool.Id === this.toolVal)[0]);
                    this.toolIds.push(this.toolVal);
                    this.buttonDisable = false;
                }
            }
            this.clearInputVal("PartNo");
            // this.disableButton();
            this.spinner = false;
        })
        .catch(error => {
            console.log(error);
            this.disableButton();
            this.spinner = false;
        });
    }

    handleSelectTool(event) {
        this.toolVal = event.currentTarget.value;
        if (!this.toolIds.includes(this.toolVal)) {
            let tool = this.toolsByPartNo.filter(tool => tool.Id === this.toolVal)[0];
            this.tools.push(tool);
            this.toolIds.push(this.toolVal);
            this.partNo = '';
        } else {
            this.toast('ERROR', 'Tool is already in the list', null, 'error', 'dissmissible');
        }
        this.disableButton();
    }

    handleDeleteTool(event){
        let index = event.currentTarget.dataset.rowIndex;
        this.tools.splice(index, 1);
        this.toolIds.splice(index, 1);
        this.disableButton();
    }

    disableButton(){
        if (this.tools.length > 0 && this.userInfo_Name != null){
            this.buttonDisable = false;
        }else{
            this.buttonDisable = true;
            let toolOptionsEl = this.template.querySelector(`[data-id="tool_options"]`)
            if (toolOptionsEl) {
                toolOptionsEl.value = null;
            }
            this.toolVal = null;
        }
        
    }
    
    submitToBorrow(){
        this.spinner = true;
        borrowTools({userId : this.userInfo_Id, tools: this.tools})
        .then(result => {
            if(result){
                const fieldToClear = this.template.querySelector(".AccessCode");
                fieldToClear.value = '';
                this.clearInputVal("PartNo");
                this.userInfo_AccessCode = '';
                this.clearUserInfo();

                this.popUpToolsBorrowed(result);

                console.log(result);
            }
            this.spinner = false;
            
        })
        .catch(error => {
            console.log(error);
            this.spinner = false;
        });
    }

    popUpToolsBorrowed(result){
        this.toolsBorrowed = result;
        this.totalTool = this.toolsBorrowed.length;
    }

    closeToolsBorrowedPopup(){
        this.toolsBorrowed = null;
        this.disableButton();
    }

    clearUserInfo(){
        this.userInfo_Name = null;
        this.userInfo_Id = null;
        this.userInfo_Location = null;
        this.userInfo_Department = null;
        this.toolOptions = [];
        this.tools = [];
        this.toolIds = [];
    }

    showDetail(event){
        let index = event.currentTarget.dataset.index;
        let link = `${window.location.protocol}//${window.location.hostname}/${this.tools[index].Id}`;
        console.log(link);
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

    clearInputVal(inputNm) {
        this.template.querySelector(`.${inputNm}`).value = null;
    }
}