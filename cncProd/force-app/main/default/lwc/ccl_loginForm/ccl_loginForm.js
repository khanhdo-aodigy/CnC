import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import cclFontStyle from '@salesforce/resourceUrl/cclFontStyle';
import assets from '@salesforce/resourceUrl/CCL_assets';
import doLogin from '@salesforce/apex/CCL_AppService.doLogin';
import loginURL from '@salesforce/label/c.CCL_RedirectURL';

export default class Ccl_loginForm extends LightningElement {

    @track disableButton = false;
    isError;
    loginDetails = {};
    logoUrl = assets + '/img/myCarriage-Logo-horizontal-inverse.png-print-CMYK.png';
    errElement;
    mainURL;
    loginStartURL;
    forgotPwdUrl;
    @track spinner = false;

    @api
    get startURL() {
        return this.mainURL;
    }

    set startURL(value) {
        this.loginStartURL = value;
        this.mainURL = 'https://' + window.location.hostname + '/ccl/CCL_RegistrationPage?msg=' + value;
        this.forgotPwdUrl = 'https://' + window.location.hostname + '/ccl/CCL_ForgotPasswordPage?msg=' + value;
    }

    async connectedCallback() {
        console.log("referrer: ", document.referrer);
        if(!document.referrer) {
            this.refreshToken();
        }
        await loadScript(this, assets + '/js/jquery.min.js');
        await loadScript(this, assets + '/js/bootstrap.min.js'),
            await Promise.all([
                loadStyle(this, cclFontStyle),
                loadStyle(this, assets + '/css/bootstrap.min.css')

            ]);
        
        if (!document.location.hash) {
            document.location.hash = Date.now();
        }
        const timeout = 600000 - (Date.now() - parseInt(document.location.hash.slice(1)));
        console.log('timeout = ' + timeout);
        setTimeout(this.refreshToken, timeout);
    } 

    refreshToken() {
        window.location.href = loginURL;
    }

    renderedCallback() {
        this.errElement = this.template.querySelector('p[data-id=errMsg]');
    }

    onValueChanged(event) {
        this.errElement.style.display = 'none';
        this.loginDetails[event.target.name] = event.target.value;
    }

    isFilled(fieldValue, dataId) {
        let elem = this.template.querySelector(`p[data-id = '${dataId}']`);
        if (!Boolean(fieldValue)) {
            this.isError = true;
            elem.style.display = 'inline-block';
            elem.innerText = 'Please enter your ' + dataId + '.';
            return false;

        } else {
            elem.style.display = 'none';
            return true;
        }
    }

    checkEmailPattern(event) {
        let fieldNotBlank = this.isFilled(event.target.value, event.target.dataset.id);
        if (fieldNotBlank) {
            const emailRegex = /^((?!\.)[\w-_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$/;
            let el = this.template.querySelector('p[data-id="email"]');
            if (!this.loginDetails.email.match(emailRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Invalid email format.';
            } else {
                this.isError = false;
                el.style.display = 'none';
            }
        }

    }

    validatePassword(event) {
        this.isFilled(event.target.value, event.target.dataset.id);
    }

    validateInput() {
        let emailElem = this.template.querySelector('input[data-id = "email"]');
        this.checkEmailPattern({
            target: {
                value: emailElem.value,
                dataset: { id: "email" }
            }
        });

        let pwdElem = this.template.querySelector('input[data-id = "password"]');
        this.isFilled(pwdElem.value, 'password');

    }

    async login() {
        this.validateInput();
        this.loginDetails.startURL = this.loginStartURL;
        if (!this.isError) {
            this.spinner = true;
            try {
                const result = await doLogin({
                    request: this.loginDetails,
                })
                if (result != null) {
                    console.log('Login successfully!!!');
                    this.dispatchEvent(new CustomEvent('loginSuccess', {
                        detail: { data: result },
                        bubbles: true,
                        composed: true
                    }));
                } else {
                    this.errElement.innerText = 'You might have entered a wrong password.';
                    this.errElement.style.display = 'inline-block';
                }
                this.spinner = false;
            } catch (error) {
                console.log('Error: ' + JSON.stringify(error));
                if (error != null) {
                    if (error.body.message === 'Invalid Email') {
                        this.errElement.innerText = 'You might have entered a wrong email.';
                    } else if (error.body.message === 'Inactive User') {
                        this.errElement.innerText = 'Your Account is inactive. Please reach out to your System Administrator for further information.';
                    }else if(error.body.message.includes("You didn't complete the approval process before it expired")) {
                        this.errElement.innerText = error.body.message;
                    } else {
                        this.errElement.innerText = error.body.message;
                    }
                    console.error(error.body.message);
                }
                this.errElement.style.display = 'inline-block';
                this.spinner = false;
            }
        }

    }
}