import { LightningElement, track, api, wire } from 'lwc';
import getSAAccessories from '@salesforce/apex/DigitalSalesAgreementApplication.getSAAcessories';

export default class RecordListAsListCmp extends LightningElement {

    @api recordId
    @track listItems

    @wire(getSAAccessories, {
        recordId: '$recordId'
    }) returnItems({data, error}){
        this.listItems = data ? data : undefined;
        this.error = error ? undefined : error;
    }

}