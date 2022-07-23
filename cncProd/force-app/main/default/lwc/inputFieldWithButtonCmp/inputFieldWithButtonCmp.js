import { LightningElement, api,track } from 'lwc';

export default class InputFieldWithButtonCmp extends LightningElement {
    @api label;
    @api inputType;
    @api inputClass;
    @api fieldAPIName;
    @api placeholder;
    @api defaultValue;
    @api pattern;
    @api maxLength;
    @api defaultFromOther;

    @track fieldValue = '';
    @track disableField = false;

    initialRender = true;
    renderedCallback(){
        this.initialRender = this.initialRender && this.defaultAPIValue();
        this.fieldValue === 0 && this.hideInputField(this.fieldAPIName);
    }

    @api disableInput() {
        this.setInputFieldDisabled();
    }

    @api enableInput() {
        this.setInputFieldEnabled();

    }

    setInputFieldDisabled() {
        this.disableField = true;
        this.fieldAPIName = '';
    }

    setInputFieldEnabled() {
        this.disableField = false;
    }

    defaultAPIValue(){
        this.fieldValue = this.fieldValue ?  Math.abs(this.fieldValue) :  Math.abs(this.defaultValue);
        this.fieldValue !== '' && this.showInputField(this.fieldAPIName);
        return false;
    }

    fireFieldChangeEvt(fields) {
        
        const selectEvent = new CustomEvent('valuechanged', {
            detail: fields
        });
        this.dispatchEvent(selectEvent);
    }

    onValueChanged(event) {
      // this.fieldValue = event.target.value > 0 ? 0 -  Number(event.target.value) : Number(event.target.value);
      this.fieldValue = event.target.value;
      this.fireFieldChangeEvt({[this.fieldAPIName] : this.fieldValue});
    } 

    onClear(event){
        this.fieldValue = 0;
        this.hideInputField(this.fieldAPIName);
        this.fireFieldChangeEvt({[this.fieldAPIName] : this.fieldValue});

    }

    onAdd(event){        
        this.fieldValue = '';
        this.showInputField(event.target.dataset.addname);
    }

    hideInputField(divName){
        this.template.querySelector(`div[data-apiname="${divName}"]`).classList.add('d-none');
        this.template.querySelector(`a[data-addname="${divName}"]`).classList.remove('d-none');
    }

    showInputField(divName){
        this.template.querySelector(`div[data-apiname="${divName}"]`).classList.remove('d-none');
        this.template.querySelector(`a[data-addname="${divName}"]`).classList.add('d-none');
    }
}