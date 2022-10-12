import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecord } from 'lightning/uiRecordApi';

import ACCOUNT_FIELD from '@salesforce/schema/Sales_Agreement__c.Account__c';

export default class Pr_createDebiteCreditNote extends NavigationMixin(LightningElement)
{
    accountId = '';
    _recordId;

    @api set recordId(value)
    {
        this._recordId = value;
    }
    
    get recordId() 
    {
        return this._recordId;
    }

    @wire(getRecord, { recordId: '$_recordId', fields: [ACCOUNT_FIELD] })
    wiredRecord({ error, data }) 
    {
        if (data) 
        {
            this.accountId = data.fields.Account__c.value;
        }
    }

    navigateToNewRecordPage() 
    {
        const defaultValues = encodeDefaultFieldValues({
            Sales_Agreement__c: this._recordId,
            Account__c: this.accountId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Credit_Note__c',
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