import {LightningElement, api, track} from 'lwc';
import calloutAddressSearch from '@salesforce/apex/CalloutPostalCodeSearchLWC.searchAddressByPostalCode';

export default class AddressCalloutCmp extends LightningElement {

@api salesAgreementObj;
@api addressType;
@api fieldAPIName;

@track isErrorPostalCode = false;
@track isAddressFilled = false;
@track addressStreet = '';
@track buildingName = '';
@track postalCode = '';
@track unitFloor = '';
@track changeList = {};

@track isError = false;
@track errorMsg;

isPrimaryAddress = false;
initialRender = true;
 
@api setErrorMsg(errorList){
    if(errorList === undefined) return;
    this.isError = true;

    this.template.querySelectorAll('input[class="form-control required"]').forEach(elem=>{
        elem.style = elem.value === '' ? 'color: #fc6c6c; border-color: #fc6c6c;' : '';
        this.template.querySelector(`label[for=${elem.id}]`).style = elem.value === '' ? 'color: #fc6c6c;' : '';
    })
}

resetErrorStyle(){

    this.isError = false;
    this.errorMsg = ''
    this.template.querySelectorAll('input[class="form-control required"]').forEach(elem=>{
        elem.style = '';
        this.template.querySelector(`label[for=${elem.id}]`).style = '';
    })
}

    renderedCallback(){

        if(this.initialRender){
            this.initialRender = false;
            this.isPrimaryAddress = this.addressType === 'primary' ? true : false;

           if(this.isPrimaryAddress){
                if(typeof this.salesAgreementObj.Postal_CodeRA__c.value === 'undefined')
                    return;
                this.isAddressFilled = true;
                this.postalCode = typeof this.salesAgreementObj.Postal_CodeRA__c.value !== 'undefined' ? this.salesAgreementObj.Postal_CodeRA__c.value  : '';
                this.addressStreet = typeof this.salesAgreementObj.Street_NameRA__c.value !== 'undefined' ? this.salesAgreementObj.Street_NameRA__c.value  : '';
                this.buildingName = typeof this.salesAgreementObj.Building_NameRA__c.value !== 'undefined' ? this.salesAgreementObj.Building_NameRA__c.value  : '';
                this.unitFloor = typeof this.salesAgreementObj.Floor_UnitRA__c.value !== 'undefined' ? this.salesAgreementObj.Floor_UnitRA__c.value  : '';
            
                
           }else{

               if(typeof this.salesAgreementObj.Postal_CodeMA__c.value === 'undefined')
                return;

                this.isAddressFilled = true;
                this.postalCode = typeof this.salesAgreementObj.Postal_CodeMA__c.value !== 'undefined' ? this.salesAgreementObj.Postal_CodeMA__c.value  : '';
                this.addressStreet = typeof this.salesAgreementObj.Street_NameMA__c.value !== 'undefined' ? this.salesAgreementObj.Street_NameMA__c.value  : '';
                this.buildingName = typeof this.salesAgreementObj.Building_NameRA__c.value !== 'undefined' ? this.salesAgreementObj.Building_NameMA__c.value  : '';
                this.unitFloor = typeof this.salesAgreementObj.Floor_UnitMA__c.value !== 'undefined' ? this.salesAgreementObj.Floor_UnitMA__c.value  : '';
            
           }
        }
    }




    handleKeyUpPostal(event){
        this.resetErrorStyle();
        
        this.postalCode = event.target.value;

         if(this.postalCode.length === 6 && !isNaN(this.postalCode) ){
            event.preventDefault();
            this.searchAdress(this.postalCode);
        }

        if(isNaN(this.postalCode) || this.postalCode.length > 6){
            event.preventDefault();
            this.isErrorPostalCode = true;
        }else{
            this.isErrorPostalCode = false;
        }

}   

    searchAdress(postalCode){

     calloutAddressSearch({ postalCode })
        .then(data => { //Return Data;
                const addressChange = {};
                let apiName = '';

                console.log(JSON.stringify(data));
                this.addressStreet = data.ADDRESS !== undefined ? `${data.BLK_NO} ${data.ROAD_NAME} ` : '';
                //this.buildingName = data.BUILDING !== undefined ? data.BUILDING  : '';
                this.buildingName = data.BUILDING !== undefined ? (data.BUILDING === 'NIL' ? '' : data.BUILDING)  : '';

                apiName = this.isPrimaryAddress === true ? 'Building_NameRA__c' : 'Building_NameMA__c';
                addressChange[apiName] = this.buildingName;

                apiName = this.isPrimaryAddress === true ? 'Street_NameRA__c' : 'Street_NameMA__c';
                addressChange[apiName] = this.addressStreet;

                this.fireFieldChangeEvt(addressChange);

                this.error = undefined;
            })
        .catch(error => {
            console.log('API Search result ' +  JSON.stringify(error));
            this.addressStreet = '';
            this.buildingName =  '';
            this.error = error;
        });
        this.isAddressFilled = true;
    }

    onChangeField(event){
        const addressChange = {};
        const apiName = this.isPrimaryAddress === true ? event.target.name + 'RA__c' : event.target.name + 'MA__c';
        addressChange[apiName] = event.target.name === 'Floor_Unit' ? this.appendUnitHexToText(event.target.value) : event.target.value;
        event.target.name === 'Floor_Unit' && (event.target.value = addressChange[apiName]);
        //addressChange[apiName] = event.target.value;

        this.fireFieldChangeEvt(addressChange);

    }

    appendUnitHexToText(value){
        if (value === '' || value === null || value === undefined || value.length === 0 || !value.trim()) {
            return '';
        }
        return value.includes('#') ? value : '#' + value;
    }

    fireFieldChangeEvt(fields){

        const selectEvent = new CustomEvent('valuechanged', {
           detail: fields
        });

        this.dispatchEvent(selectEvent);
        
    }

    onfocusField(event){
        this.template.querySelectorAll('input').forEach(element => {
            console.log('-------------');
            console.log(element.name);
        });
        console.log(event.target);
    }

    onblurField(){
        this.template.querySelectorAll('input').forEach(element => {
            console.log('-------------');
        
                console.log(element.innerHTML);
        });
        console.log(event.target);
    }

   get isShowError(){
        return this.isErrorPostalCode === true;
    }
 
}