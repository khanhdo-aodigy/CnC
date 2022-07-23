import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import isEmailExist from '@salesforce/apex/CCL_AppService.isEmailExist';
import registerUser from '@salesforce/apex/CCL_AppService.createUser';
import verifyUser from '@salesforce/apex/CCL_AppService.verifyUser';
import resendOTP from '@salesforce/apex/CCL_AppService.resendOTP';
import cclFontStyle from '@salesforce/resourceUrl/cclFontStyle';
import getSalutationValues from '@salesforce/apex/CCL_AppService.getSalutationValues';

import assets from '@salesforce/resourceUrl/CCL_assets';

export default class ccl_registrationForm extends LightningElement {

    mobileHelpText = 'Mobile phone number must be at least 8 digits and must contain numbers only.';
    passwordHelpText = 'Password must be at least 8 characters with 1 uppercase, 1 lowercase and 1 digit. Password must not contain your email address.'
    pwdContainEmailErrMsg = 'Password must not contain your email address.'
    uenHelpText = 'Company Registration Number must be at least 6 characters.';

    uenErrorText = 'Invalid Company Registration Number';
    mobileErrorText = 'Invalid Mobile Number';
    passwordErrorText = 'Invalid Password';


    termsAndConditionsURL = 'https://www.mycarriage.sg/terms-conditions/';
    privacyStatementURL = 'https://www.mycarriage.sg/privacy-statement/';
    @wire(getSalutationValues) salutations;

    showPwdIcon = 'utility:hide';
    showConfirmPwdIcon = 'utility:hide';

    @api startURL;
    @track spinner = false;
    @track registrationDetails = {
        "customerType": "individual",
        "salutation": "Please select",
        "conSalutation": "Please select",
        "individualAgree": false,
        "corporateAgree": false,
        "individualPDPA": false,
        "contactPDPA": false
    };
    @track showRegisterPage = true;
    @track showVerificationPage = false;
    @track showSuccessPage = false;
    @track verificationCode;
    @track showCompanyForm = false;
    registrationResult;
    verifyResult;

    isError = false;
    @track isCorporate = false;
    @track showTermAndCondition = false;

    async connectedCallback() {
        await loadScript(this, assets + '/js/jquery.min.js');
        await loadScript(this, assets + '/js/bootstrap.min.js'),
            await Promise.all([
                loadStyle(this, cclFontStyle),
                loadStyle(this, assets + '/css/bootstrap.min.css'),
                loadScript(this, assets + '/js/main.js'),
            ]);

    }

    switchTab(event) {
        this.showPwdIcon = 'utility:hide';
        this.showConfirmPwdIcon = 'utility:hide';
        let selectedTab = event.currentTarget.getAttribute("data-id")
        let elem = this.template.querySelector(`[data-id="${selectedTab}"]`);
        elem.classList.add('is-active');

        if (selectedTab === "person") {
            this.registrationDetails['customerType'] = 'individual';
            this.isCorporate = false;
            let elem = this.template.querySelector(`[data-id="corporate"]`);
            elem.classList.remove('is-active');

        } else if (selectedTab === "corporate") {
            this.registrationDetails['customerType'] = 'corporate';
            this.isCorporate = true;
            let elem = this.template.querySelector(`[data-id="person"]`);
            elem.classList.remove('is-active');
        }
    }

    togglePassword()
    {
        this.showPwdIcon = this.showPwdIcon === 'utility:hide' ? 'utility:preview' : 'utility:hide';
        let x = this.template.querySelector('input[data-id="password"]');
        x.type = x.type === 'password' ? 'text' : 'password';
        x.focus();
    }

    toggleConfirmPassword()
    {
        this.showConfirmPwdIcon = this.showConfirmPwdIcon === 'utility:hide' ? 'utility:preview' : 'utility:hide';
        let x = this.template.querySelector('input[data-id="confirm-password"]');
        x.type = x.type === 'password' ? 'text' : 'password';
        x.focus();
    }

    onValueChanged(event) {
        if (event.target.type == "checkbox") {
            this.registrationDetails[event.target.name] = event.target.checked;
        } else {
            this.registrationDetails[event.target.name] = event.target.value;
            this.isFilled(event.target.value, event.target.getAttribute('data-id'), event.target.required);
        }

        if (event.target.name == "verificationCode") {
            this.verificationCode = event.target.value;
        }

        if (event.target.name == "salutation") {
            this.validateSalutation();
        }
    }

