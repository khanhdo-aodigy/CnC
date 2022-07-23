import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import idpFontStyle from '@salesforce/resourceUrl/idpFontStyle';
import doForgotPassword from '@salesforce/apex/IDPAppService.doForgotPassword';
import isNewUser from '@salesforce/apex/IDPAppService.isNewUser';

export default class Idp_forgotPasswordForm extends LightningElement 
{
    isConfirmation = false;
    isError = false;
    isValid = true;
    spinner;

    showModal = false;
    modalMsg = '';
    isNewUser = false;

    details = {};

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

    onFocusEvent(event)
    {
        if (!this.isValid || this.isError) return;
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

    resetError(dataId)
    {
        let el = this.template.querySelector(`p[data-id = '${dataId}']`);
        el.style.display = 'none';    
        el.innerHTML     = '';

        this.template.querySelector(`div[data-id='${dataId + ' input element'}']`).classList.remove('focusOnError');
        this.template.querySelector(`label[data-id='${dataId + ' input label'}']`).classList.remove('labelFocusOnError');
    }

    doBack(event) 
    {
        if (event.target.name === 'backFromConfirmation') 
        { 
            this.spinner = true;
            this.handleEvent('backFromConfirmation', {'label' : 'BackFromConfirmation', 'value' : this.details.email + ';' + this.isNewUser}); 
        }
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
        
        console.log("All valid: " + allValid);
        return allValid;
    }

    doSubmit()
    {
        if (!this.onValidate() || this.isError) return;      
        console.log('Details: ' + JSON.stringify(this.details));

        isNewUser({
            request: this.details,
        }).then(result =>
        {
            this.isNewUser = result;
            this.handleEvent('sendToApp', {'label' : 'ForgotPassword', 'value' : result});
        }).
        catch(error =>
        {
            console.log('Error: ' + JSON.stringify(error));   
        })
        
        this.spinner = true;     
        doForgotPassword({
            email: this.details.email,
        }).then(result =>
        {
            this.spinner = false;
            console.log('Result Forgot Password: ' + result);
            if (result === true)
            {
                this.isConfirmation = true;
            }
            else
            {
                this.showModal = true;
                this.modalMsg  = 'Sorry, we can\'t reset your password. Please check and try again.';  
            }                 
        }).
        catch(error =>
        {
            console.log('Error: ' + JSON.stringify(error));   
            this.showModal = true;
            if (error.body.message === 'Invalid')
            {
                this.modalMsg = 'Sorry, we can\'t find this email in our records. Please check and try again.';  
            }

            if (error.body.message === 'Inactive')
            {
                this.modalMsg = 'Your Account is inactive. Please reach out to your System Administrator for further information.';
            }
            this.spinner = false;
        })
    }
}