import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import submitToGetsAsia from '@salesforce/apex/VS_VehicleShipmentLWCController.submitToGetsAsia';

export default class Vs_getAsiaCallout extends LightningElement 
{
    @api recordId;

    showItemDetails      = false;
    isLastItem           = false;
    showSpinner          = false;
    selectedServiceType  = '';
    selectedItems        = {};

    get options() 
    {
        return [
            { label: 'Inward Payment Transaction', value: 'IPT' },
            { label: 'Inward Non-Payment Transaction', value: 'INP' },
        ];
    }

    get isDisabledOK()
    {
        return this.selectedServiceType === ''; 
    }

    handleChange(e)
    {   
        this.selectedServiceType = e.currentTarget.value;
    }

    handleLastItem()
    {
        this.isLastItem = true;
    }

    handleNoItem()
    {
        this.showItemDetails = false;
    }
    
    handleSubmitItems(e)
    {
        this.selectedItems = e.detail.value;
    }

    onCancel()
    {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    onNext()
    {
        this.template.querySelector('c-vs_gets-Asia-Item-Details').handleNext();
    }

    onOK()
    {
        this.showItemDetails = true;
    }

    async onSubmit()
    {
        this.template.querySelector('c-vs_gets-Asia-Item-Details').handleSubmit();

        try 
        {
            this.showSpinner = true;
            const result = await submitToGetsAsia({
                vehicleShipmentId: this.recordId,
                serviceType: this.selectedServiceType,
                grouppedItems: this.selectedItems
            })

            if (result)
            {
                this.showNotification('SUCCESS', 'The submission to GetAsia is successful!', 'success', 'sticky');
            }
            else
            {
                this.showNotification('ERROR', 'The submission to GetAsia has failed! Please contact your Administrator.', 'error', 'sticky');
            }
        } 
        catch (error) 
        {
            this.showNotification('ERROR!', 'The submission to GetsAsia has failed! Reason: ' + error.body.message + '. Please contact your Administrator.', 'error', 'sticky');
        }
        finally
        {
            this.showSpinner = false;
            this.onCancel();
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