import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFranchiseGlobalPicklist from '@salesforce/apex/COEBiddingController.getFranchisePicklist';
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


    @wire(getFranchiseGlobalPicklist, {})
    wiredFranchise({error, data})
    {
        if (error)
        {
            console.error(error);
        }
        else if (data)
        {   
            let franchises = [];
            data.forEach(item => {
                franchises.push({ value: item.value, label : item.label });
            })
            this.franchiseOptions = franchises;
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

        if (this.selectedVPOIds.length < this.vpos.length)
        {
            this.showNotification('Error!', 'All items must be selected. Please check again!', 'error', 'dissmissible');

            return;
        }
        // let vpoIds     = [];
        // for(let vp of this.vpos){
        //     vpoIds.push(vp.Id);
        // }
        // this.selectedVPOIds = vpoIds;

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