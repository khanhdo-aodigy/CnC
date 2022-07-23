import { LightningElement, api, track } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent,
    
} from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';

import {CloseActionScreenEvent} from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';


export default class rap_flowCustomFooter extends NavigationMixin(LightningElement) {
    @api selectedOption;
    @api hideSaveBtn = false;
    @api hideNewBtn = false;
    @api hideCancelBtn = false;

    @api saveLabel = 'Save';
    @api saveNewLabel = "Save & New";
    @api cancelLabel = "Cancel";

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Used_Car_Quote__c',
                actionName: 'list'
            },
        }); 
    }

    handleSubmit() {
        this.selectedOption = 'SAVE';
        const navigateNextEvent = new FlowNavigationNextEvent ();
        this.dispatchEvent(navigateNextEvent);
        
    }

    saveAndNew() {
        this.selectedOption = 'SAVE_NEW';
        const navigateNextEvent = new FlowNavigationNextEvent ();
        this.dispatchEvent(navigateNextEvent);
    }
}