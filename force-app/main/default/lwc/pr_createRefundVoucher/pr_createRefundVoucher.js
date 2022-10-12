import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class Pr_createRefundVoucher extends NavigationMixin(LightningElement)
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

    navigateToNewRecordPage() 
    {
        const defaultValues = encodeDefaultFieldValues({
            Sales_Agreement__c: this._recordId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Refund__c',
                actionName: 'new',   
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    @api async invoke() 
    {
        const result = await this.navigateToNewRecordPage();
    }
}