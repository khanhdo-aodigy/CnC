import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';


const MBSA_FIELDS = ['MB_Sales_Agreement__c.MB_Stock_Vehicle_Master__r.Vehicle_ID__c'];


export default class Mb_SAStockChange extends NavigationMixin (LightningElement) {
    @api recordId;

    stockNo;

    @wire(getRecord, { recordId: '$recordId', fields: MBSA_FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Sales Agreement',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.stockNo = data.fields.MB_Stock_Vehicle_Master__r.value.fields.Vehicle_ID__c.value;
            console.log('stockNo:: ' + this.stockNo);
        }
    }

    @api invoke() {
        console.log('Component called');
        let confirm = window.confirm('Are you sure to change Stock?');
        confirm && this.navigateToSRPage();
    }

    navigateToSRPage() {
        this[ NavigationMixin.Navigate ]( {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MB_Stock_Reservation'
            },
            state: {
                c__prevSA: this.recordId,
                c__prevStock: this.stockNo
            }
        } );
    }
}