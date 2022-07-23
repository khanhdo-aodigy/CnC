import { LightningElement, api, track, wire } from 'lwc';
import retrieveReward from '@salesforce/apex/CMDebitUsageService.retrieveReward';
import extendRewardExpiry from '@salesforce/apex/CMCreditUsageService.extendRewardExpiry';
import { refreshApex } from '@salesforce/apex';

export default class Cm_RewardCreditExtensionDetails extends LightningElement {
    @api recordId;

    @track newExpiryDate;
    @track extensionReason;
    today = new Date();
    @track transactionDate  = this.today.getFullYear() + '-' + ('0' + (this.today.getMonth()+1)).slice(-2) + '-' + ('0' + this.today.getDate()).slice(-2);
    @track rewardRec;
    @track contactName;

    isEdit = false;
    isValid = true;

    @wire(retrieveReward, { rewardId : '$recordId'})
    rewardProfileObject(result) {
        this.wireRewardRec = result; //This is needed if you want to deliberately refresh it
        this.rewardRec = result ? result.data : undefined;
        this.rewardRec && (this.contactName = this.rewardRec.Contact__r ? this.rewardRec.Contact__r.Name : '');
    }

    onValueChanged(event) 
    {
        this[event.target.name] = event.target.value;     
        
        if (event.target.name == "newExpiryDate") 
        {
            const newExpDate = this.template.querySelector(".newExpiryDate");
            if (new Date(newExpDate.value) < new Date((new Date()).valueOf() + 86400000))
            {
                newExpDate.setCustomValidity("New Expiry Date must be greater than Today.");
                newExpDate.reportValidity();
                this.isValid = false;
            } 
            else{
                newExpDate.setCustomValidity("");
                newExpDate.reportValidity();
                this.isValid = true;
            }
        }
    }

    @api
    validateInput()
    {
        const newExpDate = this.template.querySelector(".newExpiryDate");
        const extensionReason = this.template.querySelector(".extensionReason");
        if (newExpDate.value == '' || extensionReason.value == '') 
        {
            newExpDate.reportValidity();
            extensionReason.reportValidity();
            return false;
        }
        else
        {
            if (!this.isValid) {
                return false;
            }
        }

        return true;
    }

    @api
    onCreate() 
    {
        extendRewardExpiry({
            newExpiryDate : this.newExpiryDate,
            extensionReason   : this.extensionReason,
            creditAmount : this.rewardRec.Expired_Credit__c,
            rewardId: this.rewardRec.Id,
            transactionDate   : new Date(this.transactionDate)
        }).then((result)=>{
            const saveEvent = new CustomEvent('submitrecord', {
                detail: { 'message': 'SUCCESS' },
            });
            this.dispatchEvent(saveEvent);
            refreshApex(this.wireRewardRec);
            this.isEdit = true;
        }).catch(error=>{
            const saveEvent = new CustomEvent('submitrecord', {
                detail: { 'message': error.body.message },
            });
            this.dispatchEvent(saveEvent);
        });                 
    }
}