import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import cancelSA from '@salesforce/apex/PromoLineItemService.cancelSA';
import getRelatedUpsellAccs from '@salesforce/apex/InvoicePromoLineItemService.getRelatedPromoLineItems';
import updatePromoLineItemQuantity from '@salesforce/apex/PromoLineItemService.updatePromoLineItemQuantity';
import transferUpsellAccs from '@salesforce/apex/PromoLineItemService.transferUpsellAccs';

export default class Dsa_cancelSalesAgreement extends LightningElement 
{
    @api recordId;
    @api objectApiName;

    invoiceItems = [];
    newSANo      = '';
    showMessage  = false;
    isError      = false;
    showSpinner  = false;

    @wire(getRelatedUpsellAccs, { recordId : '$recordId'})
    upsellAccs({data, error})
    {
        console.log('upsellAccs >>> ' + JSON.stringify(data));
        if (data && data.length > 0)
        {
            this.showMessage  = true;
            this.invoiceItems = data;
        }
        else if (data && data.length === 0)
        {
            this.showSpinner = true;
            cancelSA({
                sAId: this.recordId
            }).then(result => {
                result == true && this.handleSuccess('Success!', 'The Sales Agreement has been successfully cancelled!', 'success', 'sticky');
            }).catch(error => {
                this.showSpinner = false;
                this.isError = true;
                console.log('@@@ getRelatedUpsellAccs >> cancelSA >> error: ' + error.body.message);
            });
        }
    
        error && (this.isError = true, console.log('@@@ getRelatedUpsellAccs >>> error: ' + error));
    }

    onValueChanged(event)
    {
        this.newSANo = event.target.value;
        if (this.newSANo !== null && this.newSANo !== undefined && this.newSANo !== '')
        {
            console.log('HERE');
            var inputCmp = this.template.querySelector('.inputCmp');
            inputCmp.setCustomValidity('');
            inputCmp.reportValidity();
        }
    }

    onNo()
    {
        this.showMessage = false;
        this.showSpinner = true;
        updatePromoLineItemQuantity({
            records: this.invoiceItems,
            sAId: this.recordId
        }).then(result => {
            result == true && this.handleSuccess('Success!', 'The Sales Agreement has been successfully cancelled!', 'success', 'sticky');
        }).catch(error => {
            this.showSpinner = false;
            this.isError = true;
            console.log('@@@ updatePromoLineItemQuantity >>> error: ' + error.body.message);
        });
    }

    onYes()
    {
        this.showSpinner = true;
        var isValid = true;
        var inputCmp = this.template.querySelector('.inputCmp');
        if(inputCmp.value === '' || inputCmp.value === undefined || inputCmp.value === null) 
        {
            inputCmp.setCustomValidity('Please complete this field.');
            isValid = false;
        } 
        else 
        {
            inputCmp.setCustomValidity('');
            isValid = true;
        }
        inputCmp.reportValidity();

        if(!isValid)
        {
            this.showSpinner = false;
        }
        else
        {
            this.showMessage = false;
            transferUpsellAccs({
            records: this.invoiceItems,
            oldSAId: this.recordId,
            newSANo: this.newSANo
            }).then(result => {
                result == true && this.handleSuccess('Success!', 'The Sales Agreement has been successfully cancelled. You can see the associated Invoices under the new Sales Agreement now!', 'success', 'sticky');
                result == false && this.handleSuccess('', 'The Sales Agreement has been successully cancelled. However, the associated Invoices cannot be transferred due to different models!', 'warning', 'sticky');
            }).catch(error => {
                this.showSpinner = false;
                this.isError = true;
                console.log('@@@ transferUpsellAccs >>> error: ' + error.body.message);
            });
        }
    }

    closeModal()
    {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSuccess(title, message, variant, mode) 
    {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.showNotification(title, message, variant, mode);
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