/* eslint-disable no-unused-expressions */
import { LightningElement, api, track} from 'lwc';
import { capitalizedText } from 'c/dsp_configurationCmp';

export default class InputFieldAsCmp extends LightningElement {
    @api label;
    @api inputType;
    @api inputClass;
    @api fieldAPIName;
    @api placeholder;
    @api defaultValue;
    @api pattern;
    @api maxLength;
    @api defaultFromOther;
    @api focuson;
    @api isCap;
    @api readOnly;
    @api minValue;

    @track labelStyle = '';
    @track fieldValue = '';
    @track isError = false;
    @track errorMsg = '';
    initialRender = true;
    @track disableField = false;

    @api
    refreshComponent() {
        this.fieldValue = '';
    }

    @api setErrorMsg(errorList){
        if(errorList === undefined) return;
        this.isError = true;
        this.setErrorStyle();
    }
    
    @api
    changeDefaultValue(changeTodefaultFromOther) {
        this.fieldValue = changeTodefaultFromOther ? this.defaultFromOther : this.defaultValue;
        changeTodefaultFromOther ? (this.setInputFieldDisabled(), this.fireFieldChange()) : this.setInputFieldEnabled();
        changeTodefaultFromOther ? this.template.querySelector('input').style = "opacity:0.2" :
            this.template.querySelector('input').style = "opacity:1";
    }

    fireFieldChange() {
        const dataChange = {};
        dataChange[this.fieldAPIName] = this.fieldValue;
        this.fireFieldChangeEvt(dataChange);
    }

    @api disableInput() {
        this.setInputFieldDisabled();
        this.fieldValue = '';
    }

    @api enableInput() {
        this.setInputFieldEnabled();
    }

    setInputFieldDisabled() {
        this.disableField = true;
    }

    setInputFieldEnabled() {
        this.disableField = false;
    }

    renderedCallback() {

        if (this.initialRender) {
            
            this.labelStyle = this.focuson === true ? 'color:#0a9cfb' : '';

            this.fieldValue = typeof this.defaultValue === 'undefined' ?
                this.setVauleFromDefaultFromOther() :
                this.convertValueToPercentage(this.defaultValue);//this.defaultValue;
            
            this.readOnly === "true" && this.setInputFieldDisabled();

            this.initialRender = false;
        } 
    }

    get isTel() {
        return this.inputType === 'tel';
    }

    get isDate() {
        return this.inputType === 'date';
    }

    get isCurrencyType() {
        return this.inputClass.includes('money') && this.inputType === 'text';
    }

    get isPercentageType() {
        return this.inputClass.includes('percentage') && this.inputType === 'text';
    }

    get isTextAreaType() {
        return this.inputClass.includes('textarea');
    }

    get isValidatedField() {
        return (this.inputClass.includes('service-credit') || this.inputClass.includes('accs-credit'));
    }
    
    get isNRIC() {
        return this.inputClass.includes('nric') && this.inputType === 'text';
    }

    onValueChanged(event) {
        event.target.value = this.isCap === "true" ? capitalizedText(event.target.value) : event.target.value;
        const fieldValue =  this.isPercentageType ? String(event.target.value).replace('%','') : event.target.value;

        this.isError = this.fieldValidation(fieldValue);
     
        this.isError === true && this.setErrorStyle();
        
        if (!this.isError) {
            const fieldChanges = {};
            fieldChanges[event.target.name] = this.isDate === true ? (fieldValue === '' ? '' : new Date(fieldValue)): fieldValue;
            this.fireFieldChangeEvt(fieldChanges);
        }

        this.fieldValue =  this.convertValueToPercentage(fieldValue); //this.isPercentageType ? fieldValue + '%' : fieldValue;
        
    }

    setErrorStyle(){
        this.template.querySelectorAll('input').forEach(elem=>{
            elem.style = 'color: #fc6c6c; border-color: #fc6c6c;';
        })
        this.template.querySelectorAll('label').forEach(elem=>{
            elem.style = 'color: #fc6c6c;';
        })
    }
    
    resetError(){
        this.isError = false;
        this.errorMsg = '';

        this.template.querySelectorAll('input').forEach(elem=>{
            elem.style = '';
        })
        this.template.querySelectorAll('label').forEach(elem=>{
            elem.style = '';
        })
    }

