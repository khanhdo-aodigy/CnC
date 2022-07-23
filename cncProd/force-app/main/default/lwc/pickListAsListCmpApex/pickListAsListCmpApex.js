import { LightningElement, api, track } from 'lwc';

export default class PickListAsListCmpApex extends LightningElement {

  @api recordId;
  @api fieldLabel;
  @api apiFieldName;
  @api placeholder;
  @api fieldStyle;
  @api pickListValue;
  @api existingValue;
  @api focuson;

  @track labelStyle = '';
  @track selectedValue = '';
  @track updateRequired = false;
  @track displayPickListValue;
  @track displaySelectedValue;
  @track showOptions = false;
  @track ulClass = 'd-none select-list picklistUL';

  initialRender = true;
  renderedCallback() {
    this.displayPickListValue = this.pickListValue;

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
    if (this.focuson === 'true') {
      this.labelStyle = 'color:#0a9cfb';
    } else {
      this.labelStyle = '';
    }

    if (this.existingValue === '' || this.existingValue === undefined) {
      this.selectedValue = this.existingValue;
      this.displaySelectedValue = '';
    } else {
      this.selectedValue = this.existingValue;
      this.displaySelectedValue = this.pickListValue.find(EachRecord => EachRecord.value === this.selectedValue).label;
      this.dispatchChanges(this.selectedValue);
    }

  }

  onFocus() {
    this.showOptions = !this.showOptions;
    if (this.showOptions === true) {
      this.ulClass = "select-list picklistUL";
    } else {
      this.ulClass = "d-none select-list picklistUL";
    }
  }

  onSelectPickListValue(event) {
    this.selectedValue = event.target.dataset.item;
    this.displaySelectedValue = this.pickListValue.find(EachRecord => EachRecord.value === event.target.dataset.item).label;
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