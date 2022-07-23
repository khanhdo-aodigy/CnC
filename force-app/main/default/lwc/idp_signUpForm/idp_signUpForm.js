import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import idpFontStyle from '@salesforce/resourceUrl/idpFontStyle';
import verifyCaptcha from '@salesforce/apex/IDPSignUpFormService.verifyCaptcha';
import checkEmail from '@salesforce/apex/IDPSignUpFormService.checkEmail';
import createUser from '@salesforce/apex/IDPSignUpFormService.createUser';
import verifyUser from '@salesforce/apex/IDPSignUpFormService.verifyUser';
import resendOTP  from '@salesforce/apex/IDPSignUpFormService.resendOTP';
// import elapsedHourExceeded__c from '@salesforce/schema/AccountActivationDetails__ChangeEvent.elapsedHourExceeded__c';

export default class Idp_signUpForm extends LightningElement 
{
    @api startURL;

    showPassword = 'utility:hide';
    
    isFirstPage  = true;
    isSecondPage = false;
    isCheckEmail = true;
    showSignupForm = false;
    isEmailSuccess = false;
    isRead = false;
    
    showCaptchaMsg = false;
    captchaMsg = '';
   
    isError = [];
    isValid = true;
   
    showModal = false;
    showTCModal = false;
    modalMsg ='';
    buttonText ='TRY AGAIN';
    isResendOTP = false;
    
    details = {'pdpa':false};
    code = [];
    response;
    spinner = true;

    reCaptchaEvtDetail = {};

    connectedCallback() 
    {
        window.addEventListener('message', this.handleReCaptchaEvt.bind(this));
        this.spinner = false;
        Promise.all([
            loadStyle(this, idpFontStyle),
        ]).then(() => {});
    }

    get inputStyle()
    {
        return "border:none; outline:none; background-color: rgb(255, 255, 255); height: 30px; font-family: Whitney;font-style: normal;font-weight: normal;font-size: 18px; line-height: 22px; box-shadow: none; background-clip: padding-box; width:100%; text-align:left;"; 
    }

    get inputStyleVerify()
    {
        return "border: 1px solid #E2E7EE;box-sizing: border-box;border-radius: 8px; background-color: rgb(255, 255, 255); height: 62px;width:48px; padding: 3px;font-size: 38px; box-shadow: none; background-clip: padding-box; text-align:center; font-weight:bold;font-family: Whitney;line-height: 46px;outline:none;"; 
    }

    get vfURL() 
    {
        return 'https://' + window.location.host + '/' + window.location.pathname.split('/')[1] + '/apex/ReCaptcha';
    }

    get lwcOrigin()
    {
        return "https://" + window.location.host;
    }

    togglePassword()
    {
        this.showPassword = this.showPassword === 'utility:hide' ? 'utility:preview' : 'utility:hide';
        let x = this.template.querySelector('input[data-id="password"]');
        x.type = x.type === 'password' ? 'text' : 'password';
        x.focus();
    }

    handleReCaptchaEvt(event) 
    {
        if (event.origin !== this.lwcOrigin) 
        {
            // Not the expected origin: Reject the message!
            return;
        }

        if (event.data) 
        {
            switch (event.data.type) 
            {
                case 'dynamic_heigh':
                    let vfFrame = this.template.querySelector('iframe');
                    if (this.showCaptchaMsg) 
                    {
                        this.showCaptchaMsg = false;  
                        this.captchaMsg = '';
                    }
                   
                    if (event.data.captchaVisible === 'visible') 
                    {
                        vfFrame.height = 500;
                    } 
                    else 
                    {
                        vfFrame.height = 150;
                    }
                    break;
                case 'verify_captcha':
                    this.reCaptchaEvtDetail = event.data;
                    this.showCaptchaMsg = false;
                    this.captchaMsg = '';
                    console.log(JSON.stringify(event.data));
                    break;
                case 'captcha_expired':
                    this.reCaptchaEvtDetail = event.data;
                    console.log(JSON.stringify(event.data));
                    break;
                default:
                    break;
            }
        }
    }

