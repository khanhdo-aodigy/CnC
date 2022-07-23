import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import MBTDMC_CHANNEL from '@salesforce/messageChannel/MBTDMC__c';
import constructTestDriveWrapper from '@salesforce/apex/MB_TestDriveController.constructTestDriveWrapper';
import checkDailyLogExist from '@salesforce/apex/MB_TestDriveController.checkDailyLogExist';
import processVehicleRequest from '@salesforce/apex/MB_TestDriveController.processVehicleRequest';
import getProfile from '@salesforce/apex/MB_TestDriveController.getProfile';


export default class Mb_TDVehiclesSummary extends NavigationMixin (LightningElement) {
    expandStatus = false;
    queuesOpened = false;

    wrapperResult           = [];
    queuedRequestsByVehId   = [];
    requestOptions          = [
                                { label: 'Test Drive', value: 'Test Drive' },
                                { label: 'Loan', value: 'Loan' },
                                { label: 'Maintenance', value: 'Maintenance' },
                              ];

    wiredRecs;
    spinner;

    @wire(MessageContext)
    messageContext;

    subscription = null;

    subscribeToMessageChannel() {
        if (this.subscription) return;

        this.subscription = subscribe(this.messageContext, MBTDMC_CHANNEL, (message) => {
              this.handleMessage(message);
           }
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    connectedCallback() {
        this.processReqTypes();
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel;
    }

    handleMessage(message) {
        let message_ = this.deepClone(message);
        let action = message_.action;
        switch(action) {
           case '__mb_td_req_submitted':
                refreshApex(this.wiredRecs);
                break;
           default:
                break;
        }
    }

    processReqTypes() {
        getProfile({}).then(result => {
            switch(result) {
                case 'MB Sales Manager':
                    // this.removeByAttr(this.requestOptions, 'value', ['Test Drive']);
                    break;
                case 'MB Sales':
                    this.removeByAttr(this.requestOptions, 'value', ['Loan']);
                    break;
                default:
                    break;
            }
        })
    }

    @wire(constructTestDriveWrapper, {})
    wireProps(result) {
        this.wiredRecs = result;
        if (result.error) {
            this.showNotification('ERROR!', result.error, 'error', 'sticky');
        } else if (result.data) {
            this.wrapperResult = this.deepClone(result.data);
            let cnt = 0;
            for (let wrapper of this.wrapperResult)
            {
                cnt++;
                wrapper.index  = cnt;
                wrapper.status = wrapper.vehicleInfo.Is_Present__c ? 'Available' : 'Ongoing Test Drive';
                if (wrapper.ownerRequests) {
                    for (let req of wrapper.ownerRequests) {
                        req.reqInfo.Check_In__c = this.formatDdt(req.reqInfo.Check_In__c);
                        req.reqInfo.Check_Out__c = this.formatDdt(req.reqInfo.Check_Out__c);
                    }
                }
            }
            console.log(this.wrapperResult);
        }
    }

    handleBtnAction(event) {
        let vehicleId = event.currentTarget.dataset.vehicleId;
        let actionNm  = event.currentTarget.name;
        switch (actionNm) {
            case 'checkout':
                this.processBooking(vehicleId);
                break;
            case 'queue':
                this.openQueues(vehicleId);
                break;
        }
    }

    processBooking(vehicleId) {
        this.spinner = true;
        checkDailyLogExist({
            vehicleId: vehicleId
        }).then(result => {
            if (!result) {
                this.showNotification('Warning!', 'Unable to retrieve Opening Log. Please contact Duty Sales Executive!', 'warning', 'dismissible');
                this.spinner = false;
                return;
            } else {
                this.spinner = false;
                let vehWrapper = this.wrapperResult.filter(result => result.vehicleInfo.Id === vehicleId)[0];
                let doubleBook = false;
                let queuedAfterLoanOrMaintenanceReq = false;
                if (vehWrapper.ownerRequests && vehWrapper.ownerRequests.length > 0) {
                    for (let req of vehWrapper.ownerRequests) {
                        if (req.isCheckedOut || req.isQueued) {
                            this.showNotification('Warning!', 'You have an Ongoing or Queued request. Please check-in/cancel your existing booking first!', 'warning', 'dismissible');
                            doubleBook = true;
                            return;
                        }
                    }
                }
                if (vehWrapper.queuedTestDriveRequests && vehWrapper.queuedTestDriveRequests.length > 0) {
                    for (let req of vehWrapper.queuedTestDriveRequests) {
                        if (req.Test_Drive_Type__c == 'Loan' || req.Test_Drive_Type__c == 'Maintenance') {
                            this.showNotification('Warning!', 'This vehicle will be checked-out for ' + req.Test_Drive_Type__c + ' soon. You can not proceed to check-out anymore!', 'warning', 'dismissible');
                            queuedAfterLoanOrMaintenanceReq = true;
                            return;
                        }
                    }
                }
                if (!doubleBook && !queuedAfterLoanOrMaintenanceReq) {
                    let payload = { vehicleInfo: vehWrapper.vehicleInfo, requestOptions : this.requestOptions };
                    this.fireLMSEvent('__mb_td_booking', payload);
                    this.dispatchEvent(new CustomEvent('booking'));
                }
            }
        }).catch(error => {
            this.spinner = false;
            this.showNotification('Error!', 'An error occured: ' + error.body.message, 'error', 'sticky');
        })
    }

    openQueues(vehicleId) {
        this.queuedRequestsByVehId = this.wrapperResult.filter(result => result.vehicleInfo.Id === vehicleId)[0].queuedTestDriveRequests;
        this.queuesOpened = true;
    }

    closeQueues() {
        this.queuesOpened = false;
    }

    handleRequest(event) {
        let type = event.target.name;
        let reqId = event.target.dataset.reqId;
        let vehId = event.target.dataset.vehicleId;
        let currVeh = this.wrapperResult.filter(veh => veh.vehicleInfo.Id == vehId)[0];

        let confirm = window.confirm('Do you wish to ' + type + '?');
        if (confirm) {
            this.spinner = true;
            processVehicleRequest({
                type: type,
                currReqId: reqId,
            }).then(result => {
                this.spinner = false;
                switch (type) {
                    case 'Check In':
                        this.showNotification('Success!', 'Vehicle has been checked-in.', 'success', 'dismissible');
                        if (currVeh.closingLogExist) {
                            window.open('https://' + window.location.host + '/lightning/n/MB_Daily_Log?c__vehicleId=' + vehId, '_self');
                        }
                        break;
                    case 'Check Out':
                        this.showNotification('Success!', 'Vehicle has been checked-out.', 'success', 'dismissible');
                        break;
                    case 'Cancel':
                        this.showNotification('Warning!', 'Test Drive has been cancelled.', 'warning', 'dismissible');
                        break;
                    default:
                        break;
                }
                refreshApex(this.wiredRecs);
            }).catch(error => {
                this.showNotification('Error!', 'An error has occured: ' + error.body.message, 'error', 'sticky');
                this.spinner = false;
            })
        }
    }

    expandView(event) {
        this.expandStatus = !this.expandStatus;

        let vehicleId = event.currentTarget.dataset.vehicleId;
        let subTable = this.template.querySelector(`[data-sub-id="${vehicleId}"]`);
        if (subTable.style.display == 'initial') {
            subTable.style.display = 'none';
        } else {
            subTable.style.display = 'initial';
        }
    }

    formatDdt(dateInput) {
        if (!dateInput) return null;

        return new Date(dateInput).toLocaleString('en-SG', { timeZone: 'Asia/Singapore', hour12: true });
    }
    
    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    fireLMSEvent(action, data) {
        if (this.messageContext == null) return;

        const payload = {
                            action : action,
                            data   : data
                        };
        publish(this.messageContext, MBTDMC_CHANNEL, payload);
    }

    deepClone(data) {
        return JSON.parse(JSON.stringify(data));
    }

    removeByAttr(arr, attr, values) {
        for (let i = 0; i < arr.length; i++) {
            for (let val of values) {
                if (arr[i][attr] == val) {
                    arr.splice(i, 1);
                }
            }
        }
    }
}