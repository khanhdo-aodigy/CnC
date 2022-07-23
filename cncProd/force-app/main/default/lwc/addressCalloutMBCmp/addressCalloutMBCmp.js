import { LightningElement, api, wire, track } from 'lwc';
import calloutAddressSearch from '@salesforce/apex/CalloutPostalCodeSearchLWC.searchAddressByPostalCode';
import getRecords from '@salesforce/apex/MB_StockReservationCtrl.getRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { updateRecord } from 'lightning/uiRecordApi';

export default class AddressCalloutMBCmp extends LightningElement {
    @api recordId;
    @api cmpTitle;
    @api identifier;

    // objInfo;                                     // MB Sales Agrement object
    @track postalCode;                              // Address Postal Code
    @track streetNm;                                // Address Street Name
    @track buildingNm;                              // Address Building Name
    @track floorUnit;                               // Address Floor/Unit
    @track isErrorPostalCode;

    changes = { fields: {} };
    @track postalCodeAPIField;
    @track streetAPIField;
    @track buildingAPIField;
    @track floorUnitAPIField;
    // initialRender = true;

    @wire(getRecords, {
        objNm: 'MB_Sales_Agreement__c',
        fieldReference: 'Id',
        fieldValue: '$recordId',
        additionalConditions: ''
    })
    wiredProps(result) {
        result.error && console.log('ERROR IN GETTING OBJ :: ' + JSON.stringify(result.error)) && this.toastApexErrorMessage(error);
        if (result.data) {
            // Construct object info
            let objInfo = JSON.parse(JSON.stringify(result.data[0]));
            console.log('aaaa ' + JSON.stringify(objInfo));
            switch (this.identifier) {
                case 'register_address':
                    this.postalCodeAPIField = 'Postal_CodeRA__c';
                    this.streetAPIField = 'Street_NameRA__c';
                    this.buildingAPIField = 'Building_NameRA__c';
                    this.floorUnitAPIField = 'Floor_UnitRA__c';
                    // console.log('obj info:: ' + JSON.stringify(objInfo));
                    this.postalCode = objInfo.Postal_CodeRA__c === undefined ? '' : objInfo.Postal_CodeRA__c;
                    this.streetNm = objInfo.Street_NameRA__c === undefined ? '' : objInfo.Street_NameRA__c;
                    this.buildingNm = objInfo.Building_NameRA__c === undefined ? '' : objInfo.Building_NameRA__c;
                    this.floorUnit = objInfo.Floor_UnitRA__c === undefined ? '' : objInfo.Floor_UnitRA__c;
                    break;
                case 'mailing_address':
                    this.postalCodeAPIField = 'Postal_CodeMA__c';
                    this.streetAPIField = 'Street_NameMA__c';
                    this.buildingAPIField = 'Building_NameMA__c';
                    this.floorUnitAPIField = 'Floor_UnitMA__c';
                    this.postalCode = objInfo.Postal_CodeMA__c === undefined ? '' : objInfo.Postal_CodeMA__c;
                    this.streetNm = objInfo.Street_NameMA__c === undefined ? '' : objInfo.Street_NameMA__c;
                    this.buildingNm = objInfo.Building_NameMA__c === undefined ? '' : objInfo.Building_NameMA__c;
                    this.floorUnit = objInfo.Floor_UnitMA__c === undefined ? '' : objInfo.Floor_UnitMA__c;
                    break;
                case 'seller_address':
                    this.postalCodeAPIField = 'Used_Car_Postal_Code__c';
                    this.streetAPIField = 'Used_Car_Street_Name__c';
                    this.buildingAPIField = 'Used_Car_Building_Name__c';
                    this.floorUnitAPIField = 'Used_Car_Floor_Unit__c';
                    this.postalCode = objInfo.Used_Car_Postal_Code__c == undefined ? '' : objInfo.Used_Car_Postal_Code__c;
                    this.streetNm = objInfo.Used_Car_Street_Name__c == undefined ? '' : objInfo.Used_Car_Street_Name__c;
                    this.buildingNm = objInfo.Used_Car_Building_Name__c == undefined ? '' : objInfo.Used_Car_Building_Name__c;
                    this.floorUnit = objInfo.Used_Car_Floor_Unit__c == undefined ? '' : objInfo.Used_Car_Floor_Unit__c;
                    break;
                default: break;
            }
        }
    }


