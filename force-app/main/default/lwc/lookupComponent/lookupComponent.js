import { LightningElement, api, wire } from "lwc";
import getLookupRecords from "@salesforce/apex/LookupComponentController.getLookupRecords";
import { CurrentPageReference } from 'lightning/navigation';

const DEBOUNCE_DELAY = 300;

export default class Piscap_LookupComponent extends LightningElement {
  @api sObjApiName;
  @api label;
  @api iconName;
  @api recordId;
  @api fieldName;

  listOfSearchRecords;
  selectedRecord;
  errorMessage;

  showSearchResults;
  showSelectedRecord;
  showInputField;
  showSpinner;

  constructor() {
    super();
    this.searchTerm = "";
    this.showInputField = true;
    this.recordId = '';
  }

  renderedCallback() {
    if (this.hasAlreadyRenderedOnce) {
      return;
    }

    this.hasAlreadyRenderedOnce = true;

    window.addEventListener("click", () => {
      this.listOfSearchRecords = null;
      this.showSearchResults = false;
    });

    this.template
      .querySelector("lightning-input")
      .addEventListener("click", event => {
        event.stopPropagation();
      });
    this.template.querySelector("ul").addEventListener("click", event => {
      event.stopPropagation();
    });
  }

  onFocus() {
    if (this.searchTerm && this.searchTerm.trim().length > 0) {
      this.showSpinner = true;
      this.showSearchResults = true;
      this.fetchRecords();
    }
  }

  onChange(event) {
    this.searchTerm = event.currentTarget.value;
    if (this.searchTerm.trim().length === 0) {
      this.errorMessage = "";
      this.listOfSearchRecords = null;
      this.showSearchResults = false;
      this.showSpinner = false;
      return;
    }

    this.errorMessage = "";
    this.listOfSearchRecords = null;
    this.showSpinner = true;
    window.clearTimeout(this.delayTimeout);

    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      this.showSearchResults = true;
      this.fetchRecords();
    }, DEBOUNCE_DELAY);
  }

  fetchRecords() {
    getLookupRecords({
      sObjName: this.sObjApiName,
      searchKeyword: this.searchTerm,
      Id: this.recordId,
      fieldName: this.fieldName
    })
      .then(result => {
        if (result.length === 0) {
          this.listOfSearchRecords = null;
          this.errorMessage = "No records found";
        } else {
          this.errorMessage = "";
          this.listOfSearchRecords = result;
        }
        this.showSpinner = false;
      })
      .catch(error => console.log("Error: ", JSON.stringify(error)));
  }

  navigateToRecord(event) {
    const id = event.currentTarget.dataset.id;
    window.open(`/${id}`);
  }

  removeSelection() {
    this.showSelectedRecord = false;
    this.showInputField = true;
    this.searchTerm = "";
    this.listOfSearchRecords = null;
    this.selectedRecord = null;

    this.dispatchEvent(
      new CustomEvent("valuechanged", {
        detail: { data: this.selectedRecord }
      })
    );
  }

  get computedMainContainerClassName() {
    return this.showSearchResults
      ? "slds-form-element slds-lookup slds-is-open"
      : "slds-form-element slds-lookup slds-is-close";
  }

  get computedPillBlockClassName() {
    return this.showSelectedRecord
      ? "slds-form-element__control"
      : "slds-form-element__control slds-hide";
  }

  get computedInputClassName() {
    return this.showInputField ? "" : "slds-hide";
  }

  get computedSpinnerClassName() {
    return this.showSpinner ? "" : "slds-hide";
  }

  handleSelected(event) {
    this.selectedRecord = event.detail;
    this.showSelectedRecord = true;
    this.showInputField = false;
    this.showSearchResults = false;

    this.dispatchEvent(
      new CustomEvent("valuechanged", {
        detail: { data: this.selectedRecord }
      })
    );  
  }
}