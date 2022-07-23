import { LightningElement, api,track } from 'lwc';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';

export default class Dsa_digitialSalesAgreementModalEdit extends LightningElement {
    @api section;
    @api recordId;

    @track changelist = {};
    @track sectionToDisplay;
    @track isSectionShow = {'Customer' : false, 'VehiclePurchase' : false, 'Finance' : false
                            ,'TradeIn': false, 'Deposit':false };
    
    initalRender = true;
    renderedCallback(){
        this.initalRender && this.renderSection();
        this.initalRender = false;
    }

    renderSection(){
        const currentSection = this.section;
        Object.keys(this.isSectionShow).forEach(elem =>{
            this.isSectionShow[elem] = elem === currentSection ? true : false;
        });
    }

    handleChange(event){
        this.changelist = event.detail;

        //console.log(JSON.stringify(event.getParams()));
    }

    onCloseModel(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    onSaveRecord(isFinishAndClose){
        this.changelist.Id = this.recordId;
        const parent = this;
        console.log(JSON.stringify(this.changelist));
        updateSalesAgreement({
            salesAgreement : this.changelist
        }).then(()=>{
            isFinishAndClose === true && parent.onCloseModel();
        }).catch(error=>{
            this.error = error;
        })
    }

    onDoneAndSave(){
        this.onSaveRecord(true);
    }
}