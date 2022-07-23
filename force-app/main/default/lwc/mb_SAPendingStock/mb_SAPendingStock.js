import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import processPrevPendingStock from '@salesforce/apex/MB_StockReservationCtrl.processPrevPendingStock';

export default class Mb_SAPendingStock extends LightningElement {
    // @api recordId;

    _recordId;
    spinner;
    isError;
    errorMsg;

    @api set recordId(value) {
        this._recordId = value;
        this.spinner = true;
        processPrevPendingStock({
            curMBSAId: this._recordId
        }).then(result => {
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Updated successfully!',
                    variant: 'success'
                })
            );
        }).catch(error => {
            this.spinner = false;
            this.isError = true;
            this.errorMsg = 'Error occured during transaction: ' + error.body.message;
        })
    }

    get recordId() {
        return this._recordId;
    }
}