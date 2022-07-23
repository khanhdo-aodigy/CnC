import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import retrieveRecords from '@salesforce/apex/twoLevelRelatedListController.doGetInformation';
import { subscribe, onError } from 'lightning/empApi';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class TwoLevelRelatedList extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api firstLevelObject;
    @api firstLevelRelationshipField;
    @api firstLevelDisplayField;
    @api secondLevelObject;
    @api secondLevelRelationshipField;
    @api secondLevelDisplayField;
    @api recordId;
    @api componentTitle;
    @api componentIcon;
    @api defaultExpandAll;
    @api platformEventChannel;
    @track firstLevelTable = [];
    @track secondLevelTable = [];
    @track recordStorage = [];
    @track wiredRecords;
    @track recordexists;
    @track noOfRecords;
    @track spinner = true;
    @track initialRender = true;
    @track expandAll = false;
    @track componentReady = false;
    @track subscription = {};

    @api firstTierOrderBy;
    @api secondTierOrderBy;


    renderedCallback() {
        if (this.initialRender) {

            //Platform event configuration (If Any)
            if (this.platformEventChannel !== undefined && this.platformEventChannel !== '') {
                this.registerErrorListener();
                const thisComponent = this;
                const messageCallback = function (response) {
                    if (response.data.payload.Refresh__c === true) {
                        thisComponent.spinner = true;
                        refreshApex(thisComponent.wiredRecords);
                    }
                }
                subscribe(this.platformEventChannel, -1, messageCallback).then(response => {
                    console.log('Subscription request sent to: ', JSON.stringify(response.channel));
                    this.subscription = response;
                });
            }
            this.initialRender = false;
        }

        //Additional UI Formating when the component has loaded properly
        if (this.componentReady === true) {
            this.componentReady = false;
            if (this.defaultExpandAll === true) {
                this.expandAll = true;
                fireEvent(this.pageRef, 'expandAllViewStatus', this.expandAll);
            }
        }
    }

    //Error on Platform Event console log
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    refreshComponentRecords() {
        refreshApex(this.wiredRecords);
    }

    @wire(retrieveRecords, {
        CurrentRecordId: '$recordId',
        FirstLevelObject: '$firstLevelObject',
        FirstLevelRelationshipField: '$firstLevelRelationshipField',
        SecondLevelObject: '$secondLevelObject',
        SecondLevelRelationshipField: '$secondLevelRelationshipField',
        FirstLevelOrderBy: '$firstTierOrderBy',
        SecondLevelOrderBy: '$secondTierOrderBy'
    })
    wiredProps(result) {
        this.spinner = true;
        this.wiredRecords = result;
        result.error && console.log(result.error);

        if (result.data) {
            if (result.data.FirstLevelRelatedList.length !== 0) {
                this.recordexists = true;
                this.noOfRecords = result.data.FirstLevelRelatedList.length.toString();
                this.processTableInformation(result.data);
                this.processResponseWrapper(result.data);
            } else {
                console.log('------------ No Record Found ------------');
                this.noOfRecords = '0';
                this.recordexists = false;
            }
            this.spinner = false;
            this.componentReady = true;
        }
    }

    //Processing table (Headers)
    processTableInformation(response) {
        let tempFirstLevelTable = [];
        let tempSecondLevelTable = [];

        let firstTierFields = response.FirstLevelFieldMapping;
        let secondTierFields = response.SecondLevelFieldMapping;

        let firstTierDisplayFields = this.firstLevelDisplayField.split(';');
        let secondTierDisplayFields = this.secondLevelDisplayField.split(';');

        firstTierDisplayFields.forEach(eachField => {
            tempFirstLevelTable.push({
                fieldName: eachField,
                fieldLabel: firstTierFields[eachField.toLowerCase()]
            })
        })

        secondTierDisplayFields.forEach(eachField => {
            tempSecondLevelTable.push({
                fieldName: eachField,
                fieldLabel: secondTierFields[eachField.toLowerCase()]
            })
        })

        this.firstLevelTable = tempFirstLevelTable;
        this.secondLevelTable = tempSecondLevelTable;
    }

    processResponseWrapper(response) {
        let firstTier = response.FirstLevelRelatedList;
        let secondTier = response.SecondLevelRelatedList;

        let firstTierDisplayFields = this.firstLevelDisplayField.split(';');
        let secondTierDisplayFields = this.secondLevelDisplayField.split(';');

        let temporaryStorage = [];

        firstTier.forEach(firstTierRecord => {
            //Process First Tier Array
            let firstTierStorage = [];
            firstTierDisplayFields.forEach(eachField => {
                if( typeof firstTierRecord[eachField] === 'number' ) {
                    var value = firstTierRecord[eachField].toFixed(2);
                    firstTierStorage.push({
                        FieldName: eachField,
                        Value: value
                    });
                } else {
                    firstTierStorage.push({
                        FieldName: eachField,
                        Value: firstTierRecord[eachField]
                    });
                }
            })

            console.log('firstTierStorage = ' + JSON.stringify(firstTierStorage));

            //Process Second Tier Array
            let secondTierStorage = [];
            secondTier.forEach(secondTierRecord => {
                if (secondTierRecord[this.secondLevelRelationshipField] === firstTierRecord.Id) {
                    let eachRecord = [];
                    secondTierDisplayFields.forEach(eachField => {
                        if( typeof secondTierRecord[eachField] === 'number' ) {
                            var value = secondTierRecord[eachField].toFixed(2);
                            eachRecord.push({
                                FieldName: eachField,
                                Value: value
                            });
                        } else {
                            eachRecord.push({
                                FieldName: eachField,
                                Value: secondTierRecord[eachField]
                            });
                        }
                        
                    })
                    secondTierStorage.push({
                        RecordDetail: eachRecord,
                        ChildId: secondTierRecord.Id
                    });
                }
            })

            //Combine The Tiers into 1 Array
            temporaryStorage.push({
                Parent: firstTierStorage,
                ParentId: firstTierRecord.Id,
                Children: secondTierStorage
            });

        })

        this.recordStorage = temporaryStorage;
        console.log('recordStorage length = ' + this.recordStorage.length);        
        console.log('recordStorage = ' + JSON.stringify(this.recordStorage));
    }

    expandAllView() {
        this.expandAll = !this.expandAll;
        fireEvent(this.pageRef, 'expandAllViewStatus', this.expandAll);
    }

}