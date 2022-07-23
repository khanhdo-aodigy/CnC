import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import VEHICLE_REQUEST_OBJECT from '@salesforce/schema/Vehicle_Request__c';
import MAINTENANCE_FIELD from '@salesforce/schema/Vehicle_Request__c.Maintenance_Reason__c';
import MAINTENANCE_LOCATION from '@salesforce/schema/Vehicle_Request__c.Maintenance_Location__c';
import MBTDMC_CHANNEL from '@salesforce/messageChannel/MBTDMC__c';
import getTradePlates from '@salesforce/apex/MB_TestDriveController.getTradePlates';
import searchPersonAccount from '@salesforce/apex/MB_TestDriveController.searchPersonAccount';
import createVehicleRequest from '@salesforce/apex/MB_TestDriveController.createVehicleRequest';
import getHistoryRequest from '@salesforce/apex/MB_TestDriveController.getHistoryRequest';
import generateIndemnityForm from '@salesforce/apex/MB_TestDriveController.generateIndemnityForm';


export default class Mb_TDBooking extends LightningElement {
    get acceptedFormats() {
        return ['.jpg','.png'];
    }

    requestTypesPL;
    defaultReqType;
    tradePlatePL            = [];
    wireTradePlates;
    maintenanceReasonsPL;
    maintenanceLocationPL;

    historyRequests         = [];
    vehicleInfo             = {};
    pdpaAgree;

    emptySignature          = false;
    isMaintenanceRequest    = false;
    isLoanRequest           = false;
    isLoanOrMaintenance     = false;
    displayMaintenancePL    = false;

    frontLicenseFile        = {};
    backLicenseFile         = {};
    uploadedFrontLicense    = {};
    uploadedBackLicense     = {};

    changes                 = {};
    spinner;

    constructor() {
        super();
        this.template.addEventListener('signurl', this.onDataUrl.bind(this));
    }

    @wire (MessageContext)
    messageContext;

    @wire(getObjectInfo, { objectApiName: VEHICLE_REQUEST_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: MAINTENANCE_FIELD
    }) reasonPicklist({ data, error }) {
        if (data) {
            this.maintenanceReasonsPL = data.values;
        } else if (error) {
            this.maintenanceReasonsPL = undefined;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: MAINTENANCE_LOCATION
    }) serviceCenterPicklist({ data, error }) {
        if (data) {
            this.maintenanceLocationPL = data.values;
        } else if (error) {
            this.maintenanceLocationPL = undefined;
        }
    }