    onValueChanged(event)
    {
        if (event.target.name === 'pdpa') 
        {
            console.log('HERE');
            const checkboxEl = this.template.querySelector('label[data-id="pdpa label"]').classList;
            checkboxEl.contains('slds-checkbox-button_is-checked') ? checkboxEl.remove('slds-checkbox-button_is-checked') : checkboxEl.add('slds-checkbox-button_is-checked');
            this.details[event.target.name] = event.target.checked;
        }
        else
        {
            let isError = this.fieldValidation(event.target);
            if (!isError)
            {
                this.details[event.target.name] = event.target.value;
                this.resetError(event.target.getAttribute('data-id'));
                this.isError.includes(event.target.name) && this.isError.splice(this.isError.indexOf(event.target.name), 1);
            }   
        }
        console.log('Errors: ' + JSON.stringify(this.isError));
        console.log('Details: ' + JSON.stringify(this.details));
    }

    onFocusEvent(event)
    {
        if (this.isSecondPage)
        {
            this.template.querySelector(`input[data-id='${event.target.getAttribute('data-id')}']`).classList.add('focusOn');
        }
        else
        {
            const eventError = 'empty ' + event.target.getAttribute('data-id');
            if (!this.isValid || this.isError.includes(event.target.name) || this.isError.includes(eventError)) return;
            this.template.querySelector(`div[data-id='${event.target.getAttribute('data-id') + ' input element'}']`).classList.add('focusOn');
            this.template.querySelector(`label[data-id='${event.target.getAttribute('data-id') + ' input label'}']`).classList.add('labelFocusOn');
        }
    }

    onBlurEvent(event)
    {
        if (this.isSecondPage)
        {
            this.template.querySelector(`input[data-id='${event.target.getAttribute('data-id')}']`).classList.remove('focusOn');
        }
        else
        {
            this.template.querySelector(`div[data-id='${event.target.getAttribute('data-id') + ' input element'}']`).classList.remove('focusOn');
            this.template.querySelector(`label[data-id='${event.target.getAttribute('data-id') + ' input label'}']`).classList.remove('labelFocusOn');
        }
    }

    onKeyUpCode(event)
    {
        let currentEl = parseInt(event.target.name);
        const otpEls = [...this.template.querySelectorAll('input')];
        if (event.target.value === '')
        {
            this.code[currentEl] = '';
            if (event.target.name !== '0')
            {
               otpEls.map(el => {if (parseInt(el.name) === (currentEl - 1)) return this.template.querySelector(`input[data-id = '${el.name}']`).focus()});
            }
            console.log('Change OTP: ' + this.code);
        } 
        else
        {
            this.code[currentEl] = event.target.value.toString();
            let codeStr = this.code.join('').trim();
            if (codeStr.length === 6 && !isNaN(codeStr)) 
            {
                event.preventDefault();
                this.handleEvent('sendToApp', {'label' : 'verifyUser', 'value' : true});
                this.verify(codeStr);
            }
            otpEls.map(el => {if (parseInt(el.name) === (currentEl + 1)) return this.template.querySelector(`input[data-id = '${el.name}']`).focus()});
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
                el.innerHTML     = 'Please enter a valid email address';
                this.isError.push('email');
                this.template.querySelector('div[data-id="email input element"]').classList.add('focusOnError');
                this.template.querySelector('label[data-id="email input label"]').classList.add('labelFocusOnError');

                return true;
            }
        }

        if (data.name === 'password')
        {
            const regexPassword = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\w\W]{8,}$/;

