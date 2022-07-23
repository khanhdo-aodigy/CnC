import { LightningElement } from 'lwc';

export default class SpecialToolAction extends LightningElement {

changeTap(event){
    let labelId = event.target.getAttribute("id");

    const tabs = this.template.querySelectorAll(".slds-tabs_scoped__item");
    for (const tab of tabs) {      
        tab.classList.remove('slds-is-active');
    }

    const items = this.template.querySelectorAll(".slds-tabs_scoped__content");
    for (const item of items) {      
        item.classList.add('slds-hide');
    }

    let selectedLabel = this.template.querySelector("#"+labelId);
    // add active for Tab
    selectedLabel.parentElement.classList.add('slds-is-active');


    let scopeId = "." + labelId.split("__")[0];
    let itemToShow = this.template.querySelector(scopeId);
    itemToShow.classList.remove('slds-hide');

}
}