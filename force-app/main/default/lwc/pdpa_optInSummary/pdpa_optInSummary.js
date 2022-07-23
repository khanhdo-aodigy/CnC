import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Account.Fax__pc', 'Account.SMS__pc', 'Account.Call__pc', 'Account.Email__pc'];

export default class Pdpa_optInSummary extends LightningElement 
{
    @api recordId;
    
    @track optInOptions = 
    [    
        {label: 'Postal', value: 'action:close'},
        {label: 'Email', value: 'action:close'},
        {label: 'Phone', value: 'action:close'},
        {label: 'SMS', value: 'action:close'}
    ];

    account;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) 
    {
        if (error) 
        {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) 
            {
                message = error.body.map(e => e.message).join(', ');
            } 
            else if (typeof error.body.message === 'string') 
            {
                message = error.body.message;
            }

            console.log(message);
        } 
        else if (data) 
        {
            console.log(JSON.stringify(data));
            data.fields && (this.account = data.fields);
            
            if (this.account)
            {
                if (this.account.Email__pc.value)
                {
                    var key = this.optInOptions.findIndex(item => item.label === 'Email');
                    this.optInOptions[key].value = 'action:approval';
                }

                if (this.account.SMS__pc.value)
                {
                    var key = this.optInOptions.findIndex(item => item.label === 'SMS');
                    this.optInOptions[key].value = 'action:approval';
                }

                if (this.account.Fax__pc.value)
                {
                    var key = this.optInOptions.findIndex(item => item.label === 'Postal');
                    this.optInOptions[key].value = 'action:approval';
                }

                if (this.account.Call__pc.value)
                {
                    var key = this.optInOptions.findIndex(item => item.label === 'Phone');
                    this.optInOptions[key].value = 'action:approval';
                }
            }
            
            console.log(this.optInOptions);
        }
    }

}