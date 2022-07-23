import { LightningElement, api } from 'lwc';

export default class SpecialToolsBorrowedByUser extends LightningElement {

    @api toolsBorrowed;
    @api totalTool;

    close(){
        this.dispatchEvent(new CustomEvent('close')); 
    }
}