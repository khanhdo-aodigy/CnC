import { LightningElement } from 'lwc';

export default class Mb_TDContainer extends LightningElement {

    handleCancelBooking() {
        this.template.querySelector(`[data-id="td-vehicle-table"]`).style.display = 'inherit';
        this.template.querySelector(`[data-id="td-booking-detail"]`).style.display = 'none';
    }

    handleBooking() {
        this.template.querySelector(`[data-id="td-vehicle-table"]`).style.display = 'none';
        this.template.querySelector(`[data-id="td-booking-detail"]`).style.display = 'inherit';        
    }
}