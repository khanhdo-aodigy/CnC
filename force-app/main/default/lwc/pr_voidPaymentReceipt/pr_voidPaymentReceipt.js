import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import voidPaymentReceipt from '@salesforce/apex/PR_PaymentReceiptLWCController.voidPaymentReceipt';

export default class Pr_voidPaymentReceipt extends LightningElement 
{
    @api recordId;
    @api objectApiName;

    @track details = {};

    showSpinner = false;

    get disableVoidButton()
    {
       return false;
    }

    onValueChanged(e)
    {
        this.details[e.target.fieldName] = e.detail.value;
    }
   
    async onVoid()
    {
        try 
        {
            this.showSpinner       = true;
            this.details.Id        = this.recordId;
            this.details.Status__c = 'Voided';
    
            const result = await voidPaymentReceipt({
                paymentReceiptId : this.recordId,
                updatedPaymentReceipt: this.details
            })

            if (result)
            {
                this.showNotification("SUCCESS!", 'Payment Receipt has been successfully voided.', 'Success', "dismissible");
                this.onClose();
            } 
        } 
        catch (error) 
        {
            this.showNotification("ERROR!", 'Payment Receipt can\'t be voided. Reason: ' + error.body.message + '. Please contact your Administrator.', 'Error', "sticky");
        }
        finally
        {
            this.details     = {};
            this.showSpinner = false;
        }   
    }

    onClose()
    {
        this.dispatchEvent(new CloseActionScreenEvent());
        eval("$A.get('e.force:refreshView').fire();")
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