    isFilled(fieldValue, dataId, isRequired) {
        try {
            let elem = this.template.querySelector(`p[data-id = '${dataId}']`);
            if (!isRequired) {
                return true;
            } else if (/^\s*$/.test(fieldValue) || !Boolean(fieldValue) || !fieldValue) {
                elem.style.display = 'inline-block';
                elem.innerText = 'Please fill out this field.';
                elem.classList.remove("text-success");
                elem.classList.add("text-danger");
                this.isError = true;
                return false;

            } else {
                elem.style.display = 'none';
                return true;
            }
        } catch (ex) {
            console.error('isFilled() got error : ' + ex);
        }
    }

    checkEmailAvailbility(email, dataId) {
        let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
        isEmailExist({
            email: email
        }).then(result => {
            if (result !== null) {
                if (result === true) {
                    el.style.display = 'inline-block';
                    el.classList.remove("text-success");
                    el.classList.add("text-danger");
                    el.innerText = 'This email exists. Please proceed to Sign In with your existing myCarriage/myC&C/myMB account.';
                    this.isError = true;
                }
                else {
                    el.style.display = 'inline-block';
                    el.classList.remove("text-danger");
                    el.classList.add("text-success");
                    el.innerText = 'Available email';
                }
            } else {
                el.style.display = 'inline-block';
                el.classList.add("text-danger");
                el.classList.remove("text-success");
                el.innerText = 'Something went wrong, please try again';
            }
        }).catch(error => {
            console.log('Error: ' + error);
            el.style.display = 'inline-block';
            el.classList.add("text-danger");
            el.classList.remove("text-success");
            el.innerText = ex.body.message;
        })

    }