            if (data.value)
            {
                let el = this.template.querySelector('p[data-id="password"]');
               
                if (!regexPassword.test(data.value))
                {
                    el.style.display = 'inline-block';
                    el.innerHTML     = 'Please enter a valid password.';
                    this.isError.push('password');
                    this.template.querySelector('div[data-id="password input element"]').classList.add('focusOnError');
                    this.template.querySelector('label[data-id="password input label"]').classList.add('labelFocusOnError');

                    return true;
                }
            }
        }

        if (data.name === 'firstName')
        {
            const regexName = /^[a-zA-Z0-9\s\/\@\)\(\'’.,-]{1,40}$/g; 
            if (data.value)
            {
                let el = this.template.querySelector('p[data-id="first name"]');
               
                if (!regexName.test(data.value))
                {
                    el.style.display = 'inline-block';
                    el.innerHTML     = 'Please exclude special characters except for @, ( ), –, ., ,, ’ and /.  ';
                    this.isError.push('firstName');
                    this.template.querySelector('div[data-id="first name input element"]').classList.add('focusOnError');
                    this.template.querySelector('label[data-id="first name input label"]').classList.add('labelFocusOnError');

                    return true;
                }
            }
        }

        if (data.name === 'lastName')
        {
            const regexName = /^[a-zA-Z0-9\s\/\@\)\(\'’.,-]{1,60}$/g;
            if (data.value)
            {
                let el = this.template.querySelector('p[data-id="last name"]');
               
                if (!regexName.test(data.value))
                {
                    el.style.display = 'inline-block';
                    el.innerHTML     = 'Please exclude special characters except for @, ( ), –, ., ,, ’ and /.';
                    this.isError.push("lastName");
                    this.template.querySelector('div[data-id="last name input element"]').classList.add('focusOnError');
                    this.template.querySelector('label[data-id="last name input label"]').classList.add('labelFocusOnError');

                    return true;
                }
            }
        }

        return false;
    }

    isFilled(checkValue, dataId, isRequired)
    {
        if (!isRequired) return true;

        const eventError = 'empty ' + dataId;
        if(checkValue === '' || checkValue === undefined || checkValue === null) 
        {
            let y = this.template.querySelector(`p[data-id = '${dataId}']`);
            y.style.display = 'inline-block';
            y.innerHTML     = 'Please enter your ' + dataId + '.';            

            this.template.querySelector(`div[data-id='${dataId + ' input element'}']`).classList.add('focusOnError');
            this.template.querySelector(`label[data-id='${dataId + ' input label'}']`).classList.add('labelFocusOnError');
            this.isValid = false;        
            (this.isError.includes(eventError) === false) && this.isError.push(eventError);
            
            return false;
        }
        this.isValid = true;
        this.isError.includes(eventError) && this.isError.splice(this.isError.indexOf(eventError), 1);
        
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
            const eventError = 'empty ' + inputCmp.getAttribute('data-id');
            if (!isValid && this.isError.includes(eventError) === false)
            {
                this.isError.push(eventError);
            }

            return validSoFar && isValid;
        }, true);

        console.log("All valid: " + allValid);
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

    closeModal()
    {
        this.showTCModal && (this.showTCModal = false);
        this.showModal && this.resetModal();
        if(this.isSecondPage)
        {
            this.template.querySelector('input[data-id = "0"]').focus();
            this.code = [];
            const otpEls = [...this.template.querySelectorAll('input')].map(el => this.template.querySelector(`input[data-id = '${el.name}']`).value = '');
        }
    }

    resetModal()
    {
        this.showModal = false;
        this.modalMsg  = '';
    }

    handleTC()
    {
        this.showTCModal = true;
    }

    handleEvent(name, eventData)
    {
        this.dispatchEvent(new CustomEvent(name, {
            detail: {data : eventData},
            bubbles: true,
            composed: true
        }));     
    }

    checkEmail()
    {
        if (!this.onValidate() || this.isError.length !== 0) return;
        this.spinner = true;
        this.handleEvent('sendToApp', {'label' : 'checkEmail', 'value' : true});
        checkEmail({
            email: this.details.email
        }).then(result =>
        {
            console.log('Result from APEX: ' + JSON.stringify(result));
            if (result !== null)
            {
                this.spinner = false;
                if (result === true)
                {
                    this.isCheckEmail         = false;
                    this.showSignupForm       = true;
                    this.isRead               = true;
                    this.isEmailSuccess       = true;
                    this.template.querySelector('div[data-id="email input element"]').classList.add('input-readonly');
                    this.template.querySelector('input[data-id="email"]').style.backgroundColor = '#F2F4F7';
                    this.template.querySelector('input[data-id="email"]').classList.add('input-readonly');
                    this.template.querySelector('label[data-id="email input label"]').style.color = '#314959';
                }
                else
                {
                    this.showModal     = true;
                    this.modalMsg      = 'This email is taken. Please try another email address.';
                }    
            }
        }).
        catch(error =>
        {
            console.log('Error: ' + error.body.message);
        })
    }

    doSubmit()
    {
        if (this.onValidate() && this.isError.length === 0)
        {
            if (this.reCaptchaEvtDetail.status === 'expired')
            {
                this.showCaptchaMsg = true;
                this.captchaMsg = 'Please verify the captcha again.';
                return;
            }
            // Verify reCaptcha server side
            verifyCaptcha({
                secretKey: this.reCaptchaEvtDetail.secret_key,
                reCaptchaResponse: this.reCaptchaEvtDetail.g_response
            }).then(result => {
                console.log('Captcha verified result from server :: ' + typeof(result) + ' ' + result);
                if (!result) 
                {
                    this.captchaMsg    = 'Please verify the captcha.'
                    this.showCaptchaMsg = true;
                    return;
                }
                // Call to create user
                this.spinner = true;
                this.handleEvent('sendToApp', {'label' : 'createUser', 'value' : true});
                createUser({
                    request: this.details
                }).then((result) =>
                {
                    console.log('Result: ' + JSON.stringify(result));
                    if (result !== null)
                    {
                        this.spinner      = false;
                        this.isSecondPage = true;
                        this.isFirstPage  = false;            
                        this.response     = result;
                    }
                }).
                catch((error) =>
                {
                    console.log('Error: ' + error.body.message);  
                })
            }).catch(error => {
                console.log('verified error:: ' + error.body.message);
            })       
        }
    }

    verify(verificationCode)
    {
        console.log('Id: ' + this.response);
        console.log('Code: ' + verificationCode);
        this.spinner = true;
        verifyUser({
            verificationCode: verificationCode,
            request: this.details,
            response: this.response,
            startURL: this.startURL
        }).then(result =>
        {
            console.log('Result Verify OTP: ' + result);
            if (result !== null)
            {
                this.handleEvent('verifyUserSuccess', result);
                setTimeout(function(){ this.spinner = false; }, 3000);
            }
            else
            {
                this.spinner     = false;
                this.showModal   = true;
                this.modalMsg    = 'The OTP entered is incorrect. Please try again.';
            }
        }).
        catch(error =>
        {
            console.log('Error: ' + error.body.message);   
            this.spinner     = false;
            this.showModal   = true;
            this.modalMsg    = error.body.message;
        })
    }

    resendOTP()
    {
        if (this.response)
        {
            console.log('Resend OTP');
            console.log(this.response);
            console.log(this.details);
            this.spinner = true;
            resendOTP({
                request: this.details,
                response: this.response, 
            }).then(result =>
            {
                console.log('Result Verify: ' + result);
                if (result !== null)
                {
                    this.spinner    = false;            
                    this.response   = result;
                    this.showModal  = true;
                    this.isResendOTP= true;
                    this.buttonText = 'OK';
                    this.modalMsg   = 'Another email with the code has been sent to your email.';
                }
            }).
            catch(error =>
            {
                console.log('Error: ' + error.body.message);   
            })
        }
    }
}