import { LightningElement, api, track, wire} from 'lwc';

export default class CheckboxAsCmp extends LightningElement {

    @api fieldLabel;
    @api apiFieldName;
    @api valueLabel;
    @api fieldStyle;
    @api disableField;

    @api defaultValue; 
    @api existingValue;  // Need to default value if existing is not valid
    @track fieldValue;
    @track formControl = "form-group mb1";

    @track disabled = false;
    initialRender = true;
    renderedCallback(){

        if(this.initialRender === true){
            this.disabled = this.disableField;
            this.formControl = this.disableField === true ? "form-group" : this.formControl;
            this.fieldValue = typeof this.existingValue === undefined ? this.defaultValue : this.existingValue;
            this.initialRender = false;
        }

    }

    @api 
    disableInput(){
       this.setInputFieldDisabled();
    }

    @api
    enableInput(){
        this.setInputFieldEnabled();
    }

    setInputFieldEnabled(){
        this.disabled = false;
    }

    setInputFieldDisabled(){
        this.disabled = true;
        this.fieldValue = false;
    }

    onValueChanged(event){
        //event.preventDefault();     
        this.dispatchChanges(event.target.checked);   
    }

    dispatchChanges(value){
      
        this.dispatchEvent(new CustomEvent('valuechanged', {
          detail: { [this.apiFieldName] : value}
          }));
        this.updateRequired = false;
    }

}