import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/VPO_LineItemsHistoryDashboardController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const actions = [
    {
        label: 'Full History',
        name: 'full_history',
        iconName: 'utility:archive'
    },
    {
        label: 'Compare',
        name: 'compare',
        iconName: 'utility:variable'
    },
];

const SNAPSHOT_COMPARE_IGNORE = [
    'Vehicle_Purchase_Order__c',
    'Id',
    'LastModifiedDate',
    'CreatedById',
    'LastModifiedById',
    'Name',
    'attributes',
    'SystemModstamp',
    'CreatedDate',
    'IsDeleted',
    'Color_Master__r',
    'Model_Color_Trim_Master__r',
    'Model_Master__r',
    'Model_Year_Master__r',
    'Trim_Master__r',
    'Colour_Description__c',
    'Model_Color_Trim_Master__c',
    'RecordTypeId'
];

export default class Vpo_LineItemsHistoryDashboard extends LightningElement
{
    @api recordId;

    @track lineItems = [];                  // current version

    @track snapshotLineItems = [];          // snapshot version

    @track lineItemFieldLabels = {};

    @track histories = {};

    @track history = [];

    @track compare = [];

    @track displayHistoryTracking;

    @track displaySnapshotCompare;

    @track ready;

    @track selectedPOLI = '';

    @wire(init, {recordId : '$recordId'})
    initHandler({error, data})
    {
        if (data)
        {
            console.log('data', data);

            this.processLineItemFieldLabels(data.lineItemFieldLabels);
            
            this.processLineItems(data.order.Vehicle_Purchase_Order_Line_Items__r);
            if (data.snapshot)
            {
                this.processSnapshotLineItems(data.snapshot?.Vehicle_Purchase_Order_Line_Items__r);
                this.getLineItemStatus();
            }
            else
            {
                const event = new ShowToastEvent
                ({
                        message: 'No snapshot found!',
                        variant: 'error'
                });
                this.dispatchEvent(event);
            }

            this.processHistory(data.historiesByLineItemId);

            this.ready = true;

        }
        else if (error)
        {
            console.error(error);
        }
    }

    processLineItemFieldLabels(lineItemFieldLabels)
    {
        this.lineItemFieldLabels = lineItemFieldLabels;
    }

    processLineItems(lineItems)
    {
        this.lineItems = JSON.parse(JSON.stringify(lineItems));

        // replace the lookup field value with lookup field's description
        this.replaceLookupFieldWithDescription(this.lineItems);
    }

    processSnapshotLineItems(lineItems)
    {
        this.snapshotLineItems = JSON.parse(JSON.stringify(lineItems));

        // replace the lookup field value with lookup field's description
        this.replaceLookupFieldWithDescription(this.snapshotLineItems);
    }

    replaceLookupFieldWithDescription(lineItems)
    {
        for (let lineItem of lineItems)
        {
            // store original lookup value
            lineItem.Color_Master__c_               = lineItem.Color_Master__c;
            lineItem.Model_Color_Trim_Master__c_    = lineItem.Model_Color_Trim_Master__c;
            lineItem.Trim_Master__c_                = lineItem.Trim_Master__c;
            lineItem.Model_Master__c_               = lineItem.Model_Master__c;
            lineItem.Color_Master__c_               = lineItem.Color_Master__c;
            lineItem.Model_Year_Master__c_          = lineItem.Model_Year_Master__c;

            // replace the lookup value (id) by the parent description field or name
            lineItem.Color_Master__c                = lineItem.Color_Master__r?.Color_Description__c || lineItem.Color_Master__c;
            lineItem.Model_Color_Trim_Master__c     = lineItem.Model_Color_Trim_Master__r?.Name || lineItem.Model_Color_Trim_Master__c;
            lineItem.Trim_Master__c                 = lineItem.Trim_Master__r?.Trim_Description__c || lineItem.Trim_Master__c;
            lineItem.Model_Master__c                = lineItem.Model_Master__r?.Model_Description__c || lineItem.Model_Master__c;
            lineItem.Model_Year_Master__c           = lineItem.Model_Year_Master__r?.Name || lineItem.Model_Year_Master__c;
        }
    }
    
    /**
     * compare the snapshot version vs current line items and put into Status_ field so that the lightning data table can use
     */
    getLineItemStatus()
    {
        // set default status
        for (let lineItem of this.lineItems)
        {
            lineItem.Status_ = '-';
        }

        // get Id of current line items and snapshot line items
        let lineItemIds = [];
        let snapshotLineItemIds = [];

        this.lineItems.forEach(lineItem => lineItemIds.push(lineItem.Id));
        this.snapshotLineItems.forEach(snapshotLineItem => snapshotLineItemIds.push(snapshotLineItem.Id));

        // get added line item
        for (let lineItem of this.lineItems)
        {
            if (!snapshotLineItemIds.includes(lineItem.Id))
            {
                lineItem.Status_ = 'ADDED';
                lineItem.statusCell_ = 'slds-text-color_success';
            }
        }

        // get deleted line item
        for (let snapshotLineItem of this.snapshotLineItems)
        {
            if (!lineItemIds.includes(snapshotLineItem.Id))
            {
                snapshotLineItem.Status_ = 'DELETED';
                snapshotLineItem.statusCell_ = 'slds-text-color_error';
                this.lineItems.push(snapshotLineItem);
            }
        }

        // get modified line item
        for (let lineItem of this.lineItems)
        {
            if (snapshotLineItemIds.includes(lineItem.Id))
            {
                let snapshotLineItem = this.snapshotLineItems.filter(snapshotLineItem => snapshotLineItem.Id == lineItem.Id)[0];

                for (let field in lineItem)
                {
                    if (field.endsWith('_')) continue;

                    if (SNAPSHOT_COMPARE_IGNORE.includes(field)) continue;

                    if (lineItem[field] !== snapshotLineItem[field])
                    {
                        lineItem.Status_ = 'MODIFIED';
                        break;
                    }
                }
            }
        }
    }

