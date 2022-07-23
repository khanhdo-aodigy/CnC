import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import idpFontStyle from '@salesforce/resourceUrl/idpFontStyle';
import doLogin from '@salesforce/apex/IDPAppService.doLogin';
import isNewUser  from '@salesforce/apex/IDPAppService.isNewUser';

export default class Idp_loginForm extends LightningElement
{

    @api
    get startURL() {
        return this.mainURL;
    }

    set startURL(value) {
        this.loginStartURL = value;
        this.mainURL = 'https://' +  window.location.hostname + '/mycnc/IDP_SignUpPage?msg=' + value;
    }

    mainURL;
    loginStartURL;
    showPassword = 'utility:hide';
    spinner; 

    isError = false;
    isValid = true;
    
    showModal = false;
    modalMsg  = '';
    
    details                = {};
    loginResult            = {};
    showRestoreAccountPage = false;

    get inputStyle()
    {
        return "border:none; outline:none; background-color: rgb(255, 255, 255); height: 30px; font-family: Whitney;font-style: normal;font-weight: normal;font-size: 18px; line-height: 22px; box-shadow: none; background-clip: padding-box; width:100%"; 
    }

    connectedCallback()
    {
        Promise.all([
            loadStyle(this, idpFontStyle),
        ]).then(() => {});
    }

    togglePassword()
    {
        this.showPassword = this.showPassword === 'utility:hide' ? 'utility:preview' : 'utility:hide';
        let x = this.template.querySelector('input[data-id="password"]');
        x.type = x.type === 'password' ? 'text' : 'password';
        x.focus();
    }

    onFocusEvent(event)
    {
        if (event.target.name !== 'email' && !this.isValid) return;
        if (event.target.name === 'email' && (!this.isValid || this.isError)) return;
        this.template.querySelector(`div[data-id='${event.target.getAttribute('data-id') + ' input element'}']`).classList.add('focusOn');
        this.template.querySelector(`label[data-id='${event.target.getAttribute('data-id') + ' input label'}']`).classList.add('labelFocusOn');
    }

    onBlurEvent(event)
    {
        this.template.querySelector(`div[data-id='${event.target.getAttribute('data-id') + ' input element'}']`).classList.remove('focusOn');
        this.template.querySelector(`label[data-id='${event.target.getAttribute('data-id') + ' input label'}']`).classList.remove('labelFocusOn');
    }

    onValueChanged(event)
    {
        let isError = this.fieldValidation(event.target);
        if (!isError)
        {
            this.details[event.target.name] = event.target.value;
            this.resetError(event.target.getAttribute('data-id'));
        }   
    }

    fieldValidation(data)
    {
        if (!this.isFilled(data.value, data.getAttribute('data-id'), data.required)) {return true;} 

        if (data.name === 'email')
        {
            const regexEmail = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;

            let el = this.template.querySelector('p[data-id="email"]');

            if (!data.value.match(regexEmail))
            {
                el.style.display = 'inline-block';
                el.innerHTML     = 'Please enter a valid email address.';
                this.isError     = true;
                this.template.querySelector('div[data-id="email input element"]').classList.add('focusOnError');
                this.template.querySelector('label[data-id="email input label"]').classList.add('labelFocusOnError');

                return true;
            }
        }

        this.isError = false;

        return false;
    }

    isFilled(checkValue, dataId, isRequired)
    {
        if (!isRequired) return true;

        if(checkValue === '' || checkValue === undefined || checkValue === null) 
        {
            let y = this.template.querySelector(`p[data-id = '${dataId}']`);
            y.style.display = 'inline-block';
            y.innerHTML     = 'Please enter your ' + dataId + '.';        
            y.style.color   = '#fc6c6c';      

            this.template.querySelector(`div[data-id='${dataId + ' input element'}']`).classList.add('focusOnError');
            this.template.querySelector(`label[data-id='${dataId + ' input label'}']`).classList.add('labelFocusOnError');
            this.isValid = false;

            return false;
        }
        this.isValid = true;

        return true;
    }

    onValidate()
    {
        const allValid = 
        [
            ...this.template.querySelectorAll('input')
        ]
        .reduce((validSoFar, inputCmp) => 
        { 
            const isValid = this.isFilled(inputCmp.value, inputCmp.getAttribute('data-id'), inputCmp.required);
            return validSoFar && isValid;
        }, true);

        return allValid;
    }

    resetError(dataId)
    {
        let el = this.template.querySelector(`p[data-id = '${dataId}']`);
        el.style.display = 'none';    
        el.innerHTML     = '';

        this.template.querySelector(`div[data-id='${dataId + ' input element'}']`).classList.remove('focusOnError');
        this.template.querySelector(`label[data-id='${dataId + ' input label'}']`).classList.remove('labelFocusOnError');
    }

    handleEvent(name, eventData)
    {
        this.dispatchEvent(new CustomEvent(name, {
            detail: {data : eventData},
            bubbles: true,
            composed: true
        }));     
    }

    closeModal()
    {
        this.showModal = false;
        this.modalMsg = '';
    }

    handleSignUp()
    {
        this.handleEvent('sendToApp', {'label': 'SignUp', 'value':true});
    }

    doSubmit()
    {
        if (!this.onValidate() || this.isError) return;      
        this.details.startURL = this.loginStartURL;

        isNewUser({
            request: this.details,
        }).then(result =>
        {
            this.handleEvent('sendToApp', {'label':'Login', 'value': result});
        }).
        catch(error =>
        {
            console.log('Error: ' + JSON.stringify(error));   
        })

        let invalidMsg = 'You might have entered an incorrect email or password.';
        this.spinner = true;
        doLogin({
            request: this.details,
        }).then(result =>
        {
            this.spinner     = false;
            this.loginResult = JSON.parse(JSON.stringify(result));
            if (this.loginResult === null)
            {
                this.showModal = true;
                this.modalMsg  = invalidMsg; 
            }
            else
            {
                switch (this.loginResult.type)
                {
                    case 'login':
                        this.handleEvent('loginSuccess', this.loginResult.redirect_url);
                        break;
                    case 'restore':
                        this.showRestoreAccountPage = true;

                        let deletionRequestDdt = new Date(this.loginResult.uInfo.Deletion_Request_Date__c);
                        deletionRequestDdt.setDate(deletionRequestDdt.getDate() + 13);

                        this.loginResult.uInfo.Deletion_Request_Date__c = this.formatDate(deletionRequestDdt);

                        break;
                    default:
                        break;
                }
            }
        }).
        catch(error =>
        {
            console.log('Error: ' + JSON.stringify(error));   
            this.showModal = true;
            if (error.body.message === 'Invalid')
            {
                this.modalMsg = invalidMsg;
            }

            if (error.body.message === 'Inactive')
            {
                this.modalMsg = 'Your Account is inactive. Please reach out to your System Administrator for further information.';
            }
            this.spinner = false;
        })
    }

    formatDate(date) {
        let ye = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(date);
        let mo = new Intl.DateTimeFormat('en', { month: 'short' }).format(date);
        let da = new Intl.DateTimeFormat('en', { day: '2-digit' }).format(date);

        return da + ' ' + mo + ' ' + ye;
    }
}