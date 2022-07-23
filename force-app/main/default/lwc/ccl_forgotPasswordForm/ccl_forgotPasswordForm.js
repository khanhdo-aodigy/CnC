import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cclFontStyle from '@salesforce/resourceUrl/cclFontStyle';
import assets from '@salesforce/resourceUrl/CCL_assets';
import resetPassword from '@salesforce/apex/CCL_AppService.handleForgotPassword';


export default class Ccl_forgotPasswordForm extends LightningElement {
    @api startURL;
    isError;
    @track email;
    @track showForgotPwdForm = true;
    spinner = false;

    connectedCallback() {
        Promise.all([
            loadStyle(this, cclFontStyle),
            loadStyle(this, assets + '/css/bootstrap.min.css'),
        ]).catch(ex => {
            console.log('Promise Exception: ' + JSON.stringify(ex));
        });

    }

    onValueChanged(event) {
        this[event.target.name] = event.target.value;
    }

    isFilled(fieldValue) { 
        let elem = this.template.querySelector('p[data-id = "errMsg"]');
        if (!Boolean(fieldValue)) {
            this.isError = true;
            elem.style.display = 'inline-block';
            elem.innerText = 'Please enter your email.';
            return false;
        } else {
            elem.style.display = 'none';
            return true;
        }
    }

    validateEmail() {
        let input = this.template.querySelector('input[data-id="email"]');
        let fieldNotBlank = this.isFilled(input.value);
        if (fieldNotBlank) {
            const emailRegex = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;
            let el = this.template.querySelector('p[data-id="errMsg"]');
            if (!input.value.match(emailRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Invalid email format.';
            } else {
                this.isError = false;
                el.style.display = 'none';
            }
        } else {
            this.isError = true;
        }
    }

    async handleForgotPwd() {
        this.validateEmail();
        if (!this.isError) {
            this.spinner = true;
            let el = this.template.querySelector('p[data-id="errMsg"]');
            el.style.display = 'none';
            try {
                const result = await resetPassword({
                    email: this.email,
                })
                if (result != null) {
                    if (result === true) {
                        el.style.display = 'none';
                        this.showForgotPwdForm = false;
                    } else {
                        el.style.display = 'inline-block';
                        el.innerText = 'Sorry, we can\'t reset your password. Please check and try again.';
                    }
                } else {
                    el.style.display = 'inline-block';
                    el.innerText = 'Something went wrong. Please try later';
                }
                this.spinner = false;
            } catch (error) {
                this.spinner = false;
                if (error != null) {
                    if (error.body.message === 'Invalid') {
                        el.innerText = 'You might have entered a wrong email or this account does not exist. Please proceed to Sign Up';
                    } else if (error.body.message === 'Inactive') {
                        el.innerText = 'Your Account is inactive. Please reach out to myCarriage System Administrator for further information.';
                    } else {
                        el.innerText = error.body.message;
                        console.error(error.body.message);
                    }
                    el.style.display = 'inline-block';
                }
            }
        }

    }

    backToLoginPage() {
        console.log('Return to Login');
        this.spinner = true;
        this.dispatchEvent(new CustomEvent('returnToLoginPage', {
            detail: {data: this.startURL},
            bubbles: true,
            composed: true
        }));
    }

}