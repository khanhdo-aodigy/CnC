import { api, LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import idpFontStyle from '@salesforce/resourceUrl/idpFontStyle';
import doConfirmDelete from '@salesforce/apex/IDPAppService.confirmDelete';
import getUserInfo from '@salesforce/apex/IDPAppService.getUserInfo';


export default class Idp_deleteMyAccountForm extends LightningElement {
    @api userId;

    info                       = {};
    user                       = {};
    modalMsg                   = '';
    modalBtnTitle              = 'TRY AGAIN';
    showWarningPage            = true;
    showDeleteConfirmationPage = false;
    showDeleteSucceedPage      = false;
    spinner                    = false;
    showModal                  = false;
    showPassword               = 'utility:hide';

    connectedCallback()
    {
        Promise.all([
            loadStyle(this, idpFontStyle),
        ]).then(() => {});
    }

    @wire( getUserInfo, { userId: '$userId' })
    wiredUsers(result)
    {
        if (result.error) {
            this.modalMsg      = result.error.body.message;
            this.showModal     = true;
        } else if (result.data) {
            let firstNm        = result.data.FirstName ? result.data.FirstName : '';
            let lastNm         = result.data.LastName  ? result.data.LastName  : '';
            this.user.Name     = firstNm + ' ' + lastNm;
            this.user.Username = result.data.Username;
            this.info.email    = result.data.Email;
        }
    }

    handleChange(event)
    {
        let name        = event.target.name;
        let val         = event.target.value;
        this.info[name] = val;
    }

    handleClick(event)
    {
        let btnNm = event.target.name;
        switch (btnNm)
        {
            case 'next': 
                this.showDeleteConfirmationPage = true;
                this.showWarningPage            = false;
                break;
            case 'confirm':
                this.confirmDelete();
                break;
            case 'close_modal':
                this.showModal = false;
                break;
            default:
                break;
        }
    }

    onFocusEvent(event)
    {
        this.template.querySelector(`div[data-id='${event.target.getAttribute('data-id') + ' input element'}']`).classList.add('focusOn');
        this.template.querySelector(`label[data-id='${event.target.getAttribute('data-id') + ' input label'}']`).classList.add('labelFocusOn');
    }

    onBlurEvent(event)
    {
        this.template.querySelector(`div[data-id='${event.target.getAttribute('data-id') + ' input element'}']`).classList.remove('focusOn');
        this.template.querySelector(`label[data-id='${event.target.getAttribute('data-id') + ' input label'}']`).classList.remove('labelFocusOn');
    }

    onKeyPressEvent(event)
    {
        if (event.target.getAttribute('data-id') !== 'password') return;

        if (event.keyCode === 13)
        {
            event.preventDefault();

            this.confirmDelete();
        }
    }

    confirmDelete()
    {
        this.template.activeElement?.blur();

        this.spinner = true;
        doConfirmDelete({
            request: this.info
        })
        .then(result => {
            console.log(result);
            this.spinner = false;
            if (result) {
                this.showDeleteConfirmationPage = false;
                this.showDeleteSucceedPage      = true;
            } else {
                this.modalMsg  = 'Your password is incorrect.';
                this.showModal = true;
            }
        })
        .catch(error => {
            this.spinner       = false;
            this.modalMsg      = error.body.message;
            this.modalBtnTitle = this.modalMsg.includes('delete your account') ? 'OK' : this.modalBtnTitle;
            this.showModal     = true;
        })
    }

    togglePassword()
    {
        this.showPassword = this.showPassword === 'utility:hide' ? 'utility:preview' : 'utility:hide';
        let x  = this.template.querySelector('input[data-id="password"]');
        x.type = x.type === 'password' ? 'text' : 'password';
        x.focus();
    }

    handleEvent(name, eventData)
    {
        this.dispatchEvent(new CustomEvent(name, {
            detail   : { data : eventData },
            bubbles  : true,
            composed : true
        }));     
    }
}