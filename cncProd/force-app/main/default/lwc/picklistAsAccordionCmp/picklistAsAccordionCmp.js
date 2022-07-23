import { LightningElement, api,track } from 'lwc';

export default class PicklistAsAccordionSlotCmp extends LightningElement {
    @api fieldLabel;
    @api apiFieldName;
    @api multiSelect;
    @api listStyle;
    @api configurationPickListValue;
    @api existingValue;
    @api defaultValue;

    @track errorMsg;
    @track isError;
    @track refreshFirstTime = false;
    intialRender = true;
    

    @api
    changeSelectedStyle(selectedName){
        this.template.querySelector(`a[data-name="${selectedName}"]`).style.background = '#fc8d6c';
    }
    
    @api
    setErrorMsg(errorList){
        if(errorList === undefined) return;

        this.isError = true;
        this.errorMsg = errorList.errorMsg;
        this.template.querySelectorAll('div[class="card"]').forEach(elem=>{
            elem.style = 'border-color: #fc6c6c;border-width: thin; border-style:solid;color: #fc6c6c;'
        })
        this.template.querySelectorAll('label').forEach(elem=>{
            elem.style = 'color: #fc6c6c;'
        })
    }

    resetErrorStyle(){
        if(this.isError === false ) return; 
        this.template.querySelectorAll('div[class="card"]').forEach(elem=>{
            elem.style = ''
        })
        this.template.querySelectorAll('label').forEach(elem=>{
            elem.style = ''
        })
        this.isError = false;
    }

    renderedCallback(){
        this.intialRender && this.processExistingValue();
    }

    processExistingValue(){
        if(this.configurationPickListValue.length > 0 ){
            const selectedIndex = this.configurationPickListValue.findIndex(itemRow=> itemRow.label === this.existingValue);    
            
            //const selectedIndex = this.configurationPickListValue.findIndex(itemRow=> itemRow.selected === true);            
            selectedIndex >=0 && this.setActiveSelection(this.configurationPickListValue[selectedIndex].value, this.configurationPickListValue[selectedIndex]);
            this.intialRender = false;
            this.refreshFirstTime = true;
            
        }
    }

    onValueChangedDetected(event){
        const valueChanged = event.detail ? event.detail : event;
        this.resetErrorStyle();
        this.dispatchEvent(new CustomEvent('valuechanged', {
            detail: valueChanged //event.detail
        }));
    }

    setActiveSelection(name, selectedConfigRow)
    {
        this.setAllCollapsibleField();
        typeof selectedConfigRow.inputFields !== 'undefined' && this.displayInputField(selectedConfigRow, name);
        typeof selectedConfigRow.messageToDisplay !== 'undefined' && this.displayMessage(selectedConfigRow,name);

        this.template.querySelectorAll(`a`).forEach(element => {
            element.name === name ? element.setAttribute("aria-expanded", true) : element.setAttribute("aria-expanded", false);
        });
    }
    expandCard(event){

        const picklistConfigRow = this.configurationPickListValue[this.configurationPickListValue.findIndex(field => field.value === event.currentTarget.name)];
        const itemForUpdate = {}
        const fieldAPIName = this.apiFieldName;
        itemForUpdate[`${fieldAPIName}`] = picklistConfigRow.value;
        this.setActiveSelection(event.currentTarget.name, picklistConfigRow);
        this.onValueChangedDetected(itemForUpdate);
    }

    displayInputField(configData, selectedValue){

        configData.inputFields.forEach((inputField)=>{
            this.template.querySelectorAll(`div[data-parentnode="${selectedValue}"]`).forEach(element=>{
                inputField.apiName === element.dataset.name ? element.classList.remove('collapse') : element.classList.add('collapse') ;
            });
        });

    }

    displayMessage(configData, selectedValue){

        configData.messageToDisplay.forEach((msg)=>{
            this.template.querySelectorAll(`div[data-parentnode="${selectedValue}"]`).forEach(element=>{
                msg.msg === element.dataset.name ? element.classList.remove('collapse') : element.classList.add('collapse') ;
            });
        });

    }

    setAllCollapsibleField(){
        this.template.querySelectorAll('div[data-set="collapseFields"]').forEach(elem => {
            elem.classList.add('collapse');
        });
        this.template.querySelectorAll('a').forEach(elem => {
            elem.style.background = '';
        });
    }

}