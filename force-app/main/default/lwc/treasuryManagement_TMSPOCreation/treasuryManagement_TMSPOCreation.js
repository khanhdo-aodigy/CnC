import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import VEHICLE_MASTER_OBJECT from '@salesforce/schema/Vehicle_Master2__c';
import FRANCHISE_FIELD from '@salesforce/schema/Vehicle_Master2__c.Franchise_Code__c';
import getVPOs from '@salesforce/apex/TreasuryManagementController.searchVehiclePurchaseOrder';
import createTMSPO from '@salesforce/apex/TreasuryManagementController.createTMSPurchaseOrder';

const columns = [
                    { label: 'Name', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
                    { label: 'Units', fieldName: 'Total_Units_Confirmed__c', type: 'number', cellAttributes: { alignment: 'left' } }
                ];

export default class TreasuryManagement_TMSPOCreation extends LightningElement {

    haveVPOs = false;
    spinner  = false;
    vpos     = [];
    columns  = columns;
    franchiseOptions;
    selectedFranchise;
    selectedProductionMth;
    selectedVPOIds;
    selectedVPOsCnt;

    @wire(getObjectInfo, { objectApiName: VEHICLE_MASTER_OBJECT })
    objectInfo;
    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FRANCHISE_FIELD
    }) franchisePicklist({ data, error }) {
        if (data) {
            this.franchiseOptions = data.values;
        } else if (error) {
            this.franchiseOptions = undefined;
        }
    }

    handleChange(event)
    {
        let inputNm = event.target.name;
        let value   = event.target.value;

        switch(inputNm)
        {
            case 'franchise':
                this.selectedFranchise = value;
                break;
            case 'production_month':
                this.selectedProductionMth = value;
                break;
            default:
                break;
        }
    }

    searchVPOs()
    {
        this.spinner = true;
        getVPOs({
            franchise: this.selectedFranchise,
            productionMonth: this.selectedProductionMth
        }).then(result => {
            this.haveVPOs = true;
            let nameUrl;
            this.vpos = result.map(vpo => { 
                nameUrl = `/${vpo.Id}`;
                return {...vpo , nameUrl} 
            })
            console.log(result);
            console.log('success');
            this.spinner = false;
        }).catch(error => {
            console.log('error');
            console.log(error);
            this.showNotification('Error!', 'An error occurred. Please contact your System Admin ' + error.body.message, 'error', 'dissmissible');
            this.spinner = false;
        })
    }

    getSelectedRow(event) {
        let selectedRows = event.detail.selectedRows;
        let vpoIds     = [];
        if (selectedRows.length > 0) {
            selectedRows.forEach(row => {
                vpoIds.push(row.Id);
            })
            this.selectedVPOIds = vpoIds;
        }
        this.selectedVPOsCnt = selectedRows.length;
    }

    createPO()
    {
        if (!this.selectedVPOIds)
        {
            this.showNotification('Error!', 'Please select items!', 'error', 'dissmissible');

            return;
        }

        this.spinner = true;
        createTMSPO({
            vpoIds: this.selectedVPOIds
        }).then(result => {
            console.log('success');
            let tmsVPOId = result;
            let baseURL = 'https://' + window.location.host;
            window.open(baseURL + '/' + tmsVPOId, '_self');
            this.spinner = false;
        }).catch(error => {
            console.log('error');
            console.log(error);
            this.showNotification('Error!', 'An error occurred. Please contact your System Admin ' + error.body.message, 'error', 'dissmissible');
            this.spinner = false;
        })
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
}