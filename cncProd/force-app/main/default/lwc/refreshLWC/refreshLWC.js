import { LightningElement, api } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MBTDMC from "@salesforce/messageChannel/MBTDMC__c";
import { createMessageContext, releaseMessageContext, publish } from 'lightning/messageService';

export default class RefreshLWC extends LightningElement 
{
    @api title;
    @api variant;
    @api message;
    @api mode;

    context = createMessageContext();
    
    publishMC() 
    {
        const message = {
            action: "refresh",
            payload: 'refresh'
        };
        publish(this.context, MBTDMC, message);
    }

    renderedCallback()
    {
        if (this.variant === 'success')
        {
            this.handleNext();
        } 
        this.closeFlow();   
        this.showNotification();
    }

    disconnectedCallback() 
    {
        releaseMessageContext(this.context);
    }

    handleNext()
    { 
        this.publishMC();
    }


    closeFlow()
    {
        const finishNaviEvent = new FlowNavigationFinishEvent();
        this.dispatchEvent(finishNaviEvent); 
    }
    
    showNotification() {
        const evt = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant,
            mode: this.mode

        });
        this.dispatchEvent(evt);
    }
}