import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LightningConfirm from 'lightning/confirm';
import retrievePermitNo from '@salesforce/apex/VS_VehicleShipmentLWCController.retrievePermitNo';

export default class Vs_retrievePermitNo extends LightningElement 
{
    _recordId;

    @api set recordId(value)
    {
        this._recordId = value;
    }
    
    get recordId() 
    {
        return this._recordId;
    }

    isExecuting = false;

    @api async invoke() 
    {
        try 
        {
            if (this.isExecuting) 
            {
                this.showNotification('WAIT!', 'Retrieving of Permit No. is in progress!', 'warning', 'sticky');
                return;
            }
               
            this.isExecuting = true;

            const confirm = await LightningConfirm.open({
                                                        message: 'Do you want to retrieve Permit No.?',
                                                        variant: 'Header',
                                                        label: 'Confirm',
                                                        theme: 'alt-inverse'});

            if (confirm)
            {
                this.showNotification('WAIT!', 'Retrieving of Permit No. is in progress!', 'info', 'sticky');
                
                const result = await retrievePermitNo({inwardDeclarationId: this._recordId});
                if (result)
                {
                    this.showNotification('SUCCESS!', 'Permit No. has been successfully retrieved.', 'success', 'sticky');
                }
                else
                {
                    this.showNotification('ERROR!', 'Failed to retrieve Permit No. Please contact your Administrator.', 'error', 'sticky');
                }
            }  

            this.isExecuting = false;
        } 
        catch (error) 
        {
            this.showNotification('ERROR!', 'Failed to retrieve Permit No. Reason: ' + error.body.message + '. Please contact your Administrator.', 'error', 'sticky');
        }
        finally
        {
            this.dispatchEvent(new CloseActionScreenEvent());
        } 
    }

    showNotification(title, message, variant, mode) 
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }
}