    processHistory(history)
    {
        this.histories = JSON.parse(JSON.stringify(history));

        // bring the owner name onto outer object so that lighting data table can use it
        // also replace the field dev name with field label for better UX
        for (let lineItem of this.lineItems)
        {
            let historiesByLineItem = this.histories[lineItem.Id];

            if (!historiesByLineItem) continue;

            for (let history of historiesByLineItem)
            {
                history.CreatedBy_ = history.CreatedBy.Name;
                history.Field_ = this.lineItemFieldLabels[history.Field] || history.Field;
            }
        }
    }

    handleRowAction(event)
    {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedPOLI = row.Name;
        
        switch (actionName)
        {
            case 'full_history':
                this.displaySnapshotCompare = false;
                this.showHistoryOfSelectedLineItem(row);
                break;
            case 'compare':
                this.displayHistoryTracking = false;
                this.compareWithSnapshotVersion(row);
                break;
            default:
        }
    }

    showHistoryOfSelectedLineItem(row)
    {
        if (row.Status_ === 'DELETED')
        {
            const event = new ShowToastEvent
            ({
                title: 'History not found',
                message: 'History of this line item has been deleted together with the item',
                variant: 'warning'
            });
            this.dispatchEvent(event);
            return;
        }

        this.history = this.histories[row.Id];

        this.displayHistoryTracking = !!this.history;
    }

    
    compareWithSnapshotVersion(row)
    {
        let currentVersion;
        let snapshotVersion;
        
        for (let lineItem of this.lineItems)
        {
            if(lineItem.Id === row.Id)
            {
                currentVersion = lineItem;
                break;
            }                    
        }
    
        for(let snapshotLineItem of this.snapshotLineItems)
        {
        
            if(snapshotLineItem.Id === row.Id)
            {
                snapshotVersion = snapshotLineItem;
                break;
            }
        }

        this.displaySnapshotCompare = true;

        let fields = Object.keys(currentVersion);

        this.compare = [];

        for(let field of fields)
        {
            // skip pseudo fields
            if (field.endsWith('_')) continue;

            // skip ingore fields
            if (SNAPSHOT_COMPARE_IGNORE.includes(field)) continue;

            let snapshotValue = row.Status_ === 'ADDED'? '' : snapshotVersion? snapshotVersion[field] : '';
            let currentValue = row.Status_ === 'DELETED'? '' : currentVersion? currentVersion[field] : '';

            let compareRow = 
            {
                field: field,
                field_: this.lineItemFieldLabels[field] || field,
                snapshotValue: snapshotValue,
                currentValue: currentValue,
                format: snapshotValue !== currentValue? 'slds-text-color_error' : ''                
            };

            this.compare.push(compareRow);

        }
    }

    toggleHistoryTracking(e)
    {
        this.displayHistoryTracking = !this.displayHistoryTracking;
    }

    toggleSnapshotCompare(e)
    {
        this.displaySnapshotCompare = !this.displaySnapshotCompare;
    }

    lineItemColumns = [
        { 
            label: 'Status', 
            fieldName: 'Status_',
            cellAttributes: {
                class: {
                    fieldName: `statusCell_`
                },
                alignment: `left`
            }
        },        
        {   label: 'Name', 
            fieldName: 'Name' 
        },
        // { label: 'Model Master', fieldName: 'Model_Master__c', type: 'url' },
        // { label: 'Trim Master', fieldName: 'Trim_Master__c', type: 'url' },
        // { label: 'Color Master', fieldName: 'Color_Master__c', type: 'url' },
        {   
            label: 'Units Ordered', 
            fieldName: 'Units_Ordered__c', 
            type: 'number' 
        },
        {   
            label: 'Units Confirmed', 
            fieldName: 'Units_Confirmed__c', 
            type: 'number'
        },
        {   
            type: 'action', 
            typeAttributes: {rowActions: actions} 
        }
    ];

    historyColumns = [
        {   label: 'Field', 
            fieldName: 'Field_', 
            type: 'text' 
        },
        {   label: 'Changed By', 
            fieldName: 'CreatedBy_', 
            type: 'text' 
        },
        {   label: 'Changed Date', 
            fieldName: 'CreatedDate', 
            type: 'text' 
        },
        {   label: 'Old Value', 
            fieldName: 'OldValue', 
            type: 'text'    
        },
        {   label: 'New Value',
            fieldName: 'NewValue', 
            type: 'text' 
        },
    ];

    compareColumns = [
        {
            label: 'Field',
            fieldName: 'field_',type: 'text',
            cellAttributes: {
                class: {
                    fieldName: `format`
                },
                alignment: `left`
            }
        },
        {
            label: 'Snapshot Value',
            fieldName: 'snapshotValue',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: `format`
                },
                alignment: `left`
            }
        },
        {
            label: 'Current Value',
            fieldName: 'currentValue',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: `format`
                },
                alignment: `left`
            }
        },        
    ];
    
}