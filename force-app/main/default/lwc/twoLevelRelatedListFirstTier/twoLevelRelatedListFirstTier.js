import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { NavigationMixin } from 'lightning/navigation';

export default class TwoLevelRelatedListFirstTier extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api firstLevelDisplayField;
    @api secondLevelDisplayField;
    @api recordStorage;
    @track selectedRecordId;
    @track parentRecord;
    @track childRecords;
    @track childRecordsExist;
    @track initialRender = true;
    @track expandStatus = false;
    @track addBackgroundOnHover = 'background-color:white';

    renderedCallback() {
        if (this.initialRender) {
            registerListener('expandAllViewStatus', this.expandAllViewStatus, this);

            this.parentRecord = this.recordStorage.Parent;
            this.childRecords = this.recordStorage.Children;
            this.selectedRecordId = this.recordStorage.ParentId;

            if (this.childRecords.length === undefined || this.childRecords.length === 0) {
                this.childRecordsExist = false;
            } else {
                this.childRecordsExist = true;
            }

            this.initialRender = false;
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    AddColor() {
        if (this.expandStatus === false) {
            this.addBackgroundOnHover = 'background-color:#b3daff;cursor:pointer';
        }
    }

    RemoveColor() {
        if (this.expandStatus === false) {
            this.addBackgroundOnHover = 'background-color:white';
        }
    }

    fixColor() {
        if (this.expandStatus === true) {
            this.addBackgroundOnHover = 'background-color:#b3daff;cursor:pointer';
        } else {
            this.RemoveColor();
        }
    }

    expandView() {
        this.expandStatus = !this.expandStatus;
        this.fixColor();
    }

    expandAllViewStatus(data) {
        if (this.childRecordsExist === true) {
            this.expandStatus = data;
            this.fixColor();
        }
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedRecordId,
                actionName: 'view',
            },
        });
    }
}