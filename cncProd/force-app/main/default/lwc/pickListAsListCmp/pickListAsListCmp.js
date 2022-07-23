import { LightningElement, api, track } from 'lwc';

export default class PickListAsListCmp extends LightningElement {

  @api recordId;
  @api fieldLabel;
  @api apiFieldName;
  @api placeholder;
  @api fieldStyle;
  @api pickListValue;
  @api existingValue;

  @track showOptions = false;
  @track selectedValue = '';
  @track updateRequired = false;
  @track displayPickListValue;
  @track ulClass = 'd-none select-list picklistUL';

  initialRender = true;
  initialized = false;

  renderedCallback() {
    this.displayPickListValue = this.pickListValue.values && this.pickListValue.values;

    this.updateRequired === true && this.dispatchChanges(this.selectedValue);

    this.initialRender === true && this.setDefaultValue();

    this.initialRender = this.initialRender === true && false;

  }

  @api
  refreshComponent() {
    this.initialRender = true;
    this.renderedCallback()
  }

  setDefaultValue() {
    this.selectedValue = this.existingValue && this.existingValue.value;
    //console.log('TEST PICKLIST: ' + JSON.stringify(this.existingValue));
  }

  onblur(event) {
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
    this.selectedValue = event.target.dataset.item;
    this.updateRequired = true;
    this.ulClass = "d-none select-list picklistUL";
    this.showOptions = false;
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
    this.dispatchChanges(event.target.value);

  }

  dispatchChanges(value) {

    this.dispatchEvent(new CustomEvent('valuechanged', {
      detail: { [this.apiFieldName]: value }
    }));
    this.updateRequired = false;
  }

}