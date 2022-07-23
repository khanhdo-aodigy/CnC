import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import idpFontStyle from '@salesforce/resourceUrl/idpFontStyle';
import doRestore from '@salesforce/apex/IDPAppService.confirmRestore';


export default class Idp_restoreMyAccountForm extends LightningElement {
    @api details;
    @api loginResult;

    spinner;
    errorMsg;
    showModal          = false;
    showRestoreSucceed = false;
    isError            = false;

    connectedCallback()
    {
        Promise.all([
            loadStyle(this, idpFontStyle),
        ]).then(() => {});
    }

    handleClick(event)
    {
        let btnNm = event.target.name;
        switch(btnNm) {
            case 'process_restore':
                this.showModal = true;
                break;
            case 'confirm_restore':
                this.restoreAccount(this.details.email);
                break;
            case 'decline_restore':
                this.showModal = false;
                break;
            case 'succeed_restore':
                this.handleEvent('loginSuccess', this.loginResult.redirect_url);
                break;
            case 'close_modal':
                this.isError   = false;
                this.showModal = false;
                break;
            default:
                break;
        }
    }

    restoreAccount(email)
    {
        this.spinner = true;
        doRestore({
            userEmail: email
        }).then(result => {
            this.spinner            = false;
            this.showModal          = false;
            this.showRestoreSucceed = true;
        }).catch(error => {
            this.errorMsg  = error.body.message;
            this.showModal = true;
            this.isError   = true;
        })
    }

    handleEvent(name, eventData)
    {
        this.dispatchEvent(new CustomEvent(name, {
            detail: { data : eventData },
            bubbles: true,
            composed: true
        }));     
    }
}