import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TwoLevelRelatedListSecondTier extends NavigationMixin(LightningElement) {
    @api secondLevelDisplayField;
    @api recordStorage;
    @api recordNo;
    @track selectedRecordId;
    @track eachchildRecord;
    @track recordNumber;
    @track initialRender = true;
    @track addBackgroundOnHover = 'background-color:#e6f3ff';

    renderedCallback() {
        if (this.initialRender) {
            this.eachchildRecord = this.recordStorage.RecordDetail;
            this.selectedRecordId = this.recordStorage.ChildId;
            this.recordNumber = parseInt(this.recordNo) + 1;
            this.initialRender = false;

        }
    }

    AddColor() {
        this.addBackgroundOnHover = 'background-color:#b3daff;cursor:pointer';
    }

    RemoveColor() {
        this.addBackgroundOnHover = 'background-color:#e6f3ff';
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