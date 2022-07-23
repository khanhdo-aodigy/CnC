import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class PickListAsDataListCmp extends LightningElement {

    @api recordId;
    @api fieldLabel;
    @api apiFieldName;
    @api placeholder;
    @api fieldStyle;
    @api pickListValue; 
    @api existingValue; 


    @track selectedValue = '';
    @track updateRequired = false;
    @track displayPickListValue;

    initialRender = true;
    initialized =false;

    renderedCallback(){
      this.displayPickListValue = this.pickListValue.values && this.pickListValue.values;
      this.displayPickListValue && this.template.querySelector("input").setAttribute("list", this.template.querySelector('datalist').id);
    }


    setDefaultValue(){
      this.selectedValue = this.existingValue && this.existingValue.value;
    }
    onValueChanged(event){
      event.preventDefault();     
      this.dispatchChanges(event.target.value);   

    }

    dispatchChanges(value){
      
      this.dispatchEvent(new CustomEvent('valuechanged', {
        detail: { [this.apiFieldName] : value}
        }));
      this.updateRequired = false;
    }

}