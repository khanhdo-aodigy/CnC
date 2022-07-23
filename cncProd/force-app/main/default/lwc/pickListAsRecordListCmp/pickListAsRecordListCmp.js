import { LightningElement, api, track } from 'lwc';

export default class PickListAsRecordListCmp extends LightningElement {
    @api fieldLabel;
    @api objName;
    @api placeholder;
    @api fieldStyle;
    @api pickListValue;
    @api existingValue;
    @api displayedExistingValue;
  
    @track showOptions = false;
    @track displaySelectedValue = '';
    @track updateRequired = false;
    @track displayPickListValue;
    @track ulClass = 'd-none select-list picklistUL';
  
    initialRender = true;
    initialized = false;
    selectedValue = '';
  
    renderedCallback() {
      this.displayPickListValue = this.pickListValue ? this.pickListValue : '';
  
      this.updateRequired === true && this.dispatchChanges(this.selectedValue);

      this.initialRender === true && this.setDefaultValue();

      this.initialRender = this.initialRender === true && false;
  
    }
  
    @api
    refreshComponent() {
      this.initialRender = true;
      this.renderedCallback()
    }

    @api setErrorMsg(errorList){
      if(errorList === undefined) return;
      this.isError = true;
      this.setErrorStyle();
    }

    setErrorStyle(){
      this.template.querySelectorAll('input').forEach(elem=>{
          elem.style = 'color: #fc6c6c; border-color: #fc6c6c;';
      })
      this.template.querySelectorAll('label').forEach(elem=>{
          elem.style = 'color: #fc6c6c;';
      })
      this.template.querySelectorAll('c-svg-cmp').forEach(elem=>{
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

    setDefaultValue() {
      if (this.fieldLabel === 'Registration Type') {
        this.displaySelectedValue =  this.existingValue && this.existingValue.displayValue;
        this.selectedValue = this.existingValue && this.existingValue.value;
      }
    }  
  
    onblur() {
      this.ulClass = "d-none select-list picklistUL";
    }
  
    onFocus() {
      this.template.querySelector('div').setAttribute('tabindex', 0);
      this.showOptions = !this.showOptions;
      if (this.showOptions === true) {
        this.ulClass = "select-list picklistUL";
      } else {
        this.ulClass = "d-none select-list picklistUL";
      }
    }
  
    onSelectPickListValue(event) {
      this.displaySelectedValue = event.target.dataset.label;
      this.selectedValue = event.target.dataset.item;
      this.updateRequired = true;
      this.ulClass = "d-none select-list picklistUL";
      this.showOptions = false;
      this.resetError();
    }
    onKeyUpFilter(event) {
      const inputValue = event.target.value.toUpperCase();
      this.template.querySelectorAll('.pickValue').forEach(elem => {
        const itemValue = elem.innerText || elem.textContent;
        const filterKey = inputValue.toUpperCase();
        elem.style.display = itemValue.toUpperCase().indexOf(filterKey) > -1 ? "" : "none";
      });
    }
  
    onValueChanged(event) {
      event.preventDefault(); 
      //this.isError === true && this.setErrorStyle();
      this.dispatchChanges(event.target.value); 
    }
  
    dispatchChanges(value) {
      this.dispatchEvent(new CustomEvent('valuechanged', {
        detail: { [this.objName]: value }
      }));
      this.updateRequired = false;
    }
}