    @wire(getTradePlates, {})
    wireProps(result) {
        this.wireTradePlates = result;
        if (result.error) {
            console.log(result.error);
        } else if (result.data) {
            let tmpTradePlates = [ { label: '---- None ----', value: null } ];
            for (let tp of result.data) {
                tmpTradePlates.push({
                    label: tp.Name,
                    value: tp.Id
                })
            }
            this.tradePlatePL = tmpTradePlates;
        }
    }

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
        this.subscribeToMessageChannel();
    }
  
    disconnectedCallback() {
        this.unsubscribeToMessageChannel;
        this.template.removeEventListener('signurl');
    }

    handleMessage(message) {
        let message_ = this.deepClone(message);
        let action = message_.action;
        switch(action) {
           case '__mb_td_booking':
                this.requestTypesPL = message_.data.requestOptions;
                this.vehicleInfo = message_.data.vehicleInfo;
                if (this.changes['Courtesy_Vehicle__c'] !== this.vehicleInfo.Id && this.changes['__matchPA']) {
                    this.getHistoryRequest(this.vehicleInfo.Id, this.changes['__matchPA']);
                }
                this.defaultReqType = 'Test Drive';
                this.changes['Test_Drive_Type__c'] = this.defaultReqType;
                this.changes['Courtesy_Vehicle__c'] = this.vehicleInfo.Id;
                break;
           default:
                break;
        }
    }

    handleInputChange(event) {
        let inputNm = event.currentTarget.name;
        let val     = event.currentTarget.value;

        switch (inputNm) {
            case 'front_license':
                if (event.target.files.length > 0) {  
                    this.frontLicenseFile.content   = event.target.files[0];
                    this.frontLicenseFile.fileName  = 'Front_License.' + event.target.files[0].type.split("/").pop();
                    this.uploadHelper(true, this.frontLicenseFile, 'front_license');
                }
                break;
            case 'back_license':
                if (event.target.files.length > 0) {
                    this.backLicenseFile.content    = event.target.files[0];
                    this.backLicenseFile.fileName   = 'Back_License.' + event.target.files[0].type.split("/").pop();
                    this.uploadHelper(false, this.backLicenseFile, 'back_license');
                }
                break;
            case 'Test_Drive_Type__c':
                if (val == 'Maintenance') {
                    this.isLoanOrMaintenance    = true;
                    this.isMaintenanceRequest   = true;
                    this.isLoanRequest          = false;
                } else if (val == 'Loan') {
                    this.isLoanOrMaintenance    = true;
                    this.isLoanRequest          = true;
                    this.isMaintenanceRequest   = false;
                } else {
                    this.isLoanRequest          = false;
                    this.isLoanOrMaintenance    = false;
                    this.isMaintenanceRequest   = false;
                }
                this.resetPropsAndInputs();
                break;
            case 'PDPA_Agreed__c':
                this.pdpaAgree = !this.pdpaAgree;
                break;
            default:
                break;
        }

        this.changes[inputNm] = val;
    }

    handleSearchPA(event) {
        let inputNm = event.currentTarget.name;
        let val     = event.currentTarget.value;
        if (inputNm == 'PersonEmail') {
            this.searchPA(null, val);
        } else {
            this.searchPA(val, null);
        }
    }

    searchPA(mobile, email) {
        if (mobile == null && email == null) {
            return;
        }

        this.spinner = true;
        searchPersonAccount({
            mobile: mobile,
            email: email,
        }).then(result => {
            if (result != null && result.length > 0) {
                this.changes['Full_Name__pc']           = result[0]['Full_Name__pc'];
                this.changes['PersonMobilePhone']       = result[0]['PersonMobilePhone'];
                this.changes['PersonEmail']             = result[0]['PersonEmail'];
                this.changes['FirstName']               = result[0]['FirstName'];
                this.changes['LastName']                = result[0]['LastName'];
                this.changes['Address_Line_1__pc']      = result[0]['Address_Line_1__pc'];
                this.changes['Address_Line_2__pc']      = result[0]['Address_Line_2__pc'];
                this.changes['Address_Line_3__pc']      = result[0]['Address_Line_3__pc'];
                this.changes['Address_Line_4__pc']      = result[0]['Address_Line_4__pc'];
                this.changes['Unit_No_Floor__pc']       = result[0]['Unit_No_Floor__pc'];
                this.changes['__matchPA']               = result[0]['Id'];

                let inputs = this.template.querySelectorAll('lightning-input');
                for (let input of inputs) {
                    input.value = this.changes[input.name];
                }

                if (result[0]['SMS__pc'] || result[0]['Call__pc'] || result[0]['Email__pc'] || result[0]['Fax__pc']) {
                    this.pdpaAgree = true;
                }
                this.getHistoryRequest(this.vehicleInfo.Id, result[0]['Id']);
            } else {
                this.changes['__matchPA'] = null;
                this.historyRequests = [];
                this.pdpaAgree = false;
            }
            this.spinner = false;
        }).catch(error => {
            this.showNotification('Error!', 'An error occurred in find existing customer information: ' + error.body.message + '. Please contact your Administrator!', 'error');
            this.spinner = false;
        })
    }

    getHistoryRequest(vehicleId, paId) {
        getHistoryRequest({
            vehId: vehicleId,
            paId: paId
        }).then(reqsResult => {
            this.historyRequests = reqsResult;
            for (let req of this.historyRequests) {
                req.CreatedDate = this.formatDdt(req.CreatedDate);
            }
        }).catch(error => {
            console.log(error);
            this.showNotification('Error!', 'An error occurred in retrieving customer history request: ' + error.body.message + '. Please contact your Administrator!', 'error');
        })
    }

    handleConfirm(event) {
        let actionNm = event.target.name;
        if (this.validate()) {
            this.changes['PDPA_Agreed__c'] = this.pdpaAgree;
            this.spinner = true;
            createVehicleRequest({
                info: this.changes,
                frontLicense: this.uploadedFrontLicense,
                backLicense: this.uploadedBackLicense
            }).then(result => {
                console.log('request @@ ' , result);
                if (!this.isLoanOrMaintenance) {
                    this.generateForm(result.Status__c, result.Id, actionNm);
                } else {
                    this.handleAfterBooking(true, result.Status__c, result.Id, null);
                    this.spinner = false;
                }
            })
            .catch(error => {
                this.spinner = false;
                this.showNotification('Error!', error.body.message, 'error');
            })
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
  
    validateRequiredInputs() {
        let passed = true;
        let allInputValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, input) => {
                    input.reportValidity();
                    return validSoFar && input.checkValidity();
        }, true);
        let allCbbValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, input) => {
                        input.reportValidity();
                        return validSoFar && input.checkValidity();
            }, true);
        let radioGroupValid = [...this.template.querySelectorAll('lightning-radio-group')]
        .reduce((validSoFar, input) => {
                    input.reportValidity();
                    return validSoFar && input.checkValidity();
        }, true);

        if (!allInputValid || !allCbbValid || !radioGroupValid) {
            passed = false;
            this.showNotification('Warning!', 'Please fill in required details!', 'warning', 'dismissible');
        }

        return passed;
    }

    validateTradePlate() {
        let passed = true;

        if (this.isLoanOrMaintenance) return passed;

        let tradePlateId = this.changes['Trade_Plate__c'];
        if (this.vehicleInfo.Registration_No__c && tradePlateId) {
            this.showNotification('Warning!', 'This vehicle does not require Trade Plate. Please remove selection!', 'warning', 'dismissible');
            passed = false;
        } else if (!this.vehicleInfo.Registration_No__c && !tradePlateId) {
            this.showNotification('Warning!', 'This vehicle requires Trade Plate. Please select one!', 'warning', 'dismissible');
            passed = false;
        }

        return passed;
    }

    validate() {
        let validateRequiredInput = this.validateRequiredInputs();
        let validateTradePlate = this.validateTradePlate();
        this.getSignatureData();

        let uploadPhoto = true;
        if (!this.isLoanOrMaintenance) {
            uploadPhoto = Object.keys(this.uploadedBackLicense).length !== 0 && Object.keys(this.uploadedFrontLicense).length !== 0 ? true : false;
            if (!uploadPhoto) {
                this.showNotification('Warning!', 'Please upload Driving\'s Licenses!', 'warning', 'dismissible');
            }
        } else if (this.emptySignature) {
            this.emptySignature = false;
        }

        // if (this.isLoanOrMaintenance && this.emptySignature) this.emptySignature = false;

        console.log('input validated        :: ', validateRequiredInput);
        console.log('trade plate validated  :: ', validateTradePlate);
        console.log('signature validated    :: ', this.emptySignature);
        console.log('photo validated        :: ', uploadPhoto);

        return validateRequiredInput && validateTradePlate && !this.emptySignature && uploadPhoto;
    }

    clearSignature() {
        let signingPad = this.template.querySelector(`[data-id="sign_pad"]`);
        if (signingPad !== null && signingPad !== undefined) {
            signingPad.clear();
            this.emptySignature = true;
        }
    }

    getSignatureData() {
        let signingPad = this.template.querySelector(`[data-id="sign_pad"]`);
        if (signingPad !== null && signingPad !== undefined) signingPad.toDataUrl();
    }

    onDataUrl(payload) {
        this.emptySignature = payload.detail.isEmpty;
        if (this.emptySignature) {
            this.showNotification('Warning!', 'Signature is missing. Please check again!', 'warning', 'dismissible');
        } else {
            this.changes['Customer_Signature__c'] = '<img src=\"' + payload.detail.dataURL + '\" height="75" width="150">';
        }
    }

    generateForm(reqStatus, reqId, actionNm) {
        generateIndemnityForm({
            reqId: reqId
        }).then(result => {
            this.handleAfterBooking(false, reqStatus, reqId, actionNm);
            this.spinner = false;
        })
        .catch(error => {
            this.spinner = false;
            this.showNotification('Error!', 'An error occurred in generating Indemnity Form: ' + error + '. Please contact your Administrator!', 'error');
        })
    }

    handleAfterBooking(isLoanOrMaintenance, reqStatus, reqId, actionNm) {
        let msg = reqStatus == 'Queued' ? 'You have been added to Queued!' : 'Vehicle has been checked-out!';
        this.showNotification('Success!', msg, 'success');

        if (isLoanOrMaintenance) {
            window.open('https://' + window.location.host + '/' + reqId, '_blank');
        }

        refreshApex(this.wireTradePlates);
        this.resetPropsAndInputs();
        this.fireLMSEvent('__mb_td_req_submitted', null);

        if (actionNm == 'save' || isLoanOrMaintenance) {
            this.dispatchEvent(new CustomEvent('cancel'));
        }
    }

    resetPropsAndInputs() {
        this.pdpaAgree            = false;
        this.historyRequests      = [];
        this.frontLicenseFile     = {};
        this.backLicenseFile      = {};
        this.uploadedFrontLicense = {};
        this.uploadedBackLicense  = {};

        this.clearSignature();

        for (let prop of Object.keys(this.changes)) {
            if (prop == 'Test_Drive_Type__c' || prop == 'Courtesy_Vehicle__c') continue;

            this.changes[prop] = null;
        }
    
        let r_inputs = this.template.querySelectorAll(`[data-type="r_input"]`);
        for (let input of r_inputs) {
            if (input.name == 'Test_Drive_Type__c') continue;

            input.value = null;
            input.checked = false;
        }

        let photoElms = this.template.querySelectorAll(`[data-type="r_photos"]`);
        if (photoElms) {
            for (let el of photoElms) {
                el.src = '';
            }
        }
    }

    uploadHelper(isFrontLicense, licenseFile, dataId) {
        const fileReader = new FileReader();
        fileReader.onload = event => {
            const image = new Image();
            image.src = event.target.result;
            image.onload = () => {
                const canvas = document.createElement("canvas");
                const ctx = canvas.getContext("2d");
                const width = 480;
                const height = 480;

                canvas.width = width;
                canvas.height = height;

                canvas.height = canvas.width * (image.height / image.width);

                ctx.drawImage(
                    image,
                    0,
                    0,
                    image.width,
                    image.height,
                    0,
                    0,
                    canvas.width,
                    canvas.height
                );
                ctx.rotate((90 * Math.PI) / 180);

                const fileURL = canvas.toDataURL(licenseFile.content.type);
                let uploadedFile = {};
                uploadedFile["fileName"] = licenseFile.fileName;
                uploadedFile["contentType"] = licenseFile.content.type;
                uploadedFile["body"] = encodeURIComponent(fileURL.match(/,(.*)$/)[1]);
                if (isFrontLicense) {
                    this.uploadedFrontLicense = uploadedFile;
                } else {
                    this.uploadedBackLicense = uploadedFile;
                }
                this.template.querySelector(`[data-id="${dataId}"]`).src = fileURL;
            };
        };
        fileReader.readAsDataURL(licenseFile.content);
    }

    formatDdt(dateInput) {
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
}