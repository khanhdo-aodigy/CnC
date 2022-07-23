import { LightningElement, api } from "lwc";

export default class Piscap_LookupComponentResult extends LightningElement {
  @api record;
  @api iconName;

  selectRecord() {
    this.dispatchEvent(
      new CustomEvent("selected", {
        detail: this.record
      })
    );
  }
}