    validateFirstName(event) {
        let dataId = event.target.dataset.id;
        let firstName = event.target.value;
        let fieldNotBlank = this.isFilled(firstName, dataId, event.target.required);
        if (fieldNotBlank) {
            const firstNameRegex = /^[a-zA-Z0-9\s\/\@\)\(\'’.,-]{1,40}$/g;
            let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
            if(firstName.length > 40){
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Maximum length allowed is 40 characters';
            } else if (!firstName.match(firstNameRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Please exclude special characters except for @, ( ), –, ., ,, ’ and /.  ';
            } else {
                el.style.display = 'none';
            }
        }
    }

    validateLastName(event) {
        let dataId = event.target.dataset.id;
        let lastName = event.target.value;
        let fieldNotBlank = this.isFilled(lastName, dataId, event.target.required);
        if (fieldNotBlank) {
            const lastNameRegex = /^[a-zA-Z0-9\s\/\@\)\(\'’.,-]{1,60}$/g;
            let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
            if(lastName.length > 60){
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Maximum length allowed is 60 characters';
            } else if (!lastName.match(lastNameRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Please exclude special characters except for @, ( ), –, ., ,, ’ and /.  ';
            } else {
                el.style.display = 'none';
            }
        }
    }

    validateEmail(event) { // onblur: validate blank => validate format => check availbility
        let dataId = event.target.dataset.id;
        let inputEmail = event.target.value;
        let fieldNotBlank = this.isFilled(inputEmail, dataId, event.target.required);
        if (fieldNotBlank) {
            const emailRegex = /^((?!\.)[\w-_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$/;
            let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
            if (!inputEmail.match(emailRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = 'Invalid email format.';
                el.classList.add("text-danger");
                el.classList.remove("text-success");
            } else {
                this.checkEmailAvailbility(inputEmail, dataId);
            }
        }

    }

    validatePassword(event) {
        let dataId = event.target.dataset.id;
        let password = event.target.value;
        let fieldNotBlank = this.isFilled(password, dataId, event.target.required);
        if (fieldNotBlank) {
            const pwdRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\w\W]{8,}$/;
            let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
            let emailField = this.isCorporate ? 'contactEmail' : 'email'; 
            let loweredCaseEmail = this.registrationDetails[emailField].toLowerCase();
            let loweredCasePwd = password.toLowerCase();
            if (!password.match(pwdRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = this.passwordErrorText;
            } else if( loweredCasePwd.includes(loweredCaseEmail) || loweredCasePwd == loweredCaseEmail ) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = this.pwdContainEmailErrMsg;
            } else {
                el.style.display = 'none';
            }
        }
    }


    checkPwdMatching() {
        let el = this.template.querySelector('p[data-id="confirm-password"]');
        let isIndividual = this.registrationDetails["customerType"] == 'individual' ? true : false;
        if (isIndividual && this.registrationDetails["password"] !== this.registrationDetails["confirmPassword"]
            || !isIndividual && this.registrationDetails["contactPwd"] !== this.registrationDetails["contactConfirmPwd"]

        ) {
            this.isError = true;
            el.style.display = 'inline-block';
            el.innerText = 'Passwords do not match.';
        } else {
            el.style.display = 'none';
        }
    }

    validateMobile(event) {
        let dataId = event.target.dataset.id;
        let inputPhone = event.target.value;
        console.log(dataId);
        console.log(inputPhone);
        let fieldNotBlank = this.isFilled(inputPhone, dataId, event.target.required);
        if (fieldNotBlank) {
            const phoneRegex = /^[0-9]{8,}$/;
            let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
            if (!inputPhone.match(phoneRegex)) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = this.mobileErrorText;
            } else {
                el.style.display = 'none';
            }
        }
    }

    validateSalutation() {
        let saluElem = this.template.querySelector('p[data-id="salutation"]');
        if (    (this.registrationDetails["customerType"] == "individual" && this.registrationDetails["salutation"] === "Please select") 
             || (this.registrationDetails["customerType"] == "corporate" && this.registrationDetails["conSalutation"] === "Please select") 
        ) {
            saluElem.style.display = 'inline-block';
            saluElem.innerText = 'Please select a salutation.';
            this.isError = true;
        } else {
            saluElem.style.display = 'none';
        }
    }

    validateUEN(event) { //UEN (Unique Entity Number) aka Company Registration Number
        let dataId = event.target.dataset.id;
        let uen = event.target.value;
        console.log(dataId);
        console.log(uen);
        let fieldNotBlank = this.isFilled(uen, dataId, event.target.required);
        if (fieldNotBlank) {
            console.log('happy');
            let el = this.template.querySelector(`p[data-id ="${dataId}"]`);
            if (uen.length < 6) {
                this.isError = true;
                el.style.display = 'inline-block';
                el.innerText = this.uenErrorText;
            } else {
                el.style.display = 'none';
            }
        }
    }

    validateInput() {
        this.isError = false;
        try {
            //Validate required fields not blank
            let inputElems = this.template.querySelectorAll('input');
            for (var i = 0; i < inputElems.length; i++) {
                if (inputElems[i].type == "text") {
                    this.isFilled(inputElems[i].value, inputElems[i].getAttribute('data-id'), inputElems[i].required);
                }

                if (inputElems[i].dataset.id == "firstname") {
                    this.validateFirstName({
                        target: {
                            value: inputElems[i].value,
                            dataset: { id: "firstname" },
                            required: true
                        }
                    });
                }

                if (inputElems[i].type == "lastname") {
                    this.validateLastName({
                        target: {
                            value: inputElems[i].value,
                            dataset: { id: "lastname" },
                            required: true
                        }
                    });
                }

                if (inputElems[i].type == "email") {
                    this.validateEmail({
                        target: {
                            value: inputElems[i].value,
                            dataset: { id: "email" },
                            required: true
                        }
                    });
                }

                if (inputElems[i].type == "password") {
                    this.validatePassword({
                        target: {
                            value: inputElems[i].value,
                            dataset: { id: "password" },
                            required: true
                        }
                    });
                }

                if (inputElems[i].type == "tel") {
                    this.validateMobile({
                        target: {
                            value: inputElems[i].value,
                            dataset: { id: "mobile" },
                            required: true
                        }
                    });
                }

                if(inputElems[i].dataset.id == 'company-reg') {
                    this.validateUEN({
                        target: {
                            value: inputElems[i].value,
                            dataset: { id: "company-reg" },
                            required: true
                        }
                    });
                }
            }

            this.validateSalutation();
            this.checkPwdMatching();
        } catch (ex) {
            console.error('Validate input got exception: ' + ex);
        }
    }

    checkPolicyAgree() {
        let elem = this.template.querySelector('p[data-id="page-error"]');
        let isIndividual = this.registrationDetails["customerType"] == 'individual' ? true : false;
        if ((isIndividual && !this.registrationDetails["individualAgree"])
            || (!isIndividual && !this.registrationDetails["corporateAgree"])
        ) {
            elem.style.display = 'inline-block';
            elem.innerText = 'Please confirm that you have read, understand and consented to our terms and policy.';
            return false;
        } else {
            elem.style.display = 'none';
        }
        return true;
    }

    async handleRegister() {
        this.validateInput();
        if (!this.isError && this.checkPolicyAgree()) {
            this.spinner = true;
            try {
                const result = await registerUser({
                    request: this.registrationDetails,
                })
                if (result != null) {
                    this.registrationResult = result;
                    this.showRegisterPage = false;
                    this.showVerificationPage = true;
                }
            } catch (error) {
                console.log('Error: ' + JSON.stringify(error));
                let elem = this.template.querySelector('p[data-id="page-error"]');
                elem.style.display = 'inline-block';
                if(error.body.message == 'Your Password cannot equal or contain your user name') {
                    elem.innerText = this.pwdContainEmailErrMsg;
                } else {
                    elem.innerText = error.body.message;
                }
            }
            this.spinner = false;
        }

    }

    async verify() {
        let errorElem = this.template.querySelector('p[data-id="verification-code"]');
        errorElem.style.display = 'none';
        this.spinner = true;
        let fieldNotBlank = this.isFilled(this.verificationCode, 'verification-code', true);
        if (fieldNotBlank) {
            try {
                const result = await verifyUser({
                    verificationCode: this.verificationCode,
                    request: this.registrationDetails,
                    response: this.registrationResult,
                    startURL: this.startURL
                })
                if (result !== null) {
                    console.log('Verify User Successfully');
                    this.verifyResult = result;
                    this.showVerificationPage = false;
                    this.showSuccessPage = true;
                }
                else {
                    errorElem.style.display = 'inline-block';
                    errorElem.style.color = 'red';
                    errorElem.innerText = 'The OTP entered is incorrect. Please try again.';
                }
            } catch (error) {
                if(error.body.message.includes("You didn't complete the approval process before it expired")) {
                    this.returnToHomePage();
                }
                console.log('Error: ' + JSON.stringify(error));
                errorElem.style.display = 'inline-block';
                errorElem.style.color = 'red';
                if(error.body.message === "Token not valid") {
                    errorElem.innerText = "Invalid verification code";
                } else if(error.body.message === "Too many invalid tokens attempted"){
                    errorElem.innerText = "Too many invalid verification codes attempted";
                } else {                    
                    errorElem.innerText = error.body.message;
                }
            }
        }
        this.spinner = false;
    }

    returnToHomePage() {
        console.log('Continue To Booking');
        this.dispatchEvent(new CustomEvent('returnToHomePage', {
            detail: { data: this.verifyResult },
            bubbles: true,
            composed: true
        }));
        setTimeout(function () { this.spinner = false; }, 3000);
    }

    returnToLogin() {
        this.dispatchEvent(new CustomEvent('returnToLogin', {
            detail: { data: this.startURL },
            bubbles: true,
            composed: true
        }));
        setTimeout(function () { this.spinner = false; }, 3000);
    }



    async resendCode() {
        if (this.registrationResult) {
            this.spinner = true;
            try {
                const result = await resendOTP({
                    request: this.registrationDetails,
                    response: this.registrationResult,
                })
                if (result !== null) {
                    let el = this.template.querySelector('p[data-id="resend-code"]');
                    el.style.display = 'inline-block';
                    el.style.color = 'green';
                    el.innerText = 'Another email with the code has been sent to your email.';
                }

            } catch (error) {
                console.log('Error: ' + JSON.stringify(error));
            }
            this.spinner = false;
        }
    }

    openTerm(){
        this.showTermAndCondition = true;
    }

    closeModal(){
        this.showTermAndCondition = false;
    }

}