import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import retrieveRecords from '@salesforce/apex/termsAndConditionsCtl.doGetInformation';
import updateRecord from '@salesforce/apex/termsAndConditionsCtl.updateInformation';

export default class TermsAndConditions extends LightningElement {
    @api recordId;
    @api currentRecordId;
    @api identifier;
    @api styleCSS;
    @api buttonSize;
    @track activeRecordId;
    @track wiredRecords;
    @track initialRender = true;
    @track spinner = false;
    @track currentRecord;
    @track metadataRecord;
    @track displayCheckbox = false;
    @track checkboxValue = false;
    @track displayText;
    @track updateFieldAPIName;

    renderedCallback() {
        if (this.initialRender === true) {
            if (this.currentRecordId === undefined || this.currentRecordId === null) {
                this.activeRecordId = this.recordId;
            } else {
                this.activeRecordId = this.currentRecordId;
            }
            /*
            console.log('---------------- Start of T&C Code ----------------');
            console.log(this.currentRecordId);
            console.log('identifier: ' + this.identifier);
            console.log('activeRecordId: ' + this.activeRecordId);
            console.log('---------------- End of T&C Code ----------------');
            */
        }
        this.initialRender = false;
    }

    @wire(retrieveRecords, {
        CurrentRecordId: '$activeRecordId',
        FieldValue: '$identifier',
        ObjectName: 'Term_and_Condition__mdt',
        FieldName: 'Identifier__c'
    })
    wiredProps(result) {
        this.spinner = true;
        this.wiredRecords = result;
        result.error && console.log(result.error);

        if (result.data) {
            this.processWiredRecords(result.data);
            this.spinner = false;
        }
    }

    processWiredRecords(data) {
        this.metadataRecord = data.metadataRecord;
        this.displayCheckbox = data.metadataRecord.Display_Checkbox__c
        this.displayText = data.metadataRecord.Text__c;
        this.currentRecord = data.currentRecord;

        if (this.metadataRecord.Associated_Checkbox_Field_API_Name__c !== undefined) {
            this.updateFieldAPIName = this.metadataRecord.Associated_Checkbox_Field_API_Name__c;
            this.checkboxValue = this.currentRecord[this.updateFieldAPIName];
        }
    }

    updateRecord(event) {
        this.checkboxValue = !this.checkboxValue;
        if (this.updateFieldAPIName !== undefined) {
            updateRecord({
                ObjectName: this.metadataRecord.Object_API_Name__c,
                FieldName: this.updateFieldAPIName,
                FieldValue: this.checkboxValue,
                RecordId: this.activeRecordId
            })
                .then(result => {
                    refreshApex(this.wiredRecords);
                    if (result === 'updated') {
                        console.log(' Updated! Publishing Event');
                        const selectedEvent = new CustomEvent('checkboxUpdate', { name: this.updateFieldAPIName, detail: this.checkboxValue });
                        this.dispatchEvent(selectedEvent);
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }

    }
}