    fieldValidation(checkValue){
        if(checkValue === '') return false;

        const regexPhone = /[6|8|9]\d{7}/;
        const regexDOB = /([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))/;
        //const regexDOB = /^((0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2})*$/;

        if (this.isTel) {
            if (checkValue.toString().length > 10 || checkValue.toString().length < 9) {
                this.errorMsg = "Phone number must be 10 numeric and start with 65."
                return true;
            }
            if (regexPhone.test(checkValue) === false) {
                this.errorMsg = "Phone number must be 10 numeric and start with 65."
                return true;
            }
        }

        if (this.isDate === true && regexDOB.test(checkValue) === false) {
            this.errorMsg = "Incorrect Date of Birth Format."
            return true;
        }

        if (this.isValidatedField) {
            if (checkValue < this.minValue){
                this.errorMsg = "Input value must start from " + this.minValue;
                return true;
            }
        }

        if (this.isNRIC) {
            if (checkValue.length !== 9) {
                this.errorMsg = "NRIC must be 9 alpha-numerics."
                return true;
            }

            if (this.validateNRIC(checkValue) === false) {
                this.errorMsg = 'Invalidate NRIC.';
                return true;
            }     
        }

        return false;
    }

    validateNRIC(checkValue) {
        checkValue = checkValue.toUpperCase();

        var i, 
        icArray = [];
        for(i = 0; i < 9; i++) {
            icArray[i] = checkValue.charAt(i);
        }

        icArray[1] = parseInt(icArray[1], 10) * 2;
        icArray[2] = parseInt(icArray[2], 10) * 7;
        icArray[3] = parseInt(icArray[3], 10) * 6;
        icArray[4] = parseInt(icArray[4], 10) * 5;
        icArray[5] = parseInt(icArray[5], 10) * 4;
        icArray[6] = parseInt(icArray[6], 10) * 3;
        icArray[7] = parseInt(icArray[7], 10) * 2;

        var weight = 0;
        for(i = 1; i < 8; i++) {
            weight += icArray[i];
        }

        var offset = (icArray[0] == "T" || icArray[0] == "G") ? 4:0;
        var temp = (offset + weight) % 11;

        var st = ["J","Z","I","H","G","F","E","D","C","B","A"];
        var fg = ["X","W","U","T","R","Q","P","N","M","L","K"];

        var theAlpha;
        if (icArray[0] == "S" || icArray[0] == "T") { theAlpha = st[temp]; }
        else if (icArray[0] == "F" || icArray[0] == "G") { theAlpha = fg[temp]; }

        return (icArray[8] === theAlpha);
    }

    fireFieldChangeEvt(fields) {
        const selectEvent = new CustomEvent('valuechanged', {
            detail: fields
        });
        this.dispatchEvent(selectEvent);
    }

    setVauleFromDefaultFromOther() {
        let value = typeof this.defaultFromOther === 'undefined' ? '' : this.defaultFromOther;
        return this.convertValueToPercentage(value) //typeof this.defaultFromOther === 'undefined' ? '' : this.defaultFromOther;
    }

    convertValueToPercentage(value){
        return this.isPercentageType === true ? (value === null ? '' : value + '%') : value;
    }

    onOffocus(event){
       // this.template.querySelector('label') && (this.template.querySelector('label').style.color  = this.template.querySelector('label').style.color === 'rgb(10, 156, 251)' ?  (this.isError ? 'color: red;' : '') : 'rgb(10, 156, 251)');
       this.template.querySelector('label') && (
        event.type === 'focus' ? ( this.resetError(),
                                    this.template.querySelector('label').classList.add('focusOn'),
                                    this.template.querySelector('label').classList.remove('focusOff')
                                    )
                                    : (this.template.querySelector('label').classList.add('focusOff'),
                                        this.template.querySelector('label').classList.remove('focusOn')));
       
       this.template.querySelector('span') && (this.template.querySelector('span').style.color  = this.template.querySelector('span').style.color === 'rgb(10, 156, 251)' ?  '' : 'rgb(10, 156, 251)');
    }

}