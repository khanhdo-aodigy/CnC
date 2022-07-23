import { LightningElement, api, track } from 'lwc';

export default class LookupFieldAsPickListCmp extends LightningElement {
  @api fieldLabel;
  @api apiFieldName;
  @api placeholder;
  @api fieldStyle;
  @api required;
  @api inHouse = false;

  @api pickListValueSet; //External


  @api currentValueId;

  @track selectedValue = '';
  @track selectedId = '';
  @track disableField = false;
  @track displayPickListValue;
  @track ulClass = 'd-none select-list picklistUL';
  @track showOptions = false;

  @track errorMsg;
  @track isError;
  initialRender = true;
  initialized = false;

  @api disableInput() {
    this.setInputFieldDisabled();
  }

  @api enableInput() {
    this.setInputFieldEnabled();

  }

  @api setErrorMsg(errorList){
    if(errorList === undefined) return;
    this.isError = true;
    this.errorMsg = errorList.errorMsg;
      this.template.querySelectorAll('label').forEach(elem=>{
          elem.style = 'color: #fc6c6c;'
      })
      this.template.querySelectorAll('input').forEach(elem=>{
          elem.style = 'border-color: #fc6c6c;'
      })
  }

  resetErrorStyle(){
    if(this.isError === false ) return; 
    this.template.querySelectorAll('label').forEach(elem=>{
        elem.style = ''
    })
    this.template.querySelectorAll('input').forEach(elem=>{
        elem.style = ''
    })
    this.isError = false;
}
  setInputFieldDisabled() {
    this.disableField = true;
    this.template.querySelectorAll('input').forEach(elem=>{
      elem.style = 'border-color: #e2e7ee;'
     })
    this.selectedValue = '';
    this.selectedValue = '';
  }

  setInputFieldEnabled() {
    this.disableField = false;
    
    this.template.querySelectorAll('input').forEach(elem=>{
      elem.style = ''
     })
  }
  @api
  setPickListValueSet(isInHouse){
    const restrictValue = isInHouse ? false : true;
    this.inHouse = this.inHouse;
    
    this.template.querySelectorAll(`li[data-isinhouse=${isInHouse}]`).forEach(elem=>{
      elem.style.display = '';
    })

    this.template.querySelectorAll(`li[data-isinhouse=${restrictValue}]`).forEach(elem=>{
      elem.style.display = 'none';
    })
    this.selectedValue = '';
    this.selectedId = '';
  }


  renderedCallback() {
    this.displayPickListValue = this.pickListValueSet && this.pickListValueSet;
    this.displayPickListValue && this.setDefaultValue();

  }

  setDefaultValue() {
    if (this.initialRender === false) return;
    let recordFound;
    // eslint-disable-next-line no-unused-expressions
    typeof this.currentValueId !== "undefined" && (this.selectedId = this.currentValueId,
      recordFound = this.displayPickListValue.find(rowData => {
        return rowData.key === this.selectedId && rowData.label;
      }));

    
    typeof recordFound !== "undefined" && (this.selectedValue = recordFound.label, this.initialRender = false);
  }

  onblur(event) {
    this.ulClass = "d-none select-list picklistUL";
  }

  onFocus() {
    this.setPickListValueSet(this.inHouse);
    this.template.querySelector('div').setAttribute('tabindex', 0);
    this.showOptions = !this.showOptions;
    if (this.showOptions === true) {
      this.ulClass = "select-list picklistUL";
    } else {
      this.ulClass = "d-none select-list picklistUL";
    }
    
  }

  onSelectPickListValue(event) {
    this.resetErrorStyle();
    this.selectedValue = event.target.dataset.item ;
    this.selectedId = event.target.dataset.key;
    this.ulClass = "d-none select-list picklistUL";
    this.showOptions = false;
    this.dispatchChanges(this.selectedId);
  }
  
  onKeyUpFilter(event) {
    const inputValue = event.target.value.toUpperCase();
    this.template.querySelectorAll('.pickValue').forEach(elem => {
      
      const itemValue = elem.innerText || elem.textContent;
      //elem.dataset.isinhouse === this.inHouse &&(elem.style.display = itemValue.toUpperCase().indexOf(inputValue) > -1 ? "" : "none");
      elem.style.display = itemValue.toUpperCase().indexOf(inputValue) > -1 ?  
                            ( elem.dataset.isinhouse === this.inHouse.toString()  ? "" : "none") : "none";
    });

    /*
    this.template.querySelectorAll('.pickValue').forEach(elem => {
      
      const itemValue = elem.innerText || elem.textContent;
      const filterKey = inputValue.toUpperCase();
      elem.style.display = itemValue.toUpperCase().indexOf(filterKey) > -1 ? "" : "none";
    });
    */

  }

  dispatchChanges(value) {

    this.dispatchEvent(new CustomEvent('valuechanged', {
      detail: { [this.apiFieldName]: value }
    }));
    this.updateRequired = false;
  }

}