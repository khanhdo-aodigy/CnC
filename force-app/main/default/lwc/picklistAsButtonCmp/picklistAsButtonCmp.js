/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import getPickListValueOfObject from '@salesforce/apex/UserInterfaceServiceImpl.getPickListValueOfObject';

export default class PicklistAsButtonCmp extends LightningElement {
    @api objectName;
    @api picklistFieldApiName;
    @api defaultValue;
    @api componentLabel;
    @api shapeStyle;
    @api conditionalDisable;
    @api numberCol;
    @api singleEnabledValue;
  

    @track splitInto2Column = false;
    @track picklistValues = [];
    @track selectedPicklistValue;
    @track wiredRecord;

    @track disableField = false;
    @api disableInput() {
        this.setPickListAsDisabled();
        this.disableField = true;
    }

    @api enableInput() {
        this.setPickListAsEnabled();
        this.disableField = false;
    }

    @api changeValue(value) {
        this.defaultValue = value;
        this.setPickListValue(this.defaultValue);
    }

    @api refreshComponent(value) {
        if (this.conditionalDisable === true) {
            this.setPickListAsDisabled();
        } else {
            this.setPickListAsEnabled();
        }
        this.defaultValue = value;
        this.setPickListValue(this.defaultValue);
    }

    renderedCallback() {
        this.conditionalDisable === true && this.setPickListAsDisabled();

       // This is used in defect form
        if (this.numberCol === '2') {
            this.splitInto2Column = true;
        }// This is used in defect form
    }

    @wire(getPickListValueOfObject, { objectName: '$objectName', fieldAPIName: '$picklistFieldApiName' })
    getPicklistValue(result) {
        this.wiredRecord = result;
        result.error && console.log('Error! ' + result.error);

        result.data && (this.picklistValues = result.data.map(obj => ({ ...obj, style: `btn btn-radio-${this.shapeStyle}`, default: 'false' })),
                        this.setPickListValue(this.defaultValue));

    
    }

    /*
        getPicklistValue({ error, data }) {
        if (data) {

            this.picklistValues = data.map(obj => ({ ...obj, style: `btn btn-radio-${this.shapeStyle}`, default: 'false' }));
            //this.picklistValues = data.map(obj=> ({ ...obj, style: 'btn btn-radio-tick', default: 'false'}));
            this.setPickListValue(this.defaultValue);

        } else if (error) {
            // eslint-disable-next-line no-console
            console.log('cmp: pickListAsButtonCmp error:',
                error.body.errorCode,
                error.body.message
            );
        }
    }
    */




    setPickListValue(selectedValue) {
        //const returnValue = data.map(obj=> ({ ...obj, style: 'btn btn-radio-tick', default: 'false'}));
        const rowFoundIndex = this.picklistValues.findIndex(rowObj => rowObj.value === selectedValue);

        this.picklistValues.forEach((element, index) => {
            index === rowFoundIndex ? this.setElementActive(element, selectedValue) : this.setElementInActive(element);
        });

    }

    onSelectPickList(event) {
        event.preventDefault();
        if (this.disableField)
            return;

        this.setPickListValue(event.target.value);

        const selectEvent = new CustomEvent('valuechanged', {
            detail: { [this.picklistFieldApiName]: this.selectedPicklistValue }
        });
        this.dispatchEvent(selectEvent);
    }

    setPickListAsDisabled() {
        this.picklistValues.forEach(elem => {
            if (elem.value === this.singleEnabledValue) {
                elem.style = `btn btn-radio-${this.shapeStyle} active`
            } else {
                elem.style = `btn btn-radio-${this.shapeStyle} is-disabled`
            }
        });
    }

    setPickListAsEnabled() {
        this.picklistValues.forEach(elem => elem.style = `btn btn-radio-${this.shapeStyle}`);
    }

    setElementActive(elem, selectedValue) {
        elem.default = true;
        elem.style = `btn btn-radio-${this.shapeStyle} active`;
        this.selectedPicklistValue = selectedValue;
    }

    setElementInActive(elem) {
        elem.default = false;
        elem.style = `btn btn-radio-${this.shapeStyle}`;
    }
}