    // renderedCallback() {
    //     if (this.initialRender) {
    //         this.initialRender = false;
    //         let objInfo;
    //         getRecords({
    //                     objNm: 'MB_Sales_Agreement__c',
    //                     fieldReference: 'Id',
    //                     fieldValue: this.recordId,
    //                     additionalConditions: ''
    //         }).then(result => {
    //             objInfo = JSON.parse(JSON.stringify(result[0]));
    //             console.log(JSON.stringify(objInfo));
    //             switch (this.identifier) {
    //                 case 'register_address':
    //                     this.postalCodeAPIField = 'Postal_CodeRA__c';
    //                     this.streetAPIField = 'Street_NameRA__c';
    //                     this.buildingAPIField = 'Building_NameRA__c';
    //                     this.floorUnitAPIField = 'Floor_UnitRA__c';
    //                     console.log('fdghfdjhgfd:: ' + JSON.stringify(objInfo));
    //                     this.postalCode = objInfo.Postal_CodeRA__c === undefined ? '' : objInfo.Postal_CodeRA__c;
    //                     this.streetNm = objInfo.Street_NameRA__c === undefined ? '' : objInfo.Street_NameRA__c;
    //                     this.buildingNm = objInfo.Building_NameRA__c === undefined ? '' : objInfo.Building_NameRA__c;
    //                     this.floorUnit = objInfo.Floor_UnitRA__c === undefined ? '' : objInfo.Floor_UnitRA__c;
    //                     break;
    //                 case 'mailing_address':
    //                     this.postalCodeAPIField = 'Postal_CodeMA__c';
    //                     this.streetAPIField = 'Street_NameMA__c';
    //                     this.buildingAPIField = 'Building_NameMA__c';
    //                     this.floorUnitAPIField = 'Floor_UnitMA__c';
    //                     this.postalCode = objInfo.Postal_CodeMA__c === undefined ? '' : objInfo.Postal_CodeMA__c;
    //                     this.streetNm = objInfo.Street_NameMA__c === undefined ? '' : objInfo.Street_NameMA__c;
    //                     this.buildingNm = objInfo.Building_NameMA__c === undefined ? '' : objInfo.Building_NameMA__c;
    //                     this.floorUnit = objInfo.Floor_UnitMA__c === undefined ? '' : objInfo.Floor_UnitMA__c;
    //                     break;
    //                 case 'seller_address':
    //                     this.postalCodeAPIField = 'Used_Car_Postal_Code__c';
    //                     this.streetAPIField = 'Used_Car_Street_Name__c';
    //                     this.buildingAPIField = 'Used_Car_Building_Name__c';
    //                     this.floorUnitAPIField = 'Used_Car_Floor_Unit__c';
    //                     this.postalCode = objInfo.Used_Car_Postal_Code__c == undefined ? '' : objInfo.Used_Car_Postal_Code__c;
    //                     this.streetNm = objInfo.Used_Car_Street_Name__c == undefined ? '' : objInfo.Used_Car_Street_Name__c;
    //                     this.buildingNm = objInfo.Used_Car_Building_Name__c == undefined ? '' : objInfo.Used_Car_Building_Name__c;
    //                     this.floorUnit = objInfo.Used_Car_Floor_Unit__c == undefined ? '' : objInfo.Used_Car_Floor_Unit__c;
    //                     break;
    //                 default: break;
    //             }
    //         })
    //     }
    // }

    searchAddress(postalCode) {
        console.log('2');
        calloutAddressSearch({
            postalCode: postalCode
        }).then(result => {
            console.log('Address callout result' + JSON.stringify(result));
            // Handle returned data for each section
            switch (this.identifier) {
                case 'register_address':
                    this.streetNm =  result.ADDRESS !== undefined ? `${result.BLK_NO} ${result.ROAD_NAME} ` : '';
                    console.log('street name:: ' + this.streetNm);
                    this.buildingNm = result.BUILDING !== undefined ? (result.BUILDING === 'NIL' ? '' : result.BUILDING)  : '';
                    this.changes.fields.Street_NameRA__c = this.streetNm;
                    this.changes.fields.Building_NameRA__c = this.buildingNm;

                    // this.template.querySelector(`[data-id="Street_NameRA__c"]`).value = result.ADDRESS !== undefined ? `${result.BLK_NO} ${result.ROAD_NAME} ` : '';
                    // this.template.querySelector(`[data-id="Building_NameRA__c"]`).value = result.BUILDING !== undefined ? (result.BUILDING === 'NIL' ? '' : result.BUILDING)  : '';
                    // // Set value to changes for updating
                    // this.changes.fields.Street_NameRA__c = this.template.querySelector(`[data-id="Street_NameRA__c"]`).value;
                    // this.changes.fields.Building_NameRA__c = this.template.querySelector(`[data-id="Building_NameRA__c"]`).value;
                    break;
                case 'mailing_address':
                    this.streetNm = result.ADDRESS !== undefined ? `${result.BLK_NO} ${result.ROAD_NAME} ` : '';
                    this.buildingNm = result.BUILDING !== undefined ? (result.BUILDING === 'NIL' ? '' : result.BUILDING)  : '';
                    this.changes.fields.Street_NameMA__c = this.streetNm;
                    this.changes.fields.Building_NameMA__c = this.buildingNm;

                    // this.template.querySelector(`[data-id="Street_NameMA__c"]`).value = result.ADDRESS !== undefined ? `${result.BLK_NO} ${result.ROAD_NAME} ` : '';
                    // this.template.querySelector(`[data-id="Building_NameMA__c"]`).value = result.BUILDING !== undefined ? (result.BUILDING === 'NIL' ? '' : result.BUILDING)  : '';
                    // // Set value to changes for updating
                    // this.changes.fields.Street_NameMA__c = this.template.querySelector(`[data-id="Street_NameMA__c"]`).value;
                    // this.changes.fields.Building_NameMA__c = this.template.querySelector(`[data-id="Building_NameMA__c"]`).value;
                    break;
                case 'seller_address':
                    this.streetNm = result.ADDRESS !== undefined ? `${result.BLK_NO} ${result.ROAD_NAME} ` : '';
                    this.buildingNm = result.BUILDING !== undefined ? (result.BUILDING === 'NIL' ? '' : result.BUILDING)  : '';
                    this.changes.fields.Used_Car_Street_Name__c = this.streetNm;
                    this.changes.fields.Used_Car_Building_Name__c = this.buildingNm;

                    // this.template.querySelector(`[data-id="Used_Car_Street_Name__c"]`).value = result.ADDRESS !== undefined ? `${result.BLK_NO} ${result.ROAD_NAME} ` : '';
                    // this.template.querySelector(`[data-id="Used_Car_Building_Name__c"]`).value = result.BUILDING !== undefined ? (result.BUILDING === 'NIL' ? '' : result.BUILDING)  : '';
                    // // Set value to changes for updating
                    // this.changes.fields.Used_Car_Street_Name__c = this.template.querySelector(`[data-id="Used_Car_Street_Name__c"]`).value;
                    // this.changes.fields.Used_Car_Building_Name__c = this.template.querySelector(`[data-id="Used_Car_Building_Name__c"]`).value;
                    break;
                default: break;
            }
            console.log('changed address' + JSON.stringify(this.changes));
        }).catch(error => {
            console.log('API Search result ' +  JSON.stringify(error.body.message));
            this.showToast('ERROR!', 'Error: ' + error.body.message, 'error', 'sticky');
            // this.error = error;
        });
    }

    handleKeyUpPostal(event) {
        let postalCode = event.target.value;
        if (postalCode.length === 6 && !isNaN(postalCode)) {
            event.preventDefault();
            this.searchAddress(postalCode);
        }
        if (isNaN(postalCode) || postalCode.length > 6) {
            event.preventDefault();
            this.isErrorPostalCode = true;
        } else {
            this.isErrorPostalCode = false;
        }
    }

    handleInputChanged(event) {
        switch (event.target.name) {
            case 'Floor_UnitRA__c':
                this.floorUnit = this.appendUnitHexToText(event.target.value);
                // this.template.querySelector(`[data-id="Floor_UnitRA__c"]`).value = this.appendUnitHexToText(event.target.value);
                break;
            case 'Floor_UnitMA__c':
                this.floorUnit = this.appendUnitHexToText(event.target.value);
                // this.template.querySelector(`[data-id="Floor_UnitMA__c"]`).value = this.appendUnitHexToText(event.target.value);
                break;
            case 'Used_Car_Floor_Unit__c':
                this.floorUnit = this.appendUnitHexToText(event.target.value);
                // this.template.querySelector(`[data-id="Used_Car_Floor_Unit__c"]`).value = this.appendUnitHexToText(event.target.value);
                break;
            default: break;
        }
        this.changes.fields[event.target.name] = event.target.value;
        console.log('changed :: ' + JSON.stringify(this.changes));
    }

    appendUnitHexToText(value){
        if (value === '' || value === null || value === undefined || value.length === 0 || !value.trim()) {
            return '';
        }
        return value.includes('#') ? value : '#' + value;
    }

    handleSave() {
        this.changes.fields.Id = this.recordId;
        console.log(JSON.stringify(this.changes));
        let msg = '';
        switch (this.identifier) {
            case 'register_address':
                msg += 'Registered Address';
                break;
            case 'mailing_address':
                msg += 'Mailing Address';
                break;
            case 'seller_address':
                msg += 'Seller Address';
                break;
            default: break;
        }
        updateRecord(this.changes).then(() => {
            this.showToast('SUCCESS!', msg + ' saved!', '', 'success', 'pester');
        })
        .catch(error => {
            this.showToast('ERROR!', 'Error in saving ' + msg + ': ' + error.body.message, 'error', 'sticky');
            console.log('SAVED ERROR:: ' + error.body.message);
        });
    }

    handleCancel() {
        this.postalCode = null;
        this.streetNm = null;
        this.buildingNm = null;
        this.floorUnit = null;
    }

    showToast(title, message, msgData, variant, mode) {
        const toastEvent = new ShowToastEvent({
                                                'title' : title,
                                                'message' : message,
                                                'messageData' : msgData,
                                                'variant' : variant,
                                                'mode' : mode
                                             });
        this.dispatchEvent(toastEvent